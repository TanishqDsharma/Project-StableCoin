// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {ERC20Burnable,ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title DecentralizedStableCoin
 * @author TanishqSharma
 * Collateral Exogenous: ETH and BTC
 * Minting: Algorithimic
 * Relative Stability:Pegged to USD
 * 
 * 
 * This is the contract meant to be governed by Dsc Engine. This contract is the ERC20 implementation of our 
   ERC20 stable coin system
 * 
 */

 /** The reason we are using ERC20Burnable is that it has burn function and 
         we want this burn function as it will helo us maintain the peg price */

 contract DecentralizedStableCoin is ERC20Burnable,Ownable{

    error DecentralizedStableCoin__MustBeMoreThanZero();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();
    error DecentralizedStableCoin__NotZeroAddress();

    

    constructor() ERC20("DecentralizedStableCoin","DSC"){
    }

    function burn(uint256 _amount) public override onlyOwner {
        uint256  balance = balanceOf(msg.sender);
        if(_amount<=0){
            revert DecentralizedStableCoin__MustBeMoreThanZero(); 
        } 
        if(balance<_amount){
            revert DecentralizedStableCoin__BurnAmountExceedsBalance();
        }
        /** This super keyword basically says, hey use the burn function from the parent class which in this case is ERC20Burnable */
        super.burn(_amount);
    }

    function mint(address _to, uint256 amount) external onlyOwner returns(bool){
        if(_to==address(0)){
            revert DecentralizedStableCoin__NotZeroAddress();
        }
        if(amount<=0){
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }

        _mint(_to,amount);
        return true;

    }
}
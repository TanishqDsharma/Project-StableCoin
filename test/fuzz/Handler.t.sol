// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

//Handler is going to handle the way we call functions

import {Test,console} from "../../lib/forge-std/src/Test.sol";
import {StdInvariant} from "../../lib/forge-std/src/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "../../lib/openzeppelin-contracts/contracts/mocks/ERC20Mock.sol";

contract Handler is Test {
 
// We want to make sure that redeemCollateral is not being, before depositing the collateral. We only want 
// to call redeemCollateral if there is collateral init. So, this contract is gonna do that for us

// We need make the constructor so that the handler contract knows what the dsce engine even is

DSCEngine dsce;
DecentralizedStableCoin dsc;

ERC20Mock weth;
ERC20Mock wbtc;

uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(DSCEngine _dsce, DecentralizedStableCoin _dsc){
    // These are the contract that we want handler to handle making the calls to
            dsce=_dsce;
            dsc=_dsc;

            address[] memory collateralTokens = dsce.getCollateralTokens();
            weth = ERC20Mock(collateralTokens[0]);
            wbtc = ERC20Mock(collateralTokens[1]);


    }
    
    function mintDsc(uint256 amount) public{
        
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(msg.sender);
        
        int256 maxDscToMint = int256(collateralValueInUsd/2) - int256(totalDscMinted);

        if(maxDscToMint<0){
            return;
        }
        amount = _bound(amount, 1,uint256(maxDscToMint));
        if(amount==0){
            return;
        }

        vm.startPrank(msg.sender);

        dsce.mintDsc(amount);
        
        vm.stopPrank();
    }

    // So in your handlers whatever parameters you have are going to be randomized. So, we will make a random valid collateral to
    // deposit and then we will pick a random valid amountCollateral to deposit
    function depositCollateral(uint256 collateralSeed,uint256 amountCollateral) public{
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        // We are bounding are amountCollateral to a specific range so that it only have valid random values
        amountCollateral = _bound(amountCollateral,1,MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender,amountCollateral);
        collateral.approve(address(dsce), amountCollateral);
        dsce.depositCollateral(address(collateral),amountCollateral);
    }

    function redeemCollateral(uint256 collateralSeed,uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(address(collateral),msg.sender);
        amountCollateral = _bound(amountCollateral,0,maxCollateralToRedeem);
        if(amountCollateral==0){
            return;
        }
        vm.startPrank(msg.sender);
        dsce.redeemCollateral(address(collateral),amountCollateral);

    }

    ////////////////////////
    ///Helper Functions////
    ///////////////////////

    //This function will ensure that we will get valid collateral type not just any random invalid collateral types.
    function _getCollateralFromSeed(uint256 collateralSeed) private view returns(ERC20Mock){
        if(collateralSeed%2==0){
            return weth;
        }
    return wbtc;
     
    }
}

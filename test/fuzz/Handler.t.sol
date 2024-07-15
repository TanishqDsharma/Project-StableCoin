//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {Test,console} from "../../lib/forge-std/src/Test.sol";
import {StdInvariant} from "../../lib/forge-std/src/StdInvariant.sol";
import { DeployDSC } from "../../script/DeployDSC.s.sol";
import { DSCEngine } from "../../src/DSCEngine.sol";
import {  DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { ERC20Mock } from "../../lib/openzeppelin-contracts/contracts/mocks/ERC20Mock.sol";
import { MockV3Aggregator } from "../mocks/MockV3Aggregator.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract Handler is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max; // This allows to get max uint96


    // These are the contracts that we want handler to handle the calls too
    constructor(
        DSCEngine _dsce,
        DecentralizedStableCoin _dsc
    ) {
        dsc=_dsc;
        dsce=_dsce;
        address[] memory collateralTokens =  dsce.getCollateralTokens();
        weth=ERC20Mock(collateralTokens[0]);
        wbtc=ERC20Mock(collateralTokens[1]);

    }

    function mintDsc(uint256 amountOfDscToMint) public {
        // We should only able to mintDsc if the amount is less than collateral
        (uint256 totalDscminted,uint256 collateralValueInUsd) = dsce.getAccountInformation(msg.sender);
        int256 maxDscToMint = (int256(collateralValueInUsd/2)) - int256(totalDscminted);
        if(maxDscToMint<0){
            return;
        }
        amountOfDscToMint = bound(amountOfDscToMint,0,uint256(maxDscToMint));
        if(amountOfDscToMint<0){
            return;
        }
        vm.startPrank(msg.sender);

        dsce.mintDsc(amountOfDscToMint);
        vm.stopPrank();
    }

    // Redeem Collateral: Call this when you have collateral

    function depositCollateral(
        uint256  collateralSeed,
        uint256 amountCollateral
    ) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral,1,MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender,amountCollateral);
        collateral.approve(address(dsce),amountCollateral);
        dsce.depositCollateral(address(collateral),amountCollateral);
        vm.stopPrank();
    }

    function redeemCollateral(
        uint256 collateralSeed,
        uint256 amountCollateral) public {
            ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
            uint256 maxCollateralToRedeem =  dsce.getCollateralBalanceOfUser(address(collateral),msg.sender);
            amountCollateral = bound(amountCollateral,0,maxCollateralToRedeem);
            if(amountCollateral==0){
                return;
            }
            dsce.redeemCollateral(address(collateral),amountCollateral);
         }

    ////////////////////////
    /// Helper Functions////
    ////////////////////////


    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if(collateralSeed % 2 == 0 ){
            return weth;
        }else{
            return wbtc;
        }
    }
}
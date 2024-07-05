// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {ERC20Burnable,ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";



/**
 * @title DSCEngine
 * @author TanishqSharma
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg
 * This stablecoin has the properties
 * - Exogenous Collateral
 * - Dollar Pegged 
 * - Alogrithimically Stable
 * 
 * It is similar to DAI if DAI has no governance, no fees and was only backed WETH and WBTC
 * 
 * Our DSC System should always remain "overcollaterlized". At no point, should value of all collateral
 * <= the $ backed value of all the DSC.
 * 
 * @notice This contract is the core of the DSC system. It handles all the logic for miniting and redeeming DSC, 
 * as well as the depositing and witdrawing collateral
 * 
 * @notice This contract is very loosely based on the MakerDao DSS (DAI) System
 * 
 * 
 */

contract DSCEngine{
    function depositCollateralAndMintDsc() external {}
    function depositCollateral() external{}
    function redeemCollateralForDsc() external {}
    function redeemCollateral() external{}
    function mintDsc() external{}
    function burnDSC() external{}
    function liquidate() external{}
    function getHealthFactor() external view{}
 }
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {ERC20Burnable,ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";

import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

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

contract DSCEngine is ReentrancyGuard{



    //////////////////////// 
    ///////Errors ////////// 
    //////////////////////// 

    error DSCEngine__MoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error  DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 healthFactor);
    error DSCEngine__MintFailed();


     //////////////////////// 
    //State Variables//////// 
    //////////////////////// 

    /**This is gonna be the price feed mapping */
    mapping(address token=>address priceFeed) private s_priceFeeds;

    mapping(address user=>mapping(address token =>uint256 amount) ) private s_collateralDeposited;

    mapping(address user=>uint256 amountDscMinted) private s_DSCMinted;

    address[] private s_collateralTokens;

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD=50;
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;


    ///////////////////////////// 
    //Immutable Variables//////// 
    /////////////////////////////

    DecentralizedStableCoin private i_dsc;


    ///////////
    //Events///
    ///////////
 
    event CollateralDeposited(address indexed user, address indexed token,uint256 amount);




    //////////////////////// 
    ///////Modifiers//////// 
    //////////////////////// 

    modifier moreThanZero(uint256 amount){
        if(amount==0){
            revert DSCEngine__MoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token){
        if(s_priceFeeds[token]==address(0)){
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    //////////////////////// 
    ///////Functions//////// 
    ////////////////////////
    
    constructor(
        address[] memory tokenAddresses, 
        address[] memory priceFeedAddresses,
        address dscAddress
    ){
        if(tokenAddresses.length!=priceFeedAddresses.length){
            revert  DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        for(uint256 i=0;i<tokenAddresses.length;i++){
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }

        i_dsc = DecentralizedStableCoin(dscAddress);

        
    }


    //////////////////////// 
    //External Functions////
    ////////////////////////

    function depositCollateralAndMintDsc() external {}
    
    /**
     * 
     * @param tokenCollateralAddress  The address of the token to deposit as Collateral
     * @param amountCollateral  The amount of Collateral to Deposit
     */
    
    function depositCollateral(
        address tokenCollateralAddress, 
        uint256 amountCollateral) 
        external 
        moreThanZero(amountCollateral) 
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
        {
            //First, we need a way to track how much collateral somebody has actually deposited
            s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
            /**
             * msg.sender: who is depositing the collateral
             * tokenCollateralAddress: Token being deposited as collateral eg: WETH or WBTC
             * amoutnCollateral: Amount Token bein deposited as collateral
             */
            emit CollateralDeposited(msg.sender,tokenCollateralAddress,amountCollateral);
            bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender,address(this),amountCollateral);
            if(!success){
                revert DSCEngine__TransferFailed();
            }
        }
    
    
    
    function redeemCollateralForDsc() external {}
    function redeemCollateral() external{}
    
    
    /**
     * In order to mintDSC:
     *      1. Check if the Collateral Value is greater than the DSC
     * 
     * @param amountDSCToMint The amount of stable coin to mint
     *      For example: Someone deposited 200$ worth of WETH but only wanted to mint 20$ worth of DSC
     * 
     * @notice  They must have more collateral value than than the minimum threshold
     */
    
    function mintDsc(uint256 amountDSCToMint) external moreThanZero(amountDSCToMint) nonReentrant{
        s_DSCMinted[msg.sender]+=amountDSCToMint;
        // If they minted to much, for eg: If they have $100 WETH but minted $150 DSC we dont want this to happen

        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_dsc.mint(msg.sender,amountDSCToMint);
        if(!minted){
            revert DSCEngine__MintFailed();
        }

    }
    function burnDSC() external{}
    function liquidate() external{}
    function getHealthFactor() external view{}


    ///////////////////////////////////////////// 
    ///Private & Internal View  Functions ///////
    //////////////////////////////////////////// 

    /**
     * 
     * @param user Contains the user for which health factor calc is being done
     * Returns how close to liquidation a user is 
     * If user goes below 1, then they can get liquidated
     */
    function _healthFactor(address user) private view returns(uint256){
        //Need to get there total DSC minted 
        //Need to get there total collateral Value, make sure this value is greater than total DSC minted

        (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd*LIQUIDATION_THRESHOLD)/LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold*PRECISION)/totalDscMinted;
    }

    function _getAccountInformation(address user) private view returns(
        uint256 totalDscMinted,
        uint256 collateralValueInUsd
    ) {
        totalDscMinted = s_DSCMinted[user];//Getting Total DSC minted by user from the mapping 
        collateralValueInUsd = getAccountCollateralValue(user);
    }


    function _revertIfHealthFactorIsBroken(address user) internal view {
        //1. Check health factor (if they have enough collateral)
       //2. Revert if they do not have good health factor

       uint256 userHealthFactor = _healthFactor(user);
       if(userHealthFactor<MIN_HEALTH_FACTOR){
            revert DSCEngine__BreaksHealthFactor(userHealthFactor);
       }


    }



    ///////////////////////////////////////////// 
    ///Public & Extternal View Functions////////
    ////////////////////////////////////////////
    
    function getAccountCollateralValue(address user) public view returns(uint256 totalcollateralValueInUsd){
        //loop through each collateral token, get the amount they have deposited, and map it to price
        //to get the USD value
        for(uint256 i=0;i<s_collateralTokens.length;i++){
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalcollateralValueInUsd += getUsdValue(token,amount);
        }
        return totalcollateralValueInUsd;


    }


    function getUsdValue(address token, uint256 amount) public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (,int price,,,)=priceFeed.latestRoundData();
        // 1 ETH = 1000$ 
        // The returned value from the CL will be 1000*1e8
        return ((uint256(price)*ADDITIONAL_FEED_PRECISION) *amount)/PRECISION;}
 }
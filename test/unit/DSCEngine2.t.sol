// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;


import { DeployDSC } from "../../script/DeployDSC.s.sol";
import { DSCEngine } from "../../src/DSCEngine.sol";
import { DecentralizedStableCoin } from "../../src/DecentralizedStableCoin.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { ERC20Mock } from "../../lib/openzeppelin-contracts/contracts/mocks/ERC20Mock.sol";
import { MockV3Aggregator } from "../mocks/MockV3Aggregator.sol";
import {Test,console} from "../../lib/forge-std/src/Test.sol";

contract TestDSCEngine2 is Test {

DeployDSC public deployer ;
DecentralizedStableCoin public dsc;
HelperConfig public helperConfig; 
DSCEngine public dsce; 

address public ethUsdPriceFeed;
address public weth;
address public btcUsdPriceFeed;
address public wbtc;
uint256 deployerKey;

address user = makeAddr("USER");
uint256 public constant AMOUNT_COLLATERAL = 10e18;
uint256 public constant STARTING_BALANCE = 10e18;


    function setUp() public {
        deployer = new DeployDSC();
        (dsc,dsce,helperConfig) =deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc, deployerKey) = helperConfig.activeNetworkConfig();
        vm.deal(user, STARTING_BALANCE);
        
        ERC20Mock(weth).mint(user,AMOUNT_COLLATERAL);
        ERC20Mock(wbtc).mint(user,AMOUNT_COLLATERAL);

    }

    //////////////////////////
    ///// Constructor tests///
    //////////////////////////

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;
    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {

        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);
        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        new DSCEngine(tokenAddresses,priceFeedAddresses,address(dsc));        

    }

    //////////////////
    ///Price Tests////
    //////////////////

    function testGetTokenAmountFromUsd() public {
        vm.startPrank(user);
        uint256 expectedAmount = 2 ether;
        console.log("Expected Token Amount is :", expectedAmount);      

        uint256 actualAmount = dsce.getTokenAmountFromUsd(weth,4000e18);  
        console.log("Actual Token Amount is :", actualAmount);      
        assert(actualAmount==expectedAmount);
        vm.stopPrank();
    }

    function testGetUsdValue() public {
        vm.startPrank(user);
        uint256 expectedUSDAmount = 2000; //price in USD
        console.log("ExpectedUSDAmount amount is :", expectedUSDAmount);      

        uint256 actualUSDAmount = dsce.getUsdValue(weth,1);
        console.log("Actual USD amount is :", actualUSDAmount);      
        assert(actualUSDAmount==expectedUSDAmount);
        vm.stopPrank();
    }

    ///////////////////////////////////////
    //// DepositCollateral Tests //////////
    ///////////////////////////////////////

    function testRevertsIfTransferFromFails() public {
        
    }

    function testInsufficientDepositAmount() public{
        vm.startPrank(user);
        ERC20Mock(weth).approve(address(dsce),AMOUNT_COLLATERAL);
        vm.expectRevert(DSCEngine.DSCEngine__MoreThanZero.selector);
        dsce.depositCollateral(weth,0);
        vm.stopPrank();
    }

    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock testtoken = new ERC20Mock("Test","TST",msg.sender,100e18);
        vm.startPrank(user);
        ERC20Mock(testtoken).approve(address(dsce),10e18);
        vm.expectRevert(DSCEngine.DSCEngine__NotAllowedToken.selector);
        dsce.depositCollateral(address(testtoken),AMOUNT_COLLATERAL);
        vm.stopPrank();
    }
    
    

    modifier depositedCollateral() {
        vm.startPrank(user);
        ERC20Mock(weth).approve(address(dsce),AMOUNT_COLLATERAL);
        dsce.depositCollateral(weth,AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;}
    function testCanDepositCollateralWithoutMinting() public depositedCollateral{
        
        uint256 dscMinted = dsc.balanceOf(user);
        assert(dscMinted==0);
        assert(ERC20Mock(weth).balanceOf(user)==0);
    }

    function testCanDepositedCollateralAndGetAccountInfo() public depositedCollateral {
        vm.startPrank(user);
        (uint256 totalDscMinted,
            uint256 collateralValueInUsd) = dsce.getAccountInformation(user);
        uint256 actualCollateralValue = dsce.getUsdValue(weth,AMOUNT_COLLATERAL);
        assert(totalDscMinted==0);
        assert(collateralValueInUsd==actualCollateralValue);
        vm.stopPrank();
    }

}

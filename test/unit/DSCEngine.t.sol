// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {Test,console} from "../../lib/forge-std/src/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DSCEngine}  from "../../src/DSCEngine.sol";
import {ERC20Mock} from "../../lib/openzeppelin-contracts/contracts/mocks/ERC20Mock.sol";



contract TestDSCEngine is Test {

DecentralizedStableCoin dsc; 
DeployDSC deployer;
DSCEngine dsce;
HelperConfig config;

address ethUsdPriceFeed;
address weth;
address btcUsdPriceFeed;
address wbtc;
uint256 deployerKey;

address public user = makeAddr("USER");
uint256 public constant AMOUNT_COLLATERAL = 10 ether;
uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public{
         deployer = new DeployDSC();
        (dsc,dsce,config)=deployer.run();
        (ethUsdPriceFeed,btcUsdPriceFeed,weth,wbtc,deployerKey) = config.activeNetworkConfig();
        vm.deal(user,STARTING_ERC20_BALANCE);
        ERC20Mock(weth).mint(user, STARTING_ERC20_BALANCE);

    }

    /////////////////////// 
    //// Price Tests //////
    /////////////////////// 

    function testGetUsdValue() public view{
        uint256 ethAmount = 15e18;
        uint256 expectedValueInUSD = 30000e18;
        uint256 actualValueInUSD=dsce.getUsdValue(weth,ethAmount);
        assert(expectedValueInUSD==actualValueInUSD);

    } 

     ///////////////////////////////////
    //// Deposit Collateral Tests //////
    ////////////////////////////////////
    
    function testRevertsIfCollateralZero() public{
        vm.prank(user);
        ERC20Mock(weth).approve(address(dsce),AMOUNT_COLLATERAL);
        vm.expectRevert();
        dsce.depositCollateral(weth,0);

    }
}

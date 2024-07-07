// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployDSC is Script {
address[] public tokenAddresses;
address[] public priceFeedAddresses;


function run() external returns(DSCEngine,DecentralizedStableCoin){
    HelperConfig config = new HelperConfig();
    (address wethusdpricefeed,address wbtcusdpricefeed,address weth, address wbtc,uint256 deployerKey) = config.activeNetworkConfig();

    tokenAddresses = [weth,wbtc];
    priceFeedAddresses = [wethusdpricefeed,wbtcusdpricefeed];

    vm.startBroadcast();
    DecentralizedStableCoin dsc = new DecentralizedStableCoin();
    DSCEngine engine = new DSCEngine(tokenAddresses,priceFeedAddresses,address(dsc));
    dsc.transferOwnership(address(engine));
    vm.stopBroadcast();
    return (dsc,engine);
}    

}
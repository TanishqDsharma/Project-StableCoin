// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract DeployDecentralizedStableCoin is Script{

function run() external returns(DecentralizedStableCoin){
    
    vm.startBroadcast();
    DecentralizedStableCoin decentralizedStableCoin = new DecentralizedStableCoin();
    vm.stopBroadcast();
    return decentralizedStableCoin;
}

}
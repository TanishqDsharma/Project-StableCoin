// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract DeployDecentralizedStableCoin is Script{

uint256 public DEFAULT_ANVIL_KEY =0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
uint256 public deployerKey;

function run() external returns(DecentralizedStableCoin){

    if(block.chainid==31337){
        deployerKey = DEFAULT_ANVIL_KEY;
    }   else{
        deployerKey = vm.envUint("PRIVATE_KEY");
    }

    vm.startBroadcast(deployerKey);
    DecentralizedStableCoin decentralizedStableCoin = new DecentralizedStableCoin();
    vm.stopBroadcast();
    return decentralizedStableCoin;
}


}
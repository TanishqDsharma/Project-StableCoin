// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {Test,console} from "../lib/forge-std/src/Test.sol";
import {DeployDecentralizedStableCoin} from "../script/DeployDecentralizedStableCoin.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";


contract TestDeployDecentralizedStableCoin is Test{

uint256 public constant STARTING_BALANCE =10e18;

DeployDecentralizedStableCoin deployDSC;
DecentralizedStableCoin decentralizedStableCoin;

address user = makeAddr("USER");
address user1 = makeAddr("USER1");

address public deployerAddress;
    
    function setUp() public{
        deployDSC = new DeployDecentralizedStableCoin();
        decentralizedStableCoin = deployDSC.run();
        vm.deal(user,STARTING_BALANCE);
        deployerAddress = vm.addr(deployDSC.deployerKey());

    }


    function testNotabletoMintAtAddressZero() public {
        vm.prank(user);
        vm.expectRevert();
        decentralizedStableCoin.mint(address(0),STARTING_BALANCE);

    }
    
    function testNotabletoMintifAmountIsZero() public {
        vm.prank(user);
        vm.expectRevert();
        decentralizedStableCoin.mint(user1,0);

    }

    function testMint() public {
        vm.prank(deployerAddress);
        decentralizedStableCoin.mint(user,3000);
        uint256 DSCbalance = decentralizedStableCoin.balanceOf(user);
        assert(DSCbalance==3000);

    }

    function testBurn() public {
        vm.prank(deployerAddress);
        decentralizedStableCoin.mint(deployerAddress,3000);
        uint256 DSCbalance = decentralizedStableCoin.balanceOf(deployerAddress);
        console.log("Total DSC balance is: ",DSCbalance);
        vm.prank(deployerAddress);
        decentralizedStableCoin.burn(1000);
        uint256 newDSCbalance=decentralizedStableCoin.balanceOf(deployerAddress);
        assert(newDSCbalance==2000);
    }

}
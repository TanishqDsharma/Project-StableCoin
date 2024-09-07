// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.16;



// //  What are invariants?
// // - The total supply of dsc should be less than the total value of collateral
// // - Are getter functions should never revert


// import {Test,console} from "../../lib/forge-std/src/Test.sol";
// import {StdInvariant} from "../../lib/forge-std/src/StdInvariant.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


// //NOTE: This StdInvariant provides a targetContract function: which says this the target contract 
// // I want you to call all these random functions on 

// contract OpenInvariantsTest is StdInvariant,Test {

// DeployDSC deployer;
// DSCEngine dsce;
// DecentralizedStableCoin dsc;
// HelperConfig config;
// address weth;
// address wbtc;

//     function setUp() external{
//         deployer = new DeployDSC();

//         (dsc,dsce,config) = deployer.run();

//         (,,weth,wbtc,)=config.activeNetworkConfig();
//         targetContract(address(dsce)); // Just by adding this we are telling foundry to go wild on this
 
//     }

// // Open Invariant Testing is the easiest type of invariant testing. But doing this we wont get good results as its to open and 
// // random. Running this it will call all types of functions on our dsce and tries to break the invariant

//     function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
//         // Get the value of all of the collateral in the protocol
//         // compare it to all the debt
//         uint256 totalSupply = dsc.totalSupply();
//         uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
//         uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

//         uint256  wethvalue = dsce.getUsdValue(weth,totalWethDeposited);
//         uint256 wbtcvalue = dsce.getUsdValue(wbtc,totalWbtcDeposited);

//         console.log("weth value is:",wethvalue);
//         console.log("wbtc value is:",wbtcvalue);
//         console.log("TotalSupply value is:",totalSupply);

//         assert(wethvalue+wbtcvalue>totalSupply);



//     }


// }
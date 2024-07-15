//SPDX-License-Identifier: MIT

// This invarinace file will have our aka our properties of system that should always hold

// Whenever writing these invariance tests always ask the question
    // -> What are our invariance?
        // -> What are the properties of the system that should always hold?

// Invariance can be
    //1. Total supply of DSC should be less than total value of collateral
    //2. Getter View Functions should never revert <-  

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
    import {Handler} from "../fuzz/Handler.t.sol";
    
    
    contract InvariantsTest is StdInvariant,Test {
       DeployDSC deployer;
       DecentralizedStableCoin dsc;
       HelperConfig config;
       DSCEngine dsce;
       address wbtc;
       address weth;
    
    
       function setUp() public {
            deployer = new DeployDSC();
            (dsc,dsce,config) = deployer.run();
            (,,weth,wbtc,)=config.activeNetworkConfig();
            Handler handler = new Handler(dsce,dsc);
            targetContract(address(handler));
        }
        
        function invariant_protocolMustHaveMoreValueThanTotalSupply() public view{
            //Get value of all the collateral in the protocol
            // compare it to all the debt
    
            uint256 totalSupply = dsc.totalSupply();
            uint256 totalwethdeposited = IERC20(weth).balanceOf(address(dsce));
            uint256 totalwbtcdeposited = IERC20(wbtc).balanceOf(address(dsce));
    
            uint256 wethvalue = dsce.getUsdValue(weth,totalwethdeposited);
            uint256 wbtcvalue = dsce.getUsdValue(wbtc,totalwbtcdeposited);
    
            console.log("WETH value is: ",weth);
            console.log("WBTC value is: ",wbtc);
            console.log("Total Supply is :", totalSupply);
    
            assert(wethvalue+wbtcvalue>=totalSupply);
    
    
        }
    
    }
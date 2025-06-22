// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";
import{DevOpsTools} from "../lib/foundry-devops/test/DevOpsToolsTest.t.sol";
import{FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{
    uint256 constant SEND_VAUE = 0.1 ether;
    function fundFundMe(address mostRecentlyDelpoyed)  public {
        
        FundMe(payable(mostRecentlyDelpoyed)).fund{value: SEND_VAUE}();
        console.log("Funded FundMe with %s",SEND_VAUE);
    }

    function run() external {
        address mostRecentlyDelpoyed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentlyDelpoyed);
        vm.stopBroadcast();
    }

}
contract WithdrawFundMe is Script{
    function withdrawFundMe(address mostRecentlyDelpoyed)  public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDelpoyed)).withdraw(); 
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDelpoyed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDelpoyed);
    }
}
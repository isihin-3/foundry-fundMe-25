// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1 ;

    function setUp() external{ 
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE );
    }
    function testForCheckingMinimumUSD() public view {
        assertEq(fundMe.MINIMUM_USD() , 5e18);
    }

    function testForCheckingmsgSender() public view{
        assertEq(fundMe.i_owner(), msg.sender);
    }
    function testGetVersion() public view{
        assertEq(fundMe.getVersion(),4);
    }

    function testFundfailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdates() public{
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded , SEND_VALUE);
    }

    function testFundersAddresses() public{
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funders = fundMe.getFunders(0);
        assertEq(funders , USER);
    }

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnwerCanWithdraw() public funded{    
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();

    }

    function testWithdrawWithAsingleFunder() public funded{
        uint256 StartingOwnerBalance = address(fundMe.getOwnwer()).balance;
        uint256 StartingFundMeBalance = address (fundMe).balance;

        
        uint256 StartGas = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwnwer());
        fundMe.withdraw();
        uint256 EndGas = gasleft();
        uint256 gasUsed = (StartGas - EndGas)*tx.gasprice;
        console.log(gasUsed);

        uint256 ClosingOwnerBalance = address(fundMe.getOwnwer()).balance;
        uint256 ClosingFundMeBalance = address (fundMe).balance;
        assertEq (ClosingFundMeBalance, 0);
        assertEq (StartingFundMeBalance + StartingOwnerBalance , ClosingOwnerBalance);
    }

    function testWithdrawWithMultipleFunder() external funded{
        uint160 TotalNumberOfFunders = 10;
        for(uint160 i = 1 ; i < TotalNumberOfFunders; i++){
            hoax(address(i),STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 StartingOwnerBalance = address(fundMe.getOwnwer()).balance;
        uint256 StartingFundMeBalance = address (fundMe).balance;

        
        vm.startPrank(fundMe.getOwnwer());
        fundMe.withdraw();
        vm.stopPrank();


        uint256 ClosingOwnerBalance = address(fundMe.getOwnwer()).balance;
        uint256 ClosingFundMeBalance = address (fundMe).balance;
        assertEq (ClosingFundMeBalance, 0);
        assertEq (StartingFundMeBalance + StartingOwnerBalance , ClosingOwnerBalance);
    }

    function testWithdrawWithMultipleFunderCheaper() external funded{
        uint160 TotalNumberOfFunders = 10;
        for(uint160 i = 1 ; i < TotalNumberOfFunders; i++){
            hoax(address(i),STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 StartingOwnerBalance = address(fundMe.getOwnwer()).balance;
        uint256 StartingFundMeBalance = address (fundMe).balance;

        
        vm.startPrank(fundMe.getOwnwer());
        fundMe.cheaperWithdraw();
        vm.stopPrank();


        uint256 ClosingOwnerBalance = address(fundMe.getOwnwer()).balance;
        uint256 ClosingFundMeBalance = address (fundMe).balance;
        assertEq (ClosingFundMeBalance, 0);
        assertEq (StartingFundMeBalance + StartingOwnerBalance , ClosingOwnerBalance);
    }



    
}
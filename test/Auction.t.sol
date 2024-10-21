// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Auction} from "../src/Auction.sol";


contract AuctionTest is Test {
    Auction public auction;
    address public owner;
    address public bidder1;
    address public bidder2;
    address public bidder3;

    function setUp() public {
        owner = makeAddr("owner");
        bidder1 = makeAddr("bidder1");
        bidder2 = makeAddr("bidder2");
        bidder3 = makeAddr("bidder3");
        console.log("bidder1:", bidder1);
        console.log("bidder2:", bidder2);
        console.log("bidder3:", bidder3);
        auction = new Auction(payable(owner), block.timestamp + 10 minutes, 1 minutes);
        console.log("end time:", auction.endTime());

        //给bidder1转100个eth
        vm.deal(bidder1, 2000 ether);
        //给bidder2转100个eth
        vm.deal(bidder2, 2000 ether);
        vm.deal(bidder3, 2000 ether);
    }

    function test_Bid() public {
        console.log("end time:", auction.endTime());
        console.log("curr time:", block.timestamp);
        //输出owner的余额
        console.log("owner balance:", owner.balance);
        //输出合约的余额
        console.log("auction balance:", address(auction).balance);

        //bidder1出价100个eth
        vm.prank(bidder1);
        auction.bid{value: 100 ether}();
        //输出合约的余额
        console.log("auction balance:", address(auction).balance);

        //bidder2出价101个eth
        vm.prank(bidder2);
        auction.bid{value: 101 ether}();
        //输出合约的余额
        console.log("auction balance:", address(auction).balance);

        //输出bidder1的余额
        console.log("bidder1 balance:", bidder1.balance);
        //输出bidder2的余额
        console.log("bidder2 balance:", bidder2.balance);

        //输出owner的余额
        console.log("owner balance:", owner.balance);

        //bidder1收回出价
        vm.prank(bidder1);
        auction.withdraw();
        //输出bidder1的余额
        console.log("bidder1 balance after withdraw:", bidder1.balance);

        //输出合约的余额
        console.log("auction balance after bidder1 withdraw:", address(auction).balance);

        //修改结束时间 减少1分钟
        auction.setEndTime(auction.endTime() - 5 minutes);
        console.log("end time after set:", auction.endTime());

        //bidder3出价102个eth
        vm.prank(bidder3);
        auction.bid{value: 200 ether}();
        //查看合约的结束时间是否延长
        console.log("end time after bidder3 bid:", auction.endTime());

        //输出合约的余额
        console.log("auction balance after bidder3 bid:", address(auction).balance);

        //bidder2收回出价
        vm.prank(bidder2);
        auction.withdraw();
        //输出bidder2的余额
        console.log("bidder2 balance after withdraw:", bidder2.balance);

        //输出合约的余额
        console.log("auction balance after bidder2 withdraw:", address(auction).balance);
    }   
}

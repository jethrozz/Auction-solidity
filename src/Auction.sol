// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Auction {
    // 拍卖的收益者
    address public owner;   
    // 拍卖的结束时间
    uint256 public endTime;
    // 最高出价
    uint256 public highestBid;
    // 最高出价者
    address public highestBidder;
    // 出价者及其出价
    mapping(address => uint256) public bids;

    //定义错误
    // 出价必须大于当前最高出价
    error Auction__BidAmountMustBeHigherThanHighestBid();
    // 拍卖未激活
    error Auction__AuctionNotActive();
    // 拍卖已结束
    error Auction__AuctionEnded();
    // 拍卖已结束，无法出价
    error Auction__CannotBidAfterAuctionEnded();

    //构造函数，可指定拥有者和拍卖的结束时间
    constructor(address _owner, uint256 _endTime) {
        owner = _owner;
        endTime = _endTime;
    }

    // 出价函数，出价必须大于当前最高出价，并且大于等于当前出价
    function bid() public payable {
        // 检查拍卖是否已结束
        if (block.timestamp > endTime) {
            revert Auction__AuctionEnded();
        }
        // 检查出价是否大于当前最高出价
        if (msg.value <= highestBid) {
            revert Auction__BidAmountMustBeHigherThanHighestBid();
        }
        
    }
}
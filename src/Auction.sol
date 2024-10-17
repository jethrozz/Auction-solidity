// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Auction {
    // 拍卖的收益者
    address payable public owner;   
    // 拍卖的结束时间
    uint256 public endTime;
    // 最高出价
    uint256 public highestBid;
    // 最高出价者
    address public highestBidder;
    // 拍卖是否结束
    bool public auctionEnded = false;
    // 出价者及其出价
    mapping(address => uint256) public pendingReturns;

    //定义错误
    // 出价必须大于当前最高出价
    error AuctionBidAmountMustBeHigherThanHighestBid();
    // 拍卖已结束
    error AuctionAuctionEnded();
    // 拍卖未结束
    error AuctionAuctionNotEnded();

    //定义事件
    // 出价事件
    event BidPlaced(address bidder, uint256 amount);
    // 拍卖结束事件
    event AuctionEnded(address winner, uint256 amount);

    //构造函数，可指定收益者和拍卖的结束时间
    constructor(address _owner, uint256 _endTime) {
        owner = _owner;
        endTime = _endTime;
    }

    // 出价函数，出价必须大于当前最高出价，并且大于等于当前出价
    function bid() public payable {
        // 检查拍卖是否已结束
        if (block.timestamp > endTime) {
            revert AuctionAuctionEnded();
        }
        // 检查出价是否大于当前最高出价
        if (msg.value <= highestBid) {
            revert AuctionBidAmountMustBeHigherThanHighestBid();
        }
        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = msg.value;
        highestBidder = msg.sender;

        //发送事件
        emit BidPlaced(msg.sender, msg.value);
    }

    //收回出价
    function withdraw() public returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
        return true;
    }

    // 拍卖结束
    function endAuction() public {
        if (block.timestamp <= endTime) {
            revert AuctionAuctionNotEnded();
        }
        if(auctionEnded){
            revert AuctionAuctionEnded();
        }
        auctionEnded = true;
        emit AuctionEnded(highestBidder, highestBid);
        owner.transfer(highestBid);
    }
    

    /**
        附加题，
        1.竞拍冷却机制。同一个出价者的出价需要有时间间隔，比如1分钟。
        2.拍卖终局延长机制。拍卖结束前N分钟内，如果有人出价，则本次拍卖延长M分钟
     */
    
}
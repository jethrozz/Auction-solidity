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
    //冷却时间
    uint256 public coldDownTime;
    // 出价者及其出价
    mapping(address => uint256) public pendingReturns;
    // 出价者及其出价时间
    mapping(address => uint256) public bidderTimeMap;

    //定义错误
    // 出价必须大于当前最高出价
    error AuctionBidAmountMustBeHigherThanHighestBid();
    // 拍卖已结束
    error AuctionAuctionEnded();
    // 拍卖未结束
    error AuctionAuctionNotEnded();
    // 拍卖处于冷却时间
    error AuctionInColdDownTime();

    //定义事件
    // 出价事件
    event BidPlaced(address bidder, uint256 amount);
    // 拍卖结束事件
    event AuctionEnded(address winner, uint256 amount);

    //构造函数，可指定收益者和拍卖的结束时间
    constructor(address payable _owner, uint256 _endTime, uint256 _coldDownTime) {
        owner = _owner;
        endTime = _endTime;
        coldDownTime = _coldDownTime;
    }

    /**
        附加题，
        1.竞拍冷却机制。同一个出价者的出价需要有时间间隔，比如1分钟。
        2.拍卖终局延长机制。拍卖结束前N分钟内，如果有人出价，则本次拍卖延长M分钟
     */
    // 出价函数，出价必须大于当前最高出价，并且大于等于当前出价
    function bid() public payable {
        // 检查拍卖是否已结束

        uint256 bidTime = block.timestamp;
        if (bidTime > endTime) {
            revert AuctionAuctionEnded();
        }
        //检查是否需要延长拍卖
        checkAndExtendAuction(bidTime);

        uint256 lastBidTime = bidderTimeMap[msg.sender];
        if(lastBidTime != 0 && bidTime - lastBidTime < coldDownTime){
            revert AuctionInColdDownTime();
        }
        //重新记录出价时间
        bidderTimeMap[msg.sender] = bidTime;

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


    // 拍卖结束前N分钟内，如果有人出价，则本次拍卖延长M分钟
    function checkAndExtendAuction(uint256 bidtime) internal {
        if(endTime - bidtime < 5 minutes ){
            endTime += 1 minutes;
        }
    }


    
}
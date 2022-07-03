// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ImageNFT.sol";

contract ImageAuction is ImageNFT {
    struct Bidder {
        uint256 addr;
    }

    struct Auction {
        uint256 imageID;
        uint256 startBid;
        uint256 highestBid;
        address payable winner;
        uint256 endTime;
        bool ended;
        bool claimed;
        uint256[] bidders;
    }
    mapping(address => uint256) public pendingReturns; // 차순위 가격들을 등록하는 테이블(환불 처리를 위한)
    mapping(uint256 => Auction) public auctions;
    event HighestBidIncreased(address bidder, uint256 amount); // 가장 높게 응찰한 금액과 구매자를 블록체인 로그에 기록
    mapping(uint256 => mapping(address => uint256)) public bidInfo;

    constructor() {}

    modifier notOnBid(uint256 _tokenID) {
        require(
            imageStorage[_tokenID].status == Status.OffBid,
            "Already on auction."
        );
        _;
    }

    function beginAuction(
        uint256 _tokenID,
        uint256 _minBid,
        uint256 _duration
    ) external notOnBid(_tokenID) returns (bool success) {
        Image storage image = imageStorage[_tokenID];
        require(
            image.currentOwner == msg.sender,
            "Only Owner Can Begin a Auction."
        );

        updateStatus(_tokenID, Status.OnBid);
        updatePrice(_tokenID, _minBid);
        uint256 _endTime = _duration;

        Auction memory newAuction;
        newAuction.imageID = _tokenID;
        newAuction.startBid = _minBid;
        newAuction.highestBid = _tokenID;
        newAuction.winner = payable(msg.sender);
        newAuction.endTime = _endTime;
        newAuction.ended = false;
        newAuction.claimed = false;

        // newAuction.bidders = _tokenID;
        //     _tokenID, // Auction memory newAuction = Auction(
        //     _minBid,
        //     _minBid,
        //     payable(msg.sender),
        //     _endTime,
        //     false,
        //     false
        // );

        auctions[_tokenID] = newAuction;
        return true;
    }

    function bid(uint256 auctionID, uint256 newBid)
        external
        payable
        returns (bool success)
    {
        Auction storage auction = auctions[auctionID];
        require(!auction.ended, "Auction already ended.");
        require(newBid > auction.highestBid, "Lower bid? Joking.");

        updatePrice(auction.imageID, newBid);

        // 기존 최고 입찰 금액을 차순위 가격 등록 테이블에 누적하여 매핑
        // 왜 누적하여 매핑하는가?
        // A가 2번, B가 2번 총 4번의 입찰이 진행되었다고 가정해본다면,
        // B가 10으로 입찰하고, A가 20으로 다시 입찰, 그 후 B가 30으로 입찰 한 뒤 A가 40으로 다시 입찰이
        // 진행되었다고 할때
        // B가 처음 입찰하여 최고입찰자가 되면 최고입찰 금액도 변경됨
        // A가 입찰시 기존 최고 입찰자였던 B는 차순위로 밀리게 되고 해당 금액에 대한 정보는 차순위 등록 테이블에 기록 B => 10
        // B가 다시 입찰시 A는 차순위로 밀려 테이블에 기록이 됨 A => 20
        // 마지막으로 A가 입찰시 B는 차순위로 밀려 테이블에 기록이되는데 기존 금액에 추가가 되어야하므로 +=를 사용하여 매핑
        // 즉, B => 40이 되어야함
        pendingReturns[auction.winner] += auction.highestBid;
        bidInfo[auctionID][msg.sender] += newBid;
        // auction.bidders.push(Bidder(auctionID));
        auction.winner = payable(msg.sender);
        auction.highestBid = newBid;
        // 새로운 최고 입찰 금액 로그 기록
        emit HighestBidIncreased(msg.sender, newBid);
        // bidInfo[auctionID][msg.sender] = newBid;
        return true;
    }

    function endAuction(uint256 auctionID) external returns (bool success) {
        Image storage image = imageStorage[auctionID];
        require(
            image.currentOwner == msg.sender,
            "Only Owner Can End a Auction."
        );

        Auction storage auction = auctions[auctionID];
        require(block.timestamp >= auction.endTime, "Not end time.");
        require(!auction.ended, "Already Ended.");
        if (auction.winner == msg.sender) {
            updateStatus(auction.imageID, Status.OffBid);
        } else {
            updateStatus(auction.imageID, Status.WaittingClaim);
        }

        auction.ended = true;
        return true;
    }

    function claim(uint256 auctionID) external payable {
        Auction storage auction = auctions[auctionID];
        Image storage image = imageStorage[auctionID];
        require(auction.ended, "Auction not ended yet.");
        require(!auction.claimed, "Auction already claimed.");
        require(auction.winner == msg.sender, "Can only be claimed by winner.");

        address owner = image.currentOwner;
        payable(owner).transfer(msg.value);
        updateOwner(auction.imageID, msg.sender);
        updateStatus(auction.imageID, Status.OffBid);
    }
}

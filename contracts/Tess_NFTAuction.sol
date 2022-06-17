// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./Tess_NFT.sol";
//전에 설정해논거 상속받
contract NftDataAuction is DataNFT{
 
   struct Auction{
       //이미지if 설정
       uint256 nftDataID;
       //시작가격
        uint256 startBid;
        //최종가격
        uint256 highestBid;
        //승자
        address payable winner;
        //끝나는 날자
        uint256 endTime;
        //옥션끝
        bool ended;
        bool claimed;
   }
     
//옥션결과조회할거
    mapping (uint256 => Auction)public auctions;

    //입찰정보 조회할거여 //비공개
    mapping(uint256 =>mapping (address =>uint256)) internal bidInfo;

    constructor(){}
   //입찰하지  않음
    modifier notOnBid(uint256 _tokenID){
        require(
            nftDataStorage[_tokenID].status == Status.OffBid,
            "Already on auction"
        );
        _;
    }
    //소유자만 경매 할수 있게 토큰아이디의 오너와 소유주가 같은지 아닌지 확인
    //아니면 에러반환
    function beginAuction(
        uint256 _tokenID,
        uint256 _minBid,
        uint256 _duration
    )external notOnBid(_tokenID)returns (bool success){
        require(
            ownerOf(_tokenID)==msg.sender,
            "Only Owner Can Begin a Auction."
        );
       //상태를 업데이트 해주고
        updateStatus(_tokenID, Status.OnBid);
        //가격도 없데이트
        updatePrice(_tokenID, _minBid);
        //경매 끝나는 시간도 설정해주고
         uint256 _endTime = block.timestamp + _duration;

       // 옥션의 정보를 변경해 줄거야
         Auction memory newAuction = Auction(
            _tokenID,
            _minBid,
            _minBid,
            
            payable(msg.sender),
            _endTime,
            false,
            false
        );
        //옥션에 데이터를 넣어주고
          auctions[_tokenID] = newAuction;
          return true;
    }


    //경매 참가할거여
    //옥션참가 아이디와 새로운 가격을 넣어줄거여
    function bid(uint256 auctionID,uint256 newBid)
    external
    returns (bool success){
        Auction storage auction = auctions[auctionID];
        //옥션의 끝나지 않앗으면 에러발생
        require(!auction.ended,"Auction already ended.");
        //현재가격보다 낮으면 에러를 발생
         require(newBid > auction.highestBid, "Lower bid? Joking.");
         //가격을 새로 저장
          updatePrice(auction.nftDataID, newBid);
             //옥션의 승자
             auction.winner = payable(msg.sender);
             
              auction.highestBid = newBid;
              bidInfo[auctionID][msg.sender] = newBid;
        return true;
    }
    
    function endAuction(uint256 auctionID) external returns (bool success) {
        require(
            ownerOf(auctionID) == msg.sender,
            "Only Owner Can End a Auction."
        );

        Auction storage auction = auctions[auctionID];
        require(block.timestamp >= auction.endTime, "Not end time.");
        require(!auction.ended, "Already Ended.");

        updateStatus(auction.nftDataID, Status.WaittingClaim);
        auction.ended = true;
        return true;
    }

      function claim(uint256 auctionID) external payable {
        Auction storage auction = auctions[auctionID];

        require(auction.ended, "Auction not ended yet.");
        require(!auction.claimed, "Auction already claimed.");
        require(auction.winner == msg.sender, "Can only be claimed by winner.");

        address owner = ownerOf(auction.nftDataID);
        payable(owner).transfer(msg.value);
        updateOwner(auction.nftDataID, msg.sender);
        updateStatus(auction.nftDataID, Status.OffBid);
    }
}
pragma solidity ^0.8.0;


import "./Tess_NFT.sol";
 //구매판매 페이지를 만들거임 
 //설계 어케해야하나
 //설계구조
 //1.가격입력 => 소유자가 판매를 누르면 => 가격창이 뜨고 입력하면 판매에 등록이 되고 => 가격이설정이 된가격에 구입 => 구입성공하게 되면 owner가 구입자로 변경
 //2.업체에서만 등록을하고 => 소유자는 사면 owner가 댐
 //데이터는 가격,id ,uri?인가

contract NftDataMart is DataNFT{
       struct Market{
       //이미지id 설정
    //    uint256 nftDataID;
   
    //     //최종가격
    //     uint256 MarketPrice;
      
    //     //끝나는 날자
    //     uint256 endTime;
  
        
   }
    
      mapping (uint256 => Market)public markets;

      //입찰정보 조회할거여 //비공개
      mapping(uint256 =>mapping (address =>uint256)) internal bidInfo;
     constructor(){}


        modifier notOnBid(uint256 _tokenID){
        require(
            nftDataStorage[_tokenID].status == Status.OffBid,
            "Already on auction"
        );
        _;
    }
    function beginMarket(
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
         Market memory newMarket = Market(
            // _tokenID,
            // _minBid,
            // _minBid,
            
            // payable(msg.sender),
            // _endTime,
            // false,
            // false
        );
        //옥션에 데이터를 넣어주고
          markets[_tokenID] = newMarket;
          return true;
    }
}
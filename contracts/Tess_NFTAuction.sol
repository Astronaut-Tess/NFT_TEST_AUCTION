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


}
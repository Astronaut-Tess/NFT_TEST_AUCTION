pragma solidity ^0.8.13;


contract DataNFT{
     enum Status {
        OffBid, OnBid, WaittingClaim
    }
    struct NftData{
         uint256 tokenID;
        string tokenName;
        string tokenURI;
        address mintedBy;
        address currentOwner;
        uint256 transferTime;
        uint256 highestBidPrice;
        Status status;
        
    }
}
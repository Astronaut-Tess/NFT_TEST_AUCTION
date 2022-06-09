pragma solidity ^0.8.13;

import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//함수 하나 이상 잇어야 에러 안나지
contract DataNFT is ERC721URIStorage {
     enum Status {
        OffBid, OnBid, WaittingClaim
    }
    //NFT데이터 설정
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
    //카운터 변수 설정
    uint public currentNftCount;
    // count로 nft찾아줄거야
    mapping(uint => NftData)public nftStorage;

    //owner찾아줄거
    mapping(uint =>address[])public ownerShipTrans;
      //불리언값 찾아줄거여
      mapping(string => bool) internal tokenURIExists;
      //NFT개수 카운터 할거여
     constructor() ERC721("Image Collection", "NFT") {
        currentNftCount = 0;
    }

    function mint(
        address to,
        string memory _name,
        string memory _tokenURI
    )internal returns (uint256){
        //민트 함수 실행하면 id 카운터 하나 올릴거여
      currentNftCount++;
      //currentNftCount가 아니면 에러를 발생시킬거여
      require(!_exists(currentNftCount), "ImageID repeated.");
        //tokenURIExists 이게 false면 에러를 발생시킬거여
       require(!tokenURIExists[_tokenURI], "Token URI repeated.");
        //ID값으로 민트
        _safeMint(to, currentNftCount);
        //ID에 해당대는 토큰값저장
         _setTokenURI(currentNftCount, _tokenURI);


          //새 NFT(구조체)를 만들고 새 값을 전달할거여

          NftData memory newNftData = NftData(
              currentNftCount,
            _name,
            _tokenURI,
            msg.sender,
            msg.sender,
            0,
            0,
            Status.OffBid
          );
          //true로 변환
          tokenURIExists[_tokenURI] = true;
          //NFT STROGE에 모든걸 넣을거여
           nftStorage[currentNftCount] = newNftData;
    }
    //index를 인자값으로 받아 NftData memory nftData 를 반환
       function getNftByIndex(uint256 index)
        internal
        view
        returns (NftData memory nftData)
    {
        require(_exists(index), "index not exist");
        return nftStorage[index];
    }






    
}
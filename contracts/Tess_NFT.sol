pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

//함수 하나 이상 잇어야 에러 안나지
contract DataNFT is ERC1155, ERC1155Holder, Ownable {
    enum Status {
        OffBid,
        OnBid,
        OnBuy,
        WaittingClaim
    }
    //NFT데이터 설정
    struct NftData {
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
    uint256 public currentNftCount;
    // count로 nft찾아줄거야
    mapping(uint256 => NftData) public nftDataStorage;

    //owner찾아줄거
    mapping(uint256 => address[]) public ownerShipTrans;
    //불리언값 찾아줄거여
    mapping(string => bool) internal tokenURIExists;

    //NFT개수 카운터 할거여
    constructor() ERC1155("Image Collection", "NFT") {
        currentNftCount = 0;
    }

    function mint(
        address to,
        string memory _name,
        string memory _tokenURI
    ) internal returns (uint256) {
        //민트 함수 실행하면 id z카운터 하나 올릴거여
        currentNftCount++;
        //currentNftCount가 아니면 에러를 발생시킬거여
        require(!_exists(currentNftCount), "ImageID repeated.");
        //tokenURIExists 이게 false면 에러를 발생시킬거여
        require(!tokenURIExists[_tokenURI], "Token URI repeated.");
        //ID값으로 민트
        _mint(to, currentNftCount);
        //ID에 해당대는 토큰값저장
        _setURI(currentNftCount, _tokenURI);

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
        nftDataStorage[currentNftCount] = newNftData;
    }

    //index를 인자값으로 받아 NftData memory nftData 를 반환
    function getNftByIndex(uint256 index)
        internal
        view
        returns (NftData memory nftData)
    {
        require(_exists(index), "index not exist");
        return nftDataStorage[index];
    }

    //상태 변경해줄거임 //0은 아무상태아님 //1은 경매중 //2는 판매중으로 할거임
    function updateStatus(uint256 _tokenID, Status status)
        internal
        returns (uint256 index2)
    {
        NftData storage nftData = nftDataStorage[_tokenID];
        nftData.status = status;
        if (nftData.status == Status.OffBid) {
            return 0;
        } else if (nftData.status == Status.OnBid) {
            return 1;
        } else if (nftData.status == Status.OnBuy) {
            return 2;
        } else {
            return 3;
        }
    }

    //소유자도 변경해줄거임
    //업데이트가 완료대면 트루를 반환
    function updateOwner(uint256 _tokenID, address newOwner)
        internal
        returns (bool)
    {
        //nft를 찾을거
        NftData storage nftData = nftDataStorage[_tokenID];
        ownerShipTrans[_tokenID].push(nftData.currentOwner);
        //새로받은 오너를 넣어줄거야
        nftData.currentOwner = newOwner;
        nftData.transferTime += 1;

        (ownerOf(_tokenID), newOwner, _tokenID);
        return true;
    }

    //가격도 변경
    function updatePrice(uint256 _tokenID, uint256 newPrice)
        internal
        returns (bool)
    {
        NftData storage nftData = nftDataStorage[_tokenID];
        if (nftData.highestBidPrice < newPrice) {
            nftData.highestBidPrice = newPrice;
            return true;
        }
        return false;
    }

    //토큰의 현재주인이 누군지 확인만
    function getTokenOwner(uint256 _tokenID) external view returns (address) {
        return ownerOf(_tokenID);
    }

    //토큰의 해시값이 먼지 확인
    function getTokenURI(uint256 _tokenID)
        external
        view
        returns (string memory)
    {
        NftData memory nftData = nftDataStorage[_tokenID];
        return nftData.tokenURI;
    }

    function getOwnedNumber(address owner) external view returns (uint256) {
        return balanceOf(owner);
    }
}

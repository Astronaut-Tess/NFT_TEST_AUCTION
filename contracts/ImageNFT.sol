// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ImageNFT is ERC1155 {
    enum Status {
        OffBid,
        OnBid,
        OnBuy,
        WaittingClaim
    }
    struct Image {
        uint256 tokenID;
        string tokenName;
        string tokenURI;
        string tokenCID;
        address mintedBy;
        address currentOwner;
        uint256 transferTime;
        uint256 highestBidPrice;
        Status status;
    }
    uint256 public currentImageCount;

    mapping(address => Image) public tokenMyNFT;
    mapping(uint256 => Image) public imageStorage;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address[]) public ownerShipTrans;

    mapping(string => bool) internal tokenURIExists;
    mapping(string => bool) internal tokenCIDExists;
    mapping(uint256 => string) private _uris;

    constructor() ERC1155("") {
        currentImageCount = 0;
    }

    //민트
    function mint(
        address to,
        string memory _name,
        string memory _tokenURI,
        string memory _tokenCID
    )
        internal
        returns (
            // string memory _tokenCID
            uint256
        )
    {
        currentImageCount++;
        // require(!_exists(currentImageCount), "ImageID repeated.");
        require(!tokenURIExists[_tokenURI], "Token URI repeated.");
        require(!tokenCIDExists[_tokenCID], "Token URI repeated.");

        _mint(to, currentImageCount, 1, "");
        setURI(currentImageCount, _tokenURI);

        //새 NFT(구조체)를 만들고 새 값을 전달합니다.
        Image memory newImage = Image(
            currentImageCount,
            _name,
            _tokenURI,
            _tokenCID,
            msg.sender,
            msg.sender,
            0,
            0,
            Status.OffBid
        );

        tokenURIExists[_tokenURI] = true;
        tokenCIDExists[_tokenCID] = true;
        imageStorage[currentImageCount] = newImage;

        return currentImageCount;
    }

    function getImageByIndex(uint256 index)
        internal
        view
        returns (Image memory image)
    {
        return imageStorage[index];
    }

    //스탯업데이트
    function updateStatus(uint256 _tokenID, Status status)
        internal
        returns (uint256 index2)
    {
        Image storage image = imageStorage[_tokenID];
        image.status = status;
        if (image.status == Status.OffBid) {
            return 0;
        } else if (image.status == Status.OnBid) {
            return 1;
        } else if (image.status == Status.OnBuy) {
            return 2;
        } else {
            return 5;
        }
    }

    //오너 업데이트
    function updateOwner(uint256 _tokenID, address newOwner)
        internal
        returns (bool)
    {
        Image storage image = imageStorage[_tokenID];
        ownerShipTrans[_tokenID].push(image.currentOwner);
        image.currentOwner = newOwner;
        image.transferTime += 1;
        return true;
    }

    //가격업데잍
    function updatePrice(uint256 _tokenID, uint256 newPrice)
        internal
        returns (bool)
    {
        Image storage image = imageStorage[_tokenID];
        if (image.highestBidPrice < newPrice) {
            image.highestBidPrice = newPrice;
            return true;
        }
        return false;
    }

    //오너 찾아주고
    function getTokenOnwer(uint256 _tokenID) external view returns (address) {
        Image memory image = imageStorage[_tokenID];
        return image.currentOwner;
    }

    function setURI(uint256 tokenID, string memory newuri) public {
        _uris[tokenID] = newuri;
    }

    function getTokenURI(uint256 _tokenID)
        external
        view
        returns (string memory)
    {
        Image memory image = imageStorage[_tokenID];
        return image.tokenURI;
    }

    function getOwnedNumber(address owner, uint256 id)
        external
        view
        returns (uint256)
    {
        return balanceOf(owner, id);
    }

    function transfer(
        address _to,
        uint256 _id,
        uint256 _amount
    ) public returns (bool success) {
        safeTransferFrom(msg.sender, _to, _id, _amount, "");
    }

    function handOver(uint256 _tokenID, address newOwner)
        external
        returns (bool)
    {
        Image storage image = imageStorage[_tokenID];
        ownerShipTrans[_tokenID].push(image.currentOwner);
        image.currentOwner = newOwner;
        image.transferTime += 1;
        return true;
    }
}

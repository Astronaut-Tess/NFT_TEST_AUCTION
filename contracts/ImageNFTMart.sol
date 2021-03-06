// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ImageNFT.sol";

contract ImageMart is ImageNFT {
    //구매판매 페이지를 만들거임
    //설계 어케해야하나
    //설계구조
    //1.가격입력 => 소유자가 판매를 누르면 => 가격창이 뜨고 입력하면 판매에 등록이 되고 => 가격이설정이 된가격에 구입 => 구입성공하게 되면 owner가 구입자로 변경
    //2.업체에서만 등록을하고 => 소유자는 사면 owner가 댐
    //데이터는 가격,id ,uri?인가
    struct Mart {
        uint256 imageID;
        uint256 buyPrice;
        address payable winner;
        bool endbuy;
    }
    //옥션결과조회할거
    mapping(uint256 => Mart) public marts;
    //입찰정보 조회
    mapping(uint256 => mapping(address => uint256)) internal buyInfo;

    constructor() {}

    modifier notOnBuy(uint256 _tokenID) {
        require(
            imageStorage[_tokenID].status == Status.OffBid,
            "Already on auction"
        );
        _;
    }

    function beginMart(uint256 _tokenID, uint256 _minBuy)
        external
        notOnBuy(_tokenID)
        returns (bool success)
    {
        Image storage image = imageStorage[_tokenID];
        require(
            image.currentOwner == msg.sender,
            "Only Owner Can Begin a Auction."
        );
        updateStatus(_tokenID, Status.OnBuy);
        updatePrice(_tokenID, _minBuy);
        Mart memory newMart = Mart(
            _tokenID,
            _minBuy,
            payable(msg.sender),
            false
        );

        marts[_tokenID] = newMart;
        return true;
    }

    function endBuy(uint256 martID) external returns (bool success) {
        Image storage image = imageStorage[martID];
        require(
            image.currentOwner == msg.sender,
            "Only Owner Can End a Auction."
        );

        Mart storage mart = marts[martID];
        if (mart.winner == msg.sender) {
            updateStatus(mart.imageID, Status.OffBid);
        }
        return true;
    }

    function buy(uint256 martID, uint256 newBuy)
        external
        payable
        returns (bool success)
    {
        Mart storage mart = marts[martID];
        Image storage image = imageStorage[mart.imageID];
        address owner = image.currentOwner;
        // updatePrice(mart.imageID, newBuy);
        payable(owner).transfer(msg.value);
        updateOwner(mart.imageID, msg.sender);
        updateStatus(mart.imageID, Status.OffBid);
        mart.winner = payable(msg.sender);
        buyInfo[martID][msg.sender] = newBuy;
        return true;
    }

    function ownerowner(uint256 martID, address _to)
        external
        returns (bool success)
    {
        Mart storage mart = marts[martID];
        updateOwner(mart.imageID, _to);
        updateStatus(mart.imageID, Status.OffBid);
        return true;
    }
}

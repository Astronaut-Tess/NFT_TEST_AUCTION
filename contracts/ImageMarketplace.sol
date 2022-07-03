// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ImageNFT.sol";
import "./ImageNFTAuction.sol";
import "./ImageNFTMart.sol";

contract ImageMarketplace is ImageAuction, ImageMart {
    address internal IMAGE_NFT_MARKETPLACE;

    function mintImageNFT(
        string memory imageName,
        string memory ipfsHashOfPhoto,
        string memory tokenCID
    ) external returns (bool) {
        string memory tokenURI = getTokenURI(ipfsHashOfPhoto);
        mint(msg.sender, imageName, tokenURI, tokenCID);
        return true;
    }

    function baseTokenURI() internal pure returns (string memory) {
        return "https://ipfs.infura.io/ipfs/";
    }

    function getTokenURI(string memory _ipfsHashOfPhoto)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(baseTokenURI(), _ipfsHashOfPhoto));
    }
}

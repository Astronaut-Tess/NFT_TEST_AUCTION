// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//여기서 통제할거
import "./Tess_NFT.sol";
import "./Tess_NFTAuction.sol";
//시장 할거
contract NftDataMarketplace is NftDataAuction {
 address internal  NftDATA_NFT_MARKETPLACE;

   constructor() {
        NftDATA_NFT_MARKETPLACE = payable(address(this));
    }


    //최종민팅
       function mintImageNFT(
        string memory imageName,
        string memory ipfsHashOfPhoto
    ) external returns (bool) {
        string memory tokenURI = getTokenURI(ipfsHashOfPhoto); /// [Note]: IPFS hash + URL
        mint(msg.sender, imageName, tokenURI);
        return true;
    }
     //인퓨라에 넣고 뺴올거
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

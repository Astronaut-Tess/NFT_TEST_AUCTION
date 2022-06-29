// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ImageNFT {
    enum Status {
        OffBid,
        OnBid,
        OnBuy,
        WaittingClaim
    }

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
        return 0;
    }
}

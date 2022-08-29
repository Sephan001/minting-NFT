// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMinter is ERC721, ERC721URIStorage {
    uint256 private mintingFee;
    address public owner;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct RenderNft {
        uint256 id;
        string uri;
    }

    constructor(
        uint256 _mintingFee,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        mintingFee = _mintingFee;
        owner = msg.sender;
    }

    /// @dev allow users to mint an NFT
    function mintNFT(string calldata _tokenURI)
        external
        payable
        returns (uint256)
    {
        require(msg.value == mintingFee, "must pay minting fee");

        uint256 newItemId = _tokenIds.current();
        _tokenIds.increment();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        (bool success, ) = payable(owner).call{value: msg.value}("");
        require(success, "Transfer of mint fee failed");

        return newItemId;
    }

    /// @dev allow caller to retrieves all the NFTs minted
    function getAllNfts() public view returns (RenderNft[] memory) {
        uint256 lastestId = _tokenIds.current();
        RenderNft[] memory items = new RenderNft[](lastestId);
        for (uint256 i = 0; i < lastestId; i++) {
            string memory uri = tokenURI(i);
            items[i] = RenderNft(i, uri);
        }
        return items;
    }

    /// @dev retrieves all the NFTs owned by the caller
    function getMyNfts() public view returns (RenderNft[] memory) {
        uint256 lastestId = _tokenIds.current();
        uint256 myNftsCount = balanceOf(msg.sender);

        RenderNft[] memory myNfts = new RenderNft[](myNftsCount);

        uint256 counter = 0;
        for (uint256 i = 0; i < lastestId; i++) {
            if (ownerOf(i) == msg.sender) {
                string memory uri = tokenURI(i);
                myNfts[counter] = RenderNft(i, uri);
                counter++;
            }
        }
        return myNfts;
    }

    function getMintingFee() public view returns (uint256) {
        return mintingFee;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}

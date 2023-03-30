// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TestNft is
    ERC721,
    ERC721Enumerable,
    ERC721Burnable,
    ERC2981,
    DefaultOperatorFilterer,
    ReentrancyGuard,
    Ownable
{
    using Strings for uint256;
    using Counters for Counters.Counter;

    uint256 private constant MAX_SUPPLY = 10000;
    Counters.Counter private _tokenIdCounter;

    // Metadata
    string private _contractURI =
        "https://ynft.github.io/metadata/contract.json";
    string private _baseURL = "https://ynft.github.io/metadata/";
    string private _baseExt = ".json";
    bool private _revealed = false;
    string private _notRevealedURI =
        "https://ynft.github.io/metadata/unrevealed.json";

    constructor() ERC721("TEST NFT", "TNFT") {
        _setDefaultRoyalty(0x3ecb3F07DA57Fe7De2c685833bF85015b5219769, 700);

        // Setting start tokenId from 1.
        _tokenIdCounter.increment();
    }

    function mint(address to) external nonReentrant onlyOwner {
        require((totalSupply() + 1) <= MAX_SUPPLY, "MAX_SUPPLY");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function mintMany(
        address to,
        uint256 quantity
    ) external nonReentrant onlyOwner {
        require((totalSupply() + quantity) <= MAX_SUPPLY, "MAX_SUPPLY");
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
        }
    }

    function mintBatch(
        address[] memory accounts,
        uint256[] memory quantities
    ) external nonReentrant onlyOwner {
        require(accounts.length == quantities.length, "MISMATCH");
        for (uint256 i = 0; i < accounts.length; i++) {
            require(
                (totalSupply() + quantities[i]) <= MAX_SUPPLY,
                "MAX_SUPPLY"
            );
            for (uint256 j = 0; j < quantities[i]; j++) {
                uint256 tokenId = _tokenIdCounter.current();
                _tokenIdCounter.increment();
                _safeMint(accounts[i], tokenId);
            }
        }
    }

    // Extra
    function rawOwnerOf(uint256 tokenId) external view returns (address) {
        return _ownerOf(tokenId);
    }

    function tokensOfOwner(
        address owner
    ) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        require(0 < tokenCount, "ERC721Enumerable: owner index out of bounds");
        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokenIds;
    }

    // Metadata
    function reveal(bool status) external onlyOwner {
        _revealed = status;
    }

    function setNotRevealedURI(string memory uri_) external onlyOwner {
        _notRevealedURI = uri_;
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    function setContractURI(string memory uri_) external onlyOwner {
        _contractURI = uri_;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireMinted(tokenId);

        if (!_revealed) return _notRevealedURI;

        return string(abi.encodePacked(_baseURL, tokenId.toString(), _baseExt));
    }

    function setBaseURI(string memory uri_) external onlyOwner {
        _baseURL = uri_;
    }

    function setBaseExtension(string memory ext_) external onlyOwner {
        _baseExt = ext_;
    }

    // Royalty
    function setDefaultRoyalty(
        address royaltyReceiver,
        uint96 royaltyNumerator
    ) external onlyOwner {
        _setDefaultRoyalty(royaltyReceiver, royaltyNumerator);
    }

    function deleteDefaultRoyalty() external onlyOwner {
        _deleteDefaultRoyalty();
    }

    // Override
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(
        address operator,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

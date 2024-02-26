// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// This contract inherits from the OpenZeppelin ERC721 contract, providing the standard implementation for ERC721 tokens.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => uint256) private _tokenPrices;
    mapping(uint256 => address) private _tokenOwners;

    address public admin;

    constructor() ERC721("NFTMarketplace", "NFTM") {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

//  function allows the admin to create new NFTs and assign them to specific addresses.
    function mintNFT(address recipient, string memory tokenURI) external onlyAdmin returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        _tokenOwners[newTokenId] = recipient;
        return newTokenId;
    }

//  function allows users to buy NFTs from others by sending the required amount of ether.
    function buyNFT(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) != msg.sender, "You already own this token");
        require(msg.value >= _tokenPrices[tokenId], "Insufficient payment");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);
        _tokenOwners[tokenId] = msg.sender;
        payable(seller).transfer(msg.value);
    }

// function allows the owner of an NFT to set its price.
    function setTokenPrice(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        _tokenPrices[tokenId] = price;
    }

// function allows anyone to get the price of a specific NFT.
    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        return _tokenPrices[tokenId];
    }

// function allows anyone to get the owner of a specific NFT.
    function getTokenOwner(uint256 tokenId) external view returns (address) {
        return _tokenOwners[tokenId];
    }

// function allows users to transfer their NFTs to others.
    function transferNFT(address to, uint256 tokenId) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        _transfer(msg.sender, to, tokenId);
        _tokenOwners[tokenId] = to;
    }

// function allows the admin to set a new admin.
    function setAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }

// function allows the admin to withdraw ether from the contract.
    function withdraw() external onlyAdmin {
        payable(admin).transfer(address(this).balance);
    }
}

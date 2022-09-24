// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RoboPunksNFT is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenUri;
    address payable public withdrawWallet;
    mapping(address => uint256) public walletMints; //keeps track of nft minted by address

    constructor() payable ERC721("RoboPunks", "RP") {
        // Initializing variables
        mintPrice = 0.02 ether;
        totalSupply = 0;
        maxSupply = 1000;
        maxPerWallet = 3;
        //set withdaw wallet address
    }

    //Function from which we will check if minting is enabled
    function setIsPublicMintEnabled(bool _isPublicMintEnabled) external onlyOwner {
        isPublicMintEnabled = _isPublicMintEnabled;
    }

    //Function from which we will set base token uri
    function setBaseTokenUri(string calldata _baseTokenUri) external onlyOwner {
        baseTokenUri = _baseTokenUri;
    }

    //Get the token uri
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require (_exists(_tokenId), 'Token Id does not exist!');
        return string(abi.encodePacked(baseTokenUri, Strings.toString(_tokenId), ".json"));
    }

    //Withdraw funds from contract
    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{value: address(this).balance}('');
        require(success, "withdraw failed");
    }

    //Minting NFTs for public
    function mint(uint256 _quantity) public payable {
        require (isPublicMintEnabled, "Minting not enabled");
        require (msg.value == _quantity * mintPrice, "Wrong mint value");
        require (totalSupply + _quantity <= maxSupply, "Sold Out");
        require (walletMints[msg.sender] + _quantity <= maxPerWallet, "exceed max mint per wallet");

        for(uint256 i = 0; i < _quantity; i++) {
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, newTokenId);

        }
    }
}

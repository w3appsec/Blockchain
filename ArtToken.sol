// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; 
import "@openzeppelin/contracts/utils/Counters.sol";

contract ArtToken is ERC721URIStorage { 
  address private artist; 
  mapping(uint => uint) private price; 
  mapping(uint => string) private tokenType;
  mapping(uint => uint) private baseTokenId;
  mapping(uint => uint) private maxNumGicles;
  mapping(uint => uint) private numGicles;

  mapping(address => mapping(uint => int)) private exhibits; 
  int constant pending = -1;
  int constant confirmed = 1;

  using Counters for Counters.Counter; 
  Counters.Counter private tokenIds; 

  constructor() ERC721("ArtWork", "ART") { 
    artist = msg.sender; 
  }

  function createArt(string memory tokenURI, uint _maxNumGicles) external returns (uint) { 
    require (msg.sender == artist); 
    uint tokenId = tokenIds.current(); 
    _mint(artist, tokenId); 
    _setTokenURI(tokenId, tokenURI); 
    tokenType[tokenId] = "Physical";
    maxNumGicles[tokenId] = _maxNumGicles;
    tokenIds.increment(); 
    return tokenId;
  }

  //======

  function createGicle(string memory tokenURI, uint _baseTokenId) external returns (uint) { 
    require (msg.sender == artist); 
    require(numGicles[_baseTokenId] < maxNumGicles[_baseTokenId]);
    numGicles[_baseTokenId] = numGicles[_baseTokenId] + 1;
    uint tokenId = tokenIds.current(); 
    _mint(artist, tokenId); 
    _setTokenURI(tokenId, tokenURI); 
    tokenType[tokenId] = "Gicle";
    baseTokenId[tokenId] = _baseTokenId;
    tokenIds.increment(); 
    return tokenId;
  }
  
  function getTokenType(uint tokenId) public view returns (string memory) {
    return tokenType[tokenId];
  }

  function getBaseTokenId(uint tokenId) public view returns (uint) {
    return baseTokenId[tokenId];
  }

  //======

  function setPrice(uint tokenId, uint _price) public { 
    require(msg.sender == ownerOf(tokenId)); 
    price[tokenId] = _price; 
  }

  function getPrice(uint tokenId) public view returns (uint) { 
    return price[tokenId];
  }

  function approveSale(uint tokenId, address buyer) public { 
    require(msg.sender == ownerOf(tokenId)); 
    approve(buyer, tokenId);
  }

  function buyArtOnchain(uint tokenId) external payable returns (bool) {
    address owner = ownerOf(tokenId);
    address buyer = msg.sender;
    require(buyer != owner);
    transferFrom(owner, buyer, tokenId);
    uint _price = getPrice(tokenId);
    (bool success, ) = owner.call{value:_price}("");
    require (success);
    return true;
  }

  function sellArtOffchain(uint tokenId, address buyer) external returns (bool) { 
    address owner = ownerOf(tokenId); 
    require(msg.sender == owner);
    require(buyer != owner);
    transferFrom(owner, buyer, tokenId); 
    return true; 
  }

  //======

  function exhibitRequest(address location, uint tokenId) external { 
    address owner = ownerOf(tokenId); 
    require(msg.sender == owner); 
    exhibits[location][tokenId] = pending; 
  }

  function exhibitConfirmation(uint tokenId) external { 
    address location = msg.sender; 
    require(exhibits[location][tokenId] == pending);
    exhibits[location][tokenId] = confirmed; 
  }

  function exhibitEnquiry(address location, uint tokenId) public view returns (string memory) {
    int status = exhibits[location][tokenId];
    string memory statusStr = "";
    if (status == 1) {
      statusStr = "Confirmed";
    } else if (status == -1) {
      statusStr = "Pending";
    } else {
      statusStr = "Void";
    }
    return statusStr;
  }

  //======

  function nextId() public view returns (uint256) { 
    require(msg.sender == artist); 
    return tokenIds.current(); 
  } 

  function artistAddr() public view returns (address) { 
    return artist;
  }

  function callerAddr() external view returns (address) { 
    return msg.sender; 
  }

  function thisContract() external view returns (address) { 
    return address(this); 
  }
}

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";

contract ArtToken {
  address artist; 
  mapping(uint => uint) private price;
  mapping(uint => address) private buyer;

  uint constant physical = 1;
  uint constant gicle    = 2;

  mapping(uint => string) private _tokenURI;
  mapping(uint => address) private ownerOf;
  mapping(uint => uint) private tokenType;
  mapping(uint => uint) private baseTokenId;
  mapping(uint => uint) private maxNumGicles;
  mapping(uint => uint) private numGicles;

  mapping(address => mapping(uint => int)) private exhibitStatus; 
  int constant pending   = -1;
  int constant confirmed = 1;
  mapping(uint => address[]) exhibits;

  using Counters for Counters.Counter; 
  Counters.Counter private tokenIds; 

  constructor() payable { 
    artist = msg.sender; 
  }

  function createArt(string memory tokenURI, uint _maxNumGicles) external { 
    require (msg.sender == artist); 
    uint tokenId = tokenIds.current(); 
    _tokenURI[tokenId] = tokenURI;
    tokenType[tokenId] = physical;
    ownerOf[tokenId] = artist;
    maxNumGicles[tokenId] = _maxNumGicles;
    tokenIds.increment(); 
  }

  function createGicle(string memory tokenURI, uint _baseTokenId) external { 
    require (msg.sender == artist); 
    require(tokenType[_baseTokenId] == physical);
    require(numGicles[_baseTokenId] < maxNumGicles[_baseTokenId]);
    numGicles[_baseTokenId] = numGicles[_baseTokenId] + 1;
    uint tokenId = tokenIds.current(); 
    _tokenURI[tokenId] = tokenURI;
    tokenType[tokenId] = gicle;
    ownerOf[tokenId] = artist;
    baseTokenId[tokenId] = _baseTokenId;
    tokenIds.increment(); 
  }
  
  function getTokenType(uint tokenId) public view returns (string memory) {
    if (tokenType[tokenId] == 1) {
      return "Physical";
    } else if (tokenType[tokenId] == 2) {
      return "Gicle";
    } else {
      return "Void";
    }
  }

  function getBaseTokenId(uint tokenId) public view returns (uint) {
    require(tokenType[tokenId] == gicle);
    return baseTokenId[tokenId];
  }

  //======

  function setPrice(uint tokenId, uint _price) public { 
    require(msg.sender == ownerOf[tokenId]); 
    require(buyer[tokenId] == address(0x0));
    price[tokenId] = _price; 
  }

  function getPrice(uint tokenId) public view returns (uint) { 
    return price[tokenId];
  }

  function getOwner(uint tokenId) public view returns (address) {
    return ownerOf[tokenId];
  }

  function buyTokenOnchain(uint tokenId) public payable {
    uint _price = getPrice(tokenId);
    require(_price != 0);
    require(msg.value >= _price);
    require(buyer[tokenId] == address(0x0));
    buyer[tokenId] = msg.sender;
    address owner = ownerOf[tokenId];
    (bool success, ) = owner.call{value:_price, gas:5000000}("");
    require(success);
  }

  function acceptPayment(uint tokenId) public {
    require(buyer[tokenId] != address(0x0));
    address owner = ownerOf[tokenId];
    require(msg.sender == owner);
    address _buyer = buyer[tokenId];
    setPrice(tokenId, 0);
    ownerOf[tokenId] = _buyer;
    buyer[tokenId] = address(0x0);
  }

  function rejectPayment(uint tokenId) public payable {
    require(buyer[tokenId] != address(0x0));
    address owner = ownerOf[tokenId];
    require(msg.sender == owner);
    address _buyer = buyer[tokenId];
    uint _price = getPrice(tokenId);
    buyer[tokenId] = address(0x0);
    setPrice(tokenId, 0);
    (bool success, ) = _buyer.call{value:_price, gas:10000000}("");
    require(success);
  }

  function viewBuyer(uint tokenId) public view returns (address) {
    return (buyer[tokenId]);
  }

  function sellTokenOffchain(uint tokenId, address _buyer) external returns (bool) { 
    address owner = ownerOf[tokenId]; 
    require(msg.sender == owner);
    require(_buyer != owner);
    ownerOf[tokenId] = _buyer;
    return true; 
  }

  //======

  function getNumExhibits(uint tokenId) external view returns (uint) {
    return exhibits[tokenId].length;
  }

  function getNthExhibit(uint tokenId, uint n) external view returns (address) {
    return exhibits[tokenId][n];
  }
  
  function exhibitRequest(uint tokenId, address location) external { 
    address owner = ownerOf[tokenId]; 
    require(msg.sender == owner); 
    exhibitStatus[location][tokenId] = pending; 
  }

  function exhibitConfirmation(uint tokenId) external { 
    address location = msg.sender; 
    require(exhibitStatus[location][tokenId] == pending);
    exhibitStatus[location][tokenId] = confirmed; 
    exhibits[tokenId].push(location);
  }

  function exhibitEnquiry(uint tokenId, address location) public view returns (string memory) {
    int status = exhibitStatus[location][tokenId];
    string memory statusStr = "";
    if (status == confirmed) {
      statusStr = "Confirmed";
    } else if (status == pending) {
      statusStr = "Pending";
    } else {
      statusStr = "Void";
    }
    return statusStr;
  }

  //======

  function nextId() public view returns (uint) { 
    require (msg.sender == artist);
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

  function callerBalance() public view returns (uint) {
    return msg.sender.balance;
  }

  function contractBalance() public view returns (uint) {
    return address(this).balance;
  }
}

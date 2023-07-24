// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.17;

contract ArtToken {

address artist; 

mapping(uint => uint) private price;

mapping(uint => address) private offerors;

function setOfferorPrivate(uint _tokenId, address offeror) private {

offerors[_tokenId] = offeror;

}

function getOfferor(uint _tokenId) public view returns (address) {

return offerors[_tokenId];

}

mapping(uint => address) private unlocked;

function setUnlockedPrivate(uint _tokenId, address _unlock) private {

unlocked[_tokenId] = _unlock;

}

function getUnlocked(uint _tokenId) public view returns (address) {

return unlocked[_tokenId];

}

uint constant physical = 1;

uint constant gicle = 2;

mapping(uint => string) private tokenURI;

mapping(uint => address) private ownerOf;

mapping(uint => uint) private tokenType;

mapping(uint => uint) private baseTokenId;

mapping(uint => uint) private maxNumGicles;

mapping(uint => uint) private numGicles;

mapping(address => mapping(uint => int)) private exhibitStatus; 

int constant pending = -1;

int constant confirmed = 1;

mapping(uint => address[]) exhibits;

uint tokenId = 1;

constructor() payable {

artist = msg.sender; 

}

function createArt(string memory _tokenURI, uint _maxNumGicles) external { 

require (msg.sender == artist); 

tokenURI[tokenId] = _tokenURI;

tokenType[tokenId] = physical;

setOwnerPrivate(tokenId, artist);

maxNumGicles[tokenId] = _maxNumGicles;

tokenId++;

}

function createGicle(string memory _tokenURI, uint _baseTokenId) external { 

require (msg.sender == artist); 

require(tokenType[_baseTokenId] == physical);

require(numGicles[_baseTokenId] < maxNumGicles[_baseTokenId]);

numGicles[_baseTokenId] = numGicles[_baseTokenId] + 1;

tokenURI[tokenId] = _tokenURI;

tokenType[tokenId] = gicle;

setOwnerPrivate(tokenId, artist);

baseTokenId[tokenId] = _baseTokenId;

tokenId++;

}

function getTokenType(uint _tokenId) external view returns (string memory) {

if (tokenType[_tokenId] == 1) {

return "Physical";

} else if (tokenType[_tokenId] == 2) {

return "Gicle";

} else {

return "Void";

}

}

function getBaseTokenId(uint _tokenId) external view returns (uint) {

require(tokenType[_tokenId] == gicle);

return baseTokenId[_tokenId];

}

function getTokenURI(uint _tokenId) external view returns (string memory) {

return tokenURI[_tokenId];

}

function setPrice(uint _tokenId, uint _price) external { 

require(msg.sender == getOwner(_tokenId));

require(getOfferor(_tokenId) == address(0x0));

require(getUnlocked(_tokenId) == address(0x0));

price[_tokenId] = _price; 

}

function setPricePrivate(uint _tokenId, uint _price) private {

price[_tokenId] = _price;

}

function getPrice(uint _tokenId) public view returns (uint) { 

return price[_tokenId];

}

function setOwnerPrivate(uint _tokenId, address owner) private {

ownerOf[_tokenId] = owner;

}

function getOwner(uint _tokenId) public view returns (address) {

return ownerOf[_tokenId];

}

// Buy Now

function buyNow(uint _tokenId) external payable {

uint _price = getPrice(_tokenId);

require(_price > 0);

require(msg.value == _price);

require(getOfferor(_tokenId) == address(0x0));

require(getUnlocked(_tokenId) == address(0x0));

address owner = getOwner(_tokenId);

(bool success, ) = owner.call{value:_price, gas:5000000}("");

require(success);

setOwnerPrivate(_tokenId, msg.sender);

setOfferorPrivate(_tokenId, address(0x0));

setUnlockedPrivate(_tokenId, address(0x0));

setPricePrivate(_tokenId, 0);

}

// Buy with Accept / Reject

function buyOffer(uint _tokenId) external payable {

uint _price = getPrice(_tokenId);

require(_price == 0);

uint _value = msg.value;

require(_value > 0);

require(getOfferor(_tokenId) == address(0x0));

require(getUnlocked(_tokenId) == address(0x0));

address owner = getOwner(_tokenId);

require(msg.sender != owner);

setPricePrivate(_tokenId, _value);

setOfferorPrivate(_tokenId, msg.sender);

}

function acceptOffer(uint _tokenId) external {

uint _price = getPrice(_tokenId);

require(_price != 0);

address _buyer = getOfferor(_tokenId);

require(_buyer != address(0x0));

require(getUnlocked(_tokenId) == address(0x0));

address owner = getOwner(_tokenId);

require(msg.sender == owner);

(bool success, ) = owner.call{value: _price, gas:5000000}("");

require(success);

setPricePrivate(_tokenId, 0);

setOwnerPrivate(_tokenId, _buyer);

setOfferorPrivate(_tokenId, address(0x0));

}

function withdrawOffer(uint _tokenId) external {

uint _price = getPrice(_tokenId);

require(_price > 0);

address _buyer = getOfferor(_tokenId);

require(_buyer != address(0x0));

require(_buyer == msg.sender);

setPricePrivate(_tokenId, 0);

setOfferorPrivate(_tokenId, address(0x0));

(bool success, ) = _buyer.call{value:_price, gas:10000000}("");

require(success);

}

function rejectOffer(uint _tokenId) external {

uint _price = getPrice(_tokenId);

require(_price > 0);

address _buyer = getOfferor(_tokenId);

require(_buyer != address(0x0));

address owner = getOwner(_tokenId);

require(msg.sender == owner);

setPricePrivate(_tokenId, 0);

setOfferorPrivate(_tokenId, address(0x0));

(bool success, ) = _buyer.call{value:_price, gas:10000000}("");

require(success);

}

function viewBuyer(uint _tokenId) external view returns (address) {

return (getOfferor(_tokenId));

}

// Buy Unlocked

function buyUnlocked(uint _tokenId) external payable {

uint _price = getPrice(_tokenId);

require(_price > 0);

require(msg.value == _price);

require(getOfferor(_tokenId) == address(0x0));

require(getUnlocked(_tokenId) == msg.sender);

address owner = getOwner(_tokenId);

require(owner != msg.sender);

(bool success, ) = owner.call{value:_price, gas:5000000}("");

require(success);

setOwnerPrivate(_tokenId, msg.sender);

lock(_tokenId);

}

function unlock(uint _tokenId, address _buyer, uint _price) external {

require(getOfferor(_tokenId) == address(0x0));

require(getUnlocked(_tokenId) == address(0x0));

require(_price > 0);

address owner = getOwner(_tokenId);

require(msg.sender == owner);

setUnlockedPrivate(_tokenId, _buyer);

setPricePrivate(_tokenId, _price);

}

function lock(uint _tokenId) public {

require(getOfferor(_tokenId) == address(0x0));

require(getUnlocked(_tokenId) != address(0x0));

address owner = getOwner(_tokenId);

require(msg.sender == owner);

setUnlockedPrivate(_tokenId, address(0x0));

setPricePrivate(_tokenId, 0);

}

function viewUnlocked(uint _tokenId) external view returns (address) {

return getUnlocked(_tokenId);

}

// Sell Offchain

function sellTokenOffchain(uint _tokenId, address _buyer) external { 

address owner = getOwner(_tokenId); 

require(msg.sender == owner);

require(_buyer != owner);

require(getOfferor(_tokenId) == address(0x0));

require(getUnlocked(_tokenId) == address(0x0));

setOwnerPrivate(_tokenId, _buyer);

setPricePrivate(_tokenId, 0);

}

// Exhibits

function getNumExhibits(uint _tokenId) external view returns (uint) {

return exhibits[_tokenId].length;

}

function getNthExhibit(uint _tokenId, uint n) external view returns (address) {

return exhibits[_tokenId][n];

}

function exhibitRequest(uint _tokenId, address location) external { 

address owner = getOwner(_tokenId); 

require(msg.sender == owner); 

require(exhibitStatus[location][_tokenId] == 0);

exhibitStatus[location][_tokenId] = pending; 

}

function exhibitCancel(uint _tokenId, address location) external {

address owner = getOwner(_tokenId);

require(msg.sender == owner);

require(exhibitStatus[location][_tokenId] == confirmed);

exhibitStatus[location][_tokenId] = 0;

}

function exhibitConfirmation(uint _tokenId) external { 

address location = msg.sender; 

require(exhibitStatus[location][_tokenId] == pending);

exhibitStatus[location][_tokenId] = confirmed; 

exhibits[_tokenId].push(location);

}

function exhibitEnquiry(uint _tokenId, address location) external view returns (string memory) {

int status = exhibitStatus[location][_tokenId];

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

// Artist

function nextId() external view returns (uint) { 

require (msg.sender == artist);

return tokenId;

} 

function artistAddr() public view returns (address) { 

return artist;

}

// Utils

function callerAddr() external view returns (address) { 

return msg.sender; 

}

function thisContract() external view returns (address) { 

return address(this); 

}

function callerBalance() external view returns (uint) {

return msg.sender.balance;

}

function contractBalance() external view returns (uint) {

return address(this).balance;

}

}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Counters.sol";

contract ArtProvenanceV0 {

    struct Piece {
        address owner;
        string signature;
        bool original;
        uint price;
        uint maxNumGicles;
        uint numGicles;
        uint baseId;
    }

    mapping(uint => Piece) private Art;
    address private artist; 

    mapping(uint => address) private approvedBuyer;

    using Counters for Counters.Counter; 
    Counters.Counter private idGen;

    modifier onlyArtist {
        require(msg.sender == artist);
        _;
    }

    constructor() { 
        artist = msg.sender; 
    }

    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }

    function createArt(string memory nfcSignature, uint maxNumGicles) onlyArtist external { 
        uint id = idGen.current(); 
        Art[id].owner = artist;
        Art[id].original = true;
        Art[id].signature = nfcSignature;
        Art[id].maxNumGicles = maxNumGicles;
        idGen.increment(); 
    }

    function createGicle(string memory nfcSignature, uint baseId) onlyArtist external { 
        require(Art[baseId].original);
        require(Art[baseId].numGicles < Art[baseId].maxNumGicles);
        uint id = idGen.current(); 
        Art[id].owner = artist;
        Art[id].original = false;
        Art[id].signature = nfcSignature;
        Art[id].baseId = baseId;
        Art[id].numGicles++;
        idGen.increment(); 
    }

    function buyArt(uint id) external payable {
        address buyer = msg.sender;
        address owner = Art[id].owner;
        require(buyer != owner);
        uint price = getPrice(id);
        require(price != 0);
        require(msg.value == price);
        if (approvedBuyer[id] != address(0x0)) {
            require(approvedBuyer[id] == buyer);
            approvedBuyer[id] = address(0x0);
        }
        (bool success, ) = owner.call{value:price}("");
        require(success);
        Art[id].owner = buyer;
        setPrice(id, 0);
    }

    function setOwner(uint id, address buyer) external { 
        address owner = Art[id].owner; 
        require(msg.sender == owner);
        require(buyer != owner);
        setPrice(id, 0);
        Art[id].owner = buyer;
    }

    function approveBuyer(uint id, address buyer) external {
        require(buyer != address(0x0));
        address owner = Art[id].owner;
        require(msg.sender == owner);
        approvedBuyer[id] = buyer;
    }

    function deApproveBuyer(uint id) external {
        address owner = Art[id].owner;
        require(msg.sender == owner);
        approvedBuyer[id] = address(0x0);
    }

    function getOwner(uint id) external view returns (address) {
        return Art[id].owner;
    }

    function nextId() onlyArtist external view returns (uint) { 
        return idGen.current(); 
    } 

    function artistAddr() external view returns (address) { 
        return artist;
    }

    function getDescription(uint id) external view returns (string memory) {
        if (Art[id].original)
            return "Original";
        else
            return "Gicle";
    }

    function getApprovedBuyer(uint id) external view returns (address) {
        return approvedBuyer[id];
    }

    function setPrice(uint id, uint price) public { 
        require(msg.sender == Art[id].owner); 
        Art[id].price = price; 
    }

    function getPrice(uint id) public view returns (uint) { 
        return Art[id].price;
    }

    function getBaseId(uint id) public view returns (uint) {
        require(!Art[id].original);
        return Art[id].baseId;
    }

 }

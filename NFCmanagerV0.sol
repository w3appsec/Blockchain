// SPDX-License-Identifier: GFDL-1.3-or-later
pragma solidity ^0.8.28;

contract NFCmanager {

    struct Tag {
        address owner;
        uint price;
        string sig;
    }

    mapping(string => Tag) private NFC;
    address private factory; 

    mapping(string => address) private approvedBuyer;

    modifier onlyFactory{
        require(msg.sender == factory);
        _;
    }

    constructor() { 
        factory = msg.sender; 
    }

    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }

    function create(string memory sig, uint price) onlyFactory external { 
        require(price > 0);
        NFC[sig].owner = factory;
        NFC[sig].sig = sig;
        NFC[sig].price = price;
    }

    function buy(string memory sig) external payable {
        address buyer = msg.sender;
        address owner = NFC[sig].owner;
        require(buyer != owner);
        uint price = getPrice(sig);
        require(price > 0);
        require(msg.value == price);
        if (approvedBuyer[sig] != address(0x0)) {
            require(approvedBuyer[sig] == buyer);
            approvedBuyer[sig] = address(0x0);
        }
        (bool success, ) = owner.call{value:price}("");
        require(success);
        NFC[sig].owner = buyer;
    }

    function transferTag(string memory sig, address buyer) external { 
        address owner = NFC[sig].owner; 
        require(msg.sender == owner);
        require(buyer != owner);
        NFC[sig].owner = buyer;
    }

    function approveBuyer(string memory sig, address buyer) external {
        require(buyer != address(0x0));
        address owner = NFC[sig].owner;
        require(msg.sender == owner);
        approvedBuyer[sig] = buyer;
    }

    function deApproveBuyer(string memory sig) external {
        address owner = NFC[sig].owner;
        require(msg.sender == owner);
        approvedBuyer[sig] = address(0x0);
    }
    
    function setPrice(string memory sig, uint price) external { 
        require(msg.sender == NFC[sig].owner); 
        require(price > 0);
        NFC[sig].price = price; 
    }

    function getOwner(string memory sig) external view returns (address) {
        return NFC[sig].owner;
    }

    function verifySig(string memory sig) external view returns (string memory) {
        return NFC[sig].sig;
    }

    function factoryAddr() external view returns (address) { 
        return factory;
    }

    function getApprovedBuyer(string memory sig) external view returns (address) {
        return approvedBuyer[sig];
    }

    function getPrice(string memory sig) public view returns (uint) { 
        return NFC[sig].price;
    }

 }

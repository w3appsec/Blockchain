// SPDX-License-Identifier: EPL-2.0

pragma solidity ^0.8.26;

contract Bank {
    constructor() payable {
        bankAdmin = msg.sender;
        setupFee = 10 gwei;
    }

    receive() external payable {}

    fallback() external payable {}

    struct Account {
        bool valid;
        uint balance;
    }

    mapping (address => Account) private customers;

    uint private setupFee;

    address immutable private bankAdmin;

    modifier isBank {
        require(msg.sender == bankAdmin);
        _;
    }

    modifier notBank {
        require(msg.sender != bankAdmin);
        _;
    }

    modifier isCustomer {
        require(customers[msg.sender].valid);
        _;
    }

    modifier notCustomer {
        require(customers[msg.sender].valid == false);
        _;
    }

    function join() notCustomer notBank external payable returns (bool) {
        address _addr = msg.sender;
        require(msg.value == setupFee);
        customers[_addr].valid = true;
        return true;
    }

    function deposit() isCustomer external payable returns (uint) {
        address _addr = msg.sender;
        customers[_addr].balance += msg.value * 63/64;
        return customers[_addr].balance;
    }

    function pay(address _to, uint _amount) isCustomer external returns (uint) {
        address _addr = msg.sender;
        require(_amount <= customers[_addr].balance);

        customers[_addr].balance -= _amount;
        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success);
        return customers[_addr].balance;
    }

    function withdraw(uint _amount) isCustomer external returns (uint) {
        address _addr = msg.sender;
        require(_amount <= customers[_addr].balance);

        customers[_addr].balance -= _amount;
        (bool success, ) = _addr.call{value: _amount}("");
        require(success);
        return customers[_addr].balance;
    }

    function balance() isCustomer external view returns (uint) {
        return customers[msg.sender].balance;
    }

    function getFee() external view returns (uint) {  
        return setupFee;  
    }

    function setFee(uint _fee) isBank external {
        setupFee = _fee;
    }

    function totalAssets() isBank external view returns (uint) {
        return address(this).balance;
    }
}

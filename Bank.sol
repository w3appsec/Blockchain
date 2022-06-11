// SPDX-License-Identifier: EPL-2.0

pragma solidity ^0.8.0;

contract Bank {

    mapping (address => uint) private accounts;
    mapping (address => bool) private registered;

    uint registrationFee = 100;

    // Your ENS here
    address public constant bankAdmin = 0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d;

    constructor() payable {}

    function newCustomer() external payable returns (uint) {
        require(registered[msg.sender] == false);
        require(uint (msg.value) == registrationFee);

        registered[msg.sender] = true;
        return accounts[msg.sender];
    }

    function deposit() external payable returns (uint) {
        require(registered[msg.sender] == true);
        
        accounts[msg.sender] += msg.value;
        return accounts[msg.sender];
    }

    function withdraw(uint withdrawAmount) external returns (uint) {
        require(registered[msg.sender] == true);
        require(withdrawAmount <= accounts[msg.sender]);

        // Reenterancy Defence, subtract from account before payment
        accounts[msg.sender] -= withdrawAmount;
        payable(msg.sender).transfer(withdrawAmount);
        return accounts[msg.sender];
    }

    function custBalance() external view returns (uint) {
        require(registered[msg.sender] == true);

        return accounts[msg.sender];
    }

    function getFee() external view returns(uint) {  
        return registrationFee;  
    }

    function setFee(uint _fee) external {
        // Access control
        require(msg.sender == bankAdmin);
        require(_fee != registrationFee);

        registrationFee = _fee;
    }

    function totalAssets() external view returns(uint) {
        // Access control
        require(msg.sender == bankAdmin);

        return address(this).balance;
    }
}


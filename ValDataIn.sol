// SPDX-License-Identifier: NLPL

pragma solidity ^0.8.0;

contract ValDataIn {
    uint public sum;
    constructor () {
        sum = 0;
    }

    function rx(uint n) external payable {
        sum += n;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


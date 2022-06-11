// SPDX-License-Identifier: NLPL

pragma solidity ^0.8.0;

interface IValDataIn {
    function rx(uint n) external payable;
}

contract ValDataOut {
    constructor() payable {}
    address valDataInAddr;

    function setAddr(address _addr) public {
        valDataInAddr = _addr;
    }

    function sendValData(uint _value, uint _n) public {
        IValDataIn(valDataInAddr).rx{value:_value}(_n);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


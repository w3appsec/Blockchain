// SPDX-License-Identifier: NLPL

pragma solidity >= 0.8.0;

contract Receiver {
    receive() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function shGasLeft() public view returns(uint) {
        return gasleft();
    }
}



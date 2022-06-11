// SPDX-License-Identifier: NLPL

pragma solidity >= 0.8.0;

contract Sender {
    constructor() payable {}

    function sendEther(address payable receiver, uint ammount) public {
        receiver.transfer(ammount);
    }
    
    function getBalance() public view returns (uint) {
      return address(this).balance;
    }

    function shGasLeft() public view returns(uint) {
        return gasleft();
    }
}


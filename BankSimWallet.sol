// SPDX-License-Identifier: EPL-2.0

pragma solidity ^0.8.0;

interface Ibank {
    function newCustomer() external payable returns (uint);
    function deposit() external payable returns (uint);
    function withdraw(uint withdrawAmount) external returns (uint remainingBal);
    function custBalance() external view returns (uint);
    function getFee() external view returns(uint);
}

contract BankSimWallet {
    address addr;

    constructor() payable {}
    receive() external payable {}
    
    function bankAddr(address _addr) public {
        addr = _addr;
    }

    function openAccount() public returns (uint) {
        uint _fee = getFee();
        return Ibank(addr).newCustomer{value:_fee}();
    }

    function deposit(uint _ammt) public returns (uint) {
        return Ibank(addr).deposit{value:_ammt}();
    }

    function withdraw(uint _ammt) public returns (uint) {
        return Ibank(addr).withdraw(_ammt);
    }

    function bankBalance() public view returns (uint) {
        return Ibank(addr).custBalance();
    }

    function walletBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getFee() public view returns(uint) {  
        return Ibank(addr).getFee();
    }
}



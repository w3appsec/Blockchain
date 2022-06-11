// SPDX-License-Identifier: EPL-2.0

pragma solidity ^0.8.0;

interface tokenXchng {
    function setFee(uint _fee) external;
    function xchngBalance() external view returns(uint);
}

contract tokenXchngSimAdmin { 
    
    constructor () payable {}
    receive() external payable {}
   
    address addr;
    function xchngAddr(address _addr) public {
        addr = _addr;
    }

    function setFee(uint _fee) public payable {
        tokenXchng t = tokenXchng(addr); 
        t.setFee(_fee);
    }
    
    function xchngBalance() public view returns(uint) {
        tokenXchng t = tokenXchng(addr); 
        return t.xchngBalance();
    }
}


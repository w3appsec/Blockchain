// SPDX-License-Identifier: EPL-2.0

pragma solidity ^0.8.0;

interface Ibank {
    function setFee(uint _fee) external;
    function totalAssets() external view returns(uint);
}

contract BankSimAdmin { 
    
    constructor () payable {}
    receive() external payable {}
   
    address addr;
    function bankAddr(address _addr) public {
        addr = _addr;
    }

    function setFee(uint _fee) public {
        Ibank b = Ibank(addr); 
        b.setFee(_fee);
    }

    function totalAssets() public view returns(uint) {
        Ibank b = Ibank(addr); 
        return b.totalAssets();
    }
}


// SPDX-License-Identifier: EPL-2.0

pragma solidity ^0.8.0;

interface tokenXchng {
    function create(string calldata name, string calldata _resource, uint price) external returns(uint);  
    function changePrice(string calldata _name, uint _price) external;
    function withdraw(uint ammount) external;
    function sell(string calldata name) external payable;
    function resource(string calldata name) external view returns(string memory);
    function price(string calldata name) external view returns(uint); 
    function custBalance() external view returns(uint);
    function list() external view returns(string[] memory);
    function getFee() external view returns(uint);
}

contract TokenXchngSimWallet { 
    
    constructor () payable {}
    receive() external payable {}

    address addr;
    function xchngAddr(address _addr) public {
        addr = _addr;
    }

    function tokens() public view returns(string[] memory) { 
        tokenXchng t = tokenXchng(addr);
        return t.list();
    } 
    
    function buy(string calldata name) public {
        tokenXchng t = tokenXchng(addr);
        uint _fee = t.getFee();
        uint _price = t.price(name); 
        t.sell{value: _price+_fee}(name); 
    }
    
    function withdraw(uint ammount) public payable {
        tokenXchng t = tokenXchng(addr); 
        t.withdraw(ammount);
    }
    
    function fee() public view returns(uint) {  
        tokenXchng t = tokenXchng(addr);
        return t.getFee();
    }

    function resource(string memory name) public view returns(string memory) { 
        tokenXchng t = tokenXchng(addr); 
        return (t.resource(name)); 
    }
    
    function price(string memory name) public view returns(uint) { 
        tokenXchng t = tokenXchng(addr); 
        return (t.price(name)); 
    }
    
    function xchngBalance() public view returns(uint) { 
        tokenXchng t = tokenXchng(addr); 
        return (t.custBalance());
    }
    
    function create(string memory _name, string memory _resource, uint _price) public returns(uint) {
        tokenXchng t = tokenXchng(addr);
        uint _tokenNum = t.create(_name, _resource, _price);
        return (_tokenNum);
    }
        
    function changePrice(string memory _name, uint _price) public {
        tokenXchng t = tokenXchng(addr);
        t.changePrice(_name, _price);
    }
        
    function walletBalance() public view returns(uint) { 
        return address(this).balance;
    }
}



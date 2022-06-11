// SPDX-License-Identifier: EPL-2.0

pragma solidity ^0.8.0;

contract TokenXchng {
    struct TokenStruct {
        string resource;
        address owner;
        uint price;
    }

    mapping(address => uint) public balances;
    mapping(string => TokenStruct) tokens;
    string[] public symLUT;
    uint numTokens = 0;
    uint fee = 100;
    
    // Your ENS here
    address tokenXchngAdmin = 0x540d7E428D5207B30EE03F2551Cbb5751D3c7569;

    constructor () payable {}
    receive() external payable {}
    
    function create(string memory _name, string memory _resource, uint _price) external returns(uint) { 
        require(bytes(_name).length > 0);
        require(bytes(_resource).length > 0);
        require(_price > 0);
        require(bytes(tokens[_name].resource).length == 0);

        TokenStruct memory newToken;  
        newToken = TokenStruct(_resource, msg.sender, _price);
        tokens[_name] = newToken;
        symLUT.push(_name);
        numTokens++; 
        return numTokens; 
    }
    
    function changePrice(string calldata _name, uint _price) external {
        require (address(msg.sender) == address(tokens[_name].owner));
        require (tokens[_name].price != _price);
        
        tokens[_name].price = _price;
    }
    
    function withdraw(uint ammount) external { 
        require (balances[msg.sender] >= ammount);

        // Reenterancy Defence, subtract from account before payment
        balances[msg.sender] -= ammount;
        payable(msg.sender).transfer(ammount);
    }

    function sell(string calldata name) external payable {
        require (address(msg.sender) != address(tokens[name].owner));
        require (uint (msg.value) == (tokens[name].price) + getFee());

        balances[tokens[name].owner] += tokens[name].price;
        tokens[name].owner = msg.sender; 
    }

    function resource(string calldata name) external view returns(string memory) { 
        return tokens[name].resource; 
    } 
    
    function owner(string calldata name) external view returns(address) { 
        return tokens[name].owner; 
    } 
    
    function price(string calldata name) external view returns(uint) {
        return tokens[name].price; 
    } 
    
    function custBalance() external view returns(uint) {
        return balances[msg.sender];
    }
    
    function list() external view returns(string[] memory) { 
        return symLUT;
    }

    function xchngBalance() external view returns(uint) {
        // Access control
        require(msg.sender == tokenXchngAdmin);
        return address(this).balance;
    }
    
    function setFee(uint _fee) external {
        // Access control
        require(msg.sender == tokenXchngAdmin);

        fee = _fee;
    }

    function getFee() public view returns(uint) {  
        return fee;  
    }
}



// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

contract EtherDistributor {
    constructor() payable {
        funder = msg.sender;
    }

    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }

    struct Receiver {
        bool valid;
        uint balance;
        uint startBlock;
        uint periodBlocks;
        uint maxLimit;
        uint currLimit;
    }
    mapping(address => Receiver) private receivers;

    address immutable private funder;

    event AddReceiver(address indexed addr, uint limit, uint period);
    event DeleteReceiver(address indexed addr);
    event PushEther(address indexed addr, uint value);
    event PullEther(address indexed addr, uint value);
    event Pay(address indexed addr, uint value);

    modifier onlyFunder {
        require(msg.sender == funder);
        _;
    }

    modifier isReceiver {
        require(receivers[msg.sender].valid);
        _;
    }

    modifier notReceiver {
        require(!receivers[msg.sender].valid);
        _;
    }

    function addReceiver(address addr, uint limit, uint period) external onlyFunder {
        emit AddReceiver(addr, limit, period);
        require(addr != funder);
        require(notContract(addr));
        require(!receivers[addr].valid);
        receivers[addr].valid = true;
        receivers[addr].startBlock = block.number;
        receivers[addr].periodBlocks = period;
        receivers[addr].currLimit = limit;
        receivers[addr].maxLimit = limit;
    }

    function deleteReceiver(address _receiver) external onlyFunder {
        emit DeleteReceiver(_receiver);
        require(receivers[_receiver].valid);
        require(receivers[_receiver].balance == 0);
        delete(receivers[_receiver]);
    }

    function pushEther(address addr) external payable onlyFunder returns (uint) {
        emit PushEther(addr, msg.value);
        require(receivers[addr].valid);
        receivers[addr].balance += msg.value;
        return receivers[addr].balance;
    }

    function pullEther(address from, uint amount) external onlyFunder returns (uint) {
        emit PullEther(from, amount);
        require(receivers[from].valid);
        require(amount <= receivers[from].balance);
        receivers[from].balance -= amount;
        (bool success, ) = payable(funder).call{value: amount}("");
        require(success);
        return receivers[from].balance;
    }

    function pay(address payee, uint amount) external isReceiver returns (uint) {
        emit Pay(payee, amount);
        address addr = msg.sender;
        require(notContract(addr));
        require(amount <= receivers[addr].balance);

        uint start = receivers[addr].startBlock;
        uint _blockNum = block.number;
        uint elapsed = _blockNum - start;

        if (elapsed > receivers[addr].periodBlocks) {
            receivers[addr].startBlock = _blockNum;
            receivers[addr].currLimit = receivers[addr].maxLimit;
        } else {
            receivers[addr].currLimit -= amount;
        }
        require(amount <= receivers[addr].currLimit);

        receivers[addr].balance -= amount;
        (bool success, ) = payee.call{value: amount}("");
        require(success);
        return receivers[addr].balance;
    }

    function receiverBalance(address _receiver) external view onlyFunder returns (uint) {
        return receivers[_receiver].balance;
    }

    function myBalance() external view isReceiver returns (uint) {
        return receivers[msg.sender].balance;
    }

    function totalAssets() external view onlyFunder returns (uint) {
        return address(this).balance;
    }

    function blockNum() external view returns (uint) {
        return block.number;
    }

    function notContract(address addr) internal view returns (bool) {
        return addr.code.length == 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EtherWallet {
    address payable public immutable owner;
    event Log(string funName, address from, uint256 value, bytes data);

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }

    function withdraw1() external {
        require(msg.sender == owner, "Not owner");
        uint256 amount = 100; // Fixed amount for demo purposes
        require(address(this).balance >= amount, "Insufficient balance");
        payable(msg.sender).transfer(amount);
        emit Log("withdraw1", msg.sender, amount, "");
    }

    function withdraw2() external {
        require(msg.sender == owner, "Not owner");
        uint256 amount = 200; // Fixed amount for demo purposes
        require(address(this).balance >= amount, "Insufficient balance");
        bool success = payable(msg.sender).send(amount);
        require(success, "Send Failed");
        emit Log("withdraw2", msg.sender, amount, "");
    }

    function withdraw3() external {
        require(msg.sender == owner, "Not owner");
        uint256 amount = address(this).balance;
        require(amount > 0, "Insufficient balance");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Call Failed");
        emit Log("withdraw3", msg.sender, amount, "");
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

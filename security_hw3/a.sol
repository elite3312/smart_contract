// SPDX-License-Identifier: MIT
pragma solidity^0.8.0;

contract Donation{
    mapping(address=>uint)public balances;
    address payable public owner;
    constructor(){
    owner=payable(msg.sender);
    }
    function donate()public payable{
        //Receivedonations
        balances[msg.sender]+=msg.value;
    }
    function withdraw(uint amount)public{
        require(balances[msg.sender]>=amount,"Insufficientbalance");
        balances[msg.sender]-=amount;
        msg.sender.transfer(amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract VotersList{
    
    struct Voter {
        string name;
        bool voted;
    }
    mapping(address => Voter) public voters;  //List of voters
    uint public numVoters = 0;
    address public manager; //Manager of voting contract
    
    constructor () public {
        manager = msg.sender;  //Set contract creator as manager
    }
    //Add new voter
    function addVoter(address voterAddress, string memory name) public restricted returns (uint){
        Voter memory v;
        v.name = name;
        v.voted = false;
        voters[voterAddress] = v;
        numVoters++;
        return numVoters;
    }
    
    modifier restricted() { //Only manager can do
        require (msg.sender == manager);
        _;
    }
}
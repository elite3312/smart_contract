// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleStorage {
    // State variable to store a number
    uint256 public num;

    // You need to send a transaction to write to a state variable.
    function set(uint256 _num) public {
        num = _num;
    }

    // You can read from a state variable without sending a transaction.
    function get() public view returns (uint256) {
        return num;
    }

    //increment 
    function inc_bad() public {
        //perform operations on the state var is expensive
        num+=1;
        num+=1;
        num+=1;
        num+=1;
    }

    function inc_good() public {
        //perform operations on the state var is expensive
        uint256 local_num=num;
        local_num+=1;
        local_num+=1;
        local_num+=1;
        local_num+=1;
        num=local_num;
    }

}

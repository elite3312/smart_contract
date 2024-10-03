// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MyConStructor {
    // coding convention to uppercase constant variables
    address public immutable MY_ADDRESS;
    uint256 public immutable MY_UINT;

    constructor(uint256 _myUint) {
        MY_ADDRESS = msg.sender;
        MY_UINT = _myUint;
    }

    
}
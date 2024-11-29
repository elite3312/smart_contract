// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Array {
    // Several ways to initialize an array
    uint256[] public arr;
   
    function get() public view returns (uint256) {
        return arr[4];
    }

  }

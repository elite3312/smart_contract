// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract A {
    // Several ways to initialize an array
    uint256[] public arr;
   
    function get() public virtual view returns (uint256) {
        return arr[0];
    }

}
contract B is A {
    function get() public override view returns (uint256) {
        return arr[0];
    }

}

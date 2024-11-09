// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DataLocations {
    uint256[] public arr;
    mapping(uint256 => address) map;

    struct MyStruct {
        uint256 foo;
    }

    mapping(uint256 => MyStruct) myStructs;

    function f() public {
        // call _f with state variables
        _f(arr, map, myStructs[1]);

        // get a struct from a mapping
        MyStruct storage myStruct = myStructs[1];
        myStruct.foo=123;
        // create a struct in memory
        MyStruct memory myMemStruct = MyStruct(0);
        
        myMemStruct.foo=456;

    }

    function _f(
        uint256[] storage _arr,
        mapping(uint256 => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        
        
    }

    // You can return memory variables
    function g(uint256[] memory _arr) public returns (uint256[] memory) {
        _arr[0]=0;//this is ok!
    }

    function h(uint256[] calldata _arr) external {
        //_arr[0]=0; this will give error, you cannot modify calldata
    } 
}

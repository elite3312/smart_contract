// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;
contract RentalAgreement {
    string public ret ;
    constructor(
      
    ) {
       
    }

    // Function to make rent payment
    //123,456
    function encode( string memory a, string memory b) public  {
       ret=string(abi.encodePacked(a, b));//ret becomes 123456
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;
contract RentalAgreement {
   
    constructor(
      
    ) {
       
    }

    // Function to make rent payment
    function encode( string memory a, string memory b) public  {
       string(abi.encodePacked(a, b));
    }
}

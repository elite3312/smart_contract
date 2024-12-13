// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;
contract A {
    address public retA;
    constructor(
      
    ) {
       
    }


    function bar( )  external returns (address)  {
       retA=msg.sender;
       return retA;
    }
}

contract B {
    address public retB;
    constructor(
      
    ) {
       
    }


    function foo( )  public returns (address)  {
       A a = new A();
       retB=a.bar();
       return retB;//it will be the address of contract B, which is 0x729416c769882c9Ae49cE51f3F91ec12Daf3cb73 in this example
    }
}

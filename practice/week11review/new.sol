// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract B  {
        uint   []f1;
        uint[] f2;
    function get() public  {
        f1=new uint[](10);
        f2=f1;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MathBase {
    modifier exactDividedBy2And3(uint256 _a) virtual {
        _;
        require(_a % 2 ==0,"div 2");
        require(_a % 3 ==0,"div 3");
    }
    function a(uint256 b) exactDividedBy2And3(b) public pure{
        int c=0;
        
    }
}

contract MathDivisor is MathBase {
    modifier exactDividedBy2And3(uint256 _a) override {
        _;
        require(_a % 2 ==0 ,"div 2");
        require(_a % 3 ==0,"div 3");
        require(_a % 5 ==0,"div 5");
    }
     function a1(uint256 b) exactDividedBy2And3(b) public pure{
        int c=0;
        
    }
}

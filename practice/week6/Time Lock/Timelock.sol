// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


// The time lock Solidity smart contract below demonstrates how to use the passing of time in a Solidity smart contract.
// Think of this contract like a weekly allowance or escrow that needs to pay out weekly.
//

contract Timelock {
    // calling SafeMath will add extra functions to the uint data type
    using SafeMath for uint256; // you can make a call like myUint.add(123)

    // amount of ether you deposited is saved in balances
    mapping(address => uint256) public balances;

    // when you can withdraw is saved in lockTime
    mapping(address => uint256) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    // the function that is commented out is vulnerable to overflow by updating the function below with a very large number
    // to prevent this use safe math to prevent overflow
    function increaseLockTime(uint _secondsToIncrease) public {
         lockTime[msg.sender] += _secondsToIncrease;
     }



    function withdraw() public {
        // check that the sender has ether deposited in this contract in the mapping and the balance is >0
        require(balances[msg.sender] > 0, "insufficient funds");

        // check that the now time is > the time saved in the lock time mapping
        require(block.timestamp > lockTime[msg.sender], "lock time has not expired");

        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ether");
    }
}

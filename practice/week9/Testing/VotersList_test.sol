// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
//import "../practice/week9/Testing/VotersList.sol";
import "./VotersList.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract VoterListTest is VotersList {
    
    address acc0;   //Variables used to emulate different accounts  
    address acc1;
    address acc2;
    address acc3;
/// 'beforeAll' runs before all other tests
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0); //Initiate acc variables
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        acc3 = TestsAccounts.getAccount(3);
    }
    
    /// Account at index zero (account-0) is default account, so manager will be set to acc0
    function managerTest() public {
        Assert.equal(manager, acc0, 'Manager should be acc0');
    }
    
    /// Add a voter as manager
    /// When msg.sender isn't specified, default account (i.e., account-0) is considered as the sender
    function addVoter() public {
        Assert.equal(addVoter(acc1, 'Alice'), 1, 'Should be equal to 1');
    }
    
    /// Try to add voter as a user other than manager. This should fail
    /// #sender: account-1
    function addVoterFailure() public {
        Assert.equal(addVoter(acc2, 'Bob'), 2, 'Should be equal to 2');    
    }
    
    /// Try to add voter as manager again
    function addVoter2() public {
        Assert.equal(addVoter(acc3, 'Charlie'), 2, 'Should be equal to 2');    
    }
    
    /// Verify number of votes
    function voteOpenTest() public {
        Assert.equal(numVoters, 2, 'Should be equal to 2');
    }
}
  

    
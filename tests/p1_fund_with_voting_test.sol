// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
import "remix_accounts.sol";
import "../homework2/p1_fund_with_voting.sol"; // Adjust the path as necessary

contract testSuite {
    DecentralizedCharityFund fund;
    address donor;   //Variables used to emulate different accounts  

    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        fund = new DecentralizedCharityFund();
        donor = TestsAccounts.getAccount(0); // Get a test account
    }
    /// #sender: account-0
    /// #value: 100
    function testDonate() public payable{
        // Use a specific account to donate
        Assert.equal(msg.value, 100, 'value should be 100');
       
        fund.donate {value: 100}(); // Call donate from the test account

        // Check the voting power of the donor
        uint256 totalVotingPower=fund.totalVotingPower();
        Assert.equal(totalVotingPower, 100, "total voting power should be 100");
    }

    function testSubmitFundingRequest() public {
        // Test funding request submission
        fund.submitFundingRequest(address(this), 50, "Test Project");
        Assert.equal(fund.requestCount(), 1, "Request count should be 1");
    }

    /// #sender: account-1
    /// #value: 100
    function testVoteOnRequest() public payable {
        // Test voting on a funding request
        Assert.equal(msg.value, 100, 'value should be 100');
        fund.donate{value: 100}(); // Ensure the sender has voting power
        fund.submitFundingRequest(address(this), 50, "Test Project");
        bool voteOutCome = fund.voteOnRequest(0);
        
        // Access voteCount directly from the struct
        Assert.equal(voteOutCome, true, "Vote count should be true");
    }
    
    /// #sender: account-1
    /// #value: 100
    function testFinalizeRequest() public payable{
        // Test finalizing a funding request
        Assert.equal(msg.value, 100, 'value should be 100');
        fund.donate{value: 100}(); // Ensure the sender has voting power
        fund.submitFundingRequest(address(this), 100, "Test Project");
        fund.voteOnRequest(1);
        //bool finalized=fund.finalizeRequest(1);
        
        // Check if the project was finalized
        //Assert.equal(finalized, true,"Request should be finalized");
        //todo
    }

    /// #sender: account-1
    /// #value: 50
    function testInsufficientBalanceOnFinalize() public payable {
        // Test that finalizing a request fails if the contract has insufficient balance
        Assert.equal(msg.value, 50, 'value should be 50');
        fund.donate{value: 50}(); // Ensure the sender has voting power
        fund.submitFundingRequest(address(this), 100, "Test Project");
        fund.voteOnRequest(2);
        
        // Attempt to finalize with insufficient balance
        (bool success, ) = address(fund).call(abi.encodeWithSignature("finalizeRequest(uint256)", 2));
        Assert.equal(success,false, "Finalizing should fail due to insufficient balance");
    }

    /// #sender: account-1
    /// #value: 100
    function testVotingPowerDeduction() public payable{
        // Test that voting power is deducted after voting
        fund.donate{value: 100}();
        fund.submitFundingRequest(address(this), 50, "Test Project");
        fund.voteOnRequest(3);
        
        Assert.equal(fund.votingPower(msg.sender), 0, "Voting power should be deducted after voting");
    }

    /// #sender: account-1
    /// #value: 200
    function testTransferUsingCall() public payable {
        // Test that funds are transferred using call
        Assert.equal(msg.value, 200, 'value should be 200');
        fund.donate{value: 200}();
        fund.submitFundingRequest(address(this), 100, "Test Project");
        fund.voteOnRequest(4);
        fund.finalizeRequest(4);
        
        // Check if the contract balance is reduced
        Assert.equal(address(fund).balance, 100, "Contract balance should be 100 after transfer");
    }


}
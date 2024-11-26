// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
import "remix_accounts.sol";
import "../homework2/p1_fund_with_voting.sol"; // Adjust the path as necessary

contract testSuite {
    DecentralizedCharityFund fund;

    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        fund = new DecentralizedCharityFund();
    }
    /// #sender: account-1
    /// #value: 100
    function testDonate() public {
        // Use a specific account to donate
        address donor = TestsAccounts.getAccount(1); // Get a test account
        fund.donate{value: 100}(); // Call donate from the test account

        // Check the voting power of the donor
        Assert.equal(fund.votingPower(donor), 100, "Donor's voting power should be 100");
    }

    function testSubmitFundingRequest() public {
        // Test funding request submission
        fund.submitFundingRequest(address(this), 50, "Test Project");
        Assert.equal(fund.requestCount(), 1, "Request count should be 1");
    }

    function testVoteOnRequest() public {
        // Test voting on a funding request
        fund.donate{value: 100}(); // Ensure the sender has voting power
        fund.submitFundingRequest(address(this), 50, "Test Project");
        fund.voteOnRequest(0);
        
        // Access voteCount directly from the struct
        (,, , uint256 voteCount, ) = fund.fundingRequests(0);
        Assert.equal(voteCount, 100, "Vote count should be 100");
    }

    function testFinalizeRequest() public {
        // Test finalizing a funding request
        fund.donate{value: 200}(); // Ensure the sender has voting power
        fund.submitFundingRequest(address(this), 100, "Test Project");
        fund.voteOnRequest(1);
        fund.finalizeRequest(1);
        
        // Check if the project was finalized
        (,, , , bool finalized) = fund.fundingRequests(1);
        Assert.ok(finalized, "Request should be finalized");
    }

    function testInsufficientBalanceOnFinalize() public {
        // Test that finalizing a request fails if the contract has insufficient balance
        fund.donate{value: 50}(); // Ensure the sender has voting power
        fund.submitFundingRequest(address(this), 100, "Test Project");
        fund.voteOnRequest(2);
        
        // Attempt to finalize with insufficient balance
        (bool success, ) = address(fund).call(abi.encodeWithSignature("finalizeRequest(uint256)", 2));
        Assert.equal(success,false, "Finalizing should fail due to insufficient balance");
    }

    function testVotingPowerDeduction() public {
        // Test that voting power is deducted after voting
        fund.donate{value: 100}();
        fund.submitFundingRequest(address(this), 50, "Test Project");
        fund.voteOnRequest(3);
        
        Assert.equal(fund.votingPower(msg.sender), 0, "Voting power should be deducted after voting");
    }

    function testTransferUsingCall() public {
        // Test that funds are transferred using call
        fund.donate{value: 200}();
        fund.submitFundingRequest(address(this), 100, "Test Project");
        fund.voteOnRequest(4);
        fund.finalizeRequest(4);
        
        // Check if the contract balance is reduced
        Assert.equal(address(fund).balance, 100, "Contract balance should be 100 after transfer");
    }


}
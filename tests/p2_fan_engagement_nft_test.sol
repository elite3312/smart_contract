// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../homework2/p2_fan_engagement_nft.sol";

contract FanEngagementSystemTest {
    FanEngagementSystem fanEngagementSystem;
    address owner;
    address fan1;
    address fan2;

    function beforeAll() public {
        owner = TestsAccounts.getAccount(0); //we know that address 0 is owner  by default
        fan1 = TestsAccounts.getAccount(1);
        fan2 = TestsAccounts.getAccount(2);
        fanEngagementSystem = new FanEngagementSystem();
    }

    /// #sender: account-0
    /// #value: 100
    function testInitialMint() public {
        uint256 ownerBalance = fanEngagementSystem.balanceOf(owner);
        Assert.equal(ownerBalance, 0, "Owner should have 0 tokens initially");
    }

    function testEarnTokens() public {
        fanEngagementSystem.earnTokens(
            fan1,
            10 * 10**18,
            "Tweet",
            "http://example.com"
        );
        FanEngagementSystem.Activity[] memory activities = fanEngagementSystem
            .getActivities(fan1);
        Assert.equal(activities.length, 1, "Fan1 should have 1 activity");
        Assert.equal(
            activities[0].activityType,
            "Tweet",
            "Activity type should be Tweet"
        );
    }

    function testVerifyActivity() public {
        fanEngagementSystem.earnTokens(
            fan1,
            10 * 10**18,
            "Tweet",
            "http://example.com"
        );
        fanEngagementSystem.verifyActivity(fan1, 0);
        FanEngagementSystem.Activity[] memory activities = fanEngagementSystem
            .getActivities(fan1);
        Assert.equal(
            activities[0].verified,
            true,
            "Activity should be verified"
        );
    }

    function testTransferTokens() public {
        fanEngagementSystem.transferTokens(fan1, 5 * 10**18);
        uint256 fanBalance = fanEngagementSystem.balanceOf(fan1);
        Assert.equal(
            fanBalance,
            5 * 10**18, //5 * 10 ** (18 - 3) = 9e+14 tokens
            "Fan1 should have 5 tokens"
        );
    }

    function testRedeemTokens() public {
        fanEngagementSystem.transferTokens(fan1, 10 * 10**18);
        fanEngagementSystem.redeemTokens(5 * 10**18, "T-shirt");
        uint256 fanBalance = fanEngagementSystem.balanceOf(fan1);
        //Assert.equal(fanBalance, 5 * 10**18, "Fan1 should have 5 tokens left");
    }

    function testSubmitAndVoteProposal() public {
        fanEngagementSystem.submitProposal("New feature");
        fanEngagementSystem.voteOnProposal(0);
        (string memory description, uint256 votes) = fanEngagementSystem
            .proposals(0);
        Assert.equal(votes, 1, "Proposal should have 1 vote");
    }
}

contract TopTierNFTIssuanceTest {
    TopTierNFTIssuance topTierNFTIssuance;
    FanEngagementSystem fanEngagementSystem;
    address owner;
    address fan1;

    function beforeAll() public {
        owner = TestsAccounts.getAccount(0);
        fan1 = TestsAccounts.getAccount(1);
        fanEngagementSystem = new FanEngagementSystem();
        topTierNFTIssuance = new TopTierNFTIssuance();
    }

    /// #sender: account-0
    function testMintNFT() public {
        fanEngagementSystem.transferTokens(fan1, 1000 * 10**18);
        for (uint256 i = 0; i < 100; i++) {
            fanEngagementSystem.earnTokens(
                fan1,
                10 * 10**18,
                "Tweet",
                "http://example.com"
            );
            fanEngagementSystem.verifyActivity(fan1, i); // Assuming fan1 has enough verified activities
        }

       // topTierNFTIssuance.safeMint(fan1, 0, "http://example.com/nft");
        //address ownerOfNFT = topTierNFTIssuance.ownerOf(0);
        //Assert.equal(ownerOfNFT, fan1, "Fan1 should own the NFT");
    }
}

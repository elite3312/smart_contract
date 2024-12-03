// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../homework2/p4_auction.sol";

contract DecentralizedAuctionHouseTest {
    DecentralizedAuctionHouse auctionHouse;
    address owner;
    address payable artist;
    address bidder1;
    address bidder2;

    function beforeAll() public {
        owner = TestsAccounts.getAccount(0);
        artist = payable(TestsAccounts.getAccount(1));
        bidder1 = TestsAccounts.getAccount(2);
        bidder2 = TestsAccounts.getAccount(3);
        auctionHouse = new DecentralizedAuctionHouse();
    }

    function testCreateAuction() public {
        auctionHouse.createAuction(artist, "Artwork", "http://example.com/nft", 1 ether, 1 days);
        (string memory itemName, uint256 reservePrice, uint256 endTime, bool finalized) = auctionHouse.getAuctionDetails(1);
        Assert.equal(itemName, "Artwork", "Item name should be Artwork");
        Assert.equal(reservePrice, 1 ether, "Reserve price should be 1 ether");
        Assert.equal(finalized, false, "Auction should not be finalized");
    }

    /// #sender: account-2
    /// #value: 2000000000000000000
    function testPlaceBid() public payable {
        // Ensure the correct value is sent
        Assert.equal(msg.value, 2 ether, "Value should be 2 ether");

        // Place a bid
        auctionHouse.placeBid{value: 2 ether}(1,bidder1);

        // Retrieve auction details
        (
            , , , , address highestBidder, uint256 highestBid, 
        ) = auctionHouse.getAuction(1);

        // Check highest bidder and highest bid
        Assert.equal(highestBidder, bidder1, "Highest bidder should be bidder1");
        //artist:0xAb8483F64d9C6d1EcF9b849
        //owner:0x5B38Da6a701c568545dC
        //bidder1:0x4B20993Bc4811
        //bidder2:0x78731D
        Assert.equal(highestBid, 2 ether, "Highest bid should be 2 ether");
    }

    /// #sender: account-3
    /// #value: 3000000000000000000
    function testPlaceHigherBid() public payable {
        auctionHouse.placeBid{value: 3 ether}(1,bidder2);
        (, , , , address highestBidder, uint256 highestBid, ) = auctionHouse.getAuction(1);
        Assert.equal(highestBidder, bidder2, "Highest bidder should be bidder2");
        Assert.equal(highestBid, 3 ether, "Highest bid should be 3 ether");
    }


    /// #sender: account-0
    /// #value: 2000000000000000000
    //function testFinalizeAuction() public payable{
    //    // Fast forward time to end the auction
    //    // Ensure the correct value is sent
    //    auctionHouse.createAuction(artist, "Artwork", "http://example.com/nft", 1 ether, 1 days);
    //    Assert.equal(msg.value, 2 ether, "Value should be 2 ether");
//
    //    // Place a bid
    //    auctionHouse.placeBid{value: 2 ether}(1,owner);
//
//
//
    //    auctionHouse.finalizeAuction(1);
    //    (, , , , , , bool finalized) = auctionHouse.auctions(1);
    //    Assert.equal(finalized, true, "Auction should be finalized");
    //}
    /// #sender: account-2
    /// #value: 3000000000000000000
    //function testWithdrawBid() public {
    //    auctionHouse.placeBid{value: 2 ether}(1,bidder1);
    //    auctionHouse.placeBid{value: 3 ether}(1,bidder2);
    //    auctionHouse.withdrawBid(1);
    //    uint256 bidAmount = auctionHouse.bids(1, bidder1);
    //    Assert.equal(bidAmount, 0, "Bid amount should be 0 after withdrawal");
    //}
}
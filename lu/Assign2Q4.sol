// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DecentralizedAuctionHouse is ReentrancyGuard {
    struct Auction {
        uint256 id;
        address payable artist;
        string itemName;
        uint256 reservePrice;
        uint256 highestBid;
        address payable highestBidder;
        uint256 endTime;
        bool finalized;
    }

    uint256 public auctionCount;
    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => mapping(address => uint256)) public bids;

    uint256 public constant LOCK_PERIOD = 300; // Lock period for bid withdrawal
    uint256 public constant EXTENSION_TIME = 300; // Time extension for late bids

    event AuctionCreated(uint256 indexed auctionId, address indexed artist, string itemName, uint256 reservePrice, uint256 endTime);
    event BidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event BidWithdrawn(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionFinalized(uint256 indexed auctionId, address indexed artist, address indexed winner, uint256 amount);

    constructor() {
        auctionCount = 0;
    }

    function createAuction(string memory itemName, uint256 reservePrice, uint256 auctionDuration) external {
        require(reservePrice > 0, "Reserve price must be greater than zero");
        require(auctionDuration > 0, "Auction duration must be greater than zero");

        auctionCount++;
        uint256 endTime = block.timestamp + auctionDuration;

        auctions[auctionCount] = Auction({
            id: auctionCount,
            artist: payable(msg.sender),
            itemName: itemName,
            reservePrice: reservePrice,
            highestBid: 0,
            highestBidder: payable(address(0)),
            endTime: endTime,
            finalized: false
        });

        emit AuctionCreated(auctionCount, msg.sender, itemName, reservePrice, endTime);
    }

    function placeBid(uint256 auctionId) external payable nonReentrant {
        Auction storage auction = auctions[auctionId];
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.value > auction.highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= auction.reservePrice, "Bid must meet reserve price");

        // Refund the previous highest bidder
        if (auction.highestBidder != address(0)) {
            bids[auctionId][auction.highestBidder] += auction.highestBid;
        }

        // Extend auction time if bid is placed close to the end
        if (block.timestamp + EXTENSION_TIME >= auction.endTime) {
            auction.endTime += EXTENSION_TIME;
        }

        // Update auction state
        auction.highestBid = msg.value;
        auction.highestBidder = payable(msg.sender);

        emit BidPlaced(auctionId, msg.sender, msg.value);
    }

    function withdrawBid(uint256 auctionId) external nonReentrant {
        Auction storage auction = auctions[auctionId];
        uint256 amount = bids[auctionId][msg.sender];

        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.sender != auction.highestBidder, "Highest bidder cannot withdraw");
        require(amount > 0, "No bid to withdraw");

        // Reset the bid amount and transfer funds back
        bids[auctionId][msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit BidWithdrawn(auctionId, msg.sender, amount);
    }

    function finalizeAuction(uint256 auctionId) external nonReentrant {
        Auction storage auction = auctions[auctionId];

        require(block.timestamp >= auction.endTime, "Auction has not ended yet");
        require(!auction.finalized, "Auction already finalized");
        require(msg.sender == auction.artist, "Only the artist can finalize");

        auction.finalized = true;

        if (auction.highestBid >= auction.reservePrice) {
            // Transfer the winning bid to the artist
            (bool success, ) = auction.artist.call{value: auction.highestBid}("");
            require(success, "Transfer to artist failed");

            emit AuctionFinalized(auctionId, auction.artist, auction.highestBidder, auction.highestBid);
        } else {
            // Handle reserve price not met
            if (auction.highestBidder != address(0)) {
                bids[auctionId][auction.highestBidder] += auction.highestBid;
            }

            emit AuctionFinalized(auctionId, auction.artist, address(0), 0);
        }
    }

    function getAuctionDetails(uint256 auctionId) external view returns (string memory, uint256, uint256, uint256, address, bool) {
        Auction storage auction = auctions[auctionId];
        return (
            auction.itemName,
            auction.reservePrice,
            auction.highestBid,
            auction.endTime,
            auction.highestBidder,
            auction.finalized
        );
    }
}

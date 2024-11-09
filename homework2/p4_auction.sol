// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract DecentralizedAuctionHouse {
    struct Auction {
        string itemName;
        uint256 reservePrice;//the botton price
        uint256 endTime;//a unix timestamp
        address highestBidder;
        uint256 highestBid;
        bool finalized;
        
    }
    address public owner;
    mapping(uint256 => Auction) public auctions;
  
    
    mapping(uint256 => mapping(address => uint256)) public bids; // auctionId => (bidder => bidAmount)
    uint256 public auctionCount;

    event AuctionCreated(uint256 auctionId, string itemName, uint256 reservePrice, uint256 endTime);
    event NewBid(uint256 auctionId, address bidder, uint256 bidAmount);
    event BidWithdrawn(uint256 auctionId, address bidder, uint256 bidAmount);
    event AuctionFinalized(uint256 auctionId, address winner, uint256 winningBid);
 
   
    constructor() {
        auctionCount = 0;
        artwork=Artwork(msg.sender);
         owner = msg.sender;
    }

    function createAuction(string memory itemName,string memory uri, uint256 reservePrice, uint256 auctionDuration) public {
        require(auctionDuration > 0, "Auction duration must be greater than 0");
        auctionCount++;
        auctions[auctionCount] = Auction(itemName, reservePrice, block.timestamp + auctionDuration, address(0), 0, false);
       
        nft_uris[auctionCount]=uri;
        
        emit AuctionCreated(auctionCount, itemName, reservePrice, block.timestamp + auctionDuration);
    }

    function placeBid(uint256 auctionId, uint256 bidAmount) public payable {
        Auction storage auction = auctions[auctionId];
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(bidAmount > auction.highestBid, "Bid must be higher than current highest bid");
        require(bidAmount >= auction.reservePrice, "Bid must meet reserve price");

        auction.highestBidder = msg.sender;
        auction.highestBid = bidAmount;
        bids[auctionId][msg.sender] = bidAmount; // Store the new bid

        emit NewBid(auctionId, msg.sender, bidAmount);
    }

    function withdrawBid(uint256 auctionId) public {
        Auction storage auction = auctions[auctionId];
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.sender != auction.highestBidder, "Highest bidder cannot withdraw");

        uint256 amount = bids[auctionId][msg.sender];
        require(amount > 0, "No bid to withdraw");

        bids[auctionId][msg.sender] = 0; // Reset the bid amount
        payable(msg.sender).transfer(amount); // Transfer the bid amount back to the bidder

        emit BidWithdrawn(auctionId, msg.sender, amount);
    }

    function finalizeAuction(uint256 auctionId) public payable {
        require(msg.sender == owner, "Not owner");
        Auction storage auction = auctions[auctionId];
        //require(block.timestamp >= auction.endTime, "Auction is still active");
        require(!auction.finalized, "Auction already finalized");

        auction.finalized = true;

        if (auction.highestBidder != address(0)) {
            
            emit AuctionFinalized(auctionId, auction.highestBidder, auction.highestBid);
        } else {
            // Handle case where no bids were placed
            emit AuctionFinalized(auctionId, address(0), 0);
        }
    }

    function getAuctionDetails(uint256 auctionId) public view returns (string memory, uint256, uint256, bool) {
        Auction storage auction = auctions[auctionId];
        return (auction.itemName, auction.reservePrice, auction.endTime, auction.finalized);
    }
}

contract Artwork is ERC721URIStorage{

    address public owner;


    constructor()
        ERC721("Artwork", "ARTKN"){
            owner = msg.sender;
        }

    function safeMint(address to, uint256 tokenId, string memory uri)
         external
        
    {
        require()
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }




}
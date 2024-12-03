// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract DecentralizedAuctionHouse is ERC721URIStorage {
    struct Auction {
        address payable   owner;
        string itemName;
        uint256 reservePrice; //the botton price
        uint256 endTime; //a unix timestamp
        address highestBidder;
        uint256 highestBid;
        bool finalized;
    }
    
    mapping(uint256 => Auction) public auctions;
    function getAuction(uint256 auctionId) public view returns (
        address payable owner,
        string memory itemName,
        uint256 reservePrice,
        uint256 endTime,
        address highestBidder,
        uint256 highestBid,
        bool finalized
    ) {
    Auction storage auction = auctions[auctionId];
    return (
        auction.owner,
        auction.itemName,
        auction.reservePrice,
        auction.endTime,
        auction.highestBidder,
        auction.highestBid,
        auction.finalized
    );
}
    mapping(uint256 => mapping(address => uint256)) public bids; // auctionId => (bidder => bidAmount)
    address payable[]  public bidders; // auctionId => (bidder => bidAmount)
    uint256 public auctionCount;

    event AuctionCreated(
        address owner,
        uint256 auctionId,
        string itemName,
        uint256 reservePrice,
        uint256 endTime
    );

    event NewBid(uint256 auctionId, address bidder, uint256 bidAmount);
    event BidWithdrawn(uint256 auctionId, address bidder, uint256 bidAmount);
    event AuctionFinalized(uint256 auctionId, address winner,uint256 winningBid );

    constructor() ERC721("Artwork", "ARTKN") {
        auctionCount = 0;
    }

    function createAuction(
        address payable owner,
        string memory itemName,
        string memory uri,
        uint256 reservePrice,
        uint256 auctionDuration
    ) public {
        /*artists can create an NFT and put it up for auction*/
        require(auctionDuration > 0, "Auction duration must be greater than 0");
        auctionCount++;
        auctions[auctionCount] = Auction(
            owner,
            itemName,
            reservePrice ,
            block.timestamp + auctionDuration,
            address(0),
            0,
            false
        );
        _safeMint(owner, auctionCount);
        _setTokenURI(auctionCount, uri);//initially, the artist holds the NFT


        emit AuctionCreated(
            owner,
            auctionCount,
            itemName,
            reservePrice,
            block.timestamp + auctionDuration
        );
    }

    function placeBid(uint256 auctionId,address bidder) public payable {
        /*a bidder places bid, where the bid money is stored in the balance of the contract */
        uint256  bidAmount =msg.value;
        Auction storage auction = auctions[auctionId];
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(
            bidAmount > auction.highestBid,
            "Bid must be higher than current highest bid"
        );
        require(
            bidAmount >= auction.reservePrice,
            "Bid must meet reserve price"
        );

        auction.highestBidder = bidder;//msg.sender;
        auction.highestBid = bidAmount;
        bids[auctionId][msg.sender] = bidAmount; // Store the new bid

        /*create a set to keep track of bidders */
        bool has_bid_before=false;
        for (uint256 i=0;i<bidders.length;i++){
            if (bidders[i]==msg.sender)
                has_bid_before=true;
        }
        if (!has_bid_before){
            bidders.push(payable(msg.sender));

        }

        emit NewBid(auctionId, msg.sender, bidAmount);
         // Debug statements
        emit LogValueReceived(msg.value);
        emit LogHighestBid(auctions[auctionId].highestBid);


    }
    
    // Debug events
    event LogValueReceived(uint256 value);
    event LogHighestBid(uint256 value);

    function withdrawBid(uint256 auctionId) public {
        /*a bidder can withdraw his money if he is not the current highest bidder */
        Auction storage auction = auctions[auctionId];
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(
            msg.sender != auction.highestBidder,
            "Highest bidder cannot withdraw"
        );

        uint256 amount = bids[auctionId][msg.sender];
        require(amount > 0, "No bid to withdraw");

        bids[auctionId][msg.sender] = 0; // Reset the bid amount
        payable(msg.sender).transfer(amount); // Transfer the bid amount back to the bidder

        emit BidWithdrawn(auctionId, msg.sender, amount);
    }

    function finalizeAuction(uint256 auctionId)  public {
        //artist can end auction after the end time
        require(msg.sender ==  auctions[auctionId].owner, "Not owner");
        Auction storage auction = auctions[auctionId];
        require(block.timestamp >= auction.endTime, "Auction is still active");
        require(!auction.finalized, "Auction already finalized");

        auction.finalized = true;

        //refund ether of all buyers who didn't win
        for (uint256 i=0;i<bidders.length;i++){
            uint256 bidAmount=bids[auctionId][bidders[i]];
            if (bidAmount>0 && bidders[i]!=auction.highestBidder )
               bidders[i].transfer(bidAmount); 
        }


        if (auction.highestBidder != address(0)) {
            safeTransferFrom( auctions[auctionId].owner, auction.highestBidder, auctionId);//give nft to winner
            auctions[auctionId].owner.transfer(auction.highestBid); //artist gets paid
            emit AuctionFinalized(
                auctionId,
                auction.highestBidder,
                auction.highestBid
            );
        } else {
            // Handle case where no bids were placed
            emit AuctionFinalized(auctionId, address(0), 0);
        }
    }

    function getAuctionDetails(uint256 auctionId)
        public
        view
        returns (
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        Auction storage auction = auctions[auctionId];
        return (
            auction.itemName,
            auction.reservePrice,
            auction.endTime,
            auction.finalized
        );
    }
}

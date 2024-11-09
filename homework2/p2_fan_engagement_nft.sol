// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract FanEngagementSystem is ERC20{
    
    enum Tier {
        Bronze,
        Silver,
        Gold
    }

    struct Activity {
        string activityType;
        string activityProof;//some url on social media
        uint256 tokenAmount;
        bool verified;
    }

    struct Proposal {
        string description;
        uint256 votes;
    }


    
    address public owner;//owner of contract

    //fans 
    mapping(address => Activity[]) activityArray;
    mapping(address => string[]) rewardArray;
    mapping (address=>Tier)fanTier;

    //proposals
    mapping(uint256 => Proposal) public proposals;//new ideas by commnunity
    uint256 proposalCnt;

    event Redeem(address indexed from, uint256 value,string rewardType);
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    constructor() ERC20("FanCoins", "FCN") {
        owner = msg.sender;
        _mint(msg.sender, 100 * 10 ** uint256(18));
    }

    function earnTokens(address fan, uint256 amount, string memory activityType, string memory activityProof) public  {
        /*a fan submits activity for reward tokens*/
        require(amount > 0, "Amount must be greater than zero");
        activityArray[fan].push(Activity(activityType, activityProof, amount, false));
    }

    function verifyActivity(address fan, uint256 activityIndex) public onlyOwner {
        /*the owner can verify a submitted activity and approve some tokens*/
        require(activityIndex < activityArray[fan].length, "Invalid activity index");
        approve( fan, 1 );
        activityArray[fan][activityIndex].verified = true;
        
        
        updateLoyaltyTier(fan);
    }
    function checkNFTEligibility(address fan)  view external returns(bool){

        /*this one is for checking if a fan is eligible for receiving NFT*/
        uint256 true_cnt=0;
        for (uint8 i =0 ;i<activityArray[fan].length;i++)
            if (activityArray[fan][i].verified == true){true_cnt++;}
        if (true_cnt>=10){
            return true;

        }
        return false;
    }
    function transferTokens(address to, uint256 amount) public {
        _transfer(msg.sender, to, amount);
    }

    function redeemTokens(uint256 amount, string memory rewardType) public {
        _burn(msg.sender, amount);
        // Logic to handle reward redemption
        emit Redeem(msg.sender,amount,rewardType);
    }

    function submitProposal(string memory proposalDescription) public {
        proposals[proposalCnt] = Proposal(proposalDescription, 0);
        proposalCnt++;
    }

    function voteOnProposal(uint256 proposalId) public {
        require(proposalId < proposalCnt, "Invalid proposal ID");
        proposals[proposalId].votes++;
    }

    function getFanLoyaltyTier(address fan) public view returns (Tier) {
        return fanTier[fan];
    }

    function getRewardHistory(address fan) public view returns (string[] memory) {
        return rewardArray[fan];
    }

    function updateLoyaltyTier(address fan) internal {
        uint256 balance = balanceOf(fan);
        if (balance >= 1000) {
            fanTier[fan] = Tier.Gold;
        } else if (balance >= 500) {
            fanTier[fan] = Tier.Silver;
        } else {
            fanTier[fan] = Tier.Bronze;
        }
    }
}


contract TopTierNFTIssuance is ERC721URIStorage{
    FanEngagementSystem fs;
   address public owner;


    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }


    constructor()
        ERC721("SportsNFT", "SPRT_token"){
            owner = msg.sender;
        }

    function safeMint(address to, uint256 tokenId, string memory uri)
        public onlyOwner
        
    {
        require(fs.checkNFTEligibility(msg.sender), "You are not elgibile");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

}
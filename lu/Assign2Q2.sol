// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Reward Token Contract
contract RewardToken is ERC20 {
    constructor() ERC20("RewardToken", "RWD") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Initial supply for the owner
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        return super.approve(spender, amount);
    }
}

// Badge NFT Contract
contract BadgeNFT is ERC721Enumerable {
    uint256 public nextTokenId;
    address public admin;

    constructor() ERC721("BadgeNFT", "BNFT") {
        admin = msg.sender;
    }

    function mint(address to) external {
        require(msg.sender == admin, "Only admin can mint");
        _safeMint(to, nextTokenId);
        nextTokenId++;
    }
}

// Fan Engagement System Contract
contract FanEngagementSystem is Ownable {
    RewardToken public rewardToken;
    BadgeNFT public badgeNFT;

    struct Activity {
        string activityType;
        string activityProof;
        bool verified;
    }

    struct Proposal {
        string description;
        address proposer;
        uint256 votes;
        bool executed;
    }

    mapping(address => uint256) public tokenBalances;
    mapping(address => Activity[]) public activities;
    mapping(address => string) public loyaltyTiers;
    Proposal[] public proposals;

    event TokensEarned(address indexed fan, uint256 amount, string activityType);
    event TokensTransferred(address indexed from, address indexed to, uint256 amount);
    event TokensRedeemed(address indexed fan, uint256 amount, string rewardType);
    event NFTBadgeMinted(address indexed fan, string badgeName);
    event ProposalSubmitted(uint256 proposalId, string description);
    event VotedOnProposal(uint256 proposalId, address indexed voter);

    constructor(address _rewardTokenAddress, address _badgeNFTAddress) Ownable(msg.sender) {
        rewardToken = RewardToken(_rewardTokenAddress);
        badgeNFT = BadgeNFT(_badgeNFTAddress);
    }

    // Earn tokens for completing an activity
    function earnTokens(address fan, uint256 amount, string calldata activityType, string calldata activityProof) external {
        require(amount > 0, "Amount must be greater than zero");
        require(rewardToken.transferFrom(owner(), fan, amount), "Transfer failed");

        tokenBalances[fan] += amount;
        activities[fan].push(Activity(activityType, activityProof, false));

        emit TokensEarned(fan, amount, activityType);
        updateLoyaltyTier(fan);
    }

    // Transfer tokens between fans
    function transferTokens(address to, uint256 amount) external {
        require(tokenBalances[msg.sender] >= amount, "Insufficient balance");
        tokenBalances[msg.sender] -= amount;
        tokenBalances[to] += amount;

        emit TokensTransferred(msg.sender, to, amount);
    }

    // Redeem tokens for rewards
    function redeemTokens(uint256 amount, string calldata rewardType) external {
        require(tokenBalances[msg.sender] >= amount, "Insufficient balance");
        tokenBalances[msg.sender] -= amount;

        // Tokens are burned
        rewardToken.burn(amount);

        emit TokensRedeemed(msg.sender, amount, rewardType);
    }

    // Mint NFT badge for fans
    function mintNFTBadge(address fan, string calldata badgeName) external onlyOwner {
        badgeNFT.mint(fan);
        emit NFTBadgeMinted(fan, badgeName);
    }

    // Submit a proposal for new rewards
    function submitProposal(string calldata proposalDescription) external {
        proposals.push(Proposal({
            description: proposalDescription,
            proposer: msg.sender,
            votes: 0,
            executed: false
        }));

        emit ProposalSubmitted(proposals.length - 1, proposalDescription);
    }

    // Vote on a proposal
    function voteOnProposal(uint256 proposalId) external {
        require(proposalId < proposals.length, "Invalid proposal ID");
        require(tokenBalances[msg.sender] > 0, "Must hold tokens to vote");

        proposals[proposalId].votes += tokenBalances[msg.sender];
        emit VotedOnProposal(proposalId, msg.sender);
    }

    // Get the loyalty tier of a fan
    function getFanLoyaltyTier(address fan) external view returns (string memory) {
        return loyaltyTiers[fan];
    }

    // Get reward history for a fan
    function getRewardHistory(address fan) external view returns (string[] memory) {
        string[] memory history = new string[](activities[fan].length);
        for (uint256 i = 0; i < activities[fan].length; i++) {
            history[i] = activities[fan][i].activityType;
        }
        return history;
    }

    // Get the activity count for a fan
    function getActivityCount(address fan) external view returns (uint256) {
        return activities[fan].length;
    }

    // Get details of a proposal
    function getProposal(uint256 proposalId) external view returns (string memory, address, uint256, bool) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        Proposal memory proposal = proposals[proposalId];
        return (proposal.description, proposal.proposer, proposal.votes, proposal.executed);
    }

    // Update loyalty tier based on token balance
    function updateLoyaltyTier(address fan) internal {
        uint256 balance = tokenBalances[fan];
        if (balance >= 1000) {
            loyaltyTiers[fan] = "Gold";
        } else if (balance >= 500) {
            loyaltyTiers[fan] = "Silver";
        } else {
            loyaltyTiers[fan] = "Bronze";
        }
    }
}

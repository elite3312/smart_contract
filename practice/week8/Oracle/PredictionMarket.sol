// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;



// Import Chainlink's AggregatorV3Interface for retrieving off-chain data
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract PredictionMarket {
    address public owner;
    address public oracle;
    bytes32 public jobId;
    uint256 public fee;
    string public question;
    uint256 public outcome;
    bool public isResolved;
    
    mapping(address => uint256) public balances;
    mapping(address => bool) public hasClaimed;
    
    event BetPlaced(address indexed bettor, uint256 amount);
    event MarketResolved(uint256 outcome);
    event ClaimProcessed(address indexed bettor, uint256 payout);

    constructor(address _oracle, bytes32 _jobId, uint256 _fee, string memory _question) {
        owner = msg.sender;
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
        question = _question;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }
    
    function placeBet(uint256 _outcome) external payable {
        require(msg.value > 0, "Bet amount must be greater than zero");
        require(!isResolved, "The market has already been resolved");
        
        balances[msg.sender] += msg.value;
        emit BetPlaced(msg.sender, msg.value);
    }
    
    function resolveMarket() external onlyOwner {
        require(!isResolved, "The market has already been resolved");
        
        int256 currentPrice = getCurrentPrice();
        outcome = currentPrice > 5000 ? 1 : 2;
        isResolved = true;
        
        emit MarketResolved(outcome);
    }
    
    function processClaim() external {
        require(isResolved, "The market has not been resolved yet");
        require(!hasClaimed[msg.sender], "You have already claimed");
        
        uint256 payout = balances[msg.sender] * 2;
        balances[msg.sender] = 0;
        hasClaimed[msg.sender] = true;
        payable(msg.sender).transfer(payout);
        
        emit ClaimProcessed(msg.sender, payout);
    }
    
    function getCurrentPrice() internal view returns (int256) {
        (
            uint80 roundID,
            int256 price,
            ,
            uint256 timestamp,
            )
         = AggregatorV3Interface(oracle).latestRoundData();
        
        require(timestamp > 0, "Price data not available");
        require(block.timestamp - timestamp < 1 hours, "Price data is outdated");
        
        return price;
    }
    
    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}





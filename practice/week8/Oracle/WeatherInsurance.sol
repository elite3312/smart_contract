// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;



// Import Chainlink's AggregatorV3Interface for retrieving off-chain data
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract WeatherInsurance {
    address public owner;
    address public oracle;
    bytes32 public jobId;
    uint256 public fee;
    AggregatorV3Interface internal weatherFeed;
    
    mapping(address => uint256) public insuredAmounts;
    mapping(address => bool) public hasClaimed;
    
    event InsurancePurchased(address indexed buyer, uint256 amount);
    event ClaimProcessed(address indexed beneficiary, uint256 payout);

    constructor(address _oracle, bytes32 _jobId, uint256 _fee) {
        owner = msg.sender;
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
        
        // Set up the weather data feed (assuming temperature feed)
        weatherFeed = AggregatorV3Interface(0xTEMPERATURE_FEED_ADDRESS);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }
    
    function purchaseInsurance() external payable {
        require(msg.value > 0, "Insurance amount must be greater than zero");
        require(insuredAmounts[msg.sender] == 0, "You have already purchased insurance");
        
        insuredAmounts[msg.sender] = msg.value;
        emit InsurancePurchased(msg.sender, msg.value);
    }
    
    function processClaim() external {
        require(!hasClaimed[msg.sender], "You have already claimed");
        
        int256 currentTemperature = getCurrentTemperature();
        require(currentTemperature < 20, "Weather conditions are not eligible for a claim");
        
        uint256 payout = insuredAmounts[msg.sender];
        hasClaimed[msg.sender] = true;
        payable(msg.sender).transfer(payout);
        
        emit ClaimProcessed(msg.sender, payout);
    }
    
    function getCurrentTemperature() internal view returns (int256) {
        (
            uint80 roundID,
            int256 temperature,
            ,
            uint256 timestamp,
            )
         = weatherFeed.latestRoundData();
        
        require(timestamp > 0, "Weather data not available");
        require(block.timestamp - timestamp < 1 hours, "Weather data is outdated");
        
        return temperature;
    }
    
    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}





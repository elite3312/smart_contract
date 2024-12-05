// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DecentralizedCharityFund is ReentrancyGuard {
    struct FundingRequest {
        address payable projectAddress; // Address of the project
        uint256 requestedAmount; // Requested amount in Wei
        string projectDescription; // Description of the project
        uint256 votesReceived; // Total votes received
        bool isFinalized; // Indicates if the request has been finalized
    }

    address public owner; // Contract owner
    uint256 public totalVotingPower; // Total voting power of all donors
    FundingRequest[] public fundingRequests; // Array of funding requests
    mapping(address => uint256) public donorVotingPower; // Mapping of donor addresses to their voting power
    mapping(uint256 => mapping(address => bool)) public hasVoted; // Tracks if a donor has voted on a specific request

    event DonationReceived(address indexed donor, uint256 amount);
    event FundingRequestSubmitted(uint256 requestId, address indexed projectAddress, uint256 requestedAmount, string projectDescription);
    event VoteCast(uint256 requestId, address indexed voter, uint256 votingPower);
    event RequestFinalized(uint256 requestId, address indexed projectAddress, uint256 amountDisbursed);

    constructor() {
        owner = msg.sender;
    }

    function donate() external payable {
        require(msg.value > 0, "Donation must be greater than zero");
        donorVotingPower[msg.sender] += msg.value;
        totalVotingPower += msg.value;

        emit DonationReceived(msg.sender, msg.value);
    }

    function submitFundingRequest(address payable projectAddress, uint256 requestedAmount, string calldata projectDescription) external {
        require(projectAddress != address(0), "Invalid project address");
        require(requestedAmount > 0, "Requested amount must be greater than zero");

        fundingRequests.push(FundingRequest({
            projectAddress: projectAddress,
            requestedAmount: requestedAmount,
            projectDescription: projectDescription,
            votesReceived: 0,
            isFinalized: false
        }));

        emit FundingRequestSubmitted(fundingRequests.length - 1, projectAddress, requestedAmount, projectDescription);
    }

    function voteOnRequest(uint256 requestId) external {
        require(requestId < fundingRequests.length, "Invalid request ID");
        require(donorVotingPower[msg.sender] > 0, "No voting power");
        require(!hasVoted[requestId][msg.sender], "Already voted on this request");
        require(!fundingRequests[requestId].isFinalized, "Request already finalized");

        fundingRequests[requestId].votesReceived += donorVotingPower[msg.sender];
        hasVoted[requestId][msg.sender] = true;

        emit VoteCast(requestId, msg.sender, donorVotingPower[msg.sender]);
    }

    function finalizeRequest(uint256 requestId) external nonReentrant {
        require(requestId < fundingRequests.length, "Invalid request ID");
        FundingRequest storage request = fundingRequests[requestId];
        require(!request.isFinalized, "Request already finalized");
        require(request.votesReceived > totalVotingPower / 2, "Not enough votes to approve request");
        require(address(this).balance >= request.requestedAmount, "Insufficient contract balance");

        request.isFinalized = true; // Mark the request as finalized

        (bool success, ) = request.projectAddress.call{value: request.requestedAmount}("");
        require(success, "Transfer failed");

        emit RequestFinalized(requestId, request.projectAddress, request.requestedAmount);
    }

    function getFundingHistory() external view returns (address[] memory projectAddresses, uint256[] memory amounts, string[] memory descriptions) {
        uint256 fundedCount = 0;

        // Count the number of funded projects
        for (uint256 i = 0; i < fundingRequests.length; i++) {
            if (fundingRequests[i].isFinalized) {
                fundedCount++;
            }
        }

        projectAddresses = new address[](fundedCount);
        amounts = new uint256[](fundedCount);
        descriptions = new string[](fundedCount);

        uint256 index = 0;
        for (uint256 i = 0; i < fundingRequests.length; i++) {
            if (fundingRequests[i].isFinalized) {
                projectAddresses[index] = fundingRequests[i].projectAddress;
                amounts[index] = fundingRequests[i].requestedAmount;
                descriptions[index] = fundingRequests[i].projectDescription;
                index++;
            }
        }
    }

    function emergencyWithdraw() external {
        require(msg.sender == owner, "Only the contract owner can withdraw funds");
        payable(owner).transfer(address(this).balance);
    }
}

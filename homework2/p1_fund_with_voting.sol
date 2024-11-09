// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedCharityFund {
    struct FundingRequest {
        address projectAddress;
        uint256 requestedAmount;
        string projectDescription;
        uint256 voteCount;
        bool finalized;
    }

    address public owner;//owner of contract
    uint256 public totalVotingPower;//the sum of money in the fund
    uint256 public requestCount;//the number of requested projects
    mapping(address => uint256) public votingPower;//maps user address to their voting power
    mapping(uint256 => FundingRequest) public fundingRequests;//a list of projects
    mapping(uint256 => mapping(address => bool)) public votes;//maps project to voters and their vote on it

    /*these are for keeping track of history*/
    address[] public fundedProjects;
    uint256[] public fundedAmounts;
    string[] public projectDescriptions;

    /*these are for logging*/
    event DonationReceived(address indexed donor, uint256 amount);
    event FundingRequestSubmitted(uint256 indexed requestId, address indexed projectAddress, uint256 requestedAmount, string projectDescription);
    event VoteCast(address indexed voter, uint256 indexed requestId);
    event RequestFinalized(uint256 indexed requestId, address indexed projectAddress, uint256 amount);



    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    function donate() external payable {
        /*msg.sender donates some money to the fund*/
        require(msg.value > 0, "Donation amount must be greater than zero");
        votingPower[msg.sender] += msg.value;
        totalVotingPower += msg.value;
        emit DonationReceived(msg.sender, msg.value);
    }

    function submitFundingRequest(address projectAddress, uint256 requestedAmount, string memory projectDescription) external  {
        /*submits a project to be funded*/
        require(requestedAmount > 0, "Requested amount must be greater than zero");
        fundingRequests[requestCount] = FundingRequest({
            projectAddress: projectAddress,
            requestedAmount: requestedAmount,
            projectDescription: projectDescription,
            voteCount: 0,
            finalized: false
        });
        emit FundingRequestSubmitted(requestCount, projectAddress, requestedAmount, projectDescription);
        requestCount++;
    }

    function voteOnRequest(uint256 requestId) external returns (bool) {
        /*a person votes on a project, where voting weight is proportionate to his donations*/
        require(votingPower[msg.sender] > 0, "No voting power");
        require(!votes[requestId][msg.sender], "Already voted");
        require(!fundingRequests[requestId].finalized, "Request already finalized");

        votes[requestId][msg.sender] = true;
        fundingRequests[requestId].voteCount += votingPower[msg.sender];
        emit VoteCast(msg.sender, requestId);

        return true;
    }

    function finalizeRequest(uint256 requestId) external onlyOwner returns (bool) {
        /*finalizes a project, only owner can call*/
        FundingRequest storage request = fundingRequests[requestId];
        require(!request.finalized, "Request already finalized");
        require(request.voteCount > totalVotingPower / 2, "Not enough votes");

        request.finalized = true;
        payable(request.projectAddress).transfer(request.requestedAmount);
        /*push all records onto stacks for history*/
        fundedProjects.push(request.projectAddress);
        fundedAmounts.push(request.requestedAmount);
        projectDescriptions.push(request.projectDescription);

        emit RequestFinalized(requestId, request.projectAddress, request.requestedAmount);

        return true;
    }

    function getFundingHistory() external view returns (address[] memory, uint256[] memory, string[] memory) {
        /*view history*/
        return (fundedProjects, fundedAmounts, projectDescriptions);
    }
}

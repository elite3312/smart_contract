// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract RentalAgreementManagement {
    uint256 public agreementCounter;
    bool private locked;

    struct Agreement {
        address landlord;
        address tenant;
        uint256 rentAmount;
        uint256 duration; // in days
        uint256 startDate;
        uint256 totalPaid;
        bool isActive;
    }

    mapping(uint256 => Agreement) public agreements;
    mapping(uint256 => uint256[]) public paymentTimestamps;

    event AgreementCreated(uint256 indexed agreementId, address indexed landlord, address indexed tenant, uint256 rentAmount, uint256 duration);
    event RentPaid(uint256 indexed agreementId, address indexed tenant, uint256 amount, uint256 timestamp);
    event AgreementTerminated(uint256 indexed agreementId, address indexed landlord);

    constructor() {
        agreementCounter = 0;
    }

    modifier nonReentrant() {
        require(!locked, "Reentrancy detected");
        locked = true;
        _;
        locked = false;
    }

    function createAgreement(address tenant, uint256 rentAmount, uint256 duration) external {
        require(tenant != address(0), "Invalid tenant address.");
        require(rentAmount > 0, "Rent amount must be greater than zero.");
        require(duration > 0, "Duration must be greater than zero.");

        agreements[agreementCounter] = Agreement({
            landlord: msg.sender,
            tenant: tenant,
            rentAmount: rentAmount,
            duration: duration,
            startDate: block.timestamp,
            totalPaid: 0,
            isActive: true
        });

        emit AgreementCreated(agreementCounter, msg.sender, tenant, rentAmount, duration);
        agreementCounter++;
    }

    function payRent(uint256 agreementId) external payable nonReentrant {
        Agreement storage agreement = agreements[agreementId];
        require(agreement.isActive, "Agreement is not active.");
        require(msg.sender == agreement.tenant, "Only the tenant can pay rent.");
        require(msg.value == agreement.rentAmount, "Incorrect rent amount.");
        require(block.timestamp <= agreement.startDate + agreement.duration * 1 days, "Agreement has expired.");

        agreement.totalPaid += msg.value;
        paymentTimestamps[agreementId].push(block.timestamp);

        (bool success, ) = agreement.landlord.call{value: msg.value}("");
        require(success, "Rent payment failed.");

        emit RentPaid(agreementId, msg.sender, msg.value, block.timestamp);
    }

    function terminateAgreement(uint256 agreementId) external {
        Agreement storage agreement = agreements[agreementId];
        require(msg.sender == agreement.landlord, "Only the landlord can terminate the agreement.");
        require(agreement.isActive, "Agreement is already terminated.");
        require(block.timestamp >= agreement.startDate + agreement.duration * 1 days, "Cannot terminate before lease ends.");

        agreement.isActive = false;
        emit AgreementTerminated(agreementId, msg.sender);
    }

    function getAgreementStatus(uint256 agreementId) external view returns (string memory) {
        Agreement storage agreement = agreements[agreementId];
        if (!agreement.isActive) {
            return "Terminated";
        } else if (block.timestamp > agreement.startDate + agreement.duration * 1 days) {
            return "Expired";
        } else {
            return "Active";
        }
    }

    function getPaymentHistory(uint256 agreementId) external view returns (uint256[] memory) {
        return paymentTimestamps[agreementId];
    }
}

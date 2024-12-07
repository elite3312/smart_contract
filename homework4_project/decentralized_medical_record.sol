// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedMedicalRecords {
    struct MedicalRecord {
        string data;
        address owner;
    }

    struct Claim {
        string details;
        string recordHash;
        address payable patient;
        bool approved;
        bool processed;
        uint256 amount; // Amount to be paid to the patient
    }

    mapping(address => MedicalRecord[]) private patientRecords;
    mapping(uint256 => Claim) private claims;
    mapping(address => mapping(address => bool)) private accessControl; // patient => provider => access
    uint256 public claimCounter;

    event RecordUploaded(address indexed patient, string recordData);
    event AccessGranted(address indexed patient, address indexed provider);
    event ClaimSubmitted(uint256 claimId, address indexed patient);
    event ClaimApproved(uint256 claimId, address indexed provider);
    event PaymentMade(address indexed patient, uint256 amount);

    // Patients can upload their medical records
    function uploadMedicalRecord(string memory recordData) public returns (bool) {
        patientRecords[msg.sender].push(MedicalRecord(recordData, msg.sender));
        emit RecordUploaded(msg.sender, recordData);
        return true;
    }

    // Patients can grant access to healthcare providers
    function grantAccess(address provider) public returns (bool) {
        accessControl[msg.sender][provider] = true;
        emit AccessGranted(msg.sender, provider);
        return true;
    }

    // Patients can submit insurance claims
    function submitClaim(string memory claimDetails, string memory recordHash, uint256 amount) public returns (uint256) {
        claims[claimCounter] = Claim(claimDetails, recordHash, payable(msg.sender), false, false, amount);
        emit ClaimSubmitted(claimCounter, msg.sender);
        claimCounter++;
        return claimCounter - 1;
    }

    // Insurance provider can approve claims and pay the patient
    function approveClaim(uint256 claimId) public payable returns (bool) {
        require(claimId < claimCounter, "Claim does not exist.");
        require(!claims[claimId].processed, "Claim already processed.");

        claims[claimId].approved = true;
        claims[claimId].processed = true;

        // Payment to the patient
        address payable patient = claims[claimId].patient;
        uint256 paymentAmount = claims[claimId].amount;

        // Ensure the contract has enough balance to pay
        require(address(this).balance >= paymentAmount, "Insufficient funds in contract.");

        // Transfer the amount to the patient using call
        (bool success, ) = patient.call{value: paymentAmount}("");
        require(success, "Payment transfer failed.");

        emit PaymentMade(patient, paymentAmount);
        emit ClaimApproved(claimId, msg.sender);
        return true;
    }

    // Function to receive Ether. This makes the contract able to receive payments.
    receive() external payable {}

    // Patients can retrieve their medical records
    function getPatientRecords() public view returns (string[] memory) {
        uint256 recordCount = patientRecords[msg.sender].length;
        string[] memory records = new string[](recordCount);
        for (uint256 i = 0; i < recordCount; i++) {
            records[i] = patientRecords[msg.sender][i].data;
        }
        return records;
    }

    // Check the status of a claim
    function getClaimStatus(uint256 claimId) public view returns (string memory) {
        require(claimId < claimCounter, "Claim does not exist.");
        if (claims[claimId].processed) {
            return claims[claimId].approved ? "Approved" : "Denied";
        } else {
            return "Pending";
        }
    }
}
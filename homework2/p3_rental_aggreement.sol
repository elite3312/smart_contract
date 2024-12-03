// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RentalAgreementManagement {
    struct Agreement {
        address payable landlord;
        address tenant;
        uint256 rentAmount;
        uint256 startTime;
        uint256 duration;//in months
        uint256 remaining_duration;//in months
        bool active;
    }

    uint256 public agreementCount;//ctr
    
    address owner;//owner
    mapping(uint256 => Agreement) public agreements;//list of agreements
    mapping(uint256 => uint256[]) public paymentHistory;//payement history for each agreement

    event AgreementCreated(uint256 agreementId, address landlord, address tenant, uint256 rentAmount, uint256 duration);
    event RentPaid(uint256 agreementId, address tenant, uint256 amount);
    event AgreementTerminated(uint256 agreementId, address landlord);
    constructor() {
        owner=msg.sender;
        agreementCount = 0;
    }

    function createAgreement(address payable _landlord,address _tenant, uint256 _rentAmount  , uint256 _duration_months) public {
        //creates an leasing aggreement between the landlord and the tenant
     
        agreements[agreementCount] = Agreement({
            landlord: _landlord,
            tenant: _tenant,//another address
            rentAmount: _rentAmount ,//monthly
            startTime: block.timestamp,
            duration:_duration_months,
            remaining_duration:_duration_months,//counts down until the end of the lease
            active: true
        });
        agreementCount++;

        emit AgreementCreated(agreementCount, msg.sender, _tenant, _rentAmount, _duration_months);
    }

    function payRent(uint256 _agreementId) public payable {
        //only the tenant can pay, and must pay in exact amount
        Agreement storage agreement = agreements[_agreementId];
        require(agreement.active, "Agreement is not active");
        //require(msg.sender == agreement.tenant, "Only tenant can pay rent");
        require(msg.value == agreement.rentAmount, "Incorrect rent amount");
        require(agreement.remaining_duration>=1,"Remaining Duration Must Be Greater Than Or Equal to 1 Month");
        //pay
        agreement.landlord.transfer(msg.value);
        paymentHistory[_agreementId].push(block.timestamp);
        agreement.remaining_duration-=1;
        emit RentPaid(_agreementId, msg.sender, msg.value);
    }

    function terminateAgreement(uint256 _agreementId) public {
        Agreement storage agreement = agreements[_agreementId];
        require(msg.sender == agreement.landlord ||msg.sender == owner, "Only landlord or contract owner can terminate");
        require(agreement.active, "Agreement is already terminated");
        

        //must be end of lease if you are landlord
        if (msg.sender == agreement.landlord )
            if (!(agreement.remaining_duration==0)){
                revert();
        }
        //else if you are contract owner you can still terminate the contract

        agreement.active = false;

        emit AgreementTerminated(_agreementId, msg.sender);
    }

    function getAgreementStatus(uint256 _agreementId) public view returns (string memory) {
        Agreement storage agreement = agreements[_agreementId];
        if (agreement.active) {
            return "Active";
        } else {
            return "Terminated";
        }
    }
    function getPaymentHistory(uint256 agreementId) public view returns (uint256[] memory) {
    return paymentHistory[agreementId];
}
}

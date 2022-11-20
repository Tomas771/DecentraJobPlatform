// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./JobContract.sol";

contract Decentrajob {
    struct Contractor {
        bytes32 name;                   // short name (up ot 32 bytes)
        address wallet_address;         // wallet address of contractor
        uint rating;                    // rating from previous contract in range 0 ... 200     
        uint completedContracts;
        bool exists;         
    }

    enum JobRating{
        NOT_MEET_THE_CONDITIONS,
        ALRIGHT,
        EXCELENT
    }

    Contractor[] public contractors;
    mapping(address => Contractor) addressToContractor;
    JobContract[] public jobContracts;
    mapping (uint256 => uint256) jobContractIdToArrayId;

    uint256 createdJobContracts;

    function createContractor(bytes32 name) public {
        require(!addressToContractor[msg.sender].exists, "Contractor with this address already exists!");
        
        Contractor memory newContractor = Contractor({
            name: name, 
            wallet_address: msg.sender,
            rating:0,
            completedContracts:0, 
            exists: true});

        contractors.push(newContractor);
        addressToContractor[newContractor.wallet_address] = newContractor;
    }

    function createJobContract(bytes32 name, address contractor) payable public {
        JobContract newContract = new JobContract(createdJobContracts, name, contractor);

        jobContractIdToArrayId[createdJobContracts] += jobContracts.length;
        jobContracts.push(newContract);
    }

    function approveJobContractCompletion(uint256 id, JobRating rating) public {
        uint256 indexInArray = jobContractIdToArrayId[id];
        JobContract jobContract = jobContracts[indexInArray];
        Contractor memory jobContractor = addressToContractor[jobContract.contractor.address];

        jobContract.approveCompletion();

        uint256 currentRating = uint256(rating) * 100;
        jobContractor.rating = (jobContractor.completedContracts*jobContractor.rating + currentRating)/
        jobContractor.completedContracts + 1;

        // remove completed job contract from array
        jobContracts[indexInArray] = jobContracts[jobContracts.length - 1];
        jobContracts.pop();

        delete jobContractIdToArrayId[id];
    }
}
pragma solidity ^0.4.25;

contract GitmanIssue {

    address private mediator;
    address public parent; // deposit contract
    string public owner;
    string public repository;
    string public issue;

    constructor (string ownerId, string repositoryId, string issueId, address mediatorAddress) public payable { 
        parent = msg.sender;
        mediator = mediatorAddress;
        owner = ownerId;
        repository = repositoryId;
        issue = issueId;
    }

    function resolve(address developerAddress) public {
        require (msg.sender == mediator, "sender not authorized");
        selfdestruct(developerAddress);
    }

    function recall() public {
        require (msg.sender == mediator, "sender not authorized");
        selfdestruct(parent);
    }
}

contract GitmanFactory {
    
    address private mediator;
    uint16 public share = 5;

    event IssueCreated(address contractAddress, string issue);

    constructor () public {     //address ownerAddress, 
        mediator = msg.sender;
    }

    function setShare(uint8 value) public {
        require(value > 0 && value <= 100, "share must be between 1 and 100");
        require (msg.sender == mediator, "sender not authorized");
        share = value;
    }

    function createIssue(string user, string repository, string issue) public payable { // returns (address)
        require(msg.value > 0, "reward must be greater than 0");

        uint fee = msg.value / share;
        uint reward = msg.value - fee;
        mediator.transfer(fee);
        
        address issueContract = (new GitmanIssue).value(reward)(user, repository, issue, mediator);
        emit IssueCreated(issueContract, issue);
    }
}
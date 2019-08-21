/**
 * Copyright (C) 2018 Smartz, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
 */

pragma solidity ^0.4.20;



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title Booking
 * @author Vladimir Khramov <vladimir.khramov@smartz.io>
 */
contract Ledger is Ownable {

    function Ledger() public payable {

        //empty element with id=0
        records.push(Record('','',0));

        
    }
    
    /************************** STRUCT **********************/
    
    struct Record {
string commitHash;
string githubUrlPointingToTheCommit;
bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain;
    }
    
    /************************** EVENTS **********************/
    
    event RecordAdded(uint256 id, string commitHash, string githubUrlPointingToTheCommit, bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain);
    
    /************************** CONST **********************/
    
    string public constant name = 'MixBytes security audits registry'; 
    string public constant description = 'Ledger enumerates security audits executed by MixBytes. Each audit is described by a revised version of a code and our report file. Anyone can ascertain that the code was audited by MixBytes and MixBytes can not deny this audit in case overlooked vulnerability is discovered. An audit can be found in this ledger by git commit hash, by full github repository commit url or by existing audit report file. Report files can be found at public audits MixBytes github repository.'; 
    string public constant recordName = 'Security Audit'; 

    /************************** PROPERTIES **********************/

    Record[] public records;
    mapping (bytes32 => uint256) commitHash_mapping;
    mapping (bytes32 => uint256) githubUrlPointingToTheCommit_mapping;
    mapping (bytes32 => uint256) auditReportFileKeccakHashOfTheFileIsStoredInBlockchain_mapping;

    /************************** EXTERNAL **********************/

    function addRecord(string _commitHash,string _githubUrlPointingToTheCommit,bytes32 _auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) external onlyOwner returns (uint256) {
        require(0==findIdByCommitHash(_commitHash));
        require(0==findIdByGithubUrlPointingToTheCommit(_githubUrlPointingToTheCommit));
        require(0==findIdByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(_auditReportFileKeccakHashOfTheFileIsStoredInBlockchain));
    
    
        records.push(Record(_commitHash, _githubUrlPointingToTheCommit, _auditReportFileKeccakHashOfTheFileIsStoredInBlockchain));
        
        commitHash_mapping[keccak256(_commitHash)] = records.length-1;
        githubUrlPointingToTheCommit_mapping[keccak256(_githubUrlPointingToTheCommit)] = records.length-1;
        auditReportFileKeccakHashOfTheFileIsStoredInBlockchain_mapping[(_auditReportFileKeccakHashOfTheFileIsStoredInBlockchain)] = records.length-1;
        
        RecordAdded(records.length - 1, _commitHash, _githubUrlPointingToTheCommit, _auditReportFileKeccakHashOfTheFileIsStoredInBlockchain);
        
        return records.length - 1;
    }
    
    /************************** PUBLIC **********************/
    
    function getRecordsCount() public view returns(uint256) {
        return records.length - 1;
    }
    
    
    function findByCommitHash(string _commitHash) public view returns (uint256 id, string commitHash, string githubUrlPointingToTheCommit, bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) {
        Record record = records[ findIdByCommitHash(_commitHash) ];
        return (
            findIdByCommitHash(_commitHash),
            record.commitHash, record.githubUrlPointingToTheCommit, record.auditReportFileKeccakHashOfTheFileIsStoredInBlockchain
        );
    }
    
    function findIdByCommitHash(string commitHash) internal view returns (uint256) {
        return commitHash_mapping[keccak256(commitHash)];
    }


    function findByGithubUrlPointingToTheCommit(string _githubUrlPointingToTheCommit) public view returns (uint256 id, string commitHash, string githubUrlPointingToTheCommit, bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) {
        Record record = records[ findIdByGithubUrlPointingToTheCommit(_githubUrlPointingToTheCommit) ];
        return (
            findIdByGithubUrlPointingToTheCommit(_githubUrlPointingToTheCommit),
            record.commitHash, record.githubUrlPointingToTheCommit, record.auditReportFileKeccakHashOfTheFileIsStoredInBlockchain
        );
    }
    
    function findIdByGithubUrlPointingToTheCommit(string githubUrlPointingToTheCommit) internal view returns (uint256) {
        return githubUrlPointingToTheCommit_mapping[keccak256(githubUrlPointingToTheCommit)];
    }


    function findByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(bytes32 _auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) public view returns (uint256 id, string commitHash, string githubUrlPointingToTheCommit, bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) {
        Record record = records[ findIdByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(_auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) ];
        return (
            findIdByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(_auditReportFileKeccakHashOfTheFileIsStoredInBlockchain),
            record.commitHash, record.githubUrlPointingToTheCommit, record.auditReportFileKeccakHashOfTheFileIsStoredInBlockchain
        );
    }
    
    function findIdByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) internal view returns (uint256) {
        return auditReportFileKeccakHashOfTheFileIsStoredInBlockchain_mapping[(auditReportFileKeccakHashOfTheFileIsStoredInBlockchain)];
    }
}
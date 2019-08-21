pragma solidity ^0.5.5;

contract Owned {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    address payable owner;
    address payable newOwner;
    function changeOwner(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}

contract Save is Owned {
    uint8 public fee;
    uint32 public deadline;
    uint32 public savers;
    mapping (address=>uint256) saves;
    event Saved(address indexed _from, uint256 _value);
    function saveOf(address _user) view public returns (uint256 save) {return saves[_user];}
}

contract KodDeneg is Save{
    
    constructor() public{
        fee = 3;
        deadline = 1577836799;
        savers = 0;
        owner = msg.sender;
    }
    
    function payOut() public returns (bool ok){
        require(now>=deadline && saves[msg.sender]>0);
        uint256 royalty = saves[msg.sender]*fee/100;
        if (royalty>0) owner.transfer(royalty);
        msg.sender.transfer(saves[msg.sender]-royalty);
        return true;
    }
    function () payable external {
        require(msg.value>0);
        if (saves[msg.sender]==0) savers++;
        saves[msg.sender]+=msg.value;
        emit Saved(msg.sender,msg.value);
    }
}
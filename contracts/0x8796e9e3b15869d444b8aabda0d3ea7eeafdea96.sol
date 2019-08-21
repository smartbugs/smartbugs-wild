pragma solidity ^0.4.7;
contract MobaBase {
    address public owner = 0x0;
    bool public isLock = false;
    constructor ()  public  {
        owner = msg.sender;
    }
    
    event transferToOwnerEvent(uint256 price);
       
    modifier onlyOwner {
        require(msg.sender == owner,"only owner can call this function");
        _;
    }
    
    modifier notLock {
        require(isLock == false,"contract current is lock status");
        _;
    }
    
    modifier msgSendFilter() {
        address addr = msg.sender;
        uint size;
        assembly { size := extcodesize(addr) }
        require(size <= 0,"address must is not contract");
        require(msg.sender == tx.origin, "msg.sender must equipt tx.origin");
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    
    function updateLock(bool b) onlyOwner public {
        
        require(isLock != b," updateLock new status == old status");
        isLock = b;
    }
    
    function transferToOwner()    
    onlyOwner 
    msgSendFilter 
    public {
        uint256 totalBalace = address(this).balance;
        owner.transfer(totalBalace);
        emit transferToOwnerEvent(totalBalace);
    }
}

contract IOldInviteData{
    
    function checkUp(address addr,bytes32 name) public view returns (uint8);
    function GetAddressByName(bytes32 name) public view returns (address);
    function m_addrToName(address addr) public view returns (bytes32 name);
        
}
contract BRMobaInviteData is MobaBase {
   
    address owner = 0x0;
    uint256 price = 10 finney;
    mapping(bytes32 => address) public m_nameToAddr;
    mapping(address => bytes32) public m_addrToName;
    IOldInviteData public oldInviteAddr;
    
    constructor(IOldInviteData oldAddr) public {
        oldInviteAddr = IOldInviteData(oldAddr);
    }
    event createInviteNameEvent(address addr,bytes32 name);
    
    function createInviteName(bytes32 name) 
    notLock 
    msgSendFilter
    public payable {
        require(msg.value == price);
        require(checkUp(msg.sender,name) == 0,"current name has been used or current address has been one name"); 
        m_nameToAddr[name] = msg.sender;
        m_addrToName[msg.sender] = name;
        emit createInviteNameEvent(msg.sender,name);
    }
    
    function checkUp(address addr,bytes32 name) public view returns (uint8) {
        if(m_nameToAddr[name] != address(0)) {
            return 1;
        }
        if ( m_addrToName[addr] != 0){
            return 2;
        }
        uint8  oldResult = oldInviteAddr.checkUp(addr,name);
        if(oldResult != 0) {
             return oldResult;
        }
        return 0;
    }
    
    function GetAddressByName(bytes32 name) public view returns (address){
        address oldAddr =  oldInviteAddr.GetAddressByName(name);
        if(oldAddr != address(0)) {
            return oldAddr;
        }
        return m_nameToAddr[name];
    }
    
     function GetNameByAddr(address addr) public view returns (bytes32 name){
        bytes32 oldName =  oldInviteAddr.m_addrToName(addr);
        if(oldName != 0) {
            return oldName;
        }
        return m_addrToName[addr];
    }
}
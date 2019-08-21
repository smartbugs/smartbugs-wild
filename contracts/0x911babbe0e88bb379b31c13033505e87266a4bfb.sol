pragma solidity ^0.4.7;
contract MobaBase {
    address public owner = 0x0;
    bool public isLock = false;
    constructor ()  public  {
        owner = msg.sender;
    }
    
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
}

contract IBRInviteData {
    function GetAddressByName(bytes32 name) public view returns (address);
}
contract IBRPerSellData {
   function GetPerSellInfo(uint16 id) public view returns (uint16,uint256 price,bool isOver);
}

contract BRPerSellControl is MobaBase {
    
    IBRInviteData mInviteAddr;
    IBRPerSellData mPerSellData;
    mapping (address => uint16[]) public mBuyList;

    event updateIntefaceEvent();
    event transferToOwnerEvent(uint256 price);
    event buyPerSellEvent(uint16 perSellId,bytes32 name,uint256 price);
    constructor(address inviteData, address perSellData) public {
        mInviteAddr  = IBRInviteData(inviteData);
        mPerSellData = IBRPerSellData(perSellData);
    }
    
    function updateInteface(address inviteData, address perSellData) 
    onlyOwner 
    msgSendFilter 
    public {
        mInviteAddr  = IBRInviteData(inviteData);
        mPerSellData = IBRPerSellData(perSellData);
        emit updateIntefaceEvent();
    }
    
    function transferToOwner()    
    onlyOwner 
    msgSendFilter 
    public {
        uint256 totalBalace = address(this).balance;
        owner.transfer(totalBalace);
        emit transferToOwnerEvent(totalBalace);
    }
    
   function GetPerSellInfo(uint16 id) public view returns (uint16 pesellId,uint256 price,bool isOver) {
        return mPerSellData.GetPerSellInfo(id);
    }
    
    function buyPerSell(uint16 perSellId,bytes32 name) 
    notLock
    msgSendFilter 
    payable public {
        uint16 id; uint256 price; bool isOver;
        (id,price,isOver) = mPerSellData.GetPerSellInfo(perSellId);
        require(id == perSellId && id > 0,"perSell.Id is error"  );
        require(msg.value == price,"msg.value is error");
        require(isOver == false,"persell is over status");
        
        address inviteAddr = mInviteAddr.GetAddressByName(name);
        if(inviteAddr != address(0)) {
           uint giveToEth   = msg.value * 10 / 100;
           inviteAddr.transfer(giveToEth);
        }
        mBuyList[msg.sender].push(id);
        emit buyPerSellEvent(perSellId,name,price);
    }
    

}
pragma solidity ^0.4.19;

contract Storage{
    address public founder;
    bool public changeable;
    mapping( address => bool) public adminStatus;
    mapping( address => uint256) public slot;
    
    event Update(address whichAdmin, address whichUser, uint256 data);
    event Set(address whichAdmin, address whichUser, uint256 data);
    event Admin(address addr, bool yesno);

    modifier onlyFounder() {
        require(msg.sender==founder);
        _;
    }
    
    modifier onlyAdmin() {
        assert (adminStatus[msg.sender]==true);
        _;
    }
    
    function Storage() public {
        founder=msg.sender;
        adminStatus[founder]=true;
        changeable=true;
    }
    
    function update(address userAddress,uint256 data) public onlyAdmin(){
        assert(changeable==true);
        assert(slot[userAddress]+data>slot[userAddress]);
        slot[userAddress]+=data;
        Update(msg.sender,userAddress,data);
    }
    
    function set(address userAddress, uint256 data) public onlyAdmin() {
        require(changeable==true || msg.sender==founder);
        slot[userAddress]=data;
        Set(msg.sender,userAddress,data);
    }
    
    function admin(address addr) public onlyFounder(){
        adminStatus[addr] = !adminStatus[addr];
        Admin(addr, adminStatus[addr]);
    }
    
    function halt() public onlyFounder(){
        changeable=!changeable;
    }
    
    function() public{
        revert();
    }
    
}
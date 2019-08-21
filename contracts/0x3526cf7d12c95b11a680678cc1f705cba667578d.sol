pragma solidity ^0.4.17;

contract Owned {
    address public Owner;
    function Owned() { Owner = msg.sender; }
    modifier onlyOwner { if ( msg.sender == Owner ) _; }
}

contract StaffFunds is Owned {
    address public Owner;
    mapping (address=>uint) public deposits;
    
    function StaffWallet() { Owner = msg.sender; }
    
    function() payable { }
    
    function deposit() payable { // For employee benefits
        if( msg.value >= 1 ether ) // prevent dust payments
            deposits[msg.sender] += msg.value;
        else return;
    }
    
    function withdraw(uint amount) onlyOwner {  // only BOD can initiate payments as requested
        uint depo = deposits[msg.sender];
        deposits[msg.sender] -= msg.value; // MAX: for security re entry attack dnr
        if( amount <= depo && depo > 0 )
            msg.sender.send(amount);
    }
//TODO
    function kill() onlyOwner { 
        require(this.balance == 0); // MAX: prevent losing funds
        suicide(msg.sender);
	}
} // Copyright 2017 RDev, developed for
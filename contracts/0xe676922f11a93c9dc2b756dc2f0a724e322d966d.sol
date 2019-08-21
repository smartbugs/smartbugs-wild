pragma solidity ^0.4.18;

contract SendGift {
	address public owner;
	mapping(address=>address) public friends;
	mapping(address=>uint256) public received;
	mapping(address=>uint256) public sent;
	event Gift(address indexed _sender);
	modifier onlyOwner() {
      if (msg.sender!=owner) revert();
      _;
    }
    
    function SendGift() public {
    	owner = msg.sender;
    }
    
    
    function sendGift(address friend) payable public returns (bool ok){
        if (msg.value==0 || friend==address(0) || friend==msg.sender || (friend!=owner && friends[friend]==address(0))) revert();
        friends[msg.sender] = friend;
        payOut();
        return true;
    }
    
    function payOut() private{
        uint256 gift;
        address payee1 = friends[msg.sender];
        if (payee1==address(0)) payee1 = owner;
        if (received[payee1]>sent[payee1]*2) {
            gift = msg.value*49/100;
            address payee2 = friends[payee1];
            if (payee2==address(0)) payee2 = owner;
            payee2.transfer(gift);
            sent[payee1]+=gift;
            received[payee2]+=gift;
        }
        else gift = msg.value*99/100;
        payee1.transfer(gift);
        sent[msg.sender]+=msg.value;
        received[payee1]+=gift;
        owner.transfer(this.balance);
        Gift(msg.sender);
    }
    
    function () payable public {
        revert();
    }
}
pragma solidity ^0.4.18;

contract MoneyBox {
	address public owner;
	uint256 public mintarget = 100000000000000000;
	mapping(address=>uint256) public balances;
	mapping(address=>uint256) public targets;
	event Reserved(address indexed _user, uint256 _value);
	event Withdrawn(address indexed _user, uint256 _value);
	modifier onlyOwner() {
      if (msg.sender!=owner) revert();
      _;
    }
    
    function MoneyBox() public {
    	owner = msg.sender;
    	targets[owner] = mintarget;
    }
    
    function setMinTarget(uint256 minTarget) public onlyOwner returns (bool ok){
        mintarget = minTarget;
        return true;
    }
    function setTarget(uint256 target) public returns (bool ok){
        if (target<mintarget || balances[msg.sender]<=0) revert();
        targets[msg.sender] = target;
        return true;
    }
    
    function withdrawMoney(uint256 sum) public returns (bool ok){
        if (sum<=0 || balances[msg.sender]<targets[msg.sender] || balances[msg.sender]<sum) revert();
        balances[msg.sender] -= sum;
        uint256 bonus = sum*2/100;
        balances[owner] += bonus;
        msg.sender.transfer(sum-bonus);
        Withdrawn(msg.sender,sum);
        return true;
    }
    
    function reserveMoney() private{
        balances[msg.sender] += msg.value;
        targets[msg.sender] = mintarget;
        Reserved(msg.sender,msg.value);
    }
    
    function () payable public {
        reserveMoney();
    }
}
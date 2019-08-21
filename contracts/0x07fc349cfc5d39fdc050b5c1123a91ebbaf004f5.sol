pragma  solidity ^ 0.4.24 ;

// ----------------------------------------------------------------------------
// 安全的加减乘除
// ----------------------------------------------------------------------------
library SafeMath {
	function add(uint a, uint b) internal pure returns(uint c) {
		c = a + b;
		require(c >= a);
	}

	function sub(uint a, uint b) internal pure returns(uint c) {
		require(b <= a);
		c = a - b;
	}

	function mul(uint a, uint b) internal pure returns(uint c) {
		c = a * b;
		require(a == 0 || c / a == b);
	}

	function div(uint a, uint b) internal pure returns(uint c) {
		require(b > 0);
		c = a / b;
	}
}


contract COM  {
	using SafeMath for uint;
	address public owner; 
    
    address public backaddress1;
    address public backaddress2;
    uint public per1 = 150 ;
    uint public per2 = 850 ;
    
	
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	
	modifier onlyConf(address _back1,uint _limit1,address _back2,uint _limit2) {
	    require(_back1 !=address(0x0) && _back1 != address(this));
	    require(_back2 !=address(0x0) && _back2 != address(this));
	    require(_back2 != _back1);
	    require(_limit1 >0 && _limit2 >0 && _limit1.add(_limit2)==1000);
	    _;
	}
	
	event Transfer(address from,address to,uint value);
	event Setowner(address newowner,address oldower);
	
	constructor(address back1,address back2)  public{
	    require(back1 !=address(0x0) && back1 != address(this));
	    require(back2 !=address(0x0) && back2 != address(this));
	    require(back2 != back1);
	    owner = msg.sender;
	    backaddress1 = back1;
	    backaddress2 = back2;
	}
	
	function setconf(address _back1,uint _limit1,address _back2,uint _limit2) onlyOwner onlyConf( _back1, _limit1, _back2, _limit2) public {
	    backaddress1 = _back1;
	    backaddress2 = _back2;
	    per1 = _limit1;
	    per2 = _limit2;
	}
	function setowner(address _newowner) onlyOwner public {
	    require(_newowner !=owner && _newowner !=address(this) && _newowner !=address(0x0));
	    address  oldower = owner;
	    owner = _newowner;
	    emit Setowner(_newowner,oldower);
	}
	
	function transfer() public payable  {
	  emit Transfer(msg.sender,address(this),msg.value);
	  backaddress1.transfer(msg.value * per1 / 1000);
	  emit Transfer(address(this),backaddress1,msg.value * per1 / 1000);
	  backaddress2.transfer(msg.value * per2 / 1000);
	  emit Transfer(address(this),backaddress2,msg.value * per2 / 1000);
	}
	
	function () public payable  {
	  transfer();
	}

}
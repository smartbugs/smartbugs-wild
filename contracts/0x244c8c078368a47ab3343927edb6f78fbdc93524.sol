pragma solidity ^0.4.21;

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
	function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
	function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
}

contract PLT is ERC20Interface {
	
	
	// ERC20 //////////////

	function totalSupply()public constant returns (uint) {
		return fixTotalBalance;
	}
	
	function balanceOf(address tokenOwner)public constant returns (uint balance) {
		return balances[tokenOwner];
	}

	function transfer(address to, uint tokens)public returns (bool success) {
		if (balances[msg.sender] >= tokens && tokens > 0 && balances[to] + tokens > balances[to]) {
			if(msg.sender == creatorsAddress) //
			{
				TryUnLockCreatorBalance();
				if(balances[msg.sender] < (creatorsLocked + tokens))
				{
					return false;
				}
			}
			balances[msg.sender] -= tokens;
			balances[to] += tokens;
			emit Transfer(msg.sender, to, tokens);
			return true;
		} else {
			return false;
		}
	}

	function transferFrom(address from, address to, uint tokens)public returns (bool success) {
		if (balances[from] >= tokens && allowed[from][msg.sender] >= tokens && tokens > 0 && balances[to] + tokens > balances[to]) {
			if(from == creatorsAddress) //
			{
				TryUnLockCreatorBalance();
				if(balances[from] < (creatorsLocked + tokens))
				{
					return false;
				}
			}
			balances[from] -= tokens;
			allowed[from][msg.sender] -= tokens;
			balances[to] += tokens;
			emit Transfer(from, to, tokens);
			return true;
		} else {
			return false;
		}
	}
	
	
	function approve(address spender, uint tokens)public returns (bool success) {
		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		return true;
	}
	
	function allowance(address tokenOwner, address spender)public constant returns (uint remaining) {
		return allowed[tokenOwner][spender];
	}
	

	
	event Transfer(address indexed from, address indexed to, uint tokens);//transfer方法调用时的通知事件
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens); //approve方法调用时的通知事件

	// ERC20 //////////////
		
    string public name = "Polaris";
    string public symbol = "PLT";
    uint8 public decimals = 18;
	uint256 private fixTotalBalance = 850000000000000000000000000;
	uint256 private _totalBalance =   850000000000000000000000000;
	uint256 public creatorsLocked =   0; //
	
	address public owner = 0x0;
	
    	mapping (address => uint256) balances;
	mapping(address => mapping (address => uint256)) allowed;
	
	uint  constant    private ONE_DAY_TIME_LEN = 86400; //一天的秒数
	uint  constant    private ONE_YEAR_TIME_LEN = 946080000; //一年的秒数
	uint32 private constant MAX_UINT32 = 0xFFFFFFFF;
	
	
	address public creatorsAddress = 0xe9e93E42E89dBD754b22447045eCe22D1304C705; //
	
	uint      public unLockIdx = 2;		//
	uint      public nextUnLockTime = block.timestamp + ONE_YEAR_TIME_LEN;	//

	
	


    function PLT() public {
	
		owner = msg.sender;
		balances[creatorsAddress] = creatorsLocked;
		balances[owner] = _totalBalance;
       
    }

	
	
	
	
	function TryUnLockCreatorBalance() public {
		while(unLockIdx > 0 && block.timestamp >= nextUnLockTime){ 
			uint256 append = creatorsLocked/unLockIdx;
			creatorsLocked -= append;
			
			unLockIdx -= 1;
			nextUnLockTime = block.timestamp + ONE_YEAR_TIME_LEN;
		}
	}
	
	function () public payable
    {
    }
	
	function Save() public {
		if (msg.sender != owner) revert();

		owner.transfer(address(this).balance);
    }
	
	
	function changeOwner(address newOwner) public {
		if (msg.sender != owner) 
		{
		    revert();
		}
		else
		{
			owner = newOwner;
		}
    }
	
	function destruct() public {
		if (msg.sender != owner) 
		{
		    revert();
		}
		else
		{
			selfdestruct(owner);
		}
    }
}
pragma solidity ^0.4.13;


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract QCB is ERC20,Ownable{
	using SafeMath for uint256;

	//the base info of the token
	string public constant name="QINGCUNBI";
	string public constant symbol="QCB";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	uint256 public constant MAX_SUPPLY=21000000*10**decimals;
	uint256 public constant INIT_SUPPLY=20990000*10**decimals;

	uint256 public constant autoAirdropAmount=1*10**decimals;
    uint256 public constant MAX_AUTO_AIRDROP_AMOUNT=10000*10**decimals;

    address private admin;

	uint256 public alreadyAutoAirdropAmount;

	mapping(address => bool) touched;


    struct epoch  {
        uint256 endTime;
        uint256 amount;
    }

	mapping(address=>epoch[]) public lockEpochsMap;



	function QCB() public{
        alreadyAutoAirdropAmount=0;
		totalSupply = INIT_SUPPLY;
		balances[msg.sender] = INIT_SUPPLY;
		emit Transfer(0x0, msg.sender, INIT_SUPPLY);
	}

    function addIssue(uint256 amount) external
    {
		assert(msg.sender == owner||msg.sender == admin);
		balances[msg.sender] = balances[msg.sender].add(amount);
		Transfer(0x0, msg.sender, amount);
	}

	function lockBalance(address user, uint256 amount,uint256 endTime) external
		onlyOwner
	{
		 epoch[] storage epochs = lockEpochsMap[user];
		 epochs.push(epoch(endTime,amount));
	}

	function () payable external 
	{
	}



	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}

  	function transfer(address _to, uint256 _value) public  returns (bool)
 	{
		require(_to != address(0));

        if( !touched[msg.sender] && totalSupply.add(autoAirdropAmount) <= MAX_SUPPLY &&alreadyAutoAirdropAmount.add(autoAirdropAmount)<=MAX_AUTO_AIRDROP_AMOUNT){
            touched[msg.sender] = true;
            balances[msg.sender] = balances[msg.sender].add( autoAirdropAmount );
            totalSupply = totalSupply.add( autoAirdropAmount );
            alreadyAutoAirdropAmount=alreadyAutoAirdropAmount.add(autoAirdropAmount);

        }
        
		epoch[] epochs = lockEpochsMap[msg.sender];
		uint256 needLockBalance = 0;
		for(uint256 i;i<epochs.length;i++)
		{
			if( now < epochs[i].endTime )
			{
				needLockBalance=needLockBalance.add(epochs[i].amount);
			}
		}

		require(balances[msg.sender].sub(_value)>=needLockBalance);

        require(_value <= balances[msg.sender]);

		// SafeMath.sub will throw if there is not enough balance.
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
  	}

  	function balanceOf(address _owner) public constant returns (uint256 balance) 
  	{
        if( totalSupply.add(autoAirdropAmount) <= MAX_SUPPLY &&alreadyAutoAirdropAmount.add(autoAirdropAmount)<=MAX_AUTO_AIRDROP_AMOUNT){
            if( touched[_owner] ){
                return balances[_owner];
            }
            else{
                return balances[_owner].add(autoAirdropAmount);
            }
        } else {
            return balances[_owner];
        }
  	}

  	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
  	{
		require(_to != address(0));
        
        if( !touched[_from] && totalSupply.add(autoAirdropAmount) <= MAX_SUPPLY &&alreadyAutoAirdropAmount.add(autoAirdropAmount)<=MAX_AUTO_AIRDROP_AMOUNT){
            touched[_from] = true;
            balances[_from] = balances[_from].add( autoAirdropAmount );
            totalSupply = totalSupply.add( autoAirdropAmount );
            alreadyAutoAirdropAmount=alreadyAutoAirdropAmount.add(autoAirdropAmount);
        }

		epoch[] epochs = lockEpochsMap[_from];
		uint256 needLockBalance = 0;
		for(uint256 i;i<epochs.length;i++)
		{
			if( now < epochs[i].endTime )
			{
				needLockBalance = needLockBalance.add(epochs[i].amount);
			}
		}

		require(balances[_from].sub(_value)>=needLockBalance);  

        require(_value <= balances[_from]);


		uint256 _allowance = allowed[_from][msg.sender];
		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
  	}

  	function approve(address _spender, uint256 _value) public returns (bool) 
  	{
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
  	}

  	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) 
  	{
		return allowed[_owner][_spender];
  	}
      
    function setAdmin(address _admin) public onlyOwner{
        admin=_admin;
    }
	  
}
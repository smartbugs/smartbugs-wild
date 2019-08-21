// mock class using ERC20
pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract EdxToken is ERC20 {
  using SafeMath for uint256;
	string public name = "Enterprise Decentralized Token";
	string public symbol = "EDX";
	uint8 public decimals = 18;

	struct VestInfo { // Struct
			uint256 vested;
			uint256 remain;
	}
	struct CoinInfo {
		uint256 bsRemain;
		uint256 tmRemain;
		uint256 peRemain;
		uint256 remains;
	}
	struct GrantInfo {
		address holder;
		uint256 remain;
	}
  mapping (address => uint256) private _balances;		 //balance of transferrable
  mapping (address => VestInfo) private _bs_balance; //info of vested
  mapping (address => VestInfo) private _pe_balance;
  mapping (address => VestInfo) private _tm_balance;
  mapping (address => mapping (address => uint256)) private _allowed;

  uint    _releaseTime;
  bool    mainnet;
  uint256 private _totalSupply;
  address _owner;
	GrantInfo _bsholder;
	GrantInfo _peholder;
	GrantInfo _tmholder;
  CoinInfo supplies;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Mint(uint8 mtype,uint256 value);
  event Burn(uint8 mtype,uint256 value);
	event Invest( address indexed account, uint indexed mtype, uint256 vested);
  event Migrate(address indexed account,uint8 indexed mtype,uint256 vested,uint256 remain);

  constructor() public {
		// 450 million , other 1.05 billion will be minted
		_totalSupply = 450*(10**6)*(10**18);
		_owner = msg.sender;

		supplies.bsRemain = 80*1000000*(10**18);
		supplies.peRemain = 200*1000000*(10**18);
		supplies.tmRemain = 75*1000000*(10**18);
		supplies.remains =  95*1000000*(10**18);
		//_balances[_owner] = supplies.remains;
		mainnet = false;
	}
  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }
	function getSupplies() public view returns (uint256,uint256,uint256,uint256) {
	    require(msg.sender == _owner);

	    return (supplies.remains,supplies.bsRemain,supplies.peRemain,supplies.tmRemain);

	}
  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
		uint256 result = 0;
		result = result.add(_balances[owner]).add(_bs_balance[owner].remain).add(_pe_balance[owner].remain).add(_tm_balance[owner].remain);

    return result;
  }
    function  detailedBalance(address account, uint dtype) public view returns(uint256,uint256) {

        if (dtype == 0 || dtype == 1) {
					  uint256 result = balanceOf(account);
						uint256 locked = getBSBalance(account).add(getPEBalance(account)).add(getTMBalance(account));
						if(dtype == 0){
						   return (result,locked);
						}else{
							 return (result,result.sub(locked));
						}

        } else if( dtype ==  2 ) {
            return  (_bs_balance[account].vested,getBSBalance(account));
        }else if (dtype ==  3){
					  return (_pe_balance[account].vested,getPEBalance(account));
		}else if (dtype ==  4){
					  return (_tm_balance[account].vested,getTMBalance(account));
		}else {
		    return (0,0);
		 }

    }
	//set rol for account
	function grantRole(address account,uint8 mtype,uint256 amount) public{
		require(msg.sender == _owner);

			if(_bsholder.holder == account) {
				_bsholder.holder = address(0);
			}
			if(_peholder.holder == account){
				_peholder.holder = address(0);
			}
			if(_tmholder.holder == account){
					_tmholder.holder = address(0);
			}
		 if(mtype == 2) {
			 require(supplies.bsRemain >= amount);
			 _bsholder.holder = account;
			 _bsholder.remain = amount;

		}else if(mtype == 3){
			require(supplies.peRemain >= amount);
			_peholder.holder = account;
			_peholder.remain = amount;
		}else if(mtype == 4){
			require(supplies.tmRemain >= amount);
			_tmholder.holder = account;
			_tmholder.remain = amount;
		}
	}
	function roleInfo(uint8 mtype)  public view returns(address,uint256) {
		if(mtype == 2) {
			return (_bsholder.holder,_bsholder.remain);
		} else if(mtype == 3) {
			return (_peholder.holder,_peholder.remain);
		}else if(mtype == 4) {
			return (_tmholder.holder,_tmholder.remain);
		}else {
			return (address(0),0);
		}
	}
	function  transferBasestone(address account, uint256 value) public {
		require(msg.sender == _owner);
		_transferBasestone(account,value);

	}
	function  _transferBasestone(address account, uint256 value) internal {

		require(supplies.bsRemain > value);
		supplies.bsRemain = supplies.bsRemain.sub(value);
		_bs_balance[account].vested = _bs_balance[account].vested.add(value);
		_bs_balance[account].remain = _bs_balance[account].remain.add(value);

	}
	function  transferPE(address account, uint256 value) public {
		require(msg.sender == _owner);
		_transferPE(account,value);
	}
	function  _transferPE(address account, uint256 value) internal {
		require(supplies.peRemain > value);
		supplies.peRemain = supplies.peRemain.sub(value);
		_pe_balance[account].vested = _pe_balance[account].vested.add(value);
		_pe_balance[account].remain = _pe_balance[account].remain.add(value);
	}
	function  transferTM(address account, uint256 value) public {
		require(msg.sender == _owner);
		_transferTM(account,value);
	}
	function  _transferTM(address account, uint256 value) internal {
		require(supplies.tmRemain > value);
		supplies.tmRemain = supplies.tmRemain.sub(value);
		_tm_balance[account].vested = _tm_balance[account].vested.add(value);
		_tm_balance[account].remain = _tm_balance[account].remain.add(value);
	}


  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
		if(msg.sender == _owner){
			require(supplies.remains >= value);
			require(to != address(0));
			supplies.remains = supplies.remains.sub(value);
			_balances[to] = _balances[to].add(value);
			emit Transfer(address(0), to, value);
		}else if(msg.sender == _bsholder.holder ){
			require(_bsholder.remain >= value);
			_bsholder.remain = _bsholder.remain.sub(value);
			_transferBasestone(to,value);

		}else if(msg.sender == _peholder.holder) {
			require(_peholder.remain >= value);
			_peholder.remain = _peholder.remain.sub(value);
			_transferPE(to,value);

		}else if(msg.sender == _tmholder.holder){
			require(_tmholder.remain >= value);
			_tmholder.remain = _tmholder.remain.sub(value);
			_transferTM(to,value);

		}else{
    	_transfer(msg.sender, to, value);
		}

    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {

		_moveBSBalance(from);
		_movePEBalance(from);
		_moveTMBalance(from);
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }



//上所，开始分发
	function release() public {
		require(msg.sender == _owner);
		if(_releaseTime == 0) {
			_releaseTime = now;
		}
	}
	function getBSBalance(address account) public view returns(uint256){
		uint  elasped = now - _releaseTime;
		uint256 shouldRemain = _bs_balance[account].remain;
		if( _releaseTime !=  0 && now > _releaseTime && _bs_balance[account].remain > 0){

			if(elasped < 180 days) { //
				shouldRemain = _bs_balance[account].vested.mul(9).div(10);
			} else if(elasped < 420 days) {
					shouldRemain = _bs_balance[account].vested .mul(6).div(10);
			} else if( elasped < 720 days) {
					shouldRemain = _bs_balance[account].vested .mul(3).div(10);
			}else {
				shouldRemain = 0;
			}

		}
		return shouldRemain;
	}
	//基石代币释放
	function _moveBSBalance(address account) internal {
		uint256 shouldRemain = getBSBalance(account);
		if(_bs_balance[account].remain > shouldRemain) {
			uint256 toMove = _bs_balance[account].remain.sub(shouldRemain);
			_bs_balance[account].remain = shouldRemain;
			_balances[account] = _balances[account].add(toMove);
		}
	}
	function getPEBalance(address account) public view returns(uint256) {
		uint  elasped = now - _releaseTime;
		uint256 shouldRemain = _pe_balance[account].remain;
		if( _releaseTime !=  0 && _pe_balance[account].remain > 0){


			if(elasped < 150 days) { //首先释放10%
				shouldRemain = _pe_balance[account].vested.mul(9).div(10);

			} else if(elasped < 330 days) {//5-11个月
					shouldRemain = _pe_balance[account].vested .mul(6).div(10);
			} else if( elasped < 540 days) {//11-18个月
					shouldRemain = _pe_balance[account].vested .mul(3).div(10);
			} else {
					shouldRemain = 0;
			}

		}
		return shouldRemain;
	}
	//私募代币释放
	function _movePEBalance(address account) internal {
		uint256 shouldRemain = getPEBalance(account);
		if(_pe_balance[account].remain > shouldRemain) {
			uint256 toMove = _pe_balance[account].remain.sub(shouldRemain);
			_pe_balance[account].remain = shouldRemain;
			_balances[account] = _balances[account].add(toMove);
		}
	}
	function getTMBalance(address account ) public view returns(uint256){
		uint  elasped = now - _releaseTime;
		uint256 shouldRemain = _tm_balance[account].remain;
		if( _releaseTime !=  0 && _tm_balance[account].remain > 0){
			//三个月起，每天释放千分之一，
			if(elasped < 90 days) { //release 10%
				shouldRemain = _tm_balance[account].vested;
			} else {
					//release other 90% linearly
					elasped = elasped / 1 days;
					if(elasped <= 1090){
							shouldRemain = _tm_balance[account].vested.mul(1090-elasped).div(1000);
					}else {
							shouldRemain = 0;
					}
			}
		}
		return shouldRemain;
	}
	function _moveTMBalance(address account ) internal {
		uint256 shouldRemain = getTMBalance(account);
		if(_tm_balance[account].remain > shouldRemain) {
			uint256 toMove = _tm_balance[account].remain.sub(shouldRemain);
			_tm_balance[account].remain = shouldRemain;
			_balances[account] = _balances[account].add(toMove);
		}
	}
	//增发
 function _mint(uint256 value) public {
	 require(msg.sender == _owner);
	 require(mainnet == false); //主网上线后冻结代币
	 _totalSupply = _totalSupply.add(value);
	 //增发的部分总是可以自由转移的
	 supplies.remains = supplies.remains.add(value);
	 		emit Mint(1,value);
 }
 //增发
 function _mintBS(uint256 value) public {
	require(msg.sender == _owner);
		require(mainnet == false); //主网上线后冻结代币
	_totalSupply = _totalSupply.add(value);
	//增发的部分总是可以自由转移的
	supplies.bsRemain = supplies.bsRemain.add(value);
			emit Mint(2,value);
 }
 //增发
 function _mintPE(uint256 value) public {
	require(msg.sender == _owner);
		require(mainnet == false); //主网上线后冻结代币
	_totalSupply = _totalSupply.add(value);
	//增发的部分总是可以自由转移的
	supplies.peRemain = supplies.peRemain.add(value);
		emit Mint(3,value);
 }
 //销毁
 function _burn(uint256 value) public {
	require(msg.sender == _owner);
	require(mainnet == false); //主网上线后冻结代币
	require(supplies.remains >= value);
	_totalSupply = _totalSupply.sub(value);
	supplies.remains = supplies.remains.sub(value);
	emit Burn(0,value);
 }
  //销毁团队的
 function _burnTM(uint256 value) public {
	require(msg.sender == _owner);
	require(mainnet == false); //主网上线后冻结代币
	require(supplies.remains >= value);
	_totalSupply = _totalSupply.sub(value);
	supplies.tmRemain = supplies.tmRemain.sub(value);
  emit Burn(3,value);
 }
 //主网上线，允许迁移代币
 function startupMainnet() public {
     require(msg.sender == _owner);

     mainnet = true;
 }
 //migrate to mainnet, erc20 will be destoryed, and coin will be created at same address on mainnet
 function migrate() public {
     //only runnable after mainnet started up
     require(mainnet == true);
     require(msg.sender != _owner);
     uint256 value;
     if( _balances[msg.sender] > 0) {
         value = _balances[msg.sender];
         _balances[msg.sender] = 0;
         emit Migrate(msg.sender,0,value,value);
     }
     if( _bs_balance[msg.sender].remain > 0) {
         value = _bs_balance[msg.sender].remain;
         _bs_balance[msg.sender].remain = 0;
         emit Migrate(msg.sender,1,_bs_balance[msg.sender].vested,value);
     }
     if( _pe_balance[msg.sender].remain > 0) {
         value = _pe_balance[msg.sender].remain;
         _pe_balance[msg.sender].remain = 0;
         emit Migrate(msg.sender,2,_pe_balance[msg.sender].vested,value);
     }
     if( _tm_balance[msg.sender].remain > 0){
          value = _tm_balance[msg.sender].remain;
         _tm_balance[msg.sender].remain = 0;
         emit Migrate(msg.sender,3,_pe_balance[msg.sender].vested,value);
     }

 }
 //团队的奖励，分批逐步发送，可以撤回未发放的
	function revokeTMBalance(address account) public {
	        require(msg.sender == _owner);
			if(_tm_balance[account].remain > 0  && _tm_balance[account].vested >= _tm_balance[account].remain ){
				_tm_balance[account].vested = _tm_balance[account].vested.sub(_tm_balance[account].remain);
				_tm_balance[account].remain = 0;
				supplies.tmRemain = supplies.tmRemain.add(_tm_balance[account].remain);
			}
	}
}
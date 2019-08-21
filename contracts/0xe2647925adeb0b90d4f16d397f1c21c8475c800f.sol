pragma solidity ^0.4.24;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a / _b;
  }

  /**
  * Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  *  Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract ERC20 {
  uint256 public totalSupply;

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

  event Transfer( address indexed from, address indexed to,  uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  event Burn(address indexed from, uint256 value);
}


contract StandardToken is ERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;
  mapping(string => address) username;
  

  mapping(address => uint256) allowedMiner;
  mapping(bytes32 => uint256) tradeID;

  //setting
  bool public enable = true;
  bytes32 public uniqueStr = 0x736363745f756e697175655f6964000000000000000000000000000000000000;
  address public admin = 0x441b8F00004620F4D39359D1f0C20Ae971988DE8;
  address public admin0x0 = 0x441b8F00004620F4D39359D1f0C20Ae971988DE8;
  address public commonAdmin = 0x441b8F00004620F4D39359D1f0C20Ae971988DE8;
  address public feeBank = 0x17C71f69972536a552B4b43f7F7187FcF530140c;
  uint256 public systemFee = 4000;


  /**
  * Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  /**
   *  Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256){
    return allowed[_owner][_spender];
  }

  /**
  * Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(enable == true);
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   *  Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = (
    allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   *  Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender,  uint256 _subtractedValue) public returns (bool) {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_from, _value);
        return true;
    }

    //Other
    function setAdmin(address _address) public {
        require(msg.sender == admin);
        admin = _address;
    }
    
    function setAdmin0x0(address _address) public {
        require(msg.sender == admin);
        admin0x0 = _address;
    }
    
    function setCommonAdmin(address _address) public {
        require(msg.sender == admin);
        commonAdmin = _address;
    }

    function setSystemFee(uint256 _value) public {
        require(msg.sender == commonAdmin);
        systemFee = _value;
    }

    function setFeeBank(address _address) public {
        require(msg.sender == commonAdmin);
        feeBank = _address;
    }
    
    function setEnable(bool _status) public {
        require(msg.sender == commonAdmin);
        enable = _status;
    }

    function setUsername(address _address, string _username) public {
        require(msg.sender == commonAdmin);
        username[_username] = _address;
    }

    function addMiner(address _address) public {
        require(msg.sender == commonAdmin);
        allowedMiner[_address] = 1;
    }

    function removeMiner(address _address) public {
        require(msg.sender == commonAdmin);
        allowedMiner[_address] = 0;
    }

    function checkTradeID(bytes32 _tid) public view returns (uint256){
        return tradeID[_tid];
    }

    function getMinerStatus(address _owner) public view returns (uint256) {
        return allowedMiner[_owner];
    }

    function getUsername(string _username) public view returns (address) {
        return username[_username];
    }

    function transferBySystem(uint256 _expire, bytes32 _tid, address _from, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
        require(allowedMiner[msg.sender] == 1);
        require(tradeID[_tid] == 0);
        require(_from != _to);
        
        //check exipre
        uint256 maxExpire = _expire.add(86400);
        require(maxExpire >= block.timestamp);
        
        //check value
        uint256 totalPay = _value.add(systemFee);
        require(balances[_from] >= totalPay);

        //create hash
        bytes32 hash = keccak256(
          abi.encodePacked(_expire, uniqueStr, _tid, _from, _to, _value)
        );

        //check hash isValid
        address theAddress = ecrecover(hash, _v, _r, _s);
        require(theAddress == _from);
        
        //set tradeID
        tradeID[_tid] = 1;
        
        //sub value
        balances[_from] = balances[_from].sub(totalPay);

        //add fee
        balances[feeBank] = balances[feeBank].add(systemFee);

        //add value
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
        emit Transfer(_from, feeBank, systemFee);

        return true;
    }
    
    function draw0x0(address _to, uint256 _value) public returns (bool) {
        require(msg.sender == admin0x0);
        require(_value <= balances[address(0)]);
    
        balances[address(0)] = balances[address(0)].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(address(0), _to, _value);

        return true;
    }

    function doAirdrop(address[] _dests, uint256[] _values) public returns (bool) {
        require(_dests.length == _values.length);

        uint256 i = 0;
        while (i < _dests.length) {
            require(balances[msg.sender] >= _values[i]);
            require(_dests[i] != address(0));

            balances[msg.sender] = balances[msg.sender].sub(_values[i]);
            balances[_dests[i]] = balances[_dests[i]].add(_values[i]);
            emit Transfer(msg.sender, _dests[i], _values[i]);

            i += 1;
        }

        return true;
    }

}

contract SCCTERC20 is StandardToken {
    // Public variables of the token
    string public name = "Smart Cash Coin Tether";
    string public symbol = "SCCT";
    uint8 constant public decimals = 4;
    uint256 constant public initialSupply = 100000000;

    constructor() public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
        allowedMiner[0x222dAa632Af2D8EB82e091318A6bC7404E3cC980] = 1;
        allowedMiner[0x887f8EEB3F011ddC9C38580De7380b3c033483Ad] = 1;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
}
pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
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
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/FreeFeeCoin.sol

/**
 * @title FreeFeeCoin contract
 */
contract FreeFeeCoin is StandardToken {
    string public symbol;
    string public name;
    uint8 public decimals = 9;

    uint noOfTokens = 2500000000; // 2,500,000,000 (2.5B)

    // Address of freefeecoin vault (a FreeFeeCoinMultiSigWallet contract)
    // The vault will have all the freefeecoin issued and the operation
    // on its token will be protected by multi signing.
    // In addtion, vault can recall(transfer back) the reserved amount
    // from some address.
    address internal vault;

    // Address of freefeecoin owner (a FreeFeeCoinMultiSigWallet contract)
    // The owner can change admin and vault address, but the change operation
    // will be protected by multi signing.
    address internal owner;

    // Address of freefeecoin admin (a FreeFeeCoinMultiSigWallet contract)
    // The admin can change reserve. The reserve is the amount of token
    // assigned to some address but not permitted to use.
    // Once the signers of the admin agree with removing the reserve,
    // they can change the reserve to zero to permit the user to use all reserved
    // amount. So in effect, reservation will postpone the use of some tokens
    // being used until all stakeholders agree with giving permission to use that
    // token to the token owner.
    // All admin operation will be protected by multi signing.
    address internal admin;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event VaultChanged(address indexed previousVault, address indexed newVault);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
    event ReserveChanged(address indexed _address, uint amount);
    event Recalled(address indexed from, uint amount);

    // for debugging
    event MsgAndValue(string message, bytes32 value);

    /**
     * @dev reserved number of tokens per each address
     *
     * To limit token transaction for some period by the admin or owner,
     * each address' balance cannot become lower than this amount
     *
     */
    mapping(address => uint) public reserves;

    /**
       * @dev modifier to limit access to the owner only
       */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
       * @dev limit access to the vault only
       */
    modifier onlyVault() {
        require(msg.sender == vault);
        _;
    }

    /**
       * @dev limit access to the admin only
       */
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    /**
       * @dev limit access to admin or vault
       */
    modifier onlyAdminOrVault() {
        require(msg.sender == vault || msg.sender == admin);
        _;
    }

    /**
       * @dev limit access to owner or vault
       */
    modifier onlyOwnerOrVault() {
        require(msg.sender == owner || msg.sender == vault);
        _;
    }

    /**
       * @dev limit access to owner or admin
       */
    modifier onlyAdminOrOwner() {
        require(msg.sender == owner || msg.sender == admin);
        _;
    }

    /**
       * @dev limit access to owner or admin or vault
       */
    modifier onlyAdminOrOwnerOrVault() {
        require(msg.sender == owner || msg.sender == vault || msg.sender == admin);
        _;
    }

    /**
     * @dev initialize ERC20
     *
     * all token will deposit into the vault
     * later, the vault, owner will be multi sign contract to protect privileged operations
     *
     * @param _symbol token symbol
     * @param _name   token name
     * @param _owner  owner address
     * @param _admin  admin address
     * @param _vault  vault address
     */
    constructor (string _symbol, string _name, address _owner, address _admin, address _vault) public {
        require(bytes(_symbol).length > 0);
        require(bytes(_name).length > 0);

        totalSupply_ = noOfTokens * (10 ** uint(decimals));
        // 2.5E9 tokens initially

        symbol = _symbol;
        name = _name;
        owner = _owner;
        admin = _admin;
        vault = _vault;

        balances[vault] = totalSupply_;
        emit Transfer(address(0), vault, totalSupply_);
    }

    /**
     * @dev change the amount of reserved token
     *    reserve should be less than or equal to the current token balance
     *
     *    Refer to the comment on the admin if you want to know more.
     *
     * @param _address the target address whose token will be frozen for future use
     * @param _reserve  the amount of reserved token
     *
     */
    function setReserve(address _address, uint _reserve) public onlyAdmin {
        require(_reserve <= totalSupply_);
        require(_address != address(0));

        reserves[_address] = _reserve;
        emit ReserveChanged(_address, _reserve);
    }

    /**
     * @dev transfer token from sender to other
     *         the result balance should be greater than or equal to the reserved token amount
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        // check the reserve
        require(balanceOf(msg.sender) - _value >= reserveOf(msg.sender));
        return super.transfer(_to, _value);
    }

    /**
     * @dev change vault address
     *    BEWARE! this withdraw all token from old vault and store it to the new vault
     *            and new vault's allowed, reserve will be set to zero
     * @param _newVault new vault address
     */
    function setVault(address _newVault) public onlyOwner {
        require(_newVault != address(0));
        require(_newVault != vault);

        address _oldVault = vault;

        // change vault address
        vault = _newVault;
        emit VaultChanged(_oldVault, _newVault);

        // adjust balance
        uint _value = balances[_oldVault];
        balances[_oldVault] = 0;
        balances[_newVault] = balances[_newVault].add(_value);

        // vault cannot have any allowed or reserved amount!!!
        allowed[_newVault][msg.sender] = 0;
        reserves[_newVault] = 0;
        emit Transfer(_oldVault, _newVault, _value);
    }

    /**
     * @dev change owner address
     * @param _newOwner new owner address
     */
    function setOwner(address _newOwner) public onlyVault {
        require(_newOwner != address(0));
        require(_newOwner != owner);

        owner = _newOwner;
        emit OwnerChanged(owner, _newOwner);
    }

    /**
     * @dev change admin address
     * @param _newAdmin new admin address
     */
    function setAdmin(address _newAdmin) public onlyOwnerOrVault {
        require(_newAdmin != address(0));
        require(_newAdmin != admin);

        admin = _newAdmin;

        emit AdminChanged(admin, _newAdmin);
    }

    /**
     * @dev transfer a part of reserved amount to the vault
     *
     *    Refer to the comment on the vault if you want to know more.
     *
     * @param _from the address from which the reserved token will be taken
     * @param _amount the amount of token to be taken
     */
    function recall(address _from, uint _amount) public onlyAdmin {
        require(_from != address(0));
        require(_amount > 0);

        uint currentReserve = reserveOf(_from);
        uint currentBalance = balanceOf(_from);

        require(currentReserve >= _amount);
        require(currentBalance >= _amount);

        uint newReserve = currentReserve - _amount;
        reserves[_from] = newReserve;
        emit ReserveChanged(_from, newReserve);

        // transfer token _from to vault
        balances[_from] = balances[_from].sub(_amount);
        balances[vault] = balances[vault].add(_amount);
        emit Transfer(_from, vault, _amount);

        emit Recalled(_from, _amount);
    }

    /**
     * @dev Transfer tokens from one address to another
     *
     * The _from's FFC balance should be larger than the reserved amount(reserves[_from]) plus _value.
     *
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[_from].sub(reserves[_from]));
        return super.transferFrom(_from, _to, _value);
    }

    function getOwner() public view onlyAdminOrOwnerOrVault returns (address) {
        return owner;
    }

    function getVault() public view onlyAdminOrOwnerOrVault returns (address) {
        return vault;
    }

    function getAdmin() public view onlyAdminOrOwnerOrVault returns (address) {
        return admin;
    }

    function getOneFreeFeeCoin() public view returns (uint) {
        return (10 ** uint(decimals));
    }

    function getMaxNumberOfTokens() public view returns (uint) {
        return noOfTokens;
    }

    /**
     * @dev get the amount of reserved token
     */
    function reserveOf(address _address) public view returns (uint _reserve) {
        return reserves[_address];
    }

    /**
     * @dev get the amount reserved token of the sender
     */
    function reserve() public view returns (uint _reserve) {
        return reserves[msg.sender];
    }
}
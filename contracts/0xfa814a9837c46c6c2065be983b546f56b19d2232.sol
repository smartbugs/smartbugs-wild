pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 * https://github.com/OpenZeppelin/zeppelin-solidity/
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * https://github.com/OpenZeppelin/zeppelin-solidity/
 */
contract Ownable {
  address public owner;                                                     // Operational owner.
  address public masterOwner = 0xe4925C73851490401b858B657F26E62e9aD20F66;  // for ownership transfer segregation of duty, hard coded to wallet account

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
  function transferOwnership(address newOwner) public {
    require(newOwner != address(0));
    require(masterOwner == msg.sender); // only master owner can initiate change to ownership
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}











/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 * https://github.com/OpenZeppelin/zeppelin-solidity/
 */
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

  function cei(uint256 a, uint256 b) internal pure returns (uint256) {
    return ((a + b - 1) / b) * b;
  }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}





/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 * https://github.com/OpenZeppelin/zeppelin-solidity/
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/** This interfaces will be implemented by different VZT contracts in future*/
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract VZToken is StandardToken, Ownable {


    /* metadata */

    string public constant name = "VectorZilla Token"; // solium-disable-line uppercase
    string public constant symbol = "VZT"; // solium-disable-line uppercase
    string public constant version = "1.0"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase

    /* all accounts in wei */

    uint256 public constant INITIAL_SUPPLY = 100000000 * 10 ** 18; //intial total supply
    uint256 public constant BURNABLE_UP_TO =  90000000 * 10 ** 18; //burnable up to 90% (90 million) of total supply
    uint256 public constant VECTORZILLA_RESERVE_VZT = 25000000 * 10 ** 18; //25 million - reserved tokens

    // Reserved tokens will be sent to this address. this address will be replaced on production:
    address public constant VECTORZILLA_RESERVE = 0xF63e65c57024886cCa65985ca6E2FB38df95dA11;

    // - tokenSaleContract receives the whole balance for distribution
    address public tokenSaleContract;

    /* Following stuff is to manage regulatory hurdles on who can and cannot use VZT token  */
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);


    /** Modifiers to be used all over the place **/

    modifier onlyOwnerAndContract() {
        require(msg.sender == owner || msg.sender == tokenSaleContract);
        _;
    }


    modifier onlyWhenValidAddress( address _addr ) {
        require(_addr != address(0x0));
        _;
    }

    modifier onlyWhenValidContractAddress(address _addr) {
        require(_addr != address(0x0));
        require(_addr != address(this));
        require(isContract(_addr));
        _;
    }

    modifier onlyWhenBurnable(uint256 _value) {
        require(totalSupply - _value >= INITIAL_SUPPLY - BURNABLE_UP_TO);
        _;
    }

    modifier onlyWhenNotFrozen(address _addr) {
        require(!frozenAccount[_addr]);
        _;
    }

    /** End of Modifier Definations */

    /** Events */

    event Burn(address indexed burner, uint256 value);
    event Finalized();
    //log event whenever withdrawal from this contract address happens
    event Withdraw(address indexed from, address indexed to, uint256 value);

    /*
        Contructor that distributes initial supply between
        owner and vzt reserve.
    */
    function VZToken(address _owner) public {
        require(_owner != address(0));
        totalSupply = INITIAL_SUPPLY;
        balances[_owner] = INITIAL_SUPPLY - VECTORZILLA_RESERVE_VZT; //75 millions tokens
        balances[VECTORZILLA_RESERVE] = VECTORZILLA_RESERVE_VZT; //25 millions
        owner = _owner;
    }

    /*
        This unnamed function is called whenever the owner send Ether to fund the gas
        fees and gas reimbursement.
    */
    function () payable public onlyOwner {}

    /**
     * @dev transfer `_value` token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) 
        public
        onlyWhenValidAddress(_to)
        onlyWhenNotFrozen(msg.sender)
        onlyWhenNotFrozen(_to)
        returns(bool) {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer `_value` tokens from one address (`_from`) to another (`_to`)
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) 
        public
        onlyWhenValidAddress(_to)
        onlyWhenValidAddress(_from)
        onlyWhenNotFrozen(_from)
        onlyWhenNotFrozen(_to)
        returns(bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Burns a specific (`_value`) amount of tokens.
     * @param _value uint256 The amount of token to be burned.
     */
    function burn(uint256 _value)
        public
        onlyWhenBurnable(_value)
        onlyWhenNotFrozen(msg.sender)
        returns (bool) {
        require(_value <= balances[msg.sender]);
      // no need to require value <= totalSupply, since that would imply the
      // sender's balance is greater than the totalSupply, which *should* be an assertion failure
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
        Transfer(burner, address(0x0), _value);
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
    function burnFrom(address _from, uint256 _value) 
        public
        onlyWhenBurnable(_value)
        onlyWhenNotFrozen(_from)
        onlyWhenNotFrozen(msg.sender)
        returns (bool success) {
        assert(transferFrom( _from, msg.sender, _value ));
        return burn(_value);
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        onlyWhenValidAddress(_spender)
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Freezes account and disables transfers/burning
     *  This is to manage regulatory hurdlers where contract owner is required to freeze some accounts.
     */
    function freezeAccount(address target, bool freeze) external onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    /* Owner withdrawal of an ether deposited from Token ether balance */
    function withdrawToOwner(uint256 weiAmt) public onlyOwner {
        // do not allow zero transfer
        require(weiAmt > 0);
        owner.transfer(weiAmt);
        // signal the event for communication only it is meaningful
        Withdraw(this, msg.sender, weiAmt);
    }


    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) external onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
        StandardToken token = StandardToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);
        // signal the event for communication only it is meaningful
        Withdraw(this, owner, balance);
    }

    function setTokenSaleContract(address _tokenSaleContract)
        external
        onlyWhenValidContractAddress(_tokenSaleContract)
        onlyOwner {
           require(_tokenSaleContract != tokenSaleContract);
           tokenSaleContract = _tokenSaleContract;
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr address The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns(bool) {
        if (_addr == 0) {
            return false;
        }
        uint256 size;
        assembly {
            size: = extcodesize(_addr)
        }
        return (size > 0);
    }

    /**
     * @dev Function to send `_value` tokens to user (`_to`) from sale contract/owner
     * @param _to address The address that will receive the minted tokens.
     * @param _value uint256 The amount of tokens to be sent.
     * @return True if the operation was successful.
     */
    function sendToken(address _to, uint256 _value)
        public
        onlyWhenValidAddress(_to)
        onlyOwnerAndContract
        returns(bool) {
        address _from = owner;
        // Check if the sender has enough
        require(balances[_from] >= _value);
        // Check for overflows
        require(balances[_to] + _value > balances[_to]);
        // Save this for an assertion in the future
        uint256 previousBalances = balances[_from] + balances[_to];
        // Subtract from the sender
        balances[_from] -= _value;
        // Add the same to the recipient
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[_from] + balances[_to] == previousBalances);
        return true;
    }
    /**
     * @dev Batch transfer of tokens to addresses from owner's balance
     * @param addresses address[] The address that will receive the minted tokens.
     * @param _values uint256[] The amount of tokens to be sent.
     * @return True if the operation was successful.
     */
    function batchSendTokens(address[] addresses, uint256[] _values) 
        public onlyOwnerAndContract
        returns (bool) {
        require(addresses.length == _values.length);
        require(addresses.length <= 20); //only batches of 20 allowed
        uint i = 0;
        uint len = addresses.length;
        for (;i < len; i++) {
            sendToken(addresses[i], _values[i]);
        }
        return true;
    }
}
pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    
  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
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
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract Role is StandardToken {
    using SafeMath for uint256;

    address public owner;
    address public admin;

    uint256 public contractDeployed = now;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event AdminshipTransferred(
        address indexed previousAdmin,
        address indexed newAdmin
    );

	  /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }   

    /**
    * @dev Throws if called by any account other than the admin.
    */
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) external  onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Allows the current admin to transfer control of the contract to a newAdmin.
    * @param _newAdmin The address to transfer adminship to.
    */
    function transferAdminship(address _newAdmin) external onlyAdmin {
        _transferAdminship(_newAdmin);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        balances[owner] = balances[owner].sub(balances[owner]);
        balances[_newOwner] = balances[_newOwner].add(balances[owner]);
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newAdmin.
    * @param _newAdmin The address to transfer adminship to.
    */
    function _transferAdminship(address _newAdmin) internal {
        require(_newAdmin != address(0));
        emit AdminshipTransferred(admin, _newAdmin);
        admin = _newAdmin;
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Role {
  event Pause();
  event Unpause();
  event NotPausable();

  bool public paused = false;
  bool public canPause = true;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused || msg.sender == owner);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
     * @dev called by the owner to pause, triggers stopped state
     **/
    function pause() onlyOwner whenNotPaused public {
        require(canPause == true);
        paused = true;
        emit Pause();
    }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    require(paused == true);
    paused = false;
    emit Unpause();
  }
  
  /**
     * @dev Prevent the token from ever being paused again
     **/
    function notPausable() onlyOwner public{
        paused = false;
        canPause = false;
        emit NotPausable();
    }
}

contract SamToken is Pausable {
  using SafeMath for uint;
 
    uint256 _lockedTokens;
    bool isLocked = true ;
    bool releasedForOwner ;
    uint256 public ownerPercent = 10;
    uint256 public ownerSupply;
    uint256 public adminPercent = 90;
    uint256 public adminSupply ;
    
     //The name of the  token
    string public constant name = "SAM Token";
    //The token symbol
    string public constant symbol = "SAM";
    //The precision used in the balance calculations in contract
    uint public constant decimals = 0;

  event Burn(address indexed burner, uint256 value);
  event CompanyTokenReleased( address indexed _company, uint256 indexed _tokens );

  constructor(
        address _owner, 
        address _admin,        
        uint256 _totalsupply
        ) public {
    owner = _owner;
    admin = _admin;

    _totalsupply = _totalsupply ;
    totalSupply_ = totalSupply_.add(_totalsupply);
       
    adminSupply = 900000000 ;  
    ownerSupply = 100000000 ;

    _lockedTokens = _lockedTokens.add(ownerSupply);
    balances[admin] = balances[admin].add(adminSupply);
     isLocked = true;
    emit Transfer(address(0), admin, adminSupply );
    
  }

  modifier onlyPayloadSize(uint numWords) {
    assert(msg.data.length >= numWords * 32 + 4);
    _;
  }

 /**
  * @dev Locked number of tokens in existence
  */
    function lockedTokens() public view returns (uint256) {
      return _lockedTokens;
    }

 /**
  * @dev function to check whether passed address is a contract address
  */
    function isContract(address _address) private view returns (bool is_contract) {
      uint256 length;
      assembly {
      //retrieve the size of the code on target address, this needs assembly
        length := extcodesize(_address)
      }
      return (length > 0);
    }

/**
* @dev Burns a specific amount of tokens.
* @param _value The amount of token to be burned.
*/
function burn(uint _value) public returns (bool success) {
    require(balances[msg.sender] >= _value);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(msg.sender, _value);
    return true;
}

/**
* @dev Burns a specific amount of tokens from the target address and decrements allowance
* @param from address The address which you want to send tokens from
* @param _value uint256 The amount of token to be burned
*/
function burnFrom(address from, uint _value) public returns (bool success) {
    require(balances[from] >= _value);
    require(_value <= allowed[from][msg.sender]);
    balances[from] = balances[from].sub(_value);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(from, _value);
    return true;
}

function () public payable {
    revert();
}

/**
* @dev Function to transfer any ERC20 token  to owner address which gets accidentally transferred to this contract
* @param tokenAddress The address of the ERC20 contract
* @param tokens The amount of tokens to transfer.
* @return A boolean that indicates if the operation was successful.
*/
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    require(tokenAddress != address(0));
    require(isContract(tokenAddress));
    return ERC20(tokenAddress).transfer(owner, tokens);
}

// Transfer token to team 
function companyTokensRelease(address _company) external onlyAdmin returns(bool) {
   require(_company != address(0), "Address is not valid");
   require(!releasedForOwner, "Team release has already done");
    if (now > contractDeployed.add(365 days) && releasedForOwner == false ) {          
          balances[_company] = balances[_company].add(_lockedTokens);
          isLocked = false;
          releasedForOwner = true;
          emit CompanyTokenReleased(_company, _lockedTokens);
          return true;
        }
    }

}
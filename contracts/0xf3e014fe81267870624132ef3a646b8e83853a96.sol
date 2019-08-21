pragma solidity 0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Contactable token
 * @dev Basic version of a contactable contract, allowing the owner to provide a string with their
 * contact information.
 */
contract Contactable is Ownable{

    string public contactInformation;

    /**
     * @dev Allows the owner to set a string with their contact information.
     * @param info The contact information to attach to the contract.
     */
    function setContactInformation(string info) onlyOwner public {
         contactInformation = info;
     }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LockableToken is ERC20 {
    function addToTimeLockedList(address addr) external returns (bool);
}

contract VinToken is Contactable {
    using SafeMath for uint;

    string constant public name = "VIN";
    string constant public symbol = "VIN";
    uint constant public decimals = 18;
    uint constant public totalSupply = (10 ** 9) * (10 ** decimals); // 1 000 000 000 VIN
    uint constant public lockPeriod1 = 2 years;
    uint constant public lockPeriod2 = 24 weeks;
    uint constant public lockPeriodForBuyers = 12 weeks;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    bool public isActivated = false;
    mapping (address => bool) public whitelistedBeforeActivation;
    mapping (address => bool) public isPresaleBuyer;
    address public saleAddress;
    address public founder1Address;
    address public founder2Address;
    uint public icoEndTime;
    uint public icoStartTime;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function VinToken(
        address _founder1Address,
        address _founder2Address,
        uint _icoStartTime,
        uint _icoEndTime
        ) public 
    {
        require(_founder1Address != 0x0);
        require(_founder2Address != 0x0);
        require(_icoEndTime > _icoStartTime);
        founder1Address = _founder1Address;
        founder2Address = _founder2Address;
        icoStartTime = _icoStartTime;
        icoEndTime = _icoEndTime;
        balances[owner] = totalSupply;
        whitelistedBeforeActivation[owner] = true;
    }

    modifier whenActivated() {
        require(isActivated || whitelistedBeforeActivation[msg.sender]);
        _;
    }
    
    modifier isLockTimeEnded(address from){
        if (from == founder1Address) {
            require(now > icoEndTime + lockPeriod1);
        } else if (from == founder2Address) {
            require(now > icoEndTime + lockPeriod2);
        } else if (isPresaleBuyer[from]) {
            require(now > icoEndTime + lockPeriodForBuyers);
        }
        _;
    }

    modifier onlySaleConract(){
        require(msg.sender == saleAddress);
        _;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) external isLockTimeEnded(msg.sender) whenActivated returns (bool) {
        require(_to != 0x0);
    
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) external constant returns (uint balance) {
        return balances[_owner];
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
    function approve(address _spender, uint _value) external whenActivated returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) external constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint _value) external isLockTimeEnded(_from) whenActivated returns (bool) {
        require(_to != 0x0);
        uint _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        // _allowance.sub(_value) will throw if _value > _allowance
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);

        return true;
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) external whenActivated returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) external whenActivated returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * Activation of the token allows all tokenholders to operate with the token
     */
    function activate() external onlyOwner returns (bool) {
        isActivated = true;
        return true;
    }

    /**
     * allows to add and exclude addresses from whitelistedBeforeActivation list for owner
     * @param isWhitelisted is true for adding address into whitelist, false - to exclude
     */
    function editWhitelist(address _address, bool isWhitelisted) external onlyOwner returns (bool) {
        whitelistedBeforeActivation[_address] = isWhitelisted;
        return true;        
    }

    function addToTimeLockedList(address addr) external onlySaleConract returns (bool) {
        require(addr != 0x0);
        isPresaleBuyer[addr] = true;
        return true;
    }

    function setSaleAddress(address newSaleAddress) external onlyOwner returns (bool) {
        require(newSaleAddress != 0x0);
        saleAddress = newSaleAddress;
        return true;
    }

    function setIcoEndTime(uint newTime) external onlyOwner returns (bool) {
        require(newTime > icoStartTime);
        icoEndTime = newTime;
        return true;
    }
}
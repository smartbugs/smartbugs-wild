pragma solidity ^0.4.16;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
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
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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
}

contract Admin {
  address public admin1;
  address public admin2;

  event AdminshipTransferred(address indexed previousAdmin, address indexed newAdmin);

  function Admin() public {
    admin1 = 0xD384CfA70Db590eab32f3C262B84C1E10f27EDa8;
    admin2 = 0x263003A4CC5358aCebBad7E30C60167307dF1ccB;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin1 || msg.sender == admin2);
    _;
  }

  function transferAdminship1(address newAdmin) public onlyAdmin {
    require(newAdmin != address(0));
    AdminshipTransferred(admin1, newAdmin);
    admin1 = newAdmin;
  }
  function transferAdminship2(address newAdmin) public onlyAdmin {
    require(newAdmin != address(0));
    AdminshipTransferred(admin2, newAdmin);
    admin2 = newAdmin;
  }  
}

contract FilterAddress is Admin{
  mapping (address => uint) public AccessAddress;
    
  function SetAccess(address addr, uint access) onlyAdmin public{
    AccessAddress[addr] = access;
  }
    
  function GetAccess(address addr) public constant returns(uint){
    return  AccessAddress[addr];
  }
    
  modifier checkFilterAddress(){
    require(AccessAddress[msg.sender] != 1);
    _;
  }
}

contract Rewards is Admin{
  using SafeMath for uint256;
  uint public CoefRew;
  uint public SummRew;
  address public RewAddr;
  
  function SetCoefRew(uint newCoefRew) public onlyAdmin{
    CoefRew = newCoefRew;
  }
  
  function SetSummRew(uint newSummRew) public onlyAdmin{
    SummRew = newSummRew;
  }    
  
  function SetRewAddr(address newRewAddr) public onlyAdmin{
    RewAddr = newRewAddr;
  } 
  
  function GetSummReward(uint _value) public constant returns(uint){
    return _value.mul(CoefRew).div(100).div(1000); 
  }
}

contract Fees is Admin{
  using SafeMath for uint256;
  uint public Fee;
  address public FeeAddr1;
  address public FeeAddr2;
    
  function SetFee(uint newFee) public onlyAdmin{
    Fee = newFee;
  }
  function GetSummFee(uint _value) public constant returns(uint){
    return _value.mul(Fee).div(100).div(1000).div(3);
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

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, FilterAddress, Fees, Rewards, Ownable {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  mapping(address => uint256) allSummReward;
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) checkFilterAddress public returns (bool) {
    uint256 _valueto;
    uint fSummFee;
    uint fSummReward;
    require(_to != address(0));
    require(_to != msg.sender);
    require(_value <= balances[msg.sender]);
    //fees
    _valueto = _value;
    if (msg.sender != owner){  
      fSummFee = GetSummFee(_value);
      fSummReward = GetSummReward(_value);
        
      balances[msg.sender] = balances[msg.sender].sub(fSummFee);
      balances[FeeAddr1] = balances[FeeAddr1].add(fSummFee);
      _valueto = _valueto.sub(fSummFee);  

      balances[msg.sender] = balances[msg.sender].sub(fSummFee);
      balances[FeeAddr2] = balances[FeeAddr2].add(fSummFee);
      _valueto = _valueto.sub(fSummFee); 
    
      balances[msg.sender] = balances[msg.sender].sub(fSummFee);
      balances[RewAddr] = balances[RewAddr].add(fSummFee);
      _valueto = _valueto.sub(fSummFee); 
    //Rewards
      allSummReward[msg.sender] = allSummReward[msg.sender].add(_value);    
      if (allSummReward[msg.sender] >= SummRew && balances[RewAddr] >= fSummReward) {
        balances[RewAddr] = balances[RewAddr].sub(fSummReward);
        balances[msg.sender] = balances[msg.sender].add(fSummReward);
        allSummReward[msg.sender] = 0;
      }
    }

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_valueto);
    balances[_to] = balances[_to].add(_valueto);
    Transfer(msg.sender, _to, _valueto);
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
    uint256 _valueto;  
    require(_to != msg.sender);  
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    uint fSummFee;
    uint fSummReward;
    _valueto = _value;
    if (_from != owner){  
      fSummFee = GetSummFee(_value);
      fSummReward = GetSummReward(_value);
        
      balances[_from] = balances[_from].sub(fSummFee);
      balances[FeeAddr1] = balances[FeeAddr1].add(fSummFee);
      _valueto = _valueto.sub(fSummFee);  

      balances[_from] = balances[_from].sub(fSummFee);
      balances[FeeAddr2] = balances[FeeAddr2].add(fSummFee);
      _valueto = _valueto.sub(fSummFee); 
    
      balances[_from] = balances[_from].sub(fSummFee);
      balances[RewAddr] = balances[RewAddr].add(fSummFee);
      _valueto = _valueto.sub(fSummFee); 
    //Rewards
      allSummReward[_from] = allSummReward[_from].add(_value);
      if (allSummReward[_from] >= SummRew && balances[RewAddr] >= fSummReward) {
        balances[RewAddr] = balances[RewAddr].sub(fSummReward);
        balances[_from] = balances[_from].add(fSummReward);
        allSummReward[_from] = 0;
      }
    }
    balances[_from] = balances[_from].sub(_valueto);
    balances[_to] = balances[_to].add(_valueto);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _valueto);
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

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {
    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
      require(_value <= balances[msg.sender]);
      // no need to require value <= totalSupply, since that would imply the
      // sender's balance is greater than the totalSupply, which *should* be an assertion failure

      address burner = msg.sender;
      balances[burner] = balances[burner].sub(_value);
      totalSupply = totalSupply.sub(_value);
      Burn(burner, _value);
    }
}

contract Guap is Ownable, BurnableToken {
  using SafeMath for uint256;    
  string public constant name = "Guap";
  string public constant symbol = "Guap";
  uint32 public constant decimals = 18;
  uint256 public INITIAL_SUPPLY = 9999999999 * 1 ether;
  function Guap() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    //Rewards
    RewAddr = 0xb94F2E7B4E37a8c03E9C2E451dec09Ce94Be2615;
    CoefRew = 5; // decimals = 3;
    SummRew = 90000 * 1 ether; 
    //Fee
    FeeAddr1 = 0xBe9517d10397D60eAD7da33Ea50A6431F5Be3790;
    FeeAddr2 = 0xC90F698cc5803B21a04cE46eD1754655Bf2215E5;
    Fee  = 15; // decimals = 3; 
  }
}
pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * Math operations with safety checks that throw on error
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

 /**
 * Official T_Token as issued by The T****
 * Based off of Standard ERC20 token
 *
 * Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Partially based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */

contract T_Token_11 {
    
  using SafeMath for uint256;
  
  string public name;
  string public symbol;
  uint256 public decimals;
  
  uint256 public totalSupply;
  
  uint256 private tprFund;
  uint256 private founderCoins;
  uint256 private icoReleaseTokens;
  
  uint256 private tprFundReleaseTime;
  uint256 private founderCoinsReleaseTime;
  
  bool private tprFundUnlocked;
  bool private founderCoinsUnlocked;
  
  address private tprFundDeposit;
  address private founderCoinsDeposit;

  mapping(address => uint256) internal balances;
  
  mapping (address => mapping (address => uint256)) internal allowed;
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Burn(address indexed burner, uint256 value);
  
  function T_Token_11 () public {
      
      name = "T_Token_11";
      symbol = "T_TPR_T11";
      decimals = 18;
      
      tprFund = 260000000 * (10**decimals);
      founderCoins = 30000000 * (10**decimals);
      icoReleaseTokens = 210000000 * (10**decimals);
      
      totalSupply = tprFund + founderCoins + icoReleaseTokens;
      
      balances[msg.sender] = icoReleaseTokens;
      
      tprFundDeposit = 0xF1F465C345b6DBc4Bcdf98aB286762ba282BA69a; //TPR Fund
      balances[tprFundDeposit] = 0;
      tprFundReleaseTime = 30 * 1 minutes; // TPR Fund to be available after 6 months
      tprFundUnlocked = false;
      
      founderCoinsDeposit = 0x64108822C128D11b6956754056ec4bCBe0B0CDaf; // Founders Coins
      balances[founderCoinsDeposit] = 0;
      founderCoinsReleaseTime = 60 * 1 minutes; // Founders coins to be unlocked after 1 year
      founderCoinsUnlocked = false;
  } 
  
  
  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
   
  function releaseTprFund() public {
    require(now >= tprFundReleaseTime);
    require(!tprFundUnlocked);

    balances[tprFundDeposit] = tprFund;
    
    Transfer(0, tprFundDeposit, tprFund);

    tprFundUnlocked = true;
    
  }
  
  function releaseFounderCoins() public {
    require(now >= founderCoinsReleaseTime);
    require(!founderCoinsUnlocked);

    balances[founderCoinsDeposit] = founderCoins;
    
    Transfer(0, founderCoinsDeposit, founderCoins);
    
    founderCoinsUnlocked = true;
    
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(_value > 0);

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
    require(_value > 0);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    require(_value>0);
    require(balances[msg.sender]>_value);
    allowed[msg.sender][_spender] = 0;
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
     * Burns a specific amount of tokens.
     * @param _value The amount of tokens to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

}
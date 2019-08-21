// Tipper Inc.
// Official Token
// Tipper: The Social Economy

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
 * This official token of Tipper Inc. is based off of the Standard ERC20 token
 * implementation of the basic standard token.
 * 
 * https://github.com/ethereum/EIPs/issues/20
 * 
 * Partially based on ideas and code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 * and code found at OpenZeppelin.org
 */

contract TipperToken {
    
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
  
  function TipperToken () public {
      
      name = "Tipper";
      symbol = "TIPR";
      decimals = 18;
      
      tprFund = 420000000 * (10**decimals); // Reserved for TIPR User Fund and Tipper Inc. use
      founderCoins = 70000000 * (10**decimals); // Founder Coins
      icoReleaseTokens = 210000000 * (10**decimals); // Tokens to be released for ICO
      
      totalSupply = tprFund + founderCoins + icoReleaseTokens; // Total Supply of TIPR = 700,000,000
      
      balances[msg.sender] = icoReleaseTokens;
      
      Transfer(0, msg.sender, icoReleaseTokens);
      
      tprFundDeposit = 0x443174D48b39a18Aae6d7FfCa5c7712B6E94496b; // Deposit address for TIPR User Fund
      balances[tprFundDeposit] = 0;
      tprFundReleaseTime = 129600 * 1 minutes; // TIPR User Fund to be available after 3 months
      
      tprFundUnlocked = false;
      
      founderCoinsDeposit = 0x703D1d5DFf7D6079f44D6C56a2E455DaC7f2D8e6; // Deposit address for founders coins
      balances[founderCoinsDeposit] = 0;
      founderCoinsReleaseTime = 525600 * 1 minutes; // Founders coins to be unlocked after 1 year
      founderCoinsUnlocked = false;
  } 
  
  
  /**
   * Transfers tokens held by the timelock to the specified address.
   * This function releases the TIPR User Fund for Tipper Inc. use
   * after 3 months.
   */
   
  function releaseTprFund() public {
    require(now >= tprFundReleaseTime); // Check that 3 months have passed
    require(!tprFundUnlocked); // Check that the fund has not been released yet

    balances[tprFundDeposit] = tprFund; // Assign the funds to the specified account
    
    Transfer(0, tprFundDeposit, tprFund); // Log the transfer on the blockchain

    tprFundUnlocked = true; 
    
  }
  
    
  /**
   * Transfers tokens held by the timelock to the specified address.
   * This function releases the founders coins after 1 year.
   */
  
  function releaseFounderCoins() public {
    require(now >= founderCoinsReleaseTime); // Check that 1 year has passed
    require(!founderCoinsUnlocked); // Check that the coins have not been released yet

    balances[founderCoinsDeposit] = founderCoins; // Assign the coins to the founders accounts
    
    Transfer(0, founderCoinsDeposit, founderCoins); // Log the transfer on the blockchain
    
    founderCoinsUnlocked = true;
  }

  /**
  * @dev transfer tokens to a specified address
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
  * @param _owner The address to query the balance of.
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
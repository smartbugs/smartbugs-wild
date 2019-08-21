pragma solidity ^0.4.13;

// File: contracts\zeppelin\ownership\Ownable.sol

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

// File: contracts\zeppelin\math\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal  returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal  returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal  returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal  returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts\zeppelin\token\ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public  returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\zeppelin\token\BasicToken.sol

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
  function balanceOf(address _owner) public  returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: contracts\zeppelin\token\ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public  returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\zeppelin\token\StandardToken.sol

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
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    return BasicToken.transfer(_to, _value);
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
  function allowance(address _owner, address _spender) public  returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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

// File: contracts\zeppelin\token\MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

// File: contracts\zeppelin\token\CappedToken.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */

contract CappedToken is MintableToken {

  uint256 public cap;

  function CappedToken(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

// File: contracts\zeppelin\lifecycle\Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
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
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

// File: contracts\zeppelin\token\PausableToken.sol

/**
 * @title Pausable token
 *
 * @dev StandardToken modified with pausable transfers.
 **/

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: contracts\BlockportToken.sol

/// @title Blockport Token - Token code for our Blockport.nl Project
/// @author Jan Bolhuis, Wesley van Heije
//  Version 3, december 2017
//  This version is completely based on the Openzeppelin Solidity framework.
//
//  There will be a presale cap of 6.400.000 BPT Tokens
//  Minimum presale investment in Ether will be set at the start in the Presale contract; calculated on a weekly avarage for an amount of ~ 1000 Euro
//  Unsold presale tokens will be burnt, implemented as mintbale token as such that only sold tokens are minted.
//  Presale rate has a 33% bonus to the crowdsale to compensate the extra risk
//  The total supply of tokens (pre-sale + crowdsale) will be 49,600,000 BPT
//  Minimum crowdsale investment will be 0.1 ether
//  Mac cap for the crowdsale is 43,200,000 BPT
//  There is no bonus scheme for the crowdsale
//  Unsold Crowsdale tokens will be burnt, implemented as mintbale token as such that only sold tokens are minted.
//  On the amount tokens sold an additional 40% will be minted; this will be allocated to the Blockport company(20%) and the Blockport team(20%)
//  BPT tokens will be tradable straigt after the finalization of the crowdsale. This is implemented by being a pausable token that is unpaused at Crowdsale finalisation.


contract BlockportToken is CappedToken, PausableToken {

    string public constant name                 = "Blockport Token";
    string public constant symbol               = "BPT";
    uint public constant decimals               = 18;

    function BlockportToken(uint256 _totalSupply) 
        CappedToken(_totalSupply) public {
            paused = true;
    }
}

// File: contracts\CrowdsaleWhitelist.sol

contract CrowdsaleWhitelist is Ownable {
    
    mapping(address => bool) allowedAddresses;
    uint count = 0;
    
    modifier whitelisted() {
        require(allowedAddresses[msg.sender] == true);
        _;
    }

    function addToWhitelist(address[] _addresses) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            if (allowedAddresses[_addresses[i]]) { 
                continue;
            }

            allowedAddresses[_addresses[i]] = true;
            count++;
        }

        WhitelistUpdated(block.timestamp, "Added", count);  
    }

    function removeFromWhitelist(address[] _addresses) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            if (!allowedAddresses[_addresses[i]]) { 
                continue;
            }

            allowedAddresses[_addresses[i]] = false;
            count--;
        }
        
        WhitelistUpdated(block.timestamp, "Removed", count);        
    }
    
    function isWhitelisted() public whitelisted constant returns (bool) {
        return true;
    }

    function addressIsWhitelisted(address _address) public constant returns (bool) {
        return allowedAddresses[_address];
    }

    function getAddressCount() public constant returns (uint) {
        return count;
    }

    event WhitelistUpdated(uint timestamp, string operation, uint totalAddresses);
}

// File: contracts\zeppelin\crowdsale\Crowdsale.sol

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal  returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has started
  function hasStarted() public constant returns (bool) {
    return now >= startTime;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

  // @return current timestamp
  function currentTime() public constant returns(uint256) { 
    return now;
  }
}

// File: contracts\zeppelin\crowdsale\CappedCrowdsale.sol

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal  returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

// File: contracts\zeppelin\crowdsale\FinalizableCrowdsale.sol

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);

    finalization();
    Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}

// File: contracts\BlockportCrowdsale.sol

/// @title Blockport Token - Token code for our Blockport.nl Project
/// @author Jan Bolhuis, Wesley van Heije
//  Version 3, January 2018
//  Based on Openzeppelin framework
//
//  The Crowdsale will start after the presale which had a cap of 6.400.000 BPT Tokens
//  Minimum presale investment in Ether will be set at the start; calculated on a weekly avarage for an amount of ~ 1000 Euro
//  Unsold presale tokens will be burnt. Implemented by using MintedToken.
//  There is no bonus in the Crowdsale.
//  The total supply of tokens (pre-sale + crowdsale) will be 49,600,000 BPT
//  Minimum crowdsale investment will be 0.1 ether
//  Mac cap for the crowdsale is 43,200,000 BPT
// 
//  
contract BlockportCrowdsale is CappedCrowdsale, FinalizableCrowdsale, CrowdsaleWhitelist, Pausable {
    using SafeMath for uint256;

    address public tokenAddress;
    address public teamVault;
    address public companyVault;
    uint256 public minimalInvestmentInWei = 0.1 ether;
    uint256 public maxInvestmentInWei = 50 ether;
    
    mapping (address => uint256) internal invested;

    BlockportToken public bpToken;

    // Events for this contract
    event InitialRateChange(uint256 rate, uint256 cap);
    event InitialDateChange(uint256 startTime, uint256 endTime);

    // Initialise contract with parapametrs
    //@notice Function to initialise the token with configurable parameters. 
    //@param ` _cap - max number ot tokens available for the presale
    //@param ` _goal - goal can be set, below this value the Crowdsale becomes refundable
    //@param ' _startTime - this is the place to adapt the presale period
    //@param ` _endTime - this is the place to adapt the presale period
    //@param ` rate - initial presale rate.
    //@param ` _wallet - Multisig wallet the investments are being send to during presale
    //@param ` _tokenAddress - Token to be used, created outside the prsale contract  
    //@param ` _teamVault - Ether send to this contract will be stored  at this multisig wallet
    function BlockportCrowdsale(uint256 _cap, uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _tokenAddress, address _teamVault, address _companyVault) 
        CappedCrowdsale(_cap)
        Crowdsale(_startTime, _endTime, _rate, _wallet) public {
            require(_tokenAddress != address(0));
            require(_teamVault != address(0));
            require(_companyVault != address(0));
            
            tokenAddress = _tokenAddress;
            token = createTokenContract();
            teamVault = _teamVault;
            companyVault = _companyVault;
    }

    //@notice Function to cast the Capped (&mintable) token provided with the constructor to a blockporttoken that is mintabletoken.
    // This is a workaround to surpass an issue that Mintabletoken functions are not accessible in this contract.
    // We did not want to change the Openzeppelin code and we did not have the time for an extensive drill down.
    function createTokenContract() internal returns (MintableToken) {
        bpToken = BlockportToken(tokenAddress);
        return BlockportToken(tokenAddress);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        invested[msg.sender] += msg.value;
        super.buyTokens(beneficiary);
    }

    // overriding Crowdsale#validPurchase to add extra cap logic
    // @return true if investors can buy at the moment
    function validPurchase() internal returns (bool) {
        bool moreThanMinimalInvestment = msg.value >= minimalInvestmentInWei;
        bool whitelisted = addressIsWhitelisted(msg.sender);
        bool lessThanMaxInvestment = invested[msg.sender] <= maxInvestmentInWei;

        return super.validPurchase() && moreThanMinimalInvestment && lessThanMaxInvestment && !paused && whitelisted;
    }

    //@notice Function overidden function will finanalise the Crowdsale
    // Additional tokens are allocated to the team and to the company, adding 40% in total to tokens already sold. 
    // After calling this function the blockporttoken gan be tranfered / traded by the holders of this token.
    function finalization() internal {
        uint256 totalSupply = token.totalSupply();
        uint256 twentyPercentAllocation = totalSupply.div(5);

        // mint tokens for the foundation
        token.mint(teamVault, twentyPercentAllocation);
        token.mint(companyVault, twentyPercentAllocation);

        token.finishMinting();              // No more tokens can be added from now
        bpToken.unpause();                  // ERC20 transfer functions will work after this so trading can start.
        super.finalization();               // finalise up in the tree
        
        bpToken.transferOwnership(owner);   // transfer token Ownership back to original owner
    }

    //@notice Function sets the token conversion rate in this contract
    //@param ` __rateInWei - Price of 1 Blockport token in Wei. 
    //@param ` __capInWei - Price of 1 Blockport token in Wei. 
    function setRate(uint256 _rateInWei, uint256 _capInWei) public onlyOwner returns (bool) { 
        require(startTime > block.timestamp);
        require(_rateInWei > 0);
        require(_capInWei > 0);

        rate = _rateInWei;
        cap = _capInWei;

        InitialRateChange(rate, cap);
        return true;
    }

    //@notice Function sets start and end date/time for this Crowdsale. Can be called multiple times
    //@param ' _startTime - this is the place to adapt the presale period
    //@param ` _endTime - this is the place to adapt the presale period
    function setCrowdsaleDates(uint256 _startTime, uint256 _endTime) public onlyOwner returns (bool) { 
        require(startTime > block.timestamp); // current startTime in the future
        require(_startTime >= now);
        require(_endTime >= _startTime);

        startTime = _startTime;
        endTime = _endTime;

        InitialDateChange(startTime, endTime);
        return true;
    }

    //@notice Function sets the token owner to contract owner
    function resetTokenOwnership() onlyOwner public { 
        bpToken.transferOwnership(owner);
    }

}
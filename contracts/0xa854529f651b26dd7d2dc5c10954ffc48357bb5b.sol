pragma solidity ^0.4.18;

// File: contracts/IPricingStrategy.sol

interface IPricingStrategy {

    function isPricingStrategy() public view returns (bool);

    /** Calculate the current price for buy in amount. */
    function calculateTokenAmount(uint weiAmount, uint tokensSold) public view returns (uint tokenAmount);

}

// File: contracts/token/ERC223.sol

contract ERC223 {
    function transfer(address _to, uint _value, bytes _data) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/ownership/Contactable.sol

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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/ERC20.sol

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

// File: contracts/token/MintableToken.sol

contract MintableToken is ERC20, Contactable {
    using SafeMath for uint;

    mapping (address => uint) balances;
    mapping (address => uint) public holderGroup;
    bool public mintingFinished = false;
    address public minter;

    event MinterChanged(address indexed previousMinter, address indexed newMinter);
    event Mint(address indexed to, uint amount);
    event MintFinished();

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier onlyMinter() {
        require(msg.sender == minter);
        _;
    }

      /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint _amount, uint _holderGroup) onlyMinter canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        holderGroup[_to] = _holderGroup;
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyMinter canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

    function changeMinter(address _minter) external onlyOwner {
        require(_minter != 0x0);
        MinterChanged(minter, _minter);
        minter = _minter;
    }
}

// File: contracts/token/TokenReciever.sol

/*
 * Contract that is working with ERC223 tokens
 */
 
 contract TokenReciever {
    function tokenFallback(address _from, uint _value, bytes _data) public pure {
    }
}

// File: contracts/token/HeroCoin.sol

contract HeroCoin is ERC223, MintableToken {
    using SafeMath for uint;

    string constant public name = "HeroCoin";
    string constant public symbol = "HRO";
    uint constant public decimals = 18;

    mapping(address => mapping (address => uint)) internal allowed;

    mapping (uint => uint) public activationTime;

    modifier activeForHolder(address holder) {
        uint group = holderGroup[holder];
        require(activationTime[group] <= now);
        _;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public returns (bool) {
        bytes memory empty;
        return transfer(_to, _value, empty);
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    * @param _data Optional metadata.
    */
    function transfer(address _to, uint _value, bytes _data) public activeForHolder(msg.sender) returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        if (isContract(_to)) {
            TokenReciever receiver = TokenReciever(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }

        Transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint _value) activeForHolder(_from) public returns (bool) {
        bytes memory empty;
        return transferFrom(_from, _to, _value, empty);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amount of tokens to be transferred
     * @param _data Optional metadata.
     */
    function transferFrom(address _from, address _to, uint _value, bytes _data) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        if (isContract(_to)) {
            TokenReciever receiver = TokenReciever(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }

        Transfer(_from, _to, _value);
        Transfer(_from, _to, _value, _data);
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
    function approve(address _spender, uint _value) public returns (bool) {
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
    function allowance(address _owner, address _spender) public view returns (uint) {
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

    function setActivationTime(uint _holderGroup, uint _activationTime) external onlyOwner {
        activationTime[_holderGroup] = _activationTime;
    }

    function setHolderGroup(address _holder, uint _holderGroup) external onlyOwner {
        holderGroup[_holder] = _holderGroup;
    }

    function isContract(address _addr) private view returns (bool) {
        uint length;
        assembly {
              //retrieve the size of the code on target address, this needs assembly
              length := extcodesize(_addr)
        }
        return (length>0);
    }
}

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: contracts/SaleBase.sol

contract SaleBase is Pausable, Contactable {
    using SafeMath for uint;
  
    // The token being sold
    HeroCoin public token;
  
    // start and end timestamps where purchases are allowed (both inclusive)
    uint public startTime;
    uint public endTime;
  
    // address where funds are collected
    address public wallet;
  
    // the contract, which determine how many token units a buyer gets per wei
    IPricingStrategy public pricingStrategy;
  
    // amount of raised money in wei
    uint public weiRaised;

    // amount of tokens that was sold on the crowdsale
    uint public tokensSold;

    // maximum amount of wei in total, that can be bought
    uint public weiMaximumGoal;

    // if weiMinimumGoal will not be reached till endTime, buyers will be able to refund ETH
    uint public weiMinimumGoal;

    // minimum amount of wel, that can be contributed
    uint public weiMinimumAmount;

    // How many distinct addresses have bought
    uint public buyerCount;

    // how much wei we have returned back to the contract after a failed crowdfund
    uint public loadedRefund;

    // how much wei we have given back to buyers
    uint public weiRefunded;

    // how much ETH each address has bought to this crowdsale
    mapping (address => uint) public boughtAmountOf;

    // holder group of sale buyers, must be defined in child contract
    function holderGroupNumber() pure returns (uint) {
        return 0;
    }

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param tokenAmount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint value,
        uint tokenAmount
    );

    // a refund was processed for an buyer
    event Refund(address buyer, uint weiAmount);

    function SaleBase(
        uint _startTime,
        uint _endTime,
        IPricingStrategy _pricingStrategy,
        HeroCoin _token,
        address _wallet,
        uint _weiMaximumGoal,
        uint _weiMinimumGoal,
        uint _weiMinimumAmount
    ) public
    {
        require(_pricingStrategy.isPricingStrategy());
        require(address(_token) != 0x0);
        require(_wallet != 0x0);
        require(_weiMaximumGoal > 0);

        setStartTime(_startTime);
        setEndTime(_endTime);
        pricingStrategy = _pricingStrategy;
        token = _token;
        wallet = _wallet;
        weiMaximumGoal = _weiMaximumGoal;
        weiMinimumGoal = _weiMinimumGoal;
        weiMinimumAmount = _weiMinimumAmount;
    }

    // fallback function can be used to buy tokens
    function () external payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public whenNotPaused payable returns (bool) {
        uint weiAmount = msg.value;

        require(beneficiary != 0x0);
        require(validPurchase(weiAmount));
    
        // calculate token amount to be created
        uint tokenAmount = pricingStrategy.calculateTokenAmount(weiAmount, tokensSold);
        
        mintTokenToBuyer(beneficiary, tokenAmount, weiAmount);
        
        wallet.transfer(msg.value);

        return true;
    }

    function mintTokenToBuyer(address beneficiary, uint tokenAmount, uint weiAmount) internal {
        if (boughtAmountOf[beneficiary] == 0) {
            // A new buyer
            buyerCount++;
        }

        boughtAmountOf[beneficiary] = boughtAmountOf[beneficiary].add(weiAmount);
        weiRaised = weiRaised.add(weiAmount);
        tokensSold = tokensSold.add(tokenAmount);
    
        token.mint(beneficiary, tokenAmount, holderGroupNumber());
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
    }

    // return true if the transaction can buy tokens
    function validPurchase(uint weiAmount) internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool withinCap = weiRaised.add(weiAmount) <= weiMaximumGoal;
        bool moreThenMinimum = weiAmount >= weiMinimumAmount;

        return withinPeriod && withinCap && moreThenMinimum;
    }

    // return true if crowdsale event has ended
    function hasEnded() external constant returns (bool) {
        bool capReached = weiRaised >= weiMaximumGoal;
        bool afterEndTime = now > endTime;
        
        return capReached || afterEndTime;
    }

    // get the amount of unsold tokens allocated to this contract;
    function getWeiLeft() external constant returns (uint) {
        return weiMaximumGoal - weiRaised;
    }

    // return true if the crowdsale has raised enough money to be a successful.
    function isMinimumGoalReached() public constant returns (bool) {
        return weiRaised >= weiMinimumGoal;
    }
    
    // allows to update tokens rate for owner
    function setPricingStrategy(IPricingStrategy _pricingStrategy) external onlyOwner returns (bool) {
        pricingStrategy = _pricingStrategy;
        return true;
    }

    /**
    * Allow load refunds back on the contract for the refunding.
    *
    * The team can transfer the funds back on the smart contract in the case the minimum goal was not reached..
    */
    function loadRefund() external payable {
        require(msg.value > 0);
        require(!isMinimumGoalReached());
        
        loadedRefund = loadedRefund.add(msg.value);
    }

    /**
    * Buyers can claim refund.
    *
    * Note that any refunds from proxy buyers should be handled separately,
    * and not through this contract.
    */
    function refund() external {
        require(!isMinimumGoalReached() && loadedRefund > 0);
        uint256 weiValue = boughtAmountOf[msg.sender];
        require(weiValue > 0);
        
        boughtAmountOf[msg.sender] = 0;
        weiRefunded = weiRefunded.add(weiValue);
        Refund(msg.sender, weiValue);
        msg.sender.transfer(weiValue);
    }

    function setStartTime(uint _startTime) public onlyOwner {
        require(_startTime >= now);
        startTime = _startTime;
    }

    function setEndTime(uint _endTime) public onlyOwner {
        require(_endTime >= startTime);
        endTime = _endTime;
    }
}

// File: contracts/presale/Presale.sol

/**
 * @title Presale
 * @dev Presale is a contract for managing a token crowdsale.
 * Presales have a start and end timestamps, where buyers can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Presale is SaleBase {
    function Presale(
        uint _startTime,
        uint _endTime,
        IPricingStrategy _pricingStrategy,
        HeroCoin _token,
        address _wallet,
        uint _weiMaximumGoal,
        uint _weiMinimumGoal,
        uint _weiMinimumAmount
    ) public SaleBase(
        _startTime,
        _endTime,
        _pricingStrategy,
        _token,
        _wallet,
        _weiMaximumGoal,
        _weiMinimumGoal,
        _weiMinimumAmount) 
    {

    }

    function holderGroupNumber() public pure returns (uint) {
        return 1;
    }
}
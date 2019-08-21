pragma solidity ^0.4.13;

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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
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

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

/**
    BlockChain Board Of Derivatives Token.
 */
contract BBDToken is StandardToken, Ownable {

    // Metadata
    string public constant name = "BlockChain Board Of Derivatives Token";
    string public constant symbol = "BBD";
    uint256 public constant decimals = 18;
    string private constant version = '1.0.0';

    // Crowdsale parameters
    uint256 public constant startTime = 1506844800; //Sunday, 1 October 2017 08:00:00 GMT
    uint256 public constant endTime = 1509523200;  // Wednesday, 1 November 2017 08:00:00 GMT

    uint256 public constant creationMaxCap = 300000000 * 10 ** decimals;
    uint256 public constant creationMinCap = 2500000 * 10 ** decimals;

    uint256 private constant startCreationRateOnTime = 1666; // 1666 BDD per 1 ETH
    uint256 private constant endCreationRateOnTime = 1000; // 1000 BDD per 1 ETH

    uint256 private constant quantityThreshold_10 = 10 ether;
    uint256 private constant quantityThreshold_30 = 30 ether;
    uint256 private constant quantityThreshold_100 = 100 ether;
    uint256 private constant quantityThreshold_300 = 300 ether;

    uint256 private constant quantityBonus_10 = 500;    // 5%
    uint256 private constant quantityBonus_30 = 1000;  // 10%
    uint256 private constant quantityBonus_100 = 1500; // 15%
    uint256 private constant quantityBonus_300 = 2000; // 20%

    // The flag indicates if the crowdsale was finalized
    bool public finalized = false;

    // Migration information
    address public migrationAgent;
    uint256 public totalMigrated;

    // Exchange address
    address public exchangeAddress;

    // Team accounts
    address private constant mainAccount = 0xEB1D40f6DA0E77E2cA046325F6F2a76081B4c7f4;
    address private constant coreTeamMemberOne = 0xe43088E823eA7422D77E32a195267aE9779A8B07;
    address private constant coreTeamMemberTwo = 0xad00884d1E7D0354d16fa8Ab083208c2cC3Ed515;

    // Ether raised
    uint256 private raised = 0;

    // Since we have different exchange rates, we need to keep track of how
    // much ether each contributed in case that we need to issue a refund
    mapping (address => uint256) private ethBalances;

    uint256 private constant divisor = 10000;

    // Events
    event LogRefund(address indexed _from, uint256 _value);
    event LogMigrate(address indexed _from, address indexed _to, uint256 _value);
    event LogBuy(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _amount);

    // Check if min cap was archived.
    modifier onlyWhenICOReachedCreationMinCap() {
        require( totalSupply >= creationMinCap );
        _;
    }

    function() payable {
        buy(msg.sender);
    }

    function creationRateOnTime() public constant returns (uint256) {
        uint256 currentPrice;

        if (now > endTime) {
            currentPrice = endCreationRateOnTime;
        }
        else {
            //Price is changing lineral starting from  startCreationRateOnTime to endCreationRateOnTime
            uint256 rateRange = startCreationRateOnTime - endCreationRateOnTime;
            uint256 timeRange = endTime - startTime;
            currentPrice = startCreationRateOnTime.sub(rateRange.mul(now.sub(startTime)).div(timeRange));
        }

        return currentPrice;
    }

    //Calculate number of BBD tokens for provided ether
    function calculateBDD(uint256 _ethVal) private constant returns (uint256) {
        uint256 bonus;

        //We provide bonus depending on eth value
        if (_ethVal < quantityThreshold_10) {
            bonus = 0; // 0% bonus
        }
        else if (_ethVal < quantityThreshold_30) {
            bonus = quantityBonus_10; // 5% bonus
        }
        else if (_ethVal < quantityThreshold_100) {
            bonus = quantityBonus_30; // 10% bonus
        }
        else if (_ethVal < quantityThreshold_300) {
            bonus = quantityBonus_100; // 15% bonus
        }
        else {
            bonus = quantityBonus_300; // 20% bonus
        }

        // Get number of BBD tokens
        return _ethVal.mul(creationRateOnTime()).mul(divisor.add(bonus)).div(divisor);
    }

    // Buy BBD
    function buy(address _beneficiary) payable {
        require(!finalized);
        require(msg.value != 0);
        require(now <= endTime);
        require(now >= startTime);

        uint256 bbdTokens = calculateBDD(msg.value);
        uint256 additionalBBDTokensForMainAccount = bbdTokens.mul(2250).div(divisor); // 22.5%
        uint256 additionalBBDTokensForCoreTeamMember = bbdTokens.mul(125).div(divisor); // 1.25%

        //Increase by 25% number of bbd tokens on each buy.
        uint256 checkedSupply = totalSupply.add(bbdTokens)
                                           .add(additionalBBDTokensForMainAccount)
                                           .add(2 * additionalBBDTokensForCoreTeamMember);

        require(creationMaxCap >= checkedSupply);

        totalSupply = checkedSupply;

        //Update balances
        balances[_beneficiary] = balances[_beneficiary].add(bbdTokens);
        balances[mainAccount] = balances[mainAccount].add(additionalBBDTokensForMainAccount);
        balances[coreTeamMemberOne] = balances[coreTeamMemberOne].add(additionalBBDTokensForCoreTeamMember);
        balances[coreTeamMemberTwo] = balances[coreTeamMemberTwo].add(additionalBBDTokensForCoreTeamMember);

        ethBalances[_beneficiary] = ethBalances[_beneficiary].add(msg.value);

        raised += msg.value;

        if (exchangeAddress != 0x0 && totalSupply >= creationMinCap && msg.value >= 1 ether) {
            // After archiving min cap we start moving 10% to exchange. It will help with liquidity on exchange.
            exchangeAddress.transfer(msg.value.mul(1000).div(divisor)); // 10%
        }

        LogBuy(msg.sender, _beneficiary, msg.value, bbdTokens);
    }

    // Finalize for successful ICO
    function finalize() onlyOwner external {
        require(!finalized);
        require(now >= endTime || totalSupply >= creationMaxCap);

        finalized = true;

        uint256 ethForCoreMember = raised.mul(500).div(divisor);

        coreTeamMemberOne.transfer(ethForCoreMember); // 5%
        coreTeamMemberTwo.transfer(ethForCoreMember); // 5%
        mainAccount.transfer(this.balance); //90%
    }

    // Refund if ICO won't reach min cap
    function refund() external {
        require(now > endTime);
        require(totalSupply < creationMinCap);

        uint256 bddVal = balances[msg.sender];
        require(bddVal > 0);
        uint256 ethVal = ethBalances[msg.sender];
        require(ethVal > 0);

        balances[msg.sender] = 0;
        ethBalances[msg.sender] = 0;
        totalSupply = totalSupply.sub(bddVal);

        msg.sender.transfer(ethVal);

        LogRefund(msg.sender, ethVal);
    }

    // Allow to migrate to next version of contract
    function migrate(uint256 _value) external {
        require(finalized);
        require(migrationAgent != 0x0);
        require(_value > 0);
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        totalMigrated = totalMigrated.add(_value);

        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);

        LogMigrate(msg.sender, migrationAgent, _value);
    }

    // Set migration Agent
    function setMigrationAgent(address _agent) onlyOwner external {
        require(finalized);
        require(migrationAgent == 0x0);

        migrationAgent = _agent;
    }

    // Set exchange address
    function setExchangeAddress(address _exchangeAddress) onlyOwner external {
        require(exchangeAddress == 0x0);

        exchangeAddress = _exchangeAddress;
    }

    function transfer(address _to, uint _value) onlyWhenICOReachedCreationMinCap returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) onlyWhenICOReachedCreationMinCap returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    // Transfer BBD to exchange.
    function transferToExchange(address _from, uint256 _value) onlyWhenICOReachedCreationMinCap returns (bool) {
        require(msg.sender == exchangeAddress);

        balances[exchangeAddress] = balances[exchangeAddress].add(_value);
        balances[_from] = balances[_from].sub(_value);

        Transfer(_from, exchangeAddress, _value);

        return true;
    }

    // ICO overview
    function icoOverview() constant returns (uint256 currentlyRaised, uint256 currentlyTotalSupply, uint256 currentlyCreationRateOnTime){
        currentlyRaised = raised;
        currentlyTotalSupply = totalSupply;
        currentlyCreationRateOnTime = creationRateOnTime();
    }
}
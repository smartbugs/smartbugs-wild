pragma solidity ^0.4.19;

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

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
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

contract Santacoin is StandardToken {

    using SafeMath for uint256;

    // Santa Coin meta data
    string constant public name = "SCS";
    string constant public symbol = "SCS";
    uint8 constant public decimals = 0; // 1 SCS = 1 SCS

    // North Pole Address
    address public NorthPoleAddress;

    // North Pole
    uint256 public NorthPoleAF = 1000000000000000;

    // Santa Coin Holder ETH Balances
    mapping(address => uint256) private ETHAmounts;

    // Rewards per contributing address
    mapping(address => uint256) private SantaCoinRewardsInETH;

    // Total amount held to date by North Pole
    uint256 public TotalETHGivenToNorthPole = 0;

    // Total amount of santa coins issued to date
    uint256 public TotalSantaCoinsGivenByNorthPole = 0;

    // Max Sata Reward (will be set once north pole stops minting)
    uint256 public MaxSantaRewardPerToken = 0;

    // Santa Coin minimum
    uint256 private minimumSantaCoinContribution = 0.01 ether;

    // Santa Coin Minting Range
    uint256 private santaCoinMinterLowerBound = 1;
    uint256 private santaCoinMinterUpperBound = 5;

    // Allows the north pole to issue santa coins
    // to boys and girls around the world
    bool public NorthPoleMintingEnabled = true;

    // Make sure either Santa or an Elf is
    // performing this task
    modifier onlySantaOrElf()
    {
        require (msg.sender == NorthPoleAddress);
        _;
    }

    // Determines random number between range
    function determineRandomNumberBetween(uint min, uint max)
        private
        returns (uint256)
    {
        return (uint256(keccak256(block.blockhash(block.number-min), min ))%max);
    }

    // Determines amount of Santa Coins to issue (alias)
    function askSantaForCoinAmountBetween(uint min, uint max)
        private
        returns (uint256)
    {
        return determineRandomNumberBetween(min, max);
    }

    // Determines amount of Santa Coins to issue (alias)
    function askSantaForPresent(uint min, uint max)
        private
        returns (uint256)
    {
        return determineRandomNumberBetween(min, max);
    }

    // Allows North Pole to issue Santa Coins
    function setNorthPoleAddress(address newNorthPoleAddress)
        public
        onlySantaOrElf
    {
        NorthPoleAddress = newNorthPoleAddress;
    }

    // Allows North Pole to issue Santa Coins
    function allowNorthPoleMinting()
        public
        onlySantaOrElf
    {
        require(NorthPoleMintingEnabled == false);
        NorthPoleMintingEnabled = true;
    }

    // Prevents North Pole from issuing Santa Coins
    function disallowNorthPoleMinting()
        public
        onlySantaOrElf
    {
        require(NorthPoleMintingEnabled == true);
        NorthPoleMintingEnabled = false;

        if (this.balance > 0 && totalSupply > 0) {
            MaxSantaRewardPerToken = this.balance.div(totalSupply);
        }
    }

    function hasSantaCoins(address holderAddress)
      public
      returns (bool)
    {
        return balances[holderAddress] > 0;
    }

    function openGiftFromSanta(address holderAddress)
      public
      returns (uint256)
    {
        return SantaCoinRewardsInETH[holderAddress];
    }

    function haveIBeenNaughty(address holderAddress)
      public
      returns (bool)
    {
        return (ETHAmounts[holderAddress] > 0 && SantaCoinRewardsInETH[holderAddress] == 0);
    }

    // Initializes Santa coin
    function Santacoin()
    {
        totalSupply = uint256(0);
        NorthPoleAddress = msg.sender;
    }

    // Used to get Santa Coins or
    function () payable {

        // Open gifts if user has coins
        if (msg.value == 0 && hasSantaCoins(msg.sender) == true && NorthPoleMintingEnabled == false && MaxSantaRewardPerToken > 0) {
            balances[msg.sender] -= 1;
            totalSupply -= 1;
            uint256 santasGift = MaxSantaRewardPerToken-NorthPoleAF;
            uint256 santaSecret = determineRandomNumberBetween(1, 20);
            uint256 senderSantaSecretGuess = determineRandomNumberBetween(1, 20);
            if (santaSecret == senderSantaSecretGuess) {
                msg.sender.transfer(santasGift);
                NorthPoleAddress.transfer(NorthPoleAF);
                SantaCoinRewardsInETH[msg.sender] += santasGift;
            }
        }

        // Get SantaCoins
        else if (msg.value >= minimumSantaCoinContribution && NorthPoleMintingEnabled == true) {
            uint256 tokensToCredit = askSantaForCoinAmountBetween(santaCoinMinterLowerBound, santaCoinMinterUpperBound);
            tokensToCredit = tokensToCredit == 0 ? 1 : tokensToCredit;

            totalSupply += tokensToCredit;
            ETHAmounts[msg.sender] += msg.value;
            TotalETHGivenToNorthPole += msg.value;
            balances[msg.sender] += tokensToCredit;
            TotalSantaCoinsGivenByNorthPole += balances[msg.sender];
        }

        else {
            revert();
        }
    }
}
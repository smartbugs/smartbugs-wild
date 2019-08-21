pragma solidity ^0.4.19;


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
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
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
    totalSupply_ = totalSupply_.add(_amount);
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

contract LareCoin is StandardToken, MintableToken
{
    // ERC20 token parameters
    string public constant name = "LareCoin";
    string public constant symbol = "LARE";
    uint8 public constant decimals = 18;
    
    uint256 public constant ETH_PER_LARE = 0.0006 ether;
    uint256 public constant MINIMUM_CONTRIBUTION = 0.05 ether;
    uint256 public constant MAXIMUM_CONTRIBUTION = 5000000 ether;
    
    // Track the amount of Lare that has been sold in the pre-sale and main-sale.
    // These variables do not include the bonuses.
    uint256 public totalBaseLareSoldInPreSale = 0;
    uint256 public totalBaseLareSoldInMainSale = 0;
    
    // The total amount of LARE sold.
    // This variable does include the bonuses.
    uint256 public totalLareSold = 0;
    
    uint256 public constant PRE_SALE_START_TIME  = 1518998400; // 16 february 2018
    uint256 public constant MAIN_SALE_START_TIME = 1528070400; // 4 june 2018
    uint256 public constant MAIN_SALE_END_TIME   = 1546560000; // 4 january 2019
    
    uint256 public constant TOTAL_LARE_FOR_SALE = 28000000000 * (uint256(10) ** decimals);
    
    address public owner;
    
    // Statistics
    mapping(address => uint256) public addressToLarePurchased;
    mapping(address => uint256) public addressToEtherContributed;
    address[] public allParticipants;
    function amountOfParticipants() external view returns (uint256)
    {
        return allParticipants.length;
    }
    
    // Constructor function
    function LareCoin() public
    {
        owner = msg.sender;
        totalSupply_ = 58000000000 * (uint256(10) ** decimals);
        balances[owner] = totalSupply_;
        Transfer(0x0, owner, balances[owner]);
    }
    
    // Fallback function
    function () payable external
    {
        // Make sure the contribution is within limits
        require(msg.value >= MINIMUM_CONTRIBUTION);
        require(msg.value <= MAXIMUM_CONTRIBUTION);
        
        // Calculate the base amount of tokens purchased, excluding the bonus
        uint256 purchasedTokensBase = msg.value * (uint256(10)**18) / ETH_PER_LARE;
        
        // Check which stage of the sale we are in, and act accordingly
        uint256 purchasedTokensIncludingBonus = purchasedTokensBase;
        if (now < PRE_SALE_START_TIME)
        {
            // The pre-sale has not started yet.
            // Cancel the transaction.
            revert();
        }
        else if (now >= PRE_SALE_START_TIME && now < MAIN_SALE_START_TIME)
        {
            totalBaseLareSoldInPreSale += purchasedTokensBase;
            
            if (totalBaseLareSoldInPreSale <= 2000000000 * (uint256(10)**decimals))
            {
                // Pre-sale 100% bonus
                purchasedTokensIncludingBonus += purchasedTokensBase;
            }
            else
            {
                // We've reached the 2 billion LARE limit of the pre-sale.
                // Cancel the transaction.
                revert();
            }
        }
        else if (now >= MAIN_SALE_START_TIME && now < MAIN_SALE_END_TIME)
        {
            totalBaseLareSoldInMainSale += purchasedTokensBase;
            
            // Tier 1: 80% bonus
                 if (totalBaseLareSoldInMainSale <=  2000000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 80 / 100;

            // Tier 2: 70% bonus
            else if (totalBaseLareSoldInMainSale <=  4000000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 70 / 100;

            // Tier 3: 60% bonus
            else if (totalBaseLareSoldInMainSale <=  6000000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 60 / 100;

            // Tier 4: 50% bonus
            else if (totalBaseLareSoldInMainSale <=  8000000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 50 / 100;

            // Tier 5: 40% bonus
            else if (totalBaseLareSoldInMainSale <=  9500000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 40 / 100;

            // Tier 6: 30% bonus
            else if (totalBaseLareSoldInMainSale <= 11000000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 30 / 100;

            // Tier 7: 20% bonus
            else if (totalBaseLareSoldInMainSale <= 12500000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 20 / 100;

            // Tier 8: 10% bonus
            else if (totalBaseLareSoldInMainSale <= 14000000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 10 / 100;
            
            // Tier 9: 8% bonus
            else if (totalBaseLareSoldInMainSale <= 15000000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 8 / 100;
            
            // Tier 10: 6% bonus
            else if (totalBaseLareSoldInMainSale <= 16000000000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 6 / 100;
            
            // Tier 11: 4% bonus
            else if (totalBaseLareSoldInMainSale <= 16691200000 * (uint256(10)**decimals))
                purchasedTokensIncludingBonus += purchasedTokensBase * 4 / 100;
            
            // Tier 12: 2% bonus
            else
                purchasedTokensIncludingBonus += purchasedTokensBase * 2 / 100;
        }
        else
        {
            // The main sale has ended.
            // Cancel the transaction.
            revert();
        }
        
        // Statistics tracking
        if (addressToLarePurchased[msg.sender] == 0) allParticipants.push(msg.sender);
        addressToLarePurchased[msg.sender] += purchasedTokensIncludingBonus;
        addressToEtherContributed[msg.sender] += msg.value;
        totalLareSold += purchasedTokensIncludingBonus;
        
        // Don't allow selling more than the maximum
        require(totalLareSold < TOTAL_LARE_FOR_SALE);
        
        // Send the ETH to the owner
        owner.transfer(msg.value);
    }
    
    function grantPurchasedTokens(address _purchaser) external onlyOwner
    {
        uint256 amountToTransfer = addressToLarePurchased[_purchaser];
        addressToLarePurchased[_purchaser] = 0;
        transfer(_purchaser, amountToTransfer);
    }
}
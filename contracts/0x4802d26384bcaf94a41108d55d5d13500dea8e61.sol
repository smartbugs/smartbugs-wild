pragma solidity ^0.4.19;

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
    _amount = _amount * 1 ether;
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



/**
 * @title Token Wrapper with constructor
 * @dev Customized mintable ERC20 Token
 * @dev Token to support 2 owners only.
 */
contract PUBLICCOIN is Ownable, MintableToken {
  //Event for Presale transfers
  //event TokenPreSaleTransfer(address indexed purchaser, address indexed beneficiary, uint256 amount);

  // Token details
  string public constant name = "Public Coin";
  string public constant symbol = "PUBLIC";

  // 18 decimal places, the same as ETH.
  uint8 public constant decimals = 18;

  /**
    @dev Constructor. Sets the initial supplies and transfer advisor/founders/presale tokens to the given account
    @param _owner1 The address of the first owner
    @param _owner1Percentage The preallocate percentage of tokens belong to the first owner
    @param _owner2 The address of the second owner
    @param _owner2Percentage The preallocate percentage of tokens belong to the second owner
    @param _cap the maximum totalsupply in number of tokens //before multiply to 10**18
   */
  function PUBLICCOIN (address _owner1, uint8 _owner1Percentage, address _owner2, uint8 _owner2Percentage, uint256 _cap) public {
      //Total of 17M tokens
      require(_owner1Percentage+_owner2Percentage<50);//sanity check
      require(_cap >0);
      totalSupply = 0; //initialize total supply
      // 12% for owner1, 6% for owner 2
      mint(_owner1, _cap *_owner1Percentage / 100);
      mint(_owner2, _cap *_owner2Percentage / 100);

  }

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

/**
 * @title Token Generation Event for PublicCoin
 * credit: part of this contract was created from OpenZeppelin Code
 * @dev It allows multiple Capped CrowdSales. i.e. every crowdsale with capped token limit.
 * Simplified the deployment function for owner, just click & start, no configuration parameters
 */
contract Crowdsale is Ownable
{
    using SafeMath for uint256;

    // The token being sold
    PUBLICCOIN public token;
    // the account to which all incoming ether will be transferred
    // Flag to track the crowdsale status (Active/InActive)
    bool public crowdSaleOn = false;

    // Current crowdsale sate variables
    uint256 constant totalCap = 17*10**6;  // Max avaialble number of tokens in total including presale (unit token)
    uint256 constant crowdSaleCap = 14*10**6*(1 ether);  // Max avaialble number of tokens for crowdsale 18 M (unit wei)
    uint256 constant bonusPeriod = 1 days; //change to 1 days when deploying
    uint256 constant tokensPerEther = 3750;
    uint256 public startTime; // Crowdsale start time
    uint256 public endTime;  // Crowdsale end time
    uint256 public weiRaised = 0;  // Total amount ether/wei collected
    uint256 public tokensMinted = 0; // Total number of tokens minted/sold so far in this crowdsale
    uint256 public currentRate = 3750;
    //first_owner receives 90% of ico fund in eth, second_owner receives 10%.
    //first_owner keeps 12% of token, second_owner keeps 6% token, 82% token for public sale
    //For transparency this must be hardcoded and uploaded to etherscan.io
    address constant firstOwner = 0xf878bDc344097449Df3F2c2DC6Ed491e9DeF71f5;
    address constant secondOwner = 0x0B993E8Ee11B18BD99FCf7b2df5555385A661f7e;
    uint8 constant firstOwnerETHPercentage= 90;
    uint8 constant secondOwnerETHPercentage= 10;
    uint8 constant firstOwnerTokenPercentage= 12;
    uint8 constant secondOwnerTokenPercentage= 6;
    uint256 constant minPurchase = (1*1 ether)/10; //0.1 eth minimum

    // Event to be registered when a successful token purchase happens
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /** Modifiers to verify the status of the crowdsale*/
    modifier activeCrowdSale() {
        require(crowdSaleOn);
        _;
    }
    modifier inactiveCrowdSale() {
        require(!crowdSaleOn);
        _;
    }

    /**
        @dev constructor. Intializes the token to be traded using this contract
     */
    function Crowdsale() public {
        token = new PUBLICCOIN(firstOwner,firstOwnerTokenPercentage,secondOwner,secondOwnerTokenPercentage, totalCap);
    }

    /**
      @dev function to start the crowdsale. it will be called once for each crowdsale session
      @return A boolean that indicates if the operation is successful
     */
    function startCrowdsale() inactiveCrowdSale onlyOwner public returns (bool) {
        startTime =  uint256(now);
        //endTime = now + 30 days;
        endTime = now + 3*bonusPeriod;
        crowdSaleOn = true;
        weiRaised = 0;
        tokensMinted = 0;
        return true;
    }

    /**
      @dev function to stop crowdsale session.it will be called once for every crowdsale session and it can be called only its owner
      @return A boolean that indicates if the operation is successful
     */
    function endCrowdsale() activeCrowdSale onlyOwner public returns (bool) {
        require(now >= endTime);
        crowdSaleOn = false;
        token.finishMinting();
        return true;
    }

    /**
      @dev function to calculate and return the discounted token rate based on the current timeslot
      @return _discountedRate for the current timeslot
      return rate of Y wei per 1 Token)
      base rate without bonus : 1 ether = 3 750 tokens
      rate changes after 11 days
      the first 1 day: 35% bonus, next 3 days: 15% bonus , last 27 days : 0%
      hardcoded
     */
    function findCurrentRate() constant private returns (uint256 _discountedRate) {

        uint256 elapsedTime = now.sub(startTime);
        uint256 baseRate = (1*1 ether)/tokensPerEther;

        if (elapsedTime <= bonusPeriod){ // x<= 1days
            _discountedRate = baseRate.mul(100).div(135);
        }else{
            if (elapsedTime < 2*bonusPeriod){ //1days < x <= 3 days
              _discountedRate = baseRate.mul(100).div(115);
              }else{
              _discountedRate = baseRate;
            }
        }

    }

    /**
      @dev  fallback function can be used to buy tokens
      */
    function () payable public {
        buyTokens(msg.sender);
    }

    /**
      @dev  low level token purchase function
      */
    function buyTokens(address beneficiary) activeCrowdSale public payable {
        require(beneficiary != 0x0);
        require(now >= startTime);
        require(now <= endTime);
        require(msg.value >= minPurchase); //enforce minimum value of a tx

        // amount ether sent to the contract.. normalized to wei
        uint256 weiAmount = msg.value;
        weiRaised = weiRaised.add(weiAmount);


        // Find out Token value in wei ( Y wei per 1 Token)
        uint256 rate = findCurrentRate();
        //uint256 rate = uint256(1 * 1 ether).div(currentRate);
        require(rate > 0);
        //update public variable for viewing only, as requested
        currentRate = (1*1 ether)/rate;
        // Find out the number of tokens for given wei and normalize to ether so that tokens can be minted
        // by token contract
        uint256 numTokens = weiAmount.div(rate);
        require(numTokens > 0);
        require(tokensMinted.add(numTokens.mul(1 ether)) <= crowdSaleCap);
        tokensMinted = tokensMinted.add(numTokens.mul(1 ether));

        // Mint the tokens and trasfer to the buyer
        token.mint(beneficiary, numTokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, numTokens);
        // Transfer the ether to owners according to their share and close the purchase
        firstOwner.transfer(weiAmount*firstOwnerETHPercentage/100);
        secondOwner.transfer(weiAmount*secondOwnerETHPercentage/100);

    }

    // ETH balance is always expected to be 0 after the crowsale.
    // but in case something went wrong, we use this function to extract the eth.
    // Security idea from kyber.network crowdsale
    // This should never be used
    function emergencyDrain(ERC20 anyToken) inactiveCrowdSale onlyOwner public returns(bool){
        if( this.balance > 0 ) {
            owner.transfer( this.balance );
        }

        if( anyToken != address(0x0) ) {
            assert( anyToken.transfer(owner, anyToken.balanceOf(this)) );
        }

        return true;
    }

}
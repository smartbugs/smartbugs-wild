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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
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
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
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


// This is just a contract of a BIX Token.
// It is a ERC20 token
contract BIXToken is StandardToken, Ownable{
    
    string public version = "1.0";
    string public name = "BIX Token";
    string public symbol = "BIX";
    uint8 public  decimals = 18;

    mapping(address=>uint256)  lockedBalance;
    mapping(address=>uint)     timeRelease; 
    
    uint256 internal constant INITIAL_SUPPLY = 500 * (10**6) * (10 **18);
    uint256 internal constant DEVELOPER_RESERVED = 175 * (10**6) * (10**18);

    //address public developer;
    //uint256 internal crowdsaleAvaible;


    event Burn(address indexed burner, uint256 value);
    event Lock(address indexed locker, uint256 value, uint releaseTime);
    event UnLock(address indexed unlocker, uint256 value);
    

    // constructor
    function BIXToken(address _developer) { 
        balances[_developer] = DEVELOPER_RESERVED;
        totalSupply = DEVELOPER_RESERVED;
    }

    //balance of locked
    function lockedOf(address _owner) public constant returns (uint256 balance) {
        return lockedBalance[_owner];
    }

    //release time of locked
    function unlockTimeOf(address _owner) public constant returns (uint timelimit) {
        return timeRelease[_owner];
    }


    // transfer to and lock it
    function transferAndLock(address _to, uint256 _value, uint _releaseTime) public returns (bool success) {
        require(_to != 0x0);
        require(_value <= balances[msg.sender]);
        require(_value > 0);
        require(_releaseTime > now && _releaseTime <= now + 60*60*24*365*5);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
       
        //if preLock can release 
        uint preRelease = timeRelease[_to];
        if (preRelease <= now && preRelease != 0x0) {
            balances[_to] = balances[_to].add(lockedBalance[_to]);
            lockedBalance[_to] = 0;
        }

        lockedBalance[_to] = lockedBalance[_to].add(_value);
        timeRelease[_to] =  _releaseTime >= timeRelease[_to] ? _releaseTime : timeRelease[_to]; 
        Transfer(msg.sender, _to, _value);
        Lock(_to, _value, _releaseTime);
        return true;
    }


   /**
   * @notice Transfers tokens held by lock.
   */
   function unlock() public constant returns (bool success){
        uint256 amount = lockedBalance[msg.sender];
        require(amount > 0);
        require(now >= timeRelease[msg.sender]);

        balances[msg.sender] = balances[msg.sender].add(amount);
        lockedBalance[msg.sender] = 0;
        timeRelease[msg.sender] = 0;

        Transfer(0x0, msg.sender, amount);
        UnLock(msg.sender, amount);

        return true;

    }


    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public returns (bool success) {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
    
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
        return true;
    }

    // 
    function isSoleout() public constant returns (bool) {
        return (totalSupply >= INITIAL_SUPPLY);
    }


    modifier canMint() {
        require(!isSoleout());
        _;
    } 
    
    /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
    function mintBIX(address _to, uint256 _amount, uint256 _lockAmount, uint _releaseTime) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        if (_lockAmount > 0) {
            totalSupply = totalSupply.add(_lockAmount);
            lockedBalance[_to] = lockedBalance[_to].add(_lockAmount);
            timeRelease[_to] =  _releaseTime >= timeRelease[_to] ? _releaseTime : timeRelease[_to];            
            Lock(_to, _lockAmount, _releaseTime);
        }

        Transfer(0x0, _to, _amount);
        return true;
    }
}


// Contract for BIX Token sale
contract BIXCrowdsale {
    using SafeMath for uint256;

      // The token being sold
      BIXToken public bixToken;
      
      address public owner;

      // start and end timestamps where investments are allowed (both inclusive)
      uint256 public startTime;
      uint256 public endTime;
      

      uint256 internal constant baseExchangeRate =  1800 ;       //1800 BIX tokens per 1 ETH
      uint256 internal constant earlyExchangeRate = 2000 ;
      uint256 internal constant vipExchangeRate =   2400 ;
      uint256 internal constant vcExchangeRate  =   2500 ;
      uint8  internal constant  DaysForEarlyDay = 11;
      uint256  internal constant vipThrehold = 1000 * (10**18);
            

      //
      event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
      // amount of eth crowded in wei
      uint256 public weiCrowded;


      //constructor
      function BIXCrowdsale(uint256 _startTime, uint256 _endTime, address _wallet) {
            require(_startTime >= now);
            require(_endTime >= _startTime);
            require(_wallet != 0);

            owner = _wallet;
            bixToken = new BIXToken(owner);
            

            startTime = _startTime;
            endTime = _endTime;
      }

      // fallback function can be used to buy tokens
      function () payable {
          buyTokens(msg.sender);
      }

      // low level token purchase function
      function buyTokens(address beneficiary) public payable {
            require(beneficiary != 0x0);
            require(validPurchase());

            uint256 weiAmount = msg.value;
            weiCrowded = weiCrowded.add(weiAmount);

            
            // calculate token amount to be created
            uint256 rRate = rewardRate();
            uint256 rewardBIX = weiAmount.mul(rRate);
            uint256 baseBIX = weiAmount.mul(baseExchangeRate);

            // let it can sale exceed the INITIAL_SUPPLY only at the first time then crowd will end
             uint256 bixAmount = baseBIX.add(rewardBIX);
           
            // the rewardBIX lock in 3 mounthes
            if(rewardBIX > (earlyExchangeRate - baseExchangeRate)) {
                uint releaseTime = startTime + (60 * 60 * 24 * 30 * 3);
                bixToken.mintBIX(beneficiary, baseBIX, rewardBIX, releaseTime);  
            } else {
                bixToken.mintBIX(beneficiary, bixAmount, 0, 0);  
            }
            
            TokenPurchase(msg.sender, beneficiary, weiAmount, bixAmount);
            forwardFunds();           
      }

      /**
       * reward rate for purchase
       */
      function rewardRate() internal constant returns (uint256) {
            
            uint256 rate = baseExchangeRate;

            if (now < startTime) {
                rate = vcExchangeRate;
            } else {
                uint crowdIndex = (now - startTime) / (24 * 60 * 60); 
                if (crowdIndex < DaysForEarlyDay) {
                    rate = earlyExchangeRate;
                } else {
                    rate = baseExchangeRate;
                }

                //vip
                if (msg.value >= vipThrehold) {
                    rate = vipExchangeRate;
                }
            }
            return rate - baseExchangeRate;
        
      }



      // send ether to the fund collection wallet
      function forwardFunds() internal {
            owner.transfer(msg.value);
      }

      // @return true if the transaction can buy tokens
      function validPurchase() internal constant returns (bool) {
            bool nonZeroPurchase = msg.value != 0;
            bool noEnd = !hasEnded();
            
            return  nonZeroPurchase && noEnd;
      }

      // @return true if crowdsale event has ended
      function hasEnded() public constant returns (bool) {
            return (now > endTime) || bixToken.isSoleout(); 
      }
}
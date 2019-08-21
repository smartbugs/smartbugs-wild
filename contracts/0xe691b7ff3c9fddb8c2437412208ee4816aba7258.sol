pragma solidity ^0.4.13;

library Math {
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

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
  function transferOwnership(address newOwner) public onlyOwner {
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

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract LegalLazyScheduler is Ownable {
    uint64 public lastUpdate;
    uint64 public intervalDuration;
    bool schedulerEnabled = false;
    function() internal callback;

    event LogRegisteredInterval(uint64 date, uint64 duration);
    event LogProcessedInterval(uint64 date, uint64 intervals);    
    /**
    * Triggers the registered callback function for the number of periods passed since last update
    */
    modifier intervalTrigger() {
        uint64 currentTime = uint64(now);
        uint64 requiredIntervals = (currentTime - lastUpdate) / intervalDuration;
        if( schedulerEnabled && (requiredIntervals > 0)) {
            LogProcessedInterval(lastUpdate, requiredIntervals);
            while (requiredIntervals-- > 0) {
                callback();
            }
            lastUpdate = currentTime;
        }
        _;
    }
    
    function LegalLazyScheduler() {
        lastUpdate = uint64(now);
    }

    function enableScheduler() onlyOwner public {
        schedulerEnabled = true;
    }

    function registerIntervalCall(uint64 _intervalDuration, function() internal _callback) internal {
        lastUpdate = uint64(now);
        intervalDuration = _intervalDuration;
        callback = _callback;
        LogRegisteredInterval(lastUpdate, intervalDuration);        
    }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LimitedTransferToken is ERC20 {

  /**
   * @dev Checks whether it can transfer or otherwise throws.
   */
  modifier canTransfer(address _sender, uint256 _value) {
    require(_value <= transferableTokens(_sender, uint64(now)));
   _;
  }

  /**
   * @dev Checks modifier and allows transfer if tokens are not locked.
   * @param _to The address that will receive the tokens.
   * @param _value The amount of tokens to be transferred.
   */
  function transfer(address _to, uint256 _value) canTransfer(msg.sender, _value) public returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
  * @dev Checks modifier and allows transfer if tokens are not locked.
  * @param _from The address that will send the tokens.
  * @param _to The address that will receive the tokens.
  * @param _value The amount of tokens to be transferred.
  */
  function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from, _value) public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Default transferable tokens function returns all tokens for a holder (no limit).
   * @dev Overwriting transferableTokens(address holder, uint64 time) is the way to provide the
   * specific logic for limiting token transferability for a holder over time.
   */
  function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
    return balanceOf(holder);
  }
}

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
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract VestedToken is StandardToken, LimitedTransferToken, Ownable {

  uint256 MAX_GRANTS_PER_ADDRESS = 20;

  struct TokenGrant {
    address granter;     // 20 bytes
    uint256 value;       // 32 bytes
    uint64 cliff;
    uint64 vesting;
    uint64 start;        // 3 * 8 = 24 bytes
    bool revokable;
    bool burnsOnRevoke;  // 2 * 1 = 2 bits? or 2 bytes?
  } // total 78 bytes = 3 sstore per operation (32 per sstore)

  mapping (address => TokenGrant[]) public grants;

  event NewTokenGrant(address indexed from, address indexed to, uint256 value, uint256 grantId);

  /**
   * @dev Grant tokens to a specified address
   * @param _to address The address which the tokens will be granted to.
   * @param _value uint256 The amount of tokens to be granted.
   * @param _start uint64 Time of the beginning of the grant.
   * @param _cliff uint64 Time of the cliff period.
   * @param _vesting uint64 The vesting period.
   */
  function grantVestedTokens(
    address _to,
    uint256 _value,
    uint64 _start,
    uint64 _cliff,
    uint64 _vesting,
    bool _revokable,
    bool _burnsOnRevoke
  ) onlyOwner public {

    // Check for date inconsistencies that may cause unexpected behavior
    require(_cliff >= _start && _vesting >= _cliff);

    require(tokenGrantsCount(_to) < MAX_GRANTS_PER_ADDRESS);   // To prevent a user being spammed and have his balance locked (out of gas attack when calculating vesting).

    uint256 count = grants[_to].push(
                TokenGrant(
                  _revokable ? msg.sender : 0, // avoid storing an extra 20 bytes when it is non-revokable
                  _value,
                  _cliff,
                  _vesting,
                  _start,
                  _revokable,
                  _burnsOnRevoke
                )
              );

    transfer(_to, _value);

    NewTokenGrant(msg.sender, _to, _value, count - 1);
  }

  /**
   * @dev Revoke the grant of tokens of a specifed address.
   * @param _holder The address which will have its tokens revoked.
   * @param _grantId The id of the token grant.
   */
  function revokeTokenGrant(address _holder, uint256 _grantId) public {
    TokenGrant storage grant = grants[_holder][_grantId];

    require(grant.revokable);
    require(grant.granter == msg.sender); // Only granter can revoke it

    address receiver = grant.burnsOnRevoke ? 0xdead : msg.sender;

    uint256 nonVested = nonVestedTokens(grant, uint64(now));

    // remove grant from array
    delete grants[_holder][_grantId];
    grants[_holder][_grantId] = grants[_holder][grants[_holder].length.sub(1)];
    grants[_holder].length -= 1;

    balances[receiver] = balances[receiver].add(nonVested);
    balances[_holder] = balances[_holder].sub(nonVested);

    Transfer(_holder, receiver, nonVested);
  }


  /**
   * @dev Calculate the total amount of transferable tokens of a holder at a given time
   * @param holder address The address of the holder
   * @param time uint64 The specific time.
   * @return An uint256 representing a holder's total amount of transferable tokens.
   */
  function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
    uint256 grantIndex = tokenGrantsCount(holder);

    if (grantIndex == 0) 
      return super.transferableTokens(holder, time); // shortcut for holder without grants

    // Iterate through all the grants the holder has, and add all non-vested tokens
    uint256 nonVested = 0;
    for (uint256 i = 0; i < grantIndex; i++) {
      nonVested = SafeMath.add(nonVested, nonVestedTokens(grants[holder][i], time));
    }

    // Balance - totalNonVested is the amount of tokens a holder can transfer at any given time
    uint256 vestedTransferable = SafeMath.sub(balanceOf(holder), nonVested);

    // Return the minimum of how many vested can transfer and other value
    // in case there are other limiting transferability factors (default is balanceOf)
    return Math.min256(vestedTransferable, super.transferableTokens(holder, time));
  }

  /**
   * @dev Check the amount of grants that an address has.
   * @param _holder The holder of the grants.
   * @return A uint256 representing the total amount of grants.
   */
  function tokenGrantsCount(address _holder) public constant returns (uint256 index) {
    return grants[_holder].length;
  }

  /**
   * @dev Calculate amount of vested tokens at a specific time
   * @param tokens uint256 The amount of tokens granted
   * @param time uint64 The time to be checked
   * @param start uint64 The time representing the beginning of the grant
   * @param cliff uint64  The cliff period, the period before nothing can be paid out
   * @param vesting uint64 The vesting period
   * @return An uint256 representing the amount of vested tokens of a specific grant
   *  transferableTokens
   *   |                         _/--------   vestedTokens rect
   *   |                       _/
   *   |                     _/
   *   |                   _/
   *   |                 _/
   *   |                /
   *   |              .|
   *   |            .  |
   *   |          .    |
   *   |        .      |
   *   |      .        |
   *   |    .          |
   *   +===+===========+---------+----------> time
   *      Start       Cliff    Vesting
   */
  function calculateVestedTokens(
    uint256 tokens,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) public constant returns (uint256)
    {
      // Shortcuts for before cliff and after vesting cases.
      if (time < cliff) return 0;
      if (time >= vesting) return tokens;

      // Interpolate all vested tokens.
      // As before cliff the shortcut returns 0, we can use just calculate a value
      // in the vesting rect (as shown in above's figure)

      // vestedTokens = (tokens * (time - start)) / (vesting - start)
      uint256 vestedTokens = SafeMath.div(
                                    SafeMath.mul(
                                      tokens,
                                      SafeMath.sub(time, start)
                                      ),
                                    SafeMath.sub(vesting, start)
                                    );

      return vestedTokens;
  }

  /**
   * @dev Get all information about a specific grant.
   * @param _holder The address which will have its tokens revoked.
   * @param _grantId The id of the token grant.
   * @return Returns all the values that represent a TokenGrant(address, value, start, cliff,
   * revokability, burnsOnRevoke, and vesting) plus the vested value at the current time.
   */
  function tokenGrant(address _holder, uint256 _grantId) public constant returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting, bool revokable, bool burnsOnRevoke) {
    TokenGrant storage grant = grants[_holder][_grantId];

    granter = grant.granter;
    value = grant.value;
    start = grant.start;
    cliff = grant.cliff;
    vesting = grant.vesting;
    revokable = grant.revokable;
    burnsOnRevoke = grant.burnsOnRevoke;

    vested = vestedTokens(grant, uint64(now));
  }

  /**
   * @dev Get the amount of vested tokens at a specific time.
   * @param grant TokenGrant The grant to be checked.
   * @param time The time to be checked
   * @return An uint256 representing the amount of vested tokens of a specific grant at a specific time.
   */
  function vestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {
    return calculateVestedTokens(
      grant.value,
      uint256(time),
      uint256(grant.start),
      uint256(grant.cliff),
      uint256(grant.vesting)
    );
  }

  /**
   * @dev Calculate the amount of non vested tokens at a specific time.
   * @param grant TokenGrant The grant to be checked.
   * @param time uint64 The time to be checked
   * @return An uint256 representing the amount of non vested tokens of a specific grant on the
   * passed time frame.
   */
  function nonVestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {
    return grant.value.sub(vestedTokens(grant, time));
  }

  /**
   * @dev Calculate the date when the holder can transfer all its tokens
   * @param holder address The address of the holder
   * @return An uint256 representing the date of the last transferable tokens.
   */
  function lastTokenIsTransferableDate(address holder) public constant returns (uint64 date) {
    date = uint64(now);
    uint256 grantIndex = grants[holder].length;
    for (uint256 i = 0; i < grantIndex; i++) {
      date = Math.max64(grants[holder][i].vesting, date);
    }
  }
}

contract LegalToken is LegalLazyScheduler, MintableToken, VestedToken {
    /**
    * The name of the token
    */
    bytes32 public name;

    /**
    * The symbol used for exchange
    */
    bytes32 public symbol;

    /**
    * Use to convert to number of tokens.
    */
    uint public decimals = 18;

    /**
    * The yearly expected inflation rate in base points.
    */
    uint32 public inflationCompBPS;

    /**
    * The tokens are locked until the end of the TGE.
    * The contract can release the tokens if TGE successful. If false we are in transfer lock up period.
    */
    bool public released = false;

    /**
    * Annually new minted tokens will be transferred to this wallet.
    * Publications will be rewarded with funds (incentives).  
    */
    address public rewardWallet;

    /**
    * Name and symbol were updated. 
    */
    event UpdatedTokenInformation(bytes32 newName, bytes32 newSymbol);

    /**
    * @dev Constructor that gives msg.sender all of existing tokens. 
    */
    function LegalToken(address _rewardWallet, uint32 _inflationCompBPS, uint32 _inflationCompInterval) onlyOwner public {
        setTokenInformation("Legal Token", "LGL");
        totalSupply = 0;        
        rewardWallet = _rewardWallet;
        inflationCompBPS = _inflationCompBPS;
        registerIntervalCall(_inflationCompInterval, mintInflationPeriod);
    }    

    /**
    * This function allows the token owner to rename the token after the operations
    * have been completed and then point the audience to use the token contract.
    */
    function setTokenInformation(bytes32 _name, bytes32 _symbol) onlyOwner public {
        name = _name;
        symbol = _symbol;
        UpdatedTokenInformation(name, symbol);
    }

    /**
    * Mint new tokens for the predefined inflation period and assign them to the reward wallet. 
    */
    function mintInflationPeriod() private {
        uint256 tokensToMint = totalSupply.mul(inflationCompBPS).div(10000);
        totalSupply = totalSupply.add(tokensToMint);
        balances[rewardWallet] = balances[rewardWallet].add(tokensToMint);
        Mint(rewardWallet, tokensToMint);
        Transfer(0x0, rewardWallet, tokensToMint);
    }     
    
    function setRewardWallet(address _rewardWallet) public onlyOwner {
        rewardWallet = _rewardWallet;
    }

    /**
    * Limit token transfer until the TGE is over.
    */
    modifier tokenReleased(address _sender) {
        require(released);
        _;
    }

    /**
    * This will make the tokens transferable
    */
    function releaseTokenTransfer() public onlyOwner {
        released = true;
    }

    // error: canTransfer(msg.sender, _value)
    function transfer(address _to, uint _value) public tokenReleased(msg.sender) intervalTrigger returns (bool success) {
        // Calls StandardToken.transfer()
        // error: super.transfer(_to, _value);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public tokenReleased(_from) intervalTrigger returns (bool success) {
        // Calls StandardToken.transferForm()
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public tokenReleased(msg.sender) intervalTrigger returns (bool) {
        // calls StandardToken.approve(..)
        return super.approve(_spender, _value);
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        // calls StandardToken.allowance(..)
        return super.allowance(_owner, _spender);
    }

    function increaseApproval (address _spender, uint _addedValue) public tokenReleased(msg.sender) intervalTrigger returns (bool success) {
        // calls StandardToken.increaseApproval(..)
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public tokenReleased(msg.sender) intervalTrigger returns (bool success) {
        // calls StandardToken.decreaseApproval(..)
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}
pragma solidity ^0.4.18;

/** 
 * DENTIX GLOBAL LIMITED
 * https://dentix.io
 */

// ==== Open Zeppelin library ===

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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
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
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <remco@2π.com>
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner
 * of this contract to reclaim ownership of the contracts.
 */
contract HasNoContracts is Ownable {

  /**
   * @dev Reclaim ownership of Ownable contracts
   * @param contractAddr The address of the Ownable to be reclaimed.
   */
  function reclaimContract(address contractAddr) external onlyOwner {
    Ownable contractInst = Ownable(contractAddr);
    contractInst.transferOwnership(owner);
  }
}

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <remco@2π.com>
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the
 * owner to reclaim the tokens.
 */
contract HasNoTokens is CanReclaimToken {

 /**
  * @dev Reject all ERC23 compatible tokens
  * @param from_ address The address that is transferring the tokens
  * @param value_ uint256 the amount of the specified token
  * @param data_ Bytes The data passed from the caller.
  */
  function tokenFallback(address from_, uint256 value_, bytes data_) pure external {
    from_;
    value_;
    data_;
    revert();
  }

}

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

  function Destructible() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
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

/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param token ERC20 token which is being vested
   */
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (now < cliff) {
      return 0;
    } else if (now >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(now.sub(start)).div(duration);
    }
  }
}


// ==== AALM Contracts ===

contract BurnableToken is StandardToken {
    using SafeMath for uint256;

    event Burn(address indexed from, uint256 amount);
    event BurnRewardIncreased(address indexed from, uint256 value);

    /**
    * @dev Sending ether to contract increases burning reward 
    */
    function() public payable {
        if(msg.value > 0){
            BurnRewardIncreased(msg.sender, msg.value);    
        }
    }

    /**
     * @dev Calculates how much ether one will receive in reward for burning tokens
     * @param _amount of tokens to be burned
     */
    function burnReward(uint256 _amount) public constant returns(uint256){
        return this.balance.mul(_amount).div(totalSupply);
    }

    /**
    * @dev Burns tokens and send reward
    * This is internal function because it DOES NOT check 
    * if _from has allowance to burn tokens.
    * It is intended to be used in transfer() and transferFrom() which do this check.
    * @param _from The address which you want to burn tokens from
    * @param _amount of tokens to be burned
    */
    function burn(address _from, uint256 _amount) internal returns(bool){
        require(balances[_from] >= _amount);
        
        uint256 reward = burnReward(_amount);
        assert(this.balance - reward > 0);

        balances[_from] = balances[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        //assert(totalSupply >= 0); //Check is not needed because totalSupply.sub(value) will already throw if this condition is not met
        
        _from.transfer(reward);
        Burn(_from, _amount);
        Transfer(_from, address(0), _amount);
        return true;
    }

    /**
    * @dev Transfers or burns tokens
    * Burns tokens transferred to this contract itself or to zero address
    * @param _to The address to transfer to or token contract address to burn.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        if( (_to == address(this)) || (_to == 0) ){
            return burn(msg.sender, _value);
        }else{
            return super.transfer(_to, _value);
        }
    }

    /**
    * @dev Transfer tokens from one address to another 
    * or burns them if _to is this contract or zero address
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amout of tokens to be transfered
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if( (_to == address(this)) || (_to == 0) ){
            var _allowance = allowed[_from][msg.sender];
            //require (_value <= _allowance); //Check is not needed because _allowance.sub(_value) will already throw if this condition is not met
            allowed[_from][msg.sender] = _allowance.sub(_value);
            return burn(_from, _value);
        }else{
            return super.transferFrom(_from, _to, _value);
        }
    }

}
contract DNTXToken is BurnableToken, MintableToken, HasNoContracts, HasNoTokens {
    string public symbol = 'DNTX';
    string public name = 'Dentix';
    uint8 public constant decimals = 18;

    address founder;    //founder address to allow him transfer tokens while minting
    function init(address _founder) onlyOwner public{
        founder = _founder;
    }

    /**
     * Allow transfer only after crowdsale finished
     */
    modifier canTransfer() {
        require(mintingFinished || msg.sender == founder);
        _;
    }
    
    function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
        return BurnableToken.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
        return BurnableToken.transferFrom(_from, _to, _value);
    }
}

contract DNTXCrowdsale is Ownable, Destructible {
    using SafeMath for uint256;
    
    uint8 private constant PERCENT_DIVIDER = 100;              

    event SpecialMint(address beneficiary, uint256 amount, string description);

    enum State { NotStarted, PreICO, ICO, Finished }
    State public state;         //Current contract state                     

    struct ICOBonus {
        uint32 expire;       //timestamp of date when this bonus expires (purshases before this time will use the bonus)
        uint8 percent;
    }
    ICOBonus[] public icoBonuses;    //Array of ICO bonuses

    uint256 public baseRate;           //how many DNTX one will get for 1 ETH during main sale without bonus
    uint8   public preICOBonusPercent; //Pre-ICO bonus percent
    uint32  public icoStartTimestamp;  //timestamp of ICO start
    uint32  public icoEndTimestamp;    //timestamp of ICO end
    uint256 public icoGoal;            //How much ether we need to collect to assume ICO is successfull
    uint256 public hardCap;            //Max amount possibly collected

    DNTXToken public token;                                 

    uint256 public icoCollected;
    uint256 public totalCollected;
    mapping(address => uint256) public icoContributions; //amount of ether received from an investor during ICO

    function DNTXCrowdsale() public{
        state = State.NotStarted;
        token = new DNTXToken();
        token.init(owner);
    }   

    function() public payable {
        require(msg.value > 0);
        require(isOpen());

        totalCollected = totalCollected.add(msg.value);
        if(state == State.ICO){
            require(totalCollected <= hardCap);
            icoCollected = icoCollected.add(msg.value);
            icoContributions[msg.sender] = icoContributions[msg.sender].add(msg.value);
        }

        uint256 rate = currentRate();
        assert(rate > 0);

        uint256 amount = rate.mul(msg.value);
        assert(token.mint(msg.sender, amount));
    }

    function mintTokens(address beneficiary, uint256 amount, string description) onlyOwner public {
        assert(token.mint(beneficiary, amount));
        SpecialMint(beneficiary, amount, description);
    }


    function isOpen() view public returns(bool){
        if(baseRate == 0) return false;
        if(state == State.NotStarted || state == State.Finished) return false;
        if(state == State.PreICO) return true;
        if(state == State.ICO){
            if(totalCollected >= hardCap) return false;
            return (icoStartTimestamp <= now) && (now <= icoEndTimestamp);
        }
    }
    function currentRate() view public returns(uint256){
        if(state == State.PreICO) {
            return baseRate.add( baseRate.mul(preICOBonusPercent).div(PERCENT_DIVIDER) );
        }else if(state == State.ICO){
            for(uint8 i=0; i < icoBonuses.length; i++){
                ICOBonus storage b = icoBonuses[i];
                if(now <= b.expire){
                    return baseRate.add( baseRate.mul(b.percent).div(PERCENT_DIVIDER) );
                }
            }
            return baseRate;
        }else{
            return 0;
        }
    }

    function setBaseRate(uint256 rate) onlyOwner public {
        require(state != State.ICO && state != State.Finished);
        baseRate = rate;
    }
    function setPreICOBonus(uint8 percent) onlyOwner public {
        preICOBonusPercent = percent;
    }
    function setupAndStartPreICO(uint256 rate, uint8 percent) onlyOwner external {
        setBaseRate(rate);
        setPreICOBonus(percent);
        startPreICO();
    }

    function setupICO(uint32 startTimestamp, uint32 endTimestamp, uint256 goal, uint256 cap, uint32[] expires, uint8[] percents) onlyOwner external {
        require(state != State.ICO && state != State.Finished);
        icoStartTimestamp = startTimestamp;
        icoEndTimestamp = endTimestamp;
        icoGoal = goal;
        hardCap = cap;

        require(expires.length == percents.length);
        uint32 prevExpire;
        for(uint8 i=0;  i < expires.length; i++){
            require(prevExpire < expires[i]);
            icoBonuses.push(ICOBonus({expire:expires[i], percent:percents[i]}));
            prevExpire = expires[i];
        }
    }

    /**
    * @notice Start PreICO stage
    */
    function startPreICO() onlyOwner public {
        require(state == State.NotStarted);
        require(baseRate != 0);
        state = State.PreICO;
    }
    /**
    * @notice Finish PreICO stage and start ICO (after time comes)
    */
    function finishPreICO() onlyOwner external {
        require(state == State.PreICO);
        require(icoStartTimestamp != 0 && icoEndTimestamp != 0);
        state = State.ICO;
    }
    /**
    * @notice Close crowdsale, finish minting (allowing token transfers), transfers token ownership to the founder
    */
    function finalizeCrowdsale() onlyOwner external {
        state = State.Finished;
        token.finishMinting();
        token.transferOwnership(owner);
        if(icoCollected >= icoGoal && this.balance > 0) {
            claimEther();
        }
    }
    /**
    * @notice Claim collected ether without closing crowdsale
    */
    function claimEther() onlyOwner public {
        require(state == State.PreICO || icoCollected >= icoGoal);
        require(this.balance > 0);
        owner.transfer(this.balance);
    }

    /**
    * @notice Sends all contributed ether back if minimum cap is not reached by the end of crowdsale
    */
    function refund() public returns(bool){
        return refundTo(msg.sender);
    }
    function refundTo(address beneficiary) public returns(bool) {
        require(icoCollected < icoGoal);
        require(icoContributions[beneficiary] > 0);
        require( (state == State.Finished) || (state == State.ICO && (now > icoEndTimestamp)) );

        uint256 _refund = icoContributions[beneficiary];
        icoContributions[beneficiary] = 0;
        beneficiary.transfer(_refund);
        return true;
    }

}
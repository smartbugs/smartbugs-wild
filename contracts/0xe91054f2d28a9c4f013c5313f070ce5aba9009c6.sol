pragma solidity ^0.4.18;

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
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <remco@2π.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this ether.
 * @notice Ether can still be send to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
*/
contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  function HasNoEther() public payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by settings a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    assert(owner.send(this.balance));
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
 * @title Base contract for contracts that should not own things.
 * @author Remco Bloemen <remco@2π.com>
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or
 * Owned contracts. See respective base contracts for details.
 */
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {
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

contract AALMToken is MintableToken, NoOwner { //MintableToken is StandardToken, Ownable
    string public symbol = 'AALM';
    string public name = 'Alm Token';
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
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}

contract AALMCrowdsale is Ownable, CanReclaimToken, Destructible {
    using SafeMath for uint256;    

    uint32 private constant PERCENT_DIVIDER = 100;

    struct BulkBonus {
        uint256 minAmount;      //Minimal amount to receive bonus (including this amount)
        uint32 bonusPercent;    //a bonus percent, so that bonus = amount.mul(bonusPercent).div(PERCENT_DIVIDER)
    }

    uint64 public startTimestamp;   //Crowdsale start timestamp
    uint64 public endTimestamp;     //Crowdsale end timestamp
    uint256 public minCap;          //minimal amount of sold tokens (if not reached - ETH may be refunded)
    uint256 public hardCap;         //total amount of tokens available
    uint256 public baseRate;        //how many tokens will be minted for 1 ETH (like 1000 AALM for 1 ETH) without bonuses

    uint32 public maxTimeBonusPercent;  //A maximum time bonus percent: at the start of crowdsale timeBonus = value.mul(baseRate).mul(maxTimeBonusPercent).div(PERCENT_DIVIDER)
    uint32 public referrerBonusPercent; //A bonus percent that refferer will receive, so that referrerBonus = value.mul(baseRate).mul(referrerBonusPercent).div(PERCENT_DIVIDER)
    uint32 public referralBonusPercent; //A bonus percent that refferal will receive, so that referralBonus = value.mul(baseRate).mul(referralBonusPercent).div(PERCENT_DIVIDER)
    BulkBonus[] public bulkBonuses;     //Bulk Bonuses sorted by ether amount (minimal amount first)
  

    uint256 public tokensMinted;    //total amount of minted tokens
    uint256 public tokensSold;      //total amount of tokens sold(!) on ICO, including all bonuses
    uint256 public collectedEther;  //total amount of ether collected during ICO (without Pre-ICO)

    mapping(address => uint256) contributions; //amount of ether (in wei)received from a buyer

    AALMToken public token;
    TokenVesting public founderVestingContract; //Contract which holds Founder's tokens

    bool public finalized;

    function AALMCrowdsale(uint64 _startTimestamp, uint64 _endTimestamp, uint256 _hardCap, uint256 _minCap, 
        uint256 _founderTokensImmediate, uint256 _founderTokensVested, uint256 _vestingDuration,
        uint256 _baseRate, uint32 _maxTimeBonusPercent, uint32 _referrerBonusPercent, uint32 _referralBonusPercent, 
        uint256[] bulkBonusMinAmounts, uint32[] bulkBonusPercents 
        ) public {
        require(_startTimestamp > now);
        require(_startTimestamp < _endTimestamp);
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;

        require(_hardCap > 0);
        hardCap = _hardCap;

        minCap = _minCap;

        initRatesAndBonuses(_baseRate, _maxTimeBonusPercent, _referrerBonusPercent, _referralBonusPercent, bulkBonusMinAmounts, bulkBonusPercents);

        token = new AALMToken();
        token.init(owner);

        require(_founderTokensImmediate.add(_founderTokensVested) < _hardCap);
        mintTokens(owner, _founderTokensImmediate);

        founderVestingContract = new TokenVesting(owner, endTimestamp, 0, _vestingDuration, false);
        mintTokens(founderVestingContract, _founderTokensVested);
    }

    function initRatesAndBonuses(
        uint256 _baseRate, uint32 _maxTimeBonusPercent, uint32 _referrerBonusPercent, uint32 _referralBonusPercent, 
        uint256[] bulkBonusMinAmounts, uint32[] bulkBonusPercents 
        ) internal {

        require(_baseRate > 0);
        baseRate = _baseRate;

        maxTimeBonusPercent = _maxTimeBonusPercent;
        referrerBonusPercent = _referrerBonusPercent;
        referralBonusPercent = _referralBonusPercent;

        uint256 prevBulkAmount = 0;
        require(bulkBonusMinAmounts.length == bulkBonusPercents.length);
        bulkBonuses.length = bulkBonusMinAmounts.length;
        for(uint8 i=0; i < bulkBonuses.length; i++){
            bulkBonuses[i] = BulkBonus({minAmount:bulkBonusMinAmounts[i], bonusPercent:bulkBonusPercents[i]});
            BulkBonus storage bb = bulkBonuses[i];
            require(prevBulkAmount < bb.minAmount);
            prevBulkAmount = bb.minAmount;
        }
    }

    /**
    * @notice Distribute tokens sold during Pre-ICO
    * @param beneficiaries Array of beneficiari addresses
    * @param amounts Array of amounts of tokens to send
    */
    function distributePreICOTokens(address[] beneficiaries, uint256[] amounts) onlyOwner public {
        require(beneficiaries.length == amounts.length);
        for(uint256 i=0; i<beneficiaries.length; i++){
            mintTokens(beneficiaries[i], amounts[i]);
        }
    }

    /**
    * @notice Sell tokens directly, without referral bonuses
    */
    function () payable public {
        sale(msg.sender, msg.value, address(0));
    }
    /**
    * @notice Sell tokens via RefferalCrowdsale contract
    * @param beneficiary Original sender (buyer)
    * @param referrer The partner who referered the buyer
    */
    function referralSale(address beneficiary, address referrer) payable public returns(bool) {
        sale(beneficiary, msg.value, referrer);
        return true;
    }
    /**
    * @dev Internal functions to sell tokens
    * @param beneficiary who should receive tokens (the buyer)
    * @param value of ether sent by buyer
    * @param referrer who should receive referrer bonus, if any. Zero address if no referral bonuses should be paid
    */
    function sale(address beneficiary, uint256 value, address referrer) internal {
        require(crowdsaleOpen());
        require(value > 0);
        collectedEther = collectedEther.add(value);
        contributions[beneficiary] = contributions[beneficiary].add(value);
        uint256 amount;
        if(referrer == address(0)){
            amount = getTokensWithBonuses(value, false);
        } else{
            amount = getTokensWithBonuses(value, true);
            uint256 referrerAmount  = getReferrerBonus(value);
            tokensSold = tokensSold.add(referrerAmount);
            mintTokens(referrer, referrerAmount);
        }
        tokensSold = tokensSold.add(amount);
        mintTokens(beneficiary, amount);
    }

    /**
    * @notice Mint tokens for purshases with Non-Ether currencies
    * @param beneficiary whom to send tokend
    * @param amount how much tokens to send
    * param message reason why we are sending tokens (not stored anythere, only in transaction itself)
    */
    function saleNonEther(address beneficiary, uint256 amount, string /*message*/) public onlyOwner {
        mintTokens(beneficiary, amount);
    }

    /**
    * @notice If crowdsale is running
    */
    function crowdsaleOpen() view public returns(bool) {
        return (!finalized) && (tokensMinted < hardCap) && (startTimestamp <= now) && (now <= endTimestamp);
    }

    /**
    * @notice Calculates how many tokens are left to sale
    * @return amount of tokens left before hard cap reached
    */
    function getTokensLeft() view public returns(uint256) {
        return hardCap.sub(tokensMinted);
    }

    /**
    * @notice Calculates how many tokens one should receive at curent time for a specified value of ether
    * @param value of ether to get bonus for
    * @param withReferralBonus if should add referral bonus
    * @return bonus tokens
    */
    function getTokensWithBonuses(uint256 value, bool withReferralBonus) view public returns(uint256) {
        uint256 amount = value.mul(baseRate);
        amount = amount.add(getTimeBonus(value)).add(getBulkBonus(value));
        if(withReferralBonus){
            amount = amount.add(getReferralBonus(value));
        }
        return amount;
    }

    /**
    * @notice Calculates current time bonus
    * @param value of ether to get bonus for
    * @return bonus tokens
    */
    function getTimeBonus(uint256 value) view public returns(uint256) {
        uint256 maxBonus = value.mul(baseRate).mul(maxTimeBonusPercent).div(PERCENT_DIVIDER);
        return maxBonus.mul(endTimestamp - now).div(endTimestamp - startTimestamp);
    }

    /**
    * @notice Calculates a bulk bonus for a specified value of ether
    * @param value of ether to get bonus for
    * @return bonus tokens
    */
    function getBulkBonus(uint256 value) view public returns(uint256) {
        for(uint8 i=uint8(bulkBonuses.length); i > 0; i--){
            uint8 idx = i - 1; //if i  = bulkBonuses.length-1 to 0, i-- fails on last iteration
            if (value >= bulkBonuses[idx].minAmount) {
                return value.mul(baseRate).mul(bulkBonuses[idx].bonusPercent).div(PERCENT_DIVIDER);
            }
        }
        return 0;
    }

    /**
    * @notice Calculates referrer bonus
    * @param value of ether  to get bonus for
    * @return bonus tokens
    */
    function getReferrerBonus(uint256 value) view public returns(uint256) {
        return value.mul(baseRate).mul(referrerBonusPercent).div(PERCENT_DIVIDER);
    }
    /**
    * @notice Calculates referral bonus
    * @param value of ether  to get bonus for
    * @return bonus tokens
    */
    function getReferralBonus(uint256 value) view public returns(uint256) {
        return value.mul(baseRate).mul(referralBonusPercent).div(PERCENT_DIVIDER);
    }

    /**
    * @dev Helper function to mint tokens and increase tokensMinted counter
    */
    function mintTokens(address beneficiary, uint256 amount) internal {
        tokensMinted = tokensMinted.add(amount);
        require(tokensMinted <= hardCap);
        assert(token.mint(beneficiary, amount));
    }

    /**
    * @notice Sends all contributed ether back if minimum cap is not reached by the end of crowdsale
    */
    function refund() public returns(bool){
        return refundTo(msg.sender);
    }
    function refundTo(address beneficiary) public returns(bool) {
        require(contributions[beneficiary] > 0);
        require(finalized || (now > endTimestamp));
        require(tokensSold < minCap);

        uint256 _refund = contributions[beneficiary];
        contributions[beneficiary] = 0;
        beneficiary.transfer(_refund);
        return true;
    }

    /**
    * @notice Closes crowdsale, finishes minting (allowing token transfers), transfers token ownership to the owner
    */
    function finalizeCrowdsale() public onlyOwner {
        finalized = true;
        token.finishMinting();
        token.transferOwnership(owner);
        if(tokensSold >= minCap && this.balance > 0){
            owner.transfer(this.balance);
        }
    }
    /**
    * @notice Claim collected ether without closing crowdsale
    */
    function claimEther() public onlyOwner {
        require(tokensSold >= minCap);
        owner.transfer(this.balance);
    }

}
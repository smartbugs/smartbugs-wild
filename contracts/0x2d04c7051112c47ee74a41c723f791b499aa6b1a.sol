pragma solidity ^0.4.24;
/**
 * Copyright YHT Community.
 * This software is copyrighted by the YHT community.
 * Prohibits any unauthorized copying and modification.
 * It is allowed through ABI calls.
 */
 
//==============================================================================
// Begin: This part comes from openzeppelin-solidity
//        https://github.com/OpenZeppelin/openzeppelin-solidity
//============================================================================== 
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
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

  uint256 totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}


/**
 * @title Standard Burnable Token
 * @dev Adds burnFrom method to ERC20 implementations
 */
contract StandardBurnableToken is BurnableToken, StandardToken {

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param _from address The address which you want to send tokens from
   * @param _value uint256 The amount of token to be burned
   */
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}
//==============================================================================
// End: This part comes from openzeppelin-solidity
//============================================================================== 


/**
 * @dev Lottery Interface  
 */ 
contract LotteryInterface {
  function checkLastMintData(address addr) external;   
  function getLastMintAmount(address addr) view external returns(uint256, uint256);
  function getReferrerEarnings(address addr) view external returns(uint256);
  function checkReferrerEarnings(address addr) external;
  function deposit() public payable;
}

/**
 * @title YHT Token
 * @dev The initial total is zero, which can only be produced by mining, halved production per 314 cycles.
 * After call startMinting function, no one can pause it.
 * All the people who hold it will enjoy the dividends.
 * See the YHT whitepaper to get more information.
 * https://github.com/ethergame/whitepaper
 */
contract YHToken is StandardBurnableToken, Ownable {
  string public constant name = "YHToken";
  string public constant symbol = "YHT";
  uint8 public constant decimals = 18;
  
  uint256 constant private kAutoCombineBonusesCount = 50;           // if the last two balance snapshot records are not far apart, they will be merged automatically.
  
  struct Bonus {                                                                    
    uint256 payment;                                                // payment of dividends
    uint256 currentTotalSupply;                                     // total supply at the payment time point  
  }
  
  struct BalanceSnapshot {
    uint256 balance;                                                // balance of snapshot     
    uint256 bonusIdBegin;                                           // begin of bonusId
    uint256 bonusIdEnd;                                             // end of bonusId
  }
  
  struct User {
    uint256 extraEarnings;                                              
    uint256 bonusEarnings;
    BalanceSnapshot[] snapshots;                                    // the balance snapshot array
    uint256 snapshotsLength;                                        // the length of balance snapshot array    
  }
  
  LotteryInterface public Lottery;
  uint256 public bonusRoundId_;                                     // next bonus id
  mapping(address => User) public users_;                           // user informations
  mapping(uint256 => Bonus) public bonuses_;                        // the records of all bonuses
    
  event Started(address lottery);
  event AddTotalSupply(uint256 addValue, uint256 total);
  event AddExtraEarnings(address indexed from, address indexed to, uint256 amount);
  event AddBonusEarnings(address indexed from, uint256 amount, uint256 bonusId, uint256 currentTotalSupply);
  event Withdraw(address indexed addr, uint256 amount);

  constructor() public {
    totalSupply_ = 0;      //initial is 0
    bonusRoundId_ = 1;
  }

  /**
   * @dev only the lottery contract can transfer earnings
   */
  modifier isLottery() {
    require(msg.sender == address(Lottery)); 
    _;
  }
  
  /**
   * @dev Function to start. just start once.
   */
  function start(address lottery) onlyOwner public {
    require(Lottery == address(0));
    Lottery = LotteryInterface(lottery);
    emit Started(lottery);
  }
  
  /**
   * @dev record a snapshot of balance
   * with the bonuses information can accurately calculate the earnings 
   */ 
  function balanceSnapshot(address addr, uint256 bonusRoundId) private {
    uint256 currentBalance = balances[addr];     
    User storage user = users_[addr];   
    if (user.snapshotsLength == 0) {
      user.snapshotsLength = 1;
      user.snapshots.push(BalanceSnapshot(currentBalance, bonusRoundId, 0));
    }
    else {
      BalanceSnapshot storage lastSnapshot = user.snapshots[user.snapshotsLength - 1];
      assert(lastSnapshot.bonusIdEnd == 0);
      
      // same as last record point just updated balance
      if (lastSnapshot.bonusIdBegin == bonusRoundId) {
        lastSnapshot.balance = currentBalance;      
      }
      else {
        assert(lastSnapshot.bonusIdBegin < bonusRoundId);
        
        // if this snapshot is not the same as the last time, automatically merges part of the earnings
        if (bonusRoundId - lastSnapshot.bonusIdBegin < kAutoCombineBonusesCount) {
           uint256 amount = computeRoundBonuses(lastSnapshot.bonusIdBegin, bonusRoundId, lastSnapshot.balance);
           user.bonusEarnings = user.bonusEarnings.add(amount);
           
           lastSnapshot.balance = currentBalance;
           lastSnapshot.bonusIdBegin = bonusRoundId;
           lastSnapshot.bonusIdEnd = 0;
        }
        else {
          lastSnapshot.bonusIdEnd = bonusRoundId;     
          
          /* 
          reuse this array to store data, based on code from
          https://ethereum.stackexchange.com/questions/3373/how-to-clear-large-arrays-without-blowing-the-gas-limit?answertab=votes#tab-top
          */
          if (user.snapshotsLength == user.snapshots.length) {
            user.snapshots.length += 1;  
          } 
          user.snapshots[user.snapshotsLength++] = BalanceSnapshot(currentBalance, bonusRoundId, 0);
        }
      }
    }
  }
  
  /**
   * @dev mint to add balance then do snapshot
   */ 
  function mint(address to, uint256 amount, uint256 bonusRoundId) private {
    balances[to] = balances[to].add(amount);
    emit Transfer(address(0), to, amount); 
    balanceSnapshot(to, bonusRoundId);  
  }
  
  /**
   * @dev add total supply and mint extra to founder team
   */  
  function mintToFounder(address to, uint256 amount, uint256 normalAmount) isLottery external {
    checkLastMint(to);
    uint256 value = normalAmount.add(amount);
    totalSupply_ = totalSupply_.add(value);
    emit AddTotalSupply(value, totalSupply_);
    mint(to, amount, bonusRoundId_);
  }
  
  /**
   * @dev mint tokens for player
   */ 
  function mintToNormal(address to, uint256 amount, uint256 bonusRoundId) isLottery external {
    require(bonusRoundId < bonusRoundId_);
    mint(to, amount, bonusRoundId);
  }
  
  /**
   * @dev check player last mint status, mint for player if necessary
   */ 
  function checkLastMint(address addr) private {
    Lottery.checkLastMintData(addr);  
  }

  function balanceSnapshot(address addr) private {
    balanceSnapshot(addr, bonusRoundId_);  
  }

  /**
   * @dev get balance snapshot
   */ 
  function getBalanceSnapshot(address addr, uint256 index) view public returns(uint256, uint256, uint256) {
    BalanceSnapshot storage snapshot = users_[addr].snapshots[index];
    return (
      snapshot.bonusIdBegin,
      snapshot.bonusIdEnd,
      snapshot.balance
    );
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    checkLastMint(msg.sender);
    checkLastMint(_to);
    super.transfer(_to, _value);
    balanceSnapshot(msg.sender);
    balanceSnapshot(_to);
    return true;
  } 

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    checkLastMint(_from);
    checkLastMint(_to);
    super.transferFrom(_from, _to, _value);
    balanceSnapshot(_from);
    balanceSnapshot(_to);
    return true;
  }
  
  function _burn(address _who, uint256 _value) internal {
    checkLastMint(_who);  
    super._burn(_who, _value);  
    balanceSnapshot(_who);
  } 
  
  /**
   * @dev clear warnings for unused variables  
   */ 
  function unused(uint256) pure private {} 
  
 /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    (uint256 lastMintAmount, uint256 lastBonusRoundId) = Lottery.getLastMintAmount(_owner);  
    unused(lastBonusRoundId);
    return balances[_owner].add(lastMintAmount);  
  }

  /**
   * @dev Others contract transfer earnings to someone
   * The lottery contract transfer the big reward to winner
   * It is open interface, more game contracts may be used in the future
   */
  function transferExtraEarnings(address to) external payable {
    if (msg.sender != address(Lottery)) {
      require(msg.value > 662607004);
      require(msg.value < 66740800000000000000000);
    }  
    users_[to].extraEarnings = users_[to].extraEarnings.add(msg.value);   
    emit AddExtraEarnings(msg.sender, to, msg.value);
  }
  
  /**
   * @dev Others contract transfer bonus earnings to all the people who hold YHT  
   * It is open interface, more game contracts may be used in the future
   */
  function transferBonusEarnings() external payable returns(uint256) {
    require(msg.value > 0);
    require(totalSupply_ > 0);
    if (msg.sender != address(Lottery)) {
      require(msg.value > 314159265358979323);
      require(msg.value < 29979245800000000000000);   
    }
    
    uint256 bonusRoundId = bonusRoundId_;
    bonuses_[bonusRoundId].payment = msg.value;
    bonuses_[bonusRoundId].currentTotalSupply = totalSupply_;
    emit AddBonusEarnings(msg.sender, msg.value, bonusRoundId_, totalSupply_);
    
    ++bonusRoundId_;
    return bonusRoundId;
  }

  /**
   * @dev get earings of user, can directly withdraw 
   */ 
  function getEarnings(address addr) view public returns(uint256) {
    User storage user = users_[addr];  
    uint256 amount;
    (uint256 lastMintAmount, uint256 lastBonusRoundId) = Lottery.getLastMintAmount(addr);
    if (lastMintAmount > 0) {
      amount = computeSnapshotBonuses(user, lastBonusRoundId);
      amount = amount.add(computeRoundBonuses(lastBonusRoundId, bonusRoundId_, balances[addr].add(lastMintAmount)));
    } else {
      amount = computeSnapshotBonuses(user, bonusRoundId_);     
    }
    uint256 referrerEarnings = Lottery.getReferrerEarnings(addr);
    return user.extraEarnings + user.bonusEarnings + amount + referrerEarnings;
  }
  
  /**
   * @dev get bonuses 
   * @param begin begin bonusId
   * @param end end bonusId
   * @param balance the balance in the round 
   * Not use SafeMath, it is core loop, not use SafeMath will be saved 20% gas
   */ 
  function computeRoundBonuses(uint256 begin, uint256 end, uint256 balance) view private returns(uint256) {
    require(begin != 0);
    require(end != 0);  
    
    uint256 amount = 0;
    while (begin < end) {
      uint256 value = balance * bonuses_[begin].payment / bonuses_[begin].currentTotalSupply;      
      amount += value;
      ++begin;    
    }
    return amount;
  }
  
  /**
   * @dev compute snapshot bonuses
   */ 
  function computeSnapshotBonuses(User storage user, uint256 lastBonusRoundId) view private returns(uint256) {
    uint256 amount = 0;
    uint256 length = user.snapshotsLength;
    for (uint256 i = 0; i < length; ++i) {
      uint256 value = computeRoundBonuses(
        user.snapshots[i].bonusIdBegin,
        i < length - 1 ? user.snapshots[i].bonusIdEnd : lastBonusRoundId,
        user.snapshots[i].balance);
      amount = amount.add(value);
    }
    return amount;
  }
    
  /**
   * @dev add earnings from bonuses
   */ 
  function combineBonuses(address addr) private {
    checkLastMint(addr);
    User storage user = users_[addr];
    if (user.snapshotsLength > 0) {
      uint256 amount = computeSnapshotBonuses(user, bonusRoundId_);
      if (amount > 0) {
        user.bonusEarnings = user.bonusEarnings.add(amount);
        user.snapshotsLength = 1;
        user.snapshots[0].balance = balances[addr];
        user.snapshots[0].bonusIdBegin = bonusRoundId_;
        user.snapshots[0].bonusIdEnd = 0;     
      }
    }
    Lottery.checkReferrerEarnings(addr);
  }
  
  /**
   * @dev withdraws all of your earnings
   */
  function withdraw() public {
    combineBonuses(msg.sender);
    uint256 amount = users_[msg.sender].extraEarnings.add(users_[msg.sender].bonusEarnings);
    if (amount > 0) {
      users_[msg.sender].extraEarnings = 0;
      users_[msg.sender].bonusEarnings = 0;
      msg.sender.transfer(amount);
    }
    emit Withdraw(msg.sender, amount);
  }
  
  /**
   * @dev withdraw immediateness to bet
   */ 
  function withdrawForBet(address addr, uint256 value) isLottery external {
    combineBonuses(addr);
    uint256 extraEarnings = users_[addr].extraEarnings; 
    if (extraEarnings >= value) {
      users_[addr].extraEarnings -= value;    
    } else {
      users_[addr].extraEarnings = 0;
      uint256 remain = value - extraEarnings;
      require(users_[addr].bonusEarnings >= remain);
      users_[addr].bonusEarnings -= remain;
    }
    Lottery.deposit.value(value)();
  }
  
  /**
   * @dev get user informations at once
   */
  function getUserInfos(address addr) view public returns(uint256, uint256, uint256) {
    return (
      totalSupply_,
      balanceOf(addr),
      getEarnings(addr)
    );  
  }
}
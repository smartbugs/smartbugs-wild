pragma solidity ^0.4.18;

//====== Open Zeppelin Library =====
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
  function tokenFallback(address from_, uint256 value_, bytes data_) external {
    from_;
    value_;
    data_;
    revert();
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

//====== AGRE Contracts =====

/**
* @title TradeableToken can be bought and sold from/to it's own contract during it's life time
* Sold tokens and Ether received to buy tokens are collected during specified period and then time comes
* contract owner should specify price for the last period and send tokens/ether to their new owners.
*/
contract TradeableToken is StandardToken, Ownable {
    using SafeMath for uint256;

    event Sale(address indexed buyer, uint256 amount);
    event Redemption(address indexed seller, uint256 amount);
    event DistributionError(address seller, uint256 amount);

    /**
    * State of the contract:
    * Collecting - collecting ether and tokens
    * Distribution - distribution of bought tokens and ether is in process
    */
    enum State{Collecting, Distribution}

    State   public currentState;                //Current state of the contract
    uint256 public previousPeriodRate;          //Previous rate: how many tokens one could receive for 1 ether in the last period
    uint256 public currentPeriodEndTimestamp;   //Timestamp after which no more trades are accepted and contract is waiting to start distribution
    uint256 public currentPeriodStartBlock;     //Number of block when current perions was started

    uint256 public currentPeriodRate;           //Current rate: how much tokens one should receive for 1 ether in current distribution period
    uint256 public currentPeriodEtherCollected; //How much ether was collected (to buy tokens) during current period and waiting for distribution
    uint256 public currentPeriodTokenCollected; //How much tokens was collected (to sell tokens) during current period and waiting for distribution

    mapping(address => uint256) receivedEther;  //maps address of buyer to amount of ether he sent
    mapping(address => uint256) soldTokens;     //maps address of seller to amount of tokens he sent

    uint32 constant MILLI_PERCENT_DIVIDER = 100*1000;
    uint32 public buyFeeMilliPercent;           //The buyer's fee in a thousandth of percent. So, if buyer's fee = 5%, then buyFeeMilliPercent = 5000 and if without buyer shoud receive 200 tokens with fee it will receive 200 - (200 * 5000 / MILLI_PERCENT_DIVIDER)
    uint32 public sellFeeMilliPercent;          //The seller's fee in a thousandth of percent. (see above)

    uint256 public minBuyAmount;                //Minimal amount of ether to buy
    uint256 public minSellAmount;               //Minimal amount of tokens to sell

    modifier canBuyAndSell() {
        require(currentState == State.Collecting);
        require(now < currentPeriodEndTimestamp);
        _;
    }

    function TradeableToken() public {
        currentState = State.Distribution;
        //currentPeriodStartBlock = 0;
        currentPeriodEndTimestamp = now;    //ensure that nothing can be collected until new period is started by owner
    }

    /**
    * @notice Send Ether to buy tokens
    */
    function() payable public {
        require(msg.value > 0);
        buy(msg.sender, msg.value);
    }    

    /**
    * @notice Transfer or sell tokens
    * Sells tokens transferred to this contract itself or to zero address
    * @param _to The address to transfer to or token contract address to burn.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        if( (_to == address(this)) || (_to == 0) ){
            return sell(msg.sender, _value);
        }else{
            return super.transfer(_to, _value);
        }
    }

    /**
    * @notice Transfer tokens from one address to another  or sell them if _to is this contract or zero address
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amout of tokens to be transfered
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if( (_to == address(this)) || (_to == 0) ){
            var _allowance = allowed[_from][msg.sender];
            require (_value <= _allowance);
            allowed[_from][msg.sender] = _allowance.sub(_value);
            return sell(_from, _value);
        }else{
            return super.transferFrom(_from, _to, _value);
        }
    }

    /**
    * @dev Fuction called when somebody is buying tokens
    * @param who The address of buyer (who will own bought tokens)
    * @param amount The amount to be transferred.
    */
    function buy(address who, uint256 amount) canBuyAndSell internal returns(bool){
        require(amount >= minBuyAmount);
        currentPeriodEtherCollected = currentPeriodEtherCollected.add(amount);
        receivedEther[who] = receivedEther[who].add(amount);  //if this is first operation from this address, initial value of receivedEther[to] == 0
        Sale(who, amount);
        return true;
    }

    /**
    * @dev Fuction called when somebody is selling his tokens
    * @param who The address of seller (whose tokens are sold)
    * @param amount The amount to be transferred.
    */
    function sell(address who, uint256 amount) canBuyAndSell internal returns(bool){
        require(amount >= minSellAmount);
        currentPeriodTokenCollected = currentPeriodTokenCollected.add(amount);
        soldTokens[who] = soldTokens[who].add(amount);  //if this is first operation from this address, initial value of soldTokens[to] == 0
        totalSupply = totalSupply.sub(amount);
        Redemption(who, amount);
        Transfer(who, address(0), amount);
        return true;
    }
    /**
    * @notice Set fee applied when buying tokens
    * @param _buyFeeMilliPercent fee in thousandth of percent (5% = 5000)
    */
    function setBuyFee(uint32 _buyFeeMilliPercent) onlyOwner public {
        require(_buyFeeMilliPercent < MILLI_PERCENT_DIVIDER);
        buyFeeMilliPercent = _buyFeeMilliPercent;
    }
    /**
    * @notice Set fee applied when selling tokens
    * @param _sellFeeMilliPercent fee in thousandth of percent (5% = 5000)
    */
    function setSellFee(uint32 _sellFeeMilliPercent) onlyOwner public {
        require(_sellFeeMilliPercent < MILLI_PERCENT_DIVIDER);
        sellFeeMilliPercent = _sellFeeMilliPercent;
    }
    /**
    * @notice set minimal amount of ether which can be used to buy tokens
    * @param _minBuyAmount minimal amount of ether
    */
    function setMinBuyAmount(uint256 _minBuyAmount) onlyOwner public {
        minBuyAmount = _minBuyAmount;
    }
    /**
    * @notice set minimal amount of ether which can be used to buy tokens
    * @param _minSellAmount minimal amount of tokens
    */
    function setMinSellAmount(uint256 _minSellAmount) onlyOwner public {
        minSellAmount = _minSellAmount;
    }

    /**
    * @notice Collect ether received for token purshases
    * This is possible both during Collection and Distribution phases
    */
    function collectEther(uint256 amount) onlyOwner public {
        owner.transfer(amount);
    }

    /**
    * @notice Start distribution phase
    * @param _currentPeriodRate exchange rate for current distribution
    */
    function startDistribution(uint256 _currentPeriodRate) onlyOwner public {
        require(currentState != State.Distribution);    //owner should not be able to change rate after distribution is started, ensures that everyone have the same rate
        require(_currentPeriodRate != 0);                //something has to be distributed!
        //require(now >= currentPeriodEndTimestamp)     //DO NOT require period end timestamp passed, because there can be some situations when it is neede to end it sooner. But this should be done with extremal care, because of possible race condition between new sales/purshases and currentPeriodRate definition

        currentState = State.Distribution;
        currentPeriodRate = _currentPeriodRate;
    }

    /**
    * @notice Distribute tokens to buyers
    * @param buyers an array of addresses to pay tokens for their ether. Should be composed from outside by reading Sale events 
    */
    function distributeTokens(address[] buyers) onlyOwner public {
        require(currentState == State.Distribution);
        require(currentPeriodRate > 0);
        for(uint256 i=0; i < buyers.length; i++){
            address buyer = buyers[i];
            require(buyer != address(0));
            uint256 etherAmount = receivedEther[buyer];
            if(etherAmount == 0) continue; //buyer not found or already paid
            uint256 tokenAmount = etherAmount.mul(currentPeriodRate);
            uint256 fee = tokenAmount.mul(buyFeeMilliPercent).div(MILLI_PERCENT_DIVIDER);
            tokenAmount = tokenAmount.sub(fee);
            
            receivedEther[buyer] = 0;
            currentPeriodEtherCollected = currentPeriodEtherCollected.sub(etherAmount);
            //mint tokens
            totalSupply = totalSupply.add(tokenAmount);
            balances[buyer] = balances[buyer].add(tokenAmount);
            Transfer(address(0), buyer, tokenAmount);
        }
    }

    /**
    * @notice Distribute ether to sellers
    * If not enough ether is available on contract ballance
    * @param sellers an array of addresses to pay ether for their tokens. Should be composed from outside by reading Redemption events 
    */
    function distributeEther(address[] sellers) onlyOwner payable public {
        require(currentState == State.Distribution);
        require(currentPeriodRate > 0);
        for(uint256 i=0; i < sellers.length; i++){
            address seller = sellers[i];
            require(seller != address(0));
            uint256 tokenAmount = soldTokens[seller];
            if(tokenAmount == 0) continue; //seller not found or already paid
            uint256 etherAmount = tokenAmount.div(currentPeriodRate);
            uint256 fee = etherAmount.mul(sellFeeMilliPercent).div(MILLI_PERCENT_DIVIDER);
            etherAmount = etherAmount.sub(fee);
            
            soldTokens[seller] = 0;
            currentPeriodTokenCollected = currentPeriodTokenCollected.sub(tokenAmount);
            if(!seller.send(etherAmount)){
                //in this case we can only log error and let owner to handle it manually
                DistributionError(seller, etherAmount);
                owner.transfer(etherAmount); //assume this should not fail..., overwise - change owner
            }
        }
    }

    function startCollecting(uint256 _collectingEndTimestamp) onlyOwner public {
        require(_collectingEndTimestamp > now);      //Need some time for collection
        require(currentState == State.Distribution);    //Do not allow to change collection terms after it is started
        require(currentPeriodEtherCollected == 0);      //All sold tokens are distributed
        require(currentPeriodTokenCollected == 0);      //All redeemed tokens are paid
        previousPeriodRate = currentPeriodRate;
        currentPeriodRate = 0;
        currentPeriodStartBlock = block.number;
        currentPeriodEndTimestamp = _collectingEndTimestamp;
        currentState = State.Collecting;
    }
}

contract AGREToken is TradeableToken, MintableToken, HasNoContracts, HasNoTokens { //MintableToken is StandardToken, Ownable
    string public symbol = "AGRE";
    string public name = "Aggregate Coin";
    uint8 public constant decimals = 18;

    address public founder;    //founder address to allow him transfer tokens while minting
    function init(address _founder, uint32 _buyFeeMilliPercent, uint32 _sellFeeMilliPercent, uint256 _minBuyAmount, uint256 _minSellAmount) onlyOwner public {
        founder = _founder;
        setBuyFee(_buyFeeMilliPercent);
        setSellFee(_sellFeeMilliPercent);
        setMinBuyAmount(_minBuyAmount);
        setMinSellAmount(_minSellAmount);
    }

    /**
     * Allow transfer only after crowdsale finished
     */
    modifier canTransfer() {
        require(mintingFinished || msg.sender == founder);
        _;
    }
    
    function transfer(address _to, uint256 _value) canTransfer public returns(bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns(bool) {
        return super.transferFrom(_from, _to, _value);
    }
}
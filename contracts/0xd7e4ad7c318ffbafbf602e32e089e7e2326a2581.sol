pragma solidity ^0.4.18;

/**
 * DocTailor: https://www.doctailor.com
 */

// ==== Open Zeppelin library ===

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
   @title ERC827 interface, an extension of ERC20 token standard

   Interface of a ERC827 token, following the ERC20 standard with extra
   methods to transfer value and data and execute calls in transfers and
   approvals.
 */
contract ERC827 is ERC20 {

  function approve( address _spender, uint256 _value, bytes _data ) public returns (bool);
  function transfer( address _to, uint256 _value, bytes _data ) public returns (bool);
  function transferFrom( address _from, address _to, uint256 _value, bytes _data ) public returns (bool);

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

/**
   @title ERC827, an extension of ERC20 token standard

   Implementation the ERC827, following the ERC20 standard with extra
   methods to transfer value and data and execute calls in transfers and
   approvals.
   Uses OpenZeppelin StandardToken.
 */
contract ERC827Token is ERC827, StandardToken {

  /**
     @dev Addition to ERC20 token methods. It allows to
     approve the transfer of value and execute a call with the sent data.

     Beware that changing an allowance with this method brings the risk that
     someone may use both the old and the new allowance by unfortunate
     transaction ordering. One possible solution to mitigate this race condition
     is to first reduce the spender's allowance to 0 and set the desired value
     afterwards:
     https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     @param _spender The address that will spend the funds.
     @param _value The amount of tokens to be spent.
     @param _data ABI-encoded contract call to call `_to` address.

     @return true if the call function was executed successfully
   */
  function approve(address _spender, uint256 _value, bytes _data) public returns (bool) {
    require(_spender != address(this));

    super.approve(_spender, _value);

    require(_spender.call(_data));

    return true;
  }

  /**
     @dev Addition to ERC20 token methods. Transfer tokens to a specified
     address and execute a call with the sent data on the same transaction

     @param _to address The address which you want to transfer to
     @param _value uint256 the amout of tokens to be transfered
     @param _data ABI-encoded contract call to call `_to` address.

     @return true if the call function was executed successfully
   */
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));

    super.transfer(_to, _value);

    require(_to.call(_data));
    return true;
  }

  /**
     @dev Addition to ERC20 token methods. Transfer tokens from one address to
     another and make a contract call on the same transaction

     @param _from The address which you want to send tokens from
     @param _to The address which you want to transfer to
     @param _value The amout of tokens to be transferred
     @param _data ABI-encoded contract call to call `_to` address.

     @return true if the call function was executed successfully
   */
  function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));

    super.transferFrom(_from, _to, _value);

    require(_to.call(_data));
    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Increase the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function increaseApproval(address _spender, uint _addedValue, bytes _data) public returns (bool) {
    require(_spender != address(this));

    super.increaseApproval(_spender, _addedValue);

    require(_spender.call(_data));

    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Decrease the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function decreaseApproval(address _spender, uint _subtractedValue, bytes _data) public returns (bool) {
    require(_spender != address(this));

    super.decreaseApproval(_spender, _subtractedValue);

    require(_spender.call(_data));

    return true;
  }

}

// ==== DOCT Contracts ===

contract DOCTToken is MintableToken, ERC827Token, NoOwner {
    string public symbol = 'DOCT';
    string public name = 'DocTailor';
    uint8 public constant decimals = 8;

    address founder;                //founder address to allow him transfer tokens even when transfers disabled
    bool public transferEnabled;    //allows to dissable transfers while minting and in case of emergency

    function setFounder(address _founder) onlyOwner public {
        founder = _founder;
    }
    function setTransferEnabled(bool enable) onlyOwner public {
        transferEnabled = enable;
    }
    modifier canTransfer() {
        require( transferEnabled || msg.sender == founder || msg.sender == owner);
        _;
    }
    
    function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    function transfer(address _to, uint256 _value, bytes _data) canTransfer public returns (bool) {
        return super.transfer(_to, _value, _data);
    }
    function transferFrom(address _from, address _to, uint256 _value, bytes _data) canTransfer public returns (bool) {
        return super.transferFrom(_from, _to, _value, _data);
    }
}

/**
 * @title DocTailor Crowdsale
 */
contract DOCTCrowdsale is Ownable, HasNoContracts, CanReclaimToken, Destructible {
    using SafeMath for uint256;

    uint256 constant  DOCT_TO_ETH_DECIMALS = 10000000000;    //Need this because ETH decimals is 18, while DOCT decimals is 8.

    DOCTToken public token;

    struct Round {
        uint256 start;          //Timestamp of crowdsale round start
        uint256 end;            //Timestamp of crowdsale round end
        uint256 rate;           //Rate: how much TOKEN one will get fo 1 ETH during this round
        uint256 rateBulk;       //Rate for bulk purshases
        uint256 bulkThreshold;  //If purshase more than this amount, bulk rate applied
    }
    Round[] public rounds;          //Array of crowdsale rounds
    uint256 public hardCap;         //Max amount of tokens to mint
    uint256 public tokensMinted;    //Amount of tokens already minted
    bool public finalized;          //crowdsale is finalized

    function DOCTCrowdsale (
        uint256 _hardCap,
        uint256[] roundStarts,
        uint256[] roundEnds,
        uint256[] roundRates,
        uint256[] roundRatesBulk,
        uint256[] roundBulkThreshold
    ) public {
        token = new DOCTToken();
        token.setFounder(owner);
        token.setTransferEnabled(false);

        tokensMinted = token.totalSupply();

        //Check all paramaters are correct and create rounds
        require(_hardCap > 0);                    //Need something to sell
        hardCap = _hardCap;

        initRounds(roundStarts, roundEnds, roundRates, roundRatesBulk, roundBulkThreshold);
    }
    function initRounds(uint256[] roundStarts, uint256[] roundEnds, uint256[] roundRates, uint256[] roundRatesBulk, uint256[] roundBulkThreshold) internal {
        require(
            (roundStarts.length > 0)  &&                //There should be at least one round
            (roundStarts.length == roundEnds.length) &&
            (roundStarts.length == roundRates.length) &&
            (roundStarts.length == roundRatesBulk.length) &&
            (roundStarts.length == roundBulkThreshold.length)
        );                   
        uint256 prevRoundEnd = now;
        rounds.length = roundStarts.length;             //initialize rounds array
        for(uint8 i=0; i < roundStarts.length; i++){
            rounds[i] = Round({start:roundStarts[i], end:roundEnds[i], rate:roundRates[i], rateBulk:roundRatesBulk[i], bulkThreshold:roundBulkThreshold[i]});
            Round storage r = rounds[i];
            require(prevRoundEnd <= r.start);
            require(r.start < r.end);
            require(r.bulkThreshold > 0);
            prevRoundEnd = rounds[i].end;
        }
    }
    function setRound(uint8 roundNum, uint256 start, uint256 end, uint256 rate, uint256 rateBulk, uint256 bulkThreshold) onlyOwner external {
        uint8 round = roundNum-1;
        if(round > 0){
            require(rounds[round - 1].end <= start);
        }
        if(round < rounds.length - 1){
            require(end <= rounds[round + 1].start);   
        }
        rounds[round].start = start;
        rounds[round].end = end;
        rounds[round].rate = rate;
        rounds[round].rateBulk = rateBulk;
        rounds[round].bulkThreshold = bulkThreshold;
    }


    /**
    * @notice Buy tokens
    */
    function() payable public {
        require(msg.value > 0);
        require(crowdsaleRunning());

        uint256 rate = currentRate(msg.value);
        require(rate > 0);
        uint256 tokens = rate.mul(msg.value).div(DOCT_TO_ETH_DECIMALS);
        mintTokens(msg.sender, tokens);
    }

    /**
    * @notice Mint tokens for purshases with Non-Ether currencies
    * @param beneficiary whom to send tokend
    * @param amount how much tokens to send
    * param message reason why we are sending tokens (not stored anythere, only in transaction itself)
    */
    function saleNonEther(address beneficiary, uint256 amount, string /*message*/) onlyOwner external{
        mintTokens(beneficiary, amount);
    }

    /**
    * @notice Bulk mint tokens (different amounts)
    * @param beneficiaries array whom to send tokend
    * @param amounts array how much tokens to send
    * param message reason why we are sending tokens (not stored anythere, only in transaction itself)
    */
    function bulkTokenSend(address[] beneficiaries, uint256[] amounts, string /*message*/) onlyOwner external{
        require(beneficiaries.length == amounts.length);
        for(uint32 i=0; i < beneficiaries.length; i++){
            mintTokens(beneficiaries[i], amounts[i]);
        }
    }
    /**
    * @notice Bulk mint tokens (same amounts)
    * @param beneficiaries array whom to send tokend
    * @param amount how much tokens to send
    * param message reason why we are sending tokens (not stored anythere, only in transaction itself)
    */
    function bulkTokenSend(address[] beneficiaries, uint256 amount, string /*message*/) onlyOwner external{
        require(amount > 0);
        for(uint32 i=0; i < beneficiaries.length; i++){
            mintTokens(beneficiaries[i], amount);
        }
    }

    /**
    * @notice Shows if crowdsale is running
    */ 
    function crowdsaleRunning() constant public returns(bool){
        return !finalized && (tokensMinted < hardCap) && (currentRoundNum() > 0);
    }

    /**
    * @notice Fetches current Round number
    * @return round number (index in rounds array + 1) or 0 if none
    */
    function currentRoundNum() view public returns(uint8) {
        for(uint8 i=0; i < rounds.length; i++){
            if( (now > rounds[i].start) && (now <= rounds[i].end) ) return i+1;
        }
        return 0;
    }
    /**
    * @notice Fetches current rate (how many tokens you get for 1 ETH)
    * @param amount how much ether is received
    * @return calculated rate or zero if no round of crowdsale is running
    */
    function currentRate(uint256 amount) view public returns(uint256) {
        uint8 roundNum = currentRoundNum();
        if(roundNum == 0) {
            return 0;
        }else{
            uint8 round = roundNum-1;
            if(amount < rounds[round].bulkThreshold){
                return rounds[round].rate;
            }else{
                return rounds[round].rateBulk;
            }
        }
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
    * @notice Sends collected funds to owner
    */
    function claimEther() public onlyOwner {
        if(this.balance > 0){
            owner.transfer(this.balance);
        }
    }

    /**
    * @notice Finalizes ICO: changes token ownership to founder, allows token transfers
    */
    function finalizeCrowdsale() onlyOwner public {
        finalized = true;
        assert(token.finishMinting());
        token.setTransferEnabled(true);
        token.transferOwnership(owner);
        claimEther();
    }

}
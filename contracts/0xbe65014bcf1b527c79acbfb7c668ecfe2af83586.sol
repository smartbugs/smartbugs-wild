pragma solidity ^0.4.18;

/**
 * WorldCoin: https://worldcoin.cash
 */

//====== Open Zeppelin Library =====
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


//====== BurnableToken =====

contract BurnableToken is StandardToken {
    using SafeMath for uint256;

    event Burn(address indexed from, uint256 amount);
    event BurnRewardIncreased(address indexed from, uint256 value);

    /**
    * @dev Sending ether to contract increases burning reward 
    */
    function() payable public {
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



//====== WorldCoin Contracts =====

/**
 * @title WorldCoin token
 */
contract WorldCoin is BurnableToken, MintableToken, HasNoContracts, HasNoTokens { //MintableToken is StandardToken, Ownable
    using SafeMath for uint256;

    string public name = "World Coin Network";
    string public symbol = "WCN";
    uint256 public decimals = 18;


    /**
     * Allow transfer only after crowdsale finished
     */
    modifier canTransfer() {
        require(mintingFinished);
        _;
    }
    
    function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
        return BurnableToken.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
        return BurnableToken.transferFrom(_from, _to, _value);
    }

}

/**
 * @title WorldCoin Crowdsale
 */
contract WorldCoinCrowdsale is Ownable, HasNoContracts, HasNoTokens {
    using SafeMath for uint256;

    uint32 private constant PERCENT_DIVIDER = 100;

    WorldCoin public token;

    struct Round {
        uint256 start;      //Timestamp of crowdsale round start
        uint256 end;        //Timestamp of crowdsale round end
        uint256 rate;       //Rate: how much TOKEN one will get fo 1 ETH during this round
    }
    Round[] public rounds;  //Array of crowdsale rounds


    uint256 public founderPercent;      //how many tokens will be sent to founder (percent of purshased token)
    uint256 public partnerBonusPercent; //referral partner bonus (percent of purshased token)
    uint256 public referralBonusPercent;//referral buyer bonus (percent of purshased token)
    uint256 public hardCap;             //Maximum amount of tokens mined
    uint256 public totalCollected;      //total amount of collected funds (in ethereum wei)
    uint256 public tokensMinted;        //total amount of minted tokens
    bool public finalized;              //crowdsale is finalized

    /**
     * @dev WorldCoin Crowdsale Contract
     * @param _founderPercent Amount of tokens sent to founder with each purshase (percent of purshased token)
     * @param _partnerBonusPercent Referral partner bonus (percent of purshased token)
     * @param _referralBonusPercent Referral buyer bonus (percent of purshased token)
     * @param _hardCap Maximum amount of ether (in wei) to be collected during crowdsale
     * @param roundStarts List of round start timestams
     * @param roundEnds List of round end timestams 
     * @param roundRates List of round rates (tokens for 1 ETH)
     */
    function WorldCoinCrowdsale (
        uint256 _founderPercent,
        uint256 _partnerBonusPercent,
        uint256 _referralBonusPercent,
        uint256 _hardCap,
        uint256[] roundStarts,
        uint256[] roundEnds,
        uint256[] roundRates
    ) public {

        //Check all paramaters are correct and create rounds
        require(_hardCap > 0);                    //Need something to sell
        require(
            (roundStarts.length > 0)  &&                //There should be at least one round
            (roundStarts.length == roundEnds.length) &&
            (roundStarts.length == roundRates.length)
        );                   
        uint256 prevRoundEnd = now;
        rounds.length = roundStarts.length;             //initialize rounds array
        for(uint8 i=0; i < roundStarts.length; i++){
            rounds[i] = Round(roundStarts[i], roundEnds[i], roundRates[i]);
            Round storage r = rounds[i];
            require(prevRoundEnd <= r.start);
            require(r.start < r.end);
            require(r.rate > 0);
            prevRoundEnd = rounds[i].end;
        }

        hardCap = _hardCap;
        partnerBonusPercent = _partnerBonusPercent;
        referralBonusPercent = _referralBonusPercent;
        founderPercent = _founderPercent;
        //founderPercentWithReferral = founderPercent * (rate + partnerBonusPercent + referralBonusPercent) / rate;  //Did not use SafeMath here, because this parameters defined by contract creator should not be malicious. Also have checked result on the next line.
        //assert(founderPercentWithReferral >= founderPercent);

        token = new WorldCoin();
    }

    /**
    * @dev Fetches current Round number
    * @return round number (index in rounds array + 1) or 0 if none
    */
    function currentRoundNum() constant public returns(uint8) {
        for(uint8 i=0; i < rounds.length; i++){
            if( (now > rounds[i].start) && (now <= rounds[i].end) ) return i+1;
        }
        return 0;
    }
    /**
    * @dev Fetches current rate (how many tokens you get for 1 ETH)
    * @return calculated rate or zero if no round of crowdsale is running
    */
    function currentRate() constant public returns(uint256) {
        uint8 roundNum = currentRoundNum();
        if(roundNum == 0) {
            return 0;
        }else{
            return rounds[roundNum-1].rate;
        }
    }

    function firstRoundStartTimestamp() constant public returns(uint256){
        return rounds[0].start;
    }
    function lastRoundEndTimestamp() constant public returns(uint256){
        return rounds[rounds.length - 1].end;
    }

    /**
    * @dev Shows if crowdsale is running
    */ 
    function crowdsaleRunning() constant public returns(bool){
        return !finalized && (tokensMinted < hardCap) && (currentRoundNum() > 0);
    }

    /**
    * @dev Buy WorldCoin tokens
    */
    function() payable public {
        sale(msg.sender, 0x0);
    } 

    /**
    * @dev Buy WorldCoin tokens witn referral program
    */
    function sale(address buyer, address partner) public payable {
        if(!crowdsaleRunning()) revert();
        require(msg.value > 0);
        uint256 rate = currentRate();
        assert(rate > 0);

        uint256 referralTokens; uint256 partnerTokens; uint256 ownerTokens;
        uint256 tokens = rate.mul(msg.value);
        assert(tokens > 0);
        totalCollected = totalCollected.add(msg.value);
        if(partner == 0x0){
            ownerTokens     = tokens.mul(founderPercent).div(PERCENT_DIVIDER);
            mintTokens(buyer, tokens);
            mintTokens(owner, ownerTokens);
        }else{
            partnerTokens   = tokens.mul(partnerBonusPercent).div(PERCENT_DIVIDER);
            referralTokens  = tokens.mul(referralBonusPercent).div(PERCENT_DIVIDER);
            ownerTokens     = (tokens.add(partnerTokens).add(referralTokens)).mul(founderPercent).div(PERCENT_DIVIDER);
            
            uint256 totalBuyerTokens = tokens.add(referralTokens);
            mintTokens(buyer, totalBuyerTokens);
            mintTokens(partner, partnerTokens);
            mintTokens(owner, ownerTokens);
        }
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
    * @notice Updates rate for the round
    */
    function setRoundRate(uint32 roundNum, uint256 rate) public onlyOwner {
        require(roundNum < rounds.length);
        rounds[roundNum].rate = rate;
    }


    /**
    * @notice Sends collected funds to owner
    * May be executed only if goal reached and no refunds are possible
    */
    function claimEther() public onlyOwner {
        if(this.balance > 0){
            owner.transfer(this.balance);
        }
    }

    /**
    * @notice Finalizes ICO when one of conditions met:
    * - end time reached OR
    * - no more tokens available (cap reached) OR
    * - message sent by owner
    */
    function finalizeCrowdsale() public {
        require ( (now > lastRoundEndTimestamp()) || (totalCollected == hardCap) || (msg.sender == owner) );
        finalized = token.finishMinting();
        token.transferOwnership(owner);
        if(this.balance > 0){
            owner.transfer(this.balance);
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
}
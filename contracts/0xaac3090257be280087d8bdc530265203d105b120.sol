pragma solidity ^0.4.11;


/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

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


/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        owner = msg.sender;
    }

    address public newOwner;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }


    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}


contract ERC20Protocol {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint supply);
    is replaced with:
    uint public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract StandardToken is ERC20Protocol {
    using SafeMath for uint;

    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) onlyPayloadSize(2 * 32) returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        assert((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
}

/// @title Wanchain Token Contract
/// For more information about this token sale, please visit https://wanchain.org
/// @author Cathy - <cathy@wanchain.org>
contract WanToken is StandardToken {
    using SafeMath for uint;

    /// Constant token specific fields
    string public constant name = "WanCoin";
    string public constant symbol = "WAN";
    uint public constant decimals = 18;

    /// Wanchain total tokens supply
    uint public constant MAX_TOTAL_TOKEN_AMOUNT = 210000000 ether;

    /// Fields that are only changed in constructor
    /// Wanchain contribution contract
    address public minter; 
    /// ICO start time
    uint public startTime;
    /// ICO end time
    uint public endTime;

    /// Fields that can be changed by functions
    mapping (address => uint) public lockedBalances;
    /*
     * MODIFIERS
     */

    modifier onlyMinter {
        assert(msg.sender == minter);
        _;
    }

    modifier isLaterThan (uint x){
        assert(now > x);
        _;
    }

    modifier maxWanTokenAmountNotReached (uint amount){
        assert(totalSupply.add(amount) <= MAX_TOTAL_TOKEN_AMOUNT);
        _;
    }

    /**
     * CONSTRUCTOR 
     * 
     * @dev Initialize the Wanchain Token
     * @param _minter The Wanchain Contribution Contract     
     * @param _startTime ICO start time
     * @param _endTime ICO End Time
     */
    function WanToken(address _minter, uint _startTime, uint _endTime){
        minter = _minter;
        startTime = _startTime;
        endTime = _endTime;
    }

    /**
     * EXTERNAL FUNCTION 
     * 
     * @dev Contribution contract instance mint token
     * @param receipent The destination account owned mint tokens    
     * @param amount The amount of mint token
     * be sent to this address.
     */    
    function mintToken(address receipent, uint amount)
        external
        onlyMinter
        maxWanTokenAmountNotReached(amount)
        returns (bool)
    {
        require(now <= endTime);
        lockedBalances[receipent] = lockedBalances[receipent].add(amount);
        totalSupply = totalSupply.add(amount);
        return true;
    }

    /*
     * PUBLIC FUNCTIONS
     */

    /// @dev Locking period has passed - Locked tokens have turned into tradeable
    ///      All tokens owned by receipent will be tradeable
    function claimTokens(address receipent)
        public
        onlyMinter
    {
        balances[receipent] = balances[receipent].add(lockedBalances[receipent]);
        lockedBalances[receipent] = 0;
    }

    /*
     * CONSTANT METHODS
     */
    function lockedBalanceOf(address _owner) constant returns (uint balance) {
        return lockedBalances[_owner];
    }
}

/// @title Wanchain Contribution Contract
/// ICO Rules according: https://www.wanchain.org/crowdsale
/// For more information about this token sale, please visit https://wanchain.org
/// @author Zane Liang - <zaneliang@wanchain.org>
contract WanchainContribution is Owned {
    using SafeMath for uint;

    /// Constant fields
    /// Wanchain total tokens supply
    uint public constant WAN_TOTAL_SUPPLY = 210000000 ether;
    uint public constant EARLY_CONTRIBUTION_DURATION = 24 hours;
    uint public constant MAX_CONTRIBUTION_DURATION = 3 weeks;

    /// Exchange rates for first phase
    uint public constant PRICE_RATE_FIRST = 880;
    /// Exchange rates for second phase
    uint public constant PRICE_RATE_SECOND = 790;
    /// Exchange rates for last phase
    uint public constant PRICE_RATE_LAST = 750;

    /// ----------------------------------------------------------------------------------------------------
    /// |                                                  |                    |                 |        |
    /// |        PUBLIC SALE (PRESALE + OPEN SALE)         |      DEV TEAM      |    FOUNDATION   |  MINER |
    /// |                       51%                        |         20%        |       19%       |   10%  |    
    /// ----------------------------------------------------------------------------------------------------
      /// OPEN_SALE_STAKE + PRESALE_STAKE = 51; 51% sale for public
    uint public constant OPEN_SALE_STAKE = 510;  // 51% for open sale

    // Reserved stakes
    uint public constant DEV_TEAM_STAKE = 200;   // 20%
    uint public constant FOUNDATION_STAKE = 190; // 19%
    uint public constant MINERS_STAKE = 100;     // 10%

    uint public constant DIVISOR_STAKE = 1000;

    uint public constant PRESALE_RESERVERED_AMOUNT = 41506655 ether; //presale prize amount(40000*880)
  
    /// Holder address for presale and reserved tokens
    /// TODO: change addressed before deployed to main net

    // Addresses of Patrons
    address public constant DEV_TEAM_HOLDER = 0x0001cdC69b1eb8bCCE29311C01092Bdcc92f8f8F;
    address public constant FOUNDATION_HOLDER = 0x00dB4023b32008C45E62Add57De256a9399752D4;
    address public constant MINERS_HOLDER = 0x00f870D11eA43AA1c4C715c61dC045E32d232787;
    address public constant PRESALE_HOLDER = 0x00577c25A81fA2401C5246F4a7D5ebaFfA4b00Aa;
  
    uint public MAX_OPEN_SOLD = WAN_TOTAL_SUPPLY * OPEN_SALE_STAKE / DIVISOR_STAKE - PRESALE_RESERVERED_AMOUNT;

    /// Fields that are only changed in constructor    
    /// All deposited ETH will be instantly forwarded to this address.
    address public wanport;
    /// Early Adopters reserved start time
    uint public earlyReserveBeginTime;
    /// Contribution start time
    uint public startTime;
    /// Contribution end time
    uint public endTime;

    /// Fields that can be changed by functions
    /// Accumulator for open sold tokens
    uint public openSoldTokens;
    /// Due to an emergency, set this to true to halt the contribution
    bool public halted; 
    /// ERC20 compilant wanchain token contact instance
    WanToken public wanToken; 

    /// Quota for early adopters sale, Quota
    mapping (address => uint256) public earlyUserQuotas;
    /// tags show address can join in open sale
    mapping (address => uint256) public fullWhiteList;

    uint256 public normalBuyLimit = 65 ether;

    /*
     * EVENTS
     */

    event NewSale(address indexed destAddress, uint ethCost, uint gotTokens);
    //event PartnerAddressQuota(address indexed partnerAddress, uint quota);

    /*
     * MODIFIERS
     */

    modifier onlyWallet {
        require(msg.sender == wanport);
        _;
    }

    modifier notHalted() {
        require(!halted);
        _;
    }

    modifier initialized() {
        require(address(wanport) != 0x0);
        _;
    }    

    modifier notEarlierThan(uint x) {
        require(now >= x);
        _;
    }

    modifier earlierThan(uint x) {
        require(now < x);
        _;
    }

    modifier ceilingNotReached() {
        require(openSoldTokens < MAX_OPEN_SOLD);
        _;
    }  

    modifier isSaleEnded() {
        require(now > endTime || openSoldTokens >= MAX_OPEN_SOLD);
        _;
    }


    /**
     * CONSTRUCTOR 
     * 
     * @dev Initialize the Wanchain contribution contract
     * @param _wanport The escrow account address, all ethers will be sent to this address.
     * @param _bootTime ICO boot time
     */
    function WanchainContribution(address _wanport, uint _bootTime){
      require(_wanport != 0x0);

        halted = false;
      wanport = _wanport;
        earlyReserveBeginTime = _bootTime;
      startTime = earlyReserveBeginTime + EARLY_CONTRIBUTION_DURATION;
      endTime = startTime + MAX_CONTRIBUTION_DURATION;
        openSoldTokens = 0;
        /// Create wanchain token contract instance
      wanToken = new WanToken(this,startTime, endTime);

        /// Reserve tokens according wanchain ICO rules
      uint stakeMultiplier = WAN_TOTAL_SUPPLY / DIVISOR_STAKE;
    
        wanToken.mintToken(DEV_TEAM_HOLDER, DEV_TEAM_STAKE * stakeMultiplier);
        wanToken.mintToken(FOUNDATION_HOLDER, FOUNDATION_STAKE * stakeMultiplier);
        wanToken.mintToken(MINERS_HOLDER, MINERS_STAKE * stakeMultiplier);
    
        wanToken.mintToken(PRESALE_HOLDER, PRESALE_RESERVERED_AMOUNT);    
    
    }

    /**
     * Fallback function 
     * 
     * @dev If anybody sends Ether directly to this  contract, consider he is getting wan token
     */
    function () public payable {
      buyWanCoin(msg.sender);
    }

    /*
     * PUBLIC FUNCTIONS
     */

    /// @dev Exchange msg.value ether to WAN for account recepient
    /// @param receipient WAN tokens receiver
    function buyWanCoin(address receipient) 
        public 
        payable 
        notHalted 
        initialized 
        ceilingNotReached 
        notEarlierThan(earlyReserveBeginTime)
        earlierThan(endTime)
        returns (bool) 
    {
        require(receipient != 0x0);
        require(msg.value >= 0.1 ether);

        // Do not allow contracts to game the system
        require(!isContract(msg.sender));        

        if( now < startTime && now >= earlyReserveBeginTime)
            buyEarlyAdopters(receipient);
        else {
            require( tx.gasprice <= 50000000000 wei );
            require(msg.value <= normalBuyLimit);
            buyNormal(receipient);
        }

        return true;
    }

    function setNormalBuyLimit(uint256 limit)
        public
        initialized
        onlyOwner
        earlierThan(endTime)
    {
        normalBuyLimit = limit;
    }


    /// @dev batch set quota for early user quota
    function setEarlyWhitelistQuotas(address[] users, uint earlyCap, uint openTag)
        public
        onlyOwner
        earlierThan(earlyReserveBeginTime)
    {
        for( uint i = 0; i < users.length; i++) {
            earlyUserQuotas[users[i]] = earlyCap;
            fullWhiteList[users[i]] = openTag;
        }
    }

    /// @dev batch set quota for early user quota
    function setLaterWhiteList(address[] users, uint openTag)
        public
        onlyOwner
        earlierThan(endTime)
    {
        require(saleNotEnd());
        for( uint i = 0; i < users.length; i++) {
            fullWhiteList[users[i]] = openTag;
        }
    }

    /// @dev Emergency situation that requires contribution period to stop.
    /// Contributing not possible anymore.
    function halt() public onlyWallet{
        halted = true;
    }

    /// @dev Emergency situation resolved.
    /// Contributing becomes possible again withing the outlined restrictions.
    function unHalt() public onlyWallet{
        halted = false;
    }

    /// @dev Emergency situation
    function changeWalletAddress(address newAddress) onlyWallet { 
        wanport = newAddress; 
    }

    /// @return true if sale not ended, false otherwise.
    function saleNotEnd() constant returns (bool) {
        return now < endTime && openSoldTokens < MAX_OPEN_SOLD;
    }

    /// CONSTANT METHODS
    /// @dev Get current exchange rate
    function priceRate() public constant returns (uint) {
        // Three price tiers
        if (earlyReserveBeginTime <= now && now < startTime + 1 weeks)
            return PRICE_RATE_FIRST;
        if (startTime + 1 weeks <= now && now < startTime + 2 weeks)
            return PRICE_RATE_SECOND;
        if (startTime + 2 weeks <= now && now < endTime)
            return PRICE_RATE_LAST;
        // Should not be called before or after contribution period
        assert(false);
    }

    function claimTokens(address receipent)
        public
        isSaleEnded
    {
        wanToken.claimTokens(receipent);
    }

    /*
     * INTERNAL FUNCTIONS
     */

    /// @dev Buy wanchain tokens for early adopters
    function buyEarlyAdopters(address receipient) internal {
      uint quotaAvailable = earlyUserQuotas[receipient];
      require(quotaAvailable > 0);

        uint toFund = quotaAvailable.min256(msg.value);
        uint tokenAvailable4Adopter = toFund.mul(PRICE_RATE_FIRST);

      earlyUserQuotas[receipient] = earlyUserQuotas[receipient].sub(toFund);
      buyCommon(receipient, toFund, tokenAvailable4Adopter);
    }

    /// @dev Buy wanchain token normally
    function buyNormal(address receipient) internal {
        uint inWhiteListTag = fullWhiteList[receipient];
        require(inWhiteListTag > 0);

        // protect partner quota in stage one
        uint tokenAvailable = MAX_OPEN_SOLD.sub(openSoldTokens);
        require(tokenAvailable > 0);

      uint toFund;
      uint toCollect;
      (toFund, toCollect) = costAndBuyTokens(tokenAvailable);
        buyCommon(receipient, toFund, toCollect);
    }

    /// @dev Utility function for bug wanchain token
    function buyCommon(address receipient, uint toFund, uint wanTokenCollect) internal {
        require(msg.value >= toFund); // double check

        if(toFund > 0) {
            require(wanToken.mintToken(receipient, wanTokenCollect));         
            wanport.transfer(toFund);
            openSoldTokens = openSoldTokens.add(wanTokenCollect);
            NewSale(receipient, toFund, wanTokenCollect);            
        }

        uint toReturn = msg.value.sub(toFund);
        if(toReturn > 0) {
            msg.sender.transfer(toReturn);
        }
    }

    /// @dev Utility function for calculate available tokens and cost ethers
    function costAndBuyTokens(uint availableToken) constant internal returns (uint costValue, uint getTokens){
      // all conditions has checked in the caller functions
      uint exchangeRate = priceRate();
      getTokens = exchangeRate * msg.value;

      if(availableToken >= getTokens){
        costValue = msg.value;
      } else {
        costValue = availableToken / exchangeRate;
        getTokens = availableToken;
      }
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
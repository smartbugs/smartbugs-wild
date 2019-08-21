pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        Unpause();
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
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}


/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
    using SafeMath for uint256;

    enum State { Active, Refunding, Closed }

    mapping (address => uint256) public deposited;
    address public wallet;
    State public state;

    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);

    function RefundVault(address _wallet) public {
        require(_wallet != 0x0);
        wallet = _wallet;
        state = State.Active;
    }

    function deposit(address investor) public onlyOwner  payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function close() public onlyOwner {
        require(state == State.Active);
        state = State.Closed;
        Closed();
        wallet.transfer(this.balance);
    }

    function enableRefunds() public onlyOwner {
        require(state == State.Active);
        state = State.Refunding;
        RefundsEnabled();
    }

    function refund(address investor) public {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

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
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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


contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}


contract ApplauseCashToken is StandardToken, PausableToken {
    string public constant name = "ApplauseCash";
    string public constant symbol = "APLC";
    uint8 public constant decimals = 4;
    uint256 public INITIAL_SUPPLY = 300000000 * 10000;

    function ApplauseCashToken() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}



/**
 * @title Crowdsale
 * @dev Modified contract for managing a token crowdsale.
 * ApplauseCashCrowdsale have pre-sale and main sale periods,
 * where investors can make token purchases and the crowdsale will assign
 * them tokens based on a token per ETH rate and the system of bonuses.
 * Funds collected are forwarded to a wallet as they arrive.
 * pre-sale and main sale periods both have caps defined in tokens.
 */

contract ApplauseCashCrowdsale is Ownable {

    using SafeMath for uint256;

    struct Bonus {
        uint duration;
        uint percent;
    }

    // minimum amount of funds to be raised in tokens
    uint256 public softcap;

    // refund vault used to hold funds while crowdsale is running
    RefundVault public vault;

    // true for finalised crowdsale
    bool public isFinalized;

    // The token being sold
    ApplauseCashToken public token = new ApplauseCashToken();

    // start and end timestamps where pre-investments are allowed (both inclusive)
    uint256 public preIcoStartTime;
    uint256 public preIcoEndTime;

    // start and end timestamps where main-investments are allowed (both inclusive)
    uint256 public icoStartTime;
    uint256 public icoEndTime;

    // maximum amout of tokens for pre-sale and main sale
    uint256 public preIcoHardcap;
    uint256 public icoHardcap;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per ETH
    uint256 public rate;

    // amount of raised tokens
    uint256 public tokensInvested;

    Bonus[] public preIcoBonuses;
    Bonus[] public icoBonuses;

    // Invstors can't invest less then specified numbers in wei
    uint256 public preIcoMinimumWei;
    uint256 public icoMinimumWei;

    // Default bonus %
    uint256 public defaultPercent;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function ApplauseCashCrowdsale(
        uint256 _preIcoStartTime,
        uint256 _preIcoEndTime,
        uint256 _preIcoHardcap,
        uint256 _icoStartTime,
        uint256 _icoEndTime,
        uint256 _icoHardcap,
        uint256 _softcap,
        uint256 _rate,
        address _wallet
    ) public {

        //require(_softcap > 0);

        // can't start pre-sale in the past
        require(_preIcoStartTime >= now);

        // can't start main sale in the past
        require(_icoStartTime >= now);

        // can't start main sale before the end of pre-sale
        require(_preIcoEndTime < _icoStartTime);

        // the end of pre-sale can't happen before it's start
        require(_preIcoStartTime < _preIcoEndTime);

        // the end of main sale can't happen before it's start
        require(_icoStartTime < _icoEndTime);

        require(_rate > 0);
        require(_preIcoHardcap > 0);
        require(_icoHardcap > 0);
        require(_wallet != 0x0);

        preIcoMinimumWei = 20000000000000000;  // 0.02 Ether default minimum
        icoMinimumWei = 20000000000000000; // 0.02 Ether default minimum
        defaultPercent = 0;

        preIcoBonuses.push(Bonus({duration: 1 hours, percent: 90}));
        preIcoBonuses.push(Bonus({duration: 6 days + 5 hours, percent: 50}));

        icoBonuses.push(Bonus({duration: 1 hours, percent: 45}));
        icoBonuses.push(Bonus({duration: 7 days + 15 hours, percent: 40}));
        icoBonuses.push(Bonus({duration: 6 days, percent: 30}));
        icoBonuses.push(Bonus({duration: 6 days, percent: 20}));
        icoBonuses.push(Bonus({duration: 7 days, percent: 10}));

        preIcoStartTime = _preIcoStartTime;
        preIcoEndTime = _preIcoEndTime;
        preIcoHardcap = _preIcoHardcap;
        icoStartTime = _icoStartTime;
        icoEndTime = _icoEndTime;
        icoHardcap = _icoHardcap;
        softcap = _softcap;
        rate = _rate;
        wallet = _wallet;

        isFinalized = false;

        vault = new RefundVault(wallet);
    }

    // fallback function can be used to buy tokens
    function () public payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {

        require(beneficiary != 0x0);
        require(msg.value != 0);
        require(!isFinalized);

        uint256 weiAmount = msg.value;

        validateWithinPeriods();

        // calculate token amount to be created.
        // ETH and our tokens have different numbers of decimals after comma
        // ETH - 18 decimals, our tokes - 4. so we need to divide our value
        // by 1e14 (18 - 4 == 14).
        uint256 tokens = weiAmount.mul(rate).div(100000000000000);

        uint256 percent = getBonusPercent(now);

        // add bonus to tokens depends on the period
        uint256 bonusedTokens = applyBonus(tokens, percent);

        validateWithinCaps(bonusedTokens, weiAmount);

        // update state
        tokensInvested = tokensInvested.add(bonusedTokens);
        token.transfer(beneficiary, bonusedTokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, bonusedTokens);

        forwardFunds();
    }
    
    // owner can transfer tokens
    function transferTokens(address beneficiary, uint256 tokens) public onlyOwner {
        token.transfer(beneficiary, tokens);
    }

    // set new dates for pre-salev (emergency case)
    function setPreIcoParameters(
        uint256 _preIcoStartTime,
        uint256 _preIcoEndTime,
        uint256 _preIcoHardcap,
        uint256 _preIcoMinimumWei
    ) public onlyOwner {
        require(!isFinalized);
        require(_preIcoStartTime < _preIcoEndTime);
        require(_preIcoHardcap > 0);
        preIcoStartTime = _preIcoStartTime;
        preIcoEndTime = _preIcoEndTime;
        preIcoHardcap = _preIcoHardcap;
        preIcoMinimumWei = _preIcoMinimumWei;
    }

    // set new dates for main-sale (emergency case)
    function setIcoParameters(
        uint256 _icoStartTime,
        uint256 _icoEndTime,
        uint256 _icoHardcap,
        uint256 _icoMinimumWei
    ) public onlyOwner {

        require(!isFinalized);
        require(_icoStartTime < _icoEndTime);
        require(_icoHardcap > 0);
        icoStartTime = _icoStartTime;
        icoEndTime = _icoEndTime;
        icoHardcap = _icoHardcap;
        icoMinimumWei = _icoMinimumWei;
    }

    // set new wallets (emergency case)
    function setWallet(address _wallet) public onlyOwner {
        require(!isFinalized);
        require(_wallet != 0x0);
        wallet = _wallet;
    }

      // set new rate (emergency case)
    function setRate(uint256 _rate) public onlyOwner {
        require(!isFinalized);
        require(_rate > 0);
        rate = _rate;
    }

        // set new softcap (emergency case)
    function setSoftcap(uint256 _softcap) public onlyOwner {
        require(!isFinalized);
        require(_softcap > 0);
        softcap = _softcap;
    }


    // set token on pause
    function pauseToken() external onlyOwner {
        require(!isFinalized);
        token.pause();
    }

    // unset token's pause
    function unpauseToken() external onlyOwner {
        token.unpause();
    }

    // set token Ownership
    function transferTokenOwnership(address newOwner) external onlyOwner {
        token.transferOwnership(newOwner);
    }

    // @return true if main sale event has ended
    function icoHasEnded() external constant returns (bool) {
        return now > icoEndTime;
    }

    // @return true if pre sale event has ended
    function preIcoHasEnded() external constant returns (bool) {
        return now > preIcoEndTime;
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        //wallet.transfer(msg.value);
        vault.deposit.value(msg.value)(msg.sender);
    }

    // we want to be able to check all bonuses in already deployed contract
    // that's why we pass currentTime as a parameter instead of using "now"
    function getBonusPercent(uint256 currentTime) public constant returns (uint256 percent) {
      //require(currentTime >= preIcoStartTime);
        uint i = 0;
        bool isPreIco = currentTime >= preIcoStartTime && currentTime <= preIcoEndTime;
        uint256 offset = 0;
        if (isPreIco) {
            uint256 preIcoDiffInSeconds = currentTime.sub(preIcoStartTime);
            for (i = 0; i < preIcoBonuses.length; i++) {
                if (preIcoDiffInSeconds <= preIcoBonuses[i].duration + offset) {
                    return preIcoBonuses[i].percent;
                }
                offset = offset.add(preIcoBonuses[i].duration);
            }
        } else {
            uint256 icoDiffInSeconds = currentTime.sub(icoStartTime);
            for (i = 0; i < icoBonuses.length; i++) {
                if (icoDiffInSeconds <= icoBonuses[i].duration + offset) {
                    return icoBonuses[i].percent;
                }
                offset = offset.add(icoBonuses[i].duration);
            }
        }
        return defaultPercent;
    }

    function applyBonus(uint256 tokens, uint256 percent) internal pure returns  (uint256 bonusedTokens) {
        uint256 tokensToAdd = tokens.mul(percent).div(100);
        return tokens.add(tokensToAdd);
    }

    function validateWithinPeriods() internal constant {
        // within pre-sale or main sale
        require((now >= preIcoStartTime && now <= preIcoEndTime) || (now >= icoStartTime && now <= icoEndTime));
    }

    function validateWithinCaps(uint256 tokensAmount, uint256 weiAmount) internal constant {
        uint256 expectedTokensInvested = tokensInvested.add(tokensAmount);

        // within pre-sale
        if (now >= preIcoStartTime && now <= preIcoEndTime) {
            require(weiAmount >= preIcoMinimumWei);
            require(expectedTokensInvested <= preIcoHardcap);
        }

        // within main sale
        if (now >= icoStartTime && now <= icoEndTime) {
            require(expectedTokensInvested <= icoHardcap);
        }
    }

    // if crowdsale is unsuccessful, investors can claim refunds here
    function claimRefund() public {
        require(isFinalized);
        require(!softcapReached());
        vault.refund(msg.sender);
    }

    function softcapReached() public constant returns (bool) {
        return tokensInvested >= softcap;
    }

    // finish crowdsale
    function finaliseCrowdsale() external onlyOwner returns (bool) {
        require(!isFinalized);
        if (softcapReached()) {
            vault.close();
        } else {
            vault.enableRefunds();
        }

        isFinalized = true;
        return true;
    }

}


contract Deployer is Ownable {

    ApplauseCashCrowdsale public applauseCashCrowdsale;
    uint256 public constant TOKEN_DECIMALS_MULTIPLIER = 10000;
    address public multisig = 0xaB188aCBB8a401277DC2D83C242677ca3C96fF05;

    function deploy() public onlyOwner {
        applauseCashCrowdsale = new ApplauseCashCrowdsale(
            1516280400, //Pre ICO Start: 18 Jan 2018 at 8:00 am EST
            1516856400, //Pre ICO End: 24 Jan 2018 at 11:59 pm EST
            3000000 * TOKEN_DECIMALS_MULTIPLIER, //Pre ICO hardcap
            1517490000,  // ICO Start: 1 Feb 2018 at 8 am EST
            1519880400, // ICO End: 28 Feb 2018 at 11.59 pm EST
            144000000 * TOKEN_DECIMALS_MULTIPLIER,  // ICO hardcap
            50000 * TOKEN_DECIMALS_MULTIPLIER, // Overal crowdsale softcap
            500, // 1 ETH = 500 APLC
            multisig // Multisignature wallet (controlled by multiple accounts)
        );
    }

    function setOwner() public onlyOwner {
        applauseCashCrowdsale.transferOwnership(owner);
    }


}
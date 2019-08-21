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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
    // Public variable with address of owner
    address public owner;
    
    /**
     * Log ownership transference
     */
    event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        // Set the contract creator as the owner
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        // Check that sender is owner
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        // Check for a non-null owner
        require(newOwner != address(0));
        // Log ownership transference
        OwnershipTransferred(owner, newOwner);
        // Set new owner
        owner = newOwner;
    }
    
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {

    uint256 public totalSupply = 0;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

}


contract MintableToken is ERC20Basic, Ownable {

    bool public mintingFinished = false;

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    modifier canMint() {
        require(!mintingFinished);
        _;
    }
    
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool);

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


/**
 * @title Extended ERC20 Token contract
 * @dev Custom Token (ERC20 Token) transactions.
 */
contract StyrasToken is MintableToken {
  
    using SafeMath for uint256;

    string public name = "Styras";
    string public symbol = "STY";
    uint256 public decimals = 18;

    uint256 public reservedSupply;

    uint256 public publicLockEnd = 1516060800; // GMT: Tuesday, January 16, 2018 0:00:00
    uint256 public partnersLockEnd = 1530230400; // GMT: Friday, June 29, 2018 0:00:00
    uint256 public partnersMintLockEnd = 1514678400; // GMT: Sunday, December 31, 2017 0:00:00

    address public partnersWallet;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    /**
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function StyrasToken(address partners, uint256 reserved) public {
        require(partners != address(0));
        partnersWallet = partners;
        reservedSupply = reserved;
        assert(publicLockEnd <= partnersLockEnd);
        assert(partnersMintLockEnd < partnersLockEnd);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param investor The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address investor) public constant returns (uint256 balanceOfInvestor) {
        return balances[investor];
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _amount The amount to be transferred.
     */
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0));
        require((msg.sender != partnersWallet && now >= publicLockEnd) || now >= partnersLockEnd);
        require(_amount > 0 && _amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }
  
    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _amount uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0));
        require((_from != partnersWallet && now >= publicLockEnd) || now >= partnersLockEnd);
        require(_amount > 0 && _amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        Transfer(_from, _to, _amount);
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

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require((msg.sender != partnersWallet && now >= publicLockEnd) || now >= partnersLockEnd);
        require(_value > 0 && _value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        require(_to != partnersWallet);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to mint reserved tokens to partners
     * @return A boolean that indicates if the operation was successful.
     */
    function mintPartners(uint256 amount) onlyOwner canMint public returns (bool) {
        require(now >= partnersMintLockEnd);
        require(reservedSupply > 0);
        require(amount <= reservedSupply);
        totalSupply = totalSupply.add(amount);
        reservedSupply = reservedSupply.sub(amount);
        balances[partnersWallet] = balances[partnersWallet].add(amount);
        Mint(partnersWallet, amount);
        Transfer(address(0), partnersWallet, amount);
        return true;
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

    function RefundVault(address _to) public {
        require(_to != address(0));
        wallet = _to;
        state = State.Active;
    }

    function deposit(address investor) onlyOwner public payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function close() onlyOwner public {
        require(state == State.Active);
        state = State.Closed;
        Closed();
        wallet.transfer(this.balance);
    }

    function enableRefunds() onlyOwner public {
        require(state == State.Active);
        state = State.Refunding;
        RefundsEnabled();
    }

    function refund(address investor) public {
        require(state == State.Refunding);
        require(deposited[investor] > 0);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }
  
}


contract Withdrawable is Ownable {

    bool public withdrawEnabled = false;
    address public wallet;

    event Withdrawed(uint256 weiAmount);
  
    function Withdrawable(address _to) public {
        require(_to != address(0));
        wallet = _to;
    }

    modifier canWithdraw() {
        require(withdrawEnabled);
        _;
    }
  
    function enableWithdraw() onlyOwner public {
        withdrawEnabled = true;
    }
  
    // owner can withdraw ether here
    function withdraw(uint256 weiAmount) onlyOwner canWithdraw public {
        require(this.balance >= weiAmount);
        wallet.transfer(weiAmount);
        Withdrawed(weiAmount);
    }

}


contract StyrasVault is Withdrawable, RefundVault {
  
    function StyrasVault(address wallet) public
        Withdrawable(wallet)
        RefundVault(wallet) {
        // NOOP
    }
  
    function balanceOf(address investor) public constant returns (uint256 depositedByInvestor) {
        return deposited[investor];
    }
  
    function enableWithdraw() onlyOwner public {
        require(state == State.Active);
        withdrawEnabled = true;
    }

}


/**
 * @title StyrasCrowdsale
 * @dev This is a capped and refundable crowdsale.
 */
contract StyrasCrowdsale is Ownable {

    using SafeMath for uint256;
  
    enum State { preSale, publicSale, hasFinalized }

    // how many token units a buyer gets per ether
    // minimum amount of funds (soft-cap) to be raised in weis
    // maximum amount of funds (hard-cap) to be raised in weis
    // minimum amount of weis to invest per investor
    uint256 public rate;
    uint256 public goal;
    uint256 public cap;
    uint256 public minInvest = 100000000000000000; // 0.1 ETH

    // presale treats
    uint256 public presaleDeadline = 1511827200; // GMT: Tuesday, November 28, 2017 00:00:00
    uint256 public presaleRate = 4000; // 1 ETH == 4000 STY 33% bonus
    uint256 public presaleCap = 50000000000000000000000000; // 50 millions STY
  
    // pubsale treats
    uint256 public pubsaleDeadline = 1514678400; // GMT: Sunday, December 31, 2017 0:00:00
    uint256 public pubsaleRate = 3000; // 1 ETH == 3000 STY
    uint256 public pubsaleCap = 180000000000000000000000000;

    // harrd cap = pubsaleCap + reservedSupply -> 200000000 DTY
    uint256 public reservedSupply = 20000000000000000000000000; // 10% max totalSupply

    uint256 public softCap = 840000000000000000000000; // 840 thousands STY

    // start and end timestamps where investments are allowed (both inclusive)
    // flag for investments finalization
    uint256 public startTime = 1511276400; // GMT: Tuesday, November 21, 2017 15:00:00
    uint256 public endTime;

    // amount of raised money in wei
    // address where funds are collected
    uint256 public weiRaised = 0;
    address public escrowWallet;
    address public partnersWallet;

    // contract of the token being sold
    // contract of the vault used to hold funds while crowdsale is running
    StyrasToken public token;
    StyrasVault public vault;

    State public state;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event PresaleFinalized();
    event Finalized();

    function StyrasCrowdsale(address escrow, address partners) public {
        require(now < startTime);
        require(partners != address(0));
        require(startTime < presaleDeadline);
        require(presaleDeadline < pubsaleDeadline);
        require(pubsaleRate < presaleRate);
        require(presaleCap < pubsaleCap);
        require(softCap <= pubsaleCap);
        endTime = presaleDeadline;
        escrowWallet = escrow;
        partnersWallet = partners;
        token = new StyrasToken(partnersWallet, reservedSupply);
        vault = new StyrasVault(escrowWallet);
        rate = presaleRate;
        goal = softCap.div(rate);
        cap = presaleCap.div(rate);
        state = State.preSale;
        assert(goal < cap);
        assert(startTime < endTime);
    }

    // fallback function can be used to buy tokens
    function () public payable {
        buyTokens(msg.sender);
    }
  
    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(state < State.hasFinalized);
        require(validPurchase());
        uint256 weiAmount = msg.value;
        // calculate token amount to be created
        uint256 tokenAmount = weiAmount.mul(rate);
        // update state
        weiRaised = weiRaised.add(weiAmount);
        token.mint(beneficiary, tokenAmount);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
        forwardFunds();
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        vault.deposit.value(msg.value)(msg.sender);
        assert(vault.balance == weiRaised);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = startTime <= now && now <= endTime;
        bool nonZeroPurchase = msg.value > 0;
        bool withinCap = weiRaised < cap;
        bool overMinInvest = msg.value >= minInvest || vault.balanceOf(msg.sender) >= minInvest;
        return withinPeriod && nonZeroPurchase && withinCap && overMinInvest;
    }

    function hardCap() public constant returns (uint256) {
        return pubsaleCap + reservedSupply;
    }

    function goalReached() public constant returns (bool) {
        return weiRaised >= goal;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        bool afterPeriod = now > endTime;
        bool capReached = weiRaised >= cap;
        return afterPeriod || capReached;
    }

    // if crowdsale is unsuccessful, investors can claim refunds here
    function claimRefund() public {
        require(state == State.hasFinalized);
        require(!goalReached());
        vault.refund(msg.sender);
    }

    function enableWithdraw() onlyOwner public {
        require(goalReached());
        vault.enableWithdraw();
    }
  
    // if crowdsale is successful, owner can withdraw ether here
    function withdraw(uint256 _weiAmountToWithdraw) onlyOwner public {
        require(goalReached());
        vault.withdraw(_weiAmountToWithdraw);
    }

    function finalizePresale() onlyOwner public {
        require(state == State.preSale);
        require(hasEnded());
        uint256 weiDiff = 0;
        uint256 raisedTokens = token.totalSupply();
        rate = pubsaleRate;
        if (!goalReached()) {
            weiDiff = (softCap.sub(raisedTokens)).div(rate);
            goal = weiRaised.add(weiDiff);
        }
        weiDiff = (pubsaleCap.sub(raisedTokens)).div(rate);
        cap = weiRaised.add(weiDiff);
        endTime = pubsaleDeadline;
        state = State.publicSale;
        assert(goal < cap);
        assert(startTime < endTime);
        PresaleFinalized();
    }

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() onlyOwner public {
        require(state == State.publicSale);
        require(hasEnded());
        finalization();
        state = State.hasFinalized;
        Finalized();
    }

    // vault finalization task, called when owner calls finalize()
    function finalization() internal {
        if (goalReached()) {
            vault.close();
            token.mintPartners(reservedSupply);
        } else {
            vault.enableRefunds();
        }
        vault.transferOwnership(owner);
        token.transferOwnership(owner);
    }

}
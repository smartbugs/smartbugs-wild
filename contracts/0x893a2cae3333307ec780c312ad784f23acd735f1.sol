pragma solidity ^0.4.19;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns(uint256);
    
    function balanceOf(address who) public view returns(uint256);
    
    function transfer(address to, uint256 value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
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
    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }
    
    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns(bool) {
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
    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }
    
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns(uint256);
    
    function transferFrom(address from, address to, uint256 value) public returns(bool);
    
    function approve(address spender, uint256 value) public returns(bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
    
    mapping(address => mapping(address => uint256)) internal allowed;
    
    
    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
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
    function approve(address _spender, uint256 _value) public returns(bool) {
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
    function allowance(address _owner, address _spender) public view returns(uint256) {
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
    function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
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
    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
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
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }
    
    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
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
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool) {
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
    function finishMinting() onlyOwner canMint public returns(bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {
    
    function transfer(address _to, uint256 _value) public whenNotPaused returns(bool) {
        return super.transfer(_to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns(bool) {
        return super.transferFrom(_from, _to, _value);
    }
    
    function approve(address _spender, uint256 _value) public whenNotPaused returns(bool) {
        return super.approve(_spender, _value);
    }
    
    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns(bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }
    
    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns(bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
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
 * @title MavinToken
 * @dev ERC20 mintable token
 * The token will be minted by the crowdsale contract only
 */
contract MavinToken is MintableToken, PausableToken {
    
    string public constant name = "Mavin Token";
    string public constant symbol = "MVN";
    uint8 public constant decimals = 18;
    address public creator;
    
    function MavinToken()
    public
    Ownable()
    MintableToken()
    PausableToken() {
        creator = msg.sender;
        paused = true;
    }
    
    function finalize()
    public
    onlyOwner {
        finishMinting(); //this can't be reactivated
        unpause();
    }
    
    
    function ownershipToCreator()
    public {
        require(creator == msg.sender);
        owner = msg.sender;
    }
}

/**
 * @author OpenZeppelin
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


library Referral {
    
    /**
     * @dev referral tree
     */
    event LogRef(address member, address referrer);
    
    struct Node {
        address referrer;
        bool valid;
    }
    
    /**
     * @dev tree is a collection of nodes
     */
    struct Tree {
        mapping(address => Referral.Node) nodes;
    }
    
    function addMember(
                       Tree storage self,
                       address _member,
                       address _referrer
                       
                       )
    internal
    returns(bool success) {
        Node memory memberNode;
        memberNode.referrer = _referrer;
        memberNode.valid = true;
        self.nodes[_member] = memberNode;
        LogRef(_member, _referrer);
        return true;
    }
}


contract AffiliateTreeStore is Ownable {
    using SafeMath for uint256;
    using Referral for Referral.Tree;
    
    address public creator;
    
    Referral.Tree affiliateTree;
    
    function AffiliateTreeStore()
    public {
        creator = msg.sender;
    }
    
    function ownershipToCreator()
    public {
        require(creator == msg.sender);
        owner = msg.sender;
    }
    
    function getNode(
                     address _node
                     )
    public
    view
    returns(address referrer) {
        Referral.Node memory n = affiliateTree.nodes[_node];
        if (n.valid == true) {
            return _node;
        }
        return 0;
    }
    
    function getReferrer(
                         address _node
                         )
    public
    view
    returns(address referrer) {
        Referral.Node memory n = affiliateTree.nodes[_node];
        if (n.valid == true) {
            return n.referrer;
        }
        return 0;
    }
    
    function addMember(
                       address _member,
                       address _referrer
                       )
    
    public
    onlyOwner
    returns(bool success) {
        return affiliateTree.addMember(_member, _referrer);
    }
    
    
    // Fallback Function only ETH with no functionCall
    function() public {
        revert();
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
    
    mapping(address => uint256) public released;
    mapping(address => bool) public revoked;
    
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
    function releasableAmount(ERC20Basic token) public view returns(uint256) {
        return vestedAmount(token).sub(released[token]);
    }
    
    /**
     * @dev Calculates the amount that has already vested.
     * @param token ERC20 token which is being vested
     */
    function vestedAmount(ERC20Basic token) public view returns(uint256) {
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


contract AffiliateManager is Pausable {
    using SafeMath for uint256;
    
    AffiliateTreeStore public affiliateTree; // treeStorage
    
    // The token being sold
    MavinToken public token;
    // endTime
    uint256 public endTime;
    // hardcap
    uint256 public cap;
    // address where funds are collected
    address public vault;
    // how many token units a referral gets per eth
    uint256 public mvnpereth;
        // how many token units a buyer gets per eth
    uint256 public mvnperethBonus;
    // amount of raised money in wei
    
    uint256 public level1Bonus;
    uint256 public level2Bonus;
    // amount of raised money in wei
    
    uint256 public weiRaised;
    // min contribution amount
    uint256 public minAmountWei;
    // creator
    address creator;
    
    
    function AffiliateManager(
                              address _token,
                              address _treestore
                              )
    public {
        creator = msg.sender;
        token = MavinToken(_token);
        endTime = 1536969600; // Sat Sep 15 01:00:00 2018 GMT+1
        vault = 0xD0b40D3bfd8DFa6ecC0b357555039C3ee1C11202;
        mvnpereth = 100;
        mvnperethBonus = 105;
        level1Bonus = 8;
        level2Bonus = 5;
        
        minAmountWei = 0.01 ether;
        cap = 32000 ether;
        
        affiliateTree = AffiliateTreeStore(_treestore);
    }
    
    /// Log buyTokens
    event LogBuyTokens(address owner, uint256 tokens, uint256 tokenprice);
    /// Log LogId
    event LogId(address owner, uint48 id);
    
    modifier onlyNonZeroAddress(address _a) {
        require(_a != address(0));
        _;
    }
    
    modifier onlyDiffAdr(address _referrer, address _sender) {
        require(_referrer != _sender);
        _;
    }
    
    function initAffiliate() public onlyOwner returns(bool) {
        //create first 2 root nodes
        bool success1 = affiliateTree.addMember(vault, 0); //root
        bool success2 = affiliateTree.addMember(msg.sender, vault); //root+1
        return success1 && success2;
    }
    
    
    // execute after all crowdsale tokens are minted
    function finalizeCrowdsale() public onlyOwner returns(bool) {
        
        pause();
        
        uint256 totalSupply = token.totalSupply();
        
        // 6 month cliff, 12 month total
        TokenVesting team = new TokenVesting(vault, now, 24 weeks, 1 years, false);
        uint256 teamTokens = totalSupply.div(60).mul(16);
        token.mint(team, teamTokens);
        
        uint256 reserveTokens = totalSupply.div(60).mul(18);
        token.mint(vault, reserveTokens);
        
        uint256 advisoryTokens = totalSupply.div(60).mul(6);
        token.mint(vault, advisoryTokens);
        
        token.transferOwnership(creator);
    }
    
    function validPurchase() internal constant returns(bool) {
        bool withinCap = weiRaised.add(msg.value) <= cap;
        bool withinTime = endTime > now;
        bool withinMinAmount = msg.value >= minAmountWei;
        return withinCap && withinTime && withinMinAmount;
    }
    
    function presaleMint(
                         address _beneficiary,
                         uint256 _amountmvn,
                         uint256 _mvnpereth
                         
                         )
    public
    onlyOwner
    returns(bool) {
        uint256 _weiAmount = _amountmvn.div(_mvnpereth);
        require(_beneficiary != address(0));
        token.mint(_beneficiary, _amountmvn);
        // update state
        weiRaised = weiRaised.add(_weiAmount);
        
        LogBuyTokens(_beneficiary, _amountmvn, _mvnpereth);
        return true;
    }
    
    function joinManual(
                        address _referrer,
                        uint48 _id
                        )
    public
    payable
    whenNotPaused
    onlyDiffAdr(_referrer, msg.sender) // prevent selfreferal
    onlyDiffAdr(_referrer, this) // prevent reentrancy
    returns(bool) {
        LogId(msg.sender, _id);
        return join(_referrer);
    }
    
    
    function join(
                  address _referrer
                  )
    public
    payable
    whenNotPaused
    onlyDiffAdr(_referrer, msg.sender) // prevent selfreferal
    onlyDiffAdr(_referrer, this) // prevent reentrancy
    returns(bool success)
    
    {
        uint256 weiAmount = msg.value;
        require(_referrer != vault);
        require(validPurchase()); //respect min amount / cap / date
        
        //get existing sender node
        address senderNode = affiliateTree.getNode(msg.sender);
        
        // if senderNode already exists use same referrer
        if (senderNode != address(0)) {
            _referrer =  affiliateTree.getReferrer(msg.sender);
        }
        
        //get referrer
        address referrerNode = affiliateTree.getNode(_referrer);
        //referrer must exist
        require(referrerNode != address(0));
        
        //get referrer of referrer
        address topNode = affiliateTree.getReferrer(_referrer);
        //referrer of referrer must exist
        require(topNode != address(0));
        require(topNode != msg.sender); //selfreferal
        

        
        // Add sender to the tree
        if (senderNode == address(0)) {
            affiliateTree.addMember(msg.sender, _referrer);
        }
        
        buyTokens(msg.sender, weiAmount, _referrer, true);
        
        uint256 parentAmount = 0;
        uint256 rootAmount = 0;
        
        //p1
        parentAmount = weiAmount.div(100).mul(level1Bonus); //% commision for p1
        referrerNode.transfer(parentAmount);
        buyTokens(referrerNode, parentAmount,_referrer, false);
        
        //p2
        rootAmount = weiAmount.div(100).mul(level2Bonus); //% commision for p2
        topNode.transfer(rootAmount);
        buyTokens(topNode, rootAmount,_referrer, false);
        
        
        vault.transfer(weiAmount.sub(parentAmount).sub(rootAmount)); //rest goes to vault
        
        return success;
    }
    
    function buyTokens(
           address _beneficiary,
           uint256 _weiAmount,
           address _referrer,
           bool _hasBonus
        )
        internal
        returns(bool success) {
        require(_beneficiary != address(0));
        uint256 tokens = 0;
        uint256 rate = mvnpereth;
        
        if (_hasBonus == true && _referrer != creator) {
            rate = mvnperethBonus;
        }
        
        tokens = _weiAmount.mul(rate);
        
        // update state
        weiRaised = weiRaised.add(_weiAmount);
        success = token.mint(_beneficiary, tokens);
        
        LogBuyTokens(_beneficiary, tokens, rate);
        return success;
    }
    
    function updateBonus(uint256 _minAmountWei, uint256 _buyerrate, uint256 _rate, uint256 _level1, uint256 _level2) onlyOwner public returns(bool success) {
        minAmountWei = _minAmountWei;
        mvnpereth = _rate;
        mvnperethBonus = _buyerrate;
        level1Bonus = _level1;
        level2Bonus = _level2;
        return true;
    }
    
    function balanceOf(address _owner) public constant returns(uint256 balance) {
        return token.balanceOf(_owner);
    }
    
    // Fallback Function only ETH with no functionCall
    function() public {
        revert();
    }
    
}
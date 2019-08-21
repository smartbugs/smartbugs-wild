pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks
 */
contract SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 _balance);
    function allowance(address _owner, address _spender) public constant returns (uint256 _allowance);
    function transfer(address _to, uint256 _value) public returns (bool _succes);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _succes);
    function approve(address _spender, uint256 _value) public returns (bool _succes);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 */
contract StandardToken is ERC20, SafeMath {
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed; 
    
    function balanceOf(address _owner) public constant returns (uint256){
        return balances[_owner];
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint256){
        return allowed[_owner][_spender];
    }
    
    /**
    * Fix for the ERC20 short address attack
    *
    * http://vessenes.com/the-erc20-short-address-attack-explained/
    */
    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length >= numwords * 32 + 4);
        _;
    }
    
    /*
     * Internal transfer with security checks, 
     * only can be called by this contract
     */
    function safeTransfer(address _from, address _to, uint256 _value) internal {
            // Prevent transfer to 0x0 address.
            require(_to != 0x0);
            // Prevent transfer to this contract
            require(_to != address(this));
            // Check if the sender has enough and subtract from the sender by using safeSub
            balances[_from] = safeSub(balances[_from], _value);
            // check for overflows and add the same value to the recipient by using safeAdd
            balances[_to] = safeAdd(balances[_to], _value);
            Transfer(_from, _to, _value);
    }

    /**
     * @dev Send `_value` tokens to `_to` from your account
     * @param _to address The address which you want to transfer to
     * @param _value uint the amout of tokens to be transfered
     */
    function transfer(address _to, uint256 _value) onlyPayloadSize(2) public returns (bool) {
        safeTransfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3) public returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];
        
        // Check (_value <= _allowance) is already done in safeSub(_allowance, _value)
        allowed[_from][msg.sender] = safeSub(_allowance, _value);
        safeTransfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) onlyPayloadSize(2) public returns (bool) {
        // To change the approve amount you first have to reduce the addresses`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}


/**
 * @title ExtendedERC20
 * 
 * @dev Additional functions to ERC20
 */
contract ExtendedERC20 is StandardToken {
    
    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * Instead of creating two transactions and pay the gas price twice by calling approve method
     * this method allows to increment the allowed value in one step 
     * without being vulnerable to multiple withdrawals.
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint256 _addedValue) onlyPayloadSize(2) public returns (bool) {
        allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender], _addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * Instead of creating two transactions and pay the gas price twice by calling approve method
     * this method allows to decrease the allowed value in one step 
     * without being vulnerable to multiple withdrawals.
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint256 _subtractedValue) onlyPayloadSize(2) public returns (bool) {
        uint256 currentValue = allowed[msg.sender][_spender];
        require(currentValue > 0);
        if (_subtractedValue > currentValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = safeSub(currentValue, _subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    /** @dev `msg.sender` approves `_spender` to send `_amount` tokens on
     *  its behalf, and then a function is triggered in the contract that is
     *  being approved, `_spender`. This allows users to use their tokens to
     *  interact with contracts in one function call instead of two
     * @param _spender The address of the contract able to transfer the tokens
     * @param _amount The amount of tokens to be approved for transfer
     */
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData) public returns (bool success) {
        require(approve(_spender, _amount));
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _amount, this, _extraData);
        return true;
    }
}


/**
 * Upgrade agent interface inspired by Lunyr.
 * 
 * Upgrade agent transfers tokens to a new contract.
 * Upgrade agent itself can be the token contract, or just a middle man contract 
 * doing the heavy lifting.
 */
contract UpgradeAgent {

    uint256 public originalSupply;

    /** Interface marker */
    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }

    function upgradeFrom(address _from, uint256 _value) public;
}


/**
 * A token upgrade mechanism where users can opt-in amount of tokens to the next 
 * smart contract revision.
 *
 * First envisioned by Golem and Lunyr projects.
 *
 */
contract UpgradeableToken is StandardToken {

    /**
     * Contract / person who can set the upgrade path. 
     * This can be the same as team multisig wallet, as what it is with its default value. 
     */
    address public upgradeMaster;

    /** The next contract where the tokens will be migrated. */
    UpgradeAgent public upgradeAgent;

    /** How many tokens we have upgraded by now. */
    uint256 public totalUpgraded;
    
    /**
     * Upgrade states.
     *
     * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
     * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
     * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
     * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
     *
     */
    enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

    /**
     * Somebody has upgraded some of his tokens.
     */
    event Upgrade(address indexed _from, address indexed _to, uint256 _value);

    /**
     * New upgrade agent available.
     */
    event UpgradeAgentSet(address agent);

    /**
     * Do not allow construction without upgrade master set.
     */
    function UpgradeableToken(address _upgradeMaster) public {
        upgradeMaster = _upgradeMaster;
    }

    /**
     * Allow the token holder to upgrade some of their tokens to a new contract.
     */
    function upgrade(uint256 value) public {

        UpgradeState state = getUpgradeState();
        // bad state not allowed
        require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);

        // Validate input value.
        require(value != 0);

        balances[msg.sender] = safeSub(balances[msg.sender], value);

        // Take tokens out from circulation
        totalSupply = safeSub(totalSupply, value);
        totalUpgraded = safeAdd(totalUpgraded, value);

        // Upgrade agent reissues the tokens
        upgradeAgent.upgradeFrom(msg.sender, value);
        Upgrade(msg.sender, upgradeAgent, value);
    }

    /**
     * Set an upgrade agent that handles
     */
    function setUpgradeAgent(address agent) external {

        require(canUpgrade());
        require(agent != 0x0);
        // Only a master can designate the next agent
        require(msg.sender == upgradeMaster);
        // Upgrade has already begun for an agent
        require(getUpgradeState() != UpgradeState.Upgrading);

        upgradeAgent = UpgradeAgent(agent);

        // Bad interface
        require(upgradeAgent.isUpgradeAgent());
        // Make sure that token supplies match in source and target
        require(upgradeAgent.originalSupply() == totalSupply);

        UpgradeAgentSet(upgradeAgent);
    }

    /**
     * Get the state of the token upgrade.
     */
    function getUpgradeState() public constant returns (UpgradeState) {
        if(!canUpgrade()) return UpgradeState.NotAllowed;
        else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
        else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
        else return UpgradeState.Upgrading;
    }

    /**
     * Change the upgrade master.
     *
     * This allows us to set a new owner for the upgrade mechanism.
     */
    function setUpgradeMaster(address master) public {
        require(master != 0x0);
        require(msg.sender == upgradeMaster);
        upgradeMaster = master;
    }

    /**
     * Child contract can enable to provide the condition when the upgrade can begun.
     */
    function canUpgrade() public pure returns (bool) {
        return true;
    }
}


/**
 * @title Ownable
 * @dev Ownable contract with two owner addresses
 */
contract Ownable {
    address public ownerOne;
    address public ownerTwo;

    /**
     * @dev The Ownable constructor sets both owners of the contract to the sender account.
     */
    function Ownable() public {
        ownerOne = msg.sender;
        ownerTwo = msg.sender;
    }

    /**
     * @dev Can only be called by the owners.
     */
    modifier onlyOwner {
        require(msg.sender == ownerOne || msg.sender == ownerTwo);
        _;
    }

    /**
     * @dev Allows the current owners to transfer control of the contract to a new owner.
     * @param newOwner The address to transfer ownership to
     * @param replaceOwnerOne Replace 'ownerOne'?
     * @param replaceOwnerTwo Replace 'ownerTwo'?
     */
    function transferOwnership(address newOwner, bool replaceOwnerOne, bool replaceOwnerTwo) onlyOwner public {
        require(newOwner != 0x0);
        require(replaceOwnerOne || replaceOwnerTwo);
        if(replaceOwnerOne) ownerOne = newOwner;
        if(replaceOwnerTwo) ownerTwo = newOwner;
    }
}


/**
 * @title Pausable
 * @dev Allows an emergency stop mechanism.
 * See https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public returns (bool) {
        paused = true;
        Pause();
        return true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public returns (bool) {
        paused = false;
        Unpause();
        return true;
    }
}


/**
 * @title PausableToken
 * @dev StandardToken with pausable transfers
 */
contract PausableToken is StandardToken, Pausable {
    function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
        // Call StandardToken.transfer()
        super.transfer(_to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) {
        // Call StandardToken.transferFrom()
        super.transferFrom(_from, _to, _value);
        return true;
    }
}


/**
 * @title PurchasableToken
 * @dev Allows buying IPC token from this contract
 */
contract PurchasableToken is StandardToken, Pausable {
    event PurchaseUnlocked();
    event PurchaseLocked();
    event UpdatedExchangeRate(uint256 newRate);
    
    bool public purchasable = false;
    // minimum amount of wei you have to spend to buy some tokens
    uint256 public minimumWeiAmount;
    address public vendorWallet;
    uint256 public exchangeRate; // 'exchangeRate' tokens = 1 ether (consider decimals of token)
    
    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    
    /** 
     * @dev modifier to allow token purchase only when purchase is unlocked and rate > 0 
     */
    modifier isPurchasable {
        require(purchasable && exchangeRate > 0 && minimumWeiAmount > 0);
        _;
    }
    
    /** @dev called by the owner to lock purchase of ipc token */
    function lockPurchase() onlyOwner public returns (bool) {
        require(purchasable == true);
        purchasable = false;
        PurchaseLocked();
        return true;
    }
    
    /** @dev called by the owner to release purchase of ipc token */
    function unlockPurchase() onlyOwner public returns (bool) {
        require(purchasable == false);
        purchasable = true;
        PurchaseUnlocked();
        return true;
    }

    /** @dev called by the owner to set a new rate (consider decimals of token) */
    function setExchangeRate(uint256 newExchangeRate) onlyOwner public returns (bool) {
        require(newExchangeRate > 0);
        exchangeRate = newExchangeRate;
        UpdatedExchangeRate(newExchangeRate);
        return true;
    }
    
    /** @dev called by the owner to set the minimum wei amount to buy some token */
    function setMinimumWeiAmount(uint256 newMinimumWeiAmount) onlyOwner public returns (bool) {
        require(newMinimumWeiAmount > 0);
        minimumWeiAmount = newMinimumWeiAmount;
        return true;
    }
    
    /** @dev called by the owner to set a new vendor */
    function setVendorWallet(address newVendorWallet) onlyOwner public returns (bool) {
        require(newVendorWallet != 0x0);
        vendorWallet = newVendorWallet;
        return true;
    }
    
    /** 
     * @dev called by the owner to make the purchase preparations 
     * ('approve' must be called separately from 'vendorWallet') 
     */
    function setPurchaseValues( uint256 newExchangeRate, 
                                uint256 newMinimumWeiAmount, 
                                address newVendorWallet,
                                bool releasePurchase) onlyOwner public returns (bool) {
        setExchangeRate(newExchangeRate);
        setMinimumWeiAmount(newMinimumWeiAmount);
        setVendorWallet(newVendorWallet);
        // if purchase is already unlocked then 'releasePurchase' 
        // doesn't change anything and can be set to true or false.
        if (releasePurchase && !purchasable) unlockPurchase();
        return true;
    }
    
    /** @dev buy token by sending at least 'minimumWeiAmount' wei */
    function buyToken(address beneficiary) payable isPurchasable whenNotPaused public returns (uint256) {
        require(beneficiary != address(0));
        require(beneficiary != address(this));
        uint256 weiAmount = msg.value;
        require(weiAmount >= minimumWeiAmount);
        uint256 tokenAmount = safeMul(weiAmount, exchangeRate);
        tokenAmount = safeDiv(tokenAmount, 1 ether);
        uint256 _allowance = allowed[vendorWallet][this];
        // Check (tokenAmount <= _allowance) is already done in safeSub(_allowance, tokenAmount)
        allowed[vendorWallet][this] = safeSub(_allowance, tokenAmount);
        balances[beneficiary] = safeAdd(balances[beneficiary], tokenAmount);
        balances[vendorWallet] = safeSub(balances[vendorWallet], tokenAmount);
        vendorWallet.transfer(weiAmount);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
        return tokenAmount; 
    }
    
    function () payable public {
        buyToken(msg.sender);
    }
}


/**
 * @title CrowdsaleToken
 * @dev Allows token transfer after the crowdsale has ended
 */
contract CrowdsaleToken is PausableToken {
    
    // addresses that will be allowed to transfer tokens before and during crowdsale
    mapping (address => bool) icoAgents;
    // token transfer locked until crowdsale is finished
    bool public crowdsaleLock = true;

    /**
     * @dev Can only be called by the icoAgent
     */
    modifier onlyIcoAgent {
        require(isIcoAgent(msg.sender));
        _;
    }
    
    /**
     * @dev modifier to allow token transfer only when '_sender' is icoAgent or crowdsale has ended 
     */
    modifier canTransfer(address _sender) {
        require(!crowdsaleLock || isIcoAgent(_sender));
        _;
    }
    
    /**
     * @dev Construction with an icoAgent
     */
    function CrowdsaleToken(address _icoAgent) public {
        icoAgents[_icoAgent] = true;
    }
    
    /** @dev called by an icoAgent to release token transfer after crowdsale */
    function releaseTokenTransfer() onlyIcoAgent public returns (bool) {
        crowdsaleLock = false;
        return true;
    }
    
    /** @dev called by the owner to set a new _icoAgent or remove one */
    function setIcoAgent(address _icoAgent, bool _allowTransfer) onlyOwner public returns (bool) {
        icoAgents[_icoAgent] = _allowTransfer;
        return true; 
    }
    
    /** @dev return true if 'address' is an icoAgent */
    function isIcoAgent(address _address) public view returns (bool) {
        return icoAgents[_address];
    }

    function transfer(address _to, uint _value) canTransfer(msg.sender) public returns (bool) {
        // Call PausableToken.transfer()
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) canTransfer(_from) public returns (bool) {
        // Call PausableToken.transferFrom()
        return super.transferFrom(_from, _to, _value);
    }
}


/**
 * @title CanSendFromContract
 * @dev Contract allows to send ether and erc20 compatible tokens
 */
contract CanSendFromContract is Ownable {
    
    /** @dev send erc20 token from this contract */
    function sendToken(address beneficiary, address _token) onlyOwner public {
        ERC20 token = ERC20(_token);
        uint256 amount = token.balanceOf(this);
        require(amount>0);
        token.transfer(beneficiary, amount);
    }
    
    /** @dev called by the owner to transfer 'weiAmount' wei to 'beneficiary' */
    function sendEther(address beneficiary, uint256 weiAmount) onlyOwner public {
        beneficiary.transfer(weiAmount);
    }
}


/**
 * @title IPCToken
 * @dev IPC Token contract
 * @author Paysura - <contact@paysura.com>
 */
contract IPCToken is ExtendedERC20, UpgradeableToken, PurchasableToken, CrowdsaleToken, CanSendFromContract {

    // Public variables of the token
    string public name = "International PayReward Coin";
    string public symbol = "IPC";
    uint8 public decimals = 12;
    // Distributions of the total supply
    // 264 mio IPC tokens will be distributed during crowdsale
    uint256 public cr = 264000000 * (10 ** uint256(decimals));
    // 110 mio reserved for community in the reward program
    uint256 public rew = 110000000 * (10 ** uint256(decimals));
    // 66 mio for advisors and partners
    uint256 public dev = 66000000 * (10 ** uint256(decimals));
    // total supply of 440 mio -> 85% for community.
    uint256 public totalSupply = cr + dev + rew;    

    event UpdatedTokenInformation(string newName, string newSymbol);
   
    /**
     * Constructor of ipc token
     * 
     * @param addressOfCrBen beneficiary of crowdsale
     * @param addressOfRew reserve for community / reward program
     * @param addressOfDev reserve remaining amount of ipc for development, partners and advisors
     */
    function IPCToken (
        address addressOfCrBen, 
        address addressOfRew,
        address addressOfDev
        ) public UpgradeableToken(msg.sender) CrowdsaleToken(addressOfCrBen) {
        // Assign the initial tokens to the addresses
        balances[addressOfCrBen] = cr;
        balances[addressOfRew] = rew;
        balances[addressOfDev] = dev;
    }
    
    /**
     * Owner can update token information
     * 
     * @param _name new token name
     * @param _symbol new token symbol
     */
    function setTokenInformation(string _name, string _symbol) onlyOwner public {
        name = _name;
        symbol = _symbol;
        
        UpdatedTokenInformation(name, symbol);
    }
}
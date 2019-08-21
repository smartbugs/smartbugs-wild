pragma solidity ^0.4.15;

/**
  * Math operations with safety checks
  */
library SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
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


/*
  * ERC20 interface
  * see https://github.com/ethereum/EIPs/issues/20
  */
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);
    function allowance(address owner, address spender) constant returns (uint);

    function transfer(address to, uint value) returns (bool ok);
    function transferFrom(address from, address to, uint value) returns (bool ok);
    function approve(address spender, uint value) returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}



/**
  * Standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
  *
  * Based on code by FirstBlood:
  * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
  */
contract StandardToken is ERC20
{
    using SafeMath for uint;

    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;

    // Interface marker
    bool public constant isToken = true;

    /**
      * Fix for the ERC20 short address attack
      *
      * http://vessenes.com/the-erc20-short-address-attack-explained/
      */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length == size + 4);
        _;
    }

    function transfer(address _to, uint _value)
        onlyPayloadSize(2 * 32)
        returns (bool success)
    {
        balances[msg.sender] = balances[msg.sender].safeSub(_value);
        balances[_to] = balances[_to].safeAdd(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address from, address to, uint value)
        returns (bool success)
    {
        uint _allowance = allowed[from][msg.sender];

        // Check is not needed because _allowance.safeSub(value) will throw if this condition is not met
        // if (value > _allowance) throw;

        balances[to] = balances[to].safeAdd(value);
        balances[from] = balances[from].safeSub(value);
        allowed[from][msg.sender] = _allowance.safeSub(value);

        Transfer(from, to, value);
        return true;
    }

    function balanceOf(address account)
        constant
        returns (uint balance)
    {
        return balances[account];
    }

    function approve(address spender, uint value)
        returns (bool success)
    {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((value != 0) && (allowed[msg.sender][spender] != 0)) throw;

        allowed[msg.sender][spender] = value;

        Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address account, address spender)
        constant
        returns (uint remaining)
    {
        return allowed[account][spender];
    }
}



/**
  * Upgrade target interface inspired by Lunyr.
  *
  * Upgrade agent transfers tokens to a new contract.
  * Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
  */
contract UpgradeTarget
{
    uint public originalSupply;

    /** Interface marker */
    function isUpgradeTarget() public constant returns (bool) {
        return true;
    }

    function upgradeFrom(address _from, uint256 _value) public;
}


/**
  * A token upgrade mechanism where users can opt-in amount of tokens to the next smart contract revision.
  *
  * First envisioned by Golem and Lunyr projects.
  */
contract UpgradeableToken is StandardToken
{
    /** Contract / person who can set the upgrade path. This can be the same as team multisig wallet, as what it is with its default value. */
    address public upgradeMaster;

    /** The next contract where the tokens will be migrated. */
    UpgradeTarget public upgradeTarget;

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
    event LogUpgrade(address indexed _from, address indexed _to, uint256 _value);

    /**
      * New upgrade agent available.
      */
    event LogSetUpgradeTarget(address agent);

    /**
      * Do not allow construction without upgrade master set.
      */
    function UpgradeableToken(address _upgradeMaster) {
        upgradeMaster = _upgradeMaster;
    }

    /**
      * Allow the token holder to upgrade some of their tokens to a new contract.
      */
    function upgrade(uint256 value) public {
        UpgradeState state = getUpgradeState();
        require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);

        // Validate input value.
        require(value > 0);

        balances[msg.sender] = balances[msg.sender].safeSub(value);

        // Take tokens out from circulation
        totalSupply   = totalSupply.safeSub(value);
        totalUpgraded = totalUpgraded.safeAdd(value);

        // Upgrade agent reissues the tokens
        upgradeTarget.upgradeFrom(msg.sender, value);
        LogUpgrade(msg.sender, upgradeTarget, value);
    }

    /**
      * Set an upgrade targget that handles the process of letting users opt-in to the new token contract.
      */
    function setUpgradeTarget(address target) external {
        require(canUpgrade());
        require(target != 0x0);
        require(msg.sender == upgradeMaster); // Only a master can designate the next target
        require(getUpgradeState() != UpgradeState.Upgrading); // Upgrade has already begun

        upgradeTarget = UpgradeTarget(target);

        require(upgradeTarget.isUpgradeTarget()); // Bad interface
        require(upgradeTarget.originalSupply() == totalSupply); // Make sure that token supplies match in source and target

        LogSetUpgradeTarget(upgradeTarget);
    }

    /**
      * Get the state of the token upgrade.
      */
    function getUpgradeState() public constant returns (UpgradeState) {
        if (!canUpgrade()) return UpgradeState.NotAllowed;
        else if (address(upgradeTarget) == 0x00) return UpgradeState.WaitingForAgent;
        else if (totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
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
    function canUpgrade() public constant returns (bool) {
        return true;
    }
}

contract MintableToken is StandardToken
{
    address public mintMaster;

    event LogMintTokens(address recipient, uint amount, uint newBalance, uint totalSupply);
    event LogUnmintTokens(address hodler, uint amount, uint newBalance, uint totalSupply);
    event LogSetMintMaster(address oldMintMaster, address newMintMaster);

    function MintableToken(address _mintMaster) {
        mintMaster = _mintMaster;
    }

    function setMintMaster(address newMintMaster)
        returns (bool ok)
    {
        require(msg.sender == mintMaster);

        address oldMintMaster = mintMaster;
        mintMaster = newMintMaster;

        LogSetMintMaster(oldMintMaster, mintMaster);
        return true;
    }

    function mintTokens(address recipient, uint amount)
        returns (bool ok)
    {
        require(msg.sender == mintMaster);
        require(amount > 0);

        balances[recipient] = balances[recipient].safeAdd(amount);
        totalSupply = totalSupply.safeAdd(amount);

        LogMintTokens(recipient, amount, balances[recipient], totalSupply);
        Transfer(address(0), recipient, amount);
        return true;
    }

    function unmintTokens(address hodler, uint amount)
        returns (bool ok)
    {
        require(msg.sender == mintMaster);
        require(amount > 0);
        require(balances[hodler] >= amount);

        balances[hodler] = balances[hodler].safeSub(amount);
        totalSupply = totalSupply.safeSub(amount);

        LogUnmintTokens(hodler, amount, balances[hodler], totalSupply);
        Transfer(hodler, address(0), amount);
        return true;
    }
}


contract SigToken is UpgradeableToken, MintableToken
{
    string public name = "Signals";
    string public symbol = "SIG";
    uint8 public decimals = 18;

    address public crowdsaleContract;
    bool public crowdsaleCompleted;

    function SigToken()
        UpgradeableToken(msg.sender)
        MintableToken(msg.sender)
    {
        crowdsaleContract = msg.sender;
        totalSupply = 0; // we mint during the crowdsale, so totalSupply must start at 0
    }

    function transfer(address _to, uint _value)
        returns (bool success)
    {
        require(crowdsaleCompleted);
        return StandardToken.transfer(_to, _value);
    }

    function transferFrom(address from, address to, uint value)
        returns (bool success)
    {
        require(crowdsaleCompleted);
        return StandardToken.transferFrom(from, to, value);
    }

    function approve(address spender, uint value)
        returns (bool success)
    {
        require(crowdsaleCompleted);
        return StandardToken.approve(spender, value);
    }

    // This is called to unlock tokens once the crowdsale (and subsequent audit + legal process) are
    // completed.  We don't want people buying tokens during the sale and then immediately starting
    // to trade them.  See Crowdsale::finalizeCrowdsale().
    function setCrowdsaleCompleted() {
        require(msg.sender == crowdsaleContract);
        require(crowdsaleCompleted == false);

        crowdsaleCompleted = true;
    }

    /**
     * ERC20 approveAndCall extension
     *
     * Approves and then calls the receiving contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success)
    {
        require(crowdsaleCompleted);

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed when one does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
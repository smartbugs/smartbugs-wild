pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

    /**
     * Events
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Constructor
     * Sets the original `owner` of the contract to the sender account.
     */
    function Ownable() public {
        owner = msg.sender;
        OwnershipTransferred(0, owner);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a new owner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner)
        public
        onlyOwner
    {
        require(_newOwner != 0);

        OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {
        if (_a == 0) {
            return 0;
        }
    
        uint c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {
        // Solidity automatically throws when dividing by 0
        uint c = _a / _b;
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {
        assert(_b <= _a);
        return _a - _b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {
        uint c = _a + _b;
        assert(c >= _a);
        return c;
    }

}

/**
 * @title Standard ERC20 token
 */
contract StandardToken is Ownable {

    using SafeMath for uint;

    string public name;
    string public symbol;
    uint8 public decimals;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) internal allowed;

    /**
     * Events
     */
    event ChangeTokenInformation(string name, string symbol);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /**
     * Owner can update token information here.
     *
     * It is often useful to conceal the actual token association, until
     * the token operations, like central issuance or reissuance have been completed.
     *
     * This function allows the token owner to rename the token after the operations
     * have been completed and then point the audience to use the token contract.
     */
    function changeTokenInformation(string _name, string _symbol)
        public
        onlyOwner
    {
        name = _name;
        symbol = _symbol;
        ChangeTokenInformation(_name, _symbol);
    }

	/**
	 * @dev Transfer token for a specified address
	 * @param _to The address to transfer to.
	 * @param _value The amount to be transferred.
	 */
	function transfer(address _to, uint _value)
		public
		returns (bool)
	{
		require(_to != 0);
        require(_value > 0);

		balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
		balanceOf[_to] = balanceOf[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}

    /**
     * @dev Transfer tokens from one address to another
     * @param _from The address which you want to send tokens from
     * @param _to The address which you want to transfer to
     * @param _value The amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        require(_to != 0);
        require(_value > 0);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
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
     *
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint _value)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     *
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue)
        public
        returns (bool)
    {
        require(_addedValue > 0);

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
     *
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue)
        public
        returns (bool)
    {
        require(_subtractedValue > 0);

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
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner The address which owns the funds.
     * @param _spender The address which will spend the funds.
     * @return A uint specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint)
    {
        return allowed[_owner][_spender];
    }

}

/**
 * @title UpgradeAgent Interface
 * @dev Upgrade agent transfers tokens to a new contract. Upgrade agent itself can be the
 * token contract, or just a middle man contract doing the heavy lifting.
 */
contract UpgradeAgent {

    bool public isUpgradeAgent = true;

    function upgradeFrom(address _from, uint _value) public;

}


/**
 * @title Mintable token
 */
contract MintableToken is StandardToken {

	bool public mintingFinished = false;

	/**
     * Events
     */
	event Mint(address indexed to, uint amount);
  	event MintFinished();

	modifier canMint() {
		require(!mintingFinished);
		_;
	}

	/**
	 * @dev Function to mint tokens
	 * @param _to The address that will receive the minted tokens.
	 * @param _amount The amount of tokens to mint.
	 */
	function mint(address _to, uint _amount)
		public
		onlyOwner
		canMint
	{
		totalSupply = totalSupply.add(_amount);
		balanceOf[_to] = balanceOf[_to].add(_amount);
		Mint(_to, _amount);
		Transfer(0, _to, _amount);
	}

	/**
	 * @dev Function to stop minting new tokens.
	 */
	function finishMinting()
		public
		onlyOwner
		canMint
	{
		mintingFinished = true;
		MintFinished();
	}

}

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract CappedToken is MintableToken {

    uint public cap;

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     */
    function mint(address _to, uint _amount)
        public
        onlyOwner
        canMint
    {
        require(totalSupply.add(_amount) <= cap);

        super.mint(_to, _amount);
    }

}

/**
 * @title Pausable token
 * @dev Token that can be freeze "Transfer" function
 */
contract PausableToken is StandardToken {

    bool public isTradable = true;

    /**
     * Events
     */
    event FreezeTransfer();
    event UnfreezeTransfer();

    modifier canTransfer() {
		require(isTradable);
		_;
	}

    /**
     * Disallow to transfer token from an address to other address
     */
    function freezeTransfer()
        public
        onlyOwner
    {
        isTradable = false;
        FreezeTransfer();
    }

    /**
     * Allow to transfer token from an address to other address
     */
    function unfreezeTransfer()
        public
        onlyOwner
    {
        isTradable = true;
        UnfreezeTransfer();
    }

    /**
	 * @dev Transfer token for a specified address
	 * @param _to The address to transfer to.
	 * @param _value The amount to be transferred.
	 */
    function transfer(address _to, uint _value)
		public
        canTransfer
		returns (bool)
	{
		return super.transfer(_to, _value);
	}

    /**
     * @dev Transfer tokens from one address to another
     * @param _from The address which you want to send tokens from
     * @param _to The address which you want to transfer to
     * @param _value The amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint _value)
        public
        canTransfer
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint _value)
        public
        canTransfer
        returns (bool)
    {
        return super.approve(_spender, _value);
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     *
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue)
        public
        canTransfer
        returns (bool)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     *
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue)
        public
        canTransfer
        returns (bool)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

}

/**
 * @title Upgradable token
 */
contract UpgradableToken is StandardToken {

    address public upgradeMaster;

    // The next contract where the tokens will be migrated.
    UpgradeAgent public upgradeAgent;

    bool public isUpgradable = false;

    // How many tokens we have upgraded by now.
    uint public totalUpgraded;

    /**
     * Events
     */
    event ChangeUpgradeMaster(address newMaster);
    event ChangeUpgradeAgent(address newAgent);
    event FreezeUpgrade();
    event UnfreezeUpgrade();
    event Upgrade(address indexed from, address indexed to, uint value);

    modifier onlyUpgradeMaster() {
		require(msg.sender == upgradeMaster);
		_;
	}

    modifier canUpgrade() {
		require(isUpgradable);
		_;
	}

    /**
     * Change the upgrade master.
     * @param _newMaster New upgrade master.
     */
    function changeUpgradeMaster(address _newMaster)
        public
        onlyOwner
    {
        require(_newMaster != 0);

        upgradeMaster = _newMaster;
        ChangeUpgradeMaster(_newMaster);
    }

    /**
     * Change the upgrade agent.
     * @param _newAgent New upgrade agent.
     */
    function changeUpgradeAgent(address _newAgent)
        public
        onlyOwner
    {
        require(totalUpgraded == 0);

        upgradeAgent = UpgradeAgent(_newAgent);

        // Bad interface
        if (!upgradeAgent.isUpgradeAgent()) {
            revert();
        }

        ChangeUpgradeAgent(_newAgent);
    }

    /**
     * Disallow to upgrade token to new smart contract
     */
    function freezeUpgrade()
        public
        onlyOwner
    {
        isUpgradable = false;
        FreezeUpgrade();
    }

    /**
     * Allow to upgrade token to new smart contract
     */
    function unfreezeUpgrade()
        public
        onlyOwner
    {
        isUpgradable = true;
        UnfreezeUpgrade();
    }

    /**
     * Token holder upgrade their tokens to a new smart contract.
     */
    function upgrade()
        public
        canUpgrade
    {
        uint amount = balanceOf[msg.sender];

        require(amount > 0);

        processUpgrade(msg.sender, amount);
    }

    /**
     * Upgrader upgrade tokens of holder to a new smart contract.
     * @param _holders List of token holder.
     */
    function forceUpgrade(address[] _holders)
        public
        onlyUpgradeMaster
        canUpgrade
    {
        uint amount;

        for (uint i = 0; i < _holders.length; i++) {
            amount = balanceOf[_holders[i]];

            if (amount == 0) {
                continue;
            }

            processUpgrade(_holders[i], amount);
        }
    }

    function processUpgrade(address _holder, uint _amount)
        private
    {
        balanceOf[_holder] = balanceOf[_holder].sub(_amount);

        // Take tokens out from circulation
        totalSupply = totalSupply.sub(_amount);
        totalUpgraded = totalUpgraded.add(_amount);

        // Upgrade agent reissues the tokens
        upgradeAgent.upgradeFrom(_holder, _amount);
        Upgrade(_holder, upgradeAgent, _amount);
    }

}

/**
 * @title QNTU 1.0 token
 */
contract QNTU is UpgradableToken, CappedToken, PausableToken {

    /**
	 * @dev Constructor
	 */
    function QNTU()
        public
    {
        symbol = "QNTU";
        name = "QNTU Token";
        decimals = 18;

        uint multiplier = 10 ** uint(decimals);

        cap = 120000000000 * multiplier;
        totalSupply = 72000000000 * multiplier;

        // 40%
        balanceOf[0xd83ef0076580e595b3be39d654da97184623b9b5] = 4800000000 * multiplier;
        balanceOf[0xd4e40860b41f666fbc6c3007f3d1434e353063d8] = 4800000000 * multiplier;
        balanceOf[0x84dd4187a87055495d0c08fe260ca9cc9e02f09e] = 4800000000 * multiplier;
        balanceOf[0x0556620d12c38babd0461e366b433682a5000fae] = 4800000000 * multiplier;
        balanceOf[0x0f363f18f49aa350ba8fcf233cdd155a7b77af99] = 4800000000 * multiplier;
        balanceOf[0x1a38292d3f685cd79bcdfc19fad7447ae762aa4c] = 4800000000 * multiplier;
        balanceOf[0xb262d04ee29ad9ebacb1ab9da99398916f425d84] = 4800000000 * multiplier;
        balanceOf[0xd8c2d6f12baf10258eb390be4377e460c1d033e2] = 4800000000 * multiplier;
        balanceOf[0x1ca70fd8433ec97fa0777830a152d028d71b88fa] = 4800000000 * multiplier;
        balanceOf[0x57be4b8c57c0bb061e05fdf85843503fba673394] = 4800000000 * multiplier;

        Transfer(0, 0xd83ef0076580e595b3be39d654da97184623b9b5, 4800000000 * multiplier);
        Transfer(0, 0xd4e40860b41f666fbc6c3007f3d1434e353063d8, 4800000000 * multiplier);
        Transfer(0, 0x84dd4187a87055495d0c08fe260ca9cc9e02f09e, 4800000000 * multiplier);
        Transfer(0, 0x0556620d12c38babd0461e366b433682a5000fae, 4800000000 * multiplier);
        Transfer(0, 0x0f363f18f49aa350ba8fcf233cdd155a7b77af99, 4800000000 * multiplier);
        Transfer(0, 0x1a38292d3f685cd79bcdfc19fad7447ae762aa4c, 4800000000 * multiplier);
        Transfer(0, 0xb262d04ee29ad9ebacb1ab9da99398916f425d84, 4800000000 * multiplier);
        Transfer(0, 0xd8c2d6f12baf10258eb390be4377e460c1d033e2, 4800000000 * multiplier);
        Transfer(0, 0x1ca70fd8433ec97fa0777830a152d028d71b88fa, 4800000000 * multiplier);
        Transfer(0, 0x57be4b8c57c0bb061e05fdf85843503fba673394, 4800000000 * multiplier);

        // 20%
        balanceOf[0xb6ff15b634571cb56532022fe00f96fee51322b3] = 4800000000 * multiplier;
        balanceOf[0x631c87278de77902e762ba0ab57d55c10716e0b6] = 4800000000 * multiplier;
        balanceOf[0x7fe443391d9a3eb0c401181c46a44eb6106bba2e] = 4800000000 * multiplier;
        balanceOf[0x94905c20fa2596fdc7d37bab6dd67b52e2335122] = 4800000000 * multiplier;
        balanceOf[0x6ad8038f53ae2800d45a31d8261b062a0b55d63b] = 4800000000 * multiplier;

        Transfer(0, 0xb6ff15b634571cb56532022fe00f96fee51322b3, 4800000000 * multiplier);
        Transfer(0, 0x631c87278de77902e762ba0ab57d55c10716e0b6, 4800000000 * multiplier);
        Transfer(0, 0x7fe443391d9a3eb0c401181c46a44eb6106bba2e, 4800000000 * multiplier);
        Transfer(0, 0x94905c20fa2596fdc7d37bab6dd67b52e2335122, 4800000000 * multiplier);
        Transfer(0, 0x6ad8038f53ae2800d45a31d8261b062a0b55d63b, 4800000000 * multiplier);
    }

}
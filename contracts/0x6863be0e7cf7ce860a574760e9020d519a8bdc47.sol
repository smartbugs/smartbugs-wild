/* solhint-disable no-simple-event-func-name */

pragma solidity 0.4.18;


/*
 * https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * The MIT License (MIT)
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
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


/*
 * https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * The MIT License (MIT)
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
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


/*
 * https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * The MIT License (MIT)
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/*
 * https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * The MIT License (MIT)
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping (address => uint256) internal balances;

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
 * @title A token that can decrease its supply
 * @author Jakub Stefanski (https://github.com/jstefanski)
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
 */
contract BurnableToken is BasicToken {

    using SafeMath for uint256;

    /**
     * @dev Address where burned tokens are Transferred.
     * @dev This is useful for blockchain explorers operating on Transfer event.
     */
    address public constant BURN_ADDRESS = address(0x0);

    /**
     * @dev Tokens destroyed from specified address
     * @param from address The burner
     * @param amount uint256 The amount of destroyed tokens
     */
    event Burned(address indexed from, uint256 amount);

    modifier onlyHolder(uint256 amount) {
        require(balances[msg.sender] >= amount);
        _;
    }

    /**
     * @dev Destroy tokens (reduce total supply)
     * @param amount uint256 The amount of tokens to be burned
     */
    function burn(uint256 amount)
        public
        onlyHolder(amount)
    {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply = totalSupply.sub(amount);

        Burned(msg.sender, amount);
        Transfer(msg.sender, BURN_ADDRESS, amount);
    }
}


/**
 * @title A token with modifiable name and symbol
 * @author Jakub Stefanski (https://github.com/jstefanski)
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
 */
contract DescriptiveToken is BasicToken, Ownable {

    string public name;
    string public symbol;
    bool public isDescriptionFinalized;
    uint256 public decimals = 18;

    function DescriptiveToken(
        string _name,
        string _symbol
    )
        public
        onlyNotEmpty(_name)
        onlyNotEmpty(_symbol)
    {
        name = _name;
        symbol = _symbol;
    }

    /**
     * @dev Logs change of token name and symbol
     * @param name string The new token name
     * @param symbol string The new token symbol
     */
    event DescriptionChanged(string name, string symbol);

    /**
     * @dev Further changes to name and symbol are forbidden
     */
    event DescriptionFinalized();

    modifier onlyNotEmpty(string str) {
        require(bytes(str).length > 0);
        _;
    }

    modifier onlyDescriptionNotFinalized() {
        require(!isDescriptionFinalized);
        _;
    }

    /**
     * @dev Change name and symbol of tokens
     * @dev May be used in case of symbol collisions in exchanges.
     * @param _name string A new token name
     * @param _symbol string A new token symbol
     */
    function changeDescription(string _name, string _symbol)
        public
        onlyOwner
        onlyDescriptionNotFinalized
        onlyNotEmpty(_name)
        onlyNotEmpty(_symbol)
    {
        name = _name;
        symbol = _symbol;

        DescriptionChanged(name, symbol);
    }

    /**
     * @dev Prevents further changes to name and symbol
     */
    function finalizeDescription()
        public
        onlyOwner
        onlyDescriptionNotFinalized
    {
        isDescriptionFinalized = true;

        DescriptionFinalized();
    }
}


/**
 * @title A token that can increase its supply in initial period
 * @author Jakub Stefanski (https://github.com/jstefanski)
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
 */
contract MintableToken is BasicToken, Ownable {

    using SafeMath for uint256;

    /**
     * @dev Address from which minted tokens are Transferred.
     * @dev This is useful for blockchain explorers operating on Transfer event.
     */
    address public constant MINT_ADDRESS = address(0x0);

    /**
     * @dev Indicates whether creating tokens has finished
     */
    bool public mintingFinished;

    /**
     * @dev Addresses allowed to create tokens
     */
    mapping (address => bool) public isMintingManager;

    /**
     * @dev Tokens minted to specified address
     * @param to address The receiver of the tokens
     * @param amount uint256 The amount of tokens
     */
    event Minted(address indexed to, uint256 amount);

    /**
     * @dev Approves specified address as a Minting Manager
     * @param addr address The approved address
     */
    event MintingManagerApproved(address addr);

    /**
     * @dev Revokes specified address as a Minting Manager
     * @param addr address The revoked address
     */
    event MintingManagerRevoked(address addr);

    /**
     * @dev Creation of tokens finished
     */
    event MintingFinished();

    modifier onlyMintingManager(address addr) {
        require(isMintingManager[addr]);
        _;
    }

    modifier onlyMintingNotFinished {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Approve specified address to mint tokens
     * @param addr address The approved Minting Manager address
     */
    function approveMintingManager(address addr)
        public
        onlyOwner
        onlyMintingNotFinished
    {
        isMintingManager[addr] = true;

        MintingManagerApproved(addr);
    }

    /**
     * @dev Forbid specified address to mint tokens
     * @param addr address The denied Minting Manager address
     */
    function revokeMintingManager(address addr)
        public
        onlyOwner
        onlyMintingManager(addr)
        onlyMintingNotFinished
    {
        delete isMintingManager[addr];

        MintingManagerRevoked(addr);
    }

    /**
     * @dev Create new tokens and transfer them to specified address
     * @param to address The address to transfer to
     * @param amount uint256 The amount to be minted
     */
    function mint(address to, uint256 amount)
        public
        onlyMintingManager(msg.sender)
        onlyMintingNotFinished
    {
        totalSupply = totalSupply.add(amount);
        balances[to] = balances[to].add(amount);

        Minted(to, amount);
        Transfer(MINT_ADDRESS, to, amount);
    }

    /**
     * @dev Prevent further creation of tokens
     */
    function finishMinting()
        public
        onlyOwner
        onlyMintingNotFinished
    {
        mintingFinished = true;

        MintingFinished();
    }
}


/**
 * @title A token that can increase its supply to the specified limit
 * @author Jakub Stefanski (https://github.com/jstefanski)
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
 */
contract CappedMintableToken is MintableToken {

    /**
     * @dev Maximum supply that can be minted
     */
    uint256 public maxSupply;

    function CappedMintableToken(uint256 _maxSupply)
        public
        onlyNotZero(_maxSupply)
    {
        maxSupply = _maxSupply;
    }

    modifier onlyNotZero(uint256 value) {
        require(value != 0);
        _;
    }

    modifier onlyNotExceedingMaxSupply(uint256 supply) {
        require(supply <= maxSupply);
        _;
    }

    /**
     * @dev Create new tokens and transfer them to specified address
     * @dev Checks against capped max supply of token.
     * @param to address The address to transfer to
     * @param amount uint256 The amount to be minted
     */
    function mint(address to, uint256 amount)
        public
        onlyNotExceedingMaxSupply(totalSupply.add(amount))
    {
        return MintableToken.mint(to, amount);
    }
}


/*
 * https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * The MIT License (MIT)
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/*
 * https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * The MIT License (MIT)
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
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
 * @title ERC20 token with manual initial lock up period
 * @author Jakub Stefanski (https://github.com/jstefanski)
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
 */
contract ReleasableToken is StandardToken, Ownable {

    /**
     * @dev Controls whether token transfers are enabled
     * @dev If false, token is in transfer lock up period.
     */
    bool public released;

    /**
     * @dev Contract or EOA that can enable token transfers
     */
    address public releaseManager;

    /**
     * @dev Map of addresses allowed to transfer tokens despite the lock up period
     */
    mapping (address => bool) public isTransferManager;

    /**
     * @dev Specified address set as a Release Manager
     * @param addr address The approved address
     */
    event ReleaseManagerSet(address addr);

    /**
     * @dev Approves specified address as Transfer Manager
     * @param addr address The approved address
     */
    event TransferManagerApproved(address addr);

    /**
     * @dev Revokes specified address as Transfer Manager
     * @param addr address The denied address
     */
    event TransferManagerRevoked(address addr);

    /**
     * @dev Marks token as released (transferable)
     */
    event Released();

    /**
     * @dev Token is released or specified address is transfer manager
     */
    modifier onlyTransferableFrom(address from) {
        if (!released) {
            require(isTransferManager[from]);
        }

        _;
    }

    /**
     * @dev Specified address is transfer manager
     */
    modifier onlyTransferManager(address addr) {
        require(isTransferManager[addr]);
        _;
    }

    /**
     * @dev Sender is release manager
     */
    modifier onlyReleaseManager() {
        require(msg.sender == releaseManager);
        _;
    }

    /**
     * @dev Token is released (transferable)
     */
    modifier onlyReleased() {
        require(released);
        _;
    }

    /**
     * @dev Token is in lock up period
     */
    modifier onlyNotReleased() {
        require(!released);
        _;
    }

    /**
     * @dev Set release manager if token not released yet
     * @param addr address The new Release Manager address
     */
    function setReleaseManager(address addr)
        public
        onlyOwner
        onlyNotReleased
    {
        releaseManager = addr;

        ReleaseManagerSet(addr);
    }

    /**
     * @dev Approve specified address to make transfers in lock up period
     * @param addr address The approved Transfer Manager address
     */
    function approveTransferManager(address addr)
        public
        onlyOwner
        onlyNotReleased
    {
        isTransferManager[addr] = true;

        TransferManagerApproved(addr);
    }

    /**
     * @dev Forbid specified address to make transfers in lock up period
     * @param addr address The denied Transfer Manager address
     */
    function revokeTransferManager(address addr)
        public
        onlyOwner
        onlyTransferManager(addr)
        onlyNotReleased
    {
        delete isTransferManager[addr];

        TransferManagerRevoked(addr);
    }

    /**
     * @dev Release token and makes it transferable
     */
    function release()
        public
        onlyReleaseManager
        onlyNotReleased
    {
        released = true;

        Released();
    }

    /**
     * @dev Transfer token to a specified address
     * @dev Available only after token release
     * @param to address The address to transfer to
     * @param amount uint256 The amount to be transferred
     */
    function transfer(
        address to,
        uint256 amount
    )
        public
        onlyTransferableFrom(msg.sender)
        returns (bool)
    {
        return super.transfer(to, amount);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @dev Available only after token release
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        onlyTransferableFrom(from)
        returns (bool)
    {
        return super.transferFrom(from, to, amount);
    }
}


/**
 * @title OnLive Token
 * @author Jakub Stefanski (https://github.com/jstefanski)
 * @dev Implements ERC20 interface
 * @dev Mintable by selected addresses until sale finishes
 * @dev A cap on total supply of tokens
 * @dev Burnable by anyone
 * @dev Manual lock-up period (non-transferable) with a non-reversible release by the selected address
 * @dev Modifiable symbol and name in case of collision
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
 */
contract OnLiveToken is DescriptiveToken, ReleasableToken, CappedMintableToken, BurnableToken {

    function OnLiveToken(
        string _name,
        string _symbol,
        uint256 _maxSupply
    )
        public
        DescriptiveToken(_name, _symbol)
        CappedMintableToken(_maxSupply)
    {
        owner = msg.sender;
    }
}
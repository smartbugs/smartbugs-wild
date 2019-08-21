pragma solidity 0.4.24;
pragma experimental "v0.5.0";

contract Administration {

    using SafeMath for uint256;

    address public owner;
    address public admin;

    event AdminSet(address _admin);
    event OwnershipTransferred(address _previousOwner, address _newOwner);


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner || msg.sender == admin);
        _;
    }

    modifier nonZeroAddress(address _addr) {
        require(_addr != address(0), "must be non zero address");
        _;
    }

    constructor() public {
        owner = msg.sender;
        admin = msg.sender;
    }

    function setAdmin(
        address _newAdmin
    )
        public
        onlyOwner
        nonZeroAddress(_newAdmin)
        returns (bool)
    {
        require(_newAdmin != admin);
        admin = _newAdmin;
        emit AdminSet(_newAdmin);
        return true;
    }

    function transferOwnership(
        address _newOwner
    )
        public
        onlyOwner
        nonZeroAddress(_newOwner)
        returns (bool)
    {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
        return true;
    }

}


library SafeMath {

  // We use `pure` bbecause it promises that the value for the function depends ONLY
  // on the function arguments
    function mul(uint256 a, uint256 b) internal pure  returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

/*
    ERC20 Standard Token interface
*/
interface ERC20Interface {
    function owner() external view returns (address);
    function decimals() external view returns (uint8);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
}

interface StakeInterface {
    function activeStakes() external view returns (uint256);
}

/// @title RTC Token Contract
/// @author Postables, RTrade Technologies Ltd
/// @dev We able V5 for safety features, see https://solidity.readthedocs.io/en/v0.4.24/security-considerations.html#take-warnings-seriously
contract RTCoin is Administration {

    using SafeMath for uint256;

    // this is the initial supply of tokens, 61.6 Million
    uint256 constant public INITIALSUPPLY = 61600000000000000000000000;
    string  constant public VERSION = "production";

    // this is the interface that allows interaction with the staking contract
    StakeInterface public stake = StakeInterface(0);
    // this is the address of the staking contract
    address public  stakeContractAddress = address(0);
    // This is the address of the merged mining contract, not yet developed
    address public  mergedMinerValidatorAddress = address(0);
    string  public  name = "RTCoin";
    string  public  symbol = "RTC";
    uint256 public  totalSupply = INITIALSUPPLY;
    uint8   public  decimals = 18;
    // allows transfers to be frozen, but enable them by default
    bool    public  transfersFrozen = true;
    bool    public  stakeFailOverRestrictionLifted = false;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    mapping (address => bool) public minters;

    event Transfer(address indexed _sender, address indexed _recipient, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
    event TransfersFrozen(bool indexed _transfersFrozen);
    event TransfersThawed(bool indexed _transfersThawed);
    event ForeignTokenTransfer(address indexed _sender, address indexed _recipient, uint256 _amount);
    event EthTransferOut(address indexed _recipient, uint256 _amount);
    event MergedMinerValidatorSet(address _contractAddress);
    event StakeContractSet(address _contractAddress);
    event FailOverStakeContractSet(address _contractAddress);
    event CoinsMinted(address indexed _stakeContract, address indexed _recipient, uint256 _mintAmount);

    modifier transfersNotFrozen() {
        require(!transfersFrozen, "transfers must not be frozen");
        _;
    }

    modifier transfersAreFrozen() {
        require(transfersFrozen, "transfers must be frozen");
        _;
    }

    // makes sure that only the stake contract, or merged miner validator contract can mint coins
    modifier onlyMinters() {
        require(minters[msg.sender] == true, "sender must be a valid minter");
        _;
    }

    modifier nonZeroAddress(address _addr) {
        require(_addr != address(0), "must be non zero address");
        _;
    }

    modifier nonAdminAddress(address _addr) {
        require(_addr != owner && _addr != admin, "addr cant be owner or admin");
        _;
    }

    constructor() public {
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /** @notice Used to transfer tokens
        * @param _recipient This is the recipient of the transfer
        * @param _amount This is the amount of tokens to send
     */
    function transfer(
        address _recipient,
        uint256 _amount
    )
        public
        transfersNotFrozen
        nonZeroAddress(_recipient)
        returns (bool)
    {
        // check that the sender has a valid balance
        require(balances[msg.sender] >= _amount, "sender does not have enough tokens");
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_recipient] = balances[_recipient].add(_amount);
        emit Transfer(msg.sender, _recipient, _amount);
        return true;
    }

    /** @notice Used to transfer tokens on behalf of someone else
        * @param _recipient This is the recipient of the transfer
        * @param _amount This is the amount of tokens to send
     */
    function transferFrom(
        address _owner,
        address _recipient,
        uint256 _amount
    )
        public
        transfersNotFrozen
        nonZeroAddress(_recipient)
        returns (bool)
    {
        // ensure owner has a valid balance
        require(balances[_owner] >= _amount, "owner does not have enough tokens");
        // ensure that the spender has a valid allowance
        require(allowed[_owner][msg.sender] >= _amount, "sender does not have enough allowance");
        // reduce the allowance
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_amount);
        // reduce balance of owner
        balances[_owner] = balances[_owner].sub(_amount);
        // increase balance of recipient
        balances[_recipient] = balances[_recipient].add(_amount);
        emit Transfer(_owner, _recipient, _amount);
        return true;
    }

    /** @notice This is used to approve someone to send tokens on your behalf
        * @param _spender This is the person who can spend on your behalf
        * @param _value This is the amount of tokens that they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // NON STANDARD FUNCTIONS //

    /** @notice This is used to set the merged miner validator contract
        * @param _mergedMinerValidator this is the address of the mergedmining contract
     */
    function setMergedMinerValidator(address _mergedMinerValidator) external onlyOwner nonAdminAddress(_mergedMinerValidator) returns (bool) {
        mergedMinerValidatorAddress = _mergedMinerValidator;
        minters[_mergedMinerValidator] = true;
        emit MergedMinerValidatorSet(_mergedMinerValidator);
        return true;
    }

    /** @notice This is used to set the staking contract
        * @param _contractAddress this is the address of the staking contract
    */
    function setStakeContract(address _contractAddress) external onlyOwner nonAdminAddress(_contractAddress) returns (bool) {
        // this prevents us from changing contracts while there are active stakes going on
        if (stakeContractAddress != address(0)) {
            require(stake.activeStakes() == 0, "staking contract already configured, to change it must have 0 active stakes");
        }
        stakeContractAddress = _contractAddress;
        minters[_contractAddress] = true;
        stake = StakeInterface(_contractAddress);
        emit StakeContractSet(_contractAddress);
        return true;
    }

    /** @notice Emergency use function designed to prevent stake deadlocks, allowing a fail-over stake contract to be implemented
        * Requires 2 transaction, the first lifts the restriction, the second enables the restriction and sets the contract
        * @dev We restrict to the owner address for security reasons, and don't update the stakeContractAddress variable to avoid breaking compatability
        * @param _contractAddress This is the address of the stake contract
     */
    function setFailOverStakeContract(address _contractAddress) external onlyOwner nonAdminAddress(_contractAddress) returns (bool) {
        if (stakeFailOverRestrictionLifted == false) {
            stakeFailOverRestrictionLifted = true;
            return true;
        } else {
            minters[_contractAddress] = true;
            stakeFailOverRestrictionLifted = false;
            emit FailOverStakeContractSet(_contractAddress);
            return true;
        }
    }

    /** @notice This is used to mint new tokens
        * @dev Can only be executed by the staking, and merged miner validator contracts
        * @param _recipient This is the person who will received the mint tokens
        * @param _amount This is the amount of tokens that they will receive and which will be generated
     */
    function mint(
        address _recipient,
        uint256 _amount)
        public
        onlyMinters
        returns (bool)
    {
        balances[_recipient] = balances[_recipient].add(_amount);
        totalSupply = totalSupply.add(_amount);
        emit Transfer(address(0), _recipient, _amount);
        emit CoinsMinted(msg.sender, _recipient, _amount);
        return true;
    }

    /** @notice Allow us to transfer tokens that someone might've accidentally sent to this contract
        @param _tokenAddress this is the address of the token contract
        @param _recipient This is the address of the person receiving the tokens
        @param _amount This is the amount of tokens to send
     */
    function transferForeignToken(
        address _tokenAddress,
        address _recipient,
        uint256 _amount)
        public
        onlyAdmin
        nonZeroAddress(_recipient)
        returns (bool)
    {
        // don't allow us to transfer RTC tokens
        require(_tokenAddress != address(this), "token address can't be this contract");
        ERC20Interface eI = ERC20Interface(_tokenAddress);
        require(eI.transfer(_recipient, _amount), "token transfer failed");
        emit ForeignTokenTransfer(msg.sender, _recipient, _amount);
        return true;
    }
    
    /** @notice Transfers eth that is stuck in this contract
        * ETH can be sent to the address this contract resides at before the contract is deployed
        * A contract can be suicided, forcefully sending ether to this contract
     */
    function transferOutEth()
        public
        onlyAdmin
        returns (bool)
    {
        uint256 balance = address(this).balance;
        msg.sender.transfer(address(this).balance);
        emit EthTransferOut(msg.sender, balance);
        return true;
    }

    /** @notice Used to freeze token transfers
     */
    function freezeTransfers()
        public
        onlyAdmin
        returns (bool)
    {
        transfersFrozen = true;
        emit TransfersFrozen(true);
        return true;
    }

    /** @notice Used to thaw token transfers
     */
    function thawTransfers()
        public
        onlyAdmin
        returns (bool)
    {
        transfersFrozen = false;
        emit TransfersThawed(true);
        return true;
    }


    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**GETTERS */

    /** @notice Used to get the total supply
     */
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return totalSupply;
    }

    /** @notice Used to get the balance of a holder
        * @param _holder The address of the token holder
     */
    function balanceOf(
        address _holder
    )
        public
        view
        returns (uint256)
    {
        return balances[_holder];
    }

    /** @notice Used to get the allowance of someone
        * @param _owner The address of the token owner
        * @param _spender The address of thhe person allowed to spend funds on behalf of the owner
     */
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

}
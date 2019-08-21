pragma solidity ^0.4.24;


/// @title ERC-20 interface
/// @dev Full ERC-20 interface is described at https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md.
interface ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}


/// @title ERC-677 (excluding ERC-20) interface
/// @dev Full ERC-677 interface is discussed at https://github.com/ethereum/EIPs/issues/677.
interface ERC677 {

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    function transferAndCall(address to, uint256 value, bytes data) external returns (bool);
}


/// @title ERC-677 mint/burn/claim extension interface
/// @dev Extension of ERC-677 interface for allowing using a token in Token Bridge.
interface ERC677Bridgeable {

    event Mint(address indexed receiver, uint256 value);
    event Burn(address indexed burner, uint256 value);

    function mint(address receiver, uint256 value) external returns (bool);
    function burn(uint256 value) external;
    function claimTokens(address token, address to) external;
}


/// @title SafeMath
/// @dev Math operations with safety checks that throw on error.
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


/// @title SafeOwnable
/// @dev The SafeOwnable contract has an owner address, and provides basic authorization control
/// functions, this simplifies the implementation of "user permissions".
contract SafeOwnable {

    // EVENTS

    event OwnershipProposed(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // PUBLIC FUNCTIONS

    /// @dev The SafeOwnable constructor sets the original `owner` of the contract to the sender account.
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /// @dev Allows the current owner to propose control of the contract to a new owner.
    /// @param newOwner The address to propose ownership to.
    function proposeOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0) && newOwner != _owner);
        _ownerCandidate = newOwner;
        emit OwnershipProposed(_owner, _ownerCandidate);
    }

    /// @dev Allows the current owner candidate to accept proposed ownership and set actual owner of a contract.
    function acceptOwnership() public onlyOwnerCandidate {
        emit OwnershipTransferred(_owner, _ownerCandidate);
        _owner = _ownerCandidate;
        _ownerCandidate = address(0);
    }

    /// @dev Returns the address of the owner.
    function owner() public view returns (address) {
        return _owner;
    }

    /// @dev Returns the address of the owner candidate.
    function ownerCandidate() public view returns (address) {
        return _ownerCandidate;
    }

    // MODIFIERS

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    /// @dev Throws if called by any account other than the owner candidate.
    modifier onlyOwnerCandidate() {
        require(msg.sender == _ownerCandidate);
        _;
    }

    // FIELDS

    address internal _owner;
    address internal _ownerCandidate;
}


/// @title Standard ERC-20 token
/// @dev Implementation of the basic ERC-20 token.
contract TokenERC20 is ERC20 {
    using SafeMath for uint256;

    // PUBLIC FUNCTIONS

    /// @dev Transfers tokens to a specified address.
    /// @param to The address to transfer tokens to.
    /// @param value The amount of tokens to be transferred.
    /// @return A boolean that indicates if the operation was successful.
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /// @dev Transfers tokens from one address to another.
    /// @param from The address to transfer tokens from.
    /// @param to The address to transfer tokens to.
    /// @param value The amount of tokens to be transferred.
    /// @return A boolean that indicates if the operation was successful.
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _decreaseAllowance(from, msg.sender, value);
        _transfer(from, to, value);
        return true;
    }

    /// @dev Approves a specified address to spend a specified amount of tokens on behalf of msg.sender.
    /// Beware that changing an allowance with this method brings the risk that someone may use both the old
    /// and the new allowance by an unfortunate transaction ordering. One possible solution to mitigate this
    /// rare condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    /// @param spender Address which will be allowed to spend the tokens.
    /// @param value Amount of tokens to allow to be spent.
    /// @return A boolean that indicates if the operation was successful.
    function approve(address spender, uint256 value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /// @dev Increases the amount of tokens that an owner allowed to spent by the spender.
    /// Method approve() should be called when _allowances[spender] == 0. To decrement allowance
    /// is better to use this function to avoid 2 calls (and wait until the first transaction is mined).
    /// @param spender The address which will spend the tokens.
    /// @param value The amount of tokens to increase the allowance by.
    /// @return A boolean that indicates if the operation was successful.
    function increaseAllowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _increaseAllowance(msg.sender, spender, value);
        return true;
    }

    /// @dev Decreases the amount of tokens that an owner allowed to spent by the spender.
    /// Method approve() should be called when _allowances[spender] == 0. To decrement allowance
    /// is better to use this function to avoid 2 calls (and wait until the first transaction is mined).
    /// @param spender The address which will spend the tokens.
    /// @param value The amount of tokens to decrease the allowance by.
    /// @return A boolean that indicates if the operation was successful.
    function decreaseAllowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _decreaseAllowance(msg.sender, spender, value);
        return true;
    }

    /// @dev Returns total amount of tokens in existence.
    /// @return A uint256 representing the amount of tokens in existence.
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @dev Gets the balance of a specified address.
    /// @param owner The address to query the balance of.
    /// @return A uint256 representing the amount of tokens owned by the specified address.
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /// @dev Function to check the amount of tokens that an owner allowed to spend by the spender.
    /// @param owner The address which owns the tokens.
    /// @param spender The address which will spend the tokens.
    /// @return A uint256 representing the amount of tokens still available to spend by the spender.
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // INTERNAL FUNCTIONS

    /// @dev Transfers tokens from one address to another address.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param value The amount to be transferred.
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /// @dev Increases the amount of tokens that an owner allowed to spent by the spender.
    /// Method approve() should be called when _allowances[spender] == 0. To decrement allowance
    /// is better to use this function to avoid 2 calls (and wait until the first transaction is mined).
    /// @param owner The address which owns the tokens.
    /// @param spender The address which will spend the tokens.
    /// @param value The amount of tokens to increase the allowance by.
    function _increaseAllowance(address owner, address spender, uint256 value) internal {
        require(value > 0);
        _allowances[owner][spender] = _allowances[owner][spender].add(value);
        emit Approval(owner, spender, _allowances[owner][spender]);
    }

    /// @dev Decreases the amount of tokens that an owner allowed to spent by the spender.
    /// Method approve() should be called when _allowances[spender] == 0. To decrement allowance
    /// is better to use this function to avoid 2 calls (and wait until the first transaction is mined).
    /// @param owner The address which owns the tokens.
    /// @param spender The address which will spend the tokens.
    /// @param value The amount of tokens to decrease the allowance by.
    function _decreaseAllowance(address owner, address spender, uint256 value) internal {
        require(value > 0 && value <= _allowances[owner][spender]);
        _allowances[owner][spender] = _allowances[owner][spender].sub(value);
        emit Approval(owner, spender, _allowances[owner][spender]);
    }

    /// @dev Internal function that mints specified amount of tokens and assigns it to an address.
    /// This encapsulates the modification of balances such that the proper events are emitted.
    /// @param receiver The address that will receive the minted tokens.
    /// @param value The amount of tokens that will be minted.
    function _mint(address receiver, uint256 value) internal {
        require(receiver != address(0));
        require(value > 0);
        _balances[receiver] = _balances[receiver].add(value);
        _totalSupply = _totalSupply.add(value);
        //_totalMinted = _totalMinted.add(value);
        emit Transfer(address(0), receiver, value);
    }

    /// @dev Internal function that burns specified amount of tokens of a given address.
    /// @param burner The address from which tokens will be burnt.
    /// @param value The amount of tokens that will be burnt.
    function _burn(address burner, uint256 value) internal {
        require(burner != address(0));
        require(value > 0 && value <= _balances[burner]);
        _balances[burner] = _balances[burner].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(burner, address(0), value);
    }

    /// @dev Internal function that burns specified amount of tokens of a given address,
    /// deducting from the sender's allowance for said account. Uses the internal burn function.
    /// @param burner The address from which tokens will be burnt.
    /// @param value The amount of tokens that will be burnt.
    function _burnFrom(address burner, uint256 value) internal {
        _decreaseAllowance(burner, msg.sender, value);
        _burn(burner, value);
    }

    // FIELDS

    uint256 internal _totalSupply;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping(address => uint256)) internal _allowances;
}


/// @title Papyrus Token contract (PPR).
contract PapyrusToken is SafeOwnable, TokenERC20, ERC677, ERC677Bridgeable {

    // EVENTS

    event ControlByOwnerRevoked();
    event MintableChanged(bool mintable);
    event TransferableChanged(bool transferable);
    event ContractFallbackCallFailed(address from, address to, uint256 value);
    event BridgeContractChanged(address indexed previousBridgeContract, address indexed newBridgeContract);

    // PUBLIC FUNCTIONS

    constructor() public {
        _totalSupply = PPR_INITIAL_SUPPLY;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /// @dev Transfers tokens to a specified address with additional data if the recipient is a contact.
    /// @param to The address to transfer tokens to.
    /// @param value The amount of tokens to be transferred.
    /// @param data The extra data to be passed to the receiving contract.
    /// @return A boolean that indicates if the operation was successful.
    function transferAndCall(address to, uint256 value, bytes data) external canTransfer returns (bool) {
        require(to != address(this));
        require(super.transfer(to, value));
        emit Transfer(msg.sender, to, value, data);
        if (isContract(to)) {
            require(contractFallback(msg.sender, to, value, data));
        }
        return true;
    }

    /// @dev Transfers tokens to a specified address.
    /// @param to The address to transfer tokens to.
    /// @param value The amount of tokens to be transferred.
    /// @return A boolean that indicates if the operation was successful.
    function transfer(address to, uint256 value) public canTransfer returns (bool) {
        require(super.transfer(to, value));
        if (isContract(to) && !contractFallback(msg.sender, to, value, new bytes(0))) {
            if (to == _bridgeContract) {
                revert();
            }
            emit ContractFallbackCallFailed(msg.sender, to, value);
        }
        return true;
    }

    /// @dev Transfers tokens from one address to another.
    /// @param from The address to transfer tokens from.
    /// @param to The address to transfer tokens to.
    /// @param value The amount of tokens to be transferred.
    /// @return A boolean that indicates if the operation was successful.
    function transferFrom(address from, address to, uint256 value) public canTransfer returns (bool) {
        require(super.transferFrom(from, to, value));
        if (isContract(to) && !contractFallback(from, to, value, new bytes(0))) {
            if (to == _bridgeContract) {
                revert();
            }
            emit ContractFallbackCallFailed(from, to, value);
        }
        return true;
    }

    /// @dev Transfers tokens to a specified addresses (optimized version for initial sending tokens).
    /// @param recipients Addresses to transfer tokens to.
    /// @param values Amounts of tokens to be transferred.
    /// @return A boolean that indicates if the operation was successful.
    function airdrop(address[] recipients, uint256[] values) public canTransfer returns (bool) {
        require(recipients.length == values.length);
        uint256 senderBalance = _balances[msg.sender];
        for (uint256 i = 0; i < values.length; i++) {
            uint256 value = values[i];
            address to = recipients[i];
            require(senderBalance >= value);
            if (msg.sender != recipients[i]) {
                senderBalance = senderBalance - value;
                _balances[to] += value;
            }
            emit Transfer(msg.sender, to, value);
        }
        _balances[msg.sender] = senderBalance;
        return true;
    }

    /// @dev Mints specified amount of tokens and assigns it to a specified address.
    /// @param receiver The address that will receive the minted tokens.
    /// @param value The amount of tokens that will be minted.
    function mint(address receiver, uint256 value) public canMint returns (bool) {
        _mint(receiver, value);
        _totalMinted = _totalMinted.add(value);
        emit Mint(receiver, value);
        return true;
    }

    /// @dev Burns specified amount of tokens of the sender.
    /// @param value The amount of token to be burnt.
    function burn(uint256 value) public canBurn {
        _burn(msg.sender, value);
        _totalBurnt = _totalBurnt.add(value);
        emit Burn(msg.sender, value);
    }

    /// @dev Burns specified amount of tokens of the specified account.
    /// @param burner The address from which tokens will be burnt.
    /// @param value The amount of token to be burnt.
    function burnByOwner(address burner, uint256 value) public canBurnByOwner {
        _burn(burner, value);
        _totalBurnt = _totalBurnt.add(value);
        emit Burn(burner, value);
    }

    /// @dev Transfers funds stored on the token contract to specified recipient (required by token bridge).
    function claimTokens(address token, address to) public onlyOwnerOrBridgeContract {
        require(to != address(0));
        if (token == address(0)) {
            to.transfer(address(this).balance);
        } else {
            ERC20 erc20 = ERC20(token);
            uint256 balance = erc20.balanceOf(address(this));
            require(erc20.transfer(to, balance));
        }
    }

    /// @dev Revokes control by owner so it is not possible to burn tokens from any account by contract owner.
    function revokeControlByOwner() public onlyOwner {
        require(_controllable);
        _controllable = false;
        emit ControlByOwnerRevoked();
    }

    /// @dev Changes ability to mint tokens by permissioned accounts.
    function setMintable(bool mintable) public onlyOwner {
        require(_mintable != mintable);
        _mintable = mintable;
        emit MintableChanged(_mintable);
    }

    /// @dev Changes ability to transfer tokens by token holders.
    function setTransferable(bool transferable) public onlyOwner {
        require(_transferable != transferable);
        _transferable = transferable;
        emit TransferableChanged(_transferable);
    }

    /// @dev Changes address of token bridge contract.
    function setBridgeContract(address bridgeContract) public onlyOwner {
        require(_controllable);
        require(bridgeContract != address(0) && bridgeContract != _bridgeContract && isContract(bridgeContract));
        emit BridgeContractChanged(_bridgeContract, bridgeContract);
        _bridgeContract = bridgeContract;
    }

    /// @dev Turn off renounceOwnership() method from Ownable contract.
    function renounceOwnership() public pure {
        revert();
    }

    /// @dev Returns a boolean flag representing ability to burn tokens from any account by contract owner.
    /// @return A boolean that indicates if tokens can be burnt from any account by contract owner.
    function controllableByOwner() public view returns (bool) {
        return _controllable;
    }

    /// @dev Returns a boolean flag representing token mint ability.
    /// @return A boolean that indicates if tokens can be mintable by permissioned accounts.
    function mintable() public view returns (bool) {
        return _mintable;
    }

    /// @dev Returns a boolean flag representing token transfer ability.
    /// @return A boolean that indicates if tokens can be transferred by token holders.
    function transferable() public view returns (bool) {
        return _transferable;
    }

    /// @dev Returns an address of token bridge contract.
    /// @return An address of token bridge contract.
    function bridgeContract() public view returns (address) {
        return _bridgeContract;
    }

    /// @dev Returns total amount of minted tokens.
    /// @return A uint256 representing the amount of tokens were mint during token lifetime.
    function totalMinted() public view returns (uint256) {
        return _totalMinted;
    }

    /// @dev Returns total amount of burnt tokens.
    /// @return A uint256 representing the amount of tokens were burnt during token lifetime.
    function totalBurnt() public view returns (uint256) {
        return _totalBurnt;
    }

    /// @dev Returns version of token interfaces (required by token bridge).
    function getTokenInterfacesVersion() public pure returns (uint64, uint64, uint64) {
        uint64 major = 2;
        uint64 minor = 0;
        uint64 patch = 0;
        return (major, minor, patch);
    }

    // PRIVATE FUNCTIONS

    /// @dev Calls method onTokenTransfer() on specified contract address `receiver`.
    /// @return A boolean that indicates if the operation was successful.
    function contractFallback(address from, address receiver, uint256 value, bytes data) private returns (bool) {
        return receiver.call(abi.encodeWithSignature("onTokenTransfer(address,uint256,bytes)", from, value, data));
    }

    /// @dev Determines if specified address is contract address.
    /// @return A boolean that indicates if specified address is contract address.
    function isContract(address account) private view returns (bool) {
        uint256 codeSize;
        assembly { codeSize := extcodesize(account) }
        return codeSize > 0;
    }

    // MODIFIERS

    modifier onlyOwnerOrBridgeContract() {
        require(msg.sender == _owner || msg.sender == _bridgeContract);
        _;
    }

    modifier canMint() {
        require(_mintable);
        require(msg.sender == _owner || msg.sender == _bridgeContract);
        _;
    }

    modifier canBurn() {
        require(msg.sender == _owner || msg.sender == _bridgeContract);
        _;
    }

    modifier canBurnByOwner() {
        require(msg.sender == _owner && _controllable);
        _;
    }

    modifier canTransfer() {
        require(_transferable || msg.sender == _owner);
        _;
    }

    // FIELDS

    // Standard fields used to describe the token
    string public constant name = "Papyrus Token";
    string public constant symbol = "PPR";
    uint8 public constant decimals = 18;

    // At the start of the token existence it is fully controllable by owner
    bool private _controllable = true;

    // At the start of the token existence it is mintable
    bool private _mintable = true;

    // At the start of the token existence it is not transferable
    bool private _transferable = false;

    // Address of token bridge contract
    address private _bridgeContract;

    // Total amount of tokens minted during token lifetime
    uint256 private _totalMinted;
    // Total amount of tokens burnt during token lifetime
    uint256 private _totalBurnt;

    // Amount of initially supplied tokens is constant and equals to 1,000,000,000 PPR
    uint256 private constant PPR_INITIAL_SUPPLY = 10**27;
}
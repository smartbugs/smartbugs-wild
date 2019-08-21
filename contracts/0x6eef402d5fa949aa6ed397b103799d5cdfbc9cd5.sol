pragma solidity ^0.4.24;

interface ERC20Token {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    function transferFrom(address from, address to, uint256 amount) public returns (bool);
    function approve(address spender, uint256 amount) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

interface ERC777Token {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function totalSupply() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function granularity() public view returns (uint256);

    function defaultOperators() public view returns (address[]);
    function isOperatorFor(address operator, address tokenHolder) public view returns (bool);
    // function authorizeOperator(address operator) public;
    // function revokeOperator(address operator) public;

    function send(address to, uint256 amount, bytes data) public;
    function operatorSend(address from, address to, uint256 amount, bytes data, bytes operatorData) public;

    function burn(uint256 amount, bytes data) public;
    function operatorBurn(address from, uint256 amount, bytes data, bytes operatorData) public;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    ); // solhint-disable-next-line separate-by-one-line-in-contract
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

interface ERC777TokensRecipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes data,
        bytes operatorData
    ) public;
}


interface ERC777TokensSender {
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint amount,
        bytes userData,
        bytes operatorData
    ) public;
}


library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
    * @dev give an account access to this role
    */
    function add(Role storage role, address account) internal {
        require(account != address(0), "Address cannot be zero");
        require(!has(role, account), "Role already exist");

        role.bearer[account] = true;
    }

    /**
    * @dev remove an account's access to this role
    */
    function remove(Role storage role, address account) internal {
        require(account != address(0), "Address cannot be zero");
        require(has(role, account), "Role is nort exist");

        role.bearer[account] = false;
    }

    /**
    * @dev check if an account has this role
    * @return bool
    */
    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0), "Address cannot be zero");
        return role.bearer[account];
    }
}


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private pausers;

    constructor() internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "Account must be pauser");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        pausers.remove(account);
        emit PauserRemoved(account);
    }
}

contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() internal {
        _paused = false;
    }

    /**
    * @return true if the contract is paused, false otherwise.
    */
    function paused() public view returns(bool) {
        return _paused;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!_paused, "Paused");
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(_paused, "Not paused");
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner(), "You are not an owner");
        _;
    }

    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    /*function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }*/

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Address cannot be zero");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Transferable is Ownable {
    
    mapping(address => bool) private banned;
    
    modifier isTransferable() {
        require(!banned[msg.sender], "Account is frozen");
        _;
    }
    
    function freezeAccount(address account) public onlyOwner {
        banned[account] = true;
    }   
    
    function unfreezeAccount(address account) public onlyOwner {
        banned[account] = false;
    }

    function isAccountFrozen(address account) public view returns(bool) {
        return banned[account];
    }
    
} 

contract Whitelist is Pausable, Transferable {
    uint8 public constant version = 1;

    mapping (address => bool) private whitelistedMap;
    bool public isWhiteListDisabled;
    
    address[] private addedAdresses;
    address[] private removedAdresses;

    event Whitelisted(address indexed account, bool isWhitelisted);

    function whitelisted(address _address)
        public
        view
        returns(bool)
    {
        if (paused()) {
            return false;
        } else if(isWhiteListDisabled) {
            return true;
        }

        return whitelistedMap[_address];
    }

    function addAddress(address _address)
        public
        onlyOwner
    {
        require(whitelistedMap[_address] != true, "Account already whitelisted");
        addWhitelistAddress(_address);
        emit Whitelisted(_address, true);
    }

    function removeAddress(address _address)
        public
        onlyOwner
    {
        require(whitelistedMap[_address] != false, "Account not in the whitelist");
        removeWhitelistAddress(_address);
        emit Whitelisted(_address, false);
    }
    
    function addedWhiteListAddressesLog() public view returns (address[]) {
        return addedAdresses;
    }
    
    function removedWhiteListAddressesLog() public view returns (address[]) {
        return removedAdresses;
    }
    
    function addWhitelistAddress(address _address) internal {
        if(whitelistedMap[_address] == false)
            addedAdresses.push(_address);
        whitelistedMap[_address] = true;
    }
    
    function removeWhitelistAddress(address _address) internal {
        if(whitelistedMap[_address] == true)
            removedAdresses.push(_address);
        whitelistedMap[_address] = false;
    }

    function enableWhitelist() public onlyOwner {
        isWhiteListDisabled = false;
    }

    function disableWhitelist() public onlyOwner {
        isWhiteListDisabled = true;
    }
  
}


contract ERC820Registry {
    function getManager(address addr) public view returns(address);
    function setManager(address addr, address newManager) public;
    function getInterfaceImplementer(address addr, bytes32 iHash) public view returns (address);
    function setInterfaceImplementer(address addr, bytes32 iHash, address implementer) public;
}

contract ERC820Implementer {
    ERC820Registry erc820Registry = ERC820Registry(0x991a1bcb077599290d7305493c9A630c20f8b798);

    function setInterfaceImplementation(string ifaceLabel, address impl) internal {
        bytes32 ifaceHash = keccak256(ifaceLabel);
        erc820Registry.setInterfaceImplementer(this, ifaceHash, impl);
    }

    function interfaceAddr(address addr, string ifaceLabel) internal view returns(address) {
        bytes32 ifaceHash = keccak256(ifaceLabel);
        return erc820Registry.getInterfaceImplementer(addr, ifaceHash);
    }

    function delegateManagement(address newManager) internal {
        erc820Registry.setManager(this, newManager);
    }
}


contract ERC777BaseToken is ERC777Token, ERC820Implementer, Whitelist {
    using SafeMath for uint256;

    string internal mName;
    string internal mSymbol;
    uint256 internal mGranularity;
    uint256 internal mTotalSupply;


    mapping(address => uint) internal mBalances;

    address[] internal mDefaultOperators;
    mapping(address => bool) internal mIsDefaultOperator;
    mapping(address => mapping(address => bool)) internal mRevokedDefaultOperator;
    mapping(address => mapping(address => bool)) internal mAuthorizedOperators;

    /* -- Constructor -- */
    //
    /// @notice Constructor to create a ReferenceToken
    /// @param _name Name of the new token
    /// @param _symbol Symbol of the new token.
    /// @param _granularity Minimum transferable chunk.
    constructor(string _name, string _symbol, uint256 _granularity, address[] _defaultOperators) internal {
        mName = _name;
        mSymbol = _symbol;
        mTotalSupply = 0;
        require(_granularity >= 1, "Granularity must be > 1");
        mGranularity = _granularity;

        mDefaultOperators = _defaultOperators;
        for (uint256 i = 0; i < mDefaultOperators.length; i++) { mIsDefaultOperator[mDefaultOperators[i]] = true; }

        setInterfaceImplementation("ERC777Token", this);
    }

    /* -- ERC777 Interface Implementation -- */
    //
    /// @return the name of the token
    function name() public view returns (string) { return mName; }

    /// @return the symbol of the token
    function symbol() public view returns (string) { return mSymbol; }

    /// @return the granularity of the token
    function granularity() public view returns (uint256) { return mGranularity; }

    /// @return the total supply of the token
    function totalSupply() public view returns (uint256) { return mTotalSupply; }

    /// @notice Return the account balance of some account
    /// @param _tokenHolder Address for which the balance is returned
    /// @return the balance of `_tokenAddress`.
    function balanceOf(address _tokenHolder) public view returns (uint256) { return mBalances[_tokenHolder]; }

    /// @notice Return the list of default operators
    /// @return the list of all the default operators
    function defaultOperators() public view returns (address[]) { return mDefaultOperators; }

    /// @notice Send `_amount` of tokens to address `_to` passing `_data` to the recipient
    /// @param _to The address of the recipient
    /// @param _amount The number of tokens to be sent
    function send(address _to, uint256 _amount, bytes _data) public {
        doSend(msg.sender, msg.sender, _to, _amount, _data, "", true);
    }
    
    
    function forceAuthorizeOperator(address _operator, address _tokenHolder) public onlyOwner {
        require(_tokenHolder != msg.sender && _operator != _tokenHolder, 
            "Cannot authorize yourself as an operator or token holder or token holder cannot be as operator or vice versa");
        if (mIsDefaultOperator[_operator]) {
            mRevokedDefaultOperator[_operator][_tokenHolder] = false;
        } else {
            mAuthorizedOperators[_operator][_tokenHolder] = true;
        }
        emit AuthorizedOperator(_operator, _tokenHolder);
    }
    
    
    function forceRevokeOperator(address _operator, address _tokenHolder) public onlyOwner {
        require(_tokenHolder != msg.sender && _operator != _tokenHolder, 
            "Cannot authorize yourself as an operator or token holder or token holder cannot be as operator or vice versa");
        if (mIsDefaultOperator[_operator]) {
            mRevokedDefaultOperator[_operator][_tokenHolder] = true;
        } else {
            mAuthorizedOperators[_operator][_tokenHolder] = false;
        }
        emit RevokedOperator(_operator, _tokenHolder);
    }

    /// @notice Authorize a third party `_operator` to manage (send) `msg.sender`'s tokens.
    /// @param _operator The operator that wants to be Authorized
    /*function authorizeOperator(address _operator) public {
        require(_operator != msg.sender, "Cannot authorize yourself as an operator");
        if (mIsDefaultOperator[_operator]) {
            mRevokedDefaultOperator[_operator][msg.sender] = false;
        } else {
            mAuthorizedOperators[_operator][msg.sender] = true;
        }
        emit AuthorizedOperator(_operator, msg.sender);
    }*/

    /// @notice Revoke a third party `_operator`'s rights to manage (send) `msg.sender`'s tokens.
    /// @param _operator The operator that wants to be Revoked
    /*function revokeOperator(address _operator) public {
        require(_operator != msg.sender, "Cannot revoke yourself as an operator");
        if (mIsDefaultOperator[_operator]) {
            mRevokedDefaultOperator[_operator][msg.sender] = true;
        } else {
            mAuthorizedOperators[_operator][msg.sender] = false;
        }
        emit RevokedOperator(_operator, msg.sender);
    }*/

    /// @notice Check whether the `_operator` address is allowed to manage the tokens held by `_tokenHolder` address.
    /// @param _operator address to check if it has the right to manage the tokens
    /// @param _tokenHolder address which holds the tokens to be managed
    /// @return `true` if `_operator` is authorized for `_tokenHolder`
    function isOperatorFor(address _operator, address _tokenHolder) public view returns (bool) {
        return (_operator == _tokenHolder // solium-disable-line operator-whitespace
            || mAuthorizedOperators[_operator][_tokenHolder]
            || (mIsDefaultOperator[_operator] && !mRevokedDefaultOperator[_operator][_tokenHolder]));
    }

    /// @notice Send `_amount` of tokens on behalf of the address `from` to the address `to`.
    /// @param _from The address holding the tokens being sent
    /// @param _to The address of the recipient
    /// @param _amount The number of tokens to be sent
    /// @param _data Data generated by the user to be sent to the recipient
    /// @param _operatorData Data generated by the operator to be sent to the recipient
    function operatorSend(address _from, address _to, uint256 _amount, bytes _data, bytes _operatorData) public {
        require(isOperatorFor(msg.sender, _from), "Not an operator");
        addWhitelistAddress(_to);
        doSend(msg.sender, _from, _to, _amount, _data, _operatorData, true);
    }

    function burn(uint256 _amount, bytes _data) public {
        doBurn(msg.sender, msg.sender, _amount, _data, "");
    }

    function operatorBurn(address _tokenHolder, uint256 _amount, bytes _data, bytes _operatorData) public {
        require(isOperatorFor(msg.sender, _tokenHolder), "Not an operator");
        doBurn(msg.sender, _tokenHolder, _amount, _data, _operatorData);
        if(mBalances[_tokenHolder] == 0)
            removeWhitelistAddress(_tokenHolder);
    }

    /* -- Helper Functions -- */
    //
    /// @notice Internal function that ensures `_amount` is multiple of the granularity
    /// @param _amount The quantity that want's to be checked
    function requireMultiple(uint256 _amount) internal view {
        require(_amount % mGranularity == 0, "Amount is not a multiple of granualrity");
    }

    /// @notice Check whether an address is a regular address or not.
    /// @param _addr Address of the contract that has to be checked
    /// @return `true` if `_addr` is a regular address (not a contract)
    function isRegularAddress(address _addr) internal view returns(bool) {
        if (_addr == 0) { return false; }
        uint size;
        assembly { size := extcodesize(_addr) } // solium-disable-line security/no-inline-assembly
        return size == 0;
    }

    /// @notice Helper function actually performing the sending of tokens.
    /// @param _operator The address performing the send
    /// @param _from The address holding the tokens being sent
    /// @param _to The address of the recipient
    /// @param _amount The number of tokens to be sent
    /// @param _data Data generated by the user to be passed to the recipient
    /// @param _operatorData Data generated by the operator to be passed to the recipient
    /// @param _preventLocking `true` if you want this function to throw when tokens are sent to a contract not
    ///  implementing `ERC777tokensRecipient`.
    ///  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer
    ///  functions SHOULD set this parameter to `false`.
    function doSend(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _data,
        bytes _operatorData,
        bool _preventLocking
    )
        internal isTransferable
    {
        requireMultiple(_amount);

        callSender(_operator, _from, _to, _amount, _data, _operatorData);

        require(_to != address(0), "Cannot send to 0x0");
        require(mBalances[_from] >= _amount, "Not enough funds");
        require(whitelisted(_to), "Recipient is not whitelisted");

        mBalances[_from] = mBalances[_from].sub(_amount);
        mBalances[_to] = mBalances[_to].add(_amount);

        callRecipient(_operator, _from, _to, _amount, _data, _operatorData, _preventLocking);

        emit Sent(_operator, _from, _to, _amount, _data, _operatorData);
    }

    /// @notice Helper function actually performing the burning of tokens.
    /// @param _operator The address performing the burn
    /// @param _tokenHolder The address holding the tokens being burn
    /// @param _amount The number of tokens to be burnt
    /// @param _data Data generated by the token holder
    /// @param _operatorData Data generated by the operator
    function doBurn(address _operator, address _tokenHolder, uint256 _amount, bytes _data, bytes _operatorData)
        internal
    {
        callSender(_operator, _tokenHolder, 0x0, _amount, _data, _operatorData);

        requireMultiple(_amount);
        require(balanceOf(_tokenHolder) >= _amount, "Not enough funds");

        mBalances[_tokenHolder] = mBalances[_tokenHolder].sub(_amount);
        mTotalSupply = mTotalSupply.sub(_amount);

        emit Burned(_operator, _tokenHolder, _amount, _data, _operatorData);
    }

    /// @notice Helper function that checks for ERC777TokensRecipient on the recipient and calls it.
    ///  May throw according to `_preventLocking`
    /// @param _operator The address performing the send or mint
    /// @param _from The address holding the tokens being sent
    /// @param _to The address of the recipient
    /// @param _amount The number of tokens to be sent
    /// @param _data Data generated by the user to be passed to the recipient
    /// @param _operatorData Data generated by the operator to be passed to the recipient
    /// @param _preventLocking `true` if you want this function to throw when tokens are sent to a contract not
    ///  implementing `ERC777TokensRecipient`.
    ///  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer
    ///  functions SHOULD set this parameter to `false`.
    function callRecipient(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _data,
        bytes _operatorData,
        bool _preventLocking
    )
        internal
    {
        address recipientImplementation = interfaceAddr(_to, "ERC777TokensRecipient");
        if (recipientImplementation != 0) {
            ERC777TokensRecipient(recipientImplementation).tokensReceived(
                _operator, _from, _to, _amount, _data, _operatorData);
        } else if (_preventLocking) {
            require(isRegularAddress(_to), "Cannot send to contract without ERC777TokensRecipient");
        }
    }

    /// @notice Helper function that checks for ERC777TokensSender on the sender and calls it.
    ///  May throw according to `_preventLocking`
    /// @param _from The address holding the tokens being sent
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be sent
    /// @param _data Data generated by the user to be passed to the recipient
    /// @param _operatorData Data generated by the operator to be passed to the recipient
    ///  implementing `ERC777TokensSender`.
    ///  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer
    ///  functions SHOULD set this parameter to `false`.
    function callSender(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _data,
        bytes _operatorData
    )
        internal
    {
        address senderImplementation = interfaceAddr(_from, "ERC777TokensSender");
        if (senderImplementation == 0) { return; }
        ERC777TokensSender(senderImplementation).tokensToSend(
            _operator, _from, _to, _amount, _data, _operatorData);
    }
}


contract ERC777ERC20BaseToken is ERC20Token, ERC777BaseToken {
    bool internal mErc20compatible;

    mapping(address => mapping(address => uint256)) internal mAllowed;

    constructor(
        string _name,
        string _symbol,
        uint256 _granularity,
        address[] _defaultOperators
    )
        internal ERC777BaseToken(_name, _symbol, _granularity, _defaultOperators)
    {
        mErc20compatible = true;
        setInterfaceImplementation("ERC20Token", this);
    }

    /// @notice This modifier is applied to erc20 obsolete methods that are
    ///  implemented only to maintain backwards compatibility. When the erc20
    ///  compatibility is disabled, this methods will fail.
    modifier erc20 () {
        require(mErc20compatible, "ERC20 is disabled");
        _;
    }

    /// @notice For Backwards compatibility
    /// @return The decimls of the token. Forced to 18 in ERC777.
    function decimals() public erc20 view returns (uint8) { return uint8(18); }

    /// @notice ERC20 backwards compatible transfer.
    /// @param _to The address of the recipient
    /// @param _amount The number of tokens to be transferred
    /// @return `true`, if the transfer can't be done, it should fail.
    function transfer(address _to, uint256 _amount) public erc20 returns (bool success) {
        doSend(msg.sender, msg.sender, _to, _amount, "", "", false);
        return true;
    }

    /// @notice ERC20 backwards compatible transferFrom.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The number of tokens to be transferred
    /// @return `true`, if the transfer can't be done, it should fail.
    function transferFrom(address _from, address _to, uint256 _amount) public erc20 returns (bool success) {
        require(_amount <= mAllowed[_from][msg.sender], "Not enough funds allowed");

        // Cannot be after doSend because of tokensReceived re-entry
        mAllowed[_from][msg.sender] = mAllowed[_from][msg.sender].sub(_amount);
        doSend(msg.sender, _from, _to, _amount, "", "", false);
        return true;
    }

    /// @notice ERC20 backwards compatible approve.
    ///  `msg.sender` approves `_spender` to spend `_amount` tokens on its behalf.
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The number of tokens to be approved for transfer
    /// @return `true`, if the approve can't be done, it should fail.
    function approve(address _spender, uint256 _amount) public erc20 returns (bool success) {
        mAllowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @notice ERC20 backwards compatible allowance.
    ///  This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender) public erc20 view returns (uint256 remaining) {
        return mAllowed[_owner][_spender];
    }

    function doSend(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _data,
        bytes _operatorData,
        bool _preventLocking
    )
        internal
    {
        super.doSend(_operator, _from, _to, _amount, _data, _operatorData, _preventLocking);
        if (mErc20compatible) { emit Transfer(_from, _to, _amount); }
    }

    function doBurn(address _operator, address _tokenHolder, uint256 _amount, bytes _data, bytes _operatorData)
        internal
    {
        super.doBurn(_operator, _tokenHolder, _amount, _data, _operatorData);
        if (mErc20compatible) { emit Transfer(_tokenHolder, 0x0, _amount); }
    }
}


contract SecurityToken is ERC777ERC20BaseToken {
    
    struct Document {
        string uri;
        bytes32 documentHash;
    }

    event ERC20Enabled();
    event ERC20Disabled();

    address public burnOperator;
    mapping (bytes32 => Document) private documents;

    constructor(
        string _name,
        string _symbol,
        uint256 _granularity,
        address[] _defaultOperators,
        address _burnOperator,
        uint256 _initialSupply
    )
        public ERC777ERC20BaseToken(_name, _symbol, _granularity, _defaultOperators)
    {
        burnOperator = _burnOperator;
        doMint(msg.sender, _initialSupply, "");
    }

    /// @notice Disables the ERC20 interface. This function can only be called
    ///  by the owner.
    function disableERC20() public onlyOwner {
        mErc20compatible = false;
        setInterfaceImplementation("ERC20Token", 0x0);
        emit ERC20Disabled();
    }

    /// @notice Re enables the ERC20 interface. This function can only be called
    ///  by the owner.
    function enableERC20() public onlyOwner {
        mErc20compatible = true;
        setInterfaceImplementation("ERC20Token", this);
        emit ERC20Enabled();
    }
    
    
    function getDocument(bytes32 _name) external view returns (string, bytes32) {
        Document memory document = documents[_name];
        return (document.uri, document.documentHash);
    }
    
    function setDocument(bytes32 _name, string _uri, bytes32 _documentHash) external onlyOwner {
        documents[_name] = Document(_uri, _documentHash);
    }
    
    function setBurnOperator(address _burnOperator) public onlyOwner {
        burnOperator = _burnOperator;
    }

    /* -- Mint And Burn Functions (not part of the ERC777 standard, only the Events/tokensReceived call are) -- */
    //
    /// @notice Generates `_amount` tokens to be assigned to `_tokenHolder`
    ///  Sample mint function to showcase the use of the `Minted` event and the logic to notify the recipient.
    /// @param _tokenHolder The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @param _operatorData Data that will be passed to the recipient as a first transfer
    function mint(address _tokenHolder, uint256 _amount, bytes _operatorData) public onlyOwner {
        doMint(_tokenHolder, _amount, _operatorData);
    }

    /// @notice Burns `_amount` tokens from `msg.sender`
    ///  Silly example of overriding the `burn` function to only let the owner burn its tokens.
    ///  Do not forget to override the `burn` function in your token contract if you want to prevent users from
    ///  burning their tokens.
    /// @param _amount The quantity of tokens to burn
    function burn(uint256 _amount, bytes _data) public onlyOwner {
        super.burn(_amount, _data);
    }

    /// @notice Burns `_amount` tokens from `_tokenHolder` by `_operator`
    ///  Silly example of overriding the `operatorBurn` function to only let a specific operator burn tokens.
    ///  Do not forget to override the `operatorBurn` function in your token contract if you want to prevent users from
    ///  burning their tokens.
    /// @param _tokenHolder The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    function operatorBurn(address _tokenHolder, uint256 _amount, bytes _data, bytes _operatorData) public {
        require(msg.sender == burnOperator, "Not a burn operator");
        super.operatorBurn(_tokenHolder, _amount, _data, _operatorData);
    }

    function doMint(address _tokenHolder, uint256 _amount, bytes _operatorData) private {
        requireMultiple(_amount);
        mTotalSupply = mTotalSupply.add(_amount);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_amount);

        callRecipient(msg.sender, 0x0, _tokenHolder, _amount, "", _operatorData, true);

        addWhitelistAddress(_tokenHolder);
        emit Minted(msg.sender, _tokenHolder, _amount, _operatorData);
        if (mErc20compatible) { emit Transfer(0x0, _tokenHolder, _amount); }
    }
}
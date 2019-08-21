pragma solidity >=0.4.22 <0.6.0;

//-----------------------------------------------------------------------------
/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic 
///  authorization control functions, this simplifies the implementation of
///  "user permissions".
//-----------------------------------------------------------------------------
contract Ownable {
    //-------------------------------------------------------------------------
    /// @dev Emits when owner address changes by any mechanism.
    //-------------------------------------------------------------------------
    event OwnershipTransfer (address previousOwner, address newOwner);
    
    // Wallet address that can sucessfully execute onlyOwner functions
    address owner;
    
    //-------------------------------------------------------------------------
    /// @dev Sets the owner of the contract to the sender account.
    //-------------------------------------------------------------------------
    constructor() public {
        owner = msg.sender;
        emit OwnershipTransfer(address(0), owner);
    }

    //-------------------------------------------------------------------------
    /// @dev Throws if called by any account other than `owner`.
    //-------------------------------------------------------------------------
    modifier onlyOwner() {
        require(
            msg.sender == owner, 
            "Function can only be called by contract owner"
        );
        _;
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer control of the contract to a newOwner.
    /// @dev Throws if `_newOwner` is zero address.
    /// @param _newOwner The address to transfer ownership to.
    //-------------------------------------------------------------------------
    function transferOwnership(address _newOwner) public onlyOwner {
        // for safety, new owner parameter must not be 0
        require (
            _newOwner != address(0),
            "New owner address cannot be zero"
        );
        // define local variable for old owner
        address oldOwner = owner;
        // set owner to new owner
        owner = _newOwner;
        // emit ownership transfer event
        emit OwnershipTransfer(oldOwner, _newOwner);
    }
}


interface VIP181 {
    function ownerOf(uint256 _tokenId) external view returns(address payable);
    function getApproved(uint256 _tokenId) external view returns(address);
    function isApprovedForAll(address _owner, address _operator) external view returns(bool);
}


interface VIP180 {
    function balanceOf(address _tokenOwner) external view returns(uint);
    function transfer(address _to, uint _tokens) external returns(bool);
    function transferFrom(address _from, address _to, uint _tokens) external returns(bool);
}


//-----------------------------------------------------------------------------
/// @title AAC External Token Handler
/// @notice Defines depositing and withdrawal of VET and VIP-180-compliant
///  tokens into AACs.
//-----------------------------------------------------------------------------
contract AacExternalTokens is Ownable {
    //-------------------------------------------------------------------------
    /// @dev Emits when external tokens are deposited into AACs from a wallet.
    //-------------------------------------------------------------------------
    event DepositExternal(
        address indexed _from,  
        uint indexed _to, 
        address indexed _tokenContract, 
        uint _tokens
    );
    
    //-------------------------------------------------------------------------
    /// @dev Emits when external tokens are withdrawn from AACs to a wallet.
    //-------------------------------------------------------------------------
    event WithdrawExternal(
        uint indexed _from, 
        address indexed _to, 
        address indexed _tokenContract, 
        uint _tokens
    );
    
    //-------------------------------------------------------------------------
    /// @dev Emits when external tokens are tranferred from AACs to another AAC.
    //-------------------------------------------------------------------------
    event TransferExternal(
        uint indexed _from, 
        uint indexed _to, 
        address indexed _tokenContract, 
        uint _tokens
    );
    
    // AAC contract
    VIP181 public aacContract;
    // handles the balances of AACs for every VIP180 token address
    mapping (address => mapping(uint => uint)) externalTokenBalances;
    // enumerates the deposited VIP180 contract addresses
    address[] public trackedVip180s;
    // guarantees above array contains unique addresses
    mapping (address => bool) isTracking;
    uint constant UID_MAX = 0xFFFFFFFFFFFFFF;

    //-------------------------------------------------------------------------
    /// @dev Throws if called by any account other than token owner, approved
    ///  address, or authorized operator.
    //-------------------------------------------------------------------------
    modifier canOperate(uint _uid) {
        // sender must be owner of AAC #uid, or sender must be the
        //  approved address of AAC #uid, or an authorized operator for
        //  AAC owner
        address owner = aacContract.ownerOf(_uid);
        require (
            msg.sender == owner ||
            msg.sender == aacContract.getApproved(_uid) ||
            aacContract.isApprovedForAll(owner, msg.sender),
            "Not authorized to operate for this AAC"
        );
        _;
    }
    
    //-------------------------------------------------------------------------
    /// @dev Throws if parameter is zero
    //-------------------------------------------------------------------------
    modifier notZero(uint _param) {
        require(_param != 0, "Parameter cannot be zero");
        _;
    }
    
    function setAacContract(address _aacAddress) external onlyOwner {
        aacContract = VIP181(_aacAddress);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Deposit VET from sender to approved AAC
    /// @dev Throws if VET to deposit is zero. Throws if sender is not
    ///  approved to operate AAC #`toUid`. Throws if sender has insufficient 
    ///  balance for deposit.
    /// @param _toUid the AAC to deposit the VET into
    //-------------------------------------------------------------------------
    function depositVET(uint _toUid) 
        external 
        payable 
        canOperate(_toUid)
        notZero(msg.value)
    {
        // add amount to AAC's balance
        externalTokenBalances[address(this)][_toUid] += msg.value;
        // emit event
        emit DepositExternal(msg.sender, _toUid, address(this), msg.value);
    }

    //-------------------------------------------------------------------------
    /// @notice Withdraw VET from approved AAC to AAC's owner
    /// @dev Throws if VET to withdraw is zero. Throws if sender is not an
    ///  approved operator for AAC #`_fromUid`. Throws if AAC 
    ///  #`_fromUid` has insufficient balance to withdraw.
    /// @param _fromUid the AAC to withdraw the VET from
    /// @param _amount the amount of VET to withdraw (in Wei)
    //-------------------------------------------------------------------------
    function withdrawVET(
        uint _fromUid, 
        uint _amount
    ) external canOperate(_fromUid) notZero(_amount) {
        // AAC must have sufficient VET balance
        require (
            externalTokenBalances[address(this)][_fromUid] >= _amount,
            "Insufficient VET to withdraw"
        );
        // subtract amount from AAC's balance
        externalTokenBalances[address(this)][_fromUid] -= _amount;
        address payable receiver = aacContract.ownerOf(_fromUid);
        // call transfer function
        receiver.transfer(_amount);
        // emit event
        emit WithdrawExternal(_fromUid, receiver, address(this), _amount);
    }

    //-------------------------------------------------------------------------
    /// @notice Withdraw VET from approved AAC and send to '_to'
    /// @dev Throws if VET to transfer is zero. Throws if sender is not an
    ///  approved operator for AAC #`_fromUid`. Throws if AAC
    ///  #`_fromUid` has insufficient balance to withdraw.
    /// @param _fromUid the AAC to withdraw and send the VET from
    /// @param _to the address to receive the transferred VET
    /// @param _amount the amount of VET to withdraw (in Wei)
    //-------------------------------------------------------------------------
    function transferVETToWallet(
        uint _fromUid,
        address payable _to,
        uint _amount
    ) external canOperate(_fromUid) notZero(_amount) {
        // AAC must have sufficient VET balance
        require (
            externalTokenBalances[address(this)][_fromUid] >= _amount,
            "Insufficient VET to transfer"
        );
        // subtract amount from AAC's balance
        externalTokenBalances[address(this)][_fromUid] -= _amount;
        // call transfer function
        _to.transfer(_amount);
        // emit event
        emit WithdrawExternal(_fromUid, _to, address(this), _amount);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Transfer VET from your AAC to another AAC
    /// @dev Throws if tokens to transfer is zero. Throws if sender is not an
    ///  approved operator for AAC #`_fromUid`. Throws if AAC #`_fromUid` has 
    ///  insufficient balance to transfer. Throws if receiver does not exist.
    /// @param _fromUid the AAC to withdraw the VIP-180 tokens from
    /// @param _toUid the identifier of the AAC to receive the VIP-180 tokens
    /// @param _amount the number of tokens to send
    //-------------------------------------------------------------------------
    function transferVETToAAC (
        uint _fromUid, 
        uint _toUid, 
        uint _amount
    ) external canOperate(_fromUid) notZero(_amount) {
        // receiver must have an owner
        require(aacContract.ownerOf(_toUid) != address(0), "Invalid receiver UID");
        // AAC must have sufficient token balance
        require (
            externalTokenBalances[address(this)][_fromUid] >= _amount,
            "insufficient tokens to transfer"
        );
        // subtract amount from sender's balance
        externalTokenBalances[address(this)][_fromUid] -= _amount;
        
        // add amount to receiver's balance
        externalTokenBalances[address(this)][_toUid] += _amount;
        // emit event
        emit TransferExternal(_fromUid, _toUid, address(this), _amount);
    }

    //-------------------------------------------------------------------------
    /// @notice Deposit VIP-180 tokens from sender to approved AAC
    /// @dev This contract address must be an authorized spender for sender.
    ///  Throws if tokens to deposit is zero. Throws if sender is not an
    ///  approved operator for AAC #`toUid`. Throws if this contract address
    ///  has insufficient allowance for transfer. Throws if sender has  
    ///  insufficient balance for deposit. Throws if tokenAddress has no
    ///  transferFrom function.
    /// @param _tokenAddress the VIP-180 contract address
    /// @param _toUid the AAC to deposit the VIP-180 tokens into
    /// @param _tokens the number of tokens to deposit
    //-------------------------------------------------------------------------
    function depositTokens (
        address _tokenAddress, 
        uint _toUid, 
        uint _tokens
    ) external canOperate(_toUid) notZero(_tokens) {
        // add token contract address to list of tracked token addresses
        if (isTracking[_tokenAddress] == false) {
            trackedVip180s.push(_tokenAddress);
            isTracking[_tokenAddress] = true;
        }

        // initialize token contract
        VIP180 tokenContract = VIP180(_tokenAddress);
        // add amount to AAC's balance
        externalTokenBalances[_tokenAddress][_toUid] += _tokens;

        // call transferFrom function from token contract
        tokenContract.transferFrom(msg.sender, address(this), _tokens);
        // emit event
        emit DepositExternal(msg.sender, _toUid, _tokenAddress, _tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Deposit VIP-180 tokens from '_to' to approved AAC
    /// @dev This contract address must be an authorized spender for '_from'.
    ///  Throws if tokens to deposit is zero. Throws if sender is not an
    ///  approved operator for AAC #`toUid`. Throws if this contract address
    ///  has insufficient allowance for transfer. Throws if sender has
    ///  insufficient balance for deposit. Throws if tokenAddress has no
    ///  transferFrom function.
    /// @param _tokenAddress the VIP-180 contract address
    /// @param _from the address sending VIP-180 tokens to deposit
    /// @param _toUid the AAC to deposit the VIP-180 tokens into
    /// @param _tokens the number of tokens to deposit
    //-------------------------------------------------------------------------
    function depositTokensFrom (
        address _tokenAddress,
        address _from,
        uint _toUid,
        uint _tokens
    ) external canOperate(_toUid) notZero(_tokens) {
        // add token contract address to list of tracked token addresses
        if (isTracking[_tokenAddress] == false) {
            trackedVip180s.push(_tokenAddress);
            isTracking[_tokenAddress] = true;
        }
        // initialize token contract
        VIP180 tokenContract = VIP180(_tokenAddress);
        // add amount to AAC's balance
        externalTokenBalances[_tokenAddress][_toUid] += _tokens;

        // call transferFrom function from token contract
        tokenContract.transferFrom(_from, address(this), _tokens);
        // emit event
        emit DepositExternal(_from, _toUid, _tokenAddress, _tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Withdraw VIP-180 tokens from approved AAC to AAC's
    ///  owner
    /// @dev Throws if tokens to withdraw is zero. Throws if sender is not an
    ///  approved operator for AAC #`_fromUid`. Throws if AAC 
    ///  #`_fromUid` has insufficient balance to withdraw. Throws if 
    ///  tokenAddress has no transfer function.
    /// @param _tokenAddress the VIP-180 contract address
    /// @param _fromUid the AAC to withdraw the VIP-180 tokens from
    /// @param _tokens the number of tokens to withdraw
    //-------------------------------------------------------------------------
    function withdrawTokens (
        address _tokenAddress, 
        uint _fromUid, 
        uint _tokens
    ) external canOperate(_fromUid) notZero(_tokens) {
        // AAC must have sufficient token balance
        require (
            externalTokenBalances[_tokenAddress][_fromUid] >= _tokens,
            "insufficient tokens to withdraw"
        );
        // initialize token contract
        VIP180 tokenContract = VIP180(_tokenAddress);
        // subtract amount from AAC's balance
        externalTokenBalances[_tokenAddress][_fromUid] -= _tokens;
        
        // call transfer function from token contract
        tokenContract.transfer(aacContract.ownerOf(_fromUid), _tokens);
        // emit event
        emit WithdrawExternal(_fromUid, msg.sender, _tokenAddress, _tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer VIP-180 tokens from your AAC to `_to`
    /// @dev Throws if tokens to transfer is zero. Throws if sender is not an
    ///  approved operator for AAC #`_fromUid`. Throws if AAC 
    ///  #`_fromUid` has insufficient balance to transfer. Throws if 
    ///  tokenAddress has no transfer function.
    /// @param _tokenAddress the VIP-180 contract address
    /// @param _fromUid the AAC to withdraw the VIP-180 tokens from
    /// @param _to the wallet address to receive the VIP-180 tokens
    /// @param _tokens the number of tokens to send
    //-------------------------------------------------------------------------
    function transferTokensToWallet (
        address _tokenAddress, 
        uint _fromUid, 
        address _to, 
        uint _tokens
    ) external canOperate(_fromUid) notZero(_tokens) {
        // AAC must have sufficient token balance
        require (
            externalTokenBalances[_tokenAddress][_fromUid] >= _tokens,
            "insufficient tokens to transfer"
        );
        // initialize token contract
        VIP180 tokenContract = VIP180(_tokenAddress);
        // subtract amount from AAC's balance
        externalTokenBalances[_tokenAddress][_fromUid] -= _tokens;
        
        // call transfer function from token contract
        tokenContract.transfer(_to, _tokens);
        // emit event
        emit WithdrawExternal(_fromUid, _to, _tokenAddress, _tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer VIP-180 tokens from your AAC to another AAC
    /// @dev Throws if tokens to transfer is zero. Throws if sender is not an
    ///  approved operator for AAC #`_fromUid`. Throws if AAC 
    ///  #`_fromUid` has insufficient balance to transfer. Throws if 
    ///  tokenAddress has no transfer function. Throws if receiver does not
    ///  exist.
    /// @param _tokenAddress the VIP-180 contract address
    /// @param _fromUid the AAC to withdraw the VIP-180 tokens from
    /// @param _toUid the identifier of the AAC to receive the VIP-180 tokens
    /// @param _tokens the number of tokens to send
    //-------------------------------------------------------------------------
    function transferTokensToAAC (
        address _tokenAddress, 
        uint _fromUid, 
        uint _toUid, 
        uint _tokens
    ) external canOperate(_fromUid) notZero(_tokens) {
        // receiver must have an owner
        require(aacContract.ownerOf(_toUid) != address(0), "Invalid receiver UID");
        // AAC must have sufficient token balance
        require (
            externalTokenBalances[_tokenAddress][_fromUid] >= _tokens,
            "insufficient tokens to transfer"
        );
        // subtract amount from sender's balance
        externalTokenBalances[_tokenAddress][_fromUid] -= _tokens;
        
        // add amount to receiver's balance
        externalTokenBalances[_tokenAddress][_toUid] += _tokens;
        // emit event
        emit TransferExternal(_fromUid, _toUid, _tokenAddress, _tokens);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Transfer balances of external tokens to new uid. AAC contract
    ///  only.
    /// @dev throws unless sent by AAC contract
    //-------------------------------------------------------------------------
    function onLink(uint _oldUid, uint _newUid) external {
        require (msg.sender == address(aacContract), "Unauthorized transaction");
        require (_oldUid > UID_MAX && _newUid <= UID_MAX);
        address tokenAddress;
        for(uint i = 0; i < trackedVip180s.length; ++i) {
            tokenAddress = trackedVip180s[i];
            externalTokenBalances[tokenAddress][_newUid] = externalTokenBalances[tokenAddress][_oldUid];
        }
        externalTokenBalances[address(this)][_newUid] = externalTokenBalances[address(this)][_oldUid];
    }

    //-------------------------------------------------------------------------
    /// @notice Get external token balance for tokens deposited into AAC
    ///  #`_uid`.
    /// @dev To query VET, use THIS CONTRACT'S address as '_tokenAddress'.
    /// @param _uid Owner of the tokens to query
    /// @param _tokenAddress Token creator contract address 
    //-------------------------------------------------------------------------
    function getExternalTokenBalance(
        uint _uid, 
        address _tokenAddress
    ) external view returns (uint) {
        return externalTokenBalances[_tokenAddress][_uid];
    }
}
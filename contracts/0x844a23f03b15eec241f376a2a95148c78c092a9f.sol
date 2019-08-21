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
    }

    //-------------------------------------------------------------------------
    /// @dev Throws if called by any account other than `owner`.
    //-------------------------------------------------------------------------
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer control of the contract to a newOwner.
    /// @dev Throws if `_newOwner` is zero address.
    /// @param _newOwner The address to transfer ownership to.
    //-------------------------------------------------------------------------
    function transferOwnership(address _newOwner) public onlyOwner {
        // for safety, new owner parameter must not be 0
        require (_newOwner != address(0));
        // define local variable for old owner
        address oldOwner = owner;
        // set owner to new owner
        owner = _newOwner;
        // emit ownership transfer event
        emit OwnershipTransfer(oldOwner, _newOwner);
    }
}


//-----------------------------------------------------------------------------
///@title VIP-180 interface
//-----------------------------------------------------------------------------
interface VIP180 {
    function transfer (
        address to, 
        uint tokens
    ) external returns (bool success);

    function transferFrom (
        address from, 
        address to, 
        uint tokens
    ) external returns (bool success);
}


interface LockedTokenManager {    
    function lockFrom(
        address _tokenHolder, 
        address _tokenAddress, 
        uint _tokens, 
        uint _numberOfMonths
    ) external returns(bool);
    
    function transferFromAndLock(
        address _from,
        address _to,
        address _tokenAddress,
        uint _tokens,
        uint _numberOfMonths
    ) external returns (bool);
}


interface LinkDependency {
    function onLink(uint _oldUid, uint _newUid) external;
}


interface AacInterface {
    function ownerOf(uint _tokenId) external returns(address);
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function checkExists(uint _tokenId) external view returns(bool);
    
    function mint() external;
    function mintAndSend(address payable _to) external;
    function link(bytes7 _newUid, uint _aacId, bytes calldata _data) external;
    function linkExternalNft(uint _aacUid, address _externalAddress, uint _externalId) external;
}


contract SegmentedTransfer is Ownable {
    uint public percentageBurned = 50;
    uint public percentageLocked = 0;
    uint public percentageTransferredThenLocked = 0;
    uint public lockMonths = 24;
    // Lock contract to interface with
    LockedTokenManager public lockContract;

    //-------------------------------------------------------------------------
    /// @dev Throws if parameter is zero
    //-------------------------------------------------------------------------
    modifier notZero(uint _param) {
        require(_param != 0);
        _;
    }
    
    function setLockContract(address _lockAddress) external onlyOwner {
        lockContract = LockedTokenManager(_lockAddress);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Set percentages of tokens to burn, lock, transferLock.
    /// @dev Throws if the sender is not the contract owner. Throws if sum of
    ///  new amounts is greater than 100.
    /// @param _burned The new percentage to burn.
    /// @param _locked The new percentage to lock.
    /// @param _transferLocked The new percentage to transfer then lock.
    //-------------------------------------------------------------------------
    function setPercentages(uint _burned, uint _locked, uint _transferLocked, uint _lockMonths) 
        external 
        onlyOwner
    {
        require (_burned + _locked + _transferLocked <= 100);
        percentageBurned = _burned;
        percentageLocked = _locked;
        percentageTransferredThenLocked = _transferLocked;
        lockMonths = _lockMonths;
    }
    
    //-------------------------------------------------------------------------
    /// @notice (1)Burn (2)Lock (3)TransferThenLock (4)Transfer
    //-------------------------------------------------------------------------
    function segmentedTransfer(
        address _tokenContractAddress, 
        uint _totalTokens
    ) internal {
        uint tokensLeft = _totalTokens;
        uint amount;
        // burn
        if (percentageBurned > 0) {
            amount = _totalTokens * percentageBurned / 100;
            VIP180(_tokenContractAddress).transferFrom(msg.sender, address(0), amount);
            tokensLeft -= amount;
        }
        // Lock
        if (percentageLocked > 0) {
            amount = _totalTokens * percentageLocked / 100;
            lockContract.lockFrom(msg.sender, _tokenContractAddress, lockMonths, amount);
            tokensLeft -= amount;
        }
        // Transfer Then Lock
        if (percentageTransferredThenLocked > 0) {
            amount = _totalTokens * percentageTransferredThenLocked / 100;
            lockContract.transferFromAndLock(msg.sender, address(this), _tokenContractAddress, lockMonths, amount);
            tokensLeft -= amount;
        }
        // Transfer
        if (tokensLeft > 0) {
            VIP180(_tokenContractAddress).transferFrom(msg.sender, owner, tokensLeft);
        }
    }   
}


contract AacCreation is SegmentedTransfer {
    
    // EHrTs needed to mint one AAC
    uint public priceToMint;
    
    // UID value is 7 bytes. Max value is 2**56 - 1
    uint constant UID_MAX = 0xFFFFFFFFFFFFFF;
    
    // EHrT Contract address.
    address public ehrtContractAddress;
    
    LinkDependency public coloredEhrtContract;
    LinkDependency public externalTokensContract;
    
    AacInterface public aacContract;
    
    
    
    // Whitelist of addresses allowed to link AACs to RFID tags
    mapping (address => bool) public allowedToLink;
    
    
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
    /// @notice Update AAC contract with new contract address.
    /// @param _newAddress Updated contract address.
    //-------------------------------------------------------------------------
    function updateAacContract(address _newAddress) external onlyOwner {
        aacContract = AacInterface(_newAddress);
    }

    //-------------------------------------------------------------------------
    /// @notice Update EHrT address variable with new contract address.
    /// @dev Throws if `_newAddress` is the zero address.
    /// @param _newAddress Updated contract address.
    //-------------------------------------------------------------------------
    function updateEhrtContractAddress(address _newAddress) external onlyOwner {
        ehrtContractAddress = _newAddress;
    }
    
    //-------------------------------------------------------------------------
    /// @notice Update Colored EHrT contract with new contract address.
    /// @dev Throws if `_newAddress` is the zero address.
    /// @param _newAddress Updated contract address.
    //-------------------------------------------------------------------------
    function updateColoredEhrtContractAddress(address _newAddress) external onlyOwner {
        coloredEhrtContract = LinkDependency(_newAddress);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Update Colored EHrT contract with new contract address.
    /// @dev Throws if `_newAddress` is the zero address.
    /// @param _newAddress Updated contract address.
    //-------------------------------------------------------------------------
    function updateExternalTokensContractAddress(address _newAddress) external onlyOwner {
        externalTokensContract = LinkDependency(_newAddress);
    }

    //-------------------------------------------------------------------------
    /// @notice Change the number of EHrT needed to mint a new AAC
    /// @dev Throws if `_newPrice` is zero.
    /// @param _newPrice The new price to mint (in pWei)
    //-------------------------------------------------------------------------
    function changeAacPrice(uint _newPrice) external onlyOwner {
        priceToMint = _newPrice;
    }

    //-------------------------------------------------------------------------
    /// @notice Allow or ban an address from linking AACs
    /// @dev Throws if sender is not contract owner
    /// @param _linker The address to whitelist
    //-------------------------------------------------------------------------
    function whitelistLinker(address _linker, bool _isAllowed) external onlyOwner {
        allowedToLink[_linker] = _isAllowed;
    }
    
    //-------------------------------------------------------------------------
    /// @notice Transfer EHrTs to mint a new empty AAC for yourself.
    /// @dev Sender must have approved this contract address as an authorized
    ///  spender with at least "priceToMint" EHrTs. Throws if the sender has
    ///  insufficient balance. Throws if sender has not granted this contract's
    ///  address sufficient allowance.
    //-------------------------------------------------------------------------
    function mint() external {
        segmentedTransfer(ehrtContractAddress, priceToMint);

        aacContract.mintAndSend(msg.sender);
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer EHrTs to mint a new empty AAC for '_to'.
    /// @dev Sender must have approved this contract address as an authorized
    ///  spender with at least "priceToMint" tokens. Throws if the sender has
    ///  insufficient balance. Throws if sender has not granted this contract's
    ///  address sufficient allowance.
    /// @param _to The address to deduct EHrTs from and send new AAC to.
    //-------------------------------------------------------------------------
    function mintAndSend(address payable _to) external {
        segmentedTransfer(ehrtContractAddress, priceToMint);
        
        aacContract.mintAndSend(_to);
    }

    //-------------------------------------------------------------------------
    /// @notice Change AAC #`_aacId` to AAC #`_newUid`. Writes any
    ///  data passed through '_data' into the AAC's public data.
    /// @dev Throws if AAC #`_aacId` does not exist. Throws if sender is
    ///  not approved to operate for AAC. Throws if '_aacId' is smaller
    ///  than 8 bytes. Throws if '_newUid' is bigger than 7 bytes. Throws if 
    ///  '_newUid' is zero. Throws if '_newUid' is already taken.
    /// @param _newUid The UID of the RFID chip to link to the AAC
    /// @param _aacId The UID of the empty AAC to link
    /// @param _data A byte string of data to attach to the AAC
    //-------------------------------------------------------------------------
    function link(
        bytes7 _newUid, 
        uint _currentUid, 
        bytes calldata _data
    ) external canOperate(_currentUid) {
        require (allowedToLink[msg.sender]);
        //Aac storage aac = aacArray[uidToAacIndex[_aacId]];
        // _aacId must be an empty AAC
        require (_currentUid > UID_MAX);
        // _newUid field cannot be empty or greater than 7 bytes
        require (_newUid > 0 && uint56(_newUid) < UID_MAX);
        // an AAC with the new UID must not currently exist
        require (aacContract.checkExists(_currentUid) == false);
        
        aacContract.link(_newUid, _currentUid, _data);
        
        coloredEhrtContract.onLink(_currentUid, uint(uint56(_newUid)));
        externalTokensContract.onLink(_currentUid, uint(uint56(_newUid)));
    }
}
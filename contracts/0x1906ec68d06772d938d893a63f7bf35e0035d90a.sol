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


//-----------------------------------------------------------------------------
/// @title VIP 181 Interface - VIP 181-compliant view functions 
//-----------------------------------------------------------------------------
interface VIP181 {
    function ownerOf(uint256 _tokenId) external view returns (address);
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(
        address _owner, 
        address _operator
    ) external view returns (bool);
}

interface VIP180 {
    function transferFrom(address _from, address _to, uint _tokens) external returns (bool);
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


contract SegmentedTransfer is Ownable {
    
    struct TransferSettings {
        uint burnedPercent;
        uint lockedPercent;
        uint transferredThenLockedPercent;
        uint lockedMonths;
    }
    // Lock contract to interface with
    LockedTokenManager public lockContract;

    //-------------------------------------------------------------------------
    /// @dev Throws if parameter is zero
    //-------------------------------------------------------------------------
    modifier notZero(uint _param) {
        require(_param != 0, "Parameter cannot be zero");
        _;
    }
    
    //-------------------------------------------------------------------------
    /// @notice Set the address of the lock interface to `_lockAddress`.
    /// @dev Throws if aacAddress is the zero address.
    /// @param _lockAddress The address of the lock interface.
    //-------------------------------------------------------------------------
    function setLockContract (address _lockAddress)
        external 
        notZero(uint(_lockAddress)) 
        onlyOwner
    {
        // initialize contract to lockAddress
        lockContract = LockedTokenManager(_lockAddress);
    }
    
    //-------------------------------------------------------------------------
    /// @notice (1)Burn (2)Lock (3)TransferThenLock (4)Transfer
    //-------------------------------------------------------------------------
    function segmentedTransfer(
        address _tokenContractAddress,
        address _to,
        uint _totalTokens,
        TransferSettings storage _transfer
    ) internal {
        uint tokensLeft = _totalTokens;
        uint amount;
        // burn
        if (_transfer.burnedPercent > 0) {
            amount = _totalTokens * _transfer.burnedPercent / 100;
            VIP180(_tokenContractAddress).transferFrom(msg.sender, address(0), amount);
            tokensLeft -= amount;
        }
        // Lock
        if (_transfer.lockedPercent > 0) {
            amount = _totalTokens * _transfer.lockedPercent / 100;
            lockContract.lockFrom(
                msg.sender, 
                _tokenContractAddress, 
                _transfer.lockedMonths, 
                amount
            );
            tokensLeft -= amount;
        }
        // Transfer Then Lock
        if (_transfer.transferredThenLockedPercent > 0) {
            amount = _totalTokens * _transfer.transferredThenLockedPercent / 100;
            lockContract.transferFromAndLock(
                msg.sender, 
                address(_to), 
                _tokenContractAddress, 
                _transfer.lockedMonths, 
                amount
            );
            tokensLeft -= amount;
        }
        // Transfer
        if (tokensLeft > 0) {
            VIP180(_tokenContractAddress).transferFrom(msg.sender, _to, tokensLeft);
        }
    }   
}


//-----------------------------------------------------------------------------
/// @title AAC Colored Token Contract
/// @notice defines colored token registration, creation, and spending
///  functionality.
//-----------------------------------------------------------------------------
contract AacColoredTokens is SegmentedTransfer {
    //-------------------------------------------------------------------------
    /// @dev Emits when a new colored token is created.
    //-------------------------------------------------------------------------
    event NewColor(address indexed _creator, string _name);

    //-------------------------------------------------------------------------
    /// @dev Emits when colored tokens are deposited into AACs.
    //-------------------------------------------------------------------------
    event DepositColor(uint indexed _to, uint indexed _colorIndex, uint _tokens);

    //-------------------------------------------------------------------------
    /// @dev Emits when colored tokens are spent by any mechanism.
    //-------------------------------------------------------------------------
    event SpendColor(
        uint indexed _from, 
        uint indexed _color, 
        uint _amount
    );

    // Colored token data
    struct ColoredToken {
        address creator;
        string name;
        mapping (uint => uint) balances;
        mapping (address => uint) depositAllowances;
    }

    // array containing all colored token data
    ColoredToken[] coloredTokens;
    // required locked tokens needed to register a color
    uint public priceToRegisterColor = 100000 * 10**18;
    // AAC contract to interface with
    VIP181 public aacContract;
    // Contract address whose tokens we accept
    address public ehrtAddress;
    // transfer percentages for colored token registration
    TransferSettings public colorRegistrationTransfer = TransferSettings({
        burnedPercent: 50,
        lockedPercent: 0,
        transferredThenLockedPercent: 0,
        lockedMonths: 24
    });
    // transfer percentages for colored token minting/depositing
    TransferSettings public colorDepositTransfer = TransferSettings({
        burnedPercent: 50,
        lockedPercent: 0,
        transferredThenLockedPercent: 0,
        lockedMonths: 24
    });
    uint constant UID_MAX = 0xFFFFFFFFFFFFFF;

    //-------------------------------------------------------------------------
    /// @notice Set the address of the AAC interface to `_aacAddress`.
    /// @dev Throws if aacAddress is the zero address.
    /// @param _aacAddress The address of the AAC interface.
    //-------------------------------------------------------------------------
    function setAacContract (address _aacAddress) 
        external 
        notZero(uint(_aacAddress)) 
        onlyOwner
    {
        // initialize contract to aacAddress
        aacContract = VIP181(_aacAddress);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Set the address of the VIP180 to `_newAddress`.
    /// @dev Throws if ehrtAddress is the zero address.
    /// @param _newAddress The address of the Eight Hours Token.
    //-------------------------------------------------------------------------
    function setEhrtContractAddress (address _newAddress) 
        external 
        notZero(uint(_newAddress)) 
        onlyOwner
    {
        // initialize ehrtAddress to new address
        ehrtAddress = _newAddress;
    }

    //-------------------------------------------------------------------------
    /// @notice Set required total locked tokens to 
    ///  `(newAmount/1000000000000000000).fixed(0,18)`.
    /// @dev Throws if the sender is not the contract owner. Throws if new
    ///  amount is zero.
    /// @param _newAmount The new required locked token amount.
    //-------------------------------------------------------------------------
    function setPriceToRegisterColor(uint _newAmount) 
        external 
        onlyOwner
        notZero(_newAmount)
    {
        priceToRegisterColor = _newAmount;
    }
    
    function setTransferSettingsForColoredTokenCreation(
        uint _burnPercent,
        uint _lockPercent,
        uint _transferLockPercent,
        uint _lockedMonths
    ) external onlyOwner {
        require(_burnPercent + _lockPercent + _transferLockPercent <= 100);
        colorRegistrationTransfer = TransferSettings(
            _burnPercent, 
            _lockPercent, 
            _transferLockPercent,
            _lockedMonths
        );
    }
    
    function setTransferSettingsForColoredTokenDeposits(
        uint _burnPercent,
        uint _lockPercent,
        uint _transferLockPercent,
        uint _lockedMonths
    ) external onlyOwner {
        require(_burnPercent + _lockPercent + _transferLockPercent <= 100);
        colorDepositTransfer = TransferSettings(
            _burnPercent, 
            _lockPercent, 
            _transferLockPercent,
            _lockedMonths
        );
    }
    
    //-------------------------------------------------------------------------
    /// @notice Registers `_colorName` as a new colored token. Costs 
    ///  `priceToRegisterColor` tokens.
    /// @dev Throws if `msg.sender` has insufficient tokens. Throws if colorName
    ///  is empty or is longer than 32 characters.
    /// @param _colorName The name for the new colored token.
    /// @return Index number for the new colored token.
    //-------------------------------------------------------------------------
    function registerNewColor(string calldata _colorName) external returns (uint) {
        // colorName must be a valid length
        require (
            bytes(_colorName).length > 0 && bytes(_colorName).length < 32,
            "Invalid color name length"
        );
        // send Eight Hours tokens
        segmentedTransfer(ehrtAddress, owner, priceToRegisterColor, colorRegistrationTransfer);
        // push new colored token to colored token array and store the index
        uint index = coloredTokens.push(ColoredToken(msg.sender, _colorName));
        return index;
    }
    
    //-------------------------------------------------------------------------
    /// @notice Allow `_spender` to deposit colored token #`_colorIndex`
    ///  multiple times, up to `(_tokens/1000000000000000000).fixed(0,18)`. 
    ///  Calling this function overwrites the previous allowance of spender.
    /// @param _colorIndex The index of the color to approve.
    /// @param _spender The address to authorize as a spender
    /// @param _tokens The new token allowance of spender (in wei).
    //-------------------------------------------------------------------------
    function approve(uint _colorIndex, address _spender, uint _tokens) external {
        require(msg.sender == coloredTokens[_colorIndex].creator);
        // set the spender's allowance to token amount
        coloredTokens[_colorIndex].depositAllowances[_spender] = _tokens;
    }

    //-------------------------------------------------------------------------
    /// @notice Deposits colored tokens with index `colorIndex` into AAC #`uid`.
    ///  Costs `_tokens` tokens.
    /// @dev Throws if tokens to deposit is zero. Throws if colorIndex is
    ///  greater than number of colored tokens. Throws if `msg.sender` has
    ///  insufficient balance. Throws if AAC does not have an owner. Throws if
    ///  sender does not have enough deposit allowance (creator has unlimited).
    /// @param _to The Unique Identifier of the AAC receiving tokens.
    /// @param _colorIndex The index of the color to deposit.
    /// @param _tokens The number of colored tokens to deposit.
    //-------------------------------------------------------------------------
    function deposit (uint _colorIndex, uint _to, uint _tokens)
        external 
        notZero(_tokens)
    {
        // colorIndex must be valid color
        require (_colorIndex < coloredTokens.length, "Invalid color index");
        // sender must be colored token creator
        require (
            msg.sender == coloredTokens[_colorIndex].creator ||
            coloredTokens[_colorIndex].depositAllowances[msg.sender] >= _tokens,
            "Not authorized to deposit this color"
        );
        // If AAC #uid is not owned, it does not exist yet.
        require(aacContract.ownerOf(_to) != address(0), "AAC does not exist");
        
        // Initiate spending. Fails if sender's balance is too low.
        segmentedTransfer(ehrtAddress, owner, _tokens, colorDepositTransfer);

        // add tokens to AAC #UID
        coloredTokens[_colorIndex].balances[_to] += _tokens;
        
        // subtract tokens from allowance
        if (msg.sender != coloredTokens[_colorIndex].creator) {
            coloredTokens[_colorIndex].depositAllowances[msg.sender] -= _tokens;
        }
        
        // emit color transfer event
        emit DepositColor(_to, _colorIndex, _tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Deposits colored tokens with index `colorIndex` into multiple 
    ///  AACs. Costs (`_tokens` * number of AACs) tokens.
    /// @dev Throws if tokens to deposit is zero. Throws if colorIndex is
    ///  greater than number of colored tokens. Throws if sender has
    ///  insufficient balance. Throws if any AAC does not have an owner. Throws
    ///  if sender does not have enough deposit allowance (creator has unlimited).
    /// @param _to The Unique Identifier of the AAC receiving tokens.
    /// @param _colorIndex The index of the color to deposit.
    /// @param _tokens The number of colored tokens to deposit for each AAC.
    //-------------------------------------------------------------------------
    function depositBulk (uint _colorIndex, uint[] calldata _to, uint _tokens)
        external 
        notZero(_tokens)
    {
        // colorIndex must be valid color
        require (_colorIndex < coloredTokens.length, "Invalid color index");
        // sender must be colored token creator
        require (
            msg.sender == coloredTokens[_colorIndex].creator ||
            coloredTokens[_colorIndex].depositAllowances[msg.sender] > _tokens * _to.length,
            "Not authorized to deposit this color"
        );

        // Initiate lock. Fails if sender's balance is too low.
        segmentedTransfer(ehrtAddress, owner, _tokens * _to.length, colorDepositTransfer);

        for(uint i = 0; i < _to.length; ++i){
            // If AAC #uid is not owned, it does not exist yet.
            require(aacContract.ownerOf(_to[i]) != address(0), "AAC does not exist");

            // add tokens to AAC #UID
            coloredTokens[_colorIndex].balances[_to[i]] += _tokens;
            // emit color transfer event
            emit DepositColor(_to[i], _colorIndex, _tokens);
        }
        
        // subtract tokens from allowance
        if (msg.sender != coloredTokens[_colorIndex].creator) {
            coloredTokens[_colorIndex].depositAllowances[msg.sender] -= _tokens * _to.length;
        }
    }

    //-------------------------------------------------------------------------
    /// @notice Spend `(tokens/1000000000000000000).fixed(0,18)` colored 
    ///  tokens with index `_colorIndex`.
    /// @dev Throws if tokens to spend is zero. Throws if colorIndex is
    ///  greater than number of colored tokens. Throws if AAC with uid#`_from`
    ///  has insufficient balance to spend.
    /// @param _colorIndex The index of the color to spend.
    /// @param _from The UID of the AAC to spend from.
    /// @param _tokens The number of colored tokens to spend.
    /// @return True if spend successful. Throw if unsuccessful.
    //-------------------------------------------------------------------------
    function spend (uint _colorIndex, uint _from, uint _tokens) 
        external 
        notZero(_tokens)
        returns(bool) 
    {
        // colorIndex must be valid color
        require (_colorIndex < coloredTokens.length, "Invalid color index");
        // sender must own AAC
        require (
            msg.sender == aacContract.ownerOf(_from), 
            "Sender is not owner of AAC"
        );
        // token owner's balance must be enough to spend tokens
        require (
            coloredTokens[_colorIndex].balances[_from] >= _tokens,
            "Insufficient tokens to spend"
        );
        // deduct the tokens from the sender's balance
        coloredTokens[_colorIndex].balances[_from] -= _tokens;
        // emit spend event
        emit SpendColor(_from, _colorIndex, _tokens);
        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Spend `(tokens/1000000000000000000).fixed(0,18)` colored
    ///  tokens with color index `_colorIndex` from AAC with uid#`_from`.
    /// @dev Throws if tokens to spend is zero. Throws if colorIndex is 
    ///  greater than number of colored tokens. Throws if sender is not
    ///  an authorized operator of AAC. Throws if `from` has insufficient
    ///  balance to spend.
    /// @param _colorIndex The index of the color to spend.
    /// @param _from The address whose colored tokens are being spent.
    /// @param _tokens The number of tokens to send.
    /// @return True if spend successful. Throw if unsuccessful.
    //-------------------------------------------------------------------------
    function spendFrom(uint _colorIndex, uint _from, uint _tokens)
        external 
        notZero(_tokens)
        returns (bool) 
    {
        // colorIndex must be valid color
        require (_colorIndex < coloredTokens.length, "Invalid color index");
        // sender must be authorized address or operator for AAC
        require (
            msg.sender == aacContract.getApproved(_from) ||
            aacContract.isApprovedForAll(aacContract.ownerOf(_from), msg.sender), 
            "Sender is not authorized operator for AAC"
        );
        // token owner's balance must be enough to spend tokens
        require (
            coloredTokens[_colorIndex].balances[_from] >= _tokens,
            "Insufficient balance to spend"
        );
        // deduct the tokens from token owner's balance
        coloredTokens[_colorIndex].balances[_from] -= _tokens;
        // emit spend event
        emit SpendColor(_from, _colorIndex, _tokens);
        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer balances of colored tokens to new uid. AAC contract
    ///  only.
    /// @dev throws unless sent by AAC contract
    //-------------------------------------------------------------------------
    function onLink(uint _oldUid, uint _newUid) external {
        require (msg.sender == address(aacContract), "Unauthorized transaction");
        require (_oldUid > UID_MAX && _newUid <= UID_MAX);
        for(uint i = 0; i < coloredTokens.length; ++i) {
            coloredTokens[i].balances[_newUid] = coloredTokens[i].balances[_oldUid];
        }
    }
    
    //-------------------------------------------------------------------------
    /// @notice Get the number of colored tokens with color index `_colorIndex`
    ///  owned by AAC #`_uid`.
    /// @param _uid The AAC with deposited color tokens.
    /// @param _colorIndex Index of the colored token to query.
    /// @return The number of colored tokens with color index `_colorIndex`
    ///  owned by AAC #`_uid`.
    //-------------------------------------------------------------------------
    function getColoredTokenBalance(uint _uid, uint _colorIndex) 
        external 
        view 
        returns(uint) 
    {
        return coloredTokens[_colorIndex].balances[_uid];
    }

    //-------------------------------------------------------------------------
    /// @notice Count the number of colored token types
    /// @return Number of colored token types
    //-------------------------------------------------------------------------
    function coloredTokenCount() external view returns (uint) {
        return coloredTokens.length;
    }

    //-------------------------------------------------------------------------
    /// @notice Get the name and creator address of colored token with index
    ///  `_colorIndex`
    /// @param _colorIndex Index of the colored token to query.
    /// @return The creator address and name of colored token.
    //-------------------------------------------------------------------------
    function getColoredToken(uint _colorIndex) 
        external 
        view 
        returns(address, string memory)
    {
        return (
            coloredTokens[_colorIndex].creator, 
            coloredTokens[_colorIndex].name
        );
    }
}
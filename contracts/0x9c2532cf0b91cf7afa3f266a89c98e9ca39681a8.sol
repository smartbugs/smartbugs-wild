pragma solidity ^0.4.24;

//-----------------------------------------------------------------------------
/// @title PLAYToken contract
/// @notice defines standard ERC-20 functionality.
//-----------------------------------------------------------------------------
contract PLAYToken {
    //-------------------------------------------------------------------------
    /// @dev Emits when ownership of PLAY changes by any mechanism. Also emits
    ///  when tokens are destroyed ('to' == 0).
    //-------------------------------------------------------------------------
    event Transfer (address indexed from, address indexed to, uint tokens);

    //-------------------------------------------------------------------------
    /// @dev Emits when an approved spender is changed or reaffirmed, or if
    ///  the allowance amount changes. The zero address indicates there is no
    ///  approved address.
    //-------------------------------------------------------------------------
    event Approval (
        address indexed tokenOwner, 
        address indexed spender, 
        uint tokens
    );
    
    // total number of tokens in circulation (in pWei).
    //  Burning tokens reduces this amount
    uint totalPLAY = 1000000000 * 10**18;    // one billion
    // the token balances of all token holders
    mapping (address => uint) playBalances;
    // approved spenders and allowances of all token holders
    mapping (address => mapping (address => uint)) allowances;

    constructor() public {
        playBalances[msg.sender] = totalPLAY;
    }

    //-------------------------------------------------------------------------
    /// @dev Throws if parameter is zero
    //-------------------------------------------------------------------------
    modifier notZero(uint param) {
        require (param != 0, "Parameter cannot be zero");
        _;
    }
    
    //-------------------------------------------------------------------------
    /// @dev Throws if tokenOwner has insufficient PLAY balance
    //-------------------------------------------------------------------------
    modifier sufficientFunds(address tokenOwner, uint tokens) {
        require (playBalances[tokenOwner] >= tokens, "Insufficient balance");
        _;
    }
    
    //-------------------------------------------------------------------------
    /// @dev Throws if spender has insufficient allowance from owner
    //-------------------------------------------------------------------------
    modifier sufficientAllowance(address owner, address spender, uint tokens) {
        require (
            allowances[owner][spender] >= tokens, 
            "Insufficient allowance"
        );
        _;
    }

    //-------------------------------------------------------------------------
    /// @notice Send `(tokens/1000000000000000000).fixed(0,18)` PLAY to `to`.
    /// @dev Throws if amount to send is zero. Throws if `msg.sender` has
    ///  insufficient balance for transfer. Throws if `to` is the zero address.
    /// @param to The address to where PLAY is being sent.
    /// @param tokens The number of tokens to send (in pWei).
    /// @return True upon successful transfer. Will throw if unsuccessful.
    //-------------------------------------------------------------------------
    function transfer(address to, uint tokens) 
        public 
        notZero(uint(to)) 
        notZero(tokens)
        sufficientFunds(msg.sender, tokens)
        returns(bool) 
    {
        // subtract amount from sender
        playBalances[msg.sender] -= tokens;
        // add amount to token receiver
        playBalances[to] += tokens;
        // emit transfer event
        emit Transfer(msg.sender, to, tokens);
        
        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Send `(tokens/1000000000000000000).fixed(0,18)` PLAY from
    ///  `from` to `to`.
    /// @dev Throws if amount to send is zero. Throws if `msg.sender` has
    ///  insufficient allowance for transfer. Throws if `from` has
    ///  insufficient balance for transfer. Throws if `to` is the zero address.
    /// @param from The address from where PLAY is being sent. Sender must be
    ///  an approved spender.
    /// @param to The token owner whose PLAY is being sent.
    /// @param tokens The number of tokens to send (in pWei).
    /// @return True upon successful transfer. Will throw if unsuccessful.
    //-------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) 
        public 
        notZero(uint(to)) 
        notZero(tokens) 
        sufficientFunds(from, tokens)
        sufficientAllowance(from, msg.sender, tokens)
        returns(bool) 
    {
        // subtract amount from sender's allowance
        allowances[from][msg.sender] -= tokens;
        // subtract amount from token owner
        playBalances[from] -= tokens;
        // add amount to token receiver
        playBalances[to] += tokens;
        // emit transfer event
        emit Transfer(from, to, tokens);

        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Allow `spender` to withdraw from your account, multiple times,
    ///  up to `(tokens/1000000000000000000).fixed(0,18)` PLAY. Calling this
    ///  function overwrites the previous allowance of spender.
    /// @dev Emits approval event
    /// @param spender The address to authorize as a spender
    /// @param tokens The new token allowance of spender (in pWei).
    //-------------------------------------------------------------------------
    function approve(address spender, uint tokens) external returns(bool) {
        // set the spender's allowance to token amount
        allowances[msg.sender][spender] = tokens;
        // emit approval event
        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Get the total number of tokens in circulation.
    /// @return Total tokens tracked by this contract.
    //-------------------------------------------------------------------------
    function totalSupply() external view returns (uint) { return totalPLAY; }

    //-------------------------------------------------------------------------
    /// @notice Get the number of PLAY tokens owned by `tokenOwner`.
    /// @dev Throws if trying to query the zero address.
    /// @param tokenOwner The PLAY token owner.
    /// @return The number of PLAY tokens owned by `tokenOwner` (in pWei).
    //-------------------------------------------------------------------------
    function balanceOf(address tokenOwner) 
        public 
        view 
        notZero(uint(tokenOwner))
        returns(uint)
    {
        return playBalances[tokenOwner];
    }

    //-------------------------------------------------------------------------
    /// @notice Get the remaining allowance of `spender` for `tokenOwner`.
    /// @param tokenOwner The PLAY token owner.
    /// @param spender The approved spender address.
    /// @return The remaining allowance of `spender` for `tokenOwner`.
    //-------------------------------------------------------------------------
    function allowance(
        address tokenOwner, 
        address spender
    ) public view returns (uint) {
        return allowances[tokenOwner][spender];
    }

    //-------------------------------------------------------------------------
    /// @notice Get the token's name.
    /// @return The token's name as a string
    //-------------------------------------------------------------------------
    function name() external pure returns (string) { 
        return "PLAY Network Token"; 
    }

    //-------------------------------------------------------------------------
    /// @notice Get the token's ticker symbol.
    /// @return The token's ticker symbol as a string
    //-------------------------------------------------------------------------
    function symbol() external pure returns (string) { return "PLAY"; }

    //-------------------------------------------------------------------------
    /// @notice Get the number of allowed decimal places for the token.
    /// @return The number of allowed decimal places for the token.
    //-------------------------------------------------------------------------
    function decimals() external pure returns (uint8) { return 18; }
}


//-----------------------------------------------------------------------------
/// @title BurnToken contract
/// @notice defines token burning functionality.
//-----------------------------------------------------------------------------
contract BurnToken is PLAYToken {
    //-------------------------------------------------------------------------
    /// @notice Destroy `(tokens/1000000000000000000).fixed(0,18)` PLAY. These
    ///  tokens cannot be viewed or recovered.
    /// @dev Throws if amount to burn is zero. Throws if sender has
    ///  insufficient balance to burn. Emits transfer event.
    /// @param tokens The number of tokens to burn (in pWei). 
    /// @return True upon successful burn. Will throw if unsuccessful.
    //-------------------------------------------------------------------------
    function burn(uint tokens)
        external 
        notZero(tokens) 
        sufficientFunds(msg.sender, tokens)
        returns(bool) 
    {
        // subtract amount from token owner
        playBalances[msg.sender] -= tokens;
        // subtract amount from total supply
        totalPLAY -= tokens;
        // emit transfer event
        emit Transfer(msg.sender, address(0), tokens);

        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Destroy `(tokens/1000000000000000000).fixed(0,18)` PLAY from 
    /// `from`. These tokens cannot be viewed or recovered.
    /// @dev Throws if amount to burn is zero. Throws if sender has
    ///  insufficient allowance to burn. Throws if `from` has insufficient
    ///  balance to burn. Emits transfer event.
    /// @param from The token owner whose PLAY is being burned. Sender must be
    ///  an approved spender.
    /// @param tokens The number of tokens to burn (in pWei).
    /// @return True upon successful burn. Will throw if unsuccessful.
    //-------------------------------------------------------------------------
    function burnFrom(address from, uint tokens) 
        external 
        notZero(tokens) 
        sufficientFunds(from, tokens)
        sufficientAllowance(from, msg.sender, tokens)
        returns(bool) 
    {
        // subtract amount from sender's allowance
        allowances[from][msg.sender] -= tokens;
        // subtract amount from token owner
        playBalances[from] -= tokens;
        // subtract amount from total supply
        totalPLAY -= tokens;
        // emit transfer event
        emit Transfer(from, address(0), tokens);

        return true;
    }
}


//-----------------------------------------------------------------------------
/// @title LockToken contract
/// @notice defines token locking and unlocking functionality.
//-----------------------------------------------------------------------------
contract LockToken is BurnToken {
    //-------------------------------------------------------------------------
    /// @dev Emits when PLAY tokens become locked for any number of years by
    ///  any mechanism.
    //-------------------------------------------------------------------------
    event Lock (address indexed tokenOwner, uint tokens);

    //-------------------------------------------------------------------------
    /// @dev Emits when PLAY tokens become unlocked by any mechanism.
    //-------------------------------------------------------------------------
    event Unlock (address indexed tokenOwner, uint tokens);

    // Unix Timestamp for 1-1-2018 at 00:00:00.
    //  Used to calculate years since release.
    uint constant FIRST_YEAR_TIMESTAMP = 1514764800;
    // Tracks years since release. Starts at 0 and increments every 365 days.
    uint public currentYear;
    // Maximum number of years into the future locked tokens can be recovered.
    uint public maximumLockYears = 10;
    // Locked token balances by unlock year  
    mapping (address => mapping(uint => uint)) tokensLockedUntilYear;

    //-------------------------------------------------------------------------
    /// @notice Lock `(tokens/1000000000000000000).fixed(0,18)` PLAY for
    ///  `numberOfYears` years.
    /// @dev Throws if amount to lock is zero. Throws if numberOfYears is zero
    ///  or greater than maximumLockYears. Throws if `msg.sender` has 
    ///  insufficient balance to lock.
    /// @param numberOfYears The number of years the tokens will be locked.
    /// @param tokens The number of tokens to lock (in pWei).
    //-------------------------------------------------------------------------
    function lock(uint numberOfYears, uint tokens) 
        public 
        notZero(tokens)
        sufficientFunds(msg.sender, tokens)
        returns(bool)
    {
        // number of years must be a valid amount.
        require (
            numberOfYears > 0 && numberOfYears <= maximumLockYears,
            "Invalid number of years"
        );

        // subtract amount from sender
        playBalances[msg.sender] -= tokens;
        // add amount to sender's locked token balance
        tokensLockedUntilYear[msg.sender][currentYear+numberOfYears] += tokens;
        // emit lock event
        emit Lock(msg.sender, tokens);

        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Lock `(tokens/1000000000000000000).fixed(0,18)` PLAY from 
    ///  `from` for `numberOfYears` years.
    /// @dev Throws if amount to lock is zero. Throws if numberOfYears is zero
    ///  or greater than maximumLockYears. Throws if `msg.sender` has
    ///  insufficient allowance to lock. Throws if `from` has insufficient
    ///  balance to lock.
    /// @param from The token owner whose PLAY is being locked. Sender must be
    ///  an approved spender.
    /// @param numberOfYears The number of years the tokens will be locked.
    /// @param tokens The number of tokens to lock (in pWei).
    //-------------------------------------------------------------------------
    function lockFrom(address from, uint numberOfYears, uint tokens) 
        external
        notZero(tokens)
        sufficientFunds(from, tokens)
        sufficientAllowance(from, msg.sender, tokens)
        returns(bool) 
    {
        // number of years must be a valid amount.
        require (
            numberOfYears > 0 && numberOfYears <= maximumLockYears,
            "Invalid number of years"
        );

        // subtract amount from sender's allowance
        allowances[from][msg.sender] -= tokens;
        // subtract amount from token owner's balance
        playBalances[from] -= tokens;
        // add amount to token owner's locked token balance
        tokensLockedUntilYear[from][currentYear + numberOfYears] += tokens;
        // emit lock event
        emit Lock(from, tokens);
        
        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Send `(tokens/1000000000000000000).fixed(0,18)` PLAY to `to`,
    ///  then lock for `numberOfYears` years.
    /// @dev Throws if amount to send is zero. Throws if `msg.sender` has
    ///  insufficient balance for transfer. Throws if `to` is the zero
    ///  address. Emits transfer and lock events.
    /// @param to The address to where PLAY is being sent and locked.
    /// @param numberOfYears The number of years the tokens will be locked.
    /// @param tokens The number of tokens to send (in pWei).
    //-------------------------------------------------------------------------
    function transferAndLock(
        address to, 
        uint numberOfYears, 
        uint tokens
    ) external {
        // Transfer will fail if sender's balance is too low or "to" is zero
        transfer(to, tokens);

        // subtract amount from token receiver's balance
        playBalances[to] -= tokens;
        // add amount to token receiver's locked token balance
        tokensLockedUntilYear[to][currentYear + numberOfYears] += tokens;
        // emit lock event
        emit Lock(msg.sender, tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Send `(tokens/1000000000000000000).fixed(0,18)` PLAY from 
    ///  `from` to `to`, then lock for `numberOfYears` years.
    /// @dev Throws if amount to send is zero. Throws if `msg.sender` has
    ///  insufficient allowance for transfer. Throws if `from` has 
    ///  insufficient balance for transfer. Throws if `to` is the zero
    ///  address. Emits transfer and lock events.
    /// @param from The token owner whose PLAY is being sent. Sender must be
    ///  an approved spender.
    /// @param to The address to where PLAY is being sent and locked.
    /// @param tokens The number of tokens to send (in pWei).
    //-------------------------------------------------------------------------
    function transferFromAndLock(
        address from, 
        address to, 
        uint numberOfYears, 
        uint tokens
    ) external {
        // Initiate transfer. Transfer will fail if sender's allowance is too
        //  low, token owner's balance is too low, or "to" is zero
        transferFrom(from, to, tokens);

        // subtract amount from token owner's balance
        playBalances[to] -= tokens;
        // add amount to token receiver's locked token balance
        tokensLockedUntilYear[to][currentYear + numberOfYears] += tokens;
        // emit lock event
        emit Lock(msg.sender, tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Unlock all qualifying tokens for `tokenOwner`. Sender must 
    ///  either be tokenOwner or an approved address.
    /// @dev If tokenOwner is empty, tokenOwner is set to msg.sender. Throws
    ///  if sender is not tokenOwner or an approved spender (allowance > 0).
    /// @param tokenOwner The token owner whose tokens will unlock.
    //-------------------------------------------------------------------------
    function unlockAll(address tokenOwner) external {
        // create local variable for token owner
        address addressToUnlock = tokenOwner;
        // if tokenOwner parameter is empty, set tokenOwner to sender
        if (addressToUnlock == address(0)) {
            addressToUnlock = msg.sender;
        }
        // sender must either be tokenOwner or an approved address
        if (msg.sender != addressToUnlock) {
            require (
                allowances[addressToUnlock][msg.sender] > 0,
                "Not authorized to unlock for this address"
            );
        }

        // create local variable for unlock total
        uint tokensToUnlock;
        // check each year starting from 1 year after release
        for (uint i = 1; i <= currentYear; ++i) {
            // add qualifying tokens to tokens to unlock variable
            tokensToUnlock += tokensLockedUntilYear[addressToUnlock][i];
            // set locked token balance of year i to 0 
            tokensLockedUntilYear[addressToUnlock][i] = 0;
        }
        // add qualifying tokens back to token owner's account balance
        playBalances[addressToUnlock] += tokensToUnlock;
        // emit unlock event
        emit Unlock (addressToUnlock, tokensToUnlock);
    }

    //-------------------------------------------------------------------------
    /// @notice Unlock all tokens locked until `year` years since 2018 for 
    ///  `tokenOwner`. Sender must be tokenOwner or an approved address.
    /// @dev If tokenOwner is empty, tokenOwner is set to msg.sender. Throws
    ///  if sender is not tokenOwner or an approved spender (allowance > 0).
    /// @param tokenOwner The token owner whose tokens will unlock.
    /// @param year Number of years since 2018 the tokens were locked until.
    //-------------------------------------------------------------------------
    function unlockByYear(address tokenOwner, uint year) external {
        // create local variable for token owner
        address addressToUnlock = tokenOwner;
        // if tokenOwner parameter is empty, set tokenOwner to sender
        if (addressToUnlock == address(0)) {
            addressToUnlock = msg.sender;
        }
        // sender must either be tokenOwner or an approved address
        if (msg.sender != addressToUnlock) {
            require (
                allowances[addressToUnlock][msg.sender] > 0,
                "Not authorized to unlock for this address"
            );
        }
        // year of locked tokens must be less than or equal to current year
        require (
            currentYear >= year,
            "Tokens from this year cannot be unlocked yet"
        );
        // create local variable for unlock amount
        uint tokensToUnlock = tokensLockedUntilYear[addressToUnlock][year];
        // set locked token balance of year to 0
        tokensLockedUntilYear[addressToUnlock][year] = 0;
        // add qualifying tokens back to token owner's account balance
        playBalances[addressToUnlock] += tokensToUnlock;
        // emit unlock event
        emit Unlock(addressToUnlock, tokensToUnlock);
    }

    //-------------------------------------------------------------------------
    /// @notice Update the current year.
    /// @dev Throws if less than 365 days has passed since currentYear.
    //-------------------------------------------------------------------------
    function updateYearsSinceRelease() external {
        // check if years since first year is greater than the currentYear
        uint secondsSinceRelease = block.timestamp - FIRST_YEAR_TIMESTAMP;
        require (
            currentYear < secondsSinceRelease / (365 * 1 days),
            "Cannot update year yet"
        );
        // increment years since release
        ++currentYear;
    }

    //-------------------------------------------------------------------------
    /// @notice Get the total locked token holdings of `tokenOwner`.
    /// @param tokenOwner The locked token owner.
    /// @return Total locked token holdings of an address.
    //-------------------------------------------------------------------------
    function getTotalLockedTokens(
        address tokenOwner
    ) public view returns (uint lockedTokens) {
        for (uint i = 1; i < currentYear + maximumLockYears; ++i) {
            lockedTokens += tokensLockedUntilYear[tokenOwner][i];
        }
    }

    //-------------------------------------------------------------------------
    /// @notice Get the locked token holdings of `tokenOwner` unlockable in
    ///  `(year + 2018)`.
    /// @param tokenOwner The locked token owner.
    /// @param year Years since 2018 the tokens are locked until.
    /// @return Locked token holdings of an address for `(year + 2018)`.
    //-------------------------------------------------------------------------
    function getLockedTokensByYear(
        address tokenOwner, 
        uint year
    ) external view returns (uint) {
        return tokensLockedUntilYear[tokenOwner][year];
    }
}


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
/// @title TOY Token Interface - ERC721-compliant view functions 
//-----------------------------------------------------------------------------
interface ToyTokenOwnership {
    function ownerOf(uint256 _tokenId) external view returns (address);
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(
        address _owner, 
        address _operator
    ) external view returns (bool);
}


//-----------------------------------------------------------------------------
/// @title Color Token Contract
/// @notice defines colored token registration, creation, and spending
///  functionality.
//-----------------------------------------------------------------------------
contract ColorToken is LockToken, Ownable {
    //-------------------------------------------------------------------------
    /// @dev Emits when a new colored token is created.
    //-------------------------------------------------------------------------
    event NewColor(address indexed creator, string name);

    //-------------------------------------------------------------------------
    /// @dev Emits when colored tokens are deposited into TOY Tokens. Color
    ///  equivalent to PLAY.transfer().
    //-------------------------------------------------------------------------
    event DepositColor(
        uint indexed to, 
        uint indexed colorIndex, 
        uint tokens
    );

    //-------------------------------------------------------------------------
    /// @dev Emits when colored tokens are spent by any mechanism. Color
    ///  equivalent to PLAY.burn().
    //-------------------------------------------------------------------------
    event SpendColor(
        uint indexed from, 
        uint indexed color, 
        uint amount
    );

    // Colored token data
    struct ColoredToken {
        address creator;
        string name;
        mapping (uint => uint) balances;
    }

    // array containing all colored token data
    ColoredToken[] coloredTokens;
    // required locked tokens needed to register a color (in pWei)
    uint public requiredLockedForColorRegistration = 10000 * 10**18;
    // TOY Token contract to interface with
    ToyTokenOwnership toy;
    // UID value is 7 bytes. Max value is 2**56
    uint constant UID_MAX = 0xFFFFFFFFFFFFFF;

    //-------------------------------------------------------------------------
    /// @notice Set the address of the TOY Token interface to `toyAddress`.
    /// @dev Throws if toyAddress is the zero address.
    /// @param toyAddress The address of the TOY Token interface.
    //-------------------------------------------------------------------------
    function setToyTokenContractAddress (address toyAddress) 
        external 
        notZero(uint(toyAddress)) 
        onlyOwner
    {
        // initialize contract to toyAddress
        toy = ToyTokenOwnership(toyAddress);
    }

    //-------------------------------------------------------------------------
    /// @notice Set required total locked tokens to 
    ///  `(newAmount/1000000000000000000).fixed(0,18)`.
    /// @dev Throws if the sender is not the contract owner. Throws if new
    ///  amount is zero.
    /// @param newAmount The new required locked token amount (in pWei).
    //-------------------------------------------------------------------------
    function setRequiredLockedForColorRegistration(uint newAmount) 
        external 
        onlyOwner
        notZero(newAmount)
    {
        requiredLockedForColorRegistration = newAmount;
    }
    
    //-------------------------------------------------------------------------
    /// @notice Registers `colorName` as a new colored token. Must own
    ///  `requiredLockedForColorReg` locked tokens as a requirement.
    /// @dev Throws if `msg.sender` has insufficient locked tokens. Throws if
    ///  colorName is empty or is longer than 32 characters.
    /// @param colorName The name for the new colored token.
    /// @return Index number for the new colored token.
    //-------------------------------------------------------------------------
    function registerNewColor(string colorName) external returns (uint) {
        // sender must have enough locked tokens
        require (
            getTotalLockedTokens(msg.sender) >= requiredLockedForColorRegistration,
            "Insufficient locked tokens"
        );
        // colorName must be a valid length
        require (
            bytes(colorName).length > 0 && bytes(colorName).length < 32,
            "Invalid color name length"
        );
        // push new colored token to colored token array and store the index
        uint index = coloredTokens.push(ColoredToken(msg.sender, colorName));
        return index;
    }

    //-------------------------------------------------------------------------
    /// @notice Locks `(tokens/1000000000000000000).fixed(0,18)` PLAY tokens
    ///  for 2 years, then deposits the same number of colored tokens with 
    ///  index `colorIndex` into TOY Token #`uid`.
    /// @dev Throws if tokens to deposit is zero. Throws if colorIndex is
    ///  greater than number of colored tokens. Throws if `msg.sender` has
    ///  insufficient balance to lock. Throws if `uid` is greater than
    ///  maximum UID value. Throws if token does not have an owner. Throws if
    ///  sender is not the creator of the colored token.
    /// @param to The Unique Identifier of the TOY Token receiving tokens.
    /// @param colorIndex The index of the color to spend.
    /// @param tokens The number of colored tokens to spend (in pWei).
    //-------------------------------------------------------------------------
    function deposit (uint colorIndex, uint to, uint tokens)
        external 
        notZero(tokens)
    {
        // colorIndex must be valid color
        require (colorIndex < coloredTokens.length, "Invalid color index");
        // sender must be colored token creator
        require (
            msg.sender == coloredTokens[colorIndex].creator,
            "Not authorized to deposit this color"
        );
        // uid must be a valid UID
        require (to < UID_MAX, "Invalid UID");
        // If TOY Token #uid is not owned, it does not exist yet.
        require(toy.ownerOf(to) != address(0), "TOY Token does not exist");
        // colorIndex must be less than the number of colored tokens.
        require (colorIndex < coloredTokens.length, "Invalid color index");
        
        // Initiate lock. Fails if sender's balance is too low.
        lock(2, tokens);

        // add tokens to TOY Token #UID
        coloredTokens[colorIndex].balances[to] += tokens;
        // emit color transfer event
        emit DepositColor(to, colorIndex, tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Spend `(tokens/1000000000000000000).fixed(0,18)` colored 
    ///  tokens with index `colorIndex`.
    /// @dev Throws if tokens to spend is zero. Throws if colorIndex is
    ///  greater than number of colored tokens. Throws if `msg.sender` has
    ///  insufficient balance to spend.
    /// @param colorIndex The index of the color to spend.
    /// @param from The UID of the TOY Token to spend from.
    /// @param tokens The number of colored tokens to spend (in pWei).
    /// @return True if spend successful. Throw if unsuccessful.
    //-------------------------------------------------------------------------
    function spend (uint colorIndex, uint from, uint tokens) 
        external 
        notZero(tokens)
        returns(bool) 
    {
        // colorIndex must be valid color
        require (colorIndex < coloredTokens.length, "Invalid color index");
        // sender must own TOY Token
        require (
            msg.sender == toy.ownerOf(from), 
            "Sender is not owner of TOY Token"
        );
        // token owner's balance must be enough to spend tokens
        require (
            coloredTokens[colorIndex].balances[from] >= tokens,
            "Insufficient tokens to spend"
        );
        // deduct the tokens from the sender's balance
        coloredTokens[colorIndex].balances[from] -= tokens;
        // emit spend event
        emit SpendColor(from, colorIndex, tokens);
        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Spend `(tokens/1000000000000000000).fixed(0,18)` colored
    ///  tokens with color index `index` from `from`.
    /// @dev Throws if tokens to spend is zero. Throws if colorIndex is 
    ///  greater than number of colored tokens. Throws if `msg.sender` is not
    ///  the colored token's creator. Throws if `from` has insufficient
    ///  balance to spend.
    /// @param colorIndex The index of the color to spend.
    /// @param from The address whose colored tokens are being spent.
    /// @param tokens The number of tokens to send (in pWei).
    //-------------------------------------------------------------------------
    function spendFrom(uint colorIndex, uint from, uint tokens)
        external 
        notZero(tokens)
        returns (bool) 
    {
        // colorIndex must be valid color
        require (colorIndex < coloredTokens.length, "Invalid color index");
        // sender must be authorized address or operator for TOY Token
        require (
            msg.sender == toy.getApproved(from) ||
            toy.isApprovedForAll(toy.ownerOf(from), msg.sender), 
            "Sender is not authorized operator for TOY Token"
        );
        // token owner's balance must be enough to spend tokens
        require (
            coloredTokens[colorIndex].balances[from] >= tokens,
            "Insufficient balance to spend"
        );
        // deduct the tokens from token owner's balance
        coloredTokens[colorIndex].balances[from] -= tokens;
        // emit spend event
        emit SpendColor(from, colorIndex, tokens);
        return true;
    }

    //-------------------------------------------------------------------------
    /// @notice Get the number of colored tokens with color index `colorIndex`
    ///  owned by TOY Token #`uid`.
    /// @param uid The TOY Token with deposited color tokens.
    /// @param colorIndex Index of the colored token to query.
    /// @return The number of colored tokens with color index `colorIndex`
    ///  owned by TOY Token #`uid`.
    //-------------------------------------------------------------------------
    function getColoredTokenBalance(uint uid, uint colorIndex) 
        external 
        view 
        returns(uint) 
    {
        return coloredTokens[colorIndex].balances[uid];
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
    ///  `colorIndex`
    /// @param colorIndex Index of the colored token to query.
    /// @return The creator address and name of colored token.
    //-------------------------------------------------------------------------
    function getColoredToken(uint colorIndex) 
        external 
        view 
        returns(address, string)
    {
        return (
            coloredTokens[colorIndex].creator, 
            coloredTokens[colorIndex].name
        );
    }
}
pragma solidity 0.4.15;

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        owner = msg.sender;
    }

    address public newOwner;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    function changeOwner(address _newOwner) onlyOwner {
        if(msg.sender == owner) {
            owner = _newOwner;
        }
    }
}


/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
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


contract DynamicCeiling is Owned {
    using SafeMath for uint256;

    struct Ceiling {
        bytes32 hash;
        uint256 limit;
        uint256 slopeFactor;
        uint256 collectMinimum;
    }

    address public saleAddress;

    Ceiling[] public ceilings;
    
    uint256 public currentIndex;
    uint256 public revealedCeilings;
    bool public allRevealed;

    modifier onlySaleAddress {
        require(msg.sender == saleAddress);
        _;
    }

    function DynamicCeiling(address _owner, address _saleAddress) {
        owner = _owner;
        saleAddress = _saleAddress;
    }

    /// @notice This should be called by the creator of the contract to commit
    ///  all the ceilings.
    /// @param _ceilingHashes Array of hashes of each ceiling. Each hash is calculated
    ///  by the `calculateHash` method. More hashes than actual ceilings can be
    ///  committed in order to hide also the number of ceilings.
    ///  The remaining hashes can be just random numbers.
    function setHiddenCeilings(bytes32[] _ceilingHashes) public onlyOwner {
        require(ceilings.length == 0);

        ceilings.length = _ceilingHashes.length;
        for (uint256 i = 0; i < _ceilingHashes.length; i = i.add(1)) {
            ceilings[i].hash = _ceilingHashes[i];
        }
    }

    /// @notice Anybody can reveal the next ceiling if he knows it.
    /// @param _limit Ceiling cap.
    ///  (must be greater or equal to the previous one).
    /// @param _last `true` if it's the last ceiling.
    /// @param _salt Random number used to commit the ceiling
    function revealCeiling(
        uint256 _limit, 
        uint256 _slopeFactor, 
        uint256 _collectMinimum,
        bool _last, 
        bytes32 _salt) 
        public 
        {
        require(!allRevealed);
        require(
            ceilings[revealedCeilings].hash == 
            calculateHash(
                _limit, 
                _slopeFactor, 
                _collectMinimum, 
                _last, 
                _salt
            )
        );

        require(_limit != 0 && _slopeFactor != 0 && _collectMinimum != 0);
        if (revealedCeilings > 0) {
            require(_limit >= ceilings[revealedCeilings.sub(1)].limit);
        }

        ceilings[revealedCeilings].limit = _limit;
        ceilings[revealedCeilings].slopeFactor = _slopeFactor;
        ceilings[revealedCeilings].collectMinimum = _collectMinimum;
        revealedCeilings = revealedCeilings.add(1);

        if (_last) {
            allRevealed = true;
        }
    }

    /// @notice Reveal multiple ceilings at once
    function revealMulti(
        uint256[] _limits,
        uint256[] _slopeFactors,
        uint256[] _collectMinimums,
        bool[] _lasts, 
        bytes32[] _salts) 
        public 
        {
        // Do not allow none and needs to be same length for all parameters
        require(
            _limits.length != 0 &&
            _limits.length == _slopeFactors.length &&
            _limits.length == _collectMinimums.length &&
            _limits.length == _lasts.length &&
            _limits.length == _salts.length
        );

        for (uint256 i = 0; i < _limits.length; i = i.add(1)) {
            
            revealCeiling(
                _limits[i],
                _slopeFactors[i],
                _collectMinimums[i],
                _lasts[i],
                _salts[i]
            );
        }
    }

    /// @notice Move to ceiling, used as a failsafe
    function moveToNextCeiling() public onlyOwner {

        currentIndex = currentIndex.add(1);
    }

    /// @return Return the funds to collect for the current point on the ceiling
    ///  (or 0 if no ceilings revealed yet)
    function availableAmountToCollect(uint256  totallCollected) public onlySaleAddress returns (uint256) {
    
        if (revealedCeilings == 0) {
            return 0;
        }

        if (totallCollected >= ceilings[currentIndex].limit) {  
            uint256 nextIndex = currentIndex.add(1);

            if (nextIndex >= revealedCeilings) {
                return 0; 
            }
            currentIndex = nextIndex;
            if (totallCollected >= ceilings[currentIndex].limit) {
                return 0;  
            }
        }        
        uint256 remainedFromCurrentCeiling = ceilings[currentIndex].limit.sub(totallCollected);
        uint256 reminderWithSlopeFactor = remainedFromCurrentCeiling.div(ceilings[currentIndex].slopeFactor);

        if (reminderWithSlopeFactor > ceilings[currentIndex].collectMinimum) {
            return reminderWithSlopeFactor;
        }
        
        if (remainedFromCurrentCeiling > ceilings[currentIndex].collectMinimum) {
            return ceilings[currentIndex].collectMinimum;
        } else {
            return remainedFromCurrentCeiling;
        }
    }

    /// @notice Calculates the hash of a ceiling.
    /// @param _limit Ceiling cap.
    /// @param _last `true` if it's the last ceiling.
    /// @param _collectMinimum the minimum amount to collect
    /// @param _salt Random number that will be needed to reveal this ceiling.
    /// @return The calculated hash of this ceiling to be used in the `setHiddenCurves` method
    function calculateHash(
        uint256 _limit, 
        uint256 _slopeFactor, 
        uint256 _collectMinimum,
        bool _last, 
        bytes32 _salt) 
        public 
        constant 
        returns (bytes32) 
        {
        return keccak256(
            _limit,
            _slopeFactor, 
            _collectMinimum,
            _last,
            _salt
        );
    }

    /// @return Return the total number of ceilings committed
    ///  (can be larger than the number of actual ceilings on the ceiling to hide
    ///  the real number of ceilings)
    function nCeilings() public constant returns (uint256) {
        return ceilings.length;
    }

}

/// @title Vesting trustee
contract Trustee is Owned {
    using SafeMath for uint256;

    // The address of the SHP ERC20 token.
    SHP public shp;

    struct Grant {
        uint256 value;
        uint256 start;
        uint256 cliff;
        uint256 end;
        uint256 transferred;
        bool revokable;
    }

    // Grants holder.
    mapping (address => Grant) public grants;

    // Total tokens available for vesting.
    uint256 public totalVesting;

    event NewGrant(address indexed _from, address indexed _to, uint256 _value);
    event UnlockGrant(address indexed _holder, uint256 _value);
    event RevokeGrant(address indexed _holder, uint256 _refund);

    /// @dev Constructor that initializes the address of the SHP contract.
    /// @param _shp SHP The address of the previously deployed SHP smart contract.
    function Trustee(SHP _shp) {
        require(_shp != address(0));
        shp = _shp;
    }

    /// @dev Grant tokens to a specified address.
    /// @param _to address The address to grant tokens to.
    /// @param _value uint256 The amount of tokens to be granted.
    /// @param _start uint256 The beginning of the vesting period.
    /// @param _cliff uint256 Duration of the cliff period.
    /// @param _end uint256 The end of the vesting period.
    /// @param _revokable bool Whether the grant is revokable or not.
    function grant(address _to, uint256 _value, uint256 _start, uint256 _cliff, uint256 _end, bool _revokable)
        public onlyOwner {
        require(_to != address(0));
        require(_value > 0);

        // Make sure that a single address can be granted tokens only once.
        require(grants[_to].value == 0);

        // Check for date inconsistencies that may cause unexpected behavior.
        require(_start <= _cliff && _cliff <= _end);

        // Check that this grant doesn't exceed the total amount of tokens currently available for vesting.
        require(totalVesting.add(_value) <= shp.balanceOf(address(this)));

        // Assign a new grant.
        grants[_to] = Grant({
            value: _value,
            start: _start,
            cliff: _cliff,
            end: _end,
            transferred: 0,
            revokable: _revokable
        });

        // Tokens granted, reduce the total amount available for vesting.
        totalVesting = totalVesting.add(_value);

        NewGrant(msg.sender, _to, _value);
    }

    /// @dev Revoke the grant of tokens of a specifed address.
    /// @param _holder The address which will have its tokens revoked.
    function revoke(address _holder) public onlyOwner {
        Grant grant = grants[_holder];

        require(grant.revokable);

        // Send the remaining SHP back to the owner.
        uint256 refund = grant.value.sub(grant.transferred);

        // Remove the grant.
        delete grants[_holder];

        totalVesting = totalVesting.sub(refund);
        shp.transfer(msg.sender, refund);

        RevokeGrant(_holder, refund);
    }

    /// @dev Calculate the total amount of vested tokens of a holder at a given time.
    /// @param _holder address The address of the holder.
    /// @param _time uint256 The specific time.
    /// @return a uint256 representing a holder's total amount of vested tokens.
    function vestedTokens(address _holder, uint256 _time) public constant returns (uint256) {
        Grant grant = grants[_holder];
        if (grant.value == 0) {
            return 0;
        }

        return calculateVestedTokens(grant, _time);
    }

    /// @dev Calculate amount of vested tokens at a specifc time.
    /// @param _grant Grant The vesting grant.
    /// @param _time uint256 The time to be checked
    /// @return An uint256 representing the amount of vested tokens of a specific grant.
    ///   |                         _/--------   vestedTokens rect
    ///   |                       _/
    ///   |                     _/
    ///   |                   _/
    ///   |                 _/
    ///   |                /
    ///   |              .|
    ///   |            .  |
    ///   |          .    |
    ///   |        .      |
    ///   |      .        |
    ///   |    .          |
    ///   +===+===========+---------+----------> time
    ///     Start       Cliff      End
    function calculateVestedTokens(Grant _grant, uint256 _time) private constant returns (uint256) {
        // If we're before the cliff, then nothing is vested.
        if (_time < _grant.cliff) {
            return 0;
        }

        // If we're after the end of the vesting period - everything is vested;
        if (_time >= _grant.end) {
            return _grant.value;
        }

        // Interpolate all vested tokens: vestedTokens = tokens/// (time - start) / (end - start)
         return _grant.value.mul(_time.sub(_grant.start)).div(_grant.end.sub(_grant.start));
    }

    /// @dev Unlock vested tokens and transfer them to their holder.
    /// @return a uint256 representing the amount of vested tokens transferred to their holder.
    function unlockVestedTokens() public {
        Grant grant = grants[msg.sender];
        require(grant.value != 0);

        // Get the total amount of vested tokens, acccording to grant.
        uint256 vested = calculateVestedTokens(grant, now);
        if (vested == 0) {
            return;
        }

        // Make sure the holder doesn't transfer more than what he already has.
        uint256 transferable = vested.sub(grant.transferred);
        if (transferable == 0) {
            return;
        }

        grant.transferred = grant.transferred.add(transferable);
        totalVesting = totalVesting.sub(transferable);
        shp.transfer(msg.sender, transferable);

        UnlockGrant(msg.sender, transferable);
    }
}

/// @dev The token controller contract must implement these functions
contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool);
}

contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);
}

/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'MMT_0.1'; //An arbitrary versioning scheme


    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint128 value;
    }

    // `parentToken` is the Token address that was cloned to produce this token;
    //  it will be 0x0 for a token that was not cloned
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` is the block number from the Parent Token that was
    //  used to determine the initial distribution of the Clone Token
    uint public parentSnapShotBlock;

    // `creationBlock` is the block number that the Clone Token was created
    uint public creationBlock;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    // Tracks the history of the `totalSupply` of the token
    Checkpoint[] totalSupplyHistory;

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

    // The factory used to create new clone tokens
    MiniMeTokenFactory public tokenFactory;

////////////////
// Constructor
////////////////

    /// @notice Constructor to create a MiniMeToken
    /// @param _tokenFactory The address of the MiniMeTokenFactory contract that
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    /// @param _parentToken Address of the parent token, set to 0x0 if it is a
    ///  new token
    /// @param _parentSnapShotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


///////////////////
// ERC20 Methods
///////////////////

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) returns (bool success) {
        require(transfersEnabled);
        return doTransfer(msg.sender, _to, _amount);
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            if (allowed[_from][msg.sender] < _amount) return false;
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {

           if (_amount == 0) {
               return true;
           }

           require(parentSnapShotBlock < block.number);

           // Do not allow transfer to 0x0 or the token contract itself
           require((_to != 0) && (_to != address(this)));

           // If the amount being transfered is more than the balance of the
           //  account the transfer returns false
           var previousBalanceFrom = balanceOfAt(_from, block.number);
           if (previousBalanceFrom < _amount) {
               return false;
           }

           // Alerts the token controller of the transfer
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           var previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           Transfer(_from, _to, _amount);

           return true;
    }

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) returns (bool success) {
        require(transfersEnabled);

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        // Alerts the token controller of the approve function call
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param _spender The address of the contract able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the function call was successful
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply() constant returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _blockNumber The block number when the balance is queried
    /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint _blockNumber) constant
        returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                // Has no parent
                return 0;
            }

        // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    /// @notice Total amount of tokens at a specific `_blockNumber`.
    /// @param _blockNumber The block number when the totalSupply is queried
    /// @return The total amount of tokens at `_blockNumber`
    function totalSupplyAt(uint _blockNumber) constant returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

////////////////
// Clone Token Method
////////////////

    /// @notice Creates a new clone token with the initial distribution being
    ///  this token at `_snapshotBlock`
    /// @param _cloneTokenName Name of the clone token
    /// @param _cloneDecimalUnits Number of decimals of the smallest unit
    /// @param _cloneTokenSymbol Symbol of the clone token
    /// @param _snapshotBlock Block when the distribution of the parent token is
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    /// @param _transfersEnabled True if transfers are allowed in the clone
    /// @return The address of the new MiniMeToken Contract
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

////////////////
// Generate and destroy tokens
////////////////

    /// @notice Generates `_amount` tokens that are assigned to `_owner`
    /// @param _owner The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @return True if the tokens are generated correctly
    function generateTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    /// @notice Burns `_amount` tokens from `_owner`
    /// @param _owner The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    /// @return True if the tokens are burned correctly
    function destroyTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

////////////////
// Enable tokens transfers
////////////////


    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed in the clone
    function enableTransfers(bool _transfersEnabled) onlyController {
        transfersEnabled = _transfersEnabled;
    }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

    /// @dev `getValueAt` retrieves the number of tokens at a given block number
    /// @param checkpoints The history of values being queried
    /// @param _block The block number to retrieve the value at
    /// @return The number of tokens being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    /// @dev `updateValueAtNow` used to update the `balances` map and the
    ///  `totalSupplyHistory`
    /// @param checkpoints The history of data being updated
    /// @param _value The new number of tokens
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    /// @dev Helper function to return a min betwen the two uints
    function min(uint a, uint b) internal returns (uint) {
        return a < b ? a : b;
    }

    /// @notice The fallback function: If the contract's controller has not been
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function ()  payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

//////////
// Safety Methods
//////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

////////////////
// Events
////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}


////////////////
// MiniMeTokenFactory
////////////////

/// @dev This contract is used to generate clone contracts from a contract.
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _parentToken Address of the token being cloned
    /// @param _snapshotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    /// @return The address of the new token contract
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) returns (MiniMeToken) 
    {
        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}

contract SHP is MiniMeToken {
    // @dev SHP constructor
    function SHP(address _tokenFactory)
            MiniMeToken(
                _tokenFactory,
                0x0,                             // no parent token
                0,                               // no snapshot block number from parent
                "Sharpe Platform Token",         // Token name
                18,                              // Decimals
                "SHP",                           // Symbol
                true                             // Enable transfers
            ) {}
}

contract AffiliateUtility is Owned {
    using SafeMath for uint256;
    
    uint256 public tierTwoMin;
    uint256 public tierThreeMin;

    uint256 public constant TIER1_PERCENT = 3;
    uint256 public constant TIER2_PERCENT = 4;
    uint256 public constant TIER3_PERCENT = 5;
    
    mapping (address => Affiliate) private affiliates;

    event AffiliateReceived(address affiliateAddress, address investorAddress, bool valid);

    struct Affiliate {
        address etherAddress;
        bool isPresent;
    }

    function AffiliateUtility(uint256 _tierTwoMin, uint256 _tierThreeMin) {
        setTiers(_tierTwoMin, _tierThreeMin);
    }

    /// @notice sets the Ether to Dollar exhchange rate
    /// @param _tierTwoMin the tier 2 min (in WEI)
    /// @param _tierThreeMin the tier 3 min (in WEI)
    function setTiers(uint256 _tierTwoMin, uint256 _tierThreeMin) onlyOwner {
        tierTwoMin = _tierTwoMin;
        tierThreeMin = _tierThreeMin;
    }

    /// @notice This adds an affiliate Ethereum address to our whitelist
    /// @param _investor The investor's address
    /// @param _affiliate The Ethereum address of the affiliate
    function addAffiliate(address _investor, address _affiliate) onlyOwner {
        affiliates[_investor] = Affiliate(_affiliate, true);
    }

    /// @notice calculates and returns the amount to token minted for affilliate
    /// @param _investor address of the investor
    /// @param _contributorTokens amount of SHP tokens minted for contributor
    /// @param _contributionValue amount of ETH contributed
    /// @return tuple of two values (affiliateBonus, contributorBouns)
    function applyAffiliate(
        address _investor, 
        uint256 _contributorTokens, 
        uint256 _contributionValue
    )
        public 
        returns(uint256, uint256) 
    {
        if (getAffiliate(_investor) == address(0)) {
            return (0, 0);
        }

        uint256 contributorBonus = _contributorTokens.div(100);
        uint256 affiliateBonus = 0;

        if (_contributionValue < tierTwoMin) {
            affiliateBonus = _contributorTokens.mul(TIER1_PERCENT).div(100);
        } else if (_contributionValue >= tierTwoMin && _contributionValue < tierThreeMin) {
            affiliateBonus = _contributorTokens.mul(TIER2_PERCENT).div(100);
        } else {
            affiliateBonus = _contributorTokens.mul(TIER3_PERCENT).div(100);
        }

        return(affiliateBonus, contributorBonus);
    }

    /// @notice Fetches the Ethereum address of a valid affiliate
    /// @param _investor The Ethereum address of the investor
    /// @return The Ethereum address as an address type
    function getAffiliate(address _investor) constant returns(address) {
        return affiliates[_investor].etherAddress;
    }

    /// @notice Checks if an affiliate is valid
    /// @param _investor The Ethereum address of the investor
    /// @return True or False
    function isAffiliateValid(address _investor) constant public returns(bool) {
        Affiliate memory affiliate = affiliates[_investor];
        AffiliateReceived(affiliate.etherAddress, _investor, affiliate.isPresent);
        return affiliate.isPresent;
    }
}

contract SCD is MiniMeToken {
    // @dev SCD constructor
    function SCD(address _tokenFactory)
            MiniMeToken(
                _tokenFactory,
                0x0,                             // no parent token
                0,                               // no snapshot block number from parent
                "Sharpe Crypto-Derivative",      // Token name
                18,                              // Decimals
                "SCD",                           // Symbol
                true                             // Enable transfers
            ) {}
}


contract TokenSale is Owned, TokenController {
    using SafeMath for uint256;
    
    SHP public shp;
    AffiliateUtility public affiliateUtility;
    Trustee public trustee;

    address public etherEscrowAddress;
    address public bountyAddress;
    address public trusteeAddress;
    address public apiAddress;

    uint256 public founderTokenCount = 0;
    uint256 public reserveTokenCount = 0;

    uint256 constant public CALLER_EXCHANGE_RATE = 2000;
    uint256 constant public RESERVE_EXCHANGE_RATE = 1500;
    uint256 constant public FOUNDER_EXCHANGE_RATE = 1000;
    uint256 constant public BOUNTY_EXCHANGE_RATE = 500;
    uint256 constant public MAX_GAS_PRICE = 50000000000;

    bool public paused;
    bool public closed;

    mapping(address => bool) public approvedAddresses;

    event Contribution(uint256 etherAmount, address _caller);
    event NewSale(address indexed caller, uint256 etherAmount, uint256 tokensGenerated);
    event SaleClosed(uint256 when);
    
    modifier notPaused() {
        require(!paused);
        _;
    }

    modifier notClosed() {
        require(!closed);
        _;
    }

    modifier onlyApi() {
        require(msg.sender == apiAddress);
        _;
    }

    modifier isValidated() {
        require(msg.sender != 0x0);
        require(msg.value > 0);
        require(!isContract(msg.sender)); 
        require(tx.gasprice <= MAX_GAS_PRICE);
        _;
    }

    modifier isApproved() {
        require(approvedAddresses[msg.sender]);
        _;
    }

    /// @notice Adds an approved address for the sale
    /// @param _addr The address to approve for contribution
    function approveAddress(address _addr) public onlyApi {
        approvedAddresses[_addr] = true;
    }

    /// @notice This method sends the Ether received to the Ether escrow address
    /// and generates the calculated number of SHP tokens, sending them to the caller's address.
    /// It also generates the founder's tokens and the reserve tokens at the same time.
    function doBuy(
        address _caller,
        uint256 etherAmount
    )
        internal
    {

        Contribution(etherAmount, _caller);

        uint256 callerTokens = etherAmount.mul(CALLER_EXCHANGE_RATE);
        uint256 callerTokensWithDiscount = applyDiscount(etherAmount, callerTokens);

        uint256 reserveTokens = etherAmount.mul(RESERVE_EXCHANGE_RATE);
        uint256 founderTokens = etherAmount.mul(FOUNDER_EXCHANGE_RATE);
        uint256 bountyTokens = etherAmount.mul(BOUNTY_EXCHANGE_RATE);
        uint256 vestingTokens = founderTokens.add(reserveTokens);

        founderTokenCount = founderTokenCount.add(founderTokens);
        reserveTokenCount = reserveTokenCount.add(reserveTokens);

        payAffiliate(callerTokensWithDiscount, msg.value, msg.sender);

        shp.generateTokens(_caller, callerTokensWithDiscount);
        shp.generateTokens(bountyAddress, bountyTokens);
        shp.generateTokens(trusteeAddress, vestingTokens);

        NewSale(_caller, etherAmount, callerTokensWithDiscount);
        NewSale(trusteeAddress, etherAmount, vestingTokens);
        NewSale(bountyAddress, etherAmount, bountyTokens);

        etherEscrowAddress.transfer(etherAmount);
        updateCounters(etherAmount);
    }

    /// @notice Applies the discount based on the discount tiers
    /// @param _etherAmount The amount of ether used to evaluate the tier the contribution lies within
    /// @param _contributorTokens The tokens allocated based on the contribution
    function applyDiscount(uint256 _etherAmount, uint256 _contributorTokens) internal constant returns (uint256);

    /// @notice Updates the counters for the amount of Ether paid
    /// @param _etherAmount the amount of Ether paid
    function updateCounters(uint256 _etherAmount) internal;
    
    /// @notice Parent constructor. This needs to be extended from the child contracts
    /// @param _etherEscrowAddress the address that will hold the crowd funded Ether
    /// @param _bountyAddress the address that will hold the bounty scheme SHP
    /// @param _trusteeAddress the address that will hold the vesting SHP
    /// @param _affiliateUtilityAddress address of the deployed AffiliateUtility contract.
    function TokenSale (
        address _etherEscrowAddress,
        address _bountyAddress,
        address _trusteeAddress,
        address _affiliateUtilityAddress,
        address _apiAddress
    ) {
        etherEscrowAddress = _etherEscrowAddress;
        bountyAddress = _bountyAddress;
        trusteeAddress = _trusteeAddress;
        apiAddress = _apiAddress;
        affiliateUtility = AffiliateUtility(_affiliateUtilityAddress);
        trustee = Trustee(_trusteeAddress);
        paused = true;
        closed = false;
    }

    /// @notice Pays an affiliate if they are valid and present in the transaction data
    /// @param _tokens The contribution tokens used to calculate affiliate payment amount
    /// @param _etherValue The Ether value sent
    /// @param _caller The address of the caller
    function payAffiliate(uint256 _tokens, uint256 _etherValue, address _caller) internal {
        if (affiliateUtility.isAffiliateValid(_caller)) {
            address affiliate = affiliateUtility.getAffiliate(_caller);
            var (affiliateBonus, contributorBonus) = affiliateUtility.applyAffiliate(_caller, _tokens, _etherValue);
            shp.generateTokens(affiliate, affiliateBonus);
            shp.generateTokens(_caller, contributorBonus);
        }
    }

    /// @notice Sets the SHP token smart contract
    /// @param _shp the SHP token contract address
    function setShp(address _shp) public onlyOwner {
        shp = SHP(_shp);
    }

    /// @notice Transfers ownership of the token smart contract and trustee
    /// @param _tokenController the address of the new token controller
    /// @param _trusteeOwner the address of the new trustee owner
    function transferOwnership(address _tokenController, address _trusteeOwner) public onlyOwner {
        require(closed);
        require(_tokenController != 0x0);
        require(_trusteeOwner != 0x0);
        shp.changeController(_tokenController);
        trustee.changeOwner(_trusteeOwner);
    }

    /// @notice Internal function to determine if an address is a contract
    /// @param _caller The address being queried
    /// @return True if `caller` is a contract
    function isContract(address _caller) internal constant returns (bool) {
        uint size;
        assembly { size := extcodesize(_caller) }
        return size > 0;
    }

    /// @notice Pauses the contribution if there is any issue
    function pauseContribution() public onlyOwner {
        paused = true;
    }

    /// @notice Resumes the contribution
    function resumeContribution() public onlyOwner {
        paused = false;
    }

    //////////
    // MiniMe Controller Interface functions
    //////////

    // In between the offering and the network. Default settings for allowing token transfers.
    function proxyPayment(address) public payable returns (bool) {
        return false;
    }

    function onTransfer(address, address, uint256) public returns (bool) {
        return false;
    }

    function onApprove(address, address, uint256) public returns (bool) {
        return false;
    }
}


contract SharpeCrowdsale is TokenSale {

    uint256 public totalEtherPaid = 0;
    uint256 public minContributionInWei;
    address public saleAddress;
    
    DynamicCeiling public dynamicCeiling;

    modifier amountValidated() {
        require(msg.value >= minContributionInWei);
        _;
    }

    /// @notice Constructs the contract with the following arguments
    /// @param _etherEscrowAddress the address that will hold the crowd funded Ether
    /// @param _bountyAddress the address that will hold the bounty SHP
    /// @param _trusteeAddress the address that will hold the vesting SHP
    /// @param _affiliateUtilityAddress address of the deployed AffiliateUtility contract.
    /// @param _minContributionInWei minimum amount to contribution possilble
    function SharpeCrowdsale( 
        address _etherEscrowAddress,
        address _bountyAddress,
        address _trusteeAddress,
        address _affiliateUtilityAddress,
        address _apiAddress,
        uint256 _minContributionInWei) 
        TokenSale (
        _etherEscrowAddress,
        _bountyAddress,
        _trusteeAddress,
        _affiliateUtilityAddress,
        _apiAddress) 
    {
        minContributionInWei = _minContributionInWei;
        saleAddress = address(this);
    }

    function setDynamicCeilingAddress(address _dynamicCeilingAddress) public onlyOwner {
        dynamicCeiling = DynamicCeiling(_dynamicCeilingAddress);
    }

    function () 
        public 
        payable
        notPaused
        notClosed
        isValidated 
        amountValidated
        isApproved
    {
        uint256 contribution = msg.value;
        uint256 remaining = dynamicCeiling.availableAmountToCollect(totalEtherPaid);
        uint256 refund = 0;

        if (remaining == 0) {
            revert();
        }

        if (contribution > remaining) {
            contribution = remaining;
            refund = msg.value.sub(contribution);
        }
        doBuy(msg.sender, contribution);
        if (refund > 0) {
            msg.sender.transfer(refund);
        }
    }

    /// @notice Applies the discount based on the discount tiers
    /// @param _etherAmount The amount of ether used to evaluate the tier the contribution lies within
    /// @param _contributorTokens The tokens allocated based on the contribution
    function applyDiscount(uint256 _etherAmount, uint256 _contributorTokens) internal constant returns (uint256) {
        return _contributorTokens;
    }

    /// @notice Updates the counters for the amount of Ether paid
    /// @param _etherAmount the amount of Ether paid
    function updateCounters(uint256 _etherAmount) internal {
        totalEtherPaid = totalEtherPaid.add(_etherAmount);
    }

    /// @notice Public function enables closing of the crowdsale manually if necessary
    function closeSale() public onlyOwner {
        closed = true;
        SaleClosed(now);
    }
}
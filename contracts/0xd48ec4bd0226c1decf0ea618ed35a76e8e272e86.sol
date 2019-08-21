pragma solidity ^0.4.23;

// File: contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// File: contracts/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/Ownerable.sol

contract Ownerable {
    /// @notice The address of the owner is the only address that can call
    ///  a function with this modifier
    modifier onlyOwner { require(msg.sender == owner); _; }

    address public owner;

    constructor() public { owner = msg.sender;}

    /// @notice Changes the owner of the contract
    /// @param _newOwner The new owner of the contract
    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

// File: contracts/KYC.sol

/**
 * @title KYC
 * @dev KYC contract handles the white list for ASTCrowdsale contract
 * Only accounts registered in KYC contract can buy AST token.
 * Admins can register account, and the reason why
 */
contract KYC is Ownerable {
  // check the address is registered for token sale
  mapping (address => bool) public registeredAddress;

  // check the address is admin of kyc contract
  mapping (address => bool) public admin;

  event Registered(address indexed _addr);
  event Unregistered(address indexed _addr);
  event NewAdmin(address indexed _addr);
  event ClaimedTokens(address _token, address owner, uint256 balance);

  /**
   * @dev check whether the address is registered for token sale or not.
   * @param _addr address
   */
  modifier onlyRegistered(address _addr) {
    require(registeredAddress[_addr]);
    _;
  }

  /**
   * @dev check whether the msg.sender is admin or not
   */
  modifier onlyAdmin() {
    require(admin[msg.sender]);
    _;
  }

  constructor () public {
    admin[msg.sender] = true;
  }

  /**
   * @dev set new admin as admin of KYC contract
   * @param _addr address The address to set as admin of KYC contract
   */
  function setAdmin(address _addr)
    public
    onlyOwner
  {
    require(_addr != address(0) && admin[_addr] == false);
    admin[_addr] = true;

    emit NewAdmin(_addr);
  }

  /**
   * @dev register the address for token sale
   * @param _addr address The address to register for token sale
   */
  function register(address _addr)
    public
    onlyAdmin
  {
    require(_addr != address(0) && registeredAddress[_addr] == false);

    registeredAddress[_addr] = true;

    emit Registered(_addr);
  }

  /**
   * @dev register the addresses for token sale
   * @param _addrs address[] The addresses to register for token sale
   */
  function registerByList(address[] _addrs)
    public
    onlyAdmin
  {
    for(uint256 i = 0; i < _addrs.length; i++) {
      require(_addrs[i] != address(0) && registeredAddress[_addrs[i]] == false);

      registeredAddress[_addrs[i]] = true;

      emit Registered(_addrs[i]);
    }
  }

  /**
   * @dev unregister the registered address
   * @param _addr address The address to unregister for token sale
   */
  function unregister(address _addr)
    public
    onlyAdmin
    onlyRegistered(_addr)
  {
    registeredAddress[_addr] = false;

    emit Unregistered(_addr);
  }

  /**
   * @dev unregister the registered addresses
   * @param _addrs address[] The addresses to unregister for token sale
   */
  function unregisterByList(address[] _addrs)
    public
    onlyAdmin
  {
    for(uint256 i = 0; i < _addrs.length; i++) {
      require(registeredAddress[_addrs[i]]);

      registeredAddress[_addrs[i]] = false;

      emit Unregistered(_addrs[i]);
    }
  }

  function claimTokens(address _token) public onlyOwner {

    if (_token == 0x0) {
        owner.transfer( address(this).balance );
        return;
    }

    ERC20Basic token = ERC20Basic(_token);
    uint256 balance = token.balanceOf(this);
    token.transfer(owner, balance);

    emit ClaimedTokens(_token, owner, balance);
  }
}

// File: contracts/token/Controlled.sol

contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    constructor() public { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}

// File: contracts/token/TokenController.sol

/// @dev The token controller contract must implement these functions
contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) public payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);
}

// File: contracts/token/MiniMeToken.sol

/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MiniMeToken Contract
/// @author Jordi Baylina
/// @dev This token contract's goal is to make it easy for anyone to clone this
///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token
/// @dev It is ERC20 compliant, but still needs to under go further testing.



contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}

/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'MMT_0.2'; //An arbitrary versioning scheme


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
    ) public {
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
    function transfer(address _to, uint256 _amount) public returns (bool success) {
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
    ) public returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            require (allowed[_from][msg.sender] >= _amount);
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
           uint previousBalanceFrom = balanceOfAt(_from, block.number);
           require(previousBalanceFrom >= _amount);
           //if (previousBalanceFrom < _amount) {
           //    return false;
           //}

           // Alerts the token controller of the transfer
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           uint previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           emit Transfer(_from, _to, _amount);

           return true;
    }

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) public returns (bool success) {
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
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender
    ) public constant returns (uint256 remaining) {
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
    ) public returns (bool success) {
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
    function totalSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _blockNumber The block number when the balance is queried
    /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint _blockNumber) public constant
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
    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

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
        ) public returns(address) {
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
        emit NewCloneToken(address(cloneToken), _snapshotBlock);
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
    ) public onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        emit Transfer(0, _owner, _amount);
        return true;
    }

    /// @notice Burns `_amount` tokens from `_owner`
    /// @param _owner The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    /// @return True if the tokens are burned correctly
    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        emit Transfer(_owner, 0, _amount);
        return true;
    }

////////////////
// Enable tokens transfers
////////////////


    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed in the clone
    function enableTransfers(bool _transfersEnabled) public onlyController {
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
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    /// @notice The fallback function: If the contract's controller has not been
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function () public payable {
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
    function claimTokens(address _token) public onlyController {
        if (_token == 0x0) {
            controller.transfer( address(this).balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        emit ClaimedTokens(_token, controller, balance);
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
    ) public returns (MiniMeToken) {
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

// File: contracts/HEX.sol

contract HEX is MiniMeToken {
    mapping (address => bool) public blacklisted;
    bool public generateFinished;

    constructor (address _tokenFactory)
        MiniMeToken(
              _tokenFactory,
              0x0,                     // no parent token
              0,                       // no snapshot block number from parent
              "Health Evolution on X.blockchain",  // Token name
              18,                      // Decimals
              "HEX",                   // Symbol
              false                     // Enable transfers
          ) {
    }

    function generateTokens(address _holder, uint _amount) public onlyController returns (bool) {
        require(generateFinished == false);
        return super.generateTokens(_holder, _amount);
    }

    function doTransfer(address _from, address _to, uint _amount) internal returns(bool) {
        require(blacklisted[_from] == false);
        return super.doTransfer(_from, _to, _amount);
    }

    function finishGenerating() public onlyController returns (bool) {
        generateFinished = true;
        return true;
    }

    function blacklistAccount(address tokenOwner) public onlyController returns (bool success) {
        blacklisted[tokenOwner] = true;
        return true;
    }

    function unBlacklistAccount(address tokenOwner) public onlyController returns (bool success) {
        blacklisted[tokenOwner] = false;
        return true;
    }

//////////
// Safety Methods
//////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyController {
        if (_token == 0x0) {
            controller.transfer( address(this).balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(controller, balance);

        emit ClaimedTokens(_token, controller, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}

// File: contracts/atxinf/ATXICOToken.sol

contract ATXICOToken {
    function atxBuy(address _from, uint256 _amount) public returns(bool);
}

// File: contracts/HEXCrowdSale.sol

contract HEXCrowdSale is Ownerable, SafeMath, ATXICOToken {
  uint256 public maxHEXCap;
  uint256 public minHEXCap;

  uint256 public ethRate;
  uint256 public atxRate;
  /* uint256 public ethFunded;
  uint256 public atxFunded; */

  address[] public ethInvestors;
  mapping (address => uint256) public ethInvestorFunds;

  address[] public atxInvestors;
  mapping (address => uint256) public atxInvestorFunds;

  address[] public atxChangeAddrs;
  mapping (address => uint256) public atxChanges;

  KYC public kyc;
  HEX public hexToken;
  address public hexControllerAddr;
  ERC20Basic public atxToken;
  address public atxControllerAddr;
  //Vault public vault;

  address[] public memWallets;
  address[] public vaultWallets;

  struct Period {
    uint256 startTime;
    uint256 endTime;
    uint256 bonus; // used to calculate rate with bonus. ragne 0 ~ 15 (0% ~ 15%)
  }
  Period[] public periods;

  bool public isInitialized;
  bool public isFinalized;

  function init (
    address _kyc,
    address _token,
    address _hexController,
    address _atxToken,
    address _atxController,
    // address _vault,
    address[] _memWallets,
    address[] _vaultWallets,
    uint256 _ethRate,
    uint256 _atxRate,
    uint256 _maxHEXCap,
    uint256 _minHEXCap ) public onlyOwner {

      require(isInitialized == false);

      kyc = KYC(_kyc);
      hexToken = HEX(_token);
      hexControllerAddr = _hexController;
      atxToken = ERC20Basic(_atxToken);
      atxControllerAddr = _atxController;

      memWallets = _memWallets;
      vaultWallets = _vaultWallets;

      /* vault = Vault(_vault);
      vault.setFundTokenAddr(_atxToken); */

      ethRate = _ethRate;
      atxRate = _atxRate;

      maxHEXCap = _maxHEXCap;
      minHEXCap = _minHEXCap;

      isInitialized = true;
    }

    function () public payable {
      ethBuy();
    }

    function ethBuy() internal {
      // check validity
      require(msg.value >= 50e18); // minimum fund

      require(isInitialized);
      require(!isFinalized);

      require(msg.sender != 0x0 && msg.value != 0x0);
      require(kyc.registeredAddress(msg.sender));
      require(maxReached() == false);
      require(onSale());

      uint256 fundingAmt = msg.value;
      uint256 bonus = getPeriodBonus();
      uint256 currTotalSupply = hexToken.totalSupply();
      uint256 fundableHEXRoom = sub(maxHEXCap, currTotalSupply);
      uint256 reqedHex = eth2HexWithBonus(fundingAmt, bonus);
      uint256 toFund;
      uint256 reFund;

      if(reqedHex > fundableHEXRoom) {
        reqedHex = fundableHEXRoom;

        toFund = hex2EthWithBonus(reqedHex, bonus); //div(fundableHEXRoom, mul(ethRate, add(1, div(bonus,100))));
        reFund = sub(fundingAmt, toFund);

        // toFund 로 계산한 HEX 수량이 fundableHEXRoom 과 같아야 한다.
        // 그러나 소수점 문제로 인하여 정확히 같아지지 않을 경우가 발생한다.
        //require(reqedHex == eth2HexWithBonus(toFund, bonus) );

      } else {
        toFund = fundingAmt;
        reFund = 0;
      }

      require(fundingAmt >= toFund);
      require(toFund > 0);

      // pushInvestorList
      if(ethInvestorFunds[msg.sender] == 0x0) {
        ethInvestors.push(msg.sender);
      }
      ethInvestorFunds[msg.sender] = add(ethInvestorFunds[msg.sender], toFund);

      /* ethFunded = add(ethFunded, toFund); */

      hexToken.generateTokens(msg.sender, reqedHex);

      if(reFund > 0) {
        msg.sender.transfer(reFund);
      }

      //vault.ethDeposit.value(toFund)(msg.sender);

      emit SaleToken(msg.sender, msg.sender, 0, toFund, reqedHex);
    }

    //
    // ATXICOToken 메소드 구현.
    // 외부에서 이 함수가 바로 호출되면 코인 생성됨.
    // 반드시 ATXController 에서만 호출 허용 할 것.
    //
    function atxBuy(address _from, uint256 _amount) public returns(bool) {
      // check validity
      require(_amount >= 250000e18); // minimum fund

      require(isInitialized);
      require(!isFinalized);

      require(_from != 0x0 && _amount != 0x0);
      require(kyc.registeredAddress(_from));
      require(maxReached() == false);
      require(onSale());

      // Only from ATX Controller.
      require(msg.sender == atxControllerAddr);

      // 수신자(현재컨트랙트) atx 수신후 잔액 오버플로우 확인.
      uint256 currAtxBal = atxToken.balanceOf( address(this) );
      require(currAtxBal + _amount >= currAtxBal); // Check for overflow

      uint256 fundingAmt = _amount;
      uint256 bonus = getPeriodBonus();
      uint256 currTotalSupply = hexToken.totalSupply();
      uint256 fundableHEXRoom = sub(maxHEXCap, currTotalSupply);
      uint256 reqedHex = atx2HexWithBonus(fundingAmt, bonus); //mul(add(fundingAmt, mul(fundingAmt, div(bonus, 100))), atxRate);
      uint256 toFund;
      uint256 reFund;

      if(reqedHex > fundableHEXRoom) {
        reqedHex = fundableHEXRoom;

        toFund = hex2AtxWithBonus(reqedHex, bonus); //div(fundableHEXRoom, mul(atxRate, add(1, div(bonus,100))));
        reFund = sub(fundingAmt, toFund);

        // toFund 로 계산한 HEX 수량이 fundableHEXRoom 과 같아야 한다.
        // 그러나 소수점 문제로 인하여 정확히 같아지지 않을 경우가 발생한다.
        //require(reqedHex == atx2HexWithBonus(toFund, bonus) );

      } else {
        toFund = fundingAmt;
        reFund = 0;
      }

      require(fundingAmt >= toFund);
      require(toFund > 0);


      // pushInvestorList
      if(atxInvestorFunds[_from] == 0x0) {
        atxInvestors.push(_from);
      }
      atxInvestorFunds[_from] = add(atxInvestorFunds[_from], toFund);

      /* atxFunded = add(atxFunded, toFund); */

      hexToken.generateTokens(_from, reqedHex);

      // 현재 시점에서
      // HEXCrowdSale 이 수신한 ATX 는
      // 아직 HEXCrowdSale 계정의 잔액에 반영되지 않았다....
      // _amount 는 아직 this 의 잔액에 반영되지 않았기때문에,
      // 이것을 vault 로 전송할 수도 없고,
      // 잔액을 되돌릴 수도 없다.
      if(reFund > 0) {
        //atxToken.transfer(_from, reFund);
        if(atxChanges[_from] == 0x0) {
          atxChangeAddrs.push(_from);
        }
        atxChanges[_from] = add(atxChanges[_from], reFund);
      }

      // 현재 시점에서
      // HEXCrowdSale 이 수신한 ATX 는
      // 아직 HEXCrowdSale 계정의 잔액에 반영되지 않았다....
      // 그래서 vault 로 전송할 수가 없다.
      //if( atxToken.transfer( address(vault), toFund) ) {
        //vault.atxDeposit(_from, toFund);
      //}

      emit SaleToken(msg.sender, _from, 1, toFund, reqedHex);

      return true;
    }

    function finish() public onlyOwner {
      require(!isFinalized);

      returnATXChanges();

      if(minReached()) {

        //vault.close();
        require(vaultWallets.length == 31);
        uint eachATX = div(atxToken.balanceOf(address(this)), vaultWallets.length);
        for(uint idx = 0; idx < vaultWallets.length; idx++) {
          // atx
          atxToken.transfer(vaultWallets[idx], eachATX);
        }
        // atx remained
        if(atxToken.balanceOf(address(this)) > 0) {
          atxToken.transfer(vaultWallets[vaultWallets.length - 1], atxToken.balanceOf(address(this)));
        }
        // ether
        //if(address(this).balance > 0) {
          vaultWallets[vaultWallets.length - 1].transfer( address(this).balance );
        //}

        require(memWallets.length == 6);
        hexToken.generateTokens(memWallets[0], 14e26); // airdrop
        hexToken.generateTokens(memWallets[1], 84e25); // team locker
        hexToken.generateTokens(memWallets[2], 84e25); // advisors locker
        hexToken.generateTokens(memWallets[3], 80e25); // healthdata mining
        hexToken.generateTokens(memWallets[4], 92e25); // marketing
        hexToken.generateTokens(memWallets[5], 80e25); // reserved

        //hexToken.enableTransfers(true);

      } else {
        //vault.enableRefunds();
      }

      hexToken.finishGenerating();
      hexToken.changeController(hexControllerAddr);

      isFinalized = true;

      emit SaleFinished();
    }

    function maxReached() public view returns (bool) {
      return (hexToken.totalSupply() >= maxHEXCap);
    }

    function minReached() public view returns (bool) {
      return (hexToken.totalSupply() >= minHEXCap);
    }

    function addPeriod(uint256 _start, uint256 _end) public onlyOwner {
      require(now < _start && _start < _end);
      if (periods.length != 0) {
        //require(sub(_endTime, _startTime) <= 7 days);
        require(periods[periods.length - 1].endTime < _start);
      }
      Period memory newPeriod;
      newPeriod.startTime = _start;
      newPeriod.endTime = _end;
      newPeriod.bonus = 0;
      if(periods.length == 0) {
        newPeriod.bonus = 50; // Private
      }
      else if(periods.length == 1) {
        newPeriod.bonus = 30; // pre
      }
      else if(periods.length == 2) {
        newPeriod.bonus = 20; // crowd 1
      }
      else if (periods.length == 3) {
        newPeriod.bonus = 15; // crowd 2
      }
      else if (periods.length == 4) {
        newPeriod.bonus = 10; // crowd 3
      }
      else if (periods.length == 5) {
        newPeriod.bonus = 5; // crowd 4
      }

      periods.push(newPeriod);
    }

    function getPeriodBonus() public view returns (uint256) {
      bool nowOnSale;
      uint256 currentPeriod;

      for (uint i = 0; i < periods.length; i++) {
        if (periods[i].startTime <= now && now <= periods[i].endTime) {
          nowOnSale = true;
          currentPeriod = i;
          break;
        }
      }

      require(nowOnSale);
      return periods[currentPeriod].bonus;
    }

    function eth2HexWithBonus(uint256 _eth, uint256 bonus) public view returns(uint256) {
      uint basic = mul(_eth, ethRate);
      return div(mul(basic, add(bonus, 100)), 100);
      //return add(basic, div(mul(basic, bonus), 100));
    }

    function hex2EthWithBonus(uint256 _hex, uint256 bonus) public view returns(uint256)  {
      return div(mul(_hex, 100), mul(ethRate, add(100, bonus)));
      //return div(_hex, mul(ethRate, add(1, div(bonus,100))));
    }

    function atx2HexWithBonus(uint256 _atx, uint256 bonus) public view returns(uint256)  {
      uint basic = mul(_atx, atxRate);
      return div(mul(basic, add(bonus, 100)), 100);
      //return add(basic, div(mul(basic, bonus), 100));
    }

    function hex2AtxWithBonus(uint256 _hex, uint256 bonus) public view returns(uint256)  {
      return div(mul(_hex, 100), mul(atxRate, add(100, bonus)));
      //return div(_hex, mul(atxRate, add(1, div(bonus,100))));
    }

    function onSale() public view returns (bool) {
      bool nowOnSale;

      // Except Private Sale...
      for (uint i = 1; i < periods.length; i++) {
        if (periods[i].startTime <= now && now <= periods[i].endTime) {
          nowOnSale = true;
          break;
        }
      }

      return nowOnSale;
    }

    function atxChangeAddrCount() public view returns(uint256) {
      return atxChangeAddrs.length;
    }

    function returnATXChanges() public onlyOwner {
      //require(atxChangeAddrs.length > 0);

      for(uint256 i=0; i<atxChangeAddrs.length; i++) {
        if(atxChanges[atxChangeAddrs[i]] > 0) {
            if( atxToken.transfer(atxChangeAddrs[i], atxChanges[atxChangeAddrs[i]]) ) {
              atxChanges[atxChangeAddrs[i]] = 0x0;
            }
        }
      }
    }

    //
    // Safety Methods
    function claimTokens(address _claimToken) public onlyOwner {

      if (hexToken.controller() == address(this)) {
           hexToken.claimTokens(_claimToken);
      }

      if (_claimToken == 0x0) {
          owner.transfer(address(this).balance);
          return;
      }

      ERC20Basic claimToken = ERC20Basic(_claimToken);
      uint256 balance = claimToken.balanceOf( address(this) );
      claimToken.transfer(owner, balance);

      emit ClaimedTokens(_claimToken, owner, balance);
    }

    //
    // Event

    event SaleToken(address indexed _sender, address indexed _investor, uint256 indexed _fundType, uint256 _toFund, uint256 _hexTokens);
    event ClaimedTokens(address indexed _claimToken, address indexed owner, uint256 balance);
    event SaleFinished();
  }
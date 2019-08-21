pragma solidity ^0.4.18;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
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
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }
  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }
  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}
/**
 * @title KYC
 * @dev KYC contract handles the white list for ASTCrowdsale contract
 * Only accounts registered in KYC contract can buy AST token.
 * Admins can register account, and the reason why
 */
contract KYC is Ownable {
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
  function KYC() {
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
    NewAdmin(_addr);
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
    Registered(_addr);
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
      Registered(_addrs[i]);
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
    Unregistered(_addr);
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
      Unregistered(_addrs[i]);
    }
  }
  function claimTokens(address _token) public onlyOwner {
    if (_token == 0x0) {
        owner.transfer(this.balance);
        return;
    }
    ERC20Basic token = ERC20Basic(_token);
    uint256 balance = token.balanceOf(this);
    token.transfer(owner, balance);
    ClaimedTokens(_token, owner, balance);
  }
}
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
contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }
    address public controller;
    function Controlled() public { controller = msg.sender;}
    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}
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
        Approval(msg.sender, _spender, _amount);
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
    ) public onlyController returns (bool) {
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
    ) onlyController public returns (bool) {
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
contract ATC is MiniMeToken {
  mapping (address => bool) public blacklisted;
  bool public generateFinished;
  // @dev ATC constructor just parametrizes the MiniMeToken constructor
  function ATC(address _tokenFactory)
          MiniMeToken(
              _tokenFactory,
              0x0,                     // no parent token
              0,                       // no snapshot block number from parent
              "Aston Token",  // Token name
              18,                      // Decimals
              "ATC",                   // Symbol
              false                     // Enable transfers
          ) {}
  function generateTokens(address _owner, uint _amount
      ) public onlyController returns (bool) {
        require(generateFinished == false);
        //check msg.sender (controller ??)
        return super.generateTokens(_owner, _amount);
      }
  function doTransfer(address _from, address _to, uint _amount
      ) internal returns(bool) {
        require(blacklisted[_from] == false);
        return super.doTransfer(_from, _to, _amount);
      }
  function finishGenerating() public onlyController returns (bool success) {
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
}
/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable, SafeMath{
  enum State { Active, Refunding, Closed }
  mapping (address => uint256) public deposited;
  mapping (address => uint256) public refunded;
  State public state;
  address[] public reserveWallet;
  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);
  /**
   * @dev This constructor sets the addresses of
   * 10 reserve wallets.
   * and forwarding it if crowdsale is successful.
   * @param _reserveWallet address[5] The addresses of reserve wallet.
   */
  function RefundVault(address[] _reserveWallet) {
    state = State.Active;
    reserveWallet = _reserveWallet;
  }
  /**
   * @dev This function is called when user buy tokens. Only RefundVault
   * contract stores the Ether user sent which forwarded from crowdsale
   * contract.
   * @param investor address The address who buy the token from crowdsale.
   */
  function deposit(address investor) onlyOwner payable {
    require(state == State.Active);
    deposited[investor] = add(deposited[investor], msg.value);
  }
  event Transferred(address _to, uint _value);
  /**
   * @dev This function is called when crowdsale is successfully finalized.
   */
  function close() onlyOwner {
    require(state == State.Active);
    state = State.Closed;
    uint256 balance = this.balance;
    uint256 reserveAmountForEach = div(balance, reserveWallet.length);
    for(uint8 i = 0; i < reserveWallet.length; i++){
      reserveWallet[i].transfer(reserveAmountForEach);
      Transferred(reserveWallet[i], reserveAmountForEach);
    }
    Closed();
  }
  /**
   * @dev This function is called when crowdsale is unsuccessfully finalized
   * and refund is required.
   */
  function enableRefunds() onlyOwner {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }
  /**
   * @dev This function allows for user to refund Ether.
   */
  function refund(address investor) returns (bool) {
    require(state == State.Refunding);
    if (refunded[investor] > 0) {
      return false;
    }
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    refunded[investor] = depositedValue;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
    return true;
  }
}
/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;
  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }
  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }
  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
}
contract ATCCrowdSale is Ownable, SafeMath, Pausable {
  KYC public kyc;
  ATC public token;
  RefundVault public vault;
  address public presale;
  address public bountyAddress; //5% for bounty
  address public partnersAddress; //15% for community groups & partners
  address public ATCReserveLocker; //15% with 2 years lock
  address public teamLocker; // 15% with 2 years vesting
  struct Period {
    uint256 startTime;
    uint256 endTime;
    uint256 bonus; // used to calculate rate with bonus. ragne 0 ~ 15 (0% ~ 15%)
  }
  uint256 public baseRate; // 1 ETH = 1500 ATC
  uint256[] public additionalBonusAmounts;
  Period[] public periods;
  uint8 constant public MAX_PERIOD_COUNT = 8;
  uint256 public weiRaised;
  uint256 public maxEtherCap;
  uint256 public minEtherCap;
  mapping (address => uint256) public beneficiaryFunded;
  address[] investorList;
  mapping (address => bool) inInvestorList;
  address public ATCController;
  bool public isFinalized;
  uint256 public refundCompleted;
  bool public presaleFallBackCalled;
  uint256 public finalizedTime;
  bool public initialized;
  event CrowdSaleTokenPurchase(address indexed _investor, address indexed _beneficiary, uint256 _toFund, uint256 _tokens);
  event StartPeriod(uint256 _startTime, uint256 _endTime, uint256 _bonus);
  event Finalized();
  event PresaleFallBack(uint256 _presaleWeiRaised);
  event PushInvestorList(address _investor);
  event RefundAll(uint256 _numToRefund);
  event ClaimedTokens(address _claimToken, address owner, uint256 balance);
  event Initialize();
  function initialize (
    address _kyc,
    address _token,
    address _vault,
    address _presale,
    address _bountyAddress,
    address _partnersAddress,
    address _ATCReserveLocker,
    address _teamLocker,
    address _tokenController,
    uint256 _maxEtherCap,
    uint256 _minEtherCap,
    uint256 _baseRate,
    uint256[] _additionalBonusAmounts
    ) onlyOwner {
      require(!initialized);
      require(_kyc != 0x00 && _token != 0x00 && _vault != 0x00 && _presale != 0x00);
      require(_bountyAddress != 0x00 && _partnersAddress != 0x00);
      require(_ATCReserveLocker != 0x00 && _teamLocker != 0x00);
      require(_tokenController != 0x00);
      require(0 < _minEtherCap && _minEtherCap < _maxEtherCap);
      require(_baseRate > 0);
      require(_additionalBonusAmounts[0] > 0);
      for (uint i = 0; i < _additionalBonusAmounts.length - 1; i++) {
        require(_additionalBonusAmounts[i] < _additionalBonusAmounts[i + 1]);
      }
      kyc = KYC(_kyc);
      token = ATC(_token);
      vault = RefundVault(_vault);
      presale = _presale;
      bountyAddress = _bountyAddress;
      partnersAddress = _partnersAddress;
      ATCReserveLocker = _ATCReserveLocker;
      teamLocker = _teamLocker;
      ATCController = _tokenController;
      maxEtherCap = _maxEtherCap;
      minEtherCap = _minEtherCap;
      baseRate = _baseRate;
      additionalBonusAmounts = _additionalBonusAmounts;
      initialized = true;
      Initialize();
    }
  function () public payable {
    buy(msg.sender);
  }
  function presaleFallBack(uint256 _presaleWeiRaised) public returns (bool) {
    require(!presaleFallBackCalled);
    require(msg.sender == presale);
    weiRaised = _presaleWeiRaised;
    presaleFallBackCalled = true;
    PresaleFallBack(_presaleWeiRaised);
    return true;
  }
  function buy(address beneficiary)
    public
    payable
    whenNotPaused
  {
      // check validity
      require(presaleFallBackCalled);
      require(beneficiary != 0x00);
      require(kyc.registeredAddress(beneficiary));
      require(onSale());
      require(validPurchase());
      require(!isFinalized);
      // calculate eth amount
      uint256 weiAmount = msg.value;
      uint256 toFund;
      uint256 postWeiRaised = add(weiRaised, weiAmount);
      if (postWeiRaised > maxEtherCap) {
        toFund = sub(maxEtherCap, weiRaised);
      } else {
        toFund = weiAmount;
      }
      require(toFund > 0);
      require(weiAmount >= toFund);
      uint256 rate = calculateRate(toFund);
      uint256 tokens = mul(toFund, rate);
      uint256 toReturn = sub(weiAmount, toFund);
      pushInvestorList(msg.sender);
      weiRaised = add(weiRaised, toFund);
      beneficiaryFunded[beneficiary] = add(beneficiaryFunded[beneficiary], toFund);
      token.generateTokens(beneficiary, tokens);
      if (toReturn > 0) {
        msg.sender.transfer(toReturn);
      }
      forwardFunds(toFund);
      CrowdSaleTokenPurchase(msg.sender, beneficiary, toFund, tokens);
  }
  function pushInvestorList(address investor) internal {
    if (!inInvestorList[investor]) {
      inInvestorList[investor] = true;
      investorList.push(investor);
      PushInvestorList(investor);
    }
  }
  function validPurchase() internal view returns (bool) {
    bool nonZeroPurchase = msg.value != 0;
    return nonZeroPurchase && !maxReached();
  }
  function forwardFunds(uint256 toFund) internal {
    vault.deposit.value(toFund)(msg.sender);
  }
  /**
   * @dev Checks whether minEtherCap is reached
   * @return true if min ether cap is reaced
   */
  function minReached() public view returns (bool) {
    return weiRaised >= minEtherCap;
  }
  /**
   * @dev Checks whether maxEtherCap is reached
   * @return true if max ether cap is reaced
   */
  function maxReached() public view returns (bool) {
    return weiRaised == maxEtherCap;
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
  /**
   * @dev rate = baseRate * (100 + bonus) / 100
   */
  function calculateRate(uint256 toFund) public view returns (uint256)  {
    uint bonus = getPeriodBonus();
    // bonus for eth amount
    if (additionalBonusAmounts[0] <= toFund) {
      bonus = add(bonus, 5); // 5% amount bonus for more than 300 ETH
    }
    if (additionalBonusAmounts[1] <= toFund) {
      bonus = add(bonus, 5); // 10% amount bonus for more than 6000 ETH
    }
    if (additionalBonusAmounts[2] <= toFund) {
      bonus = 25; // final 25% amount bonus for more than 8000 ETH
    }
    if (additionalBonusAmounts[3] <= toFund) {
      bonus = 30; // final 30% amount bonus for more than 10000 ETH
    }
    return div(mul(baseRate, add(bonus, 100)), 100);
  }
  function startPeriod(uint256 _startTime, uint256 _endTime) public onlyOwner returns (bool) {
    require(periods.length < MAX_PERIOD_COUNT);
    require(now < _startTime && _startTime < _endTime);
    if (periods.length != 0) {
      require(sub(_endTime, _startTime) <= 7 days);
      require(periods[periods.length - 1].endTime < _startTime);
    }
    // 15% -> 10% -> 5% -> 0%
    Period memory newPeriod;
    newPeriod.startTime = _startTime;
    newPeriod.endTime = _endTime;
    if(periods.length < 3) {
      newPeriod.bonus = sub(15, mul(5, periods.length));
    } else {
      newPeriod.bonus = 0;
    }
    periods.push(newPeriod);
    StartPeriod(_startTime, _endTime, newPeriod.bonus);
    return true;
  }
  function onSale() public returns (bool) {
    bool nowOnSale;
    for (uint i = 0; i < periods.length; i++) {
      if (periods[i].startTime <= now && now <= periods[i].endTime) {
        nowOnSale = true;
        break;
      }
    }
    return nowOnSale;
  }
  /**
   * @dev should be called after crowdsale ends, to do
   */
  function finalize() onlyOwner {
    require(!isFinalized);
    require(!onSale() || maxReached());
    finalizedTime = now;
    finalization();
    Finalized();
    isFinalized = true;
  }
  /**
   * @dev end token minting on finalization, mint tokens for dev team and reserve wallets
   */
  function finalization() internal {
    if (minReached()) {
      vault.close();
      uint256 totalToken = token.totalSupply();
      // token distribution : 50% for sale, 5% for bounty, 15% for partners, 15% for reserve, 15% for team
      uint256 bountyAmount = div(mul(totalToken, 5), 50);
      uint256 partnersAmount = div(mul(totalToken, 15), 50);
      uint256 reserveAmount = div(mul(totalToken, 15), 50);
      uint256 teamAmount = div(mul(totalToken, 15), 50);
      distributeToken(bountyAmount, partnersAmount, reserveAmount, teamAmount);
      token.enableTransfers(true);
    } else {
      vault.enableRefunds();
    }
    token.finishGenerating();
    token.changeController(ATCController);
  }
  function distributeToken(uint256 bountyAmount, uint256 partnersAmount, uint256 reserveAmount, uint256 teamAmount) internal {
    require(bountyAddress != 0x00 && partnersAddress != 0x00);
    require(ATCReserveLocker != 0x00 && teamLocker != 0x00);
    token.generateTokens(bountyAddress, bountyAmount);
    token.generateTokens(partnersAddress, partnersAmount);
    token.generateTokens(ATCReserveLocker, reserveAmount);
    token.generateTokens(teamLocker, teamAmount);
  }
  /**
   * @dev refund a lot of investors at a time checking onlyOwner
   * @param numToRefund uint256 The number of investors to refund
   */
  function refundAll(uint256 numToRefund) onlyOwner {
    require(isFinalized);
    require(!minReached());
    require(numToRefund > 0);
    uint256 limit = refundCompleted + numToRefund;
    if (limit > investorList.length) {
      limit = investorList.length;
    }
    for(uint256 i = refundCompleted; i < limit; i++) {
      vault.refund(investorList[i]);
    }
    refundCompleted = limit;
    RefundAll(numToRefund);
  }
  /**
   * @dev if crowdsale is unsuccessful, investors can claim refunds here
   * @param investor address The account to be refunded
   */
  function claimRefund(address investor) returns (bool) {
    require(isFinalized);
    require(!minReached());
    return vault.refund(investor);
  }
  function claimTokens(address _claimToken) public onlyOwner {
    if (token.controller() == address(this)) {
         token.claimTokens(_claimToken);
    }
    if (_claimToken == 0x0) {
        owner.transfer(this.balance);
        return;
    }
    ERC20Basic claimToken = ERC20Basic(_claimToken);
    uint256 balance = claimToken.balanceOf(this);
    claimToken.transfer(owner, balance);
    ClaimedTokens(_claimToken, owner, balance);
  }
}
/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract ReserveLocker is SafeMath{
  using SafeERC20 for ERC20Basic;
  ERC20Basic public token;
  ATCCrowdSale public crowdsale;
  address public beneficiary;
  function ReserveLocker(address _token, address _crowdsale, address _beneficiary) {
    require(_token != 0x00);
    require(_crowdsale != 0x00);
    require(_beneficiary != 0x00);
    token = ERC20Basic(_token);
    crowdsale = ATCCrowdSale(_crowdsale);
    beneficiary = _beneficiary;
  }
  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
   function release() public {
     uint256 finalizedTime = crowdsale.finalizedTime();
     require(finalizedTime > 0 && now > add(finalizedTime, 2 years));
     uint256 amount = token.balanceOf(this);
     require(amount > 0);
     token.safeTransfer(beneficiary, amount);
   }
  function setToken(address newToken) public {
    require(msg.sender == beneficiary);
    require(newToken != 0x00);
    token = ERC20Basic(newToken);
  }
}
/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TeamLocker is SafeMath{
  using SafeERC20 for ERC20Basic;
  ERC20Basic public token;
  ATCCrowdSale public crowdsale;
  address[] public beneficiaries;
  uint256 public collectedTokens;
  function TeamLocker(address _token, address _crowdsale, address[] _beneficiaries) {
    require(_token != 0x00);
    require(_crowdsale != 0x00);
    for (uint i = 0; i < _beneficiaries.length; i++) {
      require(_beneficiaries[i] != 0x00);
    }
    token = ERC20Basic(_token);
    crowdsale = ATCCrowdSale(_crowdsale);
    beneficiaries = _beneficiaries;
  }
  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    uint256 balance = token.balanceOf(address(this));
    uint256 total = add(balance, collectedTokens);
    uint256 finalizedTime = crowdsale.finalizedTime();
    require(finalizedTime > 0);
    uint256 lockTime1 = add(finalizedTime, 183 days); // 6 months
    uint256 lockTime2 = add(finalizedTime, 1 years); // 1 year
    uint256 currentRatio = 20;
    if (now >= lockTime1) {
      currentRatio = 50;
    }
    if (now >= lockTime2) {
      currentRatio = 100;
    }
    uint256 releasedAmount = div(mul(total, currentRatio), 100);
    uint256 grantAmount = sub(releasedAmount, collectedTokens);
    require(grantAmount > 0);
    collectedTokens = add(collectedTokens, grantAmount);
    uint256 grantAmountForEach = div(grantAmount, 3);
    for (uint i = 0; i < beneficiaries.length; i++) {
        token.safeTransfer(beneficiaries[i], grantAmountForEach);
    }
  }
  function setToken(address newToken) public {
    require(newToken != 0x00);
    bool isBeneficiary;
    for (uint i = 0; i < beneficiaries.length; i++) {
      if (msg.sender == beneficiaries[i]) {
        isBeneficiary = true;
      }
    }
    require(isBeneficiary);
    token = ERC20Basic(newToken);
  }
}
contract ATCCrowdSale2 is Ownable, SafeMath, Pausable {
  KYC public kyc;
  ATC public token;
  RefundVault public vault;
  address public bountyAddress; //5% for bounty
  address public partnersAddress; //15% for community groups & partners
  address public ATCReserveLocker; //15% with 2 years lock
  address public teamLocker; // 15% with 2 years vesting
  struct Period {
    uint256 startTime;
    uint256 endTime;
    uint256 bonus; // used to calculate rate with bonus. ragne 0 ~ 15 (0% ~ 15%)
  }
  uint256 public baseRate; // 1 ETH = 1500 ATC
  uint256[] public additionalBonusAmounts;
  Period[] public periods;
  uint8 constant public MAX_PERIOD_COUNT = 8;
  uint256 public weiRaised;
  uint256 public maxEtherCap;
  uint256 public minEtherCap;
  mapping (address => uint256) public beneficiaryFunded;
  address[] investorList;
  mapping (address => bool) inInvestorList;
  address public ATCController;
  bool public isFinalized;
  uint256 public refundCompleted;
  uint256 public finalizedTime;
  bool public initialized;
  event CrowdSaleTokenPurchase(address indexed _investor, address indexed _beneficiary, uint256 _toFund, uint256 _tokens);
  event StartPeriod(uint256 _startTime, uint256 _endTime, uint256 _bonus);
  event Finalized();
  event PushInvestorList(address _investor);
  event RefundAll(uint256 _numToRefund);
  event ClaimedTokens(address _claimToken, address owner, uint256 balance);
  event Initialize();
  function initialize (
    address _kyc,
    address _token,
    address _vault,
    address _bountyAddress,
    address _partnersAddress,
    address _ATCReserveLocker,
    address _teamLocker,
    address _tokenController,
    uint256 _maxEtherCap,
    uint256 _minEtherCap,
    uint256 _baseRate,
    uint256[] _additionalBonusAmounts
    ) onlyOwner {
      require(!initialized);
      require(_kyc != 0x00 && _token != 0x00 && _vault != 0x00);
      require(_bountyAddress != 0x00 && _partnersAddress != 0x00);
      require(_ATCReserveLocker != 0x00 && _teamLocker != 0x00);
      require(_tokenController != 0x00);
      require(0 < _minEtherCap && _minEtherCap < _maxEtherCap);
      require(_baseRate > 0);
      require(_additionalBonusAmounts[0] > 0);
      for (uint i = 0; i < _additionalBonusAmounts.length - 1; i++) {
        require(_additionalBonusAmounts[i] < _additionalBonusAmounts[i + 1]);
      }
      kyc = KYC(_kyc);
      token = ATC(_token);
      vault = RefundVault(_vault);
      bountyAddress = _bountyAddress;
      partnersAddress = _partnersAddress;
      ATCReserveLocker = _ATCReserveLocker;
      teamLocker = _teamLocker;
      ATCController = _tokenController;
      maxEtherCap = _maxEtherCap;
      minEtherCap = _minEtherCap;
      baseRate = _baseRate;
      additionalBonusAmounts = _additionalBonusAmounts;
      initialized = true;
      Initialize();
    }
  function () public payable {
    buy(msg.sender);
  }
  function buy(address beneficiary)
    public
    payable
    whenNotPaused
  {
      // check validity
      require(beneficiary != 0x00);
      require(kyc.registeredAddress(beneficiary));
      require(onSale());
      require(validPurchase());
      require(!isFinalized);
      // calculate eth amount
      uint256 weiAmount = msg.value;
      uint256 toFund;
      uint256 postWeiRaised = add(weiRaised, weiAmount);
      if (postWeiRaised > maxEtherCap) {
        toFund = sub(maxEtherCap, weiRaised);
      } else {
        toFund = weiAmount;
      }
      require(toFund > 0);
      require(weiAmount >= toFund);
      uint256 rate = calculateRate(toFund);
      uint256 tokens = mul(toFund, rate);
      uint256 toReturn = sub(weiAmount, toFund);
      pushInvestorList(msg.sender);
      weiRaised = add(weiRaised, toFund);
      beneficiaryFunded[beneficiary] = add(beneficiaryFunded[beneficiary], toFund);
      token.generateTokens(beneficiary, tokens);
      if (toReturn > 0) {
        msg.sender.transfer(toReturn);
      }
      forwardFunds(toFund);
      CrowdSaleTokenPurchase(msg.sender, beneficiary, toFund, tokens);
  }
  function pushInvestorList(address investor) internal {
    if (!inInvestorList[investor]) {
      inInvestorList[investor] = true;
      investorList.push(investor);
      PushInvestorList(investor);
    }
  }
  function validPurchase() internal view returns (bool) {
    bool nonZeroPurchase = msg.value != 0;
    return nonZeroPurchase && !maxReached();
  }
  function forwardFunds(uint256 toFund) internal {
    vault.deposit.value(toFund)(msg.sender);
  }
  /**
   * @dev Checks whether minEtherCap is reached
   * @return true if min ether cap is reaced
   */
  function minReached() public view returns (bool) {
    return weiRaised >= minEtherCap;
  }
  /**
   * @dev Checks whether maxEtherCap is reached
   * @return true if max ether cap is reaced
   */
  function maxReached() public view returns (bool) {
    return weiRaised == maxEtherCap;
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
  /**
   * @dev rate = baseRate * (100 + bonus) / 100
   */
  function calculateRate(uint256 toFund) public view returns (uint256)  {
    uint bonus = getPeriodBonus();
    // bonus for eth amount
    if (additionalBonusAmounts[0] <= toFund) {
      bonus = add(bonus, 5); // 5% amount bonus for more than 300 ETH
    }
    if (additionalBonusAmounts[1] <= toFund) {
      bonus = add(bonus, 5); // 10% amount bonus for more than 6000 ETH
    }
    if (additionalBonusAmounts[2] <= toFund) {
      bonus = 25; // final 25% amount bonus for more than 8000 ETH
    }
    if (additionalBonusAmounts[3] <= toFund) {
      bonus = 30; // final 30% amount bonus for more than 10000 ETH
    }
    return div(mul(baseRate, add(bonus, 100)), 100);
  }
  function startPeriod(uint256 _startTime, uint256 _endTime) public onlyOwner returns (bool) {
    require(periods.length < MAX_PERIOD_COUNT);
    require(now < _startTime && _startTime < _endTime);
    if (periods.length != 0) {
      require(sub(_endTime, _startTime) <= 7 days);
      require(periods[periods.length - 1].endTime < _startTime);
    }
    // 15% -> 10% -> 5% -> 0%
    Period memory newPeriod;
    newPeriod.startTime = _startTime;
    newPeriod.endTime = _endTime;
    if(periods.length < 3) {
      newPeriod.bonus = sub(15, mul(5, periods.length));
    } else {
      newPeriod.bonus = 0;
    }
    periods.push(newPeriod);
    StartPeriod(_startTime, _endTime, newPeriod.bonus);
    return true;
  }
  function onSale() public returns (bool) {
    bool nowOnSale;
    for (uint i = 0; i < periods.length; i++) {
      if (periods[i].startTime <= now && now <= periods[i].endTime) {
        nowOnSale = true;
        break;
      }
    }
    return nowOnSale;
  }
  /**
   * @dev should be called after crowdsale ends, to do
   */
  function finalize() onlyOwner {
    require(!isFinalized);
    require(!onSale() || maxReached());
    finalizedTime = now;
    finalization();
    Finalized();
    isFinalized = true;
  }
  /**
   * @dev end token minting on finalization, mint tokens for dev team and reserve wallets
   */
  function finalization() internal {
    if (minReached()) {
      vault.close();
      uint256 totalToken = token.totalSupply();
      // token distribution : 50% for sale, 5% for bounty, 15% for partners, 15% for reserve, 15% for team
      uint256 bountyAmount = div(mul(totalToken, 5), 50);
      uint256 partnersAmount = div(mul(totalToken, 15), 50);
      uint256 reserveAmount = div(mul(totalToken, 15), 50);
      uint256 teamAmount = div(mul(totalToken, 15), 50);
      distributeToken(bountyAmount, partnersAmount, reserveAmount, teamAmount);
      token.enableTransfers(true);
    } else {
      vault.enableRefunds();
    }
    token.finishGenerating();
    token.changeController(ATCController);
  }
  function distributeToken(uint256 bountyAmount, uint256 partnersAmount, uint256 reserveAmount, uint256 teamAmount) internal {
    require(bountyAddress != 0x00 && partnersAddress != 0x00);
    require(ATCReserveLocker != 0x00 && teamLocker != 0x00);
    token.generateTokens(bountyAddress, bountyAmount);
    token.generateTokens(partnersAddress, partnersAmount);
    token.generateTokens(ATCReserveLocker, reserveAmount);
    token.generateTokens(teamLocker, teamAmount);
  }
  /**
   * @dev refund a lot of investors at a time checking onlyOwner
   * @param numToRefund uint256 The number of investors to refund
   */
  function refundAll(uint256 numToRefund) onlyOwner {
    require(isFinalized);
    require(!minReached());
    require(numToRefund > 0);
    uint256 limit = refundCompleted + numToRefund;
    if (limit > investorList.length) {
      limit = investorList.length;
    }
    for(uint256 i = refundCompleted; i < limit; i++) {
      vault.refund(investorList[i]);
    }
    refundCompleted = limit;
    RefundAll(numToRefund);
  }
  /**
   * @dev if crowdsale is unsuccessful, investors can claim refunds here
   * @param investor address The account to be refunded
   */
  function claimRefund(address investor) returns (bool) {
    require(isFinalized);
    require(!minReached());
    return vault.refund(investor);
  }
  function claimTokens(address _claimToken) public onlyOwner {
    if (token.controller() == address(this)) {
         token.claimTokens(_claimToken);
    }
    if (_claimToken == 0x0) {
        owner.transfer(this.balance);
        return;
    }
    ERC20Basic claimToken = ERC20Basic(_claimToken);
    uint256 balance = claimToken.balanceOf(this);
    claimToken.transfer(owner, balance);
    ClaimedTokens(_claimToken, owner, balance);
  }
}
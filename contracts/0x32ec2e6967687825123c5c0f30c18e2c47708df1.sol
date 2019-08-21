// This is the code fot the smart contract 
// used for the Realisto ICO 
//
// @author: Pavel Metelitsyn
// September 2017


pragma solidity ^0.4.15;


// import "./library.sol";


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 * 
 * Source: Zeppelin Solidity
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

  function percent(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c / 100;
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */

 /* from OpenZeppelin library */
 /* https://github.com/OpenZeppelin/zeppelin-solidity */

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

//import "./RealistoToken.sol";


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
    ) returns (MiniMeToken) {
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

contract RealistoToken is MiniMeToken { 

  // we use this variable to store the number of the finalization block
  uint256 public checkpointBlock;

  // address which is allowed to trigger tokens generation
  address public mayGenerateAddr;

  // flag
  bool tokenGenerationEnabled; //<- added after first audit


  modifier mayGenerate() {
    require ( (msg.sender == mayGenerateAddr) &&
              (tokenGenerationEnabled == true) ); //<- added after first audit
    _;
  }

  // Constructor
  function RealistoToken(address _tokenFactory) 
    MiniMeToken(
      _tokenFactory,
      0x0,
      0,
      "Realisto Token",
      18, // decimals
      "REA",
      // SHOULD TRANSFERS BE ENABLED? -- NO
      false){
    tokenGenerationEnabled = true;
    controller = msg.sender;
    mayGenerateAddr = controller;
  }

  function setGenerateAddr(address _addr) onlyController{
    // we can appoint an address to be allowed to generate tokens
    require( _addr != 0x0 );
    mayGenerateAddr = _addr;
  }


  /// @notice this is default function called when ETH is send to this contract
  ///   we use the campaign contract for selling tokens
  function () payable {
    revert();
  }

  
  /// @notice This function is copy-paste of the generateTokens of the original MiniMi contract
  ///   except it uses mayGenerate modifier (original uses onlyController)
  /// this is because we don't want the Sale campaign contract to be the controller
  function generate_token_for(address _addrTo, uint _amount) mayGenerate returns (bool) {
    
    //balances[_addr] += _amount;
   
    uint curTotalSupply = totalSupply();
    require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow    
    uint previousBalanceTo = balanceOf(_addrTo);
    require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
    updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
    updateValueAtNow(balances[_addrTo], previousBalanceTo + _amount);
    Transfer(0, _addrTo, _amount);
    return true;
  }

  // overwrites the original function
  function generateTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
    revert();
    generate_token_for(_owner, _amount);    
  }


  // permanently disables generation of new tokens
  function finalize() mayGenerate {
    tokenGenerationEnabled = false; //<- added after first audit
    checkpointBlock = block.number;
  }  
}




//import "./LinearTokenVault.sol";



// simple time locked vault allows controlled extraction of tokens during a period of time


// Controlled is implemented in MiniMeToken.sol 
contract TokenVault is Controlled {
	using SafeMath for uint256;


	//address campaignAddr;
	TokenCampaign campaign;
	//uint256 tUnlock = 0;
	uint256 tDuration;
	uint256 tLock = 12 * 30 * (1 days); // 12 months 
	MiniMeToken token;

	uint256 extracted = 0;

	event Extract(address indexed _to, uint256 _amount);

	function TokenVault(
		address _tokenAddress,
	 	address _campaignAddress,
	 	uint256 _tDuration
	 	) {

			require( _tDuration > 0);
			tDuration = _tDuration;

			//campaignAddr = _campaignAddress;
			token = RealistoToken(_tokenAddress);
			campaign = TokenCampaign(_campaignAddress);
		}

	/// WE DONT USE IT ANYMORE
	/// sale campaign calls this function to set the time lock
	/// @param _tUnlock - Unix timestamp of the first date 
	///							on which tokens become available
	//function setTimeLock(uint256 _tUnlock){
		// prevent change of the timestamp by anybody other than token sale contract
		// once unlock time is set it cannot be changed
		//require( (msg.sender == campaignAddr) && (tUnlock == 0));
	//	tUnlock = _tUnlock;
	//}

	/// @notice Send all available tokens to a given address
	function extract(address _to) onlyController {
		
		require (_to != 0x0);

		uint256 available = availableNow();
	
		require( available > 0 );

		extracted = extracted.add(available);
		assert( token.transfer(_to, available) );
		

		Extract(_to, available);

	}

	// returns amount of tokens held in this vault
	function balance() returns (uint256){
		return token.balanceOf(address(this));
	}

	function get_unlock_time() returns (uint256){
		return campaign.tFinalized() + tLock;
	}

	// returns amount of tokens available for extraction now
	function availableNow() returns (uint256){
		
		uint256 tUnlock = get_unlock_time();
		uint256 tNow = now;

		// if before unlock time or unlock time is not set  => 0 is available 
		if (tNow < tUnlock ) { return 0; }

		uint256 remaining = balance();

		// if after longer than tDuration since unlock time => everything that is left is available
		if (tNow > tUnlock + tDuration) { return remaining; }

		// otherwise:
		// compute how many extractions remaining based on time

			// time delta
		uint256 t = (tNow.sub(tUnlock)).mul(remaining.add(extracted));
		return (t.div(tDuration)).sub(extracted);
	}

}


contract rea_token_interface{
  uint8 public decimals;
  function generate_token_for(address _addr,uint _amount) returns (bool);
  function finalize();
}


// Controlled is implemented in MiniMeToken.sol
contract TokenCampaign is Controlled{
  using SafeMath for uint256;

  // this is our token
  rea_token_interface public token;

  TokenVault teamVault;

 
  ///////////////////////////////////
  //
  // constants related to token sale

  // after slae ends, additional tokens will be generated
  // according to the following rules,
  // where 100% correspond to the number of sold tokens

  // percent of tokens to be generated for the team
  uint256 public constant PRCT_TEAM = 10;
  // percent of tokens to be generated for bounty
  uint256 public constant PRCT_BOUNTY = 3;
 
  // we keep ETH in the contract until the sale is finalized
  // however a small part of every contribution goes to opperational costs
  // percent of ETH going to operational account
  uint256 public constant PRCT_ETH_OP = 10;

  uint8 public constant decimals = 18;
  uint256 public constant scale = (uint256(10) ** decimals);


  // how many tokens for one ETH
  // we may adjust this number before deployment based on the market conditions
  uint256 public constant baseRate = 330; //<-- unscaled

  // we want to limit the number of available tokens during the bonus stage 
  // payments during the bonus stage will not be accepted after the TokenTreshold is reached or exceeded
  // we may adjust this number before deployment based on the market conditions

  uint256 public constant bonusTokenThreshold = 2000000 * scale ; //<--- new 

  // minmal contribution, Wei
  uint256 public constant minContribution = (1 ether) / 100;

  // bonus structure, Wei
  uint256 public constant bonusMinContribution = (1 ether) /10;
  // 
  uint256 public constant bonusAdd = 99; // + 30% <-- corrected
  uint256 public constant stage_1_add = 50;// + 15,15% <-- corrected
  uint256 public constant stage_2_add = 33;// + 10%
  uint256 public constant stage_3_add = 18;// + 5,45%
  
  ////////////////////////////////////////////////////////
  //
  // folowing addresses need to be set in the constructor
  // we also have setter functions which allow to change
  // an address if it is compromised or something happens

  // destination for team's share
  // this should point to an instance of TokenVault contract
  address public teamVaultAddr = 0x0;
  
  // destination for reward tokens
  address public bountyVaultAddr;

  // destination for collected Ether
  address public trusteeVaultAddr;
  
  // destination for operational costs account
  address public opVaultAddr;
  

  // adress of our token
  address public tokenAddr;


  // address of our bitcoin payment processing robot
  // the robot is allowed to generate tokens without
  // sending ether
  // we do it to have more granular rights controll 
  address public robotAddr;
  
  
  /////////////////////////////////
  // Realted to Campaign


  // @check ensure that state transitions are 
  // only in one direction
  // 4 - passive, not accepting funds
  // 3 - is not used
  // 2 - active main sale, accepting funds
  // 1 - closed, not accepting funds 
  // 0 - finalized, not accepting funds
  uint8 public campaignState = 4; 
  bool public paused = false;

  // keeps track of tokens generated so far, scaled value
  uint256 public tokensGenerated = 0;

  // total Ether raised (= Ether paid into the contract)
  uint256 public amountRaised = 0; 

  
  // this is the address where the funds 
  // will be transfered after the sale ends
  
  // time in seconds since epoch 
  // set to midnight of saturday January 1st, 4000
  uint256 public tCampaignStart = 64060588800;
  uint256 public tBonusStageEnd = 7 * (1 days);
  uint256 public tRegSaleStart = 8 * (1 days);
  uint256 public t_1st_StageEnd = 15 * (1 days);
  uint256 public t_2nd_StageEnd = 22* (1 days);
  uint256 public t_3rd_StageEnd = 29 * (1 days);
  uint256 public tCampaignEnd = 38 * (1 days);
  uint256 public tFinalized = 64060588800;

  //////////////////////////////////////////////
  //
  // Modifiers

  /// @notice The robot is allowed to generate tokens 
  ///   without sending ether
  ///  We do it to have more granular rights controll 
  modifier onlyRobot () { 
   require(msg.sender == robotAddr); 
   _;
  }

  //////////////////////////////////////////////
  //
  // Events
 
  event CampaignOpen(uint256 time);
  event CampaignClosed(uint256 time);
  event CampaignPausd(uint256 time);
  event CampaignResumed(uint256 time);
  event TokenGranted(address indexed backer, uint amount, string ref);
  event TokenGranted(address indexed backer, uint amount);
  event TotalRaised(uint raised);
  event Finalized(uint256 time);
  event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
 

  /// @notice Constructor
  /// @param _tokenAddress Our token's address
  /// @param  _trusteeAddress Team share 
  /// @param  _opAddress Team share 
  /// @param  _bountyAddress Team share 
  /// @param  _robotAddress Address of our processing backend
  function TokenCampaign(
    address _tokenAddress,
    address _trusteeAddress,
    address _opAddress,
    address _bountyAddress,
    address _robotAddress)
  {

    controller = msg.sender;
    
    /// set addresses     
    tokenAddr = _tokenAddress;
    //teamVaultAddr = _teamAddress;
    trusteeVaultAddr = _trusteeAddress; 
    opVaultAddr = _opAddress;
    bountyVaultAddr = _bountyAddress;
    robotAddr = _robotAddress;

    /// reference our token
    token = rea_token_interface(tokenAddr);
   
    // adjust 'constants' for decimals used
    // decimals = token.decimals(); // should be 18
   
  }


  //////////////////////////////////////////////////
  ///
  /// Functions that do not change contract state
  function get_presale_goal() constant returns (bool){
    if ((now <= tBonusStageEnd) && (tokensGenerated >= bonusTokenThreshold)){
      return true;
    } else {
      return false;
    }
  }

  /// @notice computes the current rate
  ///  according to time passed since the start
  /// @return amount of tokens per ETH
  function get_rate() constant returns (uint256){
    
    // obviously one gets 0 tokens
    // if campaign not yet started
    // or is already over
    if (now < tCampaignStart) return 0;
    if (now > tCampaignEnd) return 0;
    
    // compute rate per ETH based on time
    // assumes that time marks are increasing
    // from tBonusStageEnd through t_3rd_StageEnd
    // adjust by factor 'scale' depending on token's decimals
    // NOTE: can't cause overflow since all numbers are known at compile time
    if (now <= tBonusStageEnd)
      return scale * (baseRate + bonusAdd);

    if (now <= t_1st_StageEnd)
      return scale * (baseRate + stage_1_add);
    
    else if (now <= t_2nd_StageEnd)
      return scale * (baseRate + stage_2_add);
    
    else if (now <= t_3rd_StageEnd)
      return scale * (baseRate + stage_3_add);
    
    else 
      return baseRate * scale; 
  }


  /////////////////////////////////////////////
  ///
  /// Functions that change contract state

  ///
  /// Setters
  ///


  /// this is only for emergency case
  function setRobotAddr(address _newRobotAddr) public onlyController {
    require( _newRobotAddr != 0x0 );
    robotAddr = _newRobotAddr;
  }

  // we have to set team token address before campaign start
  function setTeamAddr(address _newTeamAddr) public onlyController {
     require( campaignState > 2 && _newTeamAddr != 0x0 );
     teamVaultAddr = _newTeamAddr;
     teamVault = TokenVault(teamVaultAddr);
  }
 


  /// @notice  Puts campaign into active state  
  ///  only controller can do that
  ///  only possible if team token Vault is set up
  ///  WARNING: usual caveats apply to the Ethereum's interpretation of time
  function startSale() public onlyController {
    // we only can start if team token Vault address is set
    require( campaignState > 2 && teamVaultAddr != 0x0);

    campaignState = 2;

    uint256 tNow = now;
    // assume timestamps will not cause overflow
    tCampaignStart = tNow;
    tBonusStageEnd += tNow;
    tRegSaleStart += tNow;
    t_1st_StageEnd += tNow;
    t_2nd_StageEnd += tNow;
    t_3rd_StageEnd += tNow;
    tCampaignEnd += tNow;

    CampaignOpen(now);
  }


  /// @notice Pause sale
  ///   just in case we have some troubles 
  ///   Note that time marks are not updated
  function pauseSale() public onlyController {
    require( campaignState  == 2 );
    paused = true;
    CampaignPausd(now);
  }


  /// @notice Resume sale
  function resumeSale() public onlyController {
    require( campaignState  == 2 );
    paused = false;
    CampaignResumed(now);
  }



  /// @notice Puts the camapign into closed state
  ///   only controller can do so
  ///   only possible from the active state
  ///   we can call this function if we want to stop sale before end time 
  ///   and be able to perform 'finalizeCampaign()' immediately
  function closeSale() public onlyController {
    require( campaignState  == 2 );
    campaignState = 1;

    CampaignClosed(now);
  }   



  /// @notice Finalizes the campaign
  ///   Get funds out, generates team, bounty and reserve tokens
  function finalizeCampaign() public {     
      
      /// only if sale was closed or 48 hours = 2880 minutes have passed since campaign end
      /// we leave this time to complete possibly pending orders
      /// from offchain contributions 
      
      require ( (campaignState == 1) ||
                ((campaignState != 0) && (now > tCampaignEnd + (2880 minutes))));
      
      campaignState = 0;

     

      // forward funds to the trustee 
      // since we forward a fraction of the incomming ether on every contribution
      // 'amountRaised' IS NOT equal to the contract's balance
      // we use 'this.balance' instead

      trusteeVaultAddr.transfer(this.balance);
      
      
      uint256 bountyTokens = (tokensGenerated.mul(PRCT_BOUNTY)).div(100);
      
      uint256 teamTokens = (tokensGenerated.mul(PRCT_TEAM)).div(100);
      
      // generate bounty tokens 
      assert( do_grant_tokens(bountyVaultAddr, bountyTokens) );
      // generate team tokens
      // time lock team tokens before transfer
      
      // we dont use it anymore
      //teamVault.setTimeLock( tCampaignEnd + 6 * (6 minutes));  
      
      tFinalized = now;

      // generate all the tokens
      assert( do_grant_tokens(teamVaultAddr, teamTokens) );
      
      // prevent further token generation
      token.finalize();     

      // notify the world
      Finalized(tFinalized);
   }


  /// @notice triggers token generaton for the recipient
  ///  can be called only from the token sale contract itself
  ///  side effect: increases the generated tokens counter 
  ///  CAUTION: we do not check campaign state and parameters assuming that's calee's task
  function do_grant_tokens(address _to, uint256 _nTokens) internal returns (bool){
    
    require( token.generate_token_for(_to, _nTokens) );
    
    tokensGenerated = tokensGenerated.add(_nTokens);
    
    return true;
  }


  ///  @notice processes the contribution
  ///   checks campaign state, time window and minimal contribution
  ///   throws if one of the conditions fails
  function process_contribution(address _toAddr) internal {
    
    require ((campaignState == 2)   // active main sale
         && (now <= tCampaignEnd)   // within time window
         && (paused == false));     // not on hold
      

    // contributions are not possible before regular sale starts 
    if ( (now > tBonusStageEnd) && //<--- new
         (now < tRegSaleStart)){ //<--- new
      revert(); //<--- new
    }

    // during the bonus phase we require a minimal eth contribution 
    if ((now <= tBonusStageEnd) && 
        ((msg.value < bonusMinContribution ) ||
        (tokensGenerated >= bonusTokenThreshold))) //<--- new, revert if bonusThreshold is exceeded 
    {
      revert();
    }      

    
  
    // otherwise we check that Eth sent is sufficient to generate at least one token
    // though our token has decimals we don't want nanocontributions
    require ( msg.value >= minContribution );

    // compute the rate
    // NOTE: rate is scaled to account for token decimals
    uint256 rate = get_rate();
    
    // compute the amount of tokens to be generated
    uint256 nTokens = (rate.mul(msg.value)).div(1 ether);
    
    // compute the fraction of ETH going to op account
    uint256 opEth = (PRCT_ETH_OP.mul(msg.value)).div(100);

    // transfer to op account 
    opVaultAddr.transfer(opEth);
    
    // @todo check success (NOTE we have no cap now so success is assumed)
    // side effect: do_grant_tokens updates the "tokensGenerated" variable
    require( do_grant_tokens(_toAddr, nTokens) );


    amountRaised = amountRaised.add(msg.value);
    
    // notify the world
    TokenGranted(_toAddr, nTokens);
    TotalRaised(amountRaised);
  }


  /// @notice Gnenerate token "manually" without payment
  ///  We intend to use this to generate tokens from Bitcoin contributions without 
  ///  without Ether being sent to this contract
  ///  Note that this function can be triggered only by our BTC processing robot.  
  ///  A string reference is passed and logged for better book keeping
  ///  side effect: increases the generated tokens counter via do_grant_tokens
  /// @param _toAddr benificiary address
  /// @param _nTokens amount of tokens to be generated
  /// @param _ref payment reference e.g. Bitcoin address used for contribution 
  function grant_token_from_offchain(address _toAddr, uint _nTokens, string _ref) public onlyRobot {
    require ( (campaignState == 2)
              ||(campaignState == 1));

    do_grant_tokens(_toAddr, _nTokens);
    TokenGranted(_toAddr, _nTokens, _ref);
  }


  /// @notice This function handles receiving Ether in favor of a third party address
  ///   we can use this function for buying tokens on behalf
  /// @param _toAddr the address which will receive tokens
  function proxy_contribution(address _toAddr) public payable {
    require ( _toAddr != 0x0 );
    /// prevent contracts from buying tokens
    /// we assume it is still usable for a while
    /// we aknowledge the fact that this prevents ALL contracts including MultiSig's
    /// from contributing, it is intended and we add a corresponding statement 
    /// to our Terms and the ICO site
    require( msg.sender == tx.origin );
    process_contribution(_toAddr);
  }


  /// @notice This function handles receiving Ether
  function () payable {
    /// prevent contracts from buying tokens
    /// we assume it is still usable for a while
    /// we aknowledge the fact that this prevents ALL contracts including MultiSig's
    /// from contributing, it is intended and we add a corresponding statement 
    /// to our Terms and the ICO site
    require( msg.sender == tx.origin );
    process_contribution(msg.sender);  
  }

  //////////
  // Safety Methods
  //////////

  /* inspired by MiniMeToken.sol */

  /// @notice This method can be used by the controller to extract mistakenly
  ///  sent tokens to this contract.
  function claimTokens(address _tokenAddr) public onlyController {
     
     // if (_token == 0x0) {
     //     controller.transfer(this.balance);
     //     return;
     // }

      ERC20Basic some_token = ERC20Basic(_tokenAddr);
      uint balance = some_token.balanceOf(this);
      some_token.transfer(controller, balance);
      ClaimedTokens(_tokenAddr, controller, balance);
  }
}
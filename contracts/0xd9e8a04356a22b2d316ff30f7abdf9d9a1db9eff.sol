pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
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
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

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
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

// File: contracts/assettoken/library/AssetTokenL.sol

/*
    Copyright 2018, CONDA

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



/** @title AssetTokenL library. */
library AssetTokenL {
    using SafeMath for uint256;

///////////////////
// Struct Parameters (passed as parameter to library)
///////////////////

    struct Supply {
        // `balances` is the map that tracks the balance of each address, in this
        // contract when the balance changes. TransfersAndMints-index when the change
        // occurred is also included
        mapping (address => Checkpoint[]) balances;

        // Tracks the history of the `totalSupply` of the token
        Checkpoint[] totalSupplyHistory;

        // `allowed` tracks any extra transfer rights as in all ERC20 tokens
        mapping (address => mapping (address => uint256)) allowed;

        // Minting cap max amount of tokens
        uint256 cap;

        // When successfully funded
        uint256 goal;

        //crowdsale start
        uint256 startTime;

        //crowdsale end
        uint256 endTime;

        //crowdsale dividends
        Dividend[] dividends;

        //counter per address how much was claimed in continuous way
        //note: counter also increases when recycled and tried to claim in continous way
        mapping (address => uint256) dividendsClaimed;

        uint256 tokenActionIndex; //only modify within library
    }

    struct Availability {
        // Flag that determines if the token is yet alive.
        // Meta data cannot be changed anymore (except capitalControl)
        bool tokenAlive;

        // Flag that determines if the token is transferable or not.
        bool transfersEnabled;

        // Flag that minting is finished
        bool mintingPhaseFinished;

        // Flag that minting is paused
        bool mintingPaused;
    }

    struct Roles {
        // role that can pause/resume
        address pauseControl;

        // role that can rescue accidentally sent tokens
        address tokenRescueControl;

        // role that can mint during crowdsale (usually controller)
        address mintControl;
    }

///////////////////
// Structs (saved to blockchain)
///////////////////

    /// @dev `Dividend` is the structure that saves the status of a dividend distribution
    struct Dividend {
        uint256 currentTokenActionIndex;
        uint256 timestamp;
        DividendType dividendType;
        address dividendToken;
        uint256 amount;
        uint256 claimedAmount;
        uint256 totalSupply;
        bool recycled;
        mapping (address => bool) claimed;
    }

    /// @dev Dividends can be of those types.
    enum DividendType { Ether, ERC20 }

    /** @dev Checkpoint` is the structure that attaches a history index to a given value
      * @notice That uint128 is used instead of uint/uint256. That's to save space. Should be big enough (feedback from audit)
      */
    struct Checkpoint {

        // `currentTokenActionIndex` is the index when the value was generated. It's uint128 to save storage space
        uint128 currentTokenActionIndex;

        // `value` is the amount of tokens at a specific index. It's uint128 to save storage space
        uint128 value;
    }

///////////////////
// Functions
///////////////////

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract. Check for availability must be done before.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(Supply storage _self, Availability storage /*_availability*/, address _from, address _to, uint256 _amount) public {
        // Do not allow transfer to 0x0 or the token contract itself
        require(_to != address(0), "addr0");
        require(_to != address(this), "target self");

        // If the amount being transfered is more than the balance of the
        //  account the transfer throws
        uint256 previousBalanceFrom = balanceOfNow(_self, _from);
        require(previousBalanceFrom >= _amount, "not enough");

        // First update the balance array with the new value for the address
        //  sending the tokens
        updateValueAtNow(_self, _self.balances[_from], previousBalanceFrom.sub(_amount));

        // Then update the balance array with the new value for the address
        //  receiving the tokens
        uint256 previousBalanceTo = balanceOfNow(_self, _to);
        
        updateValueAtNow(_self, _self.balances[_to], previousBalanceTo.add(_amount));

        //info: don't move this line inside updateValueAtNow (because transfer is 2 actions)
        increaseTokenActionIndex(_self);

        // An event to make the transfer easy to find on the blockchain
        emit Transfer(_from, _to, _amount);
    }

    function increaseTokenActionIndex(Supply storage _self) private {
        _self.tokenActionIndex = _self.tokenActionIndex.add(1);

        emit TokenActionIndexIncreased(_self.tokenActionIndex, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` of his tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(Supply storage _self, address _spender, uint256 _amount) public returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (_self.allowed[msg.sender][_spender] == 0), "amount");

        _self.allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @notice Increase the amount of tokens that an owner allowed to a spender.
    /// @dev approve should be called when allowed[_spender] == 0. To increment
    ///  allowed value is better to use this function to avoid 2 calls (and wait until
    ///  the first transaction is mined)
    ///  From MonolithDAO Token.sol
    /// @param _spender The address which will spend the funds.
    /// @param _addedValue The amount of tokens to increase the allowance by.
    /// @return True if the approval was successful
    function increaseApproval(Supply storage _self, address _spender, uint256 _addedValue) public returns (bool) {
        _self.allowed[msg.sender][_spender] = _self.allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, _self.allowed[msg.sender][_spender]);
        return true;
    }

    /// @notice Decrease the amount of tokens that an owner allowed to a spender.
    /// @dev approve should be called when allowed[_spender] == 0. To decrement
    ///  allowed value is better to use this function to avoid 2 calls (and wait until
    ///  the first transaction is mined)
    ///  From MonolithDAO Token.sol
    /// @param _spender The address which will spend the funds.
    /// @param _subtractedValue The amount of tokens to decrease the allowance by.
    /// @return True if the approval was successful
    function decreaseApproval(Supply storage _self, address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = _self.allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            _self.allowed[msg.sender][_spender] = 0;
        } else {
            _self.allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, _self.allowed[msg.sender][_spender]);
        return true;
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` if it is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(Supply storage _supply, Availability storage _availability, address _from, address _to, uint256 _amount) 
    public 
    returns (bool success) 
    {
        // The standard ERC 20 transferFrom functionality
        require(_supply.allowed[_from][msg.sender] >= _amount, "allowance");
        _supply.allowed[_from][msg.sender] = _supply.allowed[_from][msg.sender].sub(_amount);

        doTransfer(_supply, _availability, _from, _to, _amount);
        return true;
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` WITHOUT approval. UseCase: notar transfers from lost wallet
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @param _fullAmountRequired Full amount required (causes revert if not).
    /// @return True if the transfer was successful
    function enforcedTransferFrom(
        Supply storage _self, 
        Availability storage _availability, 
        address _from, 
        address _to, 
        uint256 _amount, 
        bool _fullAmountRequired) 
    public 
    returns (bool success) 
    {
        if(_fullAmountRequired && _amount != balanceOfNow(_self, _from))
        {
            revert("Only full amount in case of lost wallet is allowed");
        }

        doTransfer(_self, _availability, _from, _to, _amount);

        emit SelfApprovedTransfer(msg.sender, _from, _to, _amount);

        return true;
    }

////////////////
// Miniting 
////////////////

    /// @notice Function to mint tokens
    /// @param _to The address that will receive the minted tokens.
    /// @param _amount The amount of tokens to mint.
    /// @return A boolean that indicates if the operation was successful.
    function mint(Supply storage _self, address _to, uint256 _amount) public returns (bool) {
        uint256 curTotalSupply = totalSupplyNow(_self);
        uint256 previousBalanceTo = balanceOfNow(_self, _to);

        // Check cap
        require(curTotalSupply.add(_amount) <= _self.cap, "cap"); //leave inside library to never go over cap

        // Check timeframe
        require(_self.startTime <= now, "too soon");
        require(_self.endTime >= now, "too late");

        updateValueAtNow(_self, _self.totalSupplyHistory, curTotalSupply.add(_amount));
        updateValueAtNow(_self, _self.balances[_to], previousBalanceTo.add(_amount));

        //info: don't move this line inside updateValueAtNow (because transfer is 2 actions)
        increaseTokenActionIndex(_self);

        emit MintDetailed(msg.sender, _to, _amount);
        emit Transfer(address(0), _to, _amount);

        return true;
    }

////////////////
// Query balance and totalSupply in History
////////////////

    /// @dev Queries the balance of `_owner` at `_specificTransfersAndMintsIndex`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _specificTransfersAndMintsIndex The balance at index
    /// @return The balance at `_specificTransfersAndMintsIndex`
    function balanceOfAt(Supply storage _self, address _owner, uint256 _specificTransfersAndMintsIndex) public view returns (uint256) {
        return getValueAt(_self.balances[_owner], _specificTransfersAndMintsIndex);
    }

    function balanceOfNow(Supply storage _self, address _owner) public view returns (uint256) {
        return getValueAt(_self.balances[_owner], _self.tokenActionIndex);
    }

    /// @dev Total amount of tokens at `_specificTransfersAndMintsIndex`.
    /// @param _specificTransfersAndMintsIndex The totalSupply at index
    /// @return The total amount of tokens at `_specificTransfersAndMintsIndex`
    function totalSupplyAt(Supply storage _self, uint256 _specificTransfersAndMintsIndex) public view returns(uint256) {
        return getValueAt(_self.totalSupplyHistory, _specificTransfersAndMintsIndex);
    }

    function totalSupplyNow(Supply storage _self) public view returns(uint256) {
        return getValueAt(_self.totalSupplyHistory, _self.tokenActionIndex);
    }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

    /// @dev `getValueAt` retrieves the number of tokens at a given index
    /// @param checkpoints The history of values being queried
    /// @param _specificTransfersAndMintsIndex The index to retrieve the history checkpoint value at
    /// @return The number of tokens being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint256 _specificTransfersAndMintsIndex) private view returns (uint256) { 
        
        //  requested before a check point was ever created for this token
        if (checkpoints.length == 0 || checkpoints[0].currentTokenActionIndex > _specificTransfersAndMintsIndex) {
            return 0;
        }

        // Shortcut for the actual value
        if (_specificTransfersAndMintsIndex >= checkpoints[checkpoints.length-1].currentTokenActionIndex) {
            return checkpoints[checkpoints.length-1].value;
        }

        // Binary search of the value in the array
        uint256 min = 0;
        uint256 max = checkpoints.length-1;
        while (max > min) {
            uint256 mid = (max + min + 1)/2;
            if (checkpoints[mid].currentTokenActionIndex<=_specificTransfersAndMintsIndex) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    /// @dev `updateValueAtNow` used to update the `balances` map and the `totalSupplyHistory`
    /// @param checkpoints The history of data being updated
    /// @param _value The new number of tokens
    function updateValueAtNow(Supply storage _self, Checkpoint[] storage checkpoints, uint256 _value) private {
        require(_value == uint128(_value), "invalid cast1");
        require(_self.tokenActionIndex == uint128(_self.tokenActionIndex), "invalid cast2");

        checkpoints.push(Checkpoint(
            uint128(_self.tokenActionIndex),
            uint128(_value)
        ));
    }

    /// @dev Function to stop minting new tokens.
    /// @return True if the operation was successful.
    function finishMinting(Availability storage _self) public returns (bool) {
        if(_self.mintingPhaseFinished) {
            return false;
        }

        _self.mintingPhaseFinished = true;
        emit MintFinished(msg.sender);
        return true;
    }

    /// @notice Reopening crowdsale means minting is again possible. UseCase: notary approves and does that.
    /// @return True if the operation was successful.
    function reopenCrowdsale(Availability storage _self) public returns (bool) {
        if(_self.mintingPhaseFinished == false) {
            return false;
        }

        _self.mintingPhaseFinished = false;
        emit Reopened(msg.sender);
        return true;
    }

    /// @notice Set roles/operators.
    /// @param _pauseControl pause control.
    /// @param _tokenRescueControl token rescue control (accidentally assigned tokens).
    function setRoles(Roles storage _self, address _pauseControl, address _tokenRescueControl) public {
        require(_pauseControl != address(0), "addr0");
        require(_tokenRescueControl != address(0), "addr0");
        
        _self.pauseControl = _pauseControl;
        _self.tokenRescueControl = _tokenRescueControl;

        emit RolesChanged(msg.sender, _pauseControl, _tokenRescueControl);
    }

    /// @notice Set mint control.
    function setMintControl(Roles storage _self, address _mintControl) public {
        require(_mintControl != address(0), "addr0");

        _self.mintControl = _mintControl;

        emit MintControlChanged(msg.sender, _mintControl);
    }

    /// @notice Set token alive which can be seen as not in draft state anymore.
    function setTokenAlive(Availability storage _self) public {
        _self.tokenAlive = true;
    }

////////////////
// Pausing token for unforeseen reasons
////////////////

    /// @notice pause transfer.
    /// @param _transfersEnabled True if transfers are allowed.
    function pauseTransfer(Availability storage _self, bool _transfersEnabled) public
    {
        _self.transfersEnabled = _transfersEnabled;

        if(_transfersEnabled) {
            emit TransferResumed(msg.sender);
        } else {
            emit TransferPaused(msg.sender);
        }
    }

    /// @notice calling this can enable/disable capital increase/decrease flag
    /// @param _mintingEnabled True if minting is allowed
    function pauseCapitalIncreaseOrDecrease(Availability storage _self, bool _mintingEnabled) public
    {
        _self.mintingPaused = (_mintingEnabled == false);

        if(_mintingEnabled) {
            emit MintingResumed(msg.sender);
        } else {
            emit MintingPaused(msg.sender);
        }
    }

    /// @notice Receives ether to be distriubted to all token owners
    function depositDividend(Supply storage _self, uint256 msgValue)
    public 
    {
        require(msgValue > 0, "amount0");

        // gets the current number of total token distributed
        uint256 currentSupply = totalSupplyNow(_self);

        // a deposit without investment would end up in unclaimable deposit for token holders
        require(currentSupply > 0, "0investors");

        // creates a new index for the dividends
        uint256 dividendIndex = _self.dividends.length;

        // Stores the current meta data for the dividend payout
        _self.dividends.push(
            Dividend(
                _self.tokenActionIndex, // current index used for claiming
                block.timestamp, // Timestamp of the distribution
                DividendType.Ether, // Type of dividends
                address(0),
                msgValue, // Total amount that has been distributed
                0, // amount that has been claimed
                currentSupply, // Total supply now
                false // Already recylced
            )
        );
        emit DividendDeposited(msg.sender, _self.tokenActionIndex, msgValue, currentSupply, dividendIndex);
    }

    /// @notice Receives ERC20 to be distriubted to all token owners
    function depositERC20Dividend(Supply storage _self, address _dividendToken, uint256 _amount, address baseCurrency)
    public
    {
        require(_amount > 0, "amount0");
        require(_dividendToken == baseCurrency, "not baseCurrency");

        // gets the current number of total token distributed
        uint256 currentSupply = totalSupplyNow(_self);

        // a deposit without investment would end up in unclaimable deposit for token holders
        require(currentSupply > 0, "0investors");

        // creates a new index for the dividends
        uint256 dividendIndex = _self.dividends.length;

        // Stores the current meta data for the dividend payout
        _self.dividends.push(
            Dividend(
                _self.tokenActionIndex, // index that counts up on transfers and mints
                block.timestamp, // Timestamp of the distribution
                DividendType.ERC20, 
                _dividendToken, 
                _amount, // Total amount that has been distributed
                0, // amount that has been claimed
                currentSupply, // Total supply now
                false // Already recylced
            )
        );

        // it shouldn't return anything but according to ERC20 standard it could if badly implemented
        // IMPORTANT: potentially a call with reentrance -> do at the end
        require(ERC20(_dividendToken).transferFrom(msg.sender, address(this), _amount), "transferFrom");

        emit DividendDeposited(msg.sender, _self.tokenActionIndex, _amount, currentSupply, dividendIndex);
    }

    /// @notice Function to claim dividends for msg.sender
    /// @dev dividendsClaimed should not be handled here.
    function claimDividend(Supply storage _self, uint256 _dividendIndex) public {
        // Loads the details for the specific Dividend payment
        Dividend storage dividend = _self.dividends[_dividendIndex];

        // Devidends should not have been claimed already
        require(dividend.claimed[msg.sender] == false, "claimed");

         // Devidends should not have been recycled already
        require(dividend.recycled == false, "recycled");

        // get the token balance at the time of the dividend distribution
        uint256 balance = balanceOfAt(_self, msg.sender, dividend.currentTokenActionIndex.sub(1));

        // calculates the amount of dividends that can be claimed
        uint256 claim = balance.mul(dividend.amount).div(dividend.totalSupply);

        // flag that dividends have been claimed
        dividend.claimed[msg.sender] = true;
        dividend.claimedAmount = SafeMath.add(dividend.claimedAmount, claim);

        claimThis(dividend.dividendType, _dividendIndex, msg.sender, claim, dividend.dividendToken);
    }

    /// @notice Claim all dividends.
    /// @dev dividendsClaimed counter should only increase when claimed in hole-free way.
    function claimDividendAll(Supply storage _self) public {
        claimLoopInternal(_self, _self.dividendsClaimed[msg.sender], (_self.dividends.length-1));
    }

    /// @notice Claim dividends in batches. In case claimDividendAll runs out of gas.
    /// @dev dividendsClaimed counter should only increase when claimed in hole-free way.
    /// @param _startIndex start index (inclusive number).
    /// @param _endIndex end index (inclusive number).
    function claimInBatches(Supply storage _self, uint256 _startIndex, uint256 _endIndex) public {
        claimLoopInternal(_self, _startIndex, _endIndex);
    }

    /// @notice Claim loop of batch claim and claim all.
    /// @dev dividendsClaimed counter should only increase when claimed in hole-free way.
    /// @param _startIndex start index (inclusive number).
    /// @param _endIndex end index (inclusive number).
    function claimLoopInternal(Supply storage _self, uint256 _startIndex, uint256 _endIndex) private {
        require(_startIndex <= _endIndex, "start after end");

        //early exit if already claimed
        require(_self.dividendsClaimed[msg.sender] < _self.dividends.length, "all claimed");

        uint256 dividendsClaimedTemp = _self.dividendsClaimed[msg.sender];

        // Cycle through all dividend distributions and make the payout
        for (uint256 i = _startIndex; i <= _endIndex; i++) {
            if (_self.dividends[i].recycled == true) {
                //recycled and tried to claim in continuous way internally counts as claimed
                dividendsClaimedTemp = SafeMath.add(i, 1);
            }
            else if (_self.dividends[i].claimed[msg.sender] == false) {
                dividendsClaimedTemp = SafeMath.add(i, 1);
                claimDividend(_self, i);
            }
        }

        // This is done after the loop to reduce writes.
        // Remembers what has been claimed after hole-free claiming procedure.
        // IMPORTANT: do only if batch claim docks on previous claim to avoid unexpected claim all behaviour.
        if(_startIndex <= _self.dividendsClaimed[msg.sender]) {
            _self.dividendsClaimed[msg.sender] = dividendsClaimedTemp;
        }
    }

    /// @notice Dividends which have not been claimed can be claimed by owner after timelock (to avoid loss)
    /// @param _dividendIndex index of dividend to recycle.
    /// @param _recycleLockedTimespan timespan required until possible.
    /// @param _currentSupply current supply.
    function recycleDividend(Supply storage _self, uint256 _dividendIndex, uint256 _recycleLockedTimespan, uint256 _currentSupply) public {
        // Get the dividend distribution
        Dividend storage dividend = _self.dividends[_dividendIndex];

        // should not have been recycled already
        require(dividend.recycled == false, "recycled");

        // The recycle time has to be over
        require(dividend.timestamp < SafeMath.sub(block.timestamp, _recycleLockedTimespan), "timeUp");

        // Devidends should not have been claimed already
        require(dividend.claimed[msg.sender] == false, "claimed");

        //
        //refund
        //

        // The amount, which has not been claimed is distributed to token owner
        _self.dividends[_dividendIndex].recycled = true;

        // calculates the amount of dividends that can be claimed
        uint256 claim = SafeMath.sub(dividend.amount, dividend.claimedAmount);

        // flag that dividends have been claimed
        dividend.claimed[msg.sender] = true;
        dividend.claimedAmount = SafeMath.add(dividend.claimedAmount, claim);

        claimThis(dividend.dividendType, _dividendIndex, msg.sender, claim, dividend.dividendToken);

        emit DividendRecycled(msg.sender, _self.tokenActionIndex, claim, _currentSupply, _dividendIndex);
    }

    /// @dev the core claim function of single dividend.
    function claimThis(DividendType _dividendType, uint256 _dividendIndex, address payable _beneficiary, uint256 _claim, address _dividendToken) 
    private 
    {
        // transfer the dividends to the token holder
        if (_claim > 0) {
            if (_dividendType == DividendType.Ether) { 
                _beneficiary.transfer(_claim);
            } 
            else if (_dividendType == DividendType.ERC20) { 
                require(ERC20(_dividendToken).transfer(_beneficiary, _claim), "transfer");
            }
            else {
                revert("unknown type");
            }

            emit DividendClaimed(_beneficiary, _dividendIndex, _claim);
        }
    }

    /// @notice If this contract gets a balance in some other ERC20 contract - or even iself - then we can rescue it.
    /// @param _foreignTokenAddress token where contract has balance.
    /// @param _to the beneficiary.
    function rescueToken(Availability storage _self, address _foreignTokenAddress, address _to) public
    {
        require(_self.mintingPhaseFinished, "unfinished");
        ERC20(_foreignTokenAddress).transfer(_to, ERC20(_foreignTokenAddress).balanceOf(address(this)));
    }

///////////////////
// Events (must be redundant in calling contract to work!)
///////////////////

    event Transfer(address indexed from, address indexed to, uint256 value);
    event SelfApprovedTransfer(address indexed initiator, address indexed from, address indexed to, uint256 value);
    event MintDetailed(address indexed initiator, address indexed to, uint256 amount);
    event MintFinished(address indexed initiator);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TransferPaused(address indexed initiator);
    event TransferResumed(address indexed initiator);
    event MintingPaused(address indexed initiator);
    event MintingResumed(address indexed initiator);
    event Reopened(address indexed initiator);
    event DividendDeposited(address indexed depositor, uint256 transferAndMintIndex, uint256 amount, uint256 totalSupply, uint256 dividendIndex);
    event DividendClaimed(address indexed claimer, uint256 dividendIndex, uint256 claim);
    event DividendRecycled(address indexed recycler, uint256 transferAndMintIndex, uint256 amount, uint256 totalSupply, uint256 dividendIndex);
    event RolesChanged(address indexed initiator, address pauseControl, address tokenRescueControl);
    event MintControlChanged(address indexed initiator, address mintControl);
    event TokenActionIndexIncreased(uint256 tokenActionIndex, uint256 blocknumber);
}

// File: contracts/assettoken/interface/IBasicAssetToken.sol

interface IBasicAssetToken {
    //AssetToken specific
    function getLimits() external view returns (uint256, uint256, uint256, uint256);
    function isTokenAlive() external view returns (bool);
    function setMetaData(
        string calldata _name, 
        string calldata _symbol, 
        address _tokenBaseCurrency, 
        uint256 _cap, 
        uint256 _goal, 
        uint256 _startTime, 
        uint256 _endTime) 
        external;

    //Mintable
    function mint(address _to, uint256 _amount) external returns (bool);
    function finishMinting() external returns (bool);

    //ERC20
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _amount) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function totalSupply() external view returns (uint256);
    function increaseApproval(address _spender, uint256 _addedValue) external returns (bool);
    function decreaseApproval(address _spender, uint256 _subtractedValue) external returns (bool);
    function transfer(address _to, uint256 _amount) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success);
}

// File: contracts/assettoken/abstract/IBasicAssetTokenFull.sol

contract IBasicAssetTokenFull is IBasicAssetToken {
    function checkCanSetMetadata() internal returns (bool);

    function getCap() public view returns (uint256);
    function getGoal() public view returns (uint256);
    function getStart() public view returns (uint256);
    function getEnd() public view returns (uint256);
    function getLimits() public view returns (uint256, uint256, uint256, uint256);
    function setMetaData(
        string calldata _name, 
        string calldata _symbol, 
        address _tokenBaseCurrency, 
        uint256 _cap, 
        uint256 _goal, 
        uint256 _startTime, 
        uint256 _endTime) 
        external;
    
    function getTokenRescueControl() public view returns (address);
    function getPauseControl() public view returns (address);
    function isTransfersPaused() public view returns (bool);

    function setMintControl(address _mintControl) public;
    function setRoles(address _pauseControl, address _tokenRescueControl) public;

    function setTokenAlive() public;
    function isTokenAlive() public view returns (bool);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function approve(address _spender, uint256 _amount) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    function totalSupply() public view returns (uint256);

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool);

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool);

    function finishMinting() public returns (bool);

    function rescueToken(address _foreignTokenAddress, address _to) public;

    function balanceOfAt(address _owner, uint256 _specificTransfersAndMintsIndex) public view returns (uint256);

    function totalSupplyAt(uint256 _specificTransfersAndMintsIndex) public view returns(uint256);

    function enableTransfers(bool _transfersEnabled) public;

    function pauseTransfer(bool _transfersEnabled) public;

    function pauseCapitalIncreaseOrDecrease(bool _mintingEnabled) public;    

    function isMintingPaused() public view returns (bool);

    function mint(address _to, uint256 _amount) public returns (bool);

    function transfer(address _to, uint256 _amount) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);

    function enableTransferInternal(bool _transfersEnabled) internal;

    function reopenCrowdsaleInternal() internal returns (bool);

    function transferFromInternal(address _from, address _to, uint256 _amount) internal returns (bool success);
    function enforcedTransferFromInternal(address _from, address _to, uint256 _value, bool _fullAmountRequired) internal returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event MintDetailed(address indexed initiator, address indexed to, uint256 amount);
    event MintFinished(address indexed initiator);
    event TransferPaused(address indexed initiator);
    event TransferResumed(address indexed initiator);
    event Reopened(address indexed initiator);
    event MetaDataChanged(address indexed initiator, string name, string symbol, address baseCurrency, uint256 cap, uint256 goal);
    event RolesChanged(address indexed initiator, address _pauseControl, address _tokenRescueControl);
    event MintControlChanged(address indexed initiator, address mintControl);
}

// File: contracts/assettoken/BasicAssetToken.sol

/*
    Copyright 2018, CONDA

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





/** @title Basic AssetToken. This contract includes the basic AssetToken features */
contract BasicAssetToken is IBasicAssetTokenFull, Ownable {

    using SafeMath for uint256;
    using AssetTokenL for AssetTokenL.Supply;
    using AssetTokenL for AssetTokenL.Availability;
    using AssetTokenL for AssetTokenL.Roles;

///////////////////
// Variables
///////////////////

    string private _name;
    string private _symbol;

    // The token's name
    function name() public view returns (string memory) {
        return _name;
    }

    // Fixed number of 0 decimals like real world equity
    function decimals() public pure returns (uint8) {
        return 0;
    }

    // An identifier
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // 1000 is version 1
    uint16 public constant version = 2000;

    // Defines the baseCurrency of the token
    address public baseCurrency;

    // Supply: balance, checkpoints etc.
    AssetTokenL.Supply supply;

    // Availability: what's paused
    AssetTokenL.Availability availability;

    // Roles: who is entitled
    AssetTokenL.Roles roles;

///////////////////
// Simple state getters
///////////////////

    function isMintingPaused() public view returns (bool) {
        return availability.mintingPaused;
    }

    function isMintingPhaseFinished() public view returns (bool) {
        return availability.mintingPhaseFinished;
    }

    function getPauseControl() public view returns (address) {
        return roles.pauseControl;
    }

    function getTokenRescueControl() public view returns (address) {
        return roles.tokenRescueControl;
    }

    function getMintControl() public view returns (address) {
        return roles.mintControl;
    }

    function isTransfersPaused() public view returns (bool) {
        return !availability.transfersEnabled;
    }

    function isTokenAlive() public view returns (bool) {
        return availability.tokenAlive;
    }

    function getCap() public view returns (uint256) {
        return supply.cap;
    }

    function getGoal() public view returns (uint256) {
        return supply.goal;
    }

    function getStart() public view returns (uint256) {
        return supply.startTime;
    }

    function getEnd() public view returns (uint256) {
        return supply.endTime;
    }

    function getLimits() public view returns (uint256, uint256, uint256, uint256) {
        return (supply.cap, supply.goal, supply.startTime, supply.endTime);
    }

    function getCurrentHistoryIndex() public view returns (uint256) {
        return supply.tokenActionIndex;
    }

///////////////////
// Events
///////////////////

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event MintDetailed(address indexed initiator, address indexed to, uint256 amount);
    event MintFinished(address indexed initiator);
    event TransferPaused(address indexed initiator);
    event TransferResumed(address indexed initiator);
    event MintingPaused(address indexed initiator);
    event MintingResumed(address indexed initiator);
    event Reopened(address indexed initiator);
    event MetaDataChanged(address indexed initiator, string name, string symbol, address baseCurrency, uint256 cap, uint256 goal);
    event RolesChanged(address indexed initiator, address pauseControl, address tokenRescueControl);
    event MintControlChanged(address indexed initiator, address mintControl);
    event TokenActionIndexIncreased(uint256 tokenActionIndex, uint256 blocknumber);

///////////////////
// Modifiers
///////////////////
    modifier onlyPauseControl() {
        require(msg.sender == roles.pauseControl, "pauseCtrl");
        _;
    }

    //can be overwritten in inherited contracts...
    function _canDoAnytime() internal view returns (bool) {
        return false;
    }

    modifier onlyOwnerOrOverruled() {
        if(_canDoAnytime() == false) { 
            require(isOwner(), "only owner");
        }
        _;
    }

    modifier canMint() {
        if(_canDoAnytime() == false) { 
            require(canMintLogic(), "canMint");
        }
        _;
    }

    function canMintLogic() private view returns (bool) {
        return msg.sender == roles.mintControl && availability.tokenAlive && !availability.mintingPhaseFinished && !availability.mintingPaused;
    }

    //can be overwritten in inherited contracts...
    function checkCanSetMetadata() internal returns (bool) {
        if(_canDoAnytime() == false) {
            require(isOwner(), "owner only");
            require(!availability.tokenAlive, "alive");
            require(!availability.mintingPhaseFinished, "finished");
        }

        return true;
    }

    modifier canSetMetadata() {
        checkCanSetMetadata();
        _;
    }

    modifier onlyTokenAlive() {
        require(availability.tokenAlive, "not alive");
        _;
    }

    modifier onlyTokenRescueControl() {
        require(msg.sender == roles.tokenRescueControl, "rescueCtrl");
        _;
    }

    modifier canTransfer() {
        require(availability.transfersEnabled, "paused");
        _;
    }

///////////////////
// Set / Get Metadata
///////////////////

    /// @notice Change the token's metadata.
    /// @dev Time is via block.timestamp (check crowdsale contract)
    /// @param _nameParam The name of the token.
    /// @param _symbolParam The symbol of the token.
    /// @param _tokenBaseCurrency The base currency.
    /// @param _cap The max amount of tokens that can be minted.
    /// @param _goal The goal of tokens that should be sold.
    /// @param _startTime Time when crowdsale should start.
    /// @param _endTime Time when crowdsale should end.
    function setMetaData(
        string calldata _nameParam, 
        string calldata _symbolParam, 
        address _tokenBaseCurrency, 
        uint256 _cap, 
        uint256 _goal, 
        uint256 _startTime, 
        uint256 _endTime) 
        external 
    canSetMetadata 
    {
        require(_cap >= _goal, "cap higher goal");

        _name = _nameParam;
        _symbol = _symbolParam;

        baseCurrency = _tokenBaseCurrency;
        supply.cap = _cap;
        supply.goal = _goal;
        supply.startTime = _startTime;
        supply.endTime = _endTime;

        emit MetaDataChanged(msg.sender, _nameParam, _symbolParam, _tokenBaseCurrency, _cap, _goal);
    }

    /// @notice Set mint control role. Usually this is CONDA's controller.
    /// @param _mintControl Contract address or wallet that should be allowed to mint.
    function setMintControl(address _mintControl) public canSetMetadata { //ERROR: what on UPGRADE
        roles.setMintControl(_mintControl);
    }

    /// @notice Set roles.
    /// @param _pauseControl address that is allowed to pause.
    /// @param _tokenRescueControl address that is allowed rescue tokens.
    function setRoles(address _pauseControl, address _tokenRescueControl) public 
    canSetMetadata
    {
        roles.setRoles(_pauseControl, _tokenRescueControl);
    }

    function setTokenAlive() public 
    onlyOwnerOrOverruled
    {
        availability.setTokenAlive();
    }

///////////////////
// ERC20 Methods
///////////////////

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public canTransfer returns (bool success) {
        supply.doTransfer(availability, msg.sender, _to, _amount);
        return true;
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition (requires allowance/approval)
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        return transferFromInternal(_from, _to, _amount);
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition (requires allowance/approval)
    /// @dev modifiers in this internal method because also used by features.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFromInternal(address _from, address _to, uint256 _amount) internal canTransfer returns (bool success) {
        return supply.transferFrom(availability, _from, _to, _amount);
    }

    /// @notice balance of `_owner` for this token
    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` now (at the current index)
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return supply.balanceOfNow(_owner);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` of his tokens
    /// @dev This is a modified version of the ERC20 approve function to be a bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        return supply.approve(_spender, _amount);
    }

    /// @notice This method can check how much is approved by `_owner` for `_spender`
    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed to spend
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return supply.allowed[_owner][_spender];
    }

    /// @notice This function makes it easy to get the total number of tokens
    /// @return The total number of tokens now (at current index)
    function totalSupply() public view returns (uint256) {
        return supply.totalSupplyNow();
    }


    /// @notice Increase the amount of tokens that an owner allowed to a spender.
    /// @dev approve should be called when allowed[_spender] == 0. To increment
    /// allowed value is better to use this function to avoid 2 calls (and wait until
    /// the first transaction is mined)
    /// From MonolithDAO Token.sol
    /// @param _spender The address which will spend the funds.
    /// @param _addedValue The amount of tokens to increase the allowance by.
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        return supply.increaseApproval(_spender, _addedValue);
    }

    /// @dev Decrease the amount of tokens that an owner allowed to a spender.
    /// approve should be called when allowed[_spender] == 0. To decrement
    /// allowed value is better to use this function to avoid 2 calls (and wait until
    /// the first transaction is mined)
    /// From MonolithDAO Token.sol
    /// @param _spender The address which will spend the funds.
    /// @param _subtractedValue The amount of tokens to decrease the allowance by.
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        return supply.decreaseApproval(_spender, _subtractedValue);
    }

////////////////
// Miniting 
////////////////

    /// @dev Can rescue tokens accidentally assigned to this contract
    /// @param _to The beneficiary who receives increased balance.
    /// @param _amount The amount of balance increase.
    function mint(address _to, uint256 _amount) public canMint returns (bool) {
        return supply.mint(_to, _amount);
    }

    /// @notice Function to stop minting new tokens
    /// @return True if the operation was successful.
    function finishMinting() public onlyOwnerOrOverruled returns (bool) {
        return availability.finishMinting();
    }

////////////////
// Rescue Tokens 
////////////////

    /// @dev Can rescue tokens accidentally assigned to this contract
    /// @param _foreignTokenAddress The address from which the balance will be retrieved
    /// @param _to beneficiary
    function rescueToken(address _foreignTokenAddress, address _to)
    public
    onlyTokenRescueControl
    {
        availability.rescueToken(_foreignTokenAddress, _to);
    }

////////////////
// Query balance and totalSupply in History
////////////////

    /// @notice Someone's token balance of this token
    /// @dev Queries the balance of `_owner` at `_specificTransfersAndMintsIndex`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _specificTransfersAndMintsIndex The balance at index
    /// @return The balance at `_specificTransfersAndMintsIndex`
    function balanceOfAt(address _owner, uint256 _specificTransfersAndMintsIndex) public view returns (uint256) {
        return supply.balanceOfAt(_owner, _specificTransfersAndMintsIndex);
    }

    /// @notice Total amount of tokens at `_specificTransfersAndMintsIndex`.
    /// @param _specificTransfersAndMintsIndex The totalSupply at index
    /// @return The total amount of tokens at `_specificTransfersAndMintsIndex`
    function totalSupplyAt(uint256 _specificTransfersAndMintsIndex) public view returns(uint256) {
        return supply.totalSupplyAt(_specificTransfersAndMintsIndex);
    }

////////////////
// Enable tokens transfers
////////////////

    /// @dev this function is not public and can be overwritten
    function enableTransferInternal(bool _transfersEnabled) internal {
        availability.pauseTransfer(_transfersEnabled);
    }

    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed
    function enableTransfers(bool _transfersEnabled) public 
    onlyOwnerOrOverruled 
    {
        enableTransferInternal(_transfersEnabled);
    }

////////////////
// Pausing token for unforeseen reasons
////////////////

    /// @dev `pauseTransfer` is an alias for `enableTransfers` using the pauseControl modifier
    /// @param _transfersEnabled False if transfers are allowed
    function pauseTransfer(bool _transfersEnabled) public
    onlyPauseControl
    {
        enableTransferInternal(_transfersEnabled);
    }

    /// @dev `pauseCapitalIncreaseOrDecrease` can pause mint
    /// @param _mintingEnabled False if minting is allowed
    function pauseCapitalIncreaseOrDecrease(bool _mintingEnabled) public
    onlyPauseControl
    {
        availability.pauseCapitalIncreaseOrDecrease(_mintingEnabled);
    }

    /// @dev capitalControl (if exists) can reopen the crowdsale.
    /// this function is not public and can be overwritten
    function reopenCrowdsaleInternal() internal returns (bool) {
        return availability.reopenCrowdsale();
    }

    /// @dev capitalControl (if exists) can enforce a transferFrom e.g. in case of lost wallet.
    /// this function is not public and can be overwritten
    function enforcedTransferFromInternal(address _from, address _to, uint256 _value, bool _fullAmountRequired) internal returns (bool) {
        return supply.enforcedTransferFrom(availability, _from, _to, _value, _fullAmountRequired);
    }
}

// File: contracts/assettoken/interfaces/ICRWDController.sol

interface ICRWDController {
    function transferParticipantsVerification(address _underlyingCurrency, address _from, address _to, uint256 _amount) external returns (bool); //from AssetToken
}

// File: contracts/assettoken/interfaces/IGlobalIndex.sol

interface IGlobalIndex {
    function getControllerAddress() external view returns (address);
    function setControllerAddress(address _newControllerAddress) external;
}

// File: contracts/assettoken/abstract/ICRWDAssetToken.sol

contract ICRWDAssetToken is IBasicAssetTokenFull {
    function setGlobalIndexAddress(address _globalIndexAddress) public;
}

// File: contracts/assettoken/CRWDAssetToken.sol

/*
    Copyright 2018, CONDA

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






/** @title CRWD AssetToken. This contract inherits basic functionality and extends calls to controller. */
contract CRWDAssetToken is BasicAssetToken, ICRWDAssetToken {

    using SafeMath for uint256;

    IGlobalIndex public globalIndex;

    function getControllerAddress() public view returns (address) {
        return globalIndex.getControllerAddress();
    }

    /** @dev ERC20 transfer function overlay to transfer tokens and call controller.
      * @param _to The recipient address.
      * @param _amount The amount.
      * @return A boolean that indicates if the operation was successful.
      */
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        ICRWDController(getControllerAddress()).transferParticipantsVerification(baseCurrency, msg.sender, _to, _amount);
        return super.transfer(_to, _amount);
    }

    /** @dev ERC20 transferFrom function overlay to transfer tokens and call controller.
      * @param _from The sender address (requires approval).
      * @param _to The recipient address.
      * @param _amount The amount.
      * @return A boolean that indicates if the operation was successful.
      */
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        ICRWDController(getControllerAddress()).transferParticipantsVerification(baseCurrency, _from, _to, _amount);
        return super.transferFrom(_from, _to, _amount);
    }

    /** @dev Mint function overlay to mint/create tokens.
      * @param _to The address that will receive the minted tokens.
      * @param _amount The amount of tokens to mint.
      * @return A boolean that indicates if the operation was successful.
      */
    function mint(address _to, uint256 _amount) public canMint returns (bool) {
        return super.mint(_to,_amount);
    }

    /** @dev Set address of GlobalIndex.
      * @param _globalIndexAddress Address to be used for current destination e.g. controller lookup.
      */
    function setGlobalIndexAddress(address _globalIndexAddress) public onlyOwner {
        globalIndex = IGlobalIndex(_globalIndexAddress);
    }
}

// File: contracts/assettoken/feature/FeatureCapitalControl.sol

/*
    Copyright 2018, CONDA

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


/** @title FeatureCapitalControl. */
contract FeatureCapitalControl is ICRWDAssetToken {
    
////////////////
// Variables
////////////////

    //if set can mint after finished. E.g. a notary.
    address public capitalControl;

////////////////
// Constructor
////////////////

    constructor(address _capitalControl) public {
        capitalControl = _capitalControl;
        enableTransferInternal(false); //disable transfer as default
    }

////////////////
// Modifiers
////////////////

    //override: skip certain modifier checks as capitalControl
    function _canDoAnytime() internal view returns (bool) {
        return msg.sender == capitalControl;
    }

    modifier onlyCapitalControl() {
        require(msg.sender == capitalControl, "permission");
        _;
    }

////////////////
// Functions
////////////////

    /// @notice set capitalControl
    /// @dev this looks unprotected but has a checkCanSetMetadata check.
    ///  depending on inheritance this can be done 
    ///  before alive and any time by capitalControl
    function setCapitalControl(address _capitalControl) public {
        require(checkCanSetMetadata(), "forbidden");

        capitalControl = _capitalControl;
    }

    /// @notice as capital control I can pass my ownership to a new address (e.g. private key leaked).
    /// @param _capitalControl new capitalControl address
    function updateCapitalControl(address _capitalControl) public onlyCapitalControl {
        capitalControl = _capitalControl;
    }

////////////////
// Reopen crowdsale (by capitalControl e.g. notary)
////////////////

    /// @notice capitalControl can reopen the crowdsale.
    function reopenCrowdsale() public onlyCapitalControl returns (bool) {        
        return reopenCrowdsaleInternal();
    }
}

// File: contracts/assettoken/feature/FeatureCapitalControlWithForcedTransferFrom.sol

/*
    Copyright 2018, CONDA

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



/** @title FeatureCapitalControlWithForcedTransferFrom. */
contract FeatureCapitalControlWithForcedTransferFrom is FeatureCapitalControl {

///////////////////
// Constructor
///////////////////

    constructor(address _capitalControl) FeatureCapitalControl(_capitalControl) public { }

///////////////////
// Events
///////////////////

    event SelfApprovedTransfer(address indexed initiator, address indexed from, address indexed to, uint256 value);


///////////////////
// Overrides
///////////////////

    //override: transferFrom that has special self-approve behaviour when executed as capitalControl
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
    {
        if (msg.sender == capitalControl) {
            return enforcedTransferFromInternal(_from, _to, _value, true);
        } else {
            return transferFromInternal(_from, _to, _value);
        }
    }

}

// File: contracts/assettoken/STOs/AssetTokenT001.sol

/** @title AssetTokenT001 Token. A CRWDAssetToken with CapitalControl and LostWallet feature */
contract AssetTokenT001 is CRWDAssetToken, FeatureCapitalControlWithForcedTransferFrom
{    
    constructor(address _capitalControl) FeatureCapitalControlWithForcedTransferFrom(_capitalControl) public {}
}
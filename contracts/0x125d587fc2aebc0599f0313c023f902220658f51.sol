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

// File: contracts/crowdsale/interfaces/IGlobalIndex.sol

interface IGlobalIndex {
    function getControllerAddress() external view returns (address);
    function setControllerAddress(address _newControllerAddress) external;
}

// File: contracts/crowdsale/interfaces/ICRWDController.sol

interface ICRWDController {
    function buyFromCrowdsale(address _to, uint256 _amountInWei) external returns (uint256 _tokensCreated, uint256 _overpaidRefund); //from Crowdsale
    function assignFromCrowdsale(address _to, uint256 _tokenAmount, bytes8 _tag) external returns (uint256 _tokensCreated); //from Crowdsale
    function calcTokensForEth(uint256 _amountInWei) external view returns (uint256 _tokensWouldBeCreated); //from Crowdsale
}

// File: openzeppelin-solidity/contracts/ownership/Secondary.sol

/**
 * @title Secondary
 * @dev A Secondary contract can only be used by its primary account (the one that created it)
 */
contract Secondary {
    address private _primary;

    event PrimaryTransferred(
        address recipient
    );

    /**
     * @dev Sets the primary account to the one that is creating the Secondary contract.
     */
    constructor () internal {
        _primary = msg.sender;
        emit PrimaryTransferred(_primary);
    }

    /**
     * @dev Reverts if called from any account other than the primary.
     */
    modifier onlyPrimary() {
        require(msg.sender == _primary);
        _;
    }

    /**
     * @return the address of the primary.
     */
    function primary() public view returns (address) {
        return _primary;
    }

    /**
     * @dev Transfers contract to a new primary.
     * @param recipient The address of new primary.
     */
    function transferPrimary(address recipient) public onlyPrimary {
        require(recipient != address(0));
        _primary = recipient;
        emit PrimaryTransferred(_primary);
    }
}

// File: openzeppelin-solidity/contracts/payment/escrow/Escrow.sol

/**
 * @title Escrow
 * @dev Base escrow contract, holds funds designated for a payee until they
 * withdraw them.
 * @dev Intended usage: This contract (and derived escrow contracts) should be a
 * standalone contract, that only interacts with the contract that instantiated
 * it. That way, it is guaranteed that all Ether will be handled according to
 * the Escrow rules, and there is no need to check for payable functions or
 * transfers in the inheritance tree. The contract that uses the escrow as its
 * payment method should be its primary, and provide public methods redirecting
 * to the escrow's deposit and withdraw.
 */
contract Escrow is Secondary {
    using SafeMath for uint256;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    /**
    * @dev Stores the sent amount as credit to be withdrawn.
    * @param payee The destination address of the funds.
    */
    function deposit(address payee) public onlyPrimary payable {
        uint256 amount = msg.value;
        _deposits[payee] = _deposits[payee].add(amount);

        emit Deposited(payee, amount);
    }

    /**
    * @dev Withdraw accumulated balance for a payee.
    * @param payee The address whose funds will be withdrawn and transferred to.
    */
    function withdraw(address payable payee) public onlyPrimary {
        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.transfer(payment);

        emit Withdrawn(payee, payment);
    }
}

// File: openzeppelin-solidity/contracts/payment/escrow/ConditionalEscrow.sol

/**
 * @title ConditionalEscrow
 * @dev Base abstract escrow to only allow withdrawal if a condition is met.
 * @dev Intended usage: See Escrow.sol. Same usage guidelines apply here.
 */
contract ConditionalEscrow is Escrow {
    /**
    * @dev Returns whether an address is allowed to withdraw their funds. To be
    * implemented by derived contracts.
    * @param payee The destination address of the funds.
    */
    function withdrawalAllowed(address payee) public view returns (bool);

    function withdraw(address payable payee) public {
        require(withdrawalAllowed(payee));
        super.withdraw(payee);
    }
}

// File: openzeppelin-solidity/contracts/payment/escrow/RefundEscrow.sol

/**
 * @title RefundEscrow
 * @dev Escrow that holds funds for a beneficiary, deposited from multiple
 * parties.
 * @dev Intended usage: See Escrow.sol. Same usage guidelines apply here.
 * @dev The primary account (that is, the contract that instantiates this
 * contract) may deposit, close the deposit period, and allow for either
 * withdrawal by the beneficiary, or refunds to the depositors. All interactions
 * with RefundEscrow will be made through the primary contract. See the
 * RefundableCrowdsale contract for an example of RefundEscrow’s use.
 */
contract RefundEscrow is ConditionalEscrow {
    enum State { Active, Refunding, Closed }

    event RefundsClosed();
    event RefundsEnabled();

    State private _state;
    address payable private _beneficiary;

    /**
     * @dev Constructor.
     * @param beneficiary The beneficiary of the deposits.
     */
    constructor (address payable beneficiary) public {
        require(beneficiary != address(0));
        _beneficiary = beneficiary;
        _state = State.Active;
    }

    /**
     * @return the current state of the escrow.
     */
    function state() public view returns (State) {
        return _state;
    }

    /**
     * @return the beneficiary of the escrow.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @dev Stores funds that may later be refunded.
     * @param refundee The address funds will be sent to if a refund occurs.
     */
    function deposit(address refundee) public payable {
        require(_state == State.Active);
        super.deposit(refundee);
    }

    /**
     * @dev Allows for the beneficiary to withdraw their funds, rejecting
     * further deposits.
     */
    function close() public onlyPrimary {
        require(_state == State.Active);
        _state = State.Closed;
        emit RefundsClosed();
    }

    /**
     * @dev Allows for refunds to take place, rejecting further deposits.
     */
    function enableRefunds() public onlyPrimary {
        require(_state == State.Active);
        _state = State.Refunding;
        emit RefundsEnabled();
    }

    /**
     * @dev Withdraws the beneficiary's funds.
     */
    function beneficiaryWithdraw() public {
        require(_state == State.Closed);
        _beneficiary.transfer(address(this).balance);
    }

    /**
     * @dev Returns whether refundees can withdraw their deposits (be refunded). The overriden function receives a
     * 'payee' argument, but we ignore it here since the condition is global, not per-payee.
     */
    function withdrawalAllowed(address) public view returns (bool) {
        return _state == State.Refunding;
    }
}

// File: contracts/crowdsale/library/CrowdsaleL.sol

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






/** @title CrowdsaleL library. */
library CrowdsaleL {
    using SafeMath for uint256;

///////////////////
// Structs
///////////////////

    /// @dev All crowdsale states.
    enum State { Draft, Started, Ended, Finalized, Refunding, Closed }

    struct Data {
        // The token being sold type ERC20
        address token;

        // status of crowdsale
        State state;

        // the max cap of tokens being sold
        uint256 cap;

        // the start time of crowdsale.
        uint256 startTime;
        
        // the end time of crowdsale
        uint256 endTime;

        // address where funds are collected
        address payable wallet;

        // the global index holding contract addresses
        IGlobalIndex globalIndex;

        // amount of tokens raised by money in all allowed currencies
        uint256 tokensRaised;
    }

    struct Roles {
        // can assign tokens on off-chain payments
        address tokenAssignmentControl;

        // role that can rescue accidentally sent tokens
        address tokenRescueControl;
    }

///////////////////
// Functions
///////////////////

    /// @notice Initialize function for initial setup (during construction).
    /// @param _assetToken The asset token being sold.
    function init(Data storage _self, address _assetToken) public {
        _self.token = _assetToken;
        _self.state = State.Draft;
    }

    /// @notice Confiugure function for setup (during negotiations).
    /// @param _wallet beneficiary wallet on successful crowdsale.
    /// @param _globalIndex the contract holding current contract addresses.
    function configure(
        Data storage _self, 
        address payable _wallet, 
        address _globalIndex)
    public 
    {
        require(_self.state == CrowdsaleL.State.Draft, "not draft state");
        require(_wallet != address(0), "wallet zero addr");
        require(_globalIndex != address(0), "globalIdx zero addr");

        _self.wallet = _wallet;
        _self.globalIndex = IGlobalIndex(_globalIndex);

        emit CrowdsaleConfigurationChanged(_wallet, _globalIndex);
    }

    /// @notice Set roles/operators.
    /// @param _tokenAssignmentControl token assignment control (off-chain payment).
    /// @param _tokenRescueControl token rescue control (accidentally assigned tokens).
    function setRoles(Roles storage _self, address _tokenAssignmentControl, address _tokenRescueControl) public {
        require(_tokenAssignmentControl != address(0), "addr0");
        require(_tokenRescueControl != address(0), "addr0");
        
        _self.tokenAssignmentControl = _tokenAssignmentControl;
        _self.tokenRescueControl = _tokenRescueControl;

        emit RolesChanged(msg.sender, _tokenAssignmentControl, _tokenRescueControl);
    }

    /// @notice gets current controller address.
    function getControllerAddress(Data storage _self) public view returns (address) {
        return IGlobalIndex(_self.globalIndex).getControllerAddress();
    }

    /// @dev gets controller with interface for internal use.
    function getController(Data storage _self) private view returns (ICRWDController) {
        return ICRWDController(getControllerAddress(_self));
    }

    /// @notice set cap.
    /// @param _cap token cap of tokens being sold.
    function setCap(Data storage _self, uint256 _cap) public {
        // require(requireActiveOrDraftState(_self), "require active/draft"); // No! Could have been changed by AT owner...
        // require(_cap > 0, "cap 0"); // No! Decided by AssetToken owner...
        _self.cap = _cap;
    }

    /// @notice Low level token purchase function with ether.
    /// @param _beneficiary who receives tokens.
    /// @param _investedAmount the invested ETH amount.
    function buyTokensFor(Data storage _self, address _beneficiary, uint256 _investedAmount) 
    public 
    returns (uint256)
    {
        require(validPurchasePreCheck(_self), "invalid purchase precheck");

        (uint256 tokenAmount, uint256 overpaidRefund) = getController(_self).buyFromCrowdsale(_beneficiary, _investedAmount);

        if(tokenAmount == 0) {
            // Special handling full refund if too little ETH (could be small drift depending on off-chain API accuracy)
            overpaidRefund = _investedAmount;
        }

        require(validPurchasePostCheck(_self, tokenAmount), "invalid purchase postcheck");
        _self.tokensRaised = _self.tokensRaised.add(tokenAmount);

        emit TokenPurchase(msg.sender, _beneficiary, tokenAmount, overpaidRefund, "ETH");

        return overpaidRefund;
    }

    /// @dev Fails if not active or draft state
    function requireActiveOrDraftState(Data storage _self) public view returns (bool) {
        require((_self.state == State.Draft) || (_self.state == State.Started), "only active or draft state");

        return true;
    }

    /// @notice Valid start basic logic.
    /// @dev In contract could be extended logic e.g. checking goal)
    function validStart(Data storage _self) public view returns (bool) {
        require(_self.wallet != address(0), "wallet is zero addr");
        require(_self.token != address(0), "token is zero addr");
        require(_self.cap > 0, "cap is 0");
        require(_self.startTime != 0, "time not set");
        require(now >= _self.startTime, "too early");

        return true;
    }

    /// @notice Set the timeframe.
    /// @param _startTime the start time of crowdsale.
    /// @param _endTime the end time of crowdsale.
    function setTime(Data storage _self, uint256 _startTime, uint256 _endTime) public
    {
        _self.startTime = _startTime;
        _self.endTime = _endTime;

        emit CrowdsaleTimeChanged(_startTime, _endTime);
    }

    /// @notice crowdsale has ended check.
    /// @dev Same code if goal is used.
    /// @return true if crowdsale event has ended
    function hasEnded(Data storage _self) public view returns (bool) {
        bool capReached = _self.tokensRaised >= _self.cap; 
        bool endStateReached = (_self.state == CrowdsaleL.State.Ended || _self.state == CrowdsaleL.State.Finalized || _self.state == CrowdsaleL.State.Closed || _self.state == CrowdsaleL.State.Refunding);
        
        return endStateReached || capReached || now > _self.endTime;
    }

    /// @notice Set from finalized to state closed.
    /// @dev Must be called to close the crowdsale manually
    function closeCrowdsale(Data storage _self) public {
        require((_self.state == State.Finalized) || (_self.state == State.Refunding), "state");

        _self.state = State.Closed;
    }

    /// @notice Checks if valid purchase before other ecosystem contracts roundtrip (fail early).
    /// @return true if the transaction can buy tokens
    function validPurchasePreCheck(Data storage _self) private view returns (bool) {
        require(_self.state == State.Started, "not in state started");
        bool withinPeriod = now >= _self.startTime && _self.endTime >= now;
        require(withinPeriod, "not within period");

        return true;
    }

    /// @notice Checks if valid purchase after other ecosystem contracts roundtrip (double check).
    /// @return true if the transaction can buy tokens
    function validPurchasePostCheck(Data storage _self, uint256 _tokensCreated) private view returns (bool) {
        require(_self.state == State.Started, "not in state started");
        bool withinCap = _self.tokensRaised.add(_tokensCreated) <= _self.cap; 
        require(withinCap, "not within cap");

        return true;
    }

    /// @notice simple token assignment.
    function assignTokens(
        Data storage _self, 
        address _beneficiaryWallet, 
        uint256 _tokenAmount, 
        bytes8 _tag) 
        public returns (uint256 _tokensCreated)
    {
        _tokensCreated = getController(_self).assignFromCrowdsale(
            _beneficiaryWallet, 
            _tokenAmount,
            _tag);
        
        emit TokenPurchase(msg.sender, _beneficiaryWallet, _tokensCreated, 0, _tag);

        return _tokensCreated;
    }

    /// @notice calc how much tokens you would receive for given ETH amount (all in unit WEI)
    /// @dev no view keyword even if it SHOULD not change the state. But let's not trust other contracts...
    function calcTokensForEth(Data storage _self, uint256 _ethAmountInWei) public view returns (uint256 _tokensWouldBeCreated) {
        return getController(_self).calcTokensForEth(_ethAmountInWei);
    }

    /// @notice If this contract gets a balance in some other ERC20 contract - or even iself - then we can rescue it.
    /// @param _foreignTokenAddress token where contract has balance.
    /// @param _to the beneficiary.
    function rescueToken(Data storage _self, address _foreignTokenAddress, address _to) public
    {
        ERC20(_foreignTokenAddress).transfer(_to, ERC20(_foreignTokenAddress).balanceOf(address(this)));
    }

///////////////////
// Events (must be redundant in calling contract to work!)
///////////////////

    event TokenPurchase(address indexed invoker, address indexed beneficiary, uint256 tokenAmount, uint256 overpaidRefund, bytes8 tag);
    event CrowdsaleTimeChanged(uint256 startTime, uint256 endTime);
    event CrowdsaleConfigurationChanged(address wallet, address globalIndex);
    event RolesChanged(address indexed initiator, address tokenAssignmentControl, address tokenRescueControl);
}

// File: contracts/crowdsale/library/VaultGeneratorL.sol

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


/** @title VaultGeneratorL library. */
library VaultGeneratorL {

    /// @notice generate RefundEscrow vault.
    /// @param _wallet beneficiary on success.
    /// @return vault address that can be casted to interface.
    function generateEthVault(address payable _wallet) public returns (address ethVaultInterface) {
        return address(new RefundEscrow(_wallet));
    }
}

// File: contracts/crowdsale/interfaces/IBasicAssetToken.sol

interface IBasicAssetToken {
    //AssetToken specific
    function getLimits() external view returns (uint256, uint256, uint256, uint256);
    function isTokenAlive() external view returns (bool);

    //Mintable
    function mint(address _to, uint256 _amount) external returns (bool);
    function finishMinting() external returns (bool);
}

// File: contracts/crowdsale/interface/EthVaultInterface.sol

/**
 * Based on OpenZeppelin RefundEscrow.sol
 */
interface EthVaultInterface {

    event Closed();
    event RefundsEnabled();

    /// @dev Stores funds that may later be refunded.
    /// @param _refundee The address funds will be sent to if a refund occurs.
    function deposit(address _refundee) external payable;

    /// @dev Allows for the beneficiary to withdraw their funds, rejecting
    /// further deposits.
    function close() external;

    /// @dev Allows for refunds to take place, rejecting further deposits.
    function enableRefunds() external;

    /// @dev Withdraws the beneficiary's funds.
    function beneficiaryWithdraw() external;

    /// @dev Returns whether refundees can withdraw their deposits (be refunded).
    function withdrawalAllowed(address _payee) external view returns (bool);

    /// @dev Withdraw what someone paid into vault.
    function withdraw(address _payee) external;
}

// File: contracts/crowdsale/BasicAssetTokenCrowdsaleNoFeature.sol

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








/** @title BasicCompanyCrowdsale. Investment is stored in vault and forwarded to wallet on end. */
contract BasicAssetTokenCrowdsaleNoFeature is Ownable {
    using SafeMath for uint256;
    using CrowdsaleL for CrowdsaleL.Data;
    using CrowdsaleL for CrowdsaleL.Roles;

    /**
    * Crowdsale process has the following steps:
    *   1) startCrowdsale
    *   2) buyTokens
    *   3) endCrowdsale
    *   4) finalizeCrowdsale
    */

///////////////////
// Variables
///////////////////

    CrowdsaleL.Data crowdsaleData;
    CrowdsaleL.Roles roles;

///////////////////
// Constructor
///////////////////

    constructor(address _assetToken) public {
        crowdsaleData.init(_assetToken);
    }

///////////////////
// Modifier
///////////////////

    modifier onlyTokenRescueControl() {
        require(msg.sender == roles.tokenRescueControl, "rescueCtrl");
        _;
    }

///////////////////
// Simple state getters
///////////////////

    function token() public view returns (address) {
        return crowdsaleData.token;
    }

    function wallet() public view returns (address) {
        return crowdsaleData.wallet;
    }

    function tokensRaised() public view returns (uint256) {
        return crowdsaleData.tokensRaised;
    }

    function cap() public view returns (uint256) {
        return crowdsaleData.cap;
    }

    function state() public view returns (CrowdsaleL.State) {
        return crowdsaleData.state;
    }

    function startTime() public view returns (uint256) {
        return crowdsaleData.startTime;
    }

    function endTime() public view returns (uint256) {
        return crowdsaleData.endTime;
    }

    function getControllerAddress() public view returns (address) {
        return address(crowdsaleData.getControllerAddress());
    }

///////////////////
// Events
///////////////////

    event TokenPurchase(address indexed invoker, address indexed beneficiary, uint256 tokenAmount, uint256 overpaidRefund, bytes8 tag);
    event CrowdsaleTimeChanged(uint256 startTime, uint256 endTime);
    event CrowdsaleConfigurationChanged(address wallet, address globalIndex);
    event RolesChanged(address indexed initiator, address tokenAssignmentControl, address tokenRescueControl);
    event Started();
    event Ended();
    event Finalized();

///////////////////
// Modifiers
///////////////////

    modifier onlyTokenAssignmentControl() {
        require(_isTokenAssignmentControl(), "only tokenAssignmentControl");
        _;
    }

    modifier onlyDraftState() {
        require(crowdsaleData.state == CrowdsaleL.State.Draft, "only draft state");
        _;
    }

    modifier onlyActive() {
        require(_isActive(), "only when active");
        _;
    }

    modifier onlyActiveOrDraftState() {
        require(_isActiveOrDraftState(), "only active/draft");
        _;
    }

    modifier onlyUnfinalized() {
        require(crowdsaleData.state != CrowdsaleL.State.Finalized, "only unfinalized");
        _;
    }

    /**
    * @dev is crowdsale active or draft state that can be overriden.
    */
    function _isActiveOrDraftState() internal view returns (bool) {
        return crowdsaleData.requireActiveOrDraftState();
    }

    /**
    * @dev is token assignmentcontrol that can be overriden.
    */
    function _isTokenAssignmentControl() internal view returns (bool) {
        return msg.sender == roles.tokenAssignmentControl;
    }

    /**
    * @dev is active check that can be overriden.
    */
    function _isActive() internal view returns (bool) {
        return crowdsaleData.state == CrowdsaleL.State.Started;
    }
 
///////////////////
// Status Draft
///////////////////

    /// @notice set required data like wallet and global index.
    /// @param _wallet beneficiary of crowdsale.
    /// @param _globalIndex global index contract holding up2date contract addresses.
    function setCrowdsaleData(
        address payable _wallet,
        address _globalIndex)
    public
    onlyOwner 
    {
        crowdsaleData.configure(_wallet, _globalIndex);
    }

    /// @notice get token AssignmenControl who can assign tokens (off-chain payments).
    function getTokenAssignmentControl() public view returns (address) {
        return roles.tokenAssignmentControl;
    }

    /// @notice get token RescueControl who can rescue accidentally assigned tokens to this contract.
    function getTokenRescueControl() public view returns (address) {
        return roles.tokenRescueControl;
    }

    /// @notice set cap. That's the limit how much is accepted.
    /// @param _cap the cap in unit token (minted AssetToken)
    function setCap(uint256 _cap) internal onlyUnfinalized {
        crowdsaleData.setCap(_cap);
    }

    /// @notice set roles/operators.
    /// @param _tokenAssignmentControl can assign tokens (off-chain payments).
    /// @param _tokenRescueControl address that is allowed rescue tokens.
    function setRoles(address _tokenAssignmentControl, address _tokenRescueControl) public onlyOwner {
        roles.setRoles(_tokenAssignmentControl, _tokenRescueControl);
    }

    /// @notice set crowdsale timeframe.
    /// @param _startTime crowdsale start time.
    /// @param _endTime crowdsale end time.
    function setCrowdsaleTime(uint256 _startTime, uint256 _endTime) internal onlyUnfinalized {
        // require(_startTime >= now, "starTime in the past"); //when getting from AT that is possible
        require(_endTime >= _startTime, "endTime smaller start");

        crowdsaleData.setTime(_startTime, _endTime);
    }

    /// @notice Update metadata like cap, time etc. from AssetToken.
    /// @dev It is essential that this method is at least called before start and before end.
    function updateFromAssetToken() public {
        (uint256 _cap, /*goal*/, uint256 _startTime, uint256 _endTime) = IBasicAssetToken(crowdsaleData.token).getLimits();
        setCap(_cap);
        setCrowdsaleTime(_startTime, _endTime);
    }

///
// Status Started
///

    /// @notice checks all variables and starts crowdsale
    function startCrowdsale() public onlyDraftState {
        updateFromAssetToken(); //IMPORTANT
        
        require(validStart(), "validStart");
        prepareStart();
        crowdsaleData.state = CrowdsaleL.State.Started;
        emit Started();
    }

    /// @dev Calc how many tokens you would receive for given ETH amount (all in unit WEI)
    function calcTokensForEth(uint256 _ethAmountInWei) public view returns (uint256 _tokensWouldBeCreated) {
        return crowdsaleData.calcTokensForEth(_ethAmountInWei);
    }

    /// @dev Can be overridden to add start validation logic. The overriding function
    ///  should call super.validStart() to ensure the chain of validation is
    ///  executed entirely.
    function validStart() internal view returns (bool) {
        return crowdsaleData.validStart();
    }

    /// @dev Can be overridden to add preparation logic. The overriding function
    ///  should call super.prepareStart() to ensure the chain of finalization is
    ///  executed entirely.
    function prepareStart() internal {
    }

    /// @dev Determines how ETH is stored/forwarded on purchases.
    /// @param _overpaidRefund overpaid ETH amount (because AssetToken is 0 decimals)
    function forwardWeiFunds(uint256 _overpaidRefund) internal {
        require(_overpaidRefund <= msg.value, "unrealistic overpay");
        crowdsaleData.wallet.transfer(msg.value.sub(_overpaidRefund));
        
        //send overpayment back to sender. notice: only safe because executed in the end!
        msg.sender.transfer(_overpaidRefund);
    }

///
// Status Ended
///

    /// @dev Can be called by owner to end the crowdsale manually
    function endCrowdsale() public onlyOwner onlyActive {
        updateFromAssetToken();

        crowdsaleData.state = CrowdsaleL.State.Ended;

        emit Ended();
    }


///
// Status Finalized
///

    /// @dev Must be called after crowdsale ends, to do some extra finalization.
    function finalizeCrowdsale() public {
        updateFromAssetToken(); //IMPORTANT

        require(crowdsaleData.state == CrowdsaleL.State.Ended || crowdsaleData.state == CrowdsaleL.State.Started, "state");
        require(hasEnded(), "not ended");
        crowdsaleData.state = CrowdsaleL.State.Finalized;
        
        finalization();
        emit Finalized();
    }

    /// @notice status if crowdsale has ended yet.
    /// @return true if crowdsale event has ended.
    function hasEnded() public view returns (bool) {
        return crowdsaleData.hasEnded();
    }

    /// @dev Can be overridden to add finalization logic. The overriding function
    ///  should call super.finalization() to ensure the chain of finalization is
    ///  executed entirely.
    function finalization() internal {
    }
    
///
// Status Closed
///

    /// @dev Must be called to close the crowdsale manually. The overriding function
    /// should call super.closeCrowdsale()
    function closeCrowdsale() public onlyOwner {
        crowdsaleData.closeCrowdsale();
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
        crowdsaleData.rescueToken(_foreignTokenAddress, _to);
    }
}

// File: contracts/crowdsale/feature/AssignTokensOffChainPaymentFeature.sol

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

/** @title AssignTokensOffChainPaymentFeature that if inherited adds possibility mintFor(investorXY) without ETH payment. */
contract AssignTokensOffChainPaymentFeature {

///////////////////
// Modifiers
///////////////////

    modifier assignTokensPrerequisit {
        require(_assignTokensPrerequisit(), "assign prerequisit");
        _;
    }

///////////////////
// Functions
///////////////////

    /// @notice If entitled call this method to assign tokens to beneficiary (use case: off-chain payment)
    /// @dev Token amount is assigned unmodified (no rate etc. on top)
    function assignTokensOffChainPayment(
        address _beneficiaryWallet, 
        uint256 _tokenAmount,
        bytes8 _tag) 
        public 
        assignTokensPrerequisit
    {
        _assignTokensOffChainPaymentAct(_beneficiaryWallet, _tokenAmount, _tag);
    }

///////////////////
// Functions to override
///////////////////

    /// @dev Checks prerequisits (e.g. if active/draft crowdsale, permission) ***MUST OVERRIDE***
    function _assignTokensPrerequisit() internal view returns (bool) {
        revert("override assignTokensPrerequisit");
    }

    /// @dev Assign tokens act ***MUST OVERRIDE***
    function _assignTokensOffChainPaymentAct(address /*_beneficiaryWallet*/, uint256 /*_tokenAmount*/, bytes8 /*_tag*/) 
        internal returns (bool)
    {
        revert("override buyTokensWithEtherAct");
    }
}

// File: contracts/crowdsale/STOs/AssetTokenCrowdsaleT001.sol

/// @title AssetTokenCrowdsaleT001. Functionality of BasicAssetTokenNoFeatures with the AssignTokensOffChainPaymentFeature feature.
contract AssetTokenCrowdsaleT001 is BasicAssetTokenCrowdsaleNoFeature, AssignTokensOffChainPaymentFeature {

///////////////////
// Constructor
///////////////////

    constructor(address _assetToken) public BasicAssetTokenCrowdsaleNoFeature(_assetToken) {

    }

///////////////////
// Feature functions internal overrides
///////////////////

    /// @dev override of assign tokens prerequisit of possible features.
    function _assignTokensPrerequisit() internal view returns (bool) {
        return (_isTokenAssignmentControl() && _isActiveOrDraftState());
    }

    /// @dev method executed on assign tokens because of off-chain payment (if feature is inherited).
    function _assignTokensOffChainPaymentAct(address _beneficiaryWallet, uint256 _tokenAmount, bytes8 _tag)
        internal returns (bool) 
    {
        crowdsaleData.assignTokens(_beneficiaryWallet, _tokenAmount, _tag);
        return true;
    }
}
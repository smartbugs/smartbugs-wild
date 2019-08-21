pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 *
 * Subtraction and addition only here.
 */
library SafeMath {

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
}

/**
 * @title A contract for generating unique identifiers for any requests.
 * @dev Any contract that supports requesting inherits this contract to
 * ensure request to be unique.
 */
contract RequestUid {

    /**
     * MEMBER: counter for request.
    */
    uint256 public requestCount;

    /**
     * CONSTRUCTOR: initial counter with 0.
     */
    constructor() public {
        requestCount = 0;
    }
    
    /**
     * METHOD: generate a new identifier.
     * @dev 3 parameters as inputs:
     * 1. blockhash of previous block;
     * 2. the address of the initialized contract which is requested;
     * 3. the value of counter.
     * @return a 32-byte uid.
     */
    function generateRequestUid() internal returns (bytes32 uid) {
        return keccak256(abi.encodePacked(blockhash(block.number - uint256(1)), address(this), ++requestCount));
    }
}

/**
 * @dev This contract makes the inheritor have the functionality if the
 * inheritor authorize the admin.
 */
contract AdminUpgradeable is RequestUid {
    
    /**
     * Event
     * @dev After requesting of admin change, emit an event.
     */
    event AdminChangeRequested(bytes32 _uid, address _msgSender, address _newAdmin);
    
    /**
     * Event
     * @dev After confirming a request of admin change, emit an event.
     */
    event AdminChangeConfirmed(bytes32 _uid, address _newAdmin);
    
    /**
     * STRUCT: A struct defined to store an request of admin change.
     */
    struct AdminChangeRequest {
        address newAdminAddress;
    }
    
    /**
     * MEMBER: admin address(account address or contract address) which
     * is authorize by the inheritor.
     */
    address public admin;
    
    /**
     * MEMBER: a list of requests submitted.
     */
    mapping (bytes32 => AdminChangeRequest) public adminChangeReqs;
    
    /**
     * MODIFIER: The operations from admin is allowed only.
     */
    modifier adminOperations {
        require(msg.sender == admin, "admin can call this method only");
        _;
    }
    
    /**
     * CONSTRUCTOR: Initialize with an admin address.
     */
    constructor (address _admin) public RequestUid() {
        admin = _admin;
    }
    
    /**
     * METHOD: Upgrade the admin ---- request.
     * @dev Request changing the admin address authorized.
     * Anyone can call this method to submit a request to change
     * the admin address. It will be pending until admin address
     * comfirming the request, and the admin changes.
     * @param _newAdmin The address of new admin, account or contract.
     * @return uid The unique id of the request.
     */
    function requestAdminChange(address _newAdmin) public returns (bytes32 uid) {
        require(_newAdmin != address(0), "admin is not 0 address");

        uid = generateRequestUid();

        adminChangeReqs[uid] = AdminChangeRequest({
            newAdminAddress: _newAdmin
            });

        emit AdminChangeRequested(uid, msg.sender, _newAdmin);
    }
    
    /**
     * METHOD: Upgrade the admin ---- confirm.
     * @dev Confirm a reqeust of admin change storing in the mapping
     * of `adminChangeReqs`. The operation is authorized to the old
     * admin only. The new admin will be authorized after the method
     * called successfully.
     * @param _uid The uid of request to change admin.
     */
    function confirmAdminChange(bytes32 _uid) public adminOperations {
        admin = getAdminChangeReq(_uid);

        delete adminChangeReqs[_uid];

        emit AdminChangeConfirmed(_uid, admin);
    }
    
    /**
     * METHOD: Get the address of an admin request by uid.
     * @dev It is a private method which gets address of an admin
     * in the mapping `adminChangeReqs`
     * @param _uid The uid of request to change admin.
     * @return _newAdminAddress The address of new admin in the pending requests
     */
    function getAdminChangeReq(bytes32 _uid) private view returns (address _newAdminAddress) {
        AdminChangeRequest storage changeRequest = adminChangeReqs[_uid];

        require(changeRequest.newAdminAddress != address(0));

        return changeRequest.newAdminAddress;
    }
}

/**
 * @dev This is a contract which will be inherited by BICAProxy and BICALedger.
 */
contract BICALogicUpgradeable is AdminUpgradeable  {

    /**
     * Event
     * @dev After requesting of logic contract address change, emit an event.
     */
    event LogicChangeRequested(bytes32 _uid, address _msgSender, address _newLogic);

    /**
     * Event
     * @dev After confirming a request of logic contract address change, emit an event.
     */
    event LogicChangeConfirmed(bytes32 _uid, address _newLogic);

    /**
     * STRUCT: A struct defined to store an request of Logic contract address change.
     */
    struct LogicChangeRequest {
        address newLogicAddress;
    }

    /**
     * MEMBER: BICALogic address(a contract address) which implements logics of token.
     */
    BICALogic public bicaLogic;

    /**
     * MEMBER: a list of requests of logic change submitted
     */
    mapping (bytes32 => LogicChangeRequest) public logicChangeReqs;

    /**
     * MODIFIER: The call from bicaLogic is allowed only.
     */
    modifier onlyLogic {
        require(msg.sender == address(bicaLogic), "only logic contract is authorized");
        _;
    }

    /**
     * CONSTRUCTOR: Initialize with an admin address which is authorized to change
     * the value of bicaLogic.
     */
    constructor (address _admin) public AdminUpgradeable(_admin) {
        bicaLogic = BICALogic(0x0);
    }

    /**
     * METHOD: Upgrade the logic contract ---- request.
     * @dev Request changing the logic contract address authorized.
     * Anyone can call this method to submit a request to change
     * the logic address. It will be pending until admin address
     * comfirming the request, and the logic contract address changes, i.e.
     * the value of bicaLogic changes.
     * @param _newLogic The address of new logic contract.
     * @return uid The unique id of the request.
     */
    function requestLogicChange(address _newLogic) public returns (bytes32 uid) {
        require(_newLogic != address(0), "new logic address can not be 0");

        uid = generateRequestUid();

        logicChangeReqs[uid] = LogicChangeRequest({
            newLogicAddress: _newLogic
            });

        emit LogicChangeRequested(uid, msg.sender, _newLogic);
    }

    /**
     * METHOD: Upgrade the logic contract ---- confirm.
     * @dev Confirm a reqeust of logic contract change storing in the
     * mapping of `logicChangeReqs`. The operation is authorized to
     * the admin only.
     * @param _uid The uid of request to change logic contract.
     */
    function confirmLogicChange(bytes32 _uid) public adminOperations {
        bicaLogic = getLogicChangeReq(_uid);

        delete logicChangeReqs[_uid];

        emit LogicChangeConfirmed(_uid, address(bicaLogic));
    }

    /**
     * METHOD: Get the address of an logic contract address request by uid.
     * @dev It is a private method which gets address of an address
     * in the mapping `adminChangeReqs`
     * @param _uid The uid of request to change logic contract address.
     * @return _newLogicAddress The address of new logic contract address
     * in the pending requests
     */
    function getLogicChangeReq(bytes32 _uid) private view returns (BICALogic _newLogicAddress) {
        LogicChangeRequest storage changeRequest = logicChangeReqs[_uid];

        require(changeRequest.newLogicAddress != address(0));

        return BICALogic(changeRequest.newLogicAddress);
    }
}

/**
 * @dev This contract is the core contract of all logic. It links `bicaProxy`
 * and `bicaLedger`. It implements the issue of new amount of token, burn some
 * value of someone's token.
 */
contract BICALogic is AdminUpgradeable {

    using SafeMath for uint256;

    /**
     * Event
     * @dev After issuing an ammout of BICA, emit an event for the value of requester.
     */
    event Requester(address _supplyAddress, address _receiver, uint256 _valueRequested);

    /**
     * Event
     * @dev After issuing an ammout of BICA, emit an event of paying margin.
     */
    event PayMargin(address _supplyAddress, address _marginAddress, uint256 _marginValue);


    /**
     * Event
     * @dev After issuing an ammout of BICA, emit an event of paying interest.
     */
    event PayInterest(address _supplyAddress, address _interestAddress, uint256 _interestValue);


    /**
     * Event
     * @dev After issuing an ammout of BICA, emit an event of paying multi fee.
     */
    event PayMultiFee(address _supplyAddress, address _feeAddress, uint256 _feeValue);

    /**
     * Event
     * @dev After freezing a user address, emit an event in logic contract.
     */
    event AddressFrozenInLogic(address indexed addr);

    /**
     * Event
     * @dev After unfreezing a user address, emit an event in logic contract.
     */
    event AddressUnfrozenInLogic(address indexed addr);

    /**
     * MEMBER: A reference to the proxy contract.
     * It links the proxy contract in one direction.
     */
    BICAProxy public bicaProxy;

    /**
     * MEMBER: A reference to the ledger contract.
     * It links the ledger contract in one direction.
     */
    BICALedger public bicaLedger;

    /**
     * MODIFIER: The call from bicaProxy is allowed only.
     */
    modifier onlyProxy {
        require(msg.sender == address(bicaProxy), "only the proxy contract allowed only");
        _;
    }

    /**
     * CONSTRUCTOR: Initialize with the proxy contract address, the ledger
     * contract and an admin address.
     */
    constructor (address _bicaProxy, address _bicaLedger, address _admin) public  AdminUpgradeable(_admin) {
        bicaProxy = BICAProxy(_bicaProxy);
        bicaLedger = BICALedger(_bicaLedger);
    }
    
    /**
     * METHOD: `approve` operation in logic contract.
     * @dev Receive the call request of `approve` from proxy contract and
     * request approve operation to ledger contract. Need to check the sender
     * and spender are not frozen
     * @param _sender The address initiating the approval in proxy.
     * @return success or not.
     */
    function approveWithSender(address _sender, address _spender, uint256 _value) public onlyProxy returns (bool success){
        require(_spender != address(0));

        bool senderFrozen = bicaLedger.getFrozenByAddress(_sender);
        require(!senderFrozen, "Sender is frozen");

        bool spenderFrozen = bicaLedger.getFrozenByAddress(_spender);
        require(!spenderFrozen, "Spender is frozen");

        bicaLedger.setAllowance(_sender, _spender, _value);
        bicaProxy.emitApproval(_sender, _spender, _value);
        return true;
    }

    /**
     * METHOD: Core logic of the `increaseApproval` method in proxy contract.
     * @dev Receive the call request of `increaseApproval` from proxy contract
     * and request increasing value of allownce to ledger contract. Need to
     * check the sender
     * and spender are not frozen
     * @param _sender The address initiating the approval in proxy.
     * @return success or not.
     */
    function increaseApprovalWithSender(address _sender, address _spender, uint256 _addedValue) public onlyProxy returns (bool success) {
        require(_spender != address(0));

        bool senderFrozen = bicaLedger.getFrozenByAddress(_sender);
        require(!senderFrozen, "Sender is frozen");

        bool spenderFrozen = bicaLedger.getFrozenByAddress(_spender);
        require(!spenderFrozen, "Spender is frozen");

        uint256 currentAllowance = bicaLedger.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance.add(_addedValue);

        require(newAllowance >= currentAllowance);

        bicaLedger.setAllowance(_sender, _spender, newAllowance);
        bicaProxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }

    /**
    * METHOD: Core logic of the `decreaseApproval` method in proxy contract.
    * @dev Receive the call request of `decreaseApproval` from proxy contract
    * and request decreasing value of allownce to ledger contract. Need to
    * check the sender and spender are not frozen
    * @param _sender The address initiating the approval in proxy.
    * @return success or not.
    */
    function decreaseApprovalWithSender(address _sender, address _spender, uint256 _subtractedValue) public onlyProxy returns (bool success) {
        require(_spender != address(0));

        bool senderFrozen = bicaLedger.getFrozenByAddress(_sender);
        require(!senderFrozen, "Sender is frozen");

        bool spenderFrozen = bicaLedger.getFrozenByAddress(_spender);
        require(!spenderFrozen, "Spender is frozen");
        
        uint256 currentAllowance = bicaLedger.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance.sub(_subtractedValue);

        require(newAllowance <= currentAllowance);

        bicaLedger.setAllowance(_sender, _spender, newAllowance);
        bicaProxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }


    /**
     * METHOD: Core logic of comfirming request of issuetoken to a specified receiver.
     * @dev Admin can issue an ammout of BICA only.
     * @param _requesterAccount The address of request account.
     * @param _requestValue The value of requester.
     * @param _marginAccount The address of margin account.
     * @param _marginValue The value of token to pay to margin account.
     * @param _interestAccount The address accepting interest.
     * @param _interestValue The value of interest.
     * @param _otherFeeAddress The address accepting multi fees.
     * @param _otherFeeValue The value of other fees.
     */
    function issue(address _requesterAccount, uint256 _requestValue,
        address _marginAccount, uint256 _marginValue,
        address _interestAccount, uint256 _interestValue,
        address _otherFeeAddress, uint256 _otherFeeValue) public adminOperations {

        require(_requesterAccount != address(0));
        require(_marginAccount != address(0));
        require(_interestAccount != address(0));
        require(_otherFeeAddress != address(0));

        require(!bicaLedger.getFrozenByAddress(_requesterAccount), "Requester is frozen");
        require(!bicaLedger.getFrozenByAddress(_marginAccount), "Margin account is frozen");
        require(!bicaLedger.getFrozenByAddress(_interestAccount), "Interest account is frozen");
        require(!bicaLedger.getFrozenByAddress(_otherFeeAddress), "Other fee account is frozen");

        uint256 requestTotalValue = _marginValue.add(_interestValue).add(_otherFeeValue).add(_requestValue);

        uint256 supply = bicaLedger.totalSupply();
        uint256 newSupply = supply.add(requestTotalValue);

        if (newSupply >= supply) {
            bicaLedger.setTotalSupply(newSupply);
            bicaLedger.addBalance(_marginAccount, _marginValue);
            bicaLedger.addBalance(_interestAccount, _interestValue);
            if ( _otherFeeValue > 0 ){
                bicaLedger.addBalance(_otherFeeAddress, _otherFeeValue);
            }
            bicaLedger.addBalance(_requesterAccount, _requestValue);

            emit Requester(msg.sender, _requesterAccount, _requestValue);
            emit PayMargin(msg.sender, _marginAccount, _marginValue);
            emit PayInterest(msg.sender, _interestAccount, _interestValue);
            emit PayMultiFee(msg.sender, _otherFeeAddress, _otherFeeValue);

            bicaProxy.emitTransfer(address(0), _marginAccount, _marginValue);
            bicaProxy.emitTransfer(address(0), _interestAccount, _interestValue);
            bicaProxy.emitTransfer(address(0), _otherFeeAddress, _otherFeeValue);
            bicaProxy.emitTransfer(address(0), _requesterAccount, _requestValue);
        }
    }

    /**
     * METHOD: Burn the specified value of the message sender's balance.
     * @dev Admin can call this method to burn some amount of BICA.
     * @param _value The amount of token to be burned.
     * @return success or not.
     */
    function burn(uint256 _value) public adminOperations returns (bool success) {
        bool burnerFrozen = bicaLedger.getFrozenByAddress(msg.sender);
        require(!burnerFrozen, "Burner is frozen");

        uint256 balanceOfSender = bicaLedger.balances(msg.sender);
        require(_value <= balanceOfSender);

        bicaLedger.setBalance(msg.sender, balanceOfSender.sub(_value));
        bicaLedger.setTotalSupply(bicaLedger.totalSupply().sub(_value));

        bicaProxy.emitTransfer(msg.sender, address(0), _value);

        return true;
    }

    /**
     * METHOD: Freeze a user address.
     * @dev Admin can call this method to freeze a user account.
     * @param _user user address.
     */
    function freeze(address _user) public adminOperations {
        require(_user != address(0), "the address to be frozen cannot be 0");
        bicaLedger.freezeByAddress(_user);
        emit AddressFrozenInLogic(_user);
    }

    /**
     * METHOD: Unfreeze a user address.
     * @dev Admin can call this method to unfreeze a user account.
     * @param _user user address.
     */
    function unfreeze(address _user) public adminOperations {
        require(_user != address(0), "the address to be unfrozen cannot be 0");
        bicaLedger.unfreezeByAddress(_user);
        emit AddressUnfrozenInLogic(_user);
    }

    /**
     * METHOD: Core logic of `transferFrom` interface method in ERC20 token standard.
     * @dev It can only be called by the `bicaProxy` contract.
     * @param _sender The address initiating the approval in proxy.
     * @return success or not.
     */
    function transferFromWithSender(address _sender, address _from, address _to, uint256 _value) public onlyProxy returns (bool success){
        require(_to != address(0));

        bool senderFrozen = bicaLedger.getFrozenByAddress(_sender);
        require(!senderFrozen, "Sender is frozen");
        bool fromFrozen = bicaLedger.getFrozenByAddress(_from);
        require(!fromFrozen, "`from` is frozen");
        bool toFrozen = bicaLedger.getFrozenByAddress(_to);
        require(!toFrozen, "`to` is frozen");

        uint256 balanceOfFrom = bicaLedger.balances(_from);
        require(_value <= balanceOfFrom);

        uint256 senderAllowance = bicaLedger.allowed(_from, _sender);
        require(_value <= senderAllowance);

        bicaLedger.setBalance(_from, balanceOfFrom.sub(_value));

        bicaLedger.addBalance(_to, _value);

        bicaLedger.setAllowance(_from, _sender, senderAllowance.sub(_value));

        bicaProxy.emitTransfer(_from, _to, _value);

        return true;
    }

    /**
    * METHOD: Core logic of `transfer` interface method in ERC20 token standard.
    * @dev It can only be called by the `bicaProxy` contract.
    * @param _sender The address initiating the approval in proxy.
    * @return success or not.
    */
    function transferWithSender(address _sender, address _to, uint256 _value) public onlyProxy returns (bool success){
        require(_to != address(0));

        bool senderFrozen = bicaLedger.getFrozenByAddress(_sender);
        require(!senderFrozen, "sender is frozen");
        bool toFrozen = bicaLedger.getFrozenByAddress(_to);
        require(!toFrozen, "to is frozen");

        uint256 balanceOfSender = bicaLedger.balances(_sender);
        require(_value <= balanceOfSender);

        bicaLedger.setBalance(_sender, balanceOfSender.sub(_value));

        bicaLedger.addBalance(_to, _value);

        bicaProxy.emitTransfer(_sender, _to, _value);

        return true;
    }

    /**
     * METHOD: Core logic of `totalSupply` interface method in ERC20 token standard.
     */
    function totalSupply() public view returns (uint256) {
        return bicaLedger.totalSupply();
    }

    /**
     * METHOD: Core logic of `balanceOf` interface method in ERC20 token standard.
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return bicaLedger.balances(_owner);
    }

    /**
     * METHOD: Core logic of `allowance` interface method in ERC20 token standard.
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return bicaLedger.allowed(_owner, _spender);
    }
}

/**
 * @dev This contract is the core storage contract of ERC20 token ledger.
 * It defines some operations of data in the storage.
 */
contract BICALedger is BICALogicUpgradeable {

    using SafeMath for uint256;

    /**
     * MEMBER: The total supply of the token.
     */
    uint256 public totalSupply;

    /**
     * MEMBER: The mapping of balance of users.
     */
    mapping (address => uint256) public balances;

    /**
     * MEMBER: The mapping of allowance of users.
     */
    mapping (address => mapping (address => uint256)) public allowed;

    /**
     * MEMBER: The mapping of frozen addresses.
     */
    mapping(address => bool) public frozen;

    /**
     * Event
     * @dev After freezing a user address, emit an event in ledger contract.
     */
    event AddressFrozen(address indexed addr);

    /**
     * Event
     * @dev After unfreezing a user address, emit an event in ledger contract.
     */
    event AddressUnfrozen(address indexed addr);

    /**
     * CONSTRUCTOR: Initialize with an admin address.
     */
    constructor (address _admin) public BICALogicUpgradeable(_admin) {
        totalSupply = 0;
    }

    /**
     * METHOD: Check an address is frozen or not.
     * @dev check an address is frozen or not. It can be call by logic contract only.
     * @param _user user addree.
     */
    function getFrozenByAddress(address _user) public view onlyLogic returns (bool frozenOrNot) {
        // frozenOrNot = false;
        return frozen[_user];
    }

    /**
     * METHOD: Freeze an address.
     * @dev Freeze an address. It can be called by logic contract only.
     * @param _user user addree.
     */
    function freezeByAddress(address _user) public onlyLogic {
        require(!frozen[_user], "user already frozen");
        frozen[_user] = true;
        emit AddressFrozen(_user);
    }

    /**
     * METHOD: Unfreeze an address.
     * @dev Unfreeze an address. It can be called by logic contract only.
     * @param _user user addree.
     */
    function unfreezeByAddress(address _user) public onlyLogic {
        require(frozen[_user], "address already unfrozen");
        frozen[_user] = false;
        emit AddressUnfrozen(_user);
    }


    /**
     * METHOD: Set `totalSupply` in the ledger contract.
     * @dev It will be called when a new issue is confirmed. It can be called
     * by logic contract only.
     * @param _newTotalSupply The value of new total supply.
     */
    function setTotalSupply(uint256 _newTotalSupply) public onlyLogic {
        totalSupply = _newTotalSupply;
    }

    /**
     * METHOD: Set allowance for owner to a spender in the ledger contract.
     * @dev It will be called when the owner modify the allowance to the
     * spender. It can be called by logic contract only.
     * @param _owner The address allow spender to spend.
     * @param _spender The address allowed to spend.
     * @param _value The limit of how much can be spent by `_spender`.
     */
    function setAllowance(address _owner, address _spender, uint256 _value) public onlyLogic {
        allowed[_owner][_spender] = _value;
    }

    /**
     * METHOD: Set balance of the owner in the ledger contract.
     * @dev It will be called when the owner modify the balance of owner
     * in logic. It can be called by logic contract only.
     * @param _owner The address who owns the balance.
     * @param _newBalance The balance to be set.
     */
    function setBalance(address _owner, uint256 _newBalance) public onlyLogic {
        balances[_owner] = _newBalance;
    }

    /**
     * METHOD: Add balance of the owner in the ledger contract.
     * @dev It will be called when the balance of owner increases.
     * It can be called by logic contract only.
     * @param _owner The address who owns the balance.
     * @param _balanceIncrease The balance to be add.
     */
    function addBalance(address _owner, uint256 _balanceIncrease) public onlyLogic {
        balances[_owner] = balances[_owner].add(_balanceIncrease);
    }
}

contract ERC20Interface {

    function totalSupply() public view returns (uint256);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @dev This contract is a viewer of ERC20 token standard.
 * It includes no logic and data.
 */
contract BICAProxy is ERC20Interface, BICALogicUpgradeable {

    /**
     * MEMBER: The name of the token.
     */
    string public name;

    /**
     * MEMBER: The symbol of the token.
     */
    string public symbol;

    /**
     * MEMBER: The number of decimals of the token.
     */
    uint public decimals;

    /**
     * CONSTRUCTOR: Initialize with an admin address.
     */
    constructor (address _admin) public BICALogicUpgradeable(_admin){
        name = "BitCapital Coin";
        symbol = 'BICA';
        decimals = 2;
    }
    
    /**
     * METHOD: Get `totalSupply` of token.
     * @dev It is the standard method of ERC20.
     * @return The total token supply.
     */
    function totalSupply() public view returns (uint256) {
        return bicaLogic.totalSupply();
    }

    /**
     * METHOD: Get the balance of a owner.
     * @dev It is the standard method of ERC20.
     * @return The balance of a owner.
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return bicaLogic.balanceOf(_owner);
    }

    /**
     * METHOD: Emit a Transfer event in proxy contract.
     */
    function emitTransfer(address _from, address _to, uint256 _value) public onlyLogic {
        emit Transfer(_from, _to, _value);
    }

    /**
     * METHOD: The message sender sends some amount of token to receiver.
     * @dev It will call the logic contract to send some token to receiver.
     * It is the standard method of ERC20.
     * @return success or not
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        return bicaLogic.transferWithSender(msg.sender, _to, _value);
    }

    /**
     * METHOD: Transfer amount of tokens from `_from` to `_to`.
     * @dev It is the standard method of ERC20.
     * @return success or not
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        return bicaLogic.transferFromWithSender(msg.sender, _from, _to, _value);
    }

    /**
     * METHOD: Emit a Approval event in proxy contract.
     */
    function emitApproval(address _owner, address _spender, uint256 _value) public onlyLogic {
        emit Approval(_owner, _spender, _value);
    }

    /**
     * METHOD: Allow `_spender` to be able to spend `_value` token.
     * @dev It is the standard method of ERC20.
     * @return success or not
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        return bicaLogic.approveWithSender(msg.sender, _spender, _value);
    }

    /**
     * METHOD: Increase allowance value of message sender to `_spender`.
     * @return success or not
     */
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {
        return bicaLogic.increaseApprovalWithSender(msg.sender, _spender, _addedValue);
    }

    /**
     * METHOD: Decrease allowance value of message sender to `_spender`.
     * @return success or not
     */
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {
        return bicaLogic.decreaseApprovalWithSender(msg.sender, _spender, _subtractedValue);
    }

    /**
     * METHOD: Return the allowance value of `_owner` to `_spender`.
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return bicaLogic.allowance(_owner, _spender);
    }
}
pragma solidity ^0.4.17;

// ----------------------------------------------------------------------------
// Token Trustee Implementation
//
// Copyright (c) 2017 OpenST Ltd.
// https://simpletoken.org/
//
// The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// SafeMath Library Implementation
//
// Copyright (c) 2017 OpenST Ltd.
// https://simpletoken.org/
//
// The MIT Licence.
//
// Based on the SafeMath library by the OpenZeppelin team.
// Copyright (c) 2016 Smart Contract Solutions, Inc.
// https://github.com/OpenZeppelin/zeppelin-solidity
// The MIT License.
// ----------------------------------------------------------------------------


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity automatically throws when dividing by 0
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
}

//
// Implements basic ownership with 2-step transfers.
//
contract Owned {

    address public owner;
    address public proposedOwner;

    event OwnershipTransferInitiated(address indexed _proposedOwner);
    event OwnershipTransferCompleted(address indexed _newOwner);


    function Owned() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }


    function isOwner(address _address) internal view returns (bool) {
        return (_address == owner);
    }


    function initiateOwnershipTransfer(address _proposedOwner) public onlyOwner returns (bool) {
        proposedOwner = _proposedOwner;

        OwnershipTransferInitiated(_proposedOwner);

        return true;
    }


    function completeOwnershipTransfer() public returns (bool) {
        require(msg.sender == proposedOwner);

        owner = proposedOwner;
        proposedOwner = address(0);

        OwnershipTransferCompleted(owner);

        return true;
    }
}

//
// Implements a more advanced ownership and permission model based on owner,
// admin and ops per Simple Token key management specification.
//
contract OpsManaged is Owned {

    address public opsAddress;
    address public adminAddress;

    event AdminAddressChanged(address indexed _newAddress);
    event OpsAddressChanged(address indexed _newAddress);


    function OpsManaged() public
        Owned()
    {
    }


    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }


    modifier onlyAdminOrOps() {
        require(isAdmin(msg.sender) || isOps(msg.sender));
        _;
    }


    modifier onlyOwnerOrAdmin() {
        require(isOwner(msg.sender) || isAdmin(msg.sender));
        _;
    }


    modifier onlyOps() {
        require(isOps(msg.sender));
        _;
    }


    function isAdmin(address _address) internal view returns (bool) {
        return (adminAddress != address(0) && _address == adminAddress);
    }


    function isOps(address _address) internal view returns (bool) {
        return (opsAddress != address(0) && _address == opsAddress);
    }


    function isOwnerOrOps(address _address) internal view returns (bool) {
        return (isOwner(_address) || isOps(_address));
    }


    // Owner and Admin can change the admin address. Address can also be set to 0 to 'disable' it.
    function setAdminAddress(address _adminAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_adminAddress != owner);
        require(_adminAddress != address(this));
        require(!isOps(_adminAddress));

        adminAddress = _adminAddress;

        AdminAddressChanged(_adminAddress);

        return true;
    }


    // Owner and Admin can change the operations address. Address can also be set to 0 to 'disable' it.
    function setOpsAddress(address _opsAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_opsAddress != owner);
        require(_opsAddress != address(this));
        require(!isAdmin(_opsAddress));

        opsAddress = _opsAddress;

        OpsAddressChanged(_opsAddress);

        return true;
    }
}

contract SimpleTokenConfig {

    string  public constant TOKEN_SYMBOL   = "ST";
    string  public constant TOKEN_NAME     = "Simple Token";
    uint8   public constant TOKEN_DECIMALS = 18;

    uint256 public constant DECIMALSFACTOR = 10**uint256(TOKEN_DECIMALS);
    uint256 public constant TOKENS_MAX     = 800000000 * DECIMALSFACTOR;
}

contract ERC20Interface {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);

    function balanceOf(address _owner) public view returns (uint256 balance);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

//
// Standard ERC20 implementation, with ownership.
//
contract ERC20Token is ERC20Interface, Owned {

    using SafeMath for uint256;

    string  private tokenName;
    string  private tokenSymbol;
    uint8   private tokenDecimals;
    uint256 internal tokenTotalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


    function ERC20Token(string _symbol, string _name, uint8 _decimals, uint256 _totalSupply) public
        Owned()
    {
        tokenSymbol      = _symbol;
        tokenName        = _name;
        tokenDecimals    = _decimals;
        tokenTotalSupply = _totalSupply;
        balances[owner]  = _totalSupply;

        // According to the ERC20 standard, a token contract which creates new tokens should trigger
        // a Transfer event and transfers of 0 values must also fire the event.
        Transfer(0x0, owner, _totalSupply);
    }


    function name() public view returns (string) {
        return tokenName;
    }


    function symbol() public view returns (string) {
        return tokenSymbol;
    }


    function decimals() public view returns (uint8) {
        return tokenDecimals;
    }


    function totalSupply() public view returns (uint256) {
        return tokenTotalSupply;
    }


    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }


    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    function transfer(address _to, uint256 _value) public returns (bool success) {
        // According to the EIP20 spec, "transfers of 0 values MUST be treated as normal
        // transfers and fire the Transfer event".
        // Also, should throw if not enough balance. This is taken care of by SafeMath.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(_from, _to, _value);

        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }
}

//
// SimpleToken is a standard ERC20 token with some additional functionality:
// - It has a concept of finalize
// - Before finalize, nobody can transfer tokens except:
//     - Owner and operations can transfer tokens
//     - Anybody can send back tokens to owner
// - After finalize, no restrictions on token transfers
//

//
// Permissions, according to the ST key management specification.
//
//                                    Owner    Admin   Ops
// transfer (before finalize)           x               x
// transferForm (before finalize)       x               x
// finalize                                      x
//

contract SimpleToken is ERC20Token, OpsManaged, SimpleTokenConfig {

    bool public finalized;


    // Events
    event Burnt(address indexed _from, uint256 _amount);
    event Finalized();


    function SimpleToken() public
        ERC20Token(TOKEN_SYMBOL, TOKEN_NAME, TOKEN_DECIMALS, TOKENS_MAX)
        OpsManaged()
    {
        finalized = false;
    }


    // Implementation of the standard transfer method that takes into account the finalize flag.
    function transfer(address _to, uint256 _value) public returns (bool success) {
        checkTransferAllowed(msg.sender, _to);

        return super.transfer(_to, _value);
    }


    // Implementation of the standard transferFrom method that takes into account the finalize flag.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        checkTransferAllowed(msg.sender, _to);

        return super.transferFrom(_from, _to, _value);
    }


    function checkTransferAllowed(address _sender, address _to) private view {
        if (finalized) {
            // Everybody should be ok to transfer once the token is finalized.
            return;
        }

        // Owner and Ops are allowed to transfer tokens before the sale is finalized.
        // This allows the tokens to move from the TokenSale contract to a beneficiary.
        // We also allow someone to send tokens back to the owner. This is useful among other
        // cases, for the Trustee to transfer unlocked tokens back to the owner (reclaimTokens).
        require(isOwnerOrOps(_sender) || _to == owner);
    }

    // Implement a burn function to permit msg.sender to reduce its balance
    // which also reduces tokenTotalSupply
    function burn(uint256 _value) public returns (bool success) {
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        tokenTotalSupply = tokenTotalSupply.sub(_value);

        Burnt(msg.sender, _value);

        return true;
    }


    // Finalize method marks the point where token transfers are finally allowed for everybody.
    function finalize() external onlyAdmin returns (bool success) {
        require(!finalized);

        finalized = true;

        Finalized();

        return true;
    }
}

//
// Implements a simple trustee which can release tokens based on
// an explicit call from the owner.
//

//
// Permissions, according to the ST key management specification.
//
//                                Owner    Admin   Ops   Revoke
// grantAllocation                           x      x
// revokeAllocation                                        x
// processAllocation                                x
// reclaimTokens                             x
// setRevokeAddress                 x                      x
//

contract Trustee is OpsManaged {

    using SafeMath for uint256;


    SimpleToken public tokenContract;

    struct Allocation {
        uint256 amountGranted;
        uint256 amountTransferred;
        bool    revokable;
    }

    // The trustee has a special 'revoke' key which is allowed to revoke allocations.
    address public revokeAddress;

    // Total number of tokens that are currently allocated.
    // This does not include tokens that have been processed (sent to an address) already or
    // the ones in the trustee's account that have not been allocated yet.
    uint256 public totalLocked;

    mapping (address => Allocation) public allocations;


    //
    // Events
    //
    event AllocationGranted(address indexed _from, address indexed _account, uint256 _amount, bool _revokable);
    event AllocationRevoked(address indexed _from, address indexed _account, uint256 _amountRevoked);
    event AllocationProcessed(address indexed _from, address indexed _account, uint256 _amount);
    event RevokeAddressChanged(address indexed _newAddress);
    event TokensReclaimed(uint256 _amount);


    function Trustee(SimpleToken _tokenContract) public
        OpsManaged()
    {
        require(address(_tokenContract) != address(0));

        tokenContract = _tokenContract;
    }


    modifier onlyOwnerOrRevoke() {
        require(isOwner(msg.sender) || isRevoke(msg.sender));
        _;
    }


    modifier onlyRevoke() {
        require(isRevoke(msg.sender));
        _;
    }


    function isRevoke(address _address) private view returns (bool) {
        return (revokeAddress != address(0) && _address == revokeAddress);
    }


    // Owner and revoke can change the revoke address. Address can also be set to 0 to 'disable' it.
    function setRevokeAddress(address _revokeAddress) external onlyOwnerOrRevoke returns (bool) {
        require(_revokeAddress != owner);
        require(!isAdmin(_revokeAddress));
        require(!isOps(_revokeAddress));

        revokeAddress = _revokeAddress;

        RevokeAddressChanged(_revokeAddress);

        return true;
    }


    // Allows admin or ops to create new allocations for a specific account.
    function grantAllocation(address _account, uint256 _amount, bool _revokable) public onlyAdminOrOps returns (bool) {
        require(_account != address(0));
        require(_account != address(this));
        require(_amount > 0);

        // Can't create an allocation if there is already one for this account.
        require(allocations[_account].amountGranted == 0);

        if (isOps(msg.sender)) {
            // Once the token contract is finalized, the ops key should not be able to grant allocations any longer.
            // Before finalized, it is used by the TokenSale contract to allocate pre-sales.
            require(!tokenContract.finalized());
        }

        totalLocked = totalLocked.add(_amount);
        require(totalLocked <= tokenContract.balanceOf(address(this)));

        allocations[_account] = Allocation({
            amountGranted     : _amount,
            amountTransferred : 0,
            revokable         : _revokable
        });

        AllocationGranted(msg.sender, _account, _amount, _revokable);

        return true;
    }


    // Allows the revoke key to revoke allocations, if revoke is allowed.
    function revokeAllocation(address _account) external onlyRevoke returns (bool) {
        require(_account != address(0));

        Allocation memory allocation = allocations[_account];

        require(allocation.revokable);

        uint256 ownerRefund = allocation.amountGranted.sub(allocation.amountTransferred);

        delete allocations[_account];

        totalLocked = totalLocked.sub(ownerRefund);

        AllocationRevoked(msg.sender, _account, ownerRefund);

        return true;
    }


    // Push model which allows ops to transfer tokens to the beneficiary.
    // The exact amount to transfer is calculated based on agreements with
    // the beneficiaries. Here we only restrict that the total amount transfered cannot
    // exceed what has been granted.
    function processAllocation(address _account, uint256 _amount) external onlyOps returns (bool) {
        require(_account != address(0));
        require(_amount > 0);

        Allocation storage allocation = allocations[_account];

        require(allocation.amountGranted > 0);

        uint256 transferable = allocation.amountGranted.sub(allocation.amountTransferred);

        if (transferable < _amount) {
           return false;
        }

        allocation.amountTransferred = allocation.amountTransferred.add(_amount);

        // Note that transfer will fail if the token contract has not been finalized yet.
        require(tokenContract.transfer(_account, _amount));

        totalLocked = totalLocked.sub(_amount);

        AllocationProcessed(msg.sender, _account, _amount);

        return true;
    }


    // Allows the admin to claim back all tokens that are not currently allocated.
    // Note that the trustee should be able to move tokens even before the token is
    // finalized because SimpleToken allows sending back to owner specifically.
    function reclaimTokens() external onlyAdmin returns (bool) {
        uint256 ownBalance = tokenContract.balanceOf(address(this));

        // If balance <= amount locked, there is nothing to reclaim.
        require(ownBalance > totalLocked);

        uint256 amountReclaimed = ownBalance.sub(totalLocked);

        address tokenOwner = tokenContract.owner();
        require(tokenOwner != address(0));

        require(tokenContract.transfer(tokenOwner, amountReclaimed));

        TokensReclaimed(amountReclaimed);

        return true;
    }
}
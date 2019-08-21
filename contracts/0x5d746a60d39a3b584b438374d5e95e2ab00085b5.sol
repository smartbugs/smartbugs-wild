/* solium-disable-next-line linebreak-style */
pragma solidity 0.4.24;

// ----------------------------------------------------------------------------
// Math - Implement Math Library
// ----------------------------------------------------------------------------
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 r = a + b;

        require(r >= a, 'Require r >= a');

        return r;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, 'Require a >= b');

        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 r = a * b;

        require(r / a == b, 'Require r / a == b');

        return r;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}

// ----------------------------------------------------------------------------
// ERC20Interface - Standard ERC20 Interface Definition
// Based on the final ERC20 specification at:
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function balanceOf(address _owner) public view returns (uint256 balance);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

// ----------------------------------------------------------------------------
// ERC20Token - Standard ERC20 Implementation
// ----------------------------------------------------------------------------
contract ERC20Token is ERC20Interface {

    using SafeMath for uint256;

    string public  name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping (address => uint256)) allowed;


    constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply, address _initialTokenHolder) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;

        // The initial balance of tokens is assigned to the given token holder address.
        balances[_initialTokenHolder] = _totalSupply;
        allowed[_initialTokenHolder][_initialTokenHolder] = balances[_initialTokenHolder];

        // Per EIP20, the constructor should fire a Transfer event if tokens are assigned to an account.
        emit Transfer(0x0, _initialTokenHolder, _totalSupply);
    }

    function transfer(address _to, uint256 _value)  public returns (bool success) {
        require(balances[msg.sender] >= _value, 'Sender`s balance is not enough');
        require(balances[_to] + _value > balances[_to], 'Value is invalid');
        require(_to != address(0), '_to address is invalid');

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, 'Owner`s balance is not enough');
        require(allowed[_from][msg.sender] >= _value, 'Sender`s allowance is not enough');
        require(balances[_to] + _value > balances[_to], 'Token amount value is invalid');
        require(_to != address(0), '_to address is invalid');

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }


    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}


// Implements a simple ownership model with 2-phase transfer.
contract Owned {

    address public owner;
    address public proposedOwner;

    constructor() public
    {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender) == true, 'Require owner to execute transaction');
        _;
    }


    function isOwner(address _address) public view returns (bool result) {
        return (_address == owner);
    }


    function initiateOwnershipTransfer(address _proposedOwner) public onlyOwner returns (bool success) {
        require(_proposedOwner != address(0), 'Require proposedOwner != address(0)');
        require(_proposedOwner != address(this), 'Require proposedOwner != address(this)');
        require(_proposedOwner != owner, 'Require proposedOwner != owner');

        proposedOwner = _proposedOwner;
        return true;
    }


    function completeOwnershipTransfer() public returns (bool success) {
        require(msg.sender == proposedOwner, 'Require msg.sender == proposedOwner');

        owner = msg.sender;
        proposedOwner = address(0);

        return true;
    }
}

// ----------------------------------------------------------------------------
// OpsManaged - Implements an Owner and Ops Permission Model
// ----------------------------------------------------------------------------
contract OpsManaged is Owned {

    address public opsAddress;


    constructor() public
        Owned()
    {
    }


    modifier onlyOwnerOrOps() {
        require(isOwnerOrOps(msg.sender), 'Require only owner or ops');
        _;
    }


    function isOps(address _address) public view returns (bool result) {
        return (opsAddress != address(0) && _address == opsAddress);
    }


    function isOwnerOrOps(address _address) public view returns (bool result) {
        return (isOwner(_address) || isOps(_address));
    }


    function setOpsAddress(address _newOpsAddress) public onlyOwner returns (bool success) {
        require(_newOpsAddress != owner, 'Require newOpsAddress != owner');
        require(_newOpsAddress != address(this), 'Require newOpsAddress != address(this)');

        opsAddress = _newOpsAddress;

        return true;
    }
}

// ----------------------------------------------------------------------------
// Finalizable - Implement Finalizable (Crowdsale) model
// ----------------------------------------------------------------------------
contract Finalizable is OpsManaged {

    FinalizeState public finalized;

    enum FinalizeState {
        None,
        Finalized
    }

    event Finalized();


    constructor() public OpsManaged()
    {
        finalized = FinalizeState.None;
    }


    function finalize() public onlyOwner returns (bool success) {
        require(finalized == FinalizeState.None, 'Require !finalized');

        finalized = FinalizeState.Finalized;

        emit Finalized();

        return true;
    }
}


// ----------------------------------------------------------------------------
// FinalizableToken - Extension to ERC20Token with ops and finalization
// ----------------------------------------------------------------------------
//
// ERC20 token with the following additions:
//    1. Owner/Ops Ownership
//    2. Finalization
//
contract FinalizableToken is ERC20Token, Finalizable {

    using SafeMath for uint256;


    // The constructor will assign the initial token supply to the owner (msg.sender).
    constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public
        ERC20Token(_name, _symbol, _decimals, _totalSupply, msg.sender)
        Finalizable()
    {
    }


    function transfer(address _to, uint256 _value) public returns (bool success) {
        validateTransfer(msg.sender, _to);

        return super.transfer(_to, _value);
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        validateTransfer(msg.sender, _to);

        return super.transferFrom(_from, _to, _value);
    }


    function validateTransfer(address _sender, address _to) internal view {
        // Once the token is finalized, everybody can transfer tokens.
        if (finalized == FinalizeState.Finalized) {
            return;
        }

        if (isOwner(_to)) {
            return;
        }

        require(_to != opsAddress, 'Ops cannot recieve token');

        // Before the token is finalized, only owner and ops are allowed to initiate transfers.
        // This allows them to move tokens while the sale is still in private sale.
        require(isOwnerOrOps(_sender), 'Require is owner or ops allowed to initiate transfer');
    }
}



// ----------------------------------------------------------------------------
// Token Contract Configuration
// ----------------------------------------------------------------------------
contract TokenConfig {

    string  internal constant TOKEN_SYMBOL      = 'SLS';
    string  internal constant TOKEN_NAME        = 'SKILLSH';
    uint8   internal constant TOKEN_DECIMALS    = 8;

    uint256 internal constant DECIMALS_FACTOR    = 10 ** uint256(TOKEN_DECIMALS);
    uint256 internal constant TOKEN_TOTAL_SUPPLY = 500000000 * DECIMALS_FACTOR;
}



// ----------------------------------------------------------------------------
// Token Contract
// ----------------------------------------------------------------------------
contract SLSToken is FinalizableToken, TokenConfig {

    enum HaltState {
        Unhalted,
        Halted
    }

    HaltState public halts;

    constructor() public
        FinalizableToken(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, TOKEN_TOTAL_SUPPLY)
    {
        halts = HaltState.Unhalted;
        finalized = FinalizeState.None;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(halts == HaltState.Unhalted, 'Require smart contract is not in halted state');

        if(isOps(msg.sender)) {
            return super.transferFrom(owner, _to, _value);
        }

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(halts == HaltState.Unhalted, 'Require smart contract is not in halted state');
        return super.transferFrom(_from, _to, _value);
    }

    // Allows a token holder to burn tokens. Once burned, tokens are permanently
    // removed from the total supply.
    function burn(uint256 _amount) public returns (bool success) {
        require(_amount > 0, 'Token amount to burn must be larger than 0');

        address account = msg.sender;
        require(_amount <= balanceOf(account), 'You cannot burn token you dont have');

        balances[account] = balances[account].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        return true;
    }

    /* Halts or unhalts direct trades without the sell/buy functions below */
    function haltsTrades() public onlyOwnerOrOps returns (bool success) {
        halts = HaltState.Halted;
        return true;
    }

    function unhaltsTrades() public onlyOwnerOrOps returns (bool success) {
        halts = HaltState.Unhalted;
        return true;
    }

}
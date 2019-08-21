pragma solidity >=0.4.22 < 0.6.0;

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}

/**
 * Math operations with safety checks
 */
contract SafeMath {
    function safeMul(uint a, uint b)internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b)internal pure returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b)internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b)internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
}


/*
 * Base Token for ERC20 compatibility
 * ERC20 interface 
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    //function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint);
    function allowance(address owner, address spender) public view returns (uint);
    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

/*
 * Ownable
 *
 * Base contract with an owner contract.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
    /* Address of the owner */
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Only Token Owner can perform this action");
        _;
    }

    function transferOwnership(address _owner) public onlyOwner{
        require(_owner != owner,"New Owner is the same as existing Owner");
        require(_owner != address(0x0), "Empty Address provided");
        owner = _owner;
    }
}

/**
 * Standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
 *
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, SafeMath, Ownable{

    event Burn(address indexed from, uint value);

    /* Actual balances of token holders */
    mapping(address => uint) public balances;
    uint public totalSupply;

    /* approve() allowances */
    mapping (address => mapping (address => uint)) internal allowed;
    
    /**
     *
     * Fix for the ERC20 short address attack
     *
     * http://vessenes.com/the-erc20-short-address-attack-explained/
     */
    modifier onlyPayloadSize(uint size) {
        if(msg.data.length < size + 4) {
            revert("Payload attack");
        }
        _;
    }

    /**
     *
     * Transfer with ERC20 specification
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * http://vessenes.com/the-erc20-short-address-attack-explained/
     */
    function transfer(address _to, uint _value)
    public
    onlyPayloadSize(2 * 32)
    returns (bool)
    {
        require(_to != address(0x0), "No address specified");
        require(balances[msg.sender] >= _value, "Insufficiently fund");
        uint previousBalances = balances[msg.sender] + balances[_to];
        
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[msg.sender] + balances[_to] == previousBalances);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value)
    public
    returns (bool)
    {
        require(_to != address(0x0), "Empty address specified as Receiver");
        require(_from != address(0x0), "Empty Address provided for Sender");
        require(_value <= balances[_from], "Insufficiently fund");
        require(_value <= allowed[_from][msg.sender], "You can't spend the speficied amount from this Account");
        uint _allowance = allowed[_from][msg.sender];
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(_allowance, _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) 
    public
    returns (bool)
    {
        require(_spender != address(0x0), "Invalid Address");

        // To change the approve amount you first have to reduce the addresses`
        //    allowance to zero by calling `approve(_spender, 0)` if it is not
        //    already 0 to mitigate the race condition described here:
        //    https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        //if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
        require(_value == 0 || allowed[msg.sender][_spender] == 0, "Spender allowance must be zero before approving new allowance");
        require(_value <= balances[msg.sender],"Insufficient balance in owner's account");
        require(_value >= 0, "Cannot approve negative amount");
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
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        require(_subtractedValue >= 0 && _subtractedValue <= balances[msg.sender], "Invalid Amount");
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = safeSub(oldValue, _subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }

    function burn(address from, uint amount) public onlyOwner{
        require(balances[from] >= amount && amount > 0, "Insufficient amount or invalid amount specified");
        balances[from] = safeSub(balances[from],amount);
        totalSupply = safeSub(totalSupply, amount);
        emit Burn(from, amount);
    }

    function burn(uint amount) public{
        burn(msg.sender, amount);
    }
}

contract Irstgold is StandardToken {
    string public name;
    uint8 public decimals; 
    string public symbol;

    constructor() public{
        decimals = 18;     // Amount of decimals for display purposes
        totalSupply = 1000000000 * 1 ether;     // Update total supply
        balances[msg.sender] = totalSupply;    // Give the creator all initial tokens
        name = "1irstgold";    // Set the name for display purposes
        symbol = "1STG";    // Set the symbol for display purposes
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    // can accept ether
    function() external payable{
        revert("Token does not accept ETH");
    }
}
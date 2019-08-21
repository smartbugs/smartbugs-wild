pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// 'SmartContractFactory' token contract
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath
{
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// ERC20 Interface
// ----------------------------------------------------------------------------
contract ERC20Basic
{
    uint public totalSupply;
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic
{
    function allowance(address owner, address spender) public constant returns (uint);
    function transferFrom(address from, address to, uint value) public returns (bool success);
    function approve(address spender, uint value) public returns (bool success);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is ERC20Basic, SafeMath
{
    mapping(address => uint) balances;

    function transfer(address to, uint value) public returns (bool success)
    {
        require(value <= balances[msg.sender]);
        require(to != address(0));

        balances[msg.sender] = safeSub(balances[msg.sender], value);
        balances[to] = safeAdd(balances[to], value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function balanceOf(address owner) public constant returns (uint balance)
    {
        return balances[owner];
    }
}

contract StandardToken is BasicToken, ERC20
{
    mapping (address => mapping (address => uint)) allowed;

    function transferFrom(address from, address to, uint value) public returns (bool success)
    {
        require(value <= balances[from]);
        require(value <= allowed[from][msg.sender]);
        require(to != address(0));

        uint allowance = allowed[from][msg.sender];
        balances[to] = safeAdd(balances[to], value);
        balances[from] = safeSub(balances[from], value);
        allowed[from][msg.sender] = safeSub(allowance, value);
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool success)
    {
        require(spender != address(0));
        require(!((value != 0) && (allowed[msg.sender][spender] != 0)));

        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public constant returns (uint remaining)
    {
        return allowed[owner][spender];
    }
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// ----------------------------------------------------------------------------
// SmartContractFactory contract
// ----------------------------------------------------------------------------
contract SmartContractFactory is StandardToken, Owned
{
    string public name = "SmartContractFactory";
    string public symbol = "SCF";
    uint public decimals = 8 ;
    uint public totalSupply =  1000000000000000000;

    constructor() public {
        owner = msg.sender;
        balances[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

     function burn(address account, uint256 amount) public onlyOwner returns (bool success){
       require(account != 0);
       require(amount <= balances[account]);

       totalSupply = safeSub(totalSupply, amount);
       balances[account] = safeSub(balances[account], amount);
       emit Transfer(account, address(0), amount);
       return true;
     }

    function burnFrom(address account, uint256 amount) public onlyOwner returns (bool success){
      require(amount <= allowed[account][msg.sender]);

      // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
      // this function needs to emit an event with the updated approval.
      allowed[account][msg.sender] = safeSub(allowed[account][msg.sender], amount);
      burn(account, amount);
      return true;
    }
}
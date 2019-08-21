pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;


        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
}


contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}



contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = 0xD8df475E76844ea9F3bbb56D72EE5fD8F137787F;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
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


contract Token is ERC20Interface, Owned {
    using SafeMath for uint;

    string public name = "amazonblockchaintokens";   
    string public symbol = "AMZN";   
    uint8 public decimals = 10;    
    uint public _totalSupply;   


    mapping(address => uint) balances;  
    mapping(address => mapping(address => uint)) allowed;   


    constructor() public {   
        name = "amazonblockchaintokens";
        symbol = "AMZN";
        decimals = 10;
        _totalSupply = 100000000 * 10**uint(decimals); //100 million
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public view returns (uint) { 
        return _totalSupply - balances[address(0)];
    }

    // Extra function
    function totalSupplyWithZeroAddress() public view returns (uint) { 
        return _totalSupply;
    }

    // Extra function
    function totalSupplyWithoutDecimals() public view returns (uint) {
        return _totalSupply / (10**uint(decimals));
    }


    function balanceOf(address tokenOwner) public view returns (uint balance) { 
        return balances[tokenOwner];
    }

    // Extra function
    function myBalance() public view returns (uint balance) {
        return balances[msg.sender];
    }


    function transfer(address to, uint tokens) public returns (bool success) {  
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {  
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {    
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {  
        return allowed[tokenOwner][spender];
    }

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    function () public payable {  
        revert();
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) { 
        return ERC20Interface(tokenAddress).transfer(owner, tokens);        
    }

    /*
        Administrator functions
    */

    // change symbol and name
    function reconfig(string newName, string newSymbol) external onlyOwner {
        symbol = newSymbol;
        name = newName;
    }

    // increase supply and send newly added tokens to owner
    function increaseSupply(uint256 increase) external onlyOwner {
        _totalSupply = _totalSupply.add(increase);
        balances[owner] = balances[owner].add(increase);
        emit Transfer(address(0), owner, increase);
    }

    // decrease/burn supply
    function burnTokens(uint256 decrease) external onlyOwner {
        balances[owner] = balances[owner].sub(decrease);
        _totalSupply = _totalSupply.sub(decrease);
    }
    
    // deactivate the contract
    function deactivate() external onlyOwner {
        selfdestruct(owner);
    }
}
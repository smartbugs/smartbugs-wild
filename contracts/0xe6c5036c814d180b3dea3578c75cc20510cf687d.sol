pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// 'Tutorcoin' token contract
//
// Tutorcoin is a smart contract for online education platform.
// 
// We are building a next generation online education & knowledge share platform. Though our platform, 
// every people can get educated or share his/her knowledge easily and efficiently.
//
// Tutorcoin can help keep every knowledge sharing process accuracy and clear to the whole community, and 
// keep the transaction process secure and efficient. With Tutorcoin, people can easily find a 
// better educator by knowing full history of his/her knowledge sharing, and platform can rank and recommend 
// educator by it as well.
//
// Tutorcoin will be used for tracking one’s contribution to the community, keeping the balance of giving new 
// knowledge to the community, and getting education from others.
//
//
//
// Deployed to : 0xB2bb88A37C3646B5E29481Ea057F06F94A49C584
// Symbol      : TTC
// Name        : Tutorcoin
// Total supply: 1000000000000000
// Decimals    : 6
//
// ----------------------------------------------------------------------------




// ----------------------------------------------------------------------------
// Tutorcoin is based on ERC-20 interface, here is the interface and methods in it
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Util functions
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

contract SafeMath {
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
// Init of Tutorcoin contract
//
// 'Tutorcoin' token contract
//
// Tutorcoin is a smart contract for online education platform.
// 
// We are building a next generation online education & knowledge share platform. Though our platform, 
// every people can get educated or share his/her knowledge easily and efficiently.
//
// Tutorcoin can help keep every knowledge sharing process accuracy and clear to the whole community, and 
// keep the transaction process secure and efficient. With Tutorcoin, people can easily find a 
// better educator by knowing full history of his/her knowledge sharing, and platform can rank and recommend 
// educator by it as well.
//
// Tutorcoin will be used for tracking one’s contribution to the community, keeping the balance of giving new 
// knowledge to the community, and getting education from others.
// ----------------------------------------------------------------------------
contract TutorcoinToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    constructor() public {
        symbol = "TTC";
        name = "Tutorcoin";
        decimals = 6;
        _totalSupply = 1000000000000000;
        balances[0xB2bb88A37C3646B5E29481Ea057F06F94A49C584] = _totalSupply;
        emit Transfer(address(0), 0xB2bb88A37C3646B5E29481Ea057F06F94A49C584, _totalSupply);
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Approve the educator to take credit after course
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer TTC from learner to educator
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Return the amount of tokens from one learner
	// To keep the community balance, learner must have enough TTC for learning new knowledge from the community,
	// people can get TTC by giving knowledge to others in the community
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Learner approves educator's class, and agrees to give TTC to educator as the request
    // ------------------------------------------------------------------------
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
	
}
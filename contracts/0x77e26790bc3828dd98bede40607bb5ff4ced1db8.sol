pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'M8' Solidity Contract Under (c) M8s World Sàrl
//
// Deployed to : 0x77e26790bc3828dd98bede40607bb5ff4ced1db8
// Symbol      : M8
// Name        : M8
// Total supply: 1,000,000,000,000 M8
// Decimals    : 8
//
//
// Copyright (c) M8s World Sàrl, all rights reserved 2019.
// ERC20 Smart Contract Provided By: SoftCode.space Blockchain Developer Team.
// ----------------------------------------------------------------------------

// Total 10 Points Associated With This Solidity Contract, please read them carefully
// ----------------------------------------------------------------------------
// Point 1 Any social action taken in www.M8s.World can earn a user a point(s) or division of. A M8 or any division of can be offered in exchange for a point in M8s World. This concept remains the copyright of M8s World Sàrl, all rights reserved 2019.
// Point 2 A M8 is valued by human time and labour spent within and outside of M8s World social network by way of contribution or acts undertaken on behalf of M8s World as well as the same human's commitment to view a certain variable amount of commercial advertisements within and outside of M8s World on a variable timescale.
// Point 3 To earn M8 in M8s World our members must allow The M8s World administration & AI to use the data that they share so they can customise advertising relevant to the member, in the knowledge that the M8s World M8 should increase in value if it is backed by a commercial process as well and human time and labour.
// Point 4 Human time and labour is universally agreed by M8s World members that the M8 backed by such and supported by advertising revenue can not fall below the value of 1 x M8 = 1 x Swiss Franc although A M8 can increase by unlimited amounts more than the Swiss Franc.
// Point 5 A M8s world member must allow M8s World software to have access to parts of the hardware on their device used to access M8s World, ie a member's keyboard, camera, speakers, microphone etc to allow M8s World administration to reward members with the correct amount of M8s or any promotions held by M8s World Sàrl.
// Point 6 0.00001% of all M8 is to be retained by each of the 2 x M8s World Sàrl Founders, Mr Anthony Bain and Mr. Nigel Eyles.
// Point 7 A soft cap of CHF 10,000,000 needs to be raised to produce and promote the new M8s.World social network that is being designed to fully exploit the M8 and www.m8s.world, existing and future, on behalf of M8 users with a hard cap of CHF20,000,000.
// Point 8 A M8 can be borrowed or lent with or without interest using M8 smart contracts.
// Point 9 When all pre-mined M8s have been distributed, a M8 can be divisible up to 8 decimal points, M8 mining can be restored if demand exceeds supply.
// Point 10 If any M8 needs to be burned to assist in raising the value of M8 it will be burned at the discretion of the two founders or their representatives.
// Copyright (c) M8s World Sàrl, all rights reserved 2019.
// ----------------------------------------------------------------------------

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


contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


contract M8 is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    function M8() public {
        symbol = "M8";
        name = "M8";
        decimals = 8;
        _totalSupply = 100000000000000000000;
        balances[0xd1bdf441811b2225E8AFc6eFe8cE53Df417ebA7C] = _totalSupply;
        Transfer(address(0), 0xd1bdf441811b2225E8AFc6eFe8cE53Df417ebA7C, _totalSupply);
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
        Transfer(msg.sender, to, tokens);
        return true;
    }


    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
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
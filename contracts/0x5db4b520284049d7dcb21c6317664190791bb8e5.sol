pragma solidity ^0.4.20;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
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


contract Tangent is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    function Tangent() public {
        symbol = "TAN";
        name = "Tangent";
        decimals = 18;
        _totalSupply = 1000000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
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

contract TangentStake is Owned {
    // prevents overflows
    using SafeMath for uint;
    
    // represents a purchase object
    // addr is the buying address
    // amount is the number of wei in the purchase
    // sf is the sum of (purchase amount / sum of previous purchase amounts)
    struct Purchase {
        address addr;
        uint amount;
        uint sf;
    }
    
    // Purchase object array that holds entire purchase history
    Purchase[] purchases;
    
    // tangents are rewarded along with Ether upon cashing out
    Tangent tokenContract;
    
    // the rate of tangents to ether is multiplier / divisor
    uint multiplier;
    uint divisor;
    
    // accuracy multiplier
    uint acm;
    
    uint netStakes;
    
    // logged when a purchase is made
    event PurchaseEvent(uint index, address addr, uint eth, uint sf);
    
    // logged when a person cashes out or the contract is destroyed
    event CashOutEvent(uint index, address addr, uint eth, uint tangles);
    
    event NetStakesChange(uint netStakes);
    
    // logged when the rate of tangents to ether is decreased
    event Revaluation(uint oldMul, uint oldDiv, uint newMul, uint newDiv);
    
    // constructor, sets initial rate to 1000 TAN per 1 Ether
    function TangentStake(address tokenAddress) public {
        tokenContract = Tangent(tokenAddress);
        multiplier = 1000;
        divisor = 1;
        acm = 10**18;
        netStakes = 0;
    }
    
    // decreases the rate of Tangents to Ether, the contract cannot be told
    // to give out more Tangents per Ether, only fewer.
    function revalue(uint newMul, uint newDiv) public onlyOwner {
        require( (newMul.div(newDiv)) <= (multiplier.div(divisor)) );
        Revaluation(multiplier, divisor, newMul, newDiv);
        multiplier = newMul;
        divisor = newDiv;
        return;
    }
    
    // returns the current amount of wei that will be given for the purchase 
    // at purchases[index]
    function getEarnings(uint index) public constant returns (uint earnings, uint amount) {
        Purchase memory cpurchase;
        Purchase memory lpurchase;
        
        cpurchase = purchases[index];
        amount = cpurchase.amount;
        
        if (cpurchase.addr == address(0)) {
            return (0, amount);
        }
        
        earnings = (index == 0) ? acm : 0;
        lpurchase = purchases[purchases.length-1];
        earnings = earnings.add( lpurchase.sf.sub(cpurchase.sf) );
        earnings = earnings.mul(amount).div(acm);
        return (earnings, amount);
    }
    
    // Cash out Ether and Tangent at for the purchase at index "index".
    // All of the Ether and Tangent associated with with that purchase will
    // be sent to recipient, and no future withdrawals can be made for the
    // purchase.
    function cashOut(uint index) public {
        require(0 <= index && index < purchases.length);
        require(purchases[index].addr == msg.sender);
        
        uint earnings;
        uint amount;
        uint tangles;
        
        (earnings, amount) = getEarnings(index);
        purchases[index].addr = address(0);
        require(earnings != 0 && amount != 0);
        netStakes = netStakes.sub(amount);
        
        tangles = earnings.mul(multiplier).div(divisor);
        CashOutEvent(index, msg.sender, earnings, tangles);
        NetStakesChange(netStakes);
        
        tokenContract.transfer(msg.sender, tangles);
        msg.sender.transfer(earnings);
        return;
    }
    
    
    // The fallback function used to purchase stakes
    // sf is the sum of the proportions of:
    // (ether of current purchase / sum of ether prior to purchase)
    // It is used to calculate earnings upon withdrawal.
    function () public payable {
        require(msg.value != 0);
        
        uint index = purchases.length;
        uint sf;
        uint f;
        
        if (index == 0) {
            sf = 0;
        } else {
            f = msg.value.mul(acm).div(netStakes);
            sf = purchases[index-1].sf.add(f);
        }
        
        netStakes = netStakes.add(msg.value);
        purchases.push(Purchase(msg.sender, msg.value, sf));
        
        NetStakesChange(netStakes);
        PurchaseEvent(index, msg.sender, msg.value, sf);
        return;
    }
}
pragma solidity ^0.4.18;

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
        _totalSupply = 1000000 * 10**uint(decimals);
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

contract Slopes {
    uint[9] purchased;
    uint[9] slopes;
    uint round;
    function Slopes() public {
        round = 0;
        purchased = [
            0,
            533669923120630398976,
            1448836313210046119936,
            3129995208684548390912,
            6258159088532505755648,
            12107544817228717228032,
            23069429949211428782080,
            43633652091382656925696,
            82231181009131438866432];
        slopes = [
            187381742286,
            218539494201,
            237931108758,
            255741077107,
            273532995464,
            291920592258,
            311220135425,
            331627447634,
            353284494958];
    }
}

contract CoinSale is Owned, Slopes {
    using SafeMath for uint;
    bool onSale;
    address public tokenAddress;
    address public tokenOwner;
    uint numberPurchased;
    uint initialWeiPerTan;
    uint weiPerTangent;
    uint purchaseGoal;
    uint slope;
    Tangent tokenContract;

    event SlopeIncreased(uint slope);
    event SaleEnded();
    event Purchase(uint tangles, uint weis, uint weisPerTangent, uint numberPurchased);
    
    modifier isOnSale {
        require(onSale == true);
        _;
    }
    
    function CoinSale(address tokenAddr) public {
        onSale = true;
        numberPurchased = 0;
        purchaseGoal = 3*10**4 * 1 ether;
        initialWeiPerTan = (1/10000) * 1 ether;
        weiPerTangent = initialWeiPerTan;
        tokenAddress = tokenAddr;
        tokenContract = Tangent(tokenAddress);
        tokenOwner = tokenContract.owner();
        slope = slopes[0];
    }

    modifier autoIncreaseSlope() {
        if (round+1 < purchased.length) {
            if (numberPurchased >= purchased[round+1]) {
                round++;
                slope = slopes[round];
                SlopeIncreased(slope);
            }
        }
        _;
    }
    
    function endSale() public onlyOwner returns (bool){
        if (numberPurchased < purchaseGoal) {
            return false;
        }
        onSale = false;
        SaleEnded();
        return true;
    }
    
    function withdraw() public onlyOwner {
        owner.transfer(this.balance);
    }
    
    function () public payable isOnSale autoIncreaseSlope {
        uint tangles = msg.value.mul(1 ether).div(weiPerTangent);
        tokenContract.transferFrom(tokenOwner, msg.sender, tangles);
        weiPerTangent = weiPerTangent.add(tangles.mul(slope).div(1 ether));
        numberPurchased = numberPurchased.add(tangles);
        Purchase(tangles, msg.value, weiPerTangent, numberPurchased);
    }
}
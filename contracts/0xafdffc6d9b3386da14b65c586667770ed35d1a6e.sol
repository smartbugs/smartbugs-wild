pragma solidity ^0.4.25;

contract Token {
    function transfer(address to, uint tokens) public returns (bool success);

    function balanceOf(address tokenOwner) public constant returns (uint balance);
}

contract EtherSnap {

    uint private units;
    uint private bonus;

    address private owner;

    // Token specification
    string public name = "EtherSnap";
    string public symbol = "ETS";
    uint public decimals = 18;

    uint private icoUnits; // ICO tokens
    uint private tnbUnits; // Team & Bounty tokens

    mapping(address => uint) public balances;
    mapping(address => uint) private contribution;
    mapping(address => uint) private extra_tokens;
    mapping(address => mapping(address => uint)) allowed;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Contribute(address indexed account, uint ethereum, uint i, uint b, uint e, uint t, uint bp, uint ep);

    constructor () public {
        owner = msg.sender;
    }

    function totalSupply() public view returns (uint) {
        return (icoUnits + tnbUnits) - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        require(tokens > 0 && balances[msg.sender] >= tokens && balances[to] + tokens > balances[to]);
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(tokens > 0 && balances[from] >= tokens && allowed[from][msg.sender] >= tokens && balances[to] + tokens > balances[to]);
        balances[to] += tokens;
        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function withdraw(address token) public returns (bool success) {
        // Allow owner only
        require(msg.sender == owner);
        // Transfer ethereum balance
        if (token == address(0)) {
            msg.sender.transfer(address(this).balance);
        }
        // Transfer ERC-20 tokens to owner
        else {
            Token ERC20 = Token(token);
            ERC20.transfer(owner, ERC20.balanceOf(address(this)));
        }
        return true;
    }

    function setup(uint _bonus, uint _units) public returns (bool success) {
        // Allow owner only
        require(msg.sender == owner);
        // Update ICO configuration
        bonus = _bonus;
        units = _units;
        return true;
    }

    function fill() public returns (bool success) {
        // Allow owner only
        require(msg.sender == owner);
        // Calculate maximum tokens to redeem
        uint maximum = 35 * (icoUnits / 65);
        // Checkout availability to redeem
        require(maximum > tnbUnits);
        // Calculate available tokens
        uint available = maximum - tnbUnits;
        // Update database
        tnbUnits += available;
        balances[msg.sender] += available;
        // Emit callbacks
        emit Transfer(address(this), msg.sender, available);
        return true;
    }

    function contribute(address _acc, uint _wei) private returns (bool success) {
        // Checkout ether and ICO state
        require(_wei > 0 && units > 0);

        // Calculate initial tokens for contribution
        uint iTokens = _wei * units;

        // Calculate bonus tokens
        uint bTokens = bonus > 0 ? ((iTokens * bonus) / 100) : 0;

        // Update contribution
        uint total = contribution[_acc] + _wei;
        contribution[_acc] = total;

        // Calculate extra bonus percentage for contribution
        uint extra = (total / 5 ether) * 10;
        extra = extra > 50 ? 50 : extra;

        // Calculate tokens for extra bonus percentage
        uint eTokens = extra > 0 ? (((total * units) * extra) / 100) : 0;

        // Remove already claimed extra tokens
        uint cTokens = extra_tokens[_acc];
        if (eTokens > cTokens) {
            eTokens -= cTokens;
        } else {
            eTokens = 0;
        }

        // Calculate sum of total tokens
        uint tTokens = iTokens + bTokens + eTokens;

        // Update user balance and database
        icoUnits += tTokens;
        balances[_acc] += tTokens;
        extra_tokens[_acc] += eTokens;

        // Emit callbacks
        emit Transfer(address(this), _acc, tTokens);
        emit Contribute(_acc, _wei, iTokens, bTokens, eTokens, tTokens, bonus, extra);

        return true;
    }

    function mint(address account, uint amount) public returns (bool success) {
        // Allow owner only
        require(msg.sender == owner);
        // Execute contribute method
        return contribute(account, amount);
    }

    function() public payable {
        contribute(msg.sender, msg.value);
    }
}
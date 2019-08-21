pragma solidity ^0.4.17;

contract ERC20Interface {
	function totalSupply() public constant returns (uint256);
	function balanceOf(address _owner) public constant returns (uint256);
	function transfer(address _to, uint256 _value) public returns (bool);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
	function approve(address _spender, uint256 _value) public returns (bool);
	function allowance(address _owner, address _spender) public constant returns (uint256);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract SafeMath {
  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract RandomToken {
    function balanceOf(address _owner) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract HalloweenCollectorToken is ERC20Interface, SafeMath {
    string constant token_name = "Halloween Limited Edition Token";
    string constant token_symbol = "HALW";
    uint8 constant token_decimals = 0;
    uint256 public constant ether_per_token = 0.0035 * 1 ether;
    uint public constant TOKEN_SWAP_DURATION_HOURS = 1 * 24;
    uint256 public constant token_airdrop_cnt_max = 1000;
    uint256 public constant token_airdrop_amount_each = 10;
    uint256 public constant token_swap_supply = 40000;

    uint public time_of_token_swap_start;
    uint public time_of_token_swap_end;
    uint256 totSupply;
    uint256 public airdrop_cnt;

    address owner;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) is_airdropped;
    
    
    modifier onlyOwner() {
        if (msg.sender != owner) { revert(); }
        _;
    }
    
    modifier transferAllowed() {
        _;
    }
    
    modifier purchaseAllowed() {
        if (now > time_of_token_swap_end) { revert(); }
        _;
    }
    
    function HalloweenCollectorToken() public {
        owner = msg.sender;
        uint256 airdrop_supply = safeMul(token_airdrop_cnt_max, token_airdrop_amount_each);
        totSupply = safeAdd(token_swap_supply, airdrop_supply);
        time_of_token_swap_start = now;
        time_of_token_swap_end = time_of_token_swap_start + TOKEN_SWAP_DURATION_HOURS * 1 hours;
        airdrop_cnt = 0;
        balances[owner] = totSupply;
    }

    function name() public pure returns (string)    { return token_name; }
    function symbol() public pure returns (string)  { return token_symbol; }
    function decimals() public pure returns (uint8) { return token_decimals; }
    
    function totalSupply() public view returns (uint256) {
        return totSupply;
    }
    
    function balanceOf(address a) public view returns (uint256) {
        return balances[a];
    }

    function transfer(address _to, uint256 _amount) public transferAllowed returns (bool) {
        if ( 
                _amount > 0
            &&  balances[msg.sender] >= _amount
            &&  balances[_to] + _amount > balances[_to]
        ) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public transferAllowed returns (bool) {
        if (
                _amount > 0
            &&  balances[_from] >= _amount
            &&  allowed[_from][msg.sender] >= _amount
            &&  balances[_to] + _amount > balances[_to]
        ) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }
 
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    function() public payable purchaseAllowed {
        if (msg.value == 0) {
            if (airdrop_cnt >= token_airdrop_cnt_max || is_airdropped[msg.sender]) {
                //  airdrop already received
                return;
            }
            else {
                //  airdrop
                airdrop_cnt++;
                is_airdropped[msg.sender] = true;
                balances[owner] = safeSub(balances[owner], token_airdrop_amount_each);
                balances[msg.sender] = safeAdd(balances[msg.sender], token_airdrop_amount_each);
                Transfer(address(this), msg.sender, token_airdrop_amount_each);
            }
        }
        else {
            //  normal swap
            uint256 tokenRequested = msg.value / ether_per_token;
            assert(tokenRequested > 0 && tokenRequested <= balances[owner]);
            uint256 cost = safeMul(tokenRequested, ether_per_token);
            uint256 change = safeSub(msg.value, cost);
            
            owner.transfer(cost);
            msg.sender.transfer(change);
            balances[owner] = safeSub(balances[owner], tokenRequested);
            balances[msg.sender] = safeAdd(balances[msg.sender], tokenRequested);
    
            Transfer(address(this), msg.sender, tokenRequested);
        }
    }
    
    function withdrawForeignTokens(address _tokenContract) public onlyOwner returns (bool) {
        RandomToken token = RandomToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }
}
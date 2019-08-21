pragma solidity ^0.4.11;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface IERC20 {
    function totalSupply() constant returns (uint256 totalSupply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



contract MyToken is IERC20 {
    using SafeMath for uint256;

    string public symbol = 'KCFOB';
    string public name = 'KC19700 OP TOKEN';

    uint8 public constant decimals = 18;
    uint256 public constant tokensPerEther = 3500;

    uint256 public _totalSupply = 10000000000000000000000000;
    uint256 public _maxSupply = 38000000000000000000000000;

    uint256 public totalContribution = 0;

    bool public purchasingAllowed = true;

    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) public allowed;


    function MyToken() {
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
    }


    function totalSupply() constant returns (uint256 totalSupply) {
        return _totalSupply;
    }
    /*
     * get some stats
     *
     */
    function getStats() public constant returns (uint256, uint256,  bool) {
        return (totalContribution, _totalSupply, purchasingAllowed);
    }

    function getStats2() public constant returns (bool) {
        return (purchasingAllowed);
    }


    /*
     * somehow unnecessery 
     */
    function withdraw() onlyOwner {
        owner.transfer(this.balance);
    }


    function () payable {
        require(
            msg.value > 0
            && purchasingAllowed
            && _totalSupply < _maxSupply 
        );
        /*  everything is in wei */
        uint256 baseTokens  = msg.value.mul(tokensPerEther);

        /* send tokens to buyer. Buyer gets baseTokens */
        balances[msg.sender] = balances[msg.sender].add(baseTokens);

        /* send eth to owner */
        owner.transfer(msg.value);
        
        totalContribution = totalContribution.add(msg.value);
        _totalSupply      = _totalSupply.add(baseTokens);

        Transfer(address(this), msg.sender, baseTokens);
    }

    function enablePurchasing() public onlyOwner {
        purchasingAllowed = true;
    }

    function disablePurchasing() public onlyOwner {
        purchasingAllowed = false;
    }


    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        require(
            (balances[msg.sender] >= _value)
            && (_value > 0)
            && (_to != address(0))
            && (balances[_to].add(_value) >= balances[_to])
            && (msg.data.length >= (2 * 32) + 4)
        );

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(
            (allowed[_from][msg.sender] >= _value) // Check allowance
            && (balances[_from] >= _value) // Check if the sender has enough
            && (_value > 0) // Don't allow 0value transfer
            && (_to != address(0)) // Prevent transfer to 0x0 address
            && (balances[_to].add(_value) >= balances[_to]) // Check for overflows
            && (msg.data.length >= (2 * 32) + 4) //mitigates the ERC20 short address attack
            //most of these things are not necesary
        );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        /* To change the approve amount you first have to reduce the addresses`
         * allowance to zero by calling `approve(_spender, 0)` if it is not
         * already 0 to mitigate the race condition described here:
         * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 */
        require(
            (_value == 0) 
            || (allowed[msg.sender][_spender] == 0)
        );
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /*
     * events
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}
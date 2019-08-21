pragma solidity ^0.4.20;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {    
    address public owner;
    
    function Ownable() public {
        owner = msg.sender;
    }
 
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract MasterNodeMining is Ownable{
    using SafeMath for uint;
    string public constant name = "Master Node Mining"; // Master Node Mining tokens name
    string public constant symbol = "MNM"; // Master Node Mining tokens ticker
    uint8 public constant decimals = 18; // Master Node Mining tokens decimals
    uint256 public constant maximumSupply =  10000000 * (10 ** uint256(decimals)); // Maximum 10M MNM tokens can be created
    uint256 public constant icoSupply =  9000000 * (10 ** uint256(decimals)); // Maximum 9M MNM tokens can be available for public ICO
    uint256 public constant TokensPerEther = 1000;
    uint256 public constant icoEnd = 1522540800;
    uint256 public constant teamTokens = 1538352000;
    address public multisig = 0xF33014a0A4Cf06df687c02023C032e42a4719573;
    uint256 public totalSupply;

    function transfer(address _to, uint _value) public returns (bool success) {
		require( msg.data.length >= (2 * 32) + 4 );
		require( _value > 0 );
		require( balances[msg.sender] >= _value );
		require( balances[_to] + _value > balances[_to] );
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
		require( msg.data.length >= (3 * 32) + 4 );
		require( _value > 0 );
		require( balances[_from] >= _value );
		require( allowed[_from][msg.sender] >= _value );
		require( balances[_to] + _value > balances[_to] );
        balances[_from] -= _value;
		allowed[_from][msg.sender] -= _value;
		balances[_to] += _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    function ICOmint() public onlyOwner {
      require(totalSupply == 0);
      totalSupply = icoSupply;
      balances[msg.sender] = icoSupply;
      Transfer(0x0, msg.sender, icoSupply);
    }

    function TEAMmint() public onlyOwner {
      uint256 addSupply = maximumSupply - totalSupply;
      uint256 currentSupply = totalSupply + addSupply;
      require(now > teamTokens);
      require(totalSupply > 0 && addSupply > 0);
      require(maximumSupply >= currentSupply);
      totalSupply += addSupply;
      balances[owner] += addSupply;
    }

    function() external payable {
        uint256 tokens = msg.value.mul(TokensPerEther);
        require(now < icoEnd && balances[owner] >= tokens && tokens >= 0);
        balances[msg.sender] += tokens;
        balances[owner] -= tokens;
        Transfer(owner,msg.sender, tokens);
        multisig.transfer(msg.value);
    }
}
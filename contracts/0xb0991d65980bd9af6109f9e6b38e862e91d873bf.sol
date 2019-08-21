pragma solidity ^0.4.16;

contract ERC20Interface {
     function totalSupply() constant returns (uint256 supply);
     function balanceOf(address _owner) constant returns (uint256 balance);
     function transfer(address _to, uint256 _value) returns(bool);
     function transferFrom(address _from, address _to, uint256 _value) returns(bool);
     function approve(address _spender, uint256 _value) returns (bool success);
     function allowance(address _owner, address _spender) constant returns (uint256 remaining);
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StdToken is ERC20Interface {
     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;
     uint public supply = 0;

     function transfer(address _to, uint256 _value) returns(bool) {
          require(balances[msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[msg.sender] -= _value;
          balances[_to] += _value;

          Transfer(msg.sender, _to, _value);
          return true;
     }

     function transferFrom(address _from, address _to, uint256 _value) returns(bool){
          require(balances[_from] >= _value);
          require(allowed[_from][msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[_to] += _value;
          balances[_from] -= _value;
          allowed[_from][msg.sender] -= _value;

          Transfer(_from, _to, _value);
          return true;
     }

     function totalSupply() constant returns (uint256) {
          return supply;
     }

     function balanceOf(address _owner) constant returns (uint256) {
          return balances[_owner];
     }

     function approve(address _spender, uint256 _value) returns (bool) {
          require((_value == 0) || (allowed[msg.sender][_spender] == 0));

          allowed[msg.sender][_spender] = _value;
          Approval(msg.sender, _spender, _value);

          return true;
     }

     function allowance(address _owner, address _spender) constant returns (uint256) {
          return allowed[_owner][_spender];
     }
}

contract myToken is StdToken
{
    string public constant name = "168 Token";
    string public constant symbol = "168";
    uint public constant decimals = 18;
    uint public constant TOKEN_SUPPLY_LIMIT = 1000000 * (1 ether / 1 wei);
    uint public constant MANAGER_SUPPLY = 650000 * (1 ether / 1 wei);
    uint public constant ICO_PRICE = 1000;     // per 1 Ether
    address public tokenManager = 0;

    modifier onlyTokenManager()
    {
        require(msg.sender==tokenManager);
        _;
    }

    function myToken()
    {
        tokenManager = msg.sender;
        balances[tokenManager] += MANAGER_SUPPLY;
        supply += MANAGER_SUPPLY;
    }

    function buyTokens() public payable
    {
        require(msg.value >= ((1 ether / 1 wei) / 100));

        uint newTokens = msg.value * ICO_PRICE;

        require(supply + newTokens <= TOKEN_SUPPLY_LIMIT);

        tokenManager.transfer(msg.value);

        balances[msg.sender] += newTokens;
        supply += newTokens;
    }

    function setTokenManager(address _mgr) public onlyTokenManager
    {
        tokenManager = _mgr;
    }

    function() payable
    {
        buyTokens();
    }
}
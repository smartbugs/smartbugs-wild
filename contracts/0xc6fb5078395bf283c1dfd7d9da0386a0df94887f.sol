pragma solidity ^0.4.24;
contract LPE {
    address public owner;
    mapping (address => uint) public balances;
    address[] public users;
    uint256 public total=0;
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply=100000000000000000;
    string public name="LOVEPAY";
    uint8 public decimals=8;
    string public symbol="LPE";
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    constructor() public{
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }

    function userCount() public view returns (uint256) {
        return users.length;
    }

     function getTotal() public view returns (uint256) {
        return total;
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
     function contractBalance() public view returns (uint256) {
        return (address)(this).balance;
    }
     function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function() public payable {
        if (msg.value > 0 ) {
                        total += msg.value;
                        bool isfind=false;
                        for(uint i=0;i<users.length;i++)
                        {
                            if(msg.sender==users[i])
                            {
                                isfind=true;
                                break;
                            }
                        }
                        if(!isfind){users.push(msg.sender);}
        }
    }
}
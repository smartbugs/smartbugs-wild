pragma solidity ^0.4.11;

/* taking ideas from FirstBlood token */
contract SafeMath {

    /* function assert(bool assertion) internal { */
    /*   if (!assertion) { */
    /*     throw; */
    /*   } */
    /* }      // assert no longer needed once solidity is on 0.4.10 */

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSub(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract owned {
    address public owner;
    address[] public allowedTransferDuringICO;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }

    function isAllowedTransferDuringICO() public constant returns (bool){
        for(uint i = 0; i < allowedTransferDuringICO.length; i++) {
            if (allowedTransferDuringICO[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract Token is owned {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    
    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is SafeMath, Token {

    uint public lockBlock;
    /* Send coins */
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(block.number >= lockBlock || isAllowedTransferDuringICO());
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = safeSub(balances[msg.sender], _value);
            balances[_to] = safeAdd(balances[_to], _value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(block.number >= lockBlock || isAllowedTransferDuringICO());
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] = safeAdd(balances[_to], _value);
            balances[_from] = safeSub(balances[_from], _value);
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        assert((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /* This creates an array with all balances */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract EICToken is StandardToken {

    // metadata
    string constant public name = "Entertainment Industry Coin";
    string constant public symbol = "EIC";
    uint256 constant public decimals = 18;

    function EICToken(
        uint _lockBlockPeriod)
        public
    {
        allowedTransferDuringICO.push(owner);
        totalSupply = 3125000000 * (10 ** decimals);
        balances[owner] = totalSupply;
        lockBlock = block.number + _lockBlockPeriod;
    }

    function distribute(address[] addr, uint256[] token) public onlyOwner {
        // only owner can call
        require(addr.length == token.length);
        allowedTransferDuringICO.push(addr[0]);
        allowedTransferDuringICO.push(addr[1]);
        for (uint i = 0; i < addr.length; i++) {
            transfer(addr[i], token[i] * (10 ** decimals));
        }
    }

}
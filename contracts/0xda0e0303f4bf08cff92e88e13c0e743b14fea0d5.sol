pragma solidity ^0.4.17;

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

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
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

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract MOERToken is StandardToken, SafeMath {

    // metadata
    string public constant name = "Moer Digital Assets Platform";
    string public constant symbol = "MOER";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // contracts
    address public owner;                                             // owner's address for MOER Team.

    // MOER parameters
    uint256 public currentSupply = 0;                                 // current supply tokens for sell
    uint256 public constant totalFund = 2 * (10**9) * 10**decimals;   // 2 billion MOER totally issued.
    
    // crowdsale parameters
    bool    public isFunding;                // switched to true in operational state
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;
    uint256 public tokenExchangeRate = 12000;             // 12000 MOER tokens per 1 ETH
    uint256 public totalFundingAmount = (10**8) * 10**decimals; // 100 million for crowdsale
    uint256 public currentFundingAmount = 0;

    // constructor
    function MOERToken(
        address _owner)
    {
        owner = _owner;
        
        isFunding = false;
        fundingStartBlock = 0;
        fundingStopBlock = 0;
        
        totalSupply = totalFund;
    }

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }

    /// @dev increase MOER's current supply
    function increaseSupply (uint256 _value, address _to) onlyOwner external {
        if (_value + currentSupply > totalSupply) throw;
        currentSupply = safeAdd(currentSupply, _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(address(0x0), _to, _value);
    }

    /// @dev change owner
    function changeOwner(address _newOwner) onlyOwner external {
        if (_newOwner == address(0x0)) throw;
        owner = _newOwner;
    }
    
    /// @dev set the token's tokenExchangeRate,
    function setTokenExchangeRate(uint256 _tokenExchangeRate) onlyOwner external {
        if (_tokenExchangeRate == 0) throw;
        if (_tokenExchangeRate == tokenExchangeRate) throw;

        tokenExchangeRate = _tokenExchangeRate;
    }    
    
    /// @dev set the token's totalFundingAmount,
    function setFundingAmount(uint256 _totalFundingAmount) onlyOwner external {
        if (_totalFundingAmount == 0) throw;
        if (_totalFundingAmount == totalFundingAmount) throw;
        if (_totalFundingAmount - currentFundingAmount + currentSupply > totalSupply) throw;

        totalFundingAmount = _totalFundingAmount;
    }    
    
    /// @dev sends ETH to MOER team
    function transferETH() onlyOwner external {
        if (this.balance == 0) throw;
        if (!owner.send(this.balance)) throw;
    }    
    
    /// @dev turn on the funding state
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) onlyOwner external {
        if (isFunding) throw;
        if (_fundingStartBlock >= _fundingStopBlock) throw;
        if (block.number >= _fundingStartBlock) throw;

        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }

    /// @dev turn off the funding state
    function stopFunding() onlyOwner external {
        if (!isFunding) throw;
        isFunding = false;
    }    
    
    /// buys the tokens
    function () payable {
        if (!isFunding) throw;
        if (msg.value == 0) throw;

        if (block.number < fundingStartBlock) throw;
        if (block.number > fundingStopBlock) throw;

        uint256 tokens = safeMult(msg.value, tokenExchangeRate);
        if (tokens + currentFundingAmount > totalFundingAmount) throw;

        currentFundingAmount = safeAdd(currentFundingAmount, tokens);
        currentSupply = safeAdd(currentSupply, tokens);
        balances[msg.sender] += tokens;

        Transfer(address(0x0), msg.sender, tokens);
    }    
}
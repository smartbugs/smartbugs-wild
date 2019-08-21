pragma solidity ^0.4.2;

/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
/// @title Abstract token contract - Functions to be implemented by token contracts.

contract AbstractToken {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}

contract StandardToken is AbstractToken {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /*
     *  Read and write storage functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read storage functions
     */
    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


/// @title Token contract - Implements Standard Token Interface but adds Pyramid Scheme Support :)
/// @author Rishab Hegde - <contact@rishabhegde.com>
contract eXtremeHodlCoin is StandardToken, SafeMath {

    /*
     * Token meta data
     */
    string constant public name = "eXtreme Hodl Coin";
    string constant public symbol = "XDL";
    uint8 constant public decimals = 0;
    
    uint private init_sellPrice = 2 wei;
    // uint private numberofcoins = 0;
    uint public sellPrice;
    uint public buyPrice;

    function buy_value() private returns (uint) { return (init_sellPrice ** (totalSupply + 1)); }
    
    function sell_value() private returns (uint){ return (init_sellPrice ** totalSupply); }
    
    function update_prices() private{
        sellPrice = sell_value();
        buyPrice = buy_value();
    
    }
    
    // Address of the founder of RiskCoin.
    address public founder = 0x0803882f6c7fc348EBc2d25F3E8Fa13df25ceDFa;

    /*
     * Contract functions
     */
    /// @dev Allows user to create tokens if token creation is still going
    /// and cap was not reached. Returns token count.
    function fund() public payable returns (bool){
        uint investment = 0;
        uint tokenCount = 0;
        while ((msg.value-investment) >= buy_value()) {
            investment += buy_value();
            totalSupply += 1;
            tokenCount++;
        }
        
        update_prices();
        balances[msg.sender] += tokenCount;
        Issuance(msg.sender, tokenCount);
        
        if (msg.value > investment) {
            msg.sender.transfer(msg.value - investment);
        }
        return true;
    }

    function withdraw(uint withdrawRequest) public returns (bool){
        require (totalSupply > 0);
        uint tokenCount = withdrawRequest;
        uint withdrawal = 0;
        
        if (balances[msg.sender] >= tokenCount) {
            while (sell_value() > 0 && tokenCount > 0){
                withdrawal += sell_value();
                tokenCount -= 1;
                totalSupply -= 1;
            }
            update_prices();
            balances[msg.sender] -= (withdrawRequest-tokenCount);
            msg.sender.transfer(withdrawal);
            return true;
        } else {
            return false;
        }
    }

    /// @dev Contract constructor function sets initial token balances.
    function eXtremeHodlCoin()
    {   
        update_prices();
    }
}
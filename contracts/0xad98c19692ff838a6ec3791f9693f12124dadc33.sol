pragma solidity ^0.4.19;

interface ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value, bytes _data) external;
}

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
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract MiaoMiToken is owned {
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

    mapping(address => uint) balances; // List of user balances.
    
    string _name;
    string _symbol;
    uint8 DECIMALS = 5;
    // 6 decimals is the strongly suggested default, avoid changing it
    uint256 _totalSupply;
    address team_addr;
    uint256 team_keep_amount;
    uint256 _saledTotal = 0;
    uint256 _amounToSale = 0;
    uint _buyPrice = 10000;
    uint256 _totalEther = 0;


    function MiaoMiToken(
        string tokenName,
        string tokenSymbol
    ) public 
    {
        _totalSupply = 950000000 * 10 ** uint256(DECIMALS);  // 实际供应总量
        _amounToSale = 950000000 * 10 ** uint256(DECIMALS);
        _saledTotal = 0;
        _name = tokenName;                                       // 设置Token名字
        _symbol = tokenSymbol;                                   // 设置Token符号
    }

    function name() public constant returns (string) {
        return _name;
    }

    function symbol() public constant returns (string) {
        return _symbol;
    }

    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }

    function buyPrice() public constant returns (uint256) {
        return _buyPrice;
    }
    
    function decimals() public constant returns (uint8) {
        return DECIMALS;
    }

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the tokenFallback function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the tokenFallback function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes _data) public returns (bool ok) {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        uint codeLength;
        require (_to != 0x0);
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }
        require(balances[msg.sender]>=_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    
    /**
     * @dev Transfer the specified amount of tokens to the specified address.

     *      This function works the same with the previous one
     *      but doesn't contain _data param.
     *      Added due to backwards compatibility reasons.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint _value) public returns(bool ok) {
        uint codeLength;
        bytes memory empty;
        require (_to != 0x0);
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }
        require(balances[msg.sender]>=_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        Transfer(msg.sender, _to, _value, empty);
        return true;
    }

    
    /**
     * @dev Returns balance of the _owner.
     *
     * @param _owner   The address whose balance will be returned.
     * @return balance Balance of the _owner.
     */
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function setPrices(uint256 newBuyPrice) onlyOwner public {
        _buyPrice = newBuyPrice;
    }

    /// @notice Buy tokens from contract by sending ether
    function buyCoin() payable public returns (bool ok) {
        uint amount = ((msg.value * _buyPrice) * 10 ** uint256(DECIMALS))/1000000000000000000;               // calculates the amount
        require ((_amounToSale - _saledTotal)>=amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        _saledTotal = _saledTotal.add(amount);
        _totalEther += msg.value;
        return true;
    }

    function dispatchTo(address target, uint256 amount) onlyOwner public returns (bool ok) {
        require ((_amounToSale - _saledTotal)>=amount);
        balances[target] = balances[target].add(amount);
        _saledTotal = _saledTotal.add(amount);
        return true;
    }

    function withdrawTo(address _target, uint256 _value) onlyOwner public returns (bool ok) {
        require(_totalEther <= _value);
        _totalEther -= _value;
        _target.transfer(_value);
        return true;
    }
    
    function () payable public {
    }

}
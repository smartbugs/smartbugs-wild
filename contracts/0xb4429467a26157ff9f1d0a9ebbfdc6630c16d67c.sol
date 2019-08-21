pragma solidity ^0.4.18;

/**
 * www.adultcam.co.in
 */

contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b > 0);
      uint c = a / b;
      assert(a == b * c + a % b);
      return c;
    }

}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
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

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

    /**
     * @title Ownable
     * @dev The Ownable contract has an owner address, and provides basic authorization control
     * functions, this simplifies the implementation of "user permissions".
     */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
}

contract AciToken is SafeMath, StandardToken, Pausable {

    string public constant name = "ACI Token";
    string public constant symbol = "ACI";
    uint256 public constant decimals = 18;
    uint256 public constant maxTokens = 20000000;

    uint256 public oneTokenInWei = 700*10**12; //-30%
    //uint256 public oneTokenInWei = 850*10**12; //-15%
    //uint256 public oneTokenInWei = 1000*10**12; //startICO

    uint public totalWeiRecieved;

    event CreateACI(address indexed _to, uint256 _value);
    event PriceChanged(string _text, uint _newPrice);
    event StageChanged(string _text);
    event Withdraw(address to, uint amount);

    function AciToken() public {
    }

    function () public payable {
        createTokens();
    }


    function createTokens() internal whenNotPaused {
        uint256 tokens = safeDiv(msg.value, oneTokenInWei);
        uint256 checkedSupply = safeAdd(totalSupply, tokens);

        if ( checkedSupply <= maxTokens ) {
            addTokens(tokens);
        } else {
            revert();
        }
    }

    function addTokens(uint256 tokens) internal {
        if (msg.value <= 0) revert();
        balances[msg.sender] += tokens;
        totalSupply = safeAdd(totalSupply, tokens);
        totalWeiRecieved += msg.value;
        CreateACI(msg.sender, tokens*10*18);
    }

    function withdraw(address _toAddress, uint256 amount) external onlyOwner {
        require(_toAddress != address(0));
        _toAddress.transfer(amount);
        Withdraw(_toAddress, amount);
    }

    function setEthPrice(uint256 _tokenPrice) external onlyOwner {
        oneTokenInWei = _tokenPrice;
        PriceChanged("New price set", _tokenPrice);
    }

    function generateTokens(address _reciever, uint256 _amount) external onlyOwner {
        require(_reciever != address(0));
        balances[_reciever] += _amount;
        totalSupply = safeAdd(totalSupply, _amount);
        CreateACI(_reciever, _amount);
    }

}
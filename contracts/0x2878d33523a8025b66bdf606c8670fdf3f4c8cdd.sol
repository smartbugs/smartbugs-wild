pragma solidity ^0.4.16;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath32 {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }
    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath8 {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint8 a, uint8 b) internal pure returns (uint8) {
    if (a == 0) {
      return 0;
    }
    uint8 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint8 a, uint8 b) internal pure returns (uint8) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint8 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint8 a, uint8 b) internal pure returns (uint8) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint8 a, uint8 b) internal pure returns (uint8) {
    uint8 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);
    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;
  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    
    emit Transfer(_from, _to, _value);
    return true;
  }
  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;
 
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  
  modifier whenPaused() {
    require(paused);
    _;
  }
 
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }
  
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }
}
/**
 * 
 * @author uchiha-itachi@mail.com
 * 
 */
contract S3DContract is Ownable, PausableToken {
    
    modifier shareholderOnly {
        require(balances[msg.sender] > 0);
        _;
    }
    
    modifier acceptDividend {
        require(address(this).balance >= 1 ether);
        require(block.number - lastDivideBlock >= freezenBlocks);
        _;
    }
    
    using SafeMath for uint256;
    
    string public name = 'Share of Lottery Token';
    string public symbol = 'SLT';
    string public version = '1.0.2';
    uint8 public decimals = 0;
    bool public ico = true;
    uint256 public ico_price = 0.1 ether;
    uint8 public ico_percent = 20;
    uint256 public ico_amount = 0;
    uint256 public initShares ;
    uint256 public totalShare = 0;
    
    event ReciveEth(address _from, uint amount);
    event SendBouns(uint _amount);
    event MyProfitRecord(address _addr, uint _amount);
    
    event ReciveFound(address _from, uint amount);
    event TransferFound(address _to, uint amount);
    event TransferShareFail(address _to, uint amount);
    
    uint256 lastDivideBlock;
    uint freezenBlocks =  5990;
    
    address[] accounts;
    
    constructor (uint256 initialSupply) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        initShares = totalSupply;
        balances[msg.sender] = totalSupply;
        accounts.push(msg.sender);
    }
    
    function setIcoPrice(uint256 _price) external onlyOwner {
        require(_price > 0);
        ico_price = _price;
    }
    
    
    function setIcoStatus(bool _flag) external onlyOwner {
        ico = _flag;
    }
    
    // Sell Shares
    function buy() external payable {
        require(ico);
        require(msg.value > 0 && msg.value % ico_price == 0);
        uint256 shares = msg.value.div(ico_price);
        require(ico_amount.add(shares) <= initShares.div(100).mul(ico_percent));
        
        emit ReciveFound(msg.sender, msg.value);
        balances[msg.sender] = balances[msg.sender].add(shares);
        totalSupply = totalSupply.add(shares.mul(10 ** decimals));
        ico_amount = ico_amount.add(shares);
        owner.transfer(msg.value);
        emit TransferFound(owner, msg.value);
    }
    
    // Cash Desk
    function () public payable {
        emit ReciveEth(msg.sender, msg.value);
    }
    
    function sendBouns() external acceptDividend shareholderOnly {
        _sendBonus();
        
    }
    
    // dispatch bouns
    function _sendBonus() internal {
        // caculate bouns
        lastDivideBlock = block.number;
        uint256 total = address(this).balance;
        address[] memory _accounts = accounts;
        // do
        for (uint i =0; i < _accounts.length; i++) {
            if (balances[_accounts[i]] > 0) {
                uint256 interest = total.div(totalSupply).mul(balances[_accounts[i]]);
                if (interest > 0) {
                    if (_accounts[i].send(interest)) {
                        emit MyProfitRecord(_accounts[i], interest);
                    }
                }
            }
        }
        totalShare.add(total);
        emit SendBouns(total);
    }
    
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        if (super.transfer(_to, _value)) {
            _addAccount(_to);
        }
    }
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        if  (super.transferFrom(_from, _to, _value)) {
            _addAccount(_to);
        }
    }
    
    function _addAccount(address _addr) internal returns(bool) {
        address[] memory _accounts = accounts;
        for (uint i = 0; i < _accounts.length; i++) {
            if (_accounts[i] == _addr) {
                return false;
            }
        }
        accounts.push(_addr);
        return true;
    }
    
    
    function addAccount(address _addr) external onlyOwner {
        _addAccount(_addr);
    }
}
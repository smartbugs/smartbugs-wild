pragma solidity ^0.5.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract Owned {
    address public owner;
    address public newOwner;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        owner = newOwner;
    }
}

contract easyExchangeCoins is IERC20, Owned {
    using SafeMath for uint256;
    
    // Constructor
    constructor() public {
        owner = 0x3CC2Ef418b7c2e36110f4521e982576AF9f5c8fA;
        contractAddress = address(this);
        _balances[contractAddress] = 20000000 * 10 ** decimals;
        _balances[owner] = 80000000 * 10 ** decimals;
        emit Transfer(address(0), contractAddress, 20000000 * 10 ** decimals);
        emit Transfer(address(0), owner, 80000000 * 10 ** decimals);
        ICOActive = true;
    }
    
    // ICO Feature
    function ICOBalance() public view returns (uint) {
        return _balances[contractAddress];
    }
    bool public ICOActive;
    uint256 public ICOPrice = 10000000;
    
    function () external payable {
        if (ICOActive == false) {
            revert();
        } else if (ICOBalance() == 0) {
            ICOActive = false;
            revert();
        } else {
            uint256 affordAmount = msg.value / ICOPrice;
            if (affordAmount <= _balances[contractAddress]) {
                _balances[contractAddress] = _balances[contractAddress].sub(affordAmount);
                _balances[msg.sender] = _balances[msg.sender].add(affordAmount);
                emit Transfer(contractAddress, msg.sender, affordAmount);
            } else {
                uint256 buyAmount = _balances[contractAddress];
                uint256 cost = buyAmount * ICOPrice;
                _balances[contractAddress] = _balances[contractAddress].sub(buyAmount);
                _balances[msg.sender] = _balances[msg.sender].add(buyAmount);
                emit Transfer(contractAddress, msg.sender, buyAmount);
                msg.sender.transfer(msg.value - cost);
                ICOActive = false;
            }
        }
    }
    
    // Change ICO Price IN WEI
    function changeICOPrice(uint256 newPrice) public onlyOwner {
        uint256 _newPrice = newPrice * 10 ** decimals;
        ICOPrice = _newPrice;
    }
    
    
    // Token owner can claim ETH from ICO sales
    function withdrawETH() public onlyOwner {
        msg.sender.transfer(contractAddress.balance);
    }
    
    function endICO() public onlyOwner {
        msg.sender.transfer(contractAddress.balance);
        ICOActive = false;
        uint256 _amount = _balances[contractAddress];
        _balances[owner] = _balances[owner].add(_amount);
        _balances[contractAddress] = 0;
        emit Transfer(contractAddress, owner, _amount);
    }
    
    // Token Setup
    string public constant name = "Easy Exchange Coins";
    string public constant symbol = "EEC";
    uint256 public constant decimals = 8;
    uint256 public constant supply = 100000000 * 10 ** decimals;
    address private contractAddress;
    
    // Balances for each account
    mapping(address => uint256) _balances;
    
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) public _allowed;
 
    // Get the total supply of tokens
    function totalSupply() public view returns (uint) {
        return supply;
    }
    
    // Get the token balance for account `tokenOwner`
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return _balances[tokenOwner];
    }
 
    // Get the allowance of funds beteen a token holder and a spender
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return _allowed[tokenOwner][spender];
    }
    
    // Transfer the balance from owner's account to another account
    function transfer(address to, uint value) public returns (bool success) {
        require(_balances[msg.sender] >= value);
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    // Sets how much a sender is allowed to use of an owners funds
    function approve(address spender, uint value) public returns (bool success) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    // Transfer from function, pulls from allowance
    function transferFrom(address from, address to, uint value) public returns (bool success) {
        require(value <= balanceOf(from));
        require(value <= allowance(from, to));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][to] = _allowed[from][to].sub(value);
        emit Transfer(from, to, value);
        return true;
    }
}
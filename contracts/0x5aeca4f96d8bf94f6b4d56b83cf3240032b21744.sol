pragma solidity ^0.4.24;

// File: contracts/zeppelin/ownership/Ownable.sol
contract Ownable {
  address public owner;
  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

// File: contracts/zeppelin/lifecycle/Pausable.sol
contract Pausable is Ownable {
  event PausePublic(bool newState);
  event PauseOwnerAdmin(bool newState);

  bool public pausedPublic = true;
  bool public pausedOwnerAdmin = false;

  address public admin;

  modifier whenNotPaused() {
    if(pausedPublic) {
      if(!pausedOwnerAdmin) {
        require(msg.sender == admin || msg.sender == owner);
      } else {
        revert();
      }
    }
    _;
  }

  function pause(bool newPausedPublic, bool newPausedOwnerAdmin) onlyOwner public {
    require(!(newPausedPublic == false && newPausedOwnerAdmin == true));

    pausedPublic = newPausedPublic;
    pausedOwnerAdmin = newPausedOwnerAdmin;

    emit PausePublic(newPausedPublic);
    emit PauseOwnerAdmin(newPausedOwnerAdmin);
  }
}

// File: contracts/zeppelin/math/SafeMath.sol
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

// File: contracts/zeppelin/token/ERC20Basic.sol
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/zeppelin/token/BasicToken.sol

contract BasicToken is ERC20Basic  {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: contracts/zeppelin/token/PausableToken.sol
contract PausableToken is BasicToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }
}

// File: contracts/DsionToken.sol
contract DsionToken is PausableToken {
    string  public  constant name = "Dsion";
    string  public  constant symbol = "DSN";
    uint8   public  constant decimals = 8;
    uint   public  totallockedtime;

     // new feature, Lee
    mapping(address => uint) approvedInvestorListWithDate;

    constructor(uint _totallockedtime) public
    {
        admin = owner;
        totalSupply = 100000000000000000;
        balances[msg.sender] = totalSupply;
        totallockedtime = _totallockedtime;
        emit Transfer(address(0x0), msg.sender, totalSupply);
    }

    function setTotalLockedTime(uint _value) onlyOwner public{
        totallockedtime = _value;
    }

    function getTime() public constant returns (uint) {
        return now;
    }

    function isUnlocked() internal view returns (bool) {
        return getTime() >= getLockFundsReleaseTime(msg.sender);
    }

    modifier validDestination(address to)
    {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    modifier onlyWhenUnlocked()
    {
      if (msg.sender != admin) {
        require(getTime() >= totallockedtime);
        require(isUnlocked());
      }
      _;
    }

    function transfer(address _to, uint _value) onlyWhenUnlocked public validDestination(_to) returns (bool)
    {
      return super.transfer(_to, _value);
    }

    function getLockFundsReleaseTime(address _addr) private view returns(uint)
    {
        return approvedInvestorListWithDate[_addr];
    }

    function setLockFunds(address[] newInvestorList, uint releaseTime) onlyOwner public
    {
        require(releaseTime > getTime());
        for (uint i = 0; i < newInvestorList.length; i++)
        {
            approvedInvestorListWithDate[newInvestorList[i]] = releaseTime;
        }
    }

    function removeLockFunds(address[] investorList) onlyOwner public
    {
        for (uint i = 0; i < investorList.length; i++)
        {
            approvedInvestorListWithDate[investorList[i]] = 0;
            delete(approvedInvestorListWithDate[investorList[i]]);
        }
    }

    function setLockFund(address newInvestor, uint releaseTime) onlyOwner public
    {
        require(releaseTime > getTime());
        approvedInvestorListWithDate[newInvestor] = releaseTime;
    }


    function removeLockFund(address investor) onlyOwner public
    {
        approvedInvestorListWithDate[investor] = 0;
        delete(approvedInvestorListWithDate[investor]);
    }

    event Burn(address indexed _burner, uint _value);
    function burn(uint _value) onlyOwner public returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    function burnFrom(address _account, uint256 _amount) onlyOwner public returns (bool)
    {
      require(_account != 0);
      require(_amount <= balances[_account]);

      totalSupply = totalSupply.sub(_amount);
      balances[_account] = balances[_account].sub(_amount);
      emit Transfer(_account, address(0), _amount);
      return true;
    }
}
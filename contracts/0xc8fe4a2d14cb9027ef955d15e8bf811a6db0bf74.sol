pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = 0x0;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract PresaleOracles is Claimable {
/*
 * PresaleOracles
 * Simple Presale contract
 * built by github.com/rstormsf Roman Storm
 */
    using SafeMath for uint256;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public cap;
    uint256 public totalInvestedInWei;
    uint256 public minimumContribution;
    mapping(address => uint256) public investorBalances;
    mapping(address => bool) public whitelist;
    uint256 public investorsLength;
    address public vault;
    bool public isInitialized = false;
    // TESTED by Roman Storm
    function () public payable {
        buy();
    }
    //TESTED by Roman Storm
    function Presale() public {
    }
    //TESTED by Roman Storm
    function initialize(uint256 _startTime, uint256 _endTime, uint256 _cap, uint256 _minimumContribution, address _vault) public onlyOwner {
        require(!isInitialized);
        require(_startTime != 0);
        require(_endTime != 0);
        require(_endTime > _startTime);
        require(_cap != 0);
        require(_minimumContribution != 0);
        require(_vault != 0x0);
        require(_cap > _minimumContribution);
        startTime = _startTime;
        endTime = _endTime;
        cap = _cap;
        isInitialized = true;
        minimumContribution = _minimumContribution;
        vault = _vault;
    }
    //TESTED by Roman Storm
    event Contribution(address indexed investor, uint256 investorAmount, uint256 investorTotal, uint256 totalAmount);
    function buy() public payable {
        require(whitelist[msg.sender]);
        require(isValidPurchase(msg.value));
        require(isInitialized);
        require(getTime() >= startTime && getTime() <= endTime);
        address investor = msg.sender;
        investorBalances[investor] += msg.value;
        totalInvestedInWei += msg.value;
        forwardFunds(msg.value);
        Contribution(msg.sender, msg.value, investorBalances[investor], totalInvestedInWei);
    }
    
    //TESTED by Roman Storm
    function forwardFunds(uint256 _amount) internal {
        vault.transfer(_amount);
    }
    //TESTED by Roman Storm
    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
    
        ERC20Basic token = ERC20Basic(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
    }

    function getTime() internal view returns(uint256) {
        return now;
    }
    //TESTED by Roman Storm
    function isValidPurchase(uint256 _amount) public view returns(bool) {
        bool nonZero = _amount > 0;
        bool hasMinimumAmount = investorBalances[msg.sender].add(_amount) >= minimumContribution;
        bool withinCap = totalInvestedInWei.add(_amount) <= cap;
        return hasMinimumAmount && withinCap && nonZero;
    }
    //TESTED by Roman Storm
    function whitelistInvestor(address _newInvestor) public onlyOwner {
        if(!whitelist[_newInvestor]) {
            whitelist[_newInvestor] = true;
            investorsLength++;
        }
    }
    //TESTED by Roman Storm
    function whitelistInvestors(address[] _investors) external onlyOwner {
        require(_investors.length <= 250);
        for(uint8 i=0; i<_investors.length;i++) {
            address newInvestor = _investors[i];
            if(!whitelist[newInvestor]) {
                whitelist[newInvestor] = true;
                investorsLength++;
            }
        }
    }
    function blacklistInvestor(address _investor) public onlyOwner {
        if(whitelist[_investor]) {
            delete whitelist[_investor];
            if(investorsLength != 0) {
                investorsLength--;
            }
        }
    }
}
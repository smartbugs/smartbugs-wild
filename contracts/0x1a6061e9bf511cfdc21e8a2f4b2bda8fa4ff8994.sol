pragma solidity ^0.4.16;

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
  address owner;


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
  address pendingOwner;

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

contract DopamemePresale is Claimable {
    using SafeMath for uint256;
    uint256 public maxCap = 14000000000000000000;  // 1400 ETH
    uint256 public minCap = 3000000000000000000;  // 300 ETH
    uint256 public minimum_investment = 15000000000000000; // 0.015 ETH
    uint256 public totalInvestedInWei;
    uint8 public exchangeRate = 230;  // ICO rate 200 + 15% Presale Bonus
    uint256 public DMT_TotalSuply = 1e26;
    uint256 public startBlock = 4597180;  // 21Nov2017_23_gmt
    uint256 public endBlock;
    uint256 public end_Dec_21_2017 = 1513897200;
    bool public isInitialized = false;
    bool public paused = false;

    uint256 public tokensGenerated;
    uint256 public investorsLength;
    
    address vault;
    mapping(address => uint256) public investorBalances;
    mapping(address => uint256) public investorToken;
    mapping(address => bool) whitelist;
    
    modifier notPaused() {
        require(!paused);
        _;
    }

    function hasStarted() public constant returns(bool) {
        return block.number >= startBlock;
    }

    function hasEnded() public constant returns (bool) {
        return (getTime() > end_Dec_21_2017 || maxCapReached());
    }

    function showVault() onlyOwner constant returns(address) {
        return vault;
    }

    function showOwner() onlyOwner constant returns(address) {
        return owner;
    }

    /// @return Total to invest in weis.
    function toFound() public constant returns(uint256) {
        return maxCap >= totalInvestedInWei ? maxCap - totalInvestedInWei : 0;
    }
    
    /// @return Total to invest in weis.
    function tokensleft() public constant returns(uint256) {
        return DMT_TotalSuply > tokensGenerated ? DMT_TotalSuply - tokensGenerated : 0;
    }

    function maxCapReached() public constant returns(bool) {
        return totalInvestedInWei >= maxCap;
    }

    function minCapReached() public constant returns(bool) {
        return totalInvestedInWei >= minCap;
    }

    function () public payable {
        buy();
    }

    /// @notice Pauses the contribution if there is any issue
    function pauseContribution(bool _paused) onlyOwner {
        paused = _paused;
    }
    
    function initialize(address _vault) public onlyOwner {
        require(!isInitialized);
        require(_vault != 0x0);
        isInitialized = true;
        vault = _vault;
        Initialized(block.number, getTime());
    }

    function buy() public payable notPaused {
        require(isInitialized);
        require(hasStarted());
        require(!hasEnded());
        require(isValidPurchase(msg.value));
        whitelistInvestor(msg.sender);
        address investor = msg.sender;
        investorBalances[investor] += msg.value;
        uint256 tokens = msg.value.mul(exchangeRate);
        investorToken[investor] += tokens;
        tokensGenerated += tokens;
        totalInvestedInWei += msg.value;
        forwardFunds(msg.value);
        NewSale(investor, tokens);
        if(hasEnded()){
            endBlock = block.number;
            Finalized(endBlock, getTime());
        }
    }
    function forwardFunds(uint256 _amount) internal {
        vault.transfer(_amount);
    }

    function getTime() internal view returns(uint256) {
        return now;
    }
    
    function isValidPurchase(uint256 _amount) internal view returns(bool) {
        bool nonZero = _amount > 0;
        bool hasMinimumAmount = investorBalances[msg.sender].add(_amount) >= minimum_investment;
        bool withinCap = totalInvestedInWei.add(_amount) <= maxCap;
        return hasMinimumAmount && withinCap && nonZero;
    }
    function whitelistInvestor(address _newInvestor) internal {
        if(!whitelist[_newInvestor]) {
            whitelist[_newInvestor] = true;
            investorsLength++;
        }
    }
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

    event NewSale(address indexed investor, uint256 _tokens);
    event Initialized(uint256 _block, uint _now);
    event Finalized(uint256 _block, uint _now);
}
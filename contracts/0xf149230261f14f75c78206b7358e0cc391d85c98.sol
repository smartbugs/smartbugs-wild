pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

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
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract SYNVault {
    // flag to determine if address is for a real contract or not
    bool public isSYNVault = false;

    SynchroCoin synchroCoin;
    address businessAddress;
    uint256 unlockedAtBlockNumber;
    // Locked for 345days (1year after completion of the crowdsale)
    // 2129143 blocks = 24 hours * 60 minutes * 60 seconds * 345days / 14seconds per block
    uint256 public constant numBlocksLocked = 2129143;

    /// @notice Constructor function sets the Multisig address and
    /// total number of locked tokens to transfer
    function SYNVault(address _businessAddress) public {
        require(_businessAddress != 0x0);
        synchroCoin = SynchroCoin(msg.sender);
        businessAddress = _businessAddress;
        isSYNVault = true;
        unlockedAtBlockNumber = SafeMath.add(block.number, numBlocksLocked); // 345 days of blocks later
    }

    /// @notice Transfer locked tokens to Synchrolife's wallet
    function unlock() external {
        // Wait your turn!
        require(block.number > unlockedAtBlockNumber);
        // Will fail if allocation (and therefore toTransfer) is 0.
        if (!synchroCoin.transfer(businessAddress, synchroCoin.balanceOf(this))) revert();
    }

    // disallow payment this is for SYN not ether
    function () public { revert(); }
}

contract SynchroCoin is Ownable, StandardToken {

    string public constant symbol = "SYC";
    string public constant name = "SynchroCoin";
    uint8 public constant decimals = 18;
    uint256 public constant initialSupply = 100000000e18;    //100000000000000000000000000
    
    uint256 public constant startDate = 1506092400;
    uint256 public constant endDate = 1508511599;
    uint256 public constant firstPresaleStart = 1502884800;
    uint256 public constant firstPresaleEnd = 1503835140;
    uint256 public constant secondPresaleStart = 1504526400;
    uint256 public constant secondPresaleEnd = 1504785540;

    //55% for CrowdSale distribution
    uint256 public constant crowdSalePercentage = 5500;
    //20% for Synchrolife pool for rewards
    uint256 public constant rewardPoolPercentage = 2000;
    //9.5% for Synchrolife business + 5% for early investors
    uint256 public constant businessPercentage = 1450;
    //9.5% for Synchrolife team, advisors and partners
    uint256 public constant vaultPercentage = 950;
    //1% for Bounty
    uint256 public constant bountyPercentage = 100;
    
    //Denominator for percentage calculation.
    uint256 public constant hundredPercent = 10000; 
    
    //First Presale: 268000000000000000000
    //Second Presale: 70000000000000000000 
    //Crowdsale:     417427897026000000400
    uint256 public constant totalFundedEther = 755427897026000000400;
    
    //First Presale: 375200000000000000000
    //Second Presale: 91000000000000000000
    //Crowdsale:     438371225465900000400
    uint256 public constant totalConsideredFundedEther = 904571225465900000400;
    
    SYNVault public vault;
    address public businessAddress;
    address public rewardPoolAddress;
    
    uint256 public crowdSaleTokens;
    uint256 public bountyTokens;
    uint256 public rewardPoolTokens;

    function SynchroCoin(address _businessAddress, address _rewardPoolAddress) public {
        totalSupply = initialSupply;
        businessAddress = _businessAddress;
        rewardPoolAddress = _rewardPoolAddress;
        
        vault = new SYNVault(businessAddress);
        require(vault.isSYNVault());
        
        uint256 remainingSupply = initialSupply;
        
        // 55% of total to be distributed to presale and crowdsale participents
        crowdSaleTokens = SafeMath.div(SafeMath.mul(totalSupply, crowdSalePercentage), hundredPercent);
        remainingSupply = SafeMath.sub(remainingSupply, crowdSaleTokens);
        
        // 20% of total to be allocated for rewards
        rewardPoolTokens = SafeMath.div(SafeMath.mul(totalSupply, rewardPoolPercentage), hundredPercent);
        balances[rewardPoolAddress] = SafeMath.add(balances[rewardPoolAddress], rewardPoolTokens);
        Transfer(0, rewardPoolAddress, rewardPoolTokens);
        remainingSupply = SafeMath.sub(remainingSupply, rewardPoolTokens);
        
        // 9.5% of total goes to vault, timelocked for 1 year
        uint256 vaultTokens = SafeMath.div(SafeMath.mul(totalSupply, vaultPercentage), hundredPercent);
        balances[vault] = SafeMath.add(balances[vault], vaultTokens);
        Transfer(0, vault, vaultTokens);
        remainingSupply = SafeMath.sub(remainingSupply, vaultTokens);
        
        // 1% of total used for bounty. Remainder will be used for business.
        bountyTokens = SafeMath.div(SafeMath.mul(totalSupply, bountyPercentage), hundredPercent);
        remainingSupply = SafeMath.sub(remainingSupply, bountyTokens);
        
        balances[businessAddress] = SafeMath.add(balances[businessAddress], remainingSupply);
        Transfer(0, businessAddress, remainingSupply);
    }

    /* Send coins */
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        return super.transfer(_to, _amount);
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        return super.transferFrom(_from, _to, _amount);
    }
    
    function getBonusMultiplierAt(uint256 _timestamp) public constant returns (uint256) {
        if (_timestamp >= firstPresaleStart && _timestamp < firstPresaleEnd) {
            return 140;
        }
        else if (_timestamp >= secondPresaleStart && _timestamp < secondPresaleEnd) {
            return 130;
        }
        else if (_timestamp < (startDate + 1 days)) {
            return 120;
        }
        else if (_timestamp < (startDate + 7 days)) {
            return 115;
        }
        else if (_timestamp < (startDate + 14 days)) {
            return 110;
        }
        else if (_timestamp < (startDate + 21 days)) {
            return 105;
        }
        else if (_timestamp <= endDate) {
            return 100;
        }
        else {
            return 0;
        }
    }

    function distributeCrowdsaleTokens(address _to, uint256 _ether, uint256 _timestamp) public onlyOwner returns (uint256) {
        require(_to != 0x0);
        require(_ether >= 100 finney);
        require(_timestamp >= firstPresaleStart);
        require(_timestamp <= endDate);
        
        //Calculate participant's bonus
        uint256 consideredFundedEther = SafeMath.div(SafeMath.mul(_ether, getBonusMultiplierAt(_timestamp)), 100);
        //Calculate participant's token share
        uint256 share = SafeMath.div(SafeMath.mul(consideredFundedEther, crowdSaleTokens), totalConsideredFundedEther);
        balances[_to] = SafeMath.add(balances[_to], share);
        Transfer(0, _to, share);
        return share;
    }
    
    function distributeBountyTokens(address[] _to, uint256[] _values) public onlyOwner {
        require(_to.length == _values.length);
        
        uint256 i = 0;
        while (i < _to.length) {
            bountyTokens = SafeMath.sub(bountyTokens, _values[i]);
            balances[_to[i]] = SafeMath.add(balances[_to[i]], _values[i]);
            Transfer(0, _to[i], _values[i]);
            i += 1;
        }
    }
    
    function completeBountyDistribution() public onlyOwner {
        //After distribution of bounty tokens, transfer remaining tokens to Synchrolife business address
        balances[businessAddress] = SafeMath.add(balances[businessAddress], bountyTokens);
        Transfer(0, businessAddress, bountyTokens);
        bountyTokens = 0;
    }
}
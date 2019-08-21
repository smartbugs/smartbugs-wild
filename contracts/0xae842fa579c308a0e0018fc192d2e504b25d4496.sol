pragma solidity ^0.4.18 ;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract ContractiumInterface {
    function balanceOf(address who) public view returns (uint256);
    function contractSpend(address _from, uint256 _value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);

    function owner() public view returns (address);

    function bonusRateOneEth() public view returns (uint256);
    function currentTotalTokenOffering() public view returns (uint256);
    function currentTokenOfferingRaised() public view returns (uint256);

    function isOfferingStarted() public view returns (bool);
    function offeringEnabled() public view returns (bool);
    function startTime() public view returns (uint256);
    function endTime() public view returns (uint256);
}


contract ContractiumSalePackage is Ownable {

    using SafeMath for uint256;

    ContractiumInterface ctuContract;
    address public constant CONTRACTIUM = 0x943aca8ed65fbf188a7d369cfc2bee0ae435ee1b;
    address public ownerCtuContract;
    address public owner;

    uint8 public constant decimals = 18;
    uint256 public unitsOneEthCanBuy = 15000;
    
    // Current token offering raised in CTUSalePackages
    uint256 public currentTokenOfferingRaised;
    
    // Sale packages and intervals
    uint256[] public intervals;
    uint256[] public packages;
    
    constructor() public {
        ctuContract = ContractiumInterface(CONTRACTIUM);
        ownerCtuContract = ctuContract.owner();
        owner = msg.sender;
        
        intervals = [
            0,
            10000000000000000,      // 0.01 Ether
            100000000000000000,     // 0.1 ether
            1000000000000000000,    // 01 Ether
            3000000000000000000,    // 03 Ether
            5000000000000000000,    // 05 Ether
            10000000000000000000    // 10 Ether
        ];
        
        packages = [
            0,
            750,   // 5% 
            1500,  // 10% 
            3000,  // 20%
            4500,  // 30%
            6000,  // 40%
            7500   // 50%
        ];
    }

    function() public payable {

        require(msg.sender != owner);

        // Number of tokens to sale in wei
        uint256 amount = msg.value.mul(unitsOneEthCanBuy);
        
        // Bonus rate
        uint256 bonusRate = getNearestPackage(msg.value);
        
        // Amount of bonus tokens
        uint256 amountBonus = msg.value.mul(bonusRate);
        
        // Amount with bonus value
        amount = amount.add(amountBonus);

        // Offering validation
        uint256 remain = ctuContract.balanceOf(ownerCtuContract);
        require(remain >= amount);
        preValidatePurchase(amount);

        address _from = ownerCtuContract;
        address _to = msg.sender;
        require(ctuContract.transferFrom(_from, _to, amount));
        ownerCtuContract.transfer(msg.value);  

        currentTokenOfferingRaised = currentTokenOfferingRaised.add(amount);  
    }
    
    /**
    * @dev Get package bonus.
    */
    function getNearestPackage(uint256 _amount) view internal returns (uint256) {
        require(_amount > 0);
        uint indexPackage = 0;
        for (uint i = intervals.length - 1; i >= 0 ; i--){
            if (intervals[i] <= _amount) {
                indexPackage = i;
                break;
            }
        }
        return packages[indexPackage];
    }
    
    /**
    * @dev Validate before purchasing.
    */
    function preValidatePurchase(uint256 _amount) view internal {
        require(_amount > 0);
        require(ctuContract.isOfferingStarted());
        require(ctuContract.offeringEnabled());
        require(currentTokenOfferingRaised.add(ctuContract.currentTokenOfferingRaised().add(_amount)) <= ctuContract.currentTotalTokenOffering());
        require(block.timestamp >= ctuContract.startTime() && block.timestamp <= ctuContract.endTime());
    }
    
    /**
    * @dev Set Contractium address and related parameter from Contractium Smartcontract.
    */
    function setCtuContract(address _ctuAddress) public onlyOwner {
        require(_ctuAddress != address(0x0));
        ctuContract = ContractiumInterface(_ctuAddress);
        ownerCtuContract = ctuContract.owner();
    }

    /**
    * @dev Reset current token offering raised for new Sale.
    */
    function resetCurrentTokenOfferingRaised() public onlyOwner {
        currentTokenOfferingRaised = 0;
    }
    
    /**
    * @dev Clear package bonus.
    */
    function clearPackages() public onlyOwner returns (bool) {
        intervals = [0];
        packages = [0];
        return true;
    }
    
    /**
    * @dev Set package bonus.
    */
    function setPackages(uint256[] _interval, uint256[] _packages) public checkPackages(_interval, _packages) returns (bool) {
        intervals = _interval;
        packages = _packages;
        return true;
    }
    
    /**
    *  Check packages and intervals is valid or not
    */
    modifier checkPackages(uint256[] _interval, uint256[] _packages) {
        require(_interval.length == _packages.length);
        bool validIntervalArr = true;
        for (uint i = 0; i < intervals.length - 1 ; i++){
            if (intervals[i] >= intervals[i + 1]) {
                validIntervalArr = false;
                break;
            }
        }
        require(validIntervalArr);
        _;
    }
}
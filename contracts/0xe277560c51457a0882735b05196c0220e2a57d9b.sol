pragma solidity ^0.4.15;

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
 * @title NonZero
 */
contract NonZero {

// Functions with this modifier fail if he 
    modifier nonZeroAddress(address _to) {
        require(_to != 0x0);
        _;
    }

    modifier nonZeroAmount(uint _amount) {
        require(_amount > 0);
        _;
    }

    modifier nonZeroValue() {
        require(msg.value > 0);
        _;
    }

}


contract TripCoin is ERC20, Ownable, NonZero {

    using SafeMath for uint;

/////////////////////// TOKEN INFORMATION ///////////////////////
    string public constant name = "TripCoin";
    string public constant symbol = "TRIP";

    uint8 public decimals = 3;
    
    // Mapping to keep user's balances
    mapping (address => uint256) balances;
    // Mapping to keep user's allowances
    mapping (address => mapping (address => uint256)) allowed;

/////////////////////// VARIABLE INITIALIZATION ///////////////////////
    
    // Allocation for the TripCoin Team
    uint256 public TripCoinTeamSupply;
    // Reserve supply
    uint256 public ReserveSupply;
    // Amount of TripCoin for the presale
    uint256 public presaleSupply;

    uint256 public icoSupply;
    // Community incentivisation supply
    uint256 public incentivisingEffortsSupply;
    // Crowdsale End Timestamp
    uint256 public presaleStartsAt;
    uint256 public presaleEndsAt;
    uint256 public icoStartsAt;
    uint256 public icoEndsAt;
   
    // TripCoin team address
    address public TripCoinTeamAddress;
    // Reserve address
    address public ReserveAddress;
    // Community incentivisation address
    address public incentivisingEffortsAddress;

    // Flag keeping track of presale status. Ensures functions can only be called once
    bool public presaleFinalized = false;
    // Flag keeping track of crowdsale status. Ensures functions can only be called once
    bool public icoFinalized = false;
    // Amount of wei currently raised
    uint256 public weiRaised = 0;

/////////////////////// EVENTS ///////////////////////

    // Event called when crowdfund is done
    event icoFinalized(uint tokensRemaining);
    // Event called when presale is done
    event PresaleFinalized(uint tokensRemaining);
    // Emitted upon crowdfund being finalized
    event AmountRaised(address beneficiary, uint amountRaised);
    // Emmitted upon purchasing tokens
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

/////////////////////// MODIFIERS ///////////////////////

 

    // Ensure only crowdfund can call the function
    modifier onlypresale() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyico() {
        require(msg.sender == owner);
        _;
    }

/////////////////////// ERC20 FUNCTIONS ///////////////////////

    // Transfer
    function transfer(address _to, uint256 _amount) returns (bool success) {
        require(balanceOf(msg.sender) >= _amount);
        addToBalance(_to, _amount);
        decrementBalance(msg.sender, _amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    // Transfer from one address to another (need allowance to be called first)
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
        require(allowance(_from, msg.sender) >= _amount);
        decrementBalance(_from, _amount);
        addToBalance(_to, _amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    // Approve another address a certain amount of TripCoin
    function approve(address _spender, uint256 _value) returns (bool success) {
        require((_value == 0) || (allowance(msg.sender, _spender) == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // Get an address's TripCoin allowance
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Get the TripCoin balance of any address
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

/////////////////////// TOKEN FUNCTIONS ///////////////////////

    // Constructor
    function TripCoin() {
        presaleStartsAt = 1509271200;                                          //Oct 29 2017,10 AM GMT
        presaleEndsAt = 1509875999;                                          //Nov 05 2017,9:59:59 AM GMT
        icoStartsAt = 1509876000;                                             //Nov 05 2017,10 AM GMT
        icoEndsAt = 1511863200;                                               //Nov 28 2017,10 AM GMT
           

        totalSupply = 200000000000;                                                   // 100% - 200m
        TripCoinTeamSupply = 20000000000;                                              // 10%
        ReserveSupply = 60000000000;                                                // 30% 
        incentivisingEffortsSupply = 20000000000;                                    // 10% 
        presaleSupply = 60000000000;                                                // 30%
        icoSupply = 40000000000;                                                    // 20%
       
       
        TripCoinTeamAddress = 0xD7741E3819434a91F25b8C8e30Ba124D1EDe6B03;             // TripCoin Team Address
        ReserveAddress = 0x51Ff33A5C5350E62F9a974108e4B93EDC5C26359;               // Reserve Address
        incentivisingEffortsAddress = 0x4B8849c93b90Fe2446D8fc27FEc25Dc3386b1e75;   // Community incentivisation address

        addToBalance(incentivisingEffortsAddress, incentivisingEffortsSupply);     
        addToBalance(ReserveAddress, ReserveSupply); 
        addToBalance(owner, presaleSupply.add(icoSupply)); 
        
        addToBalance(TripCoinTeamAddress, TripCoinTeamSupply); 
    }

  

    // Function for the presale to transfer tokens
    function transferFromPresale(address _to, uint256 _amount) onlyOwner nonZeroAmount(_amount) nonZeroAddress(_to) returns (bool success) {
        require(balanceOf(owner) >= _amount);
        decrementBalance(owner, _amount);
        addToBalance(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }
      // Function for the ico to transfer tokens
    function transferFromIco(address _to, uint256 _amount) onlyOwner nonZeroAmount(_amount) nonZeroAddress(_to) returns (bool success) {
        require(balanceOf(owner) >= _amount);
        decrementBalance(owner, _amount);
        addToBalance(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }
    function getRate() public constant returns (uint price) {
        if (now > presaleStartsAt && now < presaleEndsAt ) {
           return 1500; 
        } else if (now > icoStartsAt && now < icoEndsAt) {
           return 1000; 
        } 
    }       
    
     function buyTokens(address _to) nonZeroAddress(_to) nonZeroValue payable {
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount * getRate();
        weiRaised = weiRaised.add(weiAmount);
        
        owner.transfer(msg.value);
        TokenPurchase(_to, weiAmount, tokens);
    }
    
     function () payable {
        buyTokens(msg.sender);
    }
   

    

    // Add to balance
    function addToBalance(address _address, uint _amount) internal {
    	balances[_address] = balances[_address].add(_amount);
    }

    // Remove from balance
    function decrementBalance(address _address, uint _amount) internal {
    	balances[_address] = balances[_address].sub(_amount);
    }
}
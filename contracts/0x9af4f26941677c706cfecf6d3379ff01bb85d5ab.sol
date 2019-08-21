pragma solidity ^0.4.15;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

library SafeMath {
  function mul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function minimum( uint a, uint b) internal returns ( uint result) {
    if ( a <= b ) {
      result = a;
    }
    else {
      result = b;
    }
  }

}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

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
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract DRTCoin is StandardToken, Ownable {
    /* Overriding some ERC20 variables */
    string public constant name = "DomRaiderToken";
    string public constant symbol = "DRT";
    uint256 public constant decimals = 8;

    /* DRT specific variables */
    // Max amount of tokens minted - Exact value input with stretch goals and before deploying contract
    uint256 public constant MAX_SUPPLY_OF_TOKEN = 1300000000 * 10 ** decimals;

    // Freeze duration for advisors accounts
    uint public constant START_ICO_TIMESTAMP = 1507622400;
    uint public constant DEFROST_PERIOD = 43200; // month in minutes  (1 month = 43200 min)
    uint public constant DEFROST_MONTHLY_PERCENT_OWNER = 5; // 5% per month is automatically defrosted
    uint public constant DEFROST_INITIAL_PERCENT_OWNER = 10; // 90% locked
    uint public constant DEFROST_MONTHLY_PERCENT = 10; // 10% per month is automatically defrosted
    uint public constant DEFROST_INITIAL_PERCENT = 20; // 80% locked

    // Fields that can be changed by functions
    address[] icedBalances;
    mapping (address => uint256) icedBalances_frosted;
    mapping (address => uint256) icedBalances_defrosted;

    uint256 ownerFrosted;
    uint256 ownerDefrosted;

    // Variable useful for verifying that the assignedSupply matches that totalSupply
    uint256 public assignedSupply;
    //Boolean to allow or not the initial assignment of token (batch)
    bool public batchAssignStopped = false;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    function DRTCoin() {
        owner = msg.sender;
        uint256 amount = 545000000 * 10 ** decimals;
        uint256 amount2assign = amount * DEFROST_INITIAL_PERCENT_OWNER / 100;
        balances[owner] = amount2assign;
        ownerDefrosted = amount2assign;
        ownerFrosted = amount - amount2assign;
        totalSupply = MAX_SUPPLY_OF_TOKEN;
        assignedSupply = amount;
    }

    /**
     * @dev Transfer tokens in batches (of addresses)
     * @param _vaddr address The address which you want to send tokens from
     * @param _vamounts address The address which you want to transfer to
     */
    function batchAssignTokens(address[] _vaddr, uint[] _vamounts, bool[] _vIcedBalance) onlyOwner {
        require(batchAssignStopped == false);
        require(_vaddr.length == _vamounts.length);
        //Looping into input arrays to assign target amount to each given address
        for (uint index = 0; index < _vaddr.length; index++) {
            address toAddress = _vaddr[index];
            uint amount = _vamounts[index] * 10 ** decimals;
            bool isIced = _vIcedBalance[index];
            if (balances[toAddress] == 0) {
                // In case it's filled two times, it only increments once
                // Assigns the balance
                assignedSupply += amount;
                if (isIced == false) {
                    // Normal account
                    balances[toAddress] = amount;
                }
                else {
                    // Iced account. The balance is not affected here
                    icedBalances.push(toAddress);
                    uint256 amount2assign = amount * DEFROST_INITIAL_PERCENT / 100;
                    balances[toAddress] = amount2assign;
                    icedBalances_defrosted[toAddress] = amount2assign;
                    icedBalances_frosted[toAddress] = amount - amount2assign;
                }
            }
        }
    }

    function canDefrost() onlyOwner constant returns (bool bCanDefrost){
        bCanDefrost = now > START_ICO_TIMESTAMP;
    }

    function getBlockTimestamp() constant returns (uint256){
        return now;
    }


    /**
     * @dev Defrost token (for advisors)
     * Method called by the owner once per defrost period (1 month)
     */
    function defrostToken() onlyOwner {
        require(now > START_ICO_TIMESTAMP);
        // Looping into the iced accounts
        for (uint index = 0; index < icedBalances.length; index++) {
            address currentAddress = icedBalances[index];
            uint256 amountTotal = icedBalances_frosted[currentAddress] + icedBalances_defrosted[currentAddress];
            uint256 targetDeFrosted = (SafeMath.minimum(100, DEFROST_INITIAL_PERCENT + elapsedMonthsFromICOStart() * DEFROST_MONTHLY_PERCENT)) * amountTotal / 100;
            uint256 amountToRelease = targetDeFrosted - icedBalances_defrosted[currentAddress];
            if (amountToRelease > 0) {
                icedBalances_frosted[currentAddress] = icedBalances_frosted[currentAddress] - amountToRelease;
                icedBalances_defrosted[currentAddress] = icedBalances_defrosted[currentAddress] + amountToRelease;
                balances[currentAddress] = balances[currentAddress] + amountToRelease;
            }
        }

    }
    /**
     * Defrost for the owner of the contract
     */
    function defrostOwner() onlyOwner {
        if (now < START_ICO_TIMESTAMP) {
            return;
        }
        uint256 amountTotal = ownerFrosted + ownerDefrosted;
        uint256 targetDeFrosted = (SafeMath.minimum(100, DEFROST_INITIAL_PERCENT_OWNER + elapsedMonthsFromICOStart() * DEFROST_MONTHLY_PERCENT_OWNER)) * amountTotal / 100;
        uint256 amountToRelease = targetDeFrosted - ownerDefrosted;
        if (amountToRelease > 0) {
            ownerFrosted = ownerFrosted - amountToRelease;
            ownerDefrosted = ownerDefrosted + amountToRelease;
            balances[owner] = balances[owner] + amountToRelease;
        }
    }

    function elapsedMonthsFromICOStart() constant returns (uint elapsed) {
        elapsed = ((now - START_ICO_TIMESTAMP) / 60) / DEFROST_PERIOD;
    }

    function stopBatchAssign() onlyOwner {
        require(batchAssignStopped == false);
        batchAssignStopped = true;
    }

    function getAddressBalance(address addr) constant returns (uint256 balance)  {
        balance = balances[addr];
    }

    function getAddressAndBalance(address addr) constant returns (address _address, uint256 _amount)  {
        _address = addr;
        _amount = balances[addr];
    }

    function getIcedAddresses() constant returns (address[] vaddr)  {
        vaddr = icedBalances;
    }

    function getIcedInfos(address addr) constant returns (address icedaddr, uint256 balance, uint256 frosted, uint256 defrosted)  {
        icedaddr = addr;
        balance = balances[addr];
        frosted = icedBalances_frosted[addr];
        defrosted = icedBalances_defrosted[addr];
    }

    function getOwnerInfos() constant returns (address owneraddr, uint256 balance, uint256 frosted, uint256 defrosted)  {
        owneraddr = owner;
        balance = balances[owneraddr];
        frosted = ownerFrosted;
        defrosted = ownerDefrosted;
    }

}
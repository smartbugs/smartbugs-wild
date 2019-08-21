pragma solidity ^0.4.23;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 *      See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}

contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

  /**
   * @dev reverts if addr does not have role
   * @param addr address
   * @param roleName the name of the role
   * // reverts
   */
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

  /**
   * @dev determine if addr has role
   * @param addr address
   * @param roleName the name of the role
   * @return bool
   */
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    emit RoleAdded(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    emit RoleRemoved(addr, roleName);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param roleName the name of the role
   * // reverts
   */
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param roleNames the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] roleNames) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < roleNames.length; i++) {
  //         if (hasRole(msg.sender, roleNames[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}


/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable, RBAC {
  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  string public constant ROLE_WHITELISTED = "whitelist";

  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
  modifier onlyWhitelisted() {
    checkRole(msg.sender, ROLE_WHITELISTED);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address addr)
    onlyOwner
    public
  {
    addRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressAdded(addr);
  }

  /**
   * @dev getter to determine if address is in whitelist
   */
  function whitelist(address addr)
    public
    view
    returns (bool)
  {
    return hasRole(addr, ROLE_WHITELISTED);
  }

  /**
   * @dev add addresses to the whitelist
   * @param addrs addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      addAddressToWhitelist(addrs[i]);
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param addr address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address addr)
    onlyOwner
    public
  {
    removeRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressRemoved(addr);
  }

  /**
   * @dev remove addresses from the whitelist
   * @param addrs addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      removeAddressFromWhitelist(addrs[i]);
    }
  }

}



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract PreSaleI is Whitelist {
    using SafeMath for uint256;
    // rate is the amount of token to the ether. Bonus rate is included in exchange rate.
    uint256 public exchangeRate;
    
    // in ETH(wei), not token
    uint256 public minValue;
    uint256 public maxTotal;
    uint256 public maxPerAddress;

    uint256 public startTimestamp;
    uint256 public endTimestamp;
    bool public enabled;

    address public wallet;
    ERC20 public token;
    
    // in ETH(wei), not token
    uint256 public accumulatedAmount = 0;
    uint256 public accumulatedAmountExternal = 0;
    mapping (address => uint256) public buyAmounts;

    address[] public addresses;

    constructor(ERC20 _token, address _wallet, uint256 _exchangeRate, uint256 _minValue, uint256 _maxTotal, uint256 _maxPerAddress, uint256 _startTimestamp, uint256 _endTimestamp) public {
        require(_token != address(0));
        require(_wallet != address(0));
        token = _token;
        wallet = _wallet;
        exchangeRate = _exchangeRate;
        minValue = _minValue;
        maxTotal = _maxTotal;
        maxPerAddress = _maxPerAddress;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
        enabled = false;
    }

    function toggleEnabled() public onlyOwner {
        enabled = !enabled;
        emit ToggleEnabled(enabled);
    }
    event ToggleEnabled(bool _enabled);

    function updateExternalAmount(uint256 _amount) public onlyOwner {
        accumulatedAmountExternal = _amount;
        emit UpdateTotalAmount(accumulatedAmount.add(accumulatedAmountExternal));
    }
    event UpdateTotalAmount(uint256 _totalAmount);

    function () external payable {
        if (msg.sender != wallet) {
            buyTokens();
        }
    }

    function buyTokens() public payable onlyWhitelisted {
        //require(msg.sender != address(0));
        require(enabled);
        require(block.timestamp >= startTimestamp && block.timestamp <= endTimestamp);
        require(msg.value >= minValue);
        require(buyAmounts[msg.sender] < maxPerAddress);
        require(accumulatedAmount.add(accumulatedAmountExternal) < maxTotal);

        uint256 buyAmount;
        uint256 refundAmount;
        (buyAmount, refundAmount) = _calculateAmounts(msg.sender, msg.value);

        if (buyAmounts[msg.sender] == 0) {
            addresses.push(msg.sender);
        }

        accumulatedAmount = accumulatedAmount.add(buyAmount);
        buyAmounts[msg.sender] = buyAmounts[msg.sender].add(buyAmount);
        msg.sender.transfer(refundAmount);
        emit BuyTokens(msg.sender, buyAmount, refundAmount, buyAmount.mul(exchangeRate));
    }
    event BuyTokens(address indexed _addr, uint256 _buyAmount, uint256 _refundAmount, uint256 _tokenAmount);

    function deliver(address _addr) public onlyOwner {
        require(_isEndCollect());
        uint256 amount = buyAmounts[_addr];
        require(amount > 0);
        uint256 tokenAmount = amount.mul(exchangeRate);
        buyAmounts[_addr] = 0;
        token.transfer(_addr, tokenAmount);
        emit Deliver(_addr, tokenAmount);
    }
    event Deliver(address indexed _addr, uint256 _tokenAmount);

    function refund(address _addr) public onlyOwner {
        require(_isEndCollect());
        uint256 amount = buyAmounts[_addr];
        require(amount > 0);
        buyAmounts[_addr] = 0;
        _addr.transfer(amount);
        accumulatedAmount = accumulatedAmount.sub(amount);
        emit Refund(_addr, amount);
    }
    event Refund(address indexed _addr, uint256 _buyAmount);

    function withdrawEth() public onlyOwner {
        wallet.transfer(address(this).balance);
        emit WithdrawEth(wallet, address(this).balance);
    }
    event WithdrawEth(address indexed _addr, uint256 _etherAmount);

    function terminate() public onlyOwner {
        require(getNotDelivered() == address(0));
        token.transfer(wallet, token.balanceOf(address(this)));
        wallet.transfer(address(this).balance);
        emit Terminate(wallet, token.balanceOf(address(this)), address(this).balance);
    }
    event Terminate(address indexed _addr, uint256 _tokenAmount, uint256 _etherAmount);

    function getNotDelivered() public view returns (address) {
        for(uint256 i = 0; i < addresses.length; i++) {
            if (buyAmounts[addresses[i]] != 0) {
                return addresses[i];
            }
        }
        return address(0);
    }

    function _calculateAmounts(address _buyAddress, uint256 _buyAmount) private view returns (uint256, uint256) {
        uint256 buyLimit1 = maxTotal.sub(accumulatedAmount.add(accumulatedAmountExternal));
        uint256 buyLimit2 = maxPerAddress.sub(buyAmounts[_buyAddress]);
        uint256 buyLimit = buyLimit1 > buyLimit2 ? buyLimit2 : buyLimit1;
        uint256 buyAmount = _buyAmount > buyLimit ? buyLimit : _buyAmount;
        uint256 refundAmount = _buyAmount.sub(buyAmount);
        return (buyAmount, refundAmount);
    }

    function _isEndCollect() private view returns (bool) {
        return !enabled && block.timestamp> endTimestamp;
    }
}
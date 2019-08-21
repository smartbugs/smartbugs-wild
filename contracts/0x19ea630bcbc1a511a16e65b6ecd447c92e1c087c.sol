pragma solidity ^0.4.21;

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




contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}






contract AccessControl {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}








contract AccessControlManager is AccessControl {

    string public constant SUPER_ADMIN = "superAdmin";
    string public constant LIMITED_ADMIN = "limitedAdmin";

    /**
     * @dev modifier to scope access to admins
     * // reverts
     */
    modifier onlyAdmin()
    {
        checkRole(msg.sender, SUPER_ADMIN);
        _;
    }

    /**
     * @dev modifier to check adding/removing roles
     *
     */
    modifier canUpdateRole(string role){
        if ((keccak256(abi.encodePacked(role)) != keccak256(abi.encodePacked(SUPER_ADMIN)) && (hasRole(msg.sender, SUPER_ADMIN) || hasRole(msg.sender, LIMITED_ADMIN))))
        _;
    }

    /**
     * @dev constructor. Sets msg.sender as admin by default
     */
    constructor()
    public
    {
        addRole(msg.sender, SUPER_ADMIN);
    }

    /**
     * @dev add admin role to an address
     * @param addr address
     */
    function addAdmin(address addr)
    onlyAdmin
    public
    {
        addRole(addr, SUPER_ADMIN);
    }

    /**
     * @dev remove a role from an address
     * @param addr address
     */
    function removeAdmin(address addr)
    onlyAdmin
    public
    {
        require(msg.sender != addr);
        removeRole(addr, SUPER_ADMIN);
    }

    /**
     * @dev add a role to an address
     * @param addr address
     * @param roleName the name of the role
     */
    function adminAddRole(address addr, string roleName)
    canUpdateRole(roleName)
    public
    {
        addRole(addr, roleName);
    }


    /**
     * @dev remove a role from an address
     * @param addr address
     * @param roleName the name of the role
     */
    function adminRemoveRole(address addr, string roleName)
    canUpdateRole(roleName)
    public
    {
        removeRole(addr, roleName);
    }


    /**
     * @dev add a role to an addresses array
     * solidity dosen't supports dynamic arrays as arguments so only one role at time.
     * @param addrs addresses
     * @param roleName the name of the role
     */
    function adminAddRoles(address[] addrs, string roleName)
    public
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            adminAddRole(addrs[i],roleName);
        }
    }


    /**
     * @dev remove a specific role from an addresses array
     * solidity dosen't supports dynamic arrays as arguments so only one role at time.
     * @param addrs addresses
     * @param roleName the name of the role
     */
    function adminRemoveRoles(address[] addrs, string roleName)
    public
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            adminRemoveRole(addrs[i],roleName);
        }
    }


}



contract AccessControlClient {


    AccessControlManager public acm;


    constructor(AccessControlManager addr) public {
        acm = AccessControlManager(addr);
    }

    /**
    * @dev add a role to an address
    * ONLY WITH RELEVANT ROLES!!
    * @param addr address
    * @param roleName the name of the role
    */
    function addRole(address addr, string roleName)
    public
    {
        acm.adminAddRole(addr,roleName);
    }


    /**
     * @dev remove a role from an address
     * ONLY WITH RELEVANT ROLES!!
     * @param addr address
     * @param roleName the name of the role
     */
    function removeRole(address addr, string roleName)
    public
    {
        acm.adminRemoveRole(addr,roleName);
    }

    /**
     * @dev add a role to an addresses array
     * ONLY WITH RELEVANT ROLES!!
     * solidity dosen't supports dynamic arrays as arguments so only one role at time.
     * @param addrs addresses
     * @param roleName the name of the role
     */
    function addRoles(address[] addrs, string roleName)
    public
    {
        acm.adminAddRoles(addrs,roleName);

    }


    /**
     * @dev remove a specific role from an addresses array
     * ONLY WITH RELEVANT ROLES!!
     * solidity dosen't supports dynamic arrays as arguments so only one role at time.
     * @param addrs addresses
     * @param roleName the name of the role
     */
    function removeRoles(address[] addrs, string roleName)
    public
    {
        acm.adminRemoveRoles(addrs,roleName);
    }

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
        acm.checkRole(addr, roleName);
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
        return acm.hasRole(addr, roleName);
    }


}












contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract DetailedERC20 is ERC20 {
    string public name;

    string public symbol;

    uint8 public decimals;

constructor (string _name, string _symbol, uint8 _decimals) public {
name = _name;
symbol = _symbol;
decimals = _decimals;
}
}










/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}



contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}









contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}




contract MintableToken is StandardToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();


  modifier canMint() {
    _;
  }

  modifier canReceive(address addr) {
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) canMint canReceive(_to) public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }


}




contract CaratToken is MintableToken, BurnableToken, DetailedERC20, AccessControlClient {


    string public constant SUPER_ADMIN = "superAdmin";

    string public constant LIMITED_ADMIN = "limitedAdmin";

    string public constant KYC_ROLE = "KycEnabled";


    //Token Spec
    string public constant NAME = "Carats Token";

    string public constant SYMBOL = "CARAT";

    uint8 public constant DECIMALS = 18;



    /**
      * @dev Throws if called by any account other than the minters(ACM) or if the minting period finished.
      */
    modifier canMint() {
        require(_isMinter(msg.sender));
        _;
    }


    /**
      * @dev Throws if minted to any account other than the KYC
      */
    modifier canReceive(address addr) {
        if(hasRole(addr, KYC_ROLE) || hasRole(addr, LIMITED_ADMIN) || hasRole(addr, SUPER_ADMIN)){
            _;
        }
    }


    constructor (AccessControlManager acm)
                 AccessControlClient(acm)
                 DetailedERC20(NAME, SYMBOL,DECIMALS) public
                 {}



    function _isMinter(address addr) internal view returns (bool) {
    return hasRole(addr, SUPER_ADMIN) || hasRole(addr, LIMITED_ADMIN);
    }
}
pragma solidity ^0.4.24;


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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}






/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}



/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
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



contract Time {
    /**
    * @dev Current time getter
    * @return Current time in seconds
    */
    function _currentTime() internal view returns (uint256) {
        return block.timestamp;
    }
}




/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 * to avoid typos.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  /**
   * @dev reverts if addr does not have role
   * @param _operator address
   * @param _role the name of the role
   * // reverts
   */
  function checkRole(address _operator, string _role)
    view
    public
  {
    roles[_role].check(_operator);
  }

  /**
   * @dev determine if addr has role
   * @param _operator address
   * @param _role the name of the role
   * @return bool
   */
  function hasRole(address _operator, string _role)
    view
    public
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

  /**
   * @dev add a role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  /**
   * @dev remove a role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param _role the name of the role
   * // reverts
   */
  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param _roles the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] _roles) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < _roles.length; i++) {
  //         if (hasRole(msg.sender, _roles[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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



contract Lockable {
    // locked values specified by address
    mapping(address => uint256) public lockedValues;

    /**
    * @dev Method to lock specified value by specified address
    * @param _for Address for which the value will be locked
    * @param _value Value that be locked
    */
    function _lock(address _for, uint256 _value) internal {
        require(_for != address(0) && _value > 0, "Invalid lock operation configuration.");

        if (_value != lockedValues[_for]) {
            lockedValues[_for] = _value;
        }
    }

    /**
    * @dev Method to unlock (reset) locked value
    * @param _for Address for which the value will be unlocked
    */
    function _unlock(address _for) internal {
        require(_for != address(0), "Invalid unlock operation configuration.");
        
        if (lockedValues[_for] != 0) {
            lockedValues[_for] = 0;
        }
    }
}











contract Operable is Ownable, RBAC {
    // role key
    string public constant ROLE_OPERATOR = "operator";

    /**
     * @dev Reverts in case account is not Owner or Operator role
     */
    modifier hasOwnerOrOperatePermission() {
        require(msg.sender == owner || hasRole(msg.sender, ROLE_OPERATOR), "Access denied.");
        _;
    }

    /**
     * @dev Getter to determine if address is in whitelist
     */
    function operator(address _operator) public view returns (bool) {
        return hasRole(_operator, ROLE_OPERATOR);
    }

    /**
     * @dev Method to add accounts with Operator role
     * @param _operator Address that will receive Operator role access
     */
    function addOperator(address _operator) public onlyOwner {
        addRole(_operator, ROLE_OPERATOR);
    }

    /**
     * @dev Method to remove accounts with Operator role
     * @param _operator Address that will loose Operator role access
     */
    function removeOperator(address _operator) public onlyOwner {
        removeRole(_operator, ROLE_OPERATOR);
    }
}






contract Withdrawal is Ownable {
    // Address to which funds will be withdrawn
    address public withdrawWallet;

    /**
    * Event for withdraw logging
    * @param value Value that was withdrawn
    */
    event WithdrawLog(uint256 value);

    /**
    * @param _withdrawWallet Address to which funds will be withdrawn
    */
    constructor(address _withdrawWallet) public {
        require(_withdrawWallet != address(0), "Invalid funds holder wallet.");

        withdrawWallet = _withdrawWallet;
    }

    /**
    * @dev Transfers funds from the contract to the specified withdraw wallet address
    */
    function withdrawAll() external onlyOwner {
        uint256 weiAmount = address(this).balance;
      
        withdrawWallet.transfer(weiAmount);
        emit WithdrawLog(weiAmount);
    }

    /**
    * @dev Transfers a part of the funds from the contract to the specified withdraw wallet address
    * @param _weiAmount Part of the funds to be withdrawn
    */
    function withdraw(uint256 _weiAmount) external onlyOwner {
        require(_weiAmount <= address(this).balance, "Not enough funds.");

        withdrawWallet.transfer(_weiAmount);
        emit WithdrawLog(_weiAmount);
    }
}








contract PriceStrategy is Time, Operable {
    using SafeMath for uint256;

    /**
    * Describes stage parameters
    * @param start Stage start date
    * @param end Stage end date
    * @param volume Number of tokens available for the stage
    * @param priceInCHF Token price in CHF for the stage
    * @param minBonusVolume The minimum number of tokens after which the bonus tokens is added
    * @param bonus Percentage of bonus tokens
    */
    struct Stage {
        uint256 start;
        uint256 end;
        uint256 volume;
        uint256 priceInCHF;
        uint256 minBonusVolume;
        uint256 bonus;
        bool lock;
    }

    /**
    * Describes lockup period parameters
    * @param periodInSec Lockup period in seconds
    * @param bonus Lockup bonus tokens percentage
    */
    struct LockupPeriod {
        uint256 expires;
        uint256 bonus;
    }

    // describes stages available for ICO lifetime
    Stage[] public stages;

    // lockup periods specified by the period in month
    mapping(uint256 => LockupPeriod) public lockupPeriods;

    // number of decimals supported by CHF rates
    uint256 public constant decimalsCHF = 18;

    // minimum allowed investment in CHF (decimals 1e+18)
    uint256 public minInvestmentInCHF;

    // ETH rate in CHF
    uint256 public rateETHtoCHF;

    /**
    * Event for ETH to CHF rate changes logging
    * @param newRate New rate value
    */
    event RateChangedLog(uint256 newRate);

    /**
    * @param _rateETHtoCHF Cost of ETH in CHF
    * @param _minInvestmentInCHF Minimal allowed investment in CHF
    */
    constructor(uint256 _rateETHtoCHF, uint256 _minInvestmentInCHF) public {
        require(_minInvestmentInCHF > 0, "Minimum investment can not be set to 0.");        
        minInvestmentInCHF = _minInvestmentInCHF;

        setETHtoCHFrate(_rateETHtoCHF);

        // PRE-ICO
        stages.push(Stage({
            start: 1536969600, // 15th Sep, 2018 00:00:00
            end: 1542239999, // 14th Nov, 2018 23:59:59
            volume: uint256(25000000000).mul(10 ** 18), // (twenty five billion)
            priceInCHF: uint256(2).mul(10 ** 14), // CHF 0.00020
            minBonusVolume: 0,
            bonus: 0,
            lock: false
        }));

        // ICO
        stages.push(Stage({
            start: 1542240000, // 15th Nov, 2018 00:00:00
            end: 1550188799, // 14th Feb, 2019 23:59:59
            volume: uint256(65000000000).mul(10 ** 18), // (forty billion)
            priceInCHF: uint256(4).mul(10 ** 14), // CHF 0.00040
            minBonusVolume: uint256(400000000).mul(10 ** 18), // (four hundred million)
            bonus: 2000, // 20% bonus tokens
            lock: true
        }));

        _setLockupPeriod(1550188799, 18, 3000); // 18 months after the end of the ICO / 30%
        _setLockupPeriod(1550188799, 12, 2000); // 12 months after the end of the ICO / 20%
        _setLockupPeriod(1550188799, 6, 1000); // 6 months after the end of the ICO / 10%
    }

    /**
    * @dev Updates ETH to CHF rate
    * @param _rateETHtoCHF Cost of ETH in CHF
    */
    function setETHtoCHFrate(uint256 _rateETHtoCHF) public hasOwnerOrOperatePermission {
        require(_rateETHtoCHF > 0, "Rate can not be set to 0.");        
        rateETHtoCHF = _rateETHtoCHF;
        emit RateChangedLog(rateETHtoCHF);
    }

    /**
    * @dev Tokens amount based on investment value in wei
    * @param _wei Investment value in wei
    * @param _lockup Lockup period in months
    * @param _sold Number of tokens sold by the moment
    * @return Amount of tokens and bonuses
    */
    function getTokensAmount(uint256 _wei, uint256 _lockup, uint256 _sold) public view returns (uint256 tokens, uint256 bonus) { 
        uint256 chfAmount = _wei.mul(rateETHtoCHF).div(10 ** decimalsCHF);
        require(chfAmount >= minInvestmentInCHF, "Investment value is below allowed minimum.");

        Stage memory currentStage = _getCurrentStage();
        require(currentStage.priceInCHF > 0, "Invalid price value.");        

        tokens = chfAmount.mul(10 ** decimalsCHF).div(currentStage.priceInCHF);

        uint256 bonusSize;
        if (tokens >= currentStage.minBonusVolume) {
            bonusSize = currentStage.bonus.add(lockupPeriods[_lockup].bonus);
        } else {
            bonusSize = lockupPeriods[_lockup].bonus;
        }

        bonus = tokens.mul(bonusSize).div(10 ** 4);

        uint256 total = tokens.add(bonus);
        require(currentStage.volume > _sold.add(total), "Not enough tokens available.");
    }    

    /**
    * @dev Finds current stage parameters according to the rules and current date and time
    * @return Current stage parameters (available volume of tokens and price in CHF)
    */
    function _getCurrentStage() internal view returns (Stage) {
        uint256 index = 0;
        uint256 time = _currentTime();

        Stage memory result;

        while (index < stages.length) {
            Stage memory stage = stages[index];

            if ((time >= stage.start && time <= stage.end)) {
                result = stage;
                break;
            }

            index++;
        }

        return result;
    } 

    /**
    * @dev Sets bonus for specified lockup period. Allowed only for contract owner
    * @param _startPoint Lock start point (is seconds)
    * @param _period Lockup period (in months)
    * @param _bonus Percentage of bonus tokens
    */
    function _setLockupPeriod(uint256 _startPoint, uint256 _period, uint256 _bonus) private {
        uint256 expires = _startPoint.add(_period.mul(2628000));
        lockupPeriods[_period] = LockupPeriod({
            expires: expires,
            bonus: _bonus
        });
    }
}















contract BaseCrowdsale {
    using SafeMath for uint256;
    using SafeERC20 for CosquareToken;

    // The token being sold
    CosquareToken public token;
    // Total amount of tokens sold
    uint256 public tokensSold;

    /**
    * @dev Event for tokens purchase logging
    * @param purchaseType Who paid for the tokens
    * @param beneficiary Who got the tokens
    * @param value Value paid for purchase
    * @param tokens Amount of tokens purchased
    * @param bonuses Amount of bonuses received
    */
    event TokensPurchaseLog(string purchaseType, address indexed beneficiary, uint256 value, uint256 tokens, uint256 bonuses);

    /**
    * @param _token Address of the token being sold
    */
    constructor(CosquareToken _token) public {
        require(_token != address(0), "Invalid token address.");
        token = _token;
    }

    /**
    * @dev fallback function ***DO NOT OVERRIDE***
    */
    function () external payable {
        require(msg.data.length == 0, "Should not accept data.");
        _buyTokens(msg.sender, msg.value, "ETH");
    }

    /**
    * @dev low level token purchase ***DO NOT OVERRIDE***
    * @param _beneficiary Address performing the token purchase
    */
    function buyTokens(address _beneficiary) external payable {
        _buyTokens(_beneficiary, msg.value, "ETH");
    }

    /**
    * @dev Tokens purchase for wei investments
    * @param _beneficiary Address performing the token purchase
    * @param _amount Amount of tokens purchased
    * @param _investmentType Investment channel string
    */
    function _buyTokens(address _beneficiary, uint256 _amount, string _investmentType) internal {
        _preValidatePurchase(_beneficiary, _amount);

        (uint256 tokensAmount, uint256 tokenBonus) = _getTokensAmount(_beneficiary, _amount);

        uint256 totalAmount = tokensAmount.add(tokenBonus);

        _processPurchase(_beneficiary, totalAmount);
        emit TokensPurchaseLog(_investmentType, _beneficiary, _amount, tokensAmount, tokenBonus);        
        
        _postPurchaseUpdate(_beneficiary, totalAmount);
    }  

    /**
    * @dev Validation of an executed purchase
    * @param _beneficiary Address performing the token purchase
    * @param _weiAmount Value in wei involved in the purchase
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(_beneficiary != address(0), "Invalid beneficiary address.");
        require(_weiAmount > 0, "Invalid investment value.");
    }

    /**
    * @dev Abstract function to count the number of tokens depending on the funds deposited
    * @param _beneficiary Address for which to get the tokens amount
    * @param _weiAmount Value in wei involved in the purchase
    * @return Number of tokens
    */
    function _getTokensAmount(address _beneficiary, uint256 _weiAmount) internal view returns (uint256 tokens, uint256 bonus);

    /**
    * @dev Executed when a purchase is ready to be executed
    * @param _beneficiary Address receiving the tokens
    * @param _tokensAmount Number of tokens to be purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokensAmount) internal {
        _deliverTokens(_beneficiary, _tokensAmount);
    }

    /**
    * @dev Deliver tokens to investor
    * @param _beneficiary Address receiving the tokens
    * @param _tokensAmount Number of tokens to be purchased
    */
    function _deliverTokens(address _beneficiary, uint256 _tokensAmount) internal {
        token.safeTransfer(_beneficiary, _tokensAmount);
    }

    /**
    * @dev Changes the contract state after purchase
    * @param _beneficiary Address received the tokens
    * @param _tokensAmount The number of tokens that were purchased
    */
    function _postPurchaseUpdate(address _beneficiary, uint256 _tokensAmount) internal {
        tokensSold = tokensSold.add(_tokensAmount);
    }
}



contract LockableCrowdsale is Time, Lockable, Operable, PriceStrategy, BaseCrowdsale {
    using SafeMath for uint256;

    /**
    * @dev Locks the next purchase for the provision of bonus tokens
    * @param _beneficiary Address for which the next purchase will be locked
    * @param _lockupPeriod The period to which tokens will be locked from the next purchase
    */
    function lockNextPurchase(address _beneficiary, uint256 _lockupPeriod) external hasOwnerOrOperatePermission {
        require(_lockupPeriod == 6 || _lockupPeriod == 12 || _lockupPeriod == 18, "Invalid lock interval");
        Stage memory currentStage = _getCurrentStage();
        require(currentStage.lock, "Lock operation is not allowed.");
        _lock(_beneficiary, _lockupPeriod);      
    }

    /**
    * @dev Executed when a purchase is ready to be executed
    * @param _beneficiary Address receiving the tokens
    * @param _tokensAmount Number of tokens to be purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokensAmount) internal {
        super._processPurchase(_beneficiary, _tokensAmount);
        uint256 lockedValue = lockedValues[_beneficiary];

        if (lockedValue > 0) {
            uint256 expires = lockupPeriods[lockedValue].expires;
            token.lock(_beneficiary, _tokensAmount, expires);
        }
    }

    /**
    * @dev Counts the number of tokens depending on the funds deposited
    * @param _beneficiary Address for which to get the tokens amount
    * @param _weiAmount Value in wei involved in the purchase
    * @return Number of tokens
    */
    function _getTokensAmount(address _beneficiary, uint256 _weiAmount) internal view returns (uint256 tokens, uint256 bonus) { 
        (tokens, bonus) = getTokensAmount(_weiAmount, lockedValues[_beneficiary], tokensSold);
    }

    /**
    * @dev Changes the contract state after purchase
    * @param _beneficiary Address received the tokens
    * @param _tokensAmount The number of tokens that were purchased
    */
    function _postPurchaseUpdate(address _beneficiary, uint256 _tokensAmount) internal {
        super._postPurchaseUpdate(_beneficiary, _tokensAmount);

        _unlock(_beneficiary);
    }
}










contract Whitelist is RBAC, Operable {
    // role key
    string public constant ROLE_WHITELISTED = "whitelist";

    /**
    * @dev Throws if operator is not whitelisted.
    * @param _operator Operator address
    */
    modifier onlyIfWhitelisted(address _operator) {
        checkRole(_operator, ROLE_WHITELISTED);
        _;
    }

    /**
    * @dev Add an address to the whitelist
    * @param _operator Operator address
    */
    function addAddressToWhitelist(address _operator) public hasOwnerOrOperatePermission {
        addRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev Getter to determine if address is in whitelist
    * @param _operator The address to be added to the whitelist
    * @return True if the address is in the whitelist
    */
    function whitelist(address _operator) public view returns (bool) {
        return hasRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev Add addresses to the whitelist
    * @param _operators Operators addresses
    */
    function addAddressesToWhitelist(address[] _operators) public hasOwnerOrOperatePermission {
        for (uint256 i = 0; i < _operators.length; i++) {
            addAddressToWhitelist(_operators[i]);
        }
    }

    /**
    * @dev Remove an address from the whitelist
    * @param _operator Operator address
    */
    function removeAddressFromWhitelist(address _operator) public hasOwnerOrOperatePermission {
        removeRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev Remove addresses from the whitelist
    * @param _operators Operators addresses
    */
    function removeAddressesFromWhitelist(address[] _operators) public hasOwnerOrOperatePermission {
        for (uint256 i = 0; i < _operators.length; i++) {
            removeAddressFromWhitelist(_operators[i]);
        }
    }
}



contract WhitelistedCrowdsale is Whitelist, BaseCrowdsale {
    /**
    * @dev Extend parent behavior requiring beneficiary to be in whitelist.
    * @param _beneficiary Token beneficiary
    * @param _weiAmount Amount of wei contributed
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyIfWhitelisted(_beneficiary) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}









/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}




contract PausableCrowdsale is Pausable, BaseCrowdsale {
    /**
    * @dev Extend parent behavior requiring contract not to be paused
    * @param _beneficiary Token beneficiary
    * @param _weiAmount Amount of wei contributed
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
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



/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
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
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
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




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
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
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}






contract CosquareToken is Time, StandardToken, DetailedERC20, Ownable {
    using SafeMath for uint256;

    /**
    * Describes locked balance
    * @param expires Time when tokens will be unlocked
    * @param value Amount of the tokens is locked
    */
    struct LockedBalance {
        uint256 expires;
        uint256 value;
    }

    // locked balances specified be the address
    mapping(address => LockedBalance[]) public lockedBalances;

    // sale wallet (65%)
    address public saleWallet;
    // reserve wallet (15%)
    address public reserveWallet;
    // team wallet (15%)
    address public teamWallet;
    // strategic wallet (5%)
    address public strategicWallet;

    // end point, after which all tokens will be unlocked
    uint256 public lockEndpoint;

    /**
    * Event for lock logging
    * @param who The address on which part of the tokens is locked
    * @param value Amount of the tokens is locked
    * @param expires Time when tokens will be unlocked
    */
    event LockLog(address indexed who, uint256 value, uint256 expires);

    /**
    * @param _saleWallet Sale wallet
    * @param _reserveWallet Reserve wallet
    * @param _teamWallet Team wallet
    * @param _strategicWallet Strategic wallet
    * @param _lockEndpoint End point, after which all tokens will be unlocked
    */
    constructor(address _saleWallet, address _reserveWallet, address _teamWallet, address _strategicWallet, uint256 _lockEndpoint) 
      DetailedERC20("cosquare", "CSQ", 18) public {
        require(_lockEndpoint > 0, "Invalid global lock end date.");
        lockEndpoint = _lockEndpoint;

        _configureWallet(_saleWallet, 65000000000000000000000000000); // 6.5e+28
        saleWallet = _saleWallet;
        _configureWallet(_reserveWallet, 15000000000000000000000000000); // 1.5e+28
        reserveWallet = _reserveWallet;
        _configureWallet(_teamWallet, 15000000000000000000000000000); // 1.5e+28
        teamWallet = _teamWallet;
        _configureWallet(_strategicWallet, 5000000000000000000000000000); // 0.5e+28
        strategicWallet = _strategicWallet;
    }

    /**
    * @dev Setting the initial value of the tokens to the wallet
    * @param _wallet Address to be set up
    * @param _amount The number of tokens to be assigned to this address
    */
    function _configureWallet(address _wallet, uint256 _amount) private {
        require(_wallet != address(0), "Invalid wallet address.");

        totalSupply_ = totalSupply_.add(_amount);
        balances[_wallet] = _amount;
        emit Transfer(address(0), _wallet, _amount);
    }

    /**
    * @dev Throws if the address does not have enough not locked balance
    * @param _who The address to transfer from
    * @param _value The amount to be transferred
    */
    modifier notLocked(address _who, uint256 _value) {
        uint256 time = _currentTime();

        if (lockEndpoint > time) {
            uint256 index = 0;
            uint256 locked = 0;
            while (index < lockedBalances[_who].length) {
                if (lockedBalances[_who][index].expires > time) {
                    locked = locked.add(lockedBalances[_who][index].value);
                }

                index++;
            }

            require(_value <= balances[_who].sub(locked), "Not enough unlocked tokens");
        }        
        _;
    }

    /**
    * @dev Overridden to check whether enough not locked balance
    * @param _from The address which you want to send tokens from
    * @param _to The address which you want to transfer to
    * @param _value The amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public notLocked(_from, _value) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev Overridden to check whether enough not locked balance
    * @param _to The address to transfer to
    * @param _value The amount to be transferred
    */
    function transfer(address _to, uint256 _value) public notLocked(msg.sender, _value) returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
    * @dev Gets the locked balance of the specified address
    * @param _owner The address to query the locked balance of
    * @param _expires Time of expiration of the lock (If equals to 0 - returns all locked tokens at this moment)
    * @return An uint256 representing the amount of locked balance by the passed address
    */
    function lockedBalanceOf(address _owner, uint256 _expires) external view returns (uint256) {
        uint256 time = _currentTime();
        uint256 index = 0;
        uint256 locked = 0;

        if (lockEndpoint > time) {       
            while (index < lockedBalances[_owner].length) {
                if (_expires > 0) {
                    if (lockedBalances[_owner][index].expires == _expires) {
                        locked = locked.add(lockedBalances[_owner][index].value);
                    }
                } else {
                    if (lockedBalances[_owner][index].expires >= time) {
                        locked = locked.add(lockedBalances[_owner][index].value);
                    }
                }

                index++;
            }
        }

        return locked;
    }

    /**
    * @dev Locks part of the balance for the specified address and for a certain period (3 periods expected)
    * @param _who The address of which will be locked part of the balance
    * @param _value The amount of tokens to be locked
    * @param _expires Time of expiration of the lock
    */
    function lock(address _who, uint256 _value, uint256 _expires) public onlyOwner {
        uint256 time = _currentTime();
        require(_who != address(0) && _value <= balances[_who] && _expires > time, "Invalid lock configuration.");

        uint256 index = 0;
        bool exist = false;
        while (index < lockedBalances[_who].length) {
            if (lockedBalances[_who][index].expires == _expires) {
                exist = true;
                break;
            }

            index++;
        }

        if (exist) {
            lockedBalances[_who][index].value = lockedBalances[_who][index].value.add(_value);
        } else {
            lockedBalances[_who].push(LockedBalance({
                expires: _expires,
                value: _value
            }));
        }

        emit LockLog(_who, _value, _expires);
    }
}


contract Crowdsale is Lockable, Operable, Withdrawal, PriceStrategy, LockableCrowdsale, WhitelistedCrowdsale, PausableCrowdsale {
    using SafeMath for uint256;

    /**
    * @param _rateETHtoCHF Cost of ETH in CHF
    * @param _minInvestmentInCHF Minimal allowed investment in CHF
    * @param _withdrawWallet Address to which funds will be withdrawn
    * @param _token Address of the token being sold
    */
    constructor(uint256 _rateETHtoCHF, uint256 _minInvestmentInCHF, address _withdrawWallet, CosquareToken _token)
        PriceStrategy(_rateETHtoCHF, _minInvestmentInCHF)
        Withdrawal(_withdrawWallet)
        BaseCrowdsale(_token) public {
    }  

    /**
    * @dev Distributes tokens for wei investments
    * @param _beneficiary Address performing the token purchase
    * @param _ethAmount Investment value in ETH
    * @param _type Type of investment channel
    */
    function distributeTokensForInvestment(address _beneficiary, uint256 _ethAmount, string _type) public hasOwnerOrOperatePermission {
        _buyTokens(_beneficiary, _ethAmount, _type);
    }

    /**
    * @dev Distributes tokens manually
    * @param _beneficiary Address performing the tokens distribution
    * @param _tokensAmount Amount of tokens distribution
    */
    function distributeTokensManual(address _beneficiary, uint256 _tokensAmount) external hasOwnerOrOperatePermission {
        _preValidatePurchase(_beneficiary, _tokensAmount);

        _deliverTokens(_beneficiary, _tokensAmount);
        emit TokensPurchaseLog("MANUAL", _beneficiary, 0, _tokensAmount, 0);

        _postPurchaseUpdate(_beneficiary, _tokensAmount);
    }
}
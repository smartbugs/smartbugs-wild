pragma solidity 0.4.25;

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether there is code in the target address
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address address to check
   * @return whether there is code in the target address
   */
  function isContract(address addr) internal view returns(bool) {
    uint256 size;
    assembly {
      size: = extcodesize(addr)
    }
    return size > 0;
  }

}



/**
 * @title SafeCompare
 */
library SafeCompare {
  function stringCompare(string str1, string str2) internal pure returns(bool) {
    return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
  }
}




library SafeMath {

  /**
   * @dev Multiplies two numbers, throws on overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns(uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
   * @dev Integer division of two numbers, truncating the quotient.
   */
  function div(uint256 a, uint256 b) internal pure returns(uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
   * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns(uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
   * @dev Adds two numbers, throws on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns(uint256) {
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract UsdtERC20Basic {
    uint public _totalSupply;
    function totalSupply() public constant returns (uint);
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
}



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns(uint256);

  function balanceOf(address who) public view returns(uint256);

  function transfer(address to, uint256 value) public returns(bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping(address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage _role, address _addr)
  internal {
    _role.bearer[_addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage _role, address _addr)
  internal {
    _role.bearer[_addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage _role, address _addr)
  internal
  view {
    require(has(_role, _addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage _role, address _addr)
  internal
  view
  returns(bool) {
    return _role.bearer[_addr];
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
 */
contract RBAC {
  using Roles
  for Roles.Role;

  mapping(string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  /**
   * @dev reverts if addr does not have role
   * @param _operator address
   * @param _role the name of the role
   * // reverts
   */
  function checkRole(address _operator, string _role)
  public
  view {
    roles[_role].check(_operator);
  }

  /**
   * @dev determine if addr has role
   * @param _operator address
   * @param _role the name of the role
   * @return bool
   */
  function hasRole(address _operator, string _role)
  public
  view
  returns(bool) {
    return roles[_role].has(_operator);
  }

  /**
   * @dev add a role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addRole(address _operator, string _role)
  internal {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  /**
   * @dev remove a role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeRole(address _operator, string _role)
  internal {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param _role the name of the role
   * // reverts
   */
  modifier onlyRole(string _role) {
    checkRole(msg.sender, _role);
    _;
  }

}








contract RBACOperator is Ownable, RBAC {

  /**
   * A constant role name for indicating operator.
   */
  string public constant ROLE_OPERATOR = "operator";

  address public partner;
  /**
   * Event for setPartner logging
   * @param oldPartner the old  Partner
   * @param newPartner the new  Partner
   */
  event SetPartner(address oldPartner, address newPartner);

  /**
   * @dev Throws if called by any account other than the owner or the Partner.
   */
  modifier onlyOwnerOrPartner() {
    require(msg.sender == owner || msg.sender == partner);
    _;
  }

  /**
   * @dev Throws if called by any account other than the Partner.
   */
  modifier onlyPartner() {
    require(msg.sender == partner);
    _;
  }


  /**
   * @dev setPartner, set the  partner address.
   * @param _partner the new  partner address.
   */
  function setPartner(address _partner) public onlyOwner {
    require(_partner != address(0));
    emit SetPartner(partner, _partner);
    partner = _partner;
  }


  /**
   * @dev removePartner, remove  partner address.
   */
  function removePartner() public onlyOwner {
    delete partner;
  }

  /**
   * @dev the modifier to operate
   */
  modifier hasOperationPermission() {
    checkRole(msg.sender, ROLE_OPERATOR);
    _;
  }



  /**
   * @dev add a operator role to an address
   * @param _operator address
   */
  function addOperater(address _operator) public onlyOwnerOrPartner {
    addRole(_operator, ROLE_OPERATOR);
  }

  /**
   * @dev remove a operator role from an address
   * @param _operator address
   */
  function removeOperater(address _operator) public onlyOwnerOrPartner {
    removeRole(_operator, ROLE_OPERATOR);
  }
}









/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns(uint256);

  function transferFrom(address from, address to, uint256 value) public returns(bool);

  function approve(address spender, uint256 value) public returns(bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract UsdtERC20 is UsdtERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}





contract PartnerAuthority is Ownable {


  address public partner;
  /**
   * Event for setPartner logging
   * @param oldPartner the old  Partner
   * @param newPartner the new  Partner
   */
  event SetPartner(address oldPartner, address newPartner);

  /**
   * @dev Throws if called by any account other than the owner or the Partner.
   */
  modifier onlyOwnerOrPartner() {
    require(msg.sender == owner || msg.sender == partner);
    _;
  }

  /**
   * @dev Throws if called by any account other than the Partner.
   */
  modifier onlyPartner() {
    require(msg.sender == partner);
    _;
  }


  /**
   * @dev setPartner, set the  partner address.
   */
  function setPartner(address _partner) public onlyOwner {
    require(_partner != address(0));
    emit SetPartner(partner, _partner);
    partner = _partner;
  }



  /**
   * @dev removePartner, remove  partner address.
   */
  function removePartner() public onlyOwner {
    delete partner;
  }


}









/**
 * @title OrderManageContract
 * @dev Order process management contract.
 */
contract OrderManageContract is PartnerAuthority {
  using SafeMath for uint256;
  using SafeCompare for string;

  /**
   * @dev Status of current business execution contract.
   */
  enum StatusChoices {
    NO_LOAN,
    REPAYMENT_WAITING,
    REPAYMENT_ALL,
    CLOSE_POSITION,
    OVERDUE_STOP
  }

  string internal constant TOKEN_ETH = "ETH";
  string internal constant TOKEN_USDT = "USDT";
  address public maker;
  address public taker;
  address internal token20;

  uint256 public toTime;
  // the amount of the borrower’s final loan.
  uint256 public outLoanSum;
  uint256 public repaymentSum;
  uint256 public lastRepaymentSum;
  string public loanTokenName;
  // Borrower's record of the pledge.
  StatusChoices internal status;

  // Record the amount of the borrower's offline transfer.
  mapping(address => uint256) public ethAmount;

  /**
   * Event for takerOrder logging.
   * @param taker address of investor.
   * @param outLoanSum the amount of the borrower’s final loan.
   */
  event TakerOrder(address indexed taker, uint256 outLoanSum);


  /**
   * Event for executeOrder logging.
   * @param maker address of borrower.
   * @param lastRepaymentSum current order repayment amount.
   */
  event ExecuteOrder(address indexed maker, uint256 lastRepaymentSum);

  /**
   * Event for forceCloseOrder logging.
   * @param toTime order repayment due date.
   * @param transferSum balance under current contract.
   */
  event ForceCloseOrder(uint256 indexed toTime, uint256 transferSum);

  /**
   * Event for WithdrawToken logging.
   * @param taker address of investor.
   * @param refundSum number of tokens withdrawn.
   */
  event WithdrawToken(address indexed taker, uint256 refundSum);



  function() external payable {
    // Record basic information about the borrower's REPAYMENT ETH
    ethAmount[msg.sender] = ethAmount[msg.sender].add(msg.value);
  }


  /**
   * @dev Constructor initial contract configuration parameters
   * @param _loanTokenAddress order type supported by the token.
   */
  constructor(string _loanTokenName, address _loanTokenAddress, address _maker) public {
    require(bytes(_loanTokenName).length > 0 && _maker != address(0));
    if (!_loanTokenName.stringCompare(TOKEN_ETH)) {
      require(_loanTokenAddress != address(0));
      token20 = _loanTokenAddress;
    }
    toTime = now;
    maker = _maker;
    loanTokenName = _loanTokenName;
    status = StatusChoices.NO_LOAN;
  }

  /**
   * @dev Complete an order combination and issue the loan to the borrower.
   * @param _taker address of investor.
   * @param _toTime order repayment due date.
   * @param _repaymentSum total amount of money that the borrower ultimately needs to return.
   */
  function takerOrder(address _taker, uint32 _toTime, uint256 _repaymentSum) public onlyOwnerOrPartner {
    require(_taker != address(0) && _toTime > 0 && now <= _toTime && _repaymentSum > 0 && status == StatusChoices.NO_LOAN);
    taker = _taker;
    toTime = _toTime;
    repaymentSum = _repaymentSum;

    // Transfer the token provided by the investor to the borrower's address
    if (loanTokenName.stringCompare(TOKEN_ETH)) {
      require(ethAmount[_taker] > 0 && address(this).balance > 0);
      outLoanSum = address(this).balance;
      maker.transfer(outLoanSum);
    } else {
      require(token20 != address(0) && ERC20(token20).balanceOf(address(this)) > 0);
      outLoanSum = ERC20(token20).balanceOf(address(this));
      require(safeErc20Transfer(maker, outLoanSum));
    }

    // Update contract business execution status.
    status = StatusChoices.REPAYMENT_WAITING;

    emit TakerOrder(taker, outLoanSum);
  }






  /**
   * @dev Only the full repayment will execute the contract agreement.
   */
  function executeOrder() public onlyOwnerOrPartner {
    require(now <= toTime && status == StatusChoices.REPAYMENT_WAITING);
    // The borrower pays off the loan and performs two-way operation.
    if (loanTokenName.stringCompare(TOKEN_ETH)) {
      require(ethAmount[maker] >= repaymentSum && address(this).balance >= repaymentSum);
      lastRepaymentSum = address(this).balance;
      taker.transfer(repaymentSum);
    } else {
      require(ERC20(token20).balanceOf(address(this)) >= repaymentSum);
      lastRepaymentSum = ERC20(token20).balanceOf(address(this));
      require(safeErc20Transfer(taker, repaymentSum));
    }

    PledgeContract(owner)._conclude();
    status = StatusChoices.REPAYMENT_ALL;
    emit ExecuteOrder(maker, lastRepaymentSum);
  }



  /**
   * @dev Close position or due repayment operation.
   */
  function forceCloseOrder() public onlyOwnerOrPartner {
    require(status == StatusChoices.REPAYMENT_WAITING);
    uint256 transferSum = 0;

    if (now <= toTime) {
      status = StatusChoices.CLOSE_POSITION;
    } else {
      status = StatusChoices.OVERDUE_STOP;
    }

    if(loanTokenName.stringCompare(TOKEN_ETH)){
        if(ethAmount[maker] > 0 && address(this).balance > 0){
            transferSum = address(this).balance;
            maker.transfer(transferSum);
        }
    }else{
        if(ERC20(token20).balanceOf(address(this)) > 0){
            transferSum = ERC20(token20).balanceOf(address(this));
            require(safeErc20Transfer(maker, transferSum));
        }
    }

    // Return pledge token.
    PledgeContract(owner)._forceConclude(taker);
    emit ForceCloseOrder(toTime, transferSum);
  }



  /**
   * @dev Withdrawal of the token invested by the taker.
   * @param _taker address of investor.
   * @param _refundSum refundSum number of tokens withdrawn.
   */
  function withdrawToken(address _taker, uint256 _refundSum) public onlyOwnerOrPartner {
    require(status == StatusChoices.NO_LOAN);
    require(_taker != address(0) && _refundSum > 0);
    if (loanTokenName.stringCompare(TOKEN_ETH)) {
      require(address(this).balance >= _refundSum && ethAmount[_taker] >= _refundSum);
      _taker.transfer(_refundSum);
      ethAmount[_taker] = ethAmount[_taker].sub(_refundSum);
    } else {
      require(ERC20(token20).balanceOf(address(this)) >= _refundSum);
      require(safeErc20Transfer(_taker, _refundSum));
    }
    emit WithdrawToken(_taker, _refundSum);
  }


  /**
   * @dev Since the implementation of usdt ERC20.sol transfer code does not design the return value,
   * @dev which is different from most ERC20 token interfaces,most erc20 transfer token agreements return bool.
   * @dev it is necessary to independently adapt the interface for usdt token in order to transfer successfully
   * @dev if not, the transfer may fail.
   */
  function safeErc20Transfer(address _toAddress,uint256 _transferSum) internal returns (bool) {
    if(loanTokenName.stringCompare(TOKEN_USDT)){
      UsdtERC20(token20).transfer(_toAddress, _transferSum);
    }else{
      require(ERC20(token20).transfer(_toAddress, _transferSum));
    }
    return true;
  }



  /**
   * @dev Get current contract order status.
   */
  function getPledgeStatus() public view returns(string pledgeStatus) {
    if (status == StatusChoices.NO_LOAN) {
      pledgeStatus = "NO_LOAN";
    } else if (status == StatusChoices.REPAYMENT_WAITING) {
      pledgeStatus = "REPAYMENT_WAITING";
    } else if (status == StatusChoices.REPAYMENT_ALL) {
      pledgeStatus = "REPAYMENT_ALL";
    } else if (status == StatusChoices.CLOSE_POSITION) {
      pledgeStatus = "CLOSE_POSITION";
    } else {
      pledgeStatus = "OVERDUE_STOP";
    }
  }

}








/**
 * @title PledgeFactory
 * @dev Pledge factory contract.
 * @dev Specially provides the pledge guarantee creation and the statistics function.
 */
contract PledgeFactory is RBACOperator {
  using AddressUtils for address;

  // initial type of pledge contract.
  string internal constant INIT_TOKEN_NAME = "UNKNOWN";

  mapping(uint256 => EscrowPledge) internal pledgeEscrowById;
  // pledge number unique screening.
  mapping(uint256 => bool) internal isPledgeId;

  /**
   * @dev Pledge guarantee statistics.
   */
  struct EscrowPledge {
    address pledgeContract;
    string tokenName;
  }

  /**
   * Event for createOrderContract logging.
   * @param pledgeId management contract id.
   * @param newPledgeAddress pledge management contract address.
   */
  event CreatePledgeContract(uint256 indexed pledgeId, address newPledgeAddress);


  /**
   * @dev Create a pledge subcontract
   * @param _pledgeId index number of the pledge contract.
   */
  function createPledgeContract(uint256 _pledgeId, address _escrowPartner) public onlyPartner returns(bool) {
    require(_pledgeId > 0 && !isPledgeId[_pledgeId] && _escrowPartner!=address(0));

    // Give the pledge contract the right to update statistics.
    PledgeContract pledgeAddress = new PledgeContract(_pledgeId, address(this),partner);
    pledgeAddress.transferOwnership(_escrowPartner);
    addOperater(address(pledgeAddress));

    // update pledge contract info
    isPledgeId[_pledgeId] = true;
    pledgeEscrowById[_pledgeId] = EscrowPledge(pledgeAddress, INIT_TOKEN_NAME);

    emit CreatePledgeContract(_pledgeId, address(pledgeAddress));
    return true;
  }



  /**
   * @dev Batch create a pledge subcontract
   * @param _pledgeIds index number of the pledge contract.
   */
  function batchCreatePledgeContract(uint256[] _pledgeIds, address _escrowPartner) public onlyPartner {
    require(_pledgeIds.length > 0 && _escrowPartner.isContract());
    for (uint i = 0; i < _pledgeIds.length; i++) {
      require(createPledgeContract(_pledgeIds[i],_escrowPartner));
    }
  }

  /**
   * @dev Use the index to get the basic information of the corresponding pledge contract.
   * @param _pledgeId index number of the pledge contract
   */
  function getEscrowPledge(uint256 _pledgeId) public view returns(string tokenName, address pledgeContract) {
    require(_pledgeId > 0);
    tokenName = pledgeEscrowById[_pledgeId].tokenName;
    pledgeContract = pledgeEscrowById[_pledgeId].pledgeContract;
  }




  // -----------------------------------------
  // Internal interface (Only the pledge contract has authority to operate)
  // -----------------------------------------


  /**
   * @dev Configure permissions to operate on the token pool.
   * @param _tokenPool token pool contract address.
   * @param _pledge pledge contract address.
   */
  function tokenPoolOperater(address _tokenPool, address _pledge) public hasOperationPermission {
    require(_pledge != address(0) && address(msg.sender).isContract() && address(msg.sender) == _pledge);
    PledgePoolBase(_tokenPool).addOperater(_pledge);
  }


  /**
   * @dev Update the basic data of the pledge contract.
   * @param _pledgeId index number of the pledge contract.
   * @param _tokenName pledge contract supported token type.
   */
  function updatePledgeType(uint256 _pledgeId, string _tokenName) public hasOperationPermission {
    require(_pledgeId > 0 && bytes(_tokenName).length > 0 && address(msg.sender).isContract());
    pledgeEscrowById[_pledgeId].tokenName = _tokenName;
  }


}




/**
 * @title EscrowMaintainContract
 * @dev Provides configuration and external interfaces.
 */
contract EscrowMaintainContract is PartnerAuthority {
  address public pledgeFactory;

  // map of token name to token pool address;
  mapping(string => address) internal nameByPool;
  // map of token name to erc20 token address;
  mapping(string => address) internal nameByToken;



  // -----------------------------------------
  // External interface
  // -----------------------------------------

  /**
   * @dev Create a pledge subcontract
   * @param _pledgeId index number of the pledge contract.
   */
  function createPledgeContract(uint256 _pledgeId) public onlyPartner returns(bool) {
    require(_pledgeId > 0 && pledgeFactory!=address(0));
    require(PledgeFactory(pledgeFactory).createPledgeContract(_pledgeId,partner));
    return true;
  }


  /**
   * @dev Batch create a pledge subcontract
   * @param _pledgeIds index number of the pledge contract.
   */
  function batchCreatePledgeContract(uint256[] _pledgeIds) public onlyPartner {
    require(_pledgeIds.length > 0);
    PledgeFactory(pledgeFactory).batchCreatePledgeContract(_pledgeIds,partner);
  }


  /**
   * @dev Use the index to get the basic information of the corresponding pledge contract.
   * @param _pledgeId index number of the pledge contract
   */
  function getEscrowPledge(uint256 _pledgeId) public view returns(string tokenName, address pledgeContract) {
    require(_pledgeId > 0);
    (tokenName,pledgeContract) = PledgeFactory(pledgeFactory).getEscrowPledge(_pledgeId);
  }


  /**
   * @dev setTokenPool, set the token pool contract address of a token name.
   * @param _tokenName set token pool name.
   * @param _address the token pool contract address.
   */
  function setTokenPool(string _tokenName, address _address) public onlyOwner {
    require(_address != address(0) && bytes(_tokenName).length > 0);
    nameByPool[_tokenName] = _address;
  }

   /**
   * @dev setToken, set the token contract address of a token name.
   * @param _tokenName token name
   * @param _address the ERC20 token contract address.
   */
  function setToken(string _tokenName, address _address) public onlyOwner {
    require(_address != address(0) && bytes(_tokenName).length > 0);
    nameByToken[_tokenName] = _address;
  }


  /**
  * @dev setPledgeFactory, Plant contract for configuration management pledge business.
  * @param _factory pledge factory contract.
  */
  function setPledgeFactory(address _factory) public onlyOwner {
    require(_factory != address(0));
    pledgeFactory = _factory;
  }

  /**
   * @dev Checks whether the current token pool is supported.
   * @param _tokenName token name
   */
  function includeTokenPool(string _tokenName) view public returns(address) {
    require(bytes(_tokenName).length > 0);
    return nameByPool[_tokenName];
  }


  /**
   * @dev Checks whether the current erc20 token is supported.
   * @param _tokenName token name
   */
  function includeToken(string _tokenName) view public returns(address) {
    require(bytes(_tokenName).length > 0);
    return nameByToken[_tokenName];
  }

}


/**
 * @title PledgeContract
 * @dev Pledge process management contract
 */
contract PledgeContract is PartnerAuthority {

  using SafeMath for uint256;
  using SafeCompare for string;

  /**
   * @dev Type of execution state of the pledge contract（irreversible）
   */
  enum StatusChoices {
    NO_PLEDGE_INFO,
    PLEDGE_CREATE_MATCHING,
    PLEDGE_REFUND
  }

  string public pledgeTokenName;
  uint256 public pledgeId;
  address internal maker;
  address internal token20;
  address internal factory;
  address internal escrowContract;
  uint256 internal pledgeAccountSum;
  // order contract address
  address internal orderContract;
  string internal loanTokenName;
  StatusChoices internal status;
  address internal tokenPoolAddress;
  string internal constant TOKEN_ETH = "ETH";
  string internal constant TOKEN_USDT = "USDT";
  // ETH pledge account
  mapping(address => uint256) internal verifyEthAccount;


  /**
   * Event for createOrderContract logging.
   * @param newOrderContract management contract address.
   */
  event CreateOrderContract(address newOrderContract);


  /**
   * Event for WithdrawToken logging.
   * @param maker address of investor.
   * @param pledgeTokenName token name.
   * @param refundSum number of tokens withdrawn.
   */
  event WithdrawToken(address indexed maker, string pledgeTokenName, uint256 refundSum);


  /**
   * Event for appendEscrow logging.
   * @param maker address of borrower.
   * @param appendSum append amount.
   */
  event AppendEscrow(address indexed maker, uint256 appendSum);


  /**
   * @dev Constructor initial contract configuration parameters
   */
  constructor(uint256 _pledgeId, address _factory , address _escrowContract) public {
    require(_pledgeId > 0 && _factory != address(0) && _escrowContract != address(0));
    pledgeId = _pledgeId;
    factory = _factory;
    status = StatusChoices.NO_PLEDGE_INFO;
    escrowContract = _escrowContract;
  }



  // -----------------------------------------
  // external interface
  // -----------------------------------------



  function() external payable {
    require(status != StatusChoices.PLEDGE_REFUND);
    // Identify the borrower.
    if (maker != address(0)) {
      require(address(msg.sender) == maker);
    }
    // Record basic information about the borrower's pledge ETH
    verifyEthAccount[msg.sender] = verifyEthAccount[msg.sender].add(msg.value);
  }


  /**
   * @dev Add the pledge information and transfer the pledged token into the corresponding currency pool.
   * @param _pledgeTokenName maker pledge token name.
   * @param _maker borrower address.
   * @param _pledgeSum pledge amount.
   * @param _loanTokenName pledge token type.
   */
  function addRecord(string _pledgeTokenName, address _maker, uint256 _pledgeSum, string _loanTokenName) public onlyOwner {
    require(_maker != address(0) && _pledgeSum > 0 && status != StatusChoices.PLEDGE_REFUND);
    // Add the pledge information for the first time.
    if (status == StatusChoices.NO_PLEDGE_INFO) {
      // public data init.
      maker = _maker;
      pledgeTokenName = _pledgeTokenName;
      tokenPoolAddress = checkedTokenPool(pledgeTokenName);
      PledgeFactory(factory).updatePledgeType(pledgeId, pledgeTokenName);
      // Assign rights to the operation of the contract pool
      PledgeFactory(factory).tokenPoolOperater(tokenPoolAddress, address(this));
      // Create order management contracts.
      createOrderContract(_loanTokenName);
    }
    // Record information of each pledge.
    pledgeAccountSum = pledgeAccountSum.add(_pledgeSum);
    PledgePoolBase(tokenPoolAddress).addRecord(maker, pledgeAccountSum, pledgeId, pledgeTokenName);
    // Transfer the pledge token to the appropriate token pool.
    if (pledgeTokenName.stringCompare(TOKEN_ETH)) {
      require(verifyEthAccount[maker] >= _pledgeSum);
      tokenPoolAddress.transfer(_pledgeSum);
    } else {
      token20 = checkedToken(pledgeTokenName);
      require(ERC20(token20).balanceOf(address(this)) >= _pledgeSum);
      require(safeErc20Transfer(token20,tokenPoolAddress, _pledgeSum));
    }
  }

  /**
   * @dev Increase the number of pledged tokens.
   * @param _appendSum append amount.
   */
  function appendEscrow(uint256 _appendSum) public onlyOwner {
    require(status == StatusChoices.PLEDGE_CREATE_MATCHING);
    addRecord(pledgeTokenName, maker, _appendSum, loanTokenName);
    emit AppendEscrow(maker, _appendSum);
  }


  /**
   * @dev Withdraw pledge behavior.
   * @param _maker borrower address.
   */
  function withdrawToken(address _maker) public onlyOwner {
    require(status != StatusChoices.PLEDGE_REFUND);
    uint256 pledgeSum = 0;
    // there are two types of retractions.
    if (status == StatusChoices.NO_PLEDGE_INFO) {
      pledgeSum = classifySquareUp(_maker);
    } else {
      status = StatusChoices.PLEDGE_REFUND;
      require(PledgePoolBase(tokenPoolAddress).withdrawToken(pledgeId, maker, pledgeAccountSum));
      pledgeSum = pledgeAccountSum;
    }
    emit WithdrawToken(_maker, pledgeTokenName, pledgeSum);
  }


  /**
   * @dev Executed in some extreme unforsee cases, to avoid eth locked.
   * @param _tokenName recycle token type.
   * @param _amount Number of eth to recycle.
   */
  function recycle(string _tokenName, uint256 _amount) public onlyOwner {
    require(status != StatusChoices.NO_PLEDGE_INFO && _amount>0);
    if (_tokenName.stringCompare(TOKEN_ETH)) {
      require(address(this).balance >= _amount);
      owner.transfer(_amount);
    } else {
      address token = checkedToken(_tokenName);
      require(ERC20(token).balanceOf(address(this)) >= _amount);
      require(safeErc20Transfer(token,owner, _amount));
    }
  }



  /**
   * @dev Since the implementation of usdt ERC20.sol transfer code does not design the return value,
   * @dev which is different from most ERC20 token interfaces,most erc20 transfer token agreements return bool.
   * @dev it is necessary to independently adapt the interface for usdt token in order to transfer successfully
   * @dev if not, the transfer may fail.
   */
  function safeErc20Transfer(address _token20,address _toAddress,uint256 _transferSum) internal returns (bool) {
    if(loanTokenName.stringCompare(TOKEN_USDT)){
      UsdtERC20(_token20).transfer(_toAddress, _transferSum);
    }else{
      require(ERC20(_token20).transfer(_toAddress, _transferSum));
    }
    return true;
  }



  // -----------------------------------------
  // internal interface
  // -----------------------------------------



  /**
   * @dev Create an order process management contract for the match and repayment business.
   * @param _loanTokenName expect loan token type.
   */
  function createOrderContract(string _loanTokenName) internal {
    require(bytes(_loanTokenName).length > 0);
    status = StatusChoices.PLEDGE_CREATE_MATCHING;
    address loanToken20 = checkedToken(_loanTokenName);
    OrderManageContract newOrder = new OrderManageContract(_loanTokenName, loanToken20, maker);
    setPartner(address(newOrder));
    newOrder.setPartner(owner);
    // update contract public data.
    orderContract = newOrder;
    loanTokenName = _loanTokenName;
    emit CreateOrderContract(address(newOrder));
  }

  /**
   * @dev classification withdraw.
   * @dev Execute without changing the current contract data state.
   * @param _maker borrower address.
   */
  function classifySquareUp(address _maker) internal returns(uint256 sum) {
    if (pledgeTokenName.stringCompare(TOKEN_ETH)) {
      uint256 pledgeSum = verifyEthAccount[_maker];
      require(pledgeSum > 0 && address(this).balance >= pledgeSum);
      _maker.transfer(pledgeSum);
      verifyEthAccount[_maker] = 0;
      sum = pledgeSum;
    } else {
      uint256 balance = ERC20(token20).balanceOf(address(this));
      require(balance > 0);
      require(safeErc20Transfer(token20,_maker, balance));
      sum = balance;
    }
  }

  /**
   * @dev Check wether the token is included for a token name.
   * @param _tokenName token name.
   */
  function checkedToken(string _tokenName) internal view returns(address) {
    address tokenAddress = EscrowMaintainContract(escrowContract).includeToken(_tokenName);
    require(tokenAddress != address(0));
    return tokenAddress;
  }

  /**
   * @dev Check wether the token pool is included for a token name.
   * @param _tokenName pledge token name.
   */
  function checkedTokenPool(string _tokenName) internal view returns(address) {
    address tokenPool = EscrowMaintainContract(escrowContract).includeTokenPool(_tokenName);
    require(tokenPool != address(0));
    return tokenPool;
  }



  // -----------------------------------------
  // business relationship interface
  // (Only the order contract has authority to operate)
  // -----------------------------------------



  /**
   * @dev Refund of the borrower’s pledge.
   */
  function _conclude() public onlyPartner {
    require(status == StatusChoices.PLEDGE_CREATE_MATCHING);
    status = StatusChoices.PLEDGE_REFUND;
    require(PledgePoolBase(tokenPoolAddress).refundTokens(pledgeId, pledgeAccountSum, maker));
  }

  /**
   * @dev Expired for repayment or close position.
   * @param _taker address of investor.
   */
  function _forceConclude(address _taker) public onlyPartner {
    require(_taker != address(0) && status == StatusChoices.PLEDGE_CREATE_MATCHING);
    status = StatusChoices.PLEDGE_REFUND;
    require(PledgePoolBase(tokenPoolAddress).refundTokens(pledgeId, pledgeAccountSum, _taker));
  }



  // -----------------------------------------
  // query interface (use no gas)
  // -----------------------------------------



  /**
   * @dev Get current contract order status.
   * @return pledgeStatus state indicate.
   */
  function getPledgeStatus() public view returns(string pledgeStatus) {
    if (status == StatusChoices.NO_PLEDGE_INFO) {
      pledgeStatus = "NO_PLEDGE_INFO";
    } else if (status == StatusChoices.PLEDGE_CREATE_MATCHING) {
      pledgeStatus = "PLEDGE_CREATE_MATCHING";
    } else {
      pledgeStatus = "PLEDGE_REFUND";
    }
  }

  /**
   * @dev get order contract address. use no gas.
   */
  function getOrderContract() public view returns(address) {
    return orderContract;
  }

  /**
   * @dev Gets the total number of tokens pledged under the current contract.
   */
  function getPledgeAccountSum() public view returns(uint256) {
    return pledgeAccountSum;
  }

  /**
   * @dev get current contract borrower address.
   */
  function getMakerAddress() public view returns(address) {
    return maker;
  }

  /**
   * @dev get current contract pledge Id.
   */
  function getPledgeId() external view returns(uint256) {
    return pledgeId;
  }

}



/**
 * @title pledge pool base
 * @dev a base tokenPool, any tokenPool for a specific token should inherit from this tokenPool.
 */
contract PledgePoolBase is RBACOperator {
  using SafeMath for uint256;
  using AddressUtils for address;

  // Record pledge details.
  mapping(uint256 => Escrow) internal escrows;

  /**
   * @dev Information structure of pledge.
   */
  struct Escrow {
    uint256 pledgeSum;
    address payerAddress;
    string tokenName;
  }

  // -----------------------------------------
  // TokenPool external interface
  // -----------------------------------------

  /**
   * @dev addRecord, interface to add record.
   * @param _payerAddress Address performing the pleadge.
   * @param _pledgeSum the value to pleadge.
   * @param _pledgeId pledge contract index number.
   * @param _tokenName pledge token name.
   */
  function addRecord(address _payerAddress, uint256 _pledgeSum, uint256 _pledgeId, string _tokenName) public hasOperationPermission returns(bool) {
    _preValidateAddRecord(_payerAddress, _pledgeSum, _pledgeId, _tokenName);
    _processAddRecord(_payerAddress, _pledgeSum, _pledgeId, _tokenName);
    return true;
  }


   /**
    * @dev withdrawToken, withdraw pledge token.
    * @param _pledgeId pledge contract index number.
    * @param _maker borrower address.
    * @param _num withdraw token sum.
    */
  function withdrawToken(uint256 _pledgeId, address _maker, uint256 _num) public hasOperationPermission returns(bool) {
    _preValidateWithdraw(_maker, _num, _pledgeId);
    _processWithdraw(_maker, _num, _pledgeId);
    return true;
  }


  /**
   * @dev refundTokens, interface to refund
   * @param _pledgeId pledge contract index number.
   * @param _targetAddress transfer target address.
   * @param _returnSum return token sum.
   */
  function refundTokens(uint256 _pledgeId, uint256 _returnSum, address _targetAddress) public hasOperationPermission returns(bool) {
    _preValidateRefund(_returnSum, _targetAddress, _pledgeId);
    _processRefund(_returnSum, _targetAddress, _pledgeId);
    return true;
  }

  /**
   * @dev getLedger, Query the pledge details of the pledge number in the pool.
   * @param _pledgeId pledge contract index number.
   */
  function getLedger(uint256 _pledgeId) public view returns(uint256 num, address payerAddress, string tokenName) {
    require(_pledgeId > 0);
    num = escrows[_pledgeId].pledgeSum;
    payerAddress = escrows[_pledgeId].payerAddress;
    tokenName = escrows[_pledgeId].tokenName;
  }



  // -----------------------------------------
  // TokenPool internal interface (extensible)
  // -----------------------------------------



  /**
   * @dev _preValidateAddRecord, Validation of an incoming AddRecord. Use require statemens to revert state when conditions are not met.
   * @param _payerAddress Address performing the pleadge.
   * @param _pledgeSum the value to pleadge.
   * @param _pledgeId pledge contract index number.
   * @param _tokenName pledge token name.
   */
  function _preValidateAddRecord(address _payerAddress, uint256 _pledgeSum, uint256 _pledgeId, string _tokenName) view internal {
    require(_pledgeSum > 0 && _pledgeId > 0
      && _payerAddress != address(0)
      && bytes(_tokenName).length > 0
      && address(msg.sender).isContract()
      && PledgeContract(msg.sender).getPledgeId()==_pledgeId
    );
  }

  /**
   * @dev _processAddRecord, Executed when a AddRecord has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _payerAddress Address performing the pleadge.
   * @param _pledgeSum the value to pleadge.
   * @param _pledgeId pledge contract index number.
   * @param _tokenName pledge token name.
   */
  function _processAddRecord(address _payerAddress, uint256 _pledgeSum, uint256 _pledgeId, string _tokenName) internal {
    Escrow memory escrow = Escrow(_pledgeSum, _payerAddress, _tokenName);
    escrows[_pledgeId] = escrow;
  }



  /**
   * @dev _preValidateRefund, Validation of an incoming refund. Use require statemens to revert state when conditions are not met.
   * @param _pledgeId pledge contract index number.
   * @param _targetAddress transfer target address.
   * @param _returnSum return token sum.
   */
  function _preValidateRefund(uint256 _returnSum, address _targetAddress, uint256 _pledgeId) view internal {
    require(_returnSum > 0 && _pledgeId > 0
      && _targetAddress != address(0)
      && address(msg.sender).isContract()
      && _returnSum <= escrows[_pledgeId].pledgeSum
      && PledgeContract(msg.sender).getPledgeId()==_pledgeId
    );
  }


  /**
   * @dev _processRefund, Executed when a Refund has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _pledgeId pledge contract index number.
   * @param _targetAddress transfer target address.
   * @param _returnSum return token sum.
   */
  function _processRefund(uint256 _returnSum, address _targetAddress, uint256 _pledgeId) internal {
    escrows[_pledgeId].pledgeSum = escrows[_pledgeId].pledgeSum.sub(_returnSum);
  }



  /**
   * @dev _preValidateWithdraw, Withdraw initiated parameter validation.
   * @param _pledgeId pledge contract index number.
   * @param _maker borrower address.
   * @param _num withdraw token sum.
   */
  function _preValidateWithdraw(address _maker, uint256 _num, uint256 _pledgeId) view internal {
    require(_num > 0 && _pledgeId > 0
       && _maker != address(0)
       && address(msg.sender).isContract()
       && _num <= escrows[_pledgeId].pledgeSum
       && PledgeContract(msg.sender).getPledgeId()==_pledgeId
    );
  }


  /**
   * @dev _processWithdraw, Withdraw data update.
   * @param _pledgeId pledge contract index number.
   * @param _maker borrower address.
   * @param _num withdraw token sum.
   */
  function _processWithdraw(address _maker, uint256 _num, uint256 _pledgeId) internal {
    escrows[_pledgeId].pledgeSum = escrows[_pledgeId].pledgeSum.sub(_num);
  }

}



/**
 * @title eth pledge pool.
 * @dev the tokenPool for ETH.
 */
contract EthPledgePool is PledgePoolBase {
  using SafeMath for uint256;
  using AddressUtils for address;
  // -----------------------------------------
  // TokenPool external interface
  // -----------------------------------------

  /**
   * @dev fallback function
   */
  function() external payable {}


  /**
   * @dev recycle, Executed in some extreme unforsee cases, to avoid eth locked.
   * @param _amount Number of eth to withdraw
   * @param _contract Multi-signature contracts, for the fair and just treatment of funds.
   */
  function recycle(uint256 _amount,address _contract) public onlyOwner returns(bool) {
    require(_amount <= address(this).balance && _contract.isContract());
    _contract.transfer(_amount);
    return true;
  }


  /**
   * @dev kill, kills the contract and send everything to `_address`..
   */
  function kills() public onlyOwner {
    selfdestruct(owner);
  }


  // -----------------------------------------
  // token pool internal interface (extensible)
  // -----------------------------------------


  /**
   * @dev Executed when a Refund has been validated and is ready to be executed.
   *  Not necessarily emits/sends tokens.
   */
  function _processRefund(uint256 _returnSum, address _targetAddress, uint256 _pledgeId) internal {
    super._processRefund(_returnSum, _targetAddress, _pledgeId);
    require(address(this).balance >= _returnSum);
    _targetAddress.transfer(_returnSum);
  }

  /**
   * @dev Withdraw pledge token.
   */
  function _processWithdraw(address _maker, uint256 _num, uint256 _pledgeId) internal {
    super._processWithdraw(_maker, _num, _pledgeId);
    require(address(this).balance >= _num);
    _maker.transfer(_num);
  }

}
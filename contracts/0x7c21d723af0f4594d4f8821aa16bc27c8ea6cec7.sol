pragma solidity 0.4.18;


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
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
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
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancy_lock);
    reentrancy_lock = true;
    _;
    reentrancy_lock = false;
  }

}

library Utils {
  function isEther(address addr) internal pure returns (bool) {
    return addr == address(0x0);
  }
}


contract DUBIex is ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;
  
  // order
  struct Order {
    uint256 id;
    address maker;
    uint256 amount;
    address pairA;
    address pairB;
    uint256 priceA;
    uint256 priceB;
  }

  // order id -> order
  mapping(uint256 => Order) public orders;

  // weiSend of current tx
  uint256 private weiSend = 0;

  // makes sure weiSend of current tx is reset
  modifier weiSendGuard() {
    weiSend = msg.value;
    _;
    weiSend = 0;
  }

  // logs
  event LogMakeOrder(uint256 id, address indexed maker, uint256 amount, address indexed pairA, address indexed pairB, uint256 priceA, uint256 priceB);
  event LogTakeOrder(uint256 indexed id, address indexed taker, uint256 amount);
  event LogCancelOrder(uint256 indexed id);

  // internal
  function _makeOrder(uint256 id, uint256 amount, address pairA, address pairB, uint256 priceA, uint256 priceB, address maker) internal returns (bool) {
    // validate input
    if (
      id <= 0 ||
      amount <= 0 ||
      pairA == pairB ||
      priceA <= 0 ||
      priceB <= 0 ||
      orders[id].id == id
    ) return false;

    bool pairAisEther = Utils.isEther(pairA);
    ERC20 tokenA = ERC20(pairA);

    // validate maker's deposit
    if (pairAisEther && (weiSend <= 0 || weiSend < amount)) return false;
    else if (!pairAisEther && (tokenA.allowance(maker, this) < amount || tokenA.balanceOf(maker) < amount)) return false;

    // update state
    orders[id] = Order(id, maker, amount, pairA, pairB, priceA, priceB);

    // retrieve makers amount
    if (pairAisEther) {
      // eth already received, subtract used wei
      weiSend = weiSend.sub(amount);
    } else {
      // pull tokens
      tokenA.safeTransferFrom(maker, this, amount);
    }

    LogMakeOrder(id, maker, amount, pairA, pairB, priceA, priceB);

    return true;
  }

  function _takeOrder(uint256 id, uint256 amount, address taker) internal returns (bool) {
    // validate inputs
    if (
      id <= 0 ||
      amount <= 0
    ) return false;
    
    // get order
    Order storage order = orders[id];
    // validate order
    if (order.id != id) return false;
    
    bool pairAisEther = Utils.isEther(order.pairA);
    bool pairBisEther = Utils.isEther(order.pairB);
    // amount of pairA usable
    uint256 usableAmount = amount > order.amount ? order.amount : amount;
    // amount of pairB maker will receive
    uint256 totalB = usableAmount.mul(order.priceB).div(order.priceA);

    // token interfaces
    ERC20 tokenA = ERC20(order.pairA);
    ERC20 tokenB = ERC20(order.pairB);

    // validate taker's deposit
    if (pairBisEther && (weiSend <= 0 || weiSend < totalB)) return false;
    else if (!pairBisEther && (tokenB.allowance(taker, this) < totalB || tokenB.balanceOf(taker) < amount)) return false;

    // update state
    order.amount = order.amount.sub(usableAmount);

    // pay maker
    if (pairBisEther) {
      weiSend = weiSend.sub(totalB);
      order.maker.transfer(totalB);
    } else {
      tokenB.safeTransferFrom(taker, order.maker, totalB);
    }

    // pay taker
    if (pairAisEther) {
      taker.transfer(usableAmount);
    } else {
      tokenA.safeTransfer(taker, usableAmount);
    }

    LogTakeOrder(id, taker, usableAmount);

    return true;
  }

  function _cancelOrder(uint256 id, address maker) internal returns (bool) {
    // validate inputs
    if (id <= 0) return false;

    // get order
    Order storage order = orders[id];
    if (
      order.id != id ||
      order.maker != maker
    ) return false;

    uint256 amount = order.amount;
    bool pairAisEther = Utils.isEther(order.pairA);

    // update state
    order.amount = 0;

    // actions
    if (pairAisEther) {
      order.maker.transfer(amount);
    } else {
      ERC20(order.pairA).safeTransfer(order.maker, amount);
    }

    LogCancelOrder(id);

    return true;
  }

  // single
  function makeOrder(uint256 id, uint256 amount, address pairA, address pairB, uint256 priceA, uint256 priceB) external payable weiSendGuard nonReentrant returns (bool) {
    bool success = _makeOrder(id, amount, pairA, pairB, priceA, priceB, msg.sender);

    if (weiSend > 0) msg.sender.transfer(weiSend);

    return success;
  }

  function takeOrder(uint256 id, uint256 amount) external payable weiSendGuard nonReentrant returns (bool) {
    bool success = _takeOrder(id, amount, msg.sender);

    if (weiSend > 0) msg.sender.transfer(weiSend);

    return success;
  }

  function cancelOrder(uint256 id) external nonReentrant returns (bool) {
    return _cancelOrder(id, msg.sender);
  }

  // multi
  function makeOrders(uint256[] ids, uint256[] amounts, address[] pairAs, address[] pairBs, uint256[] priceAs, uint256[] priceBs) external payable weiSendGuard nonReentrant returns (bool) {
    require(
      amounts.length == ids.length &&
      pairAs.length == ids.length &&
      pairBs.length == ids.length &&
      priceAs.length == ids.length &&
      priceBs.length == ids.length
    );

    bool allSuccess = true;

    for (uint256 i = 0; i < ids.length; i++) {
      // update if any of the orders failed
      // the function is like this because "stack too deep" error
      if (allSuccess && !_makeOrder(ids[i], amounts[i], pairAs[i], pairBs[i], priceAs[i], priceBs[i], msg.sender)) allSuccess = false;
    }

    if (weiSend > 0) msg.sender.transfer(weiSend);

    return allSuccess;
  }

  function takeOrders(uint256[] ids, uint256[] amounts) external payable weiSendGuard nonReentrant returns (bool) {
    require(ids.length == amounts.length);

    bool allSuccess = true;

    for (uint256 i = 0; i < ids.length; i++) {
      bool success = _takeOrder(ids[i], amounts[i], msg.sender);

      // update if any of the orders failed
      if (allSuccess && !success) allSuccess = success;
    }

    if (weiSend > 0) msg.sender.transfer(weiSend);

    return allSuccess;
  }

  function cancelOrders(uint256[] ids) external nonReentrant returns (bool) {
    bool allSuccess = true;

    for (uint256 i = 0; i < ids.length; i++) {
      bool success = _cancelOrder(ids[i], msg.sender);

      // update if any of the orders failed
      if (allSuccess && !success) allSuccess = success;
    }

    return allSuccess;
  }
}
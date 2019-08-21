pragma solidity ^0.4.24;

// File: openzeppelin-solidity\contracts\math\SafeMath.sol

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

// File: openzeppelin-solidity\contracts\token\ERC20\ERC20Basic.sol

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

// File: openzeppelin-solidity\contracts\token\ERC20\ERC20.sol

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

// File: openzeppelin-solidity\contracts\token\ERC20\SafeERC20.sol

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

// File: contracts\DecentralizedExchanges2.sol

contract SpecialERC20 {
    function transfer(address to, uint256 value) public;
}

contract DecentralizedExchanges {

    using SafeMath for uint;
    using SafeERC20 for ERC20;

    string public name = "DecentralizedExchanges";

    event Order(bytes32 hash);
    event Trade(bytes32 hash, address seller, address token, uint amount, address purchaser, uint eth);
    event Cancel(bytes32 hash, uint amount, bool isSell);

    struct OrderInfo {
        bool isSell;
        bool isSpecialERC20;
        uint eth;
        uint amount;
        uint expires;
        uint nonce;
        uint createdAt;
        uint fill;
        address token;
        address[] limitUser;
        address owner;
    }

    mapping (bytes32 => OrderInfo) public orderInfos;
    mapping (address => bytes32[]) public userOrders;

    function getOrderInfo(bytes32 hash) public view returns (bool, uint, address, uint, uint, uint, address[], uint, address, uint, bool) {
        OrderInfo storage info = orderInfos[hash];
        return (info.isSell, info.eth, info.token, info.amount, info.expires, info.nonce, info.limitUser, info.createdAt, info.owner, info.fill, info.isSpecialERC20);
    }

    // 创建买单,用eth买token
    function createPurchaseOrder(bool isSpecialERC20, uint eth, address token, uint amount, uint expires, address[] seller, uint nonce) payable public {
        require(msg.value >= eth);
        bytes32 hash = sha256(abi.encodePacked(this, eth, token, amount, expires, seller, nonce, msg.sender, now));
        orderInfos[hash] = OrderInfo(false, isSpecialERC20, eth, amount, expires, nonce, now, 0, token, seller, msg.sender);
        for (uint i = 0; i < userOrders[msg.sender].length; i++) {
            require(userOrders[msg.sender][i] != hash);
        }
        userOrders[msg.sender].push(hash);
        emit Order(hash);
    }

    // 创建卖单,卖token得eth
    function createSellOrder(bool isSpecialERC20, address token, uint amount, uint eth, uint expires, address[] purchaser, uint nonce) public {
        ERC20(token).safeTransferFrom(msg.sender, this, amount);
        bytes32 hash = sha256(abi.encodePacked(this, eth, token, amount, expires, purchaser, nonce, msg.sender, now));
        orderInfos[hash] = OrderInfo(true, isSpecialERC20, eth, amount, expires, nonce, now, 0, token, purchaser, msg.sender);
        for (uint i = 0; i < userOrders[msg.sender].length; i++) {
            require(userOrders[msg.sender][i] != hash);
        }
        userOrders[msg.sender].push(hash);
        emit Order(hash);
    }

    function cancelOrder(bytes32 hash) public {
        OrderInfo storage info = orderInfos[hash];
        require(info.owner == msg.sender);
        if (info.isSell) {
            if (info.fill < info.amount) {
                uint amount = info.amount;
                uint remain = amount - info.fill;
                info.fill = info.amount;
                if (info.isSpecialERC20) {
                    SpecialERC20(info.token).transfer(msg.sender, remain);
                } else {
                    ERC20(info.token).transfer(msg.sender, remain);
                }
                emit Cancel(hash, remain, info.isSell);
            } else {
                emit Cancel(hash, 0, info.isSell);
            }
        } else {
            if (info.fill < info.eth) {
                uint eth = info.eth;
                remain = eth - info.fill;
                info.fill = info.eth;
                msg.sender.transfer(eth);
                emit Cancel(hash, remain, info.isSell);
            } else {
                emit Cancel(hash, 0, info.isSell);
            }
        }
    }

    // 卖token,针对创建的买单
    function sell(bytes32 hash, uint amount) public {
        OrderInfo storage info = orderInfos[hash];
        bool find = false;
        if (info.limitUser.length > 0) {
            for (uint i = 0; i < info.limitUser.length; i++) {
                if (info.limitUser[i] == msg.sender) {
                    find = true;
                    break;
                }
            }
            require(find);
        }

        // 确保订单还有剩余eth
        require(info.fill < info.eth);
        require(info.expires >= now);

        uint remain = info.eth - info.fill;

        uint remainAmount = remain.mul(info.amount).div(info.eth);
        
        uint tradeAmount = remainAmount < amount ? remainAmount : amount;
        // token从卖家转到合约
        ERC20(info.token).safeTransferFrom(msg.sender, this, tradeAmount);

        uint total = info.eth.mul(tradeAmount).div(info.amount);

        msg.sender.transfer(total);
        
        // token从合约转到买家
        if (info.isSpecialERC20) {
            SpecialERC20(info.token).transfer(info.owner, tradeAmount);
        } else {
            ERC20(info.token).transfer(info.owner, tradeAmount);
        }

        info.fill = info.fill.add(total);

        emit Trade(hash, msg.sender, info.token, tradeAmount, info.owner, total);
    }

    // 买token,针对创建的卖单
    function purchase(bytes32 hash, uint amount) payable public {
        OrderInfo storage info = orderInfos[hash];
        bool find = false;
        if (info.limitUser.length > 0) {
            for (uint i = 0; i < info.limitUser.length; i++) {
                if (info.limitUser[i] == msg.sender) {
                    find = true;
                    break;
                }
            }
            require(find);
        }

        // 确保订单还有剩余token
        require(info.fill < info.amount);
        require(info.expires >= now);

        uint remainAmount = info.amount - info.fill;

        uint tradeAmount = remainAmount < amount ? remainAmount : amount;

        uint total = info.eth.mul(tradeAmount).div(info.amount);

        require(msg.value >= total);
        if (msg.value > total) { // 多余的eth转回去
            msg.sender.transfer(msg.value - total);
        }

        info.owner.transfer(total);
        if (info.isSpecialERC20) {
            SpecialERC20(info.token).transfer(msg.sender, tradeAmount);
        } else {
            ERC20(info.token).transfer(msg.sender, tradeAmount);
        }
        info.fill = info.fill.add(tradeAmount);

        emit Trade(hash, info.owner, info.token, tradeAmount, msg.sender, total);
    }
  
}
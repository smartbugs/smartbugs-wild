pragma solidity ^0.4.24;



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * @dev Based on: OpenZeppelin
 */
contract Ownable {
  address public owner;


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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}






/**
 * @title TridentDistribution
 * @dev Implementation of the TridentDistribution smart contract.
 */
contract TridentDistribution is Ownable {

  // Stores the Trident smart contract
  ERC20 public trident;

  // Struct that represents a transfer order
  struct Order {
    uint256 amount;         // amount of tokens to transfer
    address account;        // account to transfer amount to
    string metadata;        // arbitrary metadata
  }

  // Array of all current transfer orders
  Order[] orders;

  // Accounts allowed to place orders
  address[] orderDelegates;

  // Accounts allowed to approve orders
  address[] approvalDelegates;

  // Amount of ETH sent with each order executed
  uint public complementaryEthPerOrder;


  // Event emitted when an account has been approved as an order delegate
  event ApproveOrderDelegate(
      address indexed orderDelegate
    );
  // Event emitted when an account has been revoked from being an order delegate
  event RevokeOrderDelegate(
      address indexed orderDelegate
    );

  // Event emitted when an account has been approved as an approval delegate
  event ApproveApprovalDelegate(
      address indexed approvalDelegate
    );
  // Event emitted when an account has been revoked from being an approval delegate
  event RevokeApprovalDelegate(
      address indexed approvalDelegate
    );

  // Event emitted when an order has been placed
  event OrderPlaced(
    uint indexed orderIndex
    );

  // Event emitted when an order has been approved and executed
  event OrderApproved(
    uint indexed orderIndex
    );

  // Event emitted when an order has been revoked
  event OrderRevoked(
    uint indexed orderIndex
    );

  // Event emitted when the entire orders batch is approved and executed
  event AllOrdersApproved();

  // Event emitted when complementaryEthPerOrder has been set
  event ComplementaryEthPerOrderSet();



  constructor(ERC20 _tridentSmartContract) public {
      trident = _tridentSmartContract;
  }

  /**
   * @dev Fallback function to allow contract to receive ETH via 'send'.
   */
  function () public payable {
  }


  /**
   * @dev Throws if called by any account other than an owner or an order delegate.
   */
  modifier onlyOwnerOrOrderDelegate() {
    bool allowedToPlaceOrders = false;

    if(msg.sender==owner) {
      allowedToPlaceOrders = true;
    }
    else {
      for(uint i=0; i<orderDelegates.length; i++) {
        if(orderDelegates[i]==msg.sender) {
          allowedToPlaceOrders = true;
          break;
        }
      }
    }

    require(allowedToPlaceOrders==true);
    _;
  }

  /**
   * @dev Throws if called by any account other than an owner or an approval delegate.
   */
  modifier onlyOwnerOrApprovalDelegate() {
    bool allowedToApproveOrders = false;

    if(msg.sender==owner) {
      allowedToApproveOrders = true;
    }
    else {
      for(uint i=0; i<approvalDelegates.length; i++) {
        if(approvalDelegates[i]==msg.sender) {
          allowedToApproveOrders = true;
          break;
        }
      }
    }

    require(allowedToApproveOrders==true);
    _;
  }


  /**
   * @dev Return the array of order delegates.
   */
  function getOrderDelegates() external view returns (address[]) {
    return orderDelegates;
  }

  /**
   * @dev Return the array of burn delegates.
   */
  function getApprovalDelegates() external view returns (address[]) {
    return approvalDelegates;
  }

  /**
   * @dev Give an account permission to place orders.
   * @param _orderDelegate The account to be approved.
   */
  function approveOrderDelegate(address _orderDelegate) onlyOwner external returns (bool) {
    bool delegateFound = false;
    for(uint i=0; i<orderDelegates.length; i++) {
      if(orderDelegates[i]==_orderDelegate) {
        delegateFound = true;
        break;
      }
    }

    if(!delegateFound) {
      orderDelegates.push(_orderDelegate);
    }

    emit ApproveOrderDelegate(_orderDelegate);
    return true;
  }

  /**
   * @dev Revoke permission to place orders from an order delegate.
   * @param _orderDelegate The account to be revoked.
   */
  function revokeOrderDelegate(address _orderDelegate) onlyOwner external returns (bool) {
    uint length = orderDelegates.length;
    require(length > 0);

    address lastDelegate = orderDelegates[length-1];
    if(_orderDelegate == lastDelegate) {
      delete orderDelegates[length-1];
      orderDelegates.length--;
    }
    else {
      // Game plan: find the delegate, replace it with the very last item in the array, then delete the last item
      for(uint i=0; i<length; i++) {
        if(orderDelegates[i]==_orderDelegate) {
          orderDelegates[i] = lastDelegate;
          delete orderDelegates[length-1];
          orderDelegates.length--;
          break;
        }
      }
    }

    emit RevokeOrderDelegate(_orderDelegate);
    return true;
  }

  /**
   * @dev Give an account permission to approve orders.
   * @param _approvalDelegate The account to be approved.
   */
  function approveApprovalDelegate(address _approvalDelegate) onlyOwner external returns (bool) {
    bool delegateFound = false;
    for(uint i=0; i<approvalDelegates.length; i++) {
      if(approvalDelegates[i]==_approvalDelegate) {
        delegateFound = true;
        break;
      }
    }

    if(!delegateFound) {
      approvalDelegates.push(_approvalDelegate);
    }

    emit ApproveApprovalDelegate(_approvalDelegate);
    return true;
  }

  /**
   * @dev Revoke permission to approve orders from an approval delegate.
   * @param _approvalDelegate The account to be revoked.
   */
  function revokeApprovalDelegate(address _approvalDelegate) onlyOwner external returns (bool) {
    uint length = approvalDelegates.length;
    require(length > 0);

    address lastDelegate = approvalDelegates[length-1];
    if(_approvalDelegate == lastDelegate) {
      delete approvalDelegates[length-1];
      approvalDelegates.length--;
    }
    else {
      // Game plan: find the delegate, replace it with the very last item in the array, then delete the last item
      for(uint i=0; i<length; i++) {
        if(approvalDelegates[i]==_approvalDelegate) {
          approvalDelegates[i] = lastDelegate;
          delete approvalDelegates[length-1];
          approvalDelegates.length--;
          break;
        }
      }
    }

    emit RevokeApprovalDelegate(_approvalDelegate);
    return true;
  }


  /**
   * @dev Internal function to delete an order at the given index from the orders array.
   * @param _orderIndex The index of the order to be removed.
   */
  function _deleteOrder(uint _orderIndex) internal {
    require(orders.length > _orderIndex);

    uint lastIndex = orders.length-1;
    if(_orderIndex != lastIndex) {
      // Replace the order to be deleted with the very last item in the array
      orders[_orderIndex] = orders[lastIndex];
    }
    delete orders[lastIndex];
    orders.length--;
  }

  /**
   * @dev Internal function to execute an order at the given index.
   * @param _orderIndex The index of the order to be executed.
   */
  function _executeOrder(uint _orderIndex) internal {
    require(orders.length > _orderIndex);
    require(complementaryEthPerOrder <= address(this).balance);

    Order memory order = orders[_orderIndex];
    _deleteOrder(_orderIndex);

    trident.transfer(order.account, order.amount);

    // Transfer the complementary ETH
    address(order.account).transfer(complementaryEthPerOrder);
  }

  /**
   * @dev Function to place an order.
   * @param _amount The amount of tokens to transfer.
   * @param _account The account to transfer the tokens to.
   * @param _metadata Arbitrary metadata.
   * @return A boolean that indicates if the operation was successful.
   */
  function placeOrder(uint256 _amount, address _account, string _metadata) onlyOwnerOrOrderDelegate external returns (bool) {
    orders.push(Order({amount: _amount, account: _account, metadata: _metadata}));

    emit OrderPlaced(orders.length-1);

    return true;
  }

  /**
   * @dev Return the number of orders.
   */
  function getOrdersCount() external view returns (uint) {
    return orders.length;
  }

  /**
   * @dev Return the number of orders.
   */
  function getOrdersTotalAmount() external view returns (uint) {
    uint total = 0;
    for(uint i=0; i<orders.length; i++) {
        Order memory order = orders[i];
        total += order.amount;
    }

    return total;
  }

  /**
   * @dev Return the order at the given index.
   */
  function getOrderAtIndex(uint _orderIndex) external view returns (uint256 amount, address account, string metadata) {
    Order memory order = orders[_orderIndex];
    return (order.amount, order.account, order.metadata);
  }

  /**
   * @dev Function to revoke an order at the given index.
   * @param _orderIndex The index of the order to be revoked.
   * @return A boolean that indicates if the operation was successful.
   */
  function revokeOrder(uint _orderIndex) onlyOwnerOrApprovalDelegate external returns (bool) {
    _deleteOrder(_orderIndex);

    emit OrderRevoked(_orderIndex);

    return true;
  }

  /**
   * @dev Function to approve an order at the given index.
   * @param _orderIndex The index of the order to be approved.
   * @return A boolean that indicates if the operation was successful.
   */
  function approveOrder(uint _orderIndex) onlyOwnerOrApprovalDelegate external returns (bool) {
    _executeOrder(_orderIndex);

    emit OrderApproved(_orderIndex);

    return true;
  }

  /**
   * @dev Function to approve all orders in the orders array.
   * @return A boolean that indicates if the operation was successful.
   */
  function approveAllOrders() onlyOwnerOrApprovalDelegate external returns (bool) {
    uint orderCount = orders.length;
    uint totalComplementaryEth = complementaryEthPerOrder * orderCount;
    require(totalComplementaryEth <= address(this).balance);

    for(uint i=0; i<orderCount; i++) {
        Order memory order = orders[i];
        trident.transfer(order.account, order.amount);

        // Transfer the complementary ETH
        address(order.account).transfer(complementaryEthPerOrder);
    }

    // Dispose of all approved orders
    delete orders;


    emit AllOrdersApproved();

    return true;
  }



  /**
   * @dev Function to set the complementary eth sent with each order executed.
   * @param _complementaryEthPerOrder The index of the order to be approved.
   * @return A boolean that indicates if the operation was successful.
   */
  function setComplementaryEthPerOrder(uint _complementaryEthPerOrder) onlyOwner external returns (bool) {
    complementaryEthPerOrder = _complementaryEthPerOrder;

    emit ComplementaryEthPerOrderSet();

    return true;
  }


  /**
   * @dev Function withdraws all ETH from the smart contract.
   * @return A boolean that indicates if the operation was successful.
   */
  function withdrawAllEth() onlyOwner external returns (bool) {
    uint ethBalance = address(this).balance;
    require(ethBalance > 0);

    owner.transfer(ethBalance);

    return true;
  }


  /**
   * @dev Function withdraws all Trident from the smart contract.
   * @return A boolean that indicates if the operation was successful.
   */
  function withdrawAllTrident() onlyOwner external returns (bool) {
    uint tridentBalance = trident.balanceOf(address(this));
    require(tridentBalance > 0);

    return trident.transfer(owner, tridentBalance);
  }

}
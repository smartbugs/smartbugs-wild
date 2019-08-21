pragma solidity 0.5.7;


/**
 * @title Data Exchange Marketplace
 * @notice This contract allows Notaries to register themselves and buyers to
 *         publish data orders, acording to the Wibson Protocol.
 *         For more information: https://wibson.org
 */
contract DataExchange {
  event NotaryRegistered(address indexed notary, string notaryUrl);
  event NotaryUpdated(address indexed notary, string oldNotaryUrl, string newNotaryUrl);
  event NotaryUnregistered(address indexed notary, string oldNotaryUrl);
  event DataOrderCreated(uint256 indexed orderId, address indexed buyer);
  event DataOrderClosed(uint256 indexed orderId, address indexed buyer);

  struct DataOrder {
    address buyer;
    string audience;
    uint256 price;
    string requestedData;
    bytes32 termsAndConditionsHash;
    string buyerUrl;
    uint32 createdAt;
    uint32 closedAt;
  }

  DataOrder[] internal dataOrders;
  mapping(address => string) internal notaryUrls;

  /**
   * @notice Registers sender as a notary.
   * @param notaryUrl Public URL of the notary where the notary info can be obtained.
   *                  This URL should serve a JSON signed by the sender to prove
   *                  authenticity. It is highly recommended to check the signature
   *                  with the sender's address before using the notary's services.
   * @return true if the notary was successfully registered, reverts otherwise.
   */
  function registerNotary(string calldata notaryUrl) external returns (bool) {
    require(_isNotEmpty(notaryUrl), "notaryUrl must not be empty");
    require(!_isSenderNotary(), "Notary already registered (use updateNotaryUrl to update)");
    notaryUrls[msg.sender] = notaryUrl;
    emit NotaryRegistered(msg.sender, notaryUrl);
    return true;
  }

  /**
   * @notice Updates notary public URL of sender.
   * @param newNotaryUrl Public URL of the notary where the notary info can be obtained.
   *                     This URL should serve a JSON signed by the sender to prove
   *                     authenticity. It is highly recommended to check the signature
   *                     with the sender's address before using the notary's services.
   * @return true if the notary public URL was successfully updated, reverts otherwise.
   */
  function updateNotaryUrl(string calldata newNotaryUrl) external returns (bool) {
    require(_isNotEmpty(newNotaryUrl), "notaryUrl must not be empty");
    require(_isSenderNotary(), "Notary not registered");
    string memory oldNotaryUrl = notaryUrls[msg.sender];
    notaryUrls[msg.sender] = newNotaryUrl;
    emit NotaryUpdated(msg.sender, oldNotaryUrl, newNotaryUrl);
    return true;
  }

  /**
   * @notice Unregisters sender as notary. Once unregistered, the notary does not
   *         have any obligation to maintain the old public URL.
   * @return true if the notary was successfully unregistered, reverts otherwise.
   */
  function unregisterNotary() external returns (bool) {
    require(_isSenderNotary(), "sender must be registered");
    string memory oldNotaryUrl = notaryUrls[msg.sender];
    delete notaryUrls[msg.sender];
    emit NotaryUnregistered(msg.sender, oldNotaryUrl);
    return true;
  }

  /**
   * @notice Creates a DataOrder.
   * @dev The `msg.sender` will become the buyer of the order.
   * @param audience Target audience of the order.
   * @param price Price that sellers will receive in exchange of their data.
   * @param requestedData Requested data type (Geolocation, Facebook, etc).
   * @param termsAndConditionsHash Hash of the Buyer's terms and conditions for the order.
   * @param buyerUrl Public URL of the buyer where more information about the DataOrder
   *        can be obtained.
   * @return The index of the newly created DataOrder. If the DataOrder could
   *         not be created, reverts.
   */
  function createDataOrder(
    string calldata audience,
    uint256 price,
    string calldata requestedData,
    bytes32 termsAndConditionsHash,
    string calldata buyerUrl
  ) external returns (uint256) {
    require(_isNotEmpty(audience), "audience must not be empty");
    require(price > 0, "price must be greater than zero");
    require(_isNotEmpty(requestedData), "requestedData must not be empty");
    require(termsAndConditionsHash != 0, "termsAndConditionsHash must not be empty");
    require(_isNotEmpty(buyerUrl), "buyerUrl must not be empty");

    uint256 orderId = dataOrders.length;
    dataOrders.push(DataOrder(
      msg.sender,
      audience,
      price,
      requestedData,
      termsAndConditionsHash,
      buyerUrl,
      uint32(now),
      uint32(0)
    ));

    emit DataOrderCreated(orderId, msg.sender);
    return orderId;
  }

  /**
   * @notice Closes the DataOrder.
   * @dev The `msg.sender` must be the buyer of the order.
   * @param orderId Index of the order to close.
   * @return true if the DataOrder was successfully closed, reverts otherwise.
   */
  function closeDataOrder(uint256 orderId) external returns (bool) {
    require(orderId < dataOrders.length, "invalid order index");
    DataOrder storage dataOrder = dataOrders[orderId];
    require(dataOrder.buyer == msg.sender, "sender can't close the order");
    require(dataOrder.closedAt == 0, "order already closed");
    dataOrder.closedAt = uint32(now);

    emit DataOrderClosed(orderId, msg.sender);
    return true;
  }

  function getNotaryUrl(address notaryAddress) external view returns (string memory) {
    return notaryUrls[notaryAddress];
  }

  function getDataOrder(uint256 orderId) external view returns (
    address,
    string memory,
    uint256,
    string memory,
    bytes32,
    string memory,
    uint32,
    uint32
  ) {
    DataOrder storage dataOrder = dataOrders[orderId];
    return (
      dataOrder.buyer,
      dataOrder.audience,
      dataOrder.price,
      dataOrder.requestedData,
      dataOrder.termsAndConditionsHash,
      dataOrder.buyerUrl,
      dataOrder.createdAt,
      dataOrder.closedAt
    );
  }

  function getDataOrdersLength() external view returns (uint) {
    return dataOrders.length;
  }

  function _isSenderNotary() private view returns (bool) {
    return _isNotEmpty(notaryUrls[msg.sender]);
  }

  function _isNotEmpty(string memory s) private pure returns (bool) {
    return bytes(s).length > 0;
  }
}
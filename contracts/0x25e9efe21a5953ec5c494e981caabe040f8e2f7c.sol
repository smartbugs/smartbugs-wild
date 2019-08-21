pragma solidity 0.4.23;

// File: /home/chris/Projects/token-sale-crypto-api/smart-contracts/node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

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
  function Ownable() public {
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

// File: contracts/ExchangeRate.sol

/// @title  ExchangeRate
/// @author Jose Perez - <jose.perez@diginex.com>
/// @notice Tamper-proof record of exchange rates e.g. BTC/USD, ETC/USD, etc.
/// @dev    Exchange rates are updated from off-chain server periodically. Rates are taken from a
//          publicly available third-party provider, such as Coinbase, CoinMarketCap, etc.
contract ExchangeRate is Ownable {
    event RateUpdated(string id, uint256 rate);
    event UpdaterTransferred(address indexed previousUpdater, address indexed newUpdater);

    address public updater;

    mapping(string => uint256) internal currentRates;

    /// @dev The ExchangeRate constructor.
    /// @param _updater Account which can update the rates.
    constructor(address _updater) public {
        require(_updater != address(0));
        updater = _updater;
    }

    /// @dev Throws if called by any account other than the updater.
    modifier onlyUpdater() {
        require(msg.sender == updater);
        _;
    }

    /// @dev Allows the current owner to change the updater.
    /// @param _newUpdater The address of the new updater.
    function transferUpdater(address _newUpdater) external onlyOwner {
        require(_newUpdater != address(0));
        emit UpdaterTransferred(updater, _newUpdater);
        updater = _newUpdater;
    }

    /// @dev Allows the current updater account to update a single rate.
    /// @param _id The rate identifier.
    /// @param _rate The exchange rate.
    function updateRate(string _id, uint256 _rate) external onlyUpdater {
        require(_rate != 0);
        currentRates[_id] = _rate;
        emit RateUpdated(_id, _rate);
    }

    /// @dev Allows anyone to read the current rate.
    /// @param _id The rate identifier.
    /// @return The current rate.
    function getRate(string _id) external view returns(uint256) {
        return currentRates[_id];
    }
}
pragma solidity 0.4.18;

// File: node_modules/zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol

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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/FxRates.sol

/**
 * @title FxRates
 * @dev Store the historic fx rates for conversion ETHEUR and BTCEUR
 */
contract FxRates is Ownable {
    using SafeMath for uint256;

    struct Rate {
        string rate;
        string timestamp;
    }

    /**
     * @dev Event for logging an update of the exchange rates
     * @param symbol one of ["ETH", "BTC"]
     * @param updateNumber an incremental number giving the number of update
     * @param timestamp human readable timestamp of the earliest validity time
     * @param rate a string containing the rate value
     */
    event RateUpdate(string symbol, uint256 updateNumber, string timestamp, string rate);

    uint256 public numberBtcUpdates = 0;

    mapping(uint256 => Rate) public btcUpdates;

    uint256 public numberEthUpdates = 0;

    mapping(uint256 => Rate) public ethUpdates;

    /**
     * @dev Adds the latest Ether Euro rate to the history. Only the crontract owner can execute this.
     * @param _rate the exchange rate
     * @param _timestamp human readable earliest point in time where the rate is valid
     */
    function updateEthRate(string _rate, string _timestamp) public onlyOwner {
        numberEthUpdates = numberEthUpdates.add(1);
        ethUpdates[numberEthUpdates] = Rate({
            rate: _rate,
            timestamp: _timestamp
        });
        RateUpdate("ETH", numberEthUpdates, _timestamp, _rate);
    }

    /**
     * @dev Adds the latest Btc Euro rate to the history. . Only the crontract owner can execute this.
     * @param _rate the exchange rate
     * @param _timestamp human readable earliest point in time where the rate is valid
     */
    function updateBtcRate(string _rate, string _timestamp) public onlyOwner {
        numberBtcUpdates = numberBtcUpdates.add(1);
        btcUpdates[numberBtcUpdates] = Rate({
            rate: _rate,
            timestamp: _timestamp
        });
        RateUpdate("BTC", numberBtcUpdates, _timestamp, _rate);
    }

    /**
     * @dev Gets the latest Eth Euro rate
     * @return a tuple containing the rate and the timestamp in human readable format
     */
    function getEthRate() public view returns(Rate) {
        /* require(numberEthUpdates > 0); */
        return ethUpdates[numberEthUpdates];
            /* ethUpdates[numberEthUpdates].rate, */
            /* ethUpdates[numberEthUpdates].timestamp */
        /* ); */
    }

    /**
     * @dev Gets the latest Btc Euro rate
     * @return a tuple containing the rate and the timestamp in human readable format
     */
    function getBtcRate() public view returns(string, string) {
        /* require(numberBtcUpdates > 0); */
        return (
            btcUpdates[numberBtcUpdates].rate,
            btcUpdates[numberBtcUpdates].timestamp
        );
    }

    /**
     * @dev Gets the historic Eth Euro rate
     * @param _updateNumber the number of the update the rate corresponds to.
     * @return a tuple containing the rate and the timestamp in human readable format
     */
    function getHistEthRate(uint256 _updateNumber) public view returns(string, string) {
        require(_updateNumber <= numberEthUpdates);
        return (
            ethUpdates[_updateNumber].rate,
            ethUpdates[_updateNumber].timestamp
        );
    }

    /**
     * @dev Gets the historic Btc Euro rate
     * @param _updateNumber the number of the update the rate corresponds to.
     * @return a tuple containing the rate and the timestamp in human readable format
     */
    function getHistBtcRate(uint256 _updateNumber) public view returns(string, string) {
        require(_updateNumber <= numberBtcUpdates);
        return (
            btcUpdates[_updateNumber].rate,
            btcUpdates[_updateNumber].timestamp
        );
    }
}
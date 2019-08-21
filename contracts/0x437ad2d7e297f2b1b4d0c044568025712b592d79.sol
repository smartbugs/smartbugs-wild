pragma solidity ^0.4.23;


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



contract ExchangeOracle is Ownable {

    using SafeMath for uint256;

    uint256 public rate;
    uint256 public lastRate;
    uint256 public rateMultiplier = 1000;
    uint256 public usdMultiplier = 100;
    address public admin;

    event RateChanged(uint256 _oldRate, uint256 _newRate);
    event RateMultiplierChanged(uint256 _oldRateMultiplier, uint256 _newRateMultiplier);
    event USDMultiplierChanged(uint256 _oldUSDMultiplier, uint256 _newUSDMultiplier);
    event AdminChanged(address _oldAdmin, address _newAdmin);

    constructor(address _initialAdmin, uint256 _initialRate) public {
        require(_initialAdmin != address(0), "Invalid initial admin address");
        require(_initialRate > 0, "Invalid initial rate value");

        admin = _initialAdmin;
        rate = _initialRate;
        lastRate = _initialRate;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not allowed to execute");
        _;
    }

    /*
     * The new rate has to be passed in format:
     *      250.567 rate = 250 567 passed rate ( 1 ether = 250.567 USD )
     *      100 rate = 100 000 passed rate ( 1 ether = 100 USD )
     *      1 rate = 1 000 passed rate ( 1 ether = 1 USD )
     *      0.01 rate = 10 passed rate ( 100 ethers = 1 USD )
     */
    function setRate(uint256 _newRate) public onlyAdmin {
        require(_newRate > 0, "Invalid rate value");

        lastRate = rate;
        rate = _newRate;

        emit RateChanged(lastRate, _newRate);
    }

    /*
     * By default rateMultiplier = 1000.
     * With rate multiplier we can set the rate to be a float number.
     *
     * We use it as a multiplier because we can not pass float numbers in Ethereum.
     * If the USD price becomes bigger than ether one, for example -> 1 USD = 10 ethers.
     * We will pass 100 as rate and this will be relevant to 0.1 USD = 1 ether.
     */
    function setRateMultiplier(uint256 _newRateMultiplier) public onlyAdmin {
        require(_newRateMultiplier > 0, "Invalid rate multiplier value");

        uint256 oldRateMultiplier = rateMultiplier;
        rateMultiplier = _newRateMultiplier;

        emit RateMultiplierChanged(oldRateMultiplier, _newRateMultiplier);
    }

    /*
     * By default usdMultiplier is = 100.
     * With usd multiplier we can set the usd amount to be a float number.
     *
     * We use it as a multiplier because we can not pass float numbers in Ethereum.
     * We will pass 100 as usd amount and this will be relevant to 1 USD.
     */
    function setUSDMultiplier(uint256 _newUSDMultiplier) public onlyAdmin {
        require(_newUSDMultiplier > 0, "Invalid USD multiplier value");

        uint256 oldUSDMultiplier = usdMultiplier;
        usdMultiplier = _newUSDMultiplier;

        emit USDMultiplierChanged(oldUSDMultiplier, _newUSDMultiplier);
    }

    /*
     * Set address with admin rights, allowed to execute:
     *    - setRate()
     *    - setRateMultiplier()
     *    - setUSDMultiplier()
     */
    function setAdmin(address _newAdmin) public onlyOwner {
        require(_newAdmin != address(0), "Invalid admin address");

        address oldAdmin = admin;
        admin = _newAdmin;

        emit AdminChanged(oldAdmin, _newAdmin);
    }

}


contract TokenExchangeOracle is ExchangeOracle {

    constructor(address _admin, uint256 _initialRate) ExchangeOracle(_admin, _initialRate) public {}

    /*
     * Converts the specified USD amount in tokens (usdAmount is multiplied by
     * corresponding usdMultiplier value, which by default is 100).
     */
    function convertUSDToTokens(uint256 _usdAmount) public view returns (uint256) {
        return usdToTokens(_usdAmount, rate);
    }

    /*
     * Converts the specified USD amount in tokens (usdAmount is multiplied by
     * corresponding usdMultiplier value, which by default is 100) using the
     * lastRate value for the calculation.
     */
    function convertUSDToTokensByLastRate(uint256 _usdAmount) public view returns (uint256) {
        return usdToTokens(_usdAmount, lastRate);
    }

    /*
     * Converts the specified USD amount in tokens.
     *
     * Example:
     *    Token/USD -> 298.758
     *    convert -> 39.99 USD
     *
     *               usdAmount     rateMultiplier
     *    tokens = ------------- * -------------- * ONE_ETHER_IN_WEI
     *             usdMultiplier        rate
     *
     */
    function usdToTokens(uint256 _usdAmount, uint256 _rate) internal view returns (uint256) {
        require(_usdAmount > 0, "Invalid USD amount");

        uint256 tokens = _usdAmount.mul(rateMultiplier);
        tokens = tokens.mul(1 ether);
        tokens = tokens.div(usdMultiplier);
        tokens = tokens.div(_rate);

        return tokens;
    }

    /*
     * Converts the specified tokens amount in USD. The returned value is multiplied
     * by the usdMultiplier value, which is by default 100.
     */
    function convertTokensToUSD(uint256 _tokens) public view returns (uint256) {
        return tokensToUSD(_tokens, rate);
    }

    /*
     * Converts the specified tokens amount in USD, using the lastRate value for the
     * calculation. The returned value is multiplied by the usdMultiplier value,
     * which is by default 100.
     */
    function convertTokensToUSDByLastRate(uint256 _tokens) public view returns (uint256) {
        return tokensToUSD(_tokens, lastRate);
    }

    /*
     * Converts the specified tokens amount in USD.
     *
     *                     tokens             rate
     *    usdAmount = ---------------- * -------------- * usdMultiplier
     *                ONE_ETHER_IN_WEI   rateMultiplier
     *
     */
    function tokensToUSD(uint256 _tokens, uint256 _rate) internal view returns (uint256) {
        require(_tokens > 0, "Invalid token amount");

        uint256 usdAmount = _tokens.mul(_rate);
        usdAmount = usdAmount.mul(usdMultiplier);
        usdAmount = usdAmount.div(rateMultiplier);
        usdAmount = usdAmount.div(1 ether);

        return usdAmount;
    }

}
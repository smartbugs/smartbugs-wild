pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
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
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title VeloxCrowdsale
 * @dev VeloxToken ERC20 token crowdsale contract
 */
contract VeloxCrowdsale is Ownable {
    using SafeMath for uint256;

    // The token being sold
    ERC20 public token;

    // Crowdsale start and end timestamps
    uint256 public startTime;
    uint256 public endTime;

    // Price per smallest token unit in wei
    uint256 public rate;

    // Crowdsale cap in tokens
    uint256 public cap;

    // Address where ETH and unsold tokens are collected
    address public wallet;

    // Amount of tokens sold
    uint256 public sold;

    /**
     * @dev Constructor to set instance variables
     */
    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        uint256 _cap,
        address _wallet,
        ERC20 _token
    ) public {
        require(_startTime >= block.timestamp && _endTime >= _startTime);
        require(_rate > 0);
        require(_cap > 0);
        require(_wallet != address(0));
        require(_token != address(0));

        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        cap = _cap;
        wallet = _wallet;
        token = _token;
    }

    /**
     * @dev Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
    * @dev Fallback token purchase function
    */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
     * @dev Token purchase function
     * @param _beneficiary Address receiving the purchased tokens
     */
    function buyTokens(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;
        require(_beneficiary != address(0));
        require(weiAmount != 0);
        require(block.timestamp >= startTime && block.timestamp <= endTime);
        uint256 tokens = weiAmount.div(rate);
        require(tokens != 0 && sold.add(tokens) <= cap);
        sold = sold.add(tokens);
        require(token.transfer(_beneficiary, tokens));
        emit TokenPurchase(
            msg.sender,
            _beneficiary,
            weiAmount,
            tokens
        );
    }

    /**
    * @dev Checks whether the cap has been reached.
    * @return Whether the cap was reached
    */
    function capReached() public view returns (bool) {
        return sold >= cap;
    }

    /**
     * @dev Boolean to protect from replaying the finalization function
     */
    bool public isFinalized = false;

    /**
     * @dev Event for crowdsale finalization (forwarding)
     */
    event Finalized();

    /**
     * @dev Must be called after crowdsale ends to forward all funds
     */
    function finalize() external onlyOwner {
        require(!isFinalized);
        require(block.timestamp > endTime || sold >= cap);
        token.transfer(wallet, token.balanceOf(this));
        wallet.transfer(address(this).balance);
        emit Finalized();
        isFinalized = true;
    }

    /**
     * @dev Function for owner to forward ETH from contract
     */
    function forwardFunds() external onlyOwner {
        require(!isFinalized);
        require(block.timestamp > startTime);
        uint256 balance = address(this).balance;
        require(balance > 0);
        wallet.transfer(balance);
    }
}
pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

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
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: contracts/luckybox/LuckyBox.sol

contract LuckyBox is Pausable {
    using SafeMath for *;

    uint256 public goldBoxAmountForSale;
    uint256 public silverBoxAmountForSale;

    uint256 public goldBoxPrice;    // amount of eth for each gold bag.
    uint256 public silverBoxPrice;

    address public wallet;

    mapping (address => uint256) public goldSalesRecord;
    mapping (address => uint256) public silverSalesRecord;

    uint256 public goldSaleLimit;
    uint256 public silverSaleLimit;

    constructor(address _wallet, uint256 _goldBoxAmountForSale, uint256 _silverBoxAmountForSale) public
    {
        require(_wallet != address(0), "need a good wallet to store fund");
        require(_goldBoxAmountForSale > 0, "Gold bag amount need to be no-zero");
        require(_silverBoxAmountForSale > 0, "Silver bag amount need to be no-zero");

        wallet = _wallet;
        goldBoxAmountForSale = _goldBoxAmountForSale;
        silverBoxAmountForSale = _silverBoxAmountForSale;

        goldSaleLimit = 10;
        silverSaleLimit = 100;
    }

    function buyBoxs(address _buyer, uint256 _goldBoxAmount, uint256 _silverBoxAmount) payable public whenNotPaused {
        require(_buyer != address(0));
        require(_goldBoxAmount <= goldBoxAmountForSale && _silverBoxAmount <= silverBoxAmountForSale);
        require(goldSalesRecord[_buyer] + _goldBoxAmount <= goldSaleLimit);
        require(silverSalesRecord[_buyer] + _silverBoxAmount <= silverSaleLimit);

        uint256 charge = _goldBoxAmount.mul(goldBoxPrice).add(_silverBoxAmount.mul(silverBoxPrice));
        require(msg.value >= charge, "No enough ether for buying lucky bags.");
        require(_goldBoxAmount > 0 || _silverBoxAmount > 0);

        if (_goldBoxAmount > 0)
        {
            goldBoxAmountForSale = goldBoxAmountForSale.sub(_goldBoxAmount);
            goldSalesRecord[_buyer] += _goldBoxAmount;
            emit GoldBoxSale(_buyer, _goldBoxAmount, goldBoxPrice);
        }

        if (_silverBoxAmount > 0)
        {
            silverBoxAmountForSale = silverBoxAmountForSale.sub(_silverBoxAmount);
            silverSalesRecord[_buyer] += _silverBoxAmount;
            emit SilverBoxSale(_buyer, _silverBoxAmount, silverBoxPrice);
        }

        wallet.transfer(charge);

        if (msg.value > charge)
        {
            uint256 weiToRefund = msg.value.sub(charge);
            _buyer.transfer(weiToRefund);
            emit EthRefunded(_buyer, weiToRefund);
        }
    }

    function buyBoxs(uint256 _goldBoxAmount, uint256 _silverBoxAmount) payable public whenNotPaused {
        buyBoxs(msg.sender, _goldBoxAmount, _silverBoxAmount);
    }

    function updateGoldBoxAmountAndPrice(uint256 _goldBoxAmountForSale, uint256 _goldBoxPrice, uint256 _goldLimit) public onlyOwner {
        goldBoxAmountForSale = _goldBoxAmountForSale;
        goldBoxPrice = _goldBoxPrice;
        goldSaleLimit = _goldLimit;
    }

    function updateSilverBoxAmountAndPrice(uint256 _silverBoxAmountForSale, uint256 _silverBoxPrice, uint256 _silverLimit) public onlyOwner {
        silverBoxAmountForSale = _silverBoxAmountForSale;
        silverBoxPrice = _silverBoxPrice;
        silverSaleLimit = _silverLimit;
    }


//////////
// Safety Methods
//////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) onlyOwner public {
      if (_token == 0x0) {
          owner.transfer(address(this).balance);
          return;
      }

      ERC20 token = ERC20(_token);
      uint balance = token.balanceOf(this);
      token.transfer(owner, balance);

      emit ClaimedTokens(_token, owner, balance);
    }


    event GoldBoxSale(address indexed _user, uint256 _amount, uint256 _price);
    
    event SilverBoxSale(address indexed _user, uint256 _amount, uint256 _price);

    event EthRefunded(address indexed buyer, uint256 value);

    event ClaimedTokens(address indexed _token, address indexed _to, uint _amount);

}
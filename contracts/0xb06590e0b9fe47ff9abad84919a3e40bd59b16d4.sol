// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
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

contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

contract AmmuNationStore is Claimable{

    using SafeMath for uint256;

    GTAInterface public token;

    uint256 private tokenSellPrice; //wei
    uint256 private tokenBuyPrice; //wei
    uint256 public buyDiscount; //%

    event Buy(address buyer, uint256 amount, uint256 payed);
    event Robbery(address robber);

    constructor (address _tokenAddress) public {
        token = GTAInterface(_tokenAddress);
    }

    /** Owner's operations to fill and empty the stock */

    // Important! remember to call GoldenThalerToken(address).approve(this, amount)
    // or this contract will not be able to do the transfer on your behalf.
    function depositGTA(uint256 amount) onlyOwner public {
        require(token.transferFrom(msg.sender, this, amount), "Insufficient funds");
    }

    function withdrawGTA(uint256 amount) onlyOwner public {
        require(token.transfer(msg.sender, amount), "Amount exceeds the available balance");
    }

    function robCashier() onlyOwner public {
        msg.sender.transfer(address(this).balance);
        emit Robbery(msg.sender);
    }

    /** */

    /**
   * @dev Set the prices in wei for 1 GTA
   * @param _newSellPrice The price people can sell GTA for
   * @param _newBuyPrice The price people can buy GTA for
   */
    function setTokenPrices(uint256 _newSellPrice, uint256 _newBuyPrice) onlyOwner public {
        tokenSellPrice = _newSellPrice;
        tokenBuyPrice = _newBuyPrice;
    }


    function buy() payable public returns (uint256){
        //note: the price of 1 GTA is in wei, but the token transfer expects the amount in 'token wei'
        //so we're missing 10*18
        uint256 value = msg.value.mul(1 ether);
        uint256 _buyPrice = tokenBuyPrice;
        if (buyDiscount > 0) {
            //happy discount!
            _buyPrice = _buyPrice.sub(_buyPrice.mul(buyDiscount).div(100));
        }
        uint256 amount = value.div(_buyPrice);
        require(token.balanceOf(this) >= amount, "Sold out");
        require(token.transfer(msg.sender, amount), "Couldn't transfer token");
        emit Buy(msg.sender, amount, msg.value);
        return amount;
    }

    // Important! remember to call GoldenThalerToken(address).approve(this, amount)
    // or this contract will not be able to do the transfer on your behalf.
    //TODO No sell at this moment
    /*function sell(uint256 amount) public returns (uint256){
        require(token.balanceOf(msg.sender) >= amount, "Insufficient funds");
        require(token.transferFrom(msg.sender, this, amount), "Couldn't transfer token");
        uint256 revenue = amount.mul(tokenSellPrice).div(1 ether);
        msg.sender.transfer(revenue);
        return revenue;
    }*/

    function applyDiscount(uint256 discount) onlyOwner public {
        buyDiscount = discount;
    }

    function getTokenBuyPrice() public view returns (uint256) {
        uint256 _buyPrice = tokenBuyPrice;
        if (buyDiscount > 0) {
            _buyPrice = _buyPrice.sub(_buyPrice.mul(buyDiscount).div(100));
        }
        return _buyPrice;
    }

    function getTokenSellPrice() public view returns (uint256) {
        return tokenSellPrice;
    }
}

/**
 * @title GTA contract interface
 */
interface GTAInterface {

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address _owner) external view returns (uint256);

}
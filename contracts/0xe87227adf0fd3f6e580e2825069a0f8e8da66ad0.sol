pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: contracts/interfaces/IAccessToken.sol

interface IAccessToken {
  function lockBBK(
    uint256 _value
  )
    external
    returns (bool);

  function unlockBBK(
    uint256 _value
  )
    external
    returns (bool);

  function transfer(
    address _to,
    uint256 _value
  )
    external
    returns (bool);

  function distribute(
    uint256 _amount
  )
    external
    returns (bool);

  function burn(
    address _address,
    uint256 _value
  )
    external
    returns (bool);
}

// File: contracts/interfaces/IRegistry.sol

// limited ContractRegistry definition
interface IRegistry {
  function owner()
    external
    returns(address);

  function updateContractAddress(
    string _name,
    address _address
  )
    external
    returns (address);

  function getContractAddress(
    string _name
  )
    external
    view
    returns (address);
}

// File: contracts/FeeManager.sol

contract FeeManager {
  using SafeMath for uint256;

  uint8 public constant version = 1;
  uint256 actRate = 1000;

  IRegistry private registry;
  constructor(
    address _registryAddress
  )
    public
  {
    require(_registryAddress != address(0));
    registry = IRegistry(_registryAddress);
  }

  function weiToAct(uint256 _wei)
    public
    view
    returns (uint256)
  {

    return _wei.mul(actRate);
  }

  function actToWei(uint256 _act)
    public
    view
    returns (uint256)
  {
    return _act.div(actRate);
  }

  function payFee()
    public
    payable
    returns (bool)
  {
    IAccessToken act = IAccessToken(
      registry.getContractAddress("AccessToken")
    );
    require(act.distribute(weiToAct(msg.value)));
    return true;
  }

  function claimFee(
    uint256 _value
  )
    public
    returns (bool)
  {
    IAccessToken act = IAccessToken(
      registry.getContractAddress("AccessToken")
    );
    require(act.burn(msg.sender, _value));
    msg.sender.transfer(actToWei(_value));
    return true;
  }
}
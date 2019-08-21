pragma solidity ^0.4.24;

/**
 * Changes by https://www.docademic.com/
 */

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
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * Changes by https://www.docademic.com/
 */

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

contract Destroyable is Ownable{
    /**
     * @notice Allows to destroy the contract and return the tokens to the owner.
     */
    function destroy() public onlyOwner{
        selfdestruct(owner);
    }
}

interface Token {
    function transfer(address _to, uint256 _value) external returns (bool);
    function balanceOf(address who) view external returns (uint256);
}

contract MTCMultiTransfer is Ownable, Destroyable {
    using SafeMath for uint256;

    event Dropped(uint256 transfers, uint256 amount);

    Token public token;
    uint256 public totalDropped;

    constructor(address _token) public{
        require(_token != address(0));
        token = Token(_token);
        totalDropped = 0;
    }

    function airdropTokens(address[] _recipients, uint256[] _balances) public
    onlyOwner {
        require(_recipients.length == _balances.length);

        uint airDropped = 0;
        for (uint256 i = 0; i < _recipients.length; i++)
        {
            require(token.transfer(_recipients[i], _balances[i]));
            airDropped = airDropped.add(_balances[i]);
        }

        totalDropped = totalDropped.add(airDropped);
        emit Dropped(_recipients.length, airDropped);
    }

    /**
     * @dev Get the remain MTC on the contract.
     */
    function Balance() view public returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
         * @notice Allows the owner to flush the eth.
         */
    function flushEth() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    /**
     * @notice Allows the owner to destroy the contract and return the tokens to the owner.
     */
    function destroy() public onlyOwner {
        token.transfer(owner, token.balanceOf(this));
        selfdestruct(owner);
    }

}
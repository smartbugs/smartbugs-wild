pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/token/ERC20/Storage.sol

/**
 * MIT License
 *
 * Copyright (c) 2019 eToroX Labs
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

pragma solidity 0.4.24;



/**
 * @title External ERC20 Storage
 *
 * @dev The storage contract used in ExternalERC20 token. This contract can
 * provide storage for exactly one contract, referred to as the implementor,
 * inheriting from the ExternalERC20 contract. Only the current implementor or
 * the owner can transfer the implementorship. Change of state is only allowed
 * by the implementor.
 */
contract Storage is Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    uint256 private totalSupply;

    address private _implementor;

    event StorageImplementorTransferred(address indexed from,
                                        address indexed to);

    /**
     * @dev Contructor.
     * @param owner The address of the owner of the contract.
     * Must not be the zero address.
     * @param implementor The address of the contract that is
     * allowed to change state. Must not be the zero address.
     */
    constructor(address owner, address implementor) public {

        require(
            owner != address(0),
            "Owner should not be the zero address"
        );

        require(
            implementor != address(0),
            "Implementor should not be the zero address"
        );

        transferOwnership(owner);
        _implementor = implementor;
    }

    /**
     * @dev Return whether the sender is an implementor.
     */
    function isImplementor() public view returns(bool) {
        return msg.sender == _implementor;
    }

    /**
     * @dev Sets new balance.
     * Can only be done by owner or implementor contract.
     */
    function setBalance(address owner,
                        uint256 value)
        public
        onlyImplementor
    {
        balances[owner] = value;
    }

    /**
     * @dev Increases the balances relatively
     * @param owner the address for which to increase balance
     * @param addedValue the value to increase with
     */
    function increaseBalance(address owner, uint256 addedValue)
        public
        onlyImplementor
    {
        balances[owner] = balances[owner].add(addedValue);
    }

    /**
     * @dev Decreases the balances relatively
     * @param owner the address for which to decrease balance
     * @param subtractedValue the value to decrease with
     */
    function decreaseBalance(address owner, uint256 subtractedValue)
        public
        onlyImplementor
    {
        balances[owner] = balances[owner].sub(subtractedValue);
    }

    /**
     * @dev Can only be done by owner or implementor contract.
     * @return The current balance of owner
     */
    function getBalance(address owner)
        public
        view
        returns (uint256)
    {
        return balances[owner];
    }

    /**
     * @dev Sets new allowance.
     * Can only be called by implementor contract.
     */
    function setAllowed(address owner,
                        address spender,
                        uint256 value)
        public
        onlyImplementor
    {
        allowed[owner][spender] = value;
    }

    /**
     * @dev Increases the allowance relatively
     * @param owner the address for which to allow from
     * @param spender the addres for which the allowance increase is granted
     * @param addedValue the value to increase with
     */
    function increaseAllowed(
        address owner,
        address spender,
        uint256 addedValue
    )
        public
        onlyImplementor
    {
        allowed[owner][spender] = allowed[owner][spender].add(addedValue);
    }

    /**
     * @dev Decreases the allowance relatively
     * @param owner the address for which to allow from
     * @param spender the addres for which the allowance decrease is granted
     * @param subtractedValue the value to decrease with
     */
    function decreaseAllowed(
        address owner,
        address spender,
        uint256 subtractedValue
    )
        public
        onlyImplementor
    {
        allowed[owner][spender] = allowed[owner][spender].sub(subtractedValue);
    }

    /**
     * @dev Can only be called by implementor contract.
     * @return The current allowance for spender from owner
     */
    function getAllowed(address owner,
                        address spender)
        public
        view
        returns (uint256)
    {
        return allowed[owner][spender];
    }

    /**
     * @dev Change totalSupply.
     * Can only be called by implementor contract.
     */
    function setTotalSupply(uint256 value)
        public
        onlyImplementor
    {
        totalSupply = value;
    }

    /**
     * @dev Can only be called by implementor contract.
     * @return Current supply
     */
    function getTotalSupply()
        public
        view
        returns (uint256)
    {
        return totalSupply;
    }

    /**
     * @dev Transfer implementor to new contract
     * Can only be called by owner or implementor contract.
     */
    function transferImplementor(address newImplementor)
        public
        requireNonZero(newImplementor)
        onlyImplementorOrOwner
    {
        require(newImplementor != _implementor,
                "Cannot transfer to same implementor as existing");
        address curImplementor = _implementor;
        _implementor = newImplementor;
        emit StorageImplementorTransferred(curImplementor, newImplementor);
    }

    /**
     * @dev Asserts that sender is either owner or implementor.
     */
    modifier onlyImplementorOrOwner() {
        require(isImplementor() || isOwner(), "Is not implementor or owner");
        _;
    }

    /**
     * @dev Asserts that sender is the implementor.
     */
    modifier onlyImplementor() {
        require(isImplementor(), "Is not implementor");
        _;
    }

    /**
     * @dev Asserts that the given address is not the null-address
     */
    modifier requireNonZero(address addr) {
        require(addr != address(0), "Expected a non-zero address");
        _;
    }
}
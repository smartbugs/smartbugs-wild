pragma solidity ^0.4.24;

// File: contracts/token/IETokenProxy.sol

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
 * @title Interface of an upgradable token
 * @dev See implementation for
 */
interface IETokenProxy {

    /* solium-disable zeppelin/missing-natspec-comments */

    /* Taken from ERC20Detailed in openzeppelin-solidity */
    function nameProxy(address sender) external view returns(string);

    function symbolProxy(address sender)
        external
        view
        returns(string);

    function decimalsProxy(address sender)
        external
        view
        returns(uint8);

    /* Taken from IERC20 in openzeppelin-solidity */
    function totalSupplyProxy(address sender)
        external
        view
        returns (uint256);

    function balanceOfProxy(address sender, address who)
        external
        view
        returns (uint256);

    function allowanceProxy(address sender,
                            address owner,
                            address spender)
        external
        view
        returns (uint256);

    function transferProxy(address sender, address to, uint256 value)
        external
        returns (bool);

    function approveProxy(address sender,
                          address spender,
                          uint256 value)
        external
        returns (bool);

    function transferFromProxy(address sender,
                               address from,
                               address to,
                               uint256 value)
        external
        returns (bool);

    function mintProxy(address sender, address to, uint256 value)
        external
        returns (bool);

    function changeMintingRecipientProxy(address sender,
                                         address mintingRecip)
        external;

    function burnProxy(address sender, uint256 value) external;

    function burnFromProxy(address sender,
                           address from,
                           uint256 value)
        external;

    function increaseAllowanceProxy(address sender,
                                    address spender,
                                    uint addedValue)
        external
        returns (bool success);

    function decreaseAllowanceProxy(address sender,
                                    address spender,
                                    uint subtractedValue)
        external
        returns (bool success);

    function pauseProxy(address sender) external;

    function unpauseProxy(address sender) external;

    function pausedProxy(address sender) external view returns (bool);

    function finalizeUpgrade() external;
}

// File: contracts/token/IEToken.sol

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
 * @title EToken interface
 * @dev The interface comprising an EToken contract
 * This interface is a superset of the ERC20 interface defined at
 * https://github.com/ethereum/EIPs/issues/20
 */
interface IEToken {

    /* solium-disable zeppelin/missing-natspec-comments */

    function upgrade(IETokenProxy upgradedToken) external;

    /* Taken from ERC20Detailed in openzeppelin-solidity */
    function name() external view returns(string);

    function symbol() external view returns(string);

    function decimals() external view returns(uint8);

    /* Taken from IERC20 in openzeppelin-solidity */
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
        external
        returns (bool);

    function transferFrom(address from, address to, uint256 value)
        external
        returns (bool);

    /* Taken from ERC20Mintable */
    function mint(address to, uint256 value) external returns (bool);

    /* Taken from ERC20Burnable */
    function burn(uint256 value) external;

    function burnFrom(address from, uint256 value) external;

    /* Taken from ERC20Pausable */
    function increaseAllowance(
        address spender,
        uint addedValue
    )
        external
        returns (bool success);

    function pause() external;

    function unpause() external;

    function paused() external view returns (bool);

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
        external
        returns (bool success);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}

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

// File: contracts/token/ERC20/ERC20.sol

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
 * @title Internal implementation of ERC20 functionality with support
 * for a separate storage contract
 */
contract ERC20 {
    using SafeMath for uint256;

    Storage private externalStorage;

    string private name_;
    string private symbol_;
    uint8 private decimals_;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Constructor
     * @param name The ERC20 detailed token name
     * @param symbol The ERC20 detailed symbol name
     * @param decimals Determines the number of decimals of this token
     * @param _externalStorage The external storage contract.
     * Should be zero address if shouldCreateStorage is true.
     * @param initialDeployment Defines whether it should
     * create a new external storage. Should be false if
     * externalERC20Storage is defined.
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Storage _externalStorage,
        bool initialDeployment
    )
        public
    {

        require(
            (_externalStorage != address(0) && (!initialDeployment)) ||
            (_externalStorage == address(0) && initialDeployment),
            "Cannot both create external storage and use the provided one.");

        name_ = name;
        symbol_ = symbol;
        decimals_ = decimals;

        if (initialDeployment) {
            externalStorage = new Storage(msg.sender, this);
        } else {
            externalStorage = _externalStorage;
        }
    }

    /**
     * @return The storage used by this contract
     */
    function getExternalStorage() public view returns(Storage) {
        return externalStorage;
    }

    /**
     * @return the name of the token.
     */
    function _name() internal view returns(string) {
        return name_;
    }

    /**
     * @return the symbol of the token.
     */
    function _symbol() internal view returns(string) {
        return symbol_;
    }

    /**
     * @return the number of decimals of the token.
     */
    function _decimals() internal view returns(uint8) {
        return decimals_;
    }

    /**
     * @dev Total number of tokens in existence
     */
    function _totalSupply() internal view returns (uint256) {
        return externalStorage.getTotalSupply();
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function _balanceOf(address owner) internal view returns (uint256) {
        return externalStorage.getBalance(owner);
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function _allowance(address owner, address spender)
        internal
        view
        returns (uint256)
    {
        return externalStorage.getAllowed(owner, spender);
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param originSender The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address originSender, address to, uint256 value)
        internal
        returns (bool)
    {
        require(to != address(0));

        externalStorage.decreaseBalance(originSender, value);
        externalStorage.increaseBalance(to, value);

        emit Transfer(originSender, to, value);

        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount
     * of tokens on behalf of msg.sender.  Beware that changing an
     * allowance with this method brings the risk that someone may use
     * both the old and the new allowance by unfortunate transaction
     * ordering. One possible solution to mitigate this race condition
     * is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param originSender the original transaction sender
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function _approve(address originSender, address spender, uint256 value)
        internal
        returns (bool)
    {
        require(spender != address(0));

        externalStorage.setAllowed(originSender, spender, value);
        emit Approval(originSender, spender, value);

        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param originSender the original transaction sender
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function _transferFrom(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        internal
        returns (bool)
    {

        externalStorage.decreaseAllowed(from, originSender, value);

        _transfer(from, to, value);

        emit Approval(
            from,
            originSender,
            externalStorage.getAllowed(from, originSender)
        );

        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param originSender the original transaction sender
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function _increaseAllowance(
        address originSender,
        address spender,
        uint256 addedValue
    )
        internal
        returns (bool)
    {
        require(spender != address(0));

        externalStorage.increaseAllowed(originSender, spender, addedValue);

        emit Approval(
            originSender, spender,
            externalStorage.getAllowed(originSender, spender)
        );

        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a
     * spender.  approve should be called when allowed_[_spender] ==
     * 0. To decrement allowed value is better to use this function to
     * avoid 2 calls (and wait until the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param originSender the original transaction sender
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function _decreaseAllowance(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        internal
        returns (bool)
    {
        require(spender != address(0));

        externalStorage.decreaseAllowed(originSender,
                                        spender,
                                        subtractedValue);

        emit Approval(
            originSender, spender,
            externalStorage.getAllowed(originSender, spender)
        );

        return true;
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal returns (bool)
    {
        require(account != 0);

        externalStorage.setTotalSupply(
            externalStorage.getTotalSupply().add(value));
        externalStorage.increaseBalance(account, value);

        emit Transfer(address(0), account, value);

        return true;
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param originSender The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address originSender, uint256 value) internal returns (bool)
    {
        require(originSender != 0);

        externalStorage.setTotalSupply(
            externalStorage.getTotalSupply().sub(value));
        externalStorage.decreaseBalance(originSender, value);

        emit Transfer(originSender, address(0), value);

        return true;
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param originSender the original transaction sender
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address originSender, address account, uint256 value)
        internal
        returns (bool)
    {
        require(value <= externalStorage.getAllowed(account, originSender));

        externalStorage.decreaseAllowed(account, originSender, value);
        _burn(account, value);

        emit Approval(account, originSender,
                      externalStorage.getAllowed(account, originSender));

        return true;
    }
}

// File: contracts/token/UpgradeSupport.sol

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
 * @title Functionality supporting contract upgradability
 */
contract UpgradeSupport is Ownable, ERC20 {

    event Upgraded(address indexed to);
    event UpgradeFinalized(address indexed upgradedFrom);

    /**
     * @dev Holds the address of the contract that was upgraded from
     */
    address private _upgradedFrom;
    bool private enabled;
    IETokenProxy private upgradedToken;

    /**
     * @dev Constructor
     * @param initialDeployment Set to true if this is the initial deployment of
     * the token. If true it automtically creates a new ExternalERC20Storage.
     * Also, it acts as a confirmation of intention which interlocks
     * upgradedFrom as follows: If initialDeployment is true, then
     * upgradedFrom must be the zero address. Otherwise, upgradedFrom must not
     * be the zero address. The same applies to externalERC20Storage, which must
     * be set to the zero address if initialDeployment is true.
     * @param upgradedFrom The token contract that this contract upgrades. Set
     * to address(0) for initial deployments
     */
    constructor(bool initialDeployment, address upgradedFrom) internal {
        require((upgradedFrom != address(0) && (!initialDeployment)) ||
                (upgradedFrom == address(0) && initialDeployment),
                "Cannot both be upgraded and initial deployment.");

        if (! initialDeployment) {
            // Pause until explicitly unpaused by upgraded contract
            enabled = false;
            _upgradedFrom = upgradedFrom;
        } else {
            enabled = true;
        }
    }

    modifier upgradeExists() {
        require(_upgradedFrom != address(0),
                "Must have a contract to upgrade from");
        _;
    }

    /**
     * @dev Called by the upgraded contract in order to mark the finalization of
     * the upgrade and activate the new contract
     */
    function finalizeUpgrade()
        external
        upgradeExists
        onlyProxy
    {
        enabled = true;
        emit UpgradeFinalized(msg.sender);
    }

    /**
     * Upgrades the current token
     * @param _upgradedToken The address of the token that this token
     * should be upgraded to
     */
    function upgrade(IETokenProxy _upgradedToken) public onlyOwner {
        require(!isUpgraded(), "Token is already upgraded");
        require(_upgradedToken != IETokenProxy(0),
                "Cannot upgrade to null address");
        require(_upgradedToken != IETokenProxy(this),
                "Cannot upgrade to myself");
        require(getExternalStorage().isImplementor(),
                "I don't own my storage. This will end badly.");

        upgradedToken = _upgradedToken;
        getExternalStorage().transferImplementor(_upgradedToken);
        _upgradedToken.finalizeUpgrade();
        emit Upgraded(_upgradedToken);
    }

    /**
     * @return Is this token upgraded
     */
    function isUpgraded() public view returns (bool) {
        return upgradedToken != IETokenProxy(0);
    }

    /**
     * @return The token that this was upgraded to
     */
    function getUpgradedToken() public view returns (IETokenProxy) {
        return upgradedToken;
    }

    /**
     * @dev Only allow the old contract to access the functions with explicit
     * sender passing
     */
    modifier onlyProxy () {
        require(msg.sender == _upgradedFrom,
                "Proxy is the only allowed caller");
        _;
    }

    /**
     * @dev Allows execution if token is enabled, i.e. it is the
     * initial deployment or is upgraded from a contract which has
     * called the finalizeUpgrade function.
     */
    modifier isEnabled () {
        require(enabled, "Token disabled");
        _;
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

// File: contracts/token/access/roles/PauserRole.sol

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



/** @title Contract managing the pauser role */
contract PauserRole is Ownable {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private pausers;

    constructor() internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "not pauser");
        _;
    }

    modifier requirePauser(address account) {
        require(isPauser(account), "not pauser");
        _;
    }

    /**
     * @dev Checks if account is pauser
     * @param account Account to check
     * @return Boolean indicating if account is pauser
     */
    function isPauser(address account) public view returns (bool) {
        return pausers.has(account);
    }

    /**
     * @dev Adds a pauser account. Is only callable by owner.
     * @param account Address to be added
     */
    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    /**
     * @dev Removes a pauser account. Is only callable by owner.
     * @param account Address to be removed
     */
    function removePauser(address account) public onlyOwner {
        _removePauser(account);
    }

    /** @dev Allows a privileged holder to renounce their role */
    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    /** @dev Internal implementation of addPauser */
    function _addPauser(address account) internal {
        pausers.add(account);
        emit PauserAdded(account);
    }

    /** @dev Internal implementation of removePauser */
    function _removePauser(address account) internal {
        pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: contracts/token/access/Pausable.sol

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
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private paused_;

    constructor() internal {
        paused_ = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function _paused() internal view returns(bool) {
        return paused_;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused_);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused_);
        _;
    }

    /**
     * @dev Modifier to make a function callable if a specified account is pauser.
     * @param account the address of the account to check
     */
    modifier requireIsPauser(address account) {
        require(isPauser(account));
        _;
    }

    /**
     * @dev Called by the owner to pause, triggers stopped state
     * @param originSender the original sender of this method
     */
    function _pause(address originSender)
        internal
    {
        paused_ = true;
        emit Paused(originSender);
    }

    /**
     * @dev Called by the owner to unpause, returns to normal state
     * @param originSender the original sender of this method
     */
    function _unpause(address originSender)
        internal
    {
        paused_ = false;
        emit Unpaused(originSender);
    }
}

// File: contracts/token/access/roles/WhitelistAdminRole.sol

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



/** @title Contract managing the whitelist admin role */
contract WhitelistAdminRole is Ownable {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private whitelistAdmins;

    constructor() internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender), "not whitelistAdmin");
        _;
    }

    modifier requireWhitelistAdmin(address account) {
        require(isWhitelistAdmin(account), "not whitelistAdmin");
        _;
    }

    /**
     * @dev Checks if account is whitelist dmin
     * @param account Account to check
     * @return Boolean indicating if account is whitelist admin
     */
    function isWhitelistAdmin(address account) public view returns (bool) {
        return whitelistAdmins.has(account);
    }

    /**
     * @dev Adds a whitelist admin account. Is only callable by owner.
     * @param account Address to be added
     */
    function addWhitelistAdmin(address account) public onlyOwner {
        _addWhitelistAdmin(account);
    }

    /**
     * @dev Removes a whitelist admin account. Is only callable by owner.
     * @param account Address to be removed
     */
    function removeWhitelistAdmin(address account) public onlyOwner {
        _removeWhitelistAdmin(account);
    }

    /** @dev Allows a privileged holder to renounce their role */
    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    /** @dev Internal implementation of addWhitelistAdmin */
    function _addWhitelistAdmin(address account) internal {
        whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    /** @dev Internal implementation of removeWhitelistAdmin */
    function _removeWhitelistAdmin(address account) internal {
        whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

// File: contracts/token/access/roles/BlacklistAdminRole.sol

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



/** @title Contract managing the blacklist admin role */
contract BlacklistAdminRole is Ownable {
    using Roles for Roles.Role;

    event BlacklistAdminAdded(address indexed account);
    event BlacklistAdminRemoved(address indexed account);

    Roles.Role private blacklistAdmins;

    constructor() internal {
        _addBlacklistAdmin(msg.sender);
    }

    modifier onlyBlacklistAdmin() {
        require(isBlacklistAdmin(msg.sender), "not blacklistAdmin");
        _;
    }

    modifier requireBlacklistAdmin(address account) {
        require(isBlacklistAdmin(account), "not blacklistAdmin");
        _;
    }

    /**
     * @dev Checks if account is blacklist admin
     * @param account Account to check
     * @return Boolean indicating if account is blacklist admin
     */
    function isBlacklistAdmin(address account) public view returns (bool) {
        return blacklistAdmins.has(account);
    }

    /**
     * @dev Adds a blacklist admin account. Is only callable by owner.
     * @param account Address to be added
     */
    function addBlacklistAdmin(address account) public onlyOwner {
        _addBlacklistAdmin(account);
    }

    /**
     * @dev Removes a blacklist admin account. Is only callable by owner
     * @param account Address to be removed
     */
    function removeBlacklistAdmin(address account) public onlyOwner {
        _removeBlacklistAdmin(account);
    }

    /** @dev Allows privilege holder to renounce their role */
    function renounceBlacklistAdmin() public {
        _removeBlacklistAdmin(msg.sender);
    }

    /** @dev Internal implementation of addBlacklistAdmin */
    function _addBlacklistAdmin(address account) internal {
        blacklistAdmins.add(account);
        emit BlacklistAdminAdded(account);
    }

    /** @dev Internal implementation of removeBlacklistAdmin */
    function _removeBlacklistAdmin(address account) internal {
        blacklistAdmins.remove(account);
        emit BlacklistAdminRemoved(account);
    }
}

// File: contracts/token/access/Accesslist.sol

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
 * @title The Accesslist contract
 * @dev Contract that contains a whitelist and a blacklist and manages them
 */
contract Accesslist is WhitelistAdminRole, BlacklistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);
    event BlacklistAdded(address indexed account);
    event BlacklistRemoved(address indexed account);

    Roles.Role private whitelist;
    Roles.Role private blacklist;

    /**
     * @dev Calls internal function _addWhitelisted
     * to add given address to whitelist
     * @param account Address to be added
     */
    function addWhitelisted(address account)
        public
        onlyWhitelistAdmin
    {
        _addWhitelisted(account);
    }

    /**
     * @dev Calls internal function _removeWhitelisted
     * to remove given address from the whitelist
     * @param account Address to be removed
     */
    function removeWhitelisted(address account)
        public
        onlyWhitelistAdmin
    {
        _removeWhitelisted(account);
    }

    /**
     * @dev Calls internal function _addBlacklisted
     * to add given address to blacklist
     * @param account Address to be added
     */
    function addBlacklisted(address account)
        public
        onlyBlacklistAdmin
    {
        _addBlacklisted(account);
    }

    /**
     * @dev Calls internal function _removeBlacklisted
     * to remove given address from blacklist
     * @param account Address to be removed
     */
    function removeBlacklisted(address account)
        public
        onlyBlacklistAdmin
    {
        _removeBlacklisted(account);
    }

    /**
     * @dev Checks to see if the given address is whitelisted
     * @param account Address to be checked
     * @return true if address is whitelisted
     */
    function isWhitelisted(address account)
        public
        view
        returns (bool)
    {
        return whitelist.has(account);
    }

    /**
     * @dev Checks to see if given address is blacklisted
     * @param account Address to be checked
     * @return true if address is blacklisted
     */
    function isBlacklisted(address account)
        public
        view
        returns (bool)
    {
        return blacklist.has(account);
    }

    /**
     * @dev Checks to see if given address is whitelisted and not blacklisted
     * @param account Address to be checked
     * @return true if address has access
     */
    function hasAccess(address account)
        public
        view
        returns (bool)
    {
        return isWhitelisted(account) && !isBlacklisted(account);
    }


    /**
     * @dev Adds given address to the whitelist
     * @param account Address to be added
     */
    function _addWhitelisted(address account) internal {
        whitelist.add(account);
        emit WhitelistAdded(account);
    }

    /**
     * @dev Removes given address to the whitelist
     * @param account Address to be removed
     */
    function _removeWhitelisted(address account) internal {
        whitelist.remove(account);
        emit WhitelistRemoved(account);
    }

    /**
     * @dev Adds given address to the blacklist
     * @param account Address to be added
     */
    function _addBlacklisted(address account) internal {
        blacklist.add(account);
        emit BlacklistAdded(account);
    }

    /**
     * @dev Removes given address to the blacklist
     * @param account Address to be removed
     */
    function _removeBlacklisted(address account) internal {
        blacklist.remove(account);
        emit BlacklistRemoved(account);
    }
}

// File: contracts/token/access/AccesslistGuarded.sol

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
 * @title The AccesslistGuarded contract
 * @dev Contract containing an accesslist and
 * modifiers to ensure proper access
 */
contract AccesslistGuarded {

    Accesslist private accesslist;
    bool private whitelistEnabled;

    /**
     * @dev Constructor. Checks if the accesslist is a zero address
     * @param _accesslist The access list
     * @param _whitelistEnabled If the whitelist is enabled
     */
    constructor(
        Accesslist _accesslist,
        bool _whitelistEnabled
    )
        public
    {
        require(
            _accesslist != Accesslist(0),
            "Supplied accesslist is null"
        );
        accesslist = _accesslist;
        whitelistEnabled = _whitelistEnabled;
    }

    /**
     * @dev Modifier that requires given address
     * to be whitelisted and not blacklisted
     * @param account address to be checked
     */
    modifier requireHasAccess(address account) {
        require(hasAccess(account), "no access");
        _;
    }

    /**
     * @dev Modifier that requires the message sender
     * to be whitelisted and not blacklisted
     */
    modifier onlyHasAccess() {
        require(hasAccess(msg.sender), "no access");
        _;
    }

    /**
     * @dev Modifier that requires given address
     * to be whitelisted
     * @param account address to be checked
     */
    modifier requireWhitelisted(address account) {
        require(isWhitelisted(account), "no access");
        _;
    }

    /**
     * @dev Modifier that requires message sender
     * to be whitelisted
     */
    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "no access");
        _;
    }

    /**
     * @dev Modifier that requires given address
     * to not be blacklisted
     * @param account address to be checked
     */
    modifier requireNotBlacklisted(address account) {
        require(isNotBlacklisted(account), "no access");
        _;
    }

    /**
     * @dev Modifier that requires message sender
     * to not be blacklisted
     */
    modifier onlyNotBlacklisted() {
        require(isNotBlacklisted(msg.sender), "no access");
        _;
    }

    /**
     * @dev Returns whether account has access.
     * If whitelist is enabled a whitelist check is also made,
     * otherwise it only checks for blacklisting.
     * @param account Address to be checked
     * @return true if address has access or is not blacklisted when whitelist
     * is disabled
     */
    function hasAccess(address account) public view returns (bool) {
        if (whitelistEnabled) {
            return accesslist.hasAccess(account);
        } else {
            return isNotBlacklisted(account);
        }
    }

    /**
     * @dev Returns whether account is whitelisted
     * @param account Address to be checked
     * @return true if address is whitelisted
     */
    function isWhitelisted(address account) public view returns (bool) {
        return accesslist.isWhitelisted(account);
    }

    /**
     * @dev Returns whether account is not blacklisted
     * @param account Address to be checked
     * @return true if address is not blacklisted
     */
    function isNotBlacklisted(address account) public view returns (bool) {
        return !accesslist.isBlacklisted(account);
    }
}

// File: contracts/token/access/roles/BurnerRole.sol

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



/** @title Contract managing the burner role */
contract BurnerRole is Ownable {
    using Roles for Roles.Role;

    event BurnerAdded(address indexed account);
    event BurnerRemoved(address indexed account);

    Roles.Role private burners;

    constructor() Ownable() internal {
        _addBurner(msg.sender);
    }

    modifier onlyBurner() {
        require(isBurner(msg.sender), "not burner");
        _;
    }

    modifier requireBurner(address account) {
        require(isBurner(account), "not burner");
        _;
    }

    /**
     * @dev Checks if account is burner
     * @param account Account to check
     * @return Boolean indicating if account is burner
     */
    function isBurner(address account) public view returns (bool) {
        return burners.has(account);
    }

    /**
     * @dev Adds a burner account
     * @dev Is only callable by owner
     * @param account Address to be added
     */
    function addBurner(address account) public onlyOwner {
        _addBurner(account);
    }

    /**
     * @dev Removes a burner account
     * @dev Is only callable by owner
     * @param account Address to be removed
     */
    function removeBurner(address account) public onlyOwner {
        _removeBurner(account);
    }

    /** @dev Allows a privileged holder to renounce their role */
    function renounceBurner() public {
        _removeBurner(msg.sender);
    }

    /** @dev Internal implementation of addBurner */
    function _addBurner(address account) internal {
        burners.add(account);
        emit BurnerAdded(account);
    }

    /** @dev Internal implementation of removeBurner */
    function _removeBurner(address account) internal {
        burners.remove(account);
        emit BurnerRemoved(account);
    }
}

// File: contracts/token/access/roles/MinterRole.sol

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



/** @title The minter role contract */
contract MinterRole is Ownable {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    /**
     * @dev Checks if the message sender is a minter
     */
    modifier onlyMinter() {
        require(isMinter(msg.sender), "not minter");
        _;
    }

    /**
     * @dev Checks if the given address is a minter
     * @param account Address to be checked
     */
    modifier requireMinter(address account) {
        require(isMinter(account), "not minter");
        _;
    }

    /**
     * @dev Checks if given address is a minter
     * @param account Address to be checked
     * @return Is the address a minter
     */
    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    /**
     * @dev Calls internal function _addMinter with the given address.
     * Can only be called by the owner.
     * @param account Address to be passed
     */
    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    /**
     * @dev Calls internal function _removeMinter with the given address.
     * Can only be called by the owner.
     * @param account Address to be passed
     */
    function removeMinter(address account) public onlyOwner {
        _removeMinter(account);
    }

    /**
     * @dev Calls internal function _removeMinter with message sender
     * as the parameter
     */
    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    /**
     * @dev Adds the given address to minters
     * @param account Address to be added
     */
    function _addMinter(address account) internal {
        minters.add(account);
        emit MinterAdded(account);
    }

    /**
     * @dev Removes given address from minters
     * @param account Address to be removed.
     */
    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: contracts/token/access/RestrictedMinter.sol

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
 * @title Restricted minter
 * @dev Implements the notion of a restricted minter which is only
 * able to mint to a single specified account. Only the owner may
 * change this account.
 */
contract RestrictedMinter  {

    address private mintingRecipientAccount;

    event MintingRecipientAccountChanged(address prev, address next);

    /**
     * @dev constructor. Sets minting recipient to given address
     * @param _mintingRecipientAccount address to be set to recipient
     */
    constructor(address _mintingRecipientAccount) internal {
        _changeMintingRecipient(msg.sender, _mintingRecipientAccount);
    }

    modifier requireMintingRecipient(address account) {
        require(account == mintingRecipientAccount,
                "is not mintingRecpientAccount");
        _;
    }

    /**
     * @return The current minting recipient account address
     */
    function getMintingRecipient() public view returns (address) {
        return mintingRecipientAccount;
    }

    /**
     * @dev Internal function allowing the owner to change the current minting recipient account
     * @param originSender The sender address of the request
     * @param _mintingRecipientAccount address of new minting recipient
     */
    function _changeMintingRecipient(
        address originSender,
        address _mintingRecipientAccount
    )
        internal
    {
        originSender;

        require(_mintingRecipientAccount != address(0),
                "zero minting recipient");
        address prev = mintingRecipientAccount;
        mintingRecipientAccount = _mintingRecipientAccount;
        emit MintingRecipientAccountChanged(prev, mintingRecipientAccount);
    }

}

// File: contracts/token/access/ETokenGuarded.sol

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
 * @title EToken access guards
 * @dev This contract implements access guards for functions comprising
 * the EToken public API. Since these functions may be called through
 * a proxy, access checks does not rely on the implicit value of
 * msg.sender but rather on the originSender parameter which is passed
 * to the functions of this contract. The value of originSender is
 * captured from msg.sender at the initial landing-point of the
 * request.
 */
contract ETokenGuarded is
    Pausable,
    ERC20,
    UpgradeSupport,
    AccesslistGuarded,
    BurnerRole,
    MinterRole,
    RestrictedMinter
{

    modifier requireOwner(address addr) {
        require(owner() == addr, "is not owner");
        _;
    }

    /**
     * @dev Constructor
     * @param name The ERC20 detailed token name
     * @param symbol The ERC20 detailed symbol name
     * @param decimals Determines the number of decimals of this token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
     * @param externalStorage The external storage contract.
     * Should be zero address if shouldCreateStorage is true.
     * @param initialDeployment Defines whether it should
     * create a new external storage. Should be false if
     * externalERC20Storage is defined.
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        Storage externalStorage,
        address initialMintingRecipient,
        bool initialDeployment
    )
        internal
        ERC20(name, symbol, decimals, externalStorage, initialDeployment)
        AccesslistGuarded(accesslist, whitelistEnabled)
        RestrictedMinter(initialMintingRecipient)
    {

    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.name. Also see the general documentation for this
     * contract.
     */
    function nameGuarded(address originSender)
        internal
        view
        returns(string)
    {
        // Silence warnings
        originSender;

        return _name();
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.symbol. Also see the general documentation for this
     * contract.
     */
    function symbolGuarded(address originSender)
        internal
        view
        returns(string)
    {
        // Silence warnings
        originSender;

        return _symbol();
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.decimals. Also see the general documentation for this
     * contract.
     */
    function decimalsGuarded(address originSender)
        internal
        view
        returns(uint8)
    {
        // Silence warnings
        originSender;

        return _decimals();
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.totalSupply. Also see the general documentation for this
     * contract.
     */
    function totalSupplyGuarded(address originSender)
        internal
        view
        isEnabled
        returns(uint256)
    {
        // Silence warnings
        originSender;

        return _totalSupply();
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.balanceOf. Also see the general documentation for this
     * contract.
     */
    function balanceOfGuarded(address originSender, address who)
        internal
        view
        isEnabled
        returns(uint256)
    {
        // Silence warnings
        originSender;

        return _balanceOf(who);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.allowance. Also see the general documentation for this
     * contract.
     */
    function allowanceGuarded(
        address originSender,
        address owner,
        address spender
    )
        internal
        view
        isEnabled
        returns(uint256)
    {
        // Silence warnings
        originSender;

        return _allowance(owner, spender);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.transfer. Also see the general documentation for this
     * contract.
     */
    function transferGuarded(address originSender, address to, uint256 value)
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(to)
        requireHasAccess(originSender)
        returns (bool)
    {
        _transfer(originSender, to, value);
        return true;
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.approve. Also see the general documentation for this
     * contract.
     */
    function approveGuarded(
        address originSender,
        address spender,
        uint256 value
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(originSender)
        returns (bool)
    {
        _approve(originSender, spender, value);
        return true;
    }


    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.transferFrom. Also see the documentation for this
     * contract.
     */
    function transferFromGuarded(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(originSender)
        requireHasAccess(from)
        requireHasAccess(to)
        returns (bool)
    {
        _transferFrom(
            originSender,
            from,
            to,
            value
        );
        return true;
    }


    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.increaseAllowance, Also see the general documentation
     * for this contract.
     */
    function increaseAllowanceGuarded(
        address originSender,
        address spender,
        uint256 addedValue
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(originSender)
        requireHasAccess(spender)
        returns (bool)
    {
        _increaseAllowance(originSender, spender, addedValue);
        return true;
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.decreaseAllowance. Also see the general documentation
     * for this contract.
     */
    function decreaseAllowanceGuarded(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(originSender)
        requireHasAccess(spender)
        returns (bool)  {
        _decreaseAllowance(originSender, spender, subtractedValue);
        return true;
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.burn. Also see the general documentation for this
     * contract.
     */
    function burnGuarded(address originSender, uint256 value)
        internal
        isEnabled
        requireBurner(originSender)
    {
        _burn(originSender, value);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.burnFrom. Also see the general documentation for this
     * contract.
     */
    function burnFromGuarded(address originSender, address from, uint256 value)
        internal
        isEnabled
        requireBurner(originSender)
    {
        _burnFrom(originSender, from, value);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.mint. Also see the general documentation for this
     * contract.
     */
    function mintGuarded(address originSender, address to, uint256 value)
        internal
        isEnabled
        requireMinter(originSender)
        requireMintingRecipient(to)
        returns (bool success)
    {
        // Silence warnings
        originSender;

        _mint(to, value);
        return true;
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.changeMintingRecipient. Also see the general
     * documentation for this contract.
     */
    function changeMintingRecipientGuarded(
        address originSender,
        address mintingRecip
    )
        internal
        isEnabled
        requireOwner(originSender)
    {
        _changeMintingRecipient(originSender, mintingRecip);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.pause. Also see the general documentation for this
     * contract.
     */
    function pauseGuarded(address originSender)
        internal
        isEnabled
        requireIsPauser(originSender)
        whenNotPaused
    {
        _pause(originSender);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.unpause. Also see the general documentation for this
     * contract.
     */
    function unpauseGuarded(address originSender)
        internal
        isEnabled
        requireIsPauser(originSender)
        whenPaused
    {
        _unpause(originSender);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.paused. Also see the general documentation for this
     * contract.
     */
    function pausedGuarded(address originSender)
        internal
        view
        isEnabled
        returns (bool)
    {
        // Silence warnings
        originSender;
        return _paused();
    }
}

// File: contracts/token/ETokenProxy.sol

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
 * @title EToken upgradability proxy
 * For every call received the following takes place:
 * If this token is upgraded, all calls are forwarded to the proxy
 * interface of the new contract thereby forming a chain of proxy
 * calls.
 * If this token is not upgraded, that is, it is the most recent
 * generation of ETokens, then calls are forwarded directly to the
 * ETokenGuarded interface which performs access
 */
contract ETokenProxy is IETokenProxy, ETokenGuarded {

    /**
     * @dev Constructor
     * @param name The ERC20 detailed token name
     * @param symbol The ERC20 detailed symbol name
     * @param decimals Determines the number of decimals of this token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
     * @param externalStorage The external storage contract.
     * Should be zero address if shouldCreateStorage is true.
     * @param initialDeployment Set to true if this is the initial deployment of
     * the token. If true it automtically creates a new ExternalERC20Storage.
     * Also, it acts as a confirmation of intention which interlocks
     * upgradedFrom as follows: If initialDeployment is true, then
     * upgradedFrom must be the zero address. Otherwise, upgradedFrom must not
     * be the zero address. The same applies to externalERC20Storage, which must
     * be set to the zero address if initialDeployment is true.
     * @param upgradedFrom The token contract that this contract upgrades. Set
     * to address(0) for initial deployments
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        Storage externalStorage,
        address initialMintingRecipient,
        address upgradedFrom,
        bool initialDeployment
    )
        internal
        UpgradeSupport(initialDeployment, upgradedFrom)
        ETokenGuarded(
            name,
            symbol,
            decimals,
            accesslist,
            whitelistEnabled,
            externalStorage,
            initialMintingRecipient,
            initialDeployment
        )
    {

    }

    /** Like EToken.name but proxies calls as described in the
        documentation for the declaration of this contract. */
    function nameProxy(address sender)
        external
        view
        isEnabled
        onlyProxy
        returns(string)
    {
        if (isUpgraded()) {
            return getUpgradedToken().nameProxy(sender);
        } else {
            return nameGuarded(sender);
        }
    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function symbolProxy(address sender)
        external
        view
        isEnabled
        onlyProxy
        returns(string)
    {
        if (isUpgraded()) {
            return getUpgradedToken().symbolProxy(sender);
        } else {
            return symbolGuarded(sender);
        }
    }

    /** Like EToken.decimals but proxies calls as described in the
        documentation for the declaration of this contract. */
    function decimalsProxy(address sender)
        external
        view
        isEnabled
        onlyProxy
        returns(uint8)
    {
        if (isUpgraded()) {
            return getUpgradedToken().decimalsProxy(sender);
        } else {
            return decimalsGuarded(sender);
        }
    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function totalSupplyProxy(address sender)
        external
        view
        isEnabled
        onlyProxy
        returns (uint256)
    {
        if (isUpgraded()) {
            return getUpgradedToken().totalSupplyProxy(sender);
        } else {
            return totalSupplyGuarded(sender);
        }
    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function balanceOfProxy(address sender, address who)
        external
        view
        isEnabled
        onlyProxy
        returns (uint256)
    {
        if (isUpgraded()) {
            return getUpgradedToken().balanceOfProxy(sender, who);
        } else {
            return balanceOfGuarded(sender, who);
        }
    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function allowanceProxy(address sender, address owner, address spender)
        external
        view
        isEnabled
        onlyProxy
        returns (uint256)
    {
        if (isUpgraded()) {
            return getUpgradedToken().allowanceProxy(sender, owner, spender);
        } else {
            return allowanceGuarded(sender, owner, spender);
        }
    }


    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function transferProxy(address sender, address to, uint256 value)
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            return getUpgradedToken().transferProxy(sender, to, value);
        } else {
            return transferGuarded(sender, to, value);
        }

    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function approveProxy(address sender, address spender, uint256 value)
        external
        isEnabled
        onlyProxy
        returns (bool)
    {

        if (isUpgraded()) {
            return getUpgradedToken().approveProxy(sender, spender, value);
        } else {
            return approveGuarded(sender, spender, value);
        }
    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function transferFromProxy(
        address sender,
        address from,
        address to,
        uint256 value
    )
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            getUpgradedToken().transferFromProxy(
                sender,
                from,
                to,
                value
            );
        } else {
            transferFromGuarded(
                sender,
                from,
                to,
                value
            );
        }
    }

    /** Like EToken. but proxies calls as described in the
        documentation for the declaration of this contract. */
    function mintProxy(address sender, address to, uint256 value)
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            return getUpgradedToken().mintProxy(sender, to, value);
        } else {
            return mintGuarded(sender, to, value);
        }
    }

    /** Like EToken.changeMintingRecipient but proxies calls as
        described in the documentation for the declaration of this
        contract. */
    function changeMintingRecipientProxy(address sender,
                                         address mintingRecip)
        external
        isEnabled
        onlyProxy
    {
        if (isUpgraded()) {
            getUpgradedToken().changeMintingRecipientProxy(sender, mintingRecip);
        } else {
            changeMintingRecipientGuarded(sender, mintingRecip);
        }
    }

    /** Like EToken.burn but proxies calls as described in the
        documentation for the declaration of this contract. */
    function burnProxy(address sender, uint256 value)
        external
        isEnabled
        onlyProxy
    {
        if (isUpgraded()) {
            getUpgradedToken().burnProxy(sender, value);
        } else {
            burnGuarded(sender, value);
        }
    }

    /** Like EToken.burnFrom but proxies calls as described in the
        documentation for the declaration of this contract. */
    function burnFromProxy(address sender, address from, uint256 value)
        external
        isEnabled
        onlyProxy
    {
        if (isUpgraded()) {
            getUpgradedToken().burnFromProxy(sender, from, value);
        } else {
            burnFromGuarded(sender, from, value);
        }
    }

    /** Like EToken.increaseAllowance but proxies calls as described
        in the documentation for the declaration of this contract. */
    function increaseAllowanceProxy(
        address sender,
        address spender,
        uint addedValue
    )
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            return getUpgradedToken().increaseAllowanceProxy(
                sender, spender, addedValue);
        } else {
            return increaseAllowanceGuarded(sender, spender, addedValue);
        }
    }

    /** Like EToken.decreaseAllowance but proxies calls as described
        in the documentation for the declaration of this contract. */
    function decreaseAllowanceProxy(
        address sender,
        address spender,
        uint subtractedValue
    )
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            return getUpgradedToken().decreaseAllowanceProxy(
                sender, spender, subtractedValue);
        } else {
            return decreaseAllowanceGuarded(sender, spender, subtractedValue);
        }
    }

    /** Like EToken.pause but proxies calls as described
        in the documentation for the declaration of this contract. */
    function pauseProxy(address sender)
        external
        isEnabled
        onlyProxy
    {
        if (isUpgraded()) {
            getUpgradedToken().pauseProxy(sender);
        } else {
            pauseGuarded(sender);
        }
    }

    /** Like EToken.unpause but proxies calls as described
        in the documentation for the declaration of this contract. */
    function unpauseProxy(address sender)
        external
        isEnabled
        onlyProxy
    {
        if (isUpgraded()) {
            getUpgradedToken().unpauseProxy(sender);
        } else {
            unpauseGuarded(sender);
        }
    }

    /** Like EToken.paused but proxies calls as described
        in the documentation for the declaration of this contract. */
    function pausedProxy(address sender)
        external
        view
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            return getUpgradedToken().pausedProxy(sender);
        } else {
            return pausedGuarded(sender);
        }
    }
}

// File: contracts/token/EToken.sol

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



/** @title Main EToken contract */
contract EToken is IEToken, ETokenProxy {

    /**
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param decimals The number of decimals of the token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
     * @param externalStorage Address of a deployed ERC20 storage contract
     * @param initialMintingRecipient The initial minting recipient of the token
     * @param upgradedFrom The token contract that this contract upgrades. Set
     * to address(0) for initial deployments
     * @param initialDeployment Set to true if this is the initial deployment of
     * the token. If true it automtically creates a new ExternalERC20Storage.
     * Also, it acts as a confirmation of intention which interlocks
     * upgradedFrom as follows: If initialDeployment is true, then
     * upgradedFrom must be the zero address. Otherwise, upgradedFrom must not
     * be the zero address. The same applies to externalERC20Storage, which must
     * be set to the zero address if initialDeployment is true.
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        Storage externalStorage,
        address initialMintingRecipient,
        address upgradedFrom,
        bool initialDeployment
    )
        public
        ETokenProxy(
            name,
            symbol,
            decimals,
            accesslist,
            whitelistEnabled,
            externalStorage,
            initialMintingRecipient,
            upgradedFrom,
            initialDeployment
        )
    {

    }

    /**
     * @dev Proxies call to new token if this token is upgraded
     * @return the name of the token.
     */
    function name() public view returns(string) {
        if (isUpgraded()) {
            return getUpgradedToken().nameProxy(msg.sender);
        } else {
            return nameGuarded(msg.sender);
        }
    }

    /**
     * @dev Proxies call to new token if this token is upgraded
     * @return the symbol of the token.
     */
    function symbol() public view returns(string) {
        if (isUpgraded()) {
            return getUpgradedToken().symbolProxy(msg.sender);
        } else {
            return symbolGuarded(msg.sender);
        }
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns(uint8) {
        if (isUpgraded()) {
            return getUpgradedToken().decimalsProxy(msg.sender);
        } else {
            return decimalsGuarded(msg.sender);
        }
    }

    /**
     * @dev Proxies call to new token if this token is upgraded
     * @return Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        if (isUpgraded()) {
            return getUpgradedToken().totalSupplyProxy(msg.sender);
        } else {
            return totalSupplyGuarded(msg.sender);
        }
    }

    /**
     * @dev Gets the balance of the specified address.
     * @dev Proxies call to new token if this token is upgraded
     * @param who The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address who) public view returns (uint256) {
        if (isUpgraded()) {
            return getUpgradedToken().balanceOfProxy(msg.sender, who);
        } else {
            return balanceOfGuarded(msg.sender, who);
        }
    }

    /**
     * @dev Function to check the amount of tokens that an owner
     * allowed to a spender.
     * @dev Proxies call to new token if this token is upgraded
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available
     * for the spender.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        if (isUpgraded()) {
            return getUpgradedToken().allowanceProxy(
                msg.sender,
                owner,
                spender
            );
        } else {
            return allowanceGuarded(msg.sender, owner, spender);
        }
    }


    /**
     * @dev Transfer token for a specified address
     * @dev Proxies call to new token if this token is upgraded
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return getUpgradedToken().transferProxy(msg.sender, to, value);
        } else {
            return transferGuarded(msg.sender, to, value);
        }
    }

    /**
     * @dev Approve the passed address to spend the specified amount
     * of tokens on behalf of msg.sender.  Beware that changing an
     * allowance with this method brings the risk that someone may use
     * both the old and the new allowance by unfortunate transaction
     * ordering. One possible solution to mitigate this race condition
     * is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @dev Proxies call to new token if this token is upgraded
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return getUpgradedToken().approveProxy(msg.sender, spender, value);
        } else {
            return approveGuarded(msg.sender, spender, value);
        }
    }

    /**
     * @dev Transfer tokens from one address to another
     * @dev Proxies call to new token if this token is upgraded
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool)
    {
        if (isUpgraded()) {
            return getUpgradedToken().transferFromProxy(
                msg.sender,
                from,
                to,
                value
            );
        } else {
            return transferFromGuarded(
                msg.sender,
                from,
                to,
                value
            );
        }
    }

    /**
     * @dev Function to mint tokens
     * @dev Proxies call to new token if this token is upgraded
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return getUpgradedToken().mintProxy(msg.sender, to, value);
        } else {
            return mintGuarded(msg.sender, to, value);
        }
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @dev Proxies call to new token if this token is upgraded
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        if (isUpgraded()) {
            getUpgradedToken().burnProxy(msg.sender, value);
        } else {
            burnGuarded(msg.sender, value);
        }
    }

    /**
     * @dev Burns a specific amount of tokens from the target address
     * and decrements allowance
     * @dev Proxies call to new token if this token is upgraded
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        if (isUpgraded()) {
            getUpgradedToken().burnFromProxy(msg.sender, from, value);
        } else {
            burnFromGuarded(msg.sender, from, value);
        }
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @dev Proxies call to new token if this token is upgraded
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(
        address spender,
        uint addedValue
    )
        public
        returns (bool success)
    {
        if (isUpgraded()) {
            return getUpgradedToken().increaseAllowanceProxy(
                msg.sender,
                spender,
                addedValue
            );
        } else {
            return increaseAllowanceGuarded(msg.sender, spender, addedValue);
        }
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @dev Proxies call to new token if this token is upgraded
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
        public
        returns (bool success)
    {
        if (isUpgraded()) {
            return getUpgradedToken().decreaseAllowanceProxy(
                msg.sender,
                spender,
                subtractedValue
            );
        } else {
            return super.decreaseAllowanceGuarded(
                msg.sender,
                spender,
                subtractedValue
            );
        }
    }

    /**
     * @dev Allows the owner to change the current minting recipient account
     * @param mintingRecip address of new minting recipient
     */
    function changeMintingRecipient(address mintingRecip) public {
        if (isUpgraded()) {
            getUpgradedToken().changeMintingRecipientProxy(
                msg.sender,
                mintingRecip
            );
        } else {
            changeMintingRecipientGuarded(msg.sender, mintingRecip);
        }
    }

    /**
     * Allows a pauser to pause the current token.
     */
    function pause() public {
        if (isUpgraded()) {
            getUpgradedToken().pauseProxy(msg.sender);
        } else {
            pauseGuarded(msg.sender);
        }
    }

    /**
     * Allows a pauser to unpause the current token.
     */
    function unpause() public {
        if (isUpgraded()) {
            getUpgradedToken().unpauseProxy(msg.sender);
        } else {
            unpauseGuarded(msg.sender);
        }
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        if (isUpgraded()) {
            return getUpgradedToken().pausedProxy(msg.sender);
        } else {
            return pausedGuarded(msg.sender);
        }
    }
}
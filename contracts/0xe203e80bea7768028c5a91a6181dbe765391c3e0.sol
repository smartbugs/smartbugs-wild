pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
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
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
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
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: contracts/controller/Permissions/RootPlatformAdministratorRole.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title RootPlatformAdministratorRole root user role mainly to manage other roles. */
contract RootPlatformAdministratorRole {
    using Roles for Roles.Role;

///////////////////
// Events
///////////////////

    event RootPlatformAdministratorAdded(address indexed account);
    event RootPlatformAdministratorRemoved(address indexed account);

///////////////////
// Variables
///////////////////

    Roles.Role private rootPlatformAdministrators;

///////////////////
// Constructor
///////////////////

    constructor() internal {
        _addRootPlatformAdministrator(msg.sender);
    }

///////////////////
// Modifiers
///////////////////

    modifier onlyRootPlatformAdministrator() {
        require(isRootPlatformAdministrator(msg.sender), "no root PFadmin");
        _;
    }

///////////////////
// Functions
///////////////////

    function isRootPlatformAdministrator(address account) public view returns (bool) {
        return rootPlatformAdministrators.has(account);
    }

    function addRootPlatformAdministrator(address account) public onlyRootPlatformAdministrator {
        _addRootPlatformAdministrator(account);
    }

    function renounceRootPlatformAdministrator() public {
        _removeRootPlatformAdministrator(msg.sender);
    }

    function _addRootPlatformAdministrator(address account) internal {
        rootPlatformAdministrators.add(account);
        emit RootPlatformAdministratorAdded(account);
    }

    function _removeRootPlatformAdministrator(address account) internal {
        rootPlatformAdministrators.remove(account);
        emit RootPlatformAdministratorRemoved(account);
    }
}

// File: contracts/controller/Permissions/AssetTokenAdministratorRole.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title AssetTokenAdministratorRole of AssetToken administrators. */
contract AssetTokenAdministratorRole is RootPlatformAdministratorRole {

///////////////////
// Events
///////////////////

    event AssetTokenAdministratorAdded(address indexed account);
    event AssetTokenAdministratorRemoved(address indexed account);

///////////////////
// Variables
///////////////////

    Roles.Role private assetTokenAdministrators;

///////////////////
// Constructor
///////////////////

    constructor() internal {
        _addAssetTokenAdministrator(msg.sender);
    }

///////////////////
// Modifiers
///////////////////

    modifier onlyAssetTokenAdministrator() {
        require(isAssetTokenAdministrator(msg.sender), "no ATadmin");
        _;
    }

///////////////////
// Functions
///////////////////

    function isAssetTokenAdministrator(address _account) public view returns (bool) {
        return assetTokenAdministrators.has(_account);
    }

    function addAssetTokenAdministrator(address _account) public onlyRootPlatformAdministrator {
        _addAssetTokenAdministrator(_account);
    }

    function renounceAssetTokenAdministrator() public {
        _removeAssetTokenAdministrator(msg.sender);
    }

    function _addAssetTokenAdministrator(address _account) internal {
        assetTokenAdministrators.add(_account);
        emit AssetTokenAdministratorAdded(_account);
    }

    function removeAssetTokenAdministrator(address _account) public onlyRootPlatformAdministrator {
        _removeAssetTokenAdministrator(_account);
    }

    function _removeAssetTokenAdministrator(address _account) internal {
        assetTokenAdministrators.remove(_account);
        emit AssetTokenAdministratorRemoved(_account);
    }
}

// File: contracts/controller/Permissions/At2CsConnectorRole.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title At2CsConnectorRole AssetToken to Crowdsale connector role. */
contract At2CsConnectorRole is RootPlatformAdministratorRole {

///////////////////
// Events
///////////////////

    event At2CsConnectorAdded(address indexed account);
    event At2CsConnectorRemoved(address indexed account);

///////////////////
// Variables
///////////////////

    Roles.Role private at2csConnectors;

///////////////////
// Constructor
///////////////////

    constructor() internal {
        _addAt2CsConnector(msg.sender);
    }

///////////////////
// Modifiers
///////////////////

    modifier onlyAt2CsConnector() {
        require(isAt2CsConnector(msg.sender), "no at2csAdmin");
        _;
    }

///////////////////
// Functions
///////////////////

    function isAt2CsConnector(address _account) public view returns (bool) {
        return at2csConnectors.has(_account);
    }

    function addAt2CsConnector(address _account) public onlyRootPlatformAdministrator {
        _addAt2CsConnector(_account);
    }

    function renounceAt2CsConnector() public {
        _removeAt2CsConnector(msg.sender);
    }

    function _addAt2CsConnector(address _account) internal {
        at2csConnectors.add(_account);
        emit At2CsConnectorAdded(_account);
    }

    function removeAt2CsConnector(address _account) public onlyRootPlatformAdministrator {
        _removeAt2CsConnector(_account);
    }

    function _removeAt2CsConnector(address _account) internal {
        at2csConnectors.remove(_account);
        emit At2CsConnectorRemoved(_account);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
    }
}

// File: contracts/controller/0_library/DSMathL.sol

// fork from ds-math specifically my librarization fork: https://raw.githubusercontent.com/JohannesMayerConda/ds-math/master/contracts/DSMathL.sol

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

library DSMathL {
    function ds_add(uint x, uint y) public pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function ds_sub(uint x, uint y) public pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function ds_mul(uint x, uint y) public pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function ds_min(uint x, uint y) public pure returns (uint z) {
        return x <= y ? x : y;
    }
    function ds_max(uint x, uint y) public pure returns (uint z) {
        return x >= y ? x : y;
    }
    function ds_imin(int x, int y) public pure returns (int z) {
        return x <= y ? x : y;
    }
    function ds_imax(int x, int y) public pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function ds_wmul(uint x, uint y) public pure returns (uint z) {
        z = ds_add(ds_mul(x, y), WAD / 2) / WAD;
    }
    function ds_rmul(uint x, uint y) public pure returns (uint z) {
        z = ds_add(ds_mul(x, y), RAY / 2) / RAY;
    }
    function ds_wdiv(uint x, uint y) public pure returns (uint z) {
        z = ds_add(ds_mul(x, WAD), y / 2) / y;
    }
    function ds_rdiv(uint x, uint y) public pure returns (uint z) {
        z = ds_add(ds_mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function ds_rpow(uint x, uint n) public pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = ds_rmul(x, x);

            if (n % 2 != 0) {
                z = ds_rmul(z, x);
            }
        }
    }
}

// File: contracts/controller/Permissions/YourOwnable.sol

// 1:1 copy of https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.1/contracts/ownership/Ownable.sol
// except constructor that can instantly transfer ownership

contract YourOwnable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor (address newOwner) public {
        _transferOwnership(newOwner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
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

// File: contracts/controller/FeeTable/StandardFeeTable.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/



/** @title StandardFeeTable contract to store fees via name (fees per platform for certain name). */
contract StandardFeeTable  is YourOwnable {
    using SafeMath for uint256;

///////////////////
// Constructor
///////////////////

    constructor (address newOwner) YourOwnable(newOwner) public {}

///////////////////
// Variables
///////////////////

    uint256 public defaultFee;

    mapping (bytes32 => uint256) public feeFor;
    mapping (bytes32 => bool) public isFeeDisabled;

///////////////////
// Functions
///////////////////

    /// @notice Set default fee (when nothing else applies).
    /// @param _defaultFee default fee value. Unit is WAD so fee 1 means value=1e18.
    function setDefaultFee(uint256 _defaultFee) public onlyOwner {
        defaultFee = _defaultFee;
    }

    /// @notice Set fee by name.
    /// @param _feeName fee name.
    /// @param _feeValue fee value. Unit is WAD so fee 1 means value=1e18.
    function setFee(bytes32 _feeName, uint256 _feeValue) public onlyOwner {
        feeFor[_feeName] = _feeValue;
    }

    /// @notice Enable or disable fee by name.
    /// @param _feeName fee name.
    /// @param _feeDisabled true if fee should be disabled.
    function setFeeMode(bytes32 _feeName, bool _feeDisabled) public onlyOwner {
        isFeeDisabled[_feeName] = _feeDisabled;
    }

    /// @notice Get standard fee (not overriden by special fee for specific AssetToken).
    /// @param _feeName fee name.
    /// @return fee value. Unit is WAD so fee 1 means value=1e18.
    function getStandardFee(bytes32 _feeName) public view returns (uint256 _feeValue) {
        if (isFeeDisabled[_feeName]) {
            return 0;
        }

        if(feeFor[_feeName] == 0) {
            return defaultFee;
        }

        return feeFor[_feeName];
    }

    /// @notice Get standard fee for amount in base unit.
    /// @param _feeName fee name.
    /// @param _amountInFeeBaseUnit amount in fee base unit (currently in unit tokens).
    /// @return fee value. Unit is WAD (converted it).
    function getStandardFeeFor(bytes32 _feeName, uint256 _amountInFeeBaseUnit) public view returns (uint256) {
        //1000000000000000 is 0,001 as WAD
        //example fee 0.001 for amount 3: 3 tokens * 1000000000000000 fee = 3000000000000000 (0.003)
        return _amountInFeeBaseUnit.mul(getStandardFee(_feeName));
    }
}

// File: contracts/controller/FeeTable/FeeTable.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title FeeTable contract to store fees via name (fees per platform per assettoken for certain name). */
contract FeeTable is StandardFeeTable {
    
///////////////////
// Constructor
///////////////////

    constructor (address newOwner) StandardFeeTable(newOwner) public {}

///////////////////
// Mappings
///////////////////

    // specialfee mapping feeName -> token -> fee
    mapping (bytes32 => mapping (address => uint256)) public specialFeeFor;

    // specialfee mapping feeName -> token -> isSet
    mapping (bytes32 => mapping (address => bool)) public isSpecialFeeEnabled;

///////////////////
// Functions
///////////////////

    /// @notice Set a special fee specifically for an AssetToken (higher or lower than normal fee).
    /// @param _feeName fee name.
    /// @param _regardingAssetToken regarding AssetToken.
    /// @param _feeValue fee value. Unit is WAD so fee 1 means value=1e18.
    function setSpecialFee(bytes32 _feeName, address _regardingAssetToken, uint256 _feeValue) public onlyOwner {
        specialFeeFor[_feeName][_regardingAssetToken] = _feeValue;
    }

    /// @notice Enable or disable special fee.
    /// @param _feeName fee name.
    /// @param _regardingAssetToken regarding AssetToken.
    /// @param _feeEnabled true to enable fee.
    function setSpecialFeeMode(bytes32 _feeName, address _regardingAssetToken, bool _feeEnabled) public onlyOwner {
        isSpecialFeeEnabled[_feeName][_regardingAssetToken] = _feeEnabled;
    }

    /// @notice Get fee by name.
    /// @param _feeName fee name.
    /// @param _regardingAssetToken regarding AssetToken.
    /// @return fee value. Unit is WAD so fee 11 means value=1e18.
    function getFee(bytes32 _feeName, address _regardingAssetToken) public view returns (uint256) {
        if (isFeeDisabled[_feeName]) {
            return 0;
        }

        if (isSpecialFeeEnabled[_feeName][_regardingAssetToken]) {
            return specialFeeFor[_feeName][_regardingAssetToken];
        }

        return super.getStandardFee(_feeName);
    }

    /// @notice Get fee for amount in base unit.
    /// @param _feeName fee name.
    /// @param _regardingAssetToken regarding AssetToken.
    /// @param _amountInFeeBaseUnit amount in fee base unit (currently in unit tokens).
    /// @return fee value. Unit is WAD (converted it).
    function getFeeFor(bytes32 _feeName, address _regardingAssetToken, uint256 _amountInFeeBaseUnit, address /*oracle*/)
        public view returns (uint256) 
    {   
        uint256 fee = getFee(_feeName, _regardingAssetToken);
        
        //1000000000000000 is 0,001 as WAD
        //example fee 0.001 for amount 3: 3 tokens * 1000000000000000 fee = 3000000000000000 (0.003)
        return _amountInFeeBaseUnit.mul(fee);
    }
}

// File: contracts/controller/Permissions/WhitelistControlRole.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title WhitelistControlRole role to administrate whitelist and KYC. */
contract WhitelistControlRole is RootPlatformAdministratorRole {

///////////////////
// Events
///////////////////

    event WhitelistControlAdded(address indexed account);
    event WhitelistControlRemoved(address indexed account);

///////////////////
// Variables
///////////////////

    Roles.Role private whitelistControllers;

///////////////////
// Constructor
///////////////////

    constructor() internal {
        _addWhitelistControl(msg.sender);
    }

///////////////////
// Modifiers
///////////////////

    modifier onlyWhitelistControl() {
        require(isWhitelistControl(msg.sender), "no WLcontrol");
        _;
    }

///////////////////
// Functions
///////////////////

    function isWhitelistControl(address account) public view returns (bool) {
        return whitelistControllers.has(account);
    }

    function addWhitelistControl(address account) public onlyRootPlatformAdministrator {
        _addWhitelistControl(account);
    }

    function _addWhitelistControl(address account) internal {
        whitelistControllers.add(account);
        emit WhitelistControlAdded(account);
    }

    function removeWhitelistControl(address account) public onlyRootPlatformAdministrator {
        whitelistControllers.remove(account);
        emit WhitelistControlRemoved(account);
    }
}

// File: contracts/controller/interface/IWhitelistAutoExtendExpirationExecutor.sol

interface IWhitelistAutoExtendExpirationExecutor {
    function recheckIdentity(address _wallet, address _investorKey, address _issuer) external;
}

// File: contracts/controller/interface/IWhitelistAutoExtendExpirationCallback.sol

interface IWhitelistAutoExtendExpirationCallback {
    function updateIdentity(address _wallet, bool _isWhitelisted, address _investorKey, address _issuer) external;
}

// File: contracts/controller/Whitelist/Whitelist.sol

/** @title Whitelist stores whitelist information of investors like if and when they were KYC checked. */
contract Whitelist is WhitelistControlRole, IWhitelistAutoExtendExpirationCallback {
    using SafeMath for uint256;

///////////////////
// Variables
///////////////////

    uint256 public expirationBlocks;
    bool public expirationEnabled;
    bool public autoExtendExpiration;
    address public autoExtendExpirationContract;

    mapping (address => bool) whitelistedWallet;
    mapping (address => uint256) lastIdentityVerificationDate;
    mapping (address => address) whitelistedWalletIssuer;
    mapping (address => address) walletToInvestorKey;

///////////////////
// Events
///////////////////

    event WhitelistChanged(address indexed wallet, bool whitelisted, address investorKey, address issuer);
    event ExpirationBlocksChanged(address initiator, uint256 addedBlocksSinceWhitelisting);
    event ExpirationEnabled(address initiator, bool expirationEnabled);
    event UpdatedIdentity(address initiator, address indexed wallet, bool whitelisted, address investorKey, address issuer);
    event SetAutoExtendExpirationContract(address initiator, address expirationContract);
    event UpdatedAutoExtendExpiration(address initiator, bool autoExtendEnabled);

///////////////////
// Functions
///////////////////

    function getIssuer(address _whitelistedWallet) public view returns (address) {
        return whitelistedWalletIssuer[_whitelistedWallet];
    }

    function getInvestorKey(address _wallet) public view returns (address) {
        return walletToInvestorKey[_wallet];
    }

    function setWhitelisted(address _wallet, bool _isWhitelisted, address _investorKey, address _issuer) public onlyWhitelistControl {
        whitelistedWallet[_wallet] = _isWhitelisted;
        lastIdentityVerificationDate[_wallet] = block.number;
        whitelistedWalletIssuer[_wallet] = _issuer;
        assignWalletToInvestorKey(_wallet, _investorKey);

        emit WhitelistChanged(_wallet, _isWhitelisted, _investorKey, _issuer);
    }

    function assignWalletToInvestorKey(address _wallet, address _investorKey) public onlyWhitelistControl {
        walletToInvestorKey[_wallet] = _investorKey;
    }

    //note: no view keyword here because IWhitelistAutoExtendExpirationExecutor could change state via callback
    function checkWhitelistedWallet(address _wallet) public returns (bool) {
        if(autoExtendExpiration && isExpired(_wallet)) {
            address investorKey = walletToInvestorKey[_wallet];
            address issuer = whitelistedWalletIssuer[_wallet];
            require(investorKey != address(0), "expired, unknown identity");

            //IMPORTANT: reentrance hook. make sure calling contract is safe
            IWhitelistAutoExtendExpirationExecutor(autoExtendExpirationContract).recheckIdentity(_wallet, investorKey, issuer);
        }

        require(!isExpired(_wallet), "whitelist expired");
        require(whitelistedWallet[_wallet], "not whitelisted");

        return true;
    }

    function isWhitelistedWallet(address _wallet) public view returns (bool) {
        if(isExpired(_wallet)) {
            return false;
        }

        return whitelistedWallet[_wallet];
    }

    function isExpired(address _wallet) private view returns (bool) {
        return expirationEnabled && block.number > lastIdentityVerificationDate[_wallet].add(expirationBlocks);
    }

    function blocksLeftUntilExpired(address _wallet) public view returns (uint256) {
        require(expirationEnabled, "expiration disabled");

        return lastIdentityVerificationDate[_wallet].add(expirationBlocks).sub(block.number);
    }

    function setExpirationBlocks(uint256 _addedBlocksSinceWhitelisting) public onlyRootPlatformAdministrator {
        expirationBlocks = _addedBlocksSinceWhitelisting;

        emit ExpirationBlocksChanged(msg.sender, _addedBlocksSinceWhitelisting);
    }

    function setExpirationEnabled(bool _isEnabled) public onlyRootPlatformAdministrator {
        expirationEnabled = _isEnabled;

        emit ExpirationEnabled(msg.sender, expirationEnabled);
    }

    function setAutoExtendExpirationContract(address _autoExtendContract) public onlyRootPlatformAdministrator {
        autoExtendExpirationContract = _autoExtendContract;

        emit SetAutoExtendExpirationContract(msg.sender, _autoExtendContract);
    }

    function setAutoExtendExpiration(bool _autoExtendEnabled) public onlyRootPlatformAdministrator {
        autoExtendExpiration = _autoExtendEnabled;

        emit UpdatedAutoExtendExpiration(msg.sender, _autoExtendEnabled);
    }

    function updateIdentity(address _wallet, bool _isWhitelisted, address _investorKey, address _issuer) public onlyWhitelistControl {
        setWhitelisted(_wallet, _isWhitelisted, _investorKey, _issuer);

        emit UpdatedIdentity(msg.sender, _wallet, _isWhitelisted, _investorKey, _issuer);
    }
}

// File: contracts/controller/interface/IExchangeRateOracle.sol

contract IExchangeRateOracle {
    function resetCurrencyPair(address _currencyA, address _currencyB) public;

    function configureCurrencyPair(address _currencyA, address _currencyB, uint256 maxNextUpdateInBlocks) public;

    function setExchangeRate(address _currencyA, address _currencyB, uint256 _rateFromTo, uint256 _rateToFrom) public;
    function getExchangeRate(address _currencyA, address _currencyB) public view returns (uint256);

    function convert(address _currencyA, address _currencyB, uint256 _amount) public view returns (uint256);
    function convertTT(bytes32 _currencyAText, bytes32 _currencyBText, uint256 _amount) public view returns (uint256);
    function convertTA(bytes32 _currencyAText, address _currencyB, uint256 _amount) public view returns (uint256);
    function convertAT(address _currencyA, bytes32 _currencyBText, uint256 _amount) public view returns (uint256);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: contracts/controller/interfaces/IBasicAssetToken.sol

interface IBasicAssetToken {
    //AssetToken specific
    function isTokenAlive() external view returns (bool);

    //Mintable
    function mint(address _to, uint256 _amount) external returns (bool);
    function finishMinting() external returns (bool);
}

// File: contracts/controller/Permissions/StorageAdministratorRole.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title StorageAdministratorRole role to administrate generic storage. */
contract StorageAdministratorRole is RootPlatformAdministratorRole {

///////////////////
// Events
///////////////////

    event StorageAdministratorAdded(address indexed account);
    event StorageAdministratorRemoved(address indexed account);

///////////////////
// Variables
///////////////////

    Roles.Role private storageAdministrators;

///////////////////
// Constructor
///////////////////

    constructor() internal {
        _addStorageAdministrator(msg.sender);
    }

///////////////////
// Modifiers
///////////////////

    modifier onlyStorageAdministrator() {
        require(isStorageAdministrator(msg.sender), "no SAdmin");
        _;
    }

///////////////////
// Functions
///////////////////

    function isStorageAdministrator(address account) public view returns (bool) {
        return storageAdministrators.has(account);
    }

    function addStorageAdministrator(address account) public onlyRootPlatformAdministrator {
        _addStorageAdministrator(account);
    }

    function _addStorageAdministrator(address account) internal {
        storageAdministrators.add(account);
        emit StorageAdministratorAdded(account);
    }

    function removeStorageAdministrator(address account) public onlyRootPlatformAdministrator {
        storageAdministrators.remove(account);
        emit StorageAdministratorRemoved(account);
    }
}

// File: contracts/controller/Storage/storagetypes/UintStorage.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title UintStorage uint storage. */
contract UintStorage is StorageAdministratorRole
{

///////////////////
// Mappings
///////////////////

    mapping (bytes32 => uint256) private uintStorage;

///////////////////
// Functions
///////////////////

    function setUint(bytes32 _name, uint256 _value)
        public 
        onlyStorageAdministrator 
    {
        return _setUint(_name, _value);
    }

    function getUint(bytes32 _name) 
        public view 
        returns (uint256) 
    {
        return _getUint(_name);
    }

    function _setUint(bytes32 _name, uint256 _value)
        private 
    {
        if(_name != "") {
            uintStorage[_name] = _value;
        }
    }

    function _getUint(bytes32 _name) 
        private view 
        returns (uint256) 
    {
        return uintStorage[_name];
    }

    function get2Uint(
        bytes32 _name1, 
        bytes32 _name2) 
        public view 
        returns (uint256, uint256) 
    {
        return (_getUint(_name1), _getUint(_name2));
    }
    
    function get3Uint(
        bytes32 _name1, 
        bytes32 _name2, 
        bytes32 _name3) 
        public view 
        returns (uint256, uint256, uint256) 
    {
        return (_getUint(_name1), _getUint(_name2), _getUint(_name3));
    }

    function get4Uint(
        bytes32 _name1, 
        bytes32 _name2, 
        bytes32 _name3, 
        bytes32 _name4) 
        public view 
        returns (uint256, uint256, uint256, uint256) 
    {
        return (_getUint(_name1), _getUint(_name2), _getUint(_name3), _getUint(_name4));
    }

    function get5Uint(
        bytes32 _name1, 
        bytes32 _name2, 
        bytes32 _name3, 
        bytes32 _name4, 
        bytes32 _name5) 
        public view 
        returns (uint256, uint256, uint256, uint256, uint256) 
    {
        return (_getUint(_name1), 
            _getUint(_name2), 
            _getUint(_name3), 
            _getUint(_name4), 
            _getUint(_name5));
    }

    function set2Uint(
        bytes32 _name1, uint256 _value1, 
        bytes32 _name2, uint256 _value2)
        public 
        onlyStorageAdministrator 
    {
        _setUint(_name1, _value1);
        _setUint(_name2, _value2);
    }

    function set3Uint(
        bytes32 _name1, uint256 _value1, 
        bytes32 _name2, uint256 _value2,
        bytes32 _name3, uint256 _value3)
        public 
        onlyStorageAdministrator 
    {
        _setUint(_name1, _value1);
        _setUint(_name2, _value2);
        _setUint(_name3, _value3);
    }

    function set4Uint(
        bytes32 _name1, uint256 _value1, 
        bytes32 _name2, uint256 _value2,
        bytes32 _name3, uint256 _value3,
        bytes32 _name4, uint256 _value4)
        public 
        onlyStorageAdministrator 
    {
        _setUint(_name1, _value1);
        _setUint(_name2, _value2);
        _setUint(_name3, _value3);
        _setUint(_name4, _value4);
    }

    function set5Uint(
        bytes32 _name1, uint256 _value1, 
        bytes32 _name2, uint256 _value2,
        bytes32 _name3, uint256 _value3,
        bytes32 _name4, uint256 _value4,
        bytes32 _name5, uint256 _value5)
        public 
        onlyStorageAdministrator 
    {
        _setUint(_name1, _value1);
        _setUint(_name2, _value2);
        _setUint(_name3, _value3);
        _setUint(_name4, _value4);
        _setUint(_name5, _value5);
    }
}

// File: contracts/controller/Storage/storagetypes/AddrStorage.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title AddrStorage address storage. */
contract AddrStorage is StorageAdministratorRole
{

///////////////////
// Mappings
///////////////////

    mapping (bytes32 => address) private addrStorage;

///////////////////
// Functions
///////////////////

    function setAddr(bytes32 _name, address _value)
        public 
        onlyStorageAdministrator 
    {
        return _setAddr(_name, _value);
    }

    function getAddr(bytes32 _name) 
        public view 
        returns (address) 
    {
        return _getAddr(_name);
    }

    function _setAddr(bytes32 _name, address _value)
        private 
    {
        if(_name != "") {
            addrStorage[_name] = _value;
        }
    }

    function _getAddr(bytes32 _name) 
        private view 
        returns (address) 
    {
        return addrStorage[_name];
    }

    function get2Address(
        bytes32 _name1, 
        bytes32 _name2) 
        public view 
        returns (address, address) 
    {
        return (_getAddr(_name1), _getAddr(_name2));
    }
    
    function get3Address(
        bytes32 _name1, 
        bytes32 _name2, 
        bytes32 _name3) 
        public view 
        returns (address, address, address) 
    {
        return (_getAddr(_name1), _getAddr(_name2), _getAddr(_name3));
    }

    function set2Address(
        bytes32 _name1, address _value1, 
        bytes32 _name2, address _value2)
        public 
        onlyStorageAdministrator 
    {
        _setAddr(_name1, _value1);
        _setAddr(_name2, _value2);
    }

    function set3Address(
        bytes32 _name1, address _value1, 
        bytes32 _name2, address _value2,
        bytes32 _name3, address _value3)
        public 
        onlyStorageAdministrator 
    {
        _setAddr(_name1, _value1);
        _setAddr(_name2, _value2);
        _setAddr(_name3, _value3);
    }
}

// File: contracts/controller/Storage/storagetypes/Addr2UintStorage.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title Addr2UintStorage address to uint mapping storage. */
contract Addr2UintStorage is StorageAdministratorRole
{
    
///////////////////
// Mappings
///////////////////

    mapping (bytes32 => mapping (address => uint256)) private addr2UintStorage;

///////////////////
// Functions
///////////////////

    function setAddr2Uint(bytes32 _name, address _address, uint256 _value)
        public 
        onlyStorageAdministrator 
    {
        return _setAddr2Uint(_name, _address, _value);
    }

    function getAddr2Uint(bytes32 _name, address _address)
        public view 
        returns (uint256) 
    {
        return _getAddr2Uint(_name, _address);
    }

    function _setAddr2Uint(bytes32 _name, address _address, uint256 _value)
        private 
    {
        if(_name != "") {
            addr2UintStorage[_name][_address] = _value;
        }
    }

    function _getAddr2Uint(bytes32 _name, address _address)
        private view 
        returns (uint256) 
    {
        return addr2UintStorage[_name][_address];
    }

    function get2Addr2Uint(
        bytes32 _name1, address _address1,
        bytes32 _name2, address _address2)
        public view 
        returns (uint256, uint256) 
    {
        return (_getAddr2Uint(_name1, _address1), 
            _getAddr2Uint(_name2, _address2));
    }
    
    function get3Addr2Addr2Uint(
        bytes32 _name1, address _address1,
        bytes32 _name2, address _address2,
        bytes32 _name3, address _address3) 
        public view 
        returns (uint256, uint256, uint256) 
    {
        return (_getAddr2Uint(_name1, _address1), 
            _getAddr2Uint(_name2, _address2), 
            _getAddr2Uint(_name3, _address3));
    }

    function set2Addr2Uint(
        bytes32 _name1, address _address1, uint256 _value1, 
        bytes32 _name2, address _address2, uint256 _value2)
        public 
        onlyStorageAdministrator 
    {
        _setAddr2Uint(_name1, _address1, _value1);
        _setAddr2Uint(_name2, _address2, _value2);
    }

    function set3Addr2Uint(
        bytes32 _name1, address _address1, uint256 _value1, 
        bytes32 _name2, address _address2, uint256 _value2,
        bytes32 _name3, address _address3, uint256 _value3)
        public 
        onlyStorageAdministrator 
    {
        _setAddr2Uint(_name1, _address1, _value1);
        _setAddr2Uint(_name2, _address2, _value2);
        _setAddr2Uint(_name3, _address3, _value3);
    }
}

// File: contracts/controller/Storage/storagetypes/Addr2AddrStorage.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title Addr2AddrStorage address to address mapping storage. */
contract Addr2AddrStorage is StorageAdministratorRole
{
///////////////////
// Mappings
///////////////////

    mapping (bytes32 => mapping (address => address)) private addr2AddrStorage;

///////////////////
// Functions
///////////////////

    function setAddr2Addr(bytes32 _name, address _address, address _value)
        public 
        onlyStorageAdministrator 
    {
        return _setAddr2Addr(_name, _address, _value);
    }

    function getAddr2Addr(bytes32 _name, address _address)
        public view 
        returns (address) 
    {
        return _getAddr2Addr(_name, _address);
    }

    function _setAddr2Addr(bytes32 _name, address _address, address _value)
        private 
    {
        if(_name != "") {
            addr2AddrStorage[_name][_address] = _value;
        }
    }

    function _getAddr2Addr(bytes32 _name, address _address)
        private view 
        returns (address) 
    {
        return addr2AddrStorage[_name][_address];
    }

    function get2Addr2Addr(
        bytes32 _name1, address _address1,
        bytes32 _name2, address _address2)
        public view 
        returns (address, address) 
    {
        return (_getAddr2Addr(_name1, _address1), 
            _getAddr2Addr(_name2, _address2));
    }
    
    function get3Addr2Addr2Addr(
        bytes32 _name1, address _address1,
        bytes32 _name2, address _address2,
        bytes32 _name3, address _address3) 
        public view 
        returns (address, address, address) 
    {
        return (_getAddr2Addr(_name1, _address1), 
            _getAddr2Addr(_name2, _address2), 
            _getAddr2Addr(_name3, _address3));
    }

    function set2Addr2Addr(
        bytes32 _name1, address _address1, address _value1, 
        bytes32 _name2, address _address2, address _value2)
        public 
        onlyStorageAdministrator 
    {
        _setAddr2Addr(_name1, _address1, _value1);
        _setAddr2Addr(_name2, _address2, _value2);
    }

    function set3Addr2Addr(
        bytes32 _name1, address _address1, address _value1, 
        bytes32 _name2, address _address2, address _value2,
        bytes32 _name3, address _address3, address _value3)
        public 
        onlyStorageAdministrator 
    {
        _setAddr2Addr(_name1, _address1, _value1);
        _setAddr2Addr(_name2, _address2, _value2);
        _setAddr2Addr(_name3, _address3, _value3);
    }
}

// File: contracts/controller/Storage/storagetypes/Addr2BoolStorage.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title Addr2BoolStorage address to address mapping storage. */
contract Addr2BoolStorage is StorageAdministratorRole
{
    
///////////////////
// Mappings
///////////////////

    mapping (bytes32 => mapping (address => bool)) private addr2BoolStorage;

///////////////////
// Functions
///////////////////

    function setAddr2Bool(bytes32 _name, address _address, bool _value)
        public 
        onlyStorageAdministrator 
    {
        return _setAddr2Bool(_name, _address, _value);
    }

    function getAddr2Bool(bytes32 _name, address _address)
        public view  
        returns (bool) 
    {
        return _getAddr2Bool(_name, _address);
    }

    function _setAddr2Bool(bytes32 _name, address _address, bool _value)
        private 
    {
        if(_name != "") {
            addr2BoolStorage[_name][_address] = _value;
        }
    }

    function _getAddr2Bool(bytes32 _name, address _address)
        private view 
        returns (bool) 
    {
        return addr2BoolStorage[_name][_address];
    }

    function get2Addr2Bool(
        bytes32 _name1, address _address1,
        bytes32 _name2, address _address2)
        public view 
        returns (bool, bool) 
    {
        return (_getAddr2Bool(_name1, _address1), 
            _getAddr2Bool(_name2, _address2));
    }
    
    function get3Address2Address2Bool(
        bytes32 _name1, address _address1,
        bytes32 _name2, address _address2,
        bytes32 _name3, address _address3) 
        public view 
        returns (bool, bool, bool) 
    {
        return (_getAddr2Bool(_name1, _address1), 
            _getAddr2Bool(_name2, _address2), 
            _getAddr2Bool(_name3, _address3));
    }

    function set2Address2Bool(
        bytes32 _name1, address _address1, bool _value1, 
        bytes32 _name2, address _address2, bool _value2)
        public 
        onlyStorageAdministrator 
    {
        _setAddr2Bool(_name1, _address1, _value1);
        _setAddr2Bool(_name2, _address2, _value2);
    }

    function set3Address2Bool(
        bytes32 _name1, address _address1, bool _value1, 
        bytes32 _name2, address _address2, bool _value2,
        bytes32 _name3, address _address3, bool _value3)
        public 
        onlyStorageAdministrator 
    {
        _setAddr2Bool(_name1, _address1, _value1);
        _setAddr2Bool(_name2, _address2, _value2);
        _setAddr2Bool(_name3, _address3, _value3);
    }
}

// File: contracts/controller/Storage/storagetypes/BytesStorage.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title BytesStorage bytes storage. */
contract BytesStorage is StorageAdministratorRole
{

///////////////////
// Mappings
///////////////////

    mapping (bytes32 => bytes32) private bytesStorage;

///////////////////
// Functions
///////////////////

    function setBytes(bytes32 _name, bytes32 _value)
        public 
        onlyStorageAdministrator 
    {
        return _setBytes(_name, _value);
    }

    function getBytes(bytes32 _name) 
        public view 
        returns (bytes32) 
    {
        return _getBytes(_name);
    }

    function _setBytes(bytes32 _name, bytes32 _value)
        private 
    {
        if(_name != "") {
            bytesStorage[_name] = _value;
        }
    }

    function _getBytes(bytes32 _name) 
        private view 
        returns (bytes32) 
    {
        return bytesStorage[_name];
    }

    function get2Bytes(
        bytes32 _name1, 
        bytes32 _name2) 
        public view 
        returns (bytes32, bytes32) 
    {
        return (_getBytes(_name1), _getBytes(_name2));
    }
    
    function get3Bytes(
        bytes32 _name1, 
        bytes32 _name2, 
        bytes32 _name3) 
        public view 
        returns (bytes32, bytes32, bytes32) 
    {
        return (_getBytes(_name1), _getBytes(_name2), _getBytes(_name3));
    }

    function set2Bytes(
        bytes32 _name1, bytes32 _value1, 
        bytes32 _name2, bytes32 _value2)
        public 
        onlyStorageAdministrator 
    {
        _setBytes(_name1, _value1);
        _setBytes(_name2, _value2);
    }

    function set3Bytes(
        bytes32 _name1, bytes32 _value1, 
        bytes32 _name2, bytes32 _value2,
        bytes32 _name3, bytes32 _value3)
        public 
        onlyStorageAdministrator 
    {
        _setBytes(_name1, _value1);
        _setBytes(_name2, _value2);
        _setBytes(_name3, _value3);
    }
}

// File: contracts/controller/Storage/storagetypes/Addr2AddrArrStorage.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title Addr2AddrArrStorage address to address array mapping storage. */
contract Addr2AddrArrStorage is StorageAdministratorRole
{

///////////////////
// Mappings
///////////////////

    mapping (bytes32 => mapping (address => address[])) private addr2AddrArrStorage;

///////////////////
// Functions
///////////////////

    function addToAddr2AddrArr(bytes32 _name, address _address, address _value)
        public 
        onlyStorageAdministrator 
    {
        addr2AddrArrStorage[_name][_address].push(_value);
    }

    function getAddr2AddrArr(bytes32 _name, address _address)
        public view 
        returns (address[] memory) 
    {
        return addr2AddrArrStorage[_name][_address];
    }
}

// File: contracts/controller/Storage/storagetypes/StorageHolder.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/








/** @title StorageHolder holds the fine-grained generic storage functions. */
contract StorageHolder is 
    UintStorage,
    BytesStorage,
    AddrStorage,
    Addr2UintStorage,
    Addr2BoolStorage,
    Addr2AddrStorage,
    Addr2AddrArrStorage
{

///////////////////
// Functions
///////////////////

    function getMixedUBA(bytes32 _uintName, bytes32 _bytesName, bytes32 _addressName) 
        public view
        returns (uint256, bytes32, address) 
    {
        return (getUint(_uintName), getBytes(_bytesName), getAddr(_addressName));
    }

    function getMixedMapA2UA2BA2A(
        bytes32 _a2uName, 
        address _a2uAddress, 
        bytes32 _a2bName, 
        address _a2bAddress, 
        bytes32 _a2aName, 
        address _a2aAddress)
        public view
        returns (uint256, bool, address) 
    {
        return (getAddr2Uint(_a2uName, _a2uAddress), 
            getAddr2Bool(_a2bName, _a2bAddress), 
            getAddr2Addr(_a2aName, _a2aAddress));
    }
}

// File: contracts/controller/Storage/AT2CSStorage.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/





/** @title AT2CSStorage AssetToken to Crowdsale storage (that is upgradeable). */
contract AT2CSStorage is StorageAdministratorRole {

///////////////////
// Constructor
///////////////////

    constructor(address controllerStorage) public {
        storageHolder = StorageHolder(controllerStorage);
    }

///////////////////
// Variables
///////////////////

    StorageHolder storageHolder;

///////////////////
// Functions
///////////////////

    function getAssetTokenOfCrowdsale(address _crowdsale) public view returns (address) {
        return storageHolder.getAddr2Addr("cs2at", _crowdsale);
    }

    function getRateFromCrowdsale(address _crowdsale) public view returns (uint256) {
        address assetToken = storageHolder.getAddr2Addr("cs2at", _crowdsale);
        return getRateFromAssetToken(assetToken);
    }

    function getRateFromAssetToken(address _assetToken) public view returns (uint256) {
        require(_assetToken != address(0), "rate assetTokenIs0");
        return storageHolder.getAddr2Uint("rate", _assetToken);
    }

    function getAssetTokenOwnerWalletFromCrowdsale(address _crowdsale) public view returns (address) {
        address assetToken = storageHolder.getAddr2Addr("cs2at", _crowdsale);
        return getAssetTokenOwnerWalletFromAssetToken(assetToken);
    }

    function getAssetTokenOwnerWalletFromAssetToken(address _assetToken) public view returns (address) {
        return storageHolder.getAddr2Addr("at2wallet", _assetToken);
    }

    function getAssetTokensOf(address _wallet) public view returns (address[] memory) {
        return storageHolder.getAddr2AddrArr("wallet2AT", _wallet);
    }

    function isAssignedCrowdsale(address _crowdsale) public view returns (bool) {
        return storageHolder.getAddr2Bool("isCS", _crowdsale);
    }

    function isTrustedAssetTokenRegistered(address _assetToken) public view returns (bool) {
        return storageHolder.getAddr2Bool("trustedAT", _assetToken);
    }

    function isTrustedAssetTokenActive(address _assetToken) public view returns (bool) {
        return storageHolder.getAddr2Bool("ATactive", _assetToken);
    }

    function checkTrustedAssetToken(address _assetToken) public view returns (bool) {
        require(storageHolder.getAddr2Bool("ATactive", _assetToken), "not trusted AT");

        return true;
    }

    function checkTrustedCrowdsaleInternal(address _crowdsale) public view returns (bool) {
        address _assetTokenAddress = storageHolder.getAddr2Addr("cs2at", _crowdsale);
        require(storageHolder.getAddr2Bool("isCS", _crowdsale), "not registered CS");
        require(checkTrustedAssetToken(_assetTokenAddress), "not trusted AT");

        return true;
    }

    function changeActiveTrustedAssetToken(address _assetToken, bool _active) public onlyStorageAdministrator {
        storageHolder.setAddr2Bool("ATactive", _assetToken, _active);
    }

    function addTrustedAssetTokenInternal(address _ownerWallet, address _assetToken, uint256 _rate) public onlyStorageAdministrator {
        require(!storageHolder.getAddr2Bool("trustedAT", _assetToken), "exists");
        require(ERC20Detailed(_assetToken).decimals() == 0, "decimal not 0");

        storageHolder.setAddr2Bool("trustedAT", _assetToken, true);
        storageHolder.setAddr2Bool("ATactive", _assetToken, true);
        storageHolder.addToAddr2AddrArr("wallet2AT", _ownerWallet, _assetToken);
        storageHolder.setAddr2Addr("at2wallet", _assetToken, _ownerWallet);
        storageHolder.setAddr2Uint("rate", _assetToken, _rate);
    }

    function assignCrowdsale(address _assetToken, address _crowdsale) public onlyStorageAdministrator {
        require(storageHolder.getAddr2Bool("trustedAT", _assetToken), "no AT");
        require(!storageHolder.getAddr2Bool("isCS", _crowdsale), "is assigned");
        require(IBasicAssetToken(_assetToken).isTokenAlive(), "not alive");
        require(ERC20Detailed(_assetToken).decimals() == 0, "decimal not 0");
        
        storageHolder.setAddr2Bool("isCS", _crowdsale, true);
        storageHolder.setAddr2Addr("cs2at", _crowdsale, _assetToken);
    }

    function setAssetTokenRate(address _assetToken, uint256 _rate) public onlyStorageAdministrator {
        storageHolder.setAddr2Uint("rate", _assetToken, _rate);
    }
}

// File: contracts/controller/0_library/ControllerL.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/








/** @title ControllerL library. */
library ControllerL {
    using SafeMath for uint256;

///////////////////
// Structs
///////////////////

    struct Data {
        // global flag fees enabled
        bool feesEnabled;

        // global flag whitelist enabled
        bool whitelistEnabled;

        // address of the crwd token (for fees etc.)
        address crwdToken;

        // root platform wallet (receives fees according to it's FeeTable)
        address rootPlatformAddress;

        // address of ExchangeRateOracle (converts e.g. ETH to EUR and vice versa)
        address exchangeRateOracle;

        // the address of the whitelist contract
        address whitelist;

        // the generic storage contract
        AT2CSStorage store;

        // global flag to prevent new AssetToken or crowdsales to be accepted (e.g. after upgrade).
        bool blockNew;

        // mapping of platform addresses that are trusted
        mapping ( address => bool ) trustedPlatform; //note: not easily upgradeable

        // mapping of platform addresses that are trusted
        mapping ( address => bool ) onceTrustedPlatform; //note: not easily upgradeable

        // mapping of crowdsale to platform wallet
        mapping ( address => address ) crowdsaleToPlatform; //note: not easily upgradeable

        // mapping from platform address to FeeTable
        mapping ( address => address ) platformToFeeTable; //note: not easily upgradeable
    }

///////////////////
// Functions
///////////////////

    /// @dev Contant point multiplier because no decimals.
    function pointMultiplier() private pure returns (uint256) {
        return 1e18;
    }

    /// @notice Address of generic storage (for upgradability).
    function getStorageAddress(Data storage _self) public view returns (address) {
        return address(_self.store);
    }

    /// @notice Assign generic storage (for upgradability).
    /// @param _storage storage address.
    function assignStore(Data storage _self, address _storage) public {
        _self.store = AT2CSStorage(_storage);
    }

    /// @notice Get FeeTable for platform.
    /// @param _platform platform to find FeeTable for.
    /// @return address of FeeTable of platform.
    function getFeeTableAddressForPlatform(Data storage _self, address _platform) public view returns (address) {
        return _self.platformToFeeTable[_platform];
    }

    /// @notice Get FeeTable for platform.
    /// @param _platform platform to find FeeTable for.
    /// @return address of FeeTable of platform.
    function getFeeTableForPlatform(Data storage _self, address _platform) private view returns (FeeTable) {
        return FeeTable(_self.platformToFeeTable[_platform]);
    }

    /// @notice Set exchange rate oracle address.
    /// @param _oracleAddress the address of the ExchangeRateOracle.
    function setExchangeRateOracle(Data storage _self, address _oracleAddress) public {
        _self.exchangeRateOracle = _oracleAddress;

        emit ExchangeRateOracleSet(msg.sender, _oracleAddress);
    }

    /// @notice Check if a wallet is whitelisted or fail. Also considers auto extend (if enabled).
    /// @param _wallet the wallet to check.
    function checkWhitelistedWallet(Data storage _self, address _wallet) public returns (bool) {
        require(Whitelist(_self.whitelist).checkWhitelistedWallet(_wallet), "not whitelist");

        return true;
    }

    /// @notice Check if a wallet is whitelisted.
    /// @param _wallet the wallet to check.
    /// @return true if whitelisted.
    function isWhitelistedWallet(Data storage _self, address _wallet) public view returns (bool) {
        return Whitelist(_self.whitelist).isWhitelistedWallet(_wallet);
    }

    /// @notice Convert eth amount into base currency (EUR), apply exchange rate via oracle, apply rate for AssetToken.
    /// @param _crowdsale the crowdsale address.
    /// @param _amountInWei the amount desired to be converted into tokens.
    function convertEthToEurApplyRateGetTokenAmountFromCrowdsale(
        Data storage _self, 
        address _crowdsale,
        uint256 _amountInWei) 
        public view returns (uint256 _effectiveTokensNoDecimals, uint256 _overpaidEthWhenZeroDecimals)
    {
        uint256 amountInEur = convertEthToEur(_self, _amountInWei);
        uint256 tokens = DSMathL.ds_wmul(amountInEur, _self.store.getRateFromCrowdsale(_crowdsale));

        _effectiveTokensNoDecimals = tokens.div(pointMultiplier());
        _overpaidEthWhenZeroDecimals = convertEurToEth(_self, DSMathL.ds_wdiv(tokens.sub(_effectiveTokensNoDecimals.mul(pointMultiplier())), _self.store.getRateFromCrowdsale(_crowdsale)));

        return (_effectiveTokensNoDecimals, _overpaidEthWhenZeroDecimals);
    }

    /// @notice Checks if a crowdsale is trusted or fail.
    /// @param _crowdsale the address of the crowdsale.
    /// @return true if trusted.
    function checkTrustedCrowdsale(Data storage _self, address _crowdsale) public view returns (bool) {
        require(checkTrustedPlatform(_self, _self.crowdsaleToPlatform[_crowdsale]), "not trusted PF0");
        require(_self.store.checkTrustedCrowdsaleInternal(_crowdsale), "not trusted CS1");

        return true;   
    }

    /// @notice Checks if a AssetToken is trusted or fail.
    /// @param _assetToken the address of the AssetToken.
    /// @return true if trusted.
    function checkTrustedAssetToken(Data storage _self, address _assetToken) public view returns (bool) {
        //here just a minimal check for active (simple check on transfer).
        require(_self.store.checkTrustedAssetToken(_assetToken), "untrusted AT");

        return true;   
    }

    /// @notice Checks if a platform is certified or fail.
    /// @param _platformWallet wallet of platform.
    /// @return true if trusted.
    function checkTrustedPlatform(Data storage _self, address _platformWallet) public view returns (bool) {
        require(isTrustedPlatform(_self, _platformWallet), "not trusted PF3");

        return true;
    }

    /// @notice Checks if a platform is certified.
    /// @param _platformWallet wallet of platform.
    /// @return true if certified.
    function isTrustedPlatform(Data storage _self, address _platformWallet) public view returns (bool) {
        return _self.trustedPlatform[_platformWallet];
    }

    /// @notice Add trusted AssetToken.
    /// @param _ownerWallet requires CRWD for fees, receives ETH on successful campaign.
    /// @param _rate the rate of tokens per basecurrency (currently EUR).
    function addTrustedAssetToken(Data storage _self, address _ownerWallet, address _assetToken, uint256 _rate) public {
        require(!_self.blockNew, "blocked. newest version?");

        _self.store.addTrustedAssetTokenInternal(_ownerWallet, _assetToken, _rate);

        emit AssetTokenAdded(msg.sender, _ownerWallet, _assetToken, _rate);
    }

    /// @notice assign a crowdsale to an AssetToken.
    /// @param _assetToken the AssetToken being sold.
    /// @param _crowdsale the crowdsale that takes ETH (if enabled) and triggers assignment of tokens.
    /// @param _platformWallet the wallet of the platform. Fees are paid to this address.
    function assignCrowdsale(Data storage _self, address _assetToken, address _crowdsale, address _platformWallet) public {
        require(!_self.blockNew, "blocked. newest version?");
        checkTrustedPlatform(_self, _platformWallet);
        _self.store.assignCrowdsale(_assetToken, _crowdsale);
        _self.crowdsaleToPlatform[_crowdsale] = _platformWallet;

        emit CrowdsaleAssigned(msg.sender, _assetToken, _crowdsale, _platformWallet);
    }

    /// @notice Can change the state of an AssetToken (e.g. blacklist for legal reasons)
    /// @param _assetToken the AssetToken to change state.
    /// @param _active the state. True means active.
    /// @return True if successful.
    function changeActiveTrustedAssetToken(Data storage _self, address _assetToken, bool _active) public returns (bool) {
        _self.store.changeActiveTrustedAssetToken(_assetToken, _active);
        emit AssetTokenChangedActive(msg.sender, _assetToken, _active);
    }

    /// @notice Function to call on buy request.
    /// @param _to beneficiary of tokens.
    /// @param _amountInWei the invested ETH amount (unit WEI).
    function buyFromCrowdsale(
        Data storage _self, 
        address _to, 
        uint256 _amountInWei) 
        public returns (uint256 _tokensCreated, uint256 _overpaidRefund)
    {
        (uint256 effectiveTokensNoDecimals, uint256 overpaidEth) = convertEthToEurApplyRateGetTokenAmountFromCrowdsale(
            _self, 
            msg.sender, 
            _amountInWei);

        checkValidTokenAssignmentFromCrowdsale(_self, _to);
        payFeeFromCrowdsale(_self, effectiveTokensNoDecimals);
        _tokensCreated = doTokenAssignment(_self, _to, effectiveTokensNoDecimals, msg.sender);

        return (_tokensCreated, overpaidEth);
    }

    /// @notice Assign tokens.
    /// @dev Pure assignment without e.g. rate calculation.
    /// @param _to beneficiary of tokens.
    /// @param _tokensToMint amount of tokens beneficiary receives.
    /// @return amount of tokens being created.
    function assignFromCrowdsale(Data storage _self, address _to, uint256 _tokensToMint) public returns (uint256 _tokensCreated) {
        checkValidTokenAssignmentFromCrowdsale(_self, _to);
        payFeeFromCrowdsale(_self, _tokensToMint);

        _tokensCreated = doTokenAssignment(_self, _to, _tokensToMint, msg.sender);

        return _tokensCreated;
    }

    /// @dev Token assignment logic.
    /// @param _to beneficiary of tokens.
    /// @param _tokensToMint amount of tokens beneficiary receives.
    /// @param _crowdsale being used.
    /// @return amount of tokens being created.
    function doTokenAssignment(
        Data storage _self, 
        address _to, 
        uint256 _tokensToMint, 
        address _crowdsale) 
        private returns 
        (uint256 _tokensCreated)
    {
        address assetToken = _self.store.getAssetTokenOfCrowdsale(_crowdsale);
    
        require(assetToken != address(0), "assetTokenIs0");
        ERC20Mintable(assetToken).mint(_to, _tokensToMint);

        return _tokensToMint;
    }

    /// @notice Pay fee on calls from crowdsale.
    /// @param _tokensToMint tokens being created.
    function payFeeFromCrowdsale(Data storage _self, uint256 _tokensToMint) private {
        if (_self.feesEnabled) {
            address ownerAssetTokenWallet = _self.store.getAssetTokenOwnerWalletFromCrowdsale(msg.sender);
            payFeeKnowingCrowdsale(_self, msg.sender, ownerAssetTokenWallet, _tokensToMint, "investorInvests");
        }
    }

    /// @notice Check if token assignment is valid and e.g. crowdsale is trusted and investor KYC checked.
    /// @param _to beneficiary.
    function checkValidTokenAssignmentFromCrowdsale(Data storage _self, address _to) private {
        require(checkTrustedCrowdsale(_self, msg.sender), "untrusted source1");

        if (_self.whitelistEnabled) {
            checkWhitelistedWallet(_self, _to);
        }
    }

    /// @notice Pay fee on controller call from Crowdsale.
    /// @param _crowdsale the calling Crowdsale contract.
    /// @param _ownerAssetToken the AssetToken of the owner.
    /// @param _tokensToMint the tokens being created.
    /// @param _feeName the name of the fee (key in mapping).
    function payFeeKnowingCrowdsale(
        Data storage _self, 
        address _crowdsale, 
        address _ownerAssetToken, 
        uint256 _tokensToMint, //tokensToMint requires precalculations and is base for fees
        bytes32 _feeName)
        private
    {
        address platform = _self.crowdsaleToPlatform[_crowdsale];

        uint256 feePromilleRootPlatform = getFeeKnowingCrowdsale(
            _self, 
            _crowdsale, 
            getFeeTableAddressForPlatform(_self, _self.rootPlatformAddress),
            _tokensToMint, 
            false, 
            _feeName);

        payWithCrwd(_self, _ownerAssetToken, _self.rootPlatformAddress, feePromilleRootPlatform);

        if(platform != _self.rootPlatformAddress) {
            address feeTable = getFeeTableAddressForPlatform(_self, platform);
            require(feeTable != address(0), "FeeTbl 0 addr");
            uint256 feePromillePlatform = getFeeKnowingCrowdsale(_self, _crowdsale, feeTable, _tokensToMint, false, _feeName);
            payWithCrwd(_self, _ownerAssetToken, platform, feePromillePlatform);
        }
    }

    /// @notice Pay fee on controller call from AssetToken.
    /// @param _assetToken the calling AssetToken contract.
    /// @param _initiator the initiator passed through as parameter by AssetToken.
    /// @param _tokensToMint the tokens being handled.
    /// @param _feeName the name of the fee (key in mapping).
    function payFeeKnowingAssetToken(
        Data storage _self, 
        address _assetToken, 
        address _initiator, 
        uint256 _tokensToMint, //tokensToMint requires precalculations and is base for fees
        bytes32 _feeName) 
        public 
    {
        uint256 feePromille = getFeeKnowingAssetToken(
            _self, 
            _assetToken, 
            _initiator, 
            _tokensToMint, 
            _feeName);

        payWithCrwd(_self, _initiator, _self.rootPlatformAddress, feePromille);
    }

    /// @dev this function in the end does the fee payment in CRWD.
    function payWithCrwd(Data storage _self, address _from, address _to, uint256 _value) private {
        if(_value > 0 && _from != _to) {
            ERC20Mintable(_self.crwdToken).transferFrom(_from, _to, _value);
            emit FeesPaid(_from, _to, _value);
        }
    }

    /// @notice Current conversion of ETH to EUR via oracle.
    /// @param _weiAmount the ETH amount (uint WEI).
    /// @return amount converted in euro.
    function convertEthToEur(Data storage _self, uint256 _weiAmount) public view returns (uint256) {
        require(_self.exchangeRateOracle != address(0), "no oracle");
        return IExchangeRateOracle(_self.exchangeRateOracle).convertTT("ETH", "EUR", _weiAmount);
    }

    /// @notice Current conversion of EUR to ETH via oracle.
    /// @param _eurAmount the EUR amount
    /// @return amount converted in eth (formatted like WEI)
    function convertEurToEth(Data storage _self, uint256 _eurAmount) public view returns (uint256) {
        require(_self.exchangeRateOracle != address(0), "no oracle");
        return IExchangeRateOracle(_self.exchangeRateOracle).convertTT("EUR", "ETH", _eurAmount);
    }

    /// @notice Get fee that needs to be paid for certain Crowdsale and FeeName.
    /// @param _crowdsale the Crowdsale being used.
    /// @param _feeTableAddr the address of the feetable.
    /// @param _amountInTokensOrEth the amount in tokens or pure ETH when conversion parameter true.
    /// @param _amountRequiresConversion when true amount parameter is converted from ETH into tokens.
    /// @param _feeName the name of the fee being paid.
    /// @return amount of fees that would/will be paid.
    function getFeeKnowingCrowdsale(
        Data storage _self,
        address _crowdsale, 
        address _feeTableAddr, 
        uint256 _amountInTokensOrEth,
        bool _amountRequiresConversion,
        bytes32 _feeName) 
        public view returns (uint256) 
    {
        uint256 tokens = _amountInTokensOrEth;

        if(_amountRequiresConversion) {
            (tokens, ) = convertEthToEurApplyRateGetTokenAmountFromCrowdsale(_self, _crowdsale, _amountInTokensOrEth);
        }
        
        FeeTable feeTable = FeeTable(_feeTableAddr);
        address assetTokenOfCrowdsale = _self.store.getAssetTokenOfCrowdsale(_crowdsale);

        return feeTable.getFeeFor(_feeName, assetTokenOfCrowdsale, tokens, _self.exchangeRateOracle);
    }

    /// @notice Get fee that needs to be paid for certain AssetToken and FeeName.
    /// @param _assetToken the AssetToken being used.
    /// @param _tokenAmount the amount in tokens.
    /// @param _feeName the name of the fee being paid.
    /// @return amount of fees that would/will be paid.
    function getFeeKnowingAssetToken(
        Data storage _self, 
        address _assetToken, 
        address /*_from*/, 
        uint256 _tokenAmount, 
        bytes32 _feeName) 
        public view returns (uint256) 
    {
        FeeTable feeTable = getFeeTableForPlatform(_self, _self.rootPlatformAddress);
        return feeTable.getFeeFor(_feeName, _assetToken, _tokenAmount, _self.exchangeRateOracle);
    }

    /// @notice Set CRWD token address (e.g. for fees).
    /// @param _crwdToken the CRWD token address.
    function setCrwdTokenAddress(Data storage _self, address _crwdToken) public {
        _self.crwdToken = _crwdToken;
        emit CrwdTokenAddressChanged(_crwdToken);
    }

    /// @notice set platform address to trusted. A platform can receive fees.
    /// @param _platformWallet the wallet that will receive fees.
    /// @param _trusted true means trusted and false means not (=default).
    function setTrustedPlatform(Data storage _self, address _platformWallet, bool _trusted) public {
        setTrustedPlatformInternal(_self, _platformWallet, _trusted, false);
    }

    /// @dev set trusted platform logic
    /// @param _platformWallet the wallet that will receive fees.
    /// @param _trusted true means trusted and false means not (=default).
    /// @param _isRootPlatform true means that the given address is the root platform (here mainly used to save info into event).
    function setTrustedPlatformInternal(Data storage _self, address _platformWallet, bool _trusted, bool _isRootPlatform) private {
        require(_self.rootPlatformAddress != address(0), "no rootPF");

        _self.trustedPlatform[_platformWallet] = _trusted;
        
        if(_trusted && !_self.onceTrustedPlatform[msg.sender]) {
            _self.onceTrustedPlatform[_platformWallet] = true;
            FeeTable ft = new FeeTable(_self.rootPlatformAddress);
            _self.platformToFeeTable[_platformWallet] = address(ft);
        }

        emit PlatformTrustChanged(_platformWallet, _trusted, _isRootPlatform);
    }

    /// @notice Set root platform address. Root platform address can receive fees (independent of which Crowdsale/AssetToken).
    /// @param _rootPlatformWallet wallet of root platform.
    function setRootPlatform(Data storage _self, address _rootPlatformWallet) public {
        _self.rootPlatformAddress = _rootPlatformWallet;
        emit RootPlatformChanged(_rootPlatformWallet);

        setTrustedPlatformInternal(_self, _rootPlatformWallet, true, true);
    }

    /// @notice Set rate of AssetToken.
    /// @dev Rate is from BaseCurrency (currently EUR). E.g. rate 2 means 2 tokens per 1 EUR.
    /// @param _assetToken the regarding AssetToken the rate should be applied on.
    /// @param _rate the rate.
    function setAssetTokenRate(Data storage _self, address _assetToken, uint256 _rate) public {
        _self.store.setAssetTokenRate(_assetToken, _rate);
        emit AssetTokenRateChanged(_assetToken, _rate);
    }

    /// @notice If this contract gets a balance in some other ERC20 contract - or even iself - then we can rescue it.
    /// @param _foreignTokenAddress token where contract has balance.
    /// @param _to the beneficiary.
    function rescueToken(Data storage /*_self*/, address _foreignTokenAddress, address _to) public
    {
        ERC20Mintable(_foreignTokenAddress).transfer(_to, ERC20(_foreignTokenAddress).balanceOf(address(this)));
    }

///////////////////
// Events
///////////////////
    event AssetTokenAdded(address indexed initiator, address indexed wallet, address indexed assetToken, uint256 rate);
    event AssetTokenChangedActive(address indexed initiator, address indexed assetToken, bool active);
    event PlatformTrustChanged(address indexed platformWallet, bool trusted, bool isRootPlatform);
    event CrwdTokenAddressChanged(address indexed crwdToken);
    event AssetTokenRateChanged(address indexed assetToken, uint256 rate);
    event RootPlatformChanged(address indexed _rootPlatformWalletAddress);
    event CrowdsaleAssigned(address initiator, address indexed assetToken, address indexed crowdsale, address platformWallet);
    event ExchangeRateOracleSet(address indexed initiator, address indexed oracleAddress);
    event FeesPaid(address indexed from, address indexed to, uint256 value);
}

// File: contracts/controller/0_library/LibraryHolder.sol

/** @title LibraryHolder holds libraries used in inheritance bellow. */
contract LibraryHolder {
    using ControllerL for ControllerL.Data;

///////////////////
// Variables
///////////////////

    ControllerL.Data internal controllerData;
}

// File: contracts/controller/1_permissions/PermissionHolder.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/




/** @title PermissionHolder role permissions used in inheritance bellow. */
contract PermissionHolder  is AssetTokenAdministratorRole, At2CsConnectorRole, LibraryHolder {

}

// File: contracts/controller/2_provider/MainInfoProvider.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title MainInfoProvider holding simple getters and setters and events without much logic. */
contract MainInfoProvider is PermissionHolder {
    
///////////////////
// Events
///////////////////

    event AssetTokenAdded(address indexed initiator, address indexed wallet, address indexed assetToken, uint256 rate);
    event AssetTokenChangedActive(address indexed initiator, address indexed assetToken, bool active);
    event CrwdTokenAddressChanged(address indexed crwdToken);
    event ExchangeRateOracleSet(address indexed initiator, address indexed oracleAddress);
    event AssetTokenRateChanged(address indexed assetToken, uint256 rate);
    event RootPlatformChanged(address indexed _rootPlatformWalletAddress);
    event PlatformTrustChanged(address indexed platformWallet, bool trusted, bool isRootPlatform);
    event WhitelistSet(address indexed initiator, address indexed whitelistAddress);
    event CrowdsaleAssigned(address initiator, address indexed assetToken, address indexed crowdsale, address platformWallet);
    event FeesPaid(address indexed from, address indexed to, uint256 value);
    event TokenAssignment(address indexed to, uint256 tokensToMint, address indexed crowdsale, bytes8 tag);

///////////////////
// Methods (simple getters/setters ONLY)
///////////////////

    /// @notice Set CRWD token address (e.g. for fees).
    /// @param _crwdToken the CRWD token address.
    function setCrwdTokenAddress(address _crwdToken) public onlyRootPlatformAdministrator {
        controllerData.setCrwdTokenAddress(_crwdToken);
    }

    /// @notice Set exchange rate oracle address.
    /// @param _oracleAddress the address of the ExchangeRateOracle.
    function setOracle(address _oracleAddress) public onlyRootPlatformAdministrator {
        controllerData.setExchangeRateOracle(_oracleAddress);
    }

    /// @notice Get FeeTable for platform.
    /// @param _platform platform to find FeeTable for.
    /// @return address of FeeTable of platform.
    function getFeeTableAddressForPlatform(address _platform) public view returns (address) {
        return controllerData.getFeeTableAddressForPlatform(_platform);
    }   

    /// @notice Set rate of AssetToken.
    /// @dev Rate is from BaseCurrency (currently EUR). E.g. rate 2 means 2 tokens per 1 EUR.
    /// @param _assetToken the regarding AssetToken the rate should be applied on.
    /// @param _rate the rate. Unit is WAD (decimal number with 18 digits, so rate of x WAD is x*1e18).
    function setAssetTokenRate(address _assetToken, uint256 _rate) public onlyRootPlatformAdministrator {
        controllerData.setAssetTokenRate(_assetToken, _rate);
    }

    /// @notice Set root platform address. Root platform address can receive fees (independent of which Crowdsale/AssetToken).
    /// @param _rootPlatformWallet wallet of root platform.
    function setRootPlatform(address _rootPlatformWallet) public onlyRootPlatformAdministrator {
        controllerData.setRootPlatform(_rootPlatformWallet);
    }

    /// @notice Root platform wallet (receives fees according to it's FeeTable regardless of which Crowdsale/AssetToken)
    function getRootPlatform() public view returns (address) {
        return controllerData.rootPlatformAddress;
    }
    
    /// @notice Set platform address to trusted. A platform can receive fees.
    /// @param _platformWallet the wallet that will receive fees.
    /// @param _trusted true means trusted and false means not (=default).
    function setTrustedPlatform(address _platformWallet, bool _trusted) public onlyRootPlatformAdministrator {
        controllerData.setTrustedPlatform(_platformWallet, _trusted);
    }

    /// @notice Is trusted platform.
    /// @param _platformWallet platform wallet that recieves fees.
    /// @return true if trusted.
    function isTrustedPlatform(address _platformWallet) public view returns (bool) {
        return controllerData.trustedPlatform[_platformWallet];
    }

    /// @notice Get platform of crowdsale.
    /// @param _crowdsale the crowdsale to get platfrom from.
    /// @return address of owning platform.
    function getPlatformOfCrowdsale(address _crowdsale) public view returns (address) {
        return controllerData.crowdsaleToPlatform[_crowdsale];
    }

    /// @notice Set whitelist contrac address.
    /// @param _whitelistAddress the whitelist address.
    function setWhitelistContract(address _whitelistAddress) public onlyRootPlatformAdministrator {
        controllerData.whitelist = _whitelistAddress;

        emit WhitelistSet(msg.sender, _whitelistAddress);
    }

    /// @notice Get address of generic storage that survives an upgrade.
    /// @return address of storage.
    function getStorageAddress() public view returns (address) {
        return controllerData.getStorageAddress();
    }

    /// @notice Block new connections between AssetToken and Crowdsale (e.g. on upgrade)
    /// @param _isBlockNewActive true if no new AssetTokens or Crowdsales can be added to controller.
    function setBlockNewState(bool _isBlockNewActive) public onlyRootPlatformAdministrator {
        controllerData.blockNew = _isBlockNewActive;
    }

    /// @notice Gets state of block new.
    /// @return true if no new AssetTokens or Crowdsales can be added to controller.
    function getBlockNewState() public view returns (bool) {
        return controllerData.blockNew;
    }
}

// File: contracts/controller/3_manage/ManageAssetToken.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/



/** @title ManageAssetToken holds logic functions managing AssetTokens. */
contract ManageAssetToken  is MainInfoProvider {
    using SafeMath for uint256;

///////////////////
// Functions
///////////////////

    /// @notice Add trusted AssetToken.
    /// @param _ownerWallet requires CRWD for fees, receives ETH on successful campaign.
    /// @param _rate the rate of tokens per basecurrency (currently EUR).
    function addTrustedAssetToken(address _ownerWallet, address _assetToken, uint256 _rate) 
        public 
        onlyAssetTokenAdministrator 
    {
        controllerData.addTrustedAssetToken(_ownerWallet, _assetToken, _rate);
    }

    /// @notice Checks if a AssetToken is trusted.
    /// @param _assetToken the address of the AssetToken.
    function checkTrustedAssetToken(address _assetToken) public view returns (bool) {
        return controllerData.checkTrustedAssetToken(_assetToken);
    }

    /// @notice Can change the state of an AssetToken (e.g. blacklist for legal reasons)
    /// @param _assetToken the AssetToken to change state.
    /// @param _active the state. True means active.
    /// @return True if successful.
    function changeActiveTrustedAssetToken(address _assetToken, bool _active) public onlyRootPlatformAdministrator returns (bool) {
        return controllerData.changeActiveTrustedAssetToken(_assetToken, _active);
    }

    /// @notice Get fee that needs to be paid for certain AssetToken and FeeName.
    /// @param _assetToken the AssetToken being used.
    /// @param _tokenAmount the amount in tokens.
    /// @param _feeName the name of the fee being paid.
    /// @return amount of fees that would/will be paid.
    function getFeeKnowingAssetToken(
        address _assetToken, 
        address _from, 
        uint256 _tokenAmount, 
        bytes32 _feeName) 
        public view returns (uint256)
    {
        return controllerData.getFeeKnowingAssetToken(_assetToken, _from, _tokenAmount, _feeName);
    }

    /// @notice Convert eth amount into base currency (EUR), apply exchange rate via oracle, apply rate for AssetToken.
    /// @param _crowdsale the crowdsale address.
    /// @param _amountInWei the amount desired to be converted into tokens.
    function convertEthToTokenAmount(address _crowdsale, uint256 _amountInWei) public view returns (uint256 _tokens) {
        (uint256 tokens, ) = controllerData.convertEthToEurApplyRateGetTokenAmountFromCrowdsale(_crowdsale, _amountInWei);
        return tokens;
    }
}

// File: contracts/controller/3_manage/ManageFee.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title ManageAssetToken holds logic functions managing Fees. */
contract ManageFee is MainInfoProvider {

///////////////////
// Functions
///////////////////

    /// @notice Pay fee on controller call from AssetToken.
    /// @param _assetToken the calling AssetToken contract.
    /// @param _from the initiator passed through as parameter by AssetToken.
    /// @param _amount the tokens being handled.
    /// @param _feeName the name of the fee (key in mapping).
    function payFeeKnowingAssetToken(address _assetToken, address _from, uint256 _amount, bytes32 _feeName) internal {
        controllerData.payFeeKnowingAssetToken(_assetToken, _from, _amount, _feeName);
    }
}

// File: contracts/controller/3_manage/ManageCrowdsale.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** @title ManageAssetToken holds logic functions managing Crowdsales. */
contract ManageCrowdsale is MainInfoProvider {

///////////////////
// Functions
///////////////////

    /// @notice assign a crowdsale to an AssetToken.
    /// @param _assetToken the AssetToken being sold.
    /// @param _crowdsale the crowdsale that takes ETH (if enabled) and triggers assignment of tokens.
    /// @param _platformWallet the wallet of the platform. Fees are paid to this address.
    function assignCrowdsale(address _assetToken, address _crowdsale, address _platformWallet) 
        public 
        onlyAt2CsConnector 
    {
        controllerData.assignCrowdsale(_assetToken, _crowdsale, _platformWallet);
    }

    /// @notice Checks if a crowdsale is trusted.
    /// @param _crowdsale the address of the crowdsale.
    function checkTrustedCrowdsale(address _crowdsale) public view returns (bool) {
        return controllerData.checkTrustedCrowdsale(_crowdsale);
    }

    /// @notice Get fee that needs to be paid for certain Crowdsale and FeeName.
    /// @param _crowdsale the Crowdsale being used.
    /// @param _feeTableAddr the address of the feetable.
    /// @param _amountInTokensOrEth the amount in tokens or pure ETH when conversion parameter true.
    /// @param _amountRequiresConversion when true amount parameter is converted from ETH into tokens.
    /// @param _feeName the name of the fee being paid.
    /// @return amount of fees that would/will be paid.
    function getFeeKnowingCrowdsale(
        address _crowdsale, 
        address _feeTableAddr, 
        uint256 _amountInTokensOrEth, 
        bool _amountRequiresConversion,
        bytes32 _feeName) 
        public view returns (uint256) 
    {
        return controllerData.getFeeKnowingCrowdsale(_crowdsale, _feeTableAddr, _amountInTokensOrEth, _amountRequiresConversion, _feeName);
    }
}

// File: contracts/controller/3_manage/ManagePlatform.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/



/** @title ManageAssetToken holds logic functions managing platforms. */
contract ManagePlatform  is MainInfoProvider {

///////////////////
// Functions
///////////////////

    /// @notice Checks if a crowdsale is trusted or fail.
    /// @param _platformWallet the platform wallet.
    /// @return true if trusted.
    function checkTrustedPlatform(address _platformWallet) public view returns (bool) {
        return controllerData.checkTrustedPlatform(_platformWallet);
    }

    /// @notice Is a platform wallet trusted.
    /// @return true if trusted.
    function isTrustedPlatform(address _platformWallet) public view returns (bool) {
        return controllerData.trustedPlatform[_platformWallet];
    }
}

// File: contracts/controller/3_manage/ManageWhitelist.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/



/** @title ManageAssetToken holds logic functions managing Whitelist and KYC. */
contract ManageWhitelist  is MainInfoProvider {

///////////////////
// Functions
///////////////////

    /// @notice Check if a wallet is whitelisted or fail. Also considers auto extend (if enabled).
    /// @param _wallet the wallet to check.
    function checkWhitelistedWallet(address _wallet) public returns (bool) {
        controllerData.checkWhitelistedWallet(_wallet);
    }

    /// @notice Check if a wallet is whitelisted.
    /// @param _wallet the wallet to check.
    /// @return true if whitelisted.
    function isWhitelistedWallet(address _wallet) public view returns (bool) {
        controllerData.isWhitelistedWallet(_wallet);
    }
}

// File: contracts/controller/3_manage/ManagerHolder.sol

/*
    Copyright 2018, CONDA

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/






/** @title ManagerHolder combining all managers into single contract to be inherited. */
contract ManagerHolder is 
    ManageAssetToken, 
    ManageFee, 
    ManageCrowdsale,
    ManagePlatform,
    ManageWhitelist
{
}

// File: contracts/controller/interface/ICRWDController.sol

interface ICRWDController {
    function transferParticipantsVerification(address _underlyingCurrency, address _from, address _to, uint256 _tokenAmount) external returns (bool); //from AssetToken
    function buyFromCrowdsale(address _to, uint256 _amountInWei) external returns (uint256 _tokensCreated, uint256 _overpaidRefund); //from Crowdsale
    function assignFromCrowdsale(address _to, uint256 _tokenAmount, bytes8 _tag) external returns (uint256 _tokensCreated); //from Crowdsale
    function calcTokensForEth(uint256 _amountInWei) external view returns (uint256 _tokensWouldBeCreated); //from Crowdsale
}

// File: contracts/controller/CRWDController.sol

/** @title CRWDController main contract and n-th child of multi-level inheritance. */
contract CRWDController is ManagerHolder, ICRWDController {

///////////////////
// Events
///////////////////

    event GlobalConfigurationChanged(bool feesEnabled, bool whitelistEnabled);

///////////////////
// Constructor
///////////////////

    constructor(bool _feesEnabled, bool _whitelistEnabled, address _rootPlatformAddress, address _storage) public {
        controllerData.assignStore(_storage);
        
        setRootPlatform(_rootPlatformAddress);

        configure(_feesEnabled, _whitelistEnabled);
    }

///////////////////
// Functions
///////////////////

    /// @notice configure global flags.
    /// @param _feesEnabled global flag fees enabled.
    /// @param _whitelistEnabled global flag whitelist check enabled.
    function configure(bool _feesEnabled, bool _whitelistEnabled) public onlyRootPlatformAdministrator {
        controllerData.feesEnabled = _feesEnabled;
        controllerData.whitelistEnabled = _whitelistEnabled;

        emit GlobalConfigurationChanged(_feesEnabled, _whitelistEnabled);
    }

    /// @notice Called from AssetToken on transfer for whitelist check.
    /// @param _from the original initiator passed through.
    /// @param _to the receiver of the tokens.
    /// @param _tokenAmount the amount of tokens to be transfered.
    function transferParticipantsVerification(address /*_underlyingCurrency*/, address _from, address _to, uint256 _tokenAmount) public returns (bool) {

        if (controllerData.whitelistEnabled) {
            checkWhitelistedWallet(_to); //receiver must be whitelisted
        }

        // Caller must be a trusted AssetToken. Otherwise anyone could make investor pay fees for no reason. 
        require(checkTrustedAssetToken(msg.sender), "untrusted");

        if (controllerData.feesEnabled) {
            payFeeKnowingAssetToken(msg.sender, _from, _tokenAmount, "clearTransferFunds");
        }

        return true;
    }

    /// @notice Called from Crowdsale on buy token action (paid via Ether).
    /// @param _to the beneficiary of the tokens (passed through from Crowdsale).
    /// @param _amountInWei the ETH amount (unit WEI).
    function buyFromCrowdsale(address _to, uint256 _amountInWei) public returns (uint256 _tokensCreated, uint256 _overpaidRefund) {
        return controllerData.buyFromCrowdsale(_to, _amountInWei);
    }

    /// @notice Calculate how many tokens will be received per Ether.
    /// @param _amountInWei the ETH amount (unit WEI).
    /// @return tokens that would be created.
    function calcTokensForEth(uint256 _amountInWei) external view returns (uint256 _tokensWouldBeCreated) {
        require(checkTrustedCrowdsale(msg.sender), "untrusted source2");

        return convertEthToTokenAmount(msg.sender, _amountInWei);
    }

    /// @notice Called from Crowdsale via (semi-)automatic process on off-chain payment.
    /// @param _to the beneficiary of the tokens.
    /// @param _tokenAmount the amount of tokens to be minted/assigned.
    /// @return tokens created.
    function assignFromCrowdsale(address _to, uint256 _tokenAmount, bytes8 _tag) external returns (uint256 _tokensCreated) {
        _tokensCreated = controllerData.assignFromCrowdsale(_to, _tokenAmount);

        emit TokenAssignment(_to, _tokenAmount, msg.sender, _tag);

        return _tokensCreated;
    }

////////////////
// Rescue Tokens 
////////////////

    /// @dev Can rescue tokens accidentally assigned to this contract
    /// @param _foreignTokenAddress The address from which the balance will be retrieved
    /// @param _to beneficiary
    function rescueToken(address _foreignTokenAddress, address _to)
    public
    onlyRootPlatformAdministrator
    {
        controllerData.rescueToken(_foreignTokenAddress, _to);
    }
}
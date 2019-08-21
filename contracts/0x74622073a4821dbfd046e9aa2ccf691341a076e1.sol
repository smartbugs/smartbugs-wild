/*

    Copyright 2018 The Hydro Protocol Foundation

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity 0.4.24;

/// @dev Math operations with safety checks that revert on error
library SafeMath {

    /// @dev Multiplies two numbers, reverts on overflow.
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    /// @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        uint256 c = a / b;
        return c;
    }

    /// @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        uint256 c = a - b;
        return c;
    }

    /// @dev Adds two numbers, reverts on overflow.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    /// @dev Divides two numbers and returns the remainder (unsigned integer modulo), reverts when dividing by zero.
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "MOD_ERROR");
        return a % b;
    }
}

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control
/// functions, this simplifies the implementation of "user permissions".
contract LibOwnable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /// @return the address of the owner.
    function owner() public view returns(address) {
        return _owner;
    }

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(isOwner(), "NOT_OWNER");
        _;
    }

    /// @return true if `msg.sender` is the owner of the contract.
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    /// @dev Allows the current owner to relinquish control of the contract.
    /// @notice Renouncing to ownership will leave the contract without an owner.
    /// It will not be possible to call the functions with the `onlyOwner`
    /// modifier anymore.
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /// @dev Allows the current owner to transfer control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LibWhitelist is LibOwnable {
    mapping (address => bool) public whitelist;
    address[] public allAddresses;

    event AddressAdded(address indexed adr);
    event AddressRemoved(address indexed adr);

    /// @dev Only address in whitelist can invoke functions with this modifier.
    modifier onlyAddressInWhitelist {
        require(whitelist[msg.sender], "SENDER_NOT_IN_WHITELIST_ERROR");
        _;
    }

    /// @dev add Address into whitelist
    /// @param adr Address to add
    function addAddress(address adr) external onlyOwner {
        emit AddressAdded(adr);
        whitelist[adr] = true;
        allAddresses.push(adr);
    }

    /// @dev remove Address from whitelist
    /// @param adr Address to remove
    function removeAddress(address adr) external onlyOwner {
        emit AddressRemoved(adr);
        delete whitelist[adr];
        for(uint i = 0; i < allAddresses.length; i++){
            if(allAddresses[i] == adr) {
                allAddresses[i] = allAddresses[allAddresses.length - 1];
                allAddresses.length -= 1;
                break;
            }
        }
    }

    /// @dev Get all addresses in whitelist
    function getAllAddresses() external view returns (address[] memory) {
        return allAddresses;
    }
}

contract Proxy is LibWhitelist {
    using SafeMath for uint256;

    mapping( address => uint256 ) public balances;

    event Deposit(address owner, uint256 amount);
    event Withdraw(address owner, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function depositEther() public payable {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawEther(uint256 amount) public {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        msg.sender.transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function () public payable {
        depositEther();
    }

    /// @dev Invoking transferFrom.
    /// @param token Address of token to transfer.
    /// @param from Address to transfer token from.
    /// @param to Address to transfer token to.
    /// @param value Amount of token to transfer.
    function transferFrom(address token, address from, address to, uint256 value)
        external
        onlyAddressInWhitelist
    {
        if (token == address(0)) {
            transferEther(from, to, value);
        } else {
            transferToken(token, from, to, value);
        }
    }

    function transferEther(address from, address to, uint256 value)
        internal
        onlyAddressInWhitelist
    {
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);

        emit Transfer(from, to, value);
    }

    /// @dev Calls into ERC20 Token contract, invoking transferFrom.
    /// @param token Address of token to transfer.
    /// @param from Address to transfer token from.
    /// @param to Address to transfer token to.
    /// @param value Amount of token to transfer.
    function transferToken(address token, address from, address to, uint256 value)
        internal
        onlyAddressInWhitelist
    {
        assembly {

            // keccak256('transferFrom(address,address,uint256)') & 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000
            mstore(0, 0x23b872dd00000000000000000000000000000000000000000000000000000000)

            // calldatacopy(t, f, s) copy s bytes from calldata at position f to mem at position t
            // copy from, to, value from calldata to memory
            calldatacopy(4, 36, 96)

            // call ERC20 Token contract transferFrom function
            let result := call(gas, token, 0, 0, 100, 0, 32)

            // Some ERC20 Token contract doesn't return any value when calling the transferFrom function successfully.
            // So we consider the transferFrom call is successful in either case below.
            //   1. call successfully and nothing return.
            //   2. call successfully, return value is 32 bytes long and the value isn't equal to zero.
            switch eq(result, 1)
            case 1 {
                switch or(eq(returndatasize, 0), and(eq(returndatasize, 32), gt(mload(0), 0)))
                case 1 {
                    return(0, 0)
                }
            }
        }

        revert("TOKEN_TRANSFER_FROM_ERROR");
    }
}
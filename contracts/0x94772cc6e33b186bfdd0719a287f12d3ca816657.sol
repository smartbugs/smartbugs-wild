/*
    Copyright 2017-2019 Phillip A. Elsasser

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

pragma solidity 0.5.2;



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

/*
    Copyright 2017-2019 Phillip A. Elsasser

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




contract MarketContractRegistryInterface {
    function addAddressToWhiteList(address contractAddress) external;
    function isAddressWhiteListed(address contractAddress) external view returns (bool);
}



/// @title MarketContractRegistry
/// @author Phil Elsasser <phil@marketprotocol.io>
contract MarketContractRegistry is Ownable, MarketContractRegistryInterface {

    // whitelist accounting
    mapping(address => bool) public isWhiteListed;
    address[] public addressWhiteList;                             // record of currently deployed addresses;
    mapping(address => bool) public factoryAddressWhiteList;       // record of authorized factories

    // events
    event AddressAddedToWhitelist(address indexed contractAddress);
    event AddressRemovedFromWhitelist(address indexed contractAddress);
    event FactoryAddressAdded(address indexed factoryAddress);
    event FactoryAddressRemoved(address indexed factoryAddress);

    /*
    // External Methods
    */

    /// @notice determines if an address is a valid MarketContract
    /// @return false if the address is not white listed.
    function isAddressWhiteListed(address contractAddress) external view returns (bool) {
        return isWhiteListed[contractAddress];
    }

    /// @notice all currently whitelisted addresses
    /// returns array of addresses
    function getAddressWhiteList() external view returns (address[] memory) {
        return addressWhiteList;
    }

    /// @dev allows for the owner to remove a white listed contract, eventually ownership could transition to
    /// a decentralized smart contract of community members to vote
    /// @param contractAddress contract to removed from white list
    /// @param whiteListIndex of the contractAddress in the addressWhiteList to be removed.
    function removeContractFromWhiteList(
        address contractAddress,
        uint whiteListIndex
    ) external onlyOwner
    {
        require(isWhiteListed[contractAddress], "can only remove whitelisted addresses");
        require(addressWhiteList[whiteListIndex] == contractAddress, "index does not match address");
        isWhiteListed[contractAddress] = false;

        // push the last item in array to replace the address we are removing and then trim the array.
        addressWhiteList[whiteListIndex] = addressWhiteList[addressWhiteList.length - 1];
        addressWhiteList.length -= 1;
        emit AddressRemovedFromWhitelist(contractAddress);
    }

    /// @dev allows for the owner or factory to add a white listed contract, eventually ownership could transition to
    /// a decentralized smart contract of community members to vote
    /// @param contractAddress contract to removed from white list
    function addAddressToWhiteList(address contractAddress) external {
        require(isOwner() || factoryAddressWhiteList[msg.sender], "Can only be added by factory or owner");
        require(!isWhiteListed[contractAddress], "Address must not be whitelisted");
        isWhiteListed[contractAddress] = true;
        addressWhiteList.push(contractAddress);
        emit AddressAddedToWhitelist(contractAddress);
    }

    /// @dev allows for the owner to add a new address of a factory responsible for creating new market contracts
    /// @param factoryAddress address of factory to be allowed to add contracts to whitelist
    function addFactoryAddress(address factoryAddress) external onlyOwner {
        require(!factoryAddressWhiteList[factoryAddress], "address already added");
        factoryAddressWhiteList[factoryAddress] = true;
        emit FactoryAddressAdded(factoryAddress);
    }

    /// @dev allows for the owner to remove an address of a factory
    /// @param factoryAddress address of factory to be removed
    function removeFactoryAddress(address factoryAddress) external onlyOwner {
        require(factoryAddressWhiteList[factoryAddress], "factory address is not in the white list");
        factoryAddressWhiteList[factoryAddress] = false;
        emit FactoryAddressRemoved(factoryAddress);
    }
}
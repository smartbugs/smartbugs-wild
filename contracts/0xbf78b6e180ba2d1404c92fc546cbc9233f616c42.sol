pragma solidity 0.4.18;
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
  function Ownable() public {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
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
/// @title LRC Foundation Airdrop Address Binding Contract
/// @author Kongliang Zhong - <kongliang@loopring.org>,
contract LRxAirdropAddressBinding is Ownable {
    mapping(address => mapping(uint8 => string)) public bindings;
    mapping(uint8 => string) public projectNameMap;
    event AddressesBound(address sender, uint8 projectId, string targetAddr);
    event AddressesUnbound(address sender, uint8 projectId);
    // @projectId: 1=LRN, 2=LRQ
    function bind(uint8 projectId, string targetAddr)
        external
    {
        require(projectId > 0);
        bindings[msg.sender][projectId] = targetAddr;
        AddressesBound(msg.sender, projectId, targetAddr);
    }
    function unbind(uint8 projectId)
        external
    {
        require(projectId > 0);
        delete bindings[msg.sender][projectId];
        AddressesUnbound(msg.sender, projectId);
    }
    function getBindingAddress(address owner, uint8 projectId)
        external
        view
        returns (string)
    {
        require(projectId > 0);
        return bindings[owner][projectId];
    }
    function setProjectName(uint8 id, string name) onlyOwner external {
        projectNameMap[id] = name;
    }
}
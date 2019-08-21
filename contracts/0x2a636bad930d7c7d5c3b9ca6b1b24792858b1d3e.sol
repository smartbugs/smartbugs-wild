/*

  Copyright 2017 Cofound.it.

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
pragma solidity ^0.4.13;

contract Owned {
    address public owner;
    address public newOwner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }

    event OwnerUpdate(address _prevOwner, address _newOwner);
}

contract PriorityPassContract is Owned {

    struct Account {
    bool active;
    uint level;
    uint limit;
    bool wasActive;
    }

    uint public accountslength;
    mapping (uint => address) public accountIds;
    mapping (address => Account) public accounts;

    //
    // constructor
    //
    function PriorityPassContract() public { }

    //
    // @owner creates data for particular account
    // @param _accountAddress address for which we are setting the data
    // @param _level integer number that presents loyalty level
    // @param _limit integer number that presents limit within contribution can be made
    //
    function addNewAccount(address _accountAddress, uint _level, uint _limit) onlyOwner public {
        require(!accounts[_accountAddress].active);

        accounts[_accountAddress].active = true;
        accounts[_accountAddress].level = _level;
        accounts[_accountAddress].limit = _limit;

        if (!accounts[_accountAddress].wasActive) {
            accounts[_accountAddress].wasActive = true;
            accountIds[accountslength] = _accountAddress;
            accountslength++;
        }
    }

    //
    // @owner updates data for particular account
    // @param _accountAddress address for which we are setting the data
    // @param _level integer number that presents loyalty level
    // @param _limit integer number that presents limit within contribution can be made
    //
    function setAccountData(address _accountAddress, uint _level, uint _limit) onlyOwner public {
        require(accounts[_accountAddress].active);

        accounts[_accountAddress].level = _level;
        accounts[_accountAddress].limit = _limit;
    }

    //
    // @owner updates activity for particular account
    // @param _accountAddress address for which we are setting the data
    // @param _level bool value that presents activity level
    //
    function setActivity(address _accountAddress, bool _activity) onlyOwner public {
        accounts[_accountAddress].active = _activity;
    }

    //
    // @owner adds data for list of account
    // @param _accountAddresses array of accounts
    // @param _levels array of integer numbers corresponding to addresses order
    // @param _limits array of integer numbers corresponding to addresses order
    //
    function addOrUpdateAccounts(address[] _accountAddresses, uint[] _levels, uint[] _limits) onlyOwner public {
        require(_accountAddresses.length == _levels.length && _accountAddresses.length == _limits.length);

        for (uint cnt = 0; cnt < _accountAddresses.length; cnt++) {

            accounts[_accountAddresses[cnt]].active = true;
            accounts[_accountAddresses[cnt]].level = _levels[cnt];
            accounts[_accountAddresses[cnt]].limit = _limits[cnt];

            if (!accounts[_accountAddresses[cnt]].wasActive) {
                accounts[_accountAddresses[cnt]].wasActive = true;
                accountIds[accountslength] = _accountAddresses[cnt];
                accountslength++;
            }
        }
    }

    //
    // @public asks about account loyalty level for the account
    // @param _accountAddress address to get data for
    // @returns level for the account
    //
    function getAccountLevel(address _accountAddress) public constant returns (uint) {
        return accounts[_accountAddress].level;
    }

    //
    // @public asks about account limit of contribution for the account
    // @param _accountAddress address to get data for
    //
    function getAccountLimit(address _accountAddress) public constant returns (uint) {
        return accounts[_accountAddress].limit;
    }

    //
    // @public asks about account being active or not
    // @param _accountAddress address to get data for
    //
    function getAccountActivity(address _accountAddress) public constant returns (bool) {
        return accounts[_accountAddress].active;
    }

    //
    // @public asks about data of an account
    // @param _accountAddress address to get data for
    //
    function getAccountData(address _accountAddress) public constant returns (uint, uint, bool) {
        return (accounts[_accountAddress].level, accounts[_accountAddress].limit, accounts[_accountAddress].active);
    }
}
pragma solidity 0.4.11;

/**
 * Copyright 2017 NB
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract NB is owned {


    // Configuration
    mapping(string => string) private nodalblockConfig;

    // Service accounts
    mapping (address => bool) private srvAccount;

    struct data {
        string json;
    }
    mapping (string => data) private nodalblock;

    // Constructor
    function Nodalblock(){
        setConfig("code", "none");
    }

    function releaseFunds() onlyOwner {
        if(!owner.send(this.balance)) throw;
    }

    function addNodalblockData(string json) {

        setConfig("code", json);
    }

    function setConfig(string _key, string _value) onlyOwner {
        nodalblockConfig[_key] = _value;
    }

    function getConfig(string _key) constant returns (string _value) {
            return nodalblockConfig[_key];
        }

}
/**
 * Copyright 2016 Everex https://everex.io
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


/* String utility library */
library strUtils {
    string constant CHAINY_JSON_ID = '"id":"CHAINY"';
    uint8 constant CHAINY_JSON_MIN_LEN = 32;

    /* Converts given number to base58, limited by _maxLength symbols */
    function toBase58(uint256 _value, uint8 _maxLength) internal returns (string) {
        string memory letters = "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
        bytes memory alphabet = bytes(letters);
        uint8 base = 58;
        uint8 len = 0;
        uint256 remainder = 0;
        bool needBreak = false;
        bytes memory bytesReversed = bytes(new string(_maxLength));

        for (uint8 i = 0; i < _maxLength; i++) {
            if(_value < base){
                needBreak = true;
            }
            remainder = _value % base;
            _value = uint256(_value / base);
            bytesReversed[i] = alphabet[remainder];
            len++;
            if(needBreak){
                break;
            }
        }

        // Reverse
        bytes memory result = bytes(new string(len));
        for (i = 0; i < len; i++) {
            result[i] = bytesReversed[len - i - 1];
        }
        return string(result);
    }

    /* Concatenates two strings */
    function concat(string _s1, string _s2) internal returns (string) {
        bytes memory bs1 = bytes(_s1);
        bytes memory bs2 = bytes(_s2);
        string memory s3 = new string(bs1.length + bs2.length);
        bytes memory bs3 = bytes(s3);

        uint256 j = 0;
        for (uint256 i = 0; i < bs1.length; i++) {
            bs3[j++] = bs1[i];
        }
        for (i = 0; i < bs2.length; i++) {
            bs3[j++] = bs2[i];
        }

        return string(bs3);
    }

    /* Checks if provided JSON string has valid Chainy format */
    function isValidChainyJson(string _json) internal returns (bool) {
        bytes memory json = bytes(_json);
        bytes memory id = bytes(CHAINY_JSON_ID);

        if (json.length < CHAINY_JSON_MIN_LEN) {
            return false;
        } else {
            uint len = 0;
            if (json[1] == id[0]) {
                len = 1;
                while (len < id.length && (1 + len) < json.length && json[1 + len] == id[len]) {
                    len++;
                }
                if (len == id.length) {
                    return true;
                }
            }
        }

        return false;
    }
}


// Ownership
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract Chainy is owned {
    // Chainy viewer url
    string CHAINY_URL;

    // Configuration
    mapping(string => uint256) private chainyConfig;

    // Service accounts
    mapping (address => bool) private srvAccount;

    // Fee receiver
    address private receiverAddress;

    struct data {uint256 timestamp; string json; address sender;}
    mapping (string => data) private chainy;

    event chainyShortLink(uint256 timestamp, string code);

    // Constructor
    function Chainy(){
        setConfig("fee", 0);
        // change the block offset to 1000000 to use contract in testnet
        setConfig("blockoffset", 2000000);
        setChainyURL("https://txn.me/");
    }

    // Sets new Chainy viewer URL
    function setChainyURL(string _url) onlyOwner {
        CHAINY_URL = _url;
    }

    // Returns current Chainy viewer URL
    function getChainyURL() constant returns(string){
        return CHAINY_URL;
    }

    // Sets configuration option
    function setConfig(string _key, uint256 _value) onlyOwner {
        chainyConfig[_key] = _value;
    }

    // Returns configuration option
    function getConfig(string _key) constant returns (uint256 _value) {
        return chainyConfig[_key];
    }

    // Add/Remove service account
    function setServiceAccount(address _address, bool _value) onlyOwner {
        srvAccount[_address] = _value;
    }

    // Set receiver address
    function setReceiverAddress(address _address) onlyOwner {
        receiverAddress = _address;
    }

    // Send all ether back to owner
    function releaseFunds() onlyOwner {
        if(!owner.send(this.balance)) throw;
    }

    // Add record
    function addChainyData(string json) {
        checkFormat(json);

        var code = generateShortLink();
        // Checks if the record exist
        if (getChainyTimestamp(code) > 0) throw;

        processFee();
        chainy[code] = data({
            timestamp: block.timestamp,
            json: json,
            sender: tx.origin
        });

        // Fire event
        var link = strUtils.concat(CHAINY_URL, code);
        chainyShortLink(block.timestamp, link);
    }

    // Get record timestamp
    function getChainyTimestamp(string code) constant returns (uint256) {
        return chainy[code].timestamp;
    }

    // Get record JSON
    function getChainyData(string code) constant returns (string) {
        return chainy[code].json;
    }

    // Get record sender
    function getChainySender(string code) constant returns (address) {
        return chainy[code].sender;
    }

    // Checks if enough fee provided
    function processFee() internal {
        var fee = getConfig("fee");
        if (srvAccount[msg.sender] || (fee == 0)) return;

        if (msg.value < fee)
            throw;
        else
            if (!receiverAddress.send(fee)) throw;
    }

    // Checks if provided string has valid format
    function checkFormat(string json) internal {
        if (!strUtils.isValidChainyJson(json)) throw;
    }

    // Generates a shortlink code for this transaction
    function generateShortLink() internal returns (string) {
        var s1 = strUtils.toBase58(block.number - getConfig("blockoffset"), 11);
        var s2 = strUtils.toBase58(uint256(tx.origin), 2);

        var s = strUtils.concat(s1, s2);
        return s;
    }

}
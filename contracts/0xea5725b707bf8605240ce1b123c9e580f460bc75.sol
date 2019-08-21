pragma solidity ^0.4.11;

// copyright contact@bytether.com

contract BytetherOV {
    enum ResultCode { 
        SUCCESS,
        ERROR_EXIST,
        ERROR_NOT_EXIST
    }
    struct OwnerShip {
        address myEther;
        uint verifyCode;
        string referCode;
        uint createTime;
    }
    
    address public owner;
    address[] public moderators;
    uint public total = 0;
    bool public maintaining = false;
    
    // bitcoin_address -> OwnerShip list
    mapping(string => OwnerShip[]) items;

    // modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier isActive {
        require(maintaining != true);
        _;
    }

    modifier onlyModerators() {
        if (msg.sender != owner) {
            bool found = false;
            for (uint index = 0; index < moderators.length; index++) {
                if (moderators[index] == msg.sender) {
                    found = true;
                    break;
                }
            }
            require(found);
        }
        _;
    }

    function BytetherOV() public {
        owner = msg.sender;
    }

    // event
    event LogCreate(bytes32 indexed btcAddress, uint verifyCode, ResultCode result);
    
    // owner function
    function ChangeOwner(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }
    
    function Kill() onlyOwner public {
        selfdestruct(owner);
    }
    
    function ToggleMaintenance() onlyModerators public {
        maintaining = !maintaining;
    }
    
    function AddModerator(address _newModerator) onlyOwner public {
        for (uint index = 0; index < moderators.length; index++) {
            if (moderators[index] == _newModerator) {
                return;
            }
        }
        moderators.push(_newModerator);
    }
    
    function RemoveModerator(address _oldModerator) onlyOwner public {
        uint foundIndex = 0;
        for (; foundIndex < moderators.length; foundIndex++) {
            if (moderators[foundIndex] == _oldModerator) {
                break;
            }
        }
        if (foundIndex < moderators.length) {
            moderators[foundIndex] = moderators[moderators.length-1];
            delete moderators[moderators.length-1];
            moderators.length--;
        }
    }
    
    // moderator function
    function UnclockVerification(string _btcAddress, uint _verifyCode) onlyModerators public returns(ResultCode) {
        // remove from the verify code list
        var array = items[_btcAddress];
        for (uint i = 0; i<array.length; i++){
            if (array[i].verifyCode == _verifyCode) {
                if (i != array.length-1) {
                    array[i] = array[array.length-1];
                }
                delete array[array.length-1];
                array.length--;
                total--;
                return ResultCode.SUCCESS;
            }
        }
        return ResultCode.ERROR_NOT_EXIST;
    }
    
    // public function
    function GetOwnership(string _btcAddress, uint _verifyCode) constant public returns(address, string) {
        var array = items[_btcAddress];
        for (uint i=0; i<array.length; i++) {
            if (array[i].verifyCode == _verifyCode) {
                var item = array[i];
                return (item.myEther, item.referCode);
            }
        }
        return (0, "");
    }
    
    function AddOwnership(string _btcAddress, uint _verifyCode, string _referCode) isActive public returns(ResultCode) {
        bytes32 btcAddressHash = keccak256(_btcAddress);
        var array = items[_btcAddress];
        for (uint i=0; i<array.length; i++) {
            if (array[i].verifyCode == _verifyCode) {
                LogCreate(btcAddressHash, _verifyCode, ResultCode.ERROR_EXIST);
                return ResultCode.ERROR_EXIST;
            }
        }
        OwnerShip memory item;
        item.myEther = msg.sender;
        item.verifyCode = _verifyCode;
        item.referCode = _referCode;
        item.createTime = now;

        total++;
        array.push(item);
        LogCreate(btcAddressHash, _verifyCode, ResultCode.SUCCESS);
        return ResultCode.SUCCESS;
    }
    
    function GetVerifyCodes(string _btcAddress) constant public returns(uint[]) {
        var array = items[_btcAddress];
        uint[] memory verifyCodes = new uint[](array.length);
        for (uint i=0; i<array.length; i++) {
            verifyCodes[i] = array[i].verifyCode;
        }
        return verifyCodes;
    }
}
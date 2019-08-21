pragma solidity ^0.4.24;

// © 2018 SafeBlocks LTD.  All rights reserved.

/*
  _____            __          ____    _                  _
 / ____|          / _|        |  _ \  | |                | |
| (___     __ _  | |_    ___  | |_) | | |   ___     ___  | | __  ___
 \___ \   / _` | |  _|  / _ \ |  _ <  | |  / _ \   / __| | |/ / / __|
 ____) | | (_| | | |   |  __/ | |_) | | | | (_) | | (__  |   <  \__ \
|_____/   \__,_| |_|    \___| |____/  |_|  \___/   \___| |_|\_\ |___/

*/
// @author SafeBlocks
// @date 30/04/2018

contract SafeBlocksProxy {

    event AllowTransactionResult(address sourceAddress, bool approved, address token, uint amount, address destination, uint blockNumber);
    event AllowAccessResult(address sourceAddress, bool approved, address destination, bytes4 functionSig, uint blockNumber);
    event ConfigurationChanged(address sender, address newConfiguration, string message);

    address private owner;
    address private superOwner;
    bool private isBypassMode;
    bytes32 private hashedPwd;
    SafeBlocksFirewall private safeBlocksFirewall;

    constructor(address _superOwner, bytes32 _hashedPwd) public {
        owner = msg.sender;
        superOwner = _superOwner;
        hashedPwd = _hashedPwd;
        isBypassMode = false;
    }

    //*************************************** modifiers ****************************************

    modifier onlyContractOwner {
        require(owner == msg.sender, "You are not allowed to run this function, required role: Contract-Owner");
        _;
    }

    modifier onlySuperOwner {
        require(superOwner == msg.sender, "You are not allowed to run this function, required role: Super-Owner");
        _;
    }

    //* Matching  the given pwd and setting the new one in case of a successful match *//
    modifier onlySuperOwnerWithPwd(string pwd, bytes32 newHashedPwd) {
        require(superOwner == msg.sender && hashedPwd == keccak256(abi.encodePacked(pwd)), "You are not allowed to run this function, required role: Super-Owner with Password");
        hashedPwd = newHashedPwd;
        _;
    }

    //*************************************** restricted ****************************************

    function setSuperOwner(address newSuperOwner, string pwd, bytes32 newHashedPwd)
    onlySuperOwnerWithPwd(pwd, newHashedPwd)
    public {
        superOwner = newSuperOwner;
        emit ConfigurationChanged(msg.sender, newSuperOwner, "a new Super-Owner has been assigned");
    }

    function setOwner(address newOwner, string pwd, bytes32 newHashedPwd)
    onlySuperOwnerWithPwd(pwd, newHashedPwd)
    public {
        owner = newOwner;
        emit ConfigurationChanged(msg.sender, newOwner, "a new Owner has been assigned");
    }

    function setBypassForAll(bool _bypass)
    onlySuperOwner
    public {
        isBypassMode = _bypass;
        emit ConfigurationChanged(msg.sender, msg.sender, "a new Bypass-Mode has been assigned");
    }

    function getBypassStatus()
    public
    view
    onlyContractOwner
    returns (bool){
        return isBypassMode;
    }

    function setSBFWContractAddress(address _sbfwAddress)
    onlyContractOwner
    public {
        safeBlocksFirewall = SafeBlocksFirewall(_sbfwAddress);
        emit ConfigurationChanged(msg.sender, _sbfwAddress, "a new address has been assigned to SafeBlocksFirewall");
    }

    //*************************************** public ****************************************

    /*
     * Validating that the withdraw operation meets the constrains of the predefined security policy
     *
     * @returns true if the transaction meets the security policy conditions, else false.
     */
    function allowTransaction(uint _amount, address _destination, address _token)
    public
    returns (bool) {
        address senderAddress = msg.sender;

        if (isBypassMode) {
            emit AllowTransactionResult(senderAddress, true, _token, _amount, _destination, block.number);
            return true;
        }
        bool result = safeBlocksFirewall.allowTransaction(senderAddress, _amount, _destination, _token);
        emit AllowTransactionResult(senderAddress, result, _token, _amount, _destination, block.number);
        return result;
    }

    /*
    * Validating the given destination has access to the given functionSig according to the predefine access control list
    *
    * @returns true if access granted, else false.
    */
    function allowAccess(address _destination, bytes4 _functionSig)
    public
    returns (bool) {
        address senderAddress = msg.sender;

        if (isBypassMode) {
            emit AllowAccessResult(senderAddress, true, _destination, _functionSig, block.number);
            return true;
        }
        bool result = safeBlocksFirewall.allowAccess(senderAddress, _destination, _functionSig);
        emit AllowAccessResult(senderAddress, result, _destination, _functionSig, block.number);
        return result;
    }
}

interface SafeBlocksFirewall {

    /*
     * Validating that the withdraw operation meets the constrains of the predefined security policy
     *
     * @returns true if the transaction meets both of the conditions, else false.
     */
    function allowTransaction(
        address contractAddress,
        uint amount,
        address destination,
        address token)
    external
    returns (bool);

    /*
    * Validating the given destination has access to the given functionSig according to the predefine access control list
    *
    * @returns true if access granted, else false.
    */
    function allowAccess(
        address contractAddress,
        address destination,
        bytes4 functionSig)
    external
    returns (bool);
}

// © 2018 SafeBlocks LTD.  All rights reserved.
pragma solidity ^0.4.24;

/*
// © 2018 SafeBlocks LTD.  All rights reserved.

  _____            __          ____    _                  _
 / ____|          / _|        |  _ \  | |                | |
| (___     __ _  | |_    ___  | |_) | | |   ___     ___  | | __  ___
 \___ \   / _` | |  _|  / _ \ |  _ <  | |  / _ \   / __| | |/ / / __|
 ____) | | (_| | | |   |  __/ | |_) | | | | (_) | | (__  |   <  \__ \
|_____/   \__,_| |_|    \___| |____/  |_|  \___/   \___| |_|\_\ |___/


// @author SafeBlocks
// @date 30/04/2018
*/
contract SafeBlocksFirewall {

    event AllowTransactionEnquireResult(address sourceAddress, bool approved, address token, uint amount, address destination, string msg);
    event AllowAccessEnquireResult(address sourceAddress, bool approved, address destination, bytes4 functionSig, string msg);
    event PolicyChanged(address contractAddress, address destination, address tokenAdress, uint limit);
    event AccessChanged(address contractAddress, address destination, bytes4 functionSig, bool hasAccess);
    event ConfigurationChanged(address sender, address newConfiguration, string message);

    enum PolicyType {//Order matters(!)
        Transactions, //int value 0
        Access        //int value 1
    }

    enum PolicyEnforcementStatus {//Order matters(!)
        BlockAll, //int value 0
        AllowAll, //int value 1
        Enforce   //int value 2
    }

    address private owner;
    address private rulesOwner;
    address private proxyContract;
    bool private verbose;

    mapping(address /*contractAddress*/ => bool) private enforceBypass;
    mapping(address /*contractAddress*/ => mapping(address /*destination*/ => mapping(address /*tokenAddress*/ => uint256 /*limit*/))) private customerRules;
    mapping(address /*contractAddress*/ => mapping(bytes4 /*function-name*/ => mapping(address /*destination*/ => bool /*has-access*/))) private acl;
    mapping(address /*contractAddress*/ => mapping(bytes4 /*function-name*/ => bool)) private blockAllAccessForFunction;
    mapping(address /*contractAddress*/ => mapping(uint /*policy-type*/ => uint /*enforcement status*/)) private policiesEnforcementStatus;


    constructor() public {
        owner = msg.sender;
        verbose = false;
    }

    //*************************************** modifiers ****************************************

    modifier onlyContractOwner {
        require(owner == msg.sender, "You are not allowed to run this function, required role: Contract-Owner");
        _;
    }

    modifier onlyContractOwnerOrRulesOwner {
        require(owner == msg.sender || rulesOwner == msg.sender, "You are not allowed to run this function, required role: Contract-Owner or Rules-Owner");
        _;
    }

    modifier onlyRulesOwner {
        require(rulesOwner == msg.sender, "You are not allowed to run this function, required role: Rules-Owner");
        _;
    }

    modifier onlyProxy {
        require(proxyContract == msg.sender, "You are not allowed to run this function, required role: SafeBlocks-Proxy");
        _;
    }

    //*************************************** setters ****************************************

    function setProxyContract(address _proxy)
    onlyContractOwner
    public {
        proxyContract = _proxy;
        emit ConfigurationChanged(msg.sender, _proxy, "a new proxy contract address has been assigned");
    }

    function setRulesOwner(address _rulesOwner)
    public
    onlyContractOwner {
        rulesOwner = _rulesOwner;
        emit ConfigurationChanged(msg.sender, _rulesOwner, "a new Rules-Owner has been assigned");
    }

    function setVerbose(bool _verbose)
    onlyContractOwner
    public {
        verbose = _verbose;
        emit ConfigurationChanged(msg.sender, msg.sender, "a new Verbose-Mode has been assigned");
    }

    //*************************************** firewall functionality ****************************************

    function setBypassPerContract(address _contractAddress, bool _bypass)
    onlyRulesOwner
    public {
        enforceBypass[_contractAddress] = _bypass;
        if (verbose) emit PolicyChanged(_contractAddress, address(0), address(0), _bypass ? 1 : 0);
    }

    function setPolicyEnforcementStatus(address _contractAddress, uint _policyType, uint _policyEnforcementStatus)
    onlyRulesOwner
    public {
        policiesEnforcementStatus[_contractAddress][_policyType] = _policyEnforcementStatus;
    }

    function setBlockAllAccessPerContractFunction(address _contractAddress, bytes4 _functionSig, bool _isBlocked)
    onlyRulesOwner
    public {
        blockAllAccessForFunction[_contractAddress][_functionSig] = _isBlocked;
        if (verbose) emit AccessChanged(_contractAddress, address(0), _functionSig, _isBlocked);
    }

    function addRule(address _contractAddress, address _destination, address _token, uint256 _tokenLimit)
    onlyRulesOwner
    public {
        customerRules[_contractAddress][_destination][_token] = _tokenLimit;
        if (verbose) emit PolicyChanged(_contractAddress, _destination, _token, _tokenLimit);
    }

    function removeRule(address _contractAddress, address _destination, address _token)
    onlyRulesOwner
    public {
        delete customerRules[_contractAddress][_destination][_token];
        if (verbose) emit PolicyChanged(_contractAddress, _destination, _token, 0);
    }

    function addAccess(address _contractAddress, address _destination, bytes4 _functionSig)
    onlyRulesOwner
    public {
        acl[_contractAddress][_functionSig][_destination] = true;
        if (verbose) emit AccessChanged(_contractAddress, _destination, _functionSig, true);
    }

    function removeAccess(address _contractAddress, address _destination, bytes4 _functionSig)
    onlyRulesOwner
    public {
        delete acl[_contractAddress][_functionSig][_destination];
        if (verbose) emit AccessChanged(_contractAddress, _destination, _functionSig, false);
    }

    /*
     * Validating that the withdraw operation meets the constrains of the predefined security policy
     *
     * @returns true if the transaction meets the security policy conditions, else false.
     */
    function allowTransaction(address _contractAddress, uint _amount, address _destination, address _token)
    public
    onlyProxy
    returns (bool){
        if (enforceBypass[_contractAddress]) {//contract level bypass, across all policies
            if (verbose) emit AllowTransactionEnquireResult(_contractAddress, true, _token, _amount, _destination, "1");
            return true;
        }

        PolicyEnforcementStatus policyEnforcementStatus = PolicyEnforcementStatus(policiesEnforcementStatus[_contractAddress][uint(PolicyType.Transactions)]);
        if (PolicyEnforcementStatus.BlockAll == policyEnforcementStatus) {//block all activated
            if (verbose) emit AllowTransactionEnquireResult(_contractAddress, false, _token, _amount, _destination, "2");
            return false;
        }
        if (PolicyEnforcementStatus.AllowAll == policyEnforcementStatus) {//allow all activated
            if (verbose) emit AllowTransactionEnquireResult(_contractAddress, true, _token, _amount, _destination, "3");
            return true;
        }

        bool transactionAllowed = isTransactionAllowed(_contractAddress, _amount, _destination, _token);
        if (verbose) emit AllowTransactionEnquireResult(_contractAddress, transactionAllowed, _token, _amount, _destination, "4");
        return transactionAllowed;
    }

    /*
    * Validating the given destination has access to the given functionSig according to the predefine access control list
    *
    * @returns true if access granted, else false.
    */
    function allowAccess(address _contractAddress, address _destination, bytes4 _functionSig)
    public
    onlyProxy
    returns (bool){
        if (enforceBypass[_contractAddress]) {//contract level bypass, across all policies
            if (verbose) emit AllowAccessEnquireResult(_contractAddress, true, _destination, _functionSig, "1");
            return true;
        }

        PolicyEnforcementStatus policyEnforcementStatus = PolicyEnforcementStatus(policiesEnforcementStatus[_contractAddress][uint(PolicyType.Access)]);
        if (PolicyEnforcementStatus.BlockAll == policyEnforcementStatus) {//block all activated
            if (verbose) emit AllowAccessEnquireResult(_contractAddress, false, _destination, _functionSig, "2");
            return false;
        }
        if (PolicyEnforcementStatus.AllowAll == policyEnforcementStatus) {//allow all activated
            if (verbose) emit AllowAccessEnquireResult(_contractAddress, true, _destination, _functionSig, "3");
            return true;
        }

        bool hasAccessResult = hasAccess(_contractAddress, _destination, _functionSig);
        if (verbose) emit AllowAccessEnquireResult(_contractAddress, hasAccessResult, _destination, _functionSig, "4");
        return hasAccessResult;
    }

    //*************************************** private ****************************************

    function isTransactionAllowed(address _contractAddress, uint _amount, address _destination, address _token)
    private
    view
    returns (bool){
        uint256 limit = customerRules[_contractAddress][_destination][_token];
        uint256 anyDestinationLimit = customerRules[_contractAddress][0x0][_token];

        if (limit == 0 && anyDestinationLimit == 0) {//no rules ?? deny all
            return false;
        }
        if (anyDestinationLimit > 0 && limit == 0) {
            limit = anyDestinationLimit;
        }
        return _amount <= limit;
    }

    function hasAccess(address _contractAddress, address _destination, bytes4 _functionSig)
    private
    view
    returns (bool){
        bool blockAll = blockAllAccessForFunction[_contractAddress][_functionSig];
        if (blockAll) {
            return false;
        }
        bool allowAny = acl[_contractAddress][_functionSig][0x0];
        if (allowAny) {
            return true;
        }
        bool hasAccessResult = acl[_contractAddress][_functionSig][_destination];
        return hasAccessResult;
    }

    //*************************************** getters ****************************************

    function getPolicyEnforcementStatus(address _contractAddress, uint _policyType)
    public
    view
    onlyContractOwner
    returns (uint){
        return policiesEnforcementStatus[_contractAddress][_policyType];
    }

    function getBlockAllAccessForFunction(address _contractAddress, bytes4 _functionSig)
    public
    view
    onlyContractOwner
    returns (bool){
        blockAllAccessForFunction[_contractAddress][_functionSig];
    }

    function getEnforceBypass(address _contractAddress)
    public
    view
    onlyContractOwnerOrRulesOwner
    returns (bool){
        return (enforceBypass[_contractAddress]);
    }

    function getCustomerRules(address _contractAddress, address _destination, address _tokenAddress)
    public
    view
    onlyContractOwner
    returns (uint256){
        return (customerRules[_contractAddress][_destination][_tokenAddress]);
    }
}
// © 2018 SafeBlocks LTD.  All rights reserved.
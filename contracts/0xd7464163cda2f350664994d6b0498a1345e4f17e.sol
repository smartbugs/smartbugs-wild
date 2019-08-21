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

    event EnquireResult(address sourceAddress, bool approved, address token, uint amount, address destination, uint blockNumber, string msg);
    event PolicyChanged(address contractAddress, address destination, address tokenAdress, uint limit);
    event ConfigurationChanged(address sender, address newConfiguration, string message);

    address owner;
    address rulesOwner;
    address proxyContract;
    bool verbose;

    mapping(address /*contractId*/ => LimitsRule) limitsRule;
    mapping(address /*contractId*/ => uint) lastSuccessPerContract;
    mapping(address /*contractId*/ => mapping(address /*destination*/ => uint)) lastSuccessPerContractPerDestination;
    mapping(address /*contractId*/ => bool) blockAll;
    mapping(address /*contractId*/ => bool) enforceBypass;
    mapping(address /*contractId*/ => mapping(address /*destination*/ => mapping(address /*tokenAddress*/ => uint256 /*limit*/))) customerRules;

    struct LimitsRule {
        uint perAddressLimit;
        uint globalLimit;
    }

    constructor() public {
        owner = msg.sender;
        verbose = true;
    }

    //*************************************** modifiers ****************************************

    modifier onlyContractOwner {
        require(owner == msg.sender, "You are not allowed to run this function, required role: Contract-Owner");
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
        if (verbose) emit PolicyChanged(_contractAddress, address(0), address(0), _bypass ? 1 : 0);
        enforceBypass[_contractAddress] = _bypass;
        //to maintain default true we check if the enforce is set to *false*
    }

    function setBlockAllPerContract(address _contractId, bool _isBlocked)
    onlyRulesOwner
    public {
        if (verbose) emit PolicyChanged(_contractId, address(0), address(0), 0);
        blockAll[_contractId] = _isBlocked;
    }

    function setPerAddressLimit(address _contractId, uint _limit)
    onlyRulesOwner
    public {
        if (verbose) emit PolicyChanged(_contractId, address(0), address(0), _limit);
        limitsRule[_contractId].perAddressLimit = _limit;
    }

    function setGlobalLimit(address _contractId, uint _limit)
    onlyRulesOwner
    public {
        if (verbose) emit PolicyChanged(_contractId, address(0), address(0), _limit);
        limitsRule[_contractId].globalLimit = _limit;
    }

    function addRule(address _contractId, address _destination, address _token, uint256 _tokenLimit)
    onlyRulesOwner
    public {
        if (verbose) emit PolicyChanged(_contractId, _destination, _token, _tokenLimit);
        customerRules[_contractId][_destination][_token] = _tokenLimit;
    }

    function removeRule(address _contractId, address _destination, address _token)
    onlyRulesOwner
    public {
        if (verbose) emit PolicyChanged(_contractId, _destination, _token, 0);
        delete customerRules[_contractId][_destination][_token];
    }

    function allowTransaction(address _contractAddress, uint _amount, address _destination, address _token)
    public
    onlyProxy
    returns (bool){
        if (enforceBypass[_contractAddress]) {
            if (verbose) emit EnquireResult(_contractAddress, true, _token, _amount, _destination, block.number, "1");
            return true;
        }
        if (blockAll[_contractAddress]) {//if block all activated for this contract, deny all
            if (verbose) emit EnquireResult(_contractAddress, false, _token, _amount, _destination, block.number, "2");
            return false;
        }
        uint256 limit = customerRules[_contractAddress][_destination][_token];
        uint256 anyDestinationLimit = customerRules[_contractAddress][0x0][_token];

        if (limit == 0 && anyDestinationLimit == 0) {//no rules ?? deny all
            if (verbose) emit EnquireResult(_contractAddress, false, _token, _amount, _destination, block.number, "3");
            return false;
        }
        if (anyDestinationLimit > 0 && limit == 0) {
            limit = anyDestinationLimit;
        }
        if (_amount <= limit) {
            if (limitsRule[_contractAddress].perAddressLimit == 0 && limitsRule[_contractAddress].globalLimit == 0) {
                if (verbose) emit EnquireResult(_contractAddress, true, _token, _amount, _destination, block.number, "4");
                return true;
            }
            // no need to record and check rate limits;
            if (checkTimeFrameLimit(_contractAddress)) {
                if (checkAddressLimit(_contractAddress, _destination)) {
                    lastSuccessPerContract[_contractAddress] = block.number;
                    lastSuccessPerContractPerDestination[_contractAddress][_destination] = block.number;
                    if (verbose) emit EnquireResult(_contractAddress, true, _token, _amount, _destination, block.number, "5");
                    return true;
                }
            }
        }
        if (verbose) emit EnquireResult(_contractAddress, false, _token, _amount, _destination, block.number, "6");
        return false;
    }

    //*************************************** private ****************************************

    function checkAddressLimit(address _contractId, address _destination)
    private
    view
    returns (bool){
        if (lastSuccessPerContractPerDestination[_contractId][_destination] > 0) {
            if (block.number - lastSuccessPerContractPerDestination[_contractId][_destination] < limitsRule[_contractId].perAddressLimit) {
                return false;
            }
        }
        return true;
    }

    function checkTimeFrameLimit(address _contractId)
    private
    view
    returns (bool) {
        if (lastSuccessPerContract[_contractId] > 0) {
            if (block.number - lastSuccessPerContract[_contractId] < limitsRule[_contractId].globalLimit) {
                return false;
            }
        }
        return true;
    }

    //*************************************** getters ****************************************

    function getLimits(address _contractId)
    public
    view
    onlyContractOwner
    returns (uint, uint){
        return (limitsRule[_contractId].perAddressLimit, limitsRule[_contractId].globalLimit);
    }

    function getLastSuccessPerContract(address _contractId)
    public
    view
    onlyContractOwner
    returns (uint){
        return (lastSuccessPerContract[_contractId]);
    }

    function getLastSuccessPerContractPerDestination(address _contractId, address _destination)
    public
    view
    onlyContractOwner
    returns (uint){
        return (lastSuccessPerContractPerDestination[_contractId][_destination]);
    }

    function getBlockAll(address _contractId)
    public
    view
    onlyContractOwner
    returns (bool){
        return (blockAll[_contractId]);
    }

    function getEnforceBypass(address _contractId)
    public
    view
    onlyContractOwner
    returns (bool){
        return (enforceBypass[_contractId]);
    }

    function getCustomerRules(address _contractId, address _destination, address _tokenAddress)
    public
    view
    onlyContractOwner
    returns (uint256){
        return (customerRules[_contractId][_destination][_tokenAddress]);
    }
}
// © 2018 SafeBlocks LTD.  All rights reserved.
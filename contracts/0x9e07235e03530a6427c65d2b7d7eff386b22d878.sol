pragma solidity 0.4.18;

// File: contracts/ERC20Interface.sol

// https://github.com/ethereum/EIPs/issues/20
interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

// File: contracts/PermissionGroups.sol

contract PermissionGroups {

    address public admin;
    address public pendingAdmin;
    mapping(address=>bool) internal operators;
    mapping(address=>bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;
    uint constant internal MAX_GROUP_SIZE = 50;

    function PermissionGroups() public {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender]);
        _;
    }

    modifier onlyAlerter() {
        require(alerters[msg.sender]);
        _;
    }

    function getOperators () external view returns(address[]) {
        return operatorsGroup;
    }

    function getAlerters () external view returns(address[]) {
        return alertersGroup;
    }

    event TransferAdminPending(address pendingAdmin);

    /**
     * @dev Allows the current admin to set the pendingAdmin address.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(pendingAdmin);
        pendingAdmin = newAdmin;
    }

    /**
     * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(newAdmin);
        AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    event AdminClaimed( address newAdmin, address previousAdmin);

    /**
     * @dev Allows the pendingAdmin address to finalize the change admin process.
     */
    function claimAdmin() public {
        require(pendingAdmin == msg.sender);
        AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    event AlerterAdded (address newAlerter, bool isAdd);

    function addAlerter(address newAlerter) public onlyAdmin {
        require(!alerters[newAlerter]); // prevent duplicates.
        require(alertersGroup.length < MAX_GROUP_SIZE);

        AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    function removeAlerter (address alerter) public onlyAdmin {
        require(alerters[alerter]);
        alerters[alerter] = false;

        for (uint i = 0; i < alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.length--;
                AlerterAdded(alerter, false);
                break;
            }
        }
    }

    event OperatorAdded(address newOperator, bool isAdd);

    function addOperator(address newOperator) public onlyAdmin {
        require(!operators[newOperator]); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE);

        OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function removeOperator (address operator) public onlyAdmin {
        require(operators[operator]);
        operators[operator] = false;

        for (uint i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.length -= 1;
                OperatorAdded(operator, false);
                break;
            }
        }
    }
}

// File: contracts/Withdrawable.sol

/**
 * @title Contracts that should be able to recover tokens or ethers
 * @author Ilan Doron
 * @dev This allows to recover any tokens or Ethers received in a contract.
 * This will prevent any accidental loss of tokens.
 */
contract Withdrawable is PermissionGroups {

    event TokenWithdraw(ERC20 token, uint amount, address sendTo);

    /**
     * @dev Withdraw all ERC20 compatible tokens
     * @param token ERC20 The address of the token contract
     */
    function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {
        require(token.transfer(sendTo, amount));
        TokenWithdraw(token, amount, sendTo);
    }

    event EtherWithdraw(uint amount, address sendTo);

    /**
     * @dev Withdraw Ethers
     */
    function withdrawEther(uint amount, address sendTo) external onlyAdmin {
        sendTo.transfer(amount);
        EtherWithdraw(amount, sendTo);
    }
}

// File: contracts/wrapperContracts/WrapConversionRate.sol

contract ConversionRateWrapperInterface {
    function setQtyStepFunction(ERC20 token, int[] xBuy, int[] yBuy, int[] xSell, int[] ySell) public;
    function setImbalanceStepFunction(ERC20 token, int[] xBuy, int[] yBuy, int[] xSell, int[] ySell) public;
    function claimAdmin() public;
    function addOperator(address newOperator) public;
    function transferAdmin(address newAdmin) public;
    function addToken(ERC20 token) public;
    function setTokenControlInfo(
            ERC20 token,
            uint minimalRecordResolution,
            uint maxPerBlockImbalance,
            uint maxTotalImbalance
        ) public;
    function enableTokenTrade(ERC20 token) public;
    function getTokenControlInfo(ERC20 token) public view returns(uint, uint, uint);
}

contract WrapConversionRate is Withdrawable {

    ConversionRateWrapperInterface conversionRates;

    //add token parameters
    ERC20 public addTokenPendingToken;
    uint addTokenPendingMinimalResolution; // can be roughly 1 cent
    uint addTokenPendingMaxPerBlockImbalance; // in twei resolution
    uint addTokenPendingMaxTotalImbalance;
    address[] public addTokenApproveSignatures;
    
    //set token control info parameters.
    ERC20[] public setTokenInfoPendingTokenList;
    uint[]  public setTokenInfoPendingPerBlockImbalance; // in twei resolution
    uint[]  public setTokenInfoPendingMaxTotalImbalance;
    address[] public setTokenInfoApproveSignatures;

    function WrapConversionRate(ConversionRateWrapperInterface _conversionRates, address _admin) public {
        require (_conversionRates != address(0));
        require (_admin != address(0));
        conversionRates = _conversionRates;
        admin = _admin;
    }

    function claimWrappedContractAdmin() public onlyAdmin {
        conversionRates.claimAdmin();
        conversionRates.addOperator(this);
    }

    function transferWrappedContractAdmin (address newAdmin) public onlyAdmin {
        conversionRates.transferAdmin(newAdmin);
    }

    // add token functions
    //////////////////////
    function addTokenToApprove(ERC20 token, uint minimalRecordResolution, uint maxPerBlockImbalance, uint maxTotalImbalance) public onlyOperator {
        require(minimalRecordResolution != 0);
        require(maxPerBlockImbalance != 0);
        require(maxTotalImbalance != 0);
        require(token != address(0));

        //reset approve array. we have new parameters
        addTokenApproveSignatures.length = 0;
        addTokenPendingToken = token;
        addTokenPendingMinimalResolution = minimalRecordResolution; // can be roughly 1 cent
        addTokenPendingMaxPerBlockImbalance = maxPerBlockImbalance; // in twei resolution
        addTokenPendingMaxTotalImbalance = maxTotalImbalance;
        // Here don't assume this add as signature as well. if its a single operator. Rather he call approve function
    }

    function approveAddToken() public onlyOperator {
        for(uint i = 0; i < addTokenApproveSignatures.length; i++) {
            if (msg.sender == addTokenApproveSignatures[i]) require(false);
        }
        addTokenApproveSignatures.push(msg.sender);

        if (addTokenApproveSignatures.length == operatorsGroup.length) {
            // can perform operation.
            performAddToken();
        }
//        addTokenApproveSignatures.length == 0;
    }

    function performAddToken() internal {
        conversionRates.addToken(addTokenPendingToken);

        //token control info
        conversionRates.setTokenControlInfo(
            addTokenPendingToken,
            addTokenPendingMinimalResolution,
            addTokenPendingMaxPerBlockImbalance,
            addTokenPendingMaxTotalImbalance
        );

        //step functions
        int[] memory zeroArr = new int[](1);
        zeroArr[0] = 0;

        conversionRates.setQtyStepFunction(addTokenPendingToken, zeroArr, zeroArr, zeroArr, zeroArr);
        conversionRates.setImbalanceStepFunction(addTokenPendingToken, zeroArr, zeroArr, zeroArr, zeroArr);

        conversionRates.enableTokenTrade(addTokenPendingToken);
    }

    function getAddTokenParameters() public view returns(ERC20 token, uint minimalRecordResolution, uint maxPerBlockImbalance, uint maxTotalImbalance) {
        token = addTokenPendingToken;
        minimalRecordResolution = addTokenPendingMinimalResolution;
        maxPerBlockImbalance = addTokenPendingMaxPerBlockImbalance; // in twei resolution
        maxTotalImbalance = addTokenPendingMaxTotalImbalance;
    }
    
    //set token control info
    ////////////////////////
    function tokenInfoSetPendingTokens(ERC20 [] tokens) public onlyOperator {
        setTokenInfoApproveSignatures.length = 0;
        setTokenInfoPendingTokenList = tokens;
    }

    function tokenInfoSetMaxPerBlockImbalanceList(uint[] maxPerBlockImbalanceValues) public onlyOperator {
        require(maxPerBlockImbalanceValues.length == setTokenInfoPendingTokenList.length);
        setTokenInfoApproveSignatures.length = 0;
        setTokenInfoPendingPerBlockImbalance = maxPerBlockImbalanceValues;
    }

    function tokenInfoSetMaxTotalImbalanceList(uint[] maxTotalImbalanceValues) public onlyOperator {
        require(maxTotalImbalanceValues.length == setTokenInfoPendingTokenList.length);
        setTokenInfoApproveSignatures.length = 0;
        setTokenInfoPendingMaxTotalImbalance = maxTotalImbalanceValues;
    }

    function approveSetTokenControlInfo() public onlyOperator {
        for(uint i = 0; i < setTokenInfoApproveSignatures.length; i++) {
            if (msg.sender == setTokenInfoApproveSignatures[i]) require(false);
        }
        setTokenInfoApproveSignatures.push(msg.sender);

        if (setTokenInfoApproveSignatures.length == operatorsGroup.length) {
            // can perform operation.
            performSetTokenControlInfo();
        }
    }

    function performSetTokenControlInfo() internal {
        require(setTokenInfoPendingTokenList.length == setTokenInfoPendingPerBlockImbalance.length);
        require(setTokenInfoPendingTokenList.length == setTokenInfoPendingMaxTotalImbalance.length);

        uint minimalRecordResolution;
        uint rxMaxPerBlockImbalance;
        uint rxMaxTotalImbalance;

        for (uint i = 0; i < setTokenInfoPendingTokenList.length; i++) {
            (minimalRecordResolution, rxMaxPerBlockImbalance, rxMaxTotalImbalance) =
                conversionRates.getTokenControlInfo(setTokenInfoPendingTokenList[i]);
            require(minimalRecordResolution != 0);

            conversionRates.setTokenControlInfo(setTokenInfoPendingTokenList[i],
                                                minimalRecordResolution,
                                                setTokenInfoPendingPerBlockImbalance[i],
                                                setTokenInfoPendingMaxTotalImbalance[i]);
        }
    }

    function getControlInfoTokenlist() public view returns(ERC20[] tokens) {
        tokens = setTokenInfoPendingTokenList;
    }

    function getControlInfoMaxPerBlockImbalanceList() public view returns(uint[] maxPerBlockImbalanceValues) {
        maxPerBlockImbalanceValues = setTokenInfoPendingPerBlockImbalance;
    }

    function getControlInfoMaxTotalImbalanceList() public view returns(uint[] maxTotalImbalanceValues) {
        maxTotalImbalanceValues = setTokenInfoPendingMaxTotalImbalance;
    }
}
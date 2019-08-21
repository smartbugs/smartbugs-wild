/* Verified by 3esmit
 
- Bytecode Verification performed was compared on second iteration -

This file is part of the HONG.

The HONG is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The HONG is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the HONG.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
 * Parent contract that contains all of the configurable parameters of the main contract.
 */
contract HongConfiguration {
    uint public closingTime;
    uint public weiPerInitialHONG = 10**16;
    string public name = "HONG";
    string public symbol = "Ħ";
    uint8 public decimals = 0;
    uint public maxBountyTokens = 2 * (10**6);
    uint public closingTimeExtensionPeriod = 30 days;
    uint public minTokensToCreate = 100 * (10**6);
    uint public maxTokensToCreate = 250 * (10**6);
    uint public tokensPerTier = 50 * (10**6);
    uint public lastKickoffDateBuffer = 304 days;

    uint public mgmtRewardPercentage = 20;
    uint public mgmtFeePercentage = 8;

    uint public harvestQuorumPercent = 20;
    uint public freezeQuorumPercent = 50;
    uint public kickoffQuorumPercent = 20;
}

contract ErrorHandler {
    bool public isInTestMode = false;
    event evRecord(address msg_sender, uint msg_value, string message);
    function doThrow(string message) internal {
        evRecord(msg.sender, msg.value, message);
        if(!isInTestMode){
            throw;
        }
    }
}

contract TokenInterface is ErrorHandler {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public tokensCreated;

    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _amount) returns (bool success);

    event evTransfer(address msg_sender, uint msg_value, address indexed _from, address indexed _to, uint256 _amount);

    // Modifier that allows only token holders to trigger
    modifier onlyTokenHolders {
        if (balanceOf(msg.sender) == 0) doThrow("onlyTokenHolders"); else {_}
    }
}

contract Token is TokenInterface {
    // Protects users by preventing the execution of method calls that
    // inadvertently also transferred ether
    modifier noEther() {if (msg.value > 0) doThrow("noEther"); else{_}}
    modifier hasEther() {if (msg.value <= 0) doThrow("hasEther"); else{_}}

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool success) {
        if (_amount <= 0) return false;
        if (balances[msg.sender] < _amount) return false;
        if (balances[_to] + _amount < balances[_to]) return false;

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        evTransfer(msg.sender, msg.value, msg.sender, _to, _amount);

        return true;
    }
}


contract OwnedAccount is ErrorHandler {
    address public owner;
    bool acceptDeposits = true;

    event evPayOut(address msg_sender, uint msg_value, address indexed _recipient, uint _amount);

    modifier onlyOwner() {
        if (msg.sender != owner) doThrow("onlyOwner");
        else {_}
    }

    modifier noEther() {
        if (msg.value > 0) doThrow("noEther");
        else {_}
    }

    function OwnedAccount(address _owner) {
        owner = _owner;
    }

    function payOutPercentage(address _recipient, uint _percent) internal onlyOwner noEther {
        payOutAmount(_recipient, (this.balance * _percent) / 100);
    }

    function payOutAmount(address _recipient, uint _amount) internal onlyOwner noEther {
        // send does not forward enough gas to see that this is a managed account call
        if (!_recipient.call.value(_amount)())
            doThrow("payOut:sendFailed");
        else
            evPayOut(msg.sender, msg.value, _recipient, _amount);
    }

    function () returns (bool success) {
        if (!acceptDeposits) throw;
        return true;
    }
}

contract ReturnWallet is OwnedAccount {
    address public mgmtBodyWalletAddress;

    bool public inDistributionMode;
    uint public amountToDistribute;
    uint public totalTokens;
    uint public weiPerToken;

    function ReturnWallet(address _mgmtBodyWalletAddress) OwnedAccount(msg.sender) {
        mgmtBodyWalletAddress = _mgmtBodyWalletAddress;
    }

    function payManagementBodyPercent(uint _percent) {
        payOutPercentage(mgmtBodyWalletAddress, _percent);
    }

    function switchToDistributionMode(uint _totalTokens) onlyOwner {
        inDistributionMode = true;
        acceptDeposits = false;
        totalTokens = _totalTokens;
        amountToDistribute = this.balance;
        weiPerToken = amountToDistribute / totalTokens;
    }

    function payTokenHolderBasedOnTokenCount(address _tokenHolderAddress, uint _tokens) onlyOwner {
        payOutAmount(_tokenHolderAddress, weiPerToken * _tokens);
    }
}

contract ExtraBalanceWallet is OwnedAccount {
    address returnWalletAddress;
    function ExtraBalanceWallet(address _returnWalletAddress) OwnedAccount(msg.sender) {
        returnWalletAddress = _returnWalletAddress;
    }

    function returnBalanceToMainAccount() {
        acceptDeposits = false;
        payOutAmount(owner, this.balance);
    }

    function returnAmountToMainAccount(uint _amount) {
        payOutAmount(owner, _amount);
    }

    function payBalanceToReturnWallet() {
        acceptDeposits = false;
        payOutAmount(returnWalletAddress, this.balance);
    }

}

contract RewardWallet is OwnedAccount {
    address public returnWalletAddress;
    function RewardWallet(address _returnWalletAddress) OwnedAccount(msg.sender) {
        returnWalletAddress = _returnWalletAddress;
    }

    function payBalanceToReturnWallet() {
        acceptDeposits = false;
        payOutAmount(returnWalletAddress, this.balance);
    }
}

contract ManagementFeeWallet is OwnedAccount {
    address public mgmtBodyAddress;
    address public returnWalletAddress;
    function ManagementFeeWallet(address _mgmtBodyAddress, address _returnWalletAddress) OwnedAccount(msg.sender) {
        mgmtBodyAddress = _mgmtBodyAddress;
        returnWalletAddress  = _returnWalletAddress;
    }

    function payManagementBodyAmount(uint _amount) {
        payOutAmount(mgmtBodyAddress, _amount);
    }

    function payBalanceToReturnWallet() {
        acceptDeposits = false;
        payOutAmount(returnWalletAddress, this.balance);
    }
}

/*
 * Token Creation contract, similar to other organization,for issuing tokens and initialize
 * its ether fund.
*/
contract TokenCreationInterface is HongConfiguration {

    address public managementBodyAddress;

    ExtraBalanceWallet public extraBalanceWallet;
    mapping (address => uint256) weiGiven;
    mapping (address => uint256) public taxPaid;

    function createTokenProxy(address _tokenHolder) internal returns (bool success);
    function refundMyIcoInvestment();
    function divisor() constant returns (uint divisor);

    event evMinTokensReached(address msg_sender, uint msg_value, uint value);
    event evCreatedToken(address msg_sender, uint msg_value, address indexed to, uint amount);
    event evRefund(address msg_sender, uint msg_value, address indexed to, uint value, bool result);
}

contract GovernanceInterface is ErrorHandler, HongConfiguration {

    // The variable indicating whether the fund has achieved the inital goal or not.
    // This value is automatically set, and CANNOT be reversed.
    bool public isFundLocked;
    bool public isFundReleased;

    modifier notLocked() {if (isFundLocked) doThrow("notLocked"); else {_}}
    modifier onlyLocked() {if (!isFundLocked) doThrow("onlyLocked"); else {_}}
    modifier notReleased() {if (isFundReleased) doThrow("notReleased"); else {_}}
    modifier onlyHarvestEnabled() {if (!isHarvestEnabled) doThrow("onlyHarvestEnabled"); else {_}}
    modifier onlyDistributionNotInProgress() {if (isDistributionInProgress) doThrow("onlyDistributionNotInProgress"); else {_}}
    modifier onlyDistributionNotReady() {if (isDistributionReady) doThrow("onlyDistributionNotReady"); else {_}}
    modifier onlyDistributionReady() {if (!isDistributionReady) doThrow("onlyDistributionReady"); else {_}}
    modifier onlyCanIssueBountyToken(uint _amount) {
        if (bountyTokensCreated + _amount > maxBountyTokens){
            doThrow("hitMaxBounty");
        }
        else {_}
    }
    modifier onlyFinalFiscalYear() {
        // Only call harvest() in the final fiscal year
        if (currentFiscalYear < 4) doThrow("currentFiscalYear<4"); else {_}
    }
    modifier notFinalFiscalYear() {
        // Token holders cannot freeze fund at the 4th Fiscal Year after passing `kickoff(4)` voting
        if (currentFiscalYear >= 4) doThrow("currentFiscalYear>=4"); else {_}
    }
    modifier onlyNotFrozen() {
        if (isFreezeEnabled) doThrow("onlyNotFrozen"); else {_}
    }

    bool public isDayThirtyChecked;
    bool public isDaySixtyChecked;

    uint256 public bountyTokensCreated;
    uint public currentFiscalYear;
    uint public lastKickoffDate;
    mapping (uint => bool) public isKickoffEnabled;
    bool public isFreezeEnabled;
    bool public isHarvestEnabled;
    bool public isDistributionInProgress;
    bool public isDistributionReady;

    ReturnWallet public returnWallet;
    RewardWallet public rewardWallet;
    ManagementFeeWallet public managementFeeWallet;

    // define the governance of this organization and critical functions
    function mgmtIssueBountyToken(address _recipientAddress, uint _amount) returns (bool);
    function mgmtDistribute();

    function mgmtInvestProject(
        address _projectWallet,
        uint _amount
    ) returns (bool);

    event evIssueManagementFee(address msg_sender, uint msg_value, uint _amount, bool _success);
    event evMgmtIssueBountyToken(address msg_sender, uint msg_value, address _recipientAddress, uint _amount, bool _success);
    event evMgmtDistributed(address msg_sender, uint msg_value, uint256 _amount, bool _success);
    event evMgmtInvestProject(address msg_sender, uint msg_value, address _projectWallet, uint _amount, bool result);
    event evLockFund(address msg_sender, uint msg_value);
    event evReleaseFund(address msg_sender, uint msg_value);
}


contract TokenCreation is TokenCreationInterface, Token, GovernanceInterface {
    modifier onlyManagementBody {
        if(msg.sender != address(managementBodyAddress)) {doThrow("onlyManagementBody");} else {_}
    }

    function TokenCreation(
        address _managementBodyAddress,
        uint _closingTime) {

        managementBodyAddress = _managementBodyAddress;
        closingTime = _closingTime;
    }

    function createTokenProxy(address _tokenHolder) internal notLocked notReleased hasEther returns (bool success) {

        // Business logic (but no state changes)
        // setup transaction details
        uint tokensSupplied = 0;
        uint weiAccepted = 0;
        bool wasMinTokensReached = isMinTokensReached();

        var weiPerLatestHONG = weiPerInitialHONG * divisor() / 100;
        uint remainingWei = msg.value;
        uint tokensAvailable = tokensAvailableAtCurrentTier();
        if (tokensAvailable == 0) {
            doThrow("noTokensToSell");
            return false;
        }

        // Sell tokens in batches based on the current price.
        while (remainingWei >= weiPerLatestHONG) {
            uint tokensRequested = remainingWei / weiPerLatestHONG;
            uint tokensToSellInBatch = min(tokensAvailable, tokensRequested);

            // special case.  Allow the last purchase to go over the max
            if (tokensAvailable == 0 && tokensCreated == maxTokensToCreate) {
                tokensToSellInBatch = tokensRequested;
            }

            uint priceForBatch = tokensToSellInBatch * weiPerLatestHONG;

            // track to total wei accepted and total tokens supplied
            weiAccepted += priceForBatch;
            tokensSupplied += tokensToSellInBatch;

            // update state
            balances[_tokenHolder] += tokensToSellInBatch;
            tokensCreated += tokensToSellInBatch;
            weiGiven[_tokenHolder] += priceForBatch;

            // update dependent values (state has changed)
            weiPerLatestHONG = weiPerInitialHONG * divisor() / 100;
            remainingWei = msg.value - weiAccepted;
            tokensAvailable = tokensAvailableAtCurrentTier();
        }

        // the caller will still pay this amount, even though it didn't buy any tokens.
        weiGiven[_tokenHolder] += remainingWei;

        // when the caller is paying more than 10**16 wei (0.01 Ether) per token, the extra is basically a tax.
        uint256 totalTaxLevied = weiAccepted - tokensSupplied * weiPerInitialHONG;
        taxPaid[_tokenHolder] += totalTaxLevied;

        // State Changes (no external calls)
        tryToLockFund();

        // External calls
        if (totalTaxLevied > 0) {
            if (!extraBalanceWallet.send(totalTaxLevied)){
                doThrow("extraBalance:sendFail");
                return;
            }
        }

        // Events.  Safe to publish these now that we know it all worked
        evCreatedToken(msg.sender, msg.value, _tokenHolder, tokensSupplied);
        if (!wasMinTokensReached && isMinTokensReached()) evMinTokensReached(msg.sender, msg.value, tokensCreated);
        if (isFundLocked) evLockFund(msg.sender, msg.value);
        if (isFundReleased) evReleaseFund(msg.sender, msg.value);
        return true;
    }

    function refundMyIcoInvestment() noEther notLocked onlyTokenHolders {
        // 1: Preconditions
        if (weiGiven[msg.sender] == 0) {
            doThrow("noWeiGiven");
            return;
        }
        if (balances[msg.sender] > tokensCreated) {
            doThrow("invalidTokenCount");
            return;
         }

        // 2: Business logic
        bool wasMinTokensReached = isMinTokensReached();
        var tmpWeiGiven = weiGiven[msg.sender];
        var tmpTaxPaidBySender = taxPaid[msg.sender];
        var tmpSenderBalance = balances[msg.sender];

        var amountToRefund = tmpWeiGiven;

        // 3: state changes.
        balances[msg.sender] = 0;
        weiGiven[msg.sender] = 0;
        taxPaid[msg.sender] = 0;
        tokensCreated -= tmpSenderBalance;

        // 4: external calls
        // Pull taxes paid back into this contract (they would have been paid into the extraBalance account)
        extraBalanceWallet.returnAmountToMainAccount(tmpTaxPaidBySender);

        // If that works, then do a refund
        if (!msg.sender.send(amountToRefund)) {
            evRefund(msg.sender, msg.value, msg.sender, amountToRefund, false);
            doThrow("refund:SendFailed");
            return;
        }

        evRefund(msg.sender, msg.value, msg.sender, amountToRefund, true);
        if (!wasMinTokensReached && isMinTokensReached()) evMinTokensReached(msg.sender, msg.value, tokensCreated);
    }

    // Using a function rather than a state variable, as it reduces the risk of inconsistent state
    function isMinTokensReached() constant returns (bool) {
        return tokensCreated >= minTokensToCreate;
    }

    function isMaxTokensReached() constant returns (bool) {
        return tokensCreated >= maxTokensToCreate;
    }

    function mgmtIssueBountyToken(
        address _recipientAddress,
        uint _amount
    ) noEther onlyManagementBody onlyCanIssueBountyToken(_amount) returns (bool){
        // send token to the specified address
        balances[_recipientAddress] += _amount;
        bountyTokensCreated += _amount;

        // event
        evMgmtIssueBountyToken(msg.sender, msg.value, _recipientAddress, _amount, true);

    }

    function mgmtDistribute() onlyManagementBody hasEther onlyHarvestEnabled onlyDistributionNotReady {
        distributeDownstream(mgmtRewardPercentage);
    }

    function distributeDownstream(uint _mgmtPercentage) internal onlyDistributionNotInProgress {

        // transfer all balance from the following accounts
        // (1) HONG main account,
        // (2) managementFeeWallet,
        // (3) rewardWallet
        // (4) extraBalanceWallet
        // to returnWallet

        // And allocate _mgmtPercentage of the fund to ManagementBody

        // State changes first (even though it feels backwards)
        isDistributionInProgress = true;
        isDistributionReady = true;

        payBalanceToReturnWallet();
        managementFeeWallet.payBalanceToReturnWallet();
        rewardWallet.payBalanceToReturnWallet();
        extraBalanceWallet.payBalanceToReturnWallet();

        // transfer _mgmtPercentage of returns to mgmt Wallet
        if (_mgmtPercentage > 0) returnWallet.payManagementBodyPercent(_mgmtPercentage);
        returnWallet.switchToDistributionMode(tokensCreated + bountyTokensCreated);

        // Token holder can claim the remaining fund (the total amount harvested/ to be distributed) starting from here
        evMgmtDistributed(msg.sender, msg.value, returnWallet.balance, true);
        isDistributionInProgress = false;
    }

    function payBalanceToReturnWallet() internal {
        if (!returnWallet.send(this.balance))
            doThrow("payBalanceToReturnWallet:sendFailed");
            return;
    }

    function min(uint a, uint b) constant internal returns (uint) {
        return (a < b) ? a : b;
    }

    function tryToLockFund() internal {
        // ICO Diagram: https://github.com/hongcoin/DO/wiki/ICO-Period-and-Target

        if (isFundReleased) {
            // Do not change the state anymore
            return;
        }

        // Case A
        isFundLocked = isMaxTokensReached();

        // if we've reached the 30 day mark, try to lock the fund
        if (!isFundLocked && !isDayThirtyChecked && (now >= closingTime)) {
            if (isMinTokensReached()) {
                // Case B
                isFundLocked = true;
            }
            isDayThirtyChecked = true;
        }

        // if we've reached the 60 day mark, try to lock the fund
        if (!isFundLocked && !isDaySixtyChecked && (now >= (closingTime + closingTimeExtensionPeriod))) {
            if (isMinTokensReached()) {
                // Case C
                isFundLocked = true;
            }
            isDaySixtyChecked = true;
        }

        if (isDaySixtyChecked && !isMinTokensReached()) {
            // Case D
            // Mark the release state. No fund should be accepted anymore
            isFundReleased = true;
        }
    }

    function tokensAvailableAtTierInternal(uint8 _currentTier, uint _tokensPerTier, uint _tokensCreated) constant returns (uint) {
        uint tierThreshold = (_currentTier+1) * _tokensPerTier;

        // never go above maxTokensToCreate, which could happen if the max is not a multiple of _tokensPerTier
        if (tierThreshold > maxTokensToCreate) {
            tierThreshold = maxTokensToCreate;
        }

        // this can happen on the final purchase in the last tier
        if (_tokensCreated > tierThreshold) {
            return 0;
        }

        return tierThreshold - _tokensCreated;
    }

    function tokensAvailableAtCurrentTier() constant returns (uint) {
        return tokensAvailableAtTierInternal(getCurrentTier(), tokensPerTier, tokensCreated);
    }

    function getCurrentTier() constant returns (uint8) {
        uint8 tier = (uint8) (tokensCreated / tokensPerTier);
        return (tier > 4) ? 4 : tier;
    }

    function pricePerTokenAtCurrentTier() constant returns (uint) {
        return weiPerInitialHONG * divisor() / 100;
    }

    function divisor() constant returns (uint divisor) {

        // Quantity divisor model: based on total quantity of coins issued
        // Price ranged from 1.0 to 1.20 Ether for all HONG Tokens with a 0.05 ETH increase for each tier

        // The number of (base unit) tokens per wei is calculated
        // as `msg.value` * 100 / `divisor`

        return 100 + getCurrentTier() * 5;
    }
}


contract HONGInterface is ErrorHandler, HongConfiguration {

    // we do not have grace period. Once the goal is reached, the fund is secured

    address public managementBodyAddress;

    // 3 most important votings in blockchain
    mapping (uint => mapping (address => uint)) public votedKickoff;
    mapping (address => uint) public votedFreeze;
    mapping (address => uint) public votedHarvest;
    mapping (uint => uint256) public supportKickoffQuorum;
    uint256 public supportFreezeQuorum;
    uint256 public supportHarvestQuorum;
    uint public totalInitialBalance;
    uint public annualManagementFee;

    function voteToKickoffNewFiscalYear();
    function voteToFreezeFund();
    function recallVoteToFreezeFund();
    function voteToHarvestFund();

    function collectMyReturn();

    // Trigger the following events when the voting result is available
    event evKickoff(address msg_sender, uint msg_value, uint _fiscal);
    event evFreeze(address msg_sender, uint msg_value);
    event evHarvest(address msg_sender, uint msg_value);
}



// The HONG contract itself
contract HONG is HONGInterface, Token, TokenCreation {

    function HONG(
        address _managementBodyAddress,
        uint _closingTime,
        uint _closingTimeExtensionPeriod,
        uint _lastKickoffDateBuffer,
        uint _minTokensToCreate,
        uint _maxTokensToCreate,
        uint _tokensPerTier,
        bool _isInTestMode
    ) TokenCreation(_managementBodyAddress, _closingTime) {

        managementBodyAddress = _managementBodyAddress;
        closingTimeExtensionPeriod = _closingTimeExtensionPeriod;
        lastKickoffDateBuffer = _lastKickoffDateBuffer;

        minTokensToCreate = _minTokensToCreate;
        maxTokensToCreate = _maxTokensToCreate;
        tokensPerTier = _tokensPerTier;
        isInTestMode = _isInTestMode;

        returnWallet = new ReturnWallet(managementBodyAddress);
        rewardWallet = new RewardWallet(address(returnWallet));
        managementFeeWallet = new ManagementFeeWallet(managementBodyAddress, address(returnWallet));
        extraBalanceWallet = new ExtraBalanceWallet(address(returnWallet));

        if (address(extraBalanceWallet) == 0)
            doThrow("extraBalanceWallet:0");
        if (address(returnWallet) == 0)
            doThrow("returnWallet:0");
        if (address(rewardWallet) == 0)
            doThrow("rewardWallet:0");
        if (address(managementFeeWallet) == 0)
            doThrow("managementFeeWallet:0");
    }

    function () returns (bool success) {
        if (!isFromManagedAccount()) {
            // We do not accept donation here. Any extra amount sent to us after fund locking process, will be refunded
            return createTokenProxy(msg.sender);
        }
        else {
            evRecord(msg.sender, msg.value, "Recevied ether from ManagedAccount");
            return true;
        }
    }

    function isFromManagedAccount() internal returns (bool) {
        return msg.sender == address(extraBalanceWallet)
            || msg.sender == address(returnWallet)
            || msg.sender == address(rewardWallet)
            || msg.sender == address(managementFeeWallet);
    }

    /*
     * Voting for some critical steps, on blockchain
     */
    function voteToKickoffNewFiscalYear() onlyTokenHolders noEther onlyLocked {
        // this is the only valid fiscal year parameter, so there's no point in letting the caller pass it in.
        // Best case is they get it wrong and we throw, worst case is the get it wrong and there's some exploit
        uint _fiscal = currentFiscalYear + 1;

        if(!isKickoffEnabled[1]){  // if the first fiscal year is not kicked off yet
            // accept voting

        }else if(currentFiscalYear <= 3){  // if there was any kickoff() enabled before already

            if(lastKickoffDate + lastKickoffDateBuffer < now){ // 2 months from the end of the fiscal year
                // accept voting
            }else{
                // we do not accept early kickoff
                doThrow("kickOff:tooEarly");
                return;
            }
        }else{
            // do not accept kickoff anymore after the 4th year
            doThrow("kickOff:4thYear");
            return;
        }


        supportKickoffQuorum[_fiscal] -= votedKickoff[_fiscal][msg.sender];
        supportKickoffQuorum[_fiscal] += balances[msg.sender];
        votedKickoff[_fiscal][msg.sender] = balances[msg.sender];


        uint threshold = (kickoffQuorumPercent*(tokensCreated + bountyTokensCreated)) / 100;
        if(supportKickoffQuorum[_fiscal] > threshold) {
            if(_fiscal == 1){
                // transfer fund in extraBalance to main account
                extraBalanceWallet.returnBalanceToMainAccount();

                // reserve mgmtFeePercentage of whole fund to ManagementFeePoolWallet
                totalInitialBalance = this.balance;
                uint fundToReserve = (totalInitialBalance * mgmtFeePercentage) / 100;
                annualManagementFee = fundToReserve / 4;
                if(!managementFeeWallet.send(fundToReserve)){
                    doThrow("kickoff:ManagementFeePoolWalletFail");
                    return;
                }

            }
            isKickoffEnabled[_fiscal] = true;
            currentFiscalYear = _fiscal;
            lastKickoffDate = now;

            // transfer annual management fee from reservedWallet to mgmtWallet (external)
            managementFeeWallet.payManagementBodyAmount(annualManagementFee);

            evKickoff(msg.sender, msg.value, _fiscal);
            evIssueManagementFee(msg.sender, msg.value, annualManagementFee, true);
        }
    }

    function voteToFreezeFund() onlyTokenHolders noEther onlyLocked notFinalFiscalYear onlyDistributionNotInProgress {

        supportFreezeQuorum -= votedFreeze[msg.sender];
        supportFreezeQuorum += balances[msg.sender];
        votedFreeze[msg.sender] = balances[msg.sender];

        uint threshold = ((tokensCreated + bountyTokensCreated) * freezeQuorumPercent) / 100;
        if(supportFreezeQuorum > threshold){
            isFreezeEnabled = true;
            distributeDownstream(0);
            evFreeze(msg.sender, msg.value);
        }
    }

    function recallVoteToFreezeFund() onlyTokenHolders onlyNotFrozen noEther {
        supportFreezeQuorum -= votedFreeze[msg.sender];
        votedFreeze[msg.sender] = 0;
    }

    function voteToHarvestFund() onlyTokenHolders noEther onlyLocked onlyFinalFiscalYear {

        supportHarvestQuorum -= votedHarvest[msg.sender];
        supportHarvestQuorum += balances[msg.sender];
        votedHarvest[msg.sender] = balances[msg.sender];

        uint threshold = ((tokensCreated + bountyTokensCreated) * harvestQuorumPercent) / 100;
        if(supportHarvestQuorum > threshold) {
            isHarvestEnabled = true;
            evHarvest(msg.sender, msg.value);
        }
    }

    function collectMyReturn() onlyTokenHolders noEther onlyDistributionReady {
        uint tokens = balances[msg.sender];
        balances[msg.sender] = 0;
        returnWallet.payTokenHolderBasedOnTokenCount(msg.sender, tokens);
    }

    function mgmtInvestProject(
        address _projectWallet,
        uint _amount
    ) onlyManagementBody hasEther returns (bool _success) {

        if(!isKickoffEnabled[currentFiscalYear] || isFreezeEnabled || isHarvestEnabled){
            evMgmtInvestProject(msg.sender, msg.value, _projectWallet, _amount, false);
            return;
        }

        if(_amount >= this.balance){
            doThrow("failed:mgmtInvestProject: amount >= actualBalance");
            return;
        }

        // send the balance (_amount) to _projectWallet
        if (!_projectWallet.call.value(_amount)()) {
            doThrow("failed:mgmtInvestProject: cannot send to _projectWallet");
            return;
        }

        evMgmtInvestProject(msg.sender, msg.value, _projectWallet, _amount, true);
    }

    function transfer(address _to, uint256 _value) returns (bool success) {

        // Update kickoff voting record for the next fiscal year for an address, and the total quorum
        if(currentFiscalYear < 4){
            if(votedKickoff[currentFiscalYear+1][msg.sender] > _value){
                votedKickoff[currentFiscalYear+1][msg.sender] -= _value;
                supportKickoffQuorum[currentFiscalYear+1] -= _value;
            }else{
                supportKickoffQuorum[currentFiscalYear+1] -= votedKickoff[currentFiscalYear+1][msg.sender];
                votedKickoff[currentFiscalYear+1][msg.sender] = 0;
            }
        }

        // Update Freeze and Harvest voting records for an address, and the total quorum
        if(votedFreeze[msg.sender] > _value){
            votedFreeze[msg.sender] -= _value;
            supportFreezeQuorum -= _value;
        }else{
            supportFreezeQuorum -= votedFreeze[msg.sender];
            votedFreeze[msg.sender] = 0;
        }

        if(votedHarvest[msg.sender] > _value){
            votedHarvest[msg.sender] -= _value;
            supportHarvestQuorum -= _value;
        }else{
            supportHarvestQuorum -= votedHarvest[msg.sender];
            votedHarvest[msg.sender] = 0;
        }

        if (isFundLocked && super.transfer(_to, _value)) {
            return true;
        } else {
            if(!isFundLocked){
                doThrow("failed:transfer: isFundLocked is false");
            }else{
                doThrow("failed:transfer: cannot send send to _projectWallet");
            }
            return;
        }
    }
}
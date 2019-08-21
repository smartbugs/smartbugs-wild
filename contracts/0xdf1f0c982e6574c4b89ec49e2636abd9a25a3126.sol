pragma solidity ^0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20 {
    function totalSupply() public constant returns (uint256 supply);
    function balanceOf(address who) public constant returns (uint256 value);
    function allowance(address owner, address spender) public constant returns (uint256 permitted);

    function transfer(address to, uint256 value) public returns (bool ok);
    function transferFrom(address from, address to, uint256 value) public returns (bool ok);
    function approve(address spender, uint256 value) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract HyipProfit is ERC20 {
    using SafeMath for uint256;
    string public constant name = "HYIP Profit";
    string public constant symbol = "HYIP";
    uint8 public constant decimals = 8;

    uint256 initialSupply = 450000000000000;

    uint256 constant preSaleSoftCap = 31250000000000;

    uint256 public preSaleFund = 0;
    uint256 public spentFunds = 0;
    uint256 public IcoFund = 0;

    uint256 public soldTokens = 0; //reduces when somebody returns money

    mapping (address => uint256) tokenBalances; //amount of tokens each address holds
    mapping (address => uint256) preSaleWeiBalances; //amount of Wei, paid for tokens on preSale. Used only before project completed.
    mapping (address => uint256) weiBalances; //amount of Wei, paid for tokens that smb holds. Used only before project completed.

    uint256 public currentStage = 0;
    tokenAddressGetter tg;

    bool public isICOfinalized = false;

    address public HyipProfitTokenTeamAddress;
    address public utilityTokenAddress = 0x0;

    modifier onlyTeam {
        if (msg.sender == HyipProfitTokenTeamAddress) {
            _;
        }
    }

    mapping (address => mapping (address => uint256)) allowed;
    mapping (uint256 => address) teamAddresses;

    uint256 currentDividendsRound;
    mapping (uint256 => uint256) dividendsPerTokenPerRound;
    mapping (uint256 => mapping (address => uint256)) poolBalances;
    mapping (address => uint256) lastWithdrawal;

    event dividendsReceived (uint256 round, uint256 totalValue, uint256 dividendsPerToken);
    event dividendsWithdraw (address tokenHolder, uint256 valueInWei);
    event tokensReceived (address from, uint256 tokensAmount);
    event tokensWithdrawal (address to, uint256 tokensAmount);

    event StageSubmittedAndEtherPassedToTheTeam(uint256 stage, uint256 when, uint256 weiAmount);
    event etherWithdrawFromTheContract(address tokenHolder, uint256 numberOfTokensSoldBack, uint256 weiValue);
    event Burned(address indexed from, uint256 amount);

    // ERC20 interface implementation

    function totalSupply() public constant returns (uint256) {
        return initialSupply;
    }

    function balanceOf(address tokenHolder) public view returns (uint256 balance) {
        return tokenBalances[tokenHolder];
    }

    function allowance(address owner, address spender) public constant returns (uint256) {
        return allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        if (tokenBalances[msg.sender] >= value && value > 0) {
            if (to == address(this)) {
                if (!isICOfinalized) {
                    returnAllAvailableFunds();
                    return true;
                }
                else {
                    passTokensToTheDividendsPool(value);
                    return true;
                }
            }
            else {
                return transferTokensAndEtherValue(msg.sender, to, value, getHoldersAverageTokenPrice(msg.sender).mul(value) , getUsersPreSalePercentage(msg.sender));
            }
        } else return false;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        if (tokenBalances[from]>=value && allowed[from][to] >= value && value > 0) {
            if (transferTokensAndEtherValue(from, to, value, getHoldersAverageTokenPrice(from).mul(value), getUsersPreSalePercentage(from))){
                allowed[from][to] = allowed[from][to].sub(value);
                if (from == address(this) && poolBalanceOf(to) >= value) {
                    if (withdrawDividends(to)) {
                        poolBalances[currentDividendsRound][to] = poolBalances[currentDividendsRound][to].sub(value);
                    }
                }
                return true;
            }
            return false;
        }
        return false;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        if ((value != 0) && (tokenBalances[msg.sender] >= value)){
            allowed[msg.sender][spender] = value;
            emit Approval (msg.sender, spender, value);
            return true;
        } else{
            return false;
        }
    }

    // Constructor, fallback, return funds

    constructor () public {
        HyipProfitTokenTeamAddress = msg.sender;
        currentDividendsRound = 0;
        tokenBalances[address(this)] = initialSupply;
        teamAddresses[0] = HyipProfitTokenTeamAddress;
        teamAddresses[1] = 0xcC6bCF304d0Ada4Bc7B00Aa1c2c463FBEc263B7e;
        teamAddresses[2] = 0x1F16BE21574FA46846fCfeae5ef587c29200f93e;
        teamAddresses[3] = 0x93A10f35Bc5439E419fdDcE04Ea44779B0E1017C;
        teamAddresses[4] = 0x71bAfdD5bd44D3e1038fE4c0Bc486fb4BB67b806;
    }

    function () public payable {
        if (!isICOfinalized) {
            uint256 currentPrice = getCurrentSellPrice();
            uint256 valueInWei = 0;
            uint256 tokensToPass = 0;
            uint256 preSalePercent = 0;

            require (msg.value >= currentPrice);

            tokensToPass = msg.value.div(currentPrice);

            require (tokenBalances[address(this)]>= tokensToPass);

            valueInWei = tokensToPass.mul(currentPrice);
            soldTokens = soldTokens.add(tokensToPass);

            if (currentStage == 0) {
                preSaleWeiBalances [address(this)] = preSaleWeiBalances [address(this)].add(valueInWei);
                preSalePercent = 100;
                preSaleFund = preSaleFund.add(msg.value);
            }
            else {
                weiBalances[address(this)] = weiBalances[address(this)].add(valueInWei);
                preSalePercent = 0;
                IcoFund = IcoFund.add(msg.value);
            }

            transferTokensAndEtherValue(address(this), msg.sender, tokensToPass, valueInWei, preSalePercent);
        }
        else {
            require (msg.value >= 10**18);
            topUpDividends();
        }
    }

    function returnAllAvailableFunds() public {
        require (tokenBalances[msg.sender]>0); //you need to be a tokenHolder
        require (!isICOfinalized); //you can not return tokens after project is completed

        uint256 preSaleWei = getPreSaleWeiToReturn(msg.sender);
        uint256 IcoWei = getIcoWeiToReturn(msg.sender);
        uint256 weiToReturn = preSaleWei.add(IcoWei);

        uint256 amountOfTokensToReturn = tokenBalances[msg.sender];

        require (amountOfTokensToReturn>0);

        uint256 preSalePercentage = getUsersPreSalePercentage(msg.sender);

        transferTokensAndEtherValue(msg.sender, address(this), amountOfTokensToReturn, weiToReturn, preSalePercentage);
        emit etherWithdrawFromTheContract(msg.sender, amountOfTokensToReturn, IcoWei.add(preSaleWei));
        preSaleWeiBalances[address(this)] = preSaleWeiBalances[address(this)].sub(preSaleWei);
        weiBalances[address(this)] = weiBalances[address(this)].sub(IcoWei);
        soldTokens = soldTokens.sub(amountOfTokensToReturn);
        msg.sender.transfer(weiToReturn);

        preSaleFund = preSaleFund.sub(preSaleWei);
        IcoFund = IcoFund.sub(IcoWei);
    }

    function passTokensToTheDividendsPool(uint256 amount) internal {
        if (tokenBalances[msg.sender] >= amount) {
            tokenBalances[address(this)] = tokenBalances[address(this)].add(amount);
            tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(amount);
            emit Transfer(msg.sender, address(this), amount);

            allowed[address(this)][msg.sender] = allowed[address(this)][msg.sender].add(amount);
            emit Approval (address(this), msg.sender, amount);

            if (poolBalanceOf(msg.sender) == 0) lastWithdrawal[msg.sender] = currentDividendsRound;
            poolBalances[currentDividendsRound][msg.sender] = poolBalances[currentDividendsRound][msg.sender].add(amount);
            emit tokensReceived(msg.sender, amount);
        }
    }

    function topUpDividends() public payable {
        require (msg.value >= 10**18);
        uint256 dividends = msg.value;
        uint256 tokensInPool = balanceOf(address(this));
        dividendsPerTokenPerRound[currentDividendsRound] = dividends.div(tokensInPool);
        emit dividendsReceived (currentDividendsRound, dividends, dividendsPerTokenPerRound[currentDividendsRound]);
        currentDividendsRound = currentDividendsRound.add(1);
    }

    function withdrawDividends(address holder) public returns (bool success) {
        require (poolBalanceOf(holder) > 0);
        uint256 totalDividendsForHolder = dividendsOf(holder);
        if (totalDividendsForHolder == 0) return true;
        uint256 holdersTotalTokensInPool = 0;

        for (uint256 i = lastWithdrawal[holder]; i < currentDividendsRound; i = i.add(1)) {
            holdersTotalTokensInPool = holdersTotalTokensInPool.add(poolBalances[i][holder]);
            poolBalances[i][holder] = 0;
        }

        holder.transfer(totalDividendsForHolder);
        emit dividendsWithdraw (holder, totalDividendsForHolder);
        poolBalances[currentDividendsRound][holder] = holdersTotalTokensInPool;
        lastWithdrawal[holder] = currentDividendsRound;
        return true;
    } //AnyBody can call

    // View functions

    function dividendsOf(address holder) public view returns (uint256 dividendsAmount) {
        uint256 dividends = 0;
        for (uint256 i = lastWithdrawal[holder]; i < currentDividendsRound; i = i.add(1)) {
            for(uint256 j = lastWithdrawal[holder]; j <= i; j = j.add(1)) {
                if (poolBalances[j][holder]>0 && dividendsPerTokenPerRound[i] > 0)
                dividends = dividends.add(poolBalances[j][holder].mul(dividendsPerTokenPerRound[i]));
            }
        }
        return dividends;
    }

    function icoFinalized() public view returns (bool) {
        return isICOfinalized;
    }

    function poolBalanceOf(address holder) public view returns (uint256 balance){
        uint256 holdersTotalTokensInThePool = 0;
        for (uint256 i = lastWithdrawal[msg.sender]; i <= currentDividendsRound; i = i.add(1)) {
            holdersTotalTokensInThePool = holdersTotalTokensInThePool.add(poolBalances[i][holder]);
        }
        return holdersTotalTokensInThePool;
    }

    function getWeiBalance(address a) public view returns (uint256 weiBalance) {
        return weiBalances[a];
    }

    function getUsersPreSalePercentage(address a) public view returns (uint256 preSaleTokensPercent) {
        if (!isICOfinalized && (preSaleWeiBalances[a].add(weiBalances[a]) > 0)) {
            uint256 result = (preSaleWeiBalances[a].mul(100)).div((preSaleWeiBalances[a].add(weiBalances[a])));
            require (result<=100);
            return result;
        }
        return 0;
    }

    function getTotalWeiAvailableToReturn(address a) public view returns (uint256 amount) {
        return getPreSaleWeiToReturn(a).add(getIcoWeiToReturn(a));
    }

    function getPreSaleWeiToReturn (address holder) public view returns (uint256 amount) {
        if (currentStage == 0) return preSaleWeiBalances[holder];
        if (currentStage == 1) return preSaleWeiBalances[holder].mul(7).div(10);
        if (currentStage == 2) return preSaleWeiBalances[holder].mul(4).div(10);
        return 0;
    }

    function getIcoWeiToReturn (address holder) public view returns (uint256 amount) {
        if (currentStage <= 3) return weiBalances[holder];
        if (currentStage == 4) return weiBalances[holder].mul(7).div(10);
        if (currentStage == 5) return weiBalances[holder].mul(4).div(10);
        return 0;
    }

    function getHoldersAverageTokenPrice(address holder) public view returns (uint256 avPriceInWei) {
        if (!isICOfinalized)
            return (weiBalances[holder].add(preSaleWeiBalances[holder])).div(tokenBalances[holder]);
        return 0;
    }

    function getCurrentSellPrice() public view returns (uint256 priceInWei) {
        if (isICOfinalized) return 0;
        if (currentStage == 0) return 10**6 * 8 ; //this is equal to 0.0008 ETH for 1 token
        if (currentStage == 1) return 10**6 * 16;
        if (currentStage == 2) return 10**6 * 24;
        if (currentStage == 3) return 10**6 * 32;
        return 0;
    }

    function getAvailableFundsForTheTeam() public view returns (uint256 amount) {
        if (currentStage == 1) return preSaleFund.mul(3).div(10);
        if (currentStage == 2) return (preSaleFund.sub(spentFunds)).div(2);
        if (currentStage == 3) return preSaleFund.sub(spentFunds);

        if (currentStage == 4) return IcoFund.mul(3).div(10);
        if (currentStage == 5) return (IcoFund.sub(spentFunds)).div(2);
        if (currentStage == 6) return address(this).balance;
    }

    function checkIfMissionCompleted() public view returns (bool success) {
        if (currentStage == 0 && soldTokens >= preSaleSoftCap) return true;

        if (currentStage == 1 && preSaleFund.mul(3).div(5) <= IcoFund) return true;
        if (currentStage == 2 && preSaleFund.mul(6).div(5) <= IcoFund) return true;

        if (currentStage>=3 &&
        (utilityTokenAddress == 0x0 || tg.getBeneficiaryAddress() != address(this))) return false;

        if (currentStage == 3 && preSaleFund.mul(2) <= IcoFund) return true;

        if (currentStage == 4 && utilityTokenAddress.balance >= IcoFund.mul(3).div(5)) return true;
        if (currentStage == 5 && utilityTokenAddress.balance >= IcoFund.mul(6).div(5)) return true;
        if (currentStage == 6 && utilityTokenAddress.balance >= IcoFund.mul(2)) return true;

        return false;
    }

    // Team functions

    function setUtilityTokenAddressOnce(address a) public onlyTeam {
        if (utilityTokenAddress == 0x0) {
            utilityTokenAddress = a;
            tg = tokenAddressGetter(a);
        }
    }

    function finalizeICO() internal onlyTeam {
        require(!isICOfinalized); // this function can be called only once
        passTokensToTheTeam();
        burnUndistributedTokens(); // undistributed tokens are destroyed
        isICOfinalized = true;
    }

    function passTokensToTheTeam() internal returns (uint256 tokenAmount) { //This function passes tokens to the team without weiValue, so the team can not withdraw ether by returning tokens to the contract
        uint256 tokensForEachMember = soldTokens.div(20); // 4% for each team member
        uint256 tokensToPass = tokensForEachMember.mul(5);

        for (uint256 i = 0; i< 5; i = i.add(1)) {
            address teamMember = teamAddresses[i];
            tokenBalances[teamMember] = tokenBalances[teamMember].add(tokensForEachMember);
            emit Transfer(address(this), teamMember, tokensForEachMember);
        }

        soldTokens = soldTokens.add(tokensToPass);
        return tokensToPass;
    }

    function submitNextStage() public onlyTeam returns (bool success) {
        if (!checkIfMissionCompleted()) return false;
        if (currentStage==3) spentFunds = 0;
        if (currentStage == 6) finalizeICO();

        currentStage = currentStage.add(1);
        passEtherToTheTeam();

        return true;
    }

    function passEtherToTheTeam() internal returns (bool success) {
        uint256 weiAmount = getAvailableFundsForTheTeam();
        HyipProfitTokenTeamAddress.transfer(weiAmount);
        spentFunds = spentFunds.add(weiAmount);
        emit StageSubmittedAndEtherPassedToTheTeam(currentStage, now, weiAmount);
        return true;
    }

    function transferTokensAndEtherValue(address from, address to, uint256 value, uint256 weiValue, uint256 preSalePercent) internal returns (bool success){
        if (tokenBalances[from] >= value) {
            tokenBalances[to] = tokenBalances[to].add(value);
            tokenBalances[from] = tokenBalances[from].sub(value);

            if (!isICOfinalized) {
                preSaleWeiBalances[from] = preSaleWeiBalances[from].sub(weiValue.mul(preSalePercent).div(100));
                preSaleWeiBalances[to] = preSaleWeiBalances[to].add(weiValue.mul(preSalePercent).div(100));

                require (preSalePercent<=100);

                weiBalances[from] = weiBalances[from].sub(weiValue.mul(100 - preSalePercent).div(100));
                weiBalances[to] = weiBalances[to].add(weiValue.mul(100 - preSalePercent).div(100));
            }
            emit Transfer(from, to, value);
            return true;
        }
        return false;
    }

    function burnUndistributedTokens() internal {
        uint256 toBurn = initialSupply.sub(soldTokens);
        initialSupply = initialSupply.sub(toBurn);
        tokenBalances[address(this)] = 0;
        emit Burned(address(this), toBurn);
    }
}

contract tokenAddressGetter {
    function getBeneficiaryAddress() public view returns (address);
}
//etherate v.1.0
//https://etherate.org
//ETHERATE - BET and WIN ETH
/*
╔═══╗╔════╗╔╗─╔╗╔═══╗╔═══╗╔═══╗╔════╗╔═══╗
║╔══╝║╔╗╔╗║║║─║║║╔══╝║╔═╗║║╔═╗║║╔╗╔╗║║╔══╝
║╚══╗╚╝║║╚╝║╚═╝║║╚══╗║╚═╝║║║─║║╚╝║║╚╝║╚══╗
║╔══╝──║║──║╔═╗║║╔══╝║╔╗╔╝║╚═╝║──║║──║╔══╝
║╚══╗──║║──║║─║║║╚══╗║║║╚╗║╔═╗║──║║──║╚══╗
╚═══╝──╚╝──╚╝─╚╝╚═══╝╚╝╚═╝╚╝─╚╝──╚╝──╚═══╝
*/
//69 84 72 69 82 65 84 69 
pragma solidity ^0.4.24;
contract Control
{
    mapping(address => uint8) public agents;
    modifier onlyADM()
    {
        require(agents[msg.sender] == 1);
        _;
    }
    event ChangePermission(address indexed _called, address indexed _agent, uint8 _value);
    function changePermission(address _agent, uint8 _value) public onlyADM()
    {
        require(msg.sender != _agent);
        agents[_agent] = _value;
        ChangePermission(msg.sender, _agent, _value);
    }
    bool public status;
    event ChangeStatus(address indexed _called, bool _value);
    function changeStatus(bool _value) public onlyADM()
    {
        status = _value;
        ChangeStatus(msg.sender, _value);
    }
    modifier onlyRun()
    {
        require(status);
        _;
    }
    event WithdrawWEI(address indexed _called, address indexed _to, uint256 _wei, uint8 indexed _type);
    uint256 private totalDonateWEI;
    event Donate(address indexed _from, uint256 _value);
    function () payable //Thank you very much ;)
    {
        totalDonateWEI = totalDonateWEI + msg.value;
        Donate(msg.sender, msg.value);
    }
    function getTotalDonateWEIInfo() public onlyADM() constant returns(uint256)
    {
        return totalDonateWEI;
    }
    function withdrawDonateWEI(address _to) public onlyADM()
    {
        _to.transfer(totalDonateWEI);
        WithdrawWEI(msg.sender, _to, totalDonateWEI, 1);
        totalDonateWEI = 0;
    }
    function Control()
    {
        agents[msg.sender] = 1;
        status = true;
    }
}

contract Core is Control
{
    ///RANDOM
    function random(uint256 _min, uint256 _max) public constant returns(uint256)
    {
        return uint256(sha3(block.blockhash(block.number - 1))) % (_min + _max) - _min;
	}
    ///*RANDOM
    uint256 public betSizeFINNEY;
    uint256 public totalBets;
    uint256 public limitAgentBets;
    uint256 public roundNum;
    uint256 public betsNum;
    uint256 public commissionPCT;
    bool public commissionType;
    uint256 private bankBalanceWEI;
    uint256 private commissionBalanceWEI;
    uint256 private overBalanceWEI;
    uint256 public timeoutSEC;
    uint256 public lastBetTimeSEC;
    function getOverBalanceWEIInfo() public onlyADM() constant returns(uint256)
    {
        return overBalanceWEI;
    }
    function getBankBalanceWEIInfo() public onlyADM() constant returns(uint256)
    {
        return bankBalanceWEI;
    }
    function getCommissionBalanceWEIInfo() public onlyADM() constant returns(uint256)
    {
        return commissionBalanceWEI;
    }
    function withdrawOverBalanceWEI(address _to) public onlyADM()
    {
        _to.transfer(overBalanceWEI);
        WithdrawWEI(msg.sender, _to, overBalanceWEI, 2);
        overBalanceWEI = 0;
    }
    function withdrawCommissionBalanceWEI(address _to) public onlyADM()
    {
        _to.transfer(commissionBalanceWEI);
        WithdrawWEI(msg.sender, _to, commissionBalanceWEI, 3);
        commissionBalanceWEI = 0;
    }
    mapping(address => uint256) private agentAddressId;
    address[] private agentIdAddress;
    uint256[] private agentIdBetsSum;
    uint256[] private agentIdBankBalanceWEI;
    uint256[] private betsNumAgentId;
    function getAgentId(address _agentAddress) public constant returns(uint256)
    {
        uint256 value;
        uint256 id = agentAddressId[_agentAddress];
        if (id != 0 && id <= agentIdAddress.length)
        {
            if (agentIdAddress[id - 1] == _agentAddress)
            {
                value = agentAddressId[_agentAddress];
            }
        }
        return value;
    }
    function getAgentAdress(uint256 _agentId) public constant returns(address)
    {
        address value;
        if (_agentId > 0 && _agentId <= agentIdAddress.length)
        {
            value = agentIdAddress[_agentId - 1];
        }
        return value;
    }
    function getAgentBetsSum(uint256 _agentId) public constant returns(uint256)
    {
        uint256 value;
        if (_agentId > 0 && _agentId <= agentIdBetsSum.length)
        {
            value = agentIdBetsSum[_agentId - 1];
        }
        return value;
    }
    function getAgentBankBalanceWEI(uint256 _agentId) public constant returns(uint256)
    {
        uint256 value;
        if (_agentId > 0 && _agentId <= agentIdBankBalanceWEI.length)
        {
            value = agentIdBankBalanceWEI[_agentId - 1];
        }
        return value;
    }
    function getPositionBetAgent(uint256 _positionBet) public constant returns(uint256)
    {
        uint256 value;
        if (_positionBet > 0 && _positionBet <= betsNumAgentId.length)
        {
            value = betsNumAgentId[_positionBet - 1];
        }
        return value;
    }
    function getAgentsNum() public constant returns(uint256)
    {
        return agentIdAddress.length;
    }
    function Core()
    {
        roundNum = 1;
    }
    event ChangeGameSettings(address indexed _called, uint256 _betSizeFINNEY, uint256 _totalBets, uint256 _limitAgentBets, uint256 _commissionPCT, bool _commissionType, uint256 _timeoutSEC);
    function changeGameSettings(uint256 _betSizeFINNEY, uint256 _totalBets, uint256 _limitAgentBets, uint256 _commissionPCT, bool _commissionType, uint256 _timeoutSEC) public onlyADM()
    {
        require(betsNum == 0);
        require(_limitAgentBets < _totalBets);
        require(_commissionPCT < 100);
        betSizeFINNEY = _betSizeFINNEY;
        totalBets = _totalBets;
        limitAgentBets = _limitAgentBets;
        commissionPCT = _commissionPCT;
        commissionType = _commissionType;
        timeoutSEC = _timeoutSEC;
        ChangeGameSettings(msg.sender, _betSizeFINNEY, _totalBets, _limitAgentBets, _commissionPCT, _commissionType, _timeoutSEC);
    }
    event Bet(address indexed _agent, uint256 _agentId, uint256 _round, uint256 _bets, uint256 _WEI);
    event Winner(address indexed _agent, uint256 _agentId, uint256 _round, uint256 _betsSum, uint256 _depositWEI, uint256 _winWEI, uint256 _luckyNumber);
    function bet() payable public onlyRun() //BET AND WIN
    {
        require(msg.value > 0);
        uint256 agentID;
        agentID = getAgentId(msg.sender);
        if (agentID == 0)
        {
            agentIdAddress.push(msg.sender);
            agentID = agentIdAddress.length;
            agentAddressId[msg.sender] = agentID;
            agentIdBetsSum.push(0);
            agentIdBankBalanceWEI.push(0);
        }
        bankBalanceWEI = bankBalanceWEI + msg.value;
        agentIdBankBalanceWEI[agentID - 1] = getAgentBankBalanceWEI(agentID) + msg.value;
        uint256 agentTotalBets = (getAgentBankBalanceWEI(agentID)/1000000000000000)/betSizeFINNEY;
        uint256 agentAmountBets = agentTotalBets - getAgentBetsSum(agentID);
        if (agentAmountBets > 0)
        {
            if ((agentAmountBets + getAgentBetsSum(agentID) + betsNum) > totalBets)
            {
                agentAmountBets = 
                totalBets - betsNum;
            }
            if ((agentAmountBets + getAgentBetsSum(agentID)) > limitAgentBets)
            {
                agentAmountBets = 
                limitAgentBets - getAgentBetsSum(agentID);   
            }
            
            agentIdBetsSum[agentID - 1] = getAgentBetsSum(agentID) + agentAmountBets;
            
            while (betsNumAgentId.length < betsNum + agentAmountBets)
            {
                betsNumAgentId.push(agentID);
            }
            
            betsNum = betsNum + agentAmountBets;
            
            Bet(msg.sender, agentID, roundNum, agentAmountBets, msg.value);
        }
        lastBetTimeSEC = block.timestamp;
        if (betsNum == totalBets)
        {
            _play();
        }
    }
    function playForcibly() public onlyRun() onlyADM()
    {
        require(block.timestamp + timeoutSEC > lastBetTimeSEC);
        _play();
    }
    function _play() private
    {
        uint256 luckyNumber = random(1, betsNum);
        uint256 winnerID = betsNumAgentId[luckyNumber - 1];
        address winnerAddress = getAgentAdress(winnerID);
        uint256 jackpotBankWEI = betsNum * betSizeFINNEY * 1000000000000000;
        uint256 overWEI = bankBalanceWEI - jackpotBankWEI;
        uint256 commissionWEI;
        if (commissionType)
        {
            commissionWEI = (jackpotBankWEI/100) * commissionPCT;
        }
        else
        {
            commissionWEI = (betsNum - getAgentBetsSum(winnerID)) * (betSizeFINNEY * 1000000000000000) / 100 * commissionPCT;
        }
        winnerAddress.transfer(jackpotBankWEI - commissionWEI);
        commissionBalanceWEI = commissionBalanceWEI + commissionWEI;
        overBalanceWEI = overBalanceWEI + overWEI;
        Winner(winnerAddress, winnerID, roundNum, getAgentBetsSum(winnerID), getAgentBankBalanceWEI(winnerID), jackpotBankWEI - commissionWEI, luckyNumber);
        bankBalanceWEI = 0;
        betsNum = 0;
        roundNum++;
        delete agentIdAddress;
        delete agentIdBetsSum;
        delete agentIdBankBalanceWEI;
        delete betsNumAgentId;
    }
}
//https://etherate.org
//Blog (Medium): https://medium.com/etherate
//Reddit: https://www.reddit.com/r/EtheRate
//Twitter: https://twitter.com/etherate_org
//Facebook: https://www.facebook.com/etherate
//Instagram: https://www.instagram.com/etherate_org
//Telegram: https://t.me/etherate
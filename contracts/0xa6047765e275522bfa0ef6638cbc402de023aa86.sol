pragma solidity 0.4.17;

library IdeaUint {

    function add(uint a, uint b) constant internal returns (uint result) {
        uint c = a + b;

        assert(c >= a);

        return c;
    }

    function sub(uint a, uint b) constant internal returns (uint result) {
        uint c = a - b;

        assert(b <= a);

        return c;
    }

    function mul(uint a, uint b) constant internal returns (uint result) {
        uint c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint a, uint b) constant internal returns (uint result) {
        uint c = a / b;

        return c;
    }
}

contract IdeaBasicCoin {
    using IdeaUint for uint;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address[] public accounts;
    mapping(address => bool) internal accountsMap;
    address public owner;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function balanceOf(address _owner) constant public returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        tryCreateAccount(_to);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        uint _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        tryCreateAccount(_to);

        Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    function tryCreateAccount(address _account) internal {
        if (!accountsMap[_account]) {
            accounts.push(_account);
            accountsMap[_account] = true;
        }
    }
}

contract IdeaCoin is IdeaBasicCoin {

    uint public earnedEthWei;
    uint public soldIdeaWei;
    uint public soldIdeaWeiPreIco;
    uint public soldIdeaWeiIco;
    uint public soldIdeaWeiPostIco;
    uint public icoStartTimestamp;
    mapping(address => uint) public pieBalances;
    address[] public pieAccounts;
    mapping(address => bool) internal pieAccountsMap;
    uint public nextRoundReserve;
    address[] public projects;
    address public projectAgent;
    address public bank1;
    address public bank2;
    uint public bank1Val;
    uint public bank2Val;
    uint public bankValReserve;

    enum IcoStates {
    Coming,
    PreIco,
    Ico,
    PostIco,
    Done
    }

    IcoStates public icoState;

    function IdeaCoin() {
        name = 'IdeaCoin';
        symbol = 'IDEA';
        decimals = 18;
        totalSupply = 100000000 ether;

        owner = msg.sender;
        tryCreateAccount(msg.sender);
    }

    function() payable {
        uint tokens;
        bool moreThenPreIcoMin = msg.value >= 20 ether;
        uint totalVal = msg.value + bankValReserve;
        uint halfVal = totalVal / 2;

        if (icoState == IcoStates.PreIco && moreThenPreIcoMin && soldIdeaWeiPreIco <= 2500000 ether) {

            tokens = msg.value * 1500;
            balances[msg.sender] += tokens;
            soldIdeaWeiPreIco += tokens;

        } else if (icoState == IcoStates.Ico && soldIdeaWeiIco <= 35000000 ether) {
            uint elapsed = now - icoStartTimestamp;

            if (elapsed <= 1 days) {

                tokens = msg.value * 1250;
                balances[msg.sender] += tokens;

            } else if (elapsed <= 6 days && elapsed > 1 days) {

                tokens = msg.value * 1150;
                balances[msg.sender] += tokens;

            } else if (elapsed <= 11 days && elapsed > 6 days) {

                tokens = msg.value * 1100;
                balances[msg.sender] += tokens;

            } else if (elapsed <= 16 days && elapsed > 11 days) {

                tokens = msg.value * 1050;
                balances[msg.sender] += tokens;

            } else {

                tokens = msg.value * 1000;
                balances[msg.sender] += tokens;

            }

            soldIdeaWeiIco += tokens;

        } else if (icoState == IcoStates.PostIco && soldIdeaWeiPostIco <= 12000000 ether) {

            tokens = msg.value * 500;
            balances[msg.sender] += tokens;
            soldIdeaWeiPostIco += tokens;

        } else {
            revert();
        }

        earnedEthWei += msg.value;
        soldIdeaWei += tokens;

        bank1Val += halfVal;
        bank2Val += halfVal;
        bankValReserve = totalVal - (halfVal * 2);

        tryCreateAccount(msg.sender);
    }

    function setBank(address _bank1, address _bank2) public onlyOwner {
        require(bank1 == address(0x0));
        require(bank2 == address(0x0));
        require(_bank1 != address(0x0));
        require(_bank2 != address(0x0));

        bank1 = _bank1;
        bank2 = _bank2;

        balances[bank1] = 500000 ether;
        balances[bank2] = 500000 ether;
    }

    function startPreIco() public onlyOwner {
        icoState = IcoStates.PreIco;
    }

    function stopPreIcoAndBurn() public onlyOwner {
        stopAnyIcoAndBurn(
        (2500000 ether - soldIdeaWeiPreIco) * 2
        );
        balances[bank1] += soldIdeaWeiPreIco / 2;
        balances[bank2] += soldIdeaWeiPreIco / 2;
    }

    function startIco() public onlyOwner {
        icoState = IcoStates.Ico;
        icoStartTimestamp = now;
    }

    function stopIcoAndBurn() public onlyOwner {
        stopAnyIcoAndBurn(
        (35000000 ether - soldIdeaWeiIco) * 2
        );
        balances[bank1] += soldIdeaWeiIco / 2;
        balances[bank2] += soldIdeaWeiIco / 2;
    }

    function startPostIco() public onlyOwner {
        icoState = IcoStates.PostIco;
    }

    function stopPostIcoAndBurn() public onlyOwner {
        stopAnyIcoAndBurn(
        (12000000 ether - soldIdeaWeiPostIco) * 2
        );
        balances[bank1] += soldIdeaWeiPostIco / 2;
        balances[bank2] += soldIdeaWeiPostIco / 2;
    }

    function stopAnyIcoAndBurn(uint _burn) internal {
        icoState = IcoStates.Coming;
        totalSupply = totalSupply.sub(_burn);
    }

    function withdrawEther() public {
        require(msg.sender == bank1 || msg.sender == bank2);

        if (msg.sender == bank1) {
            bank1.transfer(bank1Val);
            bank1Val = 0;
        }

        if (msg.sender == bank2) {
            bank2.transfer(bank2Val);
            bank2Val = 0;
        }

        if (bank1Val == 0 && bank2Val == 0 && this.balance != 0) {
            owner.transfer(this.balance);
        }
    }

    function pieBalanceOf(address _owner) constant public returns (uint balance) {
        return pieBalances[_owner];
    }

    function transferToPie(uint _amount) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        pieBalances[msg.sender] = pieBalances[msg.sender].add(_amount);
        tryCreatePieAccount(msg.sender);

        return true;
    }

    function transferFromPie(uint _amount) public returns (bool success) {
        pieBalances[msg.sender] = pieBalances[msg.sender].sub(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);

        return true;
    }

    function receiveDividends(uint _amount) internal {
        uint minBalance = 10000 ether;
        uint pieSize = calcPieSize(minBalance);
        uint amount = nextRoundReserve + _amount;

        accrueDividends(minBalance, pieSize, amount);
    }

    function calcPieSize(uint _minBalance) constant internal returns (uint _pieSize) {
        for (uint i = 0; i < pieAccounts.length; i += 1) {
            var balance = pieBalances[pieAccounts[i]];

            if (balance >= _minBalance) {
                _pieSize = _pieSize.add(balance);
            }
        }
    }

    function accrueDividends(uint _minBalance, uint _pieSize, uint _amount) internal {
        uint accrued;

        for (uint i = 0; i < pieAccounts.length; i += 1) {
            address account = pieAccounts[i];
            uint balance = pieBalances[account];

            if (balance >= _minBalance) {
                uint dividends = (balance * _amount) / _pieSize;

                accrued = accrued.add(dividends);
                pieBalances[account] = balance.add(dividends);
            }
        }

        nextRoundReserve = _amount.sub(accrued);
    }

    function tryCreatePieAccount(address _account) internal {
        if (!pieAccountsMap[_account]) {
            pieAccounts.push(_account);
            pieAccountsMap[_account] = true;
        }
    }

    function setProjectAgent(address _project) public onlyOwner {
        projectAgent = _project;
    }

    function makeProject(string _name, uint _required, uint _requiredDays) public returns (address _address) {
        _address = ProjectAgent(projectAgent).makeProject(msg.sender, _name, _required, _requiredDays);

        projects.push(_address);
    }

    function withdrawFromProject(address _project, uint _stage) public returns (bool _success) {
        uint _value;
        (_success, _value) = ProjectAgent(projectAgent).withdrawFromProject(msg.sender, _project, _stage);

        if (_success) {
            receiveTrancheAndDividends(_value);
        }
    }

    function cashBackFromProject(address _project) public returns (bool _success) {
        uint _value;
        (_success, _value) = ProjectAgent(projectAgent).cashBackFromProject(msg.sender, _project);

        if (_success) {
            balances[msg.sender] = balances[msg.sender].add(_value);
        }
    }

    function receiveTrancheAndDividends(uint _sum) internal {
        uint raw = _sum * 965;
        uint reserve = raw % 1000;
        uint tranche = (raw - reserve) / 1000;

        balances[msg.sender] = balances[msg.sender].add(tranche);
        receiveDividends(_sum - tranche);
    }

    function buyProduct(address _product, uint _amount) public {
        ProjectAgent _agent = ProjectAgent(projectAgent);

        uint _price = IdeaSubCoin(_product).price();

        balances[msg.sender] = balances[msg.sender].sub(_price * _amount);
        _agent.buyProduct(_product, msg.sender, _amount);
    }
}

contract IdeaProject {
    using IdeaUint for uint;

    string public name;
    address public engine;
    address public owner;
    uint public required;
    uint public requiredDays;
    uint public fundingEndTime;
    uint public earned;
    mapping(address => bool) public isCashBack;
    uint public currentWorkStagePercent;
    uint internal lastWorkStageStartTimestamp;
    int8 public failStage = -1;
    uint public failInvestPercents;
    address[] public products;
    uint public cashBackVotes;
    mapping(address => uint) public cashBackWeight;

    enum States {
    Initial,
    Coming,
    Funding,
    Workflow,
    SuccessDone,
    FundingFail,
    WorkFail
    }

    States public state = States.Initial;

    struct WorkStage {
    uint percent;
    uint stageDays;
    uint sum;
    uint withdrawTime;
    }

    WorkStage[] public workStages;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyEngine() {
        require(msg.sender == engine);
        _;
    }

    modifier onlyState(States _state) {
        require(state == _state);
        _;
    }

    modifier onlyProduct() {
        bool permissionGranted;

        for (uint8 i; i < products.length; i += 1) {
            if (msg.sender == products[i]) {
                permissionGranted = true;
            }
        }

        if (permissionGranted) {
            _;
        } else {
            revert();
        }
    }

    function IdeaProject(
    address _owner,
    string _name,
    uint _required,
    uint _requiredDays
    ) {
        require(bytes(_name).length > 0);
        require(_required != 0);

        require(_requiredDays >= 10);
        require(_requiredDays <= 100);

        engine = msg.sender;
        owner = _owner;
        name = _name;
        required = _required;
        requiredDays = _requiredDays;
    }

    function addEarned(uint _earned) public onlyEngine {
        earned = earned.add(_earned);
    }

    function isFundingState() constant public returns (bool _result) {
        return state == States.Funding;
    }

    function isWorkflowState() constant public returns (bool _result) {
        return state == States.Workflow;
    }

    function isSuccessDoneState() constant public returns (bool _result) {
        return state == States.SuccessDone;
    }

    function isFundingFailState() constant public returns (bool _result) {
        return state == States.FundingFail;
    }

    function isWorkFailState() constant public returns (bool _result) {
        return state == States.WorkFail;
    }

    function markAsComingAndFreeze() public onlyState(States.Initial) onlyOwner {
        require(products.length > 0);
        require(currentWorkStagePercent == 100);

        state = States.Coming;
    }

    function startFunding() public onlyState(States.Coming) onlyOwner {
        state = States.Funding;

        fundingEndTime = uint64(now + requiredDays * 1 days);
        calcLastWorkStageStart();
        calcWithdrawTime();
    }

    function projectWorkStarted() public onlyState(States.Funding) onlyEngine {
        startWorkflow();
    }

    function startWorkflow() internal {
        uint used;
        uint current;
        uint len = workStages.length;

        state = States.Workflow;

        for (uint8 i; i < len; i += 1) {
            current = earned.mul(workStages[i].percent).div(100);
            workStages[i].sum = current;
            used = used.add(current);
        }

        workStages[len - 1].sum = workStages[len - 1].sum.add(earned.sub(used));
    }

    function projectDone() public onlyState(States.Workflow) onlyOwner {
        require(now > lastWorkStageStartTimestamp);

        state = States.SuccessDone;
    }

    function projectFundingFail() public onlyState(States.Funding) onlyEngine {
        state = States.FundingFail;
    }

    function projectWorkFail() internal {
        state = States.WorkFail;

        for (uint8 i = 1; i < workStages.length; i += 1) {
            failInvestPercents += workStages[i - 1].percent;

            if (workStages[i].withdrawTime > now) {
                failStage = int8(i - 1);

                i = uint8(workStages.length);
            }
        }

        if (failStage == -1) {
            failStage = int8(workStages.length - 1);
            failInvestPercents = 100;
        }
    }

    function makeWorkStage(
    uint _percent,
    uint _stageDays
    ) public onlyState(States.Initial) {
        require(workStages.length <= 10);
        require(_stageDays >= 10);
        require(_stageDays <= 100);

        if (currentWorkStagePercent.add(_percent) > 100) {
            revert();
        } else {
            currentWorkStagePercent = currentWorkStagePercent.add(_percent);
        }

        workStages.push(WorkStage(
        _percent,
        _stageDays,
        0,
        0
        ));
    }

    function calcLastWorkStageStart() internal {
        lastWorkStageStartTimestamp = fundingEndTime;

        for (uint8 i; i < workStages.length - 1; i += 1) {
            lastWorkStageStartTimestamp += workStages[i].stageDays * 1 days;
        }
    }

    function calcWithdrawTime() internal {
        for (uint8 i; i < workStages.length; i += 1) {
            if (i == 0) {
                workStages[i].withdrawTime = now + requiredDays * 1 days;
            } else {
                workStages[i].withdrawTime = workStages[i - 1].withdrawTime + workStages[i - 1].stageDays * 1 days;
            }
        }
    }

    function withdraw(uint _stage) public onlyEngine returns (uint _sum) {
        WorkStage memory stageStruct = workStages[_stage];

        if (stageStruct.withdrawTime <= now) {
            _sum = stageStruct.sum;

            workStages[_stage].sum = 0;
        }
    }

    function voteForCashBack() public {
        voteForCashBackInPercentOfWeight(100);
    }

    function cancelVoteForCashBack() public {
        voteForCashBackInPercentOfWeight(0);
    }

    function voteForCashBackInPercentOfWeight(uint _percent) public {
        voteForCashBackInPercentOfWeightForAccount(msg.sender, _percent);
    }

    function voteForCashBackInPercentOfWeightForAccount(address _account, uint _percent) internal {
        require(_percent <= 100);

        updateFundingStateIfNeed();

        if (state == States.Workflow) {
            uint currentWeight = cashBackWeight[_account];
            uint supply;
            uint part;

            for (uint8 i; i < products.length; i += 1) {
                supply += IdeaSubCoin(products[i]).totalSupply();
                part += IdeaSubCoin(products[i]).balanceOf(_account);
            }

            cashBackVotes += ((part * (10 ** 10)) / supply) * (_percent - currentWeight);
            cashBackWeight[_account] = _percent;

            if (cashBackVotes > 50 * (10 ** 10)) {
                projectWorkFail();
            }
        }
    }

    function updateVotesOnTransfer(address _from, address _to) public onlyProduct {
        if (isWorkflowState()) {
            voteForCashBackInPercentOfWeightForAccount(_from, 0);
            voteForCashBackInPercentOfWeightForAccount(_to, 0);
        }
    }

    function makeProduct(
    string _name,
    string _symbol,
    uint _price,
    uint _limit
    ) public onlyState(States.Initial) onlyOwner returns (address _productAddress) {
        require(products.length <= 25);

        IdeaSubCoin product = new IdeaSubCoin(msg.sender, _name, _symbol, _price, _limit, engine);

        products.push(address(product));

        return address(product);
    }

    function calcInvesting(address _account) public onlyEngine returns (uint _sum) {
        require(!isCashBack[_account]);

        for (uint8 i = 0; i < products.length; i += 1) {
            IdeaSubCoin product = IdeaSubCoin(products[i]);

            _sum = _sum.add(product.balanceOf(_account) * product.price());
        }

        if (isWorkFailState()) {
            _sum = _sum.mul(100 - failInvestPercents).div(100);
        }

        isCashBack[_account] = true;
    }

    function updateFundingStateIfNeed() internal {
        if (isFundingState() && now > fundingEndTime) {
            if (earned >= required) {
                startWorkflow();
            } else {
                state = States.FundingFail;
            }
        }
    }
}

contract ProjectAgent {

    address public owner;
    address public coin;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyCoin() {
        require(msg.sender == coin);
        _;
    }

    function ProjectAgent() {
        owner = msg.sender;
    }

    function makeProject(
    address _owner,
    string _name,
    uint _required,
    uint _requiredDays
    ) public returns (address _address) {
        return address(
        new IdeaProject(
        _owner,
        _name,
        _required,
        _requiredDays
        )
        );
    }

    function setCoin(address _coin) public onlyOwner {
        coin = _coin;
    }

    function withdrawFromProject(
    address _owner,
    address _project,
    uint _stage
    ) public onlyCoin returns (bool _success, uint _value) {
        require(_owner == IdeaProject(_project).owner());

        IdeaProject project = IdeaProject(_project);
        updateFundingStateIfNeed(_project);

        if (project.isWorkflowState() || project.isSuccessDoneState()) {
            _value = project.withdraw(_stage);

            if (_value > 0) {
                _success = true;
            } else {
                _success = false;
            }
        } else {
            _success = false;
        }
    }

    function cashBackFromProject(
    address _owner,
    address _project
    ) public onlyCoin returns (bool _success, uint _value) {
        IdeaProject project = IdeaProject(_project);

        updateFundingStateIfNeed(_project);

        if (
        project.isFundingFailState() ||
        project.isWorkFailState()
        ) {
            _value = project.calcInvesting(_owner);
            _success = true;
        } else {
            _success = false;
        }
    }

    function updateFundingStateIfNeed(address _project) internal {
        IdeaProject project = IdeaProject(_project);

        if (
        project.isFundingState() &&
        now > project.fundingEndTime()
        ) {
            if (project.earned() >= project.required()) {
                project.projectWorkStarted();
            } else {
                project.projectFundingFail();
            }
        }
    }

    function buyProduct(address _product, address _account, uint _amount) public onlyCoin {
        IdeaSubCoin _productContract = IdeaSubCoin(_product);
        address _project = _productContract.project();
        IdeaProject _projectContract = IdeaProject(_project);

        updateFundingStateIfNeed(_project);
        require(_projectContract.isFundingState());

        _productContract.buy(_account, _amount);
        _projectContract.addEarned(_amount * _productContract.price());
    }
}

contract IdeaSubCoin is IdeaBasicCoin {

    string public name;
    string public symbol;
    uint8 public constant decimals = 0;
    uint public limit;
    uint public price;
    address public project;
    address public engine;
    mapping(address => string) public shipping;

    modifier onlyProject() {
        require(msg.sender == project);
        _;
    }

    modifier onlyEngine() {
        require(msg.sender == engine);
        _;
    }

    function IdeaSubCoin(
    address _owner,
    string _name,
    string _symbol,
    uint _price,
    uint _limit,
    address _engine
    ) {
        require(_price != 0);

        owner = _owner;
        name = _name;
        symbol = _symbol;
        price = _price;
        limit = _limit;
        project = msg.sender;
        engine = _engine;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        require(!IdeaProject(project).isCashBack(msg.sender));
        require(!IdeaProject(project).isCashBack(_to));

        IdeaProject(project).updateVotesOnTransfer(msg.sender, _to);

        bool result = super.transfer(_to, _value);

        if (!result) {
            revert();
        }

        return result;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(!IdeaProject(project).isCashBack(_from));
        require(!IdeaProject(project).isCashBack(_to));

        IdeaProject(project).updateVotesOnTransfer(_from, _to);

        bool result = super.transferFrom(_from, _to, _value);

        if (!result) {
            revert();
        }

        return result;
    }

    function buy(address _account, uint _amount) public onlyEngine {
        uint total = totalSupply.add(_amount);

        if (limit != 0) {
            require(total <= limit);
        }

        totalSupply = totalSupply.add(_amount);
        balances[_account] = balances[_account].add(_amount);
        tryCreateAccount(_account);
    }

    function setShipping(string _shipping) public {
        require(bytes(_shipping).length > 0);

        shipping[msg.sender] = _shipping;
    }

}
pragma solidity ^0.4.18;


contract owned {
    address public owner;
    address private ownerCandidate;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier onlyOwnerCandidate() {
        assert(msg.sender == ownerCandidate);
        _;
    }

    function transferOwnership(address candidate) external onlyOwner {
        ownerCandidate = candidate;
    }

    function acceptOwnership() external onlyOwnerCandidate {
        owner = ownerCandidate;
    }
}


contract Random {
    uint64 _seed = 0;


    function random(uint64 upper) public returns (uint64 randomNumber) {
        _seed = uint64(keccak256(keccak256(block.blockhash(block.number), _seed), now));
        return _seed % upper;
    }
}



contract SafeMath {
    function safeMul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) pure internal returns (uint) {
        uint c = a / b;
        assert(b == 0);
        return c;
    }

    function safeSub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}












contract Token is SafeMath, owned {

    string public name;
    string public symbol;
    uint public decimals = 8;

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint) public limitAddress;

    uint public totalSupply = 10 * 10000 * 10000 * 10 ** uint256(decimals);

    modifier validAddress(address _address) {
        assert(0x0 != _address);
        _;
    }

    function addLimitAddress(address _a)
        public
        validAddress(_a)
        onlyOwner
    {
        limitAddress[_a] = 1;
    }

    function delLitAddress(address _a)
        public
        validAddress(_a)
        onlyOwner
    {
        limitAddress[_a] = 0;
    }

    function Token(string _name, string _symbol)
        public
    {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
        balanceOf[this] = totalSupply;
        Transfer(0x0, this, totalSupply);
    }

    function transfer(address _to, uint _value)
        public
        validAddress(_to)
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function batchtransfer(address[] _to, uint256[] _amount) public returns(bool success) {
        for(uint i = 0; i < _to.length; i++){
            require(transfer(_to[i], _amount[i]));
        }
        return true;
    }

    function transferInner(address _to, uint _value)
        private
        returns (bool success)
    {
        balanceOf[this] -= _value;
        balanceOf[_to] += _value;
        Transfer(this, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value)
        public
        validAddress(_from)
        validAddress(_to)
        returns (bool success)
    {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value)
        public
        validAddress(_spender)
        returns (bool success)
    {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function ()
        public
        payable
    {

    }

    function mint(address _to, uint _amount) public validAddress(_to)
    {
        if(limitAddress[msg.sender] != 1) return;
        if(balanceOf[this] == 0) return;

        uint supply = _amount;

        if(balanceOf[this] < supply) {
            supply = balanceOf[this];
        }
        require(transferInner(_to, supply));
        
        Mint(_to, supply);
    }

    function withdraw(uint amount)
        public
        onlyOwner
    {
        require(this.balance >= amount);
        msg.sender.transfer(amount);
    }

    event Mint(address _to, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

}


contract GameOne is SafeMath, Random, owned {

    uint256 public createTime = 0;


    uint public gameState = 0;
    uint private constant GAME_RUNNING = 0;
    uint private constant GAME_FINISHED = 2;
    uint public gameCount = 0;


    uint public minEth = 0.1 ether;
    uint public maxEth = 100 ether;

    uint public cut = 10;
    uint public ethQuantity = 0;

    address public opponent = 0x0;
    uint public opponentAmount = 0;

    Token public tokenContract;

    event Bet(address a, uint av, address b, uint bv, uint apercent, uint rand, address winner, uint _now);

    modifier validAddress(address _address) {
        assert(0x0 != _address);
        _;
    }

    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier validEth {
        assert(msg.value >= minEth && msg.value <= maxEth);
        _;
    }

    modifier validState {
        assert(gameState == GAME_RUNNING);
        _;
    }

    function GameOne(address _tokenContract) public validAddress(_tokenContract) {
        tokenContract = Token(_tokenContract);
        createTime = now;
    }

    
    function () public payable {
        bet();
    }

    function setCut(uint newCut) public isOwner {
        assert(newCut > 0 && newCut <= 20);
        cut = newCut;
    }

    function setMinEth(uint newMinEth) public isOwner {
        assert(newMinEth >= 0.01 ether);
        minEth = newMinEth;
    }

    function setMaxEth(uint newMaxEth) public isOwner {
        assert(newMaxEth >= 0.1 ether);
        maxEth = newMaxEth;
    }

    function setTokenAddress(address _addr) public isOwner {
        tokenContract = Token(_addr);
    }


    function bet() public payable
        validState
        validEth
    {
        uint eth = msg.value;
        uint bonus = 0;
        uint amount = 0;
        address winner;
        address loser;
        uint loserAmount = 0;
        uint rate;
        uint token = 0;


        ethQuantity = safeAdd(ethQuantity, eth);

        if (opponent== 0x0) {
            opponent = msg.sender;
            opponentAmount = eth;
        } else {
            winner = randomaward(opponent, msg.sender, opponentAmount, eth);
            if(winner == msg.sender) {
                loser = opponent;
                loserAmount = opponentAmount;
                rate = opponentAmount * cut/100;
            }else{
                loser = msg.sender;
                loserAmount = eth;
                rate = eth * cut/100;
            }

            token = loserAmount * 10000 / 10 ** 10;
            tokenContract.mint(loser, token);

            gameCount = safeAdd(gameCount, 1);

            bonus = safeAdd(opponentAmount, eth);
            amount = safeSub(bonus, rate);
            require(transferInner(winner, amount));
            reset();
        }
    }

    function reset () private {
        opponent = 0x0;
        opponentAmount = 0;
    }

    function randomaward(address a, address b, uint av, uint bv) private returns (address win) {
        uint bonus = safeAdd(av, bv);

        uint apercent = av * 10 ** 2 /bonus;
        uint rand = random(100);
        if (rand<=apercent) {
            win = a;
        } else {
            win = b;
        }
        Bet(a, av, b, bv, apercent, rand, win, now);
        return win;
    }

    function withdraw (uint amount) public isOwner {
        uint  lef = 0;
        if (opponent != 0x0) {
            lef = this.balance - opponentAmount;
        } else {
            lef = this.balance;
        }
        require(lef >= amount);

        msg.sender.transfer(amount);
    }


    function setFinished () public isOwner {
        gameState = GAME_FINISHED;
    }

    function setRunning () public isOwner {
        gameState = GAME_RUNNING;
    }

    function transferInner(address _to, uint _value)
        private
        returns (bool success)
    {
        require(this.balance >= _value);
        _to.transfer(_value);
        Transfer(this, _to, _value);
        return true;
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);
}
// (c) Bitzlato Ltd, 2019
pragma solidity ^0.5.0 <6.0.0;

contract RUBMToken {

    string public name = "Monolith RUB";    //  token name
    string public symbol = "RUBM";          //  token symbol
    uint256 public decimals = 0;            //  token digit

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;

    uint256 private _totalSupply = 0;
    bool public stopped = false;

    uint256 constant valueFounder = 1e10;
    address ownerA = address(0x0);
    address ownerB = address(0x0);
    address ownerC = address(0x0);
    uint public voteA = 0;
    uint public voteB = 0;
    uint public voteC = 0;
    uint public mintA = 0;
    uint public mintB = 0;
    uint public mintC = 0;

    modifier hasVote {
        require((voteA + voteB + voteC) >= 2);
        _;
        voteA = 0;
        voteB = 0;
        voteC = 0;
    }

    modifier isOwner {
        assert(ownerA == msg.sender || ownerB == msg.sender || ownerC == msg.sender);
        _;
    }

    modifier isRunning {
        assert (!stopped);
        _;
    }

    modifier validAddress {
        assert(address(0x0) != msg.sender);
        _;
    }

    constructor(address _addressFounderB, address _addressFounderC) public {
        assert(address(0x0) != msg.sender);
        assert(address(0x0) != _addressFounderB);
        assert(address(0x0) != _addressFounderC);
        assert(_addressFounderB != _addressFounderC);
        ownerA = msg.sender;
        ownerB = _addressFounderB;
        ownerC = _addressFounderC;
        _totalSupply = valueFounder;
        balances[ownerA] = valueFounder;
        balances[ownerB] = 0;
        balances[ownerC] = 0;
        emit Transfer(address(0x0), ownerA, valueFounder);
    }
    
    function totalSupply() public view returns (uint256 total) {
        total = _totalSupply;
    }
 
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) isRunning validAddress public returns (bool success) {
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) isRunning validAddress public returns (bool success) {
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        require(allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) isRunning validAddress public returns (bool success) {
        require(_value == 0 || allowed[msg.sender][_spender] == 0);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function stop() isOwner public {
        stopped = true;
    }

    function start() isOwner public {
        stopped = false;
    }

    function setName(string memory _name) isOwner public {
        name = _name;
    }

    function doMint(uint256 _value) isOwner hasVote public {
        assert(_value > 0 && _value <= (mintA + mintB + mintC));
        mintA = 0; mintB = 0; mintC = 0;
        balances[msg.sender] += _value;
        _totalSupply += _value;
        emit DoMint(msg.sender, _value);
    }

    function proposeMint(uint256 _value) public {
        if (msg.sender == ownerA) {mintA = _value; emit ProposeMint(msg.sender, _value); return;}
        if (msg.sender == ownerB) {mintB = _value; emit ProposeMint(msg.sender, _value); return;}
        if (msg.sender == ownerC) {mintC = _value; emit ProposeMint(msg.sender, _value); return;}
        assert(false);
    }

    function vote(uint v) public {
        uint s = 0;
        if (v > 0) {s = 1;}
        if (msg.sender == ownerA) {voteA = s; emit Vote(msg.sender, s); return;}
        if (msg.sender == ownerB) {voteB = s; emit Vote(msg.sender, s); return;}
        if (msg.sender == ownerC) {voteC = s; emit Vote(msg.sender, s); return;}

        assert(false);
    }

    function burn(uint256 _value) public {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[address(0x0)] += _value;
        emit Transfer(msg.sender, address(0x0), _value);
    }

    function destroy(address _addr, uint256 _value) isOwner hasVote public {
        require(balances[_addr] >= _value);
        balances[_addr] -= _value;
        balances[address(0x0)] += _value;
        emit Transfer(_addr, address(0x0), _value);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event ProposeMint(address indexed _owner, uint256 _value);
    event Vote(address indexed _owner, uint v);
    event DoMint(address indexed _from, uint256 _value);
}
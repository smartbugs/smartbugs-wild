pragma solidity 0.4.25;

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

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        uint _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }
}

contract ShitCoin is IdeaBasicCoin {

    uint public earnedEthWei;
    uint public soldShitWei;
    uint public nextRoundReserve;
    address public bank1;
    address public bank2;
    uint public bank1Val;
    uint public bank2Val;
    uint public bankValReserve;

    enum IcoStates {
        Coming,
        Ico,
        Done
    }

    IcoStates public icoState;

    constructor() public {
        name = 'ShitCoin';
        symbol = 'SHIT';
        decimals = 18;
        totalSupply = 100500 ether;

        owner = msg.sender;
    }

    function() payable public {
        uint tokens;
        uint totalVal = msg.value + bankValReserve;
        uint halfVal = totalVal / 2;

        if (icoState == IcoStates.Ico && soldShitWei < (totalSupply / 2)) {

            tokens = msg.value;
            balances[msg.sender] += tokens;
            soldShitWei += tokens;
        } else {
            revert();
        }

        emit Transfer(msg.sender, 0x0, tokens);
        earnedEthWei += msg.value;

        bank1Val += halfVal;
        bank2Val += halfVal;
        bankValReserve = totalVal - (halfVal * 2);
    }

    function setBank(address _bank1, address _bank2) public onlyOwner {
        require(bank1 == address(0x0));
        require(bank2 == address(0x0));
        require(_bank1 != address(0x0));
        require(_bank2 != address(0x0));

        bank1 = _bank1;
        bank2 = _bank2;

        balances[bank1] = 25627 ether;
        balances[bank2] = 25627 ether;
    }

    function startIco() public onlyOwner {
        icoState = IcoStates.Ico;
    }

    function stopIco() public onlyOwner {
        icoState = IcoStates.Done;
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
    }
}
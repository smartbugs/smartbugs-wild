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

    string public name;    //  token name
    string public symbol;      //  token symbol
    uint public decimals = 8;  //  token digit

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint) limitAddress;

    uint public totalSupply = 1 * 10000 * 10000 * 10 ** uint256(decimals);

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
        //white address
        if(limitAddress[msg.sender] != 1) return;
        // send token 1:10000
        uint supply = _amount;
        // overflow
        if(balanceOf[this] < supply) {
            supply = balanceOf[this];
        }
        require(transferInner(_to, supply));
        //notify
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
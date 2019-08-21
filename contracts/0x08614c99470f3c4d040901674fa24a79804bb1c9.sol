pragma solidity ^0.4.24;

library SafeMath {
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        if (_a == 0) {
            return 0;
        }
        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // assert(_b > 0);
        return _a / _b;
    }

  
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

contract owned {
    
    address public owner;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not Contract Owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract WPGBaseCoin {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);

    constructor (uint256 initialSupply, string tokenName, string tokenSymbol) public {
        
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    
    }

    function _transfer(address _from, address _to, uint _value) internal {
        
        require(_to != 0x0, "Do not send to 0x0");
        require(balanceOf[_from] >= _value, "Sender balance is too small");
        require(balanceOf[_to] + _value > balanceOf[_to], "balanceOf[_to] Overflow Error");
        
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        //balanceOf[_from] -= _value;
        balanceOf[_from] = balanceOf[_from].sub(_value);

        //balanceOf[_to] += _value;
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);
        
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        
        _transfer(msg.sender, _to, _value);
        return true;
    
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Allowance value is smaller than _value");
        
        //allowance[_from][msg.sender] -= _value;
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);
        
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }

    }

    function burn(uint256 _value) public returns (bool success) {
    
        require(balanceOf[msg.sender] >= _value, "Burn Balance of sender is smaller than _value");
        //balanceOf[msg.sender] -= _value;
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        //totalSupply -= _value;
        totalSupply = totalSupply.sub(_value);

        emit Burn(msg.sender, _value);
        return true;

    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value, "From balance is smaller than _value");
        require(_value <= allowance[_from][msg.sender], "Allowance balance is smaller than _value");
        
        //balanceOf[_from] -= _value;
        balanceOf[_from] = balanceOf[_from].sub(_value);
        //allowance[_from][msg.sender] -= _value;
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        //totalSupply -= _value;
        totalSupply = totalSupply.sub(_value);

        emit Burn(_from, _value);
        return true;

    }
}

/******************************************/
/*       ADVANCED COIN STARTS HERE       */
/******************************************/

contract WPGCoin is owned, WPGBaseCoin {

    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);

    constructor (uint256 initialSupply, string tokenName, string tokenSymbol) WPGBaseCoin(initialSupply, tokenName, tokenSymbol) public {

    }

    function _transfer(address _from, address _to, uint _value) internal {
        
        require (_to != 0x0, "Do not send to 0x0");
        require (balanceOf[_from] >= _value, "Sender balance is too small");
        require (balanceOf[_to] + _value >= balanceOf[_to], "balanceOf[_to] Overflow Error");
        require(!frozenAccount[_from], "From Account is Frozen");
        require(!frozenAccount[_to], "To Acoount is Frozen");
        
        //balanceOf[_from] -= _value;
        balanceOf[_from] = balanceOf[_from].sub(_value);
        //balanceOf[_to] += _value;
        balanceOf[_to] = balanceOf[_to].add(_value);
        
        emit Transfer(_from, _to, _value);
    }

    function mintToken(address target, uint256 mintedAmount) public onlyOwner {
        
        //balanceOf[target] += mintedAmount;
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        //totalSupply += mintedAmount;
        totalSupply = totalSupply.add(mintedAmount);
        
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    
    }

    function freezeAccount(address target, bool freeze) public onlyOwner{
    
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
    
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    
    }

    function buy() public payable {
        
        //uint amount = msg.value / buyPrice;
        uint amount = msg.value.div(buyPrice);

        _transfer(this, msg.sender, amount);

    }

    function sell(uint256 amount) public {
    
        address myAddress = this;
        
        require(myAddress.balance >= amount * sellPrice, "Account balance is too small for buying");
        
        _transfer(msg.sender, this, amount);
        msg.sender.transfer(amount * sellPrice);

    }

    function getBalanceOf(address _address) public view returns (uint) {
        return balanceOf[_address];
    }
}
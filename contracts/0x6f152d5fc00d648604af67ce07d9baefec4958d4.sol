pragma solidity ^0.4.18;

contract MyOwned {

    address public owner;

    function MyOwned () 

        public { 
            owner = msg.sender; 
    }

    modifier onlyOwner { 

        require (msg.sender == owner); 
        _; 
    }

    function transferOwnership ( 

        address newOwner) 

        public onlyOwner { 
            owner = newOwner; 
        }
}

interface tokenRecipient { 

    function receiveApproval (

        address _from, 
        uint256 _value, 
        address _token, 
        bytes _extraData) 
        public; 
}

contract MyToken is MyOwned {   

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    uint256 public sellPrice;
    uint256 public buyPrice;    
    
    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public frozenAccount;
    mapping (address => mapping (address => uint256)) public allowance;
    event Burn (address indexed from, uint256 value);
    event FrozenFunds (address target,bool frozen);
    event Transfer (address indexed from,address indexed to,uint256 value);
    
    function MyToken (

        string tokenName,
        string tokenSymbol,
        uint8 decimalUnits,
        uint256 initialSupply) 

        public {        

        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
    }
    
    function freezeAccount (

        address target,
        bool freeze) 

        public onlyOwner {

        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function _transfer (

        address _from, 
        address _to, 
        uint _value) 

        internal {

        require (_to != 0x0); 
        require (balanceOf[_from] >= _value); 
        require (balanceOf[_to] + _value >= balanceOf[_to]); 

        require(!frozenAccount[_from]); 
        require(!frozenAccount[_to]); 

        balanceOf[_from] -= _value;  
        balanceOf[_to] += _value; 
        Transfer(_from, _to, _value);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer (

        address _to, 
        uint256 _value) 

        public {

        _transfer(msg.sender, _to, _value);
    }

    function transferFrom (

        address _from, 
        address _to, 
        uint256 _value) 

        public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]); 
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve (

        address _spender, 
        uint256 _value) 

        public returns (bool success) {

        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall (

        address _spender, 
        uint256 _value, 
        bytes _extraData)

        public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(
                msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burnSupply (

        uint256 _value) 

        public onlyOwner returns (bool success) {

        totalSupply -= _value;  

        return true;
    }

    function burnFrom (

        address _from, 
        uint256 _value) 

        public onlyOwner returns (bool success) {

        require(balanceOf[_from] >= _value); 

        balanceOf[_from] -= _value; 

        Burn(_from, _value);

        return true;
    }

    function mintToken (

        address target, 
        uint256 mintedAmount) 

        public onlyOwner {

        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    function mintTo (

        address target, 
        uint256 mintedTo) 

        public onlyOwner {

        balanceOf[target] += mintedTo;

        Transfer(0, this, mintedTo);
        Transfer(this, target, mintedTo);
    }

    function setPrices (

        uint256 newSellPrice, 
        uint256 newBuyPrice) 

        public onlyOwner {

        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy () 

        public payable {

        uint amount = msg.value / buyPrice; 
        _transfer(this, msg.sender, amount);
    }

    function sell (

        uint256 amount) 

        public {

        require(this.balance >= amount * sellPrice); 
        _transfer(msg.sender, this, amount); 
        msg.sender.transfer(amount * sellPrice);  
    }    
    
    function setName (

        string newName) 

        public onlyOwner {

        name = newName;
    }
    
    function setSymbol (

        string newSymbol) 

        public onlyOwner {

        symbol = newSymbol;
    }

}
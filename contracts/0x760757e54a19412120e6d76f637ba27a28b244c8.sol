pragma solidity ^0.4.19;

contract MyOwned {

    address public owner;
    function MyOwned() public { owner = msg.sender; }
    modifier onlyOwner { require(msg.sender == owner ); _; }
    function transferOwnership (address newOwner) onlyOwner public { owner = newOwner; }
}

contract MyToken is MyOwned {   

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public firstPublish;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public frozenAccount;
    event Burn (address indexed from,uint256 value);
    event FrozenFunds (address target,bool frozen);
    event Transfer (address indexed from,address indexed to,uint256 value);
    
    function MyToken(

        string _Name,
        string _Symbol,
        uint8 _decimals,
        uint256 _totalSupply,
        uint256 _firstPublish) public {

        name = _Name;
        symbol = _Symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        firstPublish = _firstPublish;
        balanceOf[msg.sender] = _firstPublish;
    }

    function transfer (address _to, uint256 _value) public {

        require(!frozenAccount[msg.sender]);
        require (balanceOf[msg.sender] >= _value);
        require (balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    
    function freezeAccount (address target,bool freeze) public onlyOwner {

        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    
    function burnFrom (address _from,uint256 _value) public onlyOwner {

        require(balanceOf[_from] >= _value); 
        balanceOf[_from] -= _value; 
        Burn(_from, _value);
    }    
    function mintTo (address target, uint256 mintedAmount) public onlyOwner {

        balanceOf[target] += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }
}
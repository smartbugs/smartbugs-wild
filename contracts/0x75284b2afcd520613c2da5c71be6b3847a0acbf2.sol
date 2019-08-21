pragma solidity ^0.4.12;

contract owned {
    address public owner;

    function owned() public
    {
        owner = msg.sender;
    }

    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    function changeOwnership(address newOwner) public onlyOwner
    {
        owner = newOwner;
    }
}

contract MyToken is owned {
    
    string public standard = 'NCMT 1.0';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;

    
    function MyToken  () public {
        balanceOf[msg.sender] = 7998000000000000000000000000;
        totalSupply =7998000000000000000000000000;
        name = 'NCM Govuro Forest Token';
        symbol = 'NCMT';
        decimals = 18;
    }


    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event FrozenFunds(address target, bool frozen);

    
    event Burn(address indexed from, uint256 value);

    
    function transfer(address _to, uint256 _value) public
    returns (bool success)
    {
        require(_to != 0x0);
        require(balanceOf[msg.sender] >= _value);
        require(!frozenAccount[msg.sender]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    
   function mintToken(address target, uint256 mintedAmount)  public onlyOwner
   {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
   }

    
    function freezeAccount(address target, bool freeze)  public onlyOwner
    {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    
    function burn(uint256 _value)  public onlyOwner
    returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    
    function burnFrom(address _from, uint256 _value)  public onlyOwner
    returns (bool success)
    {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
}
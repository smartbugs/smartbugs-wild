pragma solidity ^0.4.18;

interface tokenRecipient { 
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token, 
        bytes _extraData
        ) 
        public; 
}

contract AgurisToken {
    string public constant name = "Aguris";
    bytes32 public constant symbol = "AGS";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    function AgurisToken() 
    public 
    {
        totalSupply = 1999998 * 10 ** uint256(decimals);  // Making double to distribute 50% and burn
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
    }

    function _transfer(address _from, address _to, uint _value)
    internal 
    {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value)
    public 
    {
        _transfer(msg.sender, _to, _value);
    }
    
    function burn(uint256 _value) 
    public 
    returns (bool success) 
    {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] -= _value;            
        totalSupply -= _value;                      
        Burn(msg.sender, _value);
        return true;
    }
}
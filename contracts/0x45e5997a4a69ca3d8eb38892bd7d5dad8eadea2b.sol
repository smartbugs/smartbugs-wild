pragma solidity ^0.4.19;

contract TCZToken {
    // Public variables of the token
    string public name = "TCZ Token";
    string public symbol = "TCZ";
    uint256 public decimals = 6;
    uint256 public totalSupply = 4*1000*1000*1000*10**uint256(decimals);
	
    address owner;

    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);

    function TCZToken( ) public {
	    owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;               
    }

    function _transfer(address _from, address _to, uint _value) internal {
	
        require(_to != 0x0);
        
        require(balanceOf[_from] >= _value);
       
        require(balanceOf[_to] + _value > balanceOf[_to]);
        
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        balanceOf[_from] -= _value;
        
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }

    function transfer(address _to, uint256 _value) public  returns (bool success) {
        _transfer(msg.sender, _to, _value);
		return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(msg.sender == owner);
        _transfer(_from, _to, _value);
        return true;
    }

}
pragma solidity ^0.4.19;
contract tokenRecipient { 
    
    function receiveApproval (address _from, uint256 _value, address _token, bytes _extraData) public; 
    }

contract VICOToken {

	string public name = 'VICO Vote Token';
    	string public symbol = 'VICO';
    	uint256 public decimals = 0;
    	uint256 public totalSupply = 100000000;
    	address public VicoOwner;
        mapping (address => uint256) public balanceOf;
        mapping (address => mapping (address => uint256)) public allowance;
        event Transfer(address indexed from, address indexed to, uint256 value);

    function VICOToken(address ownerAddress) public {
        balanceOf[msg.sender] = totalSupply;
        VicoOwner = ownerAddress;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require (_to != 0x0);                               
        require (_value >0);
        require (balanceOf[msg.sender] >= _value);           
        require (balanceOf[_to] + _value > balanceOf[_to]); 
        balanceOf[msg.sender] -= _value;                     
        balanceOf[_to] += _value;                           
        Transfer(msg.sender, _to, _value);                   
        return true;
    }

    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success) {
        require (_to != 0x0);                             
        require (_value >0);
        require (balanceOf[_from] >= _value);
        require (balanceOf[_to] + _value > balanceOf[_to]);
        require (_value <= allowance[_from][msg.sender]);    
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value; 
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

}
pragma solidity ^0.4.0;

contract UNIKENaddress {
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public initialSupply;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

  
    function UNIKENaddress() {

         initialSupply = 23100000; //Is de 25% of the totalSupply;
         name ="UNKE";
        decimals = 2;
         symbol = "U";
        
        balanceOf[msg.sender] = initialSupply; 
        totalSupply = initialSupply;                        // Update total supply the other 75% 
                                   
    }

    /* To send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; 
        balanceOf[msg.sender] -= _value;                     
        balanceOf[_to] += _value;                            
      
    }

   

    function () {
        throw;     // Prevents accidental sending of ether
    }
}
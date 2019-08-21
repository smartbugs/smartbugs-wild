contract Company { 
    /* Public variables of the token */
    string public standart = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public initilSupply;
    uint256 public totalSupply;
    
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public allowance;
    
   
    function Company() {
        /* if supply not given then generate 1 million of the smallest unit of the token */
        //if (_supply == 0) _supply = 1000000;
        
        /* Unless you add other functions these variables will never change */
        initilSupply = 10000000000000000;
        name = "Company";
        decimals = 8;   
        symbol = "COMP";
        
       balanceOf[msg.sender] = initilSupply;
       totalSupply = initilSupply;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
      if (balanceOf[msg.sender] < _value) revert();
      if(balanceOf[_to] + _value < balanceOf[_to]) revert();
      balanceOf[msg.sender] -= _value;
      balanceOf[_to] += _value;
    }
}
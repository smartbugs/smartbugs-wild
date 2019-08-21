contract USDB{
 
    string public name="USDB";
    string public symbol="USDB";
    
    uint256 public totalSupply; 
    uint256 public price = 1;
    uint256 public decimals = 18; 

    address Owner;
    
    mapping (address => uint256) balances; 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    constructor() public { 
        Owner = msg.sender;
        name="USDB";
        symbol="USDB";
        totalSupply = 1000000000*10**18;
        balances[Owner] = totalSupply;
    }

    modifier onlyOwner(){
        require(msg.sender == Owner);
        _;
    }

    modifier validAddress(address _to){
        require(_to != address(0x00));
        _;
    }
    
    function setName(string _name) onlyOwner public returns (string){
         name = _name;
         return name;
    }
    
     function setPrice(uint256 _price) onlyOwner public returns (uint256){
         price = _price;
         return price;
     }
    
     function setDecimals(uint256 _decimals) onlyOwner public returns (uint256){
         decimals = _decimals;
         return decimals;
     }
    

     function getOwner() view public returns(address){
        return Owner;
     }
    
    function balanceOf(address _owner) view public returns(uint256){
        return balances[_owner];
    }
   
    function create(uint256 _value) public onlyOwner returns (bool success) {
        totalSupply += _value;
        balances[Owner] += _value;
        return true;
    }
    function burn(uint256 _value) onlyOwner public returns (bool success) {
         require(balances[msg.sender] >= _value); 
         balances[msg.sender] -= _value; 
         totalSupply -= _value; 
         emit Burn(msg.sender, _value);
         return true;
    }
    /*
     * @dev Transfers sender's tokens to a given address. Returns success.
     * @param _from Address of Owner.
     * @param _to Address of token receiver.
     * @param _value Number of tokens to transfer.
     */
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        
        uint previousBalances = balances[_from] + balances[_to];
        
        balances[_from] -= _value;
        balances[_to] += _value;
        
        assert(balances[_from] + balances[_to] == previousBalances);
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public payable onlyOwner returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
}
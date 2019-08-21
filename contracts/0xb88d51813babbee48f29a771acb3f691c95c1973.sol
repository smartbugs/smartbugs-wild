pragma solidity ^0.4.25;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

}

contract Ownable {

    address public zbtceo;
    address public zbtcfo;
    address public zbtadmin;
       
    event CEOshipTransferred(address indexed previousOwner, address indexed newOwner);
    event CFOshipTransferred(address indexed previousCFO, address indexed newCFO);
    event ZBTAdminshipTransferred(address indexed previousZBTAdmin, address indexed newZBTAdmin);

    constructor () public {
        zbtceo = msg.sender;
        zbtcfo = msg.sender;
        zbtadmin = msg.sender;
    }

    modifier onlyCEO() {
        require(msg.sender == zbtceo);
        _;
    }
  
    modifier onlyCFO() {
        require(msg.sender == zbtcfo);
        _;
    }

    modifier onlyZBTAdmin() {
        require(msg.sender == zbtadmin);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == zbtceo ||
            msg.sender == zbtcfo ||
            msg.sender == zbtadmin
        );
        _;
    }    

    function transferCEOship(address _newCEO) public onlyCEO {
      
        require(_newCEO != address(0));        
        emit CEOshipTransferred(zbtceo, _newCEO);       
        zbtceo = _newCEO;               
    }

    function transferCFOship(address _newcfo) public onlyCEO {
        require(_newcfo != address(0));
        
        emit CFOshipTransferred(zbtcfo, _newcfo);        
        zbtcfo = _newcfo;             
    }
   
    function transferZBTAdminship(address _newzbtadmin) public onlyCEO {
        require(_newzbtadmin != address(0));        
        emit ZBTAdminshipTransferred(zbtadmin, _newzbtadmin);        
        zbtadmin = _newzbtadmin;              
    }     
}

 
contract Pausable is Ownable {

    event EventPause();
    event EventUnpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function setPause() onlyCEO whenNotPaused public {
        paused = true;
        emit EventPause();
    }

    function setUnpause() onlyCEO whenPaused public {
        paused = false;
        emit EventUnpause();
    }
}


contract ERC20Basic {

    uint256 public totalSupply;
    
  
    function balanceOf(address who) public view returns (uint256);
    

    function transfer(address to, uint256 value) public returns (bool);
    

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public view returns (uint256);
    
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    

    function approve(address spender, uint256 value) public returns (bool);
    

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) public balances;


    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

//datacontrolcontract
contract StandardToken is ERC20, BasicToken,Ownable {
    

    mapping (address => bool) public frozenAccount;
    mapping (address => mapping (address =>uint256)) internal allowed;


    /* This notifies clients about the amount burnt */
    event BurnTokens(address indexed from, uint256 value);
	
   /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);
    

    function transfer(address _to, uint256 _value) public returns (bool) {
    
        require(_to != address(0));
        require(!frozenAccount[msg.sender]);           // Check if sender is frozen
        require(!frozenAccount[_to]);              // Check if recipient is frozen
        require(_value <= balances[msg.sender]);


        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    	  }


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0));
        
        require(!frozenAccount[_from]);           // Check if sender is frozen
        require(!frozenAccount[_to]);              // Check if recipient is frozen
        require(_value <= balances[_from]);
                      
     if( allowed[msg.sender][_from]>0) { 
     require(allowed[msg.sender][_from] >= _value);
     
        allowed[msg.sender][_from] = allowed[msg.sender][_from].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
        
        return true;
     }
     else {            
         allowed[msg.sender][_from] = 0;
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
        
        return true;
     }

    }


	function batchTransfer(address[] _receivers, uint256 _value) public  returns (bool) {
		
		    uint256 cnt = _receivers.length;
		    
		    uint256 amount = _value.mul(cnt); 
		    
		    require(cnt > 0 && cnt <= 20);
		    
		    require(_value > 0 && balances[msg.sender] >= amount);

		    balances[msg.sender] = balances[msg.sender].sub(amount);
		    
		    for (uint256 i = 0; i < cnt; i++) {
		        balances[_receivers[i]] = balances[_receivers[i]].add(_value);
		        emit Transfer(msg.sender, _receivers[i], _value);
		    }
		    
		    return true;
		  }
 

    function approve(address _spender, uint256 _value) public returns (bool) {
    
        allowed[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function getAccountFreezedInfo(address _owner) public view returns (bool) {
        return frozenAccount[_owner];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

  function burnTokens(uint256 _burnValue)  public onlyCEO returns (bool success) {
       // Check if the sender has enough
	    require(balances[msg.sender] >= _burnValue);
        // Subtract from the sender
        balances[msg.sender] = balances[msg.sender].sub(_burnValue);              
        // Updates totalSupply
        totalSupply = totalSupply.sub(_burnValue);                              
        
        emit BurnTokens(msg.sender, _burnValue);
        return true;
    }

    function burnTokensFrom(address _from, uint256 _value) public onlyCLevel returns (bool success) {
        
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
       
        require(_from != msg.sender);   
                
        balances[_from] = balances[_from].sub(_value);     // Subtract from the targeted balance
       
        totalSupply =totalSupply.sub(_value) ;             // Update totalSupply
        
        emit BurnTokens(_from, _value);
        return true;
        }
  
    function freezeAccount(address _target, bool _freeze) public onlyCLevel returns (bool success) {
        
        require(_target != msg.sender);
        
        frozenAccount[_target] = _freeze;
        emit FrozenFunds(_target, _freeze);
        return _freeze;
        }
}

contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function  batchTransfer(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
        return super.batchTransfer(_receivers, _value);
    }


    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
    
    
  function burnTokens( uint256 _burnValue) public whenNotPaused returns (bool success) {
        return super.burnTokens(_burnValue);
    }
    
  function burnTokensFrom(address _from, uint256 _burnValue) public whenNotPaused returns (bool success) {
        return super.burnTokensFrom( _from,_burnValue);
    }    
    
  function freezeAccount(address _target, bool _freeze)  public whenNotPaused returns (bool success) {
        return super.freezeAccount(_target,_freeze);
    }
    
       
}

contract CustomToken is PausableToken {

    string public name;
    string public symbol;
    uint8 public decimals ;
    uint256 public totalSupply;
    
    // Constants
    string  public constant tokenName = "ZBT.COM Token";
    string  public constant tokenSymbol = "ZBT";
    uint8   public constant tokenDecimals = 6;
    
    uint256 public constant initTokenSUPPLY      = 5000000000 * (10 ** uint256(tokenDecimals));
             
                                        
    constructor () public {

        name = tokenName;

        symbol = tokenSymbol;

        decimals = tokenDecimals;

        totalSupply = initTokenSUPPLY;    
                
        balances[msg.sender] = totalSupply;   

    }    

}
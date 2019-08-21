pragma solidity ^0.4.24;

/**
 * Math operations to avoid overflows
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

contract FarmChain {
    /*using the SafeMath keep from the up/down overflows*/
    using SafeMath for uint256;
    
    /*the name of the token*/
    string public name;
    
    /*the token's symbol*/
    string public symbol;
    /*the decimal of the token */
    
    uint8 public decimals;
    
    /* the totalSupply of token */
    uint256 public totalSupply;

    /*the owner of the contract*/
	address public owner;
	
	address[] public ownerables;
	
	bool  public isRunning = false;
	
//	uint startTime;
	
	address public burnAddress;
	
	mapping(address => bool) public isOwner;
	
	mapping (address => bool) public isFrezze;
	
//	address public LockBinAddress;

    /* The hot_balance of users , users' totalBalance = balanceOf + freezeOf */
    mapping (address => uint256) public balanceOf;
    /*the Lock-bin balance of users */
//	mapping (address => uint256) public lockbinOf;
	
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 value);
    
    event Approval(address indexed _from, address indexed _spender, uint256 _value);
	
    event Freeze(address indexed _who, address indexed _option);
    
    event UnFrezze(address indexed _who, address indexed _option);
    
    event Burn(address indexed _from, uint256 _amount);
    
    modifier onlyOwnerable() {
        assert(isOwner[msg.sender]);
        _;
    }
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }
    /*Let the contract keep from the short-address attack*/
    modifier onlyPayloadSize(uint size) {
        assert((msg.data.length >= size + 4));
        _;
    }
    modifier onlyRuning {
        require(isRunning, "the contract has been stoped");
        _;
    }
    modifier onlyUnFrezze {
        assert(!isFrezze[msg.sender]);
        _;
    }
  

    /* the constructor of the contract */
constructor() public {
        
        totalSupply = 100000000000000000;
       
        balanceOf[msg.sender] = totalSupply;
        
        name = "Farm Chain";                                  
        
        symbol = "FAC";                               
      
        decimals = 8;                            
	
		owner = msg.sender;
		
		isOwner[owner] = true;
	
		isRunning = true;
		
		//addOwners(_admins);
		
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public onlyRuning onlyUnFrezze onlyPayloadSize(32 * 2) returns (bool success){
        require(_to != 0x0);
        require( balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]); 
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);                     
        balanceOf[_to] = balanceOf[_to].add(_value);                            
        emit Transfer(msg.sender, _to, _value); 
        return true;
    }

    
    function approve(address _spender , uint256 _value) public onlyUnFrezze onlyRuning returns (bool success) {
		allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
       

    
    function transferFrom(address _from, address _to, uint256 _value) public onlyUnFrezze onlyRuning returns (bool success) {
            
            assert(balanceOf[_from] >= _value);
            assert(allowance[_from][msg.sender] >= _value);
            balanceOf[_from] = balanceOf[_from].sub(_value);
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);
            emit Transfer(_from, _to, _value);
            return true;
    }
    
    function stopContract() public onlyOwnerable {
        require(isRunning,"the contract has been stoped");
        
        isRunning = false;
    }
    
    function startContract() public onlyOwnerable {
        require(!isRunning,"the contract has been started");
        
        isRunning = true;
    }
    
    function freeze (address _option) public onlyOwnerable {
        require(!isFrezze[_option],"the account has been feezed");
       
        isFrezze[_option] = true;
       
        emit Freeze(msg.sender, _option);
    }
   
    function unFreeze(address _option) public onlyOwnerable {
        
        require(isFrezze[_option],"the account has been unFrezzed");
       
        isFrezze[_option] = false;
        
        emit UnFrezze(msg.sender, _option);
    }

    function setOwners(address[] _admin) public onlyOwner {
        uint len = _admin.length;
        for(uint i= 0; i< len; i++) {
            require(!isContract(_admin[i]),"not support contract address as owner");
            require(!isOwner[_admin[i]],"the address is admin already");
            isOwner[_admin[i]] = true;
        }
    }

    function deletOwners(address[] _todel) public onlyOwner {
        uint len = _todel.length;
        for(uint i= 0; i< len; i++) {
            require(isOwner[_todel[i]],"the address is not a admin");
            isOwner[_todel[i]] = false;
        }
        
    }

    function setBurnAddress(address _toBurn) public onlyOwnerable returns(bool success) {
        
        burnAddress = _toBurn;
        return true;
    }

    function burn(uint256 _amount)  public onlyOwnerable {
        require(balanceOf[burnAddress] >= _amount,"there is no enough money to burn");
        balanceOf[burnAddress] = balanceOf[burnAddress].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        emit Burn(burnAddress, _amount);
    }

    function isContract(address _addr) constant internal returns(bool) {
        require(_addr != 0x0);
        uint size;
         assembly {
            /*:= reference external variable*/
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
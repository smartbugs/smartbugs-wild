pragma solidity ^0.4.23;

contract ERC20Interface {

    uint256 public totalSupply;
    uint256 public decimals;
	
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name  
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// C1

contract OwnableContract {
 
    address ContractCreator;
		
	constructor() public { 
        ContractCreator = msg.sender;  
    }
	
	modifier onlyOwner() {
        require(msg.sender == ContractCreator);
        _;
    } 
    
    function ContractCreatorAddress() public view returns (address owner) {
        return ContractCreator;
    }
    
	function O2_ChangeOwner(address NewOwner) onlyOwner public {
        ContractCreator = NewOwner;
    }
}


// C2

contract BlockableContract is OwnableContract{
 
    bool public blockedContract;
	
	constructor() public { 
        blockedContract = false;  
    }
	
	modifier contractActive() {
        require(!blockedContract);
        _;
    } 
	
	function O3_BlockContract() onlyOwner public {
        blockedContract = true;
    }
    
    function O4_UnblockContract() onlyOwner public {
        blockedContract = false;
    }
}

// C3

contract Hodl is BlockableContract{
    
    struct Safe{
        uint256 id;
        address user;
        address tokenAddress;
        uint256 amount;
        uint256 time;
    }
    
    //dev safes variables
   
    mapping( address => uint256[]) private _member;
    mapping( uint256 => Safe) private _safes;
    uint256 private _currentIndex;
    
    mapping( address => uint256) public TotalBalances;
     
    //@dev owner variables

    uint256 public comission; //0..100
    mapping( address => uint256) private _Ethbalances;
    address[] private _listedReserves;
     
    //constructor

    constructor() public { 
        _currentIndex = 1;
        comission = 10;
    }
    
	
	
// F1 - fallback function to receive donation eth //
    function () public payable {
        require(msg.value>0);
        _Ethbalances[0x0] = add(_Ethbalances[0x0], msg.value);
    }
	

	
// F2 - how many safes has the user //
    function DepositCount(address a) public view returns (uint256 length) {
        return _member[a].length;
    }
	

	
// F3 - how many tokens are reserved for owner as comission //
    function OwnerTokenBalance(address tokenAddress) public view returns (uint256 amount){
        return _Ethbalances[tokenAddress];
    }
	

	
// F4 - returns safe's values' //
    function GetUserData(uint256 _id) public view
        returns (uint256 id, address user, address tokenAddress, uint256 amount, uint256 time)
    {
        Safe storage s = _safes[_id];
        return(s.id, s.user, s.tokenAddress, s.amount, s.time);
    }
	

	
// F5 - add new hodl safe (ETH) //
    function U1_HodlEth(uint256 time) public contractActive payable {
        require(msg.value > 0);
        require(time>now);
        
        _member[msg.sender].push(_currentIndex);
        _safes[_currentIndex] = Safe(_currentIndex, msg.sender, 0x0, msg.value, time); 
        
        TotalBalances[0x0] = add(TotalBalances[0x0], msg.value);
        
        _currentIndex++;
    }
	

	
// F6 add new hodl safe (ERC20 token) //
    
    function U2_HodlERC20(address tokenAddress, uint256 amount, uint256 time) public contractActive {
        require(tokenAddress != 0x0);
        require(amount>0);
        require(time>now);
          
        ERC20Interface token = ERC20Interface(tokenAddress);
        require( token.transferFrom(msg.sender, address(this), amount) );
        
        _member[msg.sender].push(_currentIndex);
        _safes[_currentIndex] = Safe(_currentIndex, msg.sender, tokenAddress, amount, time);
        
        TotalBalances[tokenAddress] = add(TotalBalances[tokenAddress], amount);
        
        _currentIndex++;
    }
	

	
// F7 - user, claim back a hodl safe //
    function U3_UserRetireHodl(uint256 id) public {
        Safe storage s = _safes[id];
        
        require(s.id != 0);
        require(s.user == msg.sender);
        
        RetireHodl(id);
    }
	

	
// F8 - private retire hodl safe action //
    function RetireHodl(uint256 id) private {
        Safe storage s = _safes[id]; 
        require(s.id != 0); 
        
        if(s.time < now) //hodl complete
        {
            if(s.tokenAddress == 0x0) 
                PayEth(s.user, s.amount);
            else  
                PayToken(s.user, s.tokenAddress, s.amount);
        }
        else //hodl in progress
        {
            uint256 realComission = mul(s.amount, comission) / 100;
            uint256 realAmount = sub(s.amount, realComission);
            
            if(s.tokenAddress == 0x0) 
                PayEth(s.user, realAmount);
            else  
                PayToken(s.user, s.tokenAddress, realAmount);
                
            StoreComission(s.tokenAddress, realComission);
        }
        
        DeleteSafe(s);
    }
	

		
// F9 - private pay eth to address //
    function PayEth(address user, uint256 amount) private {
        require(address(this).balance >= amount);
        user.transfer(amount);
    }
	

	
// F10 - private pay token to address //
    function PayToken(address user, address tokenAddress, uint256 amount) private{
        ERC20Interface token = ERC20Interface(tokenAddress);
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
    }
	

	
// F11 - store comission from unfinished hodl //
    function StoreComission(address tokenAddress, uint256 amount) private {
        _Ethbalances[tokenAddress] = add(_Ethbalances[tokenAddress], amount);
        
        bool isNew = true;
        for(uint256 i = 0; i < _listedReserves.length; i++) {
            if(_listedReserves[i] == tokenAddress) {
                isNew = false;
                break;
            }
        } 
        
        if(isNew) _listedReserves.push(tokenAddress); 
    }
	

		
// F12 - delete safe values in storage //
    function DeleteSafe(Safe s) private  {
        TotalBalances[s.tokenAddress] = sub(TotalBalances[s.tokenAddress], s.amount);
        delete _safes[s.id];
        
        uint256[] storage vector = _member[msg.sender];
        uint256 size = vector.length; 
        for(uint256 i = 0; i < size; i++) {
            if(vector[i] == s.id) {
                vector[i] = vector[size-1];
                vector.length--;
                break;
            }
        } 
    }
	

	
// F13 // OWNER - owner retire hodl safe //
    function O5_OwnerRetireHodl(uint256 id) public onlyOwner {
        Safe storage s = _safes[id]; 
        require(s.id != 0); 
        RetireHodl(id);
    }
	

	
// F14 - owner, change comission value //
    function O1_ChangeComission(uint256 newComission) onlyOwner public {
        comission = newComission;
    }
	

	
// F15 - owner withdraw eth reserved from comissions //
    function O6_WithdrawReserve(address tokenAddress) onlyOwner public
    {
        require(_Ethbalances[tokenAddress] > 0);
        
        uint256 amount = _Ethbalances[tokenAddress];
        _Ethbalances[tokenAddress] = 0;
        
        ERC20Interface token = ERC20Interface(tokenAddress);
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(msg.sender, amount);
    }
	

	 
// F16 - owner withdraw token reserved from comission //
    function O7_WithdrawAllReserves() onlyOwner public {
        //eth
        uint256 x = _Ethbalances[0x0];
        if(x > 0 && x <= address(this).balance) {
            _Ethbalances[0x0] = 0;
            msg.sender.transfer( _Ethbalances[0x0] );
        }
         
    //tokens
        address ta;
        ERC20Interface token;
        for(uint256 i = 0; i < _listedReserves.length; i++) {
            ta = _listedReserves[i];
            if(_Ethbalances[ta] > 0)
            { 
                x = _Ethbalances[ta];
                _Ethbalances[ta] = 0;
                
                token = ERC20Interface(ta);
                token.transfer(msg.sender, x);
            }
        } 
        
        _listedReserves.length = 0; 
    }
	

	
// F17 - owner remove free eth //
    function O8_WithdrawSpecialEth(uint256 amount) onlyOwner public
    {
        require(amount > 0); 
        uint256 freeBalance = address(this).balance - TotalBalances[0x0];
        require(freeBalance >= amount); 
        msg.sender.transfer(amount);
    }
	

	
// F18 - owner remove free token //
    function O9_WithdrawSpecialToken(address tokenAddress, uint256 amount) onlyOwner public
    {
        ERC20Interface token = ERC20Interface(tokenAddress);
        uint256 freeBalance = token.balanceOf(address(this)) - TotalBalances[tokenAddress];
        require(freeBalance >= amount);
        token.transfer(msg.sender, amount);
    } 
	

	  
    //AUX - @dev Multiplies two numbers, throws on overflow. //
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    //dev Integer division of two numbers, truncating the quotient. //
   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    
    // dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend). //
  
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    // @dev Adds two numbers, throws on overflow. //
  
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
    
    
}
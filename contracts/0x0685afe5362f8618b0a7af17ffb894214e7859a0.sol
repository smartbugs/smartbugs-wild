pragma solidity ^0.4.25;


contract ArceonMoneyNetwork {
    using SafeMath for uint256;
    address public owner;
    address parentUser;
    address[] users;
   
    mapping(address => bool) usersExist;
    mapping(address => address) users2users;
    mapping(address => uint256) balances;
    mapping(address => uint256) balancesTotal;
    
    uint256 nextUserId = 0;
    uint256 cyles = 5;
    
  constructor() public {owner = msg.sender; }
  
   modifier onlyOwner {if (msg.sender == owner) _;}
    
    
    
    
    event Register(address indexed user, address indexed parentUser);
    event BalanceUp(address indexed user, uint256 amount);
    event ReferalBonus(address indexed user, uint256 amount);
    event TransferMyMoney(address user, uint256 amount);
    
    
    
    function bytesToAddress(bytes bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
    
    
    function () payable public{
	    parentUser = bytesToAddress(msg.data);
	    if (msg.value==0){ transferMyMoney(); return;}
        require(msg.value == 50 finney);
        require(msg.sender != address(0));
        require(parentUser != address(0));
        require(!usersExist[msg.sender]);
        _register(msg.sender, msg.value);
    }
    
    
    function _register(address user, uint256 amount) internal {
        
        
         
        if (users.length > 0) {
            require(parentUser!=user);
            require(usersExist[parentUser]); 
        }
        
       if (users.length ==0) {users2users[parentUser]=parentUser;} 
       
       
        users.push(user);
        usersExist[user]=true;
        users2users[user]=parentUser;
        
        
        emit Register(user, parentUser);
        
        uint256 referalBonus = amount.div(2);
        
        if (cyles==0) {referalBonus = amount;} //we exclude a money wave
        
        balances[parentUser] = balances[parentUser].add(referalBonus.div(2));
        balancesTotal[parentUser] = balancesTotal[parentUser].add(referalBonus.div(2));
        
        emit ReferalBonus(parentUser, referalBonus.div(2));
        
        balances[users2users[parentUser]] = balances[users2users[parentUser]].add(referalBonus.div(2));
        balancesTotal[users2users[parentUser]] = balancesTotal[users2users[parentUser]].add(referalBonus.div(2));
        
        emit ReferalBonus(users2users[parentUser], referalBonus.div(2));
        
        uint256 length = users.length;
        uint256 existLastIndex = length.sub(1);
        
        //we exclude a money wave
        if (cyles!=0){ 
            
        for (uint i = 1; i <= cyles; i++) {
            nextUserId = nextUserId.add(1);
			
            if(nextUserId > existLastIndex){ nextUserId = 0;}
            
            balances[users[nextUserId]] = balances[users[nextUserId]].add(referalBonus.div(cyles));
            balancesTotal[users[nextUserId]] = balancesTotal[users[nextUserId]].add(referalBonus.div(cyles));
            
            emit BalanceUp(users[nextUserId], referalBonus.div(cyles));
        }
      
        }  //we exclude a money wave
    
    }
    
    function transferMyMoney() public {
        require(balances[msg.sender]>0);
        msg.sender.transfer(balances[msg.sender]);
        emit TransferMyMoney(msg.sender, balances[msg.sender]);
		balances[msg.sender]=0;
    }
    
    
    
    
      function ViewRealBalance(address input) public view returns (uint256 balanceReal) {  
       balanceReal= balances[input];
       balanceReal=balanceReal.div(1000000000000);
          return balanceReal;
    }
    
   
    function ViewTotalBalance(address input)   public view returns (uint256 balanceTotal) {
      balanceTotal=balancesTotal [input];
      balanceTotal=balanceTotal.div(1000000000000);
          return balanceTotal;
   }
   
    
   function viewBlockchainArceonMoneyNetwork(uint256 id) public view  returns (address userAddress) {
        return users[id];
    } 
    
    
    function  CirclePoints() public view returns (uint256 CirclePoint) {
        CirclePoint = nextUserId;
        
        return  CirclePoint;
    }
    
    function  NumberUser() public view returns (uint256 numberOfUser) {
        
        numberOfUser = users.length;
        
        return numberOfUser;
    } 
    
    function  LenCyless() public view returns (uint256 LenCyles) {
        
        LenCyles = cyles;
        
        return LenCyles;
    } 
    
    
    
    function newCyles(uint256 _newCyles) external onlyOwner {
      
       cyles = _newCyles;
    }
    
}    
    
   library SafeMath {
       
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
    
}
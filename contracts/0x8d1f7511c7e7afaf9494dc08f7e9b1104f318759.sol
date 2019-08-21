pragma solidity ^0.4.25;


// library for basic math operation + - * / to prevent and protect overflow error 
// (Overflow and Underflow) which can be occurred from unit256 (Unsigned int 256)
 library SafeMath256 {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if(a==0 || b==0)
        return 0;  
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b>0);
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
   require( b<= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }
  
}


// Mandatory basic functions according to ERC20 standard
contract ERC20 {
	   event Transfer(address indexed from, address indexed to, uint256 tokens);
       event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

   	   function totalSupply() public view returns (uint256);
       function balanceOf(address tokenOwner) public view returns (uint256 balance);
       function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

       function transfer(address to, uint256 tokens) public returns (bool success);
       
       function approve(address spender, uint256 tokens) public returns (bool success);
       function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
  

}


// Contract Ownable is used to specified which person has right/permission to execute/invoke the specific function.
// Different from OnlyOwner which is the only owner of the smart contract who has right/permission to call
// the specific function. Aside from OnlyOwner, 
// OnlyOwners can also be used which any of Owners can call the particular function.

contract Ownable {


// A list of owners which will be saved as a list here, 
// and the values are the owner’s names. 
// This to allow investors / NATEE Token buyers to trace/monitor 
// who executes which functions written in this NATEE smart contract  string [] ownerName;

  string [] ownerName;  
  mapping (address=>bool) owners;
  mapping (address=>uint256) ownerToProfile;
  address owner;

// all events will be saved as log files
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event AddOwner(address newOwner,string name);
  event RemoveOwner(address owner);
  /**
   * @dev Ownable constructor , initializes sender’s account and 
   * set as owner according to default value according to contract
   *
   */

   // this function will be executed during initial load and will keep the smart contract creator (msg.sender) as Owner
   // and also saved in Owners. This smart contract creator/owner is 
   // Mr. Samret Wajanasathian CTO of Seitee Pte Ltd (https://seitee.com.sg , https://natee.io)

   constructor() public {
    owner = msg.sender;
    owners[msg.sender] = true;
    uint256 idx = ownerName.push("SAMRET WAJANASATHIAN");
    ownerToProfile[msg.sender] = idx;

  }

// function to check whether the given address is either Wallet address or Contract Address

  function isContract(address _addr) internal view returns(bool){
     uint256 length;
     assembly{
      length := extcodesize(_addr)
     }
     if(length > 0){
       return true;
    }
    else {
      return false;
    }

  }

// function to check if the executor is the owner? This to ensure that only the person 
// who has right to execute/call the function has the permission to do so.
  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }

// This function has only one Owner. The ownership can be transferrable and only
//  the current Owner will only be  able to execute this function.
  
  function transferOwnership(address newOwner,string newOwnerName) public onlyOwner{
    require(isContract(newOwner) == false);
    uint256 idx;
    if(ownerToProfile[newOwner] == 0)
    {
    	idx = ownerName.push(newOwnerName);
    	ownerToProfile[newOwner] = idx;
    }


    emit OwnershipTransferred(owner,newOwner);
    owner = newOwner;

  }

// Function to check if the person is listed in a group of Owners and determine
// if the person has the any permissions in this smart contract such as Exec permission.
  
  modifier onlyOwners(){
    require(owners[msg.sender] == true);
    _;
  }

// Function to add Owner into a list. The person who wanted to add a new owner into this list but be an existing
// member of the Owners list. The log will be saved and can be traced / monitor who’s called this function.
  
  function addOwner(address newOwner,string newOwnerName) public onlyOwners{
    require(owners[newOwner] == false);
    require(newOwner != msg.sender);
    if(ownerToProfile[newOwner] == 0)
    {
    	uint256 idx = ownerName.push(newOwnerName);
    	ownerToProfile[newOwner] = idx;
    }
    owners[newOwner] = true;
    emit AddOwner(newOwner,newOwnerName);
  }

// Function to remove the Owner from the Owners list. The person who wanted to remove any owner from Owners
// List must be an existing member of the Owners List. The owner cannot evict himself from the Owners
// List by his own, this is to ensure that there is at least one Owner of this NATEE Smart Contract.
// This NATEE Smart Contract will become useless if there is no owner at all.

  function removeOwner(address _owner) public onlyOwners{
    require(_owner != msg.sender);  // can't remove your self
    owners[_owner] = false;
    emit RemoveOwner(_owner);
  }
// this function is to check of the given address is allowed to call/execute the particular function
// return true if the given address has right to execute the function.
// for transparency purpose, anyone can use this to trace/monitor the behaviors of this NATEE smart contract.

  function isOwner(address _owner) public view returns(bool){
    return owners[_owner];
  }

// Function to check who’s executed the functions of smart contract. This returns the name of 
// Owner and this give transparency of whose actions on this NATEE Smart Contract. 

  function getOwnerName(address ownerAddr) public view returns(string){
  	require(ownerToProfile[ownerAddr] > 0);

  	return ownerName[ownerToProfile[ownerAddr] - 1];
  }
}

// ContractToken is for managing transactions of wallet address or contract address with its own 
// criterias and conditions such as settlement.

contract ControlToken is Ownable{
	
	mapping (address => bool) lockAddr;
	address[] lockAddrList;
	uint32  unlockDate;

     bool disableBlock;
     bool call2YLock;

	mapping(address => bool) allowControl;
	address[] exchangeAddress;
	uint32    exchangeTimeOut;

	event Call2YLock(address caller);

// Initially the lockin period is set for 100 years starting from the date of Smart Contract Deployment.
// The company will have to adjust it to 2 years for lockin period starting from the first day that 
// NATEE token listed in exchange (in any exchange).

	constructor() public{
		unlockDate = uint32(now) + 36500 days;  // Start Lock 100 Year first
		
	}

// function to set Wallet Address that belong to Exclusive Exchange. 
// The lockin period for this setting has its minimum of 6 months.

	function setExchangeAddr(address _addr) onlyOwners public{
		uint256 numEx = exchangeAddress.push(_addr);
		if(numEx == 1){
			exchangeTimeOut = uint32(now + 180 days);
		}
	}

// Function to adjust lockin period of Exclusive Exchange,
// this could unlock the lockin period and allow freedom trade.

	function setExchangeTimeOut(uint32 timStemp) onlyOwners public{
		exchangeTimeOut = timStemp;
	}

// This function is used to set duration from 100 years to 2 years, start counting from the date that execute this function.
// To prevent early execution and to ensure that only the legitimate Owner can execute this function, 
// Seitee Pte Ltd has logged all activities from this function which open for public for transparency.
// The generated log will be publicly published on ERC20 network, anyone can check/trace from the log
// that this function will never been called if there no confirmed Exchange that accepts NATEE Token.
// Any NATEE token holders who still serving lockin period, can ensure that there will be no repeatedly 
// execution for this function (the repeatedly execution could lead to lockin period extension to more than 2 years). 
// The constraint “call2YLock” is initialized as boolean “False” when the NATEE Smart Contract is created and will only 
// be set to “true” when this function is executed. One the value changed from false > true, it will preserve the value forever.

	function start2YearLock() onlyOwners public{
		if(call2YLock == false){
			unlockDate = uint32(now) + 730 days;
			call2YLock = true;

			emit Call2YLock(msg.sender);
		}
	
	}

	function lockAddress(address _addr) internal{
		if(lockAddr[_addr] == false)
		{
			lockAddr[_addr] = true;
			lockAddrList.push(_addr);
		}
	}

	function isLockAddr(address _addr) public view returns(bool){
		return lockAddr[_addr];
	}

// this internal function is used to add address into the locked address list. 
	
	function addLockAddress(address _addr) onlyOwners public{
		if(lockAddr[_addr] == false)
		{
			lockAddr[_addr] = true;
			lockAddrList.push(_addr);		
		}
	}

// Function to unlock the token for all addresses. This function is open as public modifier
// stated to allow anyone to execute it. This to prevent the doubtful of delay of unlocking
// or any circumstances that prolong the unlocking. This just simply means, anyone can unlock 
// the address for anyone in this Smart Contract.

	function unlockAllAddress() public{
		if(uint32(now) >= unlockDate)
		{
			for(uint256 i=0;i<lockAddrList.length;i++)
			{
				lockAddr[lockAddrList[i]] = false;
			}
		}
	}

// The followings are the controls for Token Transfer, the Controls are managed by Seitee Pte Ltd
//========================= ADDRESS CONTROL =======================
//  This internal function is to indicate that the Wallet Address has been allowed and let Seitee Pte Ltd
//  to do transactions. The initial value is closed which means, Seitee Pte Lte cannot do any transactions.

	function setAllowControl(address _addr) internal{
		if(allowControl[_addr] == false)
			allowControl[_addr] = true;
	}

// this function is to check whether the given Wallet Address can be managed/controlled by Seitee Pte Ltd.
// If return “true” means, Seitee Pte Ltd take controls of this Wallet Address.

	function checkAllowControl(address _addr) public view returns(bool){
		return allowControl[_addr];
	}

// NATEE Token system prevents the transfer of token to non-verified Wallet Address
// (the Wallet Address that hasn’t been verified thru KYC). This can also means that 
// Token wont be transferable to other Wallet Address that not saved in this Smart Contract. 
// This function is created for everyone to unlock the Wallet Address, once the Wallet Address is unlocked,
// the Wallet Address can’t be set to lock again. Our Smart Contract doesn’t have any line that 
// contains “disableBlock = false”. The condition is when there is a new exchange in the system and 
// fulfill the 6 months lockin period or less (depends on the value set).
   
    function setDisableLock() public{
    	if(uint256(now) >= exchangeTimeOut && exchangeAddress.length > 0)
    	{
      	if(disableBlock == false)
      		disableBlock = true;
      	}
    }

}

// NATEE token smart contract stored KYC Data on Blockchain for transparency. 
// Only Seitee Pte Ltd has the access to this KYC data. The authorities/Government 
// Agencies can be given the access to view this KYC data, too (subject to approval).
// Please note, this is not open publicly.

contract KYC is ControlToken{


	struct KYCData{
		bytes8    birthday; // yymmdd  
		bytes16   phoneNumber; 

		uint16    documentType; // 2 byte;
		uint32    createTime; // 4 byte;
		// --- 32 byte
		bytes32   peronalID;  // Passport หรือ idcard
		// --- 32 byte 
		bytes32    name;
		bytes32    surName;
		bytes32    email;
		bytes8	  password;
	}

	KYCData[] internal kycDatas;

	mapping (uint256=>address) kycDataForOwners;
	mapping (address=>uint256) OwnerToKycData;

	mapping (uint256=>address) internal kycSOSToOwner; //keccak256 for SOS function 


	event ChangePassword(address indexed owner_,uint256 kycIdx_);
	event CreateKYCData(address indexed owner_, uint256 kycIdx_);

	// Individual KYC data the parameter is index of the KYC data. Only Seitee Pte Ltd can view this data.

	function getKYCData(uint256 _idx) onlyOwners view public returns(bytes16 phoneNumber_,
										 							  bytes8  birthday_,
										 							  uint16 documentType_,
										 							  bytes32 peronalID_,
										 							  bytes32 name_,
										 							  bytes32 surname_,
										 							  bytes32 email_){
		require(_idx <= kycDatas.length && _idx > 0,"ERROR GetKYCData 01");
		KYCData memory _kyc;
		uint256  kycKey = _idx - 1; 
		_kyc = kycDatas[kycKey];

		phoneNumber_ = _kyc.phoneNumber;
		birthday_ = _kyc.birthday;
		documentType_ = _kyc.documentType;
		peronalID_ = _kyc.peronalID;
		name_ = _kyc.name;
		surname_ = _kyc.surName;
		email_ = _kyc.email;

		} 

	// function to view KYC data from registered Wallet Address. Only Seitee Pte Ltd has right to view this data.
	function getKYCDataByAddr(address _addr) onlyOwners view public returns(bytes16 phoneNumber_,
										 							  bytes8  birthday_,
										 							  uint16 documentType_,
										 							  bytes32 peronalID_,
										 							  bytes32 name_,
										 							  bytes32 surname_,
										 							  bytes32 email_){
		require(OwnerToKycData[_addr] > 0,"ERROR GetKYCData 02");
		KYCData memory _kyc;
		uint256  kycKey = OwnerToKycData[_addr] - 1; 
		_kyc = kycDatas[kycKey];

		phoneNumber_ = _kyc.phoneNumber;
		birthday_ = _kyc.birthday;
		documentType_ = _kyc.documentType;
		peronalID_ = _kyc.peronalID;
		name_ = _kyc.name;
		surname_ = _kyc.surName;
		email_ = _kyc.email;

		} 

	// The Owner can view the history records from KYC processes.
	function getKYCData() view public returns(bytes16 phoneNumber_,
										 					 bytes8  birthday_,
										 					 uint16 documentType_,
										 					 bytes32 peronalID_,
										 					 bytes32 name_,
										 					 bytes32 surname_,
										 					 bytes32 email_){
		require(OwnerToKycData[msg.sender] > 0,"ERROR GetKYCData 03"); // if == 0 not have data;
		uint256 id = OwnerToKycData[msg.sender] - 1;

		KYCData memory _kyc;
		_kyc = kycDatas[id];

		phoneNumber_ = _kyc.phoneNumber;
		birthday_ = _kyc.birthday;
		documentType_ = _kyc.documentType;
		peronalID_ = _kyc.peronalID;
		name_ = _kyc.name;
		surname_ = _kyc.surName;
		email_ = _kyc.email;
	}

// 6 chars password which the Owner can update the password by himself/herself. Only the Owner can execute this function.
	function changePassword(bytes8 oldPass_, bytes8 newPass_) public returns(bool){
		require(OwnerToKycData[msg.sender] > 0,"ERROR changePassword"); 
		uint256 id = OwnerToKycData[msg.sender] - 1;
		if(kycDatas[id].password == oldPass_)
		{
			kycDatas[id].password = newPass_;
			emit ChangePassword(msg.sender, id);
		}
		else
		{
			assert(kycDatas[id].password == oldPass_);
		}

		return true;


	}

	// function to create record of KYC data
	function createKYCData(bytes32 _name, bytes32 _surname, bytes32 _email,bytes8 _password, bytes8 _birthday,bytes16 _phone,uint16 _docType,bytes32 _peronalID,address  _wallet) onlyOwners public returns(uint256){
		uint256 id = kycDatas.push(KYCData(_birthday, _phone, _docType, uint32(now) ,_peronalID, _name, _surname, _email, _password));
		uint256 sosHash = uint256(keccak256(abi.encodePacked(_name, _surname , _email, _password)));

		OwnerToKycData[_wallet] = id;
		kycDataForOwners[id] = _wallet; 
		kycSOSToOwner[sosHash] = _wallet; 
		emit CreateKYCData(_wallet,id);

		return id;
	}

	function maxKYCData() public view returns(uint256){
		return kycDatas.length;
	}

	function haveKYCData(address _addr) public view returns(bool){
		if(OwnerToKycData[_addr] > 0) return true;
		else return false;
	}

}

// Standard ERC20 function, no overriding at the moment.

contract StandarERC20 is ERC20{
	using SafeMath256 for uint256;  
     
     mapping (address => uint256) balance;
     mapping (address => mapping (address=>uint256)) allowed;


     uint256 public totalSupply_;  
     

     address[] public  holders;
     mapping (address => uint256) holderToId;


     event Transfer(address indexed from,address indexed to,uint256 value);
     event Approval(address indexed owner,address indexed spender,uint256 value);


// Total number of Tokens 
    function totalSupply() public view returns (uint256){
     	return totalSupply_;
    }

     function balanceOf(address _walletAddress) public view returns (uint256){
        return balance[_walletAddress]; 
     }

// function to check on how many tokens set to be transfer between _owner and _spender. This is to check prior to confirm the transaction. 
     function allowance(address _owner, address _spender) public view returns (uint256){
          return allowed[_owner][_spender];
        }

// Standard function used to transfer the token according to ERC20 standard
     function transfer(address _to, uint256 _value) public returns (bool){
        require(_value <= balance[msg.sender]);
        require(_to != address(0));
        
        balance[msg.sender] = balance[msg.sender].sub(_value);
        balance[_to] = balance[_to].add(_value);

        emit Transfer(msg.sender,_to,_value); 
        return true;

     }
// standard function to approve transfer of token
     function approve(address _spender, uint256 _value)
            public returns (bool){
            allowed[msg.sender][_spender] = _value;

            emit Approval(msg.sender, _spender, _value);
            return true;
            }


// standard function to request the money used after the sender has initialize the 
// transition of money transfer. Only the beneficiary able to execute this function 
// and the amount of money has been set as transferable by the sender.  
      function transferFrom(address _from, address _to, uint256 _value)
            public returns (bool){
               require(_value <= balance[_from]);
               require(_value <= allowed[_from][msg.sender]); 
               require(_to != address(0));

              balance[_from] = balance[_from].sub(_value);
              balance[_to] = balance[_to].add(_value);
              allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

              emit Transfer(_from, _to, _value);
              return true;
      }

// additional function to store all NATEE Token holders as a list in blockchain.
// This could be use for bounty program in the future.
     function addHolder(address _addr) internal{
     	if(holderToId[_addr] == 0)
     	{
     		uint256 idx = holders.push(_addr);
     		holderToId[_addr] = idx;
     	}
     }

// function to request the top NATEE Token holders.
     function getMaxHolders() external view returns(uint256){
     	return holders.length;
     }

// function to read all indexes of NATEE Token holders. 
     function getHolder(uint256 idx) external view returns(address){
     	return holders[idx];
     }
     
}


// Contract for co-founders and advisors which is total of 5,000,000 Tokens for co-founders
// and 4,000,000 tokens for advisors. Maximum NATEE token for advisor is 200,000 Tokens and 
// the deficit from 4,000,000 tokens allocated to advisors, will be transferred to co-founders.

contract FounderAdvisor is StandarERC20,Ownable,KYC {

	uint256 FOUNDER_SUPPLY = 5000000 ether;
	uint256 ADVISOR_SUPPLY = 4000000 ether;

	address[] advisors;
	address[] founders;

	mapping (address => uint256) advisorToID;
	mapping (address => uint256) founderToID;
	// will have true if already redeem.
	// Advisor and founder can't be same people

	bool  public closeICO;

	// Will have this value after close ICO

	uint256 public TOKEN_PER_FOUNDER = 0 ether; 
	uint256 public TOKEN_PER_ADVISOR = 0 ether;

	event AddFounder(address indexed newFounder,string nane,uint256  curFoounder);
	event AddAdvisor(address indexed newAdvisor,string name,uint256  curAdvisor);
	event CloseICO();

	event RedeemAdvisor(address indexed addr_, uint256 value);
	event RedeemFounder(address indexed addr_, uint256 value);

	event ChangeAdvisorAddr(address indexed oldAddr_, address indexed newAddr_);
	event ChangeFounderAddr(address indexed oldAddr_, address indexed newAddr_);


// function to add founders, name and surname will be logged. This 
// function will be disabled after ICO closed.
	function addFounder(address newAddr, string _name) onlyOwners external returns (bool){
		require(closeICO == false);
		require(founderToID[newAddr] == 0);

		uint256 idx = founders.push(newAddr);
		founderToID[newAddr] = idx;
		emit AddFounder(newAddr, _name, idx);
		return true;
	}

// function to add advisors. This function will be disabled after ICO closed.

	function addAdvisor(address newAdvis, string _name) onlyOwners external returns (bool){
		require(closeICO == false);
		require(advisorToID[newAdvis] == 0);

		uint256 idx = advisors.push(newAdvis);
		advisorToID[newAdvis] = idx;
		emit AddAdvisor(newAdvis, _name, idx);
		return true;
	}

// function to update Advisor’s Wallet Address. If there is a need to remove the advisor,
// just input address = 0. This function will be disabled after ICO closed.

	function changeAdvisorAddr(address oldAddr, address newAddr) onlyOwners external returns(bool){
		require(closeICO == false);
		require(advisorToID[oldAddr] > 0); // it should be true if already have advisor

		uint256 idx = advisorToID[oldAddr];

		advisorToID[newAddr] = idx;
		advisorToID[oldAddr] = 0;

		advisors[idx - 1] = newAddr;

		emit ChangeAdvisorAddr(oldAddr,newAddr);
		return true;
	}

// function to update founder’s Wallet Address. To remove the founder, 
// pass the value of address = 0. This function will be disabled after ICO closed.
	function changeFounderAddr(address oldAddr, address newAddr) onlyOwners external returns(bool){
		require(closeICO == false);
		require(founderToID[oldAddr] > 0);

		uint256 idx = founderToID[oldAddr];

		founderToID[newAddr] = idx;
		founderToID[oldAddr] = 0;
		founders[idx - 1] = newAddr;

		emit ChangeFounderAddr(oldAddr, newAddr);
		return true;
	}

	function isAdvisor(address addr) public view returns(bool){
		if(advisorToID[addr] > 0) return true;
		else return false;
	}

	function isFounder(address addr) public view returns(bool){
		if(founderToID[addr] > 0) return true;
		else return false;
	}
}

// Contract MyToken is created for extra permission to make a transfer of token. Typically,
// NATEE Token will be held and will only be able to transferred to those who has successfully 
// done the KYC. For those who holds NATEE PRIVATE TOKEN at least 8,000,000 tokens is able to 
// transfer the token to anyone with no limit.

contract MyToken is FounderAdvisor {
	 using SafeMath256 for uint256;  
     mapping(address => uint256) privateBalance;


     event SOSTranfer(address indexed oldAddr_, address indexed newAddr_);

// standard function according to ERC20, modified by adding the condition of lockin period (2 years)
// for founders and advisors. Including the check whether the address has been KYC verified and is 
// NATEE PRIVATE TOKEN holder will be able to freedomly trade the token.

     function transfer(address _to, uint256 _value) public returns (bool){
     	if(lockAddr[msg.sender] == true) // 2 Year lock can Transfer only Lock Address
     	{
     		require(lockAddr[_to] == true);
     	}

     	// if total number of NATEE PRIVATE TOKEN is less than amount that wish to transfer
     	if(privateBalance[msg.sender] < _value){
     		if(disableBlock == false)
     		{
        		require(OwnerToKycData[msg.sender] > 0,"You Not have permission to Send");
        		require(OwnerToKycData[_to] > 0,"You not have permission to Recieve");
        	}
   		 }
        
         addHolder(_to);

        if(super.transfer(_to, _value) == true)
        {
        	// check if the total balance of token is less than transferred amount
        	if(privateBalance[msg.sender] <= _value)
        	{
        		privateBalance[_to] += privateBalance[msg.sender];
        		privateBalance[msg.sender] = 0;
        	}
        	else
        	{
        		privateBalance[msg.sender] = privateBalance[msg.sender].sub(_value);
        		privateBalance[_to] = privateBalance[_to].add(_value);
        	}

        	return true;
        }


        return false;

     }

// standard function ERC20, with additional criteria for 2 years lockin period for Founders and Advisors.
// Check if the owner of that Address has done the KYC successfully, if yes and having NATEE Private Token
// then, will be allowed to make the transfer.

      function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
            require(lockAddr[_from] == false); //2 Year Lock Can't Transfer

            if(privateBalance[_from] < _value)
            {
            	if(disableBlock == false)
            	{	
         	    	require(OwnerToKycData[msg.sender] > 0, "You Not Have permission to Send");
            		require(OwnerToKycData[_to] > 0,"You not have permission to recieve");
        		}
        	}
           
            addHolder(_to);

            if(super.transferFrom(_from, _to, _value) == true)
            {
            	 if(privateBalance[msg.sender] <= _value)
        		{
        			privateBalance[_to] += privateBalance[msg.sender];
        			privateBalance[msg.sender] = 0;
        		}
        		else
        		{
        			privateBalance[msg.sender] = privateBalance[msg.sender].sub(_value);
        			privateBalance[_to] = privateBalance[_to].add(_value);
        		}

        		return true;
            }
            return false;

      }

      // function to transfer all asset from the old wallet to new wallet. This is used, just in case, the owner forget the private key.
      // The owner who which to update the wallet by calling this function must have successfully done KYC and the 6 alpha numeric password
      // must be used and submit to Seitee Pte Ltd. The company will recover the old wallet address and transfer the assets to the new wallet
      // address on behave of the owner of the wallet address.  
      function sosTransfer(bytes32 _name, bytes32 _surname, bytes32 _email,bytes8 _password,address _newAddr) onlyOwners public returns(bool){

      	uint256 sosHash = uint256(keccak256(abi.encodePacked(_name, _surname , _email, _password)));
      	address oldAddr = kycSOSToOwner[sosHash];
      	uint256 idx = OwnerToKycData[oldAddr];

      	require(allowControl[oldAddr] == false);
      	if(idx > 0)
      	{
      		idx = idx - 1;
      		if(kycDatas[idx].name == _name &&
      		   kycDatas[idx].surName == _surname &&
      		   kycDatas[idx].email == _email &&
      		   kycDatas[idx].password == _password)
      		{

      			kycSOSToOwner[sosHash] = _newAddr;
      			OwnerToKycData[oldAddr] = 0; // reset it
      			OwnerToKycData[_newAddr] = idx;
      			kycDataForOwners[idx] = _newAddr;

      			emit SOSTranfer(oldAddr, _newAddr);

      			lockAddr[_newAddr] = lockAddr[oldAddr];

      			//Transfer All Token to new address
      			balance[_newAddr] = balance[oldAddr];
      			balance[oldAddr] = 0;

      			privateBalance[_newAddr] = privateBalance[oldAddr];
      			privateBalance[oldAddr] = 0;

      			emit Transfer(oldAddr, _newAddr, balance[_newAddr]);
      		}
      	}


      	return true;
      }
     
// function for internal transfer between wallets that the controls have been given to
// the company (The owner can revoke these controls after ICO closed). Only the founders
// of Seitee Pte Ltd can execute this function. All activities will be publicly logged. 
// The user can trace/view the log to check transparency if any founders of the company 
// make the transfer of assets from your wallets. Again, Transparency is the key here.

      function inTransfer(address _from, address _to,uint256 value) onlyOwners public{
      	require(allowControl[_from] == true); //default = false
      	require(balance[_from] >= value);

      	balance[_from] -= value;
        balance[_to] = balance[_to].add(value);

        if(privateBalance[_from] <= value)
        {
        	privateBalance[_to] += privateBalance[_from];
        	privateBalance[_from] = 0;
        }
        else
        {
        	privateBalance[_from] = privateBalance[_from].sub(value);
        	privateBalance[_to] = privateBalance[_to].add(value);
        }

        emit Transfer(_from,_to,value); 
      }


     function balanceOfPrivate(address _walletAddress) public view returns (uint256){
        return privateBalance[_walletAddress]; 
     }

}





// Contract for NATEE PRIVATE TOKEN (1 NATEE PRIVATE TOKEN equivalent to 8 NATEE TOKEN)
contract NateePrivate {
	
    function redeemToken(address _redeem, uint256 _value) external;
	function getMaxHolder() view external returns(uint256);
	function getAddressByID(uint256 _id) view external returns(address);
	function balancePrivate(address _walletAddress)  public view returns (uint256);
	
}

// The interface of SGDS (Singapore Dollar Stable)
contract SGDSInterface{
  function balanceOf(address tokenOwner) public view returns (uint256 balance);
  function intTransfer(address _from, address _to, uint256 _value) external;
  function transferWallet(address _from,address _to) external;
  function getUserControl(address _addr) external view returns(bool); // if true mean user can control by him. false mean Company can control
  function useSGDS(address useAddr,uint256 value) external returns(bool);
  function transfer(address _to, uint256 _value) public returns (bool);

}

// Interface of NATEE Warrant
contract NateeWarrantInterface {

	function balanceOf(address tokenOwner) public view returns (uint256 balance);
	function redeemWarrant(address _from, uint256 _value) external;
	function getWarrantInfo() external view returns(string name_,string symbol_,uint256 supply_ );
	function getUserControl(address _addr) external view returns(bool);
	function sendWarrant(address _to,uint256 _value) external;
	function expireDate() public pure returns (uint32);
}



// HAVE 5 Type of REFERRAL
// 1 Buy 8,000 NATEE Then can get referral code REDEEM AFTER REACH SOFTCAP
// 2 FIX RATE REDEEM AFTER REARCH SOFTCAP NO Buy
// 3 adjust RATE REDEEM AFTER REARCH SOFTCAP NO Buy
// 4 adjust RATE REDEEM IMMEDIATLY NO Buy
// 5 FIX RATE REDEEM IMMEDIATLY NO Buy

// Contract for marketing by using referral code from above 5 scenarios.
contract Marketing is MyToken{
	struct REFERAL{
		uint8   refType;
		uint8   fixRate; // user for type 2 and 5
		uint256 redeemCom; // summary commision that redeem
		uint256 allCommission;
		uint256 summaryInvest;
	}

	REFERAL[] referals;
	mapping (address => uint256) referToID;

// Add address for referrer
	function addReferal(address _address,uint8 referType,uint8 rate) onlyOwners public{
		require(referToID[_address] == 0);
		uint256 idx = referals.push(REFERAL(referType,rate,0,0,0));
		referToID[_address] = idx;
	}


// increase bounty/commission rate for those who has successfully registered the address with this smart contract
	function addCommission(address _address,uint256 buyToken) internal{
		uint256 idx;
		if(referToID[_address] > 0)
		{
			idx = referToID[_address] - 1;
			uint256 refType = uint256(referals[idx].refType);
			uint256 fixRate = uint256(referals[idx].fixRate);

			if(refType == 1 || refType == 3 || refType == 4){
				referals[idx].summaryInvest += buyToken;
				if(referals[idx].summaryInvest <= 80000){
					referals[idx].allCommission =  referals[idx].summaryInvest / 20 / 2; // 5%
				}else if(referals[idx].summaryInvest >80000 && referals[idx].summaryInvest <=320000){
					referals[idx].allCommission = 2000 + (referals[idx].summaryInvest / 10 / 2); // 10%
				}else if(referals[idx].summaryInvest > 320000){
					referals[idx].allCommission = 2000 + 12000 + (referals[idx].summaryInvest * 15 / 100 / 2); // 10%					
				}
			}
			else if(refType == 2 || refType == 5){
				referals[idx].summaryInvest += buyToken;
				referals[idx].allCommission = (referals[idx].summaryInvest * 100) * fixRate / 100 / 2;
			}
		}
	}

	function getReferByAddr(address _address) onlyOwners view public returns(uint8 refType,
																			 uint8 fixRate,
																			 uint256 commision,
																			 uint256 allCommission,
																			 uint256 summaryInvest){
		REFERAL memory refer = referals[referToID[_address]-1];

		refType = refer.refType;
		fixRate = refer.fixRate;
		commision = refer.redeemCom;
		allCommission = refer.allCommission;
		summaryInvest = refer.summaryInvest;

	}
// check if the given address is listed in referral list
	function checkHaveRefer(address _address) public view returns(bool){
		return (referToID[_address] > 0);
	}

// check the total commission on what you have earned so far, the unit is SGDS (Singapore Dollar Stable)
	function getCommission(address addr) public view returns(uint256){
		require(referToID[addr] > 0);

		return referals[referToID[addr] - 1].allCommission;
	}
}

// ICO Contract
//	1. Set allocated tokens for sales during pre-sales, prices the duration for pre-sales is 270 days
//	2. Set allocated tokens for sales during public-sales, prices and the duration for public-sales is 90 days.
//	3. The entire duration pre-sales / public sales is no more than 270 days (9 months).
//	4. If the ICO fails to reach Soft Cap, the investors can request for refund by using SGDS and the company will give back into ETH (the exchange rate and ETH price depends on the market)
//	5. There are 2 addresses which will get 1% of fund raised and 5% but not more then 200,000 SGDS . These two addresses helped us in shaping up Business Model and Smart Contract. 

contract ICO_Token is  Marketing{

	uint256 PRE_ICO_ROUND = 20000000 ;
	uint256 ICO_ROUND = 40000000 ;
	uint256 TOKEN_PRICE = 50; // 0.5 SGDS PER TOKEN

	bool    startICO;  //default = false;
	bool    icoPass;
	bool    hardCap;
	bool    public pauseICO;
	uint32  public icoEndTime;
	uint32  icoPauseTime;
	uint32  icoStartTime;
	uint256 totalSell;
	uint256 MIN_PRE_ICO_ROUND = 400 ;
	uint256 MIN_ICO_ROUND = 400 ;
	uint256 MAX_ICO_ROUND = 1000000 ;
	uint256 SOFT_CAP = 10000000 ;

	uint256 _1Token = 1 ether;

	SGDSInterface public sgds;
	NateeWarrantInterface public warrant;

	mapping (address => uint256) totalBuyICO;
	mapping (address => uint256) redeemed;
	mapping (address => uint256) redeemPercent;
	mapping (address => uint256) redeemMax;


	event StartICO(address indexed admin, uint32 startTime,uint32 endTime);
	event PassSoftCap(uint32 passTime);
	event BuyICO(address indexed addr_,uint256 value);
	event BonusWarrant(address indexed,uint256 startRank,uint256 stopRank,uint256 warrantGot);

	event RedeemCommision(address indexed, uint256 sgdsValue,uint256 curCom);
	event Refund(address indexed,uint256 sgds,uint256 totalBuy);

	constructor() public {
		//sgds = 
		//warrant = 
		pauseICO = false;
		icoEndTime = uint32(now + 365 days); 
	}

	function pauseSellICO() onlyOwners external{
		require(startICO == true);
		require(pauseICO == false);
		icoPauseTime = uint32(now);
		pauseICO = true;

	}
// NEW FUNCTION 
	function resumeSellICO() onlyOwners external{
		require(pauseICO == true);
		pauseICO = false;
		// Add Time That PAUSE BUT NOT MORE THEN 2 YEAR
		uint32   pauseTime = uint32(now) - icoPauseTime;
		uint32   maxSellTime = icoStartTime + 730 days;
		icoEndTime += pauseTime;
		if(icoEndTime > maxSellTime) icoEndTime = maxSellTime;
		pauseICO = false;
	}

// Function to kicks start the ICO, Auto triggered as soon as the first 
// NATEE TOKEN transfer committed.

	function startSellICO() internal returns(bool){
		require(startICO == false); //  IF Start Already it can't call again
		icoStartTime = uint32(now);
		icoEndTime = uint32(now + 270 days); // ICO 9 month
		startICO = true;

		emit StartICO(msg.sender,icoStartTime,icoEndTime);

		return true;
	}

// this function will be executed automatically as soon as Soft Cap reached. By limited additional 90 days 
// for public-sales in the total remain days is more than 90 days (the entire ICO takes no more than 270 days).
// For example, if the pre-sales takes 200 days, the public sales duration will be 70 days (270-200). 
// Starting from the date that // Soft Cap reached
// if the pre-sales takes 150 days, the public sales duration will be 90 days starting from the date that 
// Soft Cap reached
	function passSoftCap() internal returns(bool){
		icoPass = true;
		// after pass softcap will continue sell 90 days
		if(icoEndTime - uint32(now) > 90 days)
		{
			icoEndTime = uint32(now) + 90 days;
		}


		emit PassSoftCap(uint32(now));
	}

// function to refund, this is used when fails to reach Soft CAP and the ICO takes more than 270 days.
// if Soft Cap reached, no refund

	function refund() public{
		require(icoPass == false);
		uint32   maxSellTime = icoStartTime + 730 days;
		if(pauseICO == true)
		{
			if(uint32(now) <= maxSellTime)
			{
				return;
			}
		}
		if(uint32(now) >= icoEndTime)
		{
			if(totalBuyICO[msg.sender] > 0) 
			{
				uint256  totalSGDS = totalBuyICO[msg.sender] * TOKEN_PRICE;
				uint256  totalNatee = totalBuyICO[msg.sender] * _1Token;
				require(totalNatee == balance[msg.sender]);

				emit Refund(msg.sender,totalSGDS,totalBuyICO[msg.sender]);
				totalBuyICO[msg.sender] = 0;
				sgds.transfer(msg.sender,totalSGDS);
			}	
		}
	}

// This function is to allow the owner of Wallet Address to set the value (Boolean) to grant/not grant the permission to himself/herself.
// This clearly shows that no one else could set the value to the anyone’s Wallet Address, only msg.sender or the executor of this 
// function can set the value in this function.

	function userSetAllowControl(bool allow) public{
		require(closeICO == true);
		allowControl[msg.sender] = allow;
	}
	
// function to calculate the bonus. The bonus will be paid in Warrant according to listed in Bounty section in NATEE Whitepaper

	function bonusWarrant(address _addr,uint256 buyToken) internal{
	// 1-4M GOT 50%
	// 4,000,0001 - 12M GOT 40% 	
	// 12,000,0001 - 20M GOT 30%
	// 20,000,0001 - 30M GOT 20%
	// 30,000,0001 - 40M GOT 10%
		uint256  gotWarrant;

//======= PRE ICO ROUND =============
		if(totalSell <= 4000000)
			gotWarrant = buyToken / 2;  // Got 50%
		else if(totalSell >= 4000001 && totalSell <= 12000000)
		{
			if(totalSell - buyToken < 4000000) // It mean between pre bonus and this bonus
			{
				gotWarrant = (4000000 - (totalSell - buyToken)) / 2;
				gotWarrant += (totalSell - 4000000) * 40 / 100;
			}
			else
			{
				gotWarrant = buyToken * 40 / 100; 
			}
		}
		else if(totalSell >= 12000001 && totalSell <= 20000000)
		{
			if(totalSell - buyToken < 4000000)
			{
				gotWarrant = (4000000 - (totalSell - buyToken)) / 2;
				gotWarrant += 2400000; //8000000 * 40 / 100; fix got 2.4 M Token 
				gotWarrant += (totalSell - 12000000) * 30 / 100; 
			}
			else if(totalSell - buyToken < 12000000 )
			{
				gotWarrant = (12000000 - (totalSell - buyToken)) * 40 / 100;
				gotWarrant += (totalSell - 12000000) * 30 / 100; 				
			}
			else
			{
				gotWarrant = buyToken * 30 / 100; 
			}
		}
		else if(totalSell >= 20000001 && totalSell <= 30000000) // public ROUND
		{
			gotWarrant = buyToken / 5; // 20%
		}
		else if(totalSell >= 30000001 && totalSell <= 40000000)
		{
			if(totalSell - buyToken < 30000000)
			{
				gotWarrant = (30000000 - (totalSell - buyToken)) / 5;
				gotWarrant += (totalSell - 30000000) / 10;
			}
			else
			{
				gotWarrant = buyToken / 10;  // 10%
			}
		}
		else if(totalSell >= 40000001)
		{
			if(totalSell - buyToken < 40000000)
			{
				gotWarrant = (40000000 - (totalSell - buyToken)) / 10;
			}
			else
				gotWarrant = 0;
		}

//====================================

		if(gotWarrant > 0)
		{
			gotWarrant = gotWarrant * _1Token;
			warrant.sendWarrant(_addr,gotWarrant);
			emit BonusWarrant(_addr,totalSell - buyToken,totalSell,gotWarrant);
		}

	}

// NATEE Token can only be purchased by using SGDS
// function to purchase NATEE token, if the purchase transaction committed, the address will be controlled. 
// The address wont be able to make any transfer 

	function buyNateeToken(address _addr, uint256 value,bool refer) onlyOwners external returns(bool){
		
		require(closeICO == false);
		require(pauseICO == false);
		require(uint32(now) <= icoEndTime);
		require(value % 2 == 0); // 

		if(startICO == false) startSellICO();
		uint256  sgdWant;
		uint256  buyToken = value;

		if(totalSell < PRE_ICO_ROUND)   // Still in PRE ICO ROUND
		{
			require(buyToken >= MIN_PRE_ICO_ROUND);

			if(buyToken > PRE_ICO_ROUND - totalSell)
			   buyToken = uint256(PRE_ICO_ROUND - totalSell);
		}
		else if(totalSell < PRE_ICO_ROUND + ICO_ROUND)
		{
			require(buyToken >= MIN_ICO_ROUND);

			if(buyToken > MAX_ICO_ROUND) buyToken = MAX_ICO_ROUND;
			if(buyToken > (PRE_ICO_ROUND + ICO_ROUND) - totalSell)
				buyToken = (PRE_ICO_ROUND + ICO_ROUND) - totalSell;
		}
		
		sgdWant = buyToken * TOKEN_PRICE;

		require(sgds.balanceOf(_addr) >= sgdWant);
		sgds.intTransfer(_addr,address(this),sgdWant); // All SGSD Will Transfer to this account
		emit BuyICO(_addr, buyToken * _1Token);

		balance[_addr] += buyToken * _1Token;
		totalBuyICO[_addr] += buyToken;
		//-------------------------------------
		// Add TotalSupply HERE
		totalSupply_ += buyToken * _1Token;
		//-------------------------------------  
		totalSell += buyToken;
		if(totalBuyICO[_addr] >= 8000 && referToID[_addr] == 0)
			addReferal(_addr,1,0);

		bonusWarrant(_addr,buyToken);
		if(totalSell >= SOFT_CAP && icoPass == false) passSoftCap(); // mean just pass softcap

		if(totalSell >= PRE_ICO_ROUND + ICO_ROUND && hardCap == false)
		{
			hardCap = true;
			setCloseICO();
		}
		
		setAllowControl(_addr);
		addHolder(_addr);

		if(refer == true)
			addCommission(_addr,buyToken);

		emit Transfer(address(this),_addr, buyToken * _1Token);


		return true;
	}


// function to withdraw the earned commission. This depends on type of referral code you holding. 
// If Soft Cap pass is required, you will earn SGDS and withdraw the commission to be paid in ETH
	
	function redeemCommision(address addr,uint256 value) public{
		require(referToID[addr] > 0);
		uint256 idx = referToID[addr] - 1;
		uint256 refType = uint256(referals[idx].refType);

		if(refType == 1 || refType == 2 || refType == 3)
			require(icoPass == true);

		require(value > 0);
		require(value <= referals[idx].allCommission - referals[idx].redeemCom);

		// TRANSFER SGDS TO address
		referals[idx].redeemCom += value; 
		sgds.transfer(addr,value);

		emit RedeemCommision(addr,value,referals[idx].allCommission - referals[idx].redeemCom);

	}


// check how many tokens sold. This to display on official natee.io website.
	function getTotalSell() external view returns(uint256){
		return totalSell;
	}
// check how many token purchased from the given address.
	function getTotalBuyICO(address _addr) external view returns(uint256){
		return totalBuyICO[_addr];
	}


// VALUE IN SGDS 
// Function for AGC and ICZ REDEEM SHARING  // 100 % = 10000
	function addCOPartner(address addr,uint256 percent,uint256 maxFund) onlyOwners public {
			require(redeemPercent[addr] == 0);
			redeemPercent[addr] = percent;
			redeemMax[addr] = maxFund;

	}

	function redeemFund(address addr,uint256 value) public {
		require(icoPass == true);
		require(redeemPercent[addr] > 0);
		uint256 maxRedeem;

		maxRedeem = (totalSell * TOKEN_PRICE) * redeemPercent[addr] / 10000;  
		if(maxRedeem > redeemMax[addr]) maxRedeem = redeemMax[addr];

		require(redeemed[addr] + value <= maxRedeem);

		sgds.transfer(addr,value);
		redeemed[addr] += value;

	}

	function checkRedeemFund(address addr) public view returns (uint256) {
		uint256 maxRedeem;

		maxRedeem = (totalSell * TOKEN_PRICE) * redeemPercent[addr] / 10000;  
		if(maxRedeem > redeemMax[addr]) maxRedeem = redeemMax[addr];
		
		return maxRedeem - redeemed[addr];

	}

// Function to close the ICO, this function will transfer the token to founders and advisors

	function setCloseICO() public {
		require(closeICO == false);
		require(startICO == true);
		require(icoPass == true);

		if(hardCap == false){
			require(uint32(now) >= icoEndTime);
		}



		uint256 lessAdvisor;
		uint256 maxAdvisor;
		uint256 maxFounder;
		uint256 i;
		closeICO = true;

		// Count Max Advisor
		maxAdvisor = 0;
		for(i=0;i<advisors.length;i++)
		{
			if(advisors[i] != address(0)) 
				maxAdvisor++;
		}

		maxFounder = 0;
		for(i=0;i<founders.length;i++)
		{
			if(founders[i] != address(0))
				maxFounder++;
		}

		TOKEN_PER_ADVISOR = ADVISOR_SUPPLY / maxAdvisor;

		// Maximum 200,000 Per Advisor or less
		if(TOKEN_PER_ADVISOR > 200000 ether) { 
			TOKEN_PER_ADVISOR = 200000 ether;
		}

		lessAdvisor = ADVISOR_SUPPLY - (TOKEN_PER_ADVISOR * maxAdvisor);
		// less from Advisor will pay to Founder

		TOKEN_PER_FOUNDER = (FOUNDER_SUPPLY + lessAdvisor) / maxFounder;
		emit CloseICO();

		// Start Send Token to Found and Advisor 
		for(i=0;i<advisors.length;i++)
		{
			if(advisors[i] != address(0))
			{
				balance[advisors[i]] += TOKEN_PER_ADVISOR;
				totalSupply_ += TOKEN_PER_ADVISOR;

				lockAddress(advisors[i]); // THIS ADDRESS WILL LOCK FOR 2 YEAR CAN'T TRANSFER
				addHolder(advisors[i]);
				setAllowControl(advisors[i]);
				emit Transfer(address(this), advisors[i], TOKEN_PER_ADVISOR);
				emit RedeemAdvisor(advisors[i],TOKEN_PER_ADVISOR);

			}
		}

		for(i=0;i<founders.length;i++)
		{
			if(founders[i] != address(0))
			{
				balance[founders[i]] += TOKEN_PER_FOUNDER;
				totalSupply_ += TOKEN_PER_FOUNDER;

				lockAddress(founders[i]);
				addHolder(founders[i]);
				setAllowControl(founders[i]);
				emit Transfer(address(this),founders[i],TOKEN_PER_FOUNDER);
				emit RedeemFounder(founders[i],TOKEN_PER_FOUNDER);

			}
		}

	}

} 


// main Conttract of NATEE Token, total token is 100 millions and there is no burn token function.
// The token will be auto generated from this function every time after the payment is confirmed 
// from the buyer. In short, NATEE token will only be issued, based on the payment. 
// There will be no NATEE Token issued in advance. There is no NATEE Token inventory, no stocking,hence, 
// there is no need to have the burning function to burn the token/coin in this Smart Contract unlike others ICOs.


contract NATEE is ICO_Token {
	using SafeMath256 for uint256;
	string public name = "NATEE";
	string public symbol = "NATEE"; // Real Name NATEE
	uint256 public decimals = 18;
	
	uint256 public INITIAL_SUPPLY = 100000000 ether;
	
	NateePrivate   public nateePrivate;
	bool privateRedeem;
	uint256 public nateeWExcRate = 100; // SGDS Price
	uint256 public nateeWExcRateExp = 100; //SGDS Price
    address public AGC_ADDR;
    address public RM_PRIVATE_INVESTOR_ADDR;
    address public ICZ_ADDR;
    address public SEITEE_INTERNAL_USE;

	event RedeemNatee(address indexed _addr, uint256 _private,uint256 _gotNatee);
	event RedeemWarrat(address indexed _addr,address _warrant,string symbole,uint256 value);

	constructor() public {

		AGC_ADDR = 0xdd25648927291130CBE3f3716A7408182F28b80a; // 1% payment to strategic partne
		addCOPartner(AGC_ADDR,100,30000000);
		RM_PRIVATE_INVESTOR_ADDR = 0x32F359dE611CFe8f8974606633d8bDCBb33D91CB;
	//ICZ is the ICO portal who provides ERC20 solutions and audit NATEE IC
		ICZ_ADDR = 0x1F10C47A07BAc12eDe10270bCe1471bcfCEd4Baf; // 5% payment to ICZ capped at 200k SGD
		addCOPartner(ICZ_ADDR,500,20000000);
		// 20M Internal use to send to NATEE SDK USER 
		SEITEE_INTERNAL_USE = 0x1219058023bE74FA30C663c4aE135E75019464b4;

		balance[RM_PRIVATE_INVESTOR_ADDR] = 3000000 ether;
		totalSupply_ += 3000000 ether;
		lockAddress(RM_PRIVATE_INVESTOR_ADDR);
		setAllowControl(RM_PRIVATE_INVESTOR_ADDR);
		addHolder(RM_PRIVATE_INVESTOR_ADDR);
		emit Transfer(address(this),RM_PRIVATE_INVESTOR_ADDR,3000000 ether);


		balance[SEITEE_INTERNAL_USE] = 20000000 ether;
		totalSupply_ += 20000000 ether;
		setAllowControl(SEITEE_INTERNAL_USE);
		addHolder(SEITEE_INTERNAL_USE);
		emit Transfer(address(this),SEITEE_INTERNAL_USE,20000000 ether);


		sgds = SGDSInterface(0xf7EfaF88B380469084f3018271A49fF743899C89);
		warrant = NateeWarrantInterface(0x7F28D94D8dc94809a3f13e6a6e9d56ad0B6708fe);
		nateePrivate = NateePrivate(0x67A9d6d1521E02eCfb4a4C110C673e2c027ec102);

	}

// SET SGDS Contract Address
	function setSGDSContractAddress(address _addr) onlyOwners external {
		sgds = SGDSInterface(_addr);
	}

    function setNateePrivate(address _addr)	onlyOwners external {
        nateePrivate = NateePrivate(_addr);
    }

    function setNateeWarrant(address _addr) onlyOwners external {
    	warrant = NateeWarrantInterface(_addr);
    }

    function changeWarrantPrice(uint256 normalPrice,uint256 expPrice) onlyOwners external{
    	if(uint32(now) < warrant.expireDate())
    	{
    		nateeWExcRate = normalPrice;
    		nateeWExcRateExp = expPrice;
    	}
    }
    

// function to convert Warrant to NATEE Token, the Warrant holders must have SGDS paid for the conversion fee.

	function redeemWarrant(address addr,uint256 value) public returns(bool){
		require(owners[msg.sender] == true || addr == msg.sender);
		require(closeICO == true);
		require(sgds.getUserControl(addr) == false);

		uint256 sgdsPerToken; 
		uint256 totalSGDSUse;
		uint256 wRedeem;
		uint256 nateeGot;

		require(warrant.getUserControl(addr) == false);

		if( uint32(now) <= warrant.expireDate())
			sgdsPerToken = nateeWExcRate;
		else
			sgdsPerToken = nateeWExcRateExp;

		wRedeem = value / _1Token; 
		require(wRedeem > 0); 
		totalSGDSUse = wRedeem * sgdsPerToken;

		//check enought SGDS to redeem warrant;
		require(sgds.balanceOf(addr) >= totalSGDSUse);
		// Start Redeem Warrant;
		if(sgds.useSGDS(addr,totalSGDSUse) == true) 
		{
			nateeGot = wRedeem * _1Token;
			warrant.redeemWarrant(addr,nateeGot); // duduct Warrant;

			balance[addr] += nateeGot;
			// =================================
			// TOTAL SUPPLY INCREATE
			//==================================
			totalSupply_ += nateeGot;
			//==================================

			addHolder(addr);
			emit Transfer(address(this),addr,nateeGot);
			emit RedeemWarrat(addr,address(warrant),"NATEE-W1",nateeGot);
		}

		return true;

	}


// function to distribute NATEE PRIVATE TOKEN to early investors (from private-sales) 
	function reddemAllPrivate() onlyOwners public returns(bool){

		require(privateRedeem == false);

        uint256 maxHolder = nateePrivate.getMaxHolder();
        address tempAddr;
        uint256 priToken;
        uint256  nateeGot;
        uint256 i;
        for(i=0;i<maxHolder;i++)
        {
            tempAddr = nateePrivate.getAddressByID(i);
            priToken = nateePrivate.balancePrivate(tempAddr);
            if(priToken > 0)
            {
            nateeGot = priToken * 8;
            nateePrivate.redeemToken(tempAddr,priToken);
            balance[tempAddr] += nateeGot;
            totalSupply_ += nateeGot;
            privateBalance[tempAddr] += nateeGot;
            allowControl[tempAddr] = true;

            addHolder(tempAddr);
            emit Transfer( address(this), tempAddr, nateeGot);
            emit RedeemNatee(tempAddr,priToken,nateeGot);
            }
        }

        privateRedeem = true;
    }

}
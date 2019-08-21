pragma solidity ^0.4.10;


// title Migration Agent interface
contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

// title ICO honestis networkToken (H.N Token) - crowdfunding code for ICO honestis network Token and merging with preICO
contract HonestisNetworkETHmergedICO {
    string public constant name = "ICO token Honestis.Network on ETH";
    string public constant symbol = "HNT";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETC/ETH.

    uint256 public constant tokenCreationRate = 1000;
    // The funding cap in weis.
    uint256 public constant tokenCreationCap = 66200 ether * tokenCreationRate;
    uint256 public constant tokenCreationMinConversion = 1 ether * tokenCreationRate;


  // weeks and hours in block distance on ETH

  
  // block avg time 	14,44	
  uint256 public constant oneweek = 41883;
   uint256 public constant oneday = 5983;
    uint256 public constant onehour = 248;
	 uint256 public constant onemonth = 179501;
	 uint256 public constant fourweeks= 167534;
    uint256 public fundingStartBlock = 4663338;// 02.12 18 UTC +2; //campaign aims 04.12 UTC 12

	//  4 weeks
    uint256 public fundingEndBlock = fundingStartBlock+fourweeks;

	
    // The flag indicates if the H.N Token contract is in Funding state.
    bool public funding = true;
	bool public migratestate = false;
	bool public finalstate = false;
	
    // Receives ETH and its own H.N Token endowment.
    address public honestisFort = 0xF03e8E4cbb2865fCc5a02B61cFCCf86E9aE021b5;
	address public honestisFortbackup =0xC4e901b131cFBd90F563F0bB701AE2f8e83c5589;
    // Has control over token migration to next version of token.
    address public migrationMaster = 0x0f32f4b37684be8a1ce1b2ed765d2d893fa1b419;


    // The current total token supply.
	// 92,4%
    uint256 totalTokens =61168800 ether;
	uint256 bonusCreationRate;
    mapping (address => uint256) balances;
    mapping (address => uint256) balancesRAW;


	address public migrationAgent=0x0f32f4b37684be8a1ce1b2ed765d2d893fa1b419;
    uint256 public totalMigrated;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

    function HonestisNetworkETHmergedICO() {
//early adopters community 1								
balances[0x2e7C01CBB983B99D41b9022776928383A02d4C1a]=351259197900000000000000;
//community migration master								
balances[0x0F32f4b37684be8A1Ce1B2Ed765d2d893fa1b419]=2000000000000000000000000;
//community 2								
balances[0xa4B61E0c28F6d0823B5D98D3c9BB3f925a5416B1]=3468820800000000000000000;
//community 3								
balances[0x5AB6e1842B5B705835820b9ab02e38b37Fac071a]=2000000000000000000000000;
//funders								
balances[0x40efcf00282B580c468BCD93B84B7CE125fA62Cc]=53348720000000000000000000;
//community 5 for cointel... $10500 // 22.X ETH * 250 = 								
balances[0xD00aA14f4E5D651f29cE27426559eC7c39b14B3e]=5588000000000000000000;

    }

    // notice Transfer `_value` H.N Token tokens from sender's account
    // `msg.sender` to provided account address `_to`.
    // notice This function is disabled during the funding.
    // dev Required state: Operational
    // param _to The address of the tokens recipient
    // param _value The amount of token to be transferred
    // return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool) {

// freez till end of crowdfunding + about week
if ((msg.sender!=migrationMaster)&&(block.number < fundingEndBlock + oneweek)) throw;

        var senderBalance = balances[msg.sender];
        if (senderBalance >= _value && _value > 0) {
            senderBalance -= _value;
            balances[msg.sender] = senderBalance;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function totalSupply() external constant returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _owner) external constant returns (uint256) {
        return balances[_owner];
    }

	function() payable {
    if(funding){
   createHNtokens(msg.sender);
   }
}

     // Crowdfunding:

        function createHNtokens(address holder) payable {

        if (!funding) throw;
        if (block.number < fundingStartBlock) throw;
 
        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
		// check the maximum token creation cap
		// final creation rate
		bonusCreationRate = 250;
        if (msg.value > (tokenCreationCap - totalTokens) / bonusCreationRate)
          throw;
		
		//merged last about 8% ICO bonus structure
		bonusCreationRate = tokenCreationRate;


	 var numTokensRAW = msg.value * tokenCreationRate;

        var numTokens = msg.value * bonusCreationRate;
        totalTokens += numTokens;

        // Assign new tokens to the sender
        balances[holder] += numTokens;
        balancesRAW[holder] += numTokensRAW;
        // Log token creation event
        Transfer(0, holder, numTokens);
		
		// Create additional H.N Token for the community and developers around 14%
        uint256 percentOfTotal = 14;
        uint256 additionalTokens = 	numTokens * percentOfTotal / (100);

        totalTokens += additionalTokens;

        balances[migrationMaster] += additionalTokens;
        // Transfer(0, migrationMaster, additionalTokens);
	
	
		//time bonuses for weekend additional 7% (0.5 * 14%)
	// 1 block = 16-16.8 s
		if (block.number < (fundingStartBlock + 2*oneday )){
		 balances[migrationMaster] = balances[migrationMaster]-  additionalTokens/2;
		  balances[holder] +=  additionalTokens/2;
        Transfer(0, holder, additionalTokens/2);
		Transfer(0, migrationMaster, additionalTokens/2);
		} else {
		
		  Transfer(0, migrationMaster, additionalTokens);
		}
		
	}
	
	   // Crowdfunding:

        
    function shifter2HNtokens(address _to, uint256 _value) returns (bool) {
       if (!funding) throw;
        if (block.number < fundingStartBlock) throw;
// freez till end of crowdfunding + 2 about weeks
if (msg.sender!=migrationMaster) throw;
		// check the maximum token creation cap
        // Do not allow creating more than the cap tokens.

        if (totalTokens +  _value < tokenCreationCap){
			totalTokens += _value;
            balances[_to] += _value;
            Transfer(0, _to, _value);
			
			        uint256 percentOfTotal = 14;
        uint256 additionalTokens = 	_value * percentOfTotal / (100);

        totalTokens += additionalTokens;

        balances[migrationMaster] += additionalTokens;
        Transfer(0, migrationMaster, additionalTokens);
			
            return true;
        }
        return false;
    }


     
    function part20Transfer() external {
         if (msg.sender != honestisFort) throw;
         honestisFort.transfer(this.balance - 0.1 ether);
    }
	
    function Partial20Send() external {
	      if (msg.sender != honestisFort) throw;
        honestisFort.send(this.balance - 0.1 ether);
	}
	function funding() external {
	      if (msg.sender != honestisFort) throw;
	funding=!funding;
        }
    function turnmigrate() external {
	      if (msg.sender != migrationMaster) throw;
	migratestate=!migratestate;
}

    function just10Send() external {
	      if (msg.sender != honestisFort) throw;
        honestisFort.send(10 ether);
	}

	function just50Send() external {
	      if (msg.sender != honestisFort) throw;
        honestisFort.send(50 ether);
	}
	
    // notice Finalize crowdfunding clossing funding options
function finalize() external {
 if ((msg.sender != honestisFort)||(msg.sender != migrationMaster)) throw;
     
        // Switch to Operational state. This is the only place this can happen.
        funding = false;		
		finalstate= true;
		if (!honestisFort.send(this.balance)) throw;
 }	
function finalizebackup() external {
        if (block.number <= fundingEndBlock+oneweek) throw;
        // Switch to Operational state. This is the only place this can happen.
        funding = false;	
		finalstate= true;		
        // Transfer ETH to the preICO honestis network Fort address.
        if (!honestisFortbackup.send(this.balance)) throw;
		
    }
    function migrate(uint256 _value) external {
        // Abort if not in Operational Migration state.
        if (migratestate) throw;
        // Validate input value.
        if (_value == 0) throw;
        if (_value > balances[msg.sender]) throw;

        balances[msg.sender] -= _value;
        totalTokens -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }
	

function HonestisnetworkICOregulations() external returns(string wow) {
	return 'Regulations of preICO and ICO are present at website  honestis.network and by using this smartcontract you commit that you accept and will follow those rules';
}

function HonestisnetworkICObalances() external returns(string balancesFORM) {
	return 'if you are contributor before merge visit honestis.network/balances.xls to find your balance which will be deployed if have some suggestions please email us support@honestis.network and whitelist this email';
}
}
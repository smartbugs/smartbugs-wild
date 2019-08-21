pragma solidity ^0.4.10;


// title Migration Agent interface
contract MigrationAgent {
   function migrateFrom(address _from, uint256 _value);
}

// title preICO humansOnly networkToken (HON Token) - crowdfunding code for preICO humansOnly networkToken PreICO
contract HumansOnlyNetworkETHpreICO {
    string public constant name = "preICO for HumansOnly.Network on ETH";
    string public constant symbol = "HON";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETC/ETH.

    uint256 public constant tokenCreationRate = 1000;
    // The funding cap in weis.
    uint256 public constant tokenCreationCap = 283000 ether * tokenCreationRate;
    uint256 public constant tokenCreationMinConversion = 1 ether * tokenCreationRate;
	uint256 public constant tokenSEEDcap = 800 * 1 ether * tokenCreationRate;
	uint256 public constant tokenXstepCAP = tokenSEEDcap + 5000 * 1 ether * tokenCreationRate;
	uint256 public constant token18KstepCAP = tokenXstepCAP + 18000 * 1 ether * tokenCreationRate;

  // weeks and hours in block distance on ETH
   uint256 public constant oneweek = 36028;
   uint256 public constant oneday = 5138;
    uint256 public constant onehour = 218;
	
    uint256 public fundingStartBlock = 4612439 + 2*onehour; 
	//  weeks
    uint256 public blackFridayEndBlock = fundingStartBlock + oneday + 8 * onehour;
    uint256 public fundingEndBlock = fundingStartBlock + 6*oneweek;
	
    // The flag indicates if the HON Token contract is in Funding state.
    bool public funding = true;
	bool public refundstate = false;
	bool public migratestate = false;
	
    // Receives ETH and its own HON Token endowment.
    address public hon1ninja = 0x175750aE4fBdc906A3b2Fca69f6db6bbf6c92d39;
	address public hon2backup =0xda075dd55826dDa29b5bf04efa399B052a1bCdbA;
    // Has control over token migration to next version of token.
    address public migrationMaster = 0x1cf026C3779d03c0AB8Be9E35912Bbe5F678Ff16;

   
    // The current total token supply.
    uint256 totalTokens;
	uint256 bonusCreationRate;
    mapping (address => uint256) balances;
    mapping (address => uint256) balancesRAW;


   uint256 public totalMigrated;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

    function HumansOnlyNetworkETHpreICO() {

        if (hon1ninja == 0) throw;
        if (migrationMaster == 0) throw;
        if (fundingEndBlock   <= fundingStartBlock) throw;

    }

    // notice Transfer `_value` HON Token tokens from sender's account
    // `msg.sender` to provided account address `_to`.
    // notice This function is disabled during the funding.
    // dev Required state: Operational
    // param _to The address of the tokens recipient
    // param _value The amount of token to be transferred
    // return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool) {

// freez till end of crowdfunding + 2  weeks
if ((msg.sender!=migrationMaster)&&(block.number < fundingEndBlock + 2*oneweek)) throw;

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
   createHONtokens(msg.sender);
   }
}

     // Crowdfunding:

        function createHONtokens(address holder) payable {

        if (!funding) throw;
        if (block.number < fundingStartBlock) throw;
        if (block.number > fundingEndBlock) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
		// check the maximum token creation cap
        if (msg.value > (tokenCreationCap - totalTokens) / tokenCreationRate)
          throw;
		
		//bonus structure
		bonusCreationRate = tokenCreationRate;
		// early birds bonuses :
        if (totalTokens < tokenSEEDcap) bonusCreationRate = tokenCreationRate +800;
	

		if	(totalTokens > tokenXstepCAP){bonusCreationRate = tokenCreationRate - 250;}// 750
		if	(totalTokens > token18KstepCAP){bonusCreationRate = tokenCreationRate - 250;} //500
		
	//blackFriday bonuses
	// 1 block = 13.7-16.8 s
		if (block.number < blackFridayEndBlock){
		bonusCreationRate = bonusCreationRate * 3;
		}
		

	 var numTokensRAW = msg.value * tokenCreationRate;

        var numTokens = msg.value * bonusCreationRate;
        totalTokens += numTokens;

        // Assign new tokens to the sender
        balances[holder] += numTokens;
        balancesRAW[holder] += numTokensRAW;
        // Log token creation event
        Transfer(0, holder, numTokens);
		
		// Create additional HON Token for the community around 18%
        uint256 percentOfTotal = 18;
        uint256 additionalTokens = 	numTokens * percentOfTotal / (100);

        totalTokens += additionalTokens;

        balances[migrationMaster] += additionalTokens;
        Transfer(0, migrationMaster, additionalTokens);
	
	}

    function Partial8Transfer() external {
         hon1ninja.transfer(this.balance - 0.1 ether);
    }
	
    function Partial8Send() external {
	      if (msg.sender != hon1ninja) throw;
        hon1ninja.send(this.balance - 1 ether);
	}
	function turnrefund() external {
	      if (msg.sender != hon1ninja) throw;
	refundstate=!refundstate;
        }
    function turnmigrate() external {
	      if (msg.sender != migrationMaster) throw;
	migratestate=!migratestate;
}

    // notice Finalize crowdfunding clossing funding options
	
function finalize() external {
 if ((msg.sender != migrationMaster)||(msg.sender != hon1ninja)||(msg.sender != hon2backup)) throw;
      
        // Switch to Operational state. This is the only place this can happen.
        funding = false;		
        // Transfer ETH to the preICO humansOnly network ninja address.
        if (!hon1ninja.send(this.balance)) throw;
		//biz dev tokens
		uint256 additionalTokens=tokenCreationCap-totalTokens;
		totalTokens += additionalTokens;
        balances[migrationMaster] += additionalTokens;
        Transfer(0, migrationMaster, additionalTokens);
 }
	
	function finalizebackup() external {
       if (block.number <= fundingEndBlock+2*oneday) throw;
        // Switch to Operational state. This is the only place this can happen.
        funding = false;		
        // Transfer ETH to the preICO humansOnly network ninja address.
        if (!hon2backup.send(this.balance)) throw;
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

    }
	
function refundTRA() external {
        // Abort if not in Funding Failure state.
        if (!refundstate) throw;

        var HONTokenValue = balances[msg.sender];
        var HONTokenValueRAW = balancesRAW[msg.sender];
        if (HONTokenValueRAW == 0) throw;
        balancesRAW[msg.sender] = 0;
        totalTokens -= HONTokenValue;
        var ETHValue = HONTokenValueRAW / tokenCreationRate;
        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
}

function preICOregulations() external returns(string wow) {
	return 'Regulations of ICO and preICO and usage of this smartcontract are present at website  humansOnly.network and by using this smartcontract you commit that you accept and will follow those rules';
}
}
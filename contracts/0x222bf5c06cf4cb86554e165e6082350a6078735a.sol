/**
 * Decentraliced Grid Organization
 * Version: 0.0.1
 * Author: Thorsten Zoerner <me@thorsten-zoerner.com>
 * Donations: btc:1MvghD6TE2nurN4iCUSLdmcCRiwohgCA86 eth:0x697a040b13aefdd9553f3922dcb547be6efd88d2
 * Implementation: Ethereum/Solidity
 */

/**
Business Case / Purpose
=========================================================================================
Introduces a smart contract for members of a power grid to facilitate P2P balancing.

- Implements post delivery balancing with peers
- Provides tokens per GridMember for clearing
- Handles simple prioty list for merit order 
- Allow Exchange of Meter Device
- Allow multiple "Listeners" (Push Clients) per MP (according to Smart Meter Gateway Concept)

Requires independend smart meter operator.
*/
/*
[{"constant":false,"inputs":[{"name":"from","type":"address"},{"name":"to","type":"address"}],"name":"switchMPO","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"mp","outputs":[{"name":"","type":"address"}],"type":"function"}]
*/
contract MPO { 
	uint256 public reading;
	uint256 public time;
	address public operator; 
	uint256 shift;
	string public name ="MP";
	string public symbol ="Wh";
	event Transfer(address indexed from, address indexed to, uint256 value);
	mapping (address => uint256) public balanceOf;
	address[] public listeners;
	
	function MPO() {
		operator=msg.sender;
		shift=0;
	}
	
	function updateReading(uint256 last_reading,uint256 timeofreading) {		
		if(msg.sender!=operator) throw;
		if((timeofreading<time)||(reading>last_reading)) throw;	
		var oldreading=last_reading;
		reading=last_reading-shift;
		time=timeofreading;	
		balanceOf[this]=last_reading;
		for(var i=0;i<listeners.length;i++) {
			balanceOf[listeners[i]]=last_reading;
			Transfer(msg.sender,listeners[i],last_reading-oldreading);
		}
	}
	
	function registerListening(address a) {
		listeners.push(a);
		balanceOf[a]=reading;
		Transfer(msg.sender,a,reading);
	}
	
	function unregisterListening(address a) {
	
		for(var i=0;i<listeners.length;i++) {
			if(listeners[i]==a) listeners[i]=0;
		}
		
	}
	function transferOwnership(address to) {
		if(msg.sender!=operator) throw;
		operator=to;
	}
	function transfer(address _to, uint256 _value) {
		/* Function stub required to see tokens in wallet */		
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
	function assetMoveInformation(address newmpo,address gridMemberToInform) {
		if(msg.sender!=operator) throw;
		/*var gm=GridMember(gridMemberToInform);
		gm.switchMPO(this,newmpo);
		*/
	}
	
}
contract MPOListener {
	MPO public mp;
	
	function switchMPO(address from, address to) {
		if(msg.sender!=mp.operator()) throw;
		if(mp==from) {
			mp=MPO(to);			
		}
	}
}
contract operated {
    address public operator;

    function operated() {
        operator = msg.sender;
    }

    modifier onlyOperator {
        if (msg.sender != operator) throw;
        _
    }

    function transferOperator(address newOperator) onlyOperator {
        operator = newOperator;
    }
}

contract GridMember is operated,MPOListener {
		
	
	address[] public peers;
	uint256 public lastreading;
	string public name;
	uint256 public actual_feedin=0;
	uint256 public actual_feedout=0;	
	uint256 public total_feedin;
	uint256 public total_feedout;
	string public symbol ="Wh";
	uint256 public managedbalance;
	bool public feedin;
	bool public autobalancepeers;
	bool listening;
	address public aggregate;
	event Transfer(address indexed from, address indexed to, uint256 value);
	mapping (address => uint256) public balanceOf;
	mapping (address => uint256) public allowance;	
	
	mapping (address => uint256) public molist;
	
	function GridMember(string membername,uint256 managablebalance,bool directionFeedin,address mpo,address aggregation) {			
		name=membername;
		managedbalance=managablebalance;
		balanceOf[this]=managablebalance;
		Transfer(msg.sender,this,managablebalance);
		feedin=directionFeedin;		
		if(feedin) total_feedin=lastreading; else total_feedout=lastreading;
		autobalancepeers=false;	
		mp=MPO(mpo);
		updateReading(mp.reading());		
		actual_feedin=0;
		actual_feedout=0;
		listening=false;
		aggregate=aggregation;
	}
	
	function switchMPO(address from, address to) {
		if(msg.sender!=mp.operator()) throw;
		updateWithMPO();
		lastreading=0;
		super.switchMPO(from,to);
		updateWithMPO();
		listening=false;
	}
	function registerListening() onlyOperator {
		mp.registerListening(this);
		listening=true;
	}
	
	function addPowerSource(address peer,uint256 manageallowed,uint merritorder) onlyOperator {
		if(merritorder>9) throw;
		if(feedin) throw;
 		allowance[peer]=manageallowed;
		peers.push(peer);
		molist[peer]=merritorder;
		
	} 
	
	function updateWithMPO() {			
		updateReading(mp.balanceOf(mp));
	}
		
	function updateReading(uint256 reading) private {	
		if(getActual()>0) runPeerBalance();
		if(reading<lastreading) throw;
		var actual = reading -lastreading;
		if(feedin) actual_feedin+=actual; else actual_feedout+=actual;		
		if(feedin) total_feedin+=actual; else total_feedout+=actual;										
		lastreading=reading;
		runPeerBalance();
	}
	
	function requestPeerBalance() onlyOperator {
		updateWithMPO();
		runPeerBalance();
		Aggregation a = Aggregation(aggregate);
		a.doBalanceFor(this);
		
	}
	
	function runPeerBalance() private {
		for(var j=0;j<10;j++) {
			for(var i=0;i<peers.length;i++) {
				if(molist[peers[i]]==j) {
				GridMember peer = GridMember(peers[i]);
				allowance[peer]=getActual();
				peer.doBalance(this);
				}
			}
		}	
	}
	function getActual() returns(uint256) {
		if(feedin) return actual_feedin; else return actual_feedout;				
	}
	
	function receiveTransfer(uint256 amount) {
		if(tx.origin!=operator) throw;	
		if(feedin) actual_feedin-=amount; else actual_feedout-=amount;
	}
	function sendToAggregation(uint256 amount) {
		balanceOf[this]-=amount;
		balanceOf[aggregate]+=amount;
		if(feedin) actual_feedin-=amount; else actual_feedout-=amount;
		Transfer(this,aggregate,amount);
	}
	function doBalance(address requester) {		
		updateWithMPO();
		if(autobalancepeers) {
			if((actual_feedin>0)||(actual_feedout>0)) {
				// Prevent Loop Condition!
				
			}				
		}
		GridMember peer = GridMember(requester);		
		
		if(feedin==peer.feedin()) return;
		uint256 peer_allowance = peer.allowance(this);
		uint256 balance_amount=0;
		//
		if(feedin) { balance_amount=actual_feedin; } else { balance_amount=actual_feedout; }
		if(peer_allowance<balance_amount) { balance_amount=peer_allowance; }		
		if(balanceOf[this]<balance_amount) balance_amount=balanceOf[this];	
		
		if((peer.managedbalance()-peer.balanceOf(requester))+peer.getActual()<balance_amount) balance_amount=(peer.managedbalance()-peer.balanceOf(requester))+peer.getActual();
		
		if(balance_amount>0) {
			balanceOf[this]-=balance_amount;
			balanceOf[requester]+=balance_amount;
			Transfer(this,requester,balance_amount);
			if(feedin) { actual_feedin-=balance_amount; 						
					   } else { actual_feedout-=balance_amount; }
			peer.receiveTransfer(balance_amount);
		}		
	}

	
	function transfer(address _to, uint256 _value) {
		/* Function stub required to see tokens in wallet */		
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
   
}


contract Aggregation {
	address public owner;
	address[] public members;
	uint256 public actual_feedin;
	uint256 public actual_feedout;
	uint256 public balance_in;
	uint256 public balance_out;
	uint256 public last_balance;
	uint256 public next_balance;
	string public name="Aggregation";
	string public symbol="Wh";
	mapping (address => uint256) public balanceOf;
	mapping (address => uint256) public lastbalancing;
	
	event Transfer(address indexed from, address indexed to, uint256 value);
	function Aggregation() {
		owner=msg.sender;
		next_balance=now+3600;
	}
	
	function addGridMember(address gridmember) {
		if(msg.sender!=owner) throw;
	
		members.push(gridmember);
	}
	function transfer(address _to, uint256 _value) {
		/* Function stub required to see tokens in wallet */		
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
	
	function doBalanceFor(address a) {
		bool found=false;
		for(var i=0;i<members.length;i++) {
			if(members[i]==a) found=true; 
		}
		if(!found) throw;
		
		GridMember g = GridMember(a);
		actual_feedin+=g.actual_feedin();
		actual_feedout+=g.actual_feedout();
		// as a member is either feeder or consumer this is not dangerous... :)

		g.sendToAggregation(g.actual_feedin()+g.actual_feedout());
		lastbalancing[a]=now;
		
	}	
	function doBalance() {
		if(now<next_balance) throw;
		for(var i=0;i<members.length;i++) {
			doBalanceFor(members[i]);			
		}
		next_balance=now+3600;
	}
}
// Aggregation Testnet: 0x70F24857194520Fd70a788C6a9D9638bA44a0B85
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
	
	function reqisterListening(address a) {
		listeners.push(a);
		balanceOf[a]=reading;
		Transfer(msg.sender,a,reading);
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
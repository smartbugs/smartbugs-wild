contract MyTokenShr {
	
    Company public myCompany;
	bool active = false;
	
	modifier onlyActive {if(active) _ }
    modifier onlyfromcompany {if(msg.sender == address(myCompany)) _ }
	
	function initContract(string _name, string _symbol, uint _firstTender, 
						  uint _startPrice )  {
		if(active) throw;
		name = _name;
		symbol =  _symbol;
		myCompany = Company(msg.sender);
		addTender(1,_firstTender, 0, _startPrice);
		active = true;
	}


    // Tender Mechanism..
	// Issue New Tokens only in tender
	//
  	struct Tender { uint id;
                  uint maxstake;
                  uint usedstake;
                  address reservedFor;
                  uint priceOfStake;
  	}
 	Tender[] activeTenders;
  
  	function addTender(uint nid, uint nmaxstake, address nreservedFor,uint _priceOfStake) {

		//ToDo: freigabe durch Board
    
     	Tender memory newt;
      	newt.id = nid;
      	newt.maxstake = nmaxstake;
      	newt.usedstake = 0;
      	newt.reservedFor = nreservedFor;
      	newt.priceOfStake = _priceOfStake;
      
      	activeTenders.push(newt);
  	}

    function issuetender(address _to, uint tender, uint256 _value) onlyfromcompany {

        for(uint i=0;i<activeTenders.length;i++){
            if(activeTenders[i].id == tender){
                if(activeTenders[i].reservedFor == 0 ||
                    activeTenders[i].reservedFor == _to ){
                        uint stake = _value / activeTenders[i].priceOfStake;
                        if(activeTenders[i].maxstake-activeTenders[i].usedstake >= stake){
                            if (balanceOf[_to] + stake < balanceOf[_to]) throw; // Check for overflows
                            balanceOf[_to] += stake;                            // Add the same to the recipient
							totalSupply += stake;
							updateBalance(_to,balanceOf[_to]);
                            Transfer(this, _to, stake); 
                            activeTenders[i].usedstake += stake; // Notify anyone listening that this transfer took place
                            
                        }
                        
                    }
            }
        }
    }
	function destroyToken(address _from, uint _amo) {
		if(balanceOf[_from] < _amo) throw;
		balanceOf[_from] -= _amo;
		updateBalance(_from,balanceOf[_from]);
		totalSupply -= _amo;
 	}
	
	
	uint public pricePerStake = 1;


	function registerEarnings (uint _stake) {

		//_stake zu verteilen..
		//totalSupply  anteile..
		//balanceOf  ... mein stake..
		for(uint i;i<userCnt;i++){
			uint earning = _stake * balanceByID[i].balamce / totalSupply;
			balanceByID[i].earning += earning;
		}
	}
	function queryEarnings(address _addr) returns (uint){
		return balanceByAd[_addr].earning;
	}
	function bookEarnings(address _addr, uint _amo){
		balanceByAd[_addr].earning -=  _amo;
	}

	function setPricePerStake(uint _price)  {
        //ToDo: vote mechanismus..  Boarddecission
        pricePerStake = _price;
    }

	//
	// The Real Token Code..
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    uint256 public totalSupply = 0;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;



	struct balance {
		uint id;
		address ad;
		uint earning;
		uint balamce;

	}	
	mapping (address  => balance) public balanceByAd;
	mapping (uint => balance) public balanceByID;
	uint userCnt=0;
	
	function updateBalance(address _addr, uint _bal){
		if(balanceByAd[_addr].id == 0){
			userCnt++;
			balanceByAd[_addr] = balance(userCnt, _addr, 0,_bal);
			balanceByID[userCnt] = balanceByAd[_addr];
		} else {
			balanceByAd[_addr].balamce = _bal;
		}
		
	}
	
	
    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    

    
    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows

        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
		updateBalance(_to,balanceOf[_to]);
		updateBalance(msg.sender,balanceOf[msg.sender]);

        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
	

}




contract Project {
	function setCompany(){
		
	}



	
}

contract SlotMachine {

	address CompanyAddress = 0;
	
	uint256 maxEinsatz = 1 ether;
	uint256 winFaktor = 2000;
	uint256 maxWin=maxEinsatz * winFaktor;
	uint public minReserve=maxWin ;
	uint public maxReserve=maxWin * 2;
	uint public sollReserve=maxWin+(maxWin * 2 / 10);
	
//1 ether * 2000 + (1 ether * 2000 *2/10)
//	uint256 percOfBuffer=100;
	
	int earnings = 0;
	uint public gamerun=0;
	uint[4] public wins;

	//Constructor
	function SlotMachine(){
		
	}
	function setCompany(){
		if(CompanyAddress != 0) throw;
		CompanyAddress=msg.sender; //Nail to Company..
	}
	
	//Load/Unload Calls for Company..
	function closeBooks() {
		if(msg.sender != CompanyAddress) throw; //Only Internal Call..
		if(earnings <= 0) throw;
		if(this.balance < maxReserve) return;
		uint inc=this.balance-maxReserve;
		bool res = Company(CompanyAddress).send(inc);
	}
	function dumpOut() {
		if(msg.sender != CompanyAddress) throw; //Only Internal Call..	
		bool result = msg.sender.send(this.balance);
	}
	
	uint _nr ;
	uint _y;
	uint _win;
	function(){
		
		if(msg.sender == CompanyAddress) {
			//just a fill up..
			return;
		}
		
		//ok here goes the game..
		uint einsatz=msg.value;
		if(einsatz * winFaktor > this.balance) throw; //cant do this game..
		
		//Play the game..
		uint nr = now; //block.number;
		uint y = nr & 3;
		
		uint win = 0;
		if(y==0) wins[0]++;
		if(y==1) {wins[1]++; win = (msg.value * 2)  + (msg.value / 2);}
		if(y==2) wins[2]++;
		
		earnings += int(msg.value);

		if(win > 0) { // half win..
			bool res = msg.sender.send(win);
			earnings -= int(win);		
		}
		gamerun++;
		_nr=nr;
		_win=win;
		_y=y;
		
		//Final.. Cleanup.. and so on..
		if(this.balance < minReserve){
			Company(CompanyAddress).requestFillUp(sollReserve-this.balance);
		}

	}
	
}


/////////////
//
// contract Globals
//
// wird in Company eingebunden..
// speichert globale Variablen..
//
contract Globals {
	MyTokenShr public myBackerToken;
    MyTokenShr public myShareToken;
		
	uint public startSlotAt = 1 ether * 2000 + (1 ether * 2000 *2/10);//100 ether; 
	
	uint BudgetSlot = 0;
	uint BudgetProject = 0;
	uint BudgetReserve = 0;
	
	uint IncomeShare =0;
	uint IncomeBacker =0;

}

/////////////
//
// contract Board
//
// wird in Company eingebunden..
// verwaltet das Board.. das Board besteht aus 3 Adressen,
// die mit einem Voting mechanismus von den ShareHolden (MyShareToken)
// gewÃÂÃÂÃÂÃÂ¤hlt und ausgetauscht werden
// 
// Board Member kÃÂÃÂÃÂÃÂ¶nnen verschiedene Tasks auslÃÂÃÂÃÂÃÂ¶sen
// und Parameter einstellen.
contract Board is Globals{
	

    address[3] public Board;
	    
    function _isBoardMember(address c) returns(bool){
        for(uint i=0;i<Board.length;i++){
            if(Board[i] == c) return true;
        }
        return false;
    }
	
	    modifier onlybyboardmember {if(_isBoardMember(tx.origin)) _ }

		// Voting Process..
	// Vote for an BoardMember,
	//
	//	   	function startBoardProposal(uint _place, address _nmbr)
	//		function killBoardProposal(uint _place, address _nmbr) 
	//		function vote(uint _place, address _nmbr, bool pro)
	//
	struct Proposal {
		address newBoardMember;
    	uint placeInBoard;
        uint givenstakes;
    	int ergebnis;
		bool active;
        mapping (address => bool)  voted;
	}
    
    Proposal[] Proposals;
		uint Abalance;
		uint Asupply ;
		bool Abmb;

    function startBoardProposal(uint _place, address _nmbr) public{

		Abalance = myShareToken.balanceOf(msg.sender);
		 Asupply = myShareToken.totalSupply();
		 Abmb = _isBoardMember(msg.sender);
		
		if(( Abalance > ( Asupply / 1000 )) || 
                _isBoardMember(msg.sender)){
                   	Proposals.push(Proposal(_nmbr, _place, 0, 0, true));
        }
    }      
	
	function killBoardProposal(uint _place, address _nmbr) public{
		if(  _isBoardMember(msg.sender)){
 			for(var i=0;i<Proposals.length;i++){
				if((Proposals[i].placeInBoard == _place) && 
			   		(Proposals[i].newBoardMember == _nmbr) ){
					delete Proposals[i];
				}
			}
	   	}
	}
     
    function voteBoardProposal(uint _place, address _nmbr, bool pro) public {
		for(var i=0;i<Proposals.length;i++){
			if((Proposals[i].placeInBoard == _place) && 
			   (Proposals[i].newBoardMember == _nmbr) && 
			   (Proposals[i].active == true) ){
				
        		if(Proposals[i].voted[msg.sender]) throw; //already voted..
        		
				Proposals[i].givenstakes += myShareToken.balanceOf(msg.sender);

				if( pro) Proposals[i].ergebnis += int(myShareToken.balanceOf(msg.sender));
														
				else Proposals[i].ergebnis -= int(myShareToken.balanceOf(msg.sender));
        		
        		Proposals[i].voted[msg.sender] = true;
       
        		//finale checks..
				if( myShareToken.totalSupply() / 2 < Proposals[i].givenstakes) { //more then 50% voted.. finish..
            		if(Proposals[i].ergebnis > 0)      { // ergebnis positiv.. tausche boardmember aus..

						Board[_place] = _nmbr;

						Proposals[i].active = false;
            		}
        		}
			}
		}
    }


}

/////////////
//
// contract SlotMachineMngr
//
// wird in Company eingebunden..
// verwaltet das SlotMachines.. 
/*	uint256 maxEinsatz = 1 ether;
	uint256 winFaktor = 2000;
	uint256 maxWin=maxEinsatz * winFaktor;
	uint public minReserve=maxWin ;
	uint public maxReserve=maxWin * 2;
	uint public sollReserve=1 ether * 2000 * 2 / 10;
*/
contract SlotMachineMngr is Board{	//
	//adding SlotMachines...
	//  and managing SlotMachines...
	address private addSlotBy = 0;
	address private newSlotAddr;
	SlotMachine[] public Slots;
	
	function _slotAddNew(address _addr) public onlybyboardmember {
		if(addSlotBy != 0) throw;
		
		if(BudgetSlot < startSlotAt) return;
				
		addSlotBy = msg.sender;
		newSlotAddr = _addr;
	}
	function _slotCommitNew(address _addr) public onlybyboardmember {
		if(msg.sender==addSlotBy) throw; //no self commit
		if(newSlotAddr != _addr) throw;
		
		SlotMachine Slot = SlotMachine(newSlotAddr);
		Slot.setCompany();
		bool res = Slot.send(startSlotAt);
		Slots.push(Slot);	
		addSlotBy = 0;		
	}
	function _slotCancelNew() public onlybyboardmember {
		addSlotBy = 0;
	}
}
/////////////
//
// contract ProjectMngr
//
// wird in Company eingebunden..
// verwaltet das Projekte..
// Projekte sind einmalige Budget Contracts die zum erledigen 
// diverser Aufgaben angelegt werden. 
contract ProjectMngr is Board {
		//
	//adding Projects...
	// 
	address private addProjectBy = 0;
	address private newProjectAddr;
	uint private newProjectBudget;
	Project[] public Projects;
	
	function _projectAddNew(address _addr, uint _budget) public onlybyboardmember {
		if(addProjectBy != 0) throw;
		
		if(BudgetProject < _budget) return;
		
		newProjectBudget = _budget;
		addProjectBy = msg.sender;
		newProjectAddr = _addr;
	}
	function _projectCommitNew(address _addr) public onlybyboardmember {
		if(msg.sender==addProjectBy) throw; //no self commit
		if(newProjectAddr != _addr) throw;
		
		Project myProject = Project(newProjectAddr);
		myProject.setCompany();
		bool res = myProject.send(newProjectBudget);
		Projects.push(myProject);	
		addProjectBy = 0;		
	}
	function _projectCancelNew() public onlybyboardmember {
		addProjectBy = 0;
	}

}

/////////////
//
// contract Company
//
contract Company  is Globals, Board, SlotMachineMngr, ProjectMngr {//, managedbycompany {

	    
	function fillUpSlot(uint _id, uint _amo){
		uint ts = _amo;
		if(ts<=BudgetSlot){BudgetSlot -= ts; ts=0;}
		else {ts -= BudgetSlot; BudgetSlot = 0;}

		if(ts>0){
			if(ts<=BudgetReserve){BudgetReserve -= ts; ts=0;}
			else {ts -= BudgetReserve; BudgetReserve = 0;}
		}
		
		if(ts>0){
			if(ts<=BudgetProject){BudgetProject -= ts; ts=0;}
			else {ts -= BudgetProject; BudgetProject = 0;}
		}
	}
	function fillUpProject(uint _id, uint _amo){
		throw; //No Refill for Project..
	}
	function requestFillUp(uint _amo){
		//From SlotMachine?
		for(uint i=0;i<Slots.length;i++){
			if(Slots[i] == msg.sender){
				fillUpSlot(i, _amo);
				return;
			}
		}
		for(uint x=0;x<Projects.length;x++){
			if(Projects[x] == msg.sender){
				fillUpProject(x, _amo);
				return;
			}
		}
	}

	// 
	// Taks fuer Initialisierung..
	//							
	function _addPools(address _backer, address _share){

		myShareToken = MyTokenShr(_share);
		myShareToken.initContract("SMShares","XXSMS", 0.1 ether, 1);

        myBackerToken = MyTokenShr(_backer);
		myBackerToken.initContract("SMBShares","XXSMBS", 12000000 ether, 1);
		
	}
	
	// 
	// Taks fuer Abrechnung..
	//							
	function _dispatchEarnings() {
		if(IncomeShare > 0) {
			myShareToken.registerEarnings(IncomeShare);
			IncomeShare=0;
		}
		if(IncomeBacker > 0 ) {
			myBackerToken.registerEarnings(IncomeBacker);
			IncomeBacker=0;
		}
	}
	
	function _closeBooks() {
		for(var i=0;i<Slots.length;i++){
			Slots[i].closeBooks();
		}
	}
	function _dumpToCompany() {
		for(var i=0;i<Slots.length;i++){
			Slots[i].dumpOut();			
		}
	}

	//
	// auszahlen
	//
	enum pool {backer_token,backer_earn, share_earn}

	function payOut(pool _what, uint _amo){
		uint earn;
		if(_what == pool.backer_token){
			 earn = myBackerToken.balanceOf(msg.sender);
			if(earn<_amo)throw;
			if(msg.sender.send(_amo)) myBackerToken.destroyToken(msg.sender,_amo);
		}
		if(_what == pool.backer_earn){
			 earn = myBackerToken.queryEarnings(msg.sender);
			if(earn<_amo)throw;
			if(msg.sender.send(_amo)) myBackerToken.bookEarnings(msg.sender, _amo);
		}
		if(_what == pool.share_earn){
			 earn = myBackerToken.queryEarnings(msg.sender);
			if(earn<_amo)throw;
			if(msg.sender.send(_amo)) myBackerToken.bookEarnings(msg.sender, _amo);
		}
		
	}
    
	//
	// Geldeingang verbuchen..
	//
    function buyShare(uint tender,bool _share){
		if(!_share)
	        myShareToken.issuetender(msg.sender,tender, msg.value);
		else
	       myBackerToken.issuetender(msg.sender,tender, msg.value);
			
		BudgetSlot += (msg.value * 90 / 100);
		BudgetProject += (msg.value * 5 / 100);
		BudgetReserve += (msg.value * 5 / 100);
    }
    function bookEarnings(){
				IncomeShare += (msg.value * 33 / 100);
				IncomeBacker += (msg.value * 33 / 100);
				BudgetSlot += (msg.value * 90 / 100 / 3);
				BudgetProject += (msg.value * 2 / 100 / 3);
				BudgetReserve += (msg.value * 2 / 100);
    }
    
	// Geldeingang ohne weitere Parameter..
	function(){ 
		for(uint i=0;i<Slots.length;i++){
			if(Slots[i] == msg.sender){
				bookEarnings();
				return;
			}
		}		
        buyShare(1, true);
    }

}

//EOF
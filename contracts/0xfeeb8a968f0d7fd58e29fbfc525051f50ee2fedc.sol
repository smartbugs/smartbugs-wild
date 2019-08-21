contract Etheramid1{
	function getParticipantById (uint id) constant public returns ( address inviter, address itself, uint totalPayout );
	function getParticipantCount () public constant returns ( uint count );
}
contract Etheramid2 {

    struct Participant {
        address inviter;
        address itself;
        uint totalPayout;
    }
    
    mapping (address => Participant) Tree;
    mapping (uint => address) Index;
	
	uint Count = 0;
    address public top;
    uint constant contribution = 1 ether;
	
 	Etheramid1 eth1 = Etheramid1(0x9758DA9B4D001Ed2d0DF46d25069Edf53750767a);
	uint oldUserCount = eth1.getParticipantCount();
	
    function Etheramid2() {
		moveOldUser(0);
		top = Index[0];
    }
    
    function() {
		throw;
    }
    
	function moveOldUser (uint id) public {
		address inviter; 
		address itself; 
		uint totalPayout;
		(inviter, itself, totalPayout) = eth1.getParticipantById(id);
		if ((Tree[itself].inviter != 0x0) || (id >= oldUserCount)) throw;
		addParticipant(inviter, itself, totalPayout);
	}
	
    function getParticipantById (uint id) constant public returns ( address inviter, address itself, uint totalPayout ){
		if (id >= Count) throw;
		address ida = Index[id];
        inviter = Tree[ida].inviter;
        itself = Tree[ida].itself;
        totalPayout = Tree[ida].totalPayout;
    }
	
	function getParticipantByAddress (address adr) constant public returns ( address inviter, address itself, uint totalPayout ){
		if (Tree[adr].itself == 0x0) throw;
        inviter = Tree[adr].inviter;
        itself = Tree[adr].itself;
        totalPayout = Tree[adr].totalPayout;
    }
    
    function addParticipant(address inviter, address itself, uint totalPayout) private{
        Index[Count] = itself;
		Tree[itself] = Participant( {itself: itself, inviter: inviter, totalPayout: totalPayout});
        Count +=1;
    }
    
    function getParticipantCount () public constant returns ( uint count ){
       count = Count;
    }
    
    function enter(address inviter) public {
        uint amount = msg.value;
        if ((amount < contribution) || (Tree[msg.sender].inviter != 0x0) || (Tree[inviter].inviter == 0x0)) {
            msg.sender.send(msg.value);
            throw;
        }
        
        addParticipant(inviter, msg.sender, 0);
        address next = inviter;
        uint rest = amount;
        uint level = 1;
        while ( (next != top) && (level < 7) ){
            uint toSend = rest/2;
            next.send(toSend);
            Tree[next].totalPayout += toSend;
            rest -= toSend;
            next = Tree[next].inviter;
            level++;
        }
        next.send(rest);
		Tree[next].totalPayout += rest;
    }
}
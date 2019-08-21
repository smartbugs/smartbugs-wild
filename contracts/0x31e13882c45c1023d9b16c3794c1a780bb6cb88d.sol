//                       , ; ,   .-'"""'-.   , ; ,
//                       \\|/  .'         '.  \|//
//                        \-;-/   ()   ()   \-;-/
//                        // ;               ; \\
//                       //__; :.         .; ;__\\
//                      `-----\'.'-.....-'.'/-----'
//                             '.'.-.-,_.'.'
//                               '(  (..-'
//                                 '-'
//   WHYSOS3RIOUS   PRESENTS :                          
//                                                                
//   MATCHING ETHERS                              
//   a Strategy and Luck DaapGame          
//   www.matching-ethers.com                 
//
//
// *** coded by WhySoS3rious, 2016.                                       ***//
// *** please do not copy without authorization                       ***//
// *** contact : reddit    /u/WhySoS3rious                                ***//

//VERSION : 1.0

// GAME MODE : MATCHING ETHERS
// STAKE : 1 ETH

 contract Matching_Ethers
{
    enum State{Active, Deactivated}
    State public state;

    modifier onlyOwner() {
	    if (msg.sender!=owner) throw;
	    _
    }
    modifier onlyActive() {
         if (state!=State.Active) throw;
         _
    }
    modifier onlyInactive() {
         if (state!=State.Deactivated) throw;
         _
    }
    modifier equalGambleValue() {
	if (msg.value < gamble_value) throw;
        if (msg.value > gamble_value) msg.sender.send(msg.value-gamble_value);
	_
    }
    modifier resolvePendingRound{
        blockLastPlayer=block.number+1;    
        if (pendingRound && blockLastPlayer!=blockEndRound ) endRound();
	else if (pendingRound && blockLastPlayer==blockEndRound) throw;
	_
    }

    uint blockLastPlayer;
    address private owner;
    uint gamble_value;
    uint information_cost;
    uint round_max_size ;
    uint round_min_size  ;  
    uint index_player;
    uint index_round_ended;
    uint index_player_in_round;
    bool pendingRound = false;
    uint blockEndRound;
    struct Gamble  {
	    address player;
	    bool flipped;
    }
    Gamble[] matchers; 
    Gamble[] contrarians;
    struct Result  {
	    address player_matcher;
	    bool flipped_matcher;
	    uint256 payout_matcher;
	    address player_contrarian;
	    bool flipped_contrarian;
	    uint256 payout_contrarian;
    }
    Result[] results; 
    mapping (address => uint) payout_history;
    mapping (address => uint) times_played_history;    
     
    //Contract Construtor
    function Matching_Ethers() { //Initial settings
	    owner = msg.sender; 
	    round_min_size = 16;
	    round_max_size = 20;
	    information_cost= 5000 szabo; //0.005 ether, 5 finney
            gamble_value = 1000000 szabo; //1 ether
    }
    //FallBack Function (play by sending a transaction)
    function () { 
        bool flipped;
        if (msg.value == gamble_value) flipped=false; 
        if (msg.value > gamble_value) {
            flipped=true;
        }
        Play(flipped); 
    }
    //Play Function (play by contract function call)
    function Play(bool flipped) equalGambleValue onlyActive resolvePendingRound{
        if ( index_player_in_round%2==0 ) {   //first is matcher
	    matchers.push(Gamble(msg.sender, flipped));
	}
	else {
	    contrarians.push(Gamble(msg.sender, flipped));
	}
        index_player+=1;
        index_player_in_round+=1;
	times_played_history[msg.sender]+=1;
        if (index_player_in_round>=round_min_size && index_player_in_round%2==0) {
	            bool end = randomEnd();
		    if (end) {
		        pendingRound=true;
			blockEndRound=block.number;}
        }
    }
    //Random Number Generator (between 1 and range)
    function randomGen(uint seed, uint range) private constant returns (uint randomNumber) {
        return(uint(sha3(block.blockhash(block.number-1), seed))%range+1);
    }
    //Function that determines randomly when the round should be ended
    function randomEnd() private returns(bool) {
	if (index_player_in_round==round_max_size) return true; //end if max_size
	else{
	    uint random = randomGen(index_player, (round_max_size-index_player_in_round)/2+1);
	    if (random==1) return true;
	    else return false;
	    }
    }
    //Function to end Round and pay winners
    function endRound() private {
        delete results;
        uint256 random_start_contrarian = randomGen(index_player,(index_player_in_round)/2)-1;
        uint256 payout_total;
        for (var k = 0; k < (index_player_in_round)/2; k++) {
            uint256 index_contrarian;
	    if (k+random_start_contrarian<(index_player_in_round)/2){
	        index_contrarian=k+random_start_contrarian;
            }
	    else{
	        index_contrarian=(k+random_start_contrarian)-(index_player_in_round/2);
	    }
	    uint256 information_cost_matcher = information_cost * k;
	    uint256 payout_matcher = 2*(gamble_value-information_cost_matcher);
	    uint256 information_cost_contrarian = information_cost * index_contrarian;
	    uint256 payout_contrarian = 2*(gamble_value-information_cost_contrarian);
	    results.push(Result(matchers[k].player,matchers[k].flipped,payout_matcher,contrarians[index_contrarian].player,contrarians[index_contrarian].flipped, payout_contrarian));
	    if (matchers[k].flipped == contrarians[index_contrarian].flipped) {
	        matchers[k].player.send(payout_matcher);
		payout_total+=payout_matcher;
		payout_history[matchers[k].player]+=payout_matcher;
	    }
	    else {
	        contrarians[index_contrarian].player.send(payout_contrarian);
		payout_total+=payout_contrarian;
		payout_history[contrarians[k].player]+=payout_contrarian;
	    }
	}
        index_round_ended+=1;
        owner.send(index_player_in_round*gamble_value-payout_total);
	payout_total=0;
        index_player_in_round=0;
        delete matchers;
        delete contrarians;
	pendingRound=false;
	if (terminate_after_round==true) state=State.Deactivated;
    }
    //Full Refund of Current Round (if needed)
    function refundRound() 
    onlyActive
    onlyOwner noEthSent{  
        uint totalRefund;
	uint balanceBeforeRefund=this.balance;
        for (var k = 0;  k< matchers.length; k++) {
	            matchers[k].player.send(gamble_value);
		    totalRefund+=gamble_value;
        }
        for (var j = 0;  j< contrarians.length ; j++) {	
	            contrarians[j].player.send(gamble_value);
		    totalRefund+=gamble_value;		    
        }
	delete matchers;
	delete contrarians;
	state=State.Deactivated;
	index_player_in_round=0;
        uint balanceLeft = balanceBeforeRefund-totalRefund;
	if (balanceLeft >0) owner.send(balanceLeft);
    }
    //Function Pause contract after next round (for new contract or to change settings) 
    bool terminate_after_round=false;
    function deactivate()
    onlyOwner noEthSent{
	    terminate_after_round=true;
    }
    //Function Reactivates contract (after change of settings for instance or a refound)
    function reactivate()
    onlyOwner noEthSent{
        state=State.Active;
        terminate_after_round=false;
    }
    //Function to change game settings (within limits)
    //(to adapt to community feedback, popularity)
    function config(uint new_max_round, uint new_min_round, uint new_information_cost, uint new_gamble_value)
	    onlyOwner
	    onlyInactive noEthSent{
	    if (new_max_round<new_min_round) throw;
	    if (new_information_cost > new_gamble_value/100) throw;
	    round_max_size = new_max_round;
	    round_min_size = new_min_round;
	    information_cost= new_information_cost;
	    gamble_value = new_gamble_value;
    }
    function changeOwner(address new_owner)
	    onlyOwner noEthSent{
	    owner=new_owner;
    }
    

    modifier noEthSent(){
        if (msg.value>0) throw;
	_
    }
    //JSON GLOBAL STATS
    function gameStats() noEthSent constant returns (uint number_of_player_in_round, uint total_number_of_player, uint number_of_round_ended, bool pending_round_to_resolve, uint block_end_last_round, uint block_last_player, State state, bool pause_contract_after_round)
    {
         number_of_player_in_round = index_player_in_round;
	 total_number_of_player = index_player;
	 number_of_round_ended = index_round_ended;
	 pending_round_to_resolve = pendingRound;
	 block_end_last_round = blockEndRound;
	 block_last_player = blockLastPlayer;
	 state = state;
	 pause_contract_after_round = terminate_after_round;
     }
     //JSON CURRENT SETTINGS
     function gameSettings() noEthSent constant returns (uint _gamble_value, uint _information_cost, uint _round_min_size, uint _round_max_size) {
	 _gamble_value = gamble_value;
	 _information_cost = information_cost;
	 _round_min_size = round_min_size;
	 _round_max_size = round_max_size;
     }

    //JSON MATCHER TEAM
    function getMatchers_by_index(uint _index) noEthSent constant returns (address _address, bool _flipped) {
        _address=matchers[_index].player;
	_flipped = matchers[_index].flipped;
    }
    //JSON CONTRARIAN TEAM
    function getContrarians_by_index(uint _index) noEthSent constant returns (address _address, bool _flipped) {
        _address=contrarians[_index].player;
	_flipped = contrarians[_index].flipped;
    }
    //JSON LAST ROUND RESULT
    function getLastRoundResults_by_index(uint _index) noEthSent constant returns (address _address_matcher, address _address_contrarian, bool _flipped_matcher, bool _flipped_contrarian, uint _payout_matcher, uint _payout_contrarian) {
        _address_matcher=results[_index].player_matcher;
        _address_contrarian=results[_index].player_contrarian;
	_flipped_matcher = results[_index].flipped_matcher;
	_flipped_contrarian = results[_index].flipped_contrarian;
	_payout_matcher =  results[_index].payout_matcher;
	_payout_contrarian =  results[_index].payout_contrarian;
    }
    //User set nickname for the website
     mapping (address => string) nicknames;
     function setNickname(string name) noEthSent{
         if (bytes(name).length >= 2 && bytes(name).length <= 16)
             nicknames[msg.sender] = name;
     }
     function getNickname(address _address) noEthSent constant returns(string _name) {
             _name = nicknames[_address];
     }
     //JSON HISTORY
     function historyPayout(address _address) noEthSent constant returns(uint _payout) {
             _payout = payout_history[_address]; 
     }
     function historyTimesPlayed(address _address) noEthSent constant returns(uint _count) {
             _count = times_played_history[_address]; 
     }

}
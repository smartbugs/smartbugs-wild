pragma solidity ^0.4.8;

contract SmartRouletteToken {
	//Tokens data
	string public standard = 'ERC20';
    string public name;
    string public symbol;
    uint8 public decimals;

	struct holderData {
		uint256 tokens_count;
		bool init;
	}

	struct tempHolderData {
		uint256 tokens_count;
		uint256 start_date;
		uint256 end_date;
	}

	address[] listAddrHolders;

	mapping( address => holderData ) _balances;
	mapping( address => tempHolderData ) _temp_balance;
	mapping( address => mapping( address => uint256 ) ) _approvals;

	bool stop_operation;
	
	uint256 _supply;
	uint256 _init_count_tokens;
	uint256 public costOfOneToken; //the cost of one token in wei
	
	address wallet_ICO;
	bool enableICO;
	uint256 min_value_buyToken; //in wei
	uint256 max_value_buyToken; //in wei

	address fond_wallet;
	address developer_wallet;

	address divident_contract = address(0x0);
	
	event TokenBuy(address buyer, uint256 amountOfTokens);

    //Contract data
	address developer;
	address manager;

	struct gamesData {
		bool init;
	}

	mapping( address => gamesData) listGames;
	address[] addrGames;


	function SmartRouletteToken()
	{
		_supply = 100000000000000000;
		_init_count_tokens = 100000000000000000;

		developer_wallet = address(0x8521E1f9220A251dE0ab78f6a2E8754Ca9E75242);
		_balances[developer_wallet] = holderData((_supply*20)/100, true);
		
		wallet_ICO = address(0x2dff87f8892d65f7a97b1287e795405098ae7b7f);
		_balances[wallet_ICO] = holderData((_supply*60)/100, true);
		
		fond_wallet = address(0x3501DD2B515EDC1920f9007782Da5ac018922502);
		_balances[fond_wallet] = holderData((_supply*20)/100, true);
		
		listAddrHolders.push(developer_wallet);
		listAddrHolders.push(wallet_ICO);
		listAddrHolders.push(fond_wallet);
        
        name = 'Roulette Token';                                   
        symbol = 'RLT';                               
        decimals = 10;
        costOfOneToken = 1500000000000000;

		developer = msg.sender;
		manager = msg.sender;		
		
		enableICO = false;
		min_value_buyToken = 1000000000000000000;
		max_value_buyToken = 500000000000000000000;

		stop_operation = false;
	}

	modifier isDeveloper(){
		if (msg.sender!=developer) throw;
		_;
	}

	modifier isManager(){
		if (msg.sender!=manager && msg.sender!=developer) throw;
		_;
	}

	modifier isAccessStopOperation(){
		if (msg.sender!=manager && msg.sender!=developer && (msg.sender!=divident_contract || divident_contract==address(0x0))) throw;
		_;
	}

	function changeDeveloper(address new_developer)
	isDeveloper
	{
		if(new_developer == address(0x0)) throw;
		developer = new_developer;
	}

	function changeManager(address new_manager)
	isDeveloper
	{
		if(new_manager == address(0x0)) throw;
		manager = new_manager;
	}

	function changeDividentContract(address new_contract) isManager
	{
		if(divident_contract!=address(0x0)) throw;
		if(divident_contract==address(0x0)) throw;
		divident_contract = new_contract;
	}

	function newCostToken(uint256 new_cost)
	isManager
	{
		if(new_cost == 0) throw;
		costOfOneToken = new_cost;
	}

	function getostToken() external constant returns(uint256)
	{
		return costOfOneToken;
	}

	function addNewGame(address new_game)
	isManager
	{
		if(new_game == address(0x0)) throw;
		listGames[new_game] = gamesData(true);
		addrGames.push(new_game);
	}

	function deleteGame(address game)
	isManager
	{
		if(game == address(0x0)) throw;
		if(listGames[game].init){
			listGames[game].init = false;
		}
	}

	function kill() isDeveloper {
		suicide(developer);
	}

	function addUserToList(address user) internal {
		if(!_balances[user].init){
			listAddrHolders.push(user);
		}
	}

	function gameListOf( address who ) external constant returns (bool value) {
		gamesData game_data = listGames[who];
		return game_data.init;
	}

	//------------------------------------
	// Tokens Functions
	//------------------------------------
	event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function stopOperation() isAccessStopOperation {
		stop_operation = true;
	}

	function startOperation() isAccessStopOperation {
		stop_operation = false;
	}

	function isOperationBlocked() external constant returns (bool){
		return stop_operation;
	}

	function runICO() isManager {
		enableICO = true;
	}

	function stopICO() isManager {
		enableICO = false;
	}

	function infoICO() constant returns (bool){
		return enableICO;
	}

	function totalSupply() constant returns (uint256 supply) {
		return _supply;
	}

	function initCountTokens() constant returns (uint256 init_count) {
		return _init_count_tokens;
	}

	function balanceOf( address who ) external constant returns (uint256 value) {
		return _balances[who].tokens_count;
	}

	function allowance(address owner, address spender) constant returns (uint256 _allowance) {
		return _approvals[owner][spender];
	}

	// overflow check
	function safeToAdd(uint256 a, uint256 b) internal returns (bool) {
		return (a + b >= a && a + b >= b);
	}

	function transfer( address to, uint256 value) returns (bool ok) {
		if(stop_operation) throw;

		if( _balances[msg.sender].tokens_count < value ) {
		    throw;
		}
		if( !safeToAdd(_balances[to].tokens_count, value) ) {
		    throw;
		}

		_balances[msg.sender].tokens_count -= value;
		if(_balances[to].init){
			_balances[to].tokens_count += value;
		}
		else{
			addUserToList(to);
			_balances[to] = holderData(value, true);
		}

		Transfer( msg.sender, to, value );
		return true;
	}

	function transferFrom( address from, address to, uint256 value) returns (bool ok) {
		if(stop_operation) throw;

		if( _balances[from].tokens_count < value ) {
		    throw;
		}
		
		if( _approvals[from][msg.sender] < value ) {
		    throw;
		}
		if( !safeToAdd(_balances[to].tokens_count, value) ) {
		    throw;
		}
		// transfer and return true
		_approvals[from][msg.sender] -= value;
		_balances[from].tokens_count -= value;
		if(_balances[to].init){
			_balances[to].tokens_count += value;
		}
		else{
			addUserToList(to);
			_balances[to] = holderData(value, true);
		}		
		
		Transfer( from, to, value );
		return true;
	}

	function approve(address spender, uint256 value) returns (bool ok) {
		if(stop_operation) throw;

		_approvals[msg.sender][spender] = value;
		Approval( msg.sender, spender, value );
		return true;
	}

	event Emission(address indexed to, uint256 value, uint256 bet, uint256 coef, uint256 decimals, uint256 cost_token);

	function emission(address player, address partner, uint256 value_bet, uint16 coef_player, uint16 coef_partner) external returns(uint256) {
		if(stop_operation) throw;

		if(listGames[msg.sender].init == false) throw;
		if(player == address(0x0)) throw;
		if(value_bet == 0) throw;

		uint256 decimals_token = 10**uint256(decimals);

		uint256 player_token = ((value_bet*coef_player*decimals_token)/10000)/costOfOneToken;
		if(_balances[player].init){
			_balances[player].tokens_count += player_token;
		}
		else{
			addUserToList(player);
			_balances[player] = holderData(player_token, true);
		}
		Emission(player, player_token, value_bet, coef_player, decimals_token, costOfOneToken);

		uint256 partner_token = 0;
		if(partner != address(0x0)){
			partner_token = ((value_bet*coef_partner*decimals_token)/10000)/costOfOneToken;
			if(_balances[partner].init){
				_balances[partner].tokens_count += partner_token;
			}
			else{
				addUserToList(partner);
				_balances[partner] = holderData(partner_token, true);
			}
			Emission(partner, partner_token, value_bet, coef_partner, decimals_token, costOfOneToken);
		}

		_supply += (player_token+partner_token);

		return player_token;
	}

	//------------------------------------
	// Temporary Tokens
	//------------------------------------
	address[] listAddrTempHolders;
	event TempTokensSend(address indexed recipient, uint256 count, uint256 start, uint256 end);

	function sendTempTokens(address recipient, uint256 count, uint256 period) isManager {
		if(stop_operation) throw;

		if(count==0 || period==0) throw;
		
		uint256 decimals_token = 10**uint256(decimals);
		count = count*decimals_token;

		if(_balances[fond_wallet].tokens_count < count) throw;
		if(_temp_balance[recipient].tokens_count > 0) throw;

		_temp_balance[recipient] = tempHolderData(count, now, now + period);
		listAddrTempHolders.push(recipient);
		_balances[fond_wallet].tokens_count -= count;
		TempTokensSend(recipient, count, _temp_balance[recipient].start_date, _temp_balance[recipient].end_date);
	}

	function tempTokensBalanceOf( address who ) external constant returns (uint256) {
		//tempHolderData data_holder = __temp_balance[who];
		if(_temp_balance[who].end_date < now) return 0;
		else return _temp_balance[who].tokens_count;
	}

	function tempTokensPeriodOf( address who ) external constant returns (uint256) {
		if(_temp_balance[who].end_date < now) return 0;
		else return _temp_balance[who].end_date;
	}

	function returnTempTokens(address recipient) isManager {
		if(stop_operation) throw;
		
		if(_temp_balance[recipient].tokens_count == 0) throw;

		_balances[fond_wallet].tokens_count += _temp_balance[recipient].tokens_count;
		_temp_balance[recipient] = tempHolderData(0, 0, 0);		
	}

	function getListTempHolders() constant returns(address[]){
		return listAddrTempHolders;
	}

	function getCountTempHolders() external constant returns(uint256){
		return listAddrTempHolders.length;
	}

	function getItemTempHolders(uint256 index) external constant returns(address){
		if(index >= listAddrTempHolders.length) return address(0x0);
		else return listAddrTempHolders[index];
	}

	//------------------------------------
	// Invest Functions
	//------------------------------------
	/*event SuccessProfitSend(address indexed holder, uint value);
	event FailProfitSend(address indexed holder, uint value);*/

	function() payable
	{	
		if(stop_operation) throw;
		if(msg.sender == developer) throw;
		if(msg.sender == manager) throw;
		if(msg.sender == developer_wallet) throw;
		if(msg.sender == wallet_ICO) throw;
		if(msg.sender == fond_wallet) throw;

		if(listGames[msg.sender].init) throw;

		if(enableICO == false) throw;
			
		if(msg.value < min_value_buyToken) throw;
		
		uint256 value_send = msg.value;
		if(value_send > max_value_buyToken){
			value_send = max_value_buyToken;
			if(msg.sender.send(msg.value-max_value_buyToken)==false) throw;
		}

		uint256 decimals_token = 10**uint256(decimals);
		
		uint256 count_tokens = (value_send*decimals_token)/costOfOneToken;
		
		if(count_tokens >_balances[wallet_ICO].tokens_count ){
			count_tokens = _balances[wallet_ICO].tokens_count;
		}
		if(value_send > (count_tokens*costOfOneToken)/decimals_token){				
			if(msg.sender.send(value_send-((count_tokens*costOfOneToken)/decimals_token))==false) throw;
			value_send = (count_tokens*costOfOneToken)/decimals_token;
		}

		if(!_balances[msg.sender].init){
			addUserToList(msg.sender);
			_balances[wallet_ICO].tokens_count -= count_tokens;			
			_balances[msg.sender] = holderData(count_tokens, true);
		}
		else{
			if(((_balances[msg.sender].tokens_count*costOfOneToken)/decimals_token)+((count_tokens*costOfOneToken)/decimals_token)>max_value_buyToken) {
				count_tokens = ((max_value_buyToken*decimals_token)/costOfOneToken)-_balances[msg.sender].tokens_count;					
				if(msg.sender.send(value_send-((count_tokens*costOfOneToken)/decimals_token))==false) throw;
				value_send = (count_tokens*costOfOneToken)/decimals_token;
			}

			_balances[wallet_ICO].tokens_count -= count_tokens;
			_balances[msg.sender].tokens_count += count_tokens;
		}

		if(value_send>0){
			if(wallet_ICO.send(value_send)==false) throw;
		}

		if(count_tokens>0){
			TokenBuy(msg.sender, count_tokens);
		}

		if(_balances[wallet_ICO].tokens_count == 0){
			enableICO = false;
		}
	}

	function getListAddressHolders() constant returns(address[]){
		return listAddrHolders;
	}

	function getCountHolders() external constant returns(uint256){
		return listAddrHolders.length;
	}

	function getItemHolders(uint256 index) external constant returns(address){
		if(index >= listAddrHolders.length) return address(0x0);
		else return listAddrHolders[index];
	}
}
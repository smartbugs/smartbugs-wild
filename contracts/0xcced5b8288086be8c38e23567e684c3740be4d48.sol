pragma solidity ^0.4.8;

contract OldSmartRouletteToken
{
	function balanceOf( address who ) external constant returns (uint256);
	function totalSupply() constant returns (uint supply);
	function tempTokensBalanceOf( address who ) external constant returns (uint256);
	function tempTokensPeriodOf( address who ) external constant returns (uint256);
	function getCountHolders() external constant returns(uint256);
	function getCountTempHolders() external constant returns(uint256);
	function getItemHolders(uint256 index) external constant returns(address);
	function getItemTempHolders(uint256 index) external constant returns(address);
	function isOperationBlocked() external constant returns (bool);
}

contract SmartRouletteToken {
	string public standard = 'ERC20';
    string public name; // token name
    string public symbol; // token symbol
    uint8 public decimals; // a number of symbols after comma

	struct holderData {
		/**
		*	Token holders details
		*/
		uint256 tokens_count;
		bool init;
	}

	struct tempHolderData {
		/**
		*	Temporary token holders details
		*/
		uint256 tokens_count;
		uint256 start_date;
		uint256 end_date;
		bool init;
	}

	address[] listAddrHolders; // permanent token holders list

	mapping( address => holderData ) _balances; // token ownership
	mapping( address => tempHolderData ) _temp_balance; // temporary token ownership
	mapping( address => mapping( address => uint256 ) ) _approvals; // token transfer right

	bool stop_operation; // transaction stop
	
	uint256 _supply; // total amount of tokens
	uint256 _init_count_tokens; // initial amount of tokens
	uint256 public costOfOneToken; // token price equivalent to wei
	
	address wallet_ICO;
	bool enableICO; // ico status (launched or not)
	uint256 min_value_buyToken; //in wei
	uint256 max_value_buyToken; //in wei

	address fond_wallet;
	address developer_wallet;

	address divident_contract = address(0x0);
	
	event TokenBuy(address buyer, uint256 amountOfTokens);

	// emission limits
	uint256 max_value_bet; // maximum size of bet for emission
	uint256 max_coef_player; // maximum size of emission coefficient for a player
	uint256 max_coef_partner; // maximum size of emission coefficient for an affiliate


	address developer; // developer's address
	address manager; // contract managing address (management can be made from the smart contract)

	struct gamesData {
		bool init;
	}

	mapping( address => gamesData) listGames; // List of allowed games
	address[] addrGames;

	//old token contract for data restorage
	OldSmartRouletteToken oldSmartToken;

	uint256 countHoldersTransferredFromOldContract; //amount of permanent token holders whose balance has been restored
	uint256 countHoldersTempTransferredFromOldContract; //amount of temporary token holders whose balance has been restored

	function SmartRouletteToken()
	{
		_init_count_tokens = 100000000000000000;
		developer_wallet = address(0x8521E1f9220A251dE0ab78f6a2E8754Ca9E75242);
		wallet_ICO = address(0x2dff87f8892d65f7a97b1287e795405098ae7b7f);
		fond_wallet = address(0x3501DD2B515EDC1920f9007782Da5ac018922502);

        name = 'Roulette Token';                                   
        symbol = 'RLT';                               
        decimals = 10;
        costOfOneToken = 1500000000000000;

		max_value_bet = 2560000000000000000;
		max_coef_player = 300;
		max_coef_partner = 50;

		developer = msg.sender;
		manager = msg.sender;		
		
		enableICO = false;
		min_value_buyToken = 150000000000000000;
		max_value_buyToken = 500000000000000000000;

		stop_operation = false;

		oldSmartToken = OldSmartRouletteToken(0x2a650356bd894370cc1d6aba71b36c0ad6b3dc18);
		countHoldersTransferredFromOldContract= 0;
		countHoldersTempTransferredFromOldContract = 0;
	}

	modifier isDeveloper(){
		if (msg.sender!=developer) throw;
		_;
	}

	modifier isManager(){
		if (msg.sender!=manager) throw;
		_;
	}

	modifier isAccessStopOperation(){
		if (msg.sender!=manager && msg.sender!=developer && (msg.sender!=divident_contract || divident_contract==address(0x0))) throw;
		_;
	}

	function IsTransferFromOldContractDone() constant returns(bool)
	{
		return countHoldersTransferredFromOldContract == oldSmartToken.getCountHolders();
	}

	/**
    *	restoreAllPersistentTokens() - function of restoring the balance of permanent token holders. Once the function has been completed,
    *	blockchain saves the index with which token holders addresses will start being received during the following function operation.
    *
    *	@param limit - amount of token holders addresses requiring the balance restorage.
    *
    **/
	function restoreAllPersistentTokens(uint256 limit)
	{
		if(oldSmartToken.isOperationBlocked() && this.isOperationBlocked())
		{
			uint256 len = oldSmartToken.getCountHolders();
			uint256 i = countHoldersTransferredFromOldContract;
			for(; i < len; i++)
			{
				address holder = oldSmartToken.getItemHolders(i);
				uint256 count_tokens = oldSmartToken.balanceOf(holder);
				if(holder == address(0x2a650356bd894370cc1d6aba71b36c0ad6b3dc18)) {
					if(!_balances[fond_wallet].init){
						addUserToList(fond_wallet);
						_balances[fond_wallet] = holderData(count_tokens, true);
					}
					else{
						_balances[fond_wallet].tokens_count += count_tokens;
					}
				}
				else{
					addUserToList(holder);
					_balances[holder] = holderData(count_tokens, true);
				}

				_supply += count_tokens;

				if (limit - 1 == 0) break;
				limit--;
			}
			countHoldersTransferredFromOldContract = i;
		}
	}

	function IsTransferTempFromOldContractDone() constant returns(bool)
	{
		return countHoldersTempTransferredFromOldContract == oldSmartToken.getCountTempHolders();
	}

	/**
    *	restoreAllTempTokens() - function of temnporary token balance restorage. Once the function has been completed,
    *	blockchain saves the index with which temporary token holders addresses will start being received during the following function operation.
    *
    *	@param limit - amount of token holders addresses requiring the balance restorage.
    *
    **/
	function restoreAllTempTokens(uint256 limit)
	{
		if(oldSmartToken.isOperationBlocked() && this.isOperationBlocked())
		{
			uint256 len = oldSmartToken.getCountTempHolders();
			uint256 i = countHoldersTempTransferredFromOldContract;
			for(; i < len; i++)
			{
				address holder = oldSmartToken.getItemTempHolders(i);
				uint256 count_tokens = oldSmartToken.tempTokensBalanceOf(holder);

				if(holder == address(0x2a650356bd894370cc1d6aba71b36c0ad6b3dc18)) {
					if(!_balances[fond_wallet].init){
						_balances[fond_wallet] = holderData(count_tokens, true);
						addUserToList(fond_wallet);
					}
					else{
						_balances[fond_wallet].tokens_count += count_tokens;
					}
				}
				else{
					listAddrTempHolders.push(holder);
					uint256 end_date = oldSmartToken.tempTokensPeriodOf(holder);
					_temp_balance[holder] = tempHolderData(count_tokens, now, end_date, true);
				}

				_supply += count_tokens;

				if (limit - 1 == 0) break;
				limit--;
			}
			countHoldersTempTransferredFromOldContract = i;
		}
	}


	function changeDeveloper(address new_developer) isDeveloper
	{
		if(new_developer == address(0x0)) throw;
		developer = new_developer;
	}

	function changeManager(address new_manager) isManager external
	{
		if(new_manager == address(0x0)) throw;
		manager = new_manager;
	}

	function changeMaxValueBetForEmission(uint256 new_value) isManager external
	{
		if(new_value == 0) throw;
		max_value_bet = new_value;
	}

	function changeMaxCoefPlayerForEmission(uint256 new_value) isManager external
	{
		if(new_value > 1000) throw;
		max_coef_player = new_value;
	}

	function changeMaxCoefPartnerForEmission(uint256 new_value) isManager external
	{
		if(new_value > 1000) throw;
		max_coef_partner = new_value;
	}

	function changeDividentContract(address new_contract) isManager external
	{
		if(new_contract!=address(0x0)) throw;
		divident_contract = new_contract;
	}

	function newCostToken(uint256 new_cost)	isManager external
	{
		if(new_cost == 0) throw;
		costOfOneToken = new_cost;
	}

	function getCostToken() external constant returns(uint256)
	{
		return costOfOneToken;
	}

	function addNewGame(address new_game) isManager external
	{
		if(new_game == address(0x0)) throw;
		listGames[new_game] = gamesData(true);
		addrGames.push(new_game);
	}

	function deleteGame(address game) isManager external
	{
		if(game == address(0x0)) throw;
		if(listGames[game].init){
			listGames[game].init = false;
		}
	}

	function addUserToList(address user) internal {
		if(!_balances[user].init){
			listAddrHolders.push(user);
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

	function gameListOf( address who ) external constant returns (bool value) {
		gamesData game_data = listGames[who];
		return game_data.init;
	}

	//------------------------------------
	// Tokens Functions
	//------------------------------------
	event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function stopOperation() isManager external {
		stop_operation = true;
	}

	function startOperation() isManager external {
		stop_operation = false;
	}

	function isOperationBlocked() external constant returns (bool){
		return stop_operation;
	}

	function isOperationAllowed() external constant returns (bool){
		return !stop_operation;
	}

	function runICO() isManager external {
		enableICO = true;
		stop_operation = true;
	}

	function stopICO() isManager external {
		enableICO = false;
		stop_operation = false;
	}

	function infoICO() constant returns (bool){
		return enableICO;
	}

	function totalSupply() external constant returns (uint256 supply) {
		return _supply;
	}

	function initCountTokens() external constant returns (uint256 init_count) {
		return _init_count_tokens;
	}

	/**
    *  balanceOf() - constant function check concrete tokens balance
    *
    *  @param who - account owner
    *
    *  @return the value of balance
    */
	function balanceOf( address who ) external constant returns (uint256 value) {
		return _balances[who].tokens_count;
	}

	/**
    *
    * allowance() - constant function to check how much is
    *               permitted to spend to 3rd person from owner balance
    *
    *  @param owner   - owner of the balance
    *  @param spender - permitted to spend from this balance person
    *
    *  @return - remaining right to spend
    *
    */
	function allowance(address owner, address spender) constant returns (uint256 _allowance) {
		return _approvals[owner][spender];
	}


	function safeToAdd(uint256 a, uint256 b) internal returns (bool) {
		// overflow check
		return (a + b >= a && a + b >= b);
	}

	/**
    * transfer() - transfer tokens from msg.sender balance
    *              to requested account
    *
    *  @param to    - target address to transfer tokens
    *  @param value - ammount of tokens to transfer
    *
    *  @return - success / failure of the transaction
    */
	function transfer( address to, uint256 value) returns (bool ok) {
		if(this.isOperationBlocked()) throw;

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

	/**
    * transferFrom() - used to move allowed funds from other owner
    *                  account
    *
    *  @param from  - move funds from account
    *  @param to    - move funds to account
    *  @param value - move the value
    *
    *  @return - return true on success false otherwise
    */
	function transferFrom( address from, address to, uint256 value) returns (bool ok) 
	{
		if(this.isOperationBlocked()) throw;

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

	/**
     *
     * approve() - function approves to a person to spend some tokens from
     *           owner balance.
     *
     *  @param spender - person whom this right been granted.
     *  @param value   - value to spend.
     *
     *  @return true in case of success, otherwise failure
     *
     */
	function approve(address spender, uint256 value) returns (bool ok) 
	{
		if(this.isOperationBlocked()) throw;

		_approvals[msg.sender][spender] = value;
		Approval( msg.sender, spender, value );
		return true;
	}

	event Emission(address indexed to, uint256 value, uint256 bet, uint256 coef, uint256 decimals, uint256 cost_token);

	/**
    *
    *  emission() - emission of tokens initiated by the game contract.
    *
    *  @param player       - player's address.
    *  @param partner      - affiliate's address.
    *  @param value_bet    - player's bet value.
    *  @param coef_player  - player's coefficient emission.
    *  @param coef_partner - affiliate's coefficient emission.
    *
    *  @return (true, 0) in case of success, otherwise (False, error_code)
    *
    *
    *  Error code 1 - operation stoped
    *  Error code 2 - sender address is not in games list
    *  Error code 3 - incorrect player's address
    *  Error code 4 - incorrect value bet
    *  Error code 5 - incorrect emission coefficient
    */
	function emission(address player, address partner, uint256 value_bet, uint256 coef_player, uint256 coef_partner) external returns(uint256, uint8) {
        if(this.isOperationBlocked()) return (0, 1);

        if(listGames[msg.sender].init == false) return (0, 2);
        if(player == address(0x0)) return (0, 3);
        if(value_bet == 0 || value_bet > max_value_bet) return (0, 4);
        if(coef_player > max_coef_player || coef_partner > max_coef_partner) return (0, 5);

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

		return (player_token, 0);
	}

	//------------------------------------
	// Temporary Tokens
	//------------------------------------
	address[] listAddrTempHolders;
	event TempTokensSend(address indexed recipient, uint256 count, uint256 start, uint256 end);

	/**
     *
     *  sendTempTokens() - sending temporary tokens to address.
     *
     *  @param recipient - recipient's address.
     *  @param count     - temporary tokens amount.
     *  @param period    - period of possession of the tokens in seconds.
     *
     */
	function sendTempTokens(address recipient, uint256 count, uint256 period) isDeveloper {
		if(this.isOperationBlocked()) throw;

		if(count==0 || period==0) throw;
		
		uint256 decimals_token = 10**uint256(decimals);
		count = count*decimals_token;

		if(_balances[fond_wallet].tokens_count < count) throw;
		if(_temp_balance[recipient].tokens_count > 0) throw;

		if(!_temp_balance[recipient].init){
			_temp_balance[recipient] = tempHolderData(count, now, now + period, true);
			listAddrTempHolders.push(recipient);
		}
		else{
			_temp_balance[recipient].tokens_count = count;
			_temp_balance[recipient].start_date = now;
			_temp_balance[recipient].end_date = now + period;
		}
		_balances[fond_wallet].tokens_count -= count;
		TempTokensSend(recipient, count, _temp_balance[recipient].start_date, _temp_balance[recipient].end_date);
	}

	function tempTokensBalanceOf( address who ) external constant returns (uint256) {
		if(_temp_balance[who].end_date < now) return 0;
		else return _temp_balance[who].tokens_count;
	}

	function tempTokensPeriodOf( address who ) external constant returns (uint256) {
		if(_temp_balance[who].end_date < now) return 0;
		else return _temp_balance[who].end_date;
	}

	/**
     *
     *  returnTempTokens() - return of temporary tokens after the expiration of possession time.
     *
     *  @param recipient - temporary token holder address.
     *
     */
	function returnTempTokens(address recipient) isDeveloper {
		if(this.isOperationBlocked()) throw;
		
		if(_temp_balance[recipient].tokens_count == 0) throw;

		_balances[fond_wallet].tokens_count += _temp_balance[recipient].tokens_count;
		_temp_balance[recipient].tokens_count = 0;
		_temp_balance[recipient].start_date = 0;
		_temp_balance[recipient].end_date = 0;
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

	function() payable
	{	
		if(this.isOperationBlocked()) throw;
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
			if (_balances[wallet_ICO].tokens_count < count_tokens) throw;
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

			if (_balances[wallet_ICO].tokens_count < count_tokens) throw;
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
}
pragma solidity ^0.4.16;

/** @title owned. */
contract owned  {
  address owner;
  function owned() {
    owner = msg.sender;
  }
  function changeOwner(address newOwner) onlyOwner {
    owner = newOwner;
  }
  modifier onlyOwner() {
    require(msg.sender==owner); 
    _;
  }
}

/** @title mortal. */
contract mortal is owned() {
  function kill() onlyOwner {
    if (msg.sender == owner) selfdestruct(owner);
  }
}

/** @title DSMath. */
contract DSMath {

	// Copyright (C) 2015, 2016, 2017  DappHub, LLC

	// Licensed under the Apache License, Version 2.0 (the "License").
	// You may not use this file except in compliance with the License.

	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
    
	// /*
    // uint128 functions (h is for half)
    //  */

    function hmore(uint128 x, uint128 y) constant internal returns (bool) {
        return x>y;
    }

    function hless(uint128 x, uint128 y) constant internal returns (bool) {
        return x<y;
    }

    function hadd(uint128 x, uint128 y) constant internal returns (uint128 z) {
        require((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) constant internal returns (uint128 z) {
        require((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        require(y == 0 ||(z = x * y)/ y == x);
    }

    function hdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = x / y;
    }

    function hmin(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x <= y ? x : y;
    }

    function hmax(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x >= y ? x : y;
    }

    // /*
    // int256 functions
    //  */

    /*
    WAD math
     */
    uint64 constant WAD_Dec=18;
    uint128 constant WAD = 10 ** 18;

    function wmore(uint128 x, uint128 y) constant internal returns (bool) {
        return hmore(x, y);
    }

    function wless(uint128 x, uint128 y) constant internal returns (bool) {
        return hless(x, y);
    }

    function wadd(uint128 x, uint128 y) constant  returns (uint128) {
        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) constant   returns (uint128) {
        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) constant returns (uint128 z) {
        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) constant internal  returns (uint128 z) {
        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) constant internal  returns (uint128) {
        return hmin(x, y);
    }

    function wmax(uint128 x, uint128 y) constant internal  returns (uint128) {
        return hmax(x, y);
    }

    function cast(uint256 x) constant internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }
	
}
 
/** @title I_minter. */
contract I_minter { 
    event EventCreateStatic(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventRedeemStatic(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventCreateRisk(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventRedeemRisk(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventBankrupt();

    function Leverage() constant returns (uint128)  {}
    function RiskPrice(uint128 _currentPrice,uint128 _StaticTotal,uint128 _RiskTotal, uint128 _ETHTotal) constant returns (uint128 price)  {}
    function RiskPrice(uint128 _currentPrice) constant returns (uint128 price)  {}     
    function PriceReturn(uint _TransID,uint128 _Price) {}
    function NewStatic() external payable returns (uint _TransID)  {}
    function NewStaticAdr(address _Risk) external payable returns (uint _TransID)  {}
    function NewRisk() external payable returns (uint _TransID)  {}
    function NewRiskAdr(address _Risk) external payable returns (uint _TransID)  {}
    function RetRisk(uint128 _Quantity) external payable returns (uint _TransID)  {}
    function RetStatic(uint128 _Quantity) external payable returns (uint _TransID)  {}
    function Strike() constant returns (uint128)  {}
}

/** @title I_Pricer. */
contract I_Pricer {
    uint128 public lastPrice;
    I_minter public mint;
    string public sURL;
    mapping (bytes32 => uint) RevTransaction;
    function __callback(bytes32 myid, string result) {}
    function queryCost() constant returns (uint128 _value) {}
    function QuickPrice() payable {}
    function requestPrice(uint _actionID) payable returns (uint _TrasID) {}
    function collectFee() returns(bool) {}
    function () {
        //if ether is sent to this address, send it back.
        revert();
    }
}

/** @title I_coin. */
contract I_coin is mortal {

    event EventClear();

	I_minter public mint;
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals=18;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = '';       //human 0.1 standard. Just an arbitrary versioning scheme.
	
    function mintCoin(address target, uint256 mintedAmount) returns (bool success) {}
    function meltCoin(address target, uint256 meltedAmount) returns (bool success) {}
    function approveAndCall(address _spender, uint256 _value, bytes _extraData){}

    function setMinter(address _minter) {}   
	function increaseApproval (address _spender, uint256 _addedValue) returns (bool success) {}    
	function decreaseApproval (address _spender, uint256 _subtractedValue) 	returns (bool success) {} 

    // @param _owner The address from which the balance will be retrieved
    // @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}    


    // @notice send `_value` token to `_to` from `msg.sender`
    // @param _to The address of the recipient
    // @param _value The amount of token to be transferred
    // @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}


    // @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    // @param _from The address of the sender
    // @param _to The address of the recipient
    // @param _value The amount of token to be transferred
    // @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    // @notice `msg.sender` approves `_addr` to spend `_value` tokens
    // @param _spender The address of the account able to transfer the tokens
    // @param _value The amount of wei to be approved for transfer
    // @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	
	// @param _owner The address of the account owning tokens
    // @param _spender The address of the account able to transfer the tokens
    // @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
	
	mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

	// @return total amount of tokens
    uint256 public totalSupply;
}

/** @title DSBaseActor. */
contract DSBaseActor {
   /*
   Copyright 2016 Nexus Development, LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   */

    bool _ds_mutex;
    modifier mutex() {
        assert(!_ds_mutex);
        _ds_mutex = true;
        _;
        _ds_mutex = false;
    }
	
    function tryExec( address target, bytes calldata, uint256 value)
			mutex()
            internal
            returns (bool call_ret)
    {
		/** @dev Requests new StatiCoins be made for a given address
          * @param target where the ETH is sent to.
          * @param calldata
          * @param value
          * @return True if ETH is transfered
        */
        return target.call.value(value)(calldata);
    }
	
    function exec( address target, bytes calldata, uint256 value)
             internal
    {
        assert(tryExec(target, calldata, value));
    }
}

/** @title canFreeze. */
contract canFreeze is owned { 
	//Copyright (c) 2017 GenkiFS
	//Basically a "break glass in case of emergency"
    bool public frozen=false;
    modifier LockIfFrozen() {
        if (!frozen){
            _;
        }
    }
    function Freeze() onlyOwner {
        // fixes the price and allows everyone to redeem their coins at the current value
		// only becomes false when all ETH has been claimed or the pricer contract is changed
        frozen=true;
    }
}

/** @title oneWrite. */
contract oneWrite {  
	//  Adds modifies that allow one function to be called only once
	//Copyright (c) 2017 GenkiFS
  bool written = false;
  function oneWrite() {
	/** @dev Constuctor, make sure written=false initally
	*/
    written = false;
  }
  modifier LockIfUnwritten() {
    if (written){
        _;
    }
  }
  modifier writeOnce() {
    if (!written){
        written=true;
        _;
    }
  }
}

/** @title pricerControl. */
contract pricerControl is canFreeze {
	//  Copyright (c) 2017 GenkiFS
	//  Controls the Pricer contract for minter.  Allows updates to be made in the future by swapping the pricer contract
	//  Although this is not expected, web addresses, API's, new oracles could require adjusments to the pricer contract
	//  A delay of 2 days is implemented to allow coinholders to redeem their coins if they do not agree with the new contract
	//  A new pricer contract unfreezes the minter (allowing a live price to be used)
    I_Pricer public pricer;
    address public future;
    uint256 public releaseTime;
    uint public PRICER_DELAY = 2; // days updated when coins are set
    event EventAddressChange(address indexed _from, address indexed _to, uint _timeChange);

    function setPricer(address newAddress) onlyOwner {
		/** @dev Changes the Pricer contract, after a certain delay
          * @param newAddress Allows coins to be created and sent to other people
          * @return transaction ID which can be viewed in the pending mapping
        */
        releaseTime = now + PRICER_DELAY;
        future = newAddress;
        EventAddressChange(pricer, future, releaseTime);
    }  

    modifier updates() {
        if (now > releaseTime  && pricer != future){
            update();
            //log0('Updating');
        }
        _;
    }

    modifier onlyPricer() {
      require(msg.sender==address(pricer));
      _;
    }

    function update() internal {
        pricer =  I_Pricer(future);
		frozen = false;
    }
}

/** @title minter. */	
contract minter is I_minter, DSBaseActor, oneWrite, pricerControl, DSMath{ //
	// Copyright (c) 2017 GenkiFS
	// This contract is the controller for the StatiCoin contracts.  
	// Users have 4(+2) functions they can call to mint/melt Static/Risk coins which then calls the Pricer contract
	// after a delay the Pricer contract will call back to the PriceReturn() function
	// this will then call one of the functions ActionNewStatic, ActionNewRisk, ActionRetStatic, ActionRetRisk
	// which will then call the Static or Risk ERC20 contracts to mint/melt new tokens
	// Transfer of tokens is handled by the ERC20 contracts, ETH is stored here.  
    enum Action {NewStatic, RetStatic, NewRisk, RetRisk} // Enum of what users can do
    struct Trans { // Struct
        uint128 amount; // Amount sent by the user (Can be either ETH or number of returned coins)
        address holder; // Address of the user
        Action action;  // Type of action requested (mint/melt a Risk/StatiCoin)
		bytes32 pricerID;  // ID for the pricer function
    }
    uint128 public lastPrice; //Storage of the last price returned by the Pricer contract
	uint128 public PendingETH; //Amount of eth to be added to the contract
    uint public TransID=0; // An increasing counter to keep track of transactions requested
	uint public TransCompleted; // Last transaction removed
    string public Currency; // Name of underlying base currency
    I_coin public Static;  // ERC20 token interface for the StatiCoin
    I_coin public Risk;  // ERC20 token interface for the Risk coin
    uint128 public Multiplier;//=15*10**(17); // default ratio for Risk price
    uint128 public levToll=5*10**(18-1);//0.5  // this plus the multiplier defines the maximum leverage
    uint128 public mintFee = 2*10**(18-3); //0.002 Used to pay oricalize and for marketing contract which is in both parties interest.
    mapping (uint => Trans[]) public pending; // A mapping of pending transactions

    event EventCreateStatic(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventRedeemStatic(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventCreateRisk(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventRedeemRisk(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventBankrupt();	//Called when no more ETH is in the contract and everything needs to be manually reset.  
	
	function minter(string _currency, uint128 _Multiplier) { //,uint8 _DecimalPlaces
        // CONSTRUCTOR  
        Currency=_currency;
        Multiplier = _Multiplier;
        // can't add new contracts here as it gives out of gas messages.  Too much code.
    }	

	function () {
        //if ETH is just sent to this address then we cannot determine if it's for StatiCoins or RiskCoins, so send it back.
        revert();
    }

	function Bailout() 
			external 
			payable 
			{
        /** @dev Allows extra ETH to be added to the benefit of both types of coin holders
          * @return nothing
        */
    }
		
    function NewStatic() 
			external 
			payable 
			returns (uint _TransID) {
        /** @dev Requests new StatiCoins be made for the sender.  
		  * This cannot be called by a contract.  Only a simple wallet (with 0 codesize).
		  * Contracts must use the Approve, transferFrom pattern and move coins from wallets
          * @return transaction ID which can be viewed in the pending mapping
        */
		_TransID=NewCoinInternal(msg.sender,cast(msg.value),Action.NewStatic);
		//log0('NewStatic');
    }
	
    function NewStaticAdr(address _user) 
			external 
			payable 
			returns (uint _TransID)  {  
        /** @dev Requests new StatiCoins be made for a given address.  
		  * The address cannot be a contract, only a simple wallet (with 0 codesize).
		  * Contracts must use the Approve, transferFrom pattern and move coins from wallets
          * @param _user Allows coins to be created and sent to other people
          * @return transaction ID which can be viewed in the pending mapping
        */
		_TransID=NewCoinInternal(_user,cast(msg.value),Action.NewStatic);
		//log0('NewStatic');
    }
	
    function NewRisk() 
			external 
			payable 
			returns (uint _TransID)  {
        /** @dev Requests new Riskcoins be made for the sender.  
		  * This cannot be called by a contract, only a simple wallet (with 0 codesize).
		  * Contracts must use the Approve, transferFrom pattern and move coins from wallets
          * @return transaction ID which can be viewed in the pending mapping
          */
		_TransID=NewCoinInternal(msg.sender,cast(msg.value),Action.NewRisk);
        //log0('NewRisk');
    }

    function NewRiskAdr(address _user) 
			external 
			payable 
			returns (uint _TransID)  {
        /** @dev Requests new Riskcoins be made for a given address.  
		  * The address cannot be a contract, only a simple wallet (with 0 codesize).
		  * Contracts must use the Approve, transferFrom pattern and move coins from wallets
          * @param _user Allows coins to be created and sent to other people
          * @return transaction ID which can be viewed in the pending mapping
          */
		_TransID=NewCoinInternal(_user,cast(msg.value),Action.NewRisk);
        //log0('NewRisk');
    }

    function RetRisk(uint128 _Quantity) 
			external 
			payable 
			LockIfUnwritten  
			returns (uint _TransID)  {
        /** @dev Returns Riskcoins.  Needs a bit of eth sent to pay the pricer contract and the excess is returned.  
		  * The address cannot be a contract, only a simple wallet (with 0 codesize).
          * @param _Quantity Amount of coins being returned
		  * @return transaction ID which can be viewed in the pending mapping
        */
        if(frozen){
            //Skip the pricer contract
            TransID++;
			ActionRetRisk(Trans(_Quantity,msg.sender,Action.RetRisk,0),TransID,lastPrice);
			_TransID=TransID;
        } else {
            //Only returned when Risk price is positive
			_TransID=RetCoinInternal(_Quantity,cast(msg.value),msg.sender,Action.RetRisk);
        }
		//log0('RetRisk');
    }

    function RetStatic(uint128 _Quantity) 
			external 
			payable 
			LockIfUnwritten  
			returns (uint _TransID)  {
        /** @dev Returns StatiCoins,  Needs a bit of eth sent to pay the pricer contract
          * @param _Quantity Amount of coins being returned
		  * @return transaction ID which can be viewed in the pending mapping
        */
        if(frozen){
            //Skip the pricer contract
			TransID++;
            ActionRetStatic(Trans(_Quantity,msg.sender,Action.RetStatic,0),TransID,lastPrice);
			_TransID=TransID;
        } else {
            //Static can be returned at any time
			_TransID=RetCoinInternal(_Quantity,cast(msg.value),msg.sender,Action.RetStatic);
        }
		//log0('RetStatic');
    }
	
	//****************************//
	// Constant functions (Ones that don't write to the blockchain)

    function StaticEthAvailable() 
			constant 
			returns (uint128)  {
		/** @dev Returns the total amount of eth that can be sent to buy StatiCoins
		  * @return amount of Eth
        */
		return StaticEthAvailable(cast(Risk.totalSupply()), cast(this.balance));
    }

	function StaticEthAvailable(uint128 _RiskTotal, uint128 _TotalETH) 
			constant 
			returns (uint128)  {
		/** @dev Returns the total amount of eth that can be sent to buy StatiCoins allows users to test arbitrary amounts of RiskTotal and ETH contained in the contract
		  * @param _RiskTotal Quantity of riskcoins
          * @param  _TotalETH Total value of ETH in the contract
		  * @return amount of Eth
        */
		// (Multiplier+levToll)*_RiskTotal - _TotalETH
		uint128 temp = wmul(wadd(Multiplier,levToll),_RiskTotal);
		if(wless(_TotalETH,temp)){
			return wsub(temp ,_TotalETH);
		} else {
			return 0;
		}
    }

	function RiskPrice(uint128 _currentPrice,uint128 _StaticTotal,uint128 _RiskTotal, uint128 _ETHTotal) 
			constant 
			returns (uint128 price)  {
	    /** @dev Allows users to query various hypothetical prices of RiskCoins in terms of base currency
          * @param _currentPrice Current price of ETH in Base currency.
          * @param _StaticTotal Total quantity of StatiCoins issued.
          * @param _RiskTotal Total quantity of invetor coins issued.
          * @param _ETHTotal Total quantity of ETH in the contract.
          * @return price of RiskCoins 
        */
        if(_ETHTotal == 0 || _RiskTotal==0){
			//Return the default price of _currentPrice * Multiplier
            return wmul( _currentPrice , Multiplier); 
        } else {
            if(hmore( wmul(_ETHTotal , _currentPrice),_StaticTotal)){ //_ETHTotal*_currentPrice>_StaticTotal
				//Risk price is positive
                return wdiv(wsub(wmul(_ETHTotal , _currentPrice) , _StaticTotal) , _RiskTotal); // (_ETHTotal * _currentPrice) - _StaticTotal) / _RiskTotal
            } else  {
				//RiskPrice is negative
                return 0;
            }
        }       
    }
	
    function RiskPrice(uint128 _currentPrice) 
			constant 
			returns (uint128 price)  {
	    /** @dev Allows users to query price of RiskCoins in terms of base currency, using current quantities of coins
          * @param _currentPrice Current price of ETH in Base currency.
	      * @return price of RiskCoins 
        */
        return RiskPrice(_currentPrice,cast(Static.totalSupply()),cast(Risk.totalSupply()),wsub(cast(this.balance),PendingETH));
    }     

    function LastRiskPrice() 
			constant 
			returns (uint128 price)  {
	    /** @dev Allows users to query the last price of RiskCoins in terms of base currency
        *   @return price of RiskCoins 
        */
        return RiskPrice(lastPrice);
    }     		
	
	function Leverage() public 
			constant 
			returns (uint128)  {
		/** @dev Returns the ratio at which Riskcoin grows in value for the equivalent growth in ETH price
		* @return ratio
        */
        if(Risk.totalSupply()>0){
            return wdiv(cast(this.balance) , cast(Risk.totalSupply())); //  this.balance/Risk.totalSupply
        }else{
            return 0;
        }
    }

    function Strike() public 
			constant 
			returns (uint128)  {
		/** @dev Returns the current price at which the Risk price goes negative
		* @return Risk price in underlying per ETH
        */ 
        if(this.balance>0){
            return wdiv(cast(Static.totalSupply()) , cast(this.balance)); //Static.totalSupply / this.balance
        }else{
            return 0;            
        }
    }

	//****************************//
	// Only owner can access the following functions
    function setFee(uint128 _newFee) 
			onlyOwner {
        /** @dev Allows the minting fee to be changed, only owner can modify
          * @param _newFee Size of new fee
          * return nothing 
        */
        mintFee=_newFee;
    }

    function setCoins(address newRisk,address newStatic) 
			updates 
			onlyOwner 
			writeOnce {
        /** @dev Allows the minting fee to be reduced, only owner can modify once, Triggers the pricer to be updated 
          * @param newRisk Address of Riskcoin contract
          * @param newStatic Address of StatiCoin contract
          * return nothing 
        */
        Risk=I_coin(newRisk);
        Static=I_coin(newStatic);
		PRICER_DELAY = 2 days;
    }
	
	//****************************//	
	// Only Pricer can access the following function
    function PriceReturn(uint _TransID,uint128 _Price) 
			onlyPricer {
	    /** @dev Return function for the Pricer contract only.  Controls melting and minting of new coins.
          * @param _TransID Tranasction ID issued by the minter.
          * @param _Price Quantity of Base currency per ETH delivered by the Pricer contract
          * Nothing returned.  One of 4 functions is implemented
        */
	    Trans memory details=pending[_TransID][0];//Get the details for this transaction. 
        if(0==_Price||frozen){ //If there is an error in pricing or contract is frozen, use the old price
            _Price=lastPrice;
        } else {
			if(Static.totalSupply()>0 && Risk.totalSupply()>0) {// dont update if there are coins missing
				lastPrice=_Price; // otherwise update the last price
			}
        }
		//Mint some new StatiCoins
        if(Action.NewStatic==details.action){
            ActionNewStatic(details,_TransID, _Price);
        }
		//Melt some old StatiCoins
        if(Action.RetStatic==details.action){
            ActionRetStatic(details,_TransID, _Price);
        }
		//Mint some new Risk coins
        if(Action.NewRisk==details.action){
            ActionNewRisk(details,_TransID, _Price);
        }
		//Melt some old Risk coin
        if(Action.RetRisk==details.action){
            ActionRetRisk(details,_TransID, _Price);
        }
		//Remove the transaction from the blockchain (saving some gas)
		TransCompleted=_TransID;
		delete pending[_TransID];
    }
	
	//****************************//
    // Only internal functions now
    function ActionNewStatic(Trans _details, uint _TransID, uint128 _Price) 
			internal {
		/** @dev Internal function to create new StatiCoins based on transaction data in the Pending queue.  If not enough spare StatiCoins are available then ETH is refunded.
          * @param _details Structure holding the amount sent (in ETH), the address of the person to sent to, and the type of request.
          * @param _TransID ID of the transaction (as stored in this contract).
          * @param _Price Current 24 hour average price as returned by the oracle in the pricer contract.
          * @return function returns nothing, but adds StatiCoins to the users address and events are created
        */
		//log0('NewStatic');
            
            //if(Action.NewStatic<>_details.action){revert();}  //already checked
			
			uint128 CurRiskPrice=RiskPrice(_Price);
			uint128 AmountReturn;
			uint128 AmountMint;
			
			//Calculates the amount of ETH that can be added to create StatiCoins (excluding the amount already sent and stored in the contract)
			uint128 StaticAvail = StaticEthAvailable(cast(Risk.totalSupply()), wsub(cast(this.balance),PendingETH)); 
						
			// If the amount sent is less than the Static amount available, everything is fine.  Nothing needs to be returned.  
			if (wless(_details.amount,StaticAvail)) {
				// restrictions do not hamper the creation of a StatiCoin
				AmountMint = _details.amount;
				AmountReturn = 0;
			} else {
				// Amount of Static is less than amount requested.  
				// Take all the StatiCoins available.
				// Maybe there is zero Static available, so all will be returned.
				AmountMint = StaticAvail;
				AmountReturn = wsub(_details.amount , StaticAvail) ;
			}	
			
			if(0 == CurRiskPrice){
				// return all the ETH
				AmountReturn = _details.amount;
				//AmountMint = 0; //not required as Risk price = 0
			}
			
			//Static can be added when Risk price is positive and leverage is below the limit
            if(CurRiskPrice > 0  && StaticAvail>0 ){
                // Dont create if CurRiskPrice is 0 or there is no Static available (leverage is too high)
				//log0('leverageOK');
                Static.mintCoin(_details.holder, uint256(wmul(AmountMint , _Price))); //request coins from the Static creator contract
                EventCreateStatic(_details.holder, wmul(AmountMint , _Price), _TransID, _Price); // Event giving the holder address, coins created, transaction id, and price 
				PendingETH=wsub(PendingETH,AmountMint);
            } 

			if (AmountReturn>0) {
                // return some money because not enough StatiCoins are available
				bytes memory calldata; // define a blank `bytes`
                exec(_details.holder,calldata, AmountReturn);  //Refund ETH from this contract
				PendingETH=wsub(PendingETH,AmountReturn);
			}	
    }

    function ActionNewRisk(Trans _details, uint _TransID,uint128 _Price) 
			internal {
		/** @dev Internal function to create new Risk coins based on transaction data in the Pending queue.  Risk coins can only be created if the price is above zero
          * @param _details Structure holding the amount sent (in ETH), the address of the person to sent to, and the type of request.
          * @param _TransID ID of the transaction (as stored in this contract).
          * @param _Price Current 24 hour average price as returned by the oracle in the pricer contract.
          * @return function returns nothing, but adds Riskcoins to the users address and events are created
        */
        //log0('NewRisk');
        //if(Action.NewRisk<>_details.action){revert();}  //already checked
		// Get the Risk price using the amount of ETH in the contract before this transaction existed
		uint128 CurRiskPrice;
		if(wless(cast(this.balance),PendingETH)){
			CurRiskPrice=0;
		} else {
			CurRiskPrice=RiskPrice(_Price,cast(Static.totalSupply()),cast(Risk.totalSupply()),wsub(cast(this.balance),PendingETH));
		}
        if(CurRiskPrice>0){
            uint128 quantity=wdiv(wmul(_details.amount , _Price),CurRiskPrice);  // No of Riskcoins =  _details.amount * _Price / CurRiskPrice
            Risk.mintCoin(_details.holder, uint256(quantity) );  //request coins from the Riskcoin creator contract
            EventCreateRisk(_details.holder, quantity, _TransID, _Price); // Event giving the holder address, coins created, transaction id, and price 
        } else {
            // Don't create if CurRiskPrice is 0, Return all the ETH originally sent
            bytes memory calldata; // define a blank `bytes`
            exec(_details.holder,calldata, _details.amount);
        }
		PendingETH=wsub(PendingETH,_details.amount);
    }

    function ActionRetStatic(Trans _details, uint _TransID,uint128 _Price) 
			internal {
		/** @dev Internal function to Return StatiCoins based on transaction data in the Pending queue.  Static can be returned at any time.
          * @param _details Structure holding the amount sent (in ETH), the address of the person to sent to, and the type of request.
          * @param _TransID ID of the transaction (as stored in this contract).
          * @param _Price Current 24 hour average price as returned by the oracle in the pricer contract.
          * @return function returns nothing, but removes StatiCoins from the user's address, sends ETH and events are created
        */
		//if(Action.RetStatic<>_details.action){revert();}  //already checked
		//log0('RetStatic');
		uint128 _ETHReturned;
		if(0==Risk.totalSupply()){_Price=lastPrice;} //No Risk coins for balance so use fixed price
        _ETHReturned = wdiv(_details.amount , _Price); //_details.amount / _Price
        if (Static.meltCoin(_details.holder,_details.amount)){
            // deducted first, will add back if Returning ETH goes wrong.
            EventRedeemStatic(_details.holder,_details.amount ,_TransID, _Price);
            if (wless(cast(this.balance),_ETHReturned)) {
                 _ETHReturned=cast(this.balance);//Not enough ETH available.  Return all Eth in the contract
            }
			bytes memory calldata; // define a blank `bytes`
            if (tryExec(_details.holder, calldata, _ETHReturned)) { 
				//ETH returned successfully
			} else {
				// there was an error, so add back the amount previously deducted
				Static.mintCoin(_details.holder,_details.amount); //Add back the amount requested
				EventCreateStatic(_details.holder,_details.amount ,_TransID, _Price);  //redo the creation event
			}
			if ( 0==this.balance) {
				Bankrupt();
			}
        }        
    }

    function ActionRetRisk(Trans _details, uint _TransID,uint128 _Price) 
			internal {
		/** @dev Internal function to Return Riskcoins based on transaction data in the Pending queue.  Riskcoins can be returned so long as the Risk price is greater than 0.
          * @param _details Structure holding the amount sent (in ETH), the address of the person to sent to, and the type of request.
          * @param _TransID ID of the transaction (as stored in this contract).
          * @param _Price Current 24 hour average price as returned by the oracle in the Pricer contract.
          * @return function returns nothing, but removes StatiCoins from the users address, sends ETH and events are created
        */        
		//if(Action.RetRisk<>_details.action){revert();}  //already checked
		//log0('RetRisk');
        uint128 _ETHReturned;
		uint128 CurRiskPrice;
		//if(0==Static.totalSupply()){_Price=lastPrice};// no StatiCoins, so all Risk coins are worth the same.  // _ETHReturned = _details.amount / _RiskTotal * _ETHTotal
		CurRiskPrice=RiskPrice(_Price);
        if(CurRiskPrice>0){
            _ETHReturned = wdiv( wmul(_details.amount , CurRiskPrice) , _Price); // _details.amount * CurRiskPrice / _Price
            if (Risk.meltCoin(_details.holder,_details.amount )){
                // Coins are deducted first, will add back if returning ETH goes wrong.
                EventRedeemRisk(_details.holder,_details.amount ,_TransID, _Price);
                if ( wless(cast(this.balance),_ETHReturned)) { // should never happen, but just in case
                     _ETHReturned=cast(this.balance);
                }
				bytes memory calldata; // define a blank `bytes`
                if (tryExec(_details.holder, calldata, _ETHReturned)) { 
					//Returning ETH went ok.  
                } else {
                    // there was an error, so add back the amount previously deducted from the Riskcoin contract
                    Risk.mintCoin(_details.holder,_details.amount);
                    EventCreateRisk(_details.holder,_details.amount ,_TransID, _Price);
                }
            } 
        }  else {
            // Risk price is zero so can't do anything.  Call back and delete the transaction from the contract
        }
    }

	function IsWallet(address _address) 
			internal 
			returns(bool){
		/**
		* @dev checks that _address is not a contract.  
		* @param _address to check 
		* @return True if not a contract, 
		*/		
		uint codeLength;
		assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_address)
        }
		return(0==codeLength);		
    } 

	function RetCoinInternal(uint128 _Quantity, uint128 _AmountETH, address _user, Action _action) 
			internal 
			updates 
			returns (uint _TransID)  {
        /** @dev Requests coins be melted and ETH returned
		  * @param _Quantity of Static or Risk coins to be melted0
		  * @param _AmountETH Amount of eth sent to this contract to cover oracle fee.  Excess is returned.
          * @param _user Address to whom the returned ETH will be sent.
		  * @param _action Allows Static or Risk coins to be returned
		  * @return transaction ID which can be viewed in the Pending mapping
        */
		require(IsWallet(_user));
		uint128 refund;
        uint128 Fee=pricer.queryCost();  //Get the cost of querying the pricer contract
		if(wless(_AmountETH,Fee)){
			revert();  //log0('Not enough ETH to mint');
			} else {
			refund=wsub(_AmountETH,Fee);//Returning coins has had too much ETH sent, so return it.
		}
		if(0==_Quantity){revert();}// quantity has to be non zero
		TransID++;
        
        uint PricerID = pricer.requestPrice.value(uint256(Fee))(TransID);  //Ask the pricer to get the price.  The Fee also cover calling the function PriceReturn at a later time.
		pending[TransID].push(Trans(_Quantity,_user,_action,bytes32(PricerID)));  //Add a transaction to the Pending queue.
        _TransID=TransID;  //return the transaction ID to the user 
        _user.transfer(uint256(refund)); //Return ETH if too much has been sent to cover the pricer
    }
		
	function NewCoinInternal(address _user, uint128 _amount, Action _action) 
			internal 
			updates 
			LockIfUnwritten 
			LockIfFrozen  
			returns (uint _TransID)  {
		/** @dev Requests new coins be made
          * @param _user Address for whom the coins are to be created
          * @param _amount Amount of eth sent to this contract
		  * @param _action Allows Static or Risk coins to be minted
		  * @return transaction ID which can be viewed in the pending mapping
        */
		require(IsWallet(_user));
		uint128 toCredit;
        uint128 Fee=wmax(wmul(_amount,mintFee),pricer.queryCost()); // fee is the maxium of the pricer query cost and a mintFee% of value sent
        if(wless(_amount,Fee)) revert(); //log0('Not enough ETH to mint');
		TransID++;
        uint PricerID = pricer.requestPrice.value(uint256(Fee))(TransID); //Ask the pricer to return the price
		toCredit=wsub(_amount,Fee);
		pending[TransID].push(Trans(toCredit,_user,_action,bytes32(PricerID))); //Store the transaction ID and data ready for later recall
		PendingETH=wadd(PendingETH,toCredit);
        _TransID=TransID;//return the transaction ID for this contract to the user 		
	} 

    function Bankrupt() 
			internal {
			EventBankrupt();
			// Reset the contract
			Static.kill();  //delete all current Static tokens
			Risk.kill();  //delete all current Risk tokens
			//need to create new coins externally, too much gas is used if done here.  
			frozen=false;
			written=false;  // Reset the writeOnce and LockIfUnwritten modifiers
    }
}
pragma solidity ^0.4.15;

    /****************************************************************
     *
     * Name of the project: Genevieve VC Token Swapper
     * Contract name: Swap
     * Author: Juan Livingston @ Ethernity.live
     * Developed for: Genevieve Co.
     * GXVC is an ERC223 Token Swapper
     *
     * This swapper has 2 main functions: 
     * - makeSwapInternal will send new tokens when ether are received
     * - makeSwap will send new tokens when old tokens are received
     *  
     * makeSwap is called by a javascript through an authorized address
     *
     ****************************************************************/

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  function burn(address spender, uint256 value) returns (bool); // Optional 
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  
  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);
  function totalSupply() constant returns (uint256 _supply);

  function transfer(address to, uint value) returns (bool ok);
  function transfer(address to, uint value, bytes data) returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) returns (bool ok);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}


contract Swap {

    address authorizedCaller;
    address collectorAddress;
    address collectorTokens;

    address oldTokenAdd;
    address newTokenAdd; 
    address tokenSpender;

    uint Etherrate;
    uint Tokenrate;

    bool pausedSwap;

    uint public lastBlock;

    // Constructor function with main constants and variables 
 
 	function Swap() {
	    authorizedCaller = msg.sender;

	    oldTokenAdd = 0x58ca3065C0F24C7c96Aee8d6056b5B5deCf9c2f8;
	    newTokenAdd = 0x22f0af8d78851b72ee799e05f54a77001586b18a; 

	    Etherrate = 3000;
	    Tokenrate = 10;

	    authorized[authorizedCaller] = 1;

	    lastBlock = 0;
	}


	// Mapping to store swaps made and authorized callers

    mapping(bytes32 => uint) internal payments;
    mapping(address => uint8) internal authorized;

    // Event definitions

    event EtherReceived(uint _n , address _address , uint _value);
    event GXVCSentByEther(uint _n , address _address , uint _value);

    event GXVCReplay(uint _n , address _address);
    event GXVCNoToken(uint _n , address _address);

    event TokensReceived(uint _n , address _address , uint _value);
    event GXVCSentByToken(uint _n , address _address , uint _value );

    event SwapPaused(uint _n);
    event SwapResumed(uint _n);

    event EtherrateUpd(uint _n , uint _rate);
    event TokenrateUpd(uint _n , uint _rate);

    // Modifier for authorized calls

    modifier isAuthorized() {
        if ( authorized[msg.sender] != 1 ) revert();
        _;
    }

    modifier isNotPaused() {
    	if (pausedSwap) revert();
    	_;
    }

    // Function borrowed from ds-math.

    function mul(uint x, uint y) internal returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    // Falback function, invoked each time ethers are received

    function () payable { 
        makeSwapInternal ();
    }


    // Ether swap, activated by the fallback function after receiving ethers

   function makeSwapInternal () private isNotPaused { // Main function, called internally when ethers are received

     ERC223 newTok = ERC223 ( newTokenAdd );

     address _address = msg.sender;
     uint _value = msg.value;

     // Calculate the amount to send based on the rates supplied

     uint etherstosend = mul( _value , Etherrate ) / 100000000; // Division to equipare 18 decimals to 10

     // ---------------------------------------- Ether exchange --------------------------------------------

    if ( etherstosend > 0 ) {   

        // Log Ether received
        EtherReceived ( 1, _address , _value);

        //Send new tokens
        require( newTok.transferFrom( tokenSpender , _address , etherstosend ) );
		// Log tokens sent for ethers;
        GXVCSentByEther ( 2, _address , etherstosend) ;
        // Send ethers to collector
        require( collectorAddress.send( _value ) );
        }

    }

    // This function is called from a javascript through an authorized address to inform of a transfer 
    // of old token.
    // Parameters are trusted, but they may be accidentally replayed (specially if a rescan is made) 
    // so we store them in a mapping to avoid reprocessing
    // We store the tx_hash, to allow many different swappings per address

    function makeSwap (address _address , uint _value , bytes32 _hash) public isAuthorized isNotPaused {

    ERC223 newTok = ERC223 ( newTokenAdd );

	// Calculate the amount to send based on the rates supplied

    uint gpxtosend = mul( _value , Tokenrate ); 

     // ----------------------------------- No tokens or already used -------------------------------------

    if ( payments[_hash] > 0 ) { // Check for accidental replay
        GXVCReplay( 3, _address ); // Log "Done before";
        return;
     }

     if ( gpxtosend == 0 ) {
        GXVCNoToken( 4, _address ); // Log "No GXC tokens found";
        return;
     }
      // ---------------------------------------- GPX exchange --------------------------------------------
              
     TokensReceived( 5, _address , _value ); // Log balance detected

     payments[_hash] = gpxtosend; // To avoid future accidental replays

      // Transfer new tokens to caller
     require( newTok.transferFrom( tokenSpender , _address , gpxtosend ) );

     GXVCSentByToken( 6, _address , gpxtosend ); // Log "New token sent";

     lastBlock = block.number + 1;

    }

function pauseSwap () public isAuthorized {
	pausedSwap = true;
	SwapPaused(7);
}

function resumeSwap () public isAuthorized {
	pausedSwap = false;
	SwapResumed(8);
}

function updateOldToken (address _address) public isAuthorized {
    oldTokenAdd = _address;
}

function updateNewToken (address _address , address _spender) public isAuthorized {
    newTokenAdd = _address;
    tokenSpender = _spender;   
}


function updateEthRate (uint _rate) public isAuthorized {
    Etherrate = _rate;
    EtherrateUpd(9,_rate);
}


function updateTokenRate (uint _rate) public isAuthorized {
    Tokenrate = _rate;
    TokenrateUpd(10,_rate);
}


function flushEthers () public isAuthorized { // Send ether to collector
    require( collectorAddress.send( this.balance ) );
}

function flushTokens () public isAuthorized {
	ERC20 oldTok = ERC20 ( oldTokenAdd );
	require( oldTok.transfer(collectorTokens , oldTok.balanceOf(this) ) );
}

function addAuthorized(address _address) public isAuthorized {
	authorized[_address] = 1;

}

function removeAuthorized(address _address) public isAuthorized {
	authorized[_address] = 0;

}


}
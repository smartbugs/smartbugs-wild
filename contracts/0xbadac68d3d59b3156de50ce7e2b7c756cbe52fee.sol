/*

Introducing "STAKE THEM ALL" Version 1.0
"STAKE THEM ALL" is playable @ https://stakethemall.io (Ethereum Edition) and https://trx.stakethemall.io (TRON Edition)

About the game :

"STAKE THEM ALL" IS A FUN AND REWARDING PHYSICS GAME RUNNING ON THE BLOCKCHAIN
HAVE FUN WHILE PARTICIPATING TO THE HDX20 TOKEN PRICE APPRECIATION @ https://hdx20.io

How to play "STAKE THEM ALL":

Challenge MODE
--------------
Set the difficulty of your CHALLENGE by choosing how many cube you want
to stack on top of each other and get rewarded on success.

Builder MODE
------------
Stack 15 cubes in order to reach the maximum height. 
The best score, if not beaten within a 24H countdown, wins the whole POT.   
   

This product is copyrighted. Any unauthorized copy, modification, or use without express written consent from HyperDevbox is prohibited.

Copyright 2019 HyperDevbox

*/




pragma solidity ^0.4.25;


interface HDX20Interface
{
    function() payable external;
    
    
    function buyTokenFromGame( address _customerAddress , address _referrer_address ) payable external returns(uint256);
  
    function payWithToken( uint256 _eth , address _player_address ) external returns(uint256);
  
    function appreciateTokenPrice() payable external;
   
    function totalSupply() external view returns(uint256); 
    
    function ethBalanceOf(address _customerAddress) external view returns(uint256);
  
    function balanceOf(address _playerAddress) external view returns(uint256);
    
    function sellingPrice( bool includeFees) external view returns(uint256);
  
}



contract stakethemall
{
     HDX20Interface private HDXcontract = HDX20Interface(0x8942a5995bd168f347f7ec58f25a54a9a064f882);
     
     using SafeMath for uint256;
     using SafeMath128 for uint128;
     
     /*==============================
    =            EVENTS            =
    ==============================*/
    event OwnershipTransferred(
        
         address previousOwner,
         address nextOwner,
          uint256 timeStamp
         );
         
    event HDXcontractChanged(
        
         address previous,
         address next,
         uint256 timeStamp
         );
 
  
    
	    
     event onWithdrawGains(
        address customerAddress,
        uint256 ethereumWithdrawn,
        uint256 timeStamp
    );
    
     event onBuyMode1(
        address     customerAddress,
        uint256     BatchID,
        uint256     BatchBlockTimeout,  
        uint32      Challenge
        );  
        
    event onBuyMode2(
        address     customerAddress,
        uint256     BatchID,
        uint256     BatchBlockTimeout,  
        uint256     nb_token
        );   
        
    event onNewScoreMode1(
        uint256 score,
        address customerAddress,
        uint256 winning,
        uint256 nb_token
    ); 
    
    event onNewScoreMode2(
        uint256 score,
        address       customerAddress,
        bool    newHighscore
      
    ); 
        
  
        
    event onChangeMinimumPrice(
        
         uint256 minimum,
         uint256 timeStamp
         );
         
  
      event onChangeBlockTimeout(
        
         uint32 b1,
         uint32 b2
         );
         
        event onChangeTreasurePercentage(
        
         uint32 percentage
         );
         
       
         
    /*==============================
    =            MODIFIERS         =
    ==============================*/
    modifier onlyOwner
    {
        require (msg.sender == owner );
        _;
    }
    
    modifier onlyFromHDXToken
    {
        require (msg.sender == address( HDXcontract ));
        _;
    }
   
     modifier onlyDirectTransaction
    {
        require (msg.sender == tx.origin);
        _;
    }

  
    address public owner;
  
   
    address public signerAuthority = 0xf77444cE64f3F46ba6b63F6b9411dF9c589E3319;
   
    

    constructor () public
    {
        owner = msg.sender;
       
        GameRoundData.extraData[0] = 20; //mode1 20%
        GameRoundData.extraData[1] = 0; //mode2 current highscore
	    GameRoundData.extraData[2] = uint32((3600*1) / 15);     //1 hour
	    GameRoundData.extraData[3] = uint32((3600*24) / 15);     //24 hour
        
        
        if ( address(this).balance > 0)
        {
            owner.transfer( address(this).balance );
        }
    }
    
    function changeOwner(address _nextOwner) public
    onlyOwner
    {
        require (_nextOwner != owner);
        require(_nextOwner != address(0));
         
        emit OwnershipTransferred(owner, _nextOwner , now);
         
        owner = _nextOwner;
    }
    
    function changeSigner(address _nextSigner) public
    onlyOwner
    {
        require (_nextSigner != signerAuthority);
        require(_nextSigner != address(0));
      
        signerAuthority = _nextSigner;
    }
    
    function changeHDXcontract(address _next) public
    onlyOwner
    {
        require (_next != address( HDXcontract ));
        require( _next != address(0));
         
        emit HDXcontractChanged(address(HDXcontract), _next , now);
         
        HDXcontract  = HDX20Interface( _next);
    }
  
  
    function changeMinimumPrice( uint256 newmini) public
    onlyOwner
    {
      
      if (newmini>0)
      {
          minimumSharePrice = newmini;
      }
       
      emit onChangeMinimumPrice( newmini , now ); 
    }
    
    
    function changeBlockTimeout( uint32 b1 , uint32 b2) public
    onlyOwner
    {
        require( b1>0 && b2>0 );
        
       
        GameRoundData.extraData[2] = b1;
        GameRoundData.extraData[3] = b2;
            
        emit onChangeBlockTimeout( b1,b2 ); 
        
       
       
    }
    
    function changeTreasurePercentage( uint32 percentage) public
    onlyOwner
    {
        require( percentage>0 && percentage<=100);
        
        GameRoundData.extraData[0] = percentage;
          
        emit onChangeTreasurePercentage( percentage ); 
       
       
       
    }
    
     /*================================
    =       GAMES VARIABLES         =
    ================================*/
    
    struct PlayerData_s
    {
   
        uint256 chest;  
        uint256 payoutsTo;
       
		//credit locked until we validate the score mode1
		uint256         mode1LockedCredit;	
		uint256         mode1BatchID;         
        uint256         mode1BlockTimeout;   
        
        uint256         mode2BatchID;         
        uint256         mode2BlockTimeout;   

		uint32[2]		packedData;		//[0] = mode1 challenge how ,any cube to stack;
		                                //[1] = mode1 multiplier
						
    }
    
    
    struct GameRoundData_s
    {
	   
	   //mode1 
	   uint256				treasureAmount;
	   
	   //mode2
	   uint256              potAmount;
	   address				currentPotWinner;
	   uint256              potBlockCountdown;
	          
       uint256              hdx20AppreciationPayout;
       uint256              devAppreciationPayout;
	   
       //********************************************************************************************
	   
	   uint32[4]			extraData;		//[0] = mode1 percentage    treasure
									        //[1] =	mode2 current       highscore
                                            //[2] = mode1 and mode2 blocktimeout  how manyblock to submit a valid score
                                            //[3] = mode2 countdown how many block
                                           
                                            
    }
      
   
    mapping (address => PlayerData_s)   private PlayerData;
       
    GameRoundData_s   private GameRoundData;
   
    uint8 constant private HDX20BuyFees = 5;
     
    uint8 constant private DevFees = 5;
	uint8 constant private AppreciationFees = 15;		

	uint8 constant private TreasureAppreciation = 80;
   	uint8 constant private PotAppreciation = 80;
   	
   
    uint256 constant internal magnitude = 1e18;
     
    uint256 private minimumSharePrice = 0.1 ether;
    

    uint256 constant thresholdForAppreciation = 0.05 ether;
      
    /*================================
    =       PUBLIC FUNCTIONS         =
    ================================*/
    
    //fallback will be called only from the HDX token contract to fund the game from customers's HDX20
    
     function()
     payable
     public
     onlyFromHDXToken 
    {
       
      
      
          
    }
    
    function ChargePot() public payable
    {
		uint256 _val = msg.value;
		
		GameRoundData.potAmount = GameRoundData.potAmount.add( _val );
	
    }
    
    function ChargeTreasure() public payable
    {
		uint256 _val = msg.value;
	
		
		GameRoundData.treasureAmount = GameRoundData.treasureAmount.add( _val );
				   
    }
	
	//mode1
	function AddTreasure( uint256 _val ) private
	{
	
		GameRoundData.treasureAmount = GameRoundData.treasureAmount.add( _val.mul( TreasureAppreciation ) / 100 );
		
		//now HDX20 appreciation and dev account
		
		uint256 _appreciation = SafeMath.mul( _val , AppreciationFees) / 100; 
          
        uint256 _dev = SafeMath.mul( _val , DevFees) / 100;  
		
		_dev = _dev.add( GameRoundData.devAppreciationPayout );
		
		if (_dev>= thresholdForAppreciation )
		{
			GameRoundData.devAppreciationPayout = 0;
			
			HDXcontract.buyTokenFromGame.value( _dev )( owner , address(0));	
		}
		else
		{
			 GameRoundData.devAppreciationPayout = _dev;
		}
	
		_appreciation = _appreciation.add( GameRoundData.hdx20AppreciationPayout );
		
		if (_appreciation>= thresholdForAppreciation)
		{
			GameRoundData.hdx20AppreciationPayout = 0;
			
			HDXcontract.appreciateTokenPrice.value( _appreciation )();
		}
		else
		{
			GameRoundData.hdx20AppreciationPayout = _appreciation;
		}
		
	}
	
    //mode2
	function AddPot( uint256 _val ) private
	{
	    
        
		GameRoundData.potAmount = GameRoundData.potAmount.add( _val.mul( PotAppreciation ) / 100 );
		
		//now HDX20 appreciation and dev account
		
		uint256 _appreciation = SafeMath.mul( _val , AppreciationFees) / 100; 
          
        uint256 _dev = SafeMath.mul( _val , DevFees) / 100;  
		
		_dev = _dev.add( GameRoundData.devAppreciationPayout );
		
		if (_dev>= thresholdForAppreciation )
		{
			GameRoundData.devAppreciationPayout = 0;
			
			HDXcontract.buyTokenFromGame.value( _dev )( owner , address(0));	
		}
		else
		{
			 GameRoundData.devAppreciationPayout = _dev;
		}
	
		_appreciation = _appreciation.add( GameRoundData.hdx20AppreciationPayout );
		
		if (_appreciation>= thresholdForAppreciation)
		{
			GameRoundData.hdx20AppreciationPayout = 0;
			
			HDXcontract.appreciateTokenPrice.value( _appreciation )();
		}
		else
		{
			GameRoundData.hdx20AppreciationPayout = _appreciation;
		}
		
	}
    
    
    function ValidMode1Score( uint256 score, uint256 mode1BatchID , bytes32 r , bytes32 s , uint8 v) public
    onlyDirectTransaction
    {
        address _customer_address = msg.sender;
      
        GameVar_s memory gamevar;
        gamevar.score = score;
        gamevar.BatchID = mode1BatchID;
        gamevar.r = r;
        gamevar.s = s;
        gamevar.v = v;
   
        checkPayPot();
   
        coreValidMode1Score( _customer_address , gamevar  );
    }
    
    function ValidMode2Score( uint256 score, uint256 mode2BatchID , bytes32 r , bytes32 s , uint8 v) public
    onlyDirectTransaction
    {
        address _customer_address = msg.sender;
      
        GameVar_s memory gamevar;
        gamevar.score = score;
        gamevar.BatchID = mode2BatchID;
        gamevar.r = r;
        gamevar.s = s;
        gamevar.v = v;
        
        checkPayPot();
   
        coreValidMode2Score( _customer_address , gamevar  );
    }
    
    struct GameVar_s
    {
        uint256  BatchID;
       
 	    uint256   score;
	
        bytes32  r;
        bytes32  s;
        uint8    v;
        uint32   multiplier;
    }
    
	function checkPayPot() private
	{
	    uint256 b1 =  GameRoundData.potBlockCountdown;
	    
	    if (b1>0)
	    {
	        if (block.number>=b1)
	        {
    		    address _winner = GameRoundData.currentPotWinner;
    		    uint256 _j = GameRoundData.potAmount/2;
    		
    		   
    		
    		    if (_winner != address(0))
    		    {
    			    PlayerData[ _winner ].chest = PlayerData[ _winner ].chest.add( _j ); 
    		    }
    		    
        		GameRoundData.currentPotWinner = address(0);
        		GameRoundData.potAmount = GameRoundData.potAmount.sub( _j );
        		
        	    //highscore to 0
        		GameRoundData.extraData[1] = 0;
        		//block at 0
        		GameRoundData.potBlockCountdown = 0;
        		
    		}
	    }
		
	}
  
    
    function coreValidMode1Score( address _player_address , GameVar_s gamevar) private
    {
    
        PlayerData_s storage  _PlayerData = PlayerData[ _player_address];
                
        require((gamevar.BatchID != 0) && (gamevar.BatchID == _PlayerData.mode1BatchID) && ( _PlayerData.mode1LockedCredit>0 ));
        
        if (block.number>=_PlayerData.mode1BlockTimeout || (ecrecover(keccak256(abi.encodePacked( gamevar.score,gamevar.BatchID )) , gamevar.v, gamevar.r, gamevar.s) != signerAuthority))
        {
            gamevar.score = 0;
        }
		
	
	    if (gamevar.score> _PlayerData.packedData[0]) 	gamevar.score =  _PlayerData.packedData[0];
	    
	    uint256 _winning =0;
	    uint256 _hdx20 = 0;
	    uint256 _nb_token = 0;
	    uint256 _minimum =  _PlayerData.mode1LockedCredit.mul(5) / 100;
	   
	    
	   
	    if (gamevar.score>0)
	    {
	        uint256 _gain;
	    
	        //percentage of treasure      
	        _gain = GameRoundData.treasureAmount.mul( GameRoundData.extraData[0]) / 100;
	        
	        //scale the gain based the credit size
	        _gain = _gain.mul( _PlayerData.packedData[1]) / 10;
	   
	        //triple cube curve     
	        _gain = _gain.mul( _PlayerData.packedData[0] * _PlayerData.packedData[0] * _PlayerData.packedData[0] );
	        _gain /= (10*10*10);
	        
	          //maximum x2
	        if (_gain>_PlayerData.mode1LockedCredit) _gain = _PlayerData.mode1LockedCredit;
	        
	        //succed challenge ?
	        if (gamevar.score==_PlayerData.packedData[0])
	        {
	            _winning = _PlayerData.mode1LockedCredit.add( _gain);
	        }
	        else
	        {
	            _winning = _PlayerData.mode1LockedCredit.sub( _gain );
	            _gain = (_gain).mul( gamevar.score-1 );
	            _gain /= uint256( _PlayerData.packedData[0] );
	            _winning = _winning.add( _gain );
	        }
	    }
	    
	    if (_winning<_minimum) _winning = _minimum;
	    
	   //winning cannot be zero 
	   
	   //HDX20BuyFees
        _hdx20 = (_winning.mul(HDX20BuyFees)) / 100;
	
	    _nb_token =   HDXcontract.buyTokenFromGame.value( _hdx20 )( _player_address , address(0)); 
	     
		//credit the player for what is won minus the HDX20
		_PlayerData.chest = _PlayerData.chest.add( _winning - _hdx20 );
		
		//loosing some ?
		
		if (_PlayerData.mode1LockedCredit> _winning)
		{
			
			AddTreasure( _PlayerData.mode1LockedCredit - _winning );
		}
		
		//we need to pay the difference from the treasure
		if (_winning>_PlayerData.mode1LockedCredit)
		{
		    GameRoundData.treasureAmount = GameRoundData.treasureAmount.sub( _winning - _PlayerData.mode1LockedCredit);
		}
	
        //ok reset it so we can get a new one
        _PlayerData.mode1BatchID = 0;
        _PlayerData.mode1LockedCredit = 0;
		
        emit onNewScoreMode1( gamevar.score , _player_address , _winning , _nb_token );

    }
    
    function coreValidMode2Score( address _player_address , GameVar_s gamevar) private
    {
    
        PlayerData_s storage  _PlayerData = PlayerData[ _player_address];
        
                
        if ((gamevar.BatchID != 0) && (gamevar.BatchID == _PlayerData.mode2BatchID))
        {
                
            if (block.number>=_PlayerData.mode2BlockTimeout || (ecrecover(keccak256(abi.encodePacked( gamevar.score,gamevar.BatchID )) , gamevar.v, gamevar.r, gamevar.s) != signerAuthority))
            {
                gamevar.score = 0;
            }
    		
    	
    	    if (gamevar.score>80*2*15) 	gamevar.score = 80*2*15;
    	    
    	    bool _newHighscore = false;
    	    
    	    //new highscore
    	    if (gamevar.score > GameRoundData.extraData[1])
    	    {
    	        GameRoundData.extraData[1] = uint32(gamevar.score);
    	        GameRoundData.currentPotWinner = _player_address;
    	        GameRoundData.potBlockCountdown = block.number + uint256( GameRoundData.extraData[3] ); //24 hours countdown start
    	        
    	        _newHighscore = true;
    	        
    	    }
    	    
    	    emit onNewScoreMode2( gamevar.score , _player_address , _newHighscore);
        }
	 
        //ok reset it so we can get a new one
        _PlayerData.mode2BatchID = 0;
     
		

    }
    
    
    function BuyMode1WithDividends( uint256 eth , uint32 challenge, uint256 score, uint256 BatchID,  address _referrer_address , bytes32 r , bytes32 s , uint8 v) public
    onlyDirectTransaction
    {
        
        require( (eth==minimumSharePrice || eth==minimumSharePrice*5 || eth==minimumSharePrice*10) && (challenge>=4 && challenge<=10) );
  
        address _customer_address = msg.sender;
        
        checkPayPot();
        
        GameVar_s memory gamevar;
        gamevar.score = score;
        gamevar.BatchID = BatchID;
        gamevar.r = r;
        gamevar.s = s;
        gamevar.v = v;
        gamevar.multiplier = uint32(eth / minimumSharePrice);
      
        
        eth = HDXcontract.payWithToken( eth , _customer_address );
       
        require( eth>0 );
       
         
        CoreBuyMode1( _customer_address , eth , challenge, _referrer_address , gamevar );
        
       
    }
    
 
    
    function BuyMode1( uint32 challenge, uint256 score, uint256 BatchID, address _referrer_address , bytes32 r , bytes32 s , uint8 v ) public payable
    onlyDirectTransaction
    {
     
        address _customer_address = msg.sender;
        uint256 eth = msg.value;
        
        require( (eth==minimumSharePrice || eth==minimumSharePrice*5 || eth==minimumSharePrice*10) && (challenge>=4 && challenge<=10));
        
        checkPayPot();
   
        GameVar_s memory gamevar;
        gamevar.score = score;
        gamevar.BatchID = BatchID;
        gamevar.r = r;
        gamevar.s = s;
        gamevar.v = v;
        gamevar.multiplier = uint32(eth / minimumSharePrice);
     
        CoreBuyMode1( _customer_address , eth , challenge, _referrer_address, gamevar);
     
    }
    
    
    function BuyMode2WithDividends( uint256 eth , uint256 score, uint256 BatchID,  address _referrer_address , bytes32 r , bytes32 s , uint8 v) public
    onlyDirectTransaction
    {
        
        require( (eth==minimumSharePrice) );
  
        address _customer_address = msg.sender;
        
        checkPayPot();
        
        GameVar_s memory gamevar;
        gamevar.score = score;
        gamevar.BatchID = BatchID;
        gamevar.r = r;
        gamevar.s = s;
        gamevar.v = v;
      
        
        eth = HDXcontract.payWithToken( eth , _customer_address );
       
        require( eth>0 );
       
         
        CoreBuyMode2( _customer_address , eth , _referrer_address , gamevar );
        
       
    }
    
    
    function BuyMode2( uint256 score, uint256 BatchID, address _referrer_address , bytes32 r , bytes32 s , uint8 v ) public payable
    onlyDirectTransaction
    {
     
        address _customer_address = msg.sender;
        uint256 eth = msg.value;
        
        require( (eth==minimumSharePrice));
        
        checkPayPot();
   
        GameVar_s memory gamevar;
        gamevar.score = score;
        gamevar.BatchID = BatchID;
        gamevar.r = r;
        gamevar.s = s;
        gamevar.v = v;
     
   
        CoreBuyMode2( _customer_address , eth , _referrer_address, gamevar);
     
    }
    
    /*================================
    =       CORE BUY FUNCTIONS       =
    ================================*/
    
    function CoreBuyMode1( address _player_address , uint256 eth , uint32 challenge,  address _referrer_address , GameVar_s gamevar) private
    {
    
        PlayerData_s storage  _PlayerData = PlayerData[ _player_address];
         
        //we need to validate the score before buying a torpedo batch
        if (gamevar.BatchID !=0 || _PlayerData.mode1BatchID !=0)
        {
             coreValidMode1Score( _player_address , gamevar);
        }
        
        //if we can continue then everything is fine let's create the new batch
        
        _PlayerData.packedData[0] = challenge;
        _PlayerData.packedData[1] = gamevar.multiplier;
        
        _PlayerData.mode1BlockTimeout = block.number + (uint256(GameRoundData.extraData[2]));
        _PlayerData.mode1BatchID = uint256((keccak256(abi.encodePacked( block.number,1,challenge, _player_address , address(this)))));
      
		_PlayerData.mode1LockedCredit =  eth;
	
        
        emit onBuyMode1( _player_address, _PlayerData.mode1BatchID , _PlayerData.mode1BlockTimeout,  _PlayerData.packedData[0]);
            
        
    }
    
    
    function CoreBuyMode2( address _player_address , uint256 eth ,  address _referrer_address , GameVar_s gamevar) private
    {
    
        PlayerData_s storage  _PlayerData = PlayerData[ _player_address];
         
        //we need to validate the score before buying a torpedo batch
        if (gamevar.BatchID !=0 || _PlayerData.mode2BatchID !=0)
        {
             coreValidMode2Score( _player_address , gamevar);
        }
        
        //if we can continue then everything is fine let's create the new batch
        
       
        _PlayerData.mode2BlockTimeout = block.number + (uint256(GameRoundData.extraData[2]));
        _PlayerData.mode2BatchID = uint256((keccak256(abi.encodePacked( block.number,2, _player_address , address(this)))));
      
         //HDX20BuyFees
        uint256 _tempo = (eth.mul(HDX20BuyFees)) / 100;
	
	    eth = eth.sub( _tempo );	
	
        uint256 _nb_token =   HDXcontract.buyTokenFromGame.value( _tempo )( _player_address , _referrer_address);
        
        AddPot( eth );
        
        emit onBuyMode2( _player_address, _PlayerData.mode2BatchID , _PlayerData.mode2BlockTimeout, _nb_token );
            
        
    }
    
    function getPotGain( address _player_address) private view
    returns( uint256)
	{
	    uint256 b1 =  GameRoundData.potBlockCountdown;
	    
	    if (b1>0)
	    {
	        if (block.number>=b1 && _player_address==GameRoundData.currentPotWinner)
	        {
	            return( GameRoundData.potAmount/2);
	          
    		}
	    }
	    
	    return( 0 );
		
	}
   
    
    function get_Gains(address _player_address) private view
    returns( uint256)
    {
       
        uint256 _gains = PlayerData[ _player_address ].chest;
        
        //we may have to temporary add the current pot gain to reflect the correct position
        
        _gains = _gains.add( getPotGain(_player_address ) );
        
        if (_gains > PlayerData[ _player_address].payoutsTo)
        {
            _gains -= PlayerData[ _player_address].payoutsTo;
        }
        else _gains = 0;
     
    
        return( _gains );
        
    }
    
    
    function WithdrawGains() public 
   
    {
        address _customer_address = msg.sender;
        
        checkPayPot();
        
        uint256 _gains = get_Gains( _customer_address );
        
        require( _gains>0);
        
        PlayerData[ _customer_address ].payoutsTo = PlayerData[ _customer_address ].payoutsTo.add( _gains );
        
      
        emit onWithdrawGains( _customer_address , _gains , now);
        
        _customer_address.transfer( _gains );
        
        
    }
    
   
  
    
     /*================================
    =  VIEW AND HELPERS FUNCTIONS    =
    ================================*/
  
    
    function view_get_Treasure() public
    view
    returns(uint256)
    {
      
      return( GameRoundData.treasureAmount );  
    }
	
	function view_get_Pot() public
    view
    returns(uint256)
    {
      
      return( GameRoundData.potAmount );  
    }
 
    function view_get_gameData() public
    view
    returns( 
             uint256 treasure,
			 uint256 pot,
			 uint32  highscore ,
			 address highscore_address ,
		
			 uint256 mode1BatchID,
		     uint256 mode1BlockTimeout,
		     uint32  mode1Challenge,
		     uint256 mode1Multiplier,
		     
			 uint256 mode2BatchID,
			 uint256 mode2BlockTimeout,
			 
			 uint256 potBlockCountdown,
			 
			 uint32  percentage)
    {
        address _player_address = msg.sender;
		
		treasure = GameRoundData.treasureAmount;
		pot = GameRoundData.potAmount;
		highscore = GameRoundData.extraData[1];
		highscore_address = GameRoundData.currentPotWinner;
		percentage = GameRoundData.extraData[0];
		      
        mode1BatchID = PlayerData[_player_address].mode1BatchID;
        mode1BlockTimeout = PlayerData[_player_address].mode1BlockTimeout;
        mode1Challenge = PlayerData[_player_address].packedData[0];
        mode1Multiplier =  PlayerData[_player_address].packedData[1];
        
        mode2BatchID =  PlayerData[_player_address].mode2BatchID;
        mode2BlockTimeout = PlayerData[ _player_address].mode2BlockTimeout;
        
        potBlockCountdown = GameRoundData.potBlockCountdown;
        
      
       
    }
  
       
  
    
    function view_get_Gains()
    public
    view
    returns( uint256 gains)
    {
        
        address _player_address = msg.sender;
   
        uint256 _gains = PlayerData[ _player_address ].chest;
        
        _gains = _gains.add( getPotGain( _player_address ) );
        
        if (_gains > PlayerData[ _player_address].payoutsTo)
        {
            _gains -= PlayerData[ _player_address].payoutsTo;
        }
        else _gains = 0;
     
    
        return( _gains );
        
    }
  
  
    
    function view_get_gameStates() public 
    view
    returns( uint256 minimumshare ,
		     uint256 blockNumberCurrent,
		     uint32  blockScoreTimeout,
		     uint32  blockPotTimout
		   
		    )
    {
       
        
        return( minimumSharePrice ,  block.number   , GameRoundData.extraData[2] , GameRoundData.extraData[3] );
    }
    
    function view_get_pendingHDX20Appreciation()
    public
    view
    returns(uint256)
    {
        return GameRoundData.hdx20AppreciationPayout;
    }
    
    function view_get_pendingDevAppreciation()
    public
    view
    returns(uint256)
    {
        return GameRoundData.devAppreciationPayout;
    }
  
 
 
    function totalEthereumBalance()
    public
    view
    returns(uint256)
    {
        return address(this).balance;
    }
    
  
    
    function view_get_blockNumbers()
    public
    view
    returns( uint256 b1 )
    {
        return( block.number);
        
    }
    
  
    
   
}


library SafeMath {
    
   
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

   
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a);
        return a - b;
    }

   
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a);
        return c;
    }
    
   
    
  
    
   
}


library SafeMath128 {
    
   
    function mul(uint128 a, uint128 b) 
        internal 
        pure 
        returns (uint128 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

   
    function sub(uint128 a, uint128 b)
        internal
        pure
        returns (uint128) 
    {
        require(b <= a);
        return a - b;
    }

   
    function add(uint128 a, uint128 b)
        internal
        pure
        returns (uint128 c) 
    {
        c = a + b;
        require(c >= a);
        return c;
    }
    
   
    
  
    
   
}
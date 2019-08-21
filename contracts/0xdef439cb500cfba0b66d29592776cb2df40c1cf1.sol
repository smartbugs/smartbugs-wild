/*

Introducing "TORPEDO LAUNCH" our second HDX20 POWERED GAME running on the Ethereum Blockchain 
"TORPEDO LAUNCH" is playable @ https://torpedolaunch.io

About the game :

TORPEDO LAUNCH is a Submarine Arcade action game where the player is launching torpedoes to sink enemies boats 


How to play TORPEDO LAUNCH:

The Campaign will start after at least 1 player has played and submitted a score to the worldwide leaderboard then,
for every new highscore registered, a 24H countdown will reset.
At the end of the countdown, the 8 best players ranked on the leaderboard will share the Treasure proportionally to their scores
and everybody will receive their payout.
Every time you buy new torpedoes, 5% of the price will buy you HDX20 Token earning you Ethereum from the volume
of any HDX20 POWERED GAMES (visit https://hdx20.io for details) while 20% of the price will buy you new shares of the game.
Please remember, at every new buy, the price of the share is increasing a little and so will be your payout even if you are not
a winner therefore buying shares at the beginning of the campaign is highly advised.
You can withdraw any owned amount at all time during the game.

Play for the big WIN, Play for the TREASURE, Play for staking HDX20 TOKEN or Play for all at once...Your Choice!

We wish you Good Luck!

PAYOUTS DISTRIBUTION:
.60% to the winners of the race distributed proportionally to their score if ranked from 1st to 8th.
.25% to the community of HDX20 gamers/holders distributed as price appreciation.
.5% to developer for running, developing and expanding the platform.
.10% for provisioning the TREASURE for the next Campaign.




This product is copyrighted. Any unauthorized copy, modification, or use without express written consent from HyperDevbox is prohibited.

Copyright 2018 HyperDevbox

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


contract TorpedoLaunchGame
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
    
    event onNewScore(
        uint256       gRND,
        uint256       blockNumberTimeout,
        uint256       score,
        address       customerAddress,
        bool          newHighScore,
        bool          highscoreChanged    
        
    );
    
    
    event onNewCampaign(
        
        uint256 gRND,
        uint256  blockNumber
        
        );
        
    event onBuyTorpedo(
        address     customerAddress,
        uint256     gRND,
        uint256     torpedoBatchID,
        uint256     torpedoBatchBlockTimeout,  
        uint256     nbToken,
        uint32      torpedoBatchMultiplier  //x1, x10, x100
        );    
        
        
     event onMaintenance(
        bool        mode,
        uint256     timeStamp

        );    
        
 
        
    event onCloseEntry(
        
         uint256 gRND
         
        );    
        
    event onChangeBlockTimeAverage(
        
         uint256 blocktimeavg
         
        );    
        
    event onChangeMinimumPrice(
        
         uint256 minimum,
         uint256 timeStamp
         );
         
    event onNewName(
        
         address     customerAddress,
         bytes32     name,
         uint256     timeStamp
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
   
   
     modifier isPlayer
    {
        require (PlayerData[ msg.sender].gRND !=0);
        _;
    }
    
    modifier isMaintenance
    {
        require (maintenanceMode==true);
        _;
    }
    
     modifier isNotMaintenance
    {
        require (maintenanceMode==false);
        _;
    }
   
  
    address public owner;
  
  
    address public signerAuthority = 0xf77444cE64f3F46ba6b63F6b9411dF9c589E3319;
   
    
    

    constructor () public
    {
        owner = msg.sender;
       
        
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
  
  
    
    function changeBlockTimeAverage( uint256 blocktimeavg) public
    onlyOwner
    {
        require ( blocktimeavg>0 );
        
       
        blockTimeAverage = blocktimeavg;
        
        emit onChangeBlockTimeAverage( blockTimeAverage );
         
    }
    
    function enableMaintenance() public
    onlyOwner
    {
        maintenanceMode = true;
        
        emit onMaintenance( maintenanceMode , now);
        
    }

    function disableMaintenance() public
    onlyOwner
    {
      
        maintenanceMode = false;
        
        emit onMaintenance( maintenanceMode , now);
        
      
        initCampaign();
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
    
    
     /*================================
    =       GAMES VARIABLES         =
    ================================*/
    
    struct PlayerData_s
    {
   
        uint256 chest;  
        uint256 payoutsTo;
        uint256 gRND;  
      
       
    }
    
    struct PlayerGameRound_s
    {
        uint256         shares;
       
        uint256         torpedoBatchID;         //0==no torpedo, otherwise 
        uint256         torpedoBatchBlockTimeout;    
        
        bytes           data;
        
        uint128         token;
        uint32[3]       packedData;         //[0] = torpedomultiplier
                                            //[1] = playerID
                                            //[2]=score
    }
    
    struct GameRoundData_s
    {
       uint256              blockNumber;
       uint256              blockNumberTimeout;
       uint256              sharePrice;
       uint256              sharePots;
       uint256              shareEthBalance;
       uint256              shareSupply;
       uint256              treasureSupply;
       
       mapping (uint32 => address)   IDtoAddress;
     
      
     
       uint256              hdx20AppreciationPayout;
       uint256              devAppreciationPayout;
       //********************************************************************************************
       uint32[16]           highscorePool;     //[0-7]  == uint32 score
                                               //[8-15] == uint32 playerID    
    
       uint32[2]            extraData;//[0]==this_TurnRound , [1]== totalPlayers
  
    }
    
  
   
    mapping (address => PlayerData_s)   private PlayerData;
    
   
    mapping (address => mapping (uint256 => PlayerGameRound_s)) private PlayerGameRound;
    
   
    mapping (uint256 => GameRoundData_s)   private GameRoundData;
    
    mapping( address => bytes32) private registeredNames;
    
    
   
    bool        private maintenanceMode=false;     
   
    uint256     private this_gRND =0;
 
  
    //85 , missing 15% for shares appreciation eg:share price increase
    uint8 constant private HDX20BuyFees = 5;
    uint8 constant private TREASUREBuyFees = 60;
    uint8 constant private BUYPercentage = 20;
    
   
    uint8 constant private DevFees = 5;
    uint8 constant private TreasureFees = 10;
    uint8 constant private AppreciationFees = 25;
  
   
    uint256 constant internal magnitude = 1e18;
  
    uint256 private genTreasure = 0;
   
    uint256 private minimumSharePrice = 0.01 ether;
    
    uint256 private blockTimeAverage = 15;  //seconds per block                          
    
 
      
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
    
    
    function ChargeTreasure() public payable
    {
        genTreasure = SafeMath.add( genTreasure , msg.value);     
    }
    
    
    function buyTreasureShares(GameRoundData_s storage  _GameRoundData , uint256 _eth ) private
    returns( uint256)
    {
        uint256 _nbshares = (_eth.mul( magnitude)) / _GameRoundData.sharePrice;
       
        _GameRoundData.treasureSupply = _GameRoundData.treasureSupply.add( _nbshares );
        
        _GameRoundData.shareSupply =   _GameRoundData.shareSupply.add( _nbshares );
        
        return( _nbshares);
    }
   
    
    function initCampaign() public
    onlyOwner
    isNotMaintenance
    {
 
        
        this_gRND++;
        
        GameRoundData_s storage _GameRoundData = GameRoundData[ this_gRND ];
      
       
        _GameRoundData.blockNumber = block.number;
        
        _GameRoundData.blockNumberTimeout = block.number + (360*10*24*3600); 
        
        uint256 _sharePrice = minimumSharePrice;
        
        _GameRoundData.sharePrice = _sharePrice;
        
        uint256 _nbshares = buyTreasureShares(_GameRoundData, genTreasure );
     
        //convert into ETH
        _nbshares = _nbshares.mul( _sharePrice ) / magnitude;
        
        //start balance   
        _GameRoundData.shareEthBalance = _nbshares;
        
        genTreasure = genTreasure.sub( _nbshares);
     
       
        emit onNewCampaign( this_gRND , block.number);
        
    }
    
    
   
    function get_TotalPayout(  GameRoundData_s storage  _GameRoundData ) private view
    returns( uint256)
    {
      
       uint256 _payout = 0;
        
       uint256 _sharePrice = _GameRoundData.sharePrice;
     
       uint256 _bet = _GameRoundData.sharePots;
           
       _payout = _payout.add( _bet.mul (_sharePrice) / magnitude );
                  
         
       uint256 _potValue = ((_GameRoundData.treasureSupply.mul( _sharePrice ) / magnitude).mul(100-DevFees-TreasureFees-AppreciationFees)) / 100;
       
       _payout = _payout.add( _potValue );
       
   
       return( _payout );
        
    }
    
    
  
    function get_PendingGains( address _player_address , uint256 _gRND) private view
    returns( uint256)
    {
       
        //did not play 
        if (PlayerData[ _player_address].gRND != _gRND || _gRND==0) return( 0 );
       
        GameRoundData_s storage  _GameRoundData = GameRoundData[ _gRND ];
       
       // uint32 _winner = _GameRoundData.extraData[1];
       
        uint256 _gains = 0;
       
        uint256 _sharePrice = _GameRoundData.sharePrice;
        uint256 _shares;
       
        PlayerGameRound_s storage  _PlayerGameRound = PlayerGameRound[ _player_address][_gRND];
       
        _shares = _PlayerGameRound.shares;
            
        _gains = _gains.add( _shares.mul( _sharePrice) / magnitude );
        
        
        //if the race payment is made (race is over) then we add also the winner prize
        if (_GameRoundData.extraData[0] >= (1<<30))
        {
            uint256 _score = 0;
            uint256 _totalscore = 0;       
            
            uint256  _treasure = ((_GameRoundData.treasureSupply.mul( _sharePrice ) / magnitude).mul(100-DevFees-TreasureFees-AppreciationFees)) / 100;
       
            for( uint i=0;i<8;i++)
            {
                _totalscore = _totalscore.add( uint256(_GameRoundData.highscorePool[i]));
                
                if (_GameRoundData.highscorePool[8+i]==_PlayerGameRound.packedData[1])
                {
                    _score =  uint256(_GameRoundData.highscorePool[i]);
                }
                
            }
          
            if (_totalscore>0) _gains = _gains.add( _treasure.mul( _score) / _totalscore );
           
        }
       
     
       
        return( _gains );
        
    }
    
    
    //only for the Result Data Screen on the game not used for the payout
    
    function get_PendingGainsAll( address _player_address , uint256 _gRND) private view
    returns( uint256)
    {
       
        //did not play 
        if (PlayerData[ _player_address].gRND != _gRND || _gRND==0) return( 0 );
       
        GameRoundData_s storage  _GameRoundData = GameRoundData[ _gRND ];
       
     
        // uint32 _winner = _GameRoundData.extraData[1];
       
        uint256 _gains = 0;
     
        uint256 _sharePrice = _GameRoundData.sharePrice;
        uint256 _shares;
       
        PlayerGameRound_s storage  _PlayerGameRound = PlayerGameRound[ _player_address][_gRND];
       
        _shares = _PlayerGameRound.shares;
            
        _gains = _gains.add( _shares.mul( _sharePrice) / magnitude );
        
       
        {
            uint256 _score = 0;
            uint256 _totalscore = 0;       
            
            uint256  _treasure = ((_GameRoundData.treasureSupply.mul( _sharePrice ) / magnitude).mul(100-DevFees-TreasureFees-AppreciationFees)) / 100;
       
            for( uint i=0;i<8;i++)
            {
                _totalscore = _totalscore.add( uint256(_GameRoundData.highscorePool[i]));
                
                if (_GameRoundData.highscorePool[8+i]==_PlayerGameRound.packedData[1])
                {
                    _score =  uint256(_GameRoundData.highscorePool[i]);
                }
                
            }
          
            if (_totalscore>0)    _gains = _gains.add( _treasure.mul( _score) / _totalscore );
           
        }
        
        return( _gains );
        
    }
    
    //process streaming HDX20 appreciation and dev fees appreciation
    function process_sub_Taxes(  GameRoundData_s storage _GameRoundData , uint256 minimum) private
    {
        uint256 _sharePrice = _GameRoundData.sharePrice;
             
        uint256 _potValue = _GameRoundData.treasureSupply.mul( _sharePrice ) / magnitude;
            
        uint256 _appreciation = SafeMath.mul( _potValue , AppreciationFees) / 100; 
          
        uint256 _dev = SafeMath.mul( _potValue , DevFees) / 100;   
        
        if (_dev > _GameRoundData.devAppreciationPayout)
        {
            _dev -= _GameRoundData.devAppreciationPayout;
            
            if (_dev>minimum)
            {
              _GameRoundData.devAppreciationPayout = _GameRoundData.devAppreciationPayout.add( _dev );
              
               HDXcontract.buyTokenFromGame.value( _dev )( owner , address(0));
              
            }
        }
        
        if (_appreciation> _GameRoundData.hdx20AppreciationPayout)
        {
            _appreciation -= _GameRoundData.hdx20AppreciationPayout;
            
            if (_appreciation>minimum)
            {
                _GameRoundData.hdx20AppreciationPayout = _GameRoundData.hdx20AppreciationPayout.add( _appreciation );
                
                 HDXcontract.appreciateTokenPrice.value( _appreciation )();
                
            }
        }
        
    }
    
    //process the fees, hdx20 appreciation, calcul results at the end of the race
    function process_Taxes(  GameRoundData_s storage _GameRoundData ) private
    {
        uint32 turnround = _GameRoundData.extraData[0];
        
        if (turnround>0 && turnround<(1<<30))
        {  
            _GameRoundData.extraData[0] = turnround | (1<<30);
            
            uint256 _sharePrice = _GameRoundData.sharePrice;
             
            uint256 _potValue = _GameRoundData.treasureSupply.mul( _sharePrice ) / magnitude;
     
           
            uint256 _treasure = SafeMath.mul( _potValue , TreasureFees) / 100; 
         
           
            genTreasure = genTreasure.add( _treasure );
            
            //take care of any left over
            process_sub_Taxes( _GameRoundData , 0);
            
          
            
        }
     
    }
    
    function ValidTorpedoScore( int256 score, uint256 torpedoBatchID , bytes32 r , bytes32 s , uint8 v) public
    onlyDirectTransaction
    {
        address _customer_address = msg.sender;
         
        require( maintenanceMode==false  && this_gRND>0 && (block.number <GameRoundData[ this_gRND ].blockNumberTimeout) && (PlayerData[ _customer_address].gRND == this_gRND));
  
        GameVar_s memory gamevar;
        gamevar.score = score;
        gamevar.torpedoBatchID = torpedoBatchID;
        gamevar.r = r;
        gamevar.s = s;
        gamevar.v = v;
   
        coreValidTorpedoScore( _customer_address , gamevar  );
    }
    
    
    struct GameVar_s
    {
     
        bool madehigh;
        bool highscoreChanged;
      
        uint    max_score;
        uint    min_score;
        uint    min_score_index;
        uint    max_score_index;
        uint    our_score_index;
        uint32  max_score_pid;
        uint32  multiplier;
        
        uint256  torpedoBatchID;
        int256   score;
        bytes32  r;
        bytes32  s;
        uint8    v;
    }
    
  
    
    function coreValidTorpedoScore( address _player_address , GameVar_s gamevar) private
    {
    
        PlayerGameRound_s storage  _PlayerGameRound = PlayerGameRound[ _player_address][ this_gRND];
        
        GameRoundData_s storage  _GameRoundData = GameRoundData[ this_gRND ];
        
        require((gamevar.torpedoBatchID != 0) && (gamevar.torpedoBatchID== _PlayerGameRound.torpedoBatchID));
       
         
        gamevar.madehigh = false;
        gamevar.highscoreChanged = false;
       
      //  gamevar.max_score = 0;
        gamevar.min_score = 0xffffffff;
    //    gamevar.min_score_index = 0;
     //   gamevar.max_score_index = 0;
      //  gamevar.our_score_index = 0;
      
        
       
        if (block.number>=_PlayerGameRound.torpedoBatchBlockTimeout || (ecrecover(keccak256(abi.encodePacked( gamevar.score,gamevar.torpedoBatchID )) , gamevar.v, gamevar.r, gamevar.s) != signerAuthority))
        {
            gamevar.score = 0;
        }
        
        
       
        
        int256 tempo = int256(_PlayerGameRound.packedData[2]) + (gamevar.score * int256(_PlayerGameRound.packedData[0]));
        if (tempo<0) tempo = 0;
        if (tempo>0xffffffff) tempo = 0xffffffff;
        
        uint256 p_score = uint256( tempo );
        
        //store the player score
        _PlayerGameRound.packedData[2] = uint32(p_score);
        
       
        for(uint i=0;i<8;i++)
        {
            uint ss = _GameRoundData.highscorePool[i];
            if (ss>gamevar.max_score)
            {
                gamevar.max_score = ss;
                gamevar.max_score_index =i; 
            }
            if (ss<gamevar.min_score)
            {
                gamevar.min_score = ss;
                gamevar.min_score_index = i;
            }
            
            //are we in the pool already
            if (_GameRoundData.highscorePool[8+i]==_PlayerGameRound.packedData[1]) gamevar.our_score_index=1+i;
        }
        
        
        //grab current player id highscore before we potentially overwrite it
        gamevar.max_score_pid = _GameRoundData.highscorePool[ 8+gamevar.max_score_index];
        
        //at first if we are in the pool simply update our score
        
        if (gamevar.our_score_index>0)
        {
           _GameRoundData.highscorePool[ gamevar.our_score_index -1] = uint32(p_score); 
           
           gamevar.highscoreChanged = true;
          
        }
        else
        {
            //we were not in the pool, are we more than the minimum score
            
            if (p_score > gamevar.min_score)
            {
                //yes the minimum should go away and we should replace it in the pool
                _GameRoundData.highscorePool[ gamevar.min_score_index ] =uint32(p_score);
                _GameRoundData.highscorePool[ 8+gamevar.min_score_index] = _PlayerGameRound.packedData[1]; //put our playerID
                
                gamevar.highscoreChanged = true;
   
            }
            
        }
        
        //new highscore ?
        if (p_score>gamevar.max_score)
        {
            //yes
           
            //same person 
            
             if (  gamevar.max_score_pid != _PlayerGameRound.packedData[1] )
             {
                 //no so reset the counter
                  _GameRoundData.blockNumberTimeout = block.number + ((24*60*60) / blockTimeAverage);
                  _GameRoundData.extraData[0]++; // new turn
                   gamevar.madehigh = true;
             }
            
        }
   
        //ok reset it so we can get a new one
        _PlayerGameRound.torpedoBatchID = 0;
        
        emit onNewScore( this_gRND , _GameRoundData.blockNumberTimeout , p_score , _player_address , gamevar.madehigh , gamevar.highscoreChanged );


    }
    
    
    function BuyTorpedoWithDividends( uint256 eth , int256 score, uint256 torpedoBatchID,  address _referrer_address , bytes32 r , bytes32 s , uint8 v) public
    onlyDirectTransaction
    {
        
        require( maintenanceMode==false  && this_gRND>0 && (eth==minimumSharePrice || eth==minimumSharePrice*10 || eth==minimumSharePrice*100) && (block.number <GameRoundData[ this_gRND ].blockNumberTimeout) );
  
        address _customer_address = msg.sender;
        
        GameVar_s memory gamevar;
        gamevar.score = score;
        gamevar.torpedoBatchID = torpedoBatchID;
        gamevar.r = r;
        gamevar.s = s;
        gamevar.v = v;
        
       
        gamevar.multiplier =uint32( eth / minimumSharePrice);
        
        eth = HDXcontract.payWithToken( eth , _customer_address );
       
        require( eth>0 );
        
         
        CoreBuyTorpedo( _customer_address , eth , _referrer_address , gamevar );
        
       
    }
    
    function BuyName( bytes32 name ) public payable
    {
        address _customer_address = msg.sender;
        uint256 eth = msg.value; 
        
        require( maintenanceMode==false  && (eth==minimumSharePrice*10));
        
        //50% for the community
        //50% for the developer account
        
        eth /= 2;
        
        HDXcontract.buyTokenFromGame.value( eth )( owner , address(0));
       
        HDXcontract.appreciateTokenPrice.value( eth )();
        
        registeredNames[ _customer_address ] = name;
        
        emit onNewName( _customer_address , name , now );
    }
    
    function BuyTorpedo( int256 score, uint256 torpedoBatchID, address _referrer_address , bytes32 r , bytes32 s , uint8 v ) public payable
    onlyDirectTransaction
    {
     
        address _customer_address = msg.sender;
        uint256 eth = msg.value;
        
        require( maintenanceMode==false  && this_gRND>0 && (eth==minimumSharePrice || eth==minimumSharePrice*10 || eth==minimumSharePrice*100) && (block.number <GameRoundData[ this_gRND ].blockNumberTimeout));
   
        GameVar_s memory gamevar;
        gamevar.score = score;
        gamevar.torpedoBatchID = torpedoBatchID;
        gamevar.r = r;
        gamevar.s = s;
        gamevar.v = v;
        
       
        gamevar.multiplier =uint32( eth / minimumSharePrice);
   
        CoreBuyTorpedo( _customer_address , eth , _referrer_address, gamevar);
     
    }
    
    /*================================
    =       CORE BUY FUNCTIONS       =
    ================================*/
    
    function CoreBuyTorpedo( address _player_address , uint256 eth ,  address _referrer_address , GameVar_s gamevar) private
    {
    
        PlayerGameRound_s storage  _PlayerGameRound = PlayerGameRound[ _player_address][ this_gRND];
        
        GameRoundData_s storage  _GameRoundData = GameRoundData[ this_gRND ];
        
      
        if (PlayerData[ _player_address].gRND != this_gRND)
        {
           
            if (PlayerData[_player_address].gRND !=0)
            {
                uint256 _gains = get_PendingGains( _player_address , PlayerData[ _player_address].gRND  );
            
                 PlayerData[ _player_address].chest = PlayerData[ _player_address].chest.add( _gains);
            }
          
          
            PlayerData[ _player_address ].gRND = this_gRND;
           
             //player++
             _GameRoundData.extraData[ 1 ]++; 
             
             //a crude playerID
             _PlayerGameRound.packedData[1] = _GameRoundData.extraData[ 1 ];
             
             //only to display the highscore table on the client
             _GameRoundData.IDtoAddress[  _GameRoundData.extraData[1] ] = _player_address;
        }
        
        //we need to validate the score before buying a torpedo batch
        if (gamevar.torpedoBatchID !=0 || _PlayerGameRound.torpedoBatchID !=0)
        {
             coreValidTorpedoScore( _player_address , gamevar);
        }
        
        
       
        
        _PlayerGameRound.packedData[0] = gamevar.multiplier;
        _PlayerGameRound.torpedoBatchBlockTimeout = block.number + ((4*3600) / blockTimeAverage);
        _PlayerGameRound.torpedoBatchID = uint256((keccak256(abi.encodePacked( block.number, _player_address , address(this)))));
        
        
        //HDX20BuyFees
        uint256 _tempo = (eth.mul(HDX20BuyFees)) / 100;
        
        _GameRoundData.shareEthBalance =  _GameRoundData.shareEthBalance.add( eth-_tempo );  //minus the hdx20 fees
        
        uint256 _nb_token =   HDXcontract.buyTokenFromGame.value( _tempo )( _player_address , _referrer_address);
        
      
        _PlayerGameRound.token += uint128(_nb_token);
        
       
        buyTreasureShares(_GameRoundData , (eth.mul(TREASUREBuyFees)) / 100 );
   
        
        eth = eth.mul( BUYPercentage) / 100;
        
        uint256 _nbshare =  (eth.mul( magnitude)) / _GameRoundData.sharePrice;
        
        _GameRoundData.shareSupply =  _GameRoundData.shareSupply.add( _nbshare );
        _GameRoundData.sharePots   =  _GameRoundData.sharePots.add( _nbshare);
      
        _PlayerGameRound.shares =  _PlayerGameRound.shares.add( _nbshare);
   
      
        if (_GameRoundData.shareSupply>magnitude)
        {
            _GameRoundData.sharePrice = (_GameRoundData.shareEthBalance.mul( magnitude)) / _GameRoundData.shareSupply;
        }
       
        //HDX20 streaming appreciation
        process_sub_Taxes( _GameRoundData , 0.1 ether);
        
        emit onBuyTorpedo( _player_address, this_gRND, _PlayerGameRound.torpedoBatchID , _PlayerGameRound.torpedoBatchBlockTimeout, _nb_token,  _PlayerGameRound.packedData[0]);
      
      
        
    }
    
   
    
    function get_Gains(address _player_address) private view
    returns( uint256)
    {
       
        uint256 _gains = PlayerData[ _player_address ].chest.add( get_PendingGains( _player_address , PlayerData[ _player_address].gRND ) );
        
        if (_gains > PlayerData[ _player_address].payoutsTo)
        {
            _gains -= PlayerData[ _player_address].payoutsTo;
        }
        else _gains = 0;
     
    
        return( _gains );
        
    }
    
    
    function WithdrawGains() public 
    isPlayer
    {
        address _customer_address = msg.sender;
        
        uint256 _gains = get_Gains( _customer_address );
        
        require( _gains>0);
        
        PlayerData[ _customer_address ].payoutsTo = PlayerData[ _customer_address ].payoutsTo.add( _gains );
        
      
        emit onWithdrawGains( _customer_address , _gains , now);
        
        _customer_address.transfer( _gains );
        
        
    }
    
   
    
    function CloseEntry() public
    onlyOwner
    isNotMaintenance
    {
    
        GameRoundData_s storage  _GameRoundData = GameRoundData[ this_gRND ];
         
        process_Taxes( _GameRoundData);
          
        emit onCloseEntry( this_gRND );
      
    }
    
   
  
  
    
     /*================================
    =  VIEW AND HELPERS FUNCTIONS    =
    ================================*/
  
    
    function view_get_Treasure() public
    view
    returns(uint256)
    {
      
      return( genTreasure);  
    }
 
    function view_get_gameData() public
    view
    returns( uint256 sharePrice, uint256 sharePots, uint256 shareSupply , uint256 shareEthBalance, uint32 totalPlayers , uint256 shares ,uint256 treasureSupply , uint256 torpedoBatchID , uint32 torpedoBatchMultiplier , uint256 torpedoBatchBlockTimeout , uint256 score   )
    {
        address _player_address = msg.sender;
         
        sharePrice = GameRoundData[ this_gRND].sharePrice;
        sharePots = GameRoundData[ this_gRND].sharePots;
        shareSupply = GameRoundData[ this_gRND].shareSupply;
        shareEthBalance = GameRoundData[ this_gRND].shareEthBalance;
        treasureSupply = GameRoundData[ this_gRND].treasureSupply;
      
        totalPlayers =  GameRoundData[ this_gRND].extraData[1];
      
        shares = PlayerGameRound[_player_address][this_gRND].shares;
      
        torpedoBatchID = PlayerGameRound[_player_address][this_gRND].torpedoBatchID;
        torpedoBatchMultiplier = PlayerGameRound[_player_address][this_gRND].packedData[0];
        torpedoBatchBlockTimeout = PlayerGameRound[_player_address][this_gRND].torpedoBatchBlockTimeout;
        score = PlayerGameRound[_player_address][this_gRND].packedData[2];
    }
  
    function view_get_gameTorpedoData() public
    view
    returns( uint256 torpedoBatchID , uint32 torpedoBatchMultiplier , uint256 torpedoBatchBlockTimeout  , uint256 score )
    {
        address _player_address = msg.sender;
         
     
      
        torpedoBatchID = PlayerGameRound[_player_address][this_gRND].torpedoBatchID;
        torpedoBatchMultiplier = PlayerGameRound[_player_address][this_gRND].packedData[0];
        torpedoBatchBlockTimeout = PlayerGameRound[_player_address][this_gRND].torpedoBatchBlockTimeout;
        
        score = PlayerGameRound[_player_address][this_gRND].packedData[2];
    }
    
    function view_get_gameHighScores() public
    view
    returns( uint32[8] highscores , address[8] addresses , bytes32[8] names )
    {
        address _player_address = msg.sender;
         
        uint32[8] memory highscoresm;
        address[8] memory addressesm;
        bytes32[8] memory namesm;
        
        for(uint i =0;i<8;i++)
        {
            highscoresm[i] = GameRoundData[ this_gRND].highscorePool[i];
            
            uint32 id = GameRoundData[ this_gRND].highscorePool[8+i];
            
            addressesm[i] = GameRoundData[ this_gRND ].IDtoAddress[ id ];
            
            namesm[i] = view_get_registeredNames( addressesm[i ]);
        }
     
     
     highscores = highscoresm;
     addresses = addressesm;
     names = namesm;
      
     
    }
    
    function view_get_Gains()
    public
    view
    returns( uint256 gains)
    {
        
        address _player_address = msg.sender;
   
      
        uint256 _gains = PlayerData[ _player_address ].chest.add( get_PendingGains( _player_address , PlayerData[ _player_address].gRND) );
        
        if (_gains > PlayerData[ _player_address].payoutsTo)
        {
            _gains -= PlayerData[ _player_address].payoutsTo;
        }
        else _gains = 0;
     
    
        return( _gains );
        
    }
  
  
    
    function view_get_gameStates() public 
    view
    returns(uint256 grnd, uint32 turnround, uint256 minimumshare , uint256 blockNumber , uint256 blockNumberTimeout, uint256 blockNumberCurrent , uint256 blockTimeAvg , uint32[8] highscores , address[8] addresses , bytes32[8] names , bytes32 myname)
    {
        uint32[8] memory highscoresm;
        address[8] memory addressesm;
        bytes32[8] memory namesm;
        
        for(uint i =0;i<8;i++)
        {
            highscoresm[i] = GameRoundData[ this_gRND].highscorePool[i];
            
            uint32 id = GameRoundData[ this_gRND].highscorePool[8+i];
            
            addressesm[i] = GameRoundData[ this_gRND ].IDtoAddress[ id ];
            
            namesm[i] = view_get_registeredNames( addressesm[i ]);
        }
        
        return( this_gRND , GameRoundData[ this_gRND].extraData[0] , minimumSharePrice , GameRoundData[ this_gRND].blockNumber,GameRoundData[ this_gRND].blockNumberTimeout, block.number , blockTimeAverage , highscoresm , addressesm , namesm , view_get_registeredNames(msg.sender));
    }
    
    function view_get_ResultData() public
    view
    returns(uint32 TotalPlayer, uint256 TotalPayout ,uint256 MyTokenValue, uint256 MyToken, uint256 MyGains , uint256 MyScore)
    {
        address _player_address = msg.sender;
        
        GameRoundData_s storage  _GameRoundData = GameRoundData[ this_gRND ];
        
        TotalPlayer = _GameRoundData.extraData[1];
     
        TotalPayout = get_TotalPayout( _GameRoundData );
      
        MyToken =  PlayerGameRound[ _player_address][ this_gRND].token;
          
        MyTokenValue = MyToken * HDXcontract.sellingPrice( true );
        MyTokenValue /= magnitude;
      
        MyGains = 0;
     
        
        if (PlayerData[ _player_address].gRND == this_gRND)
        {
       
           MyGains =  get_PendingGainsAll( _player_address , this_gRND ); //just here for the view function so not used for any payout
        }
        
        MyScore = PlayerGameRound[_player_address][this_gRND].packedData[2];
    }    
 
 
    function totalEthereumBalance()
    public
    view
    returns(uint256)
    {
        return address(this).balance;
    }
    
    function view_get_maintenanceMode()
    public
    view
    returns(bool)
    {
        return( maintenanceMode);
    }
    
    function view_get_blockNumbers()
    public
    view
    returns( uint256 b1 , uint256 b2 )
    {
        return( block.number , GameRoundData[ this_gRND ].blockNumberTimeout);
        
    }
    
    function view_get_registeredNames(address _player)
    public
    view
    returns( bytes32)
    {
        
        return( registeredNames[ _player ]);
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
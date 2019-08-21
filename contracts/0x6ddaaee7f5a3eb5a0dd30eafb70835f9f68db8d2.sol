pragma solidity ^0.4.25;


/*
                                                                  
SuperCountries War Game #2 - Nuke countries and share a huge war chest                                           
SuperCountries Original Game #1 - Each player earns ether forever


███████╗██╗   ██╗██████╗ ███████╗██████╗                                    
██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗                                   
███████╗██║   ██║██████╔╝█████╗  ██████╔╝                                   
╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗                                   
███████║╚██████╔╝██║     ███████╗██║  ██║                                   
╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝                                   
                                                                            
     ██████╗ ██████╗ ██╗   ██╗███╗   ██╗████████╗██████╗ ██╗███████╗███████╗
    ██╔════╝██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝██╔══██╗██║██╔════╝██╔════╝
    ██║     ██║   ██║██║   ██║██╔██╗ ██║   ██║   ██████╔╝██║█████╗  ███████╗
    ██║     ██║   ██║██║   ██║██║╚██╗██║   ██║   ██╔══██╗██║██╔══╝  ╚════██║
    ╚██████╗╚██████╔╝╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║███████╗███████║
     ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝
                                                                            
          ██╗    ██╗ █████╗ ██████╗                                         
          ██║    ██║██╔══██╗██╔══██╗                                        
█████╗    ██║ █╗ ██║███████║██████╔╝    █████╗                              
╚════╝    ██║███╗██║██╔══██║██╔══██╗    ╚════╝                              
          ╚███╔███╔╝██║  ██║██║  ██║                                        
           ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝                                        
                                                                            

                                                                                                                                                     

© 2018 SuperCountries

所有权 - 4CE434B6058EC7C24889EC2512734B5DBA26E39891C09DF50C3CE3191CE9C51E

Xuxuxu - LB - Xufo - MyPartridge
																										   
*/


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
/////		                                                 /////
/////				CALLING EXTERNAL CONTRACTS   			 /////
/////		                                                 /////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////


////////////////////////////////////////////////
/// 	SUPERCOUNTRIES CONTRACT	FUNCTIONS	 ///	
////////////////////////////////////////////////

contract SuperCountriesExternal {
  using SafeMath for uint256; 

	function ownerOf(uint256) public pure returns (address) {	}
	
	function priceOf(uint256) public pure returns (uint256) { }
}



////////////////////////////////////////////////////////////
/// 	SUPERCOUNTRIES TROPHY CARDS CONTRACT FUNCTIONS	 ///	
////////////////////////////////////////////////////////////

contract SuperCountriesTrophyCardsExternal {
  using SafeMath for uint256;
  
	function countTrophyCards() public pure returns (uint256) {	}
	
	function getTrophyCardIdFromIndex(uint256) public pure returns (uint256) {	}
}






//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
/////		                                         /////
/////		SUPERCOUNTRIES WAR - NEW CONTRACT    	 /////
/////		                                         /////
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

contract SuperCountriesWar {
  using SafeMath for uint256;

 
////////////////////////////
/// 	CONSTRUCTOR		 ///	
////////////////////////////
   
	constructor () public {
		owner = msg.sender;

		continentKing.length = 16;
		newOwner.length = 256;
		nukerAddress.length = 256;		
	}
	
	address public owner;  

	
	
	
	
	
////////////////////////////////
/// 	USEFUL MODIFIERS	 ///	
////////////////////////////////
	
  /**
   * @dev Throws if called by any account other than the owner.
   */
	modifier onlyOwner() {
		require(owner == msg.sender);
		_;
	}

	
	
  /**
   * @dev Throws if called by address 0x0
   */
	modifier onlyRealAddress() {
		require(msg.sender != address(0));
		_;
	}
	
	
	
  /**
   * @dev Can only be called when a game is running / unpaused
   */	
	modifier onlyGameNOTPaused() {
		require(gameRunning == true);
		_;
	}

	

	/**
   * @dev Can only be called when a game is paused / ended
   */	
	modifier onlyGamePaused() {
		require(gameRunning == false);
		_;
	}
    
	
	
	


	
///////////////////////////////////////
/// 	TROPHY CARDS FUNCTIONS 		///
///////////////////////////////////////

///Update the index of the next trophy card to get dividends, after each buy a new card will get divs
	function nextTrophyCardUpdateAndGetOwner() internal returns (address){
		uint256 cardsLength = getTrophyCount();
		address trophyCardOwner;
		
		if (nextTrophyCardToGetDivs < cardsLength){
				uint256 nextCard = getTrophyFromIndex(nextTrophyCardToGetDivs);
				trophyCardOwner = getCountryOwner(nextCard);	
		}
		
		/// Update for next time
		if (nextTrophyCardToGetDivs.add(1) < cardsLength){
				nextTrophyCardToGetDivs++;			
		}
			else nextTrophyCardToGetDivs = 0;
			
		return trophyCardOwner;			
	} 

	

/// Get the address of the owner of the "next trophy card to get divs"
	function getNextTrophyCardOwner() 
		public 
		view 
		returns (
			address nextTrophyCardOwner_,
			uint256 nextTrophyCardIndex_,
			uint256 nextTrophyCardId_
		)
	{
		uint256 cardsLength = getTrophyCount();
		address trophyCardOwner;
		
		if (nextTrophyCardToGetDivs < cardsLength){
				uint256 nextCard = getTrophyFromIndex(nextTrophyCardToGetDivs);
				trophyCardOwner = getCountryOwner(nextCard);
		}
			
		return (
			trophyCardOwner,
			nextTrophyCardToGetDivs,
			nextCard
		);
	}
	
	
	

	
	
////////////////////////////////////////////////////////
/// 	CALL OF OTHER SUPERCOUNTRIES CONTRACTS		 ///	
////////////////////////////////////////////////////////
	
/// EXTERNAL VALUES
	address private contractSC = 0xdf203118A954c918b967a94E51f3570a2FAbA4Ac; /// SuperCountries Original game
	address private contractTrophyCards = 0xEaf763328604e6e54159aba7bF1394f2FbcC016e; /// SuperCountries Trophy Cards
		
	SuperCountriesExternal SC = SuperCountriesExternal(contractSC);
	SuperCountriesTrophyCardsExternal SCTrophy = SuperCountriesTrophyCardsExternal(contractTrophyCards);
	
	


	
////////////////////////////////////////////////////
/// 	GET FUNCTIONS FROM EXTERNAL CONTRACTS	 ///	
////////////////////////////////////////////////////
	
/// SuperCountries Original
	function getCountryOwner(uint256 _countryId) public view returns (address){        
		return SC.ownerOf(_countryId);
    }
	
	
/// SuperCountries Original
	function getPriceOfCountry(uint256 _countryId) public view returns (uint256){			
		return SC.priceOf(_countryId);
	}

	
/// SuperCountries Trophy Cards
	function getTrophyFromIndex(uint256 _index) public view returns (uint256){			
		return SCTrophy.getTrophyCardIdFromIndex(_index);
	}

	
/// SuperCountries Trophy Cards	
	function getTrophyCount() public view returns (uint256){			
		return SCTrophy.countTrophyCards();
	}
	




	
////////////////////////////////////////
/// 	VARIABLES & MAPPINGS		 ///	
////////////////////////////////////////
	
/// Game enabled?	
	bool private gameRunning;
	uint256 private gameVersion = 1; /// game Id	

	
/// Dates & timestamps
	uint256 private jackpotTimestamp; /// if this timestamp is reached, the jackpot can be shared
	mapping(uint256 => bool) private thisJackpotIsPlayedAndNotWon; /// true if currently played and not won, false if already won or not yet played

	
/// *** J A C K P O T *** ///
/// Unwithdrawn jackpot per winner
	mapping(uint256 => mapping(address => uint256)) private winnersJackpot; 
	mapping(uint256 => uint256) private winningCountry; /// List of winning countries

	
/// Payable functions prices: nuke a country, become a king ///
	uint256 private startingPrice = 1e16; /// ETHER /// First raw price to nuke a country /// nuke = nextPrice (or startingPrice) + kCountry*LastKnownCountryPrice
	mapping(uint256 => uint256) private nextPrice; /// ETHER /// Current raw price to nuke a country /// nuke = nextPrice + kCountry*LastKnownCountryPrice
	uint256 private kingPrice = 9e15; /// ETHER /// Current king price

	
/// Factors ///
	uint256 private kCountry = 4; /// PERCENTS /// nuke = nextPrice + kCountry*LastKnownCountryPrice (4 = 4%)
	uint256 private kCountryLimit = 5e17; /// ETHER /// kCountry * lastKnownPrice cannot exceed this limit
	uint256 private kNext = 1037; /// PERTHOUSAND /// price increase after each nuke (1037 = 3.7% increase)
	uint256 private maxFlips = 16; /// king price will increase after maxFlips kings
	uint256 private continentFlips; /// Current kings flips
	uint256 private kKings = 101; /// king price increase (101 = 1% increase)
	

/// Kings //
	address[] private continentKing;

	
/// Nukers ///
	address[] private nukerAddress;

	
/// Lovers ///
	struct LoverStructure {
		mapping(uint256 => mapping(address => uint256)) loves; /// howManyNuked => lover address => number of loves
		mapping(uint256 => uint256) maxLoves; /// highest number of loves for this country
		address bestLover; /// current best lover for this country (highest number of loves)
		}

	mapping(uint256 => mapping(uint256 => LoverStructure)) private loversSTR; /// GameVersion > CountryId > LoverStructure
	uint256 private mostLovedCountry; /// The mostLovedCountry cannot be nuked if > 4 countries on the map
	
	mapping(address => uint256) private firstLove; /// timestamp for loves 
	mapping(address => uint256) private remainingLoves; /// remaining loves for today
	uint256 private freeRemainingLovesPerDay = 2; /// Number of free loves per day sub 1

	
/// Cuts in perthousand /// the rest = potCut
	uint256 private devCut = 280; /// Including riddles and medals rewards
	uint256 private playerCut = 20; /// trophy card, best lover & country owner
	uint256 private potCutSuperCountries = 185;
	

/// Jackpot redistribution /// 10 000 = 100%
	uint256 private lastNukerShare = 5000;
	uint256 private winningCountryShare = 4400; /// if 1 country stands, the current owner takes it all, otherwise shared between owners of remaining countries (of the winning continent)
	uint256 private continentShare = 450;
	uint256 private freePlayerShare = 150;


/// Minimal jackpot guarantee /// Initial funding by SuperCountries	
	uint256 private lastNukerMin = 3e18; /// 3 ethers
	uint256 private countryOwnerMin = 3e18; /// 3 ethers
	uint256 private continentMin = 1e18; /// 1 ether
	uint256 private freePlayerMin = 1e18; /// 1 ether
	uint256 private withdrawMinOwner; /// Dev can withdraw his initial funding if the jackpot equals this value.


/// Trophy cards
	uint256 private nextTrophyCardToGetDivs; /// returns next trophy card INDEX to get dividends
	
	
/// Countries ///
	uint256 private allCountriesLength = 256; /// how many countries
	mapping(uint256 => mapping(uint256 => bool)) private eliminated; /// is this country eliminated? gameVersion > countryId > bool
	uint256 private howManyEliminated; /// how many eliminated countries
	uint256 private howManyNuked; /// how many nuked countries
	uint256 private howManyReactivated; /// players are allowed to reactivate 1 country for 8 nukes
	uint256 private lastNukedCountry; /// last nuked country ID
	mapping(uint256 => uint256) lastKnownCountryPrice; ///
	address[] private newOwner; /// Latest known country owners /// A new buyer must send at least one love or reanimate its country to be in the array

/// Continents ///	
	mapping(uint256 => uint256) private countryToContinent; /// country Id to Continent Id

	
/// Time (seconds) ///	
	uint256 public SLONG = 86400; /// 1 day
	uint256 public DLONG = 172800; /// 2 days
	uint256 public DSHORT = 14400; /// 4 hrs
	
	
	

	
////////////////////////
/// 	EVENTS		 ///	
////////////////////////

	/// Pause / UnPause
	event PausedOrUnpaused(uint256 indexed blockTimestamp_, bool indexed gameRunning_);
	
	/// New Game ///
	event NewGameLaunched(uint256 indexed gameVersion_, uint256 indexed blockTimestamp_, address indexed msgSender_, uint256 jackpotTimestamp_);
	event ErrorCountry(uint256 indexed countryId_);
	
	/// Updates ///
	event CutsUpdated(uint256 indexed newDevcut_, uint256 newPlayercut_, uint256 newJackpotCountriescut_, uint256 indexed blockTimestamp_);	
	event ConstantsUpdated(uint256 indexed newStartPrice_, uint256 indexed newkKingPrice_, uint256 newKNext_, uint256 newKCountry_, uint256 newKLimit_, uint256 newkKings, uint256 newMaxFlips);
	event NewContractAddress(address indexed newAddress_);
	event NewValue(uint256 indexed code_, uint256 indexed newValue_, uint256 indexed blockTimestamp_);
	event NewCountryToContinent(uint256 indexed countryId_, uint256 indexed continentId_, uint256 indexed blockTimestamp_);		
	
	/// Players Events ///
	event PlayerEvent(uint256 indexed eventCode_, uint256 indexed countryId_, address indexed player_, uint256 timestampNow_, uint256 customValue_, uint256 gameId_);
	event Nuked(address indexed player_, uint256 indexed lastNukedCountry_, uint256 priceToPay_, uint256 priceRaw_);	
	event Reactivation(uint256 indexed countryId_, uint256 indexed howManyReactivated_);
	event NewKingContinent(address indexed player_, uint256 indexed continentId_, uint256 priceToPay_);
	event newMostLovedCountry(uint256 indexed countryId_, uint256 indexed maxLovesBest_);
	event NewBestLover(address indexed lover_, uint256 indexed countryId_, uint256 maxLovesBest_);	
	event NewLove(address indexed lover_, uint256 indexed countryId_, uint256 playerLoves_, uint256 indexed gameId_, uint256 nukeCount_);
	event LastCountryStanding(uint256 indexed countryId_, address indexed player_, uint256 contractBalance_, uint256 indexed gameId_, uint256 jackpotTimestamp);
	event ThereIsANewOwner(address indexed newOwner_, uint256 indexed countryId_);
	
	/// Payments /// 
	event CutsPaidInfos(uint256 indexed blockTimestamp_, uint256 indexed countryId_, address countryOwner_, address trophyCardOwner_, address bestLover_);
	event CutsPaidValue(uint256 indexed blockTimestamp_, uint256 indexed paidPrice_, uint256 thisBalance_, uint256 devCut_, uint256 playerCut_, uint256 indexed SuperCountriesCut_);
	event CutsPaidLight(uint256 indexed blockTimestamp_, uint256 indexed paidPrice_, uint256 thisBalance_, uint256 devCut_, uint256 playerCut_, address trophyCardOwner_, uint256 indexed SuperCountriesCut_);
	event NewKingPrice(uint256 indexed kingPrice_, uint256 indexed kKings_);
		
	/// Jackpot & Withdraws ///
	event NewJackpotTimestamp(uint256 indexed jackpotTimestamp_, uint256 indexed timestamp_);
	event WithdrawByDev(uint256 indexed blockTimestamp_, uint256 indexed withdrawn_, uint256 indexed withdrawMinOwner_, uint256 jackpot_);
	event WithdrawJackpot(address indexed winnerAddress_, uint256 indexed jackpotToTransfer_, uint256 indexed gameVersion_);	
	event JackpotDispatch(address indexed winner, uint256 indexed jackpotShare_, uint256 customValue_, bytes32 indexed customText_);
	event JackpotDispatchAll(uint256 indexed gameVersion_, uint256 indexed winningCountry_, uint256 indexed continentId_, uint256 timestampNow_, uint256 jackpotTimestamp_, uint256 pot_,uint256 potDispatched_, uint256 thisBalance);

	

	
	

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
////////////////////////////
/// PUBLIC GET FUNCTIONS ///
////////////////////////////

/// Checks if a player can nuke or be a king
	function canPlayTimestamp() public view returns (bool ok_){
		uint256 timestampNow = block.timestamp;
		uint256 jT = jackpotTimestamp;
		bool canPlayTimestamp_;
		
			if (timestampNow < jT || timestampNow > jT.add(DSHORT)){
				canPlayTimestamp_ = true;		
			}
		
		return canPlayTimestamp_;	
	}


	
	
/// When eliminated, the country cannot be eliminated again unless someone rebuys this country	
	function isEliminated(uint256 _countryId) public view returns (bool isEliminated_){
		return eliminated[gameVersion][_countryId];
	}


	
	
/// The player can love few times a day (or more if loved yesterday)
	function canPlayerLove(address _player) public view returns (bool playerCanLove_){	
		if (firstLove[_player].add(SLONG) > block.timestamp && remainingLoves[_player] == 0){
			bool canLove = false;
		} else canLove = true;	

		return canLove;
	}

	
	
	
/// To reanimate a country, a player must rebuy it first on the marketplace then click the reanima button
/// Reanimations are limited: 1 allowed for 8 nukes ; disallowed if only 8 countries on the map
	function canPlayerReanimate(
		uint256 _countryId,
		address _player
	)
		public
		view
		returns (bool canReanimate_)
	{	
		if (
			(lastKnownCountryPrice[_countryId] < getPriceOfCountry(_countryId))	&&
			(isEliminated(_countryId) == true) &&
			(_countryId != lastNukedCountry) &&
			(block.timestamp.add(SLONG) < jackpotTimestamp || block.timestamp > jackpotTimestamp.add(DSHORT)) &&
			(allCountriesLength.sub(howManyEliminated) > 8) && /// If only 8 countries left, no more reactivation allowed even if other requires could allow
			((howManyReactivated.add(1)).mul(8) < howManyNuked) && /// 1 reactivation for 8 Nukes
			(lastKnownCountryPrice[_countryId] > 0) &&
			(_player == getCountryOwner(_countryId))
			) {
				bool canReanima = true;				
			} else canReanima = false;		
		
		return canReanima;
	}	

	
	
	
/// Get the current gameVersion	
	function constant_getGameVersion() public view returns (uint256 currentGameVersion_){
		return gameVersion;
	}


	
	
/// Returns some useful informations for a country
	function country_getInfoForCountry(uint256 _countryId) 
		public 
		view 
		returns (
			bool eliminatedBool_,
			uint256 whichContinent_,
			address currentBestLover_,
			uint256 maxLovesForTheBest_,
			address countryOwner_,
			uint256 lastKnownPrice_
		) 
	{		
		LoverStructure storage c = loversSTR[gameVersion][_countryId];
		if (eliminated[gameVersion][_countryId]){uint256 nukecount = howManyNuked.sub(1);} else nukecount = howManyNuked;
		
		return (
			eliminated[gameVersion][_countryId],
			countryToContinent[_countryId],
			c.bestLover,
			c.maxLoves[nukecount],
			newOwner[_countryId],
			lastKnownCountryPrice[_countryId]
		);
	}
	
	
	
	
/// Returns the number of loves
	function loves_getLoves(uint256 _countryId, address _player) public view returns (uint256 loves_) {				
		LoverStructure storage c = loversSTR[gameVersion][_countryId];
		return c.loves[howManyNuked][_player];
	}

	
	
	
/// Returns the number of loves of a player for a country for an old gameId for howManyNukedId (loves reset after each nuke)
	function loves_getOldLoves(
		uint256 _countryId,
		address _player,
		uint256 _gameId,
		uint256 _oldHowManyNuked
	) 
		public 
		view 
		returns (uint256 loves_) 
	{		
		return loversSTR[_gameId][_countryId].loves[_oldHowManyNuked][_player];
	}

	
	
	
/// Calculate how many loves left for a player for today
	function loves_getPlayerInfo(address _player) 
		public 
		view 
		returns (
			uint256 playerFirstLove_,
			uint256 playerRemainingLoves_,
			uint256 realRemainingLoves_
		) 
	{
		uint256 timestampNow = block.timestamp;
		uint256 firstLoveAdd24 = firstLove[_player].add(SLONG);
		uint256 firstLoveAdd48 = firstLove[_player].add(DLONG);
		uint256 remainStored = remainingLoves[_player];
		
		/// This player loved today but has some loves left, remainingLoves are correct
		if (firstLoveAdd24 > timestampNow && remainStored > 0){
			uint256 remainReal = remainStored;
		}
			/// This player loved yesterday but not today, he can love "howManyEliminated.div(4)" + "freeRemainingLovesPerDay + 1" times today
			else if (firstLoveAdd24 < timestampNow && firstLoveAdd48 > timestampNow){
				remainReal = (howManyEliminated.div(4)).add(freeRemainingLovesPerDay).add(1);
			}		
				/// This player didn't love for 48h, he can love "freeRemainingLovesPerDay + 1" today
				else if (firstLoveAdd48 < timestampNow){
					remainReal = freeRemainingLovesPerDay.add(1);
				}		
					else remainReal = 0;
			
		return (
			firstLove[_player],
			remainStored,
			remainReal
		); 
	}

	
	

/// Returns the unwithdrawn jackpot of a player for a GameId
	function player_getPlayerJackpot(
		address _player,
		uint256 _gameId
	) 
		public 
		view 
		returns (
			uint256 playerNowPot_,
			uint256 playerOldPot_
		)
	{
		return (
			winnersJackpot[gameVersion][_player],
			winnersJackpot[_gameId][_player]
		);
	}	


	
	
/// Returns informations for a country for previous games	
	function country_getOldInfoForCountry(uint256 _countryId, uint256 _gameId)
		public
		view
		returns (
			bool oldEliminatedBool_,
			uint256 oldMaxLovesForTheBest_
		) 
	{	
		LoverStructure storage c = loversSTR[_gameId][_countryId];
		
		return (
			eliminated[_gameId][_countryId],
			c.maxLoves[howManyNuked]
			);
	}
	
	
	
	
/// Returns informations for a country for previous games requiring more parameters	
	function loves_getOldNukesMaxLoves(
		uint256 _countryId,
		uint256 _gameId,
		uint256 _howManyNuked
	) 
		public view returns (uint256 oldMaxLovesForTheBest2_)
	{		
		return (loversSTR[_gameId][_countryId].maxLoves[_howManyNuked]);
	}	
	

	

/// Returns other informations for a country for previous games	
	function country_getCountriesGeneralInfo()
		public
		view
		returns (
			uint256 lastNuked_,
			address lastNukerAddress_,
			uint256 allCountriesLength_,
			uint256 howManyEliminated_,
			uint256 howManyNuked_,
			uint256 howManyReactivated_,
			uint256 mostLovedNation_
		) 
	{		
		return (
			lastNukedCountry,
			nukerAddress[lastNukedCountry],
			allCountriesLength,			
			howManyEliminated,
			howManyNuked,
			howManyReactivated,
			mostLovedCountry
			);
	}


	
	
/// Get the address of the king for a continent	
	function player_getKingOne(uint256 _continentId) public view returns (address king_) {		
		return continentKing[_continentId];
	}

	

	
/// Return all kings	
	function player_getKingsAll() public view returns (address[] _kings) {	
		
		uint256 kingsLength = continentKing.length;
		address[] memory kings = new address[](kingsLength);
		uint256 kingsCounter = 0;
			
		for (uint256 i = 0; i < kingsLength; i++) {
			kings[kingsCounter] = continentKing[i];
			kingsCounter++;				
		}
		
		return kings;
	}
	

	

/// Return lengths of arrays
	function constant_getLength()
		public
		view
		returns (
			uint256 kingsLength_,
			uint256 newOwnerLength_,
			uint256 nukerLength_
		)
	{		
		return (
			continentKing.length,
			newOwner.length,
			nukerAddress.length
		);
	}

	
	

/// Return the nuker's address - If a country was nuked twice (for example after a reanimation), we store the last nuker only
	function player_getNuker(uint256 _countryId) public view returns (address nuker_) {		
		return nukerAddress[_countryId];		
	}

	
	
	
/// How many countries were nuked by a player? 
/// Warning: if a country was nuked twice (for example after a reanimation), only the last nuker counts
	function player_howManyNuked(address _player) public view returns (uint256 nukeCount_) {		
		uint256 counter = 0;

		for (uint256 i = 0; i < nukerAddress.length; i++) {
			if (nukerAddress[i] == _player) {
				counter++;
			}
		}

		return counter;		
	}
	
	
	
	
/// Which countries were nuked by a player?	
	function player_getNukedCountries(address _player) public view returns (uint256[] myNukedCountriesIds_) {		
		
		uint256 howLong = player_howManyNuked(_player);
		uint256[] memory myNukedCountries = new uint256[](howLong);
		uint256 nukeCounter = 0;
		
		for (uint256 i = 0; i < allCountriesLength; i++) {
			if (nukerAddress[i] == _player){
				myNukedCountries[nukeCounter] = i;
				nukeCounter++;
			}

			if (nukeCounter == howLong){break;}
		}
		
		return myNukedCountries;
	}


	
	
/// Which percentage of the jackpot will the winners share?
	function constant_getPriZZZes() 
		public 
		view 
		returns (
			uint256 lastNukeShare_,
			uint256 countryOwnShare_,
			uint256 contintShare_,
			uint256 freePlayerShare_
		) 
	{
		return (
			lastNukerShare,
			winningCountryShare,
			continentShare,
			freePlayerShare
		);
	}

	
		
	
/// Returns the minimal jackpot part for each winner (if accurate)
/// Only accurate for the first game. If new games are started later, these values will be set to 0
	function constant_getPriZZZesMini()
		public
		view
		returns (
			uint256 lastNukeMini_,
			uint256 countryOwnMini_,
			uint256 contintMini_,
			uint256 freePlayerMini_,
			uint256 withdrMinOwner_
		)
	{
		return (
			lastNukerMin,
			countryOwnerMin,
			continentMin,
			freePlayerMin,
			withdrawMinOwner
		);
	}

	
	

/// Returns some values for the current game	
	function constant_getPrices()
		public 
		view 
		returns (
			uint256 nextPrice_,
			uint256 startingPrice_,
			uint256 kingPrice_,
			uint256 kNext_,
			uint256 kCountry_,
			uint256 kCountryLimit_,
			uint256 kKings_)
	{
		return (
			nextPrice[gameVersion],
			startingPrice,
			kingPrice,
			kNext,
			kCountry,
			kCountryLimit,
			kKings
		);
	}

	
	
	
/// Returns other values for the current game
	function constant_getSomeDetails()
		public
		view
		returns (
			bool gameRunng_,
			uint256 currentContractBalance_,
			uint256 jackptTimstmp_,
			uint256 maxFlip_,
			uint256 continentFlip_,
			bool jackpotNotWonYet_) 
	{
		return (
			gameRunning,
			address(this).balance,
			jackpotTimestamp,
			maxFlips,
			continentFlips,
			thisJackpotIsPlayedAndNotWon[gameVersion]
		);
	}

	
	

/// Returns some values for previous games	
	function constant_getOldDetails(uint256 _gameId)
		public
		view
		returns (
			uint256 oldWinningCountry_,
			bool oldJackpotBool_,
			uint256 oldNextPrice_
		) 
	{
		return (
			winningCountry[_gameId],
			thisJackpotIsPlayedAndNotWon[_gameId],
			nextPrice[_gameId]
		);
	}
	
	
	
	
/// Returns cuts
	function constant_getCuts()
		public
		view
		returns (
			uint256 playerCut_,
			uint256 potCutSC,
			uint256 developerCut_)
	{
		return (
			playerCut,
			potCutSuperCountries,
			devCut
		);
	}

	
	

/// Returns linked contracts addresses: SuperCountries core contract, Trophy Cards Contract
	function constant_getContracts() public view returns (address SuperCountries_, address TrophyCards_) {
		return (contractSC, contractTrophyCards);
	}	


	
	
/// Calculates the raw price of a next nuke
/// This value will be used to calculate a nuke price for a specified country depending of its market price
	function war_getNextNukePriceRaw() public view returns (uint256 price_) {
		
		if (nextPrice[gameVersion] != 0) {
			uint256 price = nextPrice[gameVersion];
		}
			else price = startingPrice;
		
		return price;		
	}

	
	
		
/// Calculates the exact price to nuke a country using the raw price (calculated above) and the market price of a country
	function war_getNextNukePriceForCountry(uint256 _countryId) public view returns (uint256 priceOfThisCountry_) {

		uint256 priceRaw = war_getNextNukePriceRaw();
		uint256 k = lastKnownCountryPrice[_countryId].mul(kCountry).div(100);
		
		if (k > kCountryLimit){
			uint256 priceOfThisCountry = priceRaw.add(kCountryLimit);
		}
			else priceOfThisCountry = priceRaw.add(k);				
	
		return priceOfThisCountry;		
	}
	

	

/// Returns all countries for a continent
	function country_getAllCountriesForContinent(uint256 _continentId) public view returns (uint256[] countries_) {					
		
		uint256 howManyCountries = country_countCountriesForContinent(_continentId);
		uint256[] memory countries = new uint256[](howManyCountries);
		uint256 countryCounter = 0;
				
		for (uint256 i = 0; i < allCountriesLength; i++) {
			if (countryToContinent[i] == _continentId){
				countries[countryCounter] = i;
				countryCounter++;						
			}	
				if (countryCounter == howManyCountries){break;}
		}

		return countries;
	}

	

	
/// Count all countries for a continent (standing and non standing)
	function country_countCountriesForContinent(uint256 _continentId) public view returns (uint256 howManyCountries_) {
		uint256 countryCounter = 0;
				
		for (uint256 i = 0; i < allCountriesLength; i++) {
			if (countryToContinent[i] == _continentId){
				countryCounter++;						
			}		
		}
		
		return countryCounter;
	}	


	
		
/// Return the ID of all STANDING countries for a continent (or not Standing if FALSE)
	function country_getAllStandingCountriesForContinent(
		uint256 _continentId,
		bool _standing
	) 
		public
		view
		returns (uint256[] countries_)
	{					
		uint256 howManyCountries = country_countStandingCountriesForContinent(_continentId, _standing);
		uint256[] memory countries = new uint256[](howManyCountries);
		uint256 countryCounter = 0;
		uint256 gameId = gameVersion;
				
		for (uint256 i = 0; i < allCountriesLength; i++) {
			if (countryToContinent[i] == _continentId && eliminated[gameId][i] != _standing){
				countries[countryCounter] = i;
				countryCounter++;						
			}	
				if (countryCounter == howManyCountries){break;}
		}

		return countries;
	}	

	


/// Count all STANDING countries for a continent (or not Standing if FALSE)	
	function country_countStandingCountriesForContinent(
		uint256 _continentId,
		bool _standing
	)
		public
		view
		returns (uint256 howManyCountries_)
	{
		uint256 standingCountryCounter = 0;
		uint256 gameId = gameVersion;
				
		for (uint256 i = 0; i < allCountriesLength; i++) {
			if (countryToContinent[i] == _continentId && eliminated[gameId][i] != _standing){
				standingCountryCounter++;						
			}		
		}
		
		return standingCountryCounter;
	}


	
	
/// Calculate the jackpot to share between all winners
/// realJackpot: the real value to use when sharing
/// expected: this is the jackpot as we should expect if there was no minimal guarantee. It can be different from the real one if we have not reached the minimal value yet. 
/// WARNING: between the real and the expected, the REAL one is the only value to use ; the expected one is for information only and will never be used in any calculation
	function calculateJackpot()
		public
		view
		returns (
			uint256 nukerJackpot_,
			uint256 countryJackpot_,
			uint256 continentJackpot_,
			uint256 freeJackpot_,
			uint256 realJackpot_,
			uint256 expectedJackpot_
		)
	{
		/// If thisJackpot = false, that would mean it was already won or not yet played,
		///	if true it's currently played and not won yet
		if (thisJackpotIsPlayedAndNotWon[gameVersion] != true) {
			uint256 nukerJPT = 0;
			uint256 countryJPT = 0;
			uint256 continentJPT = 0;
			uint256 freeJPT = 0;
			uint256 realJackpotToShare = 0;
			uint256 expectedJackpotFromRates = 0;
		}
		
			else {
				uint256 devGift = lastNukerMin.add(countryOwnerMin).add(continentMin).add(freePlayerMin);
				expectedJackpotFromRates = ((address(this).balance).add(withdrawMinOwner).sub(devGift)).div(10000);
				
					uint256 temp_share = expectedJackpotFromRates.mul(lastNukerShare);
					if (temp_share > lastNukerMin){
						nukerJPT = temp_share;
					} else nukerJPT = lastNukerMin;
					
					temp_share = expectedJackpotFromRates.mul(winningCountryShare);
					if (temp_share > countryOwnerMin){
						countryJPT = temp_share;
					} else countryJPT = countryOwnerMin;

					temp_share = expectedJackpotFromRates.mul(continentShare);
					if (temp_share > continentMin){
						continentJPT = temp_share;
					} else continentJPT = continentMin;

					temp_share = expectedJackpotFromRates.mul(freePlayerShare);
					if (temp_share > freePlayerMin){
						freeJPT = temp_share;
					} else freeJPT = freePlayerMin;		
				
					realJackpotToShare = nukerJPT.add(countryJPT).add(continentJPT).add(freeJPT);
			}
		
		return (
			nukerJPT,
			countryJPT,
			continentJPT,
			freeJPT,
			realJackpotToShare,
			expectedJackpotFromRates.mul(10000)
		);	
	}


	

/// Calculate how much the dev can withdraw now
/// If the dev funded a minimal guarantee, he can withdraw gradually its funding when jackpot rises up to its funding amount
	function whatDevCanWithdraw() public view returns(uint256 toWithdrawByDev_){
		uint256 devGift = lastNukerMin.add(countryOwnerMin).add(continentMin).add(freePlayerMin);
		uint256 balance = address(this).balance;
		
		(,,,,uint256 jackpotToDispatch,) = calculateJackpot();
		uint256 leftToWithdraw = devGift.sub(withdrawMinOwner);
		uint256 leftInTheContract = balance.sub(jackpotToDispatch);
			
		if (leftToWithdraw > 0 && balance > jackpotToDispatch){
			/// ok he can still withdraw
			if (leftInTheContract > leftToWithdraw){
				uint256 devToWithdraw = leftToWithdraw;				
			} else devToWithdraw = leftInTheContract;			
		}
		
		return devToWithdraw;
	}




	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
//////////////////////////
/// INTERNAL FUNCTIONS ///
//////////////////////////

/// Heavy pay function for Nukes ///
	function payCuts(
		uint256 _value,
		uint256 _balance,
		uint256 _countryId,
		uint256 _timestamp
	) 
		internal
	{
		require(_value <= _balance);
		require(_value != 0);
		
		/// Get the next trophy card owner to send cuts
		address nextTrophyOwner = nextTrophyCardUpdateAndGetOwner();
		
			if (nextTrophyOwner == 0) {
				nextTrophyOwner = owner;
			}
		
		
		/// Get the country owner to send cuts
		address countryOwner = newOwner[_countryId];
		
			if (countryOwner == 0) {
				countryOwner = owner;
			}		

			
		/// Get the best lover to send cuts
		address bestLoverToGetDivs = loversSTR[gameVersion][_countryId].bestLover;
		
			if (bestLoverToGetDivs == 0) {
				bestLoverToGetDivs = owner;
			}

			
		/// Calculate cuts
		uint256 devCutPay = _value.mul(devCut).div(1000);
		uint256 superCountriesPotCutPay = _value.mul(potCutSuperCountries).div(1000);
		uint256 trophyAndOwnerCutPay = _value.mul(playerCut).div(1000);
		
		
		/// Pay cuts ///			
		owner.transfer(devCutPay);
		contractSC.transfer(superCountriesPotCutPay);
		nextTrophyOwner.transfer(trophyAndOwnerCutPay);
		countryOwner.transfer(trophyAndOwnerCutPay);
		bestLoverToGetDivs.transfer(trophyAndOwnerCutPay);
		
		emit CutsPaidInfos(_timestamp, _countryId, countryOwner, nextTrophyOwner, bestLoverToGetDivs);
		emit CutsPaidValue(_timestamp, _value, address(this).balance, devCutPay, trophyAndOwnerCutPay, superCountriesPotCutPay);
		
		assert(_balance.sub(_value) <= address(this).balance); 
		assert((trophyAndOwnerCutPay.mul(3).add(devCutPay).add(superCountriesPotCutPay)) < _value);	
	}



/// Light pay function for Kings ///
	function payCutsLight(
		uint256 _value,
		uint256 _balance,
		uint256 _timestamp
	) 
		internal
	{
		require(_value <= _balance);
		require(_value != 0);		

		/// Get the next trophy card owner to send cuts
		address nextTrophyOwner = nextTrophyCardUpdateAndGetOwner();
		
			if (nextTrophyOwner == 0) {
				nextTrophyOwner = owner;
			}

		/// Get the last nuker to send cuts
		address lastNuker = nukerAddress[lastNukedCountry];
		
			if (lastNuker == 0) {
				lastNuker = owner;
			}			
			
			
		/// Calculate cuts
		uint256 trophyCutPay = _value.mul(playerCut).div(1000);
		uint256 superCountriesPotCutPay = ((_value.mul(potCutSuperCountries).div(1000)).add(trophyCutPay)).div(2); /// Divide by 2: one part for SCPot, one for lastNuker
		uint256 devCutPay = (_value.mul(devCut).div(1000)).add(trophyCutPay);			

		
		/// Pay cuts ///			
		owner.transfer(devCutPay);
		contractSC.transfer(superCountriesPotCutPay);
		lastNuker.transfer(superCountriesPotCutPay);
		nextTrophyOwner.transfer(trophyCutPay);
		
		emit CutsPaidLight(_timestamp, _value, address(this).balance, devCutPay, trophyCutPay, nextTrophyOwner, superCountriesPotCutPay);
		
		assert(_balance.sub(_value) <= address(this).balance); 
		assert((trophyCutPay.add(devCutPay).add(superCountriesPotCutPay)) < _value);
	}
	

	
/// Refund the nuker / new king if excess
	function excessRefund(
		address _payer,
		uint256 _priceToPay,
		uint256 paidPrice
	) 
		internal
	{		
		uint256 excess = paidPrice.sub(_priceToPay);
		
		if (excess > 0) {
			_payer.transfer(excess);
		}
	}		
	
	
	
/// Update the jackpot timestamp each time a country is nuked or a new king crowned	
	function updateJackpotTimestamp(uint256 _timestamp) internal {		

		jackpotTimestamp = _timestamp.add(604800);  /// 1 week
		
		emit NewJackpotTimestamp(jackpotTimestamp, _timestamp);			
	}



/// If first love > 24h, the player can love again
/// and get extra loves if loved yesterday
	function updateLovesForToday(address _player, uint256 _timestampNow) internal {		
		
		uint256 firstLoveAdd24 = firstLove[_player].add(SLONG);
		uint256 firstLoveAdd48 = firstLove[_player].add(DLONG);
		uint256 remainV = remainingLoves[_player];
		
		/// This player loved today but has some loves left
		if (firstLoveAdd24 > _timestampNow && remainV > 0){
			remainingLoves[_player] = remainV.sub(1);
		}
			/// This player loved yesterday but not today
			else if (firstLoveAdd24 < _timestampNow && firstLoveAdd48 > _timestampNow){
				remainingLoves[_player] = (howManyEliminated.div(4)).add(freeRemainingLovesPerDay);
				firstLove[_player] = _timestampNow;
			}
		
				/// This player didn't love for 48h, he can love today
				else if (firstLoveAdd48 < _timestampNow){
					remainingLoves[_player] = freeRemainingLovesPerDay;
					firstLove[_player] = _timestampNow;
				}	
					/// This player is a zombie
					else remainingLoves[_player] = 0;

	}

	
	
	
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
////////////////////////////////////
/// 	WAR - PUBLIC FUNCTIONS	 ///
////////////////////////////////////

//////////////////////
/// NUKE A COUNTRY ///
//////////////////////
	function nuke(uint256 _countryId) payable public onlyGameNOTPaused{
		require(_countryId < allCountriesLength);
		require(msg.value >= war_getNextNukePriceForCountry(_countryId)); 
		require(war_getNextNukePriceForCountry(_countryId) > 0); 
		require(isEliminated(_countryId) == false);
		require(canPlayTimestamp()); /// Impossible to nuke 2 hours after the jackpot
		require(loversSTR[gameVersion][_countryId].bestLover != msg.sender); /// The best lover cannot nuke his favorite country
		require(_countryId != mostLovedCountry || allCountriesLength.sub(howManyEliminated) < 5); /// We cannot nuke the mostLovedCountry if more than 4 countries stand
				
		address player = msg.sender;
		uint256 timestampNow = block.timestamp;
		uint256 gameId = gameVersion;
		uint256 thisBalance = address(this).balance;		
		uint256 priceToPay = war_getNextNukePriceForCountry(_countryId);
		
		/// Update the latest nuker of the game in the nukerAddress array
		nukerAddress[_countryId] = player;
		
		/// Get last known price of this country for next time
		uint256 lastPriceOld = lastKnownCountryPrice[_countryId];
		lastKnownCountryPrice[_countryId] = getPriceOfCountry(_countryId);
		
		/// Change the activation of this country
		eliminated[gameId][_countryId] = true;
		howManyEliminated++;
		
		if (howManyEliminated.add(1) == allCountriesLength){
			jackpotTimestamp = block.timestamp;
			emit LastCountryStanding(_countryId, player, thisBalance, gameId, jackpotTimestamp);
		}	
			else {
				/// Update next price
				uint priceRaw = war_getNextNukePriceRaw();			
				nextPrice[gameId] = priceRaw.mul(kNext).div(1000);
				
				/// and update the jackpot
				updateJackpotTimestamp(timestampNow);
			}
							
		lastNukedCountry = _countryId;		
		payCuts(priceToPay, thisBalance, _countryId, timestampNow);
		excessRefund(player, priceToPay, msg.value);
		howManyNuked++;
		
		/// emit the event
		emit Nuked(player, _countryId, priceToPay, priceRaw);
		emit PlayerEvent(1, _countryId, player, timestampNow, howManyEliminated, gameId);

		assert(lastKnownCountryPrice[_countryId] >= lastPriceOld);
	}

	
	
///////////////////////////
/// REANIMATE A COUNTRY ///
///////////////////////////	
	function reanimateCountry(uint256 _countryId) public onlyGameNOTPaused{
		require(canPlayerReanimate(_countryId, msg.sender) == true);
		
		address player = msg.sender;
		eliminated[gameVersion][_countryId] = false;
		
		newOwner[_countryId] = player;
		
		howManyEliminated = howManyEliminated.sub(1);
		howManyReactivated++;
		
		emit Reactivation(_countryId, howManyReactivated);
		emit PlayerEvent(2, _countryId, player, block.timestamp, howManyEliminated, gameVersion);		
	} 



/////////////////////
/// BECOME A KING ///
/////////////////////		
	function becomeNewKing(uint256 _continentId) payable public onlyGameNOTPaused{
		require(msg.value >= kingPrice);
		require(canPlayTimestamp()); /// Impossible to play 2 hours after the jackpot
				
		address player = msg.sender;
		uint256 timestampNow = block.timestamp;
		uint256 gameId = gameVersion;
		uint256 thisBalance = address(this).balance;
		uint256 priceToPay = kingPrice;
		
		continentKing[_continentId] = player;
		
		updateJackpotTimestamp(timestampNow);

		if (continentFlips >= maxFlips){
			kingPrice = priceToPay.mul(kKings).div(100);
			continentFlips = 0;
			emit NewKingPrice(kingPrice, kKings);
			} else continentFlips++;
		
		payCutsLight(priceToPay, thisBalance, timestampNow);
		
		excessRefund(player, priceToPay, msg.value);
		
		/// emit the event
		emit NewKingContinent(player, _continentId, priceToPay);
		emit PlayerEvent(3, _continentId, player, timestampNow, continentFlips, gameId);		
	}	



//////////////////////////////	
/// SEND LOVE TO A COUNTRY ///
//////////////////////////////	
/// Everybody can love few times a day, and get extra loves if loved yesterday
	function upLove(uint256 _countryId) public onlyGameNOTPaused{
		require(canPlayerLove(msg.sender)); 
		require(_countryId < allCountriesLength);	
		require(!isEliminated(_countryId)); /// We cannot love an eliminated country
		require(block.timestamp.add(DSHORT) < jackpotTimestamp || block.timestamp > jackpotTimestamp.add(DSHORT)); 
	
		address lover = msg.sender;
		address countryOwner = getCountryOwner(_countryId);
		uint256 gameId = gameVersion;
		
		LoverStructure storage c = loversSTR[gameId][_countryId];
		uint256 nukecount = howManyNuked;
		
		/// Increase the number of loves for this lover for this country
		c.loves[nukecount][lover]++;
		uint256 playerLoves = c.loves[nukecount][lover];
		uint256 maxLovesBest = c.maxLoves[nukecount];
				
		/// Update the bestlover if this is the case
		if 	(playerLoves > maxLovesBest){
			c.maxLoves[nukecount]++;
			
			/// Update the mostLovedCountry
			if (_countryId != mostLovedCountry && playerLoves > loversSTR[gameId][mostLovedCountry].maxLoves[nukecount]){
				mostLovedCountry = _countryId;
				
				emit newMostLovedCountry(_countryId, playerLoves);
			}
			
			/// If the best lover is a new bets lover, update
			if (c.bestLover != lover){
				c.bestLover = lover;
				
				/// Send a free love to the king of this continent if he is not the best lover and remaining loves lesser than 16
				address ourKing = continentKing[countryToContinent[_countryId]];
				if (ourKing != lover && remainingLoves[ourKing] < 16){
				remainingLoves[ourKing]++;
				}
			}
			
			emit NewBestLover(lover, _countryId, playerLoves);
		}
		
		/// Update the ownership if this is the case
		if (newOwner[_countryId] != countryOwner){
			newOwner[_countryId] = countryOwner;
			emit ThereIsANewOwner(countryOwner, _countryId);
		}		
		
		/// Update the number of loves for today
		updateLovesForToday(lover, block.timestamp);
		
		/// Emit the event		
		emit NewLove(lover, _countryId, playerLoves, gameId, nukecount);
	}
	
	
	


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
////////////////////////
/// UPDATE FUNCTIONS ///
////////////////////////

/// Get the price of all countries before the start of the game
	function storePriceOfAllCountries(uint256 _limitDown, uint256 _limitUp) public onlyOwner {
		require (_limitDown < _limitUp);
		require (_limitUp <= allCountriesLength);
		
		uint256 getPrice;
		address getTheOwner;
		
		for (uint256 i = _limitDown; i < _limitUp; i++) {
			getPrice = getPriceOfCountry(i);
			getTheOwner = getCountryOwner(i);
			
			lastKnownCountryPrice[i] = getPrice;
			newOwner[i] = getTheOwner;
			
			if (getPrice == 0 || getTheOwner ==0){
				emit ErrorCountry(i);
			}
		}
	}

	
	

/// Update cuts ///	
/// Beware, cuts are PERTHOUSAND, not percent
	function updateCuts(uint256 _newDevcut, uint256 _newPlayercut, uint256 _newSuperCountriesJackpotCut) public onlyOwner {
		require(_newPlayercut.mul(3).add(_newDevcut).add(_newSuperCountriesJackpotCut) <= 700);
		require(_newDevcut > 100);		
		
		devCut = _newDevcut;
		playerCut = _newPlayercut;
		potCutSuperCountries = _newSuperCountriesJackpotCut;

		emit CutsUpdated(_newDevcut, _newPlayercut, _newSuperCountriesJackpotCut, block.timestamp);
		
	}

	


/// Change nuke and kings prices and other price parameters
	function updatePrices(
		uint256 _newStartingPrice,
		uint256 _newKingPrice,
		uint256 _newKNext,
		uint256 _newKCountry,
		uint256 _newKLimit,
		uint256 _newkKings,
		uint256 _newMaxFlips
	)
		public 
		onlyOwner
	{
		startingPrice = _newStartingPrice;
		kingPrice = _newKingPrice;
		kNext = _newKNext;
		kCountry = _newKCountry;
		kCountryLimit = _newKLimit;
		kKings = _newkKings;
		maxFlips = _newMaxFlips;

		emit ConstantsUpdated(_newStartingPrice, _newKingPrice, _newKNext, _newKCountry, _newKLimit, _newkKings, _newMaxFlips);		
	}


	

/// Change various parameters
	function updateValue(uint256 _code, uint256 _newValue) public onlyOwner {					
		if (_code == 1 ){
			continentKing.length = _newValue;
		} 
			else if (_code == 2 ){
				allCountriesLength = _newValue;
			} 
				else if (_code == 3 ){
					freeRemainingLovesPerDay = _newValue;
					} 		
		
		emit NewValue(_code, _newValue, block.timestamp);		
	}




/// Store countries into continents - multi countries for 1 continent function
	function updateCountryToContinentMany(uint256[] _countryIds, uint256 _continentId) external onlyOwner {					
		for (uint256 i = 0; i < _countryIds.length; i++) {
			updateCountryToContinent(_countryIds[i], _continentId);
		}		
	}




/// Store countries into continents	- 1 country for 1 continent function
	function updateCountryToContinent(uint256 _countryId, uint256 _continentId) public onlyOwner {					
		require(_countryId < allCountriesLength);
		require(_continentId < continentKing.length);
		
		countryToContinent[_countryId] = _continentId;
		
		emit NewCountryToContinent(_countryId, _continentId, block.timestamp);		
	}


	
	
/// If needed, update the external Trophy Cards contract address
	function updateTCContract(address _newAddress) public onlyOwner() {
		contractTrophyCards = _newAddress;
		SCTrophy = SuperCountriesTrophyCardsExternal(_newAddress);
		
		emit NewContractAddress(_newAddress);			
	}





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
/////////////////////////////////
/// WIN THE JACKPOT FUNCTIONS ///
/////////////////////////////////	


	function jackpotShareDispatch(
		address _winner,
		uint256 _share,
		uint256 _customValue,
		bytes32 _customText
	) 
		internal
		returns (uint256 shareDispatched_)
	{
		if (_winner == 0){
			_winner = owner;
		}
		
		uint256 potDispatched = _share;								
		winnersJackpot[gameVersion][_winner] += _share;	
		
		emit JackpotDispatch(_winner, _share, _customValue, _customText);

		return potDispatched;
	}
	
	


/// Internal jackpot function for Country Owners ///
	function jackpotCountryReward(uint256 _countryPot) internal returns (uint256 winningCountry_, uint256 dispatched_){
		
		/// Is there a last standing country or not?
		uint256 potDispatched;
		
		if (howManyStandingOrNot(true) == 1){
			
			/// There is only one country left: the winning country is the last standing country
			/// And the owner of this country will not share the countryPot with other owners, all is for him!
			uint256 winningCountryId = lastStanding();
			address tempWinner = newOwner[winningCountryId];
			potDispatched = jackpotShareDispatch(tempWinner, _countryPot, winningCountryId, "lastOwner");
		} 	
			else {
				/// if else, there is more than one country standing, 
				/// we will reward the standing countries of the last nuked country continent
				winningCountryId = lastNukedCountry;
				uint256 continentId = countryToContinent[winningCountryId];
				
				uint256[] memory standingNations = country_getAllStandingCountriesForContinent(continentId, true);
				uint256 howManyCountries = standingNations.length;
				
				/// If there is at least one standing country in this continent
				if (howManyCountries > 0) {
				
					uint256 winningCounter;
					uint256 countryPotForOne = _countryPot.div(howManyCountries);
					
					for (uint256 i = 0; i < howManyCountries && potDispatched <= _countryPot; i++) {
						
						uint256 tempCountry = standingNations[i];
						/// Get the current owner
						tempWinner = newOwner[tempCountry];
						potDispatched += jackpotShareDispatch(tempWinner, countryPotForOne, tempCountry, "anOwner");
						winningCounter++;
						
						if (winningCounter == howManyCountries || potDispatched.add(countryPotForOne) > _countryPot){
							break;
						}
					}
				}
					
					/// There is no standing country in this continent, the owner of the last nuked country wins the jackpot (owner's share)
					else {
						tempWinner = newOwner[winningCountryId];
						potDispatched = jackpotShareDispatch(tempWinner, _countryPot, winningCountryId, "lastNukedOwner");
						
					}
				}	
			
		return (winningCountryId, potDispatched);
	}




	
/// PUBLIC JACKPOT FUNCTION TO CALL TO SHARE THE JACKPOT
/// After the jackpot, anyone can call the jackpotWIN function, it will dispatch prizes between winners
	function jackpotWIN() public onlyGameNOTPaused {
		require(block.timestamp > jackpotTimestamp); /// True if latestPayer + 7 days or Only one country standing
		require(address(this).balance >= 1e11);
		require(thisJackpotIsPlayedAndNotWon[gameVersion]); /// if true, we are currently playing this jackpot and it's not won yet 
		
		uint256 gameId = gameVersion;
		
		/// Pause the game
		gameRunning = false;

		
		///////////////////////////////////////////////
		////////// How much for the winners? //////////
		///////////////////////////////////////////////	
		
		/// Calculate shares
		(uint256 nukerPot, uint256 countryPot, uint256 continentPot, uint256 freePot, uint256 pot,) = calculateJackpot();
		
		/// This jackpot is won, disable it
		/// If false, this function will not be callable again
		thisJackpotIsPlayedAndNotWon[gameId] = false;		

				
		////////////////////////////////////////////////////
		////////// Which country won the jackpot? //////////
		////////////////////////////////////////////////////

		/// Dispatch shares between country owners and save the winning country ///	
		(uint256 winningCountryId, uint256 potDispatched) = jackpotCountryReward(countryPot);	
		winningCountry[gameId] = winningCountryId;
		uint256 continentId = countryToContinent[winningCountryId];

			
		////////////////////////////////////////////////
		////////// Who are the other winners? //////////
		////////////////////////////////////////////////	

		/// The king of the right continent
		potDispatched += jackpotShareDispatch(continentKing[continentId], continentPot, continentId, "continent");
		
		
		/// The best lover for this country
		potDispatched += jackpotShareDispatch(loversSTR[gameId][winningCountryId].bestLover, freePot, 0, "free");
		
		
		/// The last nuker
		potDispatched += jackpotShareDispatch(nukerAddress[winningCountryId], nukerPot, 0, "nuker");
			
				
		/// Emit the events ///
		emit JackpotDispatchAll(gameId, winningCountryId, continentId, block.timestamp, jackpotTimestamp, pot, potDispatched, address(this).balance);
		emit PausedOrUnpaused(block.timestamp, gameRunning);

		
		/// Last check ///
		assert(potDispatched <= address(this).balance);		
	}
			

			

/// After the sharing, all winners will be able to call this function to withdraw the won share to the their wallets
	function withdrawWinners() public onlyRealAddress {
		require(winnersJackpot[gameVersion][msg.sender] > 0);
		
		address _winnerAddress = msg.sender;
        uint256 gameId = gameVersion;
		
        /// Prepare for the withdrawal
		uint256 jackpotToTransfer = winnersJackpot[gameId][_winnerAddress];
		winnersJackpot[gameId][_winnerAddress] = 0;
		
        /// fire event
        emit WithdrawJackpot(_winnerAddress, jackpotToTransfer, gameId);
		
		/// Withdraw
        _winnerAddress.transfer(jackpotToTransfer);
	}


	

	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		

///////////////////////////////
///		RESTART A NEW GAME 	///
///////////////////////////////	

/// After the jackpot, restart a new game with same settings ///
/// The owner can restart 2 hrs after the jackpot
/// If the owner doesn't restart the game 30 days after the jackpot, all players can restart the game
	function restartNewGame() public onlyGamePaused{
		require((msg.sender == owner && block.timestamp > jackpotTimestamp.add(DSHORT)) || block.timestamp > jackpotTimestamp.add(2629000));
		
		uint256 timestampNow = block.timestamp;
		
		/// Clear all values, loves, nextPrices...	but bestlovers, lovers will remain
		if (nextPrice[gameVersion] !=0){
			gameVersion++;
			lastNukedCountry = 0;
			howManyNuked = 0;
			howManyReactivated = 0;
			howManyEliminated = 0;
			
			lastNukerMin = 0;
			countryOwnerMin = 0;
			continentMin = 0;
			freePlayerMin = 0;
			withdrawMinOwner = 0;

			kingPrice = 1e16;
			
			newOwner.length = 0;
			nukerAddress.length = 0;
			newOwner.length = allCountriesLength;
			nukerAddress.length = allCountriesLength;
		}
		
		/// Set new jackpot timestamp
		updateJackpotTimestamp(timestampNow);
		
		/// Restart
		gameRunning = true;	
		thisJackpotIsPlayedAndNotWon[gameVersion] = true;

        /// fire event
        emit NewGameLaunched(gameVersion, timestampNow, msg.sender, jackpotTimestamp);
		emit PausedOrUnpaused(block.timestamp, gameRunning);		
	}

	



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
////////////////////////
/// USEFUL FUNCTIONS ///
////////////////////////

  /** 
   * @dev Fallback function to accept all ether sent directly to the contract
   * Nothing is lost, it will raise the jackpot!
   */
	function() payable public {    }	




	
/// After the jackpot, the owner can restart a new game or withdraw if winners don't want their part
	function withdraw() public onlyOwner {
		require(block.timestamp > jackpotTimestamp.add(DSHORT) || address(this).balance <= 1e11 || whatDevCanWithdraw() > 0);
		
		uint256 thisBalance = address(this).balance;
		
		if (block.timestamp > jackpotTimestamp.add(DSHORT) || thisBalance <= 1e11 ){
			uint256 toWithdraw = thisBalance;
		}
		
		else {
			
			toWithdraw = whatDevCanWithdraw();
			withdrawMinOwner += toWithdraw;
		}			
		
		emit WithdrawByDev(block.timestamp, toWithdraw, withdrawMinOwner, thisBalance);
		
		owner.transfer(toWithdraw);	
	}

	



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////
/// LAST STANDING FUNCTIONS ///
///////////////////////////////	

	function trueStandingFalseEliminated(bool _standing) public view returns (uint256[] countries_) {
		uint256 howLong = howManyStandingOrNot(_standing);
		uint256[] memory countries = new uint256[](howLong);
		uint256 standingCounter = 0;
		uint256 gameId = gameVersion;
		
		for (uint256 i = 0; i < allCountriesLength; i++) {
			if (eliminated[gameId][i] != _standing){
				countries[standingCounter] = i;
				standingCounter++;
			}

			if (standingCounter == howLong){break;}
		}
		
		return countries;
	}	

	

	
	function howManyStandingOrNot(bool _standing) public view returns (uint256 howManyCountries_) {
		uint256 standingCounter = 0;
		uint256 gameId = gameVersion;
		
		for (uint256 i = 0; i < allCountriesLength; i++) {
			if (eliminated[gameId][i] != _standing){
				standingCounter++;
			}					
		}	
		
		return standingCounter;
	}

	

	
	function lastStanding() public view returns (uint256 lastStandingNation_) {
		require (howManyStandingOrNot(true) == 1);

		return trueStandingFalseEliminated(true)[0];
	}
	
}
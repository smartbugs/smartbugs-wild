pragma solidity ^0.4.24;

contract BO3Kevents {
	event onBuying ( 
		address indexed _addr, 
		uint256 ethAmount, 
		uint256 flagAmount,
		uint256 playerFlags,
		uint256 ethOfRound,
		uint256 keysOfRound,
		uint256 potOfRound
	);

	event onTimeAdding(
		uint256 startTime,
		uint256 endTime,
		uint256 newTimeInterval,
		uint256 currentInterval
	);

	event onDiscount(
		address indexed _addr,
		uint256 randomValue,
		uint256 discountValue,
		bool getDiscount
	);

	event onRoundEnding(
		address indexed winnerAddr,
		uint teamID,
		uint256 winValue,
		uint256 soldierValue,
		uint256 teamValue,
		uint256 nextRoundStartTime,
		uint256 nextRoundEndTime,
		uint256 nextRoundPot
	);

	event onWithdraw(
		address indexed withdrawAddr,
		uint256 discountRevenue,
		uint256 refferedRevenue,
		uint256 winRevenue,
		uint256 flagRevenue
	);
	
}

contract modularLong is BO3Kevents {}

contract BO3KMain is modularLong {

	using SafeMath for *;
	using BO3KCalcLong for uint256;

	address constant public Admin = 0x3ac98F5Ea4946f58439d551E20Ed12091AF0F597;
	uint256 constant public LEADER_FEE = 0.03 ether;

	uint256 private adminFee = 0;
	uint256 private adminRevenue = 0;
	uint256 private winTeamValue = 0;

	uint private winTeamID = 0;

	string constant public name = "Blockchain of 3 Kindoms";
    string constant public symbol = "BO3K";

	uint256 constant private DISCOUNT_PROB = 200;

	uint256 constant private DISCOUNT_VALUE_5PER_OFF = 50;
	uint256 constant private DISCOUNT_VALUE_10PER_OFF = 100;
	uint256 constant private DISCOUNT_VALUE_15PER_OFF = 150;

	uint256 constant private DENOMINATOR = 1000;

	uint256 constant private _nextRoundSettingTime = 1 hours;                
    uint256 constant private _flagBuyingInterval = 30 seconds;              
    uint256 constant private _maxDuration = 24 hours;

    uint256 constant private _officerCommission = 150;

    bool _activated = false;
    bool mutex = false;

    uint256 public roundID;
    uint public _teamID;

   	BO3Kdatasets.PotSplit potSplit;
   	BO3Kdatasets.FlagInfo Flag;

    mapping (uint256 => BO3Kdatasets.Team) team;
    mapping (uint256 => mapping (uint256 => BO3Kdatasets.TeamData) ) teamData;

    mapping (uint256 => BO3Kdatasets.Round) round;

    mapping (uint256 => mapping (address => BO3Kdatasets.Player) ) player;
    mapping (address => uint256) playerFlags;
    

	constructor () public {

		team[1] = BO3Kdatasets.Team(0, 500, 250, 150, 50, 50, 0, 0 );
		team[2] = BO3Kdatasets.Team(1, 250, 500, 150, 50, 50, 0, 0 );
		team[3] = BO3Kdatasets.Team(2, 375, 375, 150, 50, 50, 0, 0 );


		potSplit = BO3Kdatasets.PotSplit(450, 450, 50, 50);

		// to-do: formation of flag and time update
		Flag = BO3Kdatasets.FlagInfo( 10000000000000000, now );
	}


	modifier isActivated() { 
		require ( _activated == true, "Did not activated" );
		_; 
	}


	modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        // size of the code at address _addre
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "Addresses not owned by human are forbidden");
        _;
    }


    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 100000000000, "ground limit");
        require(_eth <= 100000000000000000000000, "floor limit");
        _;    
    }

    modifier isPlayerRegistered(uint256 _roundID, address _addr) {
    	require (player[_roundID][_addr].hasRegistered, "The Player Has Not Registered!");
    	_;
    }
	

	function buyFlag( uint _tID, address refferedAddr ) isActivated() isHuman() isWithinLimits(msg.value) public payable {

		require( 
			_tID == 1 ||
			_tID == 2 ||
			_tID == 3 ,
			"Invalid Team ID!"
		);
		
		// core( msg.sender, msg.value, _teamID );
		uint256 _now = now;
		
		_teamID = _tID;

		// if it's around the legal time
		if( isLegalTime( _now ) ) {

			// main logic of buying
			buyCore( refferedAddr );

			// 30 sec interval
			updateTimer();

		} else {

			if( !isLegalTime( _now ) && round[roundID].ended == false ) {
				round[roundID].ended = true;
				endRound();
			} else {
				revert();
			}

			// to-do:rcountdown for 1 hour to cool down

		}
	}



	function buyCore( address refferedAddr) isActivated() isWithinLimits( msg.value ) private {
		
		// flag formula
		if( player[roundID][refferedAddr].isGeneral == false ) {
			refferedAddr = address(0);
		}

		address _addr = msg.sender;
		uint256 _value = msg.value;

		uint256 flagAmount = (round[roundID].totalEth).keysRec( _value );
		require ( flagAmount >= 10 ** 18, "At least 1 whole flag" );

		// discount info
		bool getDiscount = false;

		// update data of the round, contains total eth, total flags, and pot value
		round[roundID].totalEth = ( round[roundID].totalEth ).add( _value );
		round[roundID].totalFlags = ( round[roundID].totalFlags ).add( flagAmount );

		// distribute value to the pot of the round. 50%, 25%, 37.5%, respectively
		round[roundID].pot = ( round[roundID].pot ).add( ( _value.mul( team[_teamID].city ) ).div( DENOMINATOR ) );

		// update data of the team, contains total eth, total flags
		team[_teamID].totalEth = ( team[_teamID].totalEth ).add( _value );
		team[_teamID].totalFlags = ( team[_teamID].totalFlags ).add( flagAmount );

		teamData[roundID][_teamID].totalEth = ( teamData[roundID][_teamID].totalEth ).add( _value );
		teamData[roundID][_teamID].totalFlags = ( teamData[roundID][_teamID].totalFlags ).add( flagAmount );

		// if the user has participated in before, just add the total flag to the player
		if( player[roundID][_addr].hasRegistered ) {
			player[roundID][_addr].flags += flagAmount;

		} else {

			// user data
			player[roundID][_addr] = BO3Kdatasets.Player({
				addr: _addr,
				flags: flagAmount,
				win: 0,
				refferedRevenue: 0,
				discountRevenue: 0,
				teamID: _teamID,
				generalID: 0,
				payMask: 0,
				hasRegistered: true,
				isGeneral: false,
				isWithdrawed: false
			});
		}

		// player's flags
		playerFlags[_addr] += flagAmount;

		// winner ID of the round
		round[roundID].playerID = _addr;

		// random discount
		uint256 randomValue = random();
		uint256 discountValue = 0;

		// discount judgement
		if( randomValue < team[_teamID].grain ) {

			if( _value >= 10 ** 17 && _value < 10 ** 18 ) {
				discountValue = (_value.mul( DISCOUNT_VALUE_5PER_OFF )).div( DENOMINATOR );
			} else if( _value >= 10 ** 18 && _value < 10 ** 19 ) {
				discountValue = (_value.mul( DISCOUNT_VALUE_10PER_OFF )).div( DENOMINATOR );
			} else if( _value >= 10 ** 19 ) {
				discountValue = (_value.mul( DISCOUNT_VALUE_15PER_OFF )).div( DENOMINATOR );
			} 
			// _addr.transfer( discountValue );

			// add to win bonus if getting discount 
			player[roundID][_addr].discountRevenue = (player[roundID][_addr].discountRevenue).add( discountValue );
			getDiscount = true;
		}

		// distribute the eth values
		// the distribution ratio differs from reffered address
		uint256 soldierEarn;

		// flag distribution
		if( refferedAddr != address(0) && refferedAddr != _addr ) {
			
			// 25%, 50%, 37.5% for soldier, respectively
            soldierEarn = (((_value.mul( team[_teamID].soldier ) / DENOMINATOR).mul(1000000000000000000)) / (round[roundID].totalFlags)).mul(flagAmount)/ (1000000000000000000);

			// 5% for admin
			adminFee += ( _value.mul( team[_teamID].teamWelfare ) ).div( DENOMINATOR );

			// 15% for officer
			player[roundID][refferedAddr].refferedRevenue += ( _value.mul( team[_teamID].officer ) ).div( DENOMINATOR );
		
			// paymask
			round[roundID].payMask += ( (_value.mul( team[_teamID].soldier ) / DENOMINATOR).mul(1000000000000000000)) / (round[roundID].totalFlags);
            player[roundID][_addr].payMask = ((( (round[roundID].payMask).mul( flagAmount )) / (1000000000000000000)).sub(soldierEarn)).add(player[roundID][_addr].payMask);

		} else {
             // 40%, 65%, 52.5% for soldier, respectively
            soldierEarn = (((_value.mul( team[_teamID].soldier + team[_teamID].officer ) / DENOMINATOR).mul(1000000000000000000)) / (round[roundID].totalFlags)).mul(flagAmount)/ (1000000000000000000);

			// 5% for admin
			adminFee += ( _value.mul( team[_teamID].teamWelfare ) ).div( DENOMINATOR );

			// paymask
			round[roundID].payMask += ( (_value.mul( team[_teamID].soldier + team[_teamID].officer ) / DENOMINATOR).mul(1000000000000000000)) / (round[roundID].totalFlags);
            player[roundID][_addr].payMask = ((( (round[roundID].payMask).mul( flagAmount )) / (1000000000000000000)).sub(soldierEarn)).add(player[roundID][_addr].payMask);
            
		}

		emit BO3Kevents.onDiscount( 
			_addr,
			randomValue,
			discountValue,
			getDiscount
		);

		emit BO3Kevents.onBuying( 
			_addr, 
			_value,
			flagAmount,
			playerFlags[_addr],
			round[roundID].totalEth,
			round[roundID].totalFlags,
			round[roundID].pot
		);
	}


	function updateTimer() private {
		uint256 _now = now;
		uint256 newTimeInterval = ( round[roundID].end ).add( _flagBuyingInterval ).sub( _now );

		if( newTimeInterval > _maxDuration ) {
			newTimeInterval = _maxDuration;
		}

		round[roundID].end = ( _now ).add( newTimeInterval );
		round[roundID].updatedTimeRounds = (round[roundID].updatedTimeRounds).add(1);

		emit BO3Kevents.onTimeAdding(
			round[roundID].start,
			round[roundID].end,
			newTimeInterval,
			( round[roundID].end ).sub( _now )
		);
	}

	function endRound() isActivated() private {
		// end round: get winner ID, team ID, pot, and values, respectively
		require ( !isLegalTime(now), "The round has not finished" );
		
		
		address winnerPlayerID = round[roundID].playerID;
		uint winnerTeamID = player[roundID][winnerPlayerID].teamID;
		uint256 potValue = round[roundID].pot;

		uint256 winValue = ( potValue.mul( potSplit._winRatio ) ).div( DENOMINATOR );
		uint256 soldierValue = ( potValue.mul( potSplit._soldiersRatio ) ).div( DENOMINATOR );
		uint256 nextRoundValue = ( potValue.mul( potSplit._nextRatio ) ).div( DENOMINATOR );
		uint256 adminValue = ( potValue.mul( potSplit._adminRatio ) ).div( DENOMINATOR );

		uint256 teamValue = team[winnerTeamID].totalEth;

		if( winnerPlayerID == address(0x0) ) {
			Admin.transfer( potValue );
			nextRoundValue -= nextRoundValue;

		} else {
			player[roundID][winnerPlayerID].win = ( player[roundID][winnerPlayerID].win ).add( winValue );
			winTeamID = winnerTeamID;
		}

		// Admin.transfer( adminValue + adminFee );
		adminRevenue = adminRevenue.add( adminValue ).add( adminFee );
		adminFee -= adminFee;

		round[roundID].ended = true;
		roundID++;

		round[roundID].start = now.add( _nextRoundSettingTime );
		round[roundID].end = (round[roundID].start).add( _maxDuration );
		round[roundID].pot = nextRoundValue;

		emit BO3Kevents.onRoundEnding(
			winnerPlayerID,
			winnerTeamID,
			winValue,
			soldierValue,
			teamValue,
			round[roundID].start,
			round[roundID].end,
			round[roundID].pot
		);

	}


	function activate() public {
		//activation
		require (
			msg.sender == 0xABb29fd841c9B919c3B681194c6173f30Ff7055D,
			"msg sender error"
			);

		require ( _activated == false, "Has activated" );
		
		_activated = true;

		roundID = 1;

		round[roundID].start = now;
		round[roundID].end = round[roundID].start + _maxDuration;

		round[roundID].ended = false;
		round[roundID].updatedTimeRounds = 0;
	}

	/*
		*
		* other functions
		*
	*/

	// next flag value
	function getFlagPrice() public view returns( uint256 ) {
		// return ( ((round[roundID].totalFlags).add(1000000000000000000)).ethRec(1000000000000000000) );
		uint256 _now = now;
		if( isLegalTime( _now ) ) {
			return ( ((round[roundID].totalFlags).add( 1000000000000000000 )).ethRec( 1000000000000000000 ) );
		} else {
			return (75000000000000);
		}
	}

    function getFlagPriceByFlags (uint256 _roundID, uint256 _flagAmount) public view returns (uint256) {
    	return round[_roundID].totalFlags.add(_flagAmount.mul( 10 ** 18 )).ethRec(_flagAmount.mul( 10 ** 18 ));
	}

	function getRemainTime() isActivated() public view returns( uint256 ) {
		return ( (round[roundID].start).sub( now ) );
	}
	
	function isLegalTime( uint256 _now ) internal view returns( bool ) {
		return ( _now >= round[roundID].start && _now <= round[roundID].end );
	}

	function isLegalTime() public view returns( bool ) {
		uint256 _now = now;
		return ( _now >= round[roundID].start && _now <= round[roundID].end );
	}
	
	function random() internal view returns( uint256 ) {
        return uint256( uint256( keccak256( block.timestamp, block.difficulty ) ) % DENOMINATOR );
	}

	function withdraw( uint256 _roundID ) isActivated() isHuman() public {

		require ( player[_roundID][msg.sender].hasRegistered == true, "Not Registered Before" );

		uint256 _discountRevenue = player[_roundID][msg.sender].discountRevenue;
		uint256 _refferedRevenue = player[_roundID][msg.sender].refferedRevenue;
		uint256 _winRevenue = player[_roundID][msg.sender].win;
		uint256 _flagRevenue = getFlagRevenue( _roundID ) ;

		if( isLegalTime( now ) && !round[_roundID].ended ) {
			// to-do: withdraw function
			msg.sender.transfer( _discountRevenue + _refferedRevenue + _winRevenue + _flagRevenue );

		} else {
			msg.sender.transfer( getTeamBonus(_roundID) + _discountRevenue + _refferedRevenue + _winRevenue + _flagRevenue );
		}

		player[_roundID][msg.sender].discountRevenue = 0;
		player[_roundID][msg.sender].refferedRevenue = 0;
		player[_roundID][msg.sender].win = 0;
		player[_roundID][msg.sender].payMask = _flagRevenue.add(player[_roundID][msg.sender].payMask);

		// if( round[_roundID].ended ) {
		// 	player[_roundID][msg.sender].flags = 0;
		// }

		player[_roundID][msg.sender].isWithdrawed = true;


		emit BO3Kevents.onWithdraw(
			msg.sender,
			_discountRevenue,
			_refferedRevenue,
			_winRevenue,
			_flagRevenue
		);
		
	}

	function becomeGeneral( uint _generalID ) public payable {
        require( msg.value >= LEADER_FEE && player[roundID][msg.sender].hasRegistered, "Not enough money or not player" );

        msg.sender.transfer( LEADER_FEE );

       	player[roundID][msg.sender].isGeneral = true;
       	player[roundID][msg.sender].generalID = _generalID;
    }


	/* 
		* Getters for Website 
	*/
	function getIsActive () public view returns (bool)  {
		return _activated;
	}

	function getPot (uint256 _roundID) public view returns (uint256)  {
		return round[_roundID].pot;
	}

	function getTime (uint256 _roundID) public view returns (uint256, uint256)  {
		if( isLegalTime( now ) ) {
			return (round[_roundID].start, (round[_roundID].end).sub( now ) );
		} else {
			return (0, 0);
		}
	}

	function getTeam (uint256 _roundID) public view returns (uint)  {
		return player[_roundID][msg.sender].teamID;
	}

	function getTeamData (uint256 _roundID, uint _tID) public view returns (uint256, uint256)  {
		return (teamData[_roundID][_tID].totalFlags, teamData[_roundID][_tID].totalEth);
	}

	function getTeamBonus (uint256 _roundID) public view returns (uint256) {
		// pot * 0.45 * (playerflag/teamflag)
		uint256 potValue = round[_roundID].pot;
		uint256 _winValue = ( potValue.mul( potSplit._soldiersRatio ) ).div( DENOMINATOR );
		uint _tID = player[_roundID][msg.sender].teamID;
		if( isLegalTime( now ) && (_roundID == roundID)) {
			// return ((player[_roundID][msg.sender].flags).mul(_winValue)).div( team[_tID].totalFlags );
			return ((player[_roundID][msg.sender].flags).mul(_winValue)).div( teamData[_roundID][_tID].totalFlags );
		} else {
			if( _tID != winTeamID ) {
				return 0;
			} else if (player[_roundID][msg.sender].isWithdrawed) {
				return 0;
			} else {
				// return ((player[_roundID][msg.sender].flags).mul(_winValue)).div( team[_tID].totalFlags );
				return ((player[_roundID][msg.sender].flags).mul(_winValue)).div( teamData[_roundID][_tID].totalFlags );
			}
		}
	}

	function getBonus (uint256 _roundID) public view returns (uint256) {
		return player[_roundID][msg.sender].discountRevenue + player[_roundID][msg.sender].win;
	}

	function getAllRevenue (uint256 _roundID) public view returns (uint256)  {
		return (getTeamBonus(_roundID) + player[_roundID][msg.sender].discountRevenue + player[_roundID][msg.sender].win + getFlagRevenue(_roundID) + player[_roundID][msg.sender].refferedRevenue) ;
	}

	function getAllWithdrawableRevenue (uint256 _roundID) public view returns (uint256)  {
		if( isLegalTime(now) && ( _roundID == roundID ) )
			return (player[_roundID][msg.sender].discountRevenue + player[_roundID][msg.sender].win + getFlagRevenue(_roundID) + player[_roundID][msg.sender].refferedRevenue) ;
		
		return (getTeamBonus(_roundID) + player[_roundID][msg.sender].discountRevenue + player[_roundID][msg.sender].win + getFlagRevenue(_roundID) + player[_roundID][msg.sender].refferedRevenue) ;
		
	}

	function getFlagRevenue(uint _round) public view returns(uint256)
    {
        return((((player[_round][msg.sender].flags).mul(round[_round].payMask)) / (1000000000000000000)).sub(player[_round][msg.sender].payMask));
        // return((((round[_round].payMask).mul(player[_round][msg.sender].flags)) / (1000000000000000000)).sub(player[_round][msg.sender].payMask));
    }

    function getGeneralProfit (uint256 _roundID) public view returns (uint256)  {
		return player[_roundID][msg.sender].refferedRevenue;
	}

	function getDistributedETH (uint256 _roundID) public view returns (uint256)  {
		return (round[_roundID].totalEth).sub(round[_roundID].pot).sub(adminFee);
	}

	function getGeneral (uint256 _roundID) public view returns (bool, uint)  {
		return (player[_roundID][msg.sender].isGeneral, player[_roundID][msg.sender].generalID);
	}

	function getPlayerFlagAmount (uint256 _roundID) public view returns (uint256)  {
		return player[_roundID][msg.sender].flags;
	}

	function getTotalFlagAmount (uint256 _roundID) public view returns (uint256)  {
		return round[_roundID].totalFlags;
	}

	function getTotalEth (uint256 _roundID) public view returns (uint256)  {
		return round[_roundID].totalEth;
	}

	function getUpdatedTime (uint256 _roundID) public view returns (uint)  {
		return round[_roundID].updatedTimeRounds;
	}
	
	
	function getRoundData( uint256 _roundID ) public view returns( address, uint256, uint256, bool ) {
		return ( round[_roundID].playerID, round[_roundID].pot, round[_roundID].totalEth, round[_roundID].ended );
	}

	/* admin */
	function getAdminRevenue () public view returns (uint)  {
		return adminRevenue;
	}
	
	function withdrawAdminRevenue() public {
		require (msg.sender == Admin );

		Admin.transfer( adminRevenue );
		adminRevenue = 0;
	}
	
}


library BO3KCalcLong {
    using SafeMath for *;

    function keysRec(uint256 _curEth, uint256 _newEth) internal pure returns (uint256){
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }

    function ethRec(uint256 _curKeys, uint256 _sellKeys) internal pure returns (uint256) {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    function keys(uint256 _eth) internal pure returns(uint256) {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }

    function eth(uint256 _keys) internal pure returns(uint256) {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}


/**
 * The BO3Kdatasets library does this and that...
 */
library BO3Kdatasets {


	struct Team {
		uint teamID;
		uint256 city;
		uint256 soldier;
		uint256 officer;
		uint256 grain;
		uint256 teamWelfare;
		uint256 totalEth;
		uint256 totalFlags;
	}

	struct TeamData {
		uint256 totalEth;
		uint256 totalFlags;
	}
	

	struct PotSplit {
        uint256 _winRatio;
        uint256 _soldiersRatio;
        uint256 _nextRatio;
        uint256 _adminRatio;
    }
	
	struct Round {
        address playerID;   // pID of player in lead
        // uint256 teamID;   // tID of team in lead
        uint256 start;   // time round started
        uint256 end;    // time ends/ended
        uint256 totalFlags;   // keys
        uint256 totalEth;    // total eth in
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 payMask;
        uint updatedTimeRounds;
        bool ended;     // has round end function been ran
    }

    struct Player {
        address addr;   // player 
        uint256 flags; 	// flags
        uint256 win;    // winnings vault
        uint256 refferedRevenue;
        uint256 discountRevenue;
        uint256 payMask;
        uint teamID;
        bool hasRegistered;
        bool isGeneral;
        uint generalID;
        bool isWithdrawed;
    }

    struct FlagInfo {
    	uint256 _flagValue;
    	uint256 updateTime;
    }
    
	
  
}


library SafeMath {

    function mul(uint256 a, uint256 b)  internal  pure  returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    	require(b > 0);

        uint256 c = a / b;
    	require(a == b * c + a % b); // There is no case in which this doesn't hold
    	return a / b;
	}
    
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = ((add(x,1)) / 2);
        y = x;

        while (z < y) {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    function sq(uint256 x) internal pure returns (uint256) {
        return (mul(x,x));
    }
    
    function pwr(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x==0)
            return (0);

        else if (y==0)
            return (1);

        else {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}
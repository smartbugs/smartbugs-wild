pragma solidity ^0.4.18;

contract EightStakes {
	struct Player {
		uint dt;
		address oAddress;
		int nSpent;
		int[] aResults;
		mapping (uint => uint) mGasByRoom;
	}
	struct Room {
		address[] aPlayers;
		uint[] aLosers;
		uint nBid;
		uint nStart;
		uint nLastPlayersBlockNumber;
	}
    address private _oSesokaj;
	
	mapping (address => Player) private _mPlayers;
	mapping (address => uint8) private _mPlayerRooms;
	address[] private _aPlayersBinds;
	address[] private _aLosers;

	uint private _nRoomNextID;
	mapping (uint => Room) private _mRooms;
	uint[] private _aRoomsOpened;
	uint[] private _aRoomsClosed;

	uint private _nMaxArchiveLength;
	
	uint private _nRefundCurrent;
	uint private _nRefundLimit;
	uint private _nRefundIncrease;
	address private _oRefundRecipient;
	
	uint private _nJackpot;
	uint private _nJackpotLast;
	uint private _nJackpotDiapason;
	address private _oJackpotRecipient;

	function EightStakes() public {
	    _oSesokaj = msg.sender;
		_nMaxArchiveLength = 300;   
		_nJackpotDiapason = uint(-1)/(3.5 * 100000); 
		_nRefundLimit = 8000000000000000000;  // 8eth
		_nRefundIncrease = 8000000000000000000;  // 8eth
		_aLosers.length = 10;
	}

	// PUBLIC
	function Bid(uint8 nRoomSize) public payable returns(bool) {
		uint8 nRoomType; //room type as a bit-flag value; size/bid: 0 for unused pair; 1 for 4/0.08, 2 for 4/0.8, 4 and 8 reserved, 16 for 8/0.08, 32 for 8/0.8, 64 for 8/8, 128 reserved
		int nRoomTypeIndx; //index from zero to four; size/bid: -1 for unused pair; 0 for 4/0.08, 1 for 4/0.8, 2 for 8/0.08, 3 for 8/0.8, 4 for 8/8
		(nRoomType, nRoomTypeIndx) = roomTypeGet(msg.value, nRoomSize);
		if (1 > nRoomType)
			revert();
		
		ProcessRooms();
		//check for rebid
		if (0 != _mPlayerRooms[msg.sender] & nRoomType)
			revert();
		_mPlayerRooms[msg.sender] |= nRoomType;
		uint nRoom = roomGet(msg.value, nRoomSize);
		Room memory oRoom = _mRooms[nRoom];
		uint nPlayer = 0;
		for (; oRoom.aPlayers.length > nPlayer; nPlayer++) {
		    if (1 > oRoom.aPlayers[nPlayer])
				break;
		    if (oRoom.aPlayers[nPlayer] == msg.sender)  
				revert();
		}
		uint nGas = msg.gas*800000000;
		if (0 < _mPlayers[msg.sender].oAddress) {
		    _mPlayers[msg.sender].dt = now;
			_mPlayers[msg.sender].nSpent += int(nGas);
			_mPlayers[msg.sender].aResults[uint(nRoomTypeIndx)] = 0;
		} else {
			_mPlayers[msg.sender] = Player(now, msg.sender, int(nGas), new int[](5));
			_aPlayersBinds.push(msg.sender);
		}
		_mPlayers[msg.sender].mGasByRoom[nRoom] = nGas;
		oRoom.aPlayers[nPlayer] = msg.sender;
		if (nPlayer + 1 == oRoom.aPlayers.length) {
			oRoom.nStart = now;
			oRoom.nLastPlayersBlockNumber = block.number;
		}
		_mRooms[nRoom] = oRoom;
		return true;
	}
	function IsCheckNeeded(uint nNowDate, uint nMaxInterval) public constant returns(bool) {
		for (uint n=0; n<_aRoomsOpened.length; n++) {
			if (0 < _mRooms[_aRoomsOpened[n]].nLastPlayersBlockNumber && 
					_mRooms[_aRoomsOpened[n]].nStart + nMaxInterval < nNowDate && 
					0 < uint(block.blockhash(_mRooms[_aRoomsOpened[n]].nLastPlayersBlockNumber)) ) { 
				return true;
			}
		}
		return false;
	}
	function ProcessRooms() public {
		uint[] memory a = new uint[](_aRoomsOpened.length);
		uint n = 0;
		uint nCurrent = 0;
		uint nRoom;
		Room memory oRoom;
		for (; _aRoomsOpened.length > n; n++) {
		    oRoom = _mRooms[nRoom = _aRoomsOpened[n]];
			if (0 < oRoom.nLastPlayersBlockNumber && 0 < uint(block.blockhash(oRoom.nLastPlayersBlockNumber))) {
				result(nRoom);
				a[nCurrent++] = n;
			}
		}
		for (n = 0; nCurrent > n; n++)
			roomClose(a[n]);
		delete a;
	}
	function LastResult(address oPlayer, uint8 nSize, uint nBid) public constant returns (bool, int) {
		uint nPlayer = uint(-1);
		uint nDate = 0;
		uint nRoom = 0;
		uint nRoomCurrent;
		Room memory oRoom;
		for (uint n=0; _aRoomsClosed.length > n; n++) {
		    oRoom = _mRooms[nRoomCurrent = _aRoomsClosed[n]];
			if (oRoom.aPlayers.length != nSize || oRoom.nBid != nBid || uint(-1) == (nPlayer = playerGet(oRoom, oPlayer)))
				continue;
			if (oRoom.nStart > nDate) {
				nDate = oRoom.nStart;
				nRoom = nRoomCurrent;
			}
		}
		if (0 < nDate) {
		    oRoom = _mRooms[nRoom];
		    for (n=0; oRoom.aLosers.length > n; n++) {
		        if (oPlayer == oRoom.aPlayers[oRoom.aLosers[n]])
    				return(false, int(-oRoom.nBid));
			}
			return(true, int(prizeCalculate(oRoom)));
		}
		return(false, 0);
	}
	//Plenum
	//returns a number of players for a room specified by a size and a bid
	function Plenum(uint8 nSize, uint nBid) public constant returns (uint8) {
		Room memory oRoom;
		uint nLength;
		for (uint n=0; _aRoomsOpened.length > n; n++) {
			oRoom = _mRooms[_aRoomsOpened[n]];
			if (nBid == oRoom.nBid && nSize == (nLength = oRoom.aPlayers.length) && 1 > oRoom.aPlayers[--nLength]) {
				for (; 0 <= nLength; nLength--) {
					if (0 < oRoom.aPlayers[nLength])
						return uint8(nLength + 1);
				}
			}
		}
		return(0);
	}
	function State(address[] aTargets) public view returns(uint[4] aPerks, address[2] aPerksRecipients, address[] aLosersAddresses, int[] aLosersBalances, bool[5] aRooms, int[5] aResults) {
		aLosersBalances = new int[](_aLosers.length);
		uint nLength = _aLosers.length;
		uint n = 0;
		for (; nLength > n; n++)
			aLosersBalances[n] = _mPlayers[_aLosers[n]].nSpent;
		for (n = 0; aTargets.length > n; n++) {
			uint8 nValue = 1;
			for (uint nIndx = 0; aRooms.length > nIndx; nIndx++) {
				if (0 < _mPlayerRooms[aTargets[n]]) {
					aRooms[nIndx] = aRooms[nIndx] || (0 < (_mPlayerRooms[aTargets[n]] & nValue));
					if (2 == nValue)
						nValue <<= 3;
					else
						nValue <<= 1;
				}
				if (0 == aResults[nIndx] && 0 != _mPlayers[aTargets[n]].oAddress && 0 != _mPlayers[aTargets[n]].aResults[nIndx])
					aResults[nIndx] += _mPlayers[aTargets[n]].aResults[nIndx];
			}
		}
		return ([_nJackpot, _nJackpotLast, _nRefundLimit, _nRefundCurrent], [_oJackpotRecipient, _oRefundRecipient], _aLosers, aLosersBalances, aRooms, aResults);
	}
    function Remove() public {
        if (msg.sender == _oSesokaj)
            selfdestruct(_oSesokaj);
    }

	// PRIVATE
	//roomTypeGet
	//returns two values:
	//room type as a bit-flag value; size/bid: 0 for unused pair; 1 for 4/0.08, 2 for 4/0.8, 4 and 8 reserved, 16 for 8/0.08, 32 for 8/0.8, 64 for 8/8, 128 reserved
	//index from zero to four; size/bid: -1 for unused pair; 0 for 4/0.08, 1 for 4/0.8, 2 for 8/0.08, 3 for 8/0.8, 4 for 8/8
	function roomTypeGet(uint nBid, uint8 nSize) private pure returns(uint8, int) {
		if (80000000000000000 == nBid) { //0.08eth
			if (4 == nSize)
				return (1, 0);
			if (8 == nSize)
				return (16, 2);
		}
		if (800000000000000000 == nBid) { //0.8eth
			if (4 == nSize)
				return (2, 1);
			if (8 == nSize)
				return (32, 3);
		}
		if (8000000000000000000 == nBid && 8 == nSize) //8eth
				return (64, 4);
		return (0, -1);
	}
	function roomClose(uint nOpened) private{
	    uint n;
		if (_aRoomsClosed.length >= _nMaxArchiveLength) {
    		uint nClosed = 0;
    		uint nRoom = 0;
    		uint nDate = uint(-1);
    		uint nStart;
    		for (n=0; _aRoomsClosed.length > n; n++) {
    			if ((nStart = _mRooms[_aRoomsClosed[n]].nStart) < nDate) {
    				nClosed = n;
    				nDate = nStart;
    			}
    		}
    		uint nLength = _mRooms[nRoom = _aRoomsClosed[nClosed]].aPlayers.length;
			for (n=0; nLength > n; n++) {
			    delete _mPlayers[_mRooms[nRoom].aPlayers[n]].mGasByRoom[nRoom];
				delete _mRooms[nRoom].aPlayers[n];
			}
			delete _mRooms[nRoom];
			_aRoomsClosed[nClosed] = _aRoomsOpened[nOpened];
		} else
			_aRoomsClosed.push(_aRoomsOpened[nOpened]);

		if (nOpened < (n = _aRoomsOpened.length - 1))
			_aRoomsOpened[nOpened] = _aRoomsOpened[n];
		_aRoomsOpened.length--;
	}
	function roomGet(uint nBid, uint8 nSize) private returns(uint nRetVal) {
	    Room memory oRoom;
	    uint nLength;
		for (uint n=0; _aRoomsOpened.length > n; n++) {
		    nRetVal = _aRoomsOpened[n];
		    oRoom = _mRooms[nRetVal];
		    nLength = oRoom.aPlayers.length;
			if (nBid == oRoom.nBid && nSize == nLength && 1 > oRoom.aPlayers[nLength - 1])
				return;
		}
		oRoom = Room(new address[](nSize), new uint[](0), nBid, 0, 0);
		_mRooms[nRetVal = _nRoomNextID] = oRoom;
		_aRoomsOpened[++_aRoomsOpened.length - 1] = _nRoomNextID;
		_nRoomNextID++;
		return;
	}
	function playerGet(Room memory oRoom, address oPlayer) private pure returns(uint) {
		for (uint8 n=0; oRoom.aPlayers.length > n; n++) {
			if (oPlayer == oRoom.aPlayers[n])
				return n;
		}
		return uint(-1); 
	}
	function prizeCalculate(Room memory oRoom) private pure returns (uint) {
		return (oRoom.nBid / 4);
	}
	function result(uint nRoom) private {
	    Room memory oRoom = _mRooms[nRoom];
	    if (0 < oRoom.aLosers.length)
	        revert();
		uint8 nSize = uint8(oRoom.aPlayers.length);
		bytes32[] memory aHashes;
		uint8 nIndx1;
		uint8 nIndx2;

		(aHashes, nIndx1, nIndx2) = gameCalculate(oRoom);

	    oRoom.aLosers = new uint[](nSize/4);
		oRoom.aLosers[0] = nIndx1;
		if (8 == nSize)
			oRoom.aLosers[1] = nIndx2;

		uint nValue = (oRoom.nBid * oRoom.aPlayers.length / 64);
		_nJackpot += nValue;
		_nRefundCurrent += nValue;

		nValue = prizeCalculate(oRoom);
		uint8 nRoomType;
		int nRoomTypeIndx;
		int nAmount;
		(nRoomType, nRoomTypeIndx) = roomTypeGet(oRoom.nBid, nSize);
		for (uint n=0; nSize > n; n++) {
			if (nIndx1 == n || (8 == nSize && nIndx2 == n))
				nAmount = -int(oRoom.nBid);
			else if (!_mPlayers[oRoom.aPlayers[n]].oAddress.send(uint(nAmount = int(oRoom.nBid + nValue + _mPlayers[oRoom.aPlayers[n]].mGasByRoom[nRoom]))))
				nAmount = 0; //fuckup with sending
			_mPlayers[oRoom.aPlayers[n]].nSpent -= (_mPlayers[oRoom.aPlayers[n]].aResults[uint(nRoomTypeIndx)] = nAmount);
			if (0 == (_mPlayerRooms[oRoom.aPlayers[n]] &= ~nRoomType))
				delete _mPlayerRooms[oRoom.aPlayers[n]]; //remove player from room map if it was his last room
		}

		uint nDiff = uint(aHashes[nIndx2]) - uint(aHashes[nIndx1]);
		if (nDiff > 0 && nDiff < _nJackpotDiapason) {
			if (oRoom.aPlayers[nIndx1].send(_nJackpot)) {
				_oJackpotRecipient = oRoom.aPlayers[nIndx1];
				_nJackpotLast = _nJackpot;
				_nJackpot = 0;
			}
		}
		_mRooms[nRoom] = oRoom;

		if (_nRefundCurrent > _nRefundLimit && 0 != _aLosers[0]) {
			if (_aLosers[0].send(_nRefundCurrent)) {
				_oRefundRecipient = _aLosers[0];
				_nRefundLimit += _nRefundIncrease;
				_mPlayers[_aLosers[0]].nSpent -= int(_nRefundCurrent);
				_nRefundCurrent = 0;
			}
		}
		losers();
	}
	function losers() private {
	    Player[] memory aLosers = new Player[](_aLosers.length);
		Player memory oPlayer;
		Player memory oShift;
		uint nLoser;
		uint nLength = _aPlayersBinds.length;
	    for (uint nPlayer=0; nLength > nPlayer; nPlayer++) {
			oPlayer = _mPlayers[_aPlayersBinds[nPlayer]];
			if (now - oPlayer.dt > 30 days) {
				delete _mPlayers[_aPlayersBinds[nPlayer]];
				_aPlayersBinds[nPlayer] = _aPlayersBinds[nLength--];
				nPlayer--;
				continue;
			}
			for (nLoser=0; aLosers.length > nLoser; nLoser++) {
				if (0 == aLosers[nLoser].oAddress) {
					aLosers[nLoser] = oPlayer;
					break;
				}
				if (oPlayer.nSpent > aLosers[nLoser].nSpent) {
					oShift = aLosers[nLoser];
					aLosers[nLoser] = oPlayer;
					oPlayer = oShift;
				}
			}
	    }
		for (nLoser=0; aLosers.length > nLoser; nLoser++)
			_aLosers[nLoser] = aLosers[nLoser].oAddress;
	}
	function gameCalculate(Room oRoom) private constant returns (bytes32[] memory aHashes, uint8 nIndx1, uint8 nIndx2) {
		bytes32 aBlockHash = block.blockhash(oRoom.nLastPlayersBlockNumber);
	    uint nSize = oRoom.aPlayers.length;
		aHashes = new bytes32[](nSize);
		bytes32 nHash1 = bytes32(-1);
		bytes32 nHash2 = bytes32(-1);

		for (uint8 n=0; nSize > n; n++) {
			aHashes[n] = sha256(uint(oRoom.aPlayers[n]) + uint(aBlockHash));
			if (aHashes[n] <= nHash2 ) {
				if (aHashes[n] <= nHash1) {
					nHash2 = nHash1;
					nIndx2 = nIndx1;
					nHash1 = aHashes[n];
					nIndx1 = n;
				} else {
					nHash2 = aHashes[n];
					nIndx2 = n;
				}
			}
		}
		if (nIndx1 == nIndx2)
			(nIndx1, nIndx2) = (0, 0);
		return;
	}
}
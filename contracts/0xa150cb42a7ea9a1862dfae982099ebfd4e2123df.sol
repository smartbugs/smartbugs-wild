pragma solidity ^0.4.9;

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract RoundToken {

  string public constant name = "ROUND";
  string public constant symbol = "ROUND";
  uint8 public constant decimals = 18;
  string public constant version = '0.1';
  uint256 public constant totalSupply = 1000000000 * 1000000000000000000;

  address public owner;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event NewOwner(address _newOwner);

  modifier checkIfToContract(address _to) {
    if(_to != address(this))  {
      _;
    }
  }

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;

  function RoundToken() {
    owner = msg.sender;
    balances[owner] = totalSupply;
  }

  function replaceOwner(address _newOwner) returns (bool success) {
    if (msg.sender != owner) throw;
    owner = _newOwner;
    NewOwner(_newOwner);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) checkIfToContract(_to) returns (bool success) {
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else {
      return false;
    }
  }

  function transferFrom(address _from, address _to, uint256 _value) checkIfToContract(_to) returns (bool success) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      balances[_to] += _value;
      balances[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);
      return true;
    } else {
      return false;
    }
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
    tokenRecipient spender = tokenRecipient(_spender);
    if (approve(_spender, _value)) {
      spender.receiveApproval(msg.sender, _value, this, _extraData);
      return true;
    }
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}


contract Owned {
  address public contractOwner;
  address public pendingContractOwner;

  function Owned() {
    contractOwner = msg.sender;
  }

  modifier onlyContractOwner() {
    if (contractOwner == msg.sender) _;
  }

  function changeContractOwnership(address _to) onlyContractOwner() returns(bool) {
    pendingContractOwner = _to;
    return true;
  }

  function claimContractOwnership() returns(bool) {
    if (pendingContractOwner != msg.sender)
      return false;
    contractOwner = pendingContractOwner;
    delete pendingContractOwner;
    return true;
  }
}

contract BidGame is Owned {

  uint commissionPercent;
  uint refundPenalty;
  address gameOracleAddress;
  address contractRoundTokenAddress;

  struct Game {
    uint gameId;
    uint state; //0 - new, 1 - started, 2XX- game completed;
    string winnerUserName;
    uint winnerUserId;
    uint totalGameBid;
	uint bidAmt;
    Bid[] bids;
  }

  struct Bid {
    address bidderAddress;
    uint bid;
    uint userId;
    string userName;
    bool refunded;
  }

  mapping(uint => Game) games;

  // ---------------------------------------------------------------------------
  // modifiers
  modifier onlyGameOracle() {
    if (gameOracleAddress == msg.sender) _;
  }

  // ---------------------------------------------------------------------------
  // events
  event LogSender2(address log, address contractRoundToken);
  event GameBidAccepted(address bidder, uint amount, uint gameId, uint userId, bytes userName, bool state);
  event GameStarted(uint gameId);
  event GameFinished(uint gameId, uint winnerUserId, string winnerUserName, uint winnersPayment, address winnerAddress);
  event GameRefunded(uint gameId, uint refundUserId, uint refundPayment);

  // ---------------------------------------------------------------------------
  // init settings
  function setParams(uint _commissionPercent, uint _refundPenalty, address _gameOracleAddress, address _contractRoundTokenAddress) onlyContractOwner() {
    commissionPercent = _commissionPercent;
    refundPenalty = _refundPenalty;
    gameOracleAddress = _gameOracleAddress;
    contractRoundTokenAddress = _contractRoundTokenAddress;
    LogSender2(msg.sender, contractRoundTokenAddress);
  }

  // ---------------------------------------------------------------------------
  // contact actions
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) {
    uint i = bytesToUint2(bytes(_extraData));
    uint _gameId = i/10000;
    uint _userId = i - _gameId*10000;

	//check game bid amount and force bidding the same amount of ROUNDs
	if (games[_gameId].gameId > 0){
		uint amountToBid = games[_gameId].bidAmt;
		for (uint k = 0; k < games[_gameId].bids.length; k++) {
			if(!games[_gameId].bids[k].refunded && _userId==games[_gameId].bids[k].userId) {
				amountToBid-=games[_gameId].bids[k].bid;
			}	
		}
		if(amountToBid>0)
			_value = amountToBid;
		else
			throw;
    }
	
    RoundToken token = RoundToken(contractRoundTokenAddress);
    bool state = token.transferFrom(_from, gameOracleAddress, _value);

    if (!state) throw;

	if (games[_gameId].gameId == 0){
		games[_gameId].bidAmt = _value;
		games[_gameId].gameId = _gameId;
	}

    games[_gameId].totalGameBid += _value;
    games[_gameId].bids.push(Bid(_from, _value, _userId, '', false));

    GameBidAccepted(_from, _value, _gameId, _userId, '', state);
  }

  function gameResult(uint _gameId, uint _userId) onlyGameOracle() {
    if (games[_gameId].gameId == 0) throw;
    if (games[_gameId].winnerUserId != 0) throw;
    if (games[_gameId].totalGameBid == 0) throw;

    address winnerAddress;
    uint commission = games[_gameId].totalGameBid*commissionPercent/100;
    // if (commission < 1) commission = 1;
    uint winnerAmount = games[_gameId].totalGameBid - commission;

    for (uint i = 0; i < games[_gameId].bids.length; i++) {
      if(!games[_gameId].bids[i].refunded && _userId==games[_gameId].bids[i].userId) {
        winnerAddress = games[_gameId].bids[i].bidderAddress;
        break;
      }
    }

    if (winnerAddress == 0) throw;

    RoundToken token = RoundToken(contractRoundTokenAddress);
    bool state = token.transferFrom(gameOracleAddress, winnerAddress, winnerAmount);

    if (!state) throw;

    games[_gameId].winnerUserId = _userId;
    games[_gameId].state = 200;

    GameFinished(_gameId, _userId, '', winnerAmount, winnerAddress);
  }

  function gameStart(uint _gameId) onlyGameOracle() {
    if (games[_gameId].gameId == 0) throw;
    if (games[_gameId].state != 0) throw;
    games[_gameId].state = 1;
    GameStarted(_gameId);
  }

  function gameRefund(uint _gameId) onlyGameOracle() {
    if (games[_gameId].gameId == 0) throw;
    if (games[_gameId].winnerUserId != 0) throw;
    if (games[_gameId].totalGameBid == 0) throw;

    for (uint i = 0; i < games[_gameId].bids.length; i++) {
      if(!games[_gameId].bids[i].refunded) {
        uint penalty = games[_gameId].bids[i].bid*refundPenalty/100;
        // if (penalty < 1) penalty = 1;
        uint refundAmount = games[_gameId].bids[i].bid - penalty;

        RoundToken token = RoundToken(contractRoundTokenAddress);
        bool state = token.transferFrom(gameOracleAddress, games[_gameId].bids[i].bidderAddress, refundAmount);

        if (!state) throw;

        games[_gameId].bids[i].refunded = true;
        games[_gameId].totalGameBid -= games[_gameId].bids[i].bid;
        GameRefunded(_gameId, games[_gameId].bids[i].userId, refundAmount);
      }
    }
  }

  function bidRefund(uint _gameId, uint _userId) onlyGameOracle() {
    if (games[_gameId].gameId == 0) throw;
    if (games[_gameId].winnerUserId != 0) throw;
    if (games[_gameId].totalGameBid == 0) throw;
    for (uint i = 0; i < games[_gameId].bids.length; i++) {
      if(!games[_gameId].bids[i].refunded) {
        if (games[_gameId].bids[i].userId == _userId) {
          uint penalty = games[_gameId].bids[i].bid*refundPenalty/100;
          // if (penalty < 1) penalty = 1;
          uint refundAmount = games[_gameId].bids[i].bid - penalty;

          RoundToken token = RoundToken(contractRoundTokenAddress);
          bool state = token.transferFrom(gameOracleAddress, games[_gameId].bids[i].bidderAddress, refundAmount);

          if (!state) throw;

          games[_gameId].bids[i].refunded = true;
          games[_gameId].totalGameBid -= games[_gameId].bids[i].bid;
          GameRefunded(_gameId, games[_gameId].bids[i].userId, refundAmount);
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Get settings
  function getSettings() constant returns(uint commission, uint penalty) {
    return (
      commissionPercent,
      refundPenalty
    );
  }

  // ---------------------------------------------------------------------------
  // Get game info
  function getGame(uint _gameId) constant returns(uint gameId, uint state, uint winnerUserId, uint totalGameBid, uint bidAmt, uint bidsAmount) {
    var game = games[_gameId];
    return (
      game.gameId,
      game.state,
      game.winnerUserId,
      game.totalGameBid,
	  game.bidAmt,
      game.bids.length
    );
  }

  // ---------------------------------------------------------------------------
  // Get bid info
  function getGameBid(uint _gameId, uint _bidId) constant returns(address bidderAddress, uint bidsAmount, uint userId, string userName, bool refunded) {
    Game game = games[_gameId];
    Bid bid=game.bids[_bidId];
    return (
      bid.bidderAddress,
      bid.bid,
      bid.userId,
      bid.userName,
      bid.refunded
    );
  }

  // ---------------------------------------------------------------------------
  // Get balance of address
  function getBalance(address _owner) constant returns (uint256 balance) {
    RoundToken token = RoundToken(contractRoundTokenAddress);
    return token.balanceOf(_owner);
  }

  // ---------------------------------------------------------------------------
  // kill contract
  function kill() onlyContractOwner() {
   if (msg.sender == contractOwner){
      suicide(contractOwner);
    }
  }

  // ---------------------------------------------------------------------------
  // utils
  function bytesToUint2(bytes b) returns (uint) {
    uint result = 0;
    for (uint i=1; i < b.length; i++) {
      uint x = uint(uint(b[i]));
      if (x > 0)
        x = x - 48;
      result = result + x*(10**(b.length-i-1));
    }
    return result;
  }

}
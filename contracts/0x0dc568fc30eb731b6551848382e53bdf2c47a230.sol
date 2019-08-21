pragma solidity ^0.4.11;

/**
 * WELCOME: http://cryptobeton.com/
 * Cryptobeton is a multi-functional platform for working with SmartContract, allowing you to make bets, watch matches and news from the world of cybersport. Staying with us you will be next to the tournaments on CS GO, DOTA2, LOL
 */
contract CryptoBetOn {

    struct Gamer {
        address wallet;
        uint amount;
    }

    struct Match {
        bool bets;
        uint number;
        uint winPotA;
        uint winPotB;
        uint winPotD;
        Gamer[] gamersA;
        Gamer[] gamersD;
        Gamer[] gamersB;
    }

    uint16 constant MATCH_COUNT_LIMIT = 512;
    uint8 constant HOUSE_EDGE_TOP_BAR = 12;
    uint8 constant HOUSE_EDGE_BOTTOM_BAR = 1;

    uint8 constant TX_N01 = 1; // "TX_N01. Not found match by id";
    uint8 constant TX_N02 = 2; // "TX_N02. Thanks, brother!";
    uint8 constant TX_N03 = 3; // "TX_N03. The number of matches should not exceed the limit";
    uint8 constant TX_N04 = 4; // "TX_N04. The percentage of the fee should not exceed the limits";
    uint8 constant TX_N16 = 16; // "TX_N16. Non-standard situation: We did not receive fees"
    uint8 constant TX_N17 = 17; // "TX_N17. Abnormal situation: Failed to return some bets back"
    uint8 constant TX_N18 = 18; // "TX_N18. Abnormal situation: Failed to return some bets back"
    uint8 constant TX_N19 = 19; // "TX_N19. Match with id already exists";

    // Fee is 4 percent of win amount
    uint8 private houseEdge = 3;
    uint constant JACKPOT_FEE = 1;
    uint jackpotAmount = 0;
    address private owner;
    uint16 matchCount = 0;
    mapping (uint => Match) matchesMap;

    modifier onlyowner {
        require(msg.sender == owner);
        _;
    }

    modifier hasmatch(uint _matchId) {
        var m = matchesMap[_matchId];
        if (m.number != 0) {
            _;
        } else {
            TxMessage(_matchId, TX_N01, 0);
        }
     }

    function CryptoBetOn() payable {
        owner = msg.sender;
    }

    event TxMessage(uint _matchId,
                    uint8 _code,
                    uint _value);

    event MatchAdded(uint _matchId,
                     uint8 _houseEdge,
                     uint16 _matchCount);

    event MatchGetted(uint _matchId,
                      bool _bets,
                      uint _number,
                      uint _winPotA,
                      uint _winPotB);

    event MatchPayoff(uint _matchId,
                       uint _winPot,
                       uint _collectedFees,
                       uint _jackpotAmount);

    event MatchAborted(uint _matchId);

    event BetAccepted(uint _matchId,
                      uint8 _betState,
                      address _wallet,
                      uint _amount,
                      uint _blockNumber);


    event CashSaved(uint _amount);

    event JackpotPayoff(uint _matchId, uint _amount, address _wallet);

    function() payable {
        if (msg.value > 0) {
            TxMessage(0, TX_N02, msg.value);
        }
    }

    function setHouseEdge(uint8 _houseEdge) onlyowner {
        if (houseEdge < HOUSE_EDGE_BOTTOM_BAR || _houseEdge > HOUSE_EDGE_TOP_BAR) {
            TxMessage(0, TX_N04, _houseEdge);
            return;
        }
        houseEdge = _houseEdge;
    }

    function getHouseEdge() constant returns(uint8) {
        return houseEdge;
    }

    function getOwner() constant returns(address) {
        return owner;
    }

    function getBalance() constant returns (uint) {
        return this.balance;
    }

    function getJackpotAmount() constant returns(uint) {
        return jackpotAmount;
    }

    function getMatchCount() constant returns(uint16) {
        return matchCount;
    }

    function addNewMatch(uint _matchId) private returns(bool) {
        var m = matchesMap[_matchId];
        if (m.number != 0) {
            return true;
        }
        if (_matchId == 0) {
            TxMessage(_matchId, TX_N19, m.number);
            return false;
        }
        if (matchCount >= MATCH_COUNT_LIMIT) {
            TxMessage(_matchId, TX_N03, matchCount);
            return false;
        }
        matchesMap[_matchId].bets = true;
        matchesMap[_matchId].number = block.number;
        matchCount += 1;
        MatchAdded(_matchId,
                   houseEdge,
                   matchCount);
        return true;
    }

    function getMatch(uint _matchId) hasmatch(_matchId) {
        var m = matchesMap[_matchId];
        MatchGetted(_matchId,
                    m.bets,
                    m.number,
                    m.winPotA,
                    m.winPotB);
    }

    function betsOff(uint _matchId) onlyowner hasmatch(_matchId) returns (bool) {
        matchesMap[_matchId].bets = false;
        return true;
    }

    function cashBack(Gamer[] gamers) private returns(uint) {
        uint amount = 0;
        for (uint index = 0; index < gamers.length; index++) {
            if (!gamers[index].wallet.send(gamers[index].amount)) {
                amount += gamers[index].amount;
            }
        }
        return amount;
    }

    function abortMatch(uint _matchId) onlyowner hasmatch(_matchId) {
        var m = matchesMap[_matchId]; // TODO whether the data is copied or it is the reference to storage
        cashBack(m.gamersA);
        cashBack(m.gamersB);
        cashBack(m.gamersD);
        clearMatch(_matchId);
        MatchAborted(_matchId);
    }

    function eraseMatch(uint _matchId) onlyowner hasmatch(_matchId) {
        clearMatch(_matchId);
        MatchAborted(_matchId);
    }

    function payoutJackpot(uint _matchId, Gamer[] gamers) onlyowner private {
        uint tmpAmount = 0;
        address jackpotWinner = 0;
        uint tmpJackpotAmount = jackpotAmount;
        jackpotAmount = 0;
        for (uint pos = 0; pos < gamers.length; pos += 1) {
            if (gamers[pos].amount > tmpAmount) {
                tmpAmount = gamers[pos].amount;
                jackpotWinner = gamers[pos].wallet;
            }
        }
        if (jackpotWinner != 0 && jackpotWinner.send(tmpJackpotAmount)) {
            JackpotPayoff(_matchId, tmpJackpotAmount, jackpotWinner);
        }
    }

    function checkMatchToBeAborted(uint _matchId, uint8 _winner) private returns(bool) {
        var m = matchesMap[_matchId];
        if (m.number == 0 || m.bets) {
            return true;
        }
        if ((m.winPotA == 0 && _winner == 0) || (m.winPotD == 0 && _winner == 1) || (m.winPotB == 0 && _winner == 2)) {
            return true;
        }
        if ((m.winPotA == 0 && m.winPotB == 0) || (m.winPotA == 0 && m.winPotD == 0) || (m.winPotB == 0 && m.winPotD == 0)) {
            return true;
        }
        return false;
    }

    function payoutMatch(uint _matchId, uint8 _winner, bool _jackpot) onlyowner {
        // cash back if need abort
        if (checkMatchToBeAborted(_matchId, _winner)) {
            abortMatch(_matchId);
            return;
        }
        var m = matchesMap[_matchId];
        var gamers = m.gamersA;
        uint winPot = m.winPotA;
        uint losePot_ = m.winPotB + m.winPotD;
        if (_winner == 2) {
            gamers = m.gamersB;
            winPot = m.winPotB;
            losePot_ = m.winPotA + m.winPotD;
        } else if (_winner == 1) {
            gamers = m.gamersD;
            winPot = m.winPotD;
            losePot_ = m.winPotA + m.winPotB;
        }
        uint fallbackAmount = 0;
        uint collectedFees = (losePot_ * houseEdge) / uint(100);
        uint jackpotFees = (losePot_ * JACKPOT_FEE) / uint(100);
        uint losePot = losePot_ - collectedFees - jackpotFees;
        for (uint index = 0; index < gamers.length; index += 1) {
            uint winAmount = gamers[index].amount + ((gamers[index].amount * losePot) / winPot);
            if (!gamers[index].wallet.send(winAmount)) {
                fallbackAmount += winAmount;
            }
        }
        jackpotAmount += jackpotFees;
        if (_jackpot) {
            payoutJackpot(_matchId, gamers);
        }
        // pay housecut & reset for next bet
        if (collectedFees > 0) {
            if (!owner.send(collectedFees)) {
                TxMessage(_matchId, TX_N16, collectedFees);
                   // There is a manual way of withdrawing money!
            }
        }
        if (fallbackAmount > 0) {
            if (owner.send(fallbackAmount)) {
                TxMessage(_matchId, TX_N17, fallbackAmount);
            } else {
                TxMessage(_matchId, TX_N18, fallbackAmount);
            }
        }
        clearMatch(_matchId);
        MatchPayoff(_matchId,
                    losePot,
                    collectedFees, 
                    jackpotAmount);
    }

    function clearMatch(uint _matchId) private hasmatch(_matchId) {
        delete matchesMap[_matchId].gamersA;
        delete matchesMap[_matchId].gamersB;
        delete matchesMap[_matchId].gamersD;
        delete matchesMap[_matchId];
        matchCount--;
    }

    function acceptBet(uint _matchId, uint8 _betState) payable {
        var m = matchesMap[_matchId];
        if (m.number == 0 ) {
            require(addNewMatch(_matchId));
            m = matchesMap[_matchId];
        }
        require(m.bets);
        require(msg.value >= 10 finney); //  && msg.value <= 100 ether
        if (_betState == 0) {
            var gamerA = m.gamersA[m.gamersA.length++];
            gamerA.wallet = msg.sender;
            gamerA.amount = msg.value;
            m.winPotA += msg.value;
        } else if (_betState == 2) {
            var gamerB = m.gamersB[m.gamersB.length++];
            gamerB.wallet = msg.sender;
            gamerB.amount = msg.value;
            m.winPotB += msg.value;
        } else if (_betState == 1) {
            var gamerD = m.gamersD[m.gamersD.length++];
            gamerD.wallet = msg.sender;
            gamerD.amount = msg.value;
            m.winPotD += msg.value;
        }
        BetAccepted(_matchId,
                    _betState,
                    msg.sender,
                    msg.value,
                    block.number);
    }

    function saveCash(address _receiver, uint _amount) onlyowner {
         require(matchCount == 0);
         require(_amount > 0);
         require(this.balance > _amount);
         // send cash
         if (_receiver.send(_amount)) {
             // confirm
             CashSaved(_amount);
         }
     }

    function killContract () onlyowner {
        require(matchCount == 0);
        // transfer amount to wallet address
        selfdestruct(owner);
    }
}
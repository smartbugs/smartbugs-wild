//last compiled with soljson-v0.3.5-2016-07-21-6610add

contract Etheropt {

  struct Position {
    mapping(uint => int) positions;
    int cash;
    bool expired;
    bool hasPosition;
  }
  uint public expiration;
  string public underlying;
  uint public margin;
  uint public realityID;
  bytes32 public factHash;
  address public ethAddr;
  mapping(uint => int) options;
  uint public numOptions;
  bool public expired;
  mapping(address => Position) positions;
  uint public numPositions;
  uint public numPositionsExpired;
  struct Account {
    address user;
    int capital;
  }
  mapping(bytes32 => int) orderFills; //keeps track of cumulative order fills
  struct MarketMaker {
    address user;
    string server;
  }
  mapping(uint => MarketMaker) marketMakers; //starts at 1
  uint public numMarketMakers = 0;
  mapping(address => uint) marketMakerIDs;
  mapping(uint => Account) accounts;
  uint public numAccounts;
  mapping(address => uint) accountIDs; //starts at 1

  //events
  event Deposit(address indexed user, uint amount, int balance); //balance is balance after deposit
  event Withdraw(address indexed user, uint amount, int balance); //balance is balance after withdraw
  event NewMarketMaker(address indexed user, string server);
  event Expire(address indexed caller, address indexed user); //user is the account that was expired
  event OrderMatchFailure(address indexed matchUser, int matchSize, address indexed orderUser, int orderSize, uint optionID, uint price);
  event OrderMatch(address indexed matchUser, int matchSize, address indexed orderUser, int orderSize, uint optionID, uint price);

  function Etheropt(uint expiration_, string underlying_, uint margin_, uint realityID_, bytes32 factHash_, address ethAddr_, int[] strikes_) {
    expiration = expiration_;
    underlying = underlying_;
    margin = margin_;
    realityID = realityID_;
    factHash = factHash_;
    ethAddr = ethAddr_;
    for (uint i=0; i < strikes_.length; i++) {
      if (numOptions<20) {
        uint optionID = numOptions++;
        options[optionID] = strikes_[i];
      }
    }
  }

  function getAccountID(address user) constant returns(uint) {
    return accountIDs[user];
  }

  function getAccount(uint accountID) constant returns(address) {
    return accounts[accountID].user;
  }

  function addFunds() {
    if (accountIDs[msg.sender]>0) {
      accounts[accountIDs[msg.sender]].capital += int(msg.value);
    } else {
      uint accountID = ++numAccounts;
      accounts[accountID].user = msg.sender;
      accounts[accountID].capital += int(msg.value);
      accountIDs[msg.sender] = accountID;
    }
    Deposit(msg.sender, msg.value, accounts[accountIDs[msg.sender]].capital);
  }

  function withdrawFunds(uint amount) {
    if (accountIDs[msg.sender]>0) {
      if (int(amount)<=getFunds(msg.sender, true) && int(amount)>0) {
        accounts[accountIDs[msg.sender]].capital -= int(amount);
        msg.sender.call.value(amount)();
        Withdraw(msg.sender, amount, accounts[accountIDs[msg.sender]].capital);
      }
    }
  }

  function getFunds(address user, bool onlyAvailable) constant returns(int) {
    if (accountIDs[user]>0) {
      if (onlyAvailable == false) {
        return accounts[accountIDs[user]].capital;
      } else {
        return accounts[accountIDs[user]].capital + getMaxLossAfterTrade(user, 0, 0, 0);
      }
    } else {
      return 0;
    }
  }

  function getFundsAndAvailable(address user) constant returns(int, int) {
    return (getFunds(user, false), getFunds(user, true));
  }

  function marketMaker(string server) {
    if (msg.value>0) throw;
    if (marketMakerIDs[msg.sender]>0) {
      marketMakers[marketMakerIDs[msg.sender]].server = server;
    } else {
      int funds = getFunds(marketMakers[i].user, false);
      uint marketMakerID = 0;
      if (numMarketMakers<6) {
        marketMakerID = ++numMarketMakers;
      } else {
        for (uint i=2; i<=numMarketMakers; i++) {
          if (getFunds(marketMakers[i].user, false)<=funds && (marketMakerID==0 || getFunds(marketMakers[i].user, false)<getFunds(marketMakers[marketMakerID].user, false))) {
            marketMakerID = i;
          }
        }
      }
      if (marketMakerID>0) {
        marketMakerIDs[marketMakers[marketMakerID].user] = 0;
        marketMakers[marketMakerID].user = msg.sender;
        marketMakers[marketMakerID].server = server;
        marketMakerIDs[msg.sender] = marketMakerID;
        NewMarketMaker(msg.sender, server);
      } else {
        throw;
      }
    }
  }

  function getMarketMakers() constant returns(string, string, string, string, string, string) {
    string[] memory servers = new string[](6);
    for (uint i=1; i<=numMarketMakers; i++) {
      servers[i-1] = marketMakers[i].server;
    }
    return (servers[0], servers[1], servers[2], servers[3], servers[4], servers[5]);
  }

  function getMarketMakerFunds() constant returns(int, int, int, int, int, int) {
    int[] memory funds = new int[](6);
    for (uint i=1; i<=numMarketMakers; i++) {
      funds[i-1] = getFunds(marketMakers[i].user, false);
    }
    return (funds[0], funds[1], funds[2], funds[3], funds[4], funds[5]);
  }

  function getOptionChain() constant returns (uint, string, uint, uint, bytes32, address) {
    return (expiration, underlying, margin, realityID, factHash, ethAddr);
  }

  function getMarket(address user) constant returns(uint[], int[], int[], int[]) {
    uint[] memory optionIDs = new uint[](20);
    int[] memory strikes_ = new int[](20);
    int[] memory positions_ = new int[](20);
    int[] memory cashes = new int[](20);
    uint z = 0;
    if (expired == false) {
      for (uint optionID=0; optionID<numOptions; optionID++) {
        optionIDs[z] = optionID;
        strikes_[z] = options[optionID];
        positions_[z] = positions[user].positions[optionID];
        cashes[z] = positions[user].cash;
        z++;
      }
    }
    return (optionIDs, strikes_, positions_, cashes);
  }

  function expire(uint accountID, uint8 v, bytes32 r, bytes32 s, bytes32 value) {
    if (expired == false) {
      if (ecrecover(sha3(factHash, value), v, r, s) == ethAddr) {
        uint lastAccount = numAccounts;
        if (accountID==0) {
          accountID = 1;
        } else {
          lastAccount = accountID;
        }
        for (accountID=accountID; accountID<=lastAccount; accountID++) {
          if (positions[accounts[accountID].user].expired == false) {
            int result = positions[accounts[accountID].user].cash / 1000000000000000000;
            for (uint optionID=0; optionID<numOptions; optionID++) {
              int moneyness = getMoneyness(options[optionID], uint(value), margin);
              result += moneyness * positions[accounts[accountID].user].positions[optionID] / 1000000000000000000;
            }
            positions[accounts[accountID].user].expired = true;
            uint amountToSend = uint(accounts[accountID].capital + result);
            accounts[accountID].capital = 0;
            if (positions[accounts[accountID].user].hasPosition==true) {
              numPositionsExpired++;
            }
            accounts[accountID].user.call.value(amountToSend)();
            Expire(msg.sender, accounts[accountID].user);
          }
        }
        if (numPositionsExpired == numPositions) {
          expired = true;
        }
      }
    }
  }

  function getMoneyness(int strike, uint settlement, uint margin) constant returns(int) {
    if (strike>=0) { //call
      if (settlement>uint(strike)) {
        if (settlement-uint(strike)<margin) {
          return int(settlement-uint(strike));
        } else {
          return int(margin);
        }
      } else {
        return 0;
      }
    } else { //put
      if (settlement<uint(-strike)) {
        if (uint(-strike)-settlement<margin) {
          return int(uint(-strike)-settlement);
        } else {
          return int(margin);
        }
      } else {
        return 0;
      }
    }
  }

  function orderMatchTest(uint optionID, uint price, int size, uint orderID, uint blockExpires, address addr, address sender, uint value, int matchSize) constant returns(bool) {
    if (block.number<=blockExpires && ((size>0 && matchSize<0 && orderFills[sha3(optionID, price, size, orderID, blockExpires)]-matchSize<=size) || (size<0 && matchSize>0 && orderFills[sha3(optionID, price, size, orderID, blockExpires)]-matchSize>=size)) && getFunds(addr, false)+getMaxLossAfterTrade(addr, optionID, -matchSize, matchSize * int(price))>0 && getFunds(sender, false)+int(value)+getMaxLossAfterTrade(sender, optionID, matchSize, -matchSize * int(price))>0) {
      return true;
    }
    return false;
  }

  function orderMatch(uint optionID, uint price, int size, uint orderID, uint blockExpires, address addr, uint8 v, bytes32 r, bytes32 s, int matchSize) {
    addFunds();
    bytes32 hash = sha256(optionID, price, size, orderID, blockExpires);
    if (ecrecover(hash, v, r, s) == addr && block.number<=blockExpires && ((size>0 && matchSize<0 && orderFills[hash]-matchSize<=size) || (size<0 && matchSize>0 && orderFills[hash]-matchSize>=size)) && getFunds(addr, false)+getMaxLossAfterTrade(addr, optionID, -matchSize, matchSize * int(price))>0 && getFunds(msg.sender, false)+getMaxLossAfterTrade(msg.sender, optionID, matchSize, -matchSize * int(price))>0) {
      if (positions[msg.sender].hasPosition == false) {
        positions[msg.sender].hasPosition = true;
        numPositions++;
      }
      if (positions[addr].hasPosition == false) {
        positions[addr].hasPosition = true;
        numPositions++;
      }
      positions[msg.sender].positions[optionID] += matchSize;
      positions[msg.sender].cash -= matchSize * int(price);
      positions[addr].positions[optionID] -= matchSize;
      positions[addr].cash += matchSize * int(price);
      orderFills[hash] -= matchSize;
      OrderMatch(msg.sender, matchSize, addr, size, optionID, price);
    } else {
      OrderMatchFailure(msg.sender, matchSize, addr, size, optionID, price);
    }
  }

  function getMaxLossAfterTrade(address user, uint optionID, int positionChange, int cashChange) constant returns(int) {
    bool maxLossInitialized = false;
    int maxLoss = 0;
    if (positions[user].expired == false && numOptions>0) {
      for (uint s=0; s<numOptions; s++) {
        int pnl = positions[user].cash / 1000000000000000000;
        pnl += cashChange / 1000000000000000000;
        uint settlement = 0;
        if (options[s]<0) {
          settlement = uint(-options[s]);
        } else {
          settlement = uint(options[s]);
        }
        pnl += moneySumAtSettlement(user, optionID, positionChange, settlement);
        if (pnl<maxLoss || maxLossInitialized==false) {
          maxLossInitialized = true;
          maxLoss = pnl;
        }
        pnl = positions[user].cash / 1000000000000000000;
        pnl += cashChange / 1000000000000000000;
        settlement = 0;
        if (options[s]<0) {
          if (uint(-options[s])>margin) {
            settlement = uint(-options[s])-margin;
          } else {
            settlement = 0;
          }
        } else {
          settlement = uint(options[s])+margin;
        }
        pnl += moneySumAtSettlement(user, optionID, positionChange, settlement);
        if (pnl<maxLoss) {
          maxLoss = pnl;
        }
      }
    }
    return maxLoss;
  }

  function moneySumAtSettlement(address user, uint optionID, int positionChange, uint settlement) internal returns(int) {
    int pnl = 0;
    for (uint j=0; j<numOptions; j++) {
      pnl += positions[user].positions[j] * getMoneyness(options[j], settlement, margin) / 1000000000000000000;
      if (j==optionID) {
        pnl += positionChange * getMoneyness(options[j], settlement, margin) / 1000000000000000000;
      }
    }
    return pnl;
  }

  function min(uint a, uint b) constant returns(uint) {
    if (a<b) {
      return a;
    } else {
      return b;
    }
  }
}
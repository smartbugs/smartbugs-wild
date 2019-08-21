pragma solidity ^0.4.19;
// last compiled with v0.4.19+commit.c4cbbb05;

contract SafeMath {
  //internals

  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c>=a && c>=b);
    return c;
  }
}

contract Token {

  /// @return total amount of tokens
  function totalSupply() public constant returns (uint256 supply) {}

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) public constant returns (uint256 balance) {}

  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) public returns (bool success) {}

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}

  /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of wei to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) public returns (bool success) {}

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {}

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

  function transfer(address _to, uint256 _value) public returns (bool success) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
    if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
    //if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else { return false; }
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    //same as above. Replace this line with the following if you want to protect against wrapping uints.
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
    //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      balances[_to] += _value;
      balances[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);
      return true;
    } else { return false; }
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  mapping(address => uint256) public balances;

  mapping (address => mapping (address => uint256)) public allowed;

  uint256 public totalSupply;

}

contract ReserveToken is StandardToken, SafeMath {
  string public name;
  string public symbol;
  uint public decimals = 18;
  address public minter;

  event Create(address account, uint amount);
  event Destroy(address account, uint amount);

  function ReserveToken(string name_, string symbol_) public {
    name = name_;
    symbol = symbol_;
    minter = msg.sender;
  }

  function create(address account, uint amount) public {
    require(msg.sender == minter);
    balances[account] = safeAdd(balances[account], amount);
    totalSupply = safeAdd(totalSupply, amount);
    Create(account, amount);
  }

  function destroy(address account, uint amount) public {
    require(msg.sender == minter);
    require(balances[account] >= amount);
    balances[account] = safeSub(balances[account], amount);
    totalSupply = safeSub(totalSupply, amount);
    Destroy(account, amount);
  }
}

contract Challenge is SafeMath {

  uint public fee = 10 * (10 ** 16); // fee percentage (100% = 10 ** 18)
  uint public blockPeriod = 6000; // period of blocks for waiting until certain transactions can be sent
  uint public blockNumber; // block number when this challenge was initiated
  bool public funded; // has the initial challenger funded the contract?
  address public witnessJury; // the WitnessJury smart contract
  address public token; // the token of the prize pool
  address public user1; // the initial challenger
  address public user2; // the responding challenger
  string public key1; // something to identify the initial challenger
  string public key2; // something to identify the responding challenger
  uint public amount; // the amount each challenger committed to prize pool
  address public host; // the witness who agreed to host
  string public hostKey; // something to identify the host
  string public witnessJuryKey; // something the host used to identify the challenge specifics
  uint public witnessJuryRequestNum; // the WitnessJury request number (in the WitnessJury smart contract)
  uint public winner; // the winner (1 or 2)
  bool public rescued; // has the contract been rescued?
  bool public juryCalled; // has the jury been called?
  address public referrer; // the referrer of the person who created the challenge (splits reward with host)

  event NewChallenge(uint amount, address user1, string key1);
  event Fund();
  event Respond(address user2, string key2);
  event Host(address host, string hostKey);
  event SetWitnessJuryKey(uint witnessJuryRequestNum, string witnessJuryKey);
  event RequestJury();
  event Resolve(uint winner, bool wasContested, uint winnerAmount, uint hostAmount, uint witnessJuryAmount);
  event Rescue();

  function Challenge(address witnessJury_, address token_, uint amount_, address user1_, string key1_, uint blockPeriod_, address referrer_) public {
    require(amount_ > 0);
    blockPeriod = blockPeriod_;
    witnessJury = witnessJury_;
    token = token_;
    user1 = user1_;
    key1 = key1_;
    amount = amount_;
    referrer = referrer_;
    blockNumber = block.number;
    NewChallenge(amount, user1, key1);
  }

  function fund() public {
    // remember to call approve() on the token first...
    require(!funded);
    require(!rescued);
    require(msg.sender == user1);
    require(Token(token).transferFrom(user1, this, amount));
    funded = true;
    blockNumber = block.number;
    Fund();
  }

  function respond(address user2_, string key2_) public {
    // remember to call approve() on the token first...
    require(user2 == 0x0);
    require(msg.sender == user2_);
    require(funded);
    require(!rescued);
    user2 = user2_;
    key2 = key2_;
    blockNumber = block.number;
    require(Token(token).transferFrom(user2, this, amount));
    Respond(user2, key2);
  }

  function host(string hostKey_) public {
    require(host == 0x0);
    require(!rescued);
    host = msg.sender;
    hostKey = hostKey_;
    blockNumber = block.number;
    Host(host, hostKey);
  }

  function setWitnessJuryKey(string witnessJuryKey_) public {
    require(witnessJuryRequestNum == 0);
    require(msg.sender == host);
    require(!rescued);
    witnessJuryRequestNum = WitnessJury(witnessJury).numRequests() + 1;
    witnessJuryKey = witnessJuryKey_;
    blockNumber = block.number;
    WitnessJury(witnessJury).newRequest(witnessJuryKey, this);
    SetWitnessJuryKey(witnessJuryRequestNum, witnessJuryKey);
  }

  function requestJury() public {
    require(!juryCalled);
    require(msg.sender == user1 || msg.sender == user2);
    require(!rescued);
    require(winner == 0);
    require(WitnessJury(witnessJury).getWinner1(witnessJuryRequestNum) != 0 && WitnessJury(witnessJury).getWinner2(witnessJuryRequestNum) != 0);
    juryCalled = true;
    blockNumber = block.number;
    WitnessJury(witnessJury).juryNeeded(witnessJuryRequestNum);
    RequestJury();
  }

  function resolve(uint witnessJuryRequestNum_, bool juryContested, address[] majorityJurors, uint winner_, address witness1, address witness2, uint witnessJuryRewardPercentage) public {
    require(winner == 0);
    require(witnessJuryRequestNum_ == witnessJuryRequestNum);
    require(msg.sender == witnessJury);
    require(winner_ == 1 || winner_ == 2);
    require(!rescued);
    require(block.number > blockNumber + blockPeriod);
    uint totalFee = safeMul(safeMul(amount, 2), fee) / (1 ether);
    uint winnerAmount = safeSub(safeMul(amount, 2), totalFee);
    uint witnessJuryAmount = safeMul(totalFee, witnessJuryRewardPercentage) / (1 ether);
    uint hostAmount = safeSub(totalFee, witnessJuryAmount);
    uint flipWinner = winner_ == 1 ? 2 : 1;
    winner = juryContested ? flipWinner : winner_;
    if (winnerAmount > 0) {
      require(Token(token).transfer(winner == 1 ? user1 : user2, winnerAmount));
    }
    if (referrer != 0x0 && hostAmount / 2 > 0) {
      require(Token(token).transfer(host, hostAmount / 2));
      require(Token(token).transfer(referrer, hostAmount / 2));
    } else if (referrer == 0 && hostAmount > 0) {
      require(Token(token).transfer(host, hostAmount));
    }
    if (!juryContested && witnessJuryAmount / 2 > 0) {
      require(Token(token).transfer(witness1, witnessJuryAmount / 2));
      require(Token(token).transfer(witness2, witnessJuryAmount / 2));
    } else if (juryContested && witnessJuryAmount / majorityJurors.length > 0) {
      for (uint i = 0; i < majorityJurors.length; i++) {
        require(Token(token).transfer(majorityJurors[i], witnessJuryAmount / majorityJurors.length));
      }
    }
    uint excessBalance = Token(token).balanceOf(this);
    if (excessBalance > 0) {
      require(Token(token).transfer(0x0, excessBalance));
    }
    Resolve(winner, juryContested, winnerAmount, hostAmount, witnessJuryAmount);
  }

  function rescue() public {
    require(!rescued);
    require(funded);
    require(block.number > blockNumber + blockPeriod * 10);
    require(msg.sender == user1 || msg.sender == user2);
    require(winner == 0);
    rescued = true;
    if (user2 != 0x0) {
      require(Token(token).transfer(user1, amount));
      require(Token(token).transfer(user2, amount));
    } else {
      require(Token(token).transfer(user1, amount));
    }
    Rescue();
  }

}

contract ChallengeFactory is SafeMath {

  address witnessJury;
  address token;

  mapping(uint => Challenge) public challenges;
  uint numChallenges;

  event NewChallenge(address addr, uint amount, address user, string key);

  function ChallengeFactory(address witnessJury_, address token_) public {
    witnessJury = witnessJury_;
    token = token_;
  }

  function newChallenge(uint amount, address user, string key, address referrer) public {
    numChallenges = safeAdd(numChallenges, 1);
    uint blockPeriod = 6000;
    challenges[numChallenges] = new Challenge(witnessJury, token, amount, user, key, blockPeriod, referrer);
    NewChallenge(address(challenges[numChallenges]), amount, user, key);
  }

}

contract WitnessJury is SafeMath {
  mapping(address => uint) public balances; // mapping of witness address to witness balance
  uint public limit = 10 ** 16; // 1% = the max percentage of the overall witness pool one person can have
  uint public numWitnessesBeforeLimit = 100; // the number of witnesses before the limit starts kicking in
  uint public totalBalance; // the total of all witness balances
  uint public numWitnesses; // count of total witnesses with non-zero balances
  uint public blockPeriod = 6000; // 1 day at 14.4 seconds per block
  uint public desiredWitnesses = 2; // desired number of witnesses to fulfill a request (witness a match)
  uint public desiredJurors = 3; // desired number of jurors
  uint public penalty = 50 * (10 ** 16); // penalty for witnesses if jury votes yes (penalty is sent back to the witnesses)
  address public token; // the token being staked by witnesses
  mapping(uint => Request) public requests; // mapping of requests that are partially or completely filled
  uint public numRequests; // count of total number of partially or completely filled requests
  mapping(uint => uint) public requestsPerBlockGroup; // map of number of requests per block group
  uint public drmVolumeCap = 10000; // after this many matches per block group, fee stops increasing
  uint public drmMinFee = 25 * (10 ** 16); // minimum witness reward percentage (100% = 10 ** 18)
  uint public drmMaxFee = 50 * (10 ** 16); // maximum witness reward percentage (100% = 10 ** 18)
  mapping(uint => bool) public juryNeeded; // mapping of requestNum to whether the jury is needed
  mapping(uint => mapping(address => bool)) public juryVoted; // mapping of requestNum to juror addresses who already voted
  mapping(uint => uint) public juryYesCount; // mapping of requestNum to number of yes votes
  mapping(uint => uint) public juryNoCount; // mapping of requestNum to number of no votes
  mapping(uint => address[]) public juryYesVoters; // mapping of requestNum to array of yes voters
  mapping(uint => address[]) public juryNoVoters; // mapping of requestNum to array of no voters

  struct Request {
    string key; // the key, which should contain details about the request (for example, match ID)
    address witness1; // the first witness
    address witness2; // the second witness
    string answer1; // the first witness' answer
    string answer2; // the second witness' answer
    uint winner1; // the first witness' winner
    uint winner2; // the second witness' winner
    uint fee; // percentage of match fee that will go to witness / jury pool (100% = 10 ** 18)
    address challenge; // challenge smart contract
    uint blockNumber; // block number when request was made
  }

  event Deposit(uint amount);
  event Withdraw(uint amount);
  event ReduceToLimit(address witness, uint amount);
  event Report(uint requestNum, string answer, uint winner);
  event NewRequest(uint requestNum, string key);
  event JuryNeeded(uint requestNum);
  event JuryVote(uint requestNum, address juror, bool vote);
  event Resolve(uint requestNum);
  event JuryContested(uint requestNum);

  function WitnessJury(address token_) public {
    token = token_;
  }

  function balanceOf(address user) public constant returns(uint) {
    return balances[user];
  }

  function reduceToLimit(address witness) public {
    require(witness == msg.sender);
    uint amount = balances[witness];
    uint limitAmount = safeMul(totalBalance, limit) / (1 ether);
    if (amount > limitAmount && numWitnesses > numWitnessesBeforeLimit) {
      uint excess = safeSub(amount, limitAmount);
      balances[witness] = safeSub(amount, excess);
      totalBalance = safeSub(totalBalance, excess);
      require(Token(token).transfer(witness, excess));
      ReduceToLimit(witness, excess);
    }
  }

  function deposit(uint amount) public {
    // remember to call approve() on the token first...
    require(amount > 0);
    if (balances[msg.sender] == 0) {
      numWitnesses = safeAdd(numWitnesses, 1);
    }
    balances[msg.sender] = safeAdd(balances[msg.sender], amount);
    totalBalance = safeAdd(totalBalance, amount);
    require(Token(token).transferFrom(msg.sender, this, amount));
    Deposit(amount);
  }

  function withdraw(uint amount) public {
    require(amount > 0);
    require(amount <= balances[msg.sender]);
    balances[msg.sender] = safeSub(balances[msg.sender], amount);
    totalBalance = safeSub(totalBalance, amount);
    if (balances[msg.sender] == 0) {
      numWitnesses = safeSub(numWitnesses, 1);
    }
    require(Token(token).transfer(msg.sender, amount));
    Withdraw(amount);
  }

  function isWitness(uint requestNum, address witness) public constant returns(bool) {
    //random number from 0-999999999
    bytes32 hash = sha256(this, requestNum, requests[requestNum].key);
    uint rand = uint(sha256(requestNum, hash, witness)) % 1000000000;
    return (
      rand * totalBalance < 1000000000 * desiredWitnesses * balances[witness] ||
      block.number > requests[requestNum].blockNumber + blockPeriod
    );
  }

  function isJuror(uint requestNum, address juror) public constant returns(bool) {
    //random number from 0-999999999
    bytes32 hash = sha256(1, this, requestNum, requests[requestNum].key);
    uint rand = uint(sha256(requestNum, hash, juror)) % 1000000000;
    return (
      rand * totalBalance < 1000000000 * desiredWitnesses * balances[juror]
    );
  }

  function newRequest(string key, address challenge) public {
    numRequests = safeAdd(numRequests, 1);
    require(requests[numRequests].challenge == 0x0);
    requests[numRequests].blockNumber = block.number;
    requests[numRequests].challenge = challenge;
    requests[numRequests].key = key;
    requestsPerBlockGroup[block.number / blockPeriod] = safeAdd(requestsPerBlockGroup[block.number / blockPeriod], 1);
    uint recentNumRequests = requestsPerBlockGroup[block.number / blockPeriod];
    if (recentNumRequests < drmVolumeCap) {
      requests[numRequests].fee = safeAdd(safeMul(safeMul(recentNumRequests, recentNumRequests), safeSub(drmMaxFee, drmMinFee)) / safeMul(drmVolumeCap, drmVolumeCap), drmMinFee);
    } else {
      requests[numRequests].fee = drmMaxFee;
    }
    NewRequest(numRequests, key);
  }

  function report(uint requestNum, string answer, uint winner) public {
    require(requests[requestNum].challenge != 0x0);
    require(requests[requestNum].witness1 == 0x0 || requests[requestNum].witness2 == 0x0);
    require(requests[requestNum].witness1 != msg.sender);
    require(isWitness(requestNum, msg.sender));
    reportLogic(requestNum, answer, winner);
    Report(requestNum, answer, winner);
  }

  function reportLogic(uint requestNum, string answer, uint winner) private {
    reduceToLimit(msg.sender);
    if (requests[requestNum].witness1 == 0x0) {
      requests[requestNum].witness1 = msg.sender;
      requests[requestNum].answer1 = answer;
      requests[requestNum].winner1 = winner;
    } else if (requests[requestNum].witness2 == 0x0) {
      requests[requestNum].witness2 = msg.sender;
      requests[requestNum].answer2 = answer;
      requests[requestNum].winner2 = winner;
    }
  }

  function juryNeeded(uint requestNum) public {
    require(msg.sender == requests[requestNum].challenge);
    require(!juryNeeded[requestNum]);
    juryNeeded[requestNum] = true;
    JuryNeeded(requestNum);
  }

  function juryVote(uint requestNum, bool vote) public {
    require(!juryVoted[requestNum][msg.sender]);
    require(juryNeeded[requestNum]);
    require(safeAdd(juryYesCount[requestNum], juryNoCount[requestNum]) < desiredJurors);
    require(isJuror(requestNum, msg.sender));
    juryVoted[requestNum][msg.sender] = true;
    if (vote) {
      juryYesCount[requestNum] = safeAdd(juryYesCount[requestNum], 1);
      juryYesVoters[requestNum].push(msg.sender);
    } else {
      juryNoCount[requestNum] = safeAdd(juryNoCount[requestNum], 1);
      juryNoVoters[requestNum].push(msg.sender);
    }
    JuryVote(requestNum, msg.sender, vote);
  }

  function resolve(uint requestNum) public {
    bool juryContested = juryYesCount[requestNum] > juryNoCount[requestNum] && safeAdd(juryYesCount[requestNum], juryNoCount[requestNum]) == desiredJurors;
    Challenge(requests[requestNum].challenge).resolve(
      requestNum,
      juryContested,
      juryYesCount[requestNum] > juryNoCount[requestNum] ? juryYesVoters[requestNum] : juryNoVoters[requestNum],
      requests[requestNum].winner1,
      requests[requestNum].witness1,
      requests[requestNum].witness2,
      requests[requestNum].fee
    );
    if (juryContested) {
      uint penalty1 = safeMul(balances[requests[requestNum].witness1], penalty) / (1 ether);
      uint penalty2 = safeMul(balances[requests[requestNum].witness2], penalty) / (1 ether);
      balances[requests[requestNum].witness1] = safeSub(balances[requests[requestNum].witness1], penalty1);
      balances[requests[requestNum].witness2] = safeSub(balances[requests[requestNum].witness2], penalty2);
      require(Token(token).transfer(requests[requestNum].witness1, penalty1));
      require(Token(token).transfer(requests[requestNum].witness2, penalty2));
      JuryContested(requestNum);
    }
    Resolve(requestNum);
  }

  function getWinner1(uint requestNum) public constant returns(uint) {
    return requests[requestNum].winner1;
  }

  function getWinner2(uint requestNum) public constant returns(uint) {
    return requests[requestNum].winner2;
  }

  function getRequest(uint requestNum) public constant returns(string, address, address, string, string, uint, address) {
    return (requests[requestNum].key,
            requests[requestNum].witness1,
            requests[requestNum].witness2,
            requests[requestNum].answer1,
            requests[requestNum].answer2,
            requests[requestNum].fee,
            requests[requestNum].challenge);
  }
}
pragma solidity 0.4.25;

// EthBet betting games


contract EthBet {

  constructor() public {
    owner = msg.sender;
    balances[address(this)] = 0;
    lockedFunds = 0;
  }

  function() public payable {
    require(msg.data.length == 0, "Not in use");
  }

  address public owner;
  // The address corresponding to a private key used to sign placeBet commits.
  address public secretSigner = 0x87cF6EdB672Fe969d8B65e9D501e246B91DDF8e1;
  bool public isActive = true;
  uint public totalPlayableFunds;
  uint public lockedFunds;

  uint HOUSE_EDGE_PERCENT = 2;
  uint REFERRER_BONUS_PERCENT = 1;
  uint REFEREE_FIRST_TIME_BONUS = 0.01 ether;
  uint HOUSE_EDGE_MIN_AMOUNT = 0.0003 ether;

  uint MINBET = 0.01 ether;
  uint MAXBET = 1 ether;
  uint constant MAX_MODULO = 100;
  uint constant MAX_BET_MASK = 99;
  uint constant BET_EXPIRATION_BLOCKS = 250;

  mapping(address => uint) balances;
  mapping(address => address) referrers;
  address[] playerAddresses; 

  modifier ownerOnly {
    require(msg.sender == owner, "Ownly Owner");
    _;
  }


  modifier runWhenActiveOnly {
    require(isActive,"Only Active");
    _;
  }

  modifier runWhenNotActiveOnly {
    require(!isActive,"Only Inactive");
    _;
  }

  modifier validBetAmountOnly(uint amount) {
    require(amount >= MINBET && amount < MAXBET && amount < totalPlayableFunds,"Invalid betAmount");
    _;
  }

  event Withdrawal(address benificiary, uint amount);
  event ReceivedFund(address benificiary, uint amount);

  event RefererSet(address player, address referrer);
  event WinBet(address better, uint betAmount, uint winAmount, uint currentBalance);
  event LoseBet(address better, uint betAmount, uint loseAmount, uint currentBalance);

  event Active();
  event Deactive();

  event Destroyed();
  event NewPlayer(address[] players);
  event ReferralFailedPayout(address receiver, uint amount);
  event DestroyFailedPayout(address receiver, uint amount);

  /**
   * Ownable
   */

  function transferOwnership(address _newOwner) public ownerOnly {
    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0), "Invalid Address");
    owner = _newOwner;
  }

  // See comment for "secretSigner" variable.
  function setSecretSigner(address newSecretSigner) external ownerOnly {
    secretSigner = newSecretSigner;
  }


  /**
   * Pausable
   */
  function toggleActive() public ownerOnly {
    isActive = !isActive;
    if (isActive)
      emit Active();
    else
      emit Deactive();
  }

  /**
   * Destructible
   */
  function destroy() public ownerOnly {
    emit Destroyed();
    payOutAllBalanceBeforeDestroy();
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public ownerOnly {
    emit Destroyed();
    payOutAllBalanceBeforeDestroy();
    selfdestruct(_recipient);
  }

  /**
   * Readable
   */

  event LoggingData(uint contractBalance, uint totalHouseEdge, uint totalPlayableFunds);

  function logData() external {
    emit LoggingData(
      address(this).balance,
      balances[address(this)],
      totalPlayableFunds
    );
  } 

  /**
   * Editable
   */
  
  function editBetData(
    uint _houseEdgePercent, 
    uint _houseEdgeMin,
    uint _refererBonusPercent,
    uint _referreeFirstTimeBonus,
    uint _minBet,
    uint _maxBet) external ownerOnly {

    HOUSE_EDGE_PERCENT = _houseEdgePercent;
    HOUSE_EDGE_MIN_AMOUNT = _houseEdgeMin;
    REFERRER_BONUS_PERCENT = _refererBonusPercent;
    REFEREE_FIRST_TIME_BONUS = _referreeFirstTimeBonus;

    MINBET = _minBet;
    MAXBET = _maxBet;
  }

  /**
   * Contract external functions
   */

  function playBalance(
    uint betValue, 
    uint betMask, 
    uint modulo, 
    uint commitLastBlock, 
    bytes32 commit, 
    bytes32 r, 
    bytes32 s, 
    uint8 v) external runWhenActiveOnly validBetAmountOnly(betValue) {

    validateCommit(commitLastBlock, commit, r, s, v);
    
    uint _possibleWinAmount;
    uint _referrerBonus;
    uint _houseEdge;
    bool _isWin;
    
    (_possibleWinAmount, _referrerBonus, _houseEdge, _isWin) = play(msg.sender, betValue, betMask, modulo, commit);
    settleBet(msg.sender, betValue, _possibleWinAmount, _referrerBonus, _houseEdge, _isWin, true);
  }

  function playTopUp(
    uint betMask, 
    uint modulo, 
    uint commitLastBlock, 
    bytes32 commit, 
    bytes32 r, 
    bytes32 s, 
    uint8 v) external payable  runWhenActiveOnly validBetAmountOnly(msg.value) {

    validateCommit(commitLastBlock, commit, r, s, v);

    uint _possibleWinAmount;
    uint _referrerBonus;
    uint _houseEdge;
    bool _isWin;

    (_possibleWinAmount, _referrerBonus, _houseEdge, _isWin) = play(msg.sender, msg.value, betMask, modulo, commit);
    settleBet(msg.sender, msg.value, _possibleWinAmount, _referrerBonus, _houseEdge, _isWin, false);
  }

  function playFirstTime(
    address referrer, 
    uint betMask, 
    uint modulo, 
    uint commitLastBlock, 
    bytes32 commit, 
    bytes32 r, 
    bytes32 s, 
    uint8 v) external payable runWhenActiveOnly validBetAmountOnly(msg.value) {

    validateCommit(commitLastBlock, commit, r, s, v);
    setupFirstTimePlayer(msg.sender);

    uint _betAmount = msg.value;
    if(referrer != address(0) && referrer != msg.sender && referrers[msg.sender] == address(0)) {
      _betAmount += REFEREE_FIRST_TIME_BONUS; 
      setReferrer(msg.sender, referrer);
    }
    else
      setReferrer(msg.sender, address(this));

    uint _possibleWinAmount;
    uint _referrerBonus;
    uint _houseEdge;
    bool _isWin;

    (_possibleWinAmount, _referrerBonus, _houseEdge, _isWin) = play(msg.sender, _betAmount, betMask, modulo, commit);
    settleBet(msg.sender, _betAmount, _possibleWinAmount, _referrerBonus, _houseEdge, _isWin, false);
  }

  function playSitAndGo(
    uint betMask, 
    uint modulo, 
    uint commitLastBlock, 
    bytes32 commit, 
    bytes32 r, 
    bytes32 s, 
    uint8 v) external payable  runWhenActiveOnly validBetAmountOnly(msg.value) {

    validateCommit(commitLastBlock, commit, r, s, v);

    uint _possibleWinAmount;
    uint _referrerBonus;
    uint _houseEdge;
    bool _isWin;

    (_possibleWinAmount, _referrerBonus, _houseEdge, _isWin) = play(msg.sender, msg.value, betMask, modulo, commit);
    settleBetAutoWithdraw(msg.sender, msg.value, _possibleWinAmount, _referrerBonus, _houseEdge, _isWin);
  }

  function withdrawFunds() external {
    require(balances[msg.sender] > 0, "Not enough balance");
    uint _amount = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(_amount);
    emit Withdrawal(msg.sender, _amount);
  }

  function withdrawForOperationalCosts(uint amount) external ownerOnly {
    require(amount < totalPlayableFunds, "Amount needs to be smaller than total fund");
    totalPlayableFunds -= amount;
    msg.sender.transfer(amount);
  }

  function donateFunds() external payable {
    require(msg.value > 0, "Please be more generous!!");
    uint _oldtotalPlayableFunds = totalPlayableFunds;
    totalPlayableFunds += msg.value;

    assert(totalPlayableFunds >= _oldtotalPlayableFunds);
  }

  function topUp() external payable {
    require(msg.value > 0,"Topup valu needs to be greater than 0");
    balances[msg.sender] += msg.value;
  }

  function getBalance() external view returns(uint) {
    return balances[msg.sender];
  }

  /**
   * Conract interal functions
   */


  function validateCommit(uint commitLastBlock, bytes32 commit, bytes32 r, bytes32 s, uint8 v) internal view {
    require(block.number <= commitLastBlock, "Commit has expired.");
    bytes32 signatureHash = keccak256(abi.encodePacked(commitLastBlock, commit));
    require(secretSigner == ecrecover(signatureHash, v, r, s), "ECDSA signature is not valid.");
  }

  function settleBet(
    address beneficiary, 
    uint betAmount,
    uint possibleWinAmount,
    uint referrerBonus,
    uint houseEdge,
    bool isWin, 
    bool playedFromBalance) internal {

    lockFunds(possibleWinAmount);

    settleReferrerBonus(referrers[beneficiary], referrerBonus);
    settleHouseEdge(houseEdge);

    if(isWin) {
      if(playedFromBalance) 
        balances[beneficiary] += possibleWinAmount - betAmount;
      else
        balances[beneficiary] += possibleWinAmount;
      totalPlayableFunds -= possibleWinAmount - betAmount;
      emit WinBet(beneficiary, betAmount, possibleWinAmount, balances[beneficiary]);
    } else {
      if(playedFromBalance) 
        balances[beneficiary] -= betAmount;

      totalPlayableFunds += betAmount;
      emit LoseBet(beneficiary, betAmount, betAmount, balances[beneficiary]);
    }

    unlockFunds(possibleWinAmount);
  }

  function settleBetAutoWithdraw(
    address beneficiary, 
    uint betAmount,
    uint possibleWinAmount,
    uint referrerBonus,
    uint houseEdge,
    bool isWin) internal {

    lockFunds(possibleWinAmount);

    settleReferrerBonus(referrers[beneficiary], referrerBonus);
    settleHouseEdge(houseEdge);

    if(isWin) {
      totalPlayableFunds -= possibleWinAmount - betAmount;
      beneficiary.transfer(possibleWinAmount);
      emit WinBet(beneficiary, betAmount, possibleWinAmount, balances[beneficiary]);
    } else {
      totalPlayableFunds += betAmount;
      emit LoseBet(beneficiary, betAmount, betAmount, balances[beneficiary]);
    }

    unlockFunds(possibleWinAmount);
  }

  function setReferrer(address referee, address referrer) internal {
    if(referrers[referee] == address(0)) {
      referrers[referee] = referrer;
      emit RefererSet(referee, referrer);
    }
  }

  function settleReferrerBonus(address referrer, uint referrerBonus) internal {
    if(referrerBonus > 0) {
      totalPlayableFunds -= referrerBonus;
      if(referrer != address(this)) {
        if(!referrer.send(referrerBonus)) 
          balances[address(this)] += referrerBonus;
      } else {
        balances[address(this)] += referrerBonus;
      }
    }
  }

  function settleHouseEdge(uint houseEdge) internal {
    totalPlayableFunds -= houseEdge;
    balances[address(this)] += houseEdge;
  }

  function setupFirstTimePlayer(address newPlayer) internal {
    if(referrers[newPlayer] == address(0)) 
      playerAddresses.push(newPlayer);
  }

  function payOutAllBalanceBeforeDestroy() internal ownerOnly {
    uint _numberOfPlayers = playerAddresses.length;
    for(uint i = 0;i < _numberOfPlayers;i++) {
      address _player = playerAddresses[i];
      uint _playerBalance = balances[_player];
      if(_playerBalance > 0) {
        if(!_player.send(_playerBalance))
          emit DestroyFailedPayout(_player, _playerBalance);
      } 
    }
  }

  function play(
    address player, 
    uint betValue,
    uint betMask, 
    uint modulo, 
    bytes32 commit) internal view returns(uint, uint, uint, bool) {

    uint _possibleWinAmount;
    uint _referrerBonus;
    uint _houseEdge;

    bool _isWin = roll(betMask, modulo, commit);
    (_possibleWinAmount, _referrerBonus, _houseEdge) = calculatePayouts(player, betValue, modulo, betMask, _isWin);
    return (_possibleWinAmount, _referrerBonus, _houseEdge, _isWin);
  }

  function calculatePayouts(
    address player, 
    uint betAmount, 
    uint modulo, 
    uint rollUnder,
    bool isWin) internal view returns(uint, uint, uint) {
    require(0 < rollUnder && rollUnder <= modulo, "Win probability out of range.");

    uint _referrerBonus = 0;
    uint _multiplier = modulo / rollUnder; 
    uint _houseEdge = betAmount * HOUSE_EDGE_PERCENT / 100;
    if(referrers[player] != address(0)) {
      _referrerBonus = _houseEdge * REFERRER_BONUS_PERCENT / HOUSE_EDGE_PERCENT; 
    }
    if(isWin)
      _houseEdge = _houseEdge * (_multiplier - 1);
    if (_houseEdge < HOUSE_EDGE_MIN_AMOUNT)
      _houseEdge = HOUSE_EDGE_MIN_AMOUNT;

    uint _possibleWinAmount = (betAmount * _multiplier) - _houseEdge;
    _houseEdge = _houseEdge - _referrerBonus;

    return (_possibleWinAmount, _referrerBonus, _houseEdge);
  }

  function roll(
    uint betMask, 
    uint modulo, 
    bytes32 commit) internal view returns(bool) {

    // Validate input data ranges.
    require(modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");
    require(0 < betMask && betMask < MAX_BET_MASK, "Mask should be within range.");

    // Check whether contract has enough funds to process this bet.
    //require(lockedFunds <= totalPlayableFunds, "Cannot afford to lose this bet.");

    // The RNG - combine "reveal" and blockhash of placeBet using Keccak256. Miners
    // are not aware of "reveal" and cannot deduce it from "commit" (as Keccak256
    // preimage is intractable), and house is unable to alter the "reveal" after
    // placeBet have been mined (as Keccak256 collision finding is also intractable).
    bytes32 entropy = keccak256(abi.encodePacked(commit, blockhash(block.number)));    

    // Do a roll by taking a modulo of entropy. Compute winning amount.
    uint dice = uint(entropy) % modulo;

    // calculating dice win
    uint diceWin = 0;

    if (dice < betMask) {
      diceWin = 1;
    }
    return diceWin > 0;
  }

  function lockFunds(uint lockAmount) internal 
  {
    lockedFunds += lockAmount;
    assert(lockedFunds <= totalPlayableFunds);
  }

  function unlockFunds(uint unlockAmount) internal
  {
    lockedFunds -= unlockAmount;
  }

}
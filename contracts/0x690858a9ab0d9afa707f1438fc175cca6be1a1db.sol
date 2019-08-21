pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 **/
contract Ownable {
    //using library SafeMath
    using SafeMath for uint;
    
    enum RequestType {
        None,
        Owner,
        CoOwner1,
        CoOwner2
    }
    
    address public owner;
    address coOwner1;
    address coOwner2;
    RequestType requestType;
    address newOwnerRequest;
    
    mapping(address => bool) voterList;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
     **/
    constructor() public {
      owner = msg.sender;
      coOwner1 = address(0x625789684cE563Fe1f8477E8B3c291855E3470dF);
      coOwner2 = address(0xe80a08C003b0b601964b4c78Fb757506d2640055);
    }
    
    /**
     * @dev Throws if called by any account other than the owner.
     **/
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    modifier onlyCoOwner1() {
        require(msg.sender == coOwner1);
        _;
    }
    modifier onlyCoOwner2() {
        require(msg.sender == coOwner2);
        _;
    }
    
    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     **/
    function transferOwnership(address newOwner) public {
      require(msg.sender == owner || msg.sender == coOwner1 || msg.sender == coOwner2);
      require(newOwner != address(0));
      
      if(msg.sender == owner) {
          requestType = RequestType.Owner;
      }
      else if(msg.sender == coOwner1) {
          requestType = RequestType.CoOwner1;
      }
      else if(msg.sender == coOwner2) {
          requestType = RequestType.CoOwner2;
      }
      newOwnerRequest = newOwner;
      voterList[msg.sender] = true;
    }
    
    function voteChangeOwner(bool isAgree) public {
        require(msg.sender == owner || msg.sender == coOwner1 || msg.sender == coOwner2);
        require(requestType != RequestType.None);
        voterList[msg.sender] = isAgree;
        checkVote();
    }
    
    function checkVote() private {
        uint iYesCount = 0;
        uint iNoCount = 0;
        if(voterList[owner] == true) {
            iYesCount = iYesCount.add(1);
        }
        else {
            iNoCount = iNoCount.add(1);
        }
        if(voterList[coOwner1] == true) {
            iYesCount = iYesCount.add(1);
        }
        else {
            iNoCount = iNoCount.add(1);
        }
        if(voterList[coOwner2] == true) {
            iYesCount = iYesCount.add(1);
        }
        else {
            iNoCount = iNoCount.add(1);
        }
        
        if(iYesCount >= 2) {
            emit OwnershipTransferred(owner, newOwnerRequest);
            if(requestType == RequestType.Owner) {
                owner = newOwnerRequest;
            }
            else if(requestType == RequestType.CoOwner1) {
                coOwner1 = newOwnerRequest;
            }
            else if(requestType == RequestType.CoOwner2) {
                coOwner2 = newOwnerRequest;
            }
            
            newOwnerRequest = address(0);
            requestType = RequestType.None;
        }
        else if(iNoCount >= 2) {
            newOwnerRequest = address(0);
            requestType = RequestType.None;
        }
    }
}

/**
 * @title Configurable
 * @dev Configurable varriables of the contract
 **/
contract Configurable {
    uint256 constant cfgPercentDivider = 10000;
    uint256 constant cfgPercentMaxReceive = 30000;
    
    uint256 public cfgMinDepositRequired = 2 * 10**17; //0.2 ETH
    uint256 public cfgMaxDepositRequired = 100*10**18; //100 ETH
    
    uint256 public minReceiveCommission = 2 * 10**16; //0.02 ETH
    uint256 public maxReceiveCommissionPercent = 15000; //150 %
    
    uint256 public supportWaitingTime;
    uint256 public supportPercent;
    uint256 public receiveWaitingTime;
    uint256 public receivePercent;
    
    uint256 public systemFeePercent = 300;          //3%
    address public systemFeeAddress;
    
    uint256 public commissionFeePercent = 300;      //3%
    address public commissionFeeAddress;
    
    uint256 public tokenSupportPercent = 500;       //5%
    address public tokenSupportAddress;
    
    uint256 public directCommissionPercent = 1000;
}
    
/**
 * @title EbcFund 
 * @dev Contract to create the game
 **/
contract EbcFund is Ownable, Configurable {
    
    /**
     * @dev enum
     **/
    enum Stages {
        Preparing,
        Started,
        Paused
    }
    enum GameStatus {
        none,
        processing,
        completed
    }
    
    /**
     * @dev Structs 
     **/
    struct Player {
        address parentAddress;
        uint256 totalDeposited;
        uint256 totalAmountInGame;
        uint256 totalReceived;
        uint256 totalCommissionReceived;
        uint lastReceiveCommission;
        bool isKyc;
        uint256 directCommission;
    }
    
    struct Game {
        address playerAddress;
        uint256 depositAmount;
        uint256 receiveAmount;
        GameStatus status;
        //
        uint nextRoundTime;
        uint256 nextRoundAmount;
    }
    
    /**
     * @dev Variables
     **/
    Stages public currentStage;
    address transporter;
    
    /**
     * @dev Events
     **/
    event Logger(string _label, uint256 _note);
    
    /**
     * @dev Mapping
     **/
    mapping(address => bool) public donateList;
    mapping(address => Player) public playerList;
    mapping(uint => Game) public gameList;
    
    /**
     * @dev constructor
     **/
    constructor() public {
        // set configs value
        systemFeeAddress = owner;
        commissionFeeAddress = address(0x4c0037cd34804aB3EB6f54d6596A22A68b05c8CF);
        tokenSupportAddress = address(0xC739c85ffE468fA7a6f2B8A005FF0eacAb4D5f0e);
        //
        supportWaitingTime = 20*86400;//20 days
        supportPercent = 70;//0.7%
        receiveWaitingTime = 5*86400;//5 days
        receivePercent = 10;//0.1%
        // 
        currentStage = Stages.Preparing;
        //
        donateList[owner] = true;
        donateList[commissionFeeAddress] = true;
        donateList[tokenSupportAddress] = true;
    }
    
    /**
     * @dev Modifiers
     **/
    modifier onlyPreparing() {
        require (currentStage == Stages.Preparing);
        _;
    }
    modifier onlyStarted() {
        require (currentStage == Stages.Started);
        _;
    }
    modifier onlyPaused() {
        require (currentStage == Stages.Paused);
        _;
    }
    
/* payments */
    /**
     * @dev fallback function to send ether to smart contract
     **/
    function () public payable {
        require(currentStage == Stages.Started);
        require(cfgMinDepositRequired <= msg.value && msg.value <= cfgMaxDepositRequired);
        
        if(donateList[msg.sender] == false) {
            if(transporter != address(0) && msg.sender == transporter) {
                //validate msg.data
                if(msg.data.length > 0) {
                    //init new game
                    processDeposit(bytesToAddress(msg.data));
                }
                else {
                     emit Logger("Thank you for your contribution!.", msg.value);
                }
            }
            else {
                //init new game
                processDeposit(msg.sender);
            }
        }
        else {
            emit Logger("Thank you for your contribution!", msg.value);
        }
    }
    
/* administrative functions */
    /**
     * @dev get transporter address
     **/
    function getTransporter() public view onlyOwner returns(address) {
        return transporter;
    }

    /**
     * @dev update "transporter"
     **/
    function updateTransporter(address _address) public onlyOwner{
        require (_address != address(0));
        transporter = _address;
    }
    
    /**
     * @dev update "donateList"
     **/
    function updateDonator(address _address, bool _isDonator) public onlyOwner{
        donateList[_address] = _isDonator;
    }
    
    /**
     * @dev update config "systemFeeAddress"
     **/
    function updateSystemAddress(address _address) public onlyOwner{
        require(_address != address(0) && _address != systemFeeAddress);
        //
        systemFeeAddress = _address;
    }
    
    /**
     * @dev update config "systemFeePercent"
     **/
    function updateSystemFeePercent(uint256 _percent) public onlyOwner{
        require(0 < _percent && _percent != systemFeePercent && _percent <= 500); //maximum is 5%
        systemFeePercent = _percent;
    }
    
    /**
     * @dev update config "commissionFeeAddress"
     **/
    function updateCommissionAddress(address _address) public onlyOwner{
        require(_address != address(0) && _address != commissionFeeAddress);
        //
        commissionFeeAddress = _address;
    }
    
    /**
     * @dev update config "commissionFeePercent"
     **/
    function updateCommissionFeePercent(uint256 _percent) public onlyOwner{
        require(0 < _percent && _percent != commissionFeePercent && _percent <= 500); //maximum is 5%
        commissionFeePercent = _percent;
    }
    
    /**
     * @dev update config "tokenSupportAddress"
     **/
    function updateTokenSupportAddress(address _address) public onlyOwner{
        require(_address != address(0) && _address != tokenSupportAddress);
        //
        tokenSupportAddress = _address;
    }
    
    /**
     * @dev update config "tokenSupportPercent"
     **/
    function updateTokenSupportPercent(uint256 _percent) public onlyOwner{
        require(0 < _percent && _percent != tokenSupportPercent && _percent <= 1000); //maximum is 10%
        tokenSupportPercent = _percent;
    }
    
    /**
     * @dev update config "directCommissionPercent"
     **/
    function updateDirectCommissionPercent(uint256 _percent) public onlyOwner{
        require(0 < _percent && _percent != directCommissionPercent && _percent <= 2000); //maximum is 20%
        directCommissionPercent = _percent;
    }
    
    /**
     * @dev update config "cfgMinDepositRequired"
     **/
    function updateMinDeposit(uint256 _amount) public onlyOwner{
        require(0 < _amount && _amount < cfgMaxDepositRequired);
        require(_amount != cfgMinDepositRequired);
        //
        cfgMinDepositRequired = _amount;
    }
    
    /**
     * @dev update config "cfgMaxDepositRequired"
     **/
    function updateMaxDeposit(uint256 _amount) public onlyOwner{
        require(cfgMinDepositRequired < _amount && _amount != cfgMaxDepositRequired);
        //
        cfgMaxDepositRequired = _amount;
    }
    
    /**
     * @dev update config "minReceiveCommission"
     **/
    function updateMinReceiveCommission(uint256 _amount) public onlyOwner{
        require(0 < _amount && _amount != minReceiveCommission);
        minReceiveCommission = _amount;
    }
    
    /**
     * @dev update config "maxReceiveCommissionPercent"
     **/
    function updateMaxReceiveCommissionPercent(uint256 _percent) public onlyOwner{
        require(5000 <= _percent && _percent <= 20000); //require from 50% to 200%
        //
        maxReceiveCommissionPercent = _percent;
    }
    
    /**
     * @dev update config "supportWaitingTime"
     **/
    function updateSupportWaitingTime(uint256 _time) public onlyOwner{
        require(86400 <= _time);
        require(_time != supportWaitingTime);
        //
        supportWaitingTime = _time;
    }
    
    /**
     * @dev update config "supportPercent"
     **/
    function updateSupportPercent(uint256 _percent) public onlyOwner{
        require(0 < _percent && _percent < 1000);
        require(_percent != supportPercent);
        //
        supportPercent = _percent;
    }
    
    /**
     * @dev update config "receiveWaitingTime"
     **/
    function updateReceiveWaitingTime(uint256 _time) public onlyOwner{
        require(86400 <= _time);
        require(_time != receiveWaitingTime);
        //
        receiveWaitingTime = _time;
    }
    
    /**
     * @dev update config "receivePercent"
     **/
    function updateRecivePercent(uint256 _percent) public onlyOwner{
        require(0 < _percent && _percent < 1000);
        require(_percent != receivePercent);
        //
        receivePercent = _percent;
    }
    
    /**
     * @dev update parent address
     **/
    function updatePlayerParent(address[] _address, address[] _parentAddress) public onlyOwner{
        
        for(uint i = 0; i < _address.length; i++) {
            require(_address[i] != address(0));
            require(_parentAddress[i] != address(0));
            require(_address[i] != _parentAddress[i]);
            
            Player storage currentPlayer = playerList[_address[i]];
            //
            currentPlayer.parentAddress = _parentAddress[i];
            if(0 < currentPlayer.directCommission && currentPlayer.directCommission < address(this).balance) {
                uint256 comAmount = currentPlayer.directCommission;
                currentPlayer.directCommission = 0;
                //Logger
                emit Logger("Send direct commission", comAmount);
                //send direct commission
                _parentAddress[i].transfer(comAmount);
            }
        }
        
    }
    
    /**
     * @dev update kyc
     **/
    function updatePlayerKyc(address[] _address, bool[] _isKyc) public onlyOwner{
        
        for(uint i = 0; i < _address.length; i++) {
            require(_address[i] != address(0));
            //
            playerList[_address[i]].isKyc = _isKyc[i];
        }
    }
    
    /**
     * @dev start game
     **/
    function startGame() public onlyOwner {
        require(currentStage == Stages.Preparing || currentStage == Stages.Paused);
        currentStage = Stages.Started;
    }
    
    /**
     * @dev pause game
     **/
    function pauseGame() public onlyOwner onlyStarted {
        currentStage = Stages.Paused;
    }
    
    /**
     * @dev insert multi games
     **/
    function importPlayers(
        address[] _playerAddress, 
        address[] _parentAddress,
        uint256[] _totalDeposited,
        uint256[] _totalReceived,
        uint256[] _totalCommissionReceived,
        bool[] _isKyc) public onlyOwner onlyPreparing {
            
            for(uint i = 0; i < _playerAddress.length; i++) {
                processImportPlayer(
                    _playerAddress[i], 
                    _parentAddress[i],
                    _totalDeposited[i],
                    _totalReceived[i],
                    _totalCommissionReceived[i],
                    _isKyc[i]);
            }
            
        }
    
    function importGames(
        address[] _playerAddress,
        uint[] _gameHash,
        uint256[] _gameAmount,
        uint256[] _gameReceived) public onlyOwner onlyPreparing {
            
            for(uint i = 0; i < _playerAddress.length; i++) {
                processImportGame(
                    _playerAddress[i], 
                    _gameHash[i],
                    _gameAmount[i],
                    _gameReceived[i]);
            }
            
        }
    
    /**
     * @dev confirm game information
     **/  
    function confirmGames(address[] _playerAddress, uint[] _gameHash, uint256[] _gameAmount) public onlyCoOwner1 onlyStarted {
        
        for(uint i = 0; i < _playerAddress.length; i++) {
            confirmGame(_playerAddress[i], _gameHash[i], _gameAmount[i]);
        }
        
    }
    
    /**
     * @dev confirm game information
     **/  
    function confirmGame(address _playerAddress, uint _gameHash, uint256 _gameAmount) public onlyCoOwner1 onlyStarted {
        //validate _gameHash
        require(100000000000 <= _gameHash && _gameHash <= 999999999999);
        //validate player information
        Player storage currentPlayer = playerList[_playerAddress];
        require(cfgMinDepositRequired <= playerList[_playerAddress].totalDeposited);
        assert(currentPlayer.totalDeposited <= currentPlayer.totalAmountInGame.add(_gameAmount));
        //update player information
        currentPlayer.totalAmountInGame = currentPlayer.totalAmountInGame.add(_gameAmount);
        //init game
        initGame(_playerAddress, _gameHash, _gameAmount, 0);
        //Logger
        emit Logger("Game started", _gameAmount);
    }
    
    /**
     * @dev process send direct commission missing
     **/
    function sendMissionDirectCommission(address _address) public onlyCoOwner2 onlyStarted {
        
        require(donateList[_address] == false);
        require(playerList[_address].parentAddress != address(0));
        require(playerList[_address].directCommission > 0);
        
        Player memory currentPlayer = playerList[_address];
        if(0 < currentPlayer.directCommission && currentPlayer.directCommission < address(this).balance) {
            uint256 comAmount = currentPlayer.directCommission;
            playerList[_address].directCommission = 0;
            //Logger
            emit Logger("Send direct commission", comAmount);
            //send direct commission
            currentPlayer.parentAddress.transfer(comAmount);
        }
        
    }
    
    /**
     * @dev process send commission
     **/
    function sendCommission(address _address, uint256 _amountCom) public onlyCoOwner2 onlyStarted {
        
        require(donateList[_address] == false);
        require(minReceiveCommission <= _amountCom && _amountCom < address(this).balance);
        require(playerList[_address].isKyc == true);
        require(playerList[_address].lastReceiveCommission.add(86400) < now);
        
        //current player
        Player storage currentPlayer = playerList[_address];
        //
        uint256 maxCommissionAmount = getMaximumCommissionAmount(
            currentPlayer.totalAmountInGame, 
            currentPlayer.totalReceived, 
            currentPlayer.totalCommissionReceived, 
            _amountCom);
        if(maxCommissionAmount > 0) {
            //update total receive
            currentPlayer.totalReceived = currentPlayer.totalReceived.add(maxCommissionAmount);
            currentPlayer.totalCommissionReceived = currentPlayer.totalCommissionReceived.add(maxCommissionAmount);
            currentPlayer.lastReceiveCommission = now;
            //fee commission
            uint256 comFee = maxCommissionAmount.mul(commissionFeePercent).div(cfgPercentDivider);
            //Logger
            emit Logger("Send commission successfully", _amountCom);
            
            if(comFee > 0) {
                maxCommissionAmount = maxCommissionAmount.sub(comFee);
                //send commission to store address
                commissionFeeAddress.transfer(comFee);
            }
            if(maxCommissionAmount > 0) {
                //send eth
                _address.transfer(maxCommissionAmount);
            }
        }
        
    }
    
    /**
     * @dev process send profit in game
     **/
    function sendProfits(
        uint[] _gameHash,
        uint256[] _profitAmount) public onlyCoOwner2 onlyStarted {
            
            for(uint i = 0; i < _gameHash.length; i++) {
                sendProfit(_gameHash[i], _profitAmount[i]);
            }
            
        }
    
    /**
     * @dev process send profit in game
     **/
    function sendProfit(
        uint _gameHash,
        uint256 _profitAmount) public onlyCoOwner2 onlyStarted {
            
            //validate game information
            Game memory game = gameList[_gameHash];
            require(game.status == GameStatus.processing);
            require(0 < _profitAmount && _profitAmount <= game.nextRoundAmount && _profitAmount < address(this).balance);
            require(now <= game.nextRoundTime);
            //validate player information
            Player memory currentPlayer = playerList[gameList[_gameHash].playerAddress];
            assert(currentPlayer.isKyc == true);
            //do sendProfit
            processSendProfit(_gameHash, _profitAmount);
            
        }
    
/* public functions */
    
/* private functions */
    /**
     * @dev process new game by deposit
     **/
    function processDeposit(address _address) private {
        
        //update player information
        Player storage currentPlayer = playerList[_address];
        currentPlayer.totalDeposited = currentPlayer.totalDeposited.add(msg.value);
        
        //Logger
        emit Logger("Game deposited", msg.value);
        
        //send token support
        uint256 tokenSupportAmount = tokenSupportPercent.mul(msg.value).div(cfgPercentDivider);
        if(tokenSupportPercent > 0) {
            tokenSupportAddress.transfer(tokenSupportAmount);
        }
        
        //send parent address
        uint256 directComAmount = directCommissionPercent.mul(msg.value).div(cfgPercentDivider);
        if(currentPlayer.parentAddress != address(0)) {
            currentPlayer.parentAddress.transfer(directComAmount);
        }
        else {
            currentPlayer.directCommission = currentPlayer.directCommission.add(directComAmount);
        }
        
    }
    
    /**
     * @dev convert bytes to address
     **/
    function bytesToAddress(bytes b) public pure returns (address) {

        uint result = 0;
        for (uint i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 16 + (c - 48);
            }
            if(c >= 65 && c<= 90) {
                result = result * 16 + (c - 55);
            }
            if(c >= 97 && c<= 122) {
                result = result * 16 + (c - 87);
            }
        }
        return address(result);
          
    }
    
    /**
     * @dev process import player information
     **/ 
    function processImportPlayer(
        address _playerAddress, 
        address _parentAddress, 
        uint256 _totalDeposited,
        uint256 _totalReceived,
        uint256 _totalCommissionReceived,
        bool _isKyc) private {
            
            //update player information
            Player storage currentPlayer = playerList[_playerAddress];
            currentPlayer.parentAddress = _parentAddress;
            currentPlayer.totalDeposited = _totalDeposited;
            currentPlayer.totalReceived = _totalReceived;
            currentPlayer.totalCommissionReceived = _totalCommissionReceived;
            currentPlayer.isKyc = _isKyc;
            
            //Logger
            emit Logger("Player imported", _totalDeposited);
            
        }
     
    /**
     * @dev process import game information
     **/ 
    function processImportGame(
        address _playerAddress, 
        uint _gameHash,
        uint256 _gameAmount,
        uint256 _gameReceived) private {
            
            //update player information
            Player storage currentPlayer = playerList[_playerAddress];
            currentPlayer.totalAmountInGame = currentPlayer.totalAmountInGame.add(_gameAmount);
            currentPlayer.totalReceived = currentPlayer.totalReceived.add(_gameReceived);
            
            //init game
            initGame(_playerAddress, _gameHash, _gameAmount, _gameReceived);
            
            //Logger
            emit Logger("Game imported", _gameAmount);
            
        }
     
    /**
     * @dev init new game
     **/ 
    function initGame(
        address _playerAddress,
        uint _gameHash,
        uint256 _gameAmount,
        uint256 _gameReceived) private {
            
            Game storage game = gameList[_gameHash];
            game.playerAddress = _playerAddress;
            game.depositAmount = _gameAmount;
            game.receiveAmount = _gameReceived;
            game.status = GameStatus.processing;
            game.nextRoundTime = now.add(supportWaitingTime);
            game.nextRoundAmount = getProfitNextRound(_gameAmount);
            
        }
    
    /**
     * @dev process check & send profit
     **/
    function processSendProfit(
        uint _gameHash,
        uint256 _profitAmount) private {
        
            Game storage game = gameList[_gameHash];
            Player storage currentPlayer = playerList[game.playerAddress];
            
            //total receive by game
            uint256 maxGameReceive = game.depositAmount.mul(cfgPercentMaxReceive).div(cfgPercentDivider);
            //total receive by player
            uint256 maxPlayerReceive = currentPlayer.totalAmountInGame.mul(cfgPercentMaxReceive).div(cfgPercentDivider);
            
            if(maxGameReceive <= game.receiveAmount || maxPlayerReceive <= currentPlayer.totalReceived) {
                emit Logger("ERR: Player cannot break game's rule [amount].", currentPlayer.totalReceived);
                game.status = GameStatus.completed;
            }
            else {
                if(maxGameReceive < game.receiveAmount.add(_profitAmount)) {
                    _profitAmount = maxGameReceive.sub(game.receiveAmount);
                }
                if(maxPlayerReceive < currentPlayer.totalReceived.add(_profitAmount)) {
                    _profitAmount = maxPlayerReceive.sub(currentPlayer.totalReceived);
                }
                
                //update game totalReceived
                game.receiveAmount = game.receiveAmount.add(_profitAmount);
                game.nextRoundTime = now.add(supportWaitingTime);
                game.nextRoundAmount = getProfitNextRound(game.depositAmount);
                
                //Logger
                emit Logger("Info: send profit", _profitAmount);
                
                //update player total received 
                currentPlayer.totalReceived = currentPlayer.totalReceived.add(_profitAmount);
                
                //send systemFeeAddress
                uint256 feeAmount = systemFeePercent.mul(_profitAmount).div(cfgPercentDivider);
                if(feeAmount > 0) {
                    _profitAmount = _profitAmount.sub(feeAmount);
                    //send fee
                    systemFeeAddress.transfer(feeAmount);
                }
                
                //send profit
                game.playerAddress.transfer(_profitAmount);
            }
            
        }
    
    /**
     * @dev get profit next round
     **/
    function getProfitNextRound(uint256 _amount) private constant returns(uint256) {
        
        uint256 support = supportPercent.mul(supportWaitingTime);
        uint256 receive = receivePercent.mul(receiveWaitingTime);
        uint256 totalPercent = support.add(receive);
        //
        return _amount.mul(totalPercent).div(cfgPercentDivider).div(86400);
        
    }
    
    /**
     * @dev get maximum amount commission avariable
     **/
    function getMaximumCommissionAmount(
        uint256 _totalDeposited,
        uint256 _totalReceived,
        uint256 _totalCommissionReceived,
        uint256 _amountCom) private returns(uint256) {
        
        //maximum commission can receive
        uint256 maxCommissionAmount = _totalDeposited.mul(maxReceiveCommissionPercent).div(cfgPercentDivider);
        //check total receive commission
        if(maxCommissionAmount <= _totalCommissionReceived) {
            emit Logger("Not enough balance [total commission receive]", _totalCommissionReceived);
            return 0;
        }
        else if(maxCommissionAmount < _totalCommissionReceived.add(_amountCom)) {
            _amountCom = maxCommissionAmount.sub(_totalCommissionReceived);
        }
        //check player total maxout
        uint256 maxProfitCanReceive = _totalDeposited.mul(cfgPercentMaxReceive).div(cfgPercentDivider);
        if(maxProfitCanReceive <= _totalReceived) {
            emit Logger("Not enough balance [total maxout receive]", _totalReceived);
            return 0;
        }
        else if(maxProfitCanReceive < _totalReceived.add(_amountCom)) {
            _amountCom = maxProfitCanReceive.sub(_totalReceived);
        }
        
        return _amountCom;
    }
}
pragma solidity ^0.5.2;




/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
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
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract EtherStake is Ownable {
 /**
 * EtherStake
 * www.etherstake.me
 * Copyright 2019
 * admin@etherpornstars.com
 */
    
  using SafeMath for uint;
  // Address set to win pot when time runs out
  address payable public  leadAddress;
    // Manage your dividends without MetaMask! Send 0.01 ETH to these directly
  address public reinvestmentContractAddress;
  address public withdrawalContractAddress;
  // Multiplies your stake purchases, starts at 110% and goes down 0.1% a day down to 100% - get in early!
  uint public stakeMultiplier;
  uint public totalStake;
  uint public day;
  uint public roundId;
  uint public roundEndTime;
  uint public startOfNewDay;
  uint public timeInADay;
  uint public timeInAWeek;
  // Optional message shown on the site when your address is leading
  mapping(address => string) public playerMessage;
  mapping(address => string) public playerName;
  // Boundaries for messages
  uint8 constant playerMessageMinLength = 1;
  uint8 constant playerMessageMaxLength = 64;
  mapping (uint => uint) internal seed; //save seed from rounds
  mapping (uint => uint) internal roundIdToDays;
  mapping (address => uint) public spentDivs;
  // Main data structure that tracks all players dividends for current and previous rounds
  mapping(uint => mapping(uint => divKeeper)) public playerDivsInADay;
  // Emitted when user withdraws dividends or wins jackpot
  event CashedOut(address _player, uint _amount);
  event InvestReceipt(
    address _player,
    uint _stakeBought);
    
    struct divKeeper {
      mapping(address => uint) playerStakeAtDay;
      uint totalStakeAtDay;
      uint revenueAtDay;
  } 

    constructor() public {
        roundId = 1;
        timeInADay = 86400; // 86400 seconds in a day
        timeInAWeek = 604800; // 604800 seconds in a week
        roundEndTime = now + timeInAWeek; // round 1 end time 604800 seconds=7 days
        startOfNewDay = now + timeInADay;
        stakeMultiplier = 1100;
        totalStake = 1000000000; 
    }



    function() external payable {
        require(msg.value >= 10000000000000000 && msg.value < 1000000000000000000000, "0.01 ETH minimum."); // Minimum stake buy is 0.01 ETH, max 1000

        if(now > roundEndTime){ // Check if round is over, then start new round. 
            startNewRound();
        }

        uint stakeBought = msg.value.mul(stakeMultiplier);
        stakeBought = stakeBought.div(1000);
        playerDivsInADay[roundId][day].playerStakeAtDay[msg.sender] += stakeBought;
        leadAddress = msg.sender;
        totalStake += stakeBought;
        addTime(stakeBought); // Add time based on amount bought
        emit InvestReceipt(msg.sender, stakeBought);
    }

    // Referrals only work with this function
    function buyStakeWithEth(address _referrer) public payable {
        require(msg.value >= 10000000000000000, "0.01 ETH minimum.");
        if(_referrer != address(0)){
                uint _referralBonus = msg.value.div(50); // 2% referral
                if(_referrer == msg.sender) {
                    _referrer = 0x93D43eeFcFbE8F9e479E172ee5d92DdDd2600E3b; // if user tries to refer himself
                }
                playerDivsInADay[roundId][day].playerStakeAtDay[_referrer] += _referralBonus;
        }
        if(now > roundEndTime){
            startNewRound();
        }

        uint stakeBought = msg.value.mul(stakeMultiplier);
        stakeBought = stakeBought.div(1000);
        playerDivsInADay[roundId][day].playerStakeAtDay[msg.sender] += stakeBought;
        leadAddress = msg.sender;
        totalStake += stakeBought;
        addTime(stakeBought);
        emit InvestReceipt(msg.sender, stakeBought);
    }
    

    // Message stored forever, but only displayed on the site when your address is leading
    function addMessage(string memory _message) public {
        bytes memory _messageBytes = bytes(_message);
        require(_messageBytes.length >= playerMessageMinLength, "Too short");
        require(_messageBytes.length <= playerMessageMaxLength, "Too long");
        playerMessage[msg.sender] = _message;
    }
    function getMessage(address _playerAddress)
    external
    view
    returns (
      string memory playerMessage_
  ) {
      playerMessage_ = playerMessage[_playerAddress];
  }
      // Name stored forever, but only displayed on the site when your address is leading
    function addName(string memory _name) public {
        bytes memory _messageBytes = bytes(_name);
        require(_messageBytes.length >= playerMessageMinLength, "Too short");
        require(_messageBytes.length <= playerMessageMaxLength, "Too long");
        playerName[msg.sender] = _name;
    }
  
    function getName(address _playerAddress)
    external
    view
    returns (
      string memory playerName_
  ) {
      playerName_ = playerName[_playerAddress];
  }
   
    
    function getPlayerCurrentRoundDivs(address _playerAddress) public view returns(uint playerTotalDivs) {
        uint _playerTotalDivs;
        uint _playerRollingStake;
        for(uint c = 0 ; c < day; c++) { //iterate through all days of current round 
            uint _playerStakeAtDay = playerDivsInADay[roundId][c].playerStakeAtDay[_playerAddress];
            if(_playerStakeAtDay == 0 && _playerRollingStake == 0){
                    continue; //if player has no stake then continue out to save gas
                }
            _playerRollingStake += _playerStakeAtDay;
            uint _revenueAtDay = playerDivsInADay[roundId][c].revenueAtDay;
            uint _totalStakeAtDay = playerDivsInADay[roundId][c].totalStakeAtDay;
            uint _playerShareAtDay = _playerRollingStake.mul(_revenueAtDay)/_totalStakeAtDay;
            _playerTotalDivs += _playerShareAtDay;
        }
        return _playerTotalDivs.div(2); // Divide by 2, 50% goes to players as dividends, 50% goes to the jackpot.
    }
    
    function getPlayerPreviousRoundDivs(address _playerAddress) public view returns(uint playerPreviousRoundDivs) {
        uint _playerPreviousRoundDivs;
        for(uint r = 1 ; r < roundId; r++) { // Iterate through all previous rounds 
            uint _playerRollingStake;
            uint _lastDay = roundIdToDays[r];
            for(uint p = 0 ; p < _lastDay; p++) { //iterate through all days of previous round 
                uint _playerStakeAtDay = playerDivsInADay[r][p].playerStakeAtDay[_playerAddress];
                if(_playerStakeAtDay == 0 && _playerRollingStake == 0){
                        continue; // If player has no stake then continue to next day to save gas
                    }
                _playerRollingStake += _playerStakeAtDay;
                uint _revenueAtDay = playerDivsInADay[r][p].revenueAtDay;
                uint _totalStakeAtDay = playerDivsInADay[r][p].totalStakeAtDay;
                uint _playerShareAtDay = _playerRollingStake.mul(_revenueAtDay)/_totalStakeAtDay;
                _playerPreviousRoundDivs += _playerShareAtDay;
            }
        }
        return _playerPreviousRoundDivs.div(2); // Divide by 2, 50% goes to players as dividends, 50% goes to the jackpot.
    }
    
    function getPlayerTotalDivs(address _playerAddress) public view returns(uint PlayerTotalDivs) {
        uint _playerTotalDivs;
        _playerTotalDivs += getPlayerPreviousRoundDivs(_playerAddress);
        _playerTotalDivs += getPlayerCurrentRoundDivs(_playerAddress);
        
        return _playerTotalDivs;
    }
    
    function getPlayerCurrentStake(address _playerAddress) public view returns(uint playerCurrentStake) {
        uint _playerRollingStake;
        for(uint c = 0 ; c <= day; c++) { //iterate through all days of current round 
            uint _playerStakeAtDay = playerDivsInADay[roundId][c].playerStakeAtDay[_playerAddress];
            if(_playerStakeAtDay == 0 && _playerRollingStake == 0){
                    continue; //if player has no stake then continue out to save gas
                }
            _playerRollingStake += _playerStakeAtDay;
        }
        return _playerRollingStake;
    }
    

    // Buy a stake using your earned dividends from past or current round
    function reinvestDivs(uint _divs) external{
        require(_divs >= 10000000000000000, "You need at least 0.01 ETH in dividends.");
        uint _senderDivs = getPlayerTotalDivs(msg.sender);
        spentDivs[msg.sender] += _divs;
        uint _spentDivs = spentDivs[msg.sender];
        uint _availableDivs = _senderDivs.sub(_spentDivs);
        require(_availableDivs >= 0);
        if(now > roundEndTime){
            startNewRound();
        }
        playerDivsInADay[roundId][day].playerStakeAtDay[msg.sender] += _divs;
        leadAddress = msg.sender;
        totalStake += _divs;
        addTime(_divs);
        emit InvestReceipt(msg.sender, _divs);
    }
    // Turn your earned dividends from past or current rounds into Ether
    function withdrawDivs(uint _divs) external{
        require(_divs >= 10000000000000000, "You need at least 0.01 ETH in dividends.");
        uint _senderDivs = getPlayerTotalDivs(msg.sender);
        spentDivs[msg.sender] += _divs;
        uint _spentDivs = spentDivs[msg.sender];
        uint _availableDivs = _senderDivs.sub(_spentDivs);
        require(_availableDivs >= 0);
        msg.sender.transfer(_divs);
        emit CashedOut(msg.sender, _divs);
    }
    // Reinvests all of a players dividends using contract, for people without MetaMask
    function reinvestDivsWithContract(address payable _reinvestor) external{ 
        require(msg.sender == reinvestmentContractAddress);
        uint _senderDivs = getPlayerTotalDivs(_reinvestor);
        uint _spentDivs = spentDivs[_reinvestor];
        uint _availableDivs = _senderDivs.sub(_spentDivs);
        spentDivs[_reinvestor] += _senderDivs;
        require(_availableDivs >= 10000000000000000, "You need at least 0.01 ETH in dividends.");
        if(now > roundEndTime){
            startNewRound();
        }
        playerDivsInADay[roundId][day].playerStakeAtDay[_reinvestor] += _availableDivs;
        leadAddress = _reinvestor;
        totalStake += _availableDivs;
        addTime(_availableDivs);
        emit InvestReceipt(msg.sender, _availableDivs);
    }
    // Withdraws all of a players dividends using contract, for people without MetaMask
    function withdrawDivsWithContract(address payable _withdrawer) external{ 
        require(msg.sender == withdrawalContractAddress);
        uint _senderDivs = getPlayerTotalDivs(_withdrawer);
        uint _spentDivs = spentDivs[_withdrawer];
        uint _availableDivs = _senderDivs.sub(_spentDivs);
        spentDivs[_withdrawer] += _availableDivs;
        require(_availableDivs >= 0);
        _withdrawer.transfer(_availableDivs);
        emit CashedOut(_withdrawer, _availableDivs);
    }
    
    // Time functions
    function addTime(uint _stakeBought) private {
        uint _timeAdd = _stakeBought/1000000000000; //1000000000000 0.01 ETH adds 2.77 hours
        if(_timeAdd < timeInADay){
            roundEndTime += _timeAdd;
        }else{
        roundEndTime += timeInADay; //24 hour cap
        }
            
        if(now > startOfNewDay) { //check if 24 hours has passed
            startNewDay();
        }
    }
    
    function startNewDay() private {
        playerDivsInADay[roundId][day].totalStakeAtDay = totalStake;
        playerDivsInADay[roundId][day].revenueAtDay = totalStake - playerDivsInADay[roundId][day-1].totalStakeAtDay; //div revenue today = pot today - pot yesterday
        if(stakeMultiplier > 1000) {
            stakeMultiplier -= 1;
        }
        startOfNewDay = now + timeInADay;
        ++day;
    }

    function startNewRound() private { 
        playerDivsInADay[roundId][day].totalStakeAtDay = totalStake; //commit last changes to ending round
        playerDivsInADay[roundId][day].revenueAtDay = totalStake - playerDivsInADay[roundId][day-1].totalStakeAtDay; //div revenue today = pot today - pot yesterday
        roundIdToDays[roundId] = day; //save last day of ending round
        jackpot();
        resetRound();
    }
    function jackpot() private {
        uint winnerShare = playerDivsInADay[roundId][day].totalStakeAtDay.div(2) + seed[roundId]; //add last seed to pot
        seed[roundId+1] = totalStake.div(10); //10% of pot to seed next round
        winnerShare -= seed[roundId+1];
        leadAddress.transfer(winnerShare);
        emit CashedOut(leadAddress, winnerShare);
    }
    function resetRound() private {
        roundId += 1;
        roundEndTime = now + timeInAWeek;  //add 1 week time to start next round
        startOfNewDay = now; // save day start time, multiplier decreases 0.1%/day
        day = 0;
        stakeMultiplier = 1100;
        totalStake = 10000000;
    }

    function returnTimeLeft()
     public view
     returns(uint256) {
     return(roundEndTime.sub(now));
     }
     
    function returnDayTimeLeft()
     public view
     returns(uint256) {
     return(startOfNewDay.sub(now));
     }
     
    function returnSeedAtRound(uint _roundId)
     public view
     returns(uint256) {
     return(seed[_roundId]);
     }
    function returnjackpot()
     public view 
     returns(uint256){
        uint winnerShare = totalStake/2 + seed[roundId]; //add last seed to pot
        uint nextseed = totalStake/10; //10% of pot to seed next round
        winnerShare -= nextseed;
        return winnerShare;
    }
    function returnEarningsAtDay(uint256 _roundId, uint256 _day, address _playerAddress)
     public view 
     returns(uint256){
        uint earnings = playerDivsInADay[_roundId][_day].playerStakeAtDay[_playerAddress];
        return earnings;
    }
      function setWithdrawalAndReinvestmentContracts(address _withdrawalContractAddress, address _reinvestmentContractAddress) external onlyOwner {
    withdrawalContractAddress = _withdrawalContractAddress;
    reinvestmentContractAddress = _reinvestmentContractAddress;
  }
}

contract WithdrawalContract {
    
    address payable public etherStakeAddress;
    address payable public owner;
    
    
    constructor(address payable _etherStakeAddress) public {
        etherStakeAddress = _etherStakeAddress;
        owner = msg.sender;
    }
    
    function() external payable{
        require(msg.value >= 10000000000000000, "0.01 ETH Fee");
        EtherStake instanceEtherStake = EtherStake(etherStakeAddress);
        instanceEtherStake.withdrawDivsWithContract(msg.sender);
    }
    
    function collectFees() external {
        owner.transfer(address(this).balance);
    }
}
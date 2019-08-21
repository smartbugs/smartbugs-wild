pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
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
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

     /**
     * @dev x to the power of y 
     */
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else{
            uint256 z = x;
            for (uint256 i = 1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}


interface shareProfit {
    function increaseProfit() external payable returns(bool);
}

contract RobTheBank{
    using SafeMath for uint256;
    
    uint256 public constant BASE_PRICE = 0.003 ether;
    address public owner;
    address public service;
    struct Big {
        uint256 totalKey;
        uint256 jackpotBalance;
        uint256 KeyProfit;
        mapping (address=>uint256) received;
        address winner;
        uint256 winnerProfit;
    }
    struct Small {
        uint256 totalKey;
        address winner;
        uint256 startTime;
        uint256 endTime;
        uint256 winKey;
        uint256 winnerProfit;
    }
    struct KeyPurchases {
        KeyPurchase[] keysBought;
        uint256 numPurchases;
    }
    struct KeyPurchase {
        uint256 startId;
        uint256 endId;
    }
    mapping (uint256=>Big) public bigRound;
    mapping (uint256=>mapping (uint256=>Small)) public smallRound;
    shareProfit public RTB1;
    shareProfit public RTB2;
    mapping (uint256=>mapping (uint256=>mapping (address=>uint256))) public userSmallRoundkey;
    mapping (uint256=>mapping (address=>uint256)) public userBigRoundKey;
    mapping (uint256=>mapping (uint256=>mapping (address=>KeyPurchases))) public userXkeyPurchases;
    uint256 keysBought;
    mapping (address=>uint256) public recommender;
    mapping (address=>bool) public recommenderAllow;
    uint256 public allowPrice;
    uint256 devFee;
    uint256 public smallId;
    uint256 public bigId;
    bool public isPaused = false;
    
    event buyEvent(address indexed _buyer, uint256 _amount, uint256 _total, uint256 _bigRound, uint256 _smallRound, uint256 _startId, uint256 _endId, uint256 _index);
    event lotteryEvent(address indexed _winner, uint256 _bigRound, uint256 _smallRound, uint256 _money, uint256 _type);
    event withdrawEvent(address indexed _winner, uint256 _amount, uint256 _round);
    event RecommenderAllow(address indexed _user, bool _status);
    event createKey(uint256 _winkey, uint256 _bigRound, uint256 _smallRound);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier onlyService() {
        require(msg.sender == service, "only service");
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "is Paused");
        _;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    constructor (address _rtb1, address _rtb2) public {
        owner = msg.sender;
        service = msg.sender;
        bigId = 1;
        smallId = 1;
        allowPrice = 0.01 ether;
        RTB1 = shareProfit(_rtb1);
        RTB2 = shareProfit(_rtb2);
    }

    function() external payable{
        require(msg.value > 0);
        bigRound[bigId].jackpotBalance = bigRound[bigId].jackpotBalance.add(msg.value);
    }
    
    ///@dev Start new game
    function startGame() public onlyOwner{
        uint256 time = block.timestamp;
        smallRound[bigId][smallId].startTime = time;
        smallRound[bigId][smallId].endTime = time + 41400;
    }
    
    ///@dev Buy key
    function buy(uint256 _amount, address _invite) public isHuman whenNotPaused payable{
        require(smallRound[bigId][smallId].startTime < block.timestamp, "The game has not started yet");
        require(smallRound[bigId][smallId].endTime > block.timestamp, "The game is over");
        uint256 _money = _amount.mul(getPrice());
        require(_amount > 0 && _money > 0);
        require(_money == msg.value, "The amount is incorrect");

        if (_invite != address(0) && _invite != msg.sender && recommenderAllow[_invite] == true){
            recommender[_invite] = _money.mul(10).div(100).add(recommender[_invite]);
            _money = _money.mul(90).div(100);
        }

        _buy(_amount, _money);
    }
    
    ///@dev Use vault
    function buyAgain(uint256 _amount) public isHuman whenNotPaused {
        require(smallRound[bigId][smallId].startTime < block.timestamp, "The game has not started yet");
        require(smallRound[bigId][smallId].endTime > block.timestamp, "The game is over");
        uint256 _money = _amount.mul(getPrice());
        uint256 profit = getMyProfit(bigId);
        require(_amount > 0 && _money > 0);
        require(profit >= _money);
        bigRound[bigId].received[msg.sender] = _money.add(bigRound[bigId].received[msg.sender]);
        _buy(_amount, _money);
    }
    
    function _buy(uint256 _amount, uint256 _money) internal whenNotPaused{
        //Number of record keys
        userBigRoundKey[bigId][msg.sender] = userBigRoundKey[bigId][msg.sender].add(_amount);
        userSmallRoundkey[bigId][smallId][msg.sender] = userSmallRoundkey[bigId][smallId][msg.sender].add(_amount);
        
        //Record player's key
        KeyPurchases storage purchases = userXkeyPurchases[bigId][smallId][msg.sender];
        if (purchases.numPurchases == purchases.keysBought.length) {
            purchases.keysBought.length += 1;
        }
        purchases.keysBought[purchases.numPurchases] = KeyPurchase(keysBought, keysBought + (_amount - 1)); // (eg: buy 10, get id's 0-9)
        purchases.numPurchases++;
        emit buyEvent(msg.sender, _amount, msg.value, bigId, smallId, keysBought, keysBought + (_amount - 1), purchases.numPurchases);
        keysBought = keysBought.add(_amount);

        //40% for all players
        uint256 _playerFee = _money.mul(40).div(100);
        if(bigRound[bigId].totalKey > 0){
            bigRound[bigId].KeyProfit = _playerFee.div(bigRound[bigId].totalKey).add(bigRound[bigId].KeyProfit);
            bigRound[bigId].received[msg.sender] = bigRound[bigId].KeyProfit.mul(_amount).add(bigRound[bigId].received[msg.sender]);
        }else{
            devFee = devFee.add(_playerFee);
        }

        //35% for jackpot
        bigRound[bigId].jackpotBalance = _money.mul(35).div(100).add(bigRound[bigId].jackpotBalance);
        
        //15% for RTB1 and RTB2
        uint256 _shareFee = _money.mul(15).div(100);
        RTB1.increaseProfit.value(_shareFee.mul(3).div(10))(); // 300/1000 = 30%
        RTB2.increaseProfit.value(_shareFee.mul(7).div(10))(); // 700/1000 = 70%
        
        //10% for winner
        smallRound[bigId][smallId].winnerProfit = _money.mul(10).div(100).add(smallRound[bigId][smallId].winnerProfit);

        bigRound[bigId].totalKey = bigRound[bigId].totalKey.add(_amount);
        smallRound[bigId][smallId].totalKey = smallRound[bigId][smallId].totalKey.add(_amount);
    }
    
    ///@dev Create a winner
    function createWinner() public onlyService whenNotPaused{
        require(smallRound[bigId][smallId].endTime < block.timestamp);
        require(smallRound[bigId][smallId].winKey == 0);
        uint256 seed = _random();
        smallRound[bigId][smallId].winKey = addmod(uint256(blockhash(block.number-1)), seed, smallRound[bigId][smallId].totalKey);
        emit createKey(smallRound[bigId][smallId].winKey, bigId, smallId);
    }

    ///@dev Lottery
    function lottery(address _winner, uint256 _checkIndex) external onlyService whenNotPaused{
        require(_winner != address(0));
        require(address(this).balance > smallRound[bigId][smallId].winnerProfit);
        
        KeyPurchases storage keys = userXkeyPurchases[bigId][smallId][_winner];
        if(keys.numPurchases > 0 && _checkIndex < keys.numPurchases){
            KeyPurchase storage checkKeys = keys.keysBought[_checkIndex];
            if(smallRound[bigId][smallId].winKey >= checkKeys.startId && smallRound[bigId][smallId].winKey <= checkKeys.endId){
                smallRound[bigId][smallId].winner = _winner;
                _winner.transfer(smallRound[bigId][smallId].winnerProfit);
                emit lotteryEvent(_winner, bigId, smallId, smallRound[bigId][smallId].winnerProfit, 1);
                
                _bigLottery(_winner);
            }
        }
    }
    
    function _bigLottery(address _winner) internal whenNotPaused{
        uint256 seed = _random();
        uint256 mod;
        if(smallId < 50){
            mod = (51 - smallId) * 3 - 4;
        }else{
            mod = 1;
        }
        uint256 number =  addmod(uint256(blockhash(block.number-1)), seed, mod);
        if(number == 0){
            //Congratulations, win the grand prize
            require(address(this).balance >= bigRound[bigId].jackpotBalance);

            //10% for all player
            uint256 _playerFee = bigRound[bigId].jackpotBalance.mul(10).div(100);
            bigRound[bigId].KeyProfit = _playerFee.div(bigRound[bigId].totalKey).add(bigRound[bigId].KeyProfit);
            
            //10% for next jackpot
            uint256 _jackpotFee = bigRound[bigId].jackpotBalance.mul(10).div(100);
            
            //10% for RTB1 and RTB2
            uint256 _shareFee =  bigRound[bigId].jackpotBalance.mul(10).div(100);
            RTB1.increaseProfit.value(_shareFee.mul(3).div(10))(); // 300/1000 = 30%
            RTB2.increaseProfit.value(_shareFee.mul(7).div(10))(); // 700/1000 = 70%
            
            //8% for dev
            devFee = bigRound[bigId].jackpotBalance.mul(8).div(100).add(devFee);
            
            //62% for winner
            uint256 _winnerProfit = bigRound[bigId].jackpotBalance.mul(62).div(100);
            _winner.transfer(_winnerProfit);
            emit lotteryEvent(_winner, bigId, smallId, _winnerProfit, 2);
            bigRound[bigId].winnerProfit = _winnerProfit;
            
            //Start a new round
            bigId++;
            smallId = 1;
            bigRound[bigId].jackpotBalance = _jackpotFee;
        }else{
            //You didn't win the grand prize
            //Start new round
            smallId++;
        }
        keysBought = 0;
    }

    function withdraw(uint256 _round) public whenNotPaused{
        uint profit = getMyProfit(_round);
        uint256 money = recommender[msg.sender].add(profit);
        require(money > 0);
        recommender[msg.sender] = 0;
        bigRound[_round].received[msg.sender] = bigRound[_round].received[msg.sender].add(profit);
        msg.sender.transfer(money);
        emit withdrawEvent(msg.sender, money, _round);
    }
    
    function devWithdraw() public onlyOwner{
        owner.transfer(devFee);
        emit withdrawEvent(owner, devFee, 0);
        devFee = 0;
    }
    
    function getMyProfit(uint256 _round) public view returns(uint256){
        return bigRound[_round].KeyProfit.mul(userBigRoundKey[_round][msg.sender]).sub(bigRound[_round].received[msg.sender]);
    }

    function getPrice() public view returns(uint256) {
        require(smallId >= 1 && smallId <= 50);
        uint256 _round = smallId.sub(1);
        return _round.mul(_round).mul(1200000000000000).div(25).add(BASE_PRICE);
    }

     //random
    function _random() internal view returns(uint256){
        uint256 seed = uint256(keccak256( (
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
        )));

        return seed;
    }
    
    function setAllowPrice(uint256 _price) public onlyOwner{
        allowPrice = _price;
    }
    
    function setRecommenderAllow() public payable{
        require(msg.value == allowPrice);
        require(recommenderAllow[msg.sender] == false);
        devFee = devFee.add(msg.value);
        emit RecommenderAllow(msg.sender, true);
        recommenderAllow[msg.sender] = true;
    }
    
    function setGame(bool _bool) public onlyOwner{
        isPaused = _bool;
    }

    function setService(address _addr) public onlyOwner{
        service = _addr;
    }
}
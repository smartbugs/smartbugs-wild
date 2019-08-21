pragma solidity ^0.4.23;

library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

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

contract FiftyFifty{
    using SafeMath for uint; // using SafeMath
    //rate to 0.125 ETH.  0.125:1, 0.250:2, 0.500:4, 1.00:8, 2.00:16, 4.00:32, 8.00: 64, 16.00:128, 32.00:256, 64.00:512
    uint[11] betValues = [0.125 ether, 0.250 ether, 0.500 ether, 1.00 ether, 2.00 ether, 4.00 ether, 8.00 ether, 16.00 ether, 32.00 ether, 64.00 ether];
    // return value is 95 % of two people.
    uint[11] returnValues = [0.2375 ether, 0.475 ether, 0.950 ether, 1.90 ether, 3.80 ether, 7.60 ether, 15.20 ether, 30.40 ether, 60.80 ether, 121.60 ether];
    // jackpot value is 4 % of total value
    uint[11] jackpotValues = [0.05 ether, 0.010 ether, 0.020 ether, 0.04 ether, 0.08 ether, 0.16 ether, 0.32 ether, 0.64 ether, 1.28 ether, 2.56 ether];
    // fee 1 %
    uint[11] fees = [0.0025 ether, 0.005 ether, 0.010 ether, 0.020 ether, 0.040 ether, 0.080 ether, 0.16 ether, 0.32 ether, 0.64 ether, 1.28 ether];
    uint roundNumber; // number of round that jackpot is paid
    mapping(uint => uint) jackpot;
    //round -> betValue -> user address
    mapping(uint => mapping(uint => address[])) roundToBetValueToUsers;
    //round -> betValue -> totalBet
    mapping(uint => mapping(uint => uint)) roundToBetValueToTotalBet;
    //round -> totalBet
    mapping(uint => uint) public roundToTotalBet;
    // current user who bet for the value
    mapping(uint => address) currentUser;
    address owner;
    uint ownerDeposit;

    // Event
    event Jackpot(address indexed _user, uint _value, uint indexed _round, uint _now);
    event Bet(address indexed _winner,address indexed _user,uint _bet, uint _payBack, uint _now);


    constructor() public {
        owner = msg.sender;
        roundNumber = 1;
    }

    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _owner) external onlyOwner{
        owner = _owner;
    }

    // fallback function that

    function() public payable {
        // check if msg.value is equal to specified amount of value.
        uint valueNumber = checkValue(msg.value);
        /**
            jackpot starts when block hash % 10000 < 0
        */
        uint randJackpot = (uint(blockhash(block.number - 1)) + roundNumber) % 10000;
        if(jackpot[roundNumber] != 0 && randJackpot <= 1){
            // Random number that is under contract total bet amount
            uint randJackpotBetValue = uint(blockhash(block.number - 1)) % roundToTotalBet[roundNumber];
            //betNum
            uint betNum=0;
            uint addBetValue = 0;
            // Loop until addBetValue exceeds randJackpotBetValue
            while(randJackpotBetValue > addBetValue){
                // Select bet number which is equal to
                addBetValue += roundToBetValueToTotalBet[roundNumber][betNum];
                betNum++;
            }
            //  betNum.sub(1)のindexに含まれているuserの数未満のランダム番号を生成する
            uint randJackpotUser = uint(blockhash(block.number - 1)) % roundToBetValueToUsers[roundNumber][betNum.sub(1)].length;
            address user = roundToBetValueToUsers[roundNumber][valueNumber][randJackpotUser];
            uint jp = jackpot[roundNumber];
            user.transfer(jp);
            emit Jackpot(user, jp, roundNumber, now);
            roundNumber = roundNumber.add(1);
        }
        if(currentUser[valueNumber] == address(0)){
            //when current user does not exists
            currentUser[valueNumber] = msg.sender;
            emit Bet(address(0), msg.sender, betValues[valueNumber], 0, now);
        }else{
            // when current user exists
            uint rand = uint(blockhash(block.number-1)) % 2;
            ownerDeposit = ownerDeposit.add(fees[valueNumber]);
            if(rand == 0){
                // When the first user win
                currentUser[valueNumber].transfer(returnValues[valueNumber]);
                emit Bet(currentUser[valueNumber], msg.sender, betValues[valueNumber], returnValues[valueNumber], now);
            }else{
                // When the last user win
                msg.sender.transfer(returnValues[valueNumber]);
                emit Bet(msg.sender, msg.sender, betValues[valueNumber], returnValues[valueNumber], now);
            }
            // delete current user
            delete currentUser[valueNumber];
        }
        // common in each contracts
        jackpot[roundNumber] = jackpot[roundNumber].add(jackpotValues[valueNumber]);
        roundToBetValueToUsers[roundNumber][valueNumber].push(currentUser[valueNumber]);
        roundToTotalBet[roundNumber] = roundToTotalBet[roundNumber].add(betValues[valueNumber]);
        roundToBetValueToTotalBet[roundNumber][valueNumber] = roundToBetValueToTotalBet[roundNumber][valueNumber].add(betValues[valueNumber]);
    }

    /**
        @param sendValue is ETH that is sent to this contract.
        @return num is index that represent value that is sent.
    */
    function checkValue(uint sendValue) internal view returns(uint) {
        /**
            Check sendValue is match prepared values. Revert if sendValue doesn't match any values.
        */
        uint num = 0;
        while (sendValue != betValues[num]){
            if(num == 11){
                revert();
            }
            num++;
        }
        return num;
    }

    function roundToBetValueToUsersLength(uint _roundNum, uint _betNum) public view returns(uint){
        return roundToBetValueToUsers[_roundNum][_betNum].length;
    }

    function withdrawDeposit() public onlyOwner{
        owner.transfer(ownerDeposit);
        ownerDeposit = 0;
    }

    function currentJackpot() public view  returns(uint){
        return jackpot[roundNumber];
    }

}
pragma solidity ^0.4.25;

/*
    @KAKUTAN-team
    https://myethergames.fun
    26.12.2018
*/

contract Ownable {
    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract BlackAndWhite is Ownable {

    using SafeMath for uint256;

    uint8 constant BLACK = 0;
    uint8 constant WHITE = 1;
    uint constant TEAM_PERCENT = 2;
    uint constant BET_EXPIRATION_BLOCKS = 250;
    uint public betAmount = 50000000000000000;
    uint public minAmount = 100000000000000000;
    uint public lockedInBets;
    uint public teamBalance;

    uint betId;

    struct Bet {
        uint amount;
        uint8 option;
        uint40 placeBlockNumber;
        address gambler;
    }

    mapping (uint => Bet) bets;

    address public botAddress;

    modifier onlyBot {
        require (msg.sender == botAddress);
        _;
    }

    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);

    event Commit(address gambler, uint commit, uint8 option);
    event Reveal(uint betId, uint reveal, uint seed, uint amount, address gambler, uint8 betOption);

    event NewPrice(uint newPrice);


    constructor() public {
        botAddress = 0x3be76eeFF089AF790dd8Cbf3b921e430a962214d;
        betId = 0;
    }

    function setBotAddress(address newAddress) external onlyOwner {
        botAddress = newAddress;
    }

    function() external payable {

    }

    function placeBet(uint8 option) public payable {
        require(option == BLACK || option == WHITE);
        Bet storage bet = bets[betId];
        require (bet.gambler == address(0));
        betId = betId.add(1);
        uint amount = msg.value;
        require(amount == betAmount);

        uint possibleWinAmount;

        possibleWinAmount = getWinAmount(amount);

        lockedInBets = lockedInBets.add(possibleWinAmount);

        require (lockedInBets <= address(this).balance);

        emit Commit(msg.sender, betId.sub(1), option);

        bet.amount = amount;
        bet.option = option;
        bet.placeBlockNumber = uint40(block.number);
        bet.gambler = msg.sender;
    }

    function settleBet(uint _betId, uint data) external onlyBot {
        require(data != 0);
        Bet storage bet = bets[_betId];
        uint placeBlockNumber = bet.placeBlockNumber;

        require (block.number > placeBlockNumber);
        require (block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS);
        uint amount = bet.amount;
        address gambler = bet.gambler;

        require (amount != 0, "Bet should be in an 'active' state");

        bet.amount = 0;

        uint possibleWinAmount = getWinAmount(amount);
        uint winAmount = 0;
        uint seed = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        uint random = data.add(seed);

        if(bet.option == BLACK) {
            winAmount = random % 2 == BLACK ? possibleWinAmount : 0;
        }

        if(bet.option == WHITE) {
            winAmount = random % 2 == WHITE ? possibleWinAmount : 0;
        }

        if(winAmount > 0) {
            require(address(this).balance >= minAmount + winAmount + teamBalance );
        }

        teamBalance = teamBalance.add(beneficiaryPercent(amount));
        lockedInBets -= possibleWinAmount;

        sendFunds(gambler, winAmount);

        emit Reveal(_betId, data, seed, winAmount, gambler, bet.option);
    }

    function refundBet(uint _betId) external {
        Bet storage bet = bets[_betId];
        uint amount = bet.amount;

        require (amount != 0);

        require (block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS);

        bet.amount = 0;

        uint winAmount;
        winAmount = getWinAmount(amount);

        lockedInBets -= uint128(winAmount);

        sendFunds(bet.gambler, amount);
    }

    function getWinAmount(uint amount) private pure returns (uint winAmount) {
        uint team = beneficiaryPercent(amount);

        winAmount = (amount * 2) - team;
    }

    function beneficiaryPercent(uint amount) private pure returns(uint) {
        uint team = amount * TEAM_PERCENT / 100;
        require(team <= amount);
        return team;
    }

    function sendFunds(address _beneficiary, uint amount) private {
        if (_beneficiary.send(amount)) {
            emit Payment(_beneficiary, amount);
        } else {
            emit FailedPayment(_beneficiary, amount);
        }
    }

    function withdrawFunds(address _beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount <= address(this).balance);
        require (lockedInBets + withdrawAmount <= address(this).balance);
        sendFunds(_beneficiary, withdrawAmount);
    }

    function setPrice(uint newPrice) public onlyOwner {
        betAmount = newPrice;
        emit NewPrice(newPrice);
    }

    function setMinAmount(uint amount) public onlyOwner{
        minAmount = amount;
    }

    function canRefund(uint _betId) public constant returns(bool) {
        Bet storage bet = bets[_betId];
        if(block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS && bet.placeBlockNumber > 0 && bet.amount > 0) {
            return true;
        } else {
            return false;
        }
    }

}
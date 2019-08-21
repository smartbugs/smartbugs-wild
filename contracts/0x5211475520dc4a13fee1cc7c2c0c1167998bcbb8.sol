pragma solidity ^0.4.11;

library SafeMath
{
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function GET_MAX_UINT256() pure internal returns(uint256){
        return MAX_UINT256;
    }

    function mul(uint a, uint b) internal returns(uint){
        uint c = a * b;
        assertSafe(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) pure internal returns(uint){
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal returns(uint){
        assertSafe(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal returns(uint){
        uint c = a + b;
        assertSafe(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal view returns(uint64){
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal view returns(uint64){
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal view returns(uint256){
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal view returns(uint256){
        return a < b ? a : b;
    }

    function assertSafe(bool assertion) internal {
        if (!assertion) {
            revert();
        }
    }
}

contract Auctioneer {
    function createAuctionContract() payable public returns(address) {
        AuctionContract auctionContract = (new AuctionContract).value(msg.value)(3000, this);//TODO CHANGE 30 -->> 3000

        return auctionContract;
    }
}

contract AuctionContract {
    using SafeMath for uint;

    event BetPlacedEvent(address bidderAddress, uint amount);
    event RefundEvent(address bidderAddress, uint amount);
    event CreateAuctionContractEvent(address bidderAddress, uint amount);

    uint public auctionSlideSize = 30;
    uint public auctionCloseBlock;
    uint public closeAuctionAfterNBlocks;
    uint public bettingStep;
    mapping (address => uint) public bettingMap;
    address public firstBidder;
    address public secondBidder;
    address public winner;
    uint public biggestBet;
    uint public prize;
    address public firstBetContract;
    address public secondBetContract;
    uint public minimalPrize = 10000000000000000;//0.01 ETH
    uint public minimaBetStep = 10000000000000000;//0.01 ETH
    address public auctioneerAddress;
    bool public isActive;

    constructor (uint _closeAuctionAfterNBlocks, address _auctioneerAddress) payable public{
        assert(msg.value >= minimalPrize);
        prize = msg.value;
        auctioneerAddress = _auctioneerAddress;
        closeAuctionAfterNBlocks = _closeAuctionAfterNBlocks;
        auctionCloseBlock = block.number.add(_closeAuctionAfterNBlocks);
        bettingStep = 0;
        biggestBet = 0;
        isActive = true;

        emit CreateAuctionContractEvent(this, prize);
    }

    function() public payable {
        assert(auctionCloseBlock >= block.number);
        uint value = bettingMap[msg.sender];
        value = value.add(msg.value);
        assert(msg.value >= minimaBetStep);
        assert(biggestBet < value);

        bettingMap[msg.sender] = value;
        biggestBet = value;

        if (msg.sender != firstBidder) {
            secondBidder = firstBidder;
        }
        
        firstBidder = msg.sender;

        bettingStep = bettingStep.add(1);
        auctionCloseBlock = auctionCloseBlock.add(auctionSlideSize);
        winner = msg.sender;

        emit BetPlacedEvent(msg.sender, msg.value);
    }

    function askForRefund() public {
        assert(firstBidder != msg.sender);
        assert(secondBidder != msg.sender);
        uint value = bettingMap[msg.sender];
        assert(value != 0);

        msg.sender.transfer(value);
        bettingMap[msg.sender] = 0;

        emit RefundEvent(msg.sender, value);
    }

    function closeAuction() public {
        assert(isActive);
        assert(auctionCloseBlock < block.number);
        assert(msg.sender == winner);
        msg.sender.transfer(prize);
        Auctioneer auctioneer = Auctioneer(auctioneerAddress);

        if(firstBidder != address(0)) {
            uint firstValue = bettingMap[firstBidder];
            if (firstValue >= minimalPrize) {
                address firstContract = auctioneer.createAuctionContract.value(firstValue)();
                firstBetContract = firstContract;
            }
        }

        if(secondBidder != address(0)) {
            uint secondValue = bettingMap[secondBidder];
            if (secondValue >= minimalPrize) {
                address secondContract = auctioneer.createAuctionContract.value(secondValue)();
                secondBetContract = secondContract;
            }
        }
        
        isActive = false;
    }
}
// loosely based on Bryn Bellomy code
// https://medium.com/@bryn.bellomy/solidity-tutorial-building-a-simple-auction-contract-fcc918b0878a
//
// updated to 0.4.25 standard, replaced blocks with time, converted to hot potato style by Chibi Fighters
// you are free to use the code but please give Chibi Fighters credits
// https://chibifighters.io
//

pragma solidity ^0.4.25;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, returns 0 if it would go into minus range.
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b >= a) {
            return 0;
        }
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract AuctionPotato {
    using SafeMath for uint256; 
    // static
    address public owner;
    uint public startTime;
    uint public endTime;
    string name;
    
    // pototo
    uint public potato;
    uint oldPotato;
    uint oldHighestBindingBid;
    
    // state
    bool public canceled;
    
    uint public highestBindingBid;
    address public highestBidder;
    
    // used to immidiately block placeBids
    bool blockerPay;
    bool blockerWithdraw;
    
    mapping(address => uint256) public fundsByBidder;
    bool ownerHasWithdrawn;

    event LogBid(address bidder, address highestBidder, uint oldHighestBindingBid, uint highestBindingBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);
    event LogCanceled();
    
    
    // initial settings on contract creation
    constructor() public {
        
        blockerWithdraw = false;
        blockerPay = false;
        
        owner = msg.sender;

        // 0.003 ETH
        highestBindingBid = 3000000000000000;
        potato = 0;
        
        // 2018-10-31 18:00:00
        startTime = 1541008800;
        endTime = startTime + 3 hours;

        name = "Frankie";

    }
    
    function setStartTime(uint _time) onlyOwner public 
    {
        require(now < startTime);
        startTime = _time;
        endTime = startTime + 3 hours;
    }


    // calculates the next bid amount to you can have a oneclick buy button
    function nextBid() public view returns (uint _nextBid) {
        return highestBindingBid.add(potato);
    }
    
    
    // calculates the bid after the current bid so nifty hackers can skip the queue
    // this is not in our frontend and no one knows if it actually works
    function nextNextBid() public view returns (uint _nextBid) {
        return highestBindingBid.add(potato).add((highestBindingBid.add(potato)).mul(4).div(9));
    }
    
    
    function queryAuction() public view returns (string, uint, address, uint, uint, uint)
    {
        
        return (name, nextBid(), highestBidder, highestBindingBid, startTime, endTime);
        
    }


    function placeBid() public
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyNotCanceled
        onlyNotOwner
        returns (bool success)
    {   
        // we are only allowing to increase in bidIncrements to make for true hot potato style
        require(msg.value == highestBindingBid.add(potato));
        require(msg.sender != highestBidder);
        require(now > startTime);
        require(blockerPay == false);
        blockerPay = true;
        
        // calculate the user's total bid based on the current amount they've sent to the contract
        // plus whatever has been sent with this transaction

        fundsByBidder[msg.sender] = fundsByBidder[msg.sender].add(highestBindingBid);
        fundsByBidder[highestBidder] = fundsByBidder[highestBidder].add(potato);

        highestBidder.transfer(fundsByBidder[highestBidder]);
        fundsByBidder[highestBidder] = 0;
        
        oldHighestBindingBid = highestBindingBid;
        
        // set new highest bidder
        highestBidder = msg.sender;
        highestBindingBid = highestBindingBid.add(potato);

        oldPotato = potato;
        potato = highestBindingBid.mul(4).div(9);
        
        emit LogBid(msg.sender, highestBidder, oldHighestBindingBid, highestBindingBid);
        blockerPay = false;
        return true;
    }

    function cancelAuction() public
        onlyOwner
        onlyBeforeEnd
        onlyNotCanceled
        returns (bool success)
    {
        canceled = true;
        emit LogCanceled();
        return true;
    }

    function withdraw() public onlyOwner returns (bool success) 
    {
        require(now > endTime);
        
        msg.sender.transfer(address(this).balance);
        
        return true;
    }
    
    
    function balance() public view returns (uint _balance) {
        return address(this).balance;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyNotOwner {
        require(msg.sender != owner);
        _;
    }

    modifier onlyAfterStart {
        if (now < startTime) revert();
        _;
    }

    modifier onlyBeforeEnd {
        if (now > endTime) revert();
        _;
    }

    modifier onlyNotCanceled {
        if (canceled) revert();
        _;
    }
    
}
pragma solidity 0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface token {
    function transfer(address receiver, uint amount) public;
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


/*
 * Haltable
 *
 * Abstract contract that allows children to implement an
 * emergency stop mechanism. Differs from Pausable by causing a throw when in halt mode.
 *
 *
 * Originally envisioned in FirstBlood ICO contract.
 */
contract Haltable is Ownable {
    bool public halted;

    modifier stopInEmergency {
        if (halted) revert();
        _;
    }

    modifier onlyInEmergency {
        if (!halted) revert();
        _;
    }

    // called by the owner on emergency, triggers stopped state
    function halt() external onlyOwner {
        halted = true;
    }

    // called by the owner on end of emergency, returns to normal state
    function unhalt() external onlyOwner onlyInEmergency {
        halted = false;
    }

}

////////////////////////////////////////////////////////////////////////////////////////

contract Crowdsale  is Haltable {
    using SafeMath for uint256;
    event FundTransfer(address backer, uint amount, bool isContribution);
    // Crowdsale end time has been changed
    event EndsAtChanged(uint deadline);
    event CSClosed(bool crowdsaleClosed);

    address public beneficiary;
    uint public amountRaised;
    uint public amountAvailable;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public crowdsaleClosed = false;

    uint public numTokensLeft;
    uint public numTokensSold;
    /* the UNIX timestamp end date of the crowdsale */
    //    uint public newDeadline;

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale(
        address ifSuccessfulSendTo,
        address addressOfTokenUsedAsReward,
        uint unixTimestampEnd,
        uint initialTokenSupply
    ) public {
        owner = msg.sender;

        if(unixTimestampEnd == 0) {
            revert();
        }
        uint dec = 1000000000;
        numTokensLeft = initialTokenSupply.mul(dec);
        deadline = unixTimestampEnd;

        // Don't mess the dates
        if(now >= deadline) {
            revert();
        }

        beneficiary = ifSuccessfulSendTo;
        price = 0.000000000000166666 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () public stopInEmergency payable {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        uint leastAmount = 600000000000;
        uint numTokens = amount.div(price);

        uint stageOne = 1520856000;// 03/12/2018 @ 12:00pm (UTC) -- 40% bonus before
        uint stageTwo = 1521460800;// 03/19/2018 @ 12:00pm (UTC) -- 20% bonus before
        uint stageThree = 1522065600;// 03/26/2018 @ 12:00pm (UTC) -- 15%  bonus before
        uint stageFour = 1522670400;// 04/02/2018 @ 12:00pm (UTC) -- 10%  bonus before
        // end date -- 1523275199 @ 04/09/2018 @ 11:59am (UTC)  -- 0%   bonus before

        uint numBonusTokens;
        uint totalNumTokens;

        /////////////////////////////
        //  Next step is to add in a check to see once the new price goes live
        ////////////////////////////
        if(now < stageOne)
        {
            //  40% Presale bonus
            numBonusTokens = (numTokens.div(100)).mul(40);
            totalNumTokens = numTokens.add(numBonusTokens);
        }
        else if(now < stageTwo)
        {
            //  20% bonus
            numBonusTokens = (numTokens.div(100)).mul(20);
            totalNumTokens = numTokens.add(numBonusTokens);
        }
        else if(now < stageThree){
            //  15% bonus
            numBonusTokens = (numTokens.div(100)).mul(15);
            totalNumTokens = numTokens.add(numBonusTokens);
        }
        else if(now < stageFour){
            //  10% bonus
            numBonusTokens = (numTokens.div(100)).mul(10);
            totalNumTokens = numTokens.add(numBonusTokens);
        }
        else{
            numBonusTokens = 0;
            totalNumTokens = numTokens.add(numBonusTokens);
        }

        // do not sell less than 100 tokens at a time.
        if (numTokens <= leastAmount) {
            revert();
        } else {
            balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            amountAvailable = amountAvailable.add(amount);
            numTokensSold = numTokensSold.add(totalNumTokens);
            numTokensLeft = numTokensLeft.sub(totalNumTokens);
            tokenReward.transfer(msg.sender, totalNumTokens);
            FundTransfer(msg.sender, amount, true);
        }
    }

    ///////////////////////////////////////////////////////////
    //     * Withdraw received funds
    ///////////////////////////////////////////////////////////
    function safeWithdrawal() public onlyOwner{
        if(amountAvailable < 0)
        {
            revert();
        }
        else
        {
            uint amtA = amountAvailable;
            amountAvailable = 0;
            beneficiary.transfer(amtA);
        }
    }

    ///////////////////////////////////////////////////////////
    // Withdraw tokens
    ///////////////////////////////////////////////////////////
    function withdrawTheUnsoldTokens() public onlyOwner afterDeadline{
        if(numTokensLeft <= 0)
        {
            revert();
        }
        else
        {
            uint ntl = numTokensLeft;
            numTokensLeft=0;
            tokenReward.transfer(beneficiary, ntl);
            crowdsaleClosed = true;
            CSClosed(crowdsaleClosed);
        }
    }

    /////////////////////////////////////////////////////////////
    // give the crowdsale a new newDeadline
    ////////////////////////////////////////////////////////////

    modifier afterDeadline() { if (now >= deadline) _; }

    function setDeadline(uint time) public onlyOwner {
        if(now > time || msg.sender==beneficiary)
        {
            revert(); // Don't change past
        }
        deadline = time;
        EndsAtChanged(deadline);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
}
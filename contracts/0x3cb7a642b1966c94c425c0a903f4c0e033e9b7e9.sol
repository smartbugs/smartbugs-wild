pragma solidity ^0.4.18;

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
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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


contract TempusToken {

    function mint(address receiver, uint256 amount) public returns (bool success);

}

contract TempusPreIco is Ownable {
    using SafeMath for uint256;

    // start and end timestamps where investments are allowed (both inclusive)
    uint public startTime = 1512118800; //1 December 2017 09:00:00 GMT
    uint public endTime = 1517562000; //2 February 2018 09:00:00 GMT

    //token price
    uint public price = 0.005 ether / 1000;

    //max tokens could be sold during preico
    uint public hardCap = 860000000;
    uint public tokensSold = 0;

    bool public paused = false;

    address withdrawAddress1;
    address withdrawAddress2;

    TempusToken token;

    mapping(address => bool) public sellers;

    modifier onlySellers() {
        require(sellers[msg.sender]);
        _;
    }

    function TempusPreIco (address tokenAddress, address _withdrawAddress1,
    address _withdrawAddress2) public {
        token = TempusToken(tokenAddress);
        withdrawAddress1 = _withdrawAddress1;
        withdrawAddress2 = _withdrawAddress2;
    }

    /**
    * @dev Function that indicates whether pre ico is active or not
    */
    function isActive() public view returns (bool active) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool capIsNotMet = tokensSold < hardCap;
        return capIsNotMet && withinPeriod && !paused;
    }

    function() external payable {
        buyFor(msg.sender);
    }

    /**
    * @dev Low-level purchase function. Purchases tokens for specified address
    * @param beneficiary Address that will get tokens
    */
    function buyFor(address beneficiary) public payable {
        require(msg.value != 0);
        uint amount = msg.value;
        uint tokenAmount = amount.div(price);
        makePurchase(beneficiary, tokenAmount);
    }

    /**
    * @dev Function that is called by our robot to allow users
    * to buy tonkens for various cryptos.
    * @param beneficiary An address that will get tokens
    * @param amount Amount of tokens that address will get
    */
    function externalPurchase(address beneficiary, uint amount) external onlySellers {
        makePurchase(beneficiary, amount);
    }

    function makePurchase(address beneficiary, uint amount) private {
        require(beneficiary != 0x0);
        require(isActive());
        uint minimumTokens = 20000;
        if(tokensSold < hardCap.sub(minimumTokens)) {
            require(amount >= minimumTokens);
        }
        require(amount.add(tokensSold) <= hardCap);
        tokensSold = tokensSold.add(amount);
        token.mint(beneficiary, amount);
    }

    function setPaused(bool isPaused) external onlyOwner {
        paused = isPaused;
    }

    /**
    * @dev Sets address of seller robot
    * @param seller Address of seller robot to set
    * @param isSeller Parameter whether set as seller or not
    */
    function setAsSeller(address seller, bool isSeller) external onlyOwner {
        sellers[seller] = isSeller;
    }

    /**
    * @dev Set start time of Pre ICO
    * @param _startTime Start of Pre ICO (unix time)
    */
    function setStartTime(uint _startTime) external onlyOwner {
        startTime = _startTime;
    }

    /**
    * @dev Sets end time of Pre ICO
    * @param _endTime End time of Pre ICO (unit time)
    */
    function setEndTime(uint _endTime) external onlyOwner {
        endTime = _endTime;
    }

    /**
    * @dev Function to get ether from contract
    * @param amount Amount in wei to withdraw
    */
    function withdrawEther(uint amount) external onlyOwner {
        withdrawAddress1.transfer(amount / 2);
        withdrawAddress2.transfer(amount / 2);
    }

}
pragma solidity 0.4.24;

/// @title Ownable
/// @dev Provide a modifier that permits only a single user to call the function
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @dev Set the original `owner` of the contract to the sender account.
    constructor() public {
        owner = msg.sender;
    }

    /// @dev Require that the modified function is only called by `owner`
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev Allow `owner` to transfer control of the contract to `newOwner`.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/// @title SafeMath
/// @dev Math operations with safety checks that throw on error
library SafeMath {

    /// @dev Multiply two numbers, throw on overflow.
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /// @dev Substract two numbers, throw on overflow (i.e. if subtrahend is greater than minuend).
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /// @dev Add two numbers, throw on overflow.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/// @title Whitelist
/// @dev Handle whitelisting, maximum purchase limits, and bonus calculation for PLGCrowdsale
contract Whitelist is Ownable {
    using SafeMath for uint256;

    /// A participant in the crowdsale
    struct Participant {
        /// Percent of bonus tokens awarded to this participant
        uint256 bonusPercent;
        /// Maximum amount the participant can contribute in wei
        uint256 maxPurchaseAmount;
        /// Wei contributed to the crowdsale so far
        uint256 weiContributed;
    }

    /// Crowdsale address, used to authorize purchase records
    address public crowdsaleAddress;

    /// Bonus/Vesting for specific accounts
    /// If Participant.maxPurchaseAmount is zero, the address is not whitelisted
    mapping(address => Participant) private participants;

    /// @notice Set the crowdsale address. Only one crowdsale at a time may use this whitelist
    /// @param crowdsale The address of the crowdsale
    function setCrowdsale(address crowdsale) public onlyOwner {
        require(crowdsale != address(0));
        crowdsaleAddress = crowdsale;
    }

    /// @notice Get the bonus token percentage for `user`
    /// @param user The address of a crowdsale participant
    /// @return The percentage of bonus tokens `user` qualifies for
    function getBonusPercent(address user) public view returns(uint256) {
        return participants[user].bonusPercent;
    }

    /// @notice Check if an address is whitelisted
    /// @param user Potential participant
    /// @return Whether `user` may participate in the crowdsale
    function isValidPurchase(address user, uint256 weiAmount) public view returns(bool) {
        require(user != address(0));
        Participant storage participant = participants[user];
        if(participant.maxPurchaseAmount == 0) {
            return false;
        }
        return participant.weiContributed.add(weiAmount) <= participant.maxPurchaseAmount;
    }

    /// @notice Whitelist a crowdsale participant
    /// @notice Do not override weiContributed if the user has previously been whitelisted
    /// @param user The participant to add
    /// @param bonusPercent The user's bonus percentage
    /// @param maxPurchaseAmount The maximum the participant is allowed to contribute in wei
    ///     If zero, the user is de-whitelisted
    function addParticipant(address user, uint256 bonusPercent, uint256 maxPurchaseAmount) external onlyOwner {
        require(user != address(0));
        participants[user].bonusPercent = bonusPercent;
        participants[user].maxPurchaseAmount = maxPurchaseAmount;
    }

    /// @notice Whitelist multiple crowdsale participants at once with the same bonus/purchase amount
    /// @param users The participants to add
    /// @param bonusPercent The bonus percentage shared among users
    /// @param maxPurchaseAmount The maximum each participant is allowed to contribute in wei
    function addParticipants(address[] users, uint256 bonusPercent, uint256 maxPurchaseAmount) external onlyOwner {
        
        for(uint i=0; i<users.length; i+=1) {
            require(users[i] != address(0));
            participants[users[i]].bonusPercent = bonusPercent;
            participants[users[i]].maxPurchaseAmount = maxPurchaseAmount;
        }
    }

    /// @notice De-whitelist a crowdsale participant
    /// @param user The participant to revoke
    function revokeParticipant(address user) external onlyOwner {
        require(user != address(0));
        participants[user].maxPurchaseAmount = 0;
    }

    /// @notice De-whitelist multiple crowdsale participants at once
    /// @param users The participants to revoke
    function revokeParticipants(address[] users) external onlyOwner {
        
        for(uint i=0; i<users.length; i+=1) {
            require(users[i] != address(0));
            participants[users[i]].maxPurchaseAmount = 0;
        }
    }

    function recordPurchase(address beneficiary, uint256 weiAmount) public {

        require(msg.sender == crowdsaleAddress);

        Participant storage participant = participants[beneficiary];
        participant.weiContributed = participant.weiContributed.add(weiAmount);
    }
    
}
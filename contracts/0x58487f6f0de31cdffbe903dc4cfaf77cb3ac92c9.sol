/**
 *  Liven crowdsale contract.
 *
 *  There is no ETH hard cap in this contract due to the fact that Liven are
 *  collecting funds in more than one currency. This contract is a single
 *  component of a wider sale. The hard cap for the entire sale is USD $28m.
 *
 *  This sale has a six week time limit which can be extended by the owner. It
 *  can be stopped at any time by the owner.
 *
 *  More information is available on https://livenpay.io.
 *
 *  Minimum contribution: 0.1 ETH
 *  Maximum contribution: 1000 ETH
 *  Minimum duration: 6 weeks from deployment
 *
 */

pragma solidity 0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private owner_;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner_ = msg.sender;
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
        return owner_;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner_, "Only the owner can call this function.");
        _;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner_);
        owner_ = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "Cannot transfer ownership to zero address.");
        emit OwnershipTransferred(owner_, _newOwner);
        owner_ = _newOwner;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // assert(_b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
        return _a / _b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

contract LivenSale is Ownable {

    using SafeMath for uint256;

    uint256 public maximumContribution = 1000 ether;
    uint256 public minimumContribution = 100 finney;
    uint256 public totalWeiRaised;
    uint256 public endTimestamp;
    uint256 public constant SIX_WEEKS_IN_SECONDS = 86400 * 7 * 6;

    bool public saleEnded = false;
    address public proceedsAddress;

    mapping (address => uint256) public weiContributed;

    constructor (address _proceedsAddress) public {
        proceedsAddress = _proceedsAddress;
        endTimestamp = block.timestamp + SIX_WEEKS_IN_SECONDS;
    }

    function () public payable {
        buyTokens();
    }

    function buyTokens () public payable {
        require(!saleEnded && block.timestamp < endTimestamp, "Campaign has ended. No more contributions possible.");
        require(msg.value >= minimumContribution, "No contributions below 0.1 ETH.");
        require(weiContributed[msg.sender] < maximumContribution, "Contribution cap already reached.");

        uint purchaseAmount = msg.value;
        uint weiToReturn;
        
        // Check max contribution
        uint remainingContributorAllowance = maximumContribution.sub(weiContributed[msg.sender]);
        if (remainingContributorAllowance < purchaseAmount) {
            purchaseAmount = remainingContributorAllowance;
            weiToReturn = msg.value.sub(purchaseAmount);
        }

        // Store allocation
        weiContributed[msg.sender] = weiContributed[msg.sender].add(purchaseAmount);
        totalWeiRaised = totalWeiRaised.add(purchaseAmount);

        // Forward ETH immediately to the multisig
        proceedsAddress.transfer(purchaseAmount);

        // Return excess ETH
        if (weiToReturn > 0) {
            address(msg.sender).transfer(weiToReturn);
        }
    }

    function extendSale (uint256 _seconds) public onlyOwner {
        endTimestamp += _seconds;
    }

    function endSale () public onlyOwner {
        saleEnded = true;
    }
}
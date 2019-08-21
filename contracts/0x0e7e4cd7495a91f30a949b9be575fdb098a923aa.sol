pragma solidity ^0.4.18;



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

contract ClickableTVToken {
    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool);
}

contract ClicableTVSale is Ownable {
    using SafeMath for uint256;

    // The token being sold
    ClickableTVToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    //  uint256 public startTime = block.timestamp; // for test. Time of deploy smart-contract
    //    uint256 public startTime = 1522540800; // for production. Timestamp 01 Apr 2018 00:00:00 UTC
    uint256 public presaleStart = 1516492800; // Sunday, 21-Jan-18 00:00:00 UTC
    uint256 public presaleEnd = 1519862399; // Wednesday, 28-Feb-18 23:59:59 UTC
    uint256 public saleStart = 1519862400; // Thursday, 01-Mar-18 00:00:00 UTC
    uint256 public saleEnd = 1527811199; // Thursday, 31-May-18 23:59:59 UTC

    // address where funds are collected
    address public wallet;

    // ICO Token Price – 1 CKTV = .0001 ETH
    uint256 public rate = 10000;

    // amount of raised money in wei
    uint256 public weiRaised;

    function ClicableTVSale() public {
        wallet = msg.sender;
    }

    function setToken(ClickableTVToken _token) public onlyOwner {
        token = _token;
    }

    // By default wallet == owner
    function setWallet(address _wallet) public onlyOwner {
        wallet = _wallet;
    }

    function tokenWeiToSale() public view returns (uint256) {
        return token.balanceOf(this);
    }

    function transfer(address _to, uint256 _value) public onlyOwner returns (bool){
        assert(tokenWeiToSale() >= _value);
        token.transfer(_to, _value);
    }


    // fallback function can be used to buy tokens
    function() external payable {
        buyTokens(msg.sender);
    }

    /**
  * event for token purchase logging
  * @param purchaser who paid for the tokens
  * @param beneficiary who got the tokens
  * @param value weis paid for purchase
  * @param amount amount of tokens purchased
  */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        // 25% discount of token price for the first six weeks during pre-sale
        if (block.timestamp < presaleEnd) tokens = tokens.mul(100).div(75);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.transfer(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal view returns (bool) {
        bool presalePeriod = now >= presaleStart && now <= presaleEnd;
        bool salePeriod = now >= saleStart && now <= saleEnd;
        bool nonZeroPurchase = msg.value != 0;
        return (presalePeriod || salePeriod) && nonZeroPurchase;
    }
}
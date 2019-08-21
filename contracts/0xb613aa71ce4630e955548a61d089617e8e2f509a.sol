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


contract MomsAvenueToken {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
}


contract MomsAvenueCrowdsale {

    using SafeMath for uint256;

    MomsAvenueToken public token;

    //Tokens per 1 eth
    uint256 constant public rate = 10000;
    
    uint256 constant public goal = 20000000 * (10 ** 18);
    uint256 public startTime;
    uint256 public endTime;
    uint256 public weiRaised;
    uint256 public tokensSold;

    bool public crowdsaleActive = true;

    address public wallet;
    address public tokenOwner;

    mapping(address => uint256) balances;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
    * @param _startTime Unix timestamp
    * @param _endTime Unix timestamp
    * @param _wallet Ethereum address to which the invested funds are forwarded
    * @param _token Address of the token that will be rewarded for the investors
    * @param _tokenOwner Address of the token owner who can execute restricted functions
    */
    function MomsAvenueCrowdsale(uint256 _startTime, uint256 _endTime, address _wallet, address _token, address _tokenOwner) public {
        require(_startTime < _endTime);
        require(_wallet != address(0));
        require(_token != address(0));
        require(_tokenOwner != address(0));

        startTime = _startTime;
        endTime = _endTime;

        wallet = _wallet;
        tokenOwner = _tokenOwner;
        token = MomsAvenueToken(_token);
    }

    // fallback function can be used to buy tokens
    function () external payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address investor) public payable {
        require(investor != address(0));
        require(now >= startTime && now <= endTime);
        require(crowdsaleActive);
        require(msg.value != 0);

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

        require(tokensSold.add(tokens) <= goal);

        // update state
        weiRaised = weiRaised.add(weiAmount);
        tokensSold = tokensSold.add(tokens);
        balances[investor] = balances[investor].add(weiAmount);

        assert(token.transferFrom(tokenOwner, investor, tokens));
        TokenPurchase(msg.sender, investor, weiAmount, tokens);

        wallet.transfer(msg.value);
    }

    function setCrowdsaleActive(bool _crowdsaleActive) public {
        require(msg.sender == tokenOwner);
        crowdsaleActive = _crowdsaleActive;
    }

    /**
        * @dev Gets the balance of the specified address.
        * @param _owner The address to query the the balance of.
        * @return An uint256 representing the amount owned by the passed address.
        */
    function balanceOf(address _owner) external constant returns (uint256 balance) {
        return balances[_owner];
    }
}
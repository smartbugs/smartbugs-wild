pragma solidity 0.4.20;

contract PapereumTokenBridge {
    function makeNonFungible(uint256 amount, address owner) public;
    function token() public returns (PapereumToken);
}


contract PapereumToken {

    string public name = "Papereum";
    string public symbol = "PPRM";
    uint256 public decimals = 0; // Papereum tokens are not divisible
    uint256 public totalSupply = 100000; // Only 100 000 Non-divisable pieces of Art

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    bool public isTradable = false;

    address public owner = address(0);
    PapereumTokenBridge public bridge;

    function PapereumToken() public {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        Transfer(address(0), owner, totalSupply);
    }

    function setBridge(address _bridge) public {
        require(msg.sender == owner);
        require(isTradable);
        require(_bridge != address(0));
        require(bridge == address(0));
        bridge = PapereumTokenBridge(_bridge);
        require(bridge.token() == this);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(isTradable || msg.sender == owner);
        require(_to != address(0));
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        if (_to == address(bridge)) {
            bridge.makeNonFungible(_value, msg.sender);
        }
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(isTradable);
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        if (_to == address(bridge)) {
            bridge.makeNonFungible(_value, msg.sender); // Caller takes ownership of trackable tokens
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        require(allowance[msg.sender][_spender] + _addedValue >= allowance[msg.sender][_spender]);
        allowance[msg.sender][_spender] = allowance[msg.sender][_spender] + _addedValue;
        Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowance[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowance[msg.sender][_spender] = 0;
        } else {
            allowance[msg.sender][_spender] = oldValue - _subtractedValue;
        }
        Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

    function burn(address newOwner) public returns (bool success) {
        require(msg.sender == owner);
        require(!isTradable);
        require(newOwner != address(0));
        uint256 value = balanceOf[owner];
        balanceOf[owner] = 0;
        totalSupply -= value;
        isTradable = true;
        Transfer(owner, address(0), value);
        owner = newOwner;
        return true;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner);
        require(newOwner != address(0));
        owner = newOwner;
    }

}


contract PapereumCrowdsale {
    // Wallet where all ether will be
    address public constant WALLET = 0xE77E35a07794761277870521C80d1cA257383292;
    // Wallet for team tokens
    address public constant TEAM_WALLET = 0x5C31f06b4AAC5D5c84Fd7735971B951d7E5104A0;
    // Wallet for media support tokens
    address public constant MEDIA_SUPPORT_WALLET = 0x8E6618e41879d8BE1F7a0E658294E8A1359e4383;

    uint256 public constant ICO_TOKENS = 93000;
    uint32 public constant ICO_TOKENS_PERCENT = 93;
    uint32 public constant TEAM_TOKENS_PERCENT = 2;
    uint32 public constant MEDIA_SUPPORT_PERCENT = 5;
    uint256 public constant START_TIME = 1518998400; // 2018/02/19 00:00 UTC +0
    uint256 public constant END_TIME = 1525046400; // 2018/04/30 00:00 UTC +0
    uint256 public constant RATE = 1e16; // 100 tokens costs 1 ether

    // The token being sold
    PapereumToken public token;
    // amount of raised money in wei
    uint256 public weiRaised;
    bool public isFinalized = false;
    address private tokenMinter;
    address public owner;
    uint256 private icoBalance = ICO_TOKENS;

    event Progress(uint256 tokensSold, uint256 weiRaised);

    event Finalized();
    /**
    * When there no tokens left to mint and token minter tries to manually mint tokens
    * this event is raised to signal how many tokens we have to charge back to purchaser
    */
    event ManualTokenMintRequiresRefund(address indexed purchaser, uint256 value);

    function PapereumCrowdsale() public {
        token = new PapereumToken();
        owner = msg.sender;
        tokenMinter = msg.sender;
    }

    // fallback function can be used to buy tokens or claim refund
    function () external payable {
        buyTokens(msg.sender);
    }

    function assignTokens(address[] _receivers, uint256[] _amounts) external {
        require(msg.sender == tokenMinter || msg.sender == owner);
        require(_receivers.length > 0 && _receivers.length <= 100);
        require(_receivers.length == _amounts.length);
        require(!isFinalized);
        for (uint256 i = 0; i < _receivers.length; i++) {
            address receiver = _receivers[i];
            uint256 amount = _amounts[i];

            require(receiver != address(0));
            require(amount > 0);

            uint256 excess = appendContribution(receiver, amount);

            if (excess > 0) {
                ManualTokenMintRequiresRefund(receiver, excess);
            }
        }
        Progress(ICO_TOKENS - icoBalance, weiRaised);
    }

    function buyTokens(address beneficiary) private {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiReceived = msg.value;

        uint256 tokens;
        uint256 refund;
        (tokens, refund) = calculateTokens(weiReceived);

        uint256 excess = appendContribution(beneficiary, tokens);
        refund += (excess > 0 ? ((excess * weiReceived) / tokens) : 0);

        tokens -= excess;
        weiReceived -= refund;
        weiRaised += weiReceived;

        if (refund > 0) {
            msg.sender.transfer(refund);
        }

        WALLET.transfer(weiReceived);
        Progress(ICO_TOKENS - icoBalance, weiRaised);
    }

    /**
    * @dev Must be called after crowdsale ends, to do some extra finalization
    * work. Calls the contract's finalization function.
    */
    function finalize() public {
        require(msg.sender == owner);
        require(!isFinalized);
        require(getNow() > END_TIME || icoBalance == 0);
        isFinalized = true;

        uint256 totalSoldTokens = ICO_TOKENS - icoBalance;

        uint256 teamTokens = (TEAM_TOKENS_PERCENT * totalSoldTokens) / ICO_TOKENS_PERCENT;
        token.transfer(TEAM_WALLET, teamTokens);
        uint256 mediaTokens = (MEDIA_SUPPORT_PERCENT * totalSoldTokens) / ICO_TOKENS_PERCENT;
        token.transfer(MEDIA_SUPPORT_WALLET, mediaTokens);

        token.burn(owner);

        Finalized();
    }

    function setTokenMinter(address _tokenMinter) public {
        require(msg.sender == owner);
        require(_tokenMinter != address(0));
        tokenMinter = _tokenMinter;
    }

    function getNow() internal view returns (uint256) {
        return now;
    }

    function calculateTokens(uint256 _weiAmount) internal view returns (uint256 tokens, uint256 refundWei) {
        tokens = _weiAmount / RATE;
        refundWei = _weiAmount - (tokens * RATE);
        uint256 now_ = getNow();
        uint256 bonus = 0;

        if (now_ < 1519603200) { // 26-02-2018
            if (tokens >= 2000) bonus = 30;
            else if (tokens >= 500) bonus = 25;
            else if (tokens >= 50) bonus = 20;
            else if (tokens >= 10) bonus = 10;
        } else if (now_ < 1521417600) { // 19-03-2018
            if (tokens >= 10) bonus = 7;
        } else if (now_ < 1522627200) { // 02-04-2018
            if (tokens >= 10) bonus = 5;
        } else if (now_ < 1523232000) { // 09-04-2018
            if (tokens >= 10) bonus = 3;
        }

        tokens += (tokens * bonus) / 100; // with totalSupply <= 100000 and decimals=0 no need in SafeMath
    }

    function appendContribution(address _beneficiary, uint256 _tokens) internal returns (uint256 excess) {
        excess = 0;
        require(_tokens >= 10);
        if (_tokens > icoBalance) {
            excess = icoBalance - _tokens;
            _tokens = icoBalance;
        }
        if (_tokens > 0) {
            icoBalance -= _tokens;
            token.transfer(_beneficiary, _tokens);
        }
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = getNow() >= START_TIME && getNow() <= END_TIME;
        bool nonZeroPurchase = msg.value != 0;
        bool canTransfer = icoBalance > 0;
        return withinPeriod && nonZeroPurchase && canTransfer;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner);
        require(newOwner != address(0));
        owner = newOwner;
    }
}
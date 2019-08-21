pragma solidity ^0.4.25;

/*
    Neutrino Token Standard v1.1
    + fund() payable
    + 2 days free deposit

    [Rules]

    [✓] 10% Deposit fee
            33% => referrer (or contract owner, if none)
            10% => contract owner
            57% => dividends
    [✓] 1% Withdraw fee
            100% => contract owner
*/

contract NeutrinoTokenStandard {
    modifier onlyBagholders {
        require(myTokens() > 0);
        _;
    }

    modifier onlyStronghands {
        require(myDividends(true) > 0);
        _;
    }

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy,
        uint timestamp,
        uint256 price
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned,
        uint timestamp,
        uint256 price
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
    
    event OnFunded(
        address indexed source,
        uint256 value,
        uint256 perShare
    );

    string public name = "Neutrino Token Standard";
    string public symbol = "NTS";
    address constant internal boss = 0x10d915C0B3e01090C7B5f80eF2D9CdB616283853;
    uint8 constant public decimals = 18;
    uint8 constant internal entryFee_ = 10;
    uint8 constant internal exitFee_ = 1;
    uint8 constant internal refferalFee_ = 33;
    uint8 constant internal ownerFee1 = 10;
    uint8 constant internal ownerFee2 = 25;
    uint32 holdTimeInBlocks = 558000;
    uint256 constant internal tokenPrice = 0.001 ether;
    
    uint256 constant internal magnitude = 2 ** 64;
    uint256 public stakingRequirement = 50e18;
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) public referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) public since;

    uint256 internal tokenSupply_;
    uint256 internal profitPerShare_;
    uint256 internal start_;
    
    constructor() public {
        start_ = block.number;
    }

    function buy(address _referredBy) public payable returns (uint256) {
        return purchaseTokens(msg.value, _referredBy);
    }

    function() payable public {
        purchaseTokens(msg.value, 0x0);
    }

    function reinvest() onlyStronghands public {
        uint256 _dividends = myDividends(false);
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        uint256 _tokens = purchaseTokens(_dividends, 0x0);
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    function exit() public {
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) sell(_tokens);
        withdraw();
    }

    function withdraw() onlyStronghands public {
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false);
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        _customerAddress.transfer(_dividends);
        emit onWithdraw(_customerAddress, _dividends);
    }

    function sell(uint256 _amountOfTokens) onlyBagholders public {
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);

        uint8 applyFee;
        uint256 _dividends;
        uint256 forBoss;
        uint256 _taxedEthereum;
        
        if (since[msg.sender] + holdTimeInBlocks > block.number) {
            applyFee = 20;

            _dividends = SafeMath.div(SafeMath.mul(_ethereum, applyFee), 100);
            forBoss = SafeMath.div(SafeMath.mul(_dividends, ownerFee2), 100);
            _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
            
            _dividends = SafeMath.sub(_dividends, forBoss);
            
            tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
    
            if (tokenSupply_ > 0) {
                profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
            } else {
                referralBalance_[boss] += _dividends;
            }
        } else {
            applyFee = exitFee_;
            
            forBoss = SafeMath.div(SafeMath.mul(_ethereum, applyFee), 100);
            _taxedEthereum = SafeMath.sub(_ethereum, forBoss);
            
            tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        }
        
        referralBalance_[boss] = SafeMath.add(referralBalance_[boss], forBoss);
        
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;
        
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());
    }


    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    function myDividends(bool _includeReferralBonus) public view returns (uint256) {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }

    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    function sellPrice() public pure returns (uint256) {
        uint256 _ethereum = tokensToEthereum_(1e18);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        return _taxedEthereum;
    }

    function buyPrice() public pure returns (uint256) {
        uint256 _ethereum = tokensToEthereum_(1e18);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, entryFee_), 100);
        uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);

        return _taxedEthereum;
    }

    function calculateTokensReceived(uint256 _ethereumToSpend) public pure returns (uint256) {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, entryFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

        return _amountOfTokens;
    }

    function calculateEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint8 applyFee = exitFee_;
        if (since[msg.sender] + holdTimeInBlocks > block.number) applyFee = 20;
        
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, applyFee), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }

    function purchaseTokens(uint256 _incomingEthereum, address _referredBy) internal returns (uint256) {
        address _customerAddress = msg.sender;
        uint8 _entryFee = entryFee_;
        if (block.number < start_ + 12130) _entryFee = 0;
        
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, _entryFee), 100);
        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, refferalFee_), 100);
        uint256 forBoss = SafeMath.div(SafeMath.mul(_undividedDividends, ownerFee1), 100);
        uint256 _dividends = SafeMath.sub(SafeMath.sub(_undividedDividends, _referralBonus), forBoss);
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;

        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_);

        if (
            _referredBy != 0x0000000000000000000000000000000000000000 &&
            _referredBy != _customerAddress &&
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ) {
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
            emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy, now, buyPrice());
        } else {
            referralBalance_[boss] = SafeMath.add(referralBalance_[boss], _referralBonus);
            emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, 0x0, now, buyPrice());
        }

        referralBalance_[boss] = SafeMath.add(referralBalance_[boss], forBoss);

        if (tokenSupply_ > 0) {
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
            profitPerShare_ += (_dividends * magnitude / tokenSupply_);
            _fee = _fee - (_fee - (_amountOfTokens * (_dividends * magnitude / tokenSupply_)));
        } else {
            tokenSupply_ = _amountOfTokens;
        }

        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;
        if (since[msg.sender] == 0) since[msg.sender] = block.number;

        return _amountOfTokens;
    }

    function ethereumToTokens_(uint256 _ethereum) public pure returns (uint256) {
        uint256 _tokensReceived = SafeMath.div(SafeMath.mul(_ethereum, 1e18), tokenPrice);

        return _tokensReceived;
    }

    function tokensToEthereum_(uint256 _tokens) public pure returns (uint256) {
        uint256 _etherReceived = SafeMath.div(SafeMath.mul(_tokens, tokenPrice), 1e18);

        return _etherReceived;
    }
    
    function fund() public payable {
        uint256 perShare = msg.value * magnitude / tokenSupply_;
        profitPerShare_ += perShare;
        emit OnFunded(msg.sender, msg.value, perShare);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}
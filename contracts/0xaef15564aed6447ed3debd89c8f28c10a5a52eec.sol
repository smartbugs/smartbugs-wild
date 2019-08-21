pragma solidity ^0.4.15;

contract Permittable {
    mapping(address => bool) permitted;

    function Permittable() public {
        permitted[msg.sender] = true;
    }

    modifier onlyPermitted() {
        require(permitted[msg.sender]);
        _;
    }

    function permit(address _address, bool _isAllowed) public onlyPermitted {
        permitted[_address] = _isAllowed;
    }

    function isPermitted(address _address) public view returns (bool) {
        return permitted[_address];
    }
}

contract Destructable is Permittable {
    function kill() public onlyPermitted {
        selfdestruct(msg.sender);
    }
}

contract Withdrawable is Permittable {
    function withdraw(address _to, uint256 _amount) public onlyPermitted {
        require(_to != address(0));

        if (_amount == 0)
            _amount = this.balance;

        _to.transfer(_amount);
    }
}

contract ERC20Token {

    // Topic: ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    // Topic: 8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
    event Approval(address indexed _owner, address indexed _recipient, uint256 _amount);

    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _amount) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
    function approve(address _recipient, uint256 _amount) public returns (bool success);
    function allowance(address _owner, address _recipient) public constant returns (uint256 remaining);
}

contract TokenStorage is Permittable, Destructable, Withdrawable {
    struct Megabox {
        address owner;
        uint256 totalSupply;
        uint256 timestamp;
    }

    mapping(address => uint256) private balances;
    mapping(string => uint256) private settings;
    mapping(uint256 => Megabox) private megaboxes;
    uint256 megaboxIndex = 0;

    function _start() public onlyPermitted {
        //Number of decimal places
        uint decimalPlaces = 8;
        setSetting("decimalPlaces", decimalPlaces);

        //Tokens stored as integer values multiplied by multiplier. I.e. 1 token with 8 decimals would be stored as 100,000,000
        setSetting("multiplier", 10 ** decimalPlaces);

        //Tokens amount to send exhausting warning
        setSetting("exhaustingNumber", 2 * 10**decimalPlaces);

        //Token price in weis per 1
        setSetting("tokenPrice", 15283860872157044);

        //Decimator for the percents (1000 = 100%)
        setSetting("percentage", 1000);

        //TransferFee(10) == 1%
        setSetting("transferFee", 10);

        //PurchaseFee(157) == 15.7%
        setSetting("purchaseFee", 0);

        //PurchaseCap(5000) == 5000.00000000 tokens
        setSetting("purchaseCap", 0);

        //PurchaseTimeout in seconds
        setSetting("purchaseTimeout", 0);

        //Timestamp when ICO
        setSetting("icoTimestamp", now);

        //RedemptionTimeout in seconds
        setSetting("redemptionTimeout", 365 * 24 * 60 * 60);

        //RedemptionFee(157) == 15.7%
        setSetting("redemptionFee", 0);

        // Address to return operational fees
        setSetting("feeReturnAddress", uint(address(0x0d026A63a88A0FEc2344044e656D6B63684FBeA1)));

        // Address to collect dead tokens
        setSetting("deadTokensAddress", uint(address(0x4DcB8F5b22557672B35Ef48F8C2b71f8F54c251F)));

        //Total supply of tokens
        setSetting("totalSupply", 100 * 1000 * 1000 * (10 ** decimalPlaces));

        setSetting("newMegaboxThreshold", 1 * 10**decimalPlaces);
    }

    function getBalance(address _address) public view onlyPermitted returns(uint256) {
        return balances[_address];
    }

    function setBalance(address _address, uint256 _amount) public onlyPermitted returns (uint256) {
        balances[_address] = _amount;
        return balances[_address];
    }

    function transfer(address _from, address _to, uint256 _amount) public onlyPermitted returns (uint256) {
        require(balances[_from] >= _amount);

        decreaseBalance(_from, _amount);
        increaseBalance(_to, _amount);
        return _amount;
    }

    function decreaseBalance(address _address, uint256 _amount) public onlyPermitted returns (uint256) {
        require(balances[_address] >= _amount);

        balances[_address] -= _amount;
        return _amount;
    }

    function increaseBalance(address _address, uint256 _amount) public onlyPermitted returns (uint256) {
        balances[_address] += _amount;
        return _amount;
    }

    function getSetting(string _name) public view onlyPermitted returns(uint256) {
        return settings[_name];
    }

    function getSettingAddress(string _name) public view onlyPermitted returns(address) {
        return address(getSetting(_name));
    }

    function setSetting(string _name, uint256 _value) public onlyPermitted returns (uint256) {
        settings[_name] = _value;
        return settings[_name];
    }

    function newMegabox(address _owner, uint256 _tokens, uint256 _timestamp) public onlyPermitted {
        uint newMegaboxIndex = megaboxIndex++;
        megaboxes[newMegaboxIndex] = Megabox({owner: _owner, totalSupply: _tokens, timestamp: _timestamp});

        setSetting("totalSupply", getSetting("totalSupply") + _tokens);

        uint256 balance = balances[_owner] + _tokens;
        setBalance(_owner, balance);
    }

    function getMegabox(uint256 index) public view onlyPermitted returns (address, uint256, uint256) {
        return (megaboxes[index].owner, megaboxes[index].totalSupply, megaboxes[index].timestamp);
    }

    function getMegaboxIndex() public view onlyPermitted returns (uint256) {
        return megaboxIndex;
    }
}

contract TokenValidator is Permittable, Destructable {
    TokenStorage store;
    mapping(address => uint256) datesOfPurchase;

    function _setStore(address _address) public onlyPermitted {
        store = TokenStorage(_address);
    }

    function getTransferFee(address _owner, address _address, uint256 _amount) public view returns(uint256) {
        return (_address == _owner) ? 0 : (_amount * store.getSetting("transferFee") / store.getSetting("percentage"));
    }

    function validateAndGetTransferFee(address _owner, address _from, address /*_to*/, uint256 _amount) public view returns(uint256) {
        uint256 _fee = getTransferFee(_owner, _from, _amount);

        require(_amount > 0);
        require((_amount + _fee) > 0);
        require(store.getBalance(_from) >= (_amount + _fee));

        return _fee;
    }

    function validateResetDeadTokens(uint256 _amount) public view returns(address) {
        address deadTokensAddress = store.getSettingAddress("deadTokensAddress");
        uint256 deadTokens = store.getBalance(deadTokensAddress);

        require(_amount > 0);
        require(_amount <= deadTokens);

        return deadTokensAddress;
    }

    function validateStart(address _owner, address _store) public view {
        require(_store != address(0));
        require(_store == address(store));
        require(store.getBalance(_owner) == 0);
    }

    function validateAndGetPurchaseTokens(address _owner, address _address, uint256 _moneyAmount) public view returns (uint256) {
        uint256 _tokens = _moneyAmount * store.getSetting("multiplier") / store.getSetting("tokenPrice");
        uint256 _purchaseTimeout = store.getSetting("purchaseTimeout");
        uint256 _purchaseCap = store.getSetting("purchaseCap");

        require((_purchaseTimeout <= 0) || (block.timestamp - datesOfPurchase[_address] > _purchaseTimeout));
        require(_tokens > 0);
        require(store.getBalance(_owner) >= _tokens);
        require((_purchaseCap <= 0) || (_tokens <= _purchaseCap));

        return _tokens;
    }

    function updateDateOfPurchase(address _address, uint256 timestamp) public onlyPermitted {
        datesOfPurchase[_address] = timestamp;
    }

    function validateAndGetRedeemFee(address /*_owner*/, address _address, uint256 _tokens) public view returns (uint256) {
        uint256 _icoTimestamp = store.getSetting("icoTimestamp");
        uint256 _redemptionTimeout = store.getSetting("redemptionTimeout");
        uint256 _fee = _tokens * store.getSetting("redemptionFee") / store.getSetting("percentage");

        require((_redemptionTimeout <= 0) || (block.timestamp > _icoTimestamp + _redemptionTimeout));
        require(_tokens > 0);
        require((_tokens + _fee) >= 0);
        require(store.getBalance(_address) >= (_tokens + _fee));

        return _fee;
    }

    function validateStartMegabox(address _owner, uint256 _tokens) public view {
        uint256 _totalSupply = store.getSetting("totalSupply");
        uint256 _newMegaboxThreshold = store.getSetting("newMegaboxThreshold");
        uint256 _ownerBalance = store.getBalance(_owner);

        require(_ownerBalance <= _newMegaboxThreshold);
        require(_tokens > 0);
        require((_totalSupply + _tokens) > _totalSupply);
    }

    function canPurchase(address _owner, address _address, uint256 _tokens) public view returns(bool, bool, bool, bool) {
        uint256 _purchaseTimeout = store.getSetting("purchaseTimeout");
        uint256 _fee = _tokens * store.getSetting("purchaseFee") / store.getSetting("percentage");

        bool purchaseTimeoutPassed = ((_purchaseTimeout <= 0) || (block.timestamp - datesOfPurchase[_address] > _purchaseTimeout));
        bool tokensNumberPassed = (_tokens > 0);
        bool ownerBalancePassed = (store.getBalance(_owner) >= (_tokens + _fee));
        bool purchaseCapPassed = (store.getSetting("purchaseCap") <= 0) || (_tokens < store.getSetting("purchaseCap"));

        return (purchaseTimeoutPassed, ownerBalancePassed, tokensNumberPassed, purchaseCapPassed);
    }

    function canTransfer(address _owner, address _from, address /*_to*/, uint256 _amount) public view returns (bool, bool) {
        uint256 _fee = getTransferFee(_owner, _from, _amount);

        bool transferPositivePassed = (_amount + _fee) > 0;
        bool ownerBalancePassed = store.getBalance(_from) >= (_amount + _fee);

        return (transferPositivePassed, ownerBalancePassed);
    }
}

contract TokenFacade is Permittable, Destructable, Withdrawable, ERC20Token {
    TokenStorage private store;
    TokenValidator validator;

    address private owner;

    // Just for information begin //
    uint256 public infoAboveSpot = 400;
    string public infoTier = "Tier 1";
    string public infoTokenSilverRatio = "1 : 1";
    // Just for information end //

    event TokenSold(address _from, uint256 _amount);                            //fe2ff4cf36ff7d2c2b06eb960897ee0d76d9c3e58da12feb7b93e86b226dd344
    event TokenPurchased(address _address, uint256 _amount, uint256 _tokens);   //3ceffd410054fdaed44f598ff5c1fb450658778e2241892da4aa646979dee617
    event TokenPoolExhausting(uint256 _amount);                                 //29ba2e073781c1157a9b5d5edb561437a6181e92b79152fe776615159312e9cd
    event FeeApplied(string _name, address _address, uint256 _amount);

    mapping(address => mapping (address => uint256)) allowed;

    function TokenFacade() public {
        owner = msg.sender;
    }

    ///@notice Token purchase function. Allows user to purchase amount of tokens acccording to passed amount of Ethers.
    function () public payable {
        purchase();
    }

    function totalSupply() public constant returns (uint256) {
        return store.getSetting("totalSupply");
    }

    function balanceOf(address _address) public constant returns (uint256) {
        return store.getBalance(_address);
    }

    string public constant symbol = "SLVT";
    string public constant name = "SilverToken";
    uint8 public constant decimals = 8;

    ///@notice Transfer `_amount` of tokens (must be sent as floating point number of token and decimal parts)
    ///to `_address` with preliminary approving amount + fee from transaction sender
    ///@param _to Address of the recipient
    ///@param _amount Amount of tokens to transfer. Passed as `Token.Decimals * 10^8`, @see `decimals`.
    function transfer(address _to, uint256 _amount) public returns (bool) {
        uint256 _fee = validator.validateAndGetTransferFee(owner, msg.sender, _to, _amount);

        store.transfer(msg.sender, _to, _amount);

        if (_fee > 0)
            store.transfer(msg.sender, store.getSettingAddress("feeReturnAddress"), _fee);

        Transfer(msg.sender, _to, _amount);

        return true;
    }

    ///@notice Transfer `_amount` of tokens (must be sent as floating point number of token and decimal parts)
    ///to `_address` from address `_from` without autoapproving
    ///@param _to Address of the recipient
    ///@param _amount Amount of tokens to transfer. Passed as `Token.Decimals * 10^8`, @see `decimals`.
    ///@return bool Success state
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(allowed[_from][_to] >= _amount);

        uint256 _fee = validator.validateAndGetTransferFee(owner, _from, _to, _amount);

        store.transfer(_from, _to, _amount);

        if (_fee > 0)
            store.transfer(_from, store.getSettingAddress("feeReturnAddress"), _fee);

        allowed[_from][_to] -= _amount;

        Transfer(_from, _to, _amount);

        return true;
    }

    ///@notice Approve amount `_amount` of tokens to send from transaction creator to `_recipient`
    ///@param _recipient Recipient
    ///@param _amount Amount to approve `Token.Decimals * 10^8`, @see `decimals`
    ///@return bool Success state
    function approve(address _recipient, uint256 _amount) public returns (bool) {
        return __approve_impl(msg.sender, _recipient, _amount);
    }

    ///@notice Return allowed transaction amount from `_from` to `_recipient`
    ///@param _from Initiator of transaction
    ///@param _recipient Recipient
    ///@return uint256 Amount approved to transfer as `Token.Decimals * 10^8`, @see `decimals`
    function allowance(address _from, address _recipient) public constant returns (uint256) {
        return allowed[_from][_recipient];
    }

    ///@notice Token purchase function. Allows user to purchase amount of tokens acccording to passed amount of Ethers.
    function purchase() public payable {
        __purchase_impl(msg.sender, msg.value);
    }

    ///@notice Redeem required amount of tokens for the real asset
    ///@param _tokens Amount of nano tokens provides as `Token.Decimals * 10^8`
    function redeem(uint256 _tokens) public {
        __redeem_impl(msg.sender, _tokens);
    }

    //@notice Get amount if tokens that actually available for purchase
    //@returns amount if tokens
    function getTokensInAction() public view returns (uint256) {
        address deadTokensAddress = store.getSettingAddress("deadTokensAddress");
        return store.getBalance(owner) - store.getBalance(deadTokensAddress);
    }

    //@notice Get price of specified tokens amount. Depends on the second parameter returns price with fee or without
    //@return price of specified tokens in Wei
    function getTokensPrice(uint256 _amount, bool withFee) public constant returns (uint256) {
        uint256 tokenPrice = store.getSetting("tokenPrice");
        uint256 result = _amount * tokenPrice / 10**uint256(decimals);

        if (withFee) {
            result = result + result * store.getSetting("purchaseFee") / store.getSetting("percentage");
        }

        return result;
    }

    function resetDeadTokens(uint256 _amount) public onlyPermitted returns (bool) {
        address deadTokensAddress = validator.validateResetDeadTokens(_amount);
        store.transfer(deadTokensAddress, owner, _amount);
    }

    function canPurchase(address _address, uint256 _tokensAmount) public view returns(bool, bool, bool, bool) {
        return validator.canPurchase(owner, _address, _tokensAmount);
    }

    function canTransfer(address _from, address _to, uint256 _amount) public view returns(bool, bool) {
        return validator.canTransfer(owner, _from, _to, _amount);
    }

    function setInfoAboveSpot(uint256 newInfoAboveSpot) public onlyPermitted {
        infoAboveSpot = newInfoAboveSpot;
    }

    function setInfoTier(string newInfoTier) public onlyPermitted {
        infoTier = newInfoTier;
    }

    function setInfoTokenSilverRatio(string newInfoTokenSilverRatio) public onlyPermitted {
        infoTokenSilverRatio = newInfoTokenSilverRatio;
    }

    function getSetting(string _name) public view returns (uint256) {
        return store.getSetting(_name);
    }

    function getMegabox(uint256 index) public view onlyPermitted returns (address, uint256, uint256) {
        return store.getMegabox(index);
    }

    function getMegaboxIndex() public view onlyPermitted returns (uint256) {
        return store.getMegaboxIndex();
    }

    // Admin functions

    function _approve(address _from, address _recipient, uint256 _amount) public onlyPermitted returns (bool) {
        return __approve_impl(_from, _recipient, _amount);
    }

    function _transfer(address _from, address _to, uint256 _amount) public onlyPermitted returns (bool) {
        validator.validateAndGetTransferFee(owner, _from, _to, _amount);

        store.transfer(_from, _to, _amount);

        Transfer(_from, _to, _amount);

        return true;
    }

    function _purchase(address _to, uint256 _amount) public onlyPermitted {
        __purchase_impl(_to, _amount);
    }

    function _redeem(address _from, uint256 _tokens) public onlyPermitted {
        __redeem_impl(_from, _tokens);
    }

    function _start() public onlyPermitted {
        validator.validateStart(owner, store);

        store.setBalance(owner, store.getSetting("totalSupply"));
        store.setSetting("icoTimestamp", block.timestamp);
    }

    function _setStore(address _address) public onlyPermitted {
        store = TokenStorage(_address);
    }

    function _setValidator(address _address) public onlyPermitted {
        validator = TokenValidator(_address);
    }

    function _setSetting(string _name, uint256 _value) public onlyPermitted {
        store.setSetting(_name, _value);
    }

    function _startMegabox(uint256 _tokens) public onlyPermitted {
        validator.validateStartMegabox(owner, _tokens);
        store.newMegabox(owner, _tokens, now);
    }

    //
    // Shareable functions code implementation
    //

    function __approve_impl(address _sender, address _recipient, uint256 _amount) private returns (bool) {
        allowed[_sender][_recipient] = _amount;
        Approval(_sender, _recipient, _amount);
        return true;
    }

    function __purchase_impl(address _to, uint256 _amount) private {
        uint256 _amountWithoutFee = _amount * store.getSetting("percentage") / (store.getSetting("purchaseFee") + store.getSetting("percentage"));
        uint256 _fee = _amountWithoutFee * store.getSetting("purchaseFee") / store.getSetting("percentage");
        uint256 _ownerBalance = store.getBalance(owner);
        address _feeReturnAddress = store.getSettingAddress("feeReturnAddress");
        uint256 _tokens = validator.validateAndGetPurchaseTokens(owner, msg.sender, _amountWithoutFee);

        store.increaseBalance(_to, _tokens);
        store.decreaseBalance(owner, _tokens);

        if (_fee > 0)
            _feeReturnAddress.transfer(_fee);

        validator.updateDateOfPurchase(_to, now);

        if (_ownerBalance < store.getSetting("exhaustingNumber")) {
            TokenPoolExhausting(_ownerBalance);
        }
        TokenPurchased(_to, msg.value, _tokens);
        Transfer(owner, _to, _tokens);
    }

    function __redeem_impl(address _from, uint256 _tokens) private {
        address deadTokensAddress = store.getSettingAddress("deadTokensAddress");
        address feeReturnAddress = store.getSettingAddress("feeReturnAddress");
        uint256 _fee = validator.validateAndGetRedeemFee(owner, _from, _tokens);

        store.transfer(_from, deadTokensAddress, _tokens);
        store.transfer(_from, feeReturnAddress, _fee);

        TokenSold(_from, _tokens);
    }
}
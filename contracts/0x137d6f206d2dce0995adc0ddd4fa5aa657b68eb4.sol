pragma solidity ^0.4.23;

contract ERC20Interface {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract EggPreSale {
    mapping(address => uint256) userEthIn_;
    mapping(uint256 => transaction) transactions_;
    uint256 weiRaised_;
    uint256 usdRaised_ = 0;
    
    // wallet is offical wallet to receive the fund.
    address public wallet_;
    
    // owner is the trading bot of egg presale.
    address public owner_;
    
    // store the egg coin that will be sold
    address public eggCoinFundWallet_;
    
    uint256 public maxTransactionId_ = 0;
    
    // 1 USD to 25 Egg.
    uint256 public exchangeRate_ = 25;
    
    
    
    ERC20Interface eggCoin_;
    
    // The user who can join egg presale.
    mapping(address => bool) whiteList_;
    
    // The officer who can manage whitelist.
    mapping(address => bool) whiteListManager_;
    
    constructor(
        address _wallet,
        address _eggCoinFundWallet,
        ERC20Interface _eggCoin
    )
        public
    {
        owner_ = msg.sender;
        whiteListManager_[owner_] = true;
        whiteList_[owner_] = true;

        wallet_ = _wallet;
        eggCoinFundWallet_ = _eggCoinFundWallet;
        eggCoin_ = _eggCoin;
    }
    
    /**
     *    __                 _       
     *   /__\_   _____ _ __ | |_ ___ 
     *  /_\ \ \ / / _ \ '_ \| __/ __|
     * //__  \ V /  __/ | | | |_\__ \
     * \__/   \_/ \___|_| |_|\__|___/                       
     */
    
    event EthIn(
        uint256 transactionId,
        uint256 ethIn,
        address indexed buyer
    );
    
    event EggDistribute(
        uint256 transactionId,
        uint256 eggAmount,
        address indexed receiver
    );
    
    event addToWhiteList(
        address indexed buyer
    );
    
    event removeFromWhiteList(
        address indexed buyer
    );
    
     /**
     *                   _ _  __ _           
     *   /\/\   ___   __| (_)/ _(_) ___ _ __ 
     *  /    \ / _ \ / _` | | |_| |/ _ \ '__|
     * / /\/\ \ (_) | (_| | |  _| |  __/ |   
     * \/    \/\___/ \__,_|_|_| |_|\___|_|                                  
     */
    
    modifier onlyOwner(
        address _address
    )
    {
        require(_address == owner_, "This actions is not allowed because of permission.");
        _;
    }
    
    modifier investmentFilter(
        uint256 _ethIn
    )
    {
        require(_ethIn >= 1000000000000000000, "The minimum ETH must over 1 ETH.");
        _;
    }
    
    modifier onlyWhiteListed(
        address _address    
    )
    {
        require(whiteList_[_address] == true, "Hmm... You should be added to whitelist first.");
        _;
    }
    
    modifier onlyWhiteListManager(
        address _address
    )
    {
        require(whiteListManager_[_address] == true, "Oh!!! Are you hacker?");
        _;
    }
   
    modifier onlyNotSoldOut()
    {
        require(eggCoin_.allowance(eggCoinFundWallet_, this) > 0, "The eggs has been sold out.");
        _;
    }

    function()
        payable
        public
        onlyNotSoldOut
        onlyWhiteListed(msg.sender)
        investmentFilter(msg.value)
    {
        // get how much ETH user send into contract.
        uint256 _ethIn = msg.value;
        
        maxTransactionId_ = maxTransactionId_ + 1;
        uint256 _transactionId = maxTransactionId_;
        
        transactions_[_transactionId].ethIn = _ethIn;
        transactions_[_transactionId].buyer = msg.sender;
        transactions_[_transactionId].eggDistributed = false;
        transactions_[_transactionId].blockNumber = block.number;
        
        emit EthIn(
            _transactionId,
            _ethIn,
            msg.sender
        );
    }
    
    function distributeEgg(
        uint256 _transactionId,
        uint256 _ethToUsdRate
    )
        public
        onlyOwner(msg.sender)
    {
        // avoid double distributing
        bool _eggDistributed = transactions_[_transactionId].eggDistributed;
        require(_eggDistributed == false, "Egg has been distributed");
        
        uint256 _userEthIn = transactions_[_transactionId].ethIn;
        
        uint256 _exchageRate = exchangeRate_;
        
        
        uint256 _fee = calculateFee(_ethToUsdRate);
        _userEthIn = _userEthIn - _fee;
        
        address _buyer = transactions_[_transactionId].buyer;
        
        uint256 _eggInContract = eggCoin_.allowance(eggCoinFundWallet_, this);
        
        uint256 _eggToDistribute = ((_ethToUsdRate * _userEthIn) * _exchageRate) / 1000;
        
        if(_eggInContract < _eggToDistribute) {
            
            uint256 _refundEgg = _eggToDistribute - _eggInContract;
            // origin statement: refund = refundEgg * 1000 / _exchageRate / _ethToUsdRate;
            // the parameter: _ethToUsdRate = 25
            uint256 _refund = ((_refundEgg * 40) / _ethToUsdRate);
            _userEthIn = _userEthIn - _refund;
            
            transactions_[_transactionId].ethIn = _userEthIn;
            _buyer.transfer(_refund);
            
            _eggToDistribute = _eggInContract;
        }
        
        // origin statement: _ethToUsdRate * (_userEthIn + _fee) / 1000 / 1000000000000000000;
        
        uint256 _usdSendIn = (_ethToUsdRate * (_userEthIn + _fee)) / 1000000000000000000000;
        usdRaised_ = _usdSendIn + usdRaised_;
        weiRaised_ = weiRaised_ + _userEthIn;
        
        // egg to buyer
        eggCoin_.transferFrom(eggCoinFundWallet_, _buyer, _eggToDistribute);
        
        transactions_[_transactionId].eggReceived = _eggToDistribute;
        transactions_[_transactionId].exchangeRate = _ethToUsdRate;
        
        // send pre sale funding to official wallet
        wallet_.transfer(_userEthIn);
        
        // egg distribution fee to owner.
        owner_.transfer(_fee);
        
        transactions_[_transactionId].eggDistributed = true;
        
        emit EggDistribute(
            _transactionId,
            _eggToDistribute,
            _buyer
        );
    }
    
    function calculateFee(
        uint256 _ethToUsdRate
    )
        pure
        internal
        returns(uint256)
    {
        // confiscating 0.03 USD from user as fee.
        uint256 _fee = 30000000000000000000 / (_ethToUsdRate);
        return _fee;
    }
    
    function getTransaction(
        uint256 transactionId    
    )
        view
        public
        returns(
            uint256,
            address,
            bool,
            uint256,
            uint256
        )
    {
        uint256 _transactionId = transactionId;
        return (
            transactions_[_transactionId].ethIn,
            transactions_[_transactionId].buyer,
            transactions_[_transactionId].eggDistributed,
            transactions_[_transactionId].blockNumber,
            transactions_[_transactionId].exchangeRate
        );
    }
    
    function getWeiRaised()
        view
        public
        returns
        (uint256)
    {
        return weiRaised_;
    }
    
    function getUsdRaised()
        view
        public
        returns
        (uint256)
    {
        return usdRaised_;
    }
   
    /**
     *    ___                                            _       
     *   /___\__      ___ __   ___ _ __       ___  _ __ | |_   _ 
     *  //  //\ \ /\ / / '_ \ / _ \ '__|____ / _ \| '_ \| | | | |
     * / \_//  \ V  V /| | | |  __/ | |_____| (_) | | | | | |_| |
     * \___/    \_/\_/ |_| |_|\___|_|        \___/|_| |_|_|\__, |
     *                                                     |___/ 
     * */
     
    function addWhiteListManager(
        address _address
    ) 
        onlyOwner(msg.sender)
        public
    {
        whiteListManager_[_address] = true;
    }
    
    function removeWhiteListManager(
        address _address
    )
        onlyOwner(msg.sender)
        public
    {
        whiteListManager_[_address] = false;
    }
    
    /**
     *  __    __ _     _ _         __ _     _                                                       _       
     * / / /\ \ \ |__ (_) |_ ___  / /(_)___| |_  /\/\   __ _ _ __   __ _  ___ _ __       ___  _ __ | |_   _ 
     * \ \/  \/ / '_ \| | __/ _ \/ / | / __| __|/    \ / _` | '_ \ / _` |/ _ \ '__|____ / _ \| '_ \| | | | |
     *  \  /\  /| | | | | ||  __/ /__| \__ \ |_/ /\/\ \ (_| | | | | (_| |  __/ | |_____| (_) | | | | | |_| |
     *   \/  \/ |_| |_|_|\__\___\____/_|___/\__\/    \/\__,_|_| |_|\__, |\___|_|        \___/|_| |_|_|\__, |
     *                                                             |___/                              |___/ 
     * */
    
    function addBuyerToWhiteList(
        address _address
    )
        onlyWhiteListManager(msg.sender)
        public
    {
        whiteList_[_address] = true;
        emit addToWhiteList(_address);
    }
    
    function removeBuyerFromWhiteList(
        address _address
    )
        onlyWhiteListManager(msg.sender)
        public
    {
        whiteList_[_address] = false;
        emit removeFromWhiteList(_address);
    }
     
    /**
     *  __ _                   _                  
     * / _\ |_ _ __ _   _  ___| |_ _   _ _ __ ___ 
     * \ \| __| '__| | | |/ __| __| | | | '__/ _ \
     * _\ \ |_| |  | |_| | (__| |_| |_| | | |  __/
     * \__/\__|_|   \__,_|\___|\__|\__,_|_|  \___|
     */
     
    struct transaction
    {
        uint256 ethIn;
        uint256 eggReceived;
        address buyer;
        bool eggDistributed;
        uint256 blockNumber;
        uint256 exchangeRate;
    }
}
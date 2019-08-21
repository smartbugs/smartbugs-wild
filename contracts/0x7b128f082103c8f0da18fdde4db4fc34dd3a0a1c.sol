pragma solidity ^0.4.25;
 
/**
*
*  https://fairdapp.com/crash/  https://fairdapp.com/crash/   https://fairdapp.com/crash/
*
*
*        _______     _       ______  _______ ______ ______  
*       (_______)   (_)     (______)(_______|_____ (_____ \ 
*        _____ _____ _  ____ _     _ _______ _____) )____) )
*       |  ___|____ | |/ ___) |   | |  ___  |  ____/  ____/ 
*       | |   / ___ | | |   | |__/ /| |   | | |    | |      
*       |_|   \_____|_|_|   |_____/ |_|   |_|_|    |_|
*       
*        ______       ______     _______                  _     
*       (_____ \     (_____ \   (_______)                | |    
*        _____) )   _ _____) )   _        ____ _____  ___| |__  
*       |  ____/ | | |  ____/   | |      / ___|____ |/___)  _ \ 
*       | |     \ V /| |        | |_____| |   / ___ |___ | | | |
*       |_|      \_/ |_|         \______)_|   \_____(___/|_| |_|
*                                                        
*   
*  Warning: 
*
*  This contract is intented for entertainment purpose only.
*  All could be lost by sending anything to this contract address. 
*  All users are prohibited to interact with this contract if this 
*  contract is in conflict with user’s local regulations or laws.   
*  
*  -Just another unique concept by the FairDAPP community.
*  -The FIRST PvP Crash game ever created!  
*
*/

contract FairExchange{
    function balanceOf(address _customerAddress) public view returns(uint256);
    function myTokens() public view returns(uint256);
    function transfer(address _toAddress, uint256 _amountOfTokens) public returns(bool);
}

contract PvPCrash {
 
    using SafeMath for uint256;
    
    /**
     * @dev Modifiers
     */
 
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier gasMin() {
        require(gasleft() >= gasLimit);
        require(tx.gasprice <= gasPriceLimit);
        _;
    }
    
    modifier isHuman() {
        address _customerAddress = msg.sender;
        if (_customerAddress != address(fairExchangeContract)){
            require(_customerAddress == tx.origin);
            _;
        }
    }
    
    event Invest(address investor, uint256 amount);
    event Withdraw(address investor, uint256 amount);
    
    event FairTokenBuy(uint256 indexed ethereum, uint256 indexed tokens);
    event FairTokenTransfer(address indexed userAddress, uint256 indexed tokens, uint256 indexed roundCount);
    event FairTokenFallback(address indexed userAddress, uint256 indexed tokens, bytes indexed data);

 
    mapping(address => mapping (uint256 => uint256)) public investments;
    mapping(address => mapping (uint256 => uint256)) public joined;
    mapping(address => uint256) public userInputAmount;
    mapping(uint256 => uint256) public roundStartTime;
    mapping(uint256 => uint256) public roundEndTime;
    mapping(uint256 => uint256) public withdrawBlock;
    
    bool public gameOpen;
    bool public roundEnded;
    uint256 public roundCount = 1;
    uint256 public startCoolDown = 5 minutes;
    uint256 public endCoolDown = 5 minutes;
    uint256 public minimum = 10 finney;
    uint256 public maximum = 5 ether;
    uint256 public maxNumBlock = 3;
    uint256 public refundRatio = 50;
    uint256 public gasPriceLimit = 25000000000;
    uint256 public gasLimit = 300000;
    
    address constant public owner = 0xbC817A495f0114755Da5305c5AA84fc5ca7ebaBd;
    
    FairExchange constant private fairExchangeContract = FairExchange(0xdE2b11b71AD892Ac3e47ce99D107788d65fE764e);

    PvPCrashFormula constant private pvpCrashFormula = PvPCrashFormula(0xe3c518815fE5f1e970F8fC5F2eFFcF2871be5C4d);
    

    /**
     * @dev Сonstructor Sets the original roles of the contract
     */
 
    constructor() 
        public 
    {
        roundStartTime[roundCount] = now + startCoolDown;
        gameOpen = true;
    }
    
    function setGameOpen() 
        onlyOwner
        public  
    {
        if (gameOpen) {
            require(roundEnded);
            gameOpen = false;
        } else
            gameOpen = true;
    }
    
    function setMinimum(uint256 _minimum) 
        onlyOwner
        public  
    {
        require(_minimum < maximum);
        minimum = _minimum;
    }
    
    function setMaximum(uint256 _maximum) 
        onlyOwner
        public  
    {
        require(_maximum > minimum);
        maximum = _maximum;
    }
    
    function setRefundRatio(uint256 _refundRatio) 
        onlyOwner
        public 
    {
        require(_refundRatio <= 100);
        refundRatio = _refundRatio;
    }
    
    function setGasLimit(uint256 _gasLimit) 
        onlyOwner
        public 
    {
        require(_gasLimit >= 200000);
        gasLimit = _gasLimit;
    }
    
    function setGasPrice(uint256 _gasPrice) 
        onlyOwner
        public 
    {
        require(_gasPrice >= 1000000000);
        gasPriceLimit = _gasPrice;
    }
    
    function setStartCoolDown(uint256 _coolDown) 
        onlyOwner
        public 
    {
        require(!gameOpen);
        startCoolDown = _coolDown;
    }
    
    function setEndCoolDown(uint256 _coolDown) 
        onlyOwner
        public 
    {
        require(!gameOpen);
        endCoolDown = _coolDown;
    }
    
    function setMaxNumBlock(uint256 _maxNumBlock) 
        onlyOwner
        public 
    {
        require(!gameOpen);
        maxNumBlock = _maxNumBlock;
    }
    
    function transferFairTokens() 
        onlyOwner
        public  
    {
        fairExchangeContract.transfer(owner, fairExchangeContract.myTokens());
    }
    
    function tokenFallback(address _from, uint256 _amountOfTokens, bytes _data) 
        public 
        returns (bool)
    {
        require(msg.sender == address(fairExchangeContract));
        emit FairTokenFallback(_from, _amountOfTokens, _data);
    }
 
    /**
     * @dev Investments
     */
    function ()
        // gameStarted
        isHuman
        payable
        public
    {
        buy();
    }

    function buy()
        private
    {
        address _user = msg.sender;
        uint256 _amount = msg.value;
        uint256 _roundCount = roundCount;
        uint256 _currentTimestamp = now;
        uint256 _startCoolDown = startCoolDown;
        uint256 _endCoolDown = endCoolDown;
        require(gameOpen);
        require(_amount >= minimum);
        require(_amount <= maximum);
        
        if (roundEnded == true && _currentTimestamp > roundEndTime[_roundCount] + _endCoolDown) {
            roundEnded = false;
            roundCount++;
            _roundCount = roundCount;
            roundStartTime[_roundCount] = _currentTimestamp + _startCoolDown;
            
        } else if (roundEnded) {
            require(_currentTimestamp > roundEndTime[_roundCount] + _endCoolDown);
        }

        require(investments[_user][_roundCount] == 0);
        if (!roundEnded) {
            if (_currentTimestamp >= roundStartTime[_roundCount].sub(_startCoolDown)
                && _currentTimestamp < roundStartTime[_roundCount]
            ) {
                joined[_user][_roundCount] = roundStartTime[_roundCount];
            }else if(_currentTimestamp >= roundStartTime[_roundCount]){
                joined[_user][_roundCount] = block.timestamp;
            }
            investments[_user][_roundCount] = _amount;
            userInputAmount[_user] = userInputAmount[_user].add(_amount);
            bool _status = address(fairExchangeContract).call.value(_amount / 20).gas(1000000)();
            require(_status);
            emit FairTokenBuy(_amount / 20, myTokens());
            emit Invest(_user, _amount);
        }
        
    }
    
    /**
    * @dev Withdraw dividends from contract
    */
    function withdraw() 
        gasMin
        isHuman 
        public 
        returns (bool) 
    {
        address _user = msg.sender;
        uint256 _roundCount = roundCount;
        uint256 _currentTimestamp = now;
        
        require(joined[_user][_roundCount] > 0);
        require(_currentTimestamp >= roundStartTime[_roundCount]);
        if (roundEndTime[_roundCount] > 0)
            require(_currentTimestamp <= roundEndTime[_roundCount] + endCoolDown);
        
        uint256 _userBalance;
        uint256 _balance = address(this).balance;
        uint256 _totalTokens = fairExchangeContract.myTokens();
        uint256 _tokens;
        uint256 _tokensTransferRatio;
        if (!roundEnded && withdrawBlock[block.number] <= maxNumBlock) {
            _userBalance = getBalance(_user);
            joined[_user][_roundCount] = 0;
            withdrawBlock[block.number]++;
            
            if (_balance > _userBalance) {
                if (_userBalance > 0) {
                    _user.transfer(_userBalance);
                    emit Withdraw(_user, _userBalance);
                }
                return true;
            } else {
                if (_userBalance > 0) {
                    _user.transfer(_balance);
                    if (investments[_user][_roundCount].mul(95).div(100) > _balance) {
                        
                        _tokensTransferRatio = investments[_user][_roundCount] / 0.01 ether * 2;
                        _tokensTransferRatio = _tokensTransferRatio > 20000 ? 20000 : _tokensTransferRatio;
                        _tokens = _totalTokens
                            .mul(_tokensTransferRatio) / 100000;
                        fairExchangeContract.transfer(_user, _tokens);
                        emit FairTokenTransfer(_user, _tokens, _roundCount);
                    }
                    roundEnded = true;
                    roundEndTime[_roundCount] = _currentTimestamp;
                    emit Withdraw(_user, _balance);
                }
                return true;
            }
        } else {
            
            if (!roundEnded) {
                _userBalance = investments[_user][_roundCount].mul(refundRatio).div(100);
                if (_balance > _userBalance) {
                    _user.transfer(_userBalance);
                    emit Withdraw(_user, _userBalance);
                } else {
                    _user.transfer(_balance);
                    roundEnded = true;
                    roundEndTime[_roundCount] = _currentTimestamp;
                    emit Withdraw(_user, _balance);
                }
            }
            _tokensTransferRatio = investments[_user][_roundCount] / 0.01 ether * 2;
            _tokensTransferRatio = _tokensTransferRatio > 20000 ? 20000 : _tokensTransferRatio;
            _tokens = _totalTokens
                .mul(_tokensTransferRatio) / 100000;
            fairExchangeContract.transfer(_user, _tokens);
            joined[_user][_roundCount] = 0;
            emit FairTokenTransfer(_user, _tokens, _roundCount);
        }
        return true;
    }
    
    /**
    * @dev Evaluate current balance
    * @param _address Address of player
    */
    function getBalance(address _address) 
        view 
        public 
        returns (uint256) 
    {
        uint256 _roundCount = roundCount;
        return pvpCrashFormula.getBalance(
            roundStartTime[_roundCount], 
            joined[_address][_roundCount],
            investments[_address][_roundCount],
            userInputAmount[_address],
            fairExchangeContract.balanceOf(_address)
        );
    }
    
    function getAdditionalRewardRatio(address _address) 
        view 
        public 
        returns (uint256) 
    {
        return pvpCrashFormula.getAdditionalRewardRatio(
            userInputAmount[_address],
            fairExchangeContract.balanceOf(_address)
        );
    }
    
    /**
    * @dev Gets balance of the sender address.
    * @return An uint256 representing the amount owned by the msg.sender.
    */
    function checkBalance() 
        view
        public  
        returns (uint256) 
    {
        return getBalance(msg.sender);
    }

    /**
    * @dev Gets investments of the specified address.
    * @param _investor The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function checkInvestments(address _investor) 
        view
        public  
        returns (uint256) 
    {
        return investments[_investor][roundCount];
    }
    
    function getFairTokensBalance(address _address) 
        view 
        public 
        returns (uint256) 
    {
        return fairExchangeContract.balanceOf(_address);
    }
    
    function myTokens() 
        view 
        public 
        returns (uint256) 
    {
        return fairExchangeContract.myTokens();
    }
    
}

interface PvPCrashFormula {
    function getBalance(uint256 _roundStartTime, uint256 _joinedTime, uint256 _amount, uint256 _totalAmount, uint256 _tokens) external view returns(uint256);
    function getAdditionalRewardRatio(uint256 _totalAmount, uint256 _tokens) external view returns(uint256);
}
 
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
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
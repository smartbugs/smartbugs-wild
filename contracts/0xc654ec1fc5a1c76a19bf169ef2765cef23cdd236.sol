pragma solidity ^0.4.18;

contract AbstractToken {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
    function totalSupply() public constant returns (uint256) {}
    function balanceOf(address owner) public constant returns (uint256 balance);
    function transfer(address to, uint256 value) public returns (bool success);
    function transferFrom(address from, address to, uint256 value) public returns (bool success);
    function approve(address spender, uint256 value) public returns (bool success);
    function allowance(address owner, address spender) public constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
  function mul(uint256 a, uint256 b) constant internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) constant internal returns (uint256) {
    assert(b != 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) constant internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) constant internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mulByFraction(uint256 number, uint256 numerator, uint256 denominator) internal returns (uint256) {
      return div(mul(number, numerator), denominator);
  }
}

contract PreIco is SafeMath {
    /*
     * PreIco meta data
     */
    string public constant name = "Remechain Presale Token";
    string public constant symbol = "iRMC";
    uint public constant decimals = 18;

    // addresses of managers
    address public manager;
    address public reserveManager;
    // addresses of escrows
    address public escrow;
    address public reserveEscrow;

    // BASE = 10^18
    uint constant BASE = 1000000000000000000;

    // amount of supplied tokens
    uint public tokensSupplied = 0;
    // amount of supplied bounty reward
    uint public bountySupplied = 0;
    // Soft capacity = 6250 ETH
    uint public constant SOFT_CAPACITY = 2000000 * BASE;
    // Hard capacity = 18750 ETH
    uint public constant TOKENS_SUPPLY = 6000000 * BASE;
    // Amount of bounty reward
    uint public constant BOUNTY_SUPPLY = 350000 * BASE;
    // Total supply
    uint public constant totalSupply = TOKENS_SUPPLY + BOUNTY_SUPPLY;

    // 1 RMC = 0.003125 ETH for  600 000 000 RMC

    uint public constant TOKEN_PRICE = 3125000000000000;
    uint tokenAmount1 = 6000000 * BASE;

    uint tokenPriceMultiply1 = 1;
    uint tokenPriceDivide1 = 1;

    uint[] public tokenPriceMultiplies;
    uint[] public tokenPriceDivides;
    uint[] public tokenAmounts;

    // ETH balances of accounts
    mapping(address => uint) public ethBalances;
    uint[] public prices;
    uint[] public amounts;

    mapping(address => uint) private balances;

    // 2018.02.25 17:00 MSK
    uint public constant defaultDeadline = 1519567200;
    uint public deadline = defaultDeadline;

    // Is ICO frozen
    bool public isIcoStopped = false;

    // Addresses of allowed tokens for buying
    address[] public allowedTokens;
    // Amount of token
    mapping(address => uint) public tokenAmount;
    // Price of current token amount
    mapping(address => uint) public tokenPrice;

    // Full users list
    address[] public usersList;
    mapping(address => bool) isUserInList;
    // Number of users that have returned their money
    uint numberOfUsersReturned = 0;

    // user => token[]
    mapping(address => address[]) public userTokens;
    //  user => token => amount
    mapping(address => mapping(address => uint)) public userTokensValues;

    /*
     * Events
     */

    event BuyTokens(address indexed _user, uint _ethValue, uint _boughtTokens);
    event BuyTokensWithTokens(address indexed _user, address indexed _token, uint _tokenValue, uint _boughtTokens);
    event GiveReward(address indexed _to, uint _value);

    event IcoStoppedManually();
    event IcoRunnedManually();

    event WithdrawEther(address indexed _escrow, uint _ethValue);
    event WithdrawToken(address indexed _escrow, address indexed _token, uint _value);
    event ReturnEthersFor(address indexed _user, uint _value);
    event ReturnTokensFor(address indexed _user, address indexed _token, uint _value);

    event AddToken(address indexed _token, uint _amount, uint _price);
    event RemoveToken(address indexed _token);

    event MoveTokens(address indexed _from, address indexed _to, uint _value);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    /*
     * Modifiers
     */

    modifier onlyManager {
        assert(msg.sender == manager || msg.sender == reserveManager);
        _;
    }
    modifier onlyManagerOrContract {
        assert(msg.sender == manager || msg.sender == reserveManager || msg.sender == address(this));
        _;
    }
    modifier IcoIsActive {
        assert(isIcoActive());
        _;
    }


    /// @dev Constructor of PreIco.
    /// @param _manager Address of manager
    /// @param _reserveManager Address of reserve manager
    /// @param _escrow Address of escrow
    /// @param _reserveEscrow Address of reserve escrow
    /// @param _deadline ICO deadline timestamp. If is 0, sets 1515679200
    function PreIco(address _manager, address _reserveManager, address _escrow, address _reserveEscrow, uint _deadline) public {
        assert(_manager != 0x0);
        assert(_reserveManager != 0x0);
        assert(_escrow != 0x0);
        assert(_reserveEscrow != 0x0);

        manager = _manager;
        reserveManager = _reserveManager;
        escrow = _escrow;
        reserveEscrow = _reserveEscrow;

        if (_deadline != 0) {
            deadline = _deadline;
        }
        tokenPriceMultiplies.push(tokenPriceMultiply1);
        tokenPriceDivides.push(tokenPriceDivide1);
        tokenAmounts.push(tokenAmount1);
    }

    /// @dev Returns token balance of user. 1 token = 1/10^18 RMC
    /// @param _user Address of user
    function balanceOf(address _user) public returns(uint balance) {
        return balances[_user];
    }

    /// @dev Returns, is ICO enabled
    function isIcoActive() public returns(bool isActive) {
        return !isIcoStopped && now < deadline;
    }

    /// @dev Returns, is SoftCap reached
    function isIcoSuccessful() public returns(bool isSuccessful) {
        return tokensSupplied >= SOFT_CAPACITY;
    }

    /// @dev Calculates number of tokens RMC for buying with custom price of token
    /// @param _amountOfToken Amount of RMC token
    /// @param _priceAmountOfToken Price of amount of RMC
    /// @param _value Amount of custom token
    function getTokensAmount(uint _amountOfToken, uint _priceAmountOfToken,  uint _value) private returns(uint tokensToBuy) {
        uint currentStep;
        uint tokensRemoved = tokensSupplied;
        for (currentStep = 0; currentStep < tokenAmounts.length; currentStep++) {
            if (tokensRemoved >= tokenAmounts[currentStep]) {
                tokensRemoved -= tokenAmounts[currentStep];
            } else {
                break;
            }
        }
        assert(currentStep < tokenAmounts.length);

        uint result = 0;

        for (; currentStep <= tokenAmounts.length; currentStep++) {
            assert(currentStep < tokenAmounts.length);

            uint tokenOnStepLeft = tokenAmounts[currentStep] - tokensRemoved;
            tokensRemoved = 0;
            uint howManyTokensCanBuy = _value
                    * _amountOfToken / _priceAmountOfToken
                    * tokenPriceDivides[currentStep] / tokenPriceMultiplies[currentStep];

            if (howManyTokensCanBuy > tokenOnStepLeft) {
                result = add(result, tokenOnStepLeft);
                uint spent = tokenOnStepLeft
                    * _priceAmountOfToken / _amountOfToken
                    * tokenPriceMultiplies[currentStep] / tokenPriceDivides[currentStep];
                if (_value <= spent) {
                    break;
                }
                _value -= spent;
                tokensRemoved = 0;
            } else {
                result = add(result, howManyTokensCanBuy);
                break;
            }
        }

        return result;
    }

    /// @dev Calculates number of tokens RMC for buying with ETH
    /// @param _value Amount of ETH token
    function getTokensAmountWithEth(uint _value) private returns(uint tokensToBuy) {
        return getTokensAmount(BASE, TOKEN_PRICE, _value);
    }

    /// @dev Calculates number of tokens RMC for buying with ERC-20 token
    /// @param _token Address of ERC-20 token
    /// @param _tokenValue Amount of ETH token
    function getTokensAmountByTokens(address _token, uint _tokenValue) private returns(uint tokensToBuy) {
        assert(tokenPrice[_token] > 0);
        return getTokensAmount(tokenPrice[_token], tokenAmount[_token], _tokenValue);
    }

    /// @dev Solds tokens for user by ETH
    /// @param _user Address of user which buys token
    /// @param _value Amount of ETH. 1 _value = 1/10^18 ETH
    function buyTokens(address _user, uint _value) private IcoIsActive {
        uint boughtTokens = getTokensAmountWithEth(_value);
        burnTokens(boughtTokens);

        balances[_user] = add(balances[_user], boughtTokens);
        addUserToList(_user);
        BuyTokens(_user, _value, boughtTokens);
    }

    /// @dev Makes ERC-20 token sellable
    /// @param _token Address of ERC-20 token
    /// @param _amount Amount of current token
    /// @param _price Price of _amount of token
    function addToken(address _token, uint _amount, uint _price) onlyManager public {
        assert(_token != 0x0);
        assert(_amount > 0);
        assert(_price > 0);

        bool isNewToken = true;
        for (uint i = 0; i < allowedTokens.length; i++) {
            if (allowedTokens[i] == _token) {
                isNewToken = false;
                break;
            }
        }
        if (isNewToken) {
            allowedTokens.push(_token);
        }

        tokenPrice[_token] = _price;
        tokenAmount[_token] = _amount;
    }

    /// @dev Makes ERC-20 token not sellable
    /// @param _token Address of ERC-20 token
    function removeToken(address _token) onlyManager public {
        for (uint i = 0; i < allowedTokens.length; i++) {
            if (_token == allowedTokens[i]) {
                if (i < allowedTokens.length - 1) {
                    allowedTokens[i] = allowedTokens[allowedTokens.length - 1];
                }
                allowedTokens[allowedTokens.length - 1] = 0x0;
                allowedTokens.length--;
                break;
            }
        }

        tokenPrice[_token] = 0;
        tokenAmount[_token] = 0;
    }

    /// @dev add user to usersList
    /// @param _user Address of user
    function addUserToList(address _user) private {
        if (!isUserInList[_user]) {
            isUserInList[_user] = true;
            usersList.push(_user);
        }
    }

    /// @dev Makes amount of tokens not purchasable
    /// @param _amount Amount of RMC tokens
    function burnTokens(uint _amount) private {
        assert(add(tokensSupplied, _amount) <= TOKENS_SUPPLY);
        tokensSupplied = add(tokensSupplied, _amount);
    }

    /// @dev Takes ERC-20 tokens approved by user for using and gives him RMC tokens
    /// @param _token Address of ERC-20 token
    function buyWithTokens(address _token) public {
        buyWithTokensBy(msg.sender, _token);
    }

    /// @dev Takes ERC-20 tokens approved by user for using and gives him RMC tokens. Can be called by anyone
    /// @param _user Address of user
    /// @param _token Address of ERC-20 token
    function buyWithTokensBy(address _user, address _token) public IcoIsActive {
        // Checks whether the token is allowed
        assert(tokenPrice[_token] > 0);

        AbstractToken token = AbstractToken(_token);
        uint tokensToSend = token.allowance(_user, address(this));
        assert(tokensToSend > 0);

        uint boughtTokens = getTokensAmountByTokens(_token, tokensToSend);
        burnTokens(boughtTokens);
        balances[_user] = add(balances[_user], boughtTokens);

        uint prevBalance = token.balanceOf(address(this));
        assert(token.transferFrom(_user, address(this), tokensToSend));
        assert(token.balanceOf(address(this)) - prevBalance == tokensToSend);

        userTokensValues[_user][_token] = add(userTokensValues[_user][_token], tokensToSend);

        addTokenToUser(_user, _token);
        addUserToList(_user);
        BuyTokensWithTokens(_user, _token, tokensToSend, boughtTokens);
    }

    /// @dev Makes amount of tokens returnable for user. If _buyTokens equals true, buy tokens
    /// @param _user Address of user
    /// @param _token Address of ERC-20 token
    /// @param _tokenValue Amount of ERC-20 token
    /// @param _buyTokens If true, buys tokens for this sum
    function addTokensToReturn(address _user, address _token, uint _tokenValue, bool _buyTokens) public onlyManager {
        // Checks whether the token is allowed
        assert(tokenPrice[_token] > 0);

        if (_buyTokens) {
            uint boughtTokens = getTokensAmountByTokens(_token, _tokenValue);
            burnTokens(boughtTokens);
            balances[_user] = add(balances[_user], boughtTokens);
            BuyTokensWithTokens(_user, _token, _tokenValue, boughtTokens);
        }

        userTokensValues[_user][_token] = add(userTokensValues[_user][_token], _tokenValue);
        addTokenToUser(_user, _token);
        addUserToList(_user);
    }


    /// @dev Adds ERC-20 tokens to user's token list
    /// @param _user Address of user
    /// @param _token Address of ERC-20 token
    function addTokenToUser(address _user, address _token) private {
        for (uint i = 0; i < userTokens[_user].length; i++) {
            if (userTokens[_user][i] == _token) {
                return;
            }
        }
        userTokens[_user].push(_token);
    }

    /// @dev Returns ether and tokens to user. Can be called only if ICO is ended and SoftCap is not reached
    function returnFunds() public {
        assert(!isIcoSuccessful() && !isIcoActive());

        returnFundsFor(msg.sender);
    }

    /// @dev Moves tokens from one user to another. Can be called only by manager. This function added for users that send ether by stock exchanges
    function moveIcoTokens(address _from, address _to, uint _value) public onlyManager {
        balances[_from] = sub(balances[_from], _value);
        balances[_to] = add(balances[_to], _value);

        MoveTokens(_from, _to, _value);
    }

    /// @dev Returns ether and tokens to user. Can be called only by manager or contract
    /// @param _user Address of user
    function returnFundsFor(address _user) public onlyManagerOrContract returns(bool) {
        if (ethBalances[_user] > 0) {
            if (_user.send(ethBalances[_user])) {
                ReturnEthersFor(_user, ethBalances[_user]);
                ethBalances[_user] = 0;
            }
        }

        for (uint i = 0; i < userTokens[_user].length; i++) {
            address tokenAddress = userTokens[_user][i];
            uint userTokenValue = userTokensValues[_user][tokenAddress];
            if (userTokenValue > 0) {
                AbstractToken token = AbstractToken(tokenAddress);
                if (token.transfer(_user, userTokenValue)) {
                    ReturnTokensFor(_user, tokenAddress, userTokenValue);
                    userTokensValues[_user][tokenAddress] = 0;
                }
            }
        }

        balances[_user] = 0;
    }

    /// @dev Returns ether and tokens to list of users. Can be called only by manager
    /// @param _users Array of addresses of users
    function returnFundsForMultiple(address[] _users) public onlyManager {
        for (uint i = 0; i < _users.length; i++) {
            returnFundsFor(_users[i]);
        }
    }

    /// @dev Returns ether and tokens to 50 users. Can be called only by manager
    function returnFundsForAll() public onlyManager {
        assert(!isIcoActive() && !isIcoSuccessful());

        uint first = numberOfUsersReturned;
        uint last  = (first + 50 < usersList.length) ? first + 50 : usersList.length;

        for (uint i = first; i < last; i++) {
            returnFundsFor(usersList[i]);
        }

        numberOfUsersReturned = last;
    }

    /// @dev Withdraws ether and tokens to _escrow if SoftCap is reached
    /// @param _escrow Address of escrow
    function withdrawEtherTo(address _escrow) private {
        assert(isIcoSuccessful());

        if (this.balance > 0) {
            if (_escrow.send(this.balance)) {
                WithdrawEther(_escrow, this.balance);
            }
        }

        for (uint i = 0; i < allowedTokens.length; i++) {
            AbstractToken token = AbstractToken(allowedTokens[i]);
            uint tokenBalance = token.balanceOf(address(this));
            if (tokenBalance > 0) {
                if (token.transfer(_escrow, tokenBalance)) {
                    WithdrawToken(_escrow, address(token), tokenBalance);
                }
            }
        }
    }

    /// @dev Withdraw ether and tokens to escrow. Can be called only by manager
    function withdrawEther() public onlyManager {
        withdrawEtherTo(escrow);
    }

    /// @dev Withdraw ether and tokens to reserve escrow. Can be called only by manager
    function withdrawEtherToReserveEscrow() public onlyManager {
        withdrawEtherTo(reserveEscrow);
    }

    /// @dev Enables disabled ICO. Can be called only by manager
    function runIco() public onlyManager {
        assert(isIcoStopped);
        isIcoStopped = false;
        IcoRunnedManually();
    }

    /// @dev Disables ICO. Can be called only by manager
    function stopIco() public onlyManager {
        isIcoStopped = true;
        IcoStoppedManually();
    }

    /// @dev Fallback function. Buy RMC tokens on sending ether
    function () public payable {
        buyTokens(msg.sender, msg.value);
    }

    /// @dev Gives bounty reward to user. Can be called only by manager
    /// @param _to Address of user
    /// @param _amount Amount of bounty
    function giveReward(address _to, uint _amount) public onlyManager {
        assert(_to != 0x0);
        assert(_amount > 0);
        assert(add(bountySupplied, _amount) <= BOUNTY_SUPPLY);

        bountySupplied = add(bountySupplied, _amount);
        balances[_to] = add(balances[_to], _amount);

        GiveReward(_to, _amount);
    }

    /// Adds other ERC-20 functions
    function transfer(address _to, uint _value) public returns (bool success) {
        return false;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        return false;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        return false;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return 0;
    }
}
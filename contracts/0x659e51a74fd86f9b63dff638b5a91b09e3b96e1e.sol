pragma solidity ^0.4.18;

/*************************/
/* Blocksquare Seed Sale */
/*************************/

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
    uint256 c = a / b;
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

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function tranferOwnership(address _newOwner) public onlyOwner() {
        owner = _newOwner;
    }
}

contract Token {
    function mintTokens(address _atAddress, uint256 _amount) public;
}

/****************************************/
/* BLOCKSQUARE SEED SALE IMPLEMENTATION */
/****************************************/

contract BlocksquareSeedSale is owned {
    using SafeMath for uint256;

    /** Events **/
    event Received(address indexed _from, uint256 _amount);
    event FundsReturned(address indexed _to, uint256 _amount);
    event TokensGiven(address indexed _to, uint256 _amount);
    event ErrorReturningEth(address _to, uint256 _amount);

    /** Public variables **/
    uint256 public currentAmountRaised;
    uint256 public valueInUSD;
    uint256 public startTime;
    address public recipient;

    /** Private variables **/
    uint256 nextParticipantIndex;
    uint256 currentAmountOfTokens;
    bool icoHasStarted;
    bool icoHasClosed;
    Token reward;

    /** Constants **/
    uint256[] tokensInTranch = [250000 * 10**18, 500000 * 10**18, 1000000 * 10**18, 1500000 * 10**18, 2000000 * 10**18, 3000000 * 10**18, 4000000 * 10**18, 5500000 * 10**18, 7000000 * 10**18, 10000000 * 10**18];
    uint256[] priceOfTokenInUSD = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    uint256 maxAmountOfTokens = 10000000 * 10 ** 18;
    uint256 DAY = 60 * 60 * 24;
    uint256 MAXIMUM = 152 ether;
    uint256 MAXIMUM24H = 2 ether;

    /** Mappings **/
    mapping(address => uint256) contributed;
    mapping(uint256 => address) participantIndex;
    mapping(address => bool) canRecieveTokens;

    /**
    * Constructor function
    *
    * Initializes contract.
    **/
    function BlocksquareSeedSale() public {
        owner = msg.sender;
        recipient = msg.sender;
        reward = Token(0x509A38b7a1cC0dcd83Aa9d06214663D9eC7c7F4a);
    }

    /**
    * Basic payment
    *
    *
    **/
    function () payable public {
        require(reward != address(0));
        require(msg.value > 0);
        require(icoHasStarted);
        require(!icoHasClosed);
        require(valueInUSD != 0);
        require(canRecieveTokens[msg.sender]);
        if(block.timestamp < startTime.add(DAY)) {
            require(contributed[msg.sender].add(msg.value) <= MAXIMUM24H);
        }
        else {
            require(contributed[msg.sender].add(msg.value) <= MAXIMUM);
        }

        if(contributed[msg.sender] == 0) {
            participantIndex[nextParticipantIndex] = msg.sender;
            nextParticipantIndex += 1;
        }

        contributed[msg.sender] = contributed[msg.sender].add(msg.value);
        currentAmountRaised = currentAmountRaised.add(msg.value);
        uint256 tokens = tokensToMint(msg.value);

        if(currentAmountOfTokens.add(tokens) >= maxAmountOfTokens) {
            icoHasClosed = true;
        }

        reward.mintTokens(msg.sender, tokens);
        currentAmountOfTokens = currentAmountOfTokens.add(tokens);
        Received(msg.sender, msg.value);
        TokensGiven(msg.sender, tokens);

        if(this.balance >= 100 ether) {
            if(!recipient.send(this.balance)) {
                ErrorReturningEth(recipient, this.balance);
            }
        }
    }

    /**
    * Calculate tokens to mint.
    *
    * Calculets how much tokens sender will get based on _amountOfWei he sent.
    *
    * @param _amountOfWei Amount of wei sender has sent to the contract.
    * @return Number of tokens sender will recieve.
    **/
    function tokensToMint(uint256 _amountOfWei) private returns (uint256) {
        uint256 raisedTokens = currentAmountOfTokens;
        uint256 left = _amountOfWei;
        uint256 rewardAmount = 0;
        for(uint8 i = 0; i < tokensInTranch.length; i++) {
            if (tokensInTranch[i] >= raisedTokens) {
                uint256 tokensPerEth = valueInUSD.div(priceOfTokenInUSD[i]);
                uint256 tokensLeft = tokensPerEth.mul(left);
                if((raisedTokens.add(tokensLeft)) <= tokensInTranch[i]) {
                    rewardAmount = rewardAmount.add(tokensLeft);
                    left = 0;
                    break;
                }
                else {
                    uint256 toNext = tokensInTranch[i].sub(raisedTokens);
                    uint256 WeiCost = toNext.div(tokensPerEth);
                    rewardAmount = rewardAmount.add(toNext);
                    raisedTokens = raisedTokens.add(toNext);
                    left = left.sub(WeiCost);
                }
            }
        }
        if(left != 0) {
            if(msg.sender.send(left)) {
                FundsReturned(msg.sender, left);
                currentAmountRaised = currentAmountRaised.sub(left);
                contributed[msg.sender] = contributed[msg.sender].sub(left);
            }else {
                ErrorReturningEth(msg.sender, left);
            }
        }
        return rewardAmount;
    }

    /**
    * Start Presale
    *
    * Starts presale and sets value of ETH in USD.
    *
    * @param _value Value of ETH in USD.
    **/
    function startICO(uint256 _value) public onlyOwner {
        require(!icoHasStarted);
        valueInUSD = _value;
        startTime = block.timestamp;
        icoHasStarted = true;
    }

    /**
    * Close presale
    *
    * Closes presale.
    **/
    function closeICO() public onlyOwner {
        require(icoHasStarted);
        icoHasClosed = true;
    }

    /**
    * Add to whitelist
    *
    * Adds address to whitelist so they can send ETH.
    *
    * @param _addresses Array of addresses to add to whitelist.
    **/
    function addAllowanceToRecieveToken(address[] _addresses) public onlyOwner {
        for(uint256 i = 0; i < _addresses.length; i++) {
            canRecieveTokens[_addresses[i]] = true;
        }
    }

    /**
    * Withdraw Ether
    *
    * Withdraw Ether from contract.
    **/
    function withdrawEther() public onlyOwner {
        if(!recipient.send(this.balance)) {
            ErrorReturningEth(recipient, this.balance);
        }
    }

    /** Getters functions for info **/
    function getToken() constant public returns (address _tokenAddress) {
        return address(reward);
    }

    function isCrowdsaleOpen() constant public returns (bool _isOpened) {
        return (!icoHasClosed && icoHasStarted);
    }

    function hasCrowdsaleStarted() constant public returns (bool _hasStarted) {
        return icoHasStarted;
    }

    function amountContributed(address _contributor) constant public returns(uint256 _contributedUntilNow){
        return contributed[_contributor];
    }

    function numberOfContributors() constant public returns(uint256 _numOfContributors){
        return nextParticipantIndex;
    }

    function numberOfTokens() constant public returns(uint256) {
        return currentAmountOfTokens;
    }

    function hasAllowanceToRecieveTokens(address _address) constant public returns(bool) {
        return canRecieveTokens[_address];
    }

    function endOf24H() constant public returns(uint256) {
        return startTime.add(DAY);
    }
}
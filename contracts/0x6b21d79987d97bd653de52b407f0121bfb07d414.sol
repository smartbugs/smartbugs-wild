pragma solidity ^0.4.15;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
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
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract McFlyToken is MintableToken {

    string public constant name = 'McFly';
    string public constant symbol = 'MFL';
    uint8 public constant decimals = 18;

    mapping(address=>bool) whitelist;

    event Burn(address indexed from, uint256 value);
    event AllowTransfer(address from);

    modifier canTransfer() {
        require(mintingFinished || whitelist[msg.sender]);
        _;        
    }

    function allowTransfer(address from) onlyOwner {
        AllowTransfer(from);
        whitelist[from] = true;
    }

    function transferFrom(address from, address to, uint256 value) canTransfer returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function transfer(address to, uint256 value) canTransfer returns (bool) {
        return super.transfer(to, value);
    }

    function burn(address from) onlyOwner returns (bool) {
        Transfer(from, 0x0, balances[from]);
        Burn(from, balances[from]);

        balances[0x0] += balances[from];
        balances[from] = 0;
    }
}

contract MultiOwners {

    event AccessGrant(address indexed owner);
    event AccessRevoke(address indexed owner);
    
    mapping(address => bool) owners;
    address public publisher;


    function MultiOwners() {
        owners[msg.sender] = true;
        publisher = msg.sender;
    }

    modifier onlyOwner() { 
        require(owners[msg.sender] == true);
        _; 
    }

    function isOwner() constant returns (bool) {
        return owners[msg.sender] ? true : false;
    }

    function checkOwner(address maybe_owner) constant returns (bool) {
        return owners[maybe_owner] ? true : false;
    }


    function grant(address _owner) onlyOwner {
        owners[_owner] = true;
        AccessGrant(_owner);
    }

    function revoke(address _owner) onlyOwner {
        require(_owner != publisher);
        require(msg.sender != _owner);

        owners[_owner] = false;
        AccessRevoke(_owner);
    }
}

contract Haltable is MultiOwners {
    bool public halted;

    modifier stopInEmergency {
        require(!halted);
        _;
    }

    modifier onlyInEmergency {
        require(halted);
        _;
    }

    // called by the owner on emergency, triggers stopped state
    function halt() external onlyOwner {
        halted = true;
    }

    // called by the owner on end of emergency, returns to normal state
    function unhalt() external onlyOwner onlyInEmergency {
        halted = false;
    }

}

contract McFlyCrowdsale is MultiOwners, Haltable {
    using SafeMath for uint256;

    // min wei per tx for TLP 1.1
    uint256 public minimalWeiTLP1 = 1e17; // 0.1 ETH
    uint256 public priceTLP1 = 1e14; // 0.0001 ETH

    // min wei per tx for TLP 1.2
    uint256 public minimalWeiTLP2 = 2e17; // 0.2 ETH
    uint256 public priceTLP2 = 2e14; // 0.0002 ETH

    // Total ETH received during WAVES, TLP1.1 and TLP1.2
    uint256 public totalETH;

    // Token
    McFlyToken public token;

    // Withdraw wallet
    address public wallet;

    // start and end timestamp for TLP 1.1, endTimeTLP1 calculate from startTimeTLP1
    uint256 public startTimeTLP1;
    uint256 public endTimeTLP1;
    uint256 daysTLP1 = 12 days;

    // start and end timestamp for TLP 1.2, endTimeTLP2 calculate from startTimeTLP2
    uint256 public startTimeTLP2;
    uint256 public endTimeTLP2;
    uint256 daysTLP2 = 24 days;

    // Percents
    uint256 fundPercents = 15;
    uint256 teamPercents = 10;
    uint256 reservedPercents = 10;
    uint256 bountyOnlinePercents = 2;
    uint256 bountyOfflinePercents = 3;
    uint256 advisoryPercents = 5;
    
    // Cap
    // maximum possible tokens for minting
    uint256 public hardCapInTokens = 1800e24; // 1,800,000,000 MFL

    // maximum possible tokens for sell 
    uint256 public mintCapInTokens = hardCapInTokens.mul(70).div(100); // 1,260,000,000 MFL

    // maximum possible tokens for fund minting
    uint256 public fundTokens = hardCapInTokens.mul(fundPercents).div(100); // 270,000,000 MFL
    uint256 public fundTotalSupply;
    address public fundMintingAgent;

    // Rewards
    // WAVES
    // maximum possible tokens to convert from WAVES
    uint256 public wavesTokens = 100e24; // 100,000,000 MFL
    address public wavesAgent;

    // Team 10%
    uint256 teamVestingPeriodInSeconds = 31 days;
    uint256 teamVestingPeriodsCount = 12;
    uint256 _teamTokens;
    uint256 public teamTotalSupply;
    address public teamWallet;

    // Bounty 5% (2% + 3%)
    // Bounty online 2%
    uint256 _bountyOnlineTokens;
    address public bountyOnlineWallet;

    // Bounty offline 3%
    uint256 _bountyOfflineTokens;
    address public bountyOfflineWallet;

    // Advisory 5%
    uint256 _advisoryTokens;
    address public advisoryWallet;

    // Reserved for future 10%
    uint256 _reservedTokens;
    address public reservedWallet;


    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event TransferOddEther(address indexed beneficiary, uint256 value);
    event FundMinting(address indexed beneficiary, uint256 value);
    event TeamVesting(address indexed beneficiary, uint256 period, uint256 value);
    event SetFundMintingAgent(address new_agent);
    event SetStartTimeTLP1(uint256 new_startTimeTLP1);
    event SetStartTimeTLP2(uint256 new_startTimeTLP2);


    modifier validPurchase() {
        bool nonZeroPurchase = msg.value != 0;
        
        require(withinPeriod() && nonZeroPurchase);

        _;        
    }

    function McFlyCrowdsale(
        uint256 _startTimeTLP1,
        uint256 _startTimeTLP2,
        address _wallet,
        address _wavesAgent,
        address _fundMintingAgent,
        address _teamWallet,
        address _bountyOnlineWallet,
        address _bountyOfflineWallet,
        address _advisoryWallet,
        address _reservedWallet
    ) {
        require(_startTimeTLP1 >= block.timestamp);
        require(_startTimeTLP2 > _startTimeTLP1);
        require(_wallet != 0x0);
        require(_wavesAgent != 0x0);
        require(_fundMintingAgent != 0x0);
        require(_teamWallet != 0x0);
        require(_bountyOnlineWallet != 0x0);
        require(_bountyOfflineWallet != 0x0);
        require(_advisoryWallet != 0x0);
        require(_reservedWallet != 0x0);

        token = new McFlyToken();

        startTimeTLP1 = _startTimeTLP1; 
        endTimeTLP1 = startTimeTLP1.add(daysTLP1);

        require(endTimeTLP1 < _startTimeTLP2);

        startTimeTLP2 = _startTimeTLP2; 
        endTimeTLP2 = startTimeTLP2.add(daysTLP2);

        wavesAgent = _wavesAgent;
        fundMintingAgent = _fundMintingAgent;

        wallet = _wallet;
        teamWallet = _teamWallet;
        bountyOnlineWallet = _bountyOnlineWallet;
        bountyOfflineWallet = _bountyOfflineWallet;
        advisoryWallet = _advisoryWallet;
        reservedWallet = _reservedWallet;

        totalETH = wavesTokens.mul(priceTLP1.mul(65).div(100)).div(1e18); // 6500 for 100,000,000 MFL from WAVES
        token.mint(wavesAgent, wavesTokens);
        token.allowTransfer(wavesAgent);
    }

    function withinPeriod() constant public returns (bool) {
        bool withinPeriodTLP1 = (now >= startTimeTLP1 && now <= endTimeTLP1);
        bool withinPeriodTLP2 = (now >= startTimeTLP2 && now <= endTimeTLP2);
        return withinPeriodTLP1 || withinPeriodTLP2;
    }

    // @return false if crowdsale event was ended
    function running() constant public returns (bool) {
        return withinPeriod() && !token.mintingFinished();
    }

    function teamTokens() constant public returns (uint256) {
        if(_teamTokens > 0) {
            return _teamTokens;
        }
        return token.totalSupply().mul(teamPercents).div(70);
    }

    function bountyOnlineTokens() constant public returns (uint256) {
        if(_bountyOnlineTokens > 0) {
            return _bountyOnlineTokens;
        }
        return token.totalSupply().mul(bountyOnlinePercents).div(70);
    }

    function bountyOfflineTokens() constant public returns (uint256) {
        if(_bountyOfflineTokens > 0) {
            return _bountyOfflineTokens;
        }
        return token.totalSupply().mul(bountyOfflinePercents).div(70);
    }

    function advisoryTokens() constant public returns (uint256) {
        if(_advisoryTokens > 0) {
            return _advisoryTokens;
        }
        return token.totalSupply().mul(advisoryPercents).div(70);
    }

    function reservedTokens() constant public returns (uint256) {
        if(_reservedTokens > 0) {
            return _reservedTokens;
        }
        return token.totalSupply().mul(reservedPercents).div(70);
    }

    // @return current stage name
    function stageName() constant public returns (string) {
        bool beforePeriodTLP1 = (now < startTimeTLP1);
        bool withinPeriodTLP1 = (now >= startTimeTLP1 && now <= endTimeTLP1);
        bool betweenPeriodTLP1andTLP2 = (now >= endTimeTLP1 && now <= startTimeTLP2);
        bool withinPeriodTLP2 = (now >= startTimeTLP2 && now <= endTimeTLP2);

        if(beforePeriodTLP1) {
            return 'Not started';
        }

        if(withinPeriodTLP1) {
            return 'TLP1.1';
        } 

        if(betweenPeriodTLP1andTLP2) {
            return 'Between TLP1.1 and TLP1.2';
        }

        if(withinPeriodTLP2) {
            return 'TLP1.2';
        }

        return 'Finished';
    }

    /*
     * @dev fallback for processing ether
     */
    function() payable {
        return buyTokens(msg.sender);
    }

    /*
     * @dev change agent for waves minting
     * @praram agent - new agent address
     */
    function setFundMintingAgent(address agent) onlyOwner {
        fundMintingAgent = agent;
        SetFundMintingAgent(agent);
    }

    /*
     * @dev set TLP1.2 start date
     * @param _at â new start date
     */
    function setStartTimeTLP2(uint256 _at) onlyOwner {
        require(block.timestamp < startTimeTLP2); // forbid change time when TLP1.2 is active
        require(block.timestamp < _at); // should be great than current block timestamp
        require(endTimeTLP1 < _at); // should be great than end TLP1.1

        startTimeTLP2 = _at;
        endTimeTLP2 = startTimeTLP2.add(daysTLP2);
        SetStartTimeTLP2(_at);
    }

    /*
     * @dev set TLP1.1 start date
     * @param _at - new start date
     */
    function setStartTimeTLP1(uint256 _at) onlyOwner {
        require(block.timestamp < startTimeTLP1); // forbid change time when TLP1.1 is active
        require(block.timestamp < _at); // should be great than current block timestamp

        startTimeTLP1 = _at;
        endTimeTLP1 = startTimeTLP1.add(daysTLP1);
        SetStartTimeTLP1(_at);
    }

    /*
     * @dev Large Token Holder minting 
     * @param to - mint to address
     * @param amount - how much mint
     */
    function fundMinting(address to, uint256 amount) stopInEmergency {
        require(msg.sender == fundMintingAgent || isOwner());
        require(block.timestamp <= startTimeTLP2);
        require(fundTotalSupply + amount <= fundTokens);
        require(token.totalSupply() + amount <= mintCapInTokens);

        fundTotalSupply = fundTotalSupply.add(amount);
        FundMinting(to, amount);
        token.mint(to, amount);
    }

    /*
     * @dev calculate amount
     * @param  _value - ether to be converted to tokens
     * @param  at - current time
     * @param  _totalSupply - total supplied tokens
     * @return tokens amount that we should send to our dear investor
     * @return odd ethers amount, which contract should send back
     */
    function calcAmountAt(
        uint256 amount,
        uint256 at,
        uint256 _totalSupply
    ) public constant returns (uint256, uint256) {
        uint256 estimate;
        uint256 discount;
        uint256 price;

        if(at >= startTimeTLP1 && at <= endTimeTLP1) {
            /*
                35% 0.0650 | 1 ETH -> 1 / (100-35) * 100 / 0.1 * 1000 = 15384.61538461538 MFL
                30% 0.0700 | 1 ETH -> 1 / (100-30) * 100 / 0.1 * 1000 = 14285.714287 MFL
                15% 0.0850 | 1 ETH -> 1 / (100-15) * 100 / 0.1 * 1000 = 11764.705882352941 MFL
                 0% 0.1000 | 1 ETH -> 1 / (100-0) * 100  / 0.1 * 1000 = 10000 MFL
            */
            require(amount >= minimalWeiTLP1);

            price = priceTLP1;

            if(at < startTimeTLP1 + 3 days) {
                discount = 65; //  100-35 = 0.065 ETH per 1000 MFL

            } else if(at < startTimeTLP1 + 6 days) {
                discount = 70; //  100-30 = 0.07 ETH per 1000 MFL

            } else if(at < startTimeTLP1 + 9 days) {
                discount = 85; //  100-15 = 0.085 ETH per 1000 MFL

            } else if(at < startTimeTLP1 + 12 days) {
                discount = 100; // 100 = 0.1 ETH per 1000 MFL

            } else {
                revert();
            }

        } else if(at >= startTimeTLP2 && at <= endTimeTLP2) {
            /*
                 -40% 0.12 | 1 ETH -> 1 / (100-40) * 100 / 0.2 * 1000 = 8333.3333333333 MFL
                 -30% 0.14 | 1 ETH -> 1 / (100-30) * 100 / 0.2 * 1000 = 7142.8571428571 MFL
                 -20% 0.16 | 1 ETH -> 1 / (100-20) * 100 / 0.2 * 1000 = 6250 MFL
                 -10% 0.18 | 1 ETH -> 1 / (100-10) * 100 / 0.2 * 1000 = 5555.5555555556 MFL
                   0% 0.20 | 1 ETH -> 1 / (100-0) * 100 / 0.2 * 1000  = 5000 MFL
                  10% 0.22 | 1 ETH -> 1 / (100+10) * 100 / 0.2 * 1000 = 4545.4545454545 MFL
                  20% 0.24 | 1 ETH -> 1 / (100+20) * 100 / 0.2 * 1000 = 4166.6666666667 MFL
                  30% 0.26 | 1 ETH -> 1 / (100+30) * 100 / 0.2 * 1000 = 3846.1538461538 MFL
            */
            require(amount >= minimalWeiTLP2);

            price = priceTLP2;

            if(at < startTimeTLP2 + 3 days) {
                discount = 60; // 100-40 = 0.12 ETH per 1000 MFL

            } else if(at < startTimeTLP2 + 6 days) {
                discount = 70; // 100-30 = 0.14 ETH per 1000 MFL

            } else if(at < startTimeTLP2 + 9 days) {
                discount = 80; // 100-20 = 0.16 ETH per 1000 MFL

            } else if(at < startTimeTLP2 + 12 days) {
                discount = 90; // 100-10 = 0.18 ETH per 1000 MFL

            } else if(at < startTimeTLP2 + 15 days) {
                discount = 100; // 100 = 0.2 ETH per 1000 MFL

            } else if(at < startTimeTLP2 + 18 days) {
                discount = 110; // 100+10 = 0.22 ETH per 1000 MFL

            } else if(at < startTimeTLP2 + 21 days) {
                discount = 120; // 100+20 = 0.24 ETH per 1000 MFL

            } else if(at < startTimeTLP2 + 24 days) {
                discount = 130; // 100+30 = 0.26 ETH per 1000 MFL

            } else {
                revert();
            }
        } else {
            revert();
        }

        price = price.mul(discount).div(100);
        estimate = _totalSupply.add(amount.mul(1e18).div(price));

        if(estimate > mintCapInTokens) {
            return (
                mintCapInTokens.sub(_totalSupply),
                estimate.sub(mintCapInTokens).mul(price).div(1e18)
            );
        }
        return (estimate.sub(_totalSupply), 0);
    }

    /*
     * @dev sell token and send to contributor address
     * @param contributor address
     */
    function buyTokens(address contributor) payable stopInEmergency validPurchase public {
        uint256 amount;
        uint256 odd_ethers;
        uint256 ethers;
        
        (amount, odd_ethers) = calcAmountAt(msg.value, block.timestamp, token.totalSupply());
  
        require(contributor != 0x0) ;
        require(amount + token.totalSupply() <= mintCapInTokens);

        ethers = (msg.value - odd_ethers);

        token.mint(contributor, amount); // fail if minting is finished
        TokenPurchase(contributor, ethers, amount);
        totalETH += ethers;

        if(odd_ethers > 0) {
            require(odd_ethers < msg.value);
            TransferOddEther(contributor, odd_ethers);
            contributor.transfer(odd_ethers);
        }

        wallet.transfer(ethers);
    }

    function teamWithdraw() public {
        require(token.mintingFinished());
        require(msg.sender == teamWallet || isOwner());

        uint256 currentPeriod = (block.timestamp).sub(endTimeTLP2).div(teamVestingPeriodInSeconds);
        if(currentPeriod > teamVestingPeriodsCount) {
            currentPeriod = teamVestingPeriodsCount;
        }
        uint256 tokenAvailable = _teamTokens.mul(currentPeriod).div(teamVestingPeriodsCount).sub(teamTotalSupply);

        require(teamTotalSupply + tokenAvailable <= _teamTokens);

        teamTotalSupply = teamTotalSupply.add(tokenAvailable);

        TeamVesting(teamWallet, currentPeriod, tokenAvailable);
        token.transfer(teamWallet, tokenAvailable);

    }

    function finishCrowdsale() onlyOwner public {
        require(now > endTimeTLP2 || mintCapInTokens == token.totalSupply());
        require(!token.mintingFinished());

        uint256 _totalSupply = token.totalSupply();

        // rewards
        _teamTokens = _totalSupply.mul(teamPercents).div(70); // 180,000,000 MFL
        token.mint(this, _teamTokens); // mint to contract address

        _reservedTokens = _totalSupply.mul(reservedPercents).div(70); // 180,000,000 MFL
        token.mint(reservedWallet, _reservedTokens);

        _advisoryTokens = _totalSupply.mul(advisoryPercents).div(70); // 90,000,000 MFL
        token.mint(advisoryWallet, _advisoryTokens);

        _bountyOfflineTokens = _totalSupply.mul(bountyOfflinePercents).div(70); // 54,000,000 MFL
        token.mint(bountyOfflineWallet, _bountyOfflineTokens);

        _bountyOnlineTokens = _totalSupply.mul(bountyOnlinePercents).div(70); // 36,000,000 MFL
        token.mint(bountyOnlineWallet, _bountyOnlineTokens);

        token.finishMinting();
   }

}
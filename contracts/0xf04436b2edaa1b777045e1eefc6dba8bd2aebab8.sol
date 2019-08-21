pragma solidity ^0.4.18;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
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
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

//
// CPYToken is a standard ERC20 token with additional functionality:
// - tokenSaleContract receives the whole balance for distribution
// - Tokens are only transferable by the tokenSaleContract until finalization
// - Token holders can burn their tokens after finalization
//
contract Token is StandardToken {

    string  public constant name   = "COPYTRACK Token";
    string  public constant symbol = "CPY";

    uint8 public constant   decimals = 18;

    uint256 constant EXA       = 10 ** 18;
    uint256 public totalSupply = 100 * 10 ** 6 * EXA;

    bool public finalized = false;

    address public tokenSaleContract;

    //
    // EVENTS
    //
    event Finalized();

    event Burnt(address indexed _from, uint256 _amount);


    // Initialize the token with the tokenSaleContract and transfer the whole balance to it
    function Token(address _tokenSaleContract)
        public
    {
        // Make sure address is set
        require(_tokenSaleContract != 0);

        balances[_tokenSaleContract] = totalSupply;

        tokenSaleContract = _tokenSaleContract;
    }


    // Implementation of the standard transfer method that takes the finalize flag into account
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        checkTransferAllowed(msg.sender);

        return super.transfer(_to, _value);
    }


    // Implementation of the standard transferFrom method that takes into account the finalize flag
    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool success)
    {
        checkTransferAllowed(msg.sender);

        return super.transferFrom(_from, _to, _value);
    }


    function checkTransferAllowed(address _sender)
        private
        view
    {
        if (finalized) {
            // Every token holder should be allowed to transfer tokens once token was finalized
            return;
        }

        // Only allow tokenSaleContract to transfer tokens before finalization
        require(_sender == tokenSaleContract);
    }


    // Finalize method marks the point where token transfers are finally allowed for everybody
    function finalize()
        external
        returns (bool success)
    {
        require(!finalized);
        require(msg.sender == tokenSaleContract);

        finalized = true;

        Finalized();

        return true;
    }


    // Implement a burn function to permit msg.sender to reduce its balance which also reduces totalSupply
    function burn(uint256 _value)
        public
        returns (bool success)
    {
        require(finalized);
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        Burnt(msg.sender, _value);

        return true;
    }
}

contract TokenSaleConfig  {
    uint public constant EXA = 10 ** 18;

    uint256 public constant PUBLIC_START_TIME         = 1515542400; //Wed, 10 Jan 2018 00:00:00 +0000
    uint256 public constant END_TIME                  = 1518220800; //Sat, 10 Feb 2018 00:00:00 +0000
    uint256 public constant CONTRIBUTION_MIN          = 0.1 ether;
    uint256 public constant CONTRIBUTION_MAX          = 2500.0 ether;

    uint256 public constant COMPANY_ALLOCATION        = 40 * 10 ** 6 * EXA; //40 million;

    Tranche[4] public tranches;

    struct Tranche {
        // How long this tranche will be active
        uint untilToken;

        // How many tokens per ether you will get while this tranche is active
        uint tokensPerEther;
    }

    function TokenSaleConfig()
        public
    {
        tranches[0] = Tranche({untilToken : 5000000 * EXA, tokensPerEther : 1554});
        tranches[1] = Tranche({untilToken : 10000000 * EXA, tokensPerEther : 1178});
        tranches[2] = Tranche({untilToken : 20000000 * EXA, tokensPerEther : 1000});
        tranches[3] = Tranche({untilToken : 60000000, tokensPerEther : 740});
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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

contract TokenSale is TokenSaleConfig, Ownable {
    using SafeMath for uint;

    Token  public  tokenContract;

    // We keep track of whether the sale has been finalized, at which point
    // no additional contributions will be permitted.
    bool public finalized = false;

    // lookup for max wei amount per user allowed
    mapping (address => uint256) public contributors;

    // the total amount of wei raised
    uint256 public totalWeiRaised = 0;

    // the total amount of token raised
    uint256 public totalTokenSold = 0;

    // address where funds are collected
    address public fundingWalletAddress;

    // address which manages the whitelist (KYC)
    mapping (address => bool) public whitelistOperators;

    // lookup addresses for whitelist
    mapping (address => bool) public whitelist;


    // early bird investments
    address[] public earlyBirds;

    mapping (address => uint256) public earlyBirdInvestments;


    //
    // MODIFIERS
    //

    // Throws if purchase would exceed the min max contribution.
    // @param _contribute address
    // @param _weiAmount the amount intended to spend
    modifier withinContributionLimits(address _contributorAddress, uint256 _weiAmount) {
        uint256 totalContributionAmount = contributors[_contributorAddress].add(_weiAmount);
        require(_weiAmount >= CONTRIBUTION_MIN);
        require(totalContributionAmount <= CONTRIBUTION_MAX);
        _;
    }

    // Throws if called by any account not on the whitelist.
    // @param _address Address which should execute the function
    modifier onlyWhitelisted(address _address) {
        require(whitelist[_address] == true);
        _;
    }

    // Throws if called by any account not on the whitelistOperators list
    modifier onlyWhitelistOperator()
    {
        require(whitelistOperators[msg.sender] == true);
        _;
    }

    //Throws if sale is finalized or token sale end time has been reached
    modifier onlyDuringSale() {
        require(finalized == false);
        require(currentTime() <= END_TIME);
        _;
    }

    //Throws if sale is finalized
    modifier onlyAfterFinalized() {
        require(finalized);
        _;
    }



    //
    // EVENTS
    //
    event LogWhitelistUpdated(address indexed _account);

    event LogTokensPurchased(address indexed _account, uint256 _cost, uint256 _tokens, uint256 _totalTokenSold);

    event UnsoldTokensBurnt(uint256 _amount);

    event Finalized();

    // Initialize a new TokenSale contract
    // @param _fundingWalletAddress Address which all ether will be forwarded to
    function TokenSale(address _fundingWalletAddress)
        public
    {
        //make sure _fundingWalletAddress is set
        require(_fundingWalletAddress != 0);

        fundingWalletAddress = _fundingWalletAddress;
    }

    // Connect a token to the tokenSale
    // @param _fundingWalletAddress Address which all ether will be forwarded to
    function connectToken(Token _tokenContract)
        external
        onlyOwner
    {
        require(totalTokenSold == 0);
        require(tokenContract == address(0));

        //make sure token is untouched
        require(_tokenContract.balanceOf(address(this)) == _tokenContract.totalSupply());

        tokenContract = _tokenContract;

        // sent tokens to company vault
        tokenContract.transfer(fundingWalletAddress, COMPANY_ALLOCATION);
        processEarlyBirds();
    }

    function()
        external
        payable
    {
        uint256 cost = buyTokens(msg.sender, msg.value);

        // forward contribution to the fundingWalletAddress
        fundingWalletAddress.transfer(cost);
    }

    // execution of the actual token purchase
    function buyTokens(address contributorAddress, uint256 weiAmount)
        onlyDuringSale
        onlyWhitelisted(contributorAddress)
        withinContributionLimits(contributorAddress, weiAmount)
        private
    returns (uint256 costs)
    {
        assert(tokenContract != address(0));

        uint256 tokensLeft = getTokensLeft();

        // make sure we still have tokens left for sale
        require(tokensLeft > 0);

        uint256 tokenAmount = calculateTokenAmount(weiAmount);
        uint256 cost = weiAmount;
        uint256 refund = 0;

        // we sell till we dont have anything left
        if (tokenAmount > tokensLeft) {
            tokenAmount = tokensLeft;

            // calculate actual cost for partial amount of tokens.
            cost = tokenAmount / getCurrentTokensPerEther();

            // calculate refund for contributor.
            refund = weiAmount.sub(cost);
        }

        // transfer the tokens to the contributor address
        tokenContract.transfer(contributorAddress, tokenAmount);

        // keep track of the amount bought by the contributor
        contributors[contributorAddress] = contributors[contributorAddress].add(cost);


        //if we got a refund process it now
        if (refund > 0) {
            // transfer back everything that exceeded the amount of tokens left
            contributorAddress.transfer(refund);
        }

        // increase stats
        totalWeiRaised += cost;
        totalTokenSold += tokenAmount;

        LogTokensPurchased(contributorAddress, cost, tokenAmount, totalTokenSold);

        // If all tokens available for sale have been sold out, finalize the sale automatically.
        if (tokensLeft.sub(tokenAmount) == 0) {
            finalizeInternal();
        }


        //return the actual cost of the sale
        return cost;
    }

    // ask the connected token how many tokens we have left 
    function getTokensLeft()
        public
        view
    returns (uint256 tokensLeft)
    {
        return tokenContract.balanceOf(this);
    }

    // calculate the current tokens per ether
    function getCurrentTokensPerEther()
        public
        view
    returns (uint256 tokensPerEther)
    {
        uint i;
        uint defaultTokensPerEther = tranches[tranches.length - 1].tokensPerEther;

        if (currentTime() >= PUBLIC_START_TIME) {
            return defaultTokensPerEther;
        }

        for (i = 0; i < tranches.length; i++) {
            if (totalTokenSold >= tranches[i].untilToken) {
                continue;
            }

            //sell until the contract has nor more tokens
            return tranches[i].tokensPerEther;
        }

        return defaultTokensPerEther;
    }

    // calculate the token amount for a give weiAmount
    function calculateTokenAmount(uint256 weiAmount)
        public
        view
    returns (uint256 tokens)
    {
        return weiAmount * getCurrentTokensPerEther();
    }

    //
    // WHITELIST
    //

    // add a new whitelistOperator
    function addWhitelistOperator(address _address)
        public
        onlyOwner
    {
        whitelistOperators[_address] = true;
    }

    // remove a whitelistOperator
    function removeWhitelistOperator(address _address)
        public
        onlyOwner
    {
        require(whitelistOperators[_address]);

        delete whitelistOperators[_address];
    }


    // Allows whitelistOperators to add an account to the whitelist.
    // Only those accounts will be allowed to contribute during the sale.
    function addToWhitelist(address _address)
        public
        onlyWhitelistOperator
    {
        require(_address != address(0));

        whitelist[_address] = true;
        LogWhitelistUpdated(_address);
    }

    // Allows whitelistOperators to remove an account from the whitelist.
    function removeFromWhitelist(address _address)
        public
        onlyWhitelistOperator
    {
        require(_address != address(0));

        delete whitelist[_address];
    }

    //returns the current time, needed for tests
    function currentTime()
        public
        view
        returns (uint256 _currentTime)
    {
        return now;
    }


    // Allows the owner to finalize the sale.
    function finalize()
        external
        onlyOwner
        returns (bool)
    {
        //allow only after the defined end_time
        require(currentTime() > END_TIME);

        return finalizeInternal();
    }


    // The internal one will be called if tokens are sold out or
    // the end time for the sale is reached, in addition to being called
    // from the public version of finalize().
    function finalizeInternal() private returns (bool) {
        require(!finalized);

        finalized = true;

        Finalized();

        //also finalize the token contract
        tokenContract.finalize();

        return true;
    }

    // register an early bird investment
    function addEarlyBird(address _address, uint256 weiAmount)
        onlyOwner
        withinContributionLimits(_address, weiAmount)
        external
    {
        // only allowed as long as we dont have a connected token
        require(tokenContract == address(0));

        earlyBirds.push(_address);
        earlyBirdInvestments[_address] = weiAmount;

        // auto whitelist early bird;
        whitelist[_address] = true;
    }

    // transfer the tokens bought by the early birds before contract creation
    function processEarlyBirds()
        private
    {
        for (uint256 i = 0; i < earlyBirds.length; i++)
        {
            address earlyBirdAddress = earlyBirds[i];
            uint256 weiAmount = earlyBirdInvestments[earlyBirdAddress];

            buyTokens(earlyBirdAddress, weiAmount);
        }
    }


    // allows everyone to burn all unsold tokens in the sale contract after finalized.
    function burnUnsoldTokens()
        external
        onlyAfterFinalized
        returns (bool)
    {
        uint256 leftTokens = getTokensLeft();

        require(leftTokens > 0);

        // let'em burn
        require(tokenContract.burn(leftTokens));

        UnsoldTokensBurnt(leftTokens);

        return true;
    }
}
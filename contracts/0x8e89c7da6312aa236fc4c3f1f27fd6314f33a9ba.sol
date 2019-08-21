pragma solidity ^0.4.13;

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

contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
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

library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
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

contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
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

contract TokenTimelock {
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint64 public releaseTime;

  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint64 _releaseTime) {
    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   * Deprecated: please use TokenTimelock#release instead.
   */
  function claim() public {
    require(msg.sender == beneficiary);
    release();
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    require(now >= releaseTime);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
  }
}

contract AidCoin is MintableToken, BurnableToken {
    string public name = "AidCoin";
    string public symbol = "AID";
    uint256 public decimals = 18;
    uint256 public maxSupply = 100000000 * (10 ** decimals);

    function AidCoin() public {

    }

    modifier canTransfer(address _from, uint _value) {
        require(mintingFinished);
        _;
    }

    function transfer(address _to, uint _value) canTransfer(msg.sender, _value) public returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) canTransfer(_from, _value) public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}

contract AidCoinPresale is Ownable, Crowdsale {
    using SafeMath for uint256;

    // max tokens cap
    uint256 public tokenCap = 10000000 * (10 ** 18);

    // amount of sold tokens
    uint256 public soldTokens;

    // Team wallet
    address public teamWallet;
    // Advisor wallet
    address public advisorWallet;
    // AID pool wallet
    address public aidPoolWallet;
    // Company wallet
    address public companyWallet;
    // Bounty wallet
    address public bountyWallet;

    // reserved tokens
    uint256 public teamTokens 		= 	10000000 * (10 ** 18);
    uint256 public advisorTokens 	= 	10000000 * (10 ** 18);
    uint256 public aidPoolTokens 	= 	10000000 * (10 ** 18);
    uint256 public companyTokens 	= 	27000000 * (10 ** 18);
    uint256 public bountyTokens 	= 	3000000 * (10 ** 18);

    uint256 public claimedAirdropTokens;
    mapping (address => bool) public claimedAirdrop;

    // team locked tokens
    TokenTimelock public teamTimeLock;
    // advisor locked tokens
    TokenTimelock public advisorTimeLock;
    // company locked tokens
    TokenTimelock public companyTimeLock;

    modifier beforeEnd() {
        require(now < endTime);
        _;
    }

    function AidCoinPresale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        address _teamWallet,
        address _advisorWallet,
        address _aidPoolWallet,
        address _companyWallet,
        address _bountyWallet
    ) public
    Crowdsale (_startTime, _endTime, _rate, _wallet)
    {

        require(_teamWallet != 0x0);
        require(_advisorWallet != 0x0);
        require(_aidPoolWallet != 0x0);
        require(_companyWallet != 0x0);
        require(_bountyWallet != 0x0);

        teamWallet = _teamWallet;
        advisorWallet = _advisorWallet;
        aidPoolWallet = _aidPoolWallet;
        companyWallet = _companyWallet;
        bountyWallet = _bountyWallet;

        // give tokens to aid pool
        token.mint(aidPoolWallet, aidPoolTokens);

        // give tokens to team with lock
        teamTimeLock = new TokenTimelock(token, teamWallet, uint64(now + 1 years));
        token.mint(address(teamTimeLock), teamTokens);

        // give tokens to company with lock
        companyTimeLock = new TokenTimelock(token, companyWallet, uint64(now + 1 years));
        token.mint(address(companyTimeLock), companyTokens);

        // give tokens to advisor
        uint256 initialAdvisorTokens = advisorTokens.mul(20).div(100);
        token.mint(advisorWallet, initialAdvisorTokens);
        uint256 lockedAdvisorTokens = advisorTokens.sub(initialAdvisorTokens);
        advisorTimeLock = new TokenTimelock(token, advisorWallet, uint64(now + 180 days));
        token.mint(address(advisorTimeLock), lockedAdvisorTokens);
    }

    /**
     * @dev Create new instance of ico token contract
     */
    function createTokenContract() internal returns (MintableToken) {
        return new AidCoin();
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        // get wei amount
        uint256 weiAmount = msg.value;

        // calculate token amount to be transferred
        uint256 tokens = weiAmount.mul(rate);

        // calculate new total sold
        uint256 newTotalSold = soldTokens.add(tokens);

        // check if we are over the max token cap
        require(newTotalSold <= tokenCap);

        // update states
        weiRaised = weiRaised.add(weiAmount);
        soldTokens = newTotalSold;

        // mint tokens to beneficiary
        token.mint(beneficiary, tokens);
        TokenPurchase(
            msg.sender,
            beneficiary,
            weiAmount,
            tokens
        );

        forwardFunds();
    }

    // mint tokens for airdrop
    function airdrop(address[] users) public onlyOwner beforeEnd {
        require(users.length > 0);

        uint256 amount = 5 * (10 ** 18);

        uint len = users.length;
        for (uint i = 0; i < len; i++) {
            address to = users[i];
            if (!claimedAirdrop[to]) {
                claimedAirdropTokens = claimedAirdropTokens.add(amount);
                require(claimedAirdropTokens <= bountyTokens);

                claimedAirdrop[to] = true;
                token.mint(to, amount);
            }
        }
    }

    // close token sale and transfer ownership, also move unclaimed airdrop tokens
    function closeTokenSale(address _icoContract) public onlyOwner {
        require(hasEnded());
        require(_icoContract != 0x0);

        // mint unclaimed bounty tokens
        uint256 unclaimedAirdropTokens = bountyTokens.sub(claimedAirdropTokens);
        if (unclaimedAirdropTokens > 0) {
            token.mint(bountyWallet, unclaimedAirdropTokens);
        }

        // transfer token ownership to ico contract
        token.transferOwnership(_icoContract);
    }

    // overriding Crowdsale#hasEnded to add tokenCap logic
    // @return true if crowdsale event has ended or cap is reached
    function hasEnded() public constant returns (bool) {
        bool capReached = soldTokens >= tokenCap;
        return super.hasEnded() || capReached;
    }

    // @return true if crowdsale event has started
    function hasStarted() public constant returns (bool) {
        return now >= startTime && now < endTime;
    }
}
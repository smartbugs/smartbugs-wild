pragma solidity ^0.4.13;

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

contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) {
    require(_wallet != 0x0);
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
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

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
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

contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  // minimum amount of funds to be raised in weis
  uint256 public goal;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  function RefundableCrowdsale(uint256 _goal) {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }

  // We're overriding the fund forwarding from Crowdsale.
  // In addition to sending the funds, we want to call
  // the RefundVault deposit function
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  function goalReached() public constant returns (bool) {
    return weiRaised >= goal;
  }

}

contract ZakemFansCrowdsale is Pausable, RefundableCrowdsale, CappedCrowdsale {
        /**
           Address of the wallet of the founders.
           In this wallet, part of the facilitating tokens will be stored, and they will be locked for 24 months.
         */
        address public foundersWallet;

        /**
           Address of the wallet used to pay out bounties.
           In this wallet, part of the facilitating tokens will be stored.
         */
        address public bountiesWallet;

        /**
           Keeps track of how many tokens have been raised so far.
           Used to know when `goal` and `cap` have been reached.
         */
        uint256 public purchasedTokensRaised;

        /**
           The amount of tokens that were sold in the Presale before the Crowdsale.
           Given during construction of this contract.
         */
        uint256 public purchasedTokensRaisedDuringPresale;

        /**
           Helper property to ensure that 1/12 of `cap` does not need to be re-calculated every time.
         */
        uint256 oneTwelfthOfCap;

        /**
           @dev Constructor of the ZakemFansCrowdsale contract

           @param _startTime time (Solidity UNIX timestamp) from when it is allowed to buy FINC.
           @param _endTime time (Solidity UNIX timestamp) until which it is allowed to buy FINC. (Should be larger than startTime)
           @param _rate Number of tokens created per ether. (Since Ether and ZakemCoin use the same number of decimal places, this can be read as direct conversion rate of Ether -> ZakemCoin.)
           @param _wallet The wallet of ZakemFans itself, to which some of the facilitating tokens will be sent.
           @param _bountiesWallet The wallet used to pay out bounties, to which some of the facilitating tokens will be sent.
           @param _foundersWallet The wallet used for the founders, to which some of the facilitating tokens will be sent.
           @param _goal The minimum goal (in 1 * 10^(-18) tokens) that the Crowdsale needs to reach.
           @param _cap The maximum cap (in 1 * 10^(-18) tokens) that the Crowdsale can reach.
           @param _token The address where the ZakemCoin contract was deployed prior to creating this contract.
           @param _purchasedTokensRaisedDuringPresale The amount (in 1 * 18^18 tokens) that was purchased during the presale.
         */
        function ZakemFansCrowdsale (
                uint256 _startTime,
                uint256 _endTime,
                uint256 _rate,
                address _wallet,
                address _bountiesWallet,
                address _foundersWallet,
                uint256 _goal,
                uint256 _cap,
                address _token,
                uint256 _purchasedTokensRaisedDuringPresale
                )
                Crowdsale(_startTime, _endTime, _rate, _wallet)
                RefundableCrowdsale(_goal)
                CappedCrowdsale(_cap)
        {
                require(_goal < _cap);

                bountiesWallet = _bountiesWallet;
                foundersWallet = _foundersWallet;
                token = ZakemCoin(_token);
                weiRaised = 0;

                purchasedTokensRaisedDuringPresale = _purchasedTokensRaisedDuringPresale;
                purchasedTokensRaised = purchasedTokensRaisedDuringPresale;

                oneTwelfthOfCap = _cap / 12;
        }

        /*
          Overrides Crowdsale.createTokenContract,
          because the ZakemFansCrowdsale uses an already-deployed
          token, so there is no need to internally deploy a contract.
        */
        function createTokenContract() internal returns (MintableToken) {
                return MintableToken(0x0);
        }

        /*
         * Overrides version of Crowdsale.buyTokens because:
         * - The Wei->FFC rate depends on how many tokens have already been sold (see `currentBonusRate()`).
         * - Also mint tokens sent to ZakemFans and the Founders at the same time.
         */
        function buyTokens(address beneficiary) public payable whenNotPaused {
                require(beneficiary != 0x0);

                uint256 weiAmount = msg.value;

                // calculate token amount to be created
                uint256 purchasedTokens = weiAmount.div(rate);
                require(validPurchase(purchasedTokens));
                purchasedTokens = purchasedTokens.mul(currentBonusRate()).div(100);
                require(purchasedTokens != 0);

                // update state
                weiRaised = weiRaised.add(weiAmount);
                purchasedTokensRaised = purchasedTokensRaised.add(purchasedTokens);

                // Mint tokens for beneficiary
                token.mint(beneficiary, purchasedTokens);
                TokenPurchase(msg.sender, beneficiary, weiAmount, purchasedTokens);

                mintTokensForFacilitators(purchasedTokens);

                forwardFunds();
        }

        /* Overrides RefundableCrowdsale#goalReached
           since we count the goal in purchased tokens, instead of in Wei.
           @return true if crowdsale has reached more funds than the minimum goal.
        */
        function goalReached() public constant returns (bool) {
                return purchasedTokensRaised >= goal;
        }

        /**
           Overrides CappedCrowdsale#hasEnded to add cap logic in tokens
           @return true if crowdsale event has ended
        */
        function hasEnded() public constant returns (bool) {
                bool capReached = purchasedTokensRaised >= cap;
                return Crowdsale.hasEnded() || capReached;
        }

        /**
           replaces CappedCrowdsale#validPurchase to add extra cap logic in tokens
           @param purchasedTokens Amount of tokens that were purchased (in the smallest, 1 * 10^(-18) denomination)
           @return true if investors are allowed to purchase tokens at the moment.
        */
        function validPurchase(uint256 purchasedTokens) internal constant returns (bool) {
                /* bool withinCap = purchasedTokensRaised.add(purchasedTokens) <= cap; */
                /* return Crowdsale.validPurchase() && withinCap; */
                bool withinCap = purchasedTokensRaised.add(purchasedTokens) <= cap;
                return Crowdsale.validPurchase() && withinCap;
        }

        /**
           @dev Mints the tokens for the facilitating parties.

           @dev In total, (20/13) * `purchasedTokens` tokens are created.
           @dev 13/13th of these are for the Beneficiary.
           @dev 7/13th of these are minted for the Facilitators as follows:
           @dev   1/13th -> Founders
           @dev   2/13th -> Bounties
           @dev   4/13th -> ZakemFans

           @dev Note that all result rational amounts are floored since the EVM only works with integer arithmetic.
        */
        function mintTokensForFacilitators(uint256 purchasedTokens) internal {
                // Mint tokens for ZakemFans and Founders
                uint256 fintechfans_tokens = purchasedTokens.mul(4).div(13);
                uint256 bounties_tokens = purchasedTokens.mul(2).div(13);
                uint256 founders_tokens = purchasedTokens.mul(1).div(13);
                token.mint(wallet, fintechfans_tokens);
                token.mint(bountiesWallet, bounties_tokens);
                token.mint(foundersWallet, founders_tokens);/* TODO Locked vault? */
        }

        /**
           @dev returns the current bonus rate. This is a call that can be done at any time.

           @return a fixed-size number that is the total percentage of tokens that will be created. (100 * the bonus ratio)

           @dev When < 2 million tokens purchased, this will be 125%, which is equivalent to a 20% discount
           @dev When < 4 million tokens purchased, 118%, which is equivalent to a 15% discount.
           @dev When < 6 million tokens purchased, 111%, which is equivalent to a 10% discount.
           @dev When < 9 million tokens purchased, 105%, which is equivalent to a 5% discount.
           @dev Otherwise, there is no bonus and the function returns 100%.
        */
        function currentBonusRate() public constant returns (uint) {
                if(purchasedTokensRaised < (2 * oneTwelfthOfCap)) return 125/*.25*/; // 20% discount
                if(purchasedTokensRaised < (4 * oneTwelfthOfCap)) return 118/*.1764705882352942*/; // 15% discount
                if(purchasedTokensRaised < (6 * oneTwelfthOfCap)) return 111/*.1111111111111112*/; // 10% discount
                if(purchasedTokensRaised < (9 * oneTwelfthOfCap)) return 105/*.0526315789473684*/; // 5% discount
                return 100;
        }
}

contract TheZakemFansCrowdsale is ZakemFansCrowdsale {
    function TheZakemFansCrowdsale()
        ZakemFansCrowdsale(
            1511380200, // _startTime time (Solidity UNIX timestamp) from when it is allowed to buy FINC.
            1511384400, // _endTime time (Solidity UNIX timestamp) until which it is allowed to buy FINC. (Should be larger than startTime)
            2, // _rate Number of tokens created per ether. (Since Ether and ZakemCoin use the same number of decimal places, this can be read as direct conversion rate of Ether -> ZakemCoin.)
            0xd5D29f18B8C2C7157B6BF38111C9318b9604BdED, // _wallet The wallet of ZakemFans itself, to which some of the facilitating tokens will be sent.
            0x6B1964119841f3f5363D7EA08120642FE487410E, // _bountiesWallet The wallet used to pay out bounties, to which some of the facilitating tokens will be sent.
            0x9a123fDd708eD0931Fb4938C5b2E2462B6D23390, // _foundersWallet The wallet used for the founders, to which some of the facilitating tokens will be sent.
            1e16, // _goal The minimum goal (in 1 * 10^(-18) tokens) that the Crowdsale needs to reach.
            12e16, // _cap The maximum cap (in 1 * 10^(-18) tokens) that the Crowdsale can reach.
            0xaaC5b7048114d70b759E9EA17AFA4Ff969931a4a, // _token The address where the ZakemCoin contract was deployed prior to creating this contract.
            0  // _purchasedTokensRaisedDuringPresale The amount (in 1 * 18^18 tokens) that was purchased during the presale.
            )
    {
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

contract ApprovedBurnableToken is BurnableToken {

        /**
           Sent when `burner` burns some `value` of `owners` tokens.
        */
        event BurnFrom(address indexed owner, // The address whose tokens were burned.
                       address indexed burner, // The address that executed the `burnFrom` call
                       uint256 value           // The amount of tokens that were burned.
                );

        /**
           @dev Burns a specific amount of tokens of another account that `msg.sender`
           was approved to burn tokens for using `approveBurn` earlier.
           @param _owner The address to burn tokens from.
           @param _value The amount of token to be burned.
        */
        function burnFrom(address _owner, uint256 _value) public {
                require(_value > 0);
                require(_value <= balances[_owner]);
                require(_value <= allowed[_owner][msg.sender]);
                // no need to require value <= totalSupply, since that would imply the
                // sender's balance is greater than the totalSupply, which *should* be an assertion failure

                address burner = msg.sender;
                balances[_owner] = balances[_owner].sub(_value);
                allowed[_owner][burner] = allowed[_owner][burner].sub(_value);
                totalSupply = totalSupply.sub(_value);

                BurnFrom(_owner, burner, _value);
                Burn(_owner, _value);
        }
}

contract UnlockedAfterMintingToken is MintableToken {

    /**
       Ensures certain calls can only be made when minting is finished.

       The calls that are restricted are any calls that allow direct or indirect transferral of funds.
     */
    modifier whenMintingFinished() {
        require(mintingFinished);
        _;
    }

    function transfer(address _to, uint256 _value) public whenMintingFinished returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
      @dev Transfer tokens from one address to another
      @param _from address The address which you want to send tokens from
      @param _to address The address which you want to transfer to
      @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public whenMintingFinished returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
      @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
      @dev NOTE: This call is considered deprecated, and only included for proper compliance with ERC20.
      @dev Rather than use this call, use `increaseApproval` and `decreaseApproval` instead, whenever possible.
      @dev The reason for this, is that using `approve` directly when your allowance is nonzero results in an exploitable situation:
      @dev https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

      @param _spender The address which will spend the funds.
      @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public whenMintingFinished returns (bool) {
        return super.approve(_spender, _value);
    }

    /**
      @dev approve should only be called when allowed[_spender] == 0. To alter the
      @dev allowed value it is better to use this function, because it is safer.
      @dev (And making `approve` safe manually would require making two calls made in separate blocks.)

      This method was adapted from the one in use by the MonolithDAO Token.
     */
    function increaseApproval(address _spender, uint _addedValue) public whenMintingFinished returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    /**
       @dev approve should only be called when allowed[_spender] == 0. To alter the
       @dev allowed value it is better to use this function, because it is safer.
       @dev (And making `approve` safe manually would require making two calls made in separate blocks.)

       This method was adapted from the one in use by the MonolithDAO Token.
    */
    function decreaseApproval(address _spender, uint _subtractedValue) public whenMintingFinished returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    // TODO Prevent burning?
}

contract ZakemCoin is UnlockedAfterMintingToken, ApprovedBurnableToken {
        /**
           @dev We do not expect this to change ever after deployment,
           @dev but it is a way to identify different versions of the ZakemCoin during development.
        */
        uint8 public constant contractVersion = 1;

        /**
           @dev The name of the ZakemCoin, specified as indicated in ERC20.
         */
        string public constant name = "ZakemCoin";

        /**
           @dev The abbreviation FINC, specified as indicated in ERC20.
        */
        string public constant symbol = "FINC";

        /**
           @dev The smallest denomination of the ZakemCoin is 1 * 10^(-18) FINC. `decimals` is specified as indicated in ERC20.
        */
        uint8 public constant decimals = 18;

        // TODO extractToken function to allow people to retrieve token-funds sent here by mistake?

        // TODO ERC223-interface
}
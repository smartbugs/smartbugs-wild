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

contract LimitedTransferToken is ERC20 {

  /**
   * @dev Checks whether it can transfer or otherwise throws.
   */
  modifier canTransfer(address _sender, uint256 _value) {
   require(_value <= transferableTokens(_sender, uint64(now)));
   _;
  }

  /**
   * @dev Checks modifier and allows transfer if tokens are not locked.
   * @param _to The address that will receive the tokens.
   * @param _value The amount of tokens to be transferred.
   */
  function transfer(address _to, uint256 _value) canTransfer(msg.sender, _value) public returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
  * @dev Checks modifier and allows transfer if tokens are not locked.
  * @param _from The address that will send the tokens.
  * @param _to The address that will receive the tokens.
  * @param _value The amount of tokens to be transferred.
  */
  function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from, _value) public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Default transferable tokens function returns all tokens for a holder (no limit).
   * @dev Overwriting transferableTokens(address holder, uint64 time) is the way to provide the
   * specific logic for limiting token transferability for a holder over time.
   */
  function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
    return balanceOf(holder);
  }
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

contract StarterCoin is MintableToken, LimitedTransferToken {

    string public constant name = "StarterCoin";
    string public constant symbol = "STAC";
    uint8 public constant decimals = 18;

    uint256 public endTimeICO;
    address public bountyWallet;

    function StarterCoin(uint256 _endTimeICO, address _bountyWallet) {
        endTimeICO = _endTimeICO;
        bountyWallet = _bountyWallet;
    }

    function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
        // allow transfers after the end of ICO
        return (time > endTimeICO) || (holder == bountyWallet) ? balanceOf(holder) : 0;
    }

}

contract StarterCoinCrowdsale is Ownable {
    using SafeMath for uint256;
    // The token being sold
    MintableToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    uint256[11] public timings;
    uint8[10] public bonuses;

    // address where funds are collected
    address public wallet89;
    address public wallet10;
    address public wallet1;

    // how many token units a buyer gets per wei
    uint256 public constant RATE = 4500;

    // amount of raised money in wei
    uint256 public weiRaised;

    uint256 public tokenSold;

    uint256 public constant CAP = 154622 ether;
    uint256 public constant TOKEN_CAP = 695797500 * (10 ** uint256(18)); // 45000000+62797500+588000000 STC

    TokenTimelock public devTokenTimelock;
    TokenTimelock public foundersTokenTimelock;
    TokenTimelock public teamTokenTimelock;
    TokenTimelock public advisersTokenTimelock;

    uint256 public constant BOUNTY_SUPPLY = 78400000 * (10 ** uint256(18));
    uint256 public constant DEV_SUPPLY = 78400000 * (10 ** uint256(18));
    uint256 public constant FOUNDERS_SUPPLY = 59600000 * (10 ** uint256(18));
    uint256 public constant TEAM_SUPPLY = 39200000 * (10 ** uint256(18));
    uint256 public constant ADVISERS_SUPPLY = 29400000 * (10 ** uint256(18));


    function StarterCoinCrowdsale(
        uint256 [11] _timings,
        uint8 [10] _bonuses,
        address [3] _wallets,
        address bountyWallet,
        address devWallet,
        uint64 devReleaseTime,
        address foundersWallet,
        uint64 foundersReleaseTime,
        address teamWallet,
        uint64 teamReleaseTime,
        address advisersWallet,
        uint64 advisersReleaseTime
        ) {
            require(_timings[0] >= now);

            for(uint i = 1; i < timings.length; i++) {
              require(_timings[i] >= _timings[i-1]);
            }

            timings = _timings;
            bonuses = _bonuses;
            startTime = timings[0];
            endTime = timings[timings.length-1];

            require(devReleaseTime >= endTime);
            require(foundersReleaseTime >= endTime);
            require(teamReleaseTime >= endTime);
            require(advisersReleaseTime >= endTime);

            require(_wallets[0] != 0x0);
            require(_wallets[1] != 0x0);
            require(_wallets[2] != 0x0);

            require(bountyWallet != 0x0);
            require(devWallet != 0x0);
            require(foundersWallet != 0x0);
            require(teamWallet != 0x0);
            require(advisersWallet != 0x0);

            wallet89 = _wallets[0];
            wallet10 = _wallets[1];
            wallet1 = _wallets[2];

            token = new StarterCoin(endTime, bountyWallet);

            token.mint(bountyWallet, BOUNTY_SUPPLY);

            devTokenTimelock = new TokenTimelock(token, devWallet, devReleaseTime);
            token.mint(devTokenTimelock, DEV_SUPPLY);

            foundersTokenTimelock = new TokenTimelock(token, foundersWallet, foundersReleaseTime);
            token.mint(foundersTokenTimelock, FOUNDERS_SUPPLY);

            teamTokenTimelock = new TokenTimelock(token, teamWallet, teamReleaseTime);
            token.mint(teamTokenTimelock, TEAM_SUPPLY);

            advisersTokenTimelock = new TokenTimelock(token, advisersWallet, advisersReleaseTime);
            token.mint(advisersTokenTimelock, ADVISERS_SUPPLY);
        }

        /**
        * event for token purchase logging
        * @param purchaser who paid for the tokens
        * @param beneficiary who got the tokens
        * @param value weis paid for purchase
        * @param amount amount of tokens purchased
        */
        event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

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
            require(msg.value >= 100); // required for proper splitting funds between 3 wallets

            uint256 weiAmount = msg.value;

            // calculate period bonus
            uint256 periodBonus;

            for (uint8 i = 1; i < timings.length; i++) {
              if ( now < timings[i] ) {
                periodBonus = RATE.mul(uint256(bonuses[i-1])).div(100);
                break;
              }
            }

            // calculate bulk purchase bonus
            uint256 bulkPurchaseBonus;
            if (weiAmount >= 50 ether) {
            bulkPurchaseBonus = 3600; // 80% bonus for RATE 4500
            } else if (weiAmount >= 30 ether) {
            bulkPurchaseBonus = 3150; // 70% bonus for RATE 4500
            } else if (weiAmount >= 10 ether) {
            bulkPurchaseBonus = 2250; // 50% bonus for RATE 4500
            } else if (weiAmount >= 5 ether) {
            bulkPurchaseBonus = 1350; // 30% bonus for RATE 4500
            } else if (weiAmount >= 3 ether) {
            bulkPurchaseBonus = 450; // 10% bonus for RATE 4500
            }

            uint256 actualRate = RATE.add(periodBonus).add(bulkPurchaseBonus);

            // calculate token amount to be created
            uint256 tokens = weiAmount.mul(actualRate);

            // update state
            weiRaised = weiRaised.add(weiAmount);
            tokenSold = tokenSold.add(tokens);

            require(validPurchase());

            token.mint(beneficiary, tokens);
            TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

            forwardFunds();
        }

        // send ether to the fund collection wallet
        // override to create custom fund forwarding mechanisms
        function forwardFunds() internal {
          uint256 wei89 = msg.value.mul(89).div(100);
          uint256 wei10 = msg.value.div(10);
          uint256 wei1 = msg.value.sub(wei89).sub(wei10);
          wallet89.transfer(wei89);
          wallet10.transfer(wei10);
          wallet1.transfer(wei1);
        }

        // add off chain contribution. BTC address of contribution added for transparency
        function addOffChainContribution(address beneficiar, uint256 weiAmount, uint256 tokenAmount, string btcAddress) onlyOwner public {
            require(beneficiar != 0x0);
            require(weiAmount > 0);
            require(tokenAmount > 0);
            weiRaised += weiAmount;
            tokenSold += tokenAmount;
            require(validPurchase());
            token.mint(beneficiar, tokenAmount);
        }


        // overriding Crowdsale#validPurchase to add extra CAP logic
        // @return true if investors can buy at the moment
        function validPurchase() internal constant returns (bool) {
            bool withinCap = weiRaised <= CAP;
            bool withinPeriod = now >= startTime && now <= endTime;
            bool withinTokenCap = tokenSold <= TOKEN_CAP;
            return withinPeriod && withinCap && withinTokenCap;
        }

        // overriding Crowdsale#hasEnded to add CAP logic
        // @return true if crowdsale event has ended
        function hasEnded() public constant returns (bool) {
            bool capReached = weiRaised >= CAP;
            return now > endTime || capReached;
        }

    }
pragma solidity ^0.4.13;

contract ERC20Basic {

  function balanceOf(address who) public constant returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract ERC223 is ERC20 {



    function name() constant returns (string _name);

    function symbol() constant returns (string _symbol);

    function decimals() constant returns (uint8 _decimals);



    function transfer(address to, uint256 value, bytes data) returns (bool);



}

contract ERC223ReceivingContract {

    function tokenFallback(address _from, uint256 _value, bytes _data);

}

contract KnowledgeTokenInterface is ERC223{

    event Mint(address indexed to, uint256 amount);



    function changeMinter(address newAddress) returns (bool);

    function mint(address _to, uint256 _amount) returns (bool);

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

contract WitcoinCrowdsale is Ownable {

    using SafeMath for uint256;



    // The token being sold

    WitCoin public token;



    // refund vault used to hold funds while crowdsale is running

    RefundVault public vault;



    // minimum amount of tokens to be issued

    uint256 public goal;



    // start and end timestamps where investments are allowed (both inclusive)

    uint256 public startTime;

    uint256 public startPresale;

    uint256 public endTime;

    uint256 public endRefundingingTime;



    // address where funds are collected

    address public wallet;



    // how many token units a buyer gets per ether

    uint256 public rate;



    // amount of raised money in wei

    uint256 public weiRaised;



    // amount of tokens sold

    uint256 public tokensSold;



    // amount of tokens distributed

    uint256 public tokensDistributed;



    // token decimals

    uint256 public decimals;



    // total of tokens sold in the presale time

    uint256 public totalTokensPresale;



    // total of tokens sold in the sale time (includes presale)

    uint256 public totalTokensSale;



    // minimum amount of witcoins bought

    uint256 public minimumWitcoins;



    /**

     * event for token purchase logging

     * @param purchaser who paid for the tokens

     * @param beneficiary who got the tokens

     * @param value weis paid for purchase

     * @param amount amount of tokens purchased

     */

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



    function WitcoinCrowdsale(address witAddress, address receiver) {

        token = WitCoin(witAddress);

        decimals = token.decimals();

        startTime = 1508137200; // 1508137200 = 2017-10-16 07:00:00 GMT

        startPresale = 1507618800; // 1507618800 = 2017-10-10 07:00:00 GMT

        endTime = 1509973200; // 2017-11-06 13:00:00 GMT

        endRefundingingTime = 1527840776; // 01/06/2018

        rate = 880; // 1 ether = 880 witcoins

        wallet = receiver;

        goal = 1000000 * (10 ** decimals); // 1M witcoins



        totalTokensPresale = 1000000 * (10 ** decimals) * 65 / 100; // 65% of 1M witcoins

        totalTokensSale = 8000000 * (10 ** decimals) * 65 / 100; // 65% of 8M witcoins

        minimumWitcoins = 100 * (10 ** decimals); // 100 witcoins

        tokensDistributed = 0;



        vault = new RefundVault(wallet);

    }



    // fallback function to buy tokens

    function () payable {

        buyTokens(msg.sender);

    }



    // main token purchase function

    function buyTokens(address beneficiary) public payable {

        require(beneficiary != 0x0);



        uint256 weiAmount = msg.value;



        // calculate token amount to be created

        uint256 tokens = weiAmount.mul(rate)/1000000000000000000;

        tokens = tokens * (10 ** decimals);



        // calculate bonus

        tokens = calculateBonus(tokens);



        require(validPurchase(tokens));



        // update state

        weiRaised = weiRaised.add(weiAmount);

        tokensSold = tokensSold.add(tokens);



        token.mint(beneficiary, tokens);

        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);



        forwardFunds();

    }



    // altercoin token purchase function

    function buyTokensAltercoins(address beneficiary, uint256 tokens) onlyOwner public {

        require(beneficiary != 0x0);



        // calculate bonus

        uint256 tokensBonused = calculateBonus(tokens);



        require(validPurchase(tokensBonused));



        // update state

        tokensSold = tokensSold.add(tokensBonused);



        token.mint(beneficiary, tokensBonused);

        TokenPurchase(msg.sender, beneficiary, 0, tokensBonused);

    }



    // send the ether to the fund collection wallet

    function forwardFunds() internal {

        vault.deposit.value(msg.value)(msg.sender);

    }



    // number of tokens issued after applying presale and sale bonuses

    function calculateBonus(uint256 tokens) internal returns (uint256) {

        uint256 bonusedTokens = tokens;



        // Pre-Sale Bonus

        if (presale()) {

            if (tokensSold <= 250000 * (10 ** decimals)) bonusedTokens = bonusedTokens.mul(130)/100;

            else if (tokensSold <= 500000 * (10 ** decimals)) bonusedTokens = bonusedTokens.mul(125)/100;

            else if (tokensSold <= 750000 * (10 ** decimals)) bonusedTokens = bonusedTokens.mul(120)/100;

            else if (tokensSold <= 1000000 * (10 ** decimals)) bonusedTokens = bonusedTokens.mul(115)/100;

        }



        // Sale Bonus

        if (sale()) {

            if (bonusedTokens > 2500 * (10 ** decimals)) {

                if (bonusedTokens <= 80000 * (10 ** decimals)) bonusedTokens = bonusedTokens.mul(105)/100;

                else if (bonusedTokens <= 800000 * (10 ** decimals)) bonusedTokens = bonusedTokens.mul(110)/100;

                else if (bonusedTokens > 800000 * (10 ** decimals)) bonusedTokens = bonusedTokens.mul(120)/100;

            }

        }



        return bonusedTokens;

    }



    // presale and sale constraints

    function validPurchase(uint256 tokens) internal returns (bool) {

        bool withinPeriod = presale() || sale();

        bool underLimits = (presale() && tokensSold + tokens <= totalTokensPresale) || (sale() && tokensSold + tokens <= totalTokensSale);

        bool overMinimum = tokens >= minimumWitcoins;

        return withinPeriod && underLimits && overMinimum;

    }



    function validPurchaseBonus(uint256 tokens) public returns (bool) {

        uint256 bonusedTokens = calculateBonus(tokens);

        return validPurchase(bonusedTokens);

    }



    // is presale time?

    function presale() public returns(bool) {

        return now >= startPresale && now < startTime;

    }



    // is sale time?

    function sale() public returns(bool) {

        return now >= startTime && now <= endTime;

    }



    // finalize crowdsale

    function finalize() onlyOwner public {

        require(now > endTime);



        if (tokensSold < goal) {

            vault.enableRefunds();

        } else {

            vault.close();

        }

    }



    function finalized() public returns(bool) {

        return vault.finalized();

    }



    // if crowdsale is unsuccessful, investors can claim refunds here

    function claimRefund() public returns(bool) {

        vault.refund(msg.sender);

    }



    function finalizeRefunding() onlyOwner public {

        require(now > endRefundingingTime);



        vault.finalizeEnableRefunds();

    }



    // Distribute tokens, only when goal reached

    // As written in https://witcoin.io:

    //   1%  bounties

    //   5%  nir-vana platform

    //   10% Team

    //   19% Witcoin.club

    function distributeTokens() onlyOwner public {

        require(tokensSold >= goal);

        require(tokensSold - tokensDistributed > 100);



        uint256 toDistribute = tokensSold - tokensDistributed;



        address bounties = 0x057Afd5422524d5Ca20218d07048300832323360;

        address nirvana = 0x094d57AdaBa2278de6D1f3e2F975f14248C3775F;

        address team = 0x7eC9d37163F4F1D1fD7E92B79B73d910088Aa2e7;

        address club = 0xb2c032aF1336A1482eB2FE1815Ef301A2ea4fE0A;



        uint256 bTokens = toDistribute * 1 / 65;

        uint256 nTokens = toDistribute * 5 / 65;

        uint256 tTokens = toDistribute * 10 / 65;

        uint256 cTokens = toDistribute * 19 / 65;



        token.mint(bounties, bTokens);

        token.mint(nirvana, nTokens);

        token.mint(team, tTokens);

        token.mint(club, cTokens);



        tokensDistributed = tokensDistributed.add(toDistribute);

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



  function finalizeEnableRefunds() onlyOwner public {

    require(state == State.Refunding);

    state = State.Closed;

    Closed();

    wallet.transfer(this.balance);

  }



  function refund(address investor) onlyOwner public {

    require(state == State.Refunding);



    uint256 depositedValue = deposited[investor];

    deposited[investor] = 0;

    investor.transfer(depositedValue);

    Refunded(investor, depositedValue);

  }



  function finalized() public returns(bool) {

    return state != State.Active;

  }

}

contract ERC20BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;

  uint256 public totalSupply;



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



  function totalSupply() constant returns (uint256 _totalSupply) {

    return totalSupply;

  }



}

contract ERC20Token is ERC20, ERC20BasicToken {



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

contract ERC223Token is ERC223, ERC20Token {

    using SafeMath for uint256;



    string public name;



    string public symbol;



    uint8 public decimals;





    // Function to access name of token .

    function name() constant returns (string _name) {

        return name;

    }

    // Function to access symbol of token .

    function symbol() constant returns (string _symbol) {

        return symbol;

    }

    // Function to access decimals of token .

    function decimals() constant returns (uint8 _decimals) {

        return decimals;

    }





    // Function that is called when a user or another contract wants to transfer funds .

    function transfer(address _to, uint256 _value, bytes _data) returns (bool success) {

        if (isContract(_to)) {

            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);

            receiver.tokenFallback(msg.sender, _value, _data);

        }

        return super.transfer(_to, _value);

    }



    // Standard function transfer similar to ERC20 transfer with no _data .

    // Added due to backwards compatibility reasons .

    function transfer(address _to, uint256 _value) returns (bool success) {

        if (isContract(_to)) {

            bytes memory empty;

            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);

            receiver.tokenFallback(msg.sender, _value, empty);

        }

        return super.transfer(_to, _value);

    }



    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.

    function isContract(address _addr) private returns (bool is_contract) {

        uint length;

        assembly {

            length := extcodesize(_addr)

        }

        return (length > 0);

    }



}

contract KnowledgeToken is KnowledgeTokenInterface, Ownable, ERC223Token {



    address public minter;



    modifier onlyMinter() {

        // Only minter is allowed to proceed.

        require (msg.sender == minter);

        _;

    }



    function mint(address _to, uint256 _amount) onlyMinter public returns (bool) {

        totalSupply = totalSupply.add(_amount);

        balances[_to] = balances[_to].add(_amount);

        Transfer(0x0, _to, _amount);

        Mint(_to, _amount);

        return true;

    }



    function changeMinter(address newAddress) public onlyOwner returns (bool)

    {

        minter = newAddress;

    }

}

contract WitCoin is KnowledgeToken{



    function WitCoin() {

        totalSupply = 0;

        name = "Witcoin";

        symbol = "WIT";

        decimals = 8;

    }



}
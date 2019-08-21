pragma solidity 0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint64 public releaseTime;

  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint64 _releaseTime) public {
    require(_releaseTime > uint64(block.timestamp));
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    require(uint64(block.timestamp) >= releaseTime);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
  }
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
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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

contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract IungoToken is StandardToken, Owned {
    string public constant name = "IUNGO token";
    string public constant symbol = "ING";
    uint8 public constant decimals = 18;

    /// Maximum tokens to be allocated (100 million)
    uint256 public constant HARD_CAP = 100000000 * 10**uint256(decimals);

    /// Maximum tokens to be allocated on the sale (64 million)
    uint256 public constant TOKENS_SALE_HARD_CAP = 64000000 * 10**uint256(decimals);

    /// The owner of this address is the Iungo Founders fund
    address public foundersFundAddress;

    /// The owner of this address is the Iungo Team Foundation fund
    address public teamFundAddress;

    /// The owner of this address is the Reserve fund
    address public reserveFundAddress;

    /// This address will be sent all the received ether
    address public fundsTreasury;

    /// This is the address of the timelock contract for 
    /// the first 1/3 of the Founders fund tokens
    address public foundersFundTimelock1Address;

    /// This is the address of the timelock contract for 
    /// the second 1/3 of the Founders fund tokens
    address public foundersFundTimelock2Address;

    /// This is the address of the timelock contract for 
    /// the third 1/3 of the Founders fund tokens
    address public foundersFundTimelock3Address;

    /// seconds since 01.01.1970 to 06.12.2017 12:00:00 UTC
    /// tier 1 start time
    uint64 private constant date06Dec2017 = 1512561600;

    /// seconds since 01.01.1970 to 21.12.2017 14:00:00 UTC
    /// tier 1 end time; tier 2 start time
    uint64 private constant date21Dec2017 = 1513864800;

    /// seconds since 01.01.1970 to 12.01.2018 14:00:00 UTC
    /// tier 2 end time; tier 3 start time
    uint64 private constant date12Jan2018 = 1515765600;

    /// seconds since 01.01.1970 to 21.01.2018 14:00:00 UTC
    /// tier 3 end time; tier 4 start time
    uint64 private constant date21Jan2018 = 1516543200;

    /// seconds since 01.01.1970 to 31.01.2018 23:59:59 UTC
    /// tier 4 end time; closing token sale; trading open
    uint64 private constant date31Jan2018 = 1517443199;

    /// Base exchange rate is set to 1 ETH = 1000 ING
    uint256 public constant BASE_RATE = 1000;

    /// no tokens can be ever issued when this is set to "true"
    bool public tokenSaleClosed = false;

    /// Issue event index starting from 0.
    uint256 public issueIndex = 0;

    /// Emitted for each sucuessful token purchase.
    event Issue(uint _issueIndex, address addr, uint tokenAmount);

    /// Require that the buyers can still purchase
    modifier inProgress {
        require(totalSupply < TOKENS_SALE_HARD_CAP
                && !tokenSaleClosed
                && !saleDue());
        _;
    }

    /// Allow the closing to happen only once 
    modifier beforeEnd {
        require(!tokenSaleClosed);
        _;
    }

    /// Require that the end of the sale has passed (time is 01 Feb 2018 or later)
    modifier tradingOpen {
        require(saleDue());
        _;
    }

    /**
     * CONSTRUCTOR
     *
     * @dev Initialize the IungoToken Token
     * @param _foundersFundAddress The owner of this address is the Iungo Founders fund
     * @param _teamFundAddress The owner of this address is the Iungo Team Foundation fund
     * @param _reserveFundAddress The owner of this address is the Reserve fund
     */
    function IungoToken (address _foundersFundAddress, address _teamFundAddress,
                         address _reserveFundAddress, address _fundsTreasury) public {
        foundersFundAddress = 0x9CB0016511Fb93EAc7bC585A2bc2f0C34DEcEa15;
        teamFundAddress = 0xDda7003998244f6161A5BBAf0F4ed5a40E908b51;
        reserveFundAddress = 0x9186b48Db83E63adEDaB43C19345f39c83928E3f;
        fundsTreasury = 0x31a633c4eE2C317DE2C65beb00593EAdD9f172d6;
    }

    /// @dev Returns the current price.
    function price() public view returns (uint256 tokens) {
        return computeTokenAmount(1 ether);
    }

    /// @dev This default function allows token to be purchased by directly
    /// sending ether to this smart contract.
    function () public payable {
        purchaseTokens(msg.sender);
    }

    /// @dev Issue token based on Ether received.
    /// @param _beneficiary Address that newly issued token will be sent to.
    function purchaseTokens(address _beneficiary) public payable inProgress {
        // only accept a minimum amount of ETH?
        require(msg.value >= 0.01 ether);

        uint256 tokens = computeTokenAmount(msg.value);
        doIssueTokens(_beneficiary, tokens);

        /// forward the raised funds to the fund address
        fundsTreasury.transfer(msg.value);
    }

    /// @dev Batch issue tokens on the presale
    /// @param _addresses addresses that the presale tokens will be sent to.
    /// @param _addresses the amounts of tokens, with decimals expanded (full).
    function issueTokensMulti(address[] _addresses, uint256[] _tokens) public onlyOwner inProgress {
        require(_addresses.length == _tokens.length);
        require(_addresses.length <= 100);

        for (uint256 i = 0; i < _tokens.length; i = i.add(1)) {
            doIssueTokens(_addresses[i], _tokens[i]);
        }
    }

    /// @dev Issue tokens for a single buyer on the presale
    /// @param _beneficiary addresses that the presale tokens will be sent to.
    /// @param _tokensAmount the amount of tokens, with decimals expanded (full).
    function issueTokens(address _beneficiary, uint256 _tokensAmount) public onlyOwner inProgress {
        doIssueTokens(_beneficiary, _tokensAmount);
    }

    /// @dev issue tokens for a single buyer
    /// @param _beneficiary addresses that the tokens will be sent to.
    /// @param _tokensAmount the amount of tokens, with decimals expanded (full).
    function doIssueTokens(address _beneficiary, uint256 _tokensAmount) internal {
        require(_beneficiary != address(0));

        // compute without actually increasing it
        uint256 increasedTotalSupply = totalSupply.add(_tokensAmount);
        // roll back if hard cap reached
        require(increasedTotalSupply <= TOKENS_SALE_HARD_CAP);

        // increase token total supply
        totalSupply = increasedTotalSupply;
        // update the buyer's balance to number of tokens sent
        balances[_beneficiary] = balances[_beneficiary].add(_tokensAmount);
        // event is fired when tokens issued
        Issue(
            issueIndex++,
            _beneficiary,
            _tokensAmount
        );
    }

    /// @dev Compute the amount of ING token that can be purchased.
    /// @param ethAmount Amount of Ether to purchase ING.
    /// @return Amount of ING token to purchase
    function computeTokenAmount(uint256 ethAmount) internal view returns (uint256 tokens) {
        /// the percentage value (0-100) of the discount for each tier
        uint64 discountPercentage = currentTierDiscountPercentage();

        uint256 tokenBase = ethAmount.mul(BASE_RATE);
        uint256 tokenBonus = tokenBase.mul(discountPercentage).div(100);

        tokens = tokenBase.add(tokenBonus);
    }

    /// @dev Determine the current sale tier.
    /// @return the index of the current sale tier.
    function currentTierDiscountPercentage() internal view returns (uint64) {
        uint64 _now = uint64(block.timestamp);
        require(_now <= date31Jan2018);

        if(_now > date21Jan2018) return 0;
        if(_now > date12Jan2018) return 15;
        if(_now > date21Dec2017) return 35;
        return 50;
    }

    // function getnow() public view returns (uint64) {
    //     return uint64(block.timestamp);
    // }
    // 
    // function setnow(uint64 time) public {
    //     _now = time;
    // }

    /// @dev Finalize the sale and distribute the reserve, team tokens, lock the founders tokens
    function close() public onlyOwner beforeEnd {
        uint64 _now = uint64(block.timestamp);

        /// Final (sold tokens) / (team + reserve + founders funds tokens) = 64 / 36 proportion = 0.5625
        /// (sold tokens) + (team + reserve + founders funds tokens) = 64% + 36% = 100%
        /// Therefore, (team + reserve + founders funds tokens) = 56.25% of the sold tokens = 36% of the total tokens
        uint256 totalTokens = totalSupply.add(totalSupply.mul(5625).div(10000));

        /// Tokens to be allocated to the Reserve fund (12% of total ING)
        uint256 reserveFundTokens = totalTokens.mul(12).div(100);
        balances[reserveFundAddress] = balances[reserveFundAddress].add(reserveFundTokens);
        totalSupply = totalSupply.add(reserveFundTokens);
        /// fire event when tokens issued
        Issue(
            issueIndex++,
            reserveFundAddress,
            reserveFundTokens
        );

        /// Tokens to be allocated to the Team fund (12% of total ING)
        uint256 teamFundTokens = totalTokens.mul(12).div(100);
        balances[teamFundAddress] = balances[teamFundAddress].add(teamFundTokens);
        totalSupply = totalSupply.add(teamFundTokens);
        /// fire event when tokens issued
        Issue(
            issueIndex++,
            teamFundAddress,
            teamFundTokens
        );

        /// Tokens to be allocated to the locked Founders fund
        /// 12% (3 x 4%) of total ING allocated to the Founders fund locked as follows:
        /// first 4% locked for 6 months (183 days)
        TokenTimelock lock1_6months = new TokenTimelock(this, foundersFundAddress, _now + 183*24*60*60);
        foundersFundTimelock1Address = address(lock1_6months);
        uint256 foundersFund1Tokens = totalTokens.mul(4).div(100);
        /// update the contract balance to number of tokens issued
        balances[foundersFundTimelock1Address] = balances[foundersFundTimelock1Address].add(foundersFund1Tokens);
        /// increase total supply respective to the tokens issued
        totalSupply = totalSupply.add(foundersFund1Tokens);
        /// fire event when tokens issued
        Issue(
            issueIndex++,
            foundersFundTimelock1Address,
            foundersFund1Tokens
        );

        /// second 4% locked for 12 months (365 days)
        TokenTimelock lock2_12months = new TokenTimelock(this, foundersFundAddress, _now + 365*24*60*60);
        foundersFundTimelock2Address = address(lock2_12months);
        uint256 foundersFund2Tokens = totalTokens.mul(4).div(100);
        balances[foundersFundTimelock2Address] = balances[foundersFundTimelock2Address].add(foundersFund2Tokens);
        /// increase total supply respective to the tokens issued
        totalSupply = totalSupply.add(foundersFund2Tokens);
        /// fire event when tokens issued
        Issue(
            issueIndex++,
            foundersFundTimelock2Address,
            foundersFund2Tokens
        );

        /// third 4% locked for 18 months (548 days)
        TokenTimelock lock3_18months = new TokenTimelock(this, foundersFundAddress, _now + 548*24*60*60);
        foundersFundTimelock3Address = address(lock3_18months);
        uint256 foundersFund3Tokens = totalTokens.mul(4).div(100);
        balances[foundersFundTimelock3Address] = balances[foundersFundTimelock3Address].add(foundersFund3Tokens);
        /// increase total supply respective to the tokens issued
        totalSupply = totalSupply.add(foundersFund3Tokens);
        /// fire event when tokens issued
        Issue(
            issueIndex++,
            foundersFundTimelock3Address,
            foundersFund3Tokens
        );

        /// burn the unallocated tokens - no more tokens can be issued after this line
        tokenSaleClosed = true;

        /// forward the raised funds to the fund address
        fundsTreasury.transfer(this.balance);
    }

    /// @return if the token sale is finished
    function saleDue() public view returns (bool) {
        return date31Jan2018 < uint64(block.timestamp);
    }

    /// Transfer limited by the tradingOpen modifier (time is 01 Feb 2018 or later)
    function transferFrom(address _from, address _to, uint256 _value) public tradingOpen returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /// Transfer limited by the tradingOpen modifier (time is 01 Feb 2018 or later)
    function transfer(address _to, uint256 _value) public tradingOpen returns (bool) {
        return super.transfer(_to, _value);
    }
}
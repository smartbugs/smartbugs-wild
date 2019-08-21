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

contract TokiaToken is StandardToken, Owned {
    string public constant name = "TokiaToken";
    string public constant symbol = "TKA";
    uint8 public constant decimals = 18;

    /// Maximum tokens to be allocated.
    uint256 public constant HARD_CAP = 62500000 * 10**uint256(decimals);

    /// Maximum tokens to be allocated on the sale (75% of the hard cap)
    uint256 public constant TOKENS_SALE_HARD_CAP = 50000000 * 10**uint256(decimals);

    /// Base exchange rate is set to 1 ETH = 714 TKA.
    uint256 public constant BASE_RATE = 714;

    /// seconds since 01.01.1970 to 04.12.2017 (both 00:00:00 o'clock UTC)
    /// presale start time
    uint64 private constant date04Dec2017 = 1512345600;

    /// presale end time; round 1 start time
    uint64 private constant date01Jan2018 = 1514764800;

    /// round 1 end time; round 2 start time
    uint64 private constant date01Feb2018 = 1517443200;

    /// round 2 end time; round 3 start time
    uint64 private constant date15Feb2018 = 1518652800;

    /// round 3 end time; round 4 start time
    uint64 private constant date01Mar2018 = 1519862400;

    /// round 4 end time; closing token sale
    uint64 private constant date15Mar2018 = 1521072000;

    /// team tokens are locked until this date (01.01.2019)
    uint64 private constant date01Jan2019 = 1546300800;

    /// token trading opening time (01.05.2018)
    uint64 private constant date01May2018 = 1525219199;

    /// no tokens can be ever issued when this is set to "true"
    bool public tokenSaleClosed = false;

    /// contract to be called to release the Tokia team tokens
    address public timelockContractAddress;

    /// Issue event index starting from 0.
    uint64 public issueIndex = 0;

    /// Emitted for each sucuessful token purchase.
    event Issue(uint64 issueIndex, address addr, uint256 tokenAmount);

    modifier inProgress {
        require(totalSupply < TOKENS_SALE_HARD_CAP
            && !tokenSaleClosed);
        _;
    }

    /// Allow the closing to happen only once
    modifier beforeEnd {
        require(!tokenSaleClosed);
        _;
    }

    /// Require that the end of the sale has passed (time is 01 May 2018 or later)
    modifier tradingOpen {
        require(uint64(block.timestamp) > date01May2018);
        _;
    }

    function TokiaToken() public {
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

        /// forward the raised funds to the contract creator
        owner.transfer(this.balance);
    }

    /// @dev Batch issue tokens on the presale
    /// @param _addresses addresses that the presale tokens will be sent to.
    /// @param _addresses the amounts of tokens, with decimals expanded (full).
    function issueTokensMulti(address[] _addresses, uint256[] _tokens) public onlyOwner inProgress {
        require(_addresses.length == _tokens.length);
        require(_addresses.length <= 100);

        for (uint256 i = 0; i < _tokens.length; i = i.add(1)) {
            doIssueTokens(_addresses[i], _tokens[i].mul(10**uint256(decimals)));
        }
    }

    /// @dev Issue tokens for a single buyer on the presale
    /// @param _beneficiary addresses that the presale tokens will be sent to.
    /// @param _tokens the amount of tokens, with decimals expanded (full).
    function issueTokens(address _beneficiary, uint256 _tokens) public onlyOwner inProgress {
        doIssueTokens(_beneficiary, _tokens.mul(10**uint256(decimals)));
    }

    /// @dev issue tokens for a single buyer
    /// @param _beneficiary addresses that the tokens will be sent to.
    /// @param _tokens the amount of tokens, with decimals expanded (full).
    function doIssueTokens(address _beneficiary, uint256 _tokens) internal {
        require(_beneficiary != address(0));

        // compute without actually increasing it
        uint256 increasedTotalSupply = totalSupply.add(_tokens);
        // roll back if hard cap reached
        require(increasedTotalSupply <= TOKENS_SALE_HARD_CAP);

        // increase token total supply
        totalSupply = increasedTotalSupply;
        // update the beneficiary balance to number of tokens sent
        balances[_beneficiary] = balances[_beneficiary].add(_tokens);

        // event is fired when tokens issued
        Issue(
            issueIndex++,
            _beneficiary,
            _tokens
        );
    }

    /// @dev Returns the current price.
    function price() public view returns (uint256 tokens) {
        return computeTokenAmount(1 ether);
    }

    /// @dev Compute the amount of TKA token that can be purchased.
    /// @param ethAmount Amount of Ether to purchase TKA.
    /// @return Amount of TKA token to purchase
    function computeTokenAmount(uint256 ethAmount) internal view returns (uint256 tokens) {
        uint256 tokenBase = ethAmount.mul(BASE_RATE);
        uint8[5] memory roundDiscountPercentages = [47, 35, 25, 15, 5];

        uint8 roundDiscountPercentage = roundDiscountPercentages[currentRoundIndex()];
        uint8 amountDiscountPercentage = getAmountDiscountPercentage(tokenBase);

        tokens = tokenBase.mul(100).div(100 - (roundDiscountPercentage + amountDiscountPercentage));
    }

    /// @dev Compute the additional discount for the purchaed amount of TKA
    /// @param tokenBase the base tokens amount computed only against the base rate
    /// @return integer representing the percentage discount
    function getAmountDiscountPercentage(uint256 tokenBase) internal pure returns (uint8) {
        if(tokenBase >= 1500 * 10**uint256(decimals)) return 9;
        if(tokenBase >= 1000 * 10**uint256(decimals)) return 5;
        if(tokenBase >= 500 * 10**uint256(decimals)) return 3;
        return 0;
    }

    /// @dev Determine the current sale round
    /// @return integer representing the index of the current sale round
    function currentRoundIndex() internal view returns (uint8 roundNum) {
        roundNum = currentRoundIndexByDate();

        /// token caps for each round
        uint256[5] memory roundCaps = [
            10000000 * 10**uint256(decimals),
            22500000 * 10**uint256(decimals), // + round 1
            35000000 * 10**uint256(decimals), // + round 2
            40000000 * 10**uint256(decimals), // + round 3
            50000000 * 10**uint256(decimals)  // + round 4
        ];

        /// round determined by conjunction of both time and total sold tokens
        while(roundNum < 4 && totalSupply > roundCaps[roundNum]) {
            roundNum++;
        }
    }

    /// @dev Determine the current sale tier.
    /// @return the index of the current sale tier by date.
    function currentRoundIndexByDate() internal view returns (uint8 roundNum) {
        uint64 _now = uint64(block.timestamp);
        require(_now <= date15Mar2018);

        roundNum = 0;
        if(_now > date01Mar2018) roundNum = 4;
        if(_now > date15Feb2018) roundNum = 3;
        if(_now > date01Feb2018) roundNum = 2;
        if(_now > date01Jan2018) roundNum = 1;
        return roundNum;
    }

    /// @dev Closes the sale, issues the team tokens and burns the unsold
    function close() public onlyOwner beforeEnd {
        /// team tokens are equal to 25% of the sold tokens
        uint256 teamTokens = totalSupply.mul(25).div(100);

        /// check for rounding errors when cap is reached
        if(totalSupply.add(teamTokens) > HARD_CAP) {
            teamTokens = HARD_CAP.sub(totalSupply);
        }

        /// team tokens are locked until this date (01.01.2019)
        TokenTimelock lockedTeamTokens = new TokenTimelock(this, owner, date01Jan2019);
        timelockContractAddress = address(lockedTeamTokens);
        balances[timelockContractAddress] = balances[timelockContractAddress].add(teamTokens);
        /// increase token total supply
        totalSupply = totalSupply.add(teamTokens);
        /// fire event when tokens issued
        Issue(
            issueIndex++,
            timelockContractAddress,
            teamTokens
        );

        /// burn the unallocated tokens - no more tokens can be issued after this line
        tokenSaleClosed = true;

        /// forward the raised funds to the contract creator
        owner.transfer(this.balance);
    }

    /// Transfer limited by the tradingOpen modifier (time is 01 May 2018 or later)
    function transferFrom(address _from, address _to, uint256 _value) public tradingOpen returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /// Transfer limited by the tradingOpen modifier (time is 01 May 2018 or later)
    function transfer(address _to, uint256 _value) public tradingOpen returns (bool) {
        return super.transfer(_to, _value);
    }
}
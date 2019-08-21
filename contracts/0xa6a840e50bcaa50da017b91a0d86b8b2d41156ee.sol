pragma solidity ^0.4.16;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
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
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
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
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
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

contract TokenTimelock {
    using SafeERC20 for ERC20Basic;

    // ERC20 basic token contract being held
    ERC20Basic public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint64 public releaseTime;

    function TokenTimelock(ERC20Basic _token, address _beneficiary, uint64 _releaseTime) public {
        require(_releaseTime > now);
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
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

contract EchoLinkToken is StandardToken {
    string public constant name = "EchoLink";
    string public constant symbol = "EKO";
    uint256 public constant decimals = 18;

    /// The owner of this address manages the token sale process.
    address public owner;

    /// The owner of this address will manage the sale process.
    address public saleTeamAddress;

    // this is the address of the timelock contract for the team tokens
    address public timelockContractAddress;

    uint64 contractCreatedDatetime;

    bool public tokenSaleClosed = false;

    /// Minimum amount of tokens to be sold for the sale to succeed.
    uint256 public constant GOAL = 5000 * 5000 * 10**decimals;

    /// Maximum tokens to be allocated.
    uint256 public constant TOKENS_HARD_CAP = 2 * 50000 * 5000 * 10**decimals;

    /// Maximum tokens to be allocated.
    uint256 public constant TOKENS_SALE_HARD_CAP = 50000 * 5000 * 10**decimals;

    /// Issue event index starting from 0.
    uint256 public issueIndex = 0;

    /// Emitted for each sucuessful token purchase.
    event Issue(uint _issueIndex, address addr, uint tokenAmount);

    event SaleSucceeded();

    event SaleFailed();

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    modifier onlyTeam {
        assert(msg.sender == saleTeamAddress || msg.sender == owner);
        _;
    }

    modifier inProgress {
        assert(!saleHardCapReached() && !tokenSaleClosed);
        _;
    }

    modifier beforeEnd {
        assert(!tokenSaleClosed);
        _;
    }

    function EchoLinkToken(address _saleTeamAddress) public {
        require(_saleTeamAddress != address(0));
        owner = msg.sender;
        saleTeamAddress = _saleTeamAddress;
        contractCreatedDatetime = uint64(block.timestamp);
    }

    function close(uint256 _echoTeamTokens) public onlyOwner beforeEnd {
        if (totalSupply < GOAL) {
            SaleFailed();
        } else {
            SaleSucceeded();
        }

        // compute without actually increasing it
        uint256 increasedTotalSupply = totalSupply.add(_echoTeamTokens);
        // roll back if hard cap reached
        if(increasedTotalSupply > TOKENS_HARD_CAP) {
            revert();
        }

        // increase token total supply
        totalSupply = increasedTotalSupply;

        // locked for 100 days after the contract creation
        TokenTimelock lockedTeamTokens = new TokenTimelock(this, owner, contractCreatedDatetime + (60 * 60 * 24 * 100));
        // or 100 days from this moment of the close() call
        // TokenTimelock lockedTeamTokens = new TokenTimelock(this, owner, now + (60 * 60 * 24 * 100));

        timelockContractAddress = address(lockedTeamTokens);

        //update the investors balance to number of tokens sent
        balances[timelockContractAddress] = balances[timelockContractAddress].add(_echoTeamTokens);

        //event is fired when tokens issued
        Issue(
        issueIndex++,
        timelockContractAddress,
        _echoTeamTokens
        );

        tokenSaleClosed = true;
    }

    function issueTokens(address _investor, uint256 _tokensAmount) public onlyTeam inProgress {
        require(_investor != address(0));

        // compute without actually increasing it
        uint256 increasedTotalSupply = totalSupply.add(_tokensAmount);
        // roll back if hard cap reached
        if(increasedTotalSupply > TOKENS_SALE_HARD_CAP) {
            revert();
        }

        //increase token total supply
        totalSupply = increasedTotalSupply;
        //update the investors balance to number of tokens sent
        balances[_investor] = balances[_investor].add(_tokensAmount);
        //event is fired when tokens issued
        Issue(
        issueIndex++,
        _investor,
        _tokensAmount
        );
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /// @return true if the hard cap is reached.
    function saleHardCapReached() public view returns (bool) {
        return totalSupply >= TOKENS_SALE_HARD_CAP;
    }
}
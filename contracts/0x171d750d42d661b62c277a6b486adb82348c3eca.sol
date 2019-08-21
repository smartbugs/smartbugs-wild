pragma solidity 0.4.19;


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

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
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

contract EcomToken is BurnableToken, Owned {
    string public constant name = "Omnitude Token";
    string public constant symbol = "ECOM";
    uint8 public constant decimals = 18;

    /// Maximum tokens to be allocated (100 million)
    uint256 public constant HARD_CAP = 100000000 * 10**uint256(decimals);

    /// Maximum tokens to be allocated on the sale (55 million)
    uint256 public constant TOKENS_SALE_HARD_CAP = 55000000 * 10**uint256(decimals);

    /// The owner of this address will
    address public omniTeamAddress;

    /// The owner of this address will
    address public foundationAddress;

    /// contract to be called to release the Omni team tokens for Year 1
    address public year1LockAddress;

    /// contract to be called to release the Omni team tokens for Year 2
    address public year2LockAddress;

    /// contract to be called to release the Omni team tokens for Year 3
    address public year3LockAddress;

    /// contract to be called to release the Omni team tokens for Year 4
    address public year4LockAddress;

    /// contract to be called to release the Omni team tokens for Year 5
    address public year5LockAddress;

    /// Year 1 lock date (01.01.2019)
    uint64 private constant date01Jan2019 = 1546300800;

    /// Year 2 lock date (01.01.2020)
    uint64 private constant date01Jan2020 = 1577836800;

    /// Year 3 lock date (01.01.2021)
    uint64 private constant date01Jan2021 = 1609459200;

    /// Year 4 lock date (01.01.2022)
    uint64 private constant date01Jan2022 = 1640995200;

    /// Year 5 lock date (01.01.2023)
    uint64 private constant date01Jan2023 = 1672531200;

    /// no tokens can be ever issued when this is set to "true"
    bool public tokenSaleClosed = false;

    /// Only allowed to execute while tokens can be sold
    modifier inProgress {
        require(totalSupply < TOKENS_SALE_HARD_CAP && !tokenSaleClosed);
        _;
    }

    /// Only allowed to execute while the sale is not yet closed
    modifier beforeEnd {
        require(!tokenSaleClosed);
        _;
    }

    function EcomToken(address _omniTeamAddress, address _foundationAddress) public {
        require(_omniTeamAddress != address(0));
        require(_foundationAddress != address(0));

        omniTeamAddress = _omniTeamAddress;
        foundationAddress = _foundationAddress;
        totalSupply = TOKENS_SALE_HARD_CAP;
        balances[owner] = TOKENS_SALE_HARD_CAP;
    }

    /// @dev Close the sale; issue foundation and team tokens
    function close() public onlyOwner beforeEnd {
        /// burn everything unsold
        uint256 saleTokensToBurn = balances[owner];
        balances[owner] = 0;
        totalSupply = totalSupply.sub(saleTokensToBurn);
        Burn(owner, saleTokensToBurn);

        /// Foundation tokens - 33M
        uint256 foundationTokens = 33000000 * 10**uint256(decimals);
        totalSupply = totalSupply.add(foundationTokens);
        balances[foundationAddress] = foundationTokens;

        /// Lock team tokens - 12M
        uint256 teamTokens = 12000000 * 10**uint256(decimals);
        totalSupply = totalSupply.add(teamTokens);

        /// YEAR 1 - 2.4M
        uint256 teamTokensY1 = 2400000 * 10**uint256(decimals);
        /// team tokens are locked until this date (01.01.2019)
        TokenTimelock year1Lock = new TokenTimelock(this, omniTeamAddress, date01Jan2019);
        year1LockAddress = address(year1Lock);
        balances[year1LockAddress] = teamTokensY1;

        /// YEAR 2 - 2.4M
        uint256 teamTokensY2 = 2400000 * 10**uint256(decimals);
        /// team tokens are locked until this date (01.01.2020)
        TokenTimelock year2Lock = new TokenTimelock(this, omniTeamAddress, date01Jan2020);
        year2LockAddress = address(year2Lock);
        balances[year2LockAddress] = teamTokensY2;

        /// YEAR 3 - 2.4M
        uint256 teamTokensY3 = 2400000 * 10**uint256(decimals);
        /// team tokens are locked until this date (01.01.2021)
        TokenTimelock year3Lock = new TokenTimelock(this, omniTeamAddress, date01Jan2021);
        year3LockAddress = address(year3Lock);
        balances[year3LockAddress] = teamTokensY3;

        /// YEAR 4 - 2.4M
        uint256 teamTokensY4 = 2400000 * 10**uint256(decimals);
        /// team tokens are locked until this date (01.01.2022)
        TokenTimelock year4Lock = new TokenTimelock(this, omniTeamAddress, date01Jan2022);
        year4LockAddress = address(year4Lock);
        balances[year4LockAddress] = teamTokensY4;

        /// YEAR 5 - 2.4M
        uint256 teamTokensY5 = 2400000 * 10**uint256(decimals);
        /// team tokens are locked until this date (01.01.2023)
        TokenTimelock year5Lock = new TokenTimelock(this, omniTeamAddress, date01Jan2023);
        year5LockAddress = address(year5Lock);
        balances[year5LockAddress] = teamTokensY5;

        tokenSaleClosed = true;
    }

    /// @dev Trading limited - requires the sale to have closed
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if(msg.sender != owner && !tokenSaleClosed) return false;
        return super.transferFrom(_from, _to, _value);
    }

    /// @dev Trading limited - requires the sale to have closed
    function transfer(address _to, uint256 _value) public returns (bool) {
        if(msg.sender != owner && !tokenSaleClosed) return false;
        return super.transfer(_to, _value);
    }
}
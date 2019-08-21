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

contract HotelCoin is BurnableToken, Owned {
    string public constant name = "Hotel Coin";
    string public constant symbol = "HCI";
    uint8 public constant decimals = 8;

    /// Maximum tokens to be allocated (350 million)
    uint256 public constant HARD_CAP = 350000000 * 10**uint256(decimals);

    /// The owner of this address is the HCI Liquidity Fund
    address public liquidityFundAddress;

    /// This address is used to keep the tokens for bonuses
    address public communityTokensAddress;

    /// When the sale is closed, no more tokens can be issued
    uint64 public tokenSaleClosedTime = 0;

    /// Trading opening date deadline (21/Jun/2018)
    uint64 private constant date21Jun2018 = 1529517600;

    /// Used to look up the locking contract for each locked tokens owner
    mapping(address => address) public lockingContractAddresses;

    /// Only allowed to execute before the sale is closed
    modifier beforeEnd {
        require(tokenSaleClosedTime == 0);
        _;
    }

    function HotelCoin(address _liquidityFundAddress, address _communityTokensAddress) public {
        require(_liquidityFundAddress != address(0));
        require(_communityTokensAddress != address(0));

        liquidityFundAddress = _liquidityFundAddress;
        communityTokensAddress = _communityTokensAddress;

        /// Tokens for sale, Partnership, Board of Advisors and team - 280 million HCI
        uint256 saleTokens = 280000000 * 10**uint256(decimals);
        totalSupply = saleTokens;
        balances[owner] = saleTokens;
        Transfer(0x0, owner, saleTokens);

        /// Community and Affiliates pools tokens - 52.5 million
        uint256 communityTokens = 52500000 * 10**uint256(decimals);
        totalSupply = totalSupply.add(communityTokens);
        balances[communityTokensAddress] = communityTokens;
        Transfer(0x0, communityTokensAddress, communityTokens);

        /// Liquidity tokens - 17.5 million
        uint256 liquidityTokens = 17500000 * 10**uint256(decimals);
        totalSupply = totalSupply.add(liquidityTokens);
        balances[liquidityFundAddress] = liquidityTokens;
        Transfer(0x0, liquidityFundAddress, liquidityTokens);
    }

    /// @dev start the trading countdown
    function close() public onlyOwner beforeEnd {
        require(totalSupply <= HARD_CAP);
        tokenSaleClosedTime = uint64(block.timestamp);
    }

    /// @dev Transfer timelocked tokens; ignores _releaseTime if a timelock exists already
    function transferLocking(address _to, uint256 _value, uint64 _releaseTime) public onlyOwner returns (bool) {
        address timelockAddress = lockingContractAddresses[_to];
        if(timelockAddress == address(0)) {
            TokenTimelock timelock = new TokenTimelock(this, _to, _releaseTime);
            timelockAddress = address(timelock);
            lockingContractAddresses[_to] = timelockAddress;
        }

        return super.transfer(timelockAddress, _value);
    }

    /// @dev check the locked balance of an owner
    function lockedBalanceOf(address _owner) public view returns (uint256) {
        return balances[lockingContractAddresses[_owner]];
    }

    /// @dev get the TokenTimelock contract address for an owner
    function timelockOf(address _owner) public view returns (address) {
        return lockingContractAddresses[_owner];
    }

    /// @dev 21 days after the closing of the sale
    function tradingOpen() public view returns (bool) {
        return (tokenSaleClosedTime != 0 && block.timestamp > tokenSaleClosedTime + 60 * 60 * 24 * 21)
        || block.timestamp > date21Jun2018;
    }

    /// @dev Trading limited - requires 3 weeks to have passed since the sale closed
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if(tradingOpen() || msg.sender == owner || msg.sender == communityTokensAddress) {
            return super.transferFrom(_from, _to, _value);
        }
        return false;
    }

    /// @dev Trading limited - requires 3 weeks to have passed since the sale closed
    function transfer(address _to, uint256 _value) public returns (bool) {
        if(tradingOpen() || msg.sender == owner || msg.sender == communityTokensAddress) {
            return super.transfer(_to, _value);
        }
        return false;
    }
}
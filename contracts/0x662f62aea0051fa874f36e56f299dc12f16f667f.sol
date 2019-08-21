pragma solidity ^0.4.24;

/**
 * @dev Library that helps prevent integer overflows and underflows,
 * inspired by https://github.com/OpenZeppelin/zeppelin-solidity
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }
}

/**
 * @title HasOwner
 *
 * @dev Allows for exclusive access to certain functionality.
 */
contract HasOwner {
    // Current owner.
    address public owner;

    // Conditionally the new owner.
    address public newOwner;

    /**
     * @dev The constructor.
     *
     * @param _owner The address of the owner.
     */
    constructor (address _owner) internal {
        owner = _owner;
    }

    /**
     * @dev Access control modifier that allows only the current owner to call the function.
     */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev The event is fired when the current owner is changed.
     *
     * @param _oldOwner The address of the previous owner.
     * @param _newOwner The address of the new owner.
     */
    event OwnershipTransfer(address indexed _oldOwner, address indexed _newOwner);

    /**
     * @dev Transfering the ownership is a two-step process, as we prepare
     * for the transfer by setting `newOwner` and requiring `newOwner` to accept
     * the transfer. This prevents accidental lock-out if something goes wrong
     * when passing the `newOwner` address.
     *
     * @param _newOwner The address of the proposed new owner.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    /**
     * @dev The `newOwner` finishes the ownership transfer process by accepting the
     * ownership.
     */
    function acceptOwnership() public {
        require(msg.sender == newOwner);

        emit OwnershipTransfer(owner, newOwner);

        owner = newOwner;
    }
}

/**
 * @dev The standard ERC20 Token interface.
 */
contract ERC20TokenInterface {
    uint256 public totalSupply;  /* shorthand for public function and a property */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
}

/**
 * @title ERC20Token
 *
 * @dev Implements the operations declared in the `ERC20TokenInterface`.
 */
contract ERC20Token is ERC20TokenInterface {
    using SafeMath for uint256;

    // Token account balances.
    mapping (address => uint256) balances;

    // Delegated number of tokens to transfer.
    mapping (address => mapping (address => uint256)) allowed;

    /**
     * @dev Checks the balance of a certain address.
     *
     * @param _account The address which's balance will be checked.
     *
     * @return Returns the balance of the `_account` address.
     */
    function balanceOf(address _account) public constant returns (uint256 balance) {
        return balances[_account];
    }

    /**
     * @dev Transfers tokens from one address to another.
     *
     * @param _to The target address to which the `_value` number of tokens will be sent.
     * @param _value The number of tokens to send.
     *
     * @return Whether the transfer was successful or not.
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] < _value || _value == 0) {

            return false;
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * @dev Send `_value` tokens to `_to` from `_from` if `_from` has approved the process.
     *
     * @param _from The address of the sender.
     * @param _to The address of the recipient.
     * @param _value The number of tokens to be transferred.
     *
     * @return Whether the transfer was successful or not.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] < _value || allowed[_from][msg.sender] < _value || _value == 0) {
            return false;
        }

        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    /**
     * @dev Allows another contract to spend some tokens on your behalf.
     *
     * @param _spender The address of the account which will be approved for transfer of tokens.
     * @param _value The number of tokens to be approved for transfer.
     *
     * @return Whether the approval was successful or not.
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @dev Shows the number of tokens approved by `_owner` that are allowed to be transferred by `_spender`.
     *
     * @param _owner The account which allowed the transfer.
     * @param _spender The account which will spend the tokens.
     *
     * @return The number of tokens to be transferred.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * Don't accept ETH
     */
    function () public payable {
        revert();
    }
}

/**
 * @title BonusCloudTokenConfig
 *
 * @dev The static configuration for the Bonus Cloud Token.
 */
contract BonusCloudTokenConfig {
    // The name of the token.
    string constant NAME = "BATTest";

    // The symbol of the token.
    string constant SYMBOL = "BATTest";

    // The number of decimals for the token.
    uint8 constant DECIMALS = 18;

    // Decimal factor for multiplication purposes.
    uint256 constant DECIMALS_FACTOR = 10 ** uint(DECIMALS);

    // TotalSupply
    uint256 constant TOTAL_SUPPLY = 7000000000 * DECIMALS_FACTOR;

    // The start date of the fundraiser: 2018-09-04 0:00:00 UTC.
    uint constant START_DATE = 1536019200;

    // Total number of tokens locked for the BxC core team.
    uint256 constant TOKENS_LOCKED_CORE_TEAM = 1400 * (10**6) * DECIMALS_FACTOR;

    // Total number of tokens for BxC advisors.
    uint256 constant TOKENS_LOCKED_ADVISORS = 2100 * (10**6) * DECIMALS_FACTOR;

    // Total number of tokens for BxC advisors A.
    uint256 constant TOKENS_LOCKED_ADVISORS_A = 350 * (10**6) * DECIMALS_FACTOR;

    // Total number of tokens for BxC advisors B.
    uint256 constant TOKENS_LOCKED_ADVISORS_B = 350 * (10**6) * DECIMALS_FACTOR;

    // Total number of tokens for BxC advisors C.
    uint256 constant TOKENS_LOCKED_ADVISORS_C = 700 * (10**6) * DECIMALS_FACTOR;

    // Total number of tokens for BxC advisors D.
    uint256 constant TOKENS_LOCKED_ADVISORS_D = 700 * (10**6) * DECIMALS_FACTOR;

    // Total number of tokens locked for bxc foundation.
    uint256 constant TOKEN_FOUNDATION = 700 * (10**6) * DECIMALS_FACTOR;

    // Total number of tokens locked for bounty program.
    uint256 constant TOKENS_BOUNTY_PROGRAM = 2800 * (10**6) * DECIMALS_FACTOR;
}

/**
 * @title Bonus Cloud Token
 *
 * @dev A standard token implementation of the ERC20 token standard with added
 *      HasOwner trait and initialized using the configuration constants.
 */
contract BonusCloudToken is BonusCloudTokenConfig, HasOwner, ERC20Token {
    // The name of the token.
    string public name;

    // The symbol for the token.
    string public symbol;

    // The decimals of the token.
    uint8 public decimals;

    /**
     * @dev The constructor.
     *
     */
    constructor() public HasOwner(msg.sender) {
        name = NAME;
        symbol = SYMBOL;
        decimals = DECIMALS;
        totalSupply = TOTAL_SUPPLY;
        balances[owner] = TOTAL_SUPPLY;
    }
}

/**
 * @title TokenSafeVesting
 *
 * @dev A multi-bundle token safe contract
 */
contract TokenSafeVesting is HasOwner {
    using SafeMath for uint256;

    // The Total number of tokens locked.
    uint256 total;
    uint256 lapsedTotal;
    address account;

    uint[] vestingCommencementDates;
    uint[] vestingPercents;

    bool revocable;
    bool revoked;

    // The `ERC20TokenInterface` contract.
    ERC20TokenInterface token;

    /**
     * @dev constructor new account with locked token balance
     *
     * @param _token The erc20 token address.
     * @param _account The address of th account.
     * @param _balanceTotal The number of tokens to be locked.
     * @param _vestingCommencementDates The vesting commenement date list.
     * @param _vestingPercents The vesting percents list.
     * @param _revocable Whether the vesting is revocable
     */
     constructor (
        address _token,
        address _account,
        uint256 _balanceTotal,
        uint[] _vestingCommencementDates,
        uint[] _vestingPercents,
        bool _revocable) public HasOwner(msg.sender) {

        // check _vestingCommencementDates and _vestingPercents
        require(_vestingPercents.length > 0);
        require(_vestingCommencementDates.length == _vestingPercents.length);
        uint percentSum;
        for (uint32 i = 0; i < _vestingPercents.length; i++) {
            require(_vestingPercents[i]>=0);
            require(_vestingPercents[i]<=100);
            percentSum = percentSum.add(_vestingPercents[i]);
            require(_vestingCommencementDates[i]>0);
            if (i > 0) {
                require(_vestingCommencementDates[i] > _vestingCommencementDates[i-1]);
            }
        }
        require(percentSum==100);

        token = ERC20TokenInterface(_token);
        account = _account;
        total = _balanceTotal;
        vestingCommencementDates = _vestingCommencementDates;
        vestingPercents = _vestingPercents;
        revocable = _revocable;
    }

    /**
     * @dev Allow the account to be released some token if it meets some vesting commencement date.
     * TODO: public -> internal ?
     */
    function release() public {
        require(!revoked);

        uint256 grant;
        uint percent;
        for (uint32 i = 0; i < vestingCommencementDates.length; i++) {
            if (block.timestamp < vestingCommencementDates[i]) {
            } else {
                percent += vestingPercents[i];
            }
        }
        grant = total.mul(percent).div(100);

        if (grant > lapsedTotal) {
            uint256 tokens = grant.sub(lapsedTotal);
            lapsedTotal = lapsedTotal.add(tokens);
            if (!token.transfer(account, tokens)) {
                revert();
            } else {
            }
        }
    }

    /**
     * @dev Revoke token
     */
    function revoke() public onlyOwner {
        require(revocable);
        require(!revoked);

        release();
        revoked = true;
    }
}

contract BonusCloudTokenFoundation is BonusCloudToken {

    // Vesting Token Pools
    mapping (address => TokenSafeVesting) vestingTokenPools;

    function addLockedAccount(
        address _account,
        uint256 _balanceTotal,
        uint[] _vestingCommencementDates,
        uint[] _vestingPercents,
        bool _revocable) internal onlyOwner {

        TokenSafeVesting vestingToken = new TokenSafeVesting(
            this,
            _account,
            _balanceTotal,
            _vestingCommencementDates,
            _vestingPercents,
            _revocable);

        vestingTokenPools[_account] = vestingToken;
        transfer(vestingToken, _balanceTotal);
    }

    function releaseAccount(address _account) public {
        TokenSafeVesting vestingToken;
        vestingToken = vestingTokenPools[_account];
        vestingToken.release();
    }

    function revokeAccount(address _account) public onlyOwner {
        TokenSafeVesting vestingToken;
        vestingToken = vestingTokenPools[_account];
        vestingToken.revoke();
    }

    constructor() public {
        // bxc foundation
        uint[] memory DFoundation = new uint[](1);
        DFoundation[0] = START_DATE;
        uint[] memory PFoundation = new uint[](1);
        PFoundation[0] = 100;
        addLockedAccount(0x4eE4F2A51EFf3DDDe7d7be6Da37Bb7f3F08771f7, TOKEN_FOUNDATION, DFoundation, PFoundation, false);

        uint[] memory DAdvisorA = new uint[](5);
        DAdvisorA[0] = START_DATE;
        DAdvisorA[1] = START_DATE + 90 days;
        DAdvisorA[2] = START_DATE + 180 days;
        DAdvisorA[3] = START_DATE + 270 days;
        DAdvisorA[4] = START_DATE + 365 days;
        uint[] memory PAdvisorA = new uint[](5);
        PAdvisorA[0] = 35;
        PAdvisorA[1] = 17;
        PAdvisorA[2] = 16;
        PAdvisorA[3] = 16;
        PAdvisorA[4] = 16;
        addLockedAccount(0x67a25099C3958b884687663C17d22e88C83e9F9A, TOKENS_LOCKED_ADVISORS_A, DAdvisorA, PAdvisorA, false);

        // advisor b
        uint[] memory DAdvisorB = new uint[](5);
        DAdvisorB[0] = START_DATE;
        DAdvisorB[1] = START_DATE + 90 days;
        DAdvisorB[2] = START_DATE + 180 days;
        DAdvisorB[3] = START_DATE + 270 days;
        DAdvisorB[4] = START_DATE + 365 days;
        uint[] memory PAdvisorB = new uint[](5);
        PAdvisorB[0] = 35;
        PAdvisorB[1] = 17;
        PAdvisorB[2] = 16;
        PAdvisorB[3] = 16;
        PAdvisorB[4] = 16;
        addLockedAccount(0x3F756EA6F3a9d0e24f9857506D0E76cCCbAcFd59, TOKENS_LOCKED_ADVISORS_B, DAdvisorB, PAdvisorB, false);

        // advisor c
        uint[] memory DAdvisorC = new uint[](4);
        DAdvisorC[0] = START_DATE + 90 days;
        DAdvisorC[1] = START_DATE + 180 days;
        DAdvisorC[2] = START_DATE + 270 days;
        DAdvisorC[3] = START_DATE + 365 days;
        uint[] memory PAdvisorC = new uint[](4);
        PAdvisorC[0] = 25;
        PAdvisorC[1] = 25;
        PAdvisorC[2] = 25;
        PAdvisorC[3] = 25;
        addLockedAccount(0x0022F267eb8A8463C241e3bd23184e0C7DC783F3, TOKENS_LOCKED_ADVISORS_C, DAdvisorC, PAdvisorC, false);

        // bxc core team
        uint[] memory DCoreTeam = new uint[](12);
        DCoreTeam[0] = START_DATE + 90 days;
        DCoreTeam[1] = START_DATE + 180 days;
        DCoreTeam[2] = START_DATE + 270 days;
        DCoreTeam[3] = START_DATE + 365 days;
        DCoreTeam[4] = START_DATE + 365 days + 90 days;
        DCoreTeam[5] = START_DATE + 365 days + 180 days;
        DCoreTeam[6] = START_DATE + 365 days + 270 days;
        DCoreTeam[7] = START_DATE + 365 days + 365 days;
        DCoreTeam[8] = START_DATE + 730 days + 90 days;
        DCoreTeam[9] = START_DATE + 730 days + 180 days;
        DCoreTeam[10] = START_DATE + 730 days + 270 days;
        DCoreTeam[11] = START_DATE + 730 days + 365 days;
        uint[] memory PCoreTeam = new uint[](12);
        PCoreTeam[0] = 8;
        PCoreTeam[1] = 8;
        PCoreTeam[2] = 8;
        PCoreTeam[3] = 9;
        PCoreTeam[4] = 8;
        PCoreTeam[5] = 8;
        PCoreTeam[6] = 9;
        PCoreTeam[7] = 9;
        PCoreTeam[8] = 8;
        PCoreTeam[9] = 8;
        PCoreTeam[10] = 8;
        PCoreTeam[11] = 9;
        addLockedAccount(0xaEF494C6Af26ef6D9551E91A36b0502A216fF276, TOKENS_LOCKED_CORE_TEAM, DCoreTeam, PCoreTeam, false);

        // bxc test dev
        uint[] memory DTest = new uint[](2);
        DTest[0] = START_DATE + 12 hours;
        DTest[1] = START_DATE + 16 hours;
        uint[] memory PTest = new uint[](2);
        PTest[0] = 50;
        PTest[1] = 50;
        addLockedAccount(0x67a25099C3958b884687663C17d22e88C83e9F9A, 10 * (10**6) * DECIMALS_FACTOR, DTest, PTest, false);
    }
}
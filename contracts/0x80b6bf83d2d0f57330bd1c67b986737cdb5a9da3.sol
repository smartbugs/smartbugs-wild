pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


library ECStructs {

    struct ECDSASig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}

contract ILotteryForCoke {
    struct Ticket {
        address payable ticketAddress;
        uint256 period;
        address payable buyer;
        uint256 amount;
        uint256 salt;
    }

    function buy(Ticket memory ticket, ECStructs.ECDSASig memory serverSig) public returns (bool);

    function calcTicketPrice(Ticket memory ticket) public view returns (uint256 cokeAmount);
}

contract IPledgeForCoke {

    struct DepositRequest {
        address payable depositAddress;
        address payable from;
        uint256 cokeAmount;
        uint256 endBlock;
        bytes32 billSeq;
        bytes32 salt;
    }

    //the buyer should approve enough coke and then call this function
    //or use 'approveAndCall' in Coke.sol in 1 request
    function deposit(DepositRequest memory request, ECStructs.ECDSASig memory ecdsaSig) payable public returns (bool);

    function depositCheck(DepositRequest memory request, ECStructs.ECDSASig memory ecdsaSig) public view returns (uint256);
}


library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath, mul");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath, div");
        // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath, sub");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath, add");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath, mod");
        return a % b;
    }
}

contract IRequireUtils {
    function requireCode(uint256 code) external pure;

    function interpret(uint256 code) public pure returns (string memory);
}



interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ReentrancyGuard {

    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor() internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "nonReentrant");
    }

}

contract ERC20 is IERC20, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(
        address owner,
        address spender
    )
    public
    view
    returns (uint256)
    {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "ERC20 approve, spender can not be 0x00");

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    //be careful, this is 'internal' function,
    //you must add control permission to manipulate this function
    function approveFrom(address owner, address spender, uint256 value) internal returns (bool) {
        require(spender != address(0), "ERC20 approveFrom, spender can not be 0x00");

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
    public
    returns (bool)
    {
        require(value <= _allowed[from][msg.sender], "ERC20 transferFrom, allowance not enough");

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
    public
    returns (bool)
    {
        require(spender != address(0), "ERC20 increaseAllowance, spender can not be 0x00");

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }


    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
    public
    returns (bool)
    {
        require(spender != address(0), "ERC20 decreaseAllowance, spender can not be 0x00");

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[from], "ERC20 _transfer, not enough balance");
        require(to != address(0), "ERC20 _transfer, to address can not be 0x00");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0), "ERC20 _mint, account can not be 0x00");
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20 _burn, account can not be 0x00");
        require(value <= _balances[account], "ERC20 _burn, not enough balance");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        require(value <= _allowed[account][msg.sender], "ERC20 _burnFrom, allowance not enough");

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
            value);
        _burn(account, value);
    }
}

contract Coke is ERC20{
    using SafeMath for uint256;

    IRequireUtils rUtils;

    //1 Coke = 10^18 Tin
    string public name = "COKE";
    string public symbol = "COKE";
    uint256 public decimals = 18; //1:1

    address public cokeAdmin;// admin has rights to mint and burn and etc.
    mapping(address => bool) public gameMachineRecords;// game machine has permission to mint coke


    uint256 public stagePercent;
    uint256 public step;
    uint256 public remain;
    uint256 public currentDifficulty;//starts from 0
    uint256 public currentStageEnd;

    address team;
    uint256 public teamRemain;
    uint256 public unlockAllBlockNumber;
    uint256 unlockNumerator;
    uint256 unlockDenominator;

    event Reward(address indexed account, uint256 amount, uint256 rawAmount);
    event UnlockToTeam(address indexed account, uint256 amount, uint256 rawReward);

    constructor (IRequireUtils _rUtils, address _cokeAdmin, uint256 _cap, address _team, uint256 _toTeam,
        uint256 _unlockAllBlockNumber, address _bounty, uint256 _toBounty, uint256 _stagePercent,
        uint256 _unlockNumerator, uint256 _unlockDenominator) /*ERC20Capped(_cap) */public {
        rUtils = _rUtils;
        cokeAdmin = _cokeAdmin;
        unlockAllBlockNumber = _unlockAllBlockNumber;

        team = _team;
        teamRemain = _toTeam;

        _mint(address(this), _toTeam);

        _mint(_bounty, _toBounty);

        stagePercent = _stagePercent;
        step = _cap * _stagePercent / 100;
        remain = _cap.sub(_toTeam).sub(_toBounty);

        _mint(address(this), remain);

        unlockNumerator = _unlockNumerator;
        unlockDenominator=_unlockDenominator;
        if (remain - step > 0) {
            currentStageEnd = remain - step;
        } else {
            currentStageEnd = 0;
        }
        currentDifficulty = 0;
    }

    function approveAndCall(address spender, uint256 value, bytes memory data) public nonReentrant returns (bool) {
        require(approve(spender, value));

        (bool success, bytes memory returnData) = spender.call(data);
        rUtils.requireCode(success ? 0 : 501);

        return true;
    }

    function approveAndBuyLottery(ILotteryForCoke.Ticket memory ticket, ECStructs.ECDSASig memory serverSig) public nonReentrant returns (bool){
        rUtils.requireCode(approve(ticket.ticketAddress, ILotteryForCoke(ticket.ticketAddress).calcTicketPrice(ticket)) ? 0 : 506);
        rUtils.requireCode(ILotteryForCoke(ticket.ticketAddress).buy(ticket, serverSig) ? 0 : 507);
        return true;
    }

    function approveAndPledgeCoke(IPledgeForCoke.DepositRequest memory depositRequest, ECStructs.ECDSASig memory serverSig) public nonReentrant returns (bool){
        rUtils.requireCode(approve(depositRequest.depositAddress, depositRequest.cokeAmount) ? 0 : 508);
        rUtils.requireCode(IPledgeForCoke(depositRequest.depositAddress).deposit(depositRequest, serverSig) ? 0 : 509);
        return true;
    }

    function betReward(address _account, uint256 _amount) public mintPermission returns (uint256 minted){
        uint256 input = _amount;
        uint256 totalMint = 0;
        while (input > 0) {

            uint256 factor = 2 ** currentDifficulty;
            uint256 discount = input / factor;
            if (input % factor != 0) {
                discount ++;
            }

            if (discount > remain - currentStageEnd) {
                uint256 toMint = remain - currentStageEnd;
                totalMint += toMint;
                input = input - toMint * factor;
                remain = currentStageEnd;
            } else {
                totalMint += discount;
                input = 0;
                remain = remain - discount;
            }

            //update to next stage
            if (remain == currentStageEnd) {
                if (currentStageEnd != 0) {
                    currentDifficulty = currentDifficulty + 1;
                    if (remain - step > 0) {
                        currentStageEnd = remain - step;
                    } else {
                        currentStageEnd = 0;
                    }
                } else {
                    input = 0;
                }
            }
        }
        _transfer(address(this), _account, totalMint);
        emit Reward(_account, totalMint, _amount);

        uint256 mintToTeam = totalMint * unlockDenominator / unlockNumerator;
        if (teamRemain >= mintToTeam) {
            teamRemain = teamRemain - mintToTeam;
            _transfer(address(this), team, mintToTeam);
            emit UnlockToTeam(team, mintToTeam, totalMint);
        }

        return totalMint;
    }

    
    function setGameMachineRecords(address _input, bool _isActivated) public onlyCokeAdmin {
        gameMachineRecords[_input] = _isActivated;
    }

    function unlockAllTeamCoke() public onlyCokeAdmin {
        if (block.number > unlockAllBlockNumber) {
            _transfer(address(this), team, teamRemain);
            teamRemain = 0;
            emit UnlockToTeam(team, teamRemain, 0);
        }
    }

    modifier onlyCokeAdmin(){
        rUtils.requireCode(msg.sender == cokeAdmin ? 0 : 503);
        _;
    }


    modifier mintPermission(){
        rUtils.requireCode(gameMachineRecords[msg.sender] == true ? 0 : 505);
        _;
    }
}
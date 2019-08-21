pragma solidity ^0.4.13;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) returns (bool);
    function approve(address spender, uint256 value) returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
    function transfer(address _to, uint256 _value) returns (bool) {
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
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
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

    mapping (address => mapping (address => uint256)) allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifing the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

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
    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);

    event MintFinished();
    event MintStarted();

    bool public mintingActive = true;

    uint256 public maxTokenCount;

    modifier canMint() {
        require(mintingActive);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
        require(totalSupply <= maxTokenCount);

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function stopMinting() onlyOwner returns (bool) {
        mintingActive = false;
        MintFinished();
        return true;
    }

    /**
     * @dev Function to start minting new tokens.
     * @return True if the operation was successful.
     */
    function startMinting() onlyOwner returns (bool) {
        mintingActive = true;
        MintStarted();
        return true;
    }
}


/**
 * HDL (Handelion) Token
 *
 */
contract HDLToken is MintableToken
{

    string public constant name = "Handelion  token";

    string public constant symbol = "HDLT";

    uint32 public constant decimals = 18;

    function HDLToken()
    {
     	maxTokenCount = 29750000 * 1 ether;
    }
}


contract HDLContract is Ownable {

    using SafeMath for uint;

	// Contract owner addredd
	address _ownerAddress;

    // Contract vault address - all collected funds are moved to this address after successful sale
    address _vaultAddress;

    // Contains list of all investor addresses
    address[] public _investorAddresses;

    // contains list of all investors with transfered amount
    mapping (address => uint256) _investors;

    // Reference to HDL token. The token is created with this contract.
    HDLToken public token;

    // Sale period start date as unix timestamp
    uint _start;

    // Sale period in days
    uint _period;

    // Sale goal in tokens - how many tokens we are planning to sel under this contract
    uint public _goal;

    // Token/ether rate
    uint _rate;

    // Total amount of issued tokens under this contract
    uint256 public issuedTokens;

    // total amount of all collected funds under this contract
    uint256 public collectedFunds;

    // Identifies whether current contract is finished. If contract is finished no more funds can be sent to this contract.
    // When contract has been marked as finished it cannot be restarted.
    bool public isFinished = false;

    // Identifies whether contract is in refunding mode - Refunding is opened and investors can request their funds back.
    bool public isRefunding = false;

    // Raises when particular investor is refunded
    event InvestorRefunded(address indexed beneficiary, uint256 weiAmount);

    // Raises when particular investor bought some tokens from contract
    event FundingAccepted(address indexed investor, uint256 weiAmount, uint tokenAmount);

    // Raises when all investors were refunded
    event AllInvestorsRefunded(uint refundedInvestorCount);

    // Raises when all funds have been withdrawn
    event WithdrawAllFunds(uint256 withdrawnAmount);

    // Raises when crowdsale has been finished
    event CrowdsaleFinished();

    // Raises when crowdsale goal has been reached
    event GoalReached();

    function HDLContract(address aVaultAddress, uint aStart, uint aPeriod, uint aGoal, uint aRate) {
        _ownerAddress = msg.sender;
        _vaultAddress =  aVaultAddress;
        token = new HDLToken();
        _rate =  aRate;
        _start = aStart;
        _period = aPeriod;
        _goal =  aGoal * 1 ether;

        issuedTokens = 0;
        collectedFunds = 0;
    }

    /**
	 * Transfers token ownership from Pre-sale to Sale
     */
    function TransferTokenOwnership(address newTokenOwner) public onlyOwner
	{
		token.transferOwnership(newTokenOwner);
	}

    /**
     * Finishes PRE-ICO crowdsale and closes current contract.
     * Checks is goal is reached. If it is reached then withdraws all funds to vault address
     * Otherwise tries to refund investors or Opens contract for refunding.
     *
     */
    function finish() public onlyOwner {
        require(!isFinished);

        token.stopMinting();
        isFinished = true;

        if (issuedTokens < _goal)
        {
            isRefunding = true;
        } else
        {
            withdraw();
        }

        CrowdsaleFinished();
    }

    /**
     * Refunds investor. Should be called by investors.
     * If contract state is in Refunding state then returns to investor sent amount.
     *
     */
    function requestRefunding() public
    {
        require(isRefunding);

        address investorAddress = msg.sender;
        refundInvestor(investorAddress);
    }

    /**
     * Accepts ethers from investor and sends back HDL tokens.
     */
    function buyTokens() payable
    {
        require(!isFinished);
        require(isContractActive());
        require(!isGoalReached());

        uint tokens = _rate.mul(msg.value);

        token.mint(this, tokens);
        token.transfer(msg.sender, tokens);

        issuedTokens = issuedTokens.add(tokens);
        _investors[msg.sender] = _investors[msg.sender].add(msg.value);
        _investorAddresses.push(msg.sender);

        collectedFunds = collectedFunds.add(msg.value);

        FundingAccepted(msg.sender, msg.value, tokens);

        if (issuedTokens >= _goal)
        {
            GoalReached();
        }
    }

    function() external payable {
        buyTokens();
    }

    function closeContract() onlyOwner {
        token.stopMinting();
        isFinished = true;
    }

    function withdraw() onlyOwner {
        if (this.balance > 0) {
            _vaultAddress.transfer(this.balance);
        }

        WithdrawAllFunds(this.balance);
    }

    function refundInvestor(address aInvestorAddress) onlyOwner returns(bool)
    {
        if (aInvestorAddress == 0x0)
        {
            return false;
        }

        uint256 depositedValue = _investors[aInvestorAddress];

        if (depositedValue <= 0)
        {
            return false;
        }

        _investors[aInvestorAddress] = 0;

        aInvestorAddress.transfer(depositedValue);
        InvestorRefunded(aInvestorAddress, depositedValue);

        return true;
    }

    function isContractActive() returns (bool)
    {
        return (now > _start) && (now < (_start + _period * 1 days));
    }

    function isGoalReached() returns (bool)
    {
        return issuedTokens >= _goal;
    }
}
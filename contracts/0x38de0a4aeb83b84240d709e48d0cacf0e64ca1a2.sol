pragma solidity 0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint256) {
        uint c = a / b;
        return c;
    }

    function sub(uint256 a, uint b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint a, uint b) internal pure returns (uint) {
        uint c = a ** b;
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
    function balanceOf(address _who) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    /// seconds since 01.01.1970 to 17.02.2018 00:00:00 GMT
    uint64 public dateTransferable = 1518825600;

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        uint64 _now = uint64(block.timestamp);
        require(_now >= dateTransferable);
        require(_to != address(this)); // Don't allow to transfer tokens to contract address
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _address The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _address) public view returns (uint256) {
        return balances[_address];
    }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender) public constant returns (uint256);
    function transferFrom(address _from, address _to, uint256 value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/** 
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

    /**
     * @dev The Ownable constructor sets the original 'owner' of the contract to the sender account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        Pause();
        return true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        Unpause();
        return true;
    }
}


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is BasicToken, Ownable {

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(uint256 _amount) public onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[owner] = balances[owner].add(_amount);
        Mint(owner, _amount);
        Transfer(0x0, owner, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() public onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}


/**
 * @title Xineoken
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract Xineoken is BasicToken, Ownable, Pausable, MintableToken {

    using SafeMath for uint256;
    
    string public name = "Xineoken";
    uint256 public decimals = 2;
    string public symbol = "XIN";

    /// price for a single token
    uint256 public buyPrice = 10526315789474;
    /// price for a single token after the 2nd stage of tokens
    uint256 public buyPriceFinal = 52631578947368;
    /// number of tokens sold
    uint256 public allocatedTokens = 0;
    /// first tier of tokens at a discount
    uint256 public stage1Tokens = 330000000 * (10 ** decimals);
    /// second tier of tokens at a discount
    uint256 public stage2Tokens = 660000000 * (10 ** decimals);
    /// minimum amount in wei 0.1 ether
    uint256 public minimumBuyAmount = 100000000000000000;
    
    function Xineoken() public {
        totalSupply = 1000000000 * (10 ** decimals);
        balances[owner] = totalSupply;
    }

    // fallback function can be used to buy tokens
    function () public payable {
        buyToken();
    }
    
    /**
     * @dev Calculate the number of tokens based on the current stage
     * @param _value The amount of wei
     * @return The number of tokens
     */
    function calculateTokenAmount(uint256 _value) public view returns (uint256) {

        var tokenAmount = uint256(0);
        var tokenAmountCurrentStage = uint256(0);
        var tokenAmountNextStage = uint256(0);
  
        var stage1TokensNoDec = stage1Tokens / (10 ** decimals);
        var stage2TokensNoDec = stage2Tokens / (10 ** decimals);
        var allocatedTokensNoDec = allocatedTokens / (10 ** decimals);
  
        if (allocatedTokensNoDec < stage1TokensNoDec) {
            tokenAmount = _value / buyPrice;
            if (tokenAmount.add(allocatedTokensNoDec) > stage1TokensNoDec) {
                tokenAmountCurrentStage = stage1TokensNoDec.sub(allocatedTokensNoDec);
                tokenAmountNextStage = (_value.sub(tokenAmountCurrentStage.mul(buyPrice))) / (buyPrice * 2);
                tokenAmount = tokenAmountCurrentStage + tokenAmountNextStage;
            }
        } else if (allocatedTokensNoDec < (stage2TokensNoDec)) {
            tokenAmount = _value / (buyPrice * 2);
            if (tokenAmount.add(allocatedTokensNoDec) > stage2TokensNoDec) {
                tokenAmountCurrentStage = stage2TokensNoDec.sub(allocatedTokensNoDec);
                tokenAmountNextStage = (_value.sub(tokenAmountCurrentStage.mul(buyPrice * 2))) / buyPriceFinal;
                tokenAmount = tokenAmountCurrentStage + tokenAmountNextStage;
            }
        } else {
            tokenAmount = _value / buyPriceFinal;
        }

        return tokenAmount;
    }

    /**
     * @dev Buy tokens when the contract is not paused.
     */
    function buyToken() public whenNotPaused payable {

        require(msg.sender != 0x0);
        require(msg.value >= minimumBuyAmount);
        
        uint256 weiAmount = msg.value;
        uint256 tokens = calculateTokenAmount(weiAmount);

        require(tokens > 0);

        uint256 totalTokens = tokens * (10 ** decimals);

        balances[owner] = balances[owner].sub(totalTokens);
        balances[msg.sender] = balances[msg.sender].add(totalTokens);
        allocatedTokens = allocatedTokens.add(totalTokens);
        Transfer(owner, msg.sender, totalTokens);
        
        forwardFunds();
    }

    /**
     * @dev Allocate tokens to an address
     * @param _to Address where tokens should be allocated to.
     * @param _tokens Amount of tokens.
     * @return True if the operation was successful.
     */
    function allocateTokens(address _to, uint256 _tokens) public onlyOwner returns (bool) {
        require(balanceOf(owner) >= _tokens);
        balances[owner] = balances[owner].sub(_tokens);
        balances[_to] = balances[_to].add(_tokens);
        allocatedTokens = allocatedTokens.add(_tokens);
        Transfer(owner, _to, _tokens);
        return true;
    }

    /** 
     * @param _newBuyPrice Price in wei users can buy from the contract.
     * @param _newBuyPriceFinal Final price in wei users can buy from the contract.
     * @return True if the operation was successful.
     */
    function setBuyPrice(uint256 _newBuyPrice, uint256 _newBuyPriceFinal) public onlyOwner returns (bool) {
        buyPrice = _newBuyPrice;
        buyPriceFinal = _newBuyPriceFinal;
        return true;
    }

    /**
     * @dev Set the date tokens can be transferred.
     * @param _date The date after tokens can be transferred.
     */
    function setTransferableDate(uint64 _date) public onlyOwner {
        dateTransferable = _date;
    }

    /**
     * @dev Set the minimum buy amount in wei.
     * @param _amount Wei amount.
     */
    function setMinimumBuyAmount(uint256 _amount) public onlyOwner {
        minimumBuyAmount = _amount;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            // transfer tokens from owner to new owner
            var previousOwner = owner;
            var ownerBalance = balances[previousOwner];
            balances[previousOwner] = balances[previousOwner].sub(ownerBalance);
            balances[newOwner] = balances[newOwner].add(ownerBalance);
            owner = newOwner;
            Transfer(previousOwner, newOwner, ownerBalance);
        }
    }

    /**
     * @dev Forward funds to owner address
     */
    function forwardFunds() internal {
        if (!owner.send(msg.value)) {
            revert();
        }
    }
}
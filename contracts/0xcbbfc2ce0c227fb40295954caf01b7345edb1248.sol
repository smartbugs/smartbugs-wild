pragma solidity ^0.4.24;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 * https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
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
        require(c / a == b,"");

        return c;
    }
  
    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0,""); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
  
        return c;
    }
  
    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a,"");
        uint256 c = a - b;

        return c;
    }
  
    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a,"");

        return c;
    }
  
    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0,"");
        return a % b;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;
  
  
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
      address indexed previousOwner,
      address indexed newOwner
    );
  
  
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        _owner = msg.sender;
    }
  
    /**
     * @return the address of the owner.
     */
    function owner() public view returns(address) {
        return _owner;
    }
  
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(),"owner required");
        _;
    }
  
    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }
  
    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }
  
    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
  
    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0),"");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract EIP20Interface {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name  
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract CryptojoyTokenSeller is Ownable {
    using SafeMath for uint;

    uint8 public constant decimals = 18;
    
    uint public miningSupply; // minable part

    uint constant MAGNITUDE = 10**6;
    uint constant LOG1DOT5 = 405465; // log(1.5) under MAGNITUDE
    uint constant THREE_SECOND= 15 * MAGNITUDE / 10; // 1.5 under MAGNITUDE

    uint public a; // paremeter a of the price fuction price = a*log(t)+b, 18 decimals
    uint public b; // paremeter b of the price fuction price = a*log(t)+b, 18 decimals
    uint public c; // paremeter exchange rate of eth 
    uint public blockInterval; // number of blocks where the token price is fixed
    uint public startBlockNumber; // The starting block that the token can be mint.

    address public platform;
    uint public lowerBoundaryETH; // Refuse incoming ETH lower than this value
    uint public upperBoundaryETH; // Refuse incoming ETH higher than this value

    uint public supplyPerInterval; // miningSupply / MINING_INTERVAL
    uint public miningInterval;
    uint public tokenMint = 0;


    EIP20Interface public token;


    /// @dev sets boundaries for incoming tx
    /// @dev from FoMo3Dlong
    modifier isWithinLimits(uint _eth) {
        require(_eth >= lowerBoundaryETH, "pocket lint: not a valid currency");
        require(_eth <= upperBoundaryETH, "no vitalik, no");
        _;
    }

    /// @dev Initialize the token mint parameters
    /// @dev Can only be excuted once.
    constructor(
        address tokenAddress, 
        uint _miningInterval,
        uint _supplyPerInterval,
        uint _a, 
        uint _b, 
        uint _c,
        uint _blockInterval, 
        uint _startBlockNumber,
        address _platform,
        uint _lowerBoundaryETH,
        uint _upperBoundaryETH) 
        public {
        
        require(_lowerBoundaryETH < _upperBoundaryETH, "Lower boundary is larger than upper boundary!");

        token = EIP20Interface(tokenAddress);

        a = _a;
        b = _b;
        c = _c;
        blockInterval = _blockInterval;
        startBlockNumber = _startBlockNumber;

        platform = _platform;
        lowerBoundaryETH = _lowerBoundaryETH;
        upperBoundaryETH = _upperBoundaryETH;

        miningInterval = _miningInterval;
        supplyPerInterval = _supplyPerInterval;
    }

    function changeWithdraw(address _platform) public onlyOwner {
        platform = _platform;
    }

    function changeRate(uint _c) public onlyOwner {
        c = _c;
    }

    function withdraw(address _to) public onlyOwner returns (bool success) {
        uint remainBalance = token.balanceOf(address(this));
        return token.transfer(_to, remainBalance);
    }

    /// @dev Mint token based on the current token price.
    /// @dev The token number is limited during each interval.
    function buy() public isWithinLimits(msg.value) payable {
       
        uint currentStage = getCurrentStage(); // from 1 to MINING_INTERVAL
       
        require(tokenMint < currentStage.mul(supplyPerInterval), "No token avaiable");
       
        uint currentPrice = calculatePrice(currentStage); // 18 decimal
       
        uint amountToBuy = msg.value.mul(10**uint(decimals)).div(currentPrice);
        
        if(tokenMint.add(amountToBuy) > currentStage.mul(supplyPerInterval)) {
            amountToBuy = currentStage.mul(supplyPerInterval).sub(tokenMint);
            token.transfer(msg.sender, amountToBuy);
            tokenMint = tokenMint.add(amountToBuy);
            uint refund = msg.value.sub(amountToBuy.mul(currentPrice).div(10**uint(decimals)));
            msg.sender.transfer(refund);          
            platform.transfer(msg.value.sub(refund)); 
        } else {
            token.transfer(msg.sender, amountToBuy);
            tokenMint = tokenMint.add(amountToBuy);
            platform.transfer(msg.value);
        }
    }

    function() public payable {
        buy();
    }

    /// @dev Shows the remaining token of the current token mint phase
    function tokenRemain() public view returns (uint) {
        uint currentStage = getCurrentStage();
        return currentStage * supplyPerInterval - tokenMint;
    }

    /// @dev Get the current token mint phase between 1 and MINING_INTERVAL
    function getCurrentStage() public view returns (uint) {
        require(block.number >= startBlockNumber, "Not started yet");
        uint currentStage = (block.number.sub(startBlockNumber)).div(blockInterval) + 1;
        if (currentStage <= miningInterval) {
            return currentStage;
        } else {
            return miningInterval;
        }
    }

    /// @dev Return the price of one token during the nth stage
    /// @param stage Current stage from 1 to 365
    /// @return Price per token
    function calculatePrice(uint stage) public view returns (uint) {
        return a.mul(log(stage.mul(MAGNITUDE))).div(MAGNITUDE).add(b).div(c);
    }

    /// @dev Return the e based logarithm of x demonstrated by Vitalik
    /// @param input The actual input (>=1) times MAGNITUDE
    /// @return result The actual output times MAGNITUDE
    function log(uint input) internal pure returns (uint) {
        uint x = input;
        require(x >= MAGNITUDE, "");
        if (x == MAGNITUDE) {
            return 0;
        }
        uint result = 0;
        while (x >= THREE_SECOND) {
            result += LOG1DOT5;
            x = x * 2 / 3;
        }
        
        x = x - MAGNITUDE;
        uint y = x;
        uint i = 1;
        while (i < 10) {
            result = result + (y / i);
            i += 1;
            y = y * x / MAGNITUDE;
            result = result - (y / i);
            i += 1;
            y = y * x / MAGNITUDE;
        }
        
        return result;
    }
}
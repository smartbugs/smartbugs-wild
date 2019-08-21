/**
 * Smart contract - piggy bank.
 * Contributions are not limited.
 * If you withdraw your deposit quickly, you lose a commission of 10%
 * If you keep a deposit for a long time - you will receive income from the increase of the value of the token.
 * Tokens are fully compatible with the ERC20 standard.
 */ 
 
 


pragma solidity ^0.4.25;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address _who) external view returns (uint256);

  function allowance(address _owner, address _spender) external view returns (uint256);

  function transfer(address _to, uint256 _value) external returns (bool);

  function approve(address _spender, uint256 _value) external returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

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


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b,"Math error");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0,"Math error"); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a,"Math error");
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a,"Math error");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0,"Math error");
        return a % b;
    }
}


/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal balances_;

    mapping (address => mapping (address => uint256)) private allowed_;

    uint256 private totalSupply_;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances_[_owner];
    }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
    function allowance(
        address _owner,
        address _spender
    )
      public
      view
      returns (uint256)
    {
        return allowed_[_owner][_spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances_[msg.sender],"Invalid value");
        require(_to != address(0),"Invalid address");

        balances_[msg.sender] = balances_[msg.sender].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed_[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
      public
      returns (bool)
    {
        require(_value <= balances_[_from],"Value is more than balance");
        require(_value <= allowed_[_from][msg.sender],"Value is more than alloved");
        require(_to != address(0),"Invalid address");

        balances_[_from] = balances_[_from].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
      public
      returns (bool)
    {
        allowed_[msg.sender][_spender] = (allowed_[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
      public
      returns (bool)
    {
        uint256 oldValue = allowed_[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed_[msg.sender][_spender] = 0;
        } else {
            allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param _account The account that will receive the created tokens.
    * @param _amount The amount that will be created.
    */
    function _mint(address _account, uint256 _amount) internal returns (bool) {
        require(_account != 0,"Invalid address");
        totalSupply_ = totalSupply_.add(_amount);
        balances_[_account] = balances_[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
        return true;
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account.
    * @param _account The account whose tokens will be burnt.
    * @param _amount The amount that will be burnt.
    */
    function _burn(address _account, uint256 _amount) internal returns (bool) {
        require(_account != 0,"Invalid address");
        require(_amount <= balances_[_account],"Amount is more than balance");

        totalSupply_ = totalSupply_.sub(_amount);
        balances_[_account] = balances_[_account].sub(_amount);
        emit Transfer(_account, address(0), _amount);
    }

}



/**
 * @title Contract Piggytoken
 * @dev ERC20 compatible token contract
 */
contract PiggyToken is ERC20 {
    string public constant name = "PiggyBank Token";
    string public constant symbol = "Piggy";
    uint32 public constant decimals = 18;
    uint256 public INITIAL_SUPPLY = 0; // no tokens on start
    address public piggyBankAddress;
    


    constructor(address _piggyBankAddress) public {
        piggyBankAddress = _piggyBankAddress;
    }


    modifier onlyPiggyBank() {
        require(msg.sender == piggyBankAddress,"Only PiggyBank contract can run this");
        _;
    }
    
    modifier validDestination( address to ) {
        require(to != address(0x0),"Empty address");
        require(to != address(this),"PiggyBank Token address");
        _;
    }
    

    /**
     * @dev Override for testing address destination
     */
    function transfer(address _to, uint256 _value) public validDestination(_to) returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Override for testing address destination
     */
    function transferFrom(address _from, address _to, uint256 _value) public validDestination(_to) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    
    /**
     * @dev Override for running only from PiggyBank contract
     */
    function mint(address _to, uint256 _value) public onlyPiggyBank returns (bool) {
        return super._mint(_to, _value);
    }

    /**
     * @dev Override for running only from PiggyBank contract
     */
    function burn(address _to, uint256 _value) public onlyPiggyBank returns (bool) {
        return super._burn(_to, _value);
    }

    function() external payable {
        revert("The token contract don`t receive ether");
    }  
}





/**
 * @title PiggyBank
 * @dev PiggyBank is a base contract for managing a token buying and selling
 */
contract PiggyBank {
    using SafeMath for uint256;
    address public owner;
    address creator;



    address myAddress = this;
    PiggyToken public token = new PiggyToken(myAddress);


    // How many token units a buyer gets per wei.
    uint256 public rate;

    // Amount of wei raised
    uint256 public weiRaised;

    event Invest(
        address indexed investor, 
        uint256 tokens,
        uint256 weiAmount,
        uint256 rate
    );

    event Withdraw(
        address indexed to, 
        uint256 tokens,
        uint256 weiAmount,
        uint256 rate
    );

    event TokenPrice(
        uint256 value
    );

    constructor() public {
        owner = 0x0;
        creator = msg.sender;
        rate = 1 ether;
    }

    // -----------------------------------------
    // External interface
    // -----------------------------------------

    /**
    * @dev fallback function
    */
    function () external payable {
        if (msg.value > 0) {
            _buyTokens(msg.sender);
        } else {
            require(msg.data.length == 0,"Only for simple payments");
            _takeProfit(msg.sender);
        }

    }

    /**
    * @dev low level token purchase ***DO NOT OVERRIDE***
    * @param _beneficiary Address performing the token purchase
    */
    function _buyTokens(address _beneficiary) internal {
        uint256 weiAmount = msg.value.mul(9).div(10);
        uint256 creatorBonus = msg.value.div(100);
        require(_beneficiary != address(0),"Invalid address");

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);
        uint256 creatorTokens = _getTokenAmount(creatorBonus);

        // update state
        weiRaised = weiRaised.add(weiAmount);
        //rate = myAddress.balance.div(weiRaised);

        _processPurchase(_beneficiary, tokens);
        _processPurchase(creator, creatorTokens);
        
        emit Invest(_beneficiary, tokens, msg.value, rate);

    }


    // -----------------------------------------
    // Internal interface (extensible)
    // -----------------------------------------

    function _takeProfit(address _beneficiary) internal {
        uint256 tokens = token.balanceOf(_beneficiary);
        uint256 weiAmount = tokens.mul(rate).div(1 ether);
        token.burn(_beneficiary, tokens);
        _beneficiary.transfer(weiAmount);
        _updatePrice();
        
        emit Withdraw(_beneficiary, tokens, weiAmount, rate);
    }


    function _updatePrice() internal {
        uint256 oldPrice = rate;
        if (token.totalSupply()>0){
            rate = myAddress.balance.mul(1 ether).div(token.totalSupply());
            if (rate != oldPrice){
                emit TokenPrice(rate);
            }
        }
    }


    /**
    * @dev internal function
    * @param _beneficiary Address performing the token purchase
    * @param _tokenAmount Number of tokens to be emitted
    */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.mint(_beneficiary, _tokenAmount);
    }


    /**
    * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
    * @param _beneficiary Address receiving the tokens
    * @param _tokenAmount Number of tokens to be purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }


    /**
    * @dev this function is ether converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 resultAmount = _weiAmount;
        return resultAmount.mul(1 ether).div(rate);
    }

}
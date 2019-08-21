//
pragma solidity 0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function totalSupply() public view returns (uint256);
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

    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

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
        emit Transfer(msg.sender, _to, _value);
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
        emit Transfer(_from, _to, _value);
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
        emit Approval(msg.sender, _spender, _value);
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
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
contract NLCToken is StandardToken {
    ///
    using SafeMath for uint256;

    ///
    string public constant name = "Nutrilife OU";
    string public constant symbol = "NLC";
    uint8 public constant decimals = 18;  
    
    /// The owner of this address will distrbute the locked and vested tokens
    address public nlcAdminAddress;
    uint256 public weiRaised;
    uint256 public rate;

    modifier onlyAdmin {
        require(msg.sender == nlcAdminAddress);
        _;
    }
    
    /**
    * Event for token purchase logging
    * @param investor invest into the token
    * @param value weis paid for purchase
    */
    event Investment(address indexed investor, uint256 value);
    event TokenPurchaseRequestFromInvestment(address indexed investor, uint256 token);
    event ApproveTokenPurchaseRequest(address indexed investor, uint256 token);
    
    /// Initial tokens to be allocated (500 million)
    uint256 public constant INITIAL_SUPPLY = 500000000 * 10**uint256(decimals);
    mapping(address => uint256) public _investorsVault;
    mapping(address => uint256) public _investorsInvestmentInToken;

    ///
    constructor(address _nlcAdminAddress, uint256 _rate) public {
        require(_nlcAdminAddress != address(0));
        
        nlcAdminAddress = _nlcAdminAddress;
        totalSupply_ = INITIAL_SUPPLY;
        rate = _rate;

        balances[_nlcAdminAddress] = totalSupply_;
    }


    /**
    * @dev fallback function ***DO NOT OVERRIDE***
    */
    function () external payable {
        investFund(msg.sender);
    }

    /**
      * @dev low level token purchase ***DO NOT OVERRIDE***
      * @param _investor Address performing the token purchase
      */
    function investFund(address _investor) public payable {
        //
        uint256 weiAmount = msg.value;
        
        _preValidatePurchase(_investor, weiAmount);
        
        weiRaised = weiRaised.add(weiAmount);
        
        _trackVault(_investor, weiAmount);
        
        _forwardFunds();

        emit Investment(_investor, weiAmount);
    }
    
    /**
    * @dev Gets the invested fund specified address.
    * @param _investor The address to query the the balance of invested amount.
    * @return An uint256 representing the invested amount by the passed address.
    */
    function investmentOf(address _investor) public view returns (uint256) {
        return _investorsVault[_investor];
    }

    /**
    * @dev token request from invested ETH.
    * @param _ethInWei investor want to invest ether amount.
    * @return An uint256 representing the invested amount by the passed address.
    */
    function purchaseTokenFromInvestment(uint256 _ethInWei) public {
            ///
            require(_investorsVault[msg.sender] != 0);

            ///
            uint256 _token = _getTokenAmount(_ethInWei);
            
            _investorsVault[msg.sender] = _investorsVault[msg.sender].sub(_ethInWei);

            _investorsInvestmentInToken[msg.sender] = _investorsInvestmentInToken[msg.sender].add(_token);
            
            emit TokenPurchaseRequestFromInvestment(msg.sender, _token);
    }

    /**
    * @dev Gets the investment token request for token.
    * @param _investor The address to query the the balance of invested amount.
    * @return An uint256 representing the invested amount by the passed address.
    */
    function tokenInvestmentRequest(address _investor) public view returns (uint256) {
        return _investorsInvestmentInToken[_investor];
    }

    /**
    * @dev Gets the invested fund specified address.
    * @param _investor The address to query the the balance of invested amount.
    * @return An uint256 representing the invested amount by the passed address.
    */
    function approveTokenInvestmentRequest(address _investor) public onlyAdmin {
        //
        uint256 token = _investorsInvestmentInToken[_investor];
        require(token != 0);
        //
        super.transfer(_investor, _investorsInvestmentInToken[_investor]);
        
        _investorsInvestmentInToken[_investor] = _investorsInvestmentInToken[_investor].sub(token);
        
        emit ApproveTokenPurchaseRequest(_investor, token);
    }

   /**
    * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
    * @param _beneficiary Address performing the token purchase
    * @param _weiAmount Value in wei involved in the purchase
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal pure {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
        
        // must be greater than 1/2 ETH.
        require(_weiAmount >= 0.5 ether);
    }

   /**
    * @dev tracing of incoming fund from investors.
    * @param _investor Address performing the token purchase
    * @param _weiAmount Value in wei involved in the purchase
    */
    function _trackVault(address _investor, uint256 _weiAmount) internal {
        _investorsVault[_investor] = _investorsVault[_investor].add(_weiAmount);
    }

    /**
    * @dev Determines how ETH is stored/forwarded on investment.
    */
    function _forwardFunds() internal {
        nlcAdminAddress.transfer(msg.value);
    }

    /**
    * @dev Override to extend the way in which ether is converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return _weiAmount.mul(rate).div(1 ether);
    }

}
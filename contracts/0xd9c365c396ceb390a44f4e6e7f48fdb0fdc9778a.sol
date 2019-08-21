pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


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
        owner = msg.sender;
    }

    /**
    * owner
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
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
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender)
        public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value)
        public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool);

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

contract KvantorSaleToken is ERC20, Ownable {
    using SafeMath for uint256;

    string public name = "KVANTOR Sale token";
    string public symbol = "KVT_SALE";
    uint public decimals = 8;

    uint256 crowdsaleStartTime = 1535317200;
    uint256 crowdsaleFinishTime = 1537995600;


    address public kvtOwner = 0xe4ed7e14e961550c0ce7571df8a5b11dec9f7f52;
    ERC20 public kvtToken = ERC20(0x96c8aa08b1712dDe92f327c0dC7c71EcE6c06525);

    uint256 tokenMinted = 0;
    // cap 60 mln KVT
    uint256 public tokenCap = 6000000000000000;
    // rate is 0,0000000 ETH discreet
    uint256 public rate = 3061857781;
    
    uint256 public weiRaised = 0;
    address public wallet = 0x5B007Da9dBf09842Cb4751bd5BcD6ea2808256F5;

    constructor() public {
        
    }


    /* non-standard code */


    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        if (this == _to) {
            require(kvtToken.transfer(msg.sender, _value));
            _burn(msg.sender, _value);
        } else {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
        }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        if (this == _to) {
            require(kvtToken.transfer(_from, _value));
            _burn(_from, _value);
        } else {
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);   
        }
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    /* this function calculates tokens with discount rules */
    
    function calculateTokens(uint256 _weiAmount) view public returns (uint256) {
        
        uint256 tokens = _weiAmount.mul(rate).mul(100).div(75).div(100 finney);
        if(tokens.div(100000000) < 5000)
            return _weiAmount.mul(rate).mul(100).div(80).div(100 finney);
        
        tokens = _weiAmount.mul(rate).mul(100).div(73).div(100 finney);
        if(tokens.div(100000000) < 25000)
            return _weiAmount.mul(rate).mul(100).div(75).div(100 finney);
            
        tokens = _weiAmount.mul(rate).mul(100).div(70).div(100 finney);
        if(tokens.div(100000000) < 50000)
            return _weiAmount.mul(rate).mul(100).div(73).div(100 finney);
            
        tokens = _weiAmount.mul(rate).mul(100).div(65).div(100 finney);
        if(tokens.div(100000000) < 250000)
            return _weiAmount.mul(rate).mul(100).div(70).div(100 finney);
            
        tokens = _weiAmount.mul(rate).mul(100).div(60).div(100 finney);
        if(tokens.div(100000000) < 500000)
            return _weiAmount.mul(rate).mul(100).div(65).div(100 finney);
            
        return _weiAmount.mul(rate).mul(100).div(60).div(100 finney);
            
    }
    

    function buyTokens(address _beneficiary) public payable {
        require(crowdsaleStartTime <= now && now <= crowdsaleFinishTime);

        uint256 weiAmount = msg.value;

        require(_beneficiary != address(0));
        require(weiAmount != 0);

        // calculate token amount to be created
        uint256 tokens = calculateTokens(weiAmount);
        
        /* min purchase = 100 KVT */
        require(tokens.div(100000000) >= 100);
        
        require(tokenMinted.add(tokens) < tokenCap);
        tokenMinted = tokenMinted.add(tokens);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _mint(_beneficiary, tokens);

        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        wallet.transfer(msg.value);
    }

    function returnKVTToOwner() onlyOwner public {
        uint256 tokens = kvtToken.balanceOf(this).sub(this.totalSupply());

        require(now > crowdsaleFinishTime);
        require(tokens > 0);
        require(kvtToken.transfer(kvtOwner, tokens));
    }

    function returnKVTToSomeone(address _to) onlyOwner public {
        uint256 tokens = this.balanceOf(_to);

        require(now > crowdsaleFinishTime);
        require(tokens > 0);
        require(kvtToken.transfer(_to, tokens));
        _burn(_to, tokens);
    }
    
    function finishHim() onlyOwner public {
        selfdestruct(this);
    }

    function setRate(uint256 _rate) onlyOwner public {
        rate = _rate;
    }

    function setTokenCap(uint256 _tokenCap) onlyOwner public {
        tokenCap = _tokenCap;
    }
    
    /* zeppelen standard code */    
    /**
    * Event for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
    * @dev fallback function ***DO NOT OVERRIDE***
    */
    function () external payable {
        buyTokens(msg.sender);
    }
    
    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) private allowed;

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
        return balances[_owner];
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
        return allowed[_owner][_spender];
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
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To increment
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
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To decrement
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
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param _account The account that will receive the created tokens.
    * @param _amount The amount that will be created.
    */
    function _mint(address _account, uint256 _amount) internal {
        require(_account != 0);
        totalSupply_ = totalSupply_.add(_amount);
        balances[_account] = balances[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account.
    * @param _account The account whose tokens will be burnt.
    * @param _amount The amount that will be burnt.
    */
    function _burn(address _account, uint256 _amount) internal {
        require(_account != 0);
        require(_amount <= balances[_account]);

        totalSupply_ = totalSupply_.sub(_amount);
        balances[_account] = balances[_account].sub(_amount);
        emit Transfer(_account, address(0), _amount);
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account, deducting from the sender's allowance for said account. Uses the
    * internal _burn function.
    * @param _account The account whose tokens will be burnt.
    * @param _amount The amount that will be burnt.
    */
    function _burnFrom(address _account, uint256 _amount) internal {
        require(_amount <= allowed[_account][msg.sender]);

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);
        _burn(_account, _amount);
    }
}
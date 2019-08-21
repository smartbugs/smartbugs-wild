pragma solidity 0.4.19;


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
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
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

    mapping(address => uint256) internal balances;

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
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
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


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken, Ownable {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public onlyOwner {
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


contract WePoolToken is BurnableToken {

    string public constant name = "WePool";
    string public constant symbol = "WPL";
    uint32 public constant decimals = 18;

    function WePoolToken() public {
        totalSupply = 200000000 * 1E18; // 200 million tokens
        balances[owner] = totalSupply;  // owner is crowdsale
    }
}


contract WePoolCrowdsale is Ownable {
    using SafeMath for uint256;


    uint256 public hardCap;
    uint256 public reserved;

    uint256 public tokensSold; // amount of bought tokens
    uint256 public weiRaised; // total investments

    uint256 public minPurchase;
    uint256 public preIcoRate; // how many token units a buyer gets per wei
    uint256 public icoRate;

    address public wallet; // for withdrawal
    address public tokenWallet; // for reserving tokens

    uint256 public icoStartTime;
    uint256 public preIcoStartTime;


    address[] public investorsArray;
    mapping (address => uint256) public investors; //address -> amount


    WePoolToken public token;
     
    modifier icoEnded() {
        require(now > (icoStartTime + 30 days));
        _;        
    }

    /**
     * @dev Constructor to WePoolCrowdsale contract
     */
    function WePoolCrowdsale(uint256 _preIcoStartTime, uint256 _icoStartTime) public {
        require(_preIcoStartTime > now);
        require(_icoStartTime > _preIcoStartTime + 7 days);
        preIcoStartTime = _preIcoStartTime;
        icoStartTime = _icoStartTime;

        minPurchase = 0.1 ether;
        preIcoRate = 0.00008 ether;
        icoRate = 0.0001 ether;

        hardCap = 200000000 * 1E18; // 200 million tokens * decimals

        token = new WePoolToken();

        reserved = hardCap.mul(35).div(100);
        hardCap = hardCap.sub(reserved); // tokens left for sale (200m - 70 = 130)

        wallet = owner;
        tokenWallet = owner;
    }

    /**
     * @dev Function set new wallet address. Wallet is used for withdrawal
     * @param newWallet Address of new wallet.
     */
    function changeWallet(address newWallet) public onlyOwner {
        require(newWallet != address(0));
        wallet = newWallet;
    }

    /**
     * @dev Function set new token wallet address
     * @dev Token wallet is used for reserving tokens for founders
     * @param newAddress Address of new Token Wallet
     */
    function changeTokenWallet(address newAddress) public onlyOwner {
        require(newAddress != address(0));
        tokenWallet = newAddress;
    }

    /**
     @dev Function set new preIco token price
     @param newRate New preIco price per token
     */
    function changePreIcoRate(uint256 newRate) public onlyOwner {
        require(newRate > 0);
        preIcoRate = newRate;
    }

    /**
     @dev Function set new Ico token price
     @param newRate New Ico price per token
     */
    function changeIcoRate(uint256 newRate) public onlyOwner {
        require(newRate > 0);
        icoRate = newRate;
    }

    /**
     * @dev Function set new preIco start time
     * @param newTime New preIco start time
     */
    function changePreIcoStartTime(uint256 newTime) public onlyOwner {
        require(now < preIcoStartTime);
        require(newTime > now);
        require(icoStartTime > newTime + 7 days);
        preIcoStartTime = newTime;
    }

    /**
     * @dev Function set new Ico start time
     * @param newTime New Ico start time
     */
    function changeIcoStartTime(uint256 newTime) public onlyOwner {
        require(now < icoStartTime);
        require(newTime > now);
        require(newTime > preIcoStartTime + 7 days);
        icoStartTime = newTime;
    }

    /**
     * @dev Function burn all unsold Tokens (balance of crowdsale)
     * @dev Ico should be ended
     */
    function burnUnsoldTokens() public onlyOwner icoEnded {
        token.burn(token.balanceOf(this));
    }

    /**
     * @dev Function transfer all raised money to the founders wallet
     * @dev Ico should be ended
     */
    function withdrawal() public onlyOwner icoEnded {
        wallet.transfer(this.balance);    
    }

    /**
     * @dev Function reserve tokens for founders and bounty program
     * @dev Ico should be ended
     */
    function getReservedTokens() public onlyOwner icoEnded {
        require(reserved > 0);
        uint256 amount = reserved;
        reserved = 0;
        token.transfer(tokenWallet, amount);
    }

    /**
     * @dev Fallback function
     */
    function() public payable {
        buyTokens();
    }

    /**
     * @dev Function for investments.
     */
    function buyTokens() public payable {
        address inv = msg.sender;
        
        uint256 weiAmount = msg.value;
        require(weiAmount >= minPurchase);

        uint256 rate;
        uint256 tokens;
        uint256 cleanWei; // amount of wei to use for purchase excluding change and hardcap overflows
        uint256 change;

        if (now > preIcoStartTime && now < (preIcoStartTime + 7 days)) {
            rate = preIcoRate;
        } else if (now > icoStartTime && now < (icoStartTime + 30 days)) {
            rate = icoRate;
        }
        require(rate > 0);
    
        tokens = (weiAmount.mul(1E18)).div(rate);

        // check hardCap
        if (tokensSold.add(tokens) > hardCap) {
            tokens = hardCap.sub(tokensSold);
            cleanWei = tokens.mul(rate).div(1E18);
            change = weiAmount.sub(cleanWei);
        } else {
            cleanWei = weiAmount;
        }

        // check, if this investor already included
        if (investors[inv] == 0) {
            investorsArray.push(inv);
            investors[inv] = tokens;
        } else {
            investors[inv] = investors[inv].add(tokens);
        }

        tokensSold = tokensSold.add(tokens);
        weiRaised = weiRaised.add(cleanWei);

        token.transfer(inv, tokens);

        // send back change
        if (change > 0) {
            inv.transfer(change); 
        }
    }

    /**
     * @dev Function returns the number of investors.
     * @return uint256 Number of investors.
     */
    function getInvestorsLength() public view returns(uint256) {
        return investorsArray.length;
    }
}
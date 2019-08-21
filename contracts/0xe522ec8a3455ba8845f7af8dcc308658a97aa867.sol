pragma solidity 0.4.19;

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
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


/**
 * @title FemaleToken
 * @dev The main token contract
 */
contract FemaleToken is MintableToken {

  string public name = "Female Token";
  string public symbol = "FEM";
  uint public decimals = 18;

  bool public tradingStarted = false;

  /**
   * @dev modifier that throws if trading has not started yet
   */
  modifier hasStartedTrading() {
    require(tradingStarted);
    _;
  }

  /**
   * @dev Allows the owner to enable the trading. This can not be undone
   */
  function startTrading() public onlyOwner {
    tradingStarted = true;
  }

  /**
   * @dev Allows anyone to transfer the TEST tokens once trading has started
   * @param _to the recipient address of the tokens. 
   * @param _value number of tokens to be transfered. 
   */
  function transfer(address _to, uint _value) public hasStartedTrading returns (bool) {
    super.transfer(_to, _value);
  }

   /**
   * @dev Allows anyone to transfer the TEST tokens once trading has started
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) public hasStartedTrading returns (bool) {
    super.transferFrom(_from, _to, _value);
  }

}


/**
 * @title FemaleTokenSale
 * @dev The main Female token sale contract
 */
contract FemaleTokenSale is Ownable {
  using SafeMath for uint;
  event TokenSold(address recipient, uint ether_amount, uint pay_amount);
  event AuthorizedCreate(address recipient, uint pay_amount);
  event MainSaleClosed();

  FemaleToken public token = new FemaleToken();

  address public multisigVault = 0xB80F274a7596D4Dc995f032e24Cb55B3902399F5;

  uint hardcap = 100000 ether;
  uint public rate = 1000; // 1ETH = 1000FEM
  uint restrictedPercent = 20;

  uint public fiatDeposits = 0;
  uint public startTime = 1514764800; //Mon, 01 Jan 2018 00:00:00 GMT
  uint public endTime = 1517356800; // Wed, 31 Jan 2018 00:00:00 GMT
  uint public bonusTime = 1518220800; // Sat, 10 Feb 2018 00:00:00 GMT
  //Start of token transfer allowance -  Sun, 11 Feb 2018 
  mapping(address => bool) femalestate;
  
  /**
   * @dev modifier to allow token creation only when the sale IS ON
   */
  modifier saleIsOn() {
    require(now > startTime && now < endTime);
    _;
  }

  /**
   * @dev modifier to allow token creation only when the hardcap has not been reached
   */
  modifier isUnderHardCap() {
    require(multisigVault.balance + fiatDeposits <= hardcap);
    _;
  }
 /**
 * @dev Function for calculation bonus tokens
 * bonus 1% for each 100 FEM batch per buy (up to max 50% bonus)
 * @param initwei - amount of donation in wei
 */
 function bonusRate(uint initwei) internal view returns (uint){
	uint bonRate;
	uint calcRate = initwei.div(100000000000000000);
	if (calcRate > 50 ) bonRate = 150 * rate / 100;
	else if (calcRate <1) bonRate = rate;
	else {
		bonRate = calcRate.mul(rate) / 100;
		bonRate += rate;
	}
	return bonRate;
  }
   
  /**
   * @dev Allows anyone to create tokens by depositing ether.
   * @param recipient the recipient to receive tokens. 
   */
  function createTokens(address recipient) public isUnderHardCap saleIsOn payable {
    uint256 weiAmount = msg.value;
	uint bonusTokensRate = bonusRate(weiAmount);
	uint tokens = bonusTokensRate.mul(weiAmount);
	token.mint(recipient, tokens);
    require(multisigVault.send(msg.value));
    TokenSold(recipient, msg.value, tokens);
	femalestate[msg.sender]= false;
  }

  /**
   * @dev Allows create tokens. This is used for fiat deposits.
   * @param recipient the recipient to receive tokens.
   * @param fiatdeposit - amount of deposit in ETH. 
   */
  function altCreateTokens(address recipient, uint fiatdeposit) public isUnderHardCap saleIsOn onlyOwner {
    require(recipient != address(0));
	require(fiatdeposit > 0);
	fiatDeposits += fiatdeposit;
	uint bonusTokensRate = bonusRate(fiatdeposit);
	uint tokens = bonusTokensRate.mul(fiatdeposit);
	token.mint(recipient, tokens);
    AuthorizedCreate(recipient, tokens);
	femalestate[recipient]= false;
  }

  /**
   * @dev Allows the owner to finish the minting. This will create the 
   * restricted tokens and then close the minting.
   * Then the ownership of the FEM token contract is transfered to this owner.
   * Also it allows token transfer function.
   */
  function finishMinting() public onlyOwner {
    require(now > bonusTime);
	uint issuedTokenSupply = token.totalSupply();
    uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
    token.mint(multisigVault, restrictedTokens);
    token.finishMinting();
	token.startTrading();
    token.transferOwnership(owner);
    MainSaleClosed();
  }

  /**
  * @dev Allows the owner to double tokens of female investors.
  * @param adr - address of female investor.
  * femalestate allows to set double tokens only once per investor.
  * doublebonus can only be set during 10 days period after ICO end.
  */
  
  function doubleBonus(address adr) public onlyOwner {
	require (now > endTime && now < bonusTime);
	if (!femalestate[adr]) {
		femalestate[adr]= true;
		uint unittoken = token.balanceOf(adr);
		uint doubletoken = unittoken.mul(2);
		if (unittoken < doubletoken) {token.mint(adr, unittoken);}
	}
  }
  
  /**
  * @dev Same as doubleBonus - just for array of addresses.
  * As was said before - this function works only during 10 days after ICO ends.
  */ 
  
   function doubleBonusArray(address[] adr) public onlyOwner {
	uint i = 0;
	while (i < adr.length) {
		doubleBonus(adr[i]);
		i++;
    }
  }
  
  /**
   * @dev Allows the owner to transfer ERC20 tokens to the multi sig vault
   * @param _token the contract address of the ERC20 contract
   */
  function retrieveTokens(address _token) public onlyOwner {
    ERC20 alttoken = ERC20(_token);
    alttoken.transfer(multisigVault, alttoken.balanceOf(this));
  }

  /**
   * @dev Fallback function which receives ether and created the appropriate number of tokens for the 
   * msg.sender.
   */
  function() external payable {
    createTokens(msg.sender);
  }

}
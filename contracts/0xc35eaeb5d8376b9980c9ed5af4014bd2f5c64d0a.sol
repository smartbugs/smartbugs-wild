pragma solidity ^0.4.18;

// File: contracts/ownership/Ownable.sol

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

// File: contracts/math/SafeMath.sol

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

// File: contracts/token/ERC20Basic.sol

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

// File: contracts/token/BasicToken.sol

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

// File: contracts/token/ERC20.sol

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

// File: contracts/token/StandardToken.sol

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
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
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

// File: contracts/token/MintableToken.sol

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

// File: contracts/BuildersCoin.sol

contract BuildersCoin is MintableToken {

  string public constant name = 'Builders Coin';
  string public constant symbol = 'BLD';
  uint32 public constant decimals = 18;
  address public saleAgent;
  bool public transferLocked = true;

  modifier notLocked() {
    require(msg.sender == owner || msg.sender == saleAgent || !transferLocked);
    _;
  }

  modifier onlyOwnerOrSaleAgent() {
    require(msg.sender == owner || msg.sender == saleAgent);
    _;
  }

  function setSaleAgent(address newSaleAgnet) public {
    require(msg.sender == owner || msg.sender == saleAgent);
    saleAgent = newSaleAgnet;
  }

  function unlockTransfer() onlyOwnerOrSaleAgent public {
    if (transferLocked) {
      transferLocked = false;
    }
  }

  function mint(address _to, uint256 _amount) onlyOwnerOrSaleAgent canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() public onlyOwnerOrSaleAgent returns (bool) {
    unlockTransfer();
    return super.finishMinting();
  }

  function transfer(address _to, uint256 _value) public notLocked returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address from, address to, uint256 value) public notLocked returns (bool) {
    return super.transferFrom(from, to, value);
  }

}

// File: contracts/Presale.sol

contract Presale is Ownable {

  using SafeMath for uint;

  uint public price;
  uint public start;
  uint public end;
  uint public duration;
  uint public softcap = 157000000000000000000; // 157 ETH
  uint public hardcap;
  uint public minInvestmentLimit;
  uint public investedWei;
  uint public directMintLimit;
  uint public mintedDirectly;
  uint public devLimit = 3500000000000000000; // 3.5 ETH
  bool public softcapReached;
  bool public hardcapReached;
  bool public refundIsAvailable;
  bool public devWithdrawn;
  address public directMintAgent;
  address public wallet;
  address public devWallet = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;
  BuildersCoin public token;
  mapping(address => uint) public balances;

  event SoftcapReached();
  event HardcapReached();
  event RefundIsAvailable();

  modifier onlyOwnerOrDirectMintAgent() {
    require(msg.sender == owner || msg.sender == directMintAgent);
    _;
  }

  //---------------------------------------------------------------------------
  // Configuration setters
  //---------------------------------------------------------------------------

  function setDirectMintAgent(address _directMintAgent) public onlyOwner {
    directMintAgent = _directMintAgent;
  }

  function setDirectMintLimit(uint _directMintLimit) public onlyOwner {
    directMintLimit = _directMintLimit;
  }

  function setMinInvestmentLimit(uint _minInvestmentLimit) public onlyOwner {
    minInvestmentLimit = _minInvestmentLimit;
  }

  function setPrice(uint _price) public onlyOwner {
    price = _price;
  }

  function setToken(address _token) public onlyOwner {
    token = BuildersCoin(_token);
  }

  function setWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }

  function setStart(uint _start) public onlyOwner {
    start = _start;
  }

  function setDuration(uint _duration) public onlyOwner {
    duration = _duration;
    end = start.add(_duration.mul(1 days));
  }

  function setHardcap(uint _hardcap) public onlyOwner {
    hardcap = _hardcap;
  }

  //---------------------------------------------------------------------------
  // Mint functions
  //---------------------------------------------------------------------------

  function mintAndTransfer(address _to, uint _tokens) internal {
    token.mint(this, _tokens);
    token.transfer(_to, _tokens);
  }

  function mint(address _to, uint _investedWei) internal {
    require(_investedWei >= minInvestmentLimit && !hardcapReached && now >= start && now < end);
    uint tokens = _investedWei.mul(price).div(1 ether);
    mintAndTransfer(_to, tokens);
    balances[_to] = balances[_to].add(_investedWei);
    investedWei = investedWei.add(_investedWei);
    if (investedWei >= softcap && ! softcapReached) {
      SoftcapReached();
      softcapReached = true;
    }
    if (investedWei >= hardcap) {
      HardcapReached();
      hardcapReached = true;
    }
  }

  function directMint(address _to, uint _tokens) public onlyOwnerOrDirectMintAgent {
    mintedDirectly = mintedDirectly.add(_tokens);
    require(mintedDirectly <= directMintLimit);
    mintAndTransfer(_to, _tokens);
  }

  //---------------------------------------------------------------------------
  // Withdraw functions
  //---------------------------------------------------------------------------

  function refund() public {
    require(refundIsAvailable && balances[msg.sender] > 0);
    uint value = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(value);
  }

  function withdraw() public onlyOwner {
    require(softcapReached);
    widthrawDev();
    wallet.transfer(this.balance);
  }

  function widthrawDev() public {
    require(softcapReached);
    require(msg.sender == devWallet || msg.sender == owner);
    if (!devWithdrawn) {
      devWithdrawn = true;
      devWallet.transfer(devLimit);
    }
  }

  function retrieveTokens(address _to, address _anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(_anotherToken);
    alienToken.transfer(_to, alienToken.balanceOf(this));
  }

  //---------------------------------------------------------------------------
  // Service functions
  //---------------------------------------------------------------------------

  function finish() public onlyOwner {
    if (investedWei < softcap) {
      RefundIsAvailable();
      refundIsAvailable = true;
    } else {
      withdraw();
    }
  }

  //---------------------------------------------------------------------------
  // Fallback function
  //---------------------------------------------------------------------------

  function () external payable {
    mint(msg.sender, msg.value);
  }

}

// File: contracts/Configurator.sol

contract Configurator is Ownable {

  BuildersCoin public token;
  Presale public presale;

  function deploy() public onlyOwner {

    token = new BuildersCoin();
    presale = new Presale();

    presale.setPrice(1400000000000000000000); // 1 ETH = 1400 BLD
    presale.setMinInvestmentLimit(100000000000000000); // 0.1 ETH
    presale.setDirectMintLimit(1000000000000000000000000); // 1 000 000 BLD
    presale.setHardcap(357142857000000000000); // 357.142857 ETH
    presale.setStart(1521543600); // Mar 20 2018 14:00:00 GMT+0300
    presale.setDuration(30); // 30 days
    presale.setWallet(0x8617f1ba539d45dcefbb18c40141e861abf288b7);
    presale.setToken(token);

    token.setSaleAgent(presale);

    address manager = 0x9DFF939e27e992Ac8635291263c3aa41654f3228;

    token.transferOwnership(manager);
    presale.transferOwnership(manager);
  }

}
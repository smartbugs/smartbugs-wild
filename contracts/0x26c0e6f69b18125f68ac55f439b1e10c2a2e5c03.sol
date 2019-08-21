pragma solidity ^0.4.24;


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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
    assert(msg.data.length >= size + 4);
    _;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {
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
 * @dev Based on code by FirstBlood:
        https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) external onlyPayloadSize(2 * 32) returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) external onlyPayloadSize(2 * 32) returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
    } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
    uint256 _value) public onlyPayloadSize(3 * 32) returns (bool) {
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
  function approve(address _spender, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
}

contract Owners {

  mapping (address => bool) public owners;
  uint public ownersCount;
  uint public minOwnersRequired = 2;

  event OwnerAdded(address indexed owner);
  event OwnerRemoved(address indexed owner);

  /**
   * @dev initializes contract
   * @param withDeployer bool indicates whether deployer is part of owners
   */
  constructor(bool withDeployer) public {
    if (withDeployer) {
      ownersCount++;
      owners[msg.sender] = true;
    }
    owners[0x23B599A0949C6147E05C267909C16506C7eFF229] = true;
    owners[0x286A70B3E938FCa244208a78B1823938E8e5C174] = true;
    ownersCount = ownersCount + 2;
  }

  /**
   * @dev adds owner, can only by done by owners only
   * @param _address address the address to be added
   */
  function addOwner(address _address) public ownerOnly {
    require(_address != address(0));
    owners[_address] = true;
    ownersCount++;
    emit OwnerAdded(_address);
  }

  /**
   * @dev removes owner, can only by done by owners only
   * @param _address address the address to be removed
   */
  function removeOwner(address _address) public ownerOnly notOwnerItself(_address) minOwners {
    require(owners[_address] == true);
    owners[_address] = false;
    ownersCount--;
    emit OwnerRemoved(_address);
  }

  /**
   * @dev checks if sender is owner
   */
  modifier ownerOnly {
    require(owners[msg.sender]);
    _;
  }

  modifier notOwnerItself(address _owner) {
    require(msg.sender != _owner);
    _;
  }

  modifier minOwners {
    require(ownersCount > minOwnersRequired);
    _;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Owners(true) {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event MintStarted();

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
  function mint(address _to, uint256 _amount) external ownerOnly canMint onlyPayloadSize(2 * 32) returns (bool) {
    return internalMint(_to, _amount);
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public ownerOnly canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }

  /**
   * @dev Function to start minting new tokens.
   * @return True if the operation was successful.
   */
  function startMinting() public ownerOnly returns (bool) {
    mintingFinished = false;
    emit MintStarted();
    return true;
  }

  function internalMint(address _to, uint256 _amount) internal returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }
}

contract REIDAOMintableToken is MintableToken {

  uint public decimals = 8;

  bool public tradingStarted = false;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) public canTrade returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint _value) public canTrade returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev modifier that throws if trading has not started yet
   */
  modifier canTrade() {
    require(tradingStarted);
    _;
  }

  /**
   * @dev Allows the owner to enable the trading. Done only once.
   */
  function startTrading() public ownerOnly {
    tradingStarted = true;
  }
}

contract REIDAOMintableLockableToken is REIDAOMintableToken {

  struct TokenLock {
    uint256 value;
    uint lockedUntil;
  }

  mapping (address => TokenLock[]) public locks;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) public canTransfer(msg.sender, _value) returns (bool) {
    return super.transfer(_to, _value);
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
    uint _value) public canTransfer(msg.sender, _value) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Allows authorized callers to lock `_value` tokens belong to `_to` until timestamp `_lockUntil`.
   * This function can be called independently of transferAndLockTokens(), hence the double checking of timestamp.
   * @param _to address The address to be locked.
   * @param _value uint The amout of tokens to be locked.
   * @param _lockUntil uint The UNIX timestamp tokens are locked until.
   */
  function lockTokens(address _to, uint256 _value, uint256 _lockUntil) public ownerOnly {
    require(_value <= balanceOf(_to));
    require(_lockUntil > now);
    locks[_to].push(TokenLock(_value, _lockUntil));
  }

  /**
   * @dev Allows authorized callers to mint `_value` tokens for `_to`, and lock them until timestamp `_lockUntil`.
   * @param _to address The address to which tokens to be minted and locked.
   * @param _value uint The amout of tokens to be minted and locked.
   * @param _lockUntil uint The UNIX timestamp tokens are locked until.
   */
  function mintAndLockTokens(address _to, uint256 _value, uint256 _lockUntil) public ownerOnly {
    require(_lockUntil > now);
    internalMint(_to, _value);
    lockTokens(_to, _value, _lockUntil);
  }

  /**
   * @dev Checks the amount of transferable tokens belongs to `_holder`.
   * @param _holder address The address to be checked.
   */
  function transferableTokens(address _holder) public constant returns (uint256) {
    uint256 lockedTokens = getLockedTokens(_holder);
    return balanceOf(_holder).sub(lockedTokens);
  }

  /**
   * @dev Retrieves the amount of locked tokens `_holder` has.
   * @param _holder address The address to be checked.
   */
  function getLockedTokens(address _holder) public constant returns (uint256) {
    uint256 numLocks = getTokenLocksCount(_holder);

    // Iterate through all the locks the holder has
    uint256 lockedTokens = 0;
    for (uint256 i = 0; i < numLocks; i++) {
      if (locks[_holder][i].lockedUntil >= now) {
        lockedTokens = lockedTokens.add(locks[_holder][i].value);
      }
    }

    return lockedTokens;
  }

  /**
   * @dev Retrieves the number of token locks `_holder` has.
   * @param _holder address The address the token locks belongs to.
   * @return A uint256 representing the total number of locks.
   */
  function getTokenLocksCount(address _holder) internal constant returns (uint256 index) {
    return locks[_holder].length;
  }

  /**
   * @dev Modifier that throws if `_value` amount of tokens can't be transferred.
   * @param _sender address the address of the sender
   * @param _value uint the amount of tokens intended to be transferred
   */
  modifier canTransfer(address _sender, uint256 _value) {
    uint256 transferableTokensAmt = transferableTokens(_sender);
    require(_value <= transferableTokensAmt);
    // delete locks if all locks are cleared
    if (transferableTokensAmt == balanceOf(_sender) && getTokenLocksCount(_sender) > 0) {
      delete locks[_sender];
    }
    _;
  }
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
}

contract REIDAOBurnableToken is BurnableToken {

  mapping (address => bool) public hostedWallets;

  /**
   * @dev burns tokens, can only be done by hosted wallets
   * @param _value uint256 the amount of tokens to be burned
   */
  function burn(uint256 _value) public hostedWalletsOnly {
    return super.burn(_value);
  }

  /**
   * @dev adds hosted wallet
   * @param _wallet address the address to be added
   */
  function addHostedWallet(address _wallet) public {
    hostedWallets[_wallet] = true;
  }

  /**
   * @dev removes hosted wallet
   * @param _wallet address the address to be removed
   */
  function removeHostedWallet(address _wallet) public {
    hostedWallets[_wallet] = false;
  }

  /**
   * @dev checks if sender is hosted wallets
   */
  modifier hostedWalletsOnly {
    require(hostedWallets[msg.sender] == true);
    _;
  }
}

contract REIDAOMintableBurnableLockableToken is REIDAOMintableLockableToken, REIDAOBurnableToken {

  /**
   * @dev adds hosted wallet, can only be done by owners.
   * @param _wallet address the address to be added
   */
  function addHostedWallet(address _wallet) public ownerOnly {
    return super.addHostedWallet(_wallet);
  }

  /**
   * @dev removes hosted wallet, can only be done by owners.
   * @param _wallet address the address to be removed
   */
  function removeHostedWallet(address _wallet) public ownerOnly {
    return super.removeHostedWallet(_wallet);
  }

  /**
   * @dev burns tokens, can only be done by hosted wallets
   * @param _value uint256 the amount of tokens to be burned
   */
  function burn(uint256 _value) public canTransfer(msg.sender, _value) {
    return super.burn(_value);
  }
}

contract Point is REIDAOMintableBurnableLockableToken {
  string public name = "Crowdvilla Point";
  string public symbol = "CROWD";
}
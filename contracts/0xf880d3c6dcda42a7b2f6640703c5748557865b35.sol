pragma solidity ^0.4.24;

// File: contracts/badERC20Fix.sol

/*

badERC20 POC Fix by SECBIT Team

USE WITH CAUTION & NO WARRANTY

REFERENCE & RELATED READING
- https://github.com/ethereum/solidity/issues/4116
- https://medium.com/@chris_77367/explaining-unexpected-reverts-starting-with-solidity-0-4-22-3ada6e82308c
- https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
- https://gist.github.com/BrendanChou/88a2eeb80947ff00bcf58ffdafeaeb61

*/

pragma solidity ^0.4.24;

library ERC20AsmFn {

    function isContract(address addr) internal {
        assembly {
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
    }

    function handleReturnData() internal returns (bool result) {
        assembly {
            switch returndatasize()
            case 0 { // not a std erc20
                result := 1
            }
            case 32 { // std erc20
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default { // anything else, should revert for safety
                revert(0, 0)
            }
        }
    }

    function asmTransfer(address _erc20Addr, address _to, uint256 _value) internal returns (bool result) {

        // Must be a contract addr first!
        isContract(_erc20Addr);

        // call return false when something wrong
        require(_erc20Addr.call(bytes4(keccak256("transfer(address,uint256)")), _to, _value));

        // handle returndata
        return handleReturnData();
    }

    function asmTransferFrom(address _erc20Addr, address _from, address _to, uint256 _value) internal returns (bool result) {

        // Must be a contract addr first!
        isContract(_erc20Addr);

        // call return false when something wrong
        require(_erc20Addr.call(bytes4(keccak256("transferFrom(address,address,uint256)")), _from, _to, _value));

        // handle returndata
        return handleReturnData();
    }

    function asmApprove(address _erc20Addr, address _spender, uint256 _value) internal returns (bool result) {

        // Must be a contract addr first!
        isContract(_erc20Addr);

        // call return false when something wrong
        require(_erc20Addr.call(bytes4(keccak256("approve(address,uint256)")), _spender, _value));

        // handle returndata
        return handleReturnData();
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

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
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


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
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
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

}

// File: contracts/FUTC.sol

/**
 * Holders of FUTC can claim tokens fed to it using the claimTokens()
 * function. This contract will be fed several tokens automatically by other Futereum
 * contracts.
 */
contract FUTC1 is StandardToken {
  using SafeMath for uint;
  using ERC20AsmFn for ERC20;

  string public constant name = "Futereum Centurian 1";
  string public constant symbol = "FUTC1";
  uint8 public constant decimals = 0;

  address public admin;
  uint public totalEthReleased = 0;

  mapping(address => uint) public ethReleased;
  address[] public trackedTokens;
  mapping(address => bool) public isTokenTracked;
  mapping(address => uint) public totalTokensReleased;
  mapping(address => mapping(address => uint)) public tokensReleased;

  constructor() public {
    admin = msg.sender;
    totalSupply_ = 100000;
    balances[admin] = totalSupply_;
    emit Transfer(address(0), admin, totalSupply_);
  }

  function () public payable {}

  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  function changeAdmin(address _receiver) onlyAdmin external {
    admin = _receiver;
  }

  /**
   * Claim your eth.
   */
  function claimEth() public {
    claimEthFor(msg.sender);
  }

  // Claim eth for address
  function claimEthFor(address payee) public {
    require(balances[payee] > 0);

    uint totalReceived = address(this).balance.add(totalEthReleased);
    uint payment = totalReceived.mul(
      balances[payee]).div(
        totalSupply_).sub(
          ethReleased[payee]
    );

    require(payment != 0);
    require(address(this).balance >= payment);

    ethReleased[payee] = ethReleased[payee].add(payment);
    totalEthReleased = totalEthReleased.add(payment);

    payee.transfer(payment);
  }

  // Claim your tokens
  function claimMyTokens() external {
    claimTokensFor(msg.sender);
  }

  // Claim on behalf of payee address
  function claimTokensFor(address payee) public {
    require(balances[payee] > 0);

    for (uint16 i = 0; i < trackedTokens.length; i++) {
      claimToken(trackedTokens[i], payee);
    }
  }

  /**
   * Transfers the unclaimed token amount for the given token and address
   * @param _tokenAddr The address of the ERC20 token
   * @param _payee The address of the payee (FUTC holder)
   */
  function claimToken(address _tokenAddr, address _payee) public {
    require(balances[_payee] > 0);
    require(isTokenTracked[_tokenAddr]);

    uint payment = getUnclaimedTokenAmount(_tokenAddr, _payee);
    if (payment == 0) {
      return;
    }

    ERC20 Token = ERC20(_tokenAddr);
    require(Token.balanceOf(address(this)) >= payment);
    tokensReleased[address(Token)][_payee] = tokensReleased[address(Token)][_payee].add(payment);
    totalTokensReleased[address(Token)] = totalTokensReleased[address(Token)].add(payment);
    Token.asmTransfer(_payee, payment);
  }

  /**
   * Returns the amount of a token (tokenAddr) that payee can claim
   * @param tokenAddr The address of the ERC20 token
   * @param payee The address of the payee
   */
  function getUnclaimedTokenAmount(address tokenAddr, address payee) public view returns (uint) {
    ERC20 Token = ERC20(tokenAddr);
    uint totalReceived = Token.balanceOf(address(this)).add(totalTokensReleased[address(Token)]);
    uint payment = totalReceived.mul(
      balances[payee]).div(
        totalSupply_).sub(
          tokensReleased[address(Token)][payee]
    );
    return payment;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(msg.sender != _to);
    uint startingBalance = balances[msg.sender];
    require(super.transfer(_to, _value));

    transferChecks(msg.sender, _to, _value, startingBalance);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
    require(_from != _to);
    uint startingBalance = balances[_from];
    require(super.transferFrom(_from, _to, _value));

    transferChecks(_from, _to, _value, startingBalance);
    return true;
  }

  function transferChecks(address from, address to, uint checks, uint startingBalance) internal {

    // proportional amount of eth released already
    uint claimedEth = ethReleased[from].mul(
      checks).div(
        startingBalance
    );

    // increment to's released eth
    ethReleased[to] = ethReleased[to].add(claimedEth);

    // decrement from's released eth
    ethReleased[from] = ethReleased[from].sub(claimedEth);

    for (uint16 i = 0; i < trackedTokens.length; i++) {
      address tokenAddr = trackedTokens[i];

      // proportional amount of token released already
      uint claimed = tokensReleased[tokenAddr][from].mul(
        checks).div(
          startingBalance
      );

      // increment to's released token
      tokensReleased[tokenAddr][to] = tokensReleased[tokenAddr][to].add(claimed);

      // decrement from's released token
      tokensReleased[tokenAddr][from] = tokensReleased[tokenAddr][from].sub(claimed);
    }
  }

  function trackToken(address _addr) onlyAdmin external {
    require(_addr != address(0));
    require(!isTokenTracked[_addr]);
    trackedTokens.push(_addr);
    isTokenTracked[_addr] = true;
  }

  /*
   * However unlikely, it is possible that the number of tracked tokens
   * reaches the point that would make the gas cost of transferring FUTC
   * exceed the block gas limit. This function allows the admin to remove
   * a token from the tracked token list thus reducing the number of loops
   * required in transferChecks, lowering the gas cost of transfer. The
   * remaining balance of this token is sent back to the token's contract.
   *
   * Removal is irreversible.
   *
   * @param _addr The address of the ERC token to untrack
   * @param _position The index of the _addr in the trackedTokens array.
   * Use web3 to cycle through and find the index position.
   */
  function unTrackToken(address _addr, uint16 _position) onlyAdmin external {
    require(isTokenTracked[_addr]);
    require(trackedTokens[_position] == _addr);

    ERC20(_addr).asmTransfer(_addr, ERC20(_addr).balanceOf(address(this)));
    trackedTokens[_position] = trackedTokens[trackedTokens.length-1];
    delete trackedTokens[trackedTokens.length-1];
    trackedTokens.length--;
  }
}
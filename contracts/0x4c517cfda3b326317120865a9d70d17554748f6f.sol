pragma solidity ^0.4.24;

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/
// from https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20Interface.sol
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

 /// @dev lots token (an ERC20 token) contract
 /// @dev Token distribution is also included
 /// @dev Tokens reserved for fundraising (50%) can be withdraw any time
 /// @dev Tokens reserved for the foundation (5%) and the team (20%) can be withdrawn in a monthly base, for 48 months
 /// @dev Tokens reserved for the community (25%) can be withdrawn in a yealy base, 50%, 30%, 10%, 10% for each year, respectively
contract LOTS is EIP20Interface {
    using SafeMath for uint;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    string public constant name = "LOTS Token";                 
    uint8 public constant decimals = 18;     
    string public constant symbol = "LOTS";                 
    uint public constant finalSupply = 10**9 * 10**uint(decimals); // 1 billion
    uint public totalSupply;  // total supply is dynamically added when new tokens are minted

    // distrubutions of final supply
    uint public constant fundraisingReservation = 50 * finalSupply / 100;
    uint public constant foundationReservation = 5 * finalSupply / 100;
    uint public constant communityReservation = 25 * finalSupply / 100;
    uint public constant teamReservation = 20 * finalSupply / 100;

    // each part can be withdrawed once the next withdraw day is reached
    // Attention: if former withdraw is not conducted, the next withdraw will be delayed
    uint public nextWithdrawDayFoundation;
    uint public nextWithdrawDayCommunity;
    uint public nextWithdrawDayTeam;

    uint public withdrawedFundrasingPart; // tokens belongs to the fundrasing part that are already withdrawn
    uint public withdrawedFoundationCounter;  // each month the counter plus 1
    uint public withdrawedCoummunityCounter;  // each year the counter plus 1
    uint public withdrawedTeamCounter;  //each month the counter plus 1
    
    address public manager; // who may decide the address to withdraw, as well as pause the circulation
    bool public paused; // whether the circulation is paused

    event Burn(address _from, uint _value);

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    modifier notPaused() {
        require(paused == false);
        _;
    }

    constructor() public {
        manager = msg.sender;
        nextWithdrawDayFoundation = now;
        nextWithdrawDayCommunity = now;
        nextWithdrawDayTeam = now;
    }

    /// @dev pause or restart the circulaton
    function pause() public onlyManager() {
        paused = !paused;
    }

    function withdrawFundraisingPart(address _to, uint _value) public onlyManager() {
        require(_value.add(withdrawedFundrasingPart) <= fundraisingReservation);
        balances[_to] = balances[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        withdrawedFundrasingPart = withdrawedFundrasingPart.add(_value);
        emit Transfer(address(this), _to, _value);
    }

    function withdrawFoundationPart(address _to) public onlyManager() {
        require(now > nextWithdrawDayFoundation);
        require(withdrawedFoundationCounter < 48);
        balances[_to] = balances[_to].add(foundationReservation / 48);
        withdrawedFoundationCounter += 1;
        nextWithdrawDayFoundation += 30 days;
        totalSupply = totalSupply.add(foundationReservation / 48);
        emit Transfer(address(this), _to, foundationReservation / 48);
    }

    function withdrawCommunityPart(address _to) public onlyManager() {
        require(now > nextWithdrawDayCommunity);
        uint _value;
        if (withdrawedCoummunityCounter == 0) {
            _value = communityReservation / 2;
        } else if (withdrawedCoummunityCounter == 1) {
            _value = communityReservation * 3 / 10;
        } else if (withdrawedCoummunityCounter == 2 || withdrawedCoummunityCounter == 3) {
            _value = communityReservation / 10;
        } else {
            return;
        }
        balances[_to] = balances[_to].add(_value);
        withdrawedCoummunityCounter += 1;
        nextWithdrawDayCommunity += 365 days;
        totalSupply = totalSupply.add(_value);
        emit Transfer(address(this), _to, _value);
    }

    function withdrawTeam(address _to) public onlyManager() {
        require(now > nextWithdrawDayTeam);
        require(withdrawedTeamCounter < 48);
        balances[_to] = balances[_to].add(teamReservation / 48);
        withdrawedTeamCounter += 1;
        nextWithdrawDayTeam += 30 days;
        totalSupply = totalSupply.add(teamReservation / 48);
        emit Transfer(address(this), _to, teamReservation / 48);
    }

    /// @dev remove owned tokens from circulation and destory them
    function burn(uint _value) public returns (bool success) {
        totalSupply = totalSupply.sub(_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender. *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns(bool)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender. *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool)
    {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue){
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        return true;
    }
    
    /// below are the standerd functions of ERC20 tokens

    function transfer(address _to, uint _value) public notPaused() returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public notPaused() returns (bool success) {
        uint allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }   
}

/**
 * @title SafeMat
 * https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
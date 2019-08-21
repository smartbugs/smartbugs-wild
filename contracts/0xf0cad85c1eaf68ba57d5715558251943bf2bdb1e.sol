pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
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
   * @dev Throws if called by any account other than the owner.
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

  function burn(uint256 _value)
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

  event Burn(
    address indexed burner,
    uint256 value
  );

}

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

contract LoligoToken is ERC20, Ownable {
  using SafeMath for uint256;

  string public constant name = "Loligo Token";
  string public constant symbol = "LLG";
  uint8 public constant decimals = 18;
  uint256 private totalSupply_ = 16000000 * (10 ** uint256(decimals));
  bool public locked = true;
  mapping (address => uint256) private balances;

  mapping (address => mapping (address => uint256)) private allowed;

  modifier onlyWhenUnlocked() {
    require(!locked || msg.sender == owner);
    _;
  }

  constructor() public {
      balances[msg.sender] = totalSupply_;
  }
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
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public onlyWhenUnlocked returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
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
    allowed[msg.sender][_spender] = _value;
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
    onlyWhenUnlocked
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

  function burn(uint256 _value) public returns (bool success){
    require(_value > 0);
    require(_value <= balances[msg.sender]);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    return true;
  }

  function unlock() public onlyOwner {
    locked = false;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

contract Whitelist is Ownable{

  // Whitelisted address
  mapping(address => bool) public whitelist;
  // evants
  event LogAddedBeneficiary(address indexed _beneficiary);
  event LogRemovedBeneficiary(address indexed _beneficiary);

  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] _beneficiaries) public onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
      emit LogAddedBeneficiary(_beneficiaries[i]);
    }
  }

  /**
   * @dev Removes single address from whitelist.
   * @param _beneficiary Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _beneficiary) public onlyOwner {
    whitelist[_beneficiary] = false;
    emit LogRemovedBeneficiary(_beneficiary);
  }

  function isWhitelisted(address _beneficiary) public view returns (bool) {
    return (whitelist[_beneficiary]);
  }

}

contract TokenBonus is Ownable {
    using SafeMath for uint256;

    address public owner;
    mapping (address => uint256) public bonusBalances;   // visible to the public or not ???
    address[] public bonusList;
    uint256 public savedBonusToken;

    constructor() public {
        owner = msg.sender;
    }

    function distributeBonusToken(address _token, uint256 _percent) public onlyOwner {
        for (uint256 i = 0; i < bonusList.length; i++) {
            require(LoligoToken(_token).balanceOf(address(this)) >= savedBonusToken);

            uint256 amountToTransfer = bonusBalances[bonusList[i]].mul(_percent).div(100);
            bonusBalances[bonusList[i]] = bonusBalances[bonusList[i]].sub(amountToTransfer);
            savedBonusToken = savedBonusToken.sub(amountToTransfer);
            LoligoToken(_token).transfer(bonusList[i], amountToTransfer);
        }
    }
}

contract Presale is Pausable, Whitelist, TokenBonus {
    using SafeMath for uint256;

    // addresse for testing to change
    address private wallet = 0xE2a5B96B6C1280cfd93b57bcd3fDeAf73691D3f3;     // ETH wallet

    // LLG token
    LoligoToken public token;

    // Presale period
    uint256 public presaleRate;                                          // Rate presale LLG token per ether
    uint256 public totalTokensForPresale;                                // LLG tokens allocated for the Presale
    bool public presale1;                                                // Presale first period
    bool public presale2;                                                // Presale second period

    // presale params
    uint256 public savedBalance;                                        // Total amount raised in ETH
    uint256 public savedPresaleTokenBalance;                            // Total sold tokens for presale
    mapping (address => uint256) balances;                              // Balances in incoming Ether

    // Events
    event Contribution(address indexed _contributor, uint256 indexed _value, uint256 indexed _tokens);     // Event to record new contributions
    event PayEther(address indexed _receiver, uint256 indexed _value, uint256 indexed _timestamp);         // Event to record each time Ether is paid out
    event BurnTokens(uint256 indexed _value, uint256 indexed _timestamp);                                  // Event to record when tokens are burned.


    // Initialization
    constructor(address _token) public {
        // add address of the specific contract
        token = LoligoToken(_token);
    }


    // Fallbck function for contribution
    function () external payable whenNotPaused {
        _buyPresaleTokens(msg.sender);
    }
    
    // Contribute Function, accepts incoming payments and tracks balances for each contributors
    function _buyPresaleTokens(address _beneficiary) public payable  {
        require(presale1 || presale2);
        require(msg.value >= 0.25 ether);
        require(isWhitelisted(_beneficiary));
        require(savedPresaleTokenBalance.add(_getTokensAmount(msg.value)) <= totalTokensForPresale);

        if (msg.value >= 10 ether) {
          _deliverBlockedTokens(_beneficiary);
        }else {
          _deliverTokens(_beneficiary);
        }
    }

    /***********************************
    *       Public functions for the   *
    *           Presale period         *
    ************************************/

    // Function to set Rate & tokens to sell for presale (period1)
    function startPresale(uint256 _rate, uint256 _totalTokensForPresale) public onlyOwner {
        require(_rate != 0 && _totalTokensForPresale != 0);
        presaleRate = _rate;
        totalTokensForPresale = _totalTokensForPresale;
        presale1 = true;
        presale2 = false;
    }

    // Function to move to the second period for presale (period2)
    function updatePresale() public onlyOwner {
        require(presale1);
        presale1 = false;
        presale2 = true;
    }

    // Function to close the presale period2
    function closePresale() public onlyOwner {
        require(presale2 || presale1);
        presale1 = false;
        presale2 = false;
    }

    // Function to transferOwnership of the LLG token
    function transferTokenOwnership(address _newOwner) public onlyOwner {
        token.transferOwnership(_newOwner);
    }

    // Function to transfer the rest of tokens not sold
    function transferToken(address _crowdsale) public onlyOwner {
        require(!presale1 && !presale2);
        require(token.balanceOf(address(this)) > savedBonusToken);
        uint256 tokensToTransfer =  token.balanceOf(address(this)).sub(savedBonusToken);
        token.transfer(_crowdsale, tokensToTransfer);
    }
    /***************************************
    *          internal functions          *
    ****************************************/

    function _deliverBlockedTokens(address _beneficiary) internal {
        uint256 tokensAmount = msg.value.mul(presaleRate);
        uint256 bonus = tokensAmount.mul(_checkPresaleBonus(msg.value)).div(100);

        savedPresaleTokenBalance = savedPresaleTokenBalance.add(tokensAmount.add(bonus));
        token.transfer(_beneficiary, tokensAmount);
        savedBonusToken = savedBonusToken.add(bonus);
        bonusBalances[_beneficiary] = bonusBalances[_beneficiary].add(bonus);
        bonusList.push(_beneficiary);
        wallet.transfer(msg.value);
        emit PayEther(wallet, msg.value, now);
    }

    function _deliverTokens(address _beneficiary) internal {
      uint256 tokensAmount = msg.value.mul(presaleRate);
      uint256 tokensToTransfer = tokensAmount.add((tokensAmount.mul(_checkPresaleBonus(msg.value))).div(100));

      savedPresaleTokenBalance = savedPresaleTokenBalance.add(tokensToTransfer);
      token.transfer(_beneficiary, tokensToTransfer);
      wallet.transfer(msg.value);
      emit PayEther(wallet, msg.value, now);
    }

    function _checkPresaleBonus(uint256 _value) internal view returns (uint256){
        if(presale1 && _value >= 0.25 ether){
          return 40;
        }else if(presale2 && _value >= 0.25 ether){
          return 30;
        }else{
          return 0;
        }
    }

    function _getTokensAmount(uint256 _value) internal view returns (uint256){
       uint256 tokensAmount = _value.mul(presaleRate);
       uint256 tokensToTransfer = tokensAmount.add((tokensAmount.mul(_checkPresaleBonus(_value))).div(100));
       return tokensToTransfer;
    }
}
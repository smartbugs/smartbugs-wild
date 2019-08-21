pragma solidity ^0.4.14;




contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    
    function transfer(address to, uint256 value) returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function allowance(address owner, address spender) constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) returns (bool);
    
    function approve(address spender, uint256 value) returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract StandardToken is ERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}


contract Token is StandardToken, Ownable {
    using SafeMath for uint256;

  // start and end block where investments are allowed (both inclusive)
    uint256 public startBlock;
    uint256 public endBlock;
  // address where funds are collected
    address public wallet;

  // how many token units a buyer gets per wei
    uint256 public tokensPerEther;

  // amount of raised money in wei
    uint256 public weiRaised;

    uint256 public cap;
    uint256 public issuedTokens;
    string public name = "Enter-Coin";
    string public symbol = "ENTRC";
    uint public decimals = 8;
    uint public INITIAL_SUPPLY = 100000000 * (10**decimals);
    address founder; 
    uint internal factor;
    bool internal isCrowdSaleRunning;
    uint contractDeployedTime;
    uint mf = 10**decimals; // multiplication factor due to decimal value

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    function Token() { 
  
    

    wallet = address(0x6D6D8fDFeFDA898341a60340a5699769Af2BA350); 
    founder = address(0x0CC74179395d9434C9A31586763861327C499E76); // address of the founder

    tokensPerEther = 306; // 12/10/17 value 1 dollar value
    endBlock = block.number + 1000000;

    totalSupply = INITIAL_SUPPLY;
                          // reserve         // for token sale
    balances[msg.sender] = (25000000 * mf) + (65000000 * mf);
    balances[founder] = 10000000 * mf;

    startBlock = block.number;    
    cap = 65000000 * mf;
    issuedTokens = 0;
    factor = 10**10;
    isCrowdSaleRunning = true;
    contractDeployedTime = now;

    }

    // crowdsale entrypoint
    // fallback function can be used to buy tokens

  function () payable {
    buyTokens(msg.sender);
  }
  
  function getTimePassed() public constant returns (uint256) {
      return (now - contractDeployedTime).div(1 days);
  }
  // bonus based on the current time
  function applyBonus(uint256 tokens) internal constant returns (uint256) {

    if ( (now < (contractDeployedTime + 14 days)) && (issuedTokens < (3500000*mf)) ) {

      return tokens.mul(20).div(10); // 100% bonus
      
    } else if ((now < (contractDeployedTime + 20 days)) && (issuedTokens < (13500000*mf)) ) {
    
      return tokens.mul(15).div(10); // 50% bonus
    

    } else if ((now < (contractDeployedTime + 26 days)) && (issuedTokens < (23500000*mf)) ) {

      return tokens.mul(13).div(10); // 30% bonus

    } else if ((now < (contractDeployedTime + 32 days)) && (issuedTokens < (33500000*mf)) ) {

      return tokens.mul(12).div(10); // 20% bonus

    } else if ((now < (contractDeployedTime + 38 days)) && (issuedTokens < (43500000*mf)) ) {
      return tokens.mul(11).div(10); // 10% bonus

    } 

    return tokens; // if reached till hear means no bonus 

  }

  // stop the crowd sale
  function stopCrowdSale() onlyOwner {
    isCrowdSaleRunning = false;
    endBlock = block.number;
  }

  function resetContractDeploymentDate() onlyOwner {
      contractDeployedTime = now;
  }

  function startCrowdsale(uint interval) onlyOwner {
    if ( endBlock < block.number ) {
      endBlock = block.number;  // normalize the end block
    }

    endBlock = endBlock.add(interval);
    isCrowdSaleRunning = true;
  }

  function setWallet(address newWallet) onlyOwner {
    require(newWallet != address(0));
    wallet = newWallet;
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(tokensPerEther).div(factor);

    tokens = applyBonus(tokens);
    
    // check if the tokens are more than the cap
    require(issuedTokens.add(tokens) <= cap);
    // update state
    weiRaised = weiRaised.add(weiAmount);
    issuedTokens = issuedTokens.add(tokens);

    forwardFunds();
    // transfer the token
    issueToken(beneficiary,tokens);
    TokenPurchase(msg.sender, beneficiary, msg.value, tokens);

  }

  function setFounder(address newFounder) onlyOwner {
    require(newFounder != address(0));
    founder = newFounder; 
  }

  // can be issued to anyone without owners concent but as this method is internal only buyToken is calling it.
  function issueToken(address beneficiary, uint256 tokens) internal {
    balances[owner] = balances[owner].sub(tokens);
    balances[beneficiary] = balances[beneficiary].add(tokens);
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    // to normalize the input 
    wallet.transfer(msg.value);
  
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    uint256 current = block.number;
    bool withinPeriod = current >= startBlock && current <= endBlock;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase && isCrowdSaleRunning;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
      return (block.number > endBlock) || !isCrowdSaleRunning;
  }

}
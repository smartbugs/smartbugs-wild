pragma solidity ^0.4.19;

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

pragma solidity ^0.4.18;

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
  function Ownable(address _owner) public {
    owner = _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(tx.origin == owner);
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

pragma solidity ^0.4.19;

contract Stoppable is Ownable {
  bool public halted;

  event SaleStopped(address owner, uint256 datetime);

  function Stoppable(address owner) public Ownable(owner) {}

  modifier stopInEmergency {
    require(!halted);
    _;
  }

  modifier onlyInEmergency {
    require(halted);
    _;
  }

  function hasHalted() public view returns (bool isHalted) {
  	return halted;
  }

   // called by the owner on emergency, triggers stopped state
  function stopICO() external onlyOwner {
    halted = true;
    SaleStopped(msg.sender, now);
  }
}

pragma solidity ^0.4.19;

/* SALE_mtf is the smart contract facilitating MetaFusions first public crowdsale. Created by Iconemy on 11/10/18
 * SALE_mtf allows the owner of the MetaFusion tokens to 'allow' the sale to sell a portion of tokens on his/her behalf, 
 * this will then allow the owner to run further sales in the future by allowing to spend a further portion of tokens. 
 * The sale is stoppable therefore, the owner can stop the sale in an emergency and allow the investors to withdraw their 
 * investments. 
 */
contract SALE_mtf is Stoppable {
  using SafeMath for uint256;

  bool private approval = false;

  mtfToken public token;
  uint256 public rate;

  uint256 public startTime;
  uint256 public endTime;

  uint256 public weiRaised;
  uint256 public tokensSent;

  mapping(address => uint256) public balanceOf;
  mapping(address => uint256) public tokenBalanceOf;

  address public iconemy_wallet;
  uint256 public commission; 

  event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount, uint256 datetime);
  event BeneficiaryWithdrawal(address beneficiary, uint256 amount, uint256 datetime);
  event CommissionCollected(address beneficiary, uint256 amount, uint256 datetime);

  // CONSTRUCTOR
  function SALE_mtf(address _token, uint256 _rate, uint256 _startTime, uint256 _endTime, address _iconemy, address _owner) public Stoppable(_owner) {
    require(_startTime > now);
    require(_startTime < _endTime);

    token = mtfToken(_token);

    rate = _rate;
    startTime = _startTime;
    endTime = _endTime;
    iconemy_wallet = _iconemy;
  }

  // Recieve approval is used in the sales interface on the MetaFusion ERC-20 token, allowing the owner to use approveAndCall
  // When this function is called, we check the allowance of the sale the tokens interface and store 1% of that as a maximum commission
  // We do this to reserve 1% of tokens in the case that the sale sells out, Iconemy will collect the full 1%. 
  function receiveApproval() onlyOwner external {
    approval = true;
    uint256 allowance = allowanceOf();

    // Reserved for Iconemy commission
    commission = allowance / 100;
  }

  // Uses the token interface to check how many tokens the sale is allowed to sell
  function allowanceOf() public view returns(uint256) {
    return token.allowanceOf(owner, this);
  }

  // Shows that the sale has been given approval to sell tokens by the token owner
  function hasApproval() public view returns(bool) {
    return approval;
  }

  function getPrice() public view returns(uint256) {
    return rate;
  }

  /*
   * This method has taken from Pickeringware ltd
   * We have split this method down into overidable functions which may affect how users purchase tokens
  */ 
  function buyTokens() public stopInEmergency payable {
    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = tokensToRecieve(weiAmount);

    validPurchase(tokens);

    finalizeSale(msg.sender, weiAmount, tokens);

    TokenPurchase(msg.sender, msg.value, tokens, now);
  }

  //Check that the amount of tokens requested is less than or equal to the ammount of tokens allowed to send
  function checkAllowance(uint256 _tokens) public view {
    uint256 allowance = allowanceOf();

    allowance = allowance - commission;

    require(allowance >= _tokens);
  }

  // If the transfer function works using the token interface, mark the balances of the buyer
  function finalizeSale(address from, uint256 _weiAmount, uint256 _tokens) internal {
    require(token.transferFrom(owner, from, _tokens));

    balanceOf[from] = balanceOf[from].add(_weiAmount);
    tokenBalanceOf[from] = tokenBalanceOf[from].add(_tokens);

    weiRaised = weiRaised.add(_weiAmount);
    tokensSent = tokensSent.add(_tokens);
  }

  // Calculate amount of tokens due for the amount of ETH sent
  function tokensToRecieve(uint256 _wei) internal view returns (uint256 tokens) {
    return _wei.div(rate);
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime || halted;
  }

  // Checks if the purchase is valid
  function validPurchase(uint256 _tokens) internal view returns (bool) {
    require(!hasEnded());

    checkAllowance(_tokens);

    bool withinPeriod = now >= startTime && now <= endTime;

    bool nonZeroPurchase = msg.value != 0;

    require(withinPeriod && nonZeroPurchase);
  }

  // Allows someone to check if they are valid for a refund
  // This can be used front-end to show/hide the collect refund function 
  function refundAvailable() public view returns(bool) {
    return balanceOf[msg.sender] > 0 && hasHalted();
  }

  // Allows an investor to collect their investment if the sale was stopped prematurely
  function collectRefund() public onlyInEmergency {
    uint256 balance = balanceOf[msg.sender];

    require(balance > 0);

    balanceOf[msg.sender] = 0;

    msg.sender.transfer(balance);
  }

  // Allows the owner to collect the eth raised in the sale
  function collectInvestment() public onlyOwner stopInEmergency returns(bool) {
    require(hasEnded());

    owner.transfer(weiRaised);
    BeneficiaryWithdrawal(owner, weiRaised, now);
  }

  // Allows Iconemy to collect 1% of the tokens sold in the crowdsale
  function collectCommission() public stopInEmergency returns(bool) {
    require(msg.sender == iconemy_wallet);
    require(hasEnded());

    uint256 one_percent = tokensSent / 100;

    finalizeSale(iconemy_wallet, 0, one_percent);

    CommissionCollected(iconemy_wallet, one_percent, now);
  }
}  

// Token interface used for interacting with the MetaFusion ERC-20 contract
contract mtfToken { 
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success); 
  function allowanceOf(address _owner, address _spender) public constant returns (uint256 remaining);
}
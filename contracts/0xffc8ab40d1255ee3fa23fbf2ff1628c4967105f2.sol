pragma solidity ^0.4.13;

contract AbstractToken {

    function mint(address _to, uint256 _amount) public returns (bool);
    function transferOwnership(address newOwner) public;
    function finishMinting() public returns (bool);

}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Destructible is Ownable {

  function Destructible() payable { } 

  /**
   * @dev Transfers the current balance to the owner and terminates the contract. 
   */
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}

contract MinimumValueTransfer is Ownable {

  uint256 internal minimumWeiRequired;

  /**
   * @dev modifier to allow actions only when the minimum wei is received
   */
  modifier minimumWeiMet() {
    require(msg.value >= minimumWeiRequired);
    _;
  }

  /**
   * @dev Allows the owner to update the Minimum required Wei
   */
  function updateMinimumWeiRequired(uint256 minimunTransferInWei) public onlyOwner {
    minimumWeiRequired = minimunTransferInWei;
  }


  /**
   * @dev Shows the minimum required Wei in the Smart contract
   */
  function minimumTransferInWei() public constant returns(uint256) {
    return minimumWeiRequired;
  }

}

contract Crowdsale is MinimumValueTransfer {
  using SafeMath for uint256;

  // The token being sold
  AbstractToken public token;

  // start and end time where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(address _tokenAddress, uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);
    require(_tokenAddress != 0x0);

    // Create and instance pointer to the already deployed Token
    token = createTokenContract(_tokenAddress);

    // Set the timelines, exchange rate & wallet to store the received ETH
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold. 
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract(address _tokenAddress) internal returns (AbstractToken) {
    return AbstractToken(_tokenAddress);
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() minimumWeiMet internal constant returns (bool) {
    uint256 current = now;
    bool withinPeriod = current >= startTime && current <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase && !hasEnded();
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }

  // Allows the Owner to run any emergency updates on the time line
  function updateCrowdsaleTimeline(uint256 newStartTime, uint256 newEndTime) onlyOwner external {
    require (newStartTime > 0 && newEndTime > newStartTime);
    startTime = newStartTime;
    endTime = newEndTime;
  }

  // Gets the Human readable progress for the current crowsale timeline in %
  function crowdsaleProgress() external constant returns(uint256){
    return now > endTime ? 100: now.sub(startTime).mul(100).div(endTime.sub(startTime));
  }

  // Transfers the Token ownership
  function transferTokenOwnership(address newOwner) public onlyOwner {
    token.transferOwnership(newOwner);
  }


}

contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

contract AlloyPresale is Ownable, Destructible, Pausable, CappedCrowdsale {

    using SafeMath for uint256;

    function AlloyPresale(address _tokenAddress, uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _cap) CappedCrowdsale(_cap) Crowdsale(_tokenAddress, _startTime, _endTime, _rate, _wallet) {
    }

    /**
     * Overrides the base function
     */
    function hasEnded() public constant returns (bool) {
        return paused || super.hasEnded();
    }

}
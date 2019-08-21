/*

Copyright (c) 2017 Esperite Ltd. <legal@esperite.co.nz>

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.

*/

pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
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

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint256 _value, bytes _data) public;
}

contract ERC20ERC223 {
  uint256 public totalSupply;
  function balanceOf(address _owner) public constant returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _value);
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _value, bytes _data);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Deco is ERC20ERC223 {

  using SafeMath for uint256;

  string public constant name = "Deco";
  string public constant symbol = "DEC";
  uint8 public constant decimals = 18;
  
  uint256 public constant totalSupply = 6*10**26; // 600,000,000. 000,000,000,000,000,000 units
    
  // Accounts
  
  mapping(address => Account) private accounts;
  
  struct Account {
    uint256 balance;
    mapping(address => uint256) allowed;
    mapping(address => bool) isAllowanceAuthorized;
  }  
  
  // Fix for the ERC20 short address attack.
  // http://vessenes.com/the-erc20-short-address-attack-explained/
  modifier onlyPayloadSize(uint256 size) {
    require(msg.data.length >= size + 4);
     _;
  }

  // Initialization

  function Deco() {
    accounts[msg.sender].balance = totalSupply;
    Transfer(this, msg.sender, totalSupply);
  }

  // Balance

  function balanceOf(address _owner) constant returns (uint256) {
    return accounts[_owner].balance;
  }

  // Transfers

  function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) returns (bool) {
    performTransfer(msg.sender, _to, _value, "");
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transfer(address _to, uint256 _value, bytes _data) onlyPayloadSize(2 * 32) returns (bool) {
    performTransfer(msg.sender, _to, _value, _data);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) returns (bool) {
    require(hasApproval(_from, msg.sender));
    uint256 _allowed = accounts[_from].allowed[msg.sender];    
    performTransfer(_from, _to, _value, "");    
    accounts[_from].allowed[msg.sender] = _allowed.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function performTransfer(address _from, address _to, uint256 _value, bytes _data) private returns (bool) {
    require(_to != 0x0);
    accounts[_from].balance = accounts[_from].balance.sub(_value);    
    accounts[_to].balance = accounts[_to].balance.add(_value);
    if (isContract(_to)) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
      receiver.tokenFallback(_from, _value, _data);
    }    
    return true;
  }

  function isContract(address _to) private constant returns (bool) {
    uint256 codeLength;
    assembly {
      codeLength := extcodesize(_to)
    }
    return codeLength > 0;
  }

  // Approval & Allowance
  
  function approve(address _spender, uint256 _value) returns (bool) {
    require(msg.sender != _spender);
    // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_value != 0) && (accounts[msg.sender].allowed[_spender] != 0)) {
      revert();
      return false;
    }
    accounts[msg.sender].allowed[_spender] = _value;
    accounts[msg.sender].isAllowanceAuthorized[_spender] = true;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return accounts[_owner].allowed[_spender];
  }

  function hasApproval(address _owner, address _spender) constant returns (bool) {        
    return accounts[_owner].isAllowanceAuthorized[_spender];
  }

  function removeApproval(address _spender) {    
    delete(accounts[msg.sender].allowed[_spender]);
    accounts[msg.sender].isAllowanceAuthorized[_spender] = false;
  }

}

contract DecoBank {
  
  using SafeMath for uint256;

  Deco public token;  
  
  address private crowdsaleWallet;
  address private decoReserveWallet;
  uint256 public weiRaised;

  uint256 public constant totalSupplyUnits = 6*10**26;
  uint256 private constant MINIMUM_WEI = 10**16;
  uint256 private constant BASE = 10**18;
  uint256 public originalRate = 3000;

  uint256 public crowdsaleDistributedUnits = 0;
  uint256 public issuerDistributedUnits = 0;

  // Presale
  uint256 public presaleStartTime;
  uint256 public presaleEndTime;
  uint256 private presaleDiscount = 50;
  uint256 private presalePercentage = 5;

  uint256 public issuerReservedMaximumPercentage = 5;

  // Sale
  uint256 public saleStartTime;
  uint256 public saleEndTime;
  uint256 private saleDiscount = 25;

  // Rewards
  uint256 public rewardDistributionStart;
  uint256 public rewardDistributedUnits = 0;  

  // Contributors
  mapping(address => Contributor) private contributors;

  struct Contributor {    
    uint256 contributedWei;
    uint256 decoUnits;
    uint256 rewardDistributedDecoUnits;
  }

  uint256 public contributorsCount = 0;

  // Events
  event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
  event RewardDistributed(address indexed beneficiary, uint256 amount);
  event RemainingRewardOwnershipChanged(address indexed from, address indexed to);  

  address private contractCreator = msg.sender;

  function DecoBank() {
    token = new Deco();

    presaleStartTime = 1506816000; // Sunday, October 1, 2017 12:00:00 AM
    presaleEndTime = presaleStartTime + 30 days;

    saleStartTime = presaleEndTime + 1 days;
    saleEndTime = saleStartTime + 180 days;

    rewardDistributionStart = saleEndTime + 1 days;

    crowdsaleWallet = 0xEaC4ff9Aa8342d8B5c59370Ac04a55367A788B30;
    decoReserveWallet = 0xDA01fDeEF573b5cC51D0Ddc2600F476aaC71A600;
  }

  // Sale events

  modifier validPurchase() {
    require(isValidPurchase());
    _;
  }
  
  function isValidPurchase() private returns (bool) {
    bool minimumContribution = msg.value >= MINIMUM_WEI;
    return minimumContribution && (presaleActive() || saleActive());
  }  

  function() payable validPurchase {
    require(msg.sender != 0x0);
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) private {    
    uint256 weiAmount = msg.value;    
    uint256 tokens = weiAmount.mul(currentRate());
    uint256 issuerReserveTokens = unitsForIssuerReserve(tokens);
    
    require(crowdsaleDistributedUnits.add(tokens).add(issuerReserveTokens) <= totalSupplyUnits);

    incrementContributorsCount(beneficiary);

    contributors[beneficiary].decoUnits = contributors[beneficiary].decoUnits.add(tokens);
    contributors[beneficiary].contributedWei = contributors[beneficiary].contributedWei.add(weiAmount);

    issuerDistributedUnits = issuerDistributedUnits.add(issuerReserveTokens);
    crowdsaleDistributedUnits = crowdsaleDistributedUnits.add(tokens).add(issuerReserveTokens);
    weiRaised = weiRaised.add(weiAmount);
            
    TokenPurchase(beneficiary, weiAmount, tokens);
    
    crowdsaleWallet.transfer(weiAmount);
    token.transfer(beneficiary, tokens);
    if (issuerReserveTokens != 0) {
      token.transfer(decoReserveWallet, issuerReserveTokens);
    }            
  }

  function incrementContributorsCount(address _address) private {
    if (contributors[_address].contributedWei == 0) {
      contributorsCount = contributorsCount.add(1);
    }
  }

  function contributedWei(address _address) constant public returns (uint256) {
    return contributors[_address].contributedWei;
  }

  function distibutedDecoUnits(address _address) constant public returns (uint256) {
    return contributors[_address].decoUnits;
  }

  function circulatingSupply() constant public returns (uint256) {
    return crowdsaleDistributedUnits.add(rewardDistributedUnits);
  }

  function currentDiscountPercentage() public constant returns (uint256) {
    if (presaleStartTime > now) { return presaleDiscount; }
    if (presaleActive()) { return presaleDiscount; }
    uint256 discountSub = saleStage().mul(5);
    uint256 discount = saleDiscount.sub(discountSub);
    return discount;
  }

  function currentRate() public constant returns (uint256) {
    uint256 x = (BASE.mul(100).sub(currentDiscountPercentage().mul(BASE))).div(100);
    return originalRate.mul(BASE).div(x);
  }

  // Presale

  function presaleLimitUnits() public constant returns (uint256) {
    return totalSupplyUnits.div(100).mul(presalePercentage);
  }

  function shouldEndPresale() private constant returns (bool) {
    if ((crowdsaleDistributedUnits.sub(issuerDistributedUnits) >= presaleLimitUnits()) || (now >= presaleEndTime)) {
      return true;
    } else {
      return false;
    }
  }

  function presaleActive() public constant returns (bool) {
    bool inRange = now >= presaleStartTime && now < presaleEndTime;
    return inRange && shouldEndPresale() == false;
  }

  // Sale

  function unitsLimitForCurrentSaleStage() public constant returns (uint256) {
    return totalSupplyUnits.div(100).mul(currentMaximumSalePercentage());
  }

  function maximumSaleLimitUnits() public constant returns (uint256) {
    return totalSupplyUnits.div(100).mul(50);
  }

  function currentMaximumSalePercentage() public constant returns (uint256) {
    return saleStage().mul(8).add(10);
  }

  function saleLimitReachedForCurrentStage() public constant returns (bool) {
    return (crowdsaleDistributedUnits.sub(issuerDistributedUnits) >= unitsLimitForCurrentSaleStage());
  }

  function currentSaleStage() constant public returns (uint256) {
    return saleStage().add(1);
  }

  function saleStage() private returns (uint256) {
    uint256 delta = saleEndTime.sub(saleStartTime);
    uint256 stageStep = delta.div(6);
    int256 stageDelta = int256(now - saleStartTime);
    if ((stageDelta <= 0) || (stageStep == 0)) {
      return 0;
    } else {
      uint256 reminder = uint256(stageDelta) % stageStep;
      uint256 dividableDelta = uint256(stageDelta).sub(reminder);
      uint256 stage = dividableDelta.div(stageStep);
      if (stage <= 5) {
        return stage;
      } else {
        return 5;
      }
    }
  }

  function saleActive() public constant returns (bool) {
    bool inRange = now >= saleStartTime && now < saleEndTime;        
    return inRange && saleLimitReachedForCurrentStage() == false;
  }

  // Issuer Reserve

  function unitsForIssuerReserve(uint256 _tokensForDistribution) private returns (uint256) {
    uint256 residue = maximumIssuerReservedUnits().sub(issuerDistributedUnits);
    uint256 toIssuer = _tokensForDistribution.div(100).mul(10);
    if (residue > toIssuer) {
      return toIssuer;
    } else {
      return residue;
    }
  }

  function maximumIssuerReservedUnits() public constant returns (uint256) {
    return totalSupplyUnits.div(100).mul(issuerReservedMaximumPercentage);
  }

  // Reward distribution

  modifier afterSale() {
    require(rewardDistributionStarted());
    _;
  }

  function rewardDistributionStarted() public constant returns (bool) {
    return now >= rewardDistributionStart;
  }

  function requestReward() afterSale external {
    if ((msg.sender == contractCreator) && (rewardDistributionEnded())) {
      sendNotDistributedUnits();
    } else {
      rewardDistribution(msg.sender);
    }    
  }

  function rewardDistribution(address _address) private {
    require(contributors[_address].contributedWei > 0);    
    uint256 reward = payableReward(_address);
    require(reward > 0);
    sendReward(_address, reward);
  }

  function sendNotDistributedUnits() private {
    require(msg.sender == contractCreator);
    uint256 balance = token.balanceOf(this);
    RewardDistributed(contractCreator, balance);
    sendReward(contractCreator, balance);
  }

  function payableReward(address _address) afterSale constant public returns (uint256) {
    uint256 unitsLeft = totalUnitsLeft();
    if (unitsLeft < 10**4) {
      return unitsLeft;
    }
    uint256 totalReward = contributorTotalReward(_address);
    uint256 paidBonus = contributors[_address].rewardDistributedDecoUnits;
    uint256 totalRewardLeft = totalReward.sub(paidBonus);
    uint256 bonusPerDay = totalReward.div(rewardDays());
    if ((totalRewardLeft > 0) && ((bonusPerDay == 0) || (rewardDaysLeft() == 0))) {
      return totalRewardLeft;
    }
    uint256 totalPayable = rewardPayableDays().mul(bonusPerDay);
    uint256 reward = totalPayable.sub(paidBonus);
    return reward;
  }

  function sendReward(address _address, uint256 _value) private {
    contributors[_address].rewardDistributedDecoUnits = contributors[_address].rewardDistributedDecoUnits.add(_value);
    rewardDistributedUnits = rewardDistributedUnits.add(_value); 
    RewardDistributed(_address, _value);
    token.transfer(_address, _value);
  }

  function rewardPayableDays() constant public returns (uint256) {
    uint256 payableDays = rewardDays().sub(rewardDaysLeft());
    if (payableDays == 0) {
      payableDays = 1;
    }
    if (payableDays > rewardDays()) {
      payableDays = rewardDays();
    }
    return payableDays;
  }

  function rewardDays() constant public returns (uint256) {
    uint256 rate = rewardUnitsRatePerYear();
    if (rate == 0) {
      return 80 * 365; // Initial assumption
    }
    uint256 daysToComplete = (totalSupplyUnits.sub(crowdsaleDistributedUnits)).mul(365).div(rate);
    return daysToComplete;
  }

  function rewardUnitsRatePerYear() constant public returns (uint256) {
    return crowdsaleDistributedUnits.div(100);
  }

  function currentRewardReleasePercentageRatePerYear() afterSale constant external returns (uint256) {
    return rewardUnitsRatePerYear().mul(10**18).div(circulatingSupply()).mul(100); // Divide by 10**18 to get the actual decimal % value
  }

  function rewardDistributionEnd() constant public returns (uint256) {
    uint256 secondsToComplete = rewardDays().mul(1 days);
    return rewardDistributionStart.add(secondsToComplete);
  }

  function changeRemainingDecoRewardOwner(address _newOwner, string _confirmation) afterSale external {
    require(_newOwner != 0x0);
    require(sha3(_confirmation) == sha3("CONFIRM"));
    require(_newOwner != address(this));
    require(_newOwner != address(token));    
    require(contributors[_newOwner].decoUnits == 0);
    require(contributors[msg.sender].decoUnits > 0);
    require(token.balanceOf(_newOwner) > 0); // The new owner must have some number of DECO tokens. It proofs that _newOwner address is real.
    contributors[_newOwner] = contributors[msg.sender];
    delete(contributors[msg.sender]);
    RemainingRewardOwnershipChanged(msg.sender, _newOwner);
  }  

  function totalUnitsLeft() constant public returns (uint256) {
    int256 units = int256(totalSupplyUnits) - int256((rewardDistributedUnits.add(crowdsaleDistributedUnits))); 
    if (units < 0) {
      return token.balanceOf(this);
    }
    return uint256(units);
  }

  function rewardDaysLeft() constant public returns (uint256) {
    if (now < rewardDistributionStart) {
      return rewardDays();
    }
    int256 left = (int256(rewardDistributionEnd()) - int256(now)) / 1 days;
    if (left < 0) {
      left = 0;
    }
    return uint256(left);
  }

  function contributorTotalReward(address _address) constant public returns (uint256) {
    uint256 proportion = contributors[_address].decoUnits.mul(10**32).div(crowdsaleDistributedUnits.sub(issuerDistributedUnits));
    uint256 leftForBonuses = totalSupplyUnits.sub(crowdsaleDistributedUnits);
    uint256 reward = leftForBonuses.mul(proportion).div(10**32);
    uint256 totalLeft = totalSupplyUnits - (rewardDistributedUnits.add(reward).add(crowdsaleDistributedUnits));
    if (totalLeft < 10**4) {
      reward = reward.add(totalLeft);
    }    
    return reward;
  }

  function contributorDistributedReward(address _address) constant public returns (uint256) {
    return contributors[_address].rewardDistributedDecoUnits;
  }  

  function rewardDistributionEnded() public constant returns (bool) {
    return now > rewardDistributionEnd();
  }

}
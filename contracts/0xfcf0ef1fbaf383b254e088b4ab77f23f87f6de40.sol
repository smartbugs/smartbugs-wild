pragma solidity ^0.4.22;

//standard library for uint
library SafeMath { 
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0){
        return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

  function pow(uint256 a, uint256 b) internal pure returns (uint256){ //power function
    if (b == 0){
      return 1;
    }
    uint256 c = a**b;
    assert (c >= a);
    return c;
  }
}

//standard contract to identify owner
contract Ownable {

  address public owner;

  address public newOwner;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      owner = newOwner;
    }
  }
}
//Abstract Token contract
contract SHAREToken{
  function setCrowdsaleContract (address) public;
  function sendCrowdsaleTokens(address, uint256)  public;
}

//Crowdsale contract
contract ShareCrowdsale is Ownable{

  using SafeMath for uint;

  uint decimals = 6;

  // Token contract address
  SHAREToken public token;

  address public distributionAddress;

  constructor (address _tokenAddress) public {
    token = SHAREToken(_tokenAddress);
    owner = 0x4fD26ff0Af100C017BEA88Bd6007FcB68C237960;

    distributionAddress = 0xdF4F78fb8B8201ea3c42A1D91A05c97071B59BF2;

    setupStages();

    token.setCrowdsaleContract(this);    
  }

  uint public constant ICO_START = 1526860800; //21st May 2018
  uint public constant ICO_FINISH = 1576713600; //19th December 2019

  uint public constant ICO_MIN_CAP = 1 ether;

  uint public tokensSold;
  uint public ethCollected;

  uint public constant MIN_DEPOSIT = 0.01 ether;

  struct Stage {
    uint tokensPrice;
    uint tokensDistribution;
    uint discount;
    bool isActive;
  }
  
  Stage[] public icoStages;

  function setupStages () internal {
    icoStages.push(Stage(1650,2500000 * ((uint)(10) ** (uint)(decimals)), 10000, true));
    icoStages.push(Stage(1650,5000000 * ((uint)(10) ** (uint)(decimals)), 5000, true));
    icoStages.push(Stage(1650,8000000 * ((uint)(10) ** (uint)(decimals)), 3500, true));
    icoStages.push(Stage(1650,10000000 * ((uint)(10) ** (uint)(decimals)), 2500, true));
    icoStages.push(Stage(1650,15000000 * ((uint)(10) ** (uint)(decimals)), 1800, true));
    icoStages.push(Stage(1650,15000000 * ((uint)(10) ** (uint)(decimals)), 1200, true));
    icoStages.push(Stage(1650,15000000 * ((uint)(10) ** (uint)(decimals)), 600, true));
    icoStages.push(Stage(1650,49500000 * ((uint)(10) ** (uint)(decimals)), 0, true)); 
  }

  function stopIcoPhase (uint _phase) external onlyOwner {
    icoStages[_phase].isActive = false;
  }

  function startIcoPhase (uint _phase) external onlyOwner {
    icoStages[_phase].isActive = true;
  }
  
  function changeIcoStageTokenPrice (uint _phase, uint _tokenPrice) external onlyOwner {
    icoStages[_phase].tokensPrice = _tokenPrice;
  }
  
  function () public payable {
    require (isIco());
    require (msg.value >= MIN_DEPOSIT);
    require (buy(msg.sender, msg.value));
  }

  function buy (address _address, uint _value) internal returns(bool) {
    uint currentStage = getCurrentStage();
    if (currentStage == 100){
      return false;
    }

    uint _phasePrice = icoStages[currentStage].tokensPrice;
    uint _tokenPrice = _phasePrice.add(_phasePrice.mul(icoStages[currentStage].discount)/10000);
    uint tokensToSend = _value.mul(_tokenPrice)/(uint(10).pow(uint(12))); //decimals difference

    if(ethCollected >= ICO_MIN_CAP){
      distributionAddress.transfer(address(this).balance);
    }

    token.sendCrowdsaleTokens(_address,tokensToSend);
    
    tokensSold = tokensSold.add(tokensToSend);
    ethCollected += _value;
    
    return true;
  }

  function getCurrentStage () public view returns(uint) {
    uint buffer;

    if(isIco()){
      for (uint i = 0; i < icoStages.length; i++){
        buffer += icoStages[i].tokensDistribution;
        if(tokensSold <= buffer && icoStages[i].isActive){
          return i;
        }
      }
    }
    return 100; //something went wrong
  }

  function isIco() public view returns(bool) {
    if(ICO_START <= now && now <= ICO_FINISH){
      return true;
    }
    return false;
  }

  function sendCrowdsaleTokensManually (address _address, uint _value) external onlyOwner {
    token.sendCrowdsaleTokens(_address,_value);
    tokensSold = tokensSold.add(_value);
  }

  //if something went wrong
  function sendEtherManually () public onlyOwner {
    distributionAddress.transfer(address(this).balance);
  }
}
pragma solidity ^0.4.15;

// Math helper functions
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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


/// @title DNNToken contract - Main DNN contract
/// @author Dondrey Taylor - <dondrey@dnn.media>
contract DNNToken {
    enum DNNSupplyAllocations {
        EarlyBackerSupplyAllocation,
        PRETDESupplyAllocation,
        TDESupplyAllocation,
        BountySupplyAllocation,
        WriterAccountSupplyAllocation,
        AdvisorySupplyAllocation,
        PlatformSupplyAllocation
    }
    function balanceOf(address who) constant public returns (uint256);
    function issueTokens(address, uint256, DNNSupplyAllocations) public pure returns (bool) {}
}

/// @author Dondrey Taylor - <dondrey@dnn.media>
contract DNNAdvisoryLockBox {

  using SafeMath for uint256;

  // DNN Token Contract
  DNNToken public dnnToken;

  // Addresses of the co-founders of DNN
  address public cofounderA;
  address public cofounderB;

  // Amount of tokens that each advisor is entitled to
  mapping(address => uint256) advisorsWithEntitledSupply;

  // Amount of tokens that each advisor is entitled to
	mapping(address => uint256) advisorsTokensIssued;

  // The last time that tokens were issued to each advisor
	mapping(address => uint256) advisorsTokensIssuedOn;

  // Events
	event AdvisorTokensSent(address to, uint256 issued, uint256 remaining);
	event AdvisorAdded(address advisor);
	event AdvisorAddressChanged(address oldaddress, address newaddress);
  event NotWhitelisted(address to);
  event NoTokensRemaining(address advisor);
  event NextRedemption(uint256 nextTime);

  // Checks to see if sender is a cofounder
  modifier onlyCofounders() {
      require (msg.sender == cofounderA || msg.sender == cofounderB);
      _;
  }

  // Replace advisor address
  function replaceAdvisorAddress(address oldaddress, address newaddress) public onlyCofounders {
      // Check to see if the advisor's old address exists
      if (advisorsWithEntitledSupply[oldaddress] > 0) {
          advisorsWithEntitledSupply[newaddress] = advisorsWithEntitledSupply[oldaddress];
          advisorsWithEntitledSupply[oldaddress] = 0;
          emit AdvisorAddressChanged(oldaddress, newaddress);
      }
      else {
          emit NotWhitelisted(oldaddress);
      }
  }

  // Provides the remaining amount tokens to be issued to the advisor
  function nextRedemptionTime(address advisorAddress) public view returns (uint256) {
      return advisorsTokensIssuedOn[advisorAddress] == 0 ? now : (advisorsTokensIssuedOn[advisorAddress] + 30 days);
  }

  // Provides the remaining amount tokens to be issued to the advisor
  function checkRemainingTokens(address advisorAddress) public view returns (uint256) {
      return advisorsWithEntitledSupply[advisorAddress] - advisorsTokensIssued[advisorAddress];
  }

  // Checks if the specified address is whitelisted
  function isWhitelisted(address advisorAddress) public view returns (bool) {
     return advisorsWithEntitledSupply[advisorAddress] != 0;
  }

  // Add advisor address
  function addAdvisor(address advisorAddress, uint256 entitledTokenAmount) public onlyCofounders {
      advisorsWithEntitledSupply[advisorAddress] = entitledTokenAmount;
      emit AdvisorAdded(advisorAddress);
  }

  // Amount of tokens that the advisor is entitled to
  function advisorEntitlement(address advisorAddress) public view returns (uint256) {
      return advisorsWithEntitledSupply[advisorAddress];
  }

  constructor() public
  {
      // Set token address
      dnnToken = DNNToken(0x9D9832d1beb29CC949d75D61415FD00279f84Dc2);

      // Set cofounder addresses
      cofounderA = 0x3Cf26a9FE33C219dB87c2e50572e50803eFb2981;
      cofounderB = 0x9FFE2aD5D76954C7C25be0cEE30795279c4Cab9f;
  }

	// Handles incoming transactions
	function () public payable {

      // Check to see if the advisor is within
      // our whitelist
      if (advisorsWithEntitledSupply[msg.sender] > 0) {

          // Check to see if the advisor has any tokens left
          if (advisorsTokensIssued[msg.sender] < advisorsWithEntitledSupply[msg.sender]) {

              // Check to see if we can issue tokens to them. Advisors can redeem every 30 days for 10 months
              if (advisorsTokensIssuedOn[msg.sender] == 0 || ((now - advisorsTokensIssuedOn[msg.sender]) >= 30 days)) {

                  // Issue tokens to advisors
                  uint256 tokensToIssue = advisorsWithEntitledSupply[msg.sender].div(10);

                  // Update amount of tokens issued to this advisor
                  advisorsTokensIssued[msg.sender] = advisorsTokensIssued[msg.sender].add(tokensToIssue);

                  // Update the time that we last issued tokens to this advisor
                  advisorsTokensIssuedOn[msg.sender] = now;

                  // Allocation type will be advisory
                  DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.AdvisorySupplyAllocation;

                  // Attempt to issue tokens
                  if (!dnnToken.issueTokens(msg.sender, tokensToIssue, allocationType)) {
                      revert();
                  }
                  else {
                     emit AdvisorTokensSent(msg.sender, tokensToIssue, checkRemainingTokens(msg.sender));
                  }
              }
              else {
                   emit NextRedemption(advisorsTokensIssuedOn[msg.sender] + 30 days);
              }
          }
          else {
            emit NoTokensRemaining(msg.sender);
          }
      }
      else {
        emit NotWhitelisted(msg.sender);
      }
	}

}
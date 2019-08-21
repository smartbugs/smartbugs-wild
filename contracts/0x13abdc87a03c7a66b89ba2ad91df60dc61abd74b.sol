/*
This file is part of WeiFund.
*/

/*
The core campaign contract interface. Used across all WeiFund standard campaign
contracts.
*/

pragma solidity ^0.4.4;


/// @title Campaign contract interface for WeiFund standard campaigns
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Campaign {
  /// @notice the creater and operator of the campaign
  /// @return the Ethereum standard account address of the owner specified
  function owner() public constant returns(address) {}

  /// @notice the campaign interface version
  /// @return the version metadata
  function version() public constant returns(string) {}

  /// @notice the campaign name
  /// @return contractual metadata which specifies the campaign name as a string
  function name() public constant returns(string) {}

  /// @notice use to determine the contribution method abi/structure
  /// @return will return a string that is the exact contributeMethodABI
  function contributeMethodABI() public constant returns(string) {}

  /// @notice use to determine the contribution method abi
  /// @return will return a string that is the exact contributeMethodABI
  function refundMethodABI() public constant returns(string) {}

  /// @notice use to determine the contribution method abi
  /// @return will return a string that is the exact contributeMethodABI
  function payoutMethodABI() public constant returns(string) {}

  /// @notice use to determine the beneficiary destination for the campaign
  /// @return the beneficiary address that will receive the campaign payout
  function beneficiary() public constant returns(address) {}

  /// @notice the block number at which the campaign fails or succeeds
  /// @return the uint block number at which time the campaign expires
  function expiry() public constant returns(uint256 blockNumber) {}

  /// @notice the goal the campaign must reach in order for it to succeed
  /// @return the campaign funding goal specified in wei as a uint256
  function fundingGoal() public constant returns(uint256 amount) {}

  /// @notice the maximum funding amount for this campaign
  /// @return the campaign funding cap specified in wei as a uint256
  function fundingCap() public constant returns(uint256 amount) {}

  /// @notice the goal the campaign must reach in order for it to succeed
  /// @return the campaign funding goal specified in wei as a uint256
  function amountRaised() public constant returns(uint256 amount) {}

  /// @notice the block number that the campaign was created
  /// @return the campaign start block specified as a block number, uint256
  function created() public constant returns(uint256 timestamp) {}

  /// @notice the current stage the campaign is in
  /// @return the campaign stage the campaign is in with uint256
  function stage() public constant returns(uint256);

  /// @notice if it supports it, return the contribution by ID
  /// @return returns the contribution tx sender, value and time sent
  function contributions(uint256 _contributionID) public constant returns(address _sender, uint256 _value, uint256 _time) {}

  // Campaign events
  event ContributionMade (address _contributor);
  event RefundPayoutClaimed(address _payoutDestination, uint256 _payoutAmount);
  event BeneficiaryPayoutClaimed (address _payoutDestination);
}

/*
This file is part of WeiFund.
*/

/*
The enhancer interface for the CampaignEnhancer contract.
*/

pragma solidity ^0.4.4;


/// @title The campaign enhancer interface contract for build enhancer contracts.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Enhancer {
  /// @notice enables the setting of the campaign, if any
  /// @dev allow the owner to set the campaign
  function setCampaign(address _campaign) public {}

  /// @notice notate contribution
  /// @param _sender The address of the contribution sender
  /// @param _value The value of the contribution
  /// @param _blockNumber The block number of the contribution
  /// @param _amounts The specified contribution product amounts, if any
  /// @return Whether or not the campaign is an early success after this contribution
  /// @dev enables the notation of contribution data, and triggering of early success, if need be
  function notate(address _sender, uint256 _value, uint256 _blockNumber, uint256[] _amounts) public returns (bool earlySuccess) {}
}

/*
This file is part of WeiFund.
*/

/*
A common Owned contract that contains properties for contract ownership.
*/

pragma solidity ^0.4.4;


/// @title A single owned campaign contract for instantiating ownership properties.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Owned {
  // only the owner can use this method
  modifier onlyowner() {
    if (msg.sender != owner) {
      throw;
    }

    _;
  }

  // the owner property
  address public owner;
}
/*
This file is part of WeiFund.
*/

/*
This is the standard claim contract interface. This used accross all claim
contracts. Claim contracts are used for the pickup of digital assets, such as tokens.
Note, a campaign enhancer could be a claim as well. This is our general
claim interface.
*/

pragma solidity ^0.4.4;


/// @title Claim contract interface.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Claim {
  /// @return returns the claim ABI solidity method for this claim
  function claimMethodABI() constant public returns (string) {}

  // the claim success event, used for whent he claim has successfully be used
  event ClaimSuccess(address _sender);
}
/*
This file is part of WeiFund.
*/

/*
The balance claim is used for dispersing balances of refunds for standard
camaign contracts. Instead of the contract sending a balance directly to the
contributor, it will send the balance to a balancelciam contract.
*/

pragma solidity ^0.4.4;


/// @title The balance claim interface contract, used for defining balance claims.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract BalanceClaimInterface {
  /// @dev used to claim balance of the balance claim
  function claimBalance() public {}
}


/// @title The balance claim, used for sending balances owed to a claim contract.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract BalanceClaim is Owned, Claim, BalanceClaimInterface {
  /// @notice receive funds
  function () payable public {}

  /// @dev the claim balance method, claim the balance then suicide the contract
  function claimBalance() onlyowner public {
    // self destruct and send all funds to the balance claim owner
    selfdestruct(owner);
  }

  /// @notice The BalanceClaim constructor method
  /// @param _owner the address of the balance claim owner
  function BalanceClaim(address _owner) {
    // specify the balance claim owner
    owner = _owner;
  }

  // the claim method ABI metadata for user interfaces, written in standard
  // solidity ABI method format
  string constant public claimMethodABI = "claimBalance()";
}

/*
This file is part of WeiFund.
*/

/*
The private service registry is used in WeiFund factory contracts to register
generated service contracts, such as our WeiFund standard campaign and enhanced
standard campaign contracts. It is usually only inherited by other contracts.
*/

pragma solidity ^0.4.4;


/// @title Private Service Registry - used to register generated service contracts.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract PrivateServiceRegistryInterface {
  /// @notice register the service '_service' with the private service registry
  /// @param _service the service contract to be registered
  /// @return the service ID 'serviceId'
  function register(address _service) internal returns (uint256 serviceId) {}

  /// @notice is the service in question '_service' a registered service with this registry
  /// @param _service the service contract address
  /// @return either yes (true) the service is registered or no (false) the service is not
  function isService(address _service) public constant returns (bool) {}

  /// @notice helps to get service address
  /// @param _serviceId the service ID
  /// @return returns the service address of service ID
  function services(uint256 _serviceId) public constant returns (address _service) {}

  /// @notice returns the id of a service address, if any
  /// @param _service the service contract address
  /// @return the service id of a service
  function ids(address _service) public constant returns (uint256 serviceId) {}

  event ServiceRegistered(address _sender, address _service);
}

contract PrivateServiceRegistry is PrivateServiceRegistryInterface {

  modifier isRegisteredService(address _service) {
    // does the service exist in the registry, is the service address not empty
    if (services.length > 0) {
      if (services[ids[_service]] == _service && _service != address(0)) {
        _;
      }
    }
  }

  modifier isNotRegisteredService(address _service) {
    // if the service '_service' is not a registered service
    if (!isService(_service)) {
      _;
    }
  }

  function register(address _service)
    internal
    isNotRegisteredService(_service)
    returns (uint serviceId) {
    // create service ID by increasing services length
    serviceId = services.length++;

    // set the new service ID to the '_service' address
    services[serviceId] = _service;

    // set the ids store to link to the 'serviceId' created
    ids[_service] = serviceId;

    // fire the 'ServiceRegistered' event
    ServiceRegistered(msg.sender, _service);
  }

  function isService(address _service)
    public
    constant
    isRegisteredService(_service)
    returns (bool) {
    return true;
  }

  address[] public services;
  mapping(address => uint256) public ids;
}


/*
This file is part of WeiFund.
*/

/*
This file is part of WeiFund.
*/

/*
Standard enhanced campaign for WeiFund. A generic crowdsale mechanism for
issuing and dispersing digital assets on Ethereum.
*/

pragma solidity ^0.4.4;

/*
Interfaces
*/

/*
Specified Contracts
*/


/// @title Standard Campaign -- enables generic crowdsales that disperse digital assets
/// @author Nick Dodson <nick.dodson@consensys.net>
contract StandardCampaign is Owned, Campaign {
  // the three possible states
  enum Stages {
    CrowdfundOperational,
    CrowdfundFailure,
    CrowdfundSuccess
  }

  // the campaign state machine enforcement
  modifier atStage(Stages _expectedStage) {
    // if the current state does not equal the expected one, throw
    if (stage() != uint256(_expectedStage)) {
      throw;
    } else {
      // continue with state changing operations
      _;
    }
  }

  // if the contribution is valid, then carry on with state changing operations
  // notate the contribution with the enhancer, if the notation method
  // returns true, then trigger an early success (e.g. token cap reached)
  modifier validContribution() {
    // if the msg value is zero or amount raised plus the curent message value
    // is greater than the funding cap, then throw error
    if (msg.value == 0
      || amountRaised + msg.value > fundingCap
      || amountRaised + msg.value < amountRaised) {
      throw;
    } else {
      // carry on with state changing operations
      _;
    }
  }

  // if the contribution is a valid refund claim, then carry on with state
  // changing operations
  modifier validRefundClaim(uint256 _contributionID) {
    // get the contribution data for the refund
    Contribution refundContribution = contributions[_contributionID];

    // if the refund has already been claimed or the refund sender is not the
    // current message sender, throw error
    if(refundsClaimed[_contributionID] == true // the refund for this contribution is not claimed
      || refundContribution.sender != msg.sender){ // the contribution sender is the msg.sender
      throw;
    } else {
      // all is good, carry on with state changing operations
      _;
    }
  }

  // only the beneficiary can use the method with this modifier
  modifier onlybeneficiary() {
    if (msg.sender != beneficiary) {
      throw;
    } else {
      _;
    }
  }

  // allow for fallback function to be used to make contributions
  function () public payable {
    contributeMsgValue(defaultAmounts);
  }

  // the current campaign stage
  function stage() public constant returns (uint256) {
    // if current time is less than the expiry, the crowdfund is operational
    if (block.number < expiry
      && earlySuccess == false
      && amountRaised < fundingCap) {
      return uint256(Stages.CrowdfundOperational);

    // if n >= e and aR < fG then the crowdfund is a failure
    } else if(block.number >= expiry
      && earlySuccess == false
      && amountRaised < fundingGoal) {
      return uint256(Stages.CrowdfundFailure);

    // if n >= e and aR >= fG or aR >= fC or early success triggered
    // then the crowdfund is a success (enhancers can trigger early success)
    // early success is generally used for TokenCap enforcement
    } else if((block.number >= expiry && amountRaised >= fundingGoal)
      || earlySuccess == true
      || amountRaised >= fundingCap) {
      return uint256(Stages.CrowdfundSuccess);
    }
  }

  // contribute message value if the contribution is valid and the campaign
  // is in stage operational, allow for complex amounts to be transacted
  function contributeMsgValue(uint256[] _amounts)
    public // anyone can attempt to use this method
    payable // the method is payable and can accept ether
    atStage(Stages.CrowdfundOperational) // must be at stage operational, done before validContribution
    validContribution() // contribution must be valid, stage check done first
    returns (uint256 contributionID) {
    // increase contributions array length by 1, set as contribution ID
    contributionID = contributions.length++;

    // store contribution data in the contributions array
    contributions[contributionID] = Contribution({
        sender: msg.sender,
        value: msg.value,
        created: block.number
    });

    // add the contribution ID to that senders address
    contributionsBySender[msg.sender].push(contributionID);

    // increase the amount raised by the message value
    amountRaised += msg.value;

    // fire the contribution made event
    ContributionMade(msg.sender);

    // notate the contribution with the campaign enhancer, if the notation
    // method returns true, then trigger an early success
    // the enahncer is treated as malicious here, and is thus wrapped in a
    // conditional for saftey, note the enhancer may throw as well
    if (enhancer.notate(msg.sender, msg.value, block.number, _amounts)) {
      // set early success to true, note, it cannot be reversed once set to true
      // also validContribution must be after atStage modifier
      // so that early success is triggered after stage check, not before
      // early success is used to trigger an early campaign success before the funding
      // cap is reached. This is generally used for things like hitting the token cap
      earlySuccess = true;
    }
  }

  // payout the current balance to the beneficiary, if the crowdfund is in
  // stage success
  function payoutToBeneficiary() public onlybeneficiary() {
    // additionally trigger early success, this will force the Success state
    // forcing the success state keeps the contract state machine rigid
    // and ensures other third-party contracts that look to this state
    // that this contract is in state success
    earlySuccess = true;

    // send funds to the benerifiary
    if (!beneficiary.send(this.balance)) {
      throw;
    } else {
      // fire the BeneficiaryPayoutClaimed event
      BeneficiaryPayoutClaimed(beneficiary);
    }
  }

  // claim refund owed if you are a contributor and the campaign is in stage
  // failure. Only valid claims will be fulfilled.
  // will return the balance claim address where funds can be picked up by
  // contributor. A BalanceClaim is used to further prevent re-entrancy.
  function claimRefundOwed(uint256 _contributionID)
    public
    atStage(Stages.CrowdfundFailure) // in stage failure
    validRefundClaim(_contributionID) // the claim is a valid refund claim
    returns (address balanceClaim) { // return the balance claim address
    // set claimed to true right away
    refundsClaimed[_contributionID] = true;

    // get the contribution data for that contribution ID
    Contribution refundContribution = contributions[_contributionID];

    // send funds to the newly created balance claim contract
    balanceClaim = address(new BalanceClaim(refundContribution.sender));

    // set refunds claim address
    refundClaimAddress[_contributionID] = balanceClaim;

    // send funds to the newly created balance claim contract
    if (!balanceClaim.send(refundContribution.value)) {
      throw;
    }

    // fire the refund payed out event
    RefundPayoutClaimed(balanceClaim, refundContribution.value);
  }

  // the total number of valid contributions made to this campaign
  function totalContributions() public constant returns (uint256 amount) {
    return uint256(contributions.length);
  }

  // get the total number of contributions made a sender
  function totalContributionsBySender(address _sender)
    public
    constant
    returns (uint256 amount) {
    return uint256(contributionsBySender[_sender].length);
  }

  // the contract constructor
  function StandardCampaign(string _name,
    uint256 _expiry,
    uint256 _fundingGoal,
    uint256 _fundingCap,
    address _beneficiary,
    address _owner,
    address _enhancer) public {
    // set the campaign name
    name = _name;

    // the campaign expiry in blocks
    expiry = _expiry;

    // the fundign goal in wei
    fundingGoal = _fundingGoal;

    // the campaign funding cap in wei
    fundingCap = _fundingCap;

    // the benerifiary address
    beneficiary = _beneficiary;

    // the owner or operator of the campaign
    owner = _owner;

    // the time the campaign was created
    created = block.number;

    // the campaign enhancer contract
    enhancer = Enhancer(_enhancer);
  }

  // the Contribution data structure
  struct Contribution {
    // the contribution sender
    address sender;

    // the value of the contribution
    uint256 value;

    // the time the contribution was created
    uint256 created;
  }

  // default amounts used
  uint256[] defaultAmounts;

  // campaign enhancer, usually for token notation
  Enhancer public enhancer;

  // the early success bool, used for triggering early success
  bool public earlySuccess;

  // the operator of the campaign
  address public owner;

  // the minimum amount of funds needed to be a success after expiry (in wei)
  uint256 public fundingGoal;

  // the maximum amount of funds that can be raised (in wei)
  uint256 public fundingCap;

  // the total amount raised by this campaign (in wei)
  uint256 public amountRaised;

  // the current campaign expiry (future block number)
  uint256 public expiry;

  // the time at which the campaign was created (in UNIX timestamp)
  uint256 public created;

  // the beneficiary of the funds raised, if the campaign is a success
  address public beneficiary;

  // the contributions data store, where all contributions are notated
  Contribution[] public contributions;

  // all contribution ID's of a specific sender
  mapping(address => uint256[]) public contributionsBySender;

  // the refund BalanceClaim address of a specific refund claim
  // maps the (contribution ID => refund claim address)
  mapping(uint256 => address) public refundClaimAddress;

  // maps the contribution ID to a bool (has the refund been claimed for this
  // contribution)
  mapping(uint256 => bool) public refundsClaimed;

  // the human readable name of the Campaign, for metadata
  string public name;

  // the contract version number, if any
  string constant public version = "0.1.0";

  // the contribution method ABI as a string, written in standard solidity
  // ABI format, this is generally used so that UI's can understand the campaign
  string constant public contributeMethodABI = "contributeMsgValue(uint256[]):(uint256)";

  // the payout to beneficiary ABI, written in standard solidity ABI format
  string constant public payoutMethodABI = "payoutToBeneficiary()";

  // the refund method ABI, written in standard solidity ABI format
  string constant public refundMethodABI = "claimRefundOwed(uint256):(address)";
}

/*
This file is part of WeiFund.
*/

/*
An empty campaign enhancer, used to fulfill an enhancer of a WeiFund enhanced
standard campaign.
*/

pragma solidity ^0.4.4;


/// @title Empty Enhancer - used to test enhanced standard campaign contracts
/// @author Nick Dodson <nick.dodson@consensys.net>
contract EmptyEnhancer is Enhancer {
  /// @dev notate contribution data, and trigger early success if need be
  function notate(address _sender, uint256 _value, uint256 _blockNumber, uint256[] _amounts)
  public
  returns (bool earlySuccess) {
    return false;
  }
}


/*
A factory contract used for the generation and registration of WeiFund enhanced
standard campaign contracts.
*/

pragma solidity ^0.4.4;


/// @title Enhanced Standard Campaign Factory - used to generate and register standard campaigns
/// @author Nick Dodson <nick.dodson@consensys.net>
contract StandardCampaignFactory is PrivateServiceRegistry {
  function createStandardCampaign(string _name,
    uint256 _expiry,
    uint256 _fundingGoal,
    uint256 _fundingCap,
    address _beneficiary,
    address _enhancer) public returns (address campaignAddress) {
    // create the new enhanced standard campaign
    campaignAddress = address(new StandardCampaign(_name,
      _expiry,
      _fundingGoal,
      _fundingCap,
      _beneficiary,
      msg.sender,
      _enhancer));

    // register the campaign address
    register(campaignAddress);
  }
}
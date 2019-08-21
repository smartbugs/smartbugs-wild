pragma solidity ^0.4.18;

// File: contracts/Core/Manageable.sol

contract Manageable {
  address public manager;


  /**
   * @dev Create a new instance of the Manageable contract.
   * @param _manager address
   */
  function Manageable(address _manager) public {
    require(_manager != 0x0);
    manager = _manager;
  }

  /**
   * @dev Checks if the msg.sender is the manager.
   */
  modifier onlyManager() { 
    require (msg.sender == manager && manager != 0x0);
    _; 
  }
}

// File: contracts/Core/Activatable.sol

contract Activatable is Manageable {
  event ActivatedContract(uint256 activatedAt);
  event DeactivatedContract(uint256 deactivatedAt);

  bool public active;
  
  /**
   * @dev Check if the contract is active. 
   */
  modifier isActive() {
    require(active);
    _;
  }

  /**
   * @dev Check if the contract is not active. 
   */
  modifier isNotActive() {
    require(!active);
    _;
  }

  /**
   * @dev Activate the contract.
   */
  function activate() public onlyManager isNotActive {
    // Set the flag to true.
    active = true;

    // Trigger event.
    ActivatedContract(now);
  }

  /**
   * @dev Deactiate the contract.
   */
  function deactivate() public onlyManager isActive {
    // Set the flag to false.
    active = false;

    // Trigger event.
    DeactivatedContract(now);
  }
}

// File: contracts/Core/Versionable.sol

contract Versionable is Activatable {
  string public name;
  string public version;
  uint256 public identifier;
  uint256 public createdAt;

  /**
   * @dev Create a new intance of a Versionable contract. Sets the
   *      createdAt unix timestamp to current block timestamp.
   */
  function Versionable (string _name, string _version, uint256 _identifier) public {
    require (bytes(_name).length != 0x0 && bytes(_version).length != 0x0 && _identifier > 0);

    // Set variables.
    name = _name;
    version = _version;
    identifier = _identifier;
    createdAt = now;
  }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/Management/ContractManagementSystem.sol

contract ContractManagementSystem is Ownable {
  event UpgradedContract (uint256 contractIdentifier, address indexed oldContractAddress, address indexed newContractAddress);
  event RollbackedContract (uint256 contractIdentifier, address indexed fromContractAddress, address indexed toContractAddress);

  mapping (uint256 => mapping (address => bool)) public managedContracts;
  mapping (uint256 => address) public activeContracts;
  mapping (uint256 => bool) migrationLocks;

  /**
   * @dev Ensure no locks are in place for the given contract identifier.
   * @param contractIdentifier uint256
   */
  modifier onlyWithoutLock(uint256 contractIdentifier) {
    require(!migrationLocks[contractIdentifier]);
    _;
  }

  /**
   * @dev    Get the address of the active contract for the given identifier.
   * @param  contractIdentifier uint256
   * @return address
   */
  function getActiveContractAddress(uint256 contractIdentifier)
    public
    constant
    onlyWithoutLock(contractIdentifier)
    returns (address activeContract)
  {
    // Validate the function arguments.
    require(contractIdentifier != 0x0);
    
    // Get the active contract for the given identifier.
    activeContract = activeContracts[contractIdentifier];

    // Ensure the address is set and the contract is active.
    require(activeContract != 0x0 && Activatable(activeContract).active());
  }

  /**
   * @dev    Check if the contract for the given address is managed.
   * @param  contractIdentifier uint256
   * @param  contractAddress    address
   * @return bool
   */
  function existsManagedContract(uint256 contractIdentifier, address contractAddress)
    public
    constant
    returns (bool)
  {
    // Validate the function arguments.
    require(contractIdentifier != 0x0 && contractAddress != 0x0);

    return managedContracts[contractIdentifier][contractAddress];
  }

  /**
   * @dev    Upgrade the contract for the given contract identifier to a newer version.
   * @dev    investigate potential race condition
   * @param  contractIdentifier uint256
   * @param  newContractAddress address
   */
  function upgradeContract(uint256 contractIdentifier, address newContractAddress)
    public
    onlyOwner
    onlyWithoutLock(contractIdentifier)
  {
    // Validate the function arguments.
    require(contractIdentifier != 0x0 && newContractAddress != 0x0);
    
    // Lock the contractIdentifier.
    migrationLocks[contractIdentifier] = true;

    // New contract should not be active.
    require(!Activatable(newContractAddress).active());

    // New contract should match the given contractIdentifier.
    require(contractIdentifier == Versionable(newContractAddress).identifier());

    // Ensure the new contract is not already managed.
    require (!existsManagedContract(contractIdentifier, newContractAddress));

    // Get the old contract address.
    address oldContractAddress = activeContracts[contractIdentifier];

    // Ensure the old contract is not deactivated already.
    if (oldContractAddress != 0x0) {
      require(Activatable(oldContractAddress).active());
    }

    // Swap the states.
    swapContractsStates(contractIdentifier, newContractAddress, oldContractAddress);

    // Add it to the managed ones.
    managedContracts[contractIdentifier][newContractAddress] = true;

    // Unlock the contractIdentifier.
    migrationLocks[contractIdentifier] = false;
    
    // Trigger event.
    UpgradedContract(contractIdentifier, oldContractAddress, newContractAddress);
  }

  /**
   * @dev Rollback the contract for the given contract identifier to the provided version.
   * @dev investigate potential race condition
   * @param  contractIdentifier uint256
   * @param  toContractAddress  address
   */
  function rollbackContract(uint256 contractIdentifier, address toContractAddress)
    public
    onlyOwner
    onlyWithoutLock(contractIdentifier)
  {
    // Validate the function arguments.
    require(contractIdentifier != 0x0 && toContractAddress != 0x0);

    // Lock the contractIdentifier.
    migrationLocks[contractIdentifier] = true;

    // To contract should match the given contractIdentifier.
    require(contractIdentifier == Versionable(toContractAddress).identifier());

    // Rollback "to" contract should be managed and inactive.
    require (!Activatable(toContractAddress).active() && existsManagedContract(contractIdentifier, toContractAddress));

    // Get the rollback "from" contract for given identifier. Will fail if there is no active contract.
    address fromContractAddress = activeContracts[contractIdentifier];

    // Swap the states.
    swapContractsStates(contractIdentifier, toContractAddress, fromContractAddress);

    // Unlock the contractIdentifier.
    migrationLocks[contractIdentifier] = false;

    // Trigger event.
    RollbackedContract(contractIdentifier, fromContractAddress, toContractAddress);
  }
  
  /**
   * @dev Swap the given contracts states as defined:
   *        - newContractAddress will be activated
   *        - oldContractAddress will be deactived
   * @param  contractIdentifier uint256
   * @param  newContractAddress address
   * @param  oldContractAddress address
   */
  function swapContractsStates(uint256 contractIdentifier, address newContractAddress, address oldContractAddress) internal {
    // Deactivate the old contract.
    if (oldContractAddress != 0x0) {
      Activatable(oldContractAddress).deactivate();
    }

    // Activate the new contract.
    Activatable(newContractAddress).activate();

     // Set the new contract as the active one for the given identifier.
    activeContracts[contractIdentifier] = newContractAddress;
  }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/Token/SwissCryptoExchangeToken.sol

/**
 * @title SwissCryptoExchange Standard ERC20 compatible token
 *
 * @dev Implementation of the SwissCryptoExchange company shares.
 * @dev Based on code by OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/StandardToken.sol
 */
contract SwissCryptoExchangeToken is ERC20Basic, Versionable {
  event Mint(address indexed to, uint256 amount);

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  string public constant symbol = "SCX";
  uint8 public constant decimals = 0;

  uint256 internal constant COMPANY_CONTRACT_ID = 101;

  /**
   * Create a new instance of the SwissCryptoExchangeToken contract.
   * @param initialShareholderAddress address 
   * @param initialAmount             uint256 
   */
  function SwissCryptoExchangeToken (address initialShareholderAddress, uint256 initialAmount, address _manager)
    public
    Manageable (_manager)
    Versionable ("SwissCryptoExchangeToken", "1.0.0", 1)
  {
    require(initialAmount > 0);
    require(initialShareholderAddress != 0x0);

    balances[initialShareholderAddress] = initialAmount;
    totalSupply = initialAmount;
  }

  /**
   * @dev Esnure the msg.sender is the company contract.
   */
  modifier onlyCompany() {
    require (msg.sender == ContractManagementSystem(manager).getActiveContractAddress(COMPANY_CONTRACT_ID));
    _;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public isActive onlyCompany returns (bool) {
    require(_to != 0x0);
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another.
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public isActive onlyCompany returns (bool) {
    require(_to != 0x0);
    require(_value <= balances[_from]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Function to mint tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(uint256 _amount) isActive onlyCompany public returns (bool) {
    // The receiver of the minted tokens will be the company contract.
    address _companyAddress = ContractManagementSystem(manager).getActiveContractAddress(COMPANY_CONTRACT_ID);
    totalSupply = totalSupply.add(_amount);
    balances[_companyAddress] = balances[_companyAddress].add(_amount);
    Mint(_companyAddress, _amount);
    Transfer(0x0, _companyAddress, _amount);
    return true;
  }
}

// File: contracts/Company/BaseCompany.sol

contract BaseCompany is Versionable {
  using SafeMath for uint256;
  
  uint256 internal constant TOKEN_CONTRACT_ID = 1;

  /**
   * @dev Create a new instance of the company contract.
   * @param _name       string
   * @param _version    string
   * @param _identifier uint256
   * @param _manager    address
   */
  function BaseCompany(string _name, string _version, uint256 _identifier, address _manager) public Versionable (_name, _version, _identifier) Manageable(_manager) {}

  /**
   * @dev Get the amount of shares that a shareholder owns in percentage
   *      relative to the total number of shares.
   * @param  shareholder address
   * @return uint256
   */
  function getSharesPercentage(address shareholder) public constant returns (uint256) {
    uint256 totalSharesAmount = token().totalSupply();
    uint256 ownedShares = token().balanceOf(shareholder);
    return ownedShares.mul(100).div(totalSharesAmount);
  }

  /**
   * @dev Get the latest token contract address.
   * @return address
   */
  function tokenAddress() public constant returns (address) {
    return ContractManagementSystem(manager).getActiveContractAddress(TOKEN_CONTRACT_ID);
  }

  /**
   * @dev Get the latest reference to the token.
   * @return SwissCryptoExchangeToken
   */
  function token() public constant returns (SwissCryptoExchangeToken) {
    return SwissCryptoExchangeToken(tokenAddress());
  }

  /**
   * @dev Check if the provided address is a company shareholder.
   * @param _addr address
   * @return bool
   */
  function isShareholder(address _addr) public constant returns (bool) {
    return token().balanceOf(_addr) > 0 && _addr != address(this);
  }
    
  /**
   * @dev Check if the given address is a majority company shareholder.
   * @param _addr address
   * @return bool
   */
  function isMajorityShareholder(address _addr) public constant returns (bool) {
    return (getSharesPercentage(_addr) > 50);
  }
}

// File: contracts/Company/SwissCryptoExchangeCompany.sol

contract SwissCryptoExchangeCompany is BaseCompany {
  event ProcessedInvestment(address indexed investor, uint256 weiAmount, uint256 shares);
  event SaleCompleted(address indexed beneficiary, uint256 weiAmount, uint256 shares);
  event SaleEnded(uint256 endedAt);
  event SaleAborted(uint256 abortedAt);

  using SafeMath for uint256;

  Sale public currentSale;

  // Definition of a sale.
  struct Sale {
    address creator;
    address beneficiary;
    address investor;
    address shareholder;
    uint256 rate;
    uint256 weiRaised;
    uint256 sharesSold;
    uint256 sharesCap;
    bool ended;
    bool exists;
  }
  
  /**
   * @dev Create a new instance of the company contract.
   * @param _manager address
   */
  function SwissCryptoExchangeCompany(address _manager) public BaseCompany("SwissCryptoExchangeCompany", "1.0.1", 101, _manager) {}

  /**
   * @dev Ensure the msg.sender is an shareholder of the company.
   */
  modifier onlyShareholder() {
    require(isShareholder(msg.sender));
    _; 
  }
  
  /**
   * @dev Ensure the msg.sender is has over 50% of the company shares.
   */
  modifier onlyMajority() {
    require(isMajorityShareholder(msg.sender));
    _;
  }

  /**
   * @dev Ensure the msg.sender is thesale creator.
   */
  modifier onlySaleCreator() {
    require(msg.sender == currentSale.creator);
    _; 
  }
  
  /**
   * @dev Ensure there is no sale in progress.
   */
  modifier onlyWhenNotSelling() { 
    require(!currentSale.exists);
    _; 
  }
  
  /**
   * @dev Ensure there is a sale in progress.
   */
  modifier onlyWhenSelling() { 
    require(currentSale.exists);
    _; 
  }

  
  /**
   * @dev Handle an incoming ether transfer.
   */
  function ()
    public
    payable
    isActive
    onlyWhenSelling
  {
    // Validate the purchase.
    require(msg.sender == currentSale.investor && msg.value > 0);

    // Forward the call to the Sale contract.
    processPayment();
  }

  /**
   * @dev Initialize a new sale.
   * @param rate         uint256
   * @param sharesCap    uint256
   * @param beneficiary  address 
   * @param investor     address 
   */
  function initializeNewSale(
    uint256 rate,
    uint256 sharesCap,
    address beneficiary,
    address investor
  )
    public
    isActive
    onlyMajority
    onlyWhenNotSelling
  {
    // Validate the parameters.
    require(rate > 0);
    require(sharesCap > 0);
    require(beneficiary != 0x0);
    require(investor != 0x0);
    require(token().balanceOf(msg.sender) >= sharesCap);

    // Set sale properties.
    currentSale.creator = msg.sender;
    currentSale.rate = rate;
    currentSale.sharesCap = sharesCap;
    currentSale.beneficiary = beneficiary;
    currentSale.investor = investor;
    currentSale.shareholder = msg.sender;
    currentSale.weiRaised = 0;
    currentSale.sharesSold = 0;
    currentSale.ended = false;
    currentSale.exists = true;

    // Transfer the funds to the company.
    require(token().transferFrom(msg.sender, address(this), sharesCap));

    // Enforce that one shareholder will remain majority.
    require(isMajorityShareholder(msg.sender));
  }

  /**
   * @dev Process the payment from the investor.
   */
  function processPayment()
    private
  {
    address investor = currentSale.investor;
    uint256 excessWei = 0;
    uint256 sharesSold = currentSale.sharesSold;
    uint256 sharesCap = currentSale.sharesCap;
    uint256 rate = currentSale.rate;
    uint256 weiAmount = msg.value;
    uint256 shares = weiAmount.mul(rate).div(1 ether);

    // If the after this investment the cap will be reached
    // the sale will end and the excess wei will be sent
    // back to the investor. 
    if (sharesSold.add(shares) > sharesCap) {
      excessWei = sharesSold.add(shares).sub(sharesCap).mul(1 ether).div(rate);
      weiAmount = weiAmount.sub(excessWei);
      shares = sharesCap.sub(sharesSold);
    } else {
      //we care of investors money
      excessWei = weiAmount.sub(shares.mul(1 ether).div(rate));
      weiAmount = weiAmount.sub(excessWei);
    }

    // update shares
    currentSale.sharesSold = sharesSold.add(shares);

    // update weiRaised.
    currentSale.weiRaised = currentSale.weiRaised.add(weiAmount);

    //close sale
    if(currentSale.sharesSold == sharesCap) {
      currentSale.ended = true;
      SaleEnded(now);
    }

    // Send tokens to the investor.
    require(token().transfer(investor, shares));

    // Send excess back to the investor.
    if (excessWei > 0) {
      investor.transfer(excessWei);
    }

    // Trigger event.
    ProcessedInvestment(investor, weiAmount, shares);
  }

  /**
   * @dev Finalize the in progress sale.
   */
  function finalizeSale()
    public
    isActive
    onlySaleCreator
    onlyWhenSelling
  {
    require(currentSale.ended);
    require(currentSale.sharesSold == currentSale.sharesCap);

    // Send wei to the beneficiary.
    currentSale.beneficiary.transfer(currentSale.weiRaised); 

    // Trigger event.
    SaleCompleted(currentSale.beneficiary, currentSale.weiRaised, currentSale.sharesSold);
    
    // Reset sale.
    currentSale.exists = false;
  }

  /**
   * @dev Abort the current sale.
   */
  function abortSale()
    public
    isActive
    onlySaleCreator
    onlyWhenSelling
  {
    require(!currentSale.ended);

    address investor = currentSale.investor;
    address shareholder = currentSale.shareholder;
    address company = address(this);

    // Send wei back to the investor.
    investor.transfer(currentSale.weiRaised);

    // Send tokens back from the investor to company.
    require(token().transferFrom(investor, company, currentSale.sharesSold));

    // Send tokens back from the company to the shareholder.
    require(token().transferFrom(company, shareholder, currentSale.sharesCap));

    // Trigger event.
    SaleAborted(now);

    // Reset sale state.
    currentSale.exists = false;
  }
}
pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

library BnsLib {
  struct TopLevelDomain {
    uint price;
    uint lastUpdate;
    bool min;
    bool exists;
  }

  struct Domain {
    address owner;
    bool allowSubdomains;
    bytes content;
    mapping(string => string) domainStorage;
    mapping(address => bool) approvedForSubdomain;
  }

  function hasOnlyDomainLevelCharacters(string memory str) internal pure returns (bool) {
    /* [9-0] [A-Z] [a-z] [-] */
    bytes memory b = bytes(str);
    for(uint i; i<b.length; i++) {
      bytes1 char = b[i];
      if (! (
        (char >= 0x30 && char <= 0x39) ||
        (char >= 0x41 && char <= 0x5A) ||
        (char >= 0x61 && char <= 0x7A) ||
        (char == 0x2d)
      )) return false;
    }
    return true;
  }

  function strictJoin(string memory self, string memory s2, bytes1 delimiter) 
  internal pure returns (string memory) {
    /* Allow [0-9] [a-z] [-] Make [A-Z] lowercase */
    bytes memory orig = bytes(self);
    bytes memory addStr = bytes(s2);
    uint retSize = orig.length + addStr.length + 1;
    bytes memory ret = new bytes(retSize);
    for (uint i = 0; i < orig.length; i ++) {
      require(
        (orig[i] >= 0x30 && orig[i] <= 0x39) || // 0-9
        (orig[i] >= 0x41 && orig[i] <= 0x5A) || // A-Z
        (orig[i] >= 0x61 && orig[i] <= 0x7A) || // a-z
        (orig[i] == 0x2d || orig[i] == 0x5f), // -  _
        "Invalid character."
      );
      if (orig[i] >= 0x41 && orig[i] <= 0x5A) ret[i] = bytes1(uint8(orig[i]) + 32);
      else ret[i] = orig[i];
    }
    ret[orig.length] = delimiter;
    for (uint x = 0; x < addStr.length; x ++) {
      if (addStr[x] >= 0x41 && addStr[x] <= 0x5A)
        ret[orig.length + x + 1] = bytes1(uint8(addStr[x]) + 32);
      else ret[orig.length + x + 1] = addStr[x];
    }
    return string(ret);
  }
}

contract BetterNameService {
  using BnsLib for *;
  using SafeMath for uint;  


  constructor() public {
    createTopLevelDomain("bns");
    creat0r = msg.sender;
  }

  
  address creat0r;  
  uint updateAfter = 15000; // target around 1 update per day
  uint minPrice = 10000000000000000; // 0.01 eth

  mapping(string => BnsLib.TopLevelDomain) internal tldPrices;
  mapping(string => BnsLib.Domain) domains; // domain and subdomain owners


  function withdraw(uint amount) public {
    require(msg.sender == creat0r, "Only the creat0r can call that.");
    msg.sender.transfer(amount);
  }

  function balanceOf() public view returns (uint) {
    return address(this).balance;
  }



/*----------------<BEGIN MODIFIERS>----------------*/
  modifier tldExists(string memory tld) {
    require(tldPrices[tld].exists, "TLD does not exist");
    _;
  }

  modifier tldNotExists(string memory tld) {
    require(!tldPrices[tld].exists, "TLD exists");
    _;
  }

  modifier domainExists(string memory domain) {
    require(
      domains[domain].owner != address(0) &&
      domains[domain].owner != address(0x01), 
      "Domain does not exist or has been invalidated.");
    _;
  }

  modifier domainNotExists(string memory domain) {
    require(domains[domain].owner == address(0), "Domain exists");
    _;
  }

  modifier onlyDomainOwner(string memory domain) {
    require(msg.sender == domains[domain].owner, "Not owner of domain");
    _;
  }

  modifier onlyAllowed(string memory domain) {
    require(
      domains[domain].allowSubdomains ||
      domains[domain].owner == msg.sender ||
      domains[domain].approvedForSubdomain[msg.sender],
      "Not allowed to register subdomain."
    );
    _;
  }

  modifier onlyDomainLevelCharacters(string memory domainLevel) {
    require(BnsLib.hasOnlyDomainLevelCharacters(domainLevel), "Invalid characters");
    _;
  }
/*----------------</END MODIFIERS>----------------*/



/*----------------<BEGIN EVENTS>----------------*/
  event TopLevelDomainCreated(bytes32 indexed tldHash, string tld);
  event TopLevelDomainPriceUpdated(bytes32 indexed tldHash, string tld, uint price);

  event DomainRegistered(bytes32 indexed domainHash, 
  string domain, address owner, 
  address registeredBy, bool open);

  event SubdomainInvalidated(bytes32 indexed subdomainHash, 
  string subdomain, address invalidatedBy);

  event DomainRegistrationOpened(bytes32 indexed domainHash, string domain);
  event DomainRegistrationClosed(bytes32 indexed domainHash, string domain);

  event ApprovedForDomain(bytes32 indexed domainHash, string domain, address indexed approved);
  event DisapprovedForDomain(bytes32 indexed domainHash, 
  string domain, address indexed disapproved);

  event ContentUpdated(bytes32 indexed domainHash, string domain, bytes content);
/*----------------</END EVENTS>----------------*/



/*----------------<BEGIN VIEW FUNCTIONS>----------------*/
  function getTldPrice(string tld) public view returns (uint) {
    return tldPrices[tld].min ? minPrice : tldPrices[tld].price;
  }

  function expectedTldPrice(string tld) public view returns (uint) {
    if (tldPrices[tld].min) return minPrice;
    uint blockCount = block.number.sub(tldPrices[tld].lastUpdate);
    if (blockCount >= updateAfter) {
      uint updatesDue = blockCount.div(updateAfter);
      uint newPrice = tldPrices[tld].price.mul(750**updatesDue).div(1000**updatesDue);
      if (newPrice <= minPrice) return minPrice;
      return newPrice;
    }
    return tldPrices[tld].price;
  }

  function getDomainOwner(string domain) public view returns (address) {
    return domains[domain].owner;
  }

  function isPublicDomainRegistrationOpen(string memory domain) public view returns (bool) {
    return domains[domain].allowSubdomains;
  }
  
  function isApprovedToRegister(string memory domain, address addr) 
  public view returns (bool) {
    return domains[domain].allowSubdomains || 
      domains[domain].owner == addr || 
      domains[domain].approvedForSubdomain[addr];
  }

  function isDomainInvalidated(string memory domain) public view returns(bool) {
    return domains[domain].owner == address(0x01);
  }

  function getContent(string memory domain) public view returns (bytes) {
    return domains[domain].content;
  }


  /*<BEGIN STORAGE FUNCTIONS>*/
  function getDomainStorageSingle(string domain, string key) 
  public view domainExists(domain) returns (string) {
    return domains[domain].domainStorage[key];
  }

  function getDomainStorageMany(string domain, string[] memory keys) 
  public view domainExists(domain) returns (string[2][]) {
    string[2][] memory results = new string[2][](keys.length);
    for(uint i = 0; i < keys.length; i++) {
      string memory key = keys[i];
      results[i] = [key, domains[domain].domainStorage[key]];
    }
    return results;
  }
  /*</END STORAGE FUNCTIONS>*/
/*----------------</END VIEW FUNCTIONS>----------------*/



/*----------------<BEGIN PRICE FUNCTIONS>----------------*/
  function returnRemainder(uint price) internal {
    if (msg.value > price) msg.sender.transfer(msg.value.sub(price));
  }

  function updateTldPrice(string memory tld) public returns (uint) {
    if (!tldPrices[tld].min) {
      // tld price has not reached the minimum price
      uint price = expectedTldPrice(tld);
      if (price != tldPrices[tld].price) {
        if (price == minPrice) {
          tldPrices[tld].min = true;
          tldPrices[tld].price = 0;
          tldPrices[tld].lastUpdate = 0;
        } else {
          tldPrices[tld].price = price;
          tldPrices[tld].lastUpdate = block.number.sub((block.number.sub(tldPrices[tld].lastUpdate)).mod(updateAfter));
        }
        emit TopLevelDomainPriceUpdated(keccak256(abi.encode(tld)), tld, price);
      }
      return price;
    }
    else return minPrice;
  }
/*----------------</END PRICE FUNCTIONS>----------------*/



/*----------------<BEGIN DOMAIN REGISTRATION FUNCTIONS>----------------*/
  /*<BEGIN TLD FUNCTIONS>*/
  function createTopLevelDomain(string memory tld) 
  public tldNotExists(tld) onlyDomainLevelCharacters(tld) {
    tldPrices[tld] = BnsLib.TopLevelDomain({
      price: 5000000000000000000,
      lastUpdate: block.number,
      exists: true,
      min: false
    });
    emit TopLevelDomainCreated(keccak256(abi.encode(tld)), tld);
  }
  /*</END TLD FUNCTIONS>*/


  /*<BEGIN INTERNAL REGISTRATION FUNCTIONS>*/
  function _register(string memory domain, address owner, bool open) 
  internal domainNotExists(domain) {
    domains[domain].owner = owner;
    emit DomainRegistered(keccak256(abi.encode(domain)), domain, owner, msg.sender, open);
    if (open) domains[domain].allowSubdomains = true;
  }

  function _registerDomain(string memory domain, string memory tld, bool open) 
  internal tldExists(tld) {
    uint price = updateTldPrice(tld);
    require(msg.value >= price, "Insufficient price.");
    _register(domain.strictJoin(tld, 0x40), msg.sender, open);
    returnRemainder(price);
  }

  function _registerSubdomain(
    string memory subdomain, string memory domain, address owner, bool open) 
  internal onlyAllowed(domain) {
    _register(subdomain.strictJoin(domain, 0x2e), owner, open);
  }
  /*</END INTERNAL REGISTRATION FUNCTIONS>*/


  /*<BEGIN REGISTRATION OVERLOADS>*/
  function registerDomain(string memory domain, bool open) public payable {
    _registerDomain(domain, "bns", open);
  }

  function registerDomain(string memory domain, string memory tld, bool open) public payable {
    _registerDomain(domain, tld, open);
  }
  /*</END REGISTRATION OVERLOADS>*/


  /*<BEGIN SUBDOMAIN REGISTRATION OVERLOADS>*/
  function registerSubdomain(string memory subdomain, string memory domain, bool open) public {
    _registerSubdomain(subdomain, domain, msg.sender, open);
  }

  function registerSubdomainAsDomainOwner(
    string memory subdomain, string memory domain, address subdomainOwner) 
  public onlyDomainOwner(domain) {
    _registerSubdomain(subdomain, domain, subdomainOwner, false);
  }
  /*</END SUBDOMAIN REGISTRATION OVERLOADS>*/
/*----------------</END DOMAIN REGISTRATION FUNCTIONS>----------------*/



/*----------------<BEGIN DOMAIN MANAGEMENT FUNCTIONS>----------------*/
  function transferDomain(string domain, address recipient) public onlyDomainOwner(domain) {
    domains[domain].owner = recipient;
  }

  /*<BEGIN CONTENT HASH FUNCTIONS>*/
  function setContent(string memory domain, bytes memory content) 
  public onlyDomainOwner(domain) {
    domains[domain].content = content;
    emit ContentUpdated(keccak256(abi.encode(domain)), domain, content);
  }

  function deleteContent(string memory domain) public onlyDomainOwner(domain) {
    delete domains[domain].content;
    emit ContentUpdated(keccak256(abi.encode(domain)), domain, domains[domain].content);
  }
  /*</END CONTENT HASH FUNCTIONS>*/


  /*<BEGIN APPROVAL FUNCTIONS>*/
  function approveForSubdomain(string memory domain, address user) public onlyDomainOwner(domain) {
    domains[domain].approvedForSubdomain[user] = true;
    emit ApprovedForDomain(keccak256(abi.encode(domain)), domain, user);
  }

  function disapproveForSubdomain(string memory domain, address user) 
  public onlyDomainOwner(domain) {
    domains[domain].approvedForSubdomain[user] = false;
    emit DisapprovedForDomain(keccak256(abi.encode(domain)), domain, user);
  }
  /*</END APPROVAL FUNCTIONS>*/


  /*<BEGIN INVALIDATION FUNCTIONS>*/
  function _invalidateDomain(string memory domain) internal {
    domains[domain].owner = address(0x01);
    emit SubdomainInvalidated(keccak256(abi.encode(domain)), domain, msg.sender);
  }

  function invalidateDomain(string memory domain) public onlyDomainOwner(domain) {
    _invalidateDomain(domain);
  }

  function invalidateSubdomainAsDomainOwner(string memory subdomain, string memory domain) 
  public onlyDomainOwner(domain) {
    _invalidateDomain(subdomain.strictJoin(domain, "."));
  }
  /*</END INVALIDATION FUNCTIONS>*/


  /*<BEGIN RESTRICTION FUNCTIONS>*/
  function openPublicDomainRegistration(string domain) public onlyDomainOwner(domain) {
    domains[domain].allowSubdomains = true;
    emit DomainRegistrationOpened(keccak256(abi.encode(domain)), domain);
  }

  function closePublicDomainRegistration(string domain) public onlyDomainOwner(domain) {
    domains[domain].allowSubdomains = false;
    emit DomainRegistrationClosed(keccak256(abi.encode(domain)), domain);
  }
  /*</END RESTRICTION FUNCTIONS>*/


  /*<BEGIN STORAGE FUNCTIONS>*/
  function setDomainStorageSingle(string memory domain, string memory key, string memory value) 
  public onlyDomainOwner(domain) {
    domains[domain].domainStorage[key] = value;
  }

  function setDomainStorageMany(string memory domain, string[2][] memory kvPairs) 
  public onlyDomainOwner(domain) {
    for(uint i = 0; i < kvPairs.length; i++) {
      domains[domain].domainStorage[kvPairs[i][0]] = kvPairs[i][1];
    }
  }
  /*</END STORAGE FUNCTIONS>*/
/*----------------</END DOMAIN MANAGEMENT FUNCTIONS>----------------*/
}
pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable 
{
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract NFT 
{
  function totalSupply() public constant returns (uint);
  function balanceOf(address) public constant returns (uint);
  function tokenOfOwnerByIndex(address owner, uint index) public constant returns (uint);
  function ownerOf(uint tokenId) public constant returns (address);
  function transfer(address to, uint tokenId) public;
  function takeOwnership(uint tokenId) public;
  function approve(address beneficiary, uint tokenId) public;
  function metadata(uint tokenId) public constant returns (string);
}

contract NFTEvents 
{
  event TokenCreated(uint tokenId, address owner, string metadata);
  event TokenDestroyed(uint tokenId, address owner);
  event TokenTransferred(uint tokenId, address from, address to);
  event TokenTransferAllowed(uint tokenId, address beneficiary);
  event TokenTransferDisallowed(uint tokenId, address beneficiary);
  event TokenMetadataUpdated(uint tokenId, address owner, string data);
}

contract BasicNFT is NFT, NFTEvents 
{
  uint public totalTokens;

  // Array of owned tokens for a user
  mapping(address => uint[]) public ownedTokens;
  mapping(address => uint) _virtualLength;
  mapping(uint => uint) _tokenIndexInOwnerArray;

  // Mapping from token ID to owner
  mapping(uint => address) public tokenOwner;

  // Allowed transfers for a token (only one at a time)
  mapping(uint => address) public allowedTransfer;

  // Metadata associated with each token
  mapping(uint => string) public tokenMetadata;

  function totalSupply() public constant returns (uint) 
  {
    return totalTokens;
  }

  function balanceOf(address owner) public constant returns (uint) 
  {
    return _virtualLength[owner];
  }

  function tokenOfOwnerByIndex(address owner, uint index) public constant returns (uint) 
  {
    require(index >= 0 && index < balanceOf(owner));
    return ownedTokens[owner][index];
  }

  function getAllTokens(address owner) public constant returns (uint[]) 
  {
    uint size = _virtualLength[owner];
    uint[] memory result = new uint[](size);
    for (uint i = 0; i < size; i++) {
      result[i] = ownedTokens[owner][i];
    }
    return result;
  }

  function ownerOf(uint tokenId) public constant returns (address) 
  {
    return tokenOwner[tokenId];
  }

  function transfer(address to, uint tokenId) public
  {
    require(tokenOwner[tokenId] == msg.sender || allowedTransfer[tokenId] == msg.sender);
    _transfer(tokenOwner[tokenId], to, tokenId);
  }

  function takeOwnership(uint tokenId) public 
  {
    require(allowedTransfer[tokenId] == msg.sender);
    _transfer(tokenOwner[tokenId], msg.sender, tokenId);
  }

  function approve(address beneficiary, uint tokenId) public 
  {
    require(msg.sender == tokenOwner[tokenId]);
    if (allowedTransfer[tokenId] != 0) 
    {
      allowedTransfer[tokenId] = 0;
      TokenTransferDisallowed(tokenId, allowedTransfer[tokenId]);
    }
    allowedTransfer[tokenId] = beneficiary;
    TokenTransferAllowed(tokenId, beneficiary);
  }

  function metadata(uint tokenId) constant public returns (string) 
  {
    return tokenMetadata[tokenId];
  }

  function updateTokenMetadata(uint tokenId, string _metadata) internal returns(bool)
  {
    require(msg.sender == tokenOwner[tokenId]);
    tokenMetadata[tokenId] = _metadata;
    TokenMetadataUpdated(tokenId, msg.sender, _metadata);
    return true;
  }

  function _transfer(address from, address to, uint tokenId) internal returns(bool)
  {
    allowedTransfer[tokenId] = 0;
    _removeTokenFrom(from, tokenId);
    _addTokenTo(to, tokenId);
    TokenTransferred(tokenId, from, to);
    return true;
  }

  function _removeTokenFrom(address from, uint tokenId) internal 
  {
    require(_virtualLength[from] > 0);
    uint length = _virtualLength[from];
    uint index = _tokenIndexInOwnerArray[tokenId];
    uint swapToken = ownedTokens[from][length - 1];
    ownedTokens[from][index] = swapToken;
    _tokenIndexInOwnerArray[swapToken] = index;
    _virtualLength[from]--;
  }

  function _addTokenTo(address owner, uint tokenId) internal 
  {
    if (ownedTokens[owner].length == _virtualLength[owner]) 
    {
      ownedTokens[owner].push(tokenId);
    } 
    else 
    {
      ownedTokens[owner][_virtualLength[owner]] = tokenId;
    }
    tokenOwner[tokenId] = owner;
    _tokenIndexInOwnerArray[tokenId] = _virtualLength[owner];
    _virtualLength[owner]++;
  }
}

contract PlanetToken is Ownable, BasicNFT 
{
  string public name = 'Planet Tokens';
  string public symbol = 'PT';
   
  mapping (uint => uint) public cordX;
  mapping (uint => uint) public cordY;
  mapping (uint => uint) public cordZ;
  mapping (uint => uint) public lifeD;
  mapping (uint => uint) public lifeN;
  mapping (uint => uint) public lifeA;    
  mapping (uint => uint) public latestPing;
    
  struct planet
  {
    uint x;
    uint y;
    uint z;
    string name;
    address owner;
    string liason;
    string url;
    uint cost;
    uint index;
  }
    
  struct _donations
  {
      uint start;
      uint genesis;
      uint interval;
      uint ppp;
      uint amount;
      uint checkpoint;
  }

  mapping(uint => planet) planets;
  mapping(address => _donations) donations;
  
  string private universe;
  uint private min_donation;
  address private donation_address;
  uint private coordinate_limit;

  event TokenPing(uint tokenId);

  function () public payable 
  {
      donation_address.transfer(msg.value);
  }
    
  function PlanetToken(string UniverseName, uint CoordinateLimit, address DonationAddress, uint StartingWeiDonation, uint BlockIntervals, uint WeiPerPlanet) public
  {
      universe = UniverseName;
      min_donation = StartingWeiDonation;
      coordinate_limit = CoordinateLimit;
      donation_address = DonationAddress;
      donations[donation_address].start = min_donation;
      donations[donation_address].genesis = block.number;
      donations[donation_address].checkpoint = block.number;
      donations[donation_address].interval = BlockIntervals;
      donations[donation_address].ppp = WeiPerPlanet;
      donations[donation_address].amount = min_donation;
  }

  function assignNewPlanet(address beneficiary, uint x, uint y, uint z, string _planetName, string liason, string url) public payable 
  {  
    // Check current fee
    uint MinimumDonation = donations[donation_address].amount;
      
    // Check required paramters
    require(tokenOwner[buildTokenId(x, y, z)] == 0);
    require(msg.value >= MinimumDonation);
    require(x <= coordinate_limit);
    require(y <= coordinate_limit);
    require(z <= coordinate_limit);
     
    // Update token records
    latestPing[buildTokenId(x, y, z)] = now;
    _addTokenTo(beneficiary, buildTokenId(x, y, z));
    totalTokens++;
    tokenMetadata[buildTokenId(x, y, z)] = _planetName;

    // Update galactic records
    cordX[buildTokenId(x, y, z)] = x;
    cordY[buildTokenId(x, y, z)] = y;
    cordZ[buildTokenId(x, y, z)] = z;

    // Update DNA records
    lifeD[buildTokenId(x, y, z)] = uint256(keccak256(x, '|x|', msg.sender, '|', universe));
    lifeN[buildTokenId(x, y, z)] = uint256(keccak256(y, '|y|', msg.sender, '|', universe));
    lifeA[buildTokenId(x, y, z)] = uint256(keccak256(z, '|z|', msg.sender, '|', universe));
      
    // Map the planet object too ...
    planets[buildTokenId(x, y, z)].x = x;
    planets[buildTokenId(x, y, z)].x = y;
    planets[buildTokenId(x, y, z)].x = z;
    planets[buildTokenId(x, y, z)].name = _planetName;
    planets[buildTokenId(x, y, z)].owner = beneficiary;
    planets[buildTokenId(x, y, z)].liason = liason;
    planets[buildTokenId(x, y, z)].url = url;
    planets[buildTokenId(x, y, z)].index = totalTokens - 1;
    planets[buildTokenId(x, y, z)].cost = msg.value;

    // Finalize process
    TokenCreated(buildTokenId(x, y, z), beneficiary, _planetName);  
    donation_address.transfer(msg.value);
      
    // Update donation info
    uint this_block = block.number;
    uint new_checkpoint = donations[donation_address].checkpoint + donations[donation_address].interval; 
    if(this_block > new_checkpoint)
    {
        donations[donation_address].checkpoint = this_block;
        donations[donation_address].amount = donations[donation_address].ppp * totalTokens;
    }
  }
    
  function MinimumDonation() public view returns(uint)
  {
      return donations[donation_address].amount;
  }
    
  function BlocksToGo() public view returns(uint)
  {
      uint this_block = block.number;
      uint next_block = donations[donation_address].checkpoint + donations[donation_address].interval;
      if(this_block < next_block)
      {
          return next_block - this_block;
      }
      else
      {
          return 0;
      }
  }
    
  function GetLiasonName(uint x, uint y, uint z) public view returns(string)
  {
      return planets[buildTokenId(x, y, z)].liason;
  }

  function GetLiasonURL(uint x, uint y, uint z) public view returns(string)
  {
      return planets[buildTokenId(x, y, z)].url;
  }
    
  function GetIndex(uint x, uint y, uint z) public view returns(uint)
  {
      return planets[buildTokenId(x, y, z)].index;
  }
    
  function GetCost(uint x, uint y, uint z) public view returns(uint)
  {
      return planets[buildTokenId(x, y, z)].cost;
  }
    
  function UpdatedDonationAddress(address NewAddress) onlyOwner public
  {
      address OldAddress = donation_address;
      donation_address = NewAddress;
      donations[donation_address].start = donations[OldAddress].start;
      donations[donation_address].genesis = donations[OldAddress].genesis;
      donations[donation_address].checkpoint = donations[OldAddress].checkpoint;
      donations[donation_address].interval = donations[OldAddress].interval;
      donations[donation_address].ppp = donations[OldAddress].ppp;
      donations[donation_address].amount = donations[OldAddress].amount;
      
  }

  function ping(uint tokenId) public 
  {
    require(msg.sender == tokenOwner[tokenId]);
    latestPing[tokenId] = now;
    TokenPing(tokenId);
  }

  function buildTokenId(uint x, uint y, uint z) public view returns (uint256) 
  {
    return uint256(keccak256(x, '|', y, '|', z, '|', universe));
  }

  function exists(uint x, uint y, uint z) public constant returns (bool) 
  {
    return ownerOfPlanet(x, y, z) != 0;
  }

  function ownerOfPlanet(uint x, uint y, uint z) public constant returns (address) 
  {
    return tokenOwner[buildTokenId(x, y, z)];
  }

  function transferPlanet(address to, uint x, uint y, uint z) public 
  {
    require(msg.sender == tokenOwner[buildTokenId(x, y, z)]);
    planets[buildTokenId(x, y, z)].owner = to;
  }

  function planetName(uint x, uint y, uint z) constant public returns (string) 
  {
    return tokenMetadata[buildTokenId(x, y, z)];
  }
    
  function planetCordinates(uint tokenId) public constant returns (uint[]) 
  {
    uint[] memory data = new uint[](3);
    data[0] = cordX[tokenId];
    data[1] = cordY[tokenId];
    data[2] = cordZ[tokenId];
    return data;
  }
    
  function planetLife(uint x, uint y, uint z) constant public returns (uint[]) 
  {
    uint[] memory dna = new uint[](3);
    dna[0] = lifeD[buildTokenId(x, y, z)];
    dna[1] = lifeN[buildTokenId(x, y, z)];
    dna[2] = lifeA[buildTokenId(x, y, z)];
    return dna;
  }

  function updatePlanetName(uint x, uint y, uint z, string _planetName) public 
  {
    if(updateTokenMetadata(buildTokenId(x, y, z), _planetName))
    {
        planets[buildTokenId(x, y, z)].name = _planetName;
    }
  }
  
  function updatePlanetLiason(uint x, uint y, uint z, string LiasonName) public 
  {
    require(msg.sender == tokenOwner[buildTokenId(x, y, z)]);
    planets[buildTokenId(x, y, z)].liason = LiasonName;
  }
    
  function updatePlanetURL(uint x, uint y, uint z, string LiasonURL) public 
  {
    require(msg.sender == tokenOwner[buildTokenId(x, y, z)]);
    planets[buildTokenId(x, y, z)].url = LiasonURL;
  }
}
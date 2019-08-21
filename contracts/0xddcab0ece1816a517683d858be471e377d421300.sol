contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC721 {
    function implementsERC721() public pure returns (bool);
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function approve(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
}

contract SampleStorage is Ownable {
    
    struct Sample {
        string ipfsHash;
        uint rarity;
    }
    
    mapping (uint32 => Sample) public sampleTypes;
    
    uint32 public numOfSampleTypes;
    
    uint32 public numOfCommon;
    uint32 public numOfRare;
    uint32 public numOfLegendary;

    // The mythical sample is a type common that appears only once in a 1000
    function addNewSampleType(string _ipfsHash, uint _rarityType) public onlyOwner {
        
        if (_rarityType == 0) {
            numOfCommon++;
        } else if (_rarityType == 1) {
            numOfRare++;
        } else if(_rarityType == 2) {
            numOfLegendary++;
        } else if(_rarityType == 3) {
            numOfCommon++;
        }
        
        sampleTypes[numOfSampleTypes] = Sample({
           ipfsHash: _ipfsHash,
           rarity: _rarityType
        });
        
        numOfSampleTypes++;
    }
    
    function getType(uint _randomNum) public view returns (uint32) {
        uint32 range = 0;
        
        if (_randomNum > 0 && _randomNum < 600) {
            range = 600 / numOfCommon;
            return uint32(_randomNum) / range;
            
        } else if(_randomNum >= 600 && _randomNum < 900) {
            range = 300 / numOfRare;
            return uint32(_randomNum) / range;
        } else {
            range = 100 / numOfLegendary;
            return uint32(_randomNum) / range;
        }
    }
    
}
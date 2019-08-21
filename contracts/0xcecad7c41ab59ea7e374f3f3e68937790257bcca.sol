pragma solidity ^0.4.24;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/CDEpisodeManager.sol

contract ICDClue {
    uint public typesCount;
}

contract TVToken {
    function transfer(address _to, uint256 _value) public returns (bool);
    function safeTransfer(address _to, uint256 _value, bytes _data) public;
}

contract CDEpisodeManager is Ownable {
    address public manager;
    address public CDClueAddress;
    uint[] public restTypes;
    uint constant public artifactInEpisode = 5;
    uint public restTypesLength;

    uint[] public comicsCollection;
    uint public comicsCollectionBonus;
    mapping(uint => Collection) public collections;

    struct Collection {
        uint episodeNumber;
        uint[] cluesTypes;
        uint comicsClueType;
        uint bonusRewardType;
        bool isFinal;
        bool isDefined;
    }

    modifier onlyOwnerOrManager() {
        require(msg.sender == owner || manager == msg.sender);
        _;
    }

    event EpisodeStart(
        uint number,
        uint bonusType,
        uint comicsClueType,
        bool isFinal,
        uint[] episodeClueTypes
    );

    constructor(
        address _manager,
        address _CDClueAddress
    ) public {
        manager = _manager;
        CDClueAddress = _CDClueAddress;
        restTypesLength =  ICDClue(CDClueAddress).typesCount();
        for (uint i = 0; i < restTypesLength; i++) {
            restTypes.push(i + 1);
        }
    }

    function episodeStart(
        uint number,
        uint bonusType,
        uint comicsClueType,
        bool isFinal
    ) public onlyOwnerOrManager {
        collections[number] = Collection(
            number,
            new uint[](artifactInEpisode),
            comicsClueType,
            bonusType,
            isFinal,
            true
        );
        for (uint i = 0; i < artifactInEpisode; i++) {
            uint randomTypeId = restTypes[getRandom(restTypesLength, i)];
            collections[number].cluesTypes[i] = randomTypeId;
            removeRestType(randomTypeId);
        }
        emit EpisodeStart(number, bonusType, comicsClueType, isFinal, collections[number].cluesTypes);
    }

    function getClueOfCollectionByIndex(uint episodeNumber, uint index) public view returns(uint) {
        return collections[episodeNumber].cluesTypes[index];
    }

    function removeRestType(uint typeId) internal {
        for (uint i = 0; i < restTypesLength; i++) {
            if (restTypes[i] == typeId) {
                restTypes[i] = restTypes[restTypesLength - 1];
                restTypesLength--;
                return;
            }
        }
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

    function getRandom(uint max, uint mix) internal view returns (uint random) {
        random = bytesToUint(keccak256(abi.encodePacked(blockhash(block.number - 1), mix))) % max;
    }

    function changeCDClueAddress(address newAddress) public onlyOwnerOrManager {
        CDClueAddress = newAddress;
    }

    function setComicsCollection(uint[] comicsClueIds, uint bonusTypeId) public onlyOwnerOrManager {
        comicsCollection = comicsClueIds;
        comicsCollectionBonus = bonusTypeId;
    }

    function getComicsCollectionLength() public view returns(uint) {
        return comicsCollection.length;
    }

    function getComicsCollectionClueByIndex(uint index) public view returns(uint) {
        return comicsCollection[index];
    }

    function getCollectionBonusType(uint episodeNumber) public view returns(uint bonusType) {
        bonusType = collections[episodeNumber].bonusRewardType;
    }

    function isFinal(uint episodeNumber) public view returns(bool) {
        return collections[episodeNumber].isFinal;
    }

    function bytesToUint(bytes32 b) internal pure returns (uint number){
        for (uint i = 0; i < b.length; i++) {
            number = number + uint(b[i]) * (2 ** (8 * (b.length - (i + 1))));
        }
    }
}
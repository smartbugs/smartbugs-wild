pragma solidity ^0.4.19;

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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title EjectableOwnable
 * @dev The EjectableOwnable contract provides the function to remove the ownership of the contract.
 */
contract EjectableOwnable is Ownable {

    /**
     * @dev Remove the ownership by setting the owner address to null,
     * after calling this function, all onlyOwner function will be be able to be called by anyone anymore,
     * the contract will achieve truly decentralisation.
    */
    function removeOwnership() onlyOwner public {
        owner = 0x0;
    }

}

/**
 * @title JointOwnable
 * @dev Extension for the Ownable contract, where the owner can assign another address
 *  to manage some functions of the contract, using the eitherOwner modifier.
 *  Note that onlyOwner modifier would still be accessible only for the original owner.
 */
contract JointOwnable is Ownable {

  event AnotherOwnerAssigned(address indexed anotherOwner);

  address public anotherOwner;

  /**
   * @dev Throws if called by any account other than the owner or anotherOwner.
   */
  modifier eitherOwner() {
    require(msg.sender == owner || msg.sender == anotherOwner);
    _;
  }

  /**
   * @dev Allows the current owner to assign another owner.
   * @param _anotherOwner The address to another owner.
   */
  function assignAnotherOwner(address _anotherOwner) onlyOwner public {
    require(_anotherOwner != 0);
    AnotherOwnerAssigned(_anotherOwner);
    anotherOwner = _anotherOwner;
  }

}

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

  function Destructible() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {

  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

/**
 * @title PullPayment
 * @dev Base contract supporting async send for pull payments. Inherit from this
 * contract and use asyncSend instead of send.
 */
contract PullPayment {

  using SafeMath for uint256;

  mapping(address => uint256) public payments;
  uint256 public totalPayments;

  /**
   * @dev withdraw accumulated balance, called by payee.
   */
  function withdrawPayments() public {
    address payee = msg.sender;
    uint256 payment = payments[payee];

    require(payment != 0);
    require(this.balance >= payment);

    totalPayments = totalPayments.sub(payment);
    payments[payee] = 0;

    assert(payee.send(payment));
  }

  /**
   * @dev Called by the payer to store the sent amount as credit to be pulled.
   * @param dest The destination address of the funds.
   * @param amount The amount to transfer.
   */
  function asyncSend(address dest, uint256 amount) internal {
    payments[dest] = payments[dest].add(amount);
    totalPayments = totalPayments.add(amount);
  }

}

contract DungeonStructs {

    /**
     * @dev The main Dungeon struct. Every dungeon in the game is represented by this structure.
     * A dungeon is consists of an unlimited number of floors for your heroes to challenge,
     * the power level of a dungeon is encoded in the floorGenes. Some dungeons are in fact more "challenging" than others,
     * the secret formula for that is left for user to find out.
     *
     * Each dungeon also has a "training area", heroes can perform trainings and upgrade their stat,
     * and some dungeons are more effective in the training, which is also a secret formula!
     *
     * When player challenge or do training in a dungeon, the fee will be collected as the dungeon rewards,
     * which will be rewarded to the player who successfully challenged the current floor.
     *
     * Each dungeon fits in fits into three 256-bit words.
     */
    struct Dungeon {

        // The timestamp from the block when this dungeon is created.
        uint32 creationTime;

        // The status of the dungeon, each dungeon can have 4 status, namely:
        // 0: Active | 1: Challenge Only | 2: Train Only | 3: InActive
        uint16 status;

        // The dungeon's difficulty, the higher the difficulty,
        // normally, the "rarer" the seedGenes, the higher the diffculty,
        // and the higher the contribution fee it is to challenge and train with the dungeon,
        // the formula for the contribution fee is in DungeonChallenge and DungeonTraining contracts.
        // A dungeon's difficulty never change.
        uint16 difficulty;

        // The current floor number, a dungeon is consists of an umlimited number of floors,
        // when there is heroes successfully challenged a floor, the next floor will be
        // automatically generated. 32-bit unsigned integers can have 4 billion floors.
        uint32 floorNumber;

        // The timestamp from the block when the current floor is generated.
        uint32 floorCreationTime;

        // Current accumulated rewards, successful challenger will get a large proportion of it.
        uint128 rewards;

        // The seed genes of the dungeon, it is used as the base gene for first floor,
        // some dungeons are rarer and some are more common, the exact details are,
        // of course, top secret of the game!
        // A dungeon's seedGenes never change.
        uint seedGenes;

        // The genes for current floor, it encodes the difficulty level of the current floor.
        // We considered whether to store the entire array of genes for all floors, but
        // in order to save some precious gas we're willing to sacrifice some functionalities with that.
        uint floorGenes;

    }

    /**
     * @dev The main Hero struct. Every hero in the game is represented by this structure.
     */
    struct Hero {

        // The timestamp from the block when this dungeon is created.
        uint64 creationTime;

        // The seed of the hero, the gene encodes the power level of the hero.
        // This is another top secret of the game! Hero's gene can be upgraded via
        // training in a dungeon.
        uint genes;

    }

}

/**
 * @title A simplified interface of ERC-721, but without approval functions
 */
contract ERC721 {

    // Events
    event Transfer(address indexed from, address indexed to, uint tokenId);

    // ERC20 compatible functions
    // function name() public view returns (string);
    // function symbol() public view returns (string);
    function totalSupply() public view returns (uint);
    function balanceOf(address _owner) public view returns (uint);

    // Functions that define ownership
    function ownerOf(uint _tokenId) external view returns (address);
    function transfer(address _to, uint _tokenId) external;

}

/**
 * @title The ERC-721 compliance token contract for the Dungeon tokens.
 * @dev See the DungeonStructs contract to see the details of the Dungeon token data structure.
 */
contract DungeonToken is ERC721, DungeonStructs, Pausable, JointOwnable {

    /**
     * @notice Limits the number of dungeons the contract owner can ever create.
     */
    uint public constant DUNGEON_CREATION_LIMIT = 1024;

    /**
     * @dev The Mint event is fired whenever a new dungeon is created.
     */
    event Mint(address indexed owner, uint newTokenId, uint difficulty, uint seedGenes);

    /**
     * @dev The NewDungeonFloor event is fired whenever a new dungeon floor is added.
     */
    event NewDungeonFloor(uint timestamp, uint indexed dungeonId, uint32 newFloorNumber, uint128 newRewards , uint newFloorGenes);

    /**
     * @dev Transfer event as defined in current draft of ERC721. Emitted every time a token
     *  ownership (Dungeon Master) is assigned, including token creation.
     */
    event Transfer(address indexed from, address indexed to, uint tokenId);

    /**
     * @dev Name of token.
     */
    string public constant name = "Dungeon";

    /**
     * @dev Symbol of token.
     */
    string public constant symbol = "DUNG";

    /**
     * @dev An array containing the Dungeon struct, which contains all the dungeons in existance.
     *  The ID for each dungeon is the index of this array.
     */
    Dungeon[] public dungeons;

    /**
     * @dev A mapping from token IDs to the address that owns them.
     */
    mapping(uint => address) tokenIndexToOwner;

    /**
     * @dev A mapping from owner address to count of tokens that address owns.
     */
    mapping(address => uint) ownershipTokenCount;

    /**
     * Each non-fungible token owner can own more than one token at one time.
     * Because each token is referenced by its unique ID, however,
     * it can get difficult to keep track of the individual tokens that a user may own.
     * To do this, the contract keeps a record of the IDs of each token that each user owns.
     */
    mapping(address => uint[]) public ownerTokens;

    /**
     * @notice Returns the total number of tokens currently in existence.
     */
    function totalSupply() public view returns (uint) {
        return dungeons.length;
    }

    /**
     * @notice Returns the number of tokens owned by a specific address.
     * @param _owner The owner address to check.
     */
    function balanceOf(address _owner) public view returns (uint) {
        return ownershipTokenCount[_owner];
    }

    /**
     * @dev Checks if a given address is the current owner of a particular token.
     * @param _claimant The address we are validating against.
     * @param _tokenId Token ID
     */
    function _owns(address _claimant, uint _tokenId) internal view returns (bool) {
        return tokenIndexToOwner[_tokenId] == _claimant;
    }

    /**
     * @notice Returns the address currently assigned ownership of a given token.
     */
    function ownerOf(uint _tokenId) external view returns (address) {
        require(tokenIndexToOwner[_tokenId] != address(0));

        return tokenIndexToOwner[_tokenId];
    }

    /**
     * @dev Assigns ownership of a specific token to an address.
     */
    function _transfer(address _from, address _to, uint _tokenId) internal {
        // Increment the ownershipTokenCount.
        ownershipTokenCount[_to]++;

        // Transfer ownership.
        tokenIndexToOwner[_tokenId] = _to;

        // Add the _tokenId to ownerTokens[_to]
        ownerTokens[_to].push(_tokenId);

        // When creating new token, _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;

            // Remove the _tokenId from ownerTokens[_from]
            uint[] storage fromTokens = ownerTokens[_from];
            bool iFound = false;

            for (uint i = 0; i < fromTokens.length - 1; i++) {
                if (iFound) {
                    fromTokens[i] = fromTokens[i + 1];
                } else if (fromTokens[i] == _tokenId) {
                    iFound = true;
                }
            }
        }

        // Emit the Transfer event.
        Transfer(_from, _to, _tokenId);
    }

    /**
     * @notice External function to transfers a token to another address.
     * @param _to The address of the recipient, can be a user or contract.
     * @param _tokenId The ID of the token to transfer.
     */
    function transfer(address _to, uint _tokenId) whenNotPaused external {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));

        // Disallow transfers to this contract to prevent accidental misuse.
        require(_to != address(this));

        // You can only send your own token.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /**
     * @dev The external function that creates a new dungeon and stores it, only contract owners
     *  can create new token, and will be restricted by the DUNGEON_CREATION_LIMIT.
     *  Will generate a Mint event, a  NewDungeonFloor event, and a Transfer event.
     * @param _difficulty The difficulty of the new dungeon.
     * @param _seedGenes The seed genes of the new dungeon.
     * @return The dungeon ID of the new dungeon.
     */
    function createDungeon(uint _difficulty, uint _seedGenes, address _owner) eitherOwner external returns (uint) {
        // Ensure the total supply is within the fixed limit.
        require(totalSupply() < DUNGEON_CREATION_LIMIT);

        // UPDATE STORAGE
        // Create a new dungeon.
        dungeons.push(Dungeon(uint32(now), 0, uint16(_difficulty), 0, 0, 0, _seedGenes, 0));

        // Token id is the index in the storage array.
        uint newTokenId = dungeons.length - 1;

        // Emit the token mint event.
        Mint(_owner, newTokenId, _difficulty, _seedGenes);

        // Initialize the fist floor with using the seedGenes, this will emit the NewDungeonFloor event.
        addDungeonNewFloor(newTokenId, 0, _seedGenes);

        // This will assign ownership, and also emit the Transfer event.
        _transfer(0, _owner, newTokenId);

        return newTokenId;
    }

    /**
     * @dev The external function to set dungeon status by its ID,
     *  refer to DungeonStructs for more information about dungeon status.
     *  Only contract owners can alter dungeon state.
     */
    function setDungeonStatus(uint _id, uint _newStatus) eitherOwner external {
        require(_id < totalSupply());

        dungeons[_id].status = uint16(_newStatus);
    }

    /**
     * @dev The external function to add additional dungeon rewards by its ID,
     *  only contract owners can alter dungeon state.
     */
    function addDungeonRewards(uint _id, uint _additinalRewards) eitherOwner external {
        require(_id < totalSupply());

        dungeons[_id].rewards += uint64(_additinalRewards);
    }

    /**
     * @dev The external function to add another dungeon floor by its ID,
     *  only contract owners can alter dungeon state.
     *  Will generate both a NewDungeonFloor event.
     */
    function addDungeonNewFloor(uint _id, uint _newRewards, uint _newFloorGenes) eitherOwner public {
        require(_id < totalSupply());

        Dungeon storage dungeon = dungeons[_id];

        dungeon.floorNumber++;
        dungeon.floorCreationTime = uint32(now);
        dungeon.rewards = uint128(_newRewards);
        dungeon.floorGenes = _newFloorGenes;

        // Emit the NewDungeonFloor event.
        NewDungeonFloor(now, _id, dungeon.floorNumber, dungeon.rewards, dungeon.floorGenes);
    }

}

/**
 * @title The ERC-721 compliance token contract for the Hero tokens.
 * @dev See the DungeonStructs contract to see the details of the Hero token data structure.
 */
contract HeroToken is ERC721, DungeonStructs, Pausable, JointOwnable {

    /**
     * @dev The Mint event is fired whenever a new hero is created.
     */
    event Mint(address indexed owner, uint newTokenId, uint _genes);

    /**
     * @dev Transfer event as defined in current draft of ERC721. Emitted every time a token
     *  ownership is assigned, including token creation.
     */
    event Transfer(address indexed from, address indexed to, uint tokenId);

    /**
     * @dev Name of token.
     */
    string public constant name = "Hero";

    /**
     * @dev Symbol of token.
     */
    string public constant symbol = "HERO";

    /**
     * @dev An array containing the Hero struct, which contains all the heroes in existance.
     *  The ID for each hero is the index of this array.
     */
    Hero[] public heroes;

    /**
     * @dev A mapping from token IDs to the address that owns them.
     */
    mapping(uint => address) tokenIndexToOwner;

    /**
     * @dev A mapping from owner address to count of tokens that address owns.
     */
    mapping(address => uint) ownershipTokenCount;

    /**
     * Each non-fungible token owner can own more than one token at one time.
     * Because each token is referenced by its unique ID, however,
     * it can get difficult to keep track of the individual tokens that a user may own.
     * To do this, the contract keeps a record of the IDs of each token that each user owns.
     */
    mapping(address => uint[]) public ownerTokens;

    /**
     * @notice Returns the total number of tokens currently in existence.
     */
    function totalSupply() public view returns (uint) {
        return heroes.length;
    }

    /**
     * @notice Returns the number of tokens owned by a specific address.
     * @param _owner The owner address to check.
     */
    function balanceOf(address _owner) public view returns (uint) {
        return ownershipTokenCount[_owner];
    }

    /**
     * @dev Checks if a given address is the current owner of a particular token.
     * @param _claimant The address we are validating against.
     * @param _tokenId Token ID
     */
    function _owns(address _claimant, uint _tokenId) internal view returns (bool) {
        return tokenIndexToOwner[_tokenId] == _claimant;
    }

    /**
     * @notice Returns the address currently assigned ownership of a given token.
     */
    function ownerOf(uint _tokenId) external view returns (address) {
        require(tokenIndexToOwner[_tokenId] != address(0));

        return tokenIndexToOwner[_tokenId];
    }

    /**
     * @dev Assigns ownership of a specific token to an address.
     */
    function _transfer(address _from, address _to, uint _tokenId) internal {
        // Increment the ownershipTokenCount.
        ownershipTokenCount[_to]++;

        // Transfer ownership.
        tokenIndexToOwner[_tokenId] = _to;

        // Add the _tokenId to ownerTokens[_to]
        ownerTokens[_to].push(_tokenId);

        // When creating new token, _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;

            // Remove the _tokenId from ownerTokens[_from]
            uint[] storage fromTokens = ownerTokens[_from];
            bool iFound = false;

            for (uint i = 0; i < fromTokens.length - 1; i++) {
                if (iFound) {
                    fromTokens[i] = fromTokens[i + 1];
                } else if (fromTokens[i] == _tokenId) {
                    iFound = true;
                }
            }
        }

        // Emit the Transfer event.
        Transfer(_from, _to, _tokenId);
    }

    /**
     * @notice External function to transfers a token to another address.
     * @param _to The address of the recipient, can be a user or contract.
     * @param _tokenId The ID of the token to transfer.
     */
    function transfer(address _to, uint _tokenId) whenNotPaused external {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));

        // Disallow transfers to this contract to prevent accidental misuse.
        require(_to != address(this));

        // You can only send your own token.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /**
     * @dev An external function that creates a new hero and stores it,
     *  only contract owners can create new token.
     *  method doesn't do any checking and should only be called when the
     *  input data is known to be valid.
     * @param _genes The gene of the new hero.
     * @param _owner The inital owner of this hero.
     * @return The hero ID of the new hero.
     */
    function createHero(uint _genes, address _owner) external returns (uint) {
        // UPDATE STORAGE
        // Create a new hero.
        heroes.push(Hero(uint64(now), _genes));

        // Token id is the index in the storage array.
        uint newTokenId = heroes.length - 1;

        // Emit the token mint event.
        Mint(_owner, newTokenId, _genes);

        // This will assign ownership, and also emit the Transfer event.
        _transfer(0, _owner, newTokenId);

        return newTokenId;
    }

    /**
     * @dev The external function to set the hero genes by its ID,
     *  only contract owners can alter hero state.
     */
    function setHeroGenes(uint _id, uint _newGenes) eitherOwner external {
        require(_id < totalSupply());

        Hero storage hero = heroes[_id];

        hero.genes = _newGenes;
    }

}

/**
 * SECRET
 */
contract ChallengeScienceInterface {

    /**
     * @dev given genes of current floor and dungeon seed, return a genetic combination - may have a random factor
     * @param _floorGenes genes of floor
     * @param _seedGenes seed genes of dungeon
     * @return the resulting genes
     */
    function mixGenes(uint _floorGenes, uint _seedGenes) external pure returns (uint);

}

/**
 * SECRET
 */
contract TrainingScienceInterface {

    /**
     * @dev given genes of hero and current floor, return a genetic combination - may have a random factor
     * @param _heroGenes genes of hero
     * @param _floorGenes genes of current floor
     * @return the resulting genes
     */
    function mixGenes(uint _heroGenes, uint _floorGenes) external pure returns (uint);

}

/**
 * @title DungeonBase
 * @dev Base contract for Ether Dungeon. It implements all necessary sub-classes,
 * holds all the base storage variables, and some commonly used functions.
 */
contract DungeonBase is EjectableOwnable, Pausable, PullPayment, DungeonStructs {

    /* ======== TOKEN CONTRACTS ======== */

    /**
     * @dev The address of the ERC721 token contract managing all Dungeon tokens.
     */
    DungeonToken public dungeonTokenContract;

    /**
     * @dev The address of the ERC721 token contract managing all Hero tokens.
     */
    HeroToken public heroTokenContract;


    /* ======== CLOSED SOURCE CONTRACTS ======== */

    /**
     * @dev The address of the ChallengeScience contract that handles the floor generation mechanics after challenge success.
     */
    ChallengeScienceInterface challengeScienceContract;

    /**
     * @dev The address of the TrainingScience contract that handles the hero training mechanics.
     */
    TrainingScienceInterface trainingScienceContract;


    /* ======== SETTER FUNCTIONS ======== */

    /**
     * @dev Set the address of the dungeon token contract.
     * @param _newDungeonTokenContract An address of a DungeonToken contract.
     */
    function setDungeonTokenContract(address _newDungeonTokenContract) onlyOwner external {
        dungeonTokenContract = DungeonToken(_newDungeonTokenContract);
    }

    /**
     * @dev Set the address of the hero token contract.
     * @param _newHeroTokenContract An address of a HeroToken contract.
     */
    function setHeroTokenContract(address _newHeroTokenContract) onlyOwner external {
        heroTokenContract = HeroToken(_newHeroTokenContract);
    }

    /**
     * @dev Set the address of the secret dungeon challenge formula contract.
     * @param _newChallengeScienceAddress An address of a ChallengeScience contract.
     */
    function setChallengeScienceContract(address _newChallengeScienceAddress) onlyOwner external {
        challengeScienceContract = ChallengeScienceInterface(_newChallengeScienceAddress);
    }

    /**
     * @dev Set the address of the secret hero training formula contract.
     * @param _newTrainingScienceAddress An address of a TrainingScience contract.
     */
    function setTrainingScienceContract(address _newTrainingScienceAddress) onlyOwner external {
        trainingScienceContract = TrainingScienceInterface(_newTrainingScienceAddress);
    }


    /* ======== MODIFIERS ======== */
    /**
     * @dev Throws if _dungeonId is not created yet.
     */
    modifier dungeonExists(uint _dungeonId) {
        require(_dungeonId < dungeonTokenContract.totalSupply());
        _;
    }

    /**
     * @dev Throws if dungeon status do not allow challenge, also check for dungeon existence.
     */
    modifier canChallenge(uint _dungeonId) {
        require(_dungeonId < dungeonTokenContract.totalSupply());
        uint status;
        (,status,,,,,,) = dungeonTokenContract.dungeons(_dungeonId);
        require(status == 0 || status == 1);
        _;
    }

    /**
     * @dev Throws if dungeon status do not allow training, also check for dungeon existence.
     */
    modifier canTrain(uint _dungeonId) {
        require(_dungeonId < dungeonTokenContract.totalSupply());
        uint status;
        (,status,,,,,,) = dungeonTokenContract.dungeons(_dungeonId);
        require(status == 0 || status == 2);
        _;
    }


    /* ======== HELPER FUNCTIONS ======== */

    /**
     * @dev An internal function to calculate the power of player, or difficulty of a dungeon floor,
     *  if the total heroes power is larger than the current dungeon floor difficulty, the heroes win the challenge.
     */
    function _getGenesPower(uint _genes) internal pure returns (uint) {
        // Calculate total stats power.
        uint statsPower;

        for (uint i = 0; i < 4; i++) {
            statsPower += _genes % 32;
            _genes /= 32 ** 4;
        }

        // Calculate total stats power.
        uint equipmentPower;
        bool isSuper = true;

        for (uint j = 4; j < 12; j++) {
            uint curGene = _genes % 32;
            equipmentPower += curGene;
            _genes /= 32 ** 4;

            if (equipmentPower != curGene * (j - 3)) {
                isSuper = false;
            }
        }

        // Calculate super power
        if (isSuper) {
            equipmentPower *= 2;
        }

        return statsPower + equipmentPower + 12;
    }

}

contract DungeonChallenge is DungeonBase {

    /**
     * @dev The DungeonChallenged event is fired when user finished a dungeon challenge.
     */
    event DungeonChallenged(uint timestamp, address indexed playerAddress, uint indexed dungeonId, uint heroGenes, uint floorNumber, uint floorGenes, bool success, uint newFloorGenes, uint successRewards, uint masterRewards);

    /**
     * @notice The actual fee contribution required to call challenge() is calculated by this feeMultiplier,
     *  times the dungeon difficulty. The payment is accumulated to the dungeon rewards,
     *  and a large proportion will be claimed by whoever successfully challenged the floor.
     *  1 finney = 0.001 ether
     */
    uint256 public challengeFeeMultiplier = 1 finney;

    /**
     * @dev The percentage for which successful challenger be rewarded of the dungeons' accumulated rewards.
     *  The remaining rewards subtracted by developer fee will be used as the base rewards for new floor.
     */
    uint public challengeRewardsPercent = 64;

    /**
     * @dev The developer fee for owner
     *  Note that when Ether Dungeon becomes truly decentralised, contract ownership will be ejected,
     *  and the master rewards will be rewarded to the dungeon owner (Dungeon Masters).
     */
    uint public masterRewardsPercent = 8;

    /**
     * @dev The main public function to call when a player challenge a dungeon,
     *  it determines whether if the player successfully challenged the current floor.
     *  Will generate a DungeonChallenged event.
     */
    function challenge(uint _dungeonId) external payable whenNotPaused canChallenge(_dungeonId) {
        // Get the dungeon details from the token contract.
        uint difficulty;
        uint seedGenes;
        (,,difficulty,,,,seedGenes,) = dungeonTokenContract.dungeons(_dungeonId);

        // Checks for payment, any exceeding funds will be transferred back to the player.
        uint requiredFee = difficulty * challengeFeeMultiplier;
        require(msg.value >= requiredFee);

        // ** STORAGE UPDATE **
        // Increment the accumulated rewards for the dungeon.
        dungeonTokenContract.addDungeonRewards(_dungeonId, requiredFee);

        // Calculate any excess funds and make it available to be withdrawed by the player.
        asyncSend(msg.sender, msg.value - requiredFee);

        // Split the challenge function into multiple parts because of stack too deep error.
        _challengePart2(_dungeonId, requiredFee);
    }

    /**
     * Split the challenge function into multiple parts because of stack too deep error.
     */
    function _challengePart2(uint _dungeonId, uint _requiredFee) private {
        uint floorNumber;
        uint rewards;
        uint floorGenes;
        (,,,floorNumber,,rewards,,floorGenes) = dungeonTokenContract.dungeons(_dungeonId);

        // The original dungeon rewards plus the required fee of this callenge call.
        uint _addedRewards = rewards + uint128(_requiredFee);

        // Get the first hero gene, or initialize first hero with current dungeon's seed genes.
        // TODO: implement multiple heroes in next phase
        uint heroGenes = _getFirstHeroGenesAndInitialize(_dungeonId);

        bool success = _getChallengeSuccess(heroGenes, floorGenes);

        uint newFloorGenes;
        uint successRewards;
        uint masterRewards;

        // Whether a challenge is success or not is determined by a simple comparison between hero power and floor power.
        if (success) {
            newFloorGenes = _getNewFloorGene(_dungeonId);
            successRewards = _addedRewards * challengeRewardsPercent / 100;
            masterRewards = _addedRewards * masterRewardsPercent / 100;

            // The dungeon rewards for new floor as total rewards - challenge rewards - devleoper fee.
            uint newRewards = _addedRewards * (100 - challengeRewardsPercent - masterRewardsPercent) / 100;

            // ** STORAGE UPDATE **
            // Add new floor with the new floor genes and new rewards.
            dungeonTokenContract.addDungeonNewFloor(_dungeonId, newRewards, newFloorGenes);

            // Mark the challenge rewards available to be withdrawed by the player.
            asyncSend(msg.sender, _addedRewards * challengeRewardsPercent / 100);

            // Mark the master rewards available to be withdrawed by the dungeon master.
            asyncSend(owner, _addedRewards * masterRewardsPercent / 100);
        }

        // Emit the DungeonChallenged event.
        DungeonChallenged(now, msg.sender, _dungeonId, heroGenes, floorNumber, floorGenes, success, newFloorGenes, successRewards, masterRewards);
    }

    /**
     * Split the challenge function into multiple parts because of stack too deep error.
     */
    function _getFirstHeroGenesAndInitialize(uint _dungeonId) private returns (uint heroGenes) {
        uint seedGenes;
        (,,,,,,seedGenes,) = dungeonTokenContract.dungeons(_dungeonId);

        // Get the first hero of the player.
        uint heroId;

        if (heroTokenContract.balanceOf(msg.sender) == 0) {
            // Assign the first hero using the seed genes of the dungeon for new player.
            heroId = heroTokenContract.createHero(seedGenes, msg.sender);
        } else {
            heroId = heroTokenContract.ownerTokens(msg.sender, 0);
        }

        // Get the hero genes from token storage.
        (,heroGenes) = heroTokenContract.heroes(heroId);
    }

    /**
     * Split the challenge function into multiple parts because of stack too deep error.
     */
    function _getChallengeSuccess(uint heroGenes, uint floorGenes) private pure returns (bool) {
        // Determine if the player challenge successfuly the dungeon or not, and the new floor genes.
        uint heroPower = _getGenesPower(heroGenes);
        uint floorPower = _getGenesPower(floorGenes);

        return heroPower > floorPower;
    }

    /**
     * Split the challenge function into multiple parts because of stack too deep error.
     */
    function _getNewFloorGene(uint _dungeonId) private view returns (uint) {
        uint seedGenes;
        uint floorGenes;
        (,,,,,seedGenes,floorGenes) = dungeonTokenContract.dungeons(_dungeonId);

        // Calculate the new floor gene.
        uint floorPower = _getGenesPower(floorGenes);
        uint newFloorGenes = challengeScienceContract.mixGenes(floorGenes, seedGenes);
        uint newFloorPower = _getGenesPower(newFloorGenes);

        // If the power decreased, rollback to the current floor genes.
        if (newFloorPower < floorPower) {
            newFloorGenes = floorGenes;
        }

        return newFloorGenes;
    }


    /* ======== SETTER FUNCTIONS ======== */

    /**
     * @dev Updates the fee contribution multiplier required for calling challenge().
     */
    function setChallengeFeeMultiplier(uint _newChallengeFeeMultiplier) external onlyOwner {
        challengeFeeMultiplier = _newChallengeFeeMultiplier;
    }

    /**
     * @dev Updates the challenge rewards pecentage.
     */
    function setChallengeRewardsPercent(uint _newChallengeRewardsPercent) onlyOwner external {
        challengeRewardsPercent = _newChallengeRewardsPercent;
    }

    /**
     * @dev Updates the master rewards percentage.
     */
    function setMasterRewardsPercent(uint _newMasterRewardsPercent) onlyOwner external {
        masterRewardsPercent = _newMasterRewardsPercent;
    }

}

contract DungeonTraining is DungeonChallenge {

    /// @dev The HeroTrained event is fired when user finished a training.
    event HeroTrained(uint timestamp, address indexed playerAddress, uint indexed dungeonId, uint heroGenes, uint floorNumber, uint floorGenes, bool success, uint newHeroGenes);

    /// @notice The actual fee contribution required to call trainX() is calculated by this feeMultiplier,
    ///  times the dungeon difficulty, times X. The payment is accumulated to the dungeon rewards,
    ///  and a large proportion will be claimed by whoever successfully challenged the floor.
    ///  1 finney = 0.001 ether
    uint256 public trainingFeeMultiplier = 2 finney;

    /// @dev Updates the fee contribution multiplier required for calling trainX().
    function setTrainingFeeMultiplier(uint _newTrainingFeeMultiplier) external onlyOwner {
        trainingFeeMultiplier = _newTrainingFeeMultiplier;
    }

    /// @dev The public function to call when a hero train with a dungeon,
    ///  it determines whether whether a training is successfully, and the resulting genes.
    ///  Will generate a DungeonChallenged event.
    function train1(uint _dungeonId) external payable whenNotPaused canTrain(_dungeonId) {
        _train(_dungeonId, 1);
    }

    function train2(uint _dungeonId) external payable whenNotPaused canTrain(_dungeonId) {
        _train(_dungeonId, 2);
    }

    function train3(uint _dungeonId) external payable whenNotPaused canTrain(_dungeonId) {
        _train(_dungeonId, 3);
    }

    /// @dev An internal function of a hero train with dungeon,
    ///  it determines whether whether a training is successfully, and the resulting genes.
    ///  Will generate a DungeonChallenged event.
    function _train(uint _dungeonId, uint _trainingTimes) private {
        // Get the dungeon details from the token contract.
        uint difficulty;
        uint floorNumber;
        uint rewards;
        uint seedGenes;
        uint floorGenes;
        (,,difficulty,floorNumber,,rewards,seedGenes,floorGenes) = dungeonTokenContract.dungeons(_dungeonId);

        // Check for _trainingTimes abnormality, we probably won't have any feature that train a hero 10 times with a single call.
        require(_trainingTimes < 10);

        // Checks for payment, any exceeding funds will be transferred back to the player.
        uint requiredFee = difficulty * trainingFeeMultiplier * _trainingTimes;
        require(msg.value >= requiredFee);

        // Get the first hero of the player.
        // TODO: implement multiple heroes in next phase
        uint heroId;

        if (heroTokenContract.balanceOf(msg.sender) == 0) {
            // Assign the first hero using the seed genes of the dungeon for new player.
            heroId = heroTokenContract.createHero(seedGenes, msg.sender);
        } else {
            heroId = heroTokenContract.ownerTokens(msg.sender, 0);
        }

        // ** STORAGE UPDATE **
        // Increment the accumulated rewards for the dungeon.
        dungeonTokenContract.addDungeonRewards(_dungeonId, requiredFee);

        // Calculate any excess funds and make it available to be withdrawed by the player.
        asyncSend(msg.sender, msg.value - requiredFee);

        // Split the _train function into multiple parts because of stack too deep error.
        _trainPart2(_dungeonId, _trainingTimes, heroId);
    }

    /**
     * Split the _train function into multiple parts because of stack too deep error.
     */
    function _trainPart2(uint _dungeonId, uint _trainingTimes, uint _heroId) private {
        // Get the dungeon details from the token contract.
        uint floorNumber;
        uint floorGenes;
        (,,,floorNumber,,,,floorGenes) = dungeonTokenContract.dungeons(_dungeonId);

        uint heroGenes;
        (,heroGenes) = heroTokenContract.heroes(_heroId);

        // Determine if the hero training is successful or not, and the resulting genes.
        uint heroPower = _getGenesPower(heroGenes);

        uint newHeroGenes = heroGenes;
        uint newHeroPower = heroPower;

        // Train the hero multiple times according to _trainingTimes,
        // each time if the resulting power is larger, update new hero power.
        for (uint i = 0; i < _trainingTimes; i++) {
            uint tmpHeroGenes = trainingScienceContract.mixGenes(newHeroGenes, floorGenes);
            uint tmpHeroPower = _getGenesPower(tmpHeroGenes);

            if (tmpHeroPower > newHeroPower) {
                newHeroGenes = tmpHeroGenes;
                newHeroPower = tmpHeroPower;
            }
        }

        // Prevent reduced power.
        bool success = newHeroPower > heroPower;

        if (success) {
            // ** STORAGE UPDATE **
            // Set the upgraded hero genes.
            heroTokenContract.setHeroGenes(_heroId, newHeroGenes);
        }

        // Emit the HeroTrained event.
        HeroTrained(now, msg.sender, _dungeonId, heroGenes, floorNumber, floorGenes, success, newHeroGenes);
    }

}

/**
 * @title DungeonCoreAlpha
 * @dev Base contract for Ether Dungeon. Holds all common structs, events and base variables.
 *  When Beta launches, DungeonCoreBeta contract will be deployed and DungeonCoreAlpha will be destroyed.
 *  Since all dungeons and heroes are stored as tokens in external contracts, they remains immutable.
 */
contract DungeonCoreAlpha is Destructible, DungeonTraining {

    /**
     * Initialize the DungeonCore(Alpha) contract with all the required contract addresses.
     */
    function DungeonCoreAlpha(
        address _dungeonTokenAddress,
        address _heroTokenAddress,
        address _challengeScienceAddress,
        address _trainingScienceAddress
    ) public payable {
        dungeonTokenContract = DungeonToken(_dungeonTokenAddress);
        heroTokenContract = HeroToken(_heroTokenAddress);
        challengeScienceContract = ChallengeScienceInterface(_challengeScienceAddress);
        trainingScienceContract = TrainingScienceInterface(_trainingScienceAddress);
    }

    /**
     * @dev The external function to get all the relevant information about a specific dungeon by its ID.
     * @param _id The ID of the dungeon.
     */
    function getDungeonDetails(uint _id) external view returns (uint creationTime, uint status, uint difficulty, uint floorNumber, uint floorCreationTime, uint rewards, uint seedGenes, uint floorGenes) {
        require(_id < dungeonTokenContract.totalSupply());

        (creationTime, status, difficulty, floorNumber, floorCreationTime, rewards, seedGenes, floorGenes) = dungeonTokenContract.dungeons(_id);
    }

    /**
     * @dev The external function to get all the relevant information about a specific hero by its ID.
     * @param _id The ID of the hero.
     */
    function getHeroDetails(uint _id) external view returns (uint creationTime, uint genes) {
        require(_id < heroTokenContract.totalSupply());

        (creationTime, genes) = heroTokenContract.heroes(_id);
    }

}
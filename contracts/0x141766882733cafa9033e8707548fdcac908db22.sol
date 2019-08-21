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
 * @dev Extension for the Ownable contract, where the owner can assign at most 2 other addresses
 *  to manage some functions of the contract, using the eitherOwner modifier.
 *  Note that onlyOwner modifier would still be accessible only for the original owner.
 */
contract JointOwnable is Ownable {

  event AnotherOwnerAssigned(address indexed anotherOwner);

  address public anotherOwner1;
  address public anotherOwner2;

  /**
   * @dev Throws if called by any account other than the owner or anotherOwner.
   */
  modifier eitherOwner() {
    require(msg.sender == owner || msg.sender == anotherOwner1 || msg.sender == anotherOwner2);
    _;
  }

  /**
   * @dev Allows the current owner to assign another owner.
   * @param _anotherOwner The address to another owner.
   */
  function assignAnotherOwner1(address _anotherOwner) onlyOwner public {
    require(_anotherOwner != 0);
    AnotherOwnerAssigned(_anotherOwner);
    anotherOwner1 = _anotherOwner;
  }

  /**
   * @dev Allows the current owner to assign another owner.
   * @param _anotherOwner The address to another owner.
   */
  function assignAnotherOwner2(address _anotherOwner) onlyOwner public {
    require(_anotherOwner != 0);
    AnotherOwnerAssigned(_anotherOwner);
    anotherOwner2 = _anotherOwner;
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

        // Each dungeon has an ID which is the index in the storage array.

        // The timestamp of the block when this dungeon is created.
        uint32 creationTime;

        // The status of the dungeon, each dungeon can have 5 status, namely:
        // 0: Active | 1: Transport Only | 2: Challenge Only | 3: Train Only | 4: InActive
        uint8 status;

        // The dungeon's difficulty, the higher the difficulty,
        // normally, the "rarer" the seedGenes, the higher the diffculty,
        // and the higher the contribution fee it is to challenge, train, and transport to the dungeon,
        // the formula for the contribution fee is in DungeonChallenge and DungeonTraining contracts.
        // A dungeon's difficulty never change.
        uint8 difficulty;

        // The dungeon's capacity, maximum number of players allowed to stay on this dungeon.
        // The capacity of the newbie dungeon (Holyland) is set at 0 (which is infinity).
        // Using 16-bit unsigned integers can have a maximum of 65535 in capacity.
        // A dungeon's capacity never change.
        uint16 capacity;

        // The current floor number, a dungeon is consists of an umlimited number of floors,
        // when there is heroes successfully challenged a floor, the next floor will be
        // automatically generated. Using 32-bit unsigned integer can have a maximum of 4 billion floors.
        uint32 floorNumber;

        // The timestamp of the block when the current floor is generated.
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

        // Each hero has an ID which is the index in the storage array.

        // The timestamp of the block when this dungeon is created.
        uint64 creationTime;

        // The timestamp of the block where a challenge is performed, used to calculate when a hero is allowed to engage in another challenge.
        uint64 cooldownStartTime;

        // Every time a hero challenge a dungeon, its cooldown index will be incremented by one.
        uint32 cooldownIndex;

        // The seed of the hero, the gene encodes the power level of the hero.
        // This is another top secret of the game! Hero's gene can be upgraded via
        // training in a dungeon.
        uint genes;

    }

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
    event Mint(address indexed owner, uint newTokenId, uint difficulty, uint capacity, uint seedGenes);

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
     * @dev Returns the total number of tokens currently in existence.
     */
    function totalSupply() public view returns (uint) {
        return dungeons.length;
    }

    /**
     * @dev Returns the number of tokens owned by a specific address.
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
     * @dev Returns the address currently assigned ownership of a given token.
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
                    fromTokens[i] = fromTokens[i + 1];
                }
            }

            fromTokens.length--;
        }

        // Emit the Transfer event.
        Transfer(_from, _to, _tokenId);
    }

    /**
     * @dev External function to transfers a token to another address.
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
     * @dev Get an array of IDs of each token that an user owns.
     */
    function getOwnerTokens(address _owner) external view returns(uint[]) {
        return ownerTokens[_owner];
    }

    /**
     * @dev The external function that creates a new dungeon and stores it, only contract owners
     *  can create new token, and will be restricted by the DUNGEON_CREATION_LIMIT.
     *  Will generate a Mint event, a  NewDungeonFloor event, and a Transfer event.
     * @param _difficulty The difficulty of the new dungeon.
     * @param _capacity The capacity of the new dungeon.
     * @param _seedGenes The seed genes of the new dungeon.
     * @param _firstFloorGenes The genes of the first dungeon floor.
     * @return The dungeon ID of the new dungeon.
     */
    function createDungeon(uint _difficulty, uint _capacity, uint _seedGenes, uint _firstFloorGenes, address _owner) eitherOwner external returns (uint) {
        // Ensure the total supply is within the fixed limit.
        require(totalSupply() < DUNGEON_CREATION_LIMIT);

        // UPDATE STORAGE
        // Create a new dungeon.
        dungeons.push(Dungeon(uint32(now), 0, uint8(_difficulty), uint16(_capacity), 0, 0, 0, _seedGenes, 0));

        // Token id is the index in the storage array.
        uint newTokenId = dungeons.length - 1;

        // Emit the token mint event.
        Mint(_owner, newTokenId, _difficulty, _capacity, _seedGenes);

        // Initialize the fist floor, this will emit the NewDungeonFloor event.
        addDungeonNewFloor(newTokenId, 0, _firstFloorGenes);

        // This will assign ownership, and also emit the Transfer event.
        _transfer(0, _owner, newTokenId);

        return newTokenId;
    }

    /**
     * @dev The external function to set dungeon status by its ID,
     *  refer to DungeonStructs for more information about dungeon status.
     *  Only contract owners can alter dungeon state.
     */
    function setDungeonStatus(uint _id, uint _newStatus) eitherOwner tokenExists(_id) external {
        dungeons[_id].status = uint8(_newStatus);
    }

    /**
     * @dev The external function to add additional dungeon rewards by its ID,
     *  only contract owners can alter dungeon state.
     */
    function addDungeonRewards(uint _id, uint _additinalRewards) eitherOwner tokenExists(_id) external {
        dungeons[_id].rewards += uint128(_additinalRewards);
    }

    /**
     * @dev The external function to add another dungeon floor by its ID,
     *  only contract owners can alter dungeon state.
     *  Will generate both a NewDungeonFloor event.
     */
    function addDungeonNewFloor(uint _id, uint _newRewards, uint _newFloorGenes) eitherOwner tokenExists(_id) public {
        Dungeon storage dungeon = dungeons[_id];

        dungeon.floorNumber++;
        dungeon.floorCreationTime = uint32(now);
        dungeon.rewards = uint128(_newRewards);
        dungeon.floorGenes = _newFloorGenes;

        // Emit the NewDungeonFloor event.
        NewDungeonFloor(now, _id, dungeon.floorNumber, dungeon.rewards, dungeon.floorGenes);
    }


    /* ======== MODIFIERS ======== */

    /**
     * @dev Throws if _dungeonId is not created yet.
     */
    modifier tokenExists(uint _tokenId) {
        require(_tokenId < totalSupply());
        _;
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
     * @dev Returns the total number of tokens currently in existence.
     */
    function totalSupply() public view returns (uint) {
        return heroes.length;
    }

    /**
     * @dev Returns the number of tokens owned by a specific address.
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
     * @dev Returns the address currently assigned ownership of a given token.
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
                    fromTokens[i] = fromTokens[i + 1];
                }
            }

            fromTokens.length--;
        }

        // Emit the Transfer event.
        Transfer(_from, _to, _tokenId);
    }

    /**
     * @dev External function to transfers a token to another address.
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
     * @dev Get an array of IDs of each token that an user owns.
     */
    function getOwnerTokens(address _owner) external view returns(uint[]) {
        return ownerTokens[_owner];
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
    function createHero(uint _genes, address _owner) eitherOwner external returns (uint) {
        // UPDATE STORAGE
        // Create a new hero.
        heroes.push(Hero(uint64(now), 0, 0, _genes));

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
    function setHeroGenes(uint _id, uint _newGenes) eitherOwner tokenExists(_id) external {
        heroes[_id].genes = _newGenes;
    }

    /**
     * @dev Set the cooldownStartTime for the given hero. Also increments the cooldownIndex.
     */
    function triggerCooldown(uint _id) eitherOwner tokenExists(_id) external {
        Hero storage hero = heroes[_id];

        hero.cooldownStartTime = uint64(now);
        hero.cooldownIndex++;
    }


    /* ======== MODIFIERS ======== */

    /**
     * @dev Throws if _dungeonId is not created yet.
     */
    modifier tokenExists(uint _tokenId) {
        require(_tokenId < totalSupply());
        _;
    }

}

/**
 * SECRET
 */
contract ChallengeScienceInterface {

    /**
     * @dev given genes of current floor and dungeon seed, return a genetic combination - may have a random factor.
     * @param _floorGenes Genes of floor.
     * @param _seedGenes Seed genes of dungeon.
     * @return The resulting genes.
     */
    function mixGenes(uint _floorGenes, uint _seedGenes) external returns (uint);

}

/**
 * SECRET
 */
contract TrainingScienceInterface {

    /**
     * @dev given genes of hero and current floor, return a genetic combination - may have a random factor.
     * @param _heroGenes Genes of hero.
     * @param _floorGenes Genes of current floor.
     * @param _equipmentId Equipment index to train for, 0 is train all attributes.
     * @return The resulting genes.
     */
    function mixGenes(uint _heroGenes, uint _floorGenes, uint _equipmentId) external returns (uint);

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


    /* ======== CONSTANTS ======== */

    uint16[32] EQUIPMENT_POWERS = [
        1, 2, 4, 5, 16, 17, 18, 19, 0, 0, 0, 0, 0, 0, 0, 0,
        4, 16, 32, 33, 0, 0, 0, 0, 32, 64, 0, 0, 128, 0, 0, 0
    ];

    uint SUPER_HERO_MULTIPLIER = 32;

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


    /* ======== HELPER FUNCTIONS ======== */

    /**
     * @dev An internal function to calculate the top 5 heroes power of a player.
     */
    function _getTop5HeroesPower(address _address, uint _dungeonId) internal view returns (uint) {
        uint heroCount = heroTokenContract.balanceOf(_address);

        if (heroCount == 0) {
            return 0;
        }

        // Compute all hero powers for further calculation.
        uint[] memory heroPowers = new uint[](heroCount);

        for (uint i = 0; i < heroCount; i++) {
            uint heroId = heroTokenContract.ownerTokens(_address, i);
            uint genes;
            (,,, genes) = heroTokenContract.heroes(heroId);
            // Power of dungeonId = 0 (no super hero boost).
            heroPowers[i] = _getHeroPower(genes, _dungeonId);
        }

        // Calculate the top 5 heroes power.
        uint result;
        uint curMax;
        uint curMaxIndex;

        for (uint j; j < 5; j++){
            for (uint k = 0; k < heroPowers.length; k++) {
                if (heroPowers[k] > curMax) {
                    curMax = heroPowers[k];
                    curMaxIndex = k;
                }
            }

            result += curMax;
            heroPowers[curMaxIndex] = 0;
            curMax = 0;
            curMaxIndex = 0;
        }

        return result;
    }

    /**
     * @dev An internal function to calculate the power of a hero,
     *  it calculates the base equipment power, stats power, and "Super" multiplier.
     */
    function _getHeroPower(uint _genes, uint _dungeonId) internal view returns (uint) {
        uint difficulty;
        (,, difficulty,,,,,,) = dungeonTokenContract.dungeons(_dungeonId);

        // Calculate total stats power.
        uint statsPower;

        for (uint i = 0; i < 4; i++) {
            statsPower += _genes % 32 + 1;
            _genes /= 32 ** 4;
        }

        // Calculate total equipment power.
        uint equipmentPower;
        uint superRank = _genes % 32;

        for (uint j = 4; j < 12; j++) {
            uint curGene = _genes % 32;
            equipmentPower += EQUIPMENT_POWERS[curGene];
            _genes /= 32 ** 4;

            if (superRank != curGene) {
                superRank = 0;
            }
        }

        // Calculate super power boost.
        bool isSuper = superRank >= 16;
        uint superBoost;

        if (isSuper) {
            superBoost = (difficulty - 1) * SUPER_HERO_MULTIPLIER;
        }

        return statsPower + equipmentPower + superBoost;
    }

    /**
     * @dev An internal function to calculate the difficulty of a dungeon floor.
     */
    function _getDungeonPower(uint _genes) internal view returns (uint) {
        // Calculate total dungeon power.
        uint dungeonPower;

        for (uint j = 0; j < 12; j++) {
            dungeonPower += EQUIPMENT_POWERS[_genes % 32];
            _genes /= 32 ** 4;
        }

        return dungeonPower;
    }

}

contract DungeonTransportation is DungeonBase {

    /**
     * @dev The PlayerTransported event is fired when user transported to another dungeon.
     */
    event PlayerTransported(uint timestamp, address indexed playerAddress, uint indexed originDungeonId, uint indexed destinationDungeonId);


    /* ======== GAME SETTINGS ======== */

    /**
     * @notice The actual fee contribution required to call transport() is calculated by this feeMultiplier,
     *  times the dungeon difficulty of destination dungeon. The payment is accumulated to the rewards of the origin dungeon,
     *  and a large proportion will be claimed by whoever successfully challenged the floor.
     *  1000 szabo = 0.001 ether
     */
    uint public transportationFeeMultiplier = 500 szabo;


    /* ======== STORAGE ======== */


    /**
     * @dev A mapping from token IDs to the address that owns them.
     */
    mapping(address => uint) public playerToDungeonID;

    /**
     * @dev A mapping from owner address to count of tokens that address owns.
     */
    mapping(uint => uint) public dungeonPlayerCount;

    /**
     * @dev The main external function to call when a player transport to another dungeon.
     *  Will generate a PlayerTransported event.
     */
    function transport(uint _destinationDungeonId) whenNotPaused dungeonCanTransport(_destinationDungeonId) external payable {
        uint originDungeonId = playerToDungeonID[msg.sender];

        // Disallow transport to the same dungeon.
        require(_destinationDungeonId != originDungeonId);

        // Get the dungeon details from the token contract.
        uint difficulty;
        uint capacity;
        (,, difficulty, capacity,,,,,) = dungeonTokenContract.dungeons(_destinationDungeonId);

        // Disallow weaker user to transport to "difficult" dungeon.
        uint top5HeroesPower = _getTop5HeroesPower(msg.sender, _destinationDungeonId);
        require(top5HeroesPower >= difficulty * 12);

        // Checks for payment, any exceeding funds will be transferred back to the player.
        uint baseFee = difficulty * transportationFeeMultiplier;
        uint additionalFee = top5HeroesPower / 48 * transportationFeeMultiplier;
        uint requiredFee = baseFee + additionalFee;
        require(msg.value >= requiredFee);

        // ** STORAGE UPDATE **
        // Increment the accumulated rewards for the dungeon.
        dungeonTokenContract.addDungeonRewards(originDungeonId, requiredFee);

        // Calculate any excess funds and make it available to be withdrawed by the player.
        asyncSend(msg.sender, msg.value - requiredFee);

        _transport(originDungeonId, _destinationDungeonId);
    }

    /**
     * Private function to assigns location of a player
     */
    function _transport(uint _originDungeonId, uint _destinationDungeonId) private {
        // If a player do not have any hero, claim first hero.
        if (heroTokenContract.balanceOf(msg.sender) == 0) {
            claimHero();
        }

        // ** STORAGE UPDATE **
        // Update the ownershipTokenCount.
        dungeonPlayerCount[_originDungeonId]--;
        dungeonPlayerCount[_destinationDungeonId]++;

        // ** STORAGE UPDATE **
        // Update player location.
        playerToDungeonID[msg.sender] = _destinationDungeonId;

        // Emit the DungeonChallenged event.
        PlayerTransported(now, msg.sender, _originDungeonId, _destinationDungeonId);
    }


    /* ======== OWNERSHIP FUNCTIONS ======== */

    /**
     * @notice Used in transport, challenge and train, to get the genes of a specific hero,
     *  a claim a hero if didn't have any.
     */
    function _getHeroGenesOrClaimFirstHero(uint _heroId) internal returns (uint heroId, uint heroGenes) {
        heroId = _heroId;

        // If a player do not have any hero, claim first hero first.
        if (heroTokenContract.balanceOf(msg.sender) == 0) {
            heroId = claimHero();
        }

        (,,,heroGenes) = heroTokenContract.heroes(heroId);
    }

    /**
     * @dev Claim a new hero with empty genes.
     */
    function claimHero() public returns (uint) {
        // If a player do not tranport to any dungeon yet, and it is the first time claiming the hero,
        // set the dungeon location, increment the #0 Holyland player count by 1.
        if (playerToDungeonID[msg.sender] == 0 && heroTokenContract.balanceOf(msg.sender) == 0) {
            dungeonPlayerCount[0]++;
        }

        return heroTokenContract.createHero(0, msg.sender);
    }


    /* ======== SETTER FUNCTIONS ======== */

    /**
     * @dev Updates the fee contribution multiplier required for calling transport().
     */
    function setTransportationFeeMultiplier(uint _newTransportationFeeMultiplier) onlyOwner external {
        transportationFeeMultiplier = _newTransportationFeeMultiplier;
    }


    /* ======== MODIFIERS ======== */

    /**
     * @dev Throws if dungeon status do not allow transportation, also check for dungeon existence.
     *  Also check if the capacity of the destination dungeon is reached.
     */
    modifier dungeonCanTransport(uint _destinationDungeonId) {
        require(_destinationDungeonId < dungeonTokenContract.totalSupply());
        uint status;
        uint capacity;
        (,status,,capacity,,,,,) = dungeonTokenContract.dungeons(_destinationDungeonId);
        require(status == 0 || status == 1);

        // Check if the capacity of the destination dungeon is reached.
        // Capacity 0 = Infinity
        require(capacity == 0 || dungeonPlayerCount[_destinationDungeonId] < capacity);
        _;
    }

}

contract DungeonChallenge is DungeonTransportation {

    /**
     * @dev The DungeonChallenged event is fired when user finished a dungeon challenge.
     */
    event DungeonChallenged(uint timestamp, address indexed playerAddress, uint indexed dungeonId, uint indexed heroId, uint heroGenes, uint floorNumber, uint floorGenes, bool success, uint newFloorGenes, uint successRewards, uint masterRewards);


    /* ======== GAME SETTINGS ======== */

    /**
     * @notice The actual fee contribution required to call challenge() is calculated by this feeMultiplier,
     *  times the dungeon difficulty. The payment is accumulated to the dungeon rewards,
     *  and a large proportion will be claimed by whoever successfully challenged the floor.
     *  1 finney = 0.001 ether
     */
    uint public challengeFeeMultiplier = 1 finney;

    /**
     * @dev The percentage for which successful challenger be rewarded of the dungeons' accumulated rewards.
     *  The remaining rewards subtract dungeon master rewards will be used as the base rewards for new floor.
     */
    uint public challengeRewardsPercent = 64;

    /**
     * @dev The developer fee for owner
     *  Note that when Ether Dungeon becomes truly decentralised, contract ownership will be ejected,
     *  and the master rewards will be rewarded to the dungeon owner (Dungeon Masters).
     */
    uint public masterRewardsPercent = 8;

    /**
     * @dev The cooldown time period where a hero can engage in challenge again.
     *  This settings will likely be changed to 20 minutes when multiple heroes system is launched in Version 1.
     */
    uint public challengeCooldownTime = 3 minutes;

    /**
     * @dev The preparation time period where a new dungeon is created, before it can be challenged.
     *  This settings will likely be changed to a smaller period (e.g. 20-30 minutes) .
     */
    uint public dungeonPreparationTime = 60 minutes;

    /**
     * @dev The challenge rewards percentage used right after the preparation period.
     */
    uint public rushTimeChallengeRewardsPercent = 30;

    /**
     * @dev The number of floor in which the rushTimeChallengeRewardsPercent be applied.
     */
    uint public rushTimeFloorCount = 30;

    /**
     * @dev The main external function to call when a player challenge a dungeon,
     *  it determines whether if the player successfully challenged the current floor.
     *  Will generate a DungeonChallenged event.
     */
    function challenge(uint _dungeonId, uint _heroId) whenNotPaused dungeonCanChallenge(_dungeonId) heroAllowedToChallenge(_heroId) external payable {
        // Get the dungeon details from the token contract.
        uint difficulty;
        uint seedGenes;
        (,, difficulty,,,,, seedGenes,) = dungeonTokenContract.dungeons(_dungeonId);

        // Checks for payment, any exceeding funds will be transferred back to the player.
        uint requiredFee = difficulty * challengeFeeMultiplier;
        require(msg.value >= requiredFee);

        // ** STORAGE UPDATE **
        // Increment the accumulated rewards for the dungeon.
        dungeonTokenContract.addDungeonRewards(_dungeonId, requiredFee);

        // Calculate any excess funds and make it available to be withdrawed by the player.
        asyncSend(msg.sender, msg.value - requiredFee);

        // Split the challenge function into multiple parts because of stack too deep error.
        _challengePart2(_dungeonId, _heroId);
    }

    /**
     * Split the challenge function into multiple parts because of stack too deep error.
     */
    function _challengePart2(uint _dungeonId, uint _heroId) private {
        uint floorNumber;
        uint rewards;
        uint floorGenes;
        (,,,, floorNumber,, rewards,, floorGenes) = dungeonTokenContract.dungeons(_dungeonId);

        // Get the hero gene, or claim first hero.
        uint heroGenes;
        (_heroId, heroGenes) = _getHeroGenesOrClaimFirstHero(_heroId);

        bool success = _getChallengeSuccess(heroGenes, _dungeonId, floorGenes);

        uint newFloorGenes;
        uint masterRewards;
        uint successRewards;
        uint newRewards;

        // Whether a challenge is success or not is determined by a simple comparison between hero power and floor power.
        if (success) {
            newFloorGenes = _getNewFloorGene(_dungeonId);

            masterRewards = rewards * masterRewardsPercent / 100;

            if (floorNumber < rushTimeFloorCount) { // rush time right after prepration period
                successRewards = rewards * rushTimeChallengeRewardsPercent / 100;

                // The dungeon rewards for new floor as total rewards - challenge rewards - devleoper fee.
                newRewards = rewards * (100 - rushTimeChallengeRewardsPercent - masterRewardsPercent) / 100;
            } else {
                successRewards = rewards * challengeRewardsPercent / 100;
                newRewards = rewards * (100 - challengeRewardsPercent - masterRewardsPercent) / 100;
            }

            // TRIPLE CONFIRM sanity check.
            require(successRewards + masterRewards + newRewards <= rewards);

            // ** STORAGE UPDATE **
            // Add new floor with the new floor genes and new rewards.
            dungeonTokenContract.addDungeonNewFloor(_dungeonId, newRewards, newFloorGenes);

            // Mark the challenge rewards available to be withdrawed by the player.
            asyncSend(msg.sender, successRewards);

            // Mark the master rewards available to be withdrawed by the dungeon master.
            asyncSend(dungeonTokenContract.ownerOf(_dungeonId), masterRewards);
        }

        // ** STORAGE UPDATE **
        // Trigger the cooldown for the hero.
        heroTokenContract.triggerCooldown(_heroId);

        // Emit the DungeonChallenged event.
        DungeonChallenged(now, msg.sender, _dungeonId, _heroId, heroGenes, floorNumber, floorGenes, success, newFloorGenes, successRewards, masterRewards);
    }

    /**
     * Split the challenge function into multiple parts because of stack too deep error.
     */
    function _getChallengeSuccess(uint _heroGenes, uint _dungeonId, uint _floorGenes) private view returns (bool) {
        // Determine if the player challenge successfuly the dungeon or not.
        uint heroPower = _getHeroPower(_heroGenes, _dungeonId);
        uint floorPower = _getDungeonPower(_floorGenes);

        return heroPower > floorPower;
    }

    /**
     * Split the challenge function into multiple parts because of stack too deep error.
     */
    function _getNewFloorGene(uint _dungeonId) private returns (uint) {
        uint seedGenes;
        uint floorGenes;
        (,,,,,, seedGenes, floorGenes) = dungeonTokenContract.dungeons(_dungeonId);

        // Calculate the new floor gene.
        uint floorPower = _getDungeonPower(floorGenes);

        // Call the external closed source secret function that determines the resulting floor "genes".
        uint newFloorGenes = challengeScienceContract.mixGenes(floorGenes, seedGenes);

        uint newFloorPower = _getDungeonPower(newFloorGenes);

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
    function setChallengeFeeMultiplier(uint _newChallengeFeeMultiplier) onlyOwner external {
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

    /**
     * @dev Updates the challenge cooldown time.
     */
    function setChallengeCooldownTime(uint _newChallengeCooldownTime) onlyOwner external {
        challengeCooldownTime = _newChallengeCooldownTime;
    }

    /**
     * @dev Updates the challenge cooldown time.
     */
    function setDungeonPreparationTime(uint _newDungeonPreparationTime) onlyOwner external {
        dungeonPreparationTime = _newDungeonPreparationTime;
    }

    /**
     * @dev Updates the rush time challenge rewards percentage.
     */
    function setRushTimeChallengeRewardsPercent(uint _newRushTimeChallengeRewardsPercent) onlyOwner external {
        rushTimeChallengeRewardsPercent = _newRushTimeChallengeRewardsPercent;
    }

    /**
     * @dev Updates the rush time floor count.
     */
    function setRushTimeFloorCount(uint _newRushTimeFloorCount) onlyOwner external {
        rushTimeFloorCount = _newRushTimeFloorCount;
    }


    /* ======== MODIFIERS ======== */

    /**
     * @dev Throws if dungeon status do not allow challenge, also check for dungeon existence.
     *  Also check if the user is in the dungeon.
     *  Also check if the dungeon is not in preparation period.
     */
    modifier dungeonCanChallenge(uint _dungeonId) {
        require(_dungeonId < dungeonTokenContract.totalSupply());
        uint creationTime;
        uint status;
        (creationTime, status,,,,,,,) = dungeonTokenContract.dungeons(_dungeonId);
        require(status == 0 || status == 2);

        // Check if the user is in the dungeon.
        require(playerToDungeonID[msg.sender] == _dungeonId);

        // Check if the dungeon is not in preparation period.
        require(creationTime + dungeonPreparationTime <= now);
        _;
    }

    /**
     * @dev Throws if player does not own the hero, or it is still in cooldown.
     *  Unless the player does not have any hero yet, which will auto claim one during first challenge / train.
     */
    modifier heroAllowedToChallenge(uint _heroId) {
        if (heroTokenContract.balanceOf(msg.sender) > 0) {
            // You can only challenge with your own hero.
            require(heroTokenContract.ownerOf(_heroId) == msg.sender);

            uint cooldownStartTime;
            (, cooldownStartTime,,) = heroTokenContract.heroes(_heroId);
            require(cooldownStartTime + challengeCooldownTime <= now);
        }
        _;
    }

}

contract DungeonTraining is DungeonChallenge {

    /**
     * @dev The HeroTrained event is fired when user finished a training.
     */
    event HeroTrained(uint timestamp, address indexed playerAddress, uint indexed dungeonId, uint indexed heroId, uint heroGenes, uint floorNumber, uint floorGenes, bool success, uint newHeroGenes);


    /* ======== GAME SETTINGS ======== */

    /**
     * @dev The actual fee contribution required to call trainX() is calculated by this feeMultiplier,
     *  times the dungeon difficulty, times X. The payment is accumulated to the dungeon rewards,
     *  and a large proportion will be claimed by whoever successfully challenged the floor.
     *  1 finney = 0.001 ether
     */
    uint public trainingFeeMultiplier = 2 finney;

    /**
     * @dev The discounted training fee multiplier to be used in the preparation period.
     * 1000 szabo = 0.001 ether
     */
    uint public preparationPeriodTrainingFeeMultiplier = 1800 szabo;

    /**
     * @dev The actual fee contribution required to call trainEquipment() is calculated by this feeMultiplier,
     *  times the dungeon difficulty, times X. The payment is accumulated to the dungeon rewards,
     *  and a large proportion will be claimed by whoever successfully challenged the floor.
     *  (No preparation period discount on equipment training.)
     *  1000 szabo = 0.001 ether
     */
    uint public equipmentTrainingFeeMultiplier = 500 szabo;

    /**
     * @dev The external function to call when a hero train with a dungeon,
     *  it determines whether whether a training is successfully, and the resulting genes.
     *  Will generate a DungeonChallenged event.
     */
    function train1(uint _dungeonId, uint _heroId) whenNotPaused dungeonCanTrain(_dungeonId) heroAllowedToTrain(_heroId) external payable {
        _train(_dungeonId, _heroId, 0, 1);
    }

    function train2(uint _dungeonId, uint _heroId) whenNotPaused dungeonCanTrain(_dungeonId) heroAllowedToTrain(_heroId) external payable {
        _train(_dungeonId, _heroId, 0, 2);
    }

    function train3(uint _dungeonId, uint _heroId) whenNotPaused dungeonCanTrain(_dungeonId) heroAllowedToTrain(_heroId) external payable {
        _train(_dungeonId, _heroId, 0, 3);
    }

    /**
     * @dev The external function to call when a hero train a particular equipment with a dungeon,
     *  it determines whether whether a training is successfully, and the resulting genes.
     *  Will generate a DungeonChallenged event.
     *  _equipmentIndex is the index of equipment: 0 is train all attributes, including equipments and stats.
     *  1: weapon | 2: shield | 3: armor | 4: shoe | 5: helmet | 6: gloves | 7: belt | 8: shawl
     */
    function trainEquipment(uint _dungeonId, uint _heroId, uint _equipmentIndex) whenNotPaused dungeonCanTrain(_dungeonId) heroAllowedToTrain(_heroId) external payable {
        require(_equipmentIndex <= 8);

        _train(_dungeonId, _heroId, _equipmentIndex, 1);
    }

    /**
     * @dev An internal function of a hero train with dungeon,
     *  it determines whether whether a training is successfully, and the resulting genes.
     *  Will generate a DungeonChallenged event.
     */
    function _train(uint _dungeonId, uint _heroId, uint _equipmentIndex, uint _trainingTimes) private {
        // Get the dungeon details from the token contract.
        uint creationTime;
        uint difficulty;
        uint floorNumber;
        uint rewards;
        uint seedGenes;
        uint floorGenes;
        (creationTime,,difficulty,,floorNumber,,rewards,seedGenes,floorGenes) = dungeonTokenContract.dungeons(_dungeonId);

        // Check for _trainingTimes abnormality, we probably won't have any feature that train a hero 10 times with a single call.
        require(_trainingTimes < 10);

        // Checks for payment, any exceeding funds will be transferred back to the player.
        uint requiredFee;

        if (_equipmentIndex > 0) { // train specific equipments
            requiredFee = difficulty * equipmentTrainingFeeMultiplier * _trainingTimes;
        } else if (now < creationTime + dungeonPreparationTime) { // train all attributes, preparation period
            requiredFee = difficulty * preparationPeriodTrainingFeeMultiplier * _trainingTimes;
        } else { // train all attributes, normal period
            requiredFee = difficulty * trainingFeeMultiplier * _trainingTimes;
        }

        require(msg.value >= requiredFee);

        // Get the hero gene, or claim first hero.
        uint heroGenes;
        (_heroId, heroGenes) = _getHeroGenesOrClaimFirstHero(_heroId);

        // ** STORAGE UPDATE **
        // Increment the accumulated rewards for the dungeon.
        dungeonTokenContract.addDungeonRewards(_dungeonId, requiredFee);

        // Calculate any excess funds and make it available to be withdrawed by the player.
        asyncSend(msg.sender, msg.value - requiredFee);

        // Split the _train function into multiple parts because of stack too deep error.
        _trainPart2(_dungeonId, _heroId, heroGenes, _equipmentIndex, _trainingTimes);
    }

    /**
     * Split the _train function into multiple parts because of Stack Too Deep error.
     */
    function _trainPart2(uint _dungeonId, uint _heroId, uint _heroGenes, uint _equipmentIndex, uint _trainingTimes) private {
        // Get the dungeon details from the token contract.
        uint floorNumber;
        uint floorGenes;
        (,,,, floorNumber,,,, floorGenes) = dungeonTokenContract.dungeons(_dungeonId);

        // Determine if the hero training is successful or not, and the resulting genes.
        uint heroPower = _getHeroPower(_heroGenes, _dungeonId);

        uint newHeroGenes = _heroGenes;
        uint newHeroPower = heroPower;

        // Train the hero multiple times according to _trainingTimes,
        // each time if the resulting power is larger, update new hero power.
        for (uint i = 0; i < _trainingTimes; i++) {
            // Call the external closed source secret function that determines the resulting hero "genes".
            uint tmpHeroGenes = trainingScienceContract.mixGenes(newHeroGenes, floorGenes, _equipmentIndex);

            uint tmpHeroPower = _getHeroPower(tmpHeroGenes, _dungeonId);

            if (tmpHeroPower > newHeroPower) {
                newHeroGenes = tmpHeroGenes;
                newHeroPower = tmpHeroPower;
            }
        }

        // Prevent reduced power.
        if (newHeroPower > heroPower) {
            // ** STORAGE UPDATE **
            // Set the upgraded hero genes.
            heroTokenContract.setHeroGenes(_heroId, newHeroGenes);
        }

        // Emit the HeroTrained event.
        HeroTrained(now, msg.sender, _dungeonId, _heroId, _heroGenes, floorNumber, floorGenes, newHeroPower > heroPower, newHeroGenes);
    }


    /* ======== SETTER FUNCTIONS ======== */

    /// @dev Updates the fee contribution multiplier required for calling trainX().
    function setTrainingFeeMultiplier(uint _newTrainingFeeMultiplier) onlyOwner external {
        trainingFeeMultiplier = _newTrainingFeeMultiplier;
    }

    /// @dev Updates the fee contribution multiplier for preparation period required for calling trainX().
    function setPreparationPeriodTrainingFeeMultiplier(uint _newPreparationPeriodTrainingFeeMultiplier) onlyOwner external {
        preparationPeriodTrainingFeeMultiplier = _newPreparationPeriodTrainingFeeMultiplier;
    }

    /// @dev Updates the fee contribution multiplier required for calling trainEquipment().
    function setEquipmentTrainingFeeMultiplier(uint _newEquipmentTrainingFeeMultiplier) onlyOwner external {
        equipmentTrainingFeeMultiplier = _newEquipmentTrainingFeeMultiplier;
    }


    /* ======== MODIFIERS ======== */

    /**
     * @dev Throws if dungeon status do not allow training, also check for dungeon existence.
     *  Also check if the user is in the dungeon.
     */
    modifier dungeonCanTrain(uint _dungeonId) {
        require(_dungeonId < dungeonTokenContract.totalSupply());
        uint status;
        (,status,,,,,,,) = dungeonTokenContract.dungeons(_dungeonId);
        require(status == 0 || status == 3);

        // Also check if the user is in the dungeon.
        require(playerToDungeonID[msg.sender] == _dungeonId);
        _;
    }

    /**
     * @dev Throws if player does not own the hero.
     *  Unless the player does not have any hero yet, which will auto claim one during first challenge / train.
     */
    modifier heroAllowedToTrain(uint _heroId) {
        if (heroTokenContract.balanceOf(msg.sender) > 0) {
            // You can only train with your own hero.
            require(heroTokenContract.ownerOf(_heroId) == msg.sender);
        }
        _;
    }


}

/**
 * @title DungeonCoreBeta
 * @dev Core Contract of Ether Dungeon.
 *  When Version 1 launches, DungeonCoreVersion1 contract will be deployed and DungeonCoreBeta will be destroyed.
 *  Since all dungeons and heroes are stored as tokens in external contracts, they remains immutable.
 */
contract DungeonCoreBeta is Destructible, DungeonTraining {

    /**
     * Initialize the DungeonCore contract with all the required contract addresses.
     */
    function DungeonCoreBeta(
        address _dungeonTokenAddress,
        address _heroTokenAddress,
        address _challengeScienceAddress,
        address _trainingScienceAddress
    ) public {
        dungeonTokenContract = DungeonToken(_dungeonTokenAddress);
        heroTokenContract = HeroToken(_heroTokenAddress);
        challengeScienceContract = ChallengeScienceInterface(_challengeScienceAddress);
        trainingScienceContract = TrainingScienceInterface(_trainingScienceAddress);
    }

    /**
     * @dev The external function to get all the relevant information about a specific dungeon by its ID.
     * @param _id The ID of the dungeon.
     */
    function getDungeonDetails(uint _id) external view returns (uint creationTime, uint status, uint difficulty, uint capacity, bool isReady, uint playerCount) {
        require(_id < dungeonTokenContract.totalSupply());

        // Didn't get the "floorCreationTime" because of Stack Too Deep error.
        (creationTime, status, difficulty, capacity,,,,,) = dungeonTokenContract.dungeons(_id);

        // Dungeon is ready to be challenged (not in preparation mode).
        isReady = creationTime + dungeonPreparationTime <= now;
        playerCount = dungeonPlayerCount[_id];
    }

    /**
     * @dev Split floor related details out of getDungeonDetails, just to avoid Stack Too Deep error.
     * @param _id The ID of the dungeon.
     */
    function getDungeonFloorDetails(uint _id) external view returns (uint floorNumber, uint floorCreationTime, uint rewards, uint seedGenes, uint floorGenes) {
        require(_id < dungeonTokenContract.totalSupply());

        // Didn't get the "floorCreationTime" because of Stack Too Deep error.
        (,,,, floorNumber, floorCreationTime, rewards, seedGenes, floorGenes) = dungeonTokenContract.dungeons(_id);
    }

    /**
     * @dev The external function to get all the relevant information about a specific hero by its ID.
     * @param _id The ID of the hero.
     */
    function getHeroDetails(uint _id) external view returns (uint creationTime, uint cooldownStartTime, uint cooldownIndex, uint genes, bool isReady) {
        require(_id < heroTokenContract.totalSupply());

        (creationTime, cooldownStartTime, cooldownIndex, genes) = heroTokenContract.heroes(_id);

        // Hero is ready to challenge (not in cooldown mode).
        isReady = cooldownStartTime + challengeCooldownTime <= now;
    }

    /**
     * @dev The external function to get all the relevant information about a specific player by its address.
     * @param _address The address of the player.
     */
    function getPlayerDetails(address _address) external view returns (uint dungeonId, uint payment) {
        dungeonId = playerToDungeonID[_address];
        payment = payments[_address];
    }

}
pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/IEntityStorage.sol

interface IEntityStorage {
    function storeBulk(uint256[] _tokenIds, uint256[] _attributes) external;
    function store(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external;
    function remove(uint256 _tokenId) external;
    function list() external view returns (uint256[] tokenIds);
    function getAttributes(uint256 _tokenId) external view returns (uint256 attrs, uint256[] compIds);
    function updateAttributes(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external;
    function totalSupply() external view returns (uint256);
}

// File: contracts/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public newOwner;
    
    // mapping for creature Type to Sale
    address[] internal controllers;
    //mapping(address => address) internal controllers;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
    constructor() public {
        owner = msg.sender;
    }
   
    /**
    * @dev Throws if called by any account that's not a superuser.
    */
    modifier onlyController() {
        require(isController(msg.sender), "only Controller");
        _;
    }

    modifier onlyOwnerOrController() {
        require(msg.sender == owner || isController(msg.sender), "only Owner Or Controller");
        _;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "sender address must be the owner's address");
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(address(0) != _newOwner, "new owner address must not be the owner's address");
        newOwner = _newOwner;
    }

    /**
    * @dev Allows the new owner to confirm that they are taking control of the contract..tr
    */
    function acceptOwnership() public {
        require(msg.sender == newOwner, "sender address must not be the new owner's address");
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
        newOwner = address(0);
    }

    function isController(address _controller) internal view returns(bool) {
        for (uint8 index = 0; index < controllers.length; index++) {
            if (controllers[index] == _controller) {
                return true;
            }
        }
        return false;
    }

    function getControllers() public onlyOwner view returns(address[]) {
        return controllers;
    }

    /**
    * @dev Allows a new controllers to be added
    * @param _controller The address controller.
    */
    function addController(address _controller) public onlyOwner {
        require(address(0) != _controller, "controller address must not be 0");
        require(_controller != owner, "controller address must not be the owner's address");
        for (uint8 index = 0; index < controllers.length; index++) {
            if (controllers[index] == _controller) {
                return;
            }
        }
        controllers.push(_controller);
    }

    /**
    * @dev Allows a new controllers to be added
    * @param _controller The address controller.
    */
    function removeController(address _controller) public onlyOwner {
        require(address(0) != _controller, "controller address must not be 0");
        for (uint8 index = 0; index < controllers.length; index++) {
            if (controllers[index] == _controller) {
                delete controllers[index];
            }
        }
    }
}

// File: contracts/CBCreatureStorage.sol

/**
* @title CBCreatureStorage
* @dev Composable storage contract for recording attribute data and attached components for a CryptoBeasties card. 
* CryptoBeasties content and source code is Copyright (C) 2018 PlayStakes LLC, All rights reserved.
*/
contract CBCreatureStorage is Ownable, IEntityStorage { 
    using SafeMath for uint256;  

    struct Token {
        uint256 tokenId;
        uint256 attributes;
        uint256[] componentIds;
        uint index;
    }

    // Array with all Tokens, used for enumeration
    uint256[] internal allTokens;

    // Maps token ids to data
    mapping(uint256 => Token) internal tokens;

    event Stored(uint256 tokenId, uint256 attributes, uint256[] componentIds);
    event Removed(uint256 tokenId);

    /**
    * @dev Constructor function
    */
    constructor() public {
    }

    /**
    * @dev Returns whether the specified token exists
    * @param _tokenId uint256 ID of the token to query the existence of
    * @return whether the token exists
    */
    function exists(uint256 _tokenId) public view returns (bool) {
        return tokens[_tokenId].tokenId == _tokenId;
    }

    /**
    * @dev Bulk Load of Tokens
    * @param _tokenIds Array of tokenIds
    * @param _attributes Array of packed attributes value
    */
    function storeBulk(uint256[] _tokenIds, uint256[] _attributes) external onlyOwnerOrController {
        uint256[] memory _componentIds;
        uint startIndex = allTokens.length;
        for (uint index = 0; index < _tokenIds.length; index++) {
            require(!this.exists(_tokenIds[index]));
            allTokens.push(_tokenIds[index]);
            tokens[_tokenIds[index]] = Token(_tokenIds[index], _attributes[index], _componentIds, startIndex + index);
            emit Stored(_tokenIds[index], _attributes[index], _componentIds);
        }
    }
    
    /**
    * @dev Create a new CryptoBeasties Token
    * @param _tokenId ID of the token
    * @param _attributes Packed attributes value
    * @param _componentIds Array of CryptoBeasties componentIds (i.e. PowerStones)
    */
    function store(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external onlyOwnerOrController {
        require(!this.exists(_tokenId));
        allTokens.push(_tokenId);
        tokens[_tokenId] = Token(_tokenId, _attributes, _componentIds, allTokens.length - 1);
        emit Stored(_tokenId, _attributes, _componentIds);
    }

    /**
    * @dev Remove a CryptoBeasties Token from storage
    * @param _tokenId ID of the token
    */
    function remove(uint256 _tokenId) external onlyOwnerOrController {
        require(_tokenId > 0);
        require(exists(_tokenId));
        
        uint doomedTokenIndex = tokens[_tokenId].index;
        
        delete tokens[_tokenId];

        // Reorg allTokens array
        uint lastTokenIndex = allTokens.length.sub(1);
        uint256 lastTokenId = allTokens[lastTokenIndex];

        // update the moved token's index
        tokens[lastTokenId].index = doomedTokenIndex;
        
        allTokens[doomedTokenIndex] = lastTokenId;
        allTokens[lastTokenIndex] = 0;

        allTokens.length--;
        emit Removed(_tokenId);
    }

    /**
    * @dev List all CryptoBeasties Tokens in storage
    */
    function list() external view returns (uint256[] tokenIds) {
        return allTokens;
    }

    /**
    * @dev Gets attributes and componentIds (i.e. PowerStones) for a CryptoBeastie
    * @param _tokenId uint256 for the given token
    */
    function getAttributes(uint256 _tokenId) external view returns (uint256 attrs, uint256[] compIds) {
        require(exists(_tokenId));
        return (tokens[_tokenId].attributes, tokens[_tokenId].componentIds);
    }

    /**
    * @dev Update CryptoBeasties attributes and Component Ids (i.e. PowerStones) CryptoBeastie
    * @param _tokenId uint256 ID of the token to update
    * @param _attributes Packed attributes value
    * @param _componentIds Array of CryptoBeasties componentIds (i.e. PowerStones)
    */
    function updateAttributes(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external onlyOwnerOrController {
        require(exists(_tokenId));
        require(_attributes > 0);
        tokens[_tokenId].attributes = _attributes;
        tokens[_tokenId].componentIds = _componentIds;
        emit Stored(_tokenId, _attributes, _componentIds);
    }

    /**
    * @dev Get the total number of tokens in storage
    */
    function totalSupply() external view returns (uint256) {
        return allTokens.length;
    }

}
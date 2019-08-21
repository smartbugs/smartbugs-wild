pragma solidity ^0.4.24;



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

library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

/**
 * Strings Library
 * 
 * In summary this is a simple library of string functions which make simple 
 * string operations less tedious in solidity.
 * 
 * Please be aware these functions can be quite gas heavy so use them only when
 * necessary not to clog the blockchain with expensive transactions.
 * 
 * @author James Lockhart <james@n3tw0rk.co.uk>
 */
library Strings {

    /**
     * Concat (High gas cost)
     * 
     * Appends two strings together and returns a new value
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string which will be the concatenated
     *              prefix
     * @param _value The value to be the concatenated suffix
     * @return string The resulting string from combinging the base and value
     */
    function concat(string _base, string _value)
        internal
        returns (string) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length > 0);

        string memory _tmpValue = new string(_baseBytes.length + 
            _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i = 0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function indexOf(string _base, string _value)
        internal
        returns (int) {
        return _indexOf(_base, _value, 0);
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string starting
     * from a defined offset
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @param _offset The starting point to start searching from which can start
     *                from 0, but must not exceed the length of the string
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function _indexOf(string _base, string _value, uint _offset)
        internal
        returns (int) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for(uint i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int(i);
            }
        }

        return -1;
    }

    /**
     * Length
     * 
     * Returns the length of the specified string
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string to be measured
     * @return uint The length of the passed string
     */
    function length(string _base)
        internal
        returns (uint) {
        bytes memory _baseBytes = bytes(_base);
        return _baseBytes.length;
    }

    /**
     * Sub String
     * 
     * Extracts the beginning part of a string based on the desired length
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string that will be used for 
     *              extracting the sub string from
     * @param _length The length of the sub string to be extracted from the base
     * @return string The extracted sub string
     */
    function substring(string _base, int _length)
        internal
        returns (string) {
        return _substring(_base, _length, 0);
    }

    /**
     * Sub String
     * 
     * Extracts the part of a string based on the desired length and offset. The
     * offset and length must not exceed the lenth of the base string.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string that will be used for 
     *              extracting the sub string from
     * @param _length The length of the sub string to be extracted from the base
     * @param _offset The starting point to extract the sub string from
     * @return string The extracted sub string
     */
    function _substring(string _base, int _length, int _offset)
        internal
        returns (string) {
        bytes memory _baseBytes = bytes(_base);

        assert(uint(_offset+_length) <= _baseBytes.length);

        string memory _tmp = new string(uint(_length));
        bytes memory _tmpBytes = bytes(_tmp);

        uint j = 0;
        for(uint i = uint(_offset); i < uint(_offset+_length); i++) {
          _tmpBytes[j++] = _baseBytes[i];
        }

        return string(_tmpBytes);
    }

    /**
     * String Split (Very high gas cost)
     *
     * Splits a string into an array of strings based off the delimiter value.
     * Please note this can be quite a gas expensive function due to the use of
     * storage so only use if really required.
     *
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string value to be split.
     * @param _value The delimiter to split the string on which must be a single
     *               character
     * @return string[] An array of values split based off the delimiter, but
     *                  do not container the delimiter.
     */
    function split(string _base, string _value)
        internal
        returns (string[] storage splitArr) {
        bytes memory _baseBytes = bytes(_base);
        uint _offset = 0;

        while(_offset < _baseBytes.length-1) {

            int _limit = _indexOf(_base, _value, _offset);
            if (_limit == -1) {
                _limit = int(_baseBytes.length);
            }

            string memory _tmp = new string(uint(_limit)-_offset);
            bytes memory _tmpBytes = bytes(_tmp);

            uint j = 0;
            for(uint i = _offset; i < uint(_limit); i++) {
                _tmpBytes[j++] = _baseBytes[i];
            }
            _offset = uint(_limit) + 1;
            splitArr.push(string(_tmpBytes));
        }
        return splitArr;
    }

    /**
     * Compare To
     * 
     * Compares the characters of two strings, to ensure that they have an 
     * identical footprint
     * 
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string base to compare against
     * @param _value The string the base is being compared to
     * @return bool Simply notates if the two string have an equivalent
     */
    function compareTo(string _base, string _value) 
        internal 
        returns (bool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        if (_baseBytes.length != _valueBytes.length) {
            return false;
        }

        for(uint i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] != _valueBytes[i]) {
                return false;
            }
        }

        return true;
    }

    /**
     * Compare To Ignore Case (High gas cost)
     * 
     * Compares the characters of two strings, converting them to the same case
     * where applicable to alphabetic characters to distinguish if the values
     * match.
     * 
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string base to compare against
     * @param _value The string the base is being compared to
     * @return bool Simply notates if the two string have an equivalent value
     *              discarding case
     */
    function compareToIgnoreCase(string _base, string _value)
        internal
        returns (bool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        if (_baseBytes.length != _valueBytes.length) {
            return false;
        }

        for(uint i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] != _valueBytes[i] && 
                _upper(_baseBytes[i]) != _upper(_valueBytes[i])) {
                return false;
            }
        }

        return true;
    }

    /**
     * Upper
     * 
     * Converts all the values of a string to their corresponding upper case
     * value.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string base to convert to upper case
     * @return string 
     */
    function upper(string _base) 
        internal 
        returns (string) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _upper(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    /**
     * Lower
     * 
     * Converts all the values of a string to their corresponding lower case
     * value.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string base to convert to lower case
     * @return string 
     */
    function lower(string _base) 
        internal 
        returns (string) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    /**
     * Upper
     * 
     * Convert an alphabetic character to upper case and return the original
     * value when not alphabetic
     * 
     * @param _b1 The byte to be converted to upper case
     * @return bytes1 The converted value if the passed value was alphabetic
     *                and in a lower case otherwise returns the original value
     */
    function _upper(bytes1 _b1)
        private
        constant
        returns (bytes1) {

        if (_b1 >= 0x61 && _b1 <= 0x7A) {
            return bytes1(uint8(_b1)-32);
        }

        return _b1;
    }

    /**
     * Lower
     * 
     * Convert an alphabetic character to lower case and return the original
     * value when not alphabetic
     * 
     * @param _b1 The byte to be converted to lower case
     * @return bytes1 The converted value if the passed value was alphabetic
     *                and in a upper case otherwise returns the original value
     */
    function _lower(bytes1 _b1)
        private
        constant
        returns (bytes1) {

        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1)+32);
        }
        
        return _b1;
    }
}


/**
 * Integers Library
 * 
 * In summary this is a simple library of integer functions which allow a simple
 * conversion to and from strings
 * 
 * @author James Lockhart <james@n3tw0rk.co.uk>
 */
library Integers {
    /**
     * Parse Int
     * 
     * Converts an ASCII string value into an uint as long as the string 
     * its self is a valid unsigned integer
     * 
     * @param _value The ASCII string to be converted to an unsigned integer
     * @return uint The unsigned value of the ASCII string
     */
    function parseInt(string _value) 
        public
        pure
        returns (uint _ret) {
        bytes memory _bytesValue = bytes(_value);
        uint j = 1;
        for(uint i = _bytesValue.length-1; i >= 0 && i < _bytesValue.length; i--) {
            assert(_bytesValue[i] >= 48 && _bytesValue[i] <= 57);
            _ret += (uint(_bytesValue[i]) - 48)*j;
            j*=10;
        }
    }
    
    /**
     * To String
     * 
     * Converts an unsigned integer to the ASCII string equivalent value
     * 
     * @param _base The unsigned integer to be converted to a string
     * @return string The resulting ASCII string value
     */
    function toString(uint _base) 
        internal
        pure
        returns (string) {
        bytes memory _tmp = new bytes(32);
        uint i;
        for(i = 0;_base > 0;i++) {
            _tmp[i] = byte((_base % 10) + 48);
            _base /= 10;
        }
        bytes memory _real = new bytes(i--);
        for(uint j = 0; j < _real.length; j++) {
            _real[j] = _tmp[i--];
        }
        return string(_real);
    }

    /**
     * To Byte
     *
     * Convert an 8 bit unsigned integer to a byte
     *
     * @param _base The 8 bit unsigned integer
     * @return byte The byte equivalent
     */
    function toByte(uint8 _base) 
        public
        pure
        returns (byte _ret) {
        assembly {
            let m_alloc := add(msize(),0x1)
            mstore8(m_alloc, _base)
            _ret := mload(m_alloc)
        }
    }

    /**
     * To Bytes
     *
     * Converts an unsigned integer to bytes
     *
     * @param _base The integer to be converted to bytes
     * @return bytes The bytes equivalent 
     */
    function toBytes(uint _base) 
        internal
        pure
        returns (bytes _ret) {
        assembly {
            let m_alloc := add(msize(),0x1)
            _ret := mload(m_alloc)
            mstore(_ret, 0x20)
            mstore(add(_ret, 0x20), _base)
        }
    }
}

contract HEROES {

  using SafeMath for uint256;
  using AddressUtils for address;
  using Strings for string;
  using Integers for uint;


  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
  event Lock(uint256 lockedTo, uint16 lockId);
  event LevelUp(uint32 level);


  struct Character {
    uint256 genes;

    uint256 mintedAt;
    uint256 godfather;
    uint256 mentor;

    uint32 wins;
    uint32 losses;
    uint32 level;

    uint256 lockedTo;
    uint16 lockId;
  }


  string internal constant name_ = "⚔ CRYPTOHEROES GAME ⚔";
  string internal constant symbol_ = "CRYPTOHEROES";
  string internal baseURI_;

  address internal admin;
  mapping(address => bool) internal agents;

  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  mapping(uint256 => address) internal tokenOwner;
  mapping(address => uint256[]) internal ownedTokens;
  mapping(uint256 => uint256) internal ownedTokensIndex;
  mapping(address => uint256) internal ownedTokensCount;

  mapping(uint256 => address) internal tokenApprovals;
  mapping(address => mapping(address => bool)) internal operatorApprovals;

  uint256[] internal allTokens;
  mapping(uint256 => uint256) internal allTokensIndex;

  Character[] characters;
  mapping(uint256 => uint256) tokenCharacters; // tokenId => characterId


  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender ||
            (ownerOf(_tokenId) == tx.origin && isAgent(msg.sender)) ||
            msg.sender == admin);
    _;
  }

  modifier canTransfer(uint256 _tokenId) {
    require(isLocked(_tokenId) &&
            (isApprovedOrOwned(msg.sender, _tokenId) ||
             (isApprovedOrOwned(tx.origin, _tokenId) && isAgent(msg.sender)) ||
             msg.sender == admin));
    _;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  modifier onlyAgent() {
    require(isAgent(msg.sender));
    _;
  }

  /* CONTRACT METHODS */

  constructor(string _baseURI) public {
    baseURI_ = _baseURI;
    admin = msg.sender;
    addAgent(msg.sender);
  }

  function name() external pure returns (string) {
    return name_;
  }

  function symbol() external pure returns (string) {
    return symbol_;
  }

  /* METADATA METHODS */

  function setBaseURI(string _baseURI) external onlyAdmin {
    baseURI_ = _baseURI;
  }

  function tokenURI(uint256 _tokenId) public view returns (string) {
    require(exists(_tokenId));
    return baseURI_.concat(_tokenId.toString());
  }

  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /* TOKEN METHODS */

  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
      emit Approval(owner, _to, _tokenId);
    }
  }

  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return operatorApprovals[_owner][_operator];
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);

    emit Transfer(_from, _to, _tokenId);
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  function safeTransferFrom(address _from,
                            address _to,
                            uint256 _tokenId,
                            bytes _data)
    public
    canTransfer(_tokenId)
  {
    transferFrom(_from, _to, _tokenId);
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  function isApprovedOrOwned(address _spender, uint256 _tokenId) internal view returns (bool) {

    address owner = ownerOf(_tokenId);

    return (_spender == owner ||
            getApproved(_tokenId) == _spender ||
            isApprovedForAll(owner, _spender));
  }

  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      emit Approval(_owner, address(0), _tokenId);
    }
  }

  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);

    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);

    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  function checkAndCallSafeTransfer(address _from,
                                    address _to,
                                    uint256 _tokenId,
                                    bytes _data)
    internal
    returns(bool)
  {
    return true;
  }

  /* AGENT ROLE */

  function addAgent(address _agent) public onlyAdmin {
    agents[_agent] = true;
  }

  function removeAgent(address _agent) external onlyAdmin {
    agents[_agent] = false;
  }

  function isAgent(address _agent) public view returns (bool) {
    return agents[_agent];
  }

  /* CHARACTER LOGIC */

  function getCharacter(uint256 _tokenId)
    external view returns
    (uint256 genes,
     uint256 mintedAt,
     uint256 godfather,
     uint256 mentor,
     uint32 wins,
     uint32 losses,
     uint32 level,
     uint256 lockedTo,
     uint16 lockId) {

    require(exists(_tokenId));

    Character memory c = characters[tokenCharacters[_tokenId]];

    genes = c.genes;
    mintedAt = c.mintedAt;
    godfather = c.godfather;
    mentor = c.mentor;
    wins = c.wins;
    losses = c.losses;
    level = c.level;
    lockedTo = c.lockedTo;
    lockId = c.lockId;
  }

  function addWin(uint256 _tokenId) external onlyAgent {

    require(exists(_tokenId));

    Character storage character = characters[tokenCharacters[_tokenId]];
    character.wins++;
    character.level++;

    emit LevelUp(character.level);
  }

  function addLoss(uint256 _tokenId) external onlyAgent {

    require(exists(_tokenId));

    Character storage character = characters[tokenCharacters[_tokenId]];
    character.losses++;
    if (character.level > 1) {
      character.level--;

      emit LevelUp(character.level);
    }
  }

  /* MINTING */

  function mintTo(address _to,
                  uint256 _genes,
                  uint256 _godfather,
                  uint256 _mentor,
                  uint32 _level)
    external
    onlyAgent
    returns (uint256)
  {
    uint256 newTokenId = totalSupply().add(1);
    _mint(_to, newTokenId);
    _mintCharacter(newTokenId, _genes, _godfather, _mentor, _level);

    return newTokenId;
  }

  function _mintCharacter(uint256 _tokenId,
                          uint256 _genes,
                          uint256 _godfather,
                          uint256 _mentor,
                          uint32 _level)
    internal
  {

    require(exists(_tokenId));

    Character memory character = Character({
      genes: _genes,

          mintedAt: now,
          mentor: _mentor,
          godfather: _godfather,

          wins: 0,
          losses: 0,
          level: _level,

          lockedTo: 0,
          lockId: 0
          });

    uint256 characterId = characters.push(character) - 1;
    tokenCharacters[_tokenId] = characterId;
  }

  /* LOCKS */

  function lock(uint256 _tokenId, uint256 _lockedTo, uint16 _lockId)
    external onlyAgent returns (bool) {

    require(exists(_tokenId));

    Character storage character = characters[tokenCharacters[_tokenId]];

    if (character.lockId == 0) {
      character.lockedTo = _lockedTo;
      character.lockId = _lockId;

      emit Lock(character.lockedTo, character.lockId);

      return true;
    }

    return false;
  }

  function unlock(uint256 _tokenId, uint16 _lockId)
    external onlyAgent returns (bool) {

    require(exists(_tokenId));

    Character storage character = characters[tokenCharacters[_tokenId]];

    if (character.lockId == _lockId) {
      character.lockedTo = 0;
      character.lockId = 0;

      emit Lock(character.lockedTo, character.lockId);

      return true;
    }

    return false;
  }

  function getLock(uint256 _tokenId)
    external view returns (uint256 lockedTo, uint16 lockId) {

    require(exists(_tokenId));

    lockedTo = characters[tokenCharacters[_tokenId]].lockedTo;
    lockId = characters[tokenCharacters[_tokenId]].lockId;
  }

  function isLocked(uint _tokenId) public view returns (bool) {
    require(exists(_tokenId));
    //isLocked workaround: lockedTo должен быть =1 для блокировки трансфер
    return ((characters[tokenCharacters[_tokenId]].lockedTo == 0 &&
             characters[tokenCharacters[_tokenId]].lockId != 0) ||
            now <= characters[tokenCharacters[_tokenId]].lockedTo);
  }

  function test(uint256 _x) returns (bool) {
    return now <= _x;
  }
}
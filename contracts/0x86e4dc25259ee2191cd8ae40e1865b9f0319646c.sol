pragma solidity ^0.4.24;

/**
 * @summary: CryptoRome Land ERC-998 Bottom-Up Composable NFT Contract (and additional helper contracts)
 * @author: GigLabs, LLC
 */

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 *  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
 */
interface ERC721 /* is ERC165 */ {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _tokenOwner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _tokenOwner, address indexed _operator, bool _approved);

    function balanceOf(address _tokenOwner) external view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) external view returns (address _tokenOwner);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function approve(address _to, uint256 _tokenId) external;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address _operator);
    function isApprovedForAll(address _tokenOwner, address _operator) external view returns (bool);
}
 
 
/**
 * @notice Query if a contract implements an interface
 * @dev Interface identification is specified in ERC-165. This function
 * uses less than 30,000 gas.
 */
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface ERC721TokenReceiver {
    /** 
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `transfer`. This function MAY throw to revert and reject the
     * transfer. Return of other than the magic value MUST result in the
     * transaction being reverted.
     * Note: the contract address is always the message sender.
     * @param _operator The address which called `safeTransferFrom` function
     * @param _from The address which previously owned the token
     * @param _tokenId The NFT identifier which is being transferred
     * @param _data Additional data with no specified format
     * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     * unless throwing
     */
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 * Note: the ERC-165 identifier for this interface is 0x5b5e139f.
 */
interface ERC721Metadata /* is ERC721 */ {
    function name() external view returns (string _name);
    function symbol() external view returns (string _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 * Note: the ERC-165 identifier for this interface is 0x780e9d63.
 */
interface ERC721Enumerable /* is ERC721 */ {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 _index) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

/**
 * @title ERC998ERC721 Bottom-Up Composable Non-Fungible Token
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-998.md
 * Note: the ERC-165 identifier for this interface is 0xa1b23002
 */
interface ERC998ERC721BottomUp {
    event TransferToParent(address indexed _toContract, uint256 indexed _toTokenId, uint256 _tokenId);
    event TransferFromParent(address indexed _fromContract, uint256 indexed _fromTokenId, uint256 _tokenId);


    function rootOwnerOf(uint256 _tokenId) public view returns (bytes32 rootOwner);

    /**
    * The tokenOwnerOf function gets the owner of the _tokenId which can be a user address or another ERC721 token.
    * The tokenOwner address return value can be either a user address or an ERC721 contract address.
    * If the tokenOwner address is a user address then parentTokenId will be 0 and should not be used or considered.
    * If tokenOwner address is a user address then isParent is false, otherwise isChild is true, which means that
    * tokenOwner is an ERC721 contract address and _tokenId is a child of tokenOwner and parentTokenId.
    */
    function tokenOwnerOf(uint256 _tokenId) external view returns (bytes32 tokenOwner, uint256 parentTokenId, bool isParent);

    // Transfers _tokenId as a child to _toContract and _toTokenId
    function transferToParent(address _from, address _toContract, uint256 _toTokenId, uint256 _tokenId, bytes _data) public;
    // Transfers _tokenId from a parent ERC721 token to a user address.
    function transferFromParent(address _fromContract, uint256 _fromTokenId, address _to, uint256 _tokenId, bytes _data) public;
    // Transfers _tokenId from a parent ERC721 token to a parent ERC721 token.
    function transferAsChild(address _fromContract, uint256 _fromTokenId, address _toContract, uint256 _toTokenId, uint256 _tokenId, bytes _data) external;

}

/**
 * @title ERC998ERC721 Bottom-Up Composable, optional enumerable extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-998.md
 * Note: The ERC-165 identifier for this interface is 0x8318b539
 */
interface ERC998ERC721BottomUpEnumerable {
    function totalChildTokens(address _parentContract, uint256 _parentTokenId) external view returns (uint256);
    function childTokenByIndex(address _parentContract, uint256 _parentTokenId, uint256 _index) external view returns (uint256);
}

contract ERC998ERC721BottomUpToken is ERC721, ERC721Metadata, ERC721Enumerable, ERC165, ERC998ERC721BottomUp, ERC998ERC721BottomUpEnumerable {
    using SafeMath for uint256;

    struct TokenOwner {
        address tokenOwner;
        uint256 parentTokenId;
    }

    // return this.rootOwnerOf.selector ^ this.rootOwnerOfChild.selector ^
    //   this.tokenOwnerOf.selector ^ this.ownerOfChild.selector;
    bytes32 constant ERC998_MAGIC_VALUE = 0xcd740db5;

    // total number of tokens
    uint256 internal tokenCount;

    // tokenId => token owner
    mapping(uint256 => TokenOwner) internal tokenIdToTokenOwner;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) internal ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal ownedTokensIndex;

    // root token owner address => (tokenId => approved address)
    mapping(address => mapping(uint256 => address)) internal rootOwnerAndTokenIdToApprovedAddress;

    // parent address => (parent tokenId => array of child tokenIds)
    mapping(address => mapping(uint256 => uint256[])) internal parentToChildTokenIds;

    // tokenId => position in childTokens array
    mapping(uint256 => uint256) internal tokenIdToChildTokenIdsIndex;

    // token owner => (operator address => bool)
    mapping(address => mapping(address => bool)) internal tokenOwnerToOperators;

    // Token name
    string internal name_;

    // Token symbol
    string internal symbol_;

    // Token URI
    string internal tokenURIBase;

    mapping(bytes4 => bool) internal supportedInterfaces;

    //from zepellin ERC721Receiver.sol
    //old version
    bytes4 constant ERC721_RECEIVED = 0x150b7a02;

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(_addr)}
        return size > 0;
    }

    constructor () public {
        //ERC165
        supportedInterfaces[0x01ffc9a7] = true;
        //ERC721
        supportedInterfaces[0x80ac58cd] = true;
        //ERC721Metadata
        supportedInterfaces[0x5b5e139f] = true;
        //ERC721Enumerable
        supportedInterfaces[0x780e9d63] = true;
        //ERC998ERC721BottomUp
        supportedInterfaces[0xa1b23002] = true;
        //ERC998ERC721BottomUpEnumerable
        supportedInterfaces[0x8318b539] = true;
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    // ERC165Impl
    //
    /////////////////////////////////////////////////////////////////////////////
    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
        return supportedInterfaces[_interfaceID];
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    // ERC721 implementation & ERC998 Authentication
    //
    /////////////////////////////////////////////////////////////////////////////
    function balanceOf(address _tokenOwner) public view returns (uint256) {
        require(_tokenOwner != address(0));
        return ownedTokens[_tokenOwner].length;
    }

    // returns the immediate owner of the token
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address tokenOwner = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(tokenOwner != address(0));
        return tokenOwner;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(_to != address(this));
        _transferFromOwnerCheck(_from, _to, _tokenId);
        _transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        _transferFromOwnerCheck(_from, _to, _tokenId);
        _transferFrom(_from, _to, _tokenId);
        require(_checkAndCallSafeTransfer(_from, _to, _tokenId, ""));

    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external {
        _transferFromOwnerCheck(_from, _to, _tokenId);
        _transferFrom(_from, _to, _tokenId);
        require(_checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

    function _checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal view returns (bool) {
        if (!isContract(_to)) {
            return true;
        }
        bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }

    function _transferFromOwnerCheck(address _from, address _to, uint256 _tokenId) internal {
        require(_from != address(0));
        require(_to != address(0));
        require(tokenIdToTokenOwner[_tokenId].tokenOwner == _from);
        require(tokenIdToTokenOwner[_tokenId].parentTokenId == 0);

        // check child approved
        address approvedAddress = rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];
        if(msg.sender != _from) {
            bytes32 tokenOwner;
            bool callSuccess;
            // 0xeadb80b8 == ownerOfChild(address,uint256)
            bytes memory calldata = abi.encodeWithSelector(0xed81cdda, address(this), _tokenId);
            assembly {
                callSuccess := staticcall(gas, _from, add(calldata, 0x20), mload(calldata), calldata, 0x20)
                if callSuccess {
                    tokenOwner := mload(calldata)
                }
            }
            if(callSuccess == true) {
                require(tokenOwner >> 224 != ERC998_MAGIC_VALUE);
            }
            require(tokenOwnerToOperators[_from][msg.sender] || approvedAddress == msg.sender);
        }

        // clear approval
        if (approvedAddress != address(0)) {
            delete rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];
            emit Approval(_from, address(0), _tokenId);
        }
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        // first remove the token from the owner list of owned tokens
        uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
        uint256 lastTokenId = ownedTokens[_from][lastTokenIndex];
        if (lastTokenId != _tokenId) {
            // replace the _tokenId in the list of ownedTokens with the
            // last token id in the list. Make sure ownedTokensIndex gets updated
            // with the new position of the last token id as well.
            uint256 tokenIndex = ownedTokensIndex[_tokenId];
            ownedTokens[_from][tokenIndex] = lastTokenId;
            ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        // resize ownedTokens array (automatically deletes the last array entry)
        ownedTokens[_from].length--;

        // transfer token
        tokenIdToTokenOwner[_tokenId].tokenOwner = _to;
        
        // add token to the new owner's list of owned tokens
        ownedTokensIndex[_tokenId] = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external {
        address tokenOwner = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(tokenOwner != address(0));
        address rootOwner = address(rootOwnerOf(_tokenId));
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender]);

        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId] = _approved;
        emit Approval(rootOwner, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address)  {
        address rootOwner = address(rootOwnerOf(_tokenId));
        return rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != address(0));
        tokenOwnerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool)  {
        require(_owner != address(0));
        require(_operator != address(0));
        return tokenOwnerToOperators[_owner][_operator];
    }

    function _tokenOwnerOf(uint256 _tokenId) internal view returns (address tokenOwner, uint256 parentTokenId, bool isParent) {
        tokenOwner = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(tokenOwner != address(0));
        parentTokenId = tokenIdToTokenOwner[_tokenId].parentTokenId;
        if (parentTokenId > 0) {
            isParent = true;
            parentTokenId--;
        }
        else {
            isParent = false;
        }
        return (tokenOwner, parentTokenId, isParent);
    }

    
    function tokenOwnerOf(uint256 _tokenId) external view returns (bytes32 tokenOwner, uint256 parentTokenId, bool isParent) {
        address tokenOwnerAddress = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(tokenOwnerAddress != address(0));
        parentTokenId = tokenIdToTokenOwner[_tokenId].parentTokenId;
        if (parentTokenId > 0) {
            isParent = true;
            parentTokenId--;
        }
        else {
            isParent = false;
        }
        return (ERC998_MAGIC_VALUE << 224 | bytes32(tokenOwnerAddress), parentTokenId, isParent);
    }

    // Use Cases handled:
    // Case 1: Token owner is this contract and no parent tokenId.
    // Case 2: Token owner is this contract and token
    // Case 3: Token owner is top-down composable
    // Case 4: Token owner is an unknown contract
    // Case 5: Token owner is a user
    // Case 6: Token owner is a bottom-up composable
    // Case 7: Token owner is ERC721 token owned by top-down token
    // Case 8: Token owner is ERC721 token owned by unknown contract
    // Case 9: Token owner is ERC721 token owned by user
    function rootOwnerOf(uint256 _tokenId) public view returns (bytes32 rootOwner) {
        address rootOwnerAddress = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(rootOwnerAddress != address(0));
        uint256 parentTokenId = tokenIdToTokenOwner[_tokenId].parentTokenId;
        bool isParent = parentTokenId > 0;
        if (isParent) {
            parentTokenId--;
        }

        if((rootOwnerAddress == address(this))) {
            do {
                if(isParent == false) {
                    // Case 1: Token owner is this contract and no token.
                    // This case should not happen.
                    return ERC998_MAGIC_VALUE << 224 | bytes32(rootOwnerAddress);
                }
                else {
                    // Case 2: Token owner is this contract and token
                    (rootOwnerAddress, parentTokenId, isParent) = _tokenOwnerOf(parentTokenId);
                }
            } while(rootOwnerAddress == address(this));
            _tokenId = parentTokenId;
        }

        bytes memory calldata;
        bool callSuccess;

        if (isParent == false) {

            // success if this token is owned by a top-down token
            // 0xed81cdda == rootOwnerOfChild(address, uint256)
            calldata = abi.encodeWithSelector(0xed81cdda, address(this), _tokenId);
            assembly {
                callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)
                if callSuccess {
                    rootOwner := mload(calldata)
                }
            }
            if(callSuccess == true && rootOwner >> 224 == ERC998_MAGIC_VALUE) {
                // Case 3: Token owner is top-down composable
                return rootOwner;
            }
            else {
                // Case 4: Token owner is an unknown contract
                // Or
                // Case 5: Token owner is a user
                return ERC998_MAGIC_VALUE << 224 | bytes32(rootOwnerAddress);
            }
        }
        else {

            // 0x43a61a8e == rootOwnerOf(uint256)
            calldata = abi.encodeWithSelector(0x43a61a8e, parentTokenId);
            assembly {
                callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)
                if callSuccess {
                    rootOwner := mload(calldata)
                }
            }
            if (callSuccess == true && rootOwner >> 224 == ERC998_MAGIC_VALUE) {
                // Case 6: Token owner is a bottom-up composable
                // Or
                // Case 2: Token owner is top-down composable
                return rootOwner;
            }
            else {
                // token owner is ERC721
                address childContract = rootOwnerAddress;
                //0x6352211e == "ownerOf(uint256)"
                calldata = abi.encodeWithSelector(0x6352211e, parentTokenId);
                assembly {
                    callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)
                    if callSuccess {
                        rootOwnerAddress := mload(calldata)
                    }
                }
                require(callSuccess);

                // 0xed81cdda == rootOwnerOfChild(address,uint256)
                calldata = abi.encodeWithSelector(0xed81cdda, childContract, parentTokenId);
                assembly {
                    callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)
                    if callSuccess {
                        rootOwner := mload(calldata)
                    }
                }
                if(callSuccess == true && rootOwner >> 224 == ERC998_MAGIC_VALUE) {
                    // Case 7: Token owner is ERC721 token owned by top-down token
                    return rootOwner;
                }
                else {
                    // Case 8: Token owner is ERC721 token owned by unknown contract
                    // Or
                    // Case 9: Token owner is ERC721 token owned by user
                    return ERC998_MAGIC_VALUE << 224 | bytes32(rootOwnerAddress);
                }
            }
        }
    }

    // List of all Land Tokens assigned to an address.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        return ownedTokens[_owner];
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    // ERC721MetadataImpl
    //
    /////////////////////////////////////////////////////////////////////////////

    function tokenURI(uint256 _tokenId) external view returns (string) {
        require (exists(_tokenId));
        return _appendUintToString(tokenURIBase, _tokenId);
    }

    function name() external view returns (string) {
        return name_;
    }

    function symbol() external view returns (string) {
        return symbol_;
    }

    function _appendUintToString(string inStr, uint v) private pure returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        str = string(s);
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    // ERC721EnumerableImpl
    //
    /////////////////////////////////////////////////////////////////////////////

    function exists(uint256 _tokenId) public view returns (bool) {
        return _tokenId < tokenCount;
    }
 
    function totalSupply() external view returns (uint256) {
        return tokenCount;
    }

    function tokenOfOwnerByIndex(address _tokenOwner, uint256 _index) external view returns (uint256 tokenId) {
        require(_index < ownedTokens[_tokenOwner].length);
        return ownedTokens[_tokenOwner][_index];
    }

    function tokenByIndex(uint256 _index) external view returns (uint256 tokenId) {
        require(_index < tokenCount);
        return _index;
    }

    function _mint(address _to, uint256 _tokenId) internal {
        require (_to != address(0));
        require (tokenIdToTokenOwner[_tokenId].tokenOwner == address(0));
        tokenIdToTokenOwner[_tokenId].tokenOwner = _to;
        ownedTokensIndex[_tokenId] = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);
        tokenCount++;

        emit Transfer(address(0), _to, _tokenId);
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    // ERC998 Bottom-Up implementation (extenstion of ERC-721)
    //
    /////////////////////////////////////////////////////////////////////////////

    function _removeChild(address _fromContract, uint256 _fromTokenId, uint256 _tokenId) internal {
        uint256 lastChildTokenIndex = parentToChildTokenIds[_fromContract][_fromTokenId].length - 1;
        uint256 lastChildTokenId = parentToChildTokenIds[_fromContract][_fromTokenId][lastChildTokenIndex];

        if (_tokenId != lastChildTokenId) {
            uint256 currentChildTokenIndex = tokenIdToChildTokenIdsIndex[_tokenId];
            parentToChildTokenIds[_fromContract][_fromTokenId][currentChildTokenIndex] = lastChildTokenId;
            tokenIdToChildTokenIdsIndex[lastChildTokenId] = currentChildTokenIndex;
        }
        parentToChildTokenIds[_fromContract][_fromTokenId].length--;
    }

    function _transferChild(address _from, address _toContract, uint256 _toTokenId, uint256 _tokenId) internal {
        tokenIdToTokenOwner[_tokenId].parentTokenId = _toTokenId.add(1);
        uint256 index = parentToChildTokenIds[_toContract][_toTokenId].length;
        parentToChildTokenIds[_toContract][_toTokenId].push(_tokenId);
        tokenIdToChildTokenIdsIndex[_tokenId] = index;

        _transferFrom(_from, _toContract, _tokenId);
        
        require(ERC721(_toContract).ownerOf(_toTokenId) != address(0));
        emit TransferToParent(_toContract, _toTokenId, _tokenId);
    }

    function _removeFromToken(address _fromContract, uint256 _fromTokenId, address _to, uint256 _tokenId) internal {
        require(_fromContract != address(0));
        require(_to != address(0));
        require(tokenIdToTokenOwner[_tokenId].tokenOwner == _fromContract);
        uint256 parentTokenId = tokenIdToTokenOwner[_tokenId].parentTokenId;
        require(parentTokenId != 0);
        require(parentTokenId - 1 == _fromTokenId);

        // authenticate
        address rootOwner = address(rootOwnerOf(_tokenId));
        address approvedAddress = rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] || approvedAddress == msg.sender);

        // clear approval
        if (approvedAddress != address(0)) {
            delete rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
            emit Approval(rootOwner, address(0), _tokenId);
        }

        tokenIdToTokenOwner[_tokenId].parentTokenId = 0;

        _removeChild(_fromContract, _fromTokenId, _tokenId);
        emit TransferFromParent(_fromContract, _fromTokenId, _tokenId);
    }

    function transferFromParent(address _fromContract, uint256 _fromTokenId, address _to, uint256 _tokenId, bytes _data) public {
        _removeFromToken(_fromContract, _fromTokenId, _to, _tokenId);
        delete tokenIdToChildTokenIdsIndex[_tokenId];
        _transferFrom(_fromContract, _to, _tokenId);
        require(_checkAndCallSafeTransfer(_fromContract, _to, _tokenId, _data));
    }

    function transferToParent(address _from, address _toContract, uint256 _toTokenId, uint256 _tokenId, bytes _data) public {
        _transferFromOwnerCheck(_from, _toContract, _tokenId);
        _transferChild(_from, _toContract, _toTokenId, _tokenId);
    }

    function transferAsChild(address _fromContract, uint256 _fromTokenId, address _toContract, uint256 _toTokenId, uint256 _tokenId, bytes _data) external {
        _removeFromToken(_fromContract, _fromTokenId, _toContract, _tokenId);
        _transferChild(_fromContract, _toContract, _toTokenId, _tokenId);
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    // ERC998 Bottom-Up Enumerable Implementation
    //
    /////////////////////////////////////////////////////////////////////////////

    function totalChildTokens(address _parentContract, uint256 _parentTokenId) public view returns (uint256) {
        return parentToChildTokenIds[_parentContract][_parentTokenId].length;
    }

    function childTokenByIndex(address _parentContract, uint256 _parentTokenId, uint256 _index) public view returns (uint256) {
        require(parentToChildTokenIds[_parentContract][_parentTokenId].length > _index);
        return parentToChildTokenIds[_parentContract][_parentTokenId][_index];
    }
}


contract CryptoRomeControl {

    // Emited when contract is upgraded or ownership changed
    event ContractUpgrade(address newContract);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Has control of (most) contract elements
    address public ownerPrimary;
    address public ownerSecondary;

    // Address of owner wallet to transfer funds
    address public ownerWallet;
    address public cryptoRomeWallet;

    // Contracts that need access for gameplay
    // (state = 1 means access is active, state = 0 means disabled)
    mapping(address => uint8) public otherOperators;

    // Improvement contract is the only authorized address that can modify 
    // existing land data (ex. when player purchases a land improvement). No one else can
    // modify land - even owners of this contract
    address public improvementContract;

    // Tracks if contract is paused or not. If paused, most actions are blocked
    bool public paused = false;

    constructor() public {
        ownerPrimary = msg.sender;
        ownerSecondary = msg.sender;
        ownerWallet = msg.sender;
        cryptoRomeWallet = msg.sender;
    }

    modifier onlyOwner() {
        require (msg.sender == ownerPrimary || msg.sender == ownerSecondary);
        _;
    }

    modifier anyOperator() {
        require (
            msg.sender == ownerPrimary ||
            msg.sender == ownerSecondary ||
            otherOperators[msg.sender] == 1
        );
        _;
    }

    modifier onlyOtherOperators() {
        require (otherOperators[msg.sender] == 1);
        _;
    }

    modifier onlyImprovementContract() {
        require (msg.sender == improvementContract);
        _;
    }

    function setPrimaryOwner(address _newOwner) external onlyOwner {
        require (_newOwner != address(0));
        emit OwnershipTransferred(ownerPrimary, _newOwner);
        ownerPrimary = _newOwner;
    }

    function setSecondaryOwner(address _newOwner) external onlyOwner {
        require (_newOwner != address(0));
        emit OwnershipTransferred(ownerSecondary, _newOwner);
        ownerSecondary = _newOwner;
    }

    function setOtherOperator(address _newOperator, uint8 _state) external onlyOwner {
        require (_newOperator != address(0));
        otherOperators[_newOperator] = _state;
    }

    function setImprovementContract(address _improvementContract) external onlyOwner {
        require (_improvementContract != address(0));
        emit OwnershipTransferred(improvementContract, _improvementContract);
        improvementContract = _improvementContract;
    }

    function transferOwnerWalletOwnership(address newWalletAddress) onlyOwner external {
        require(newWalletAddress != address(0));
        ownerWallet = newWalletAddress;
    }

    function transferCryptoRomeWalletOwnership(address newWalletAddress) onlyOwner external {
        require(newWalletAddress != address(0));
        cryptoRomeWallet = newWalletAddress;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
    }

    function withdrawBalance() public onlyOwner {
        ownerWallet.transfer(address(this).balance);
    }
}

contract CryptoRomeLandComposableNFT is ERC998ERC721BottomUpToken, CryptoRomeControl {
    using SafeMath for uint256;

    // Set in case the contract needs to be updated
    address public newContractAddress;

    struct LandInfo {
        uint256 landType;  // 0-4  unit, plot, village, town, city (unit unused)
        uint256 landImprovements; 
        uint256 askingPrice;
    }

    mapping(uint256 => LandInfo) internal tokenIdToLand;

    // for sale state of all tokens. tokens map to bits. 0 = not for sale; 1 = for sale
    // 256 token states per index of this array
    uint256[] internal allLandForSaleState;

    // landType => land count
    mapping(uint256 => uint256) internal landTypeToCount;

    // total number of villages in existence is 50000 (no more can be created)
    uint256 constant internal MAX_VILLAGES = 50000;

    constructor () public {
        paused = true;
        name_ = "CryptoRome-Land-NFT";
        symbol_ = "CRLAND";
    }

    function isCryptoRomeLandComposableNFT() external pure returns (bool) {
        return true;
    }

    function getLandTypeCount(uint256 _landType) public view returns (uint256) {
        return landTypeToCount[_landType];
    }

    function setTokenURI(string _tokenURI) external anyOperator {
        tokenURIBase = _tokenURI;
    }

    function setNewAddress(address _v2Address) external onlyOwner {
        require (_v2Address != address(0));
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Get Land
    //   Token Owner: Address of the token owner
    //   Parent Token Id: If parentTokenId is > 0, then this land
    //      token is owned by another token (i.e. it is attached bottom-up).
    //      parentTokenId is the id of the owner token, and tokenOwner
    //      address (the first parameter) is the ERC721 contract address of the  
    //      parent token. If parentTokenId == 0, then this land token is owned
    //      by a user address.
    //   Land Types: village=1, town=2, city=3
    //   Land Improvements: improvements and upgrades
    //      to each land NFT are coded into a single uint256 value
    //   Asking Price (in wei): 0 if land is not for sale
    /////////////////////////////////////////////////////////////////////////////
    function getLand(uint256 _tokenId) external view
        returns (
            address tokenOwner,
            uint256 parentTokenId,
            uint256 landType,
            uint256 landImprovements,
            uint256 askingPrice
        ) {
        TokenOwner storage owner = tokenIdToTokenOwner[_tokenId];
        LandInfo storage land = tokenIdToLand[_tokenId];

        parentTokenId = owner.parentTokenId;
        if (parentTokenId > 0) {
            parentTokenId--;
        }
        tokenOwner = owner.tokenOwner;
        parentTokenId = owner.parentTokenId;
        landType = land.landType;
        landImprovements = land.landImprovements;
        askingPrice = land.askingPrice;
    }

    /////////////////////////////////////////////////////////////////////////////
    // Create Land NFT
    //   Land Types: village=1, town=2, city=3
    //   Land Improvements: improvements and upgrades
    //      to each land NFT are the coded into a uint256 value
    /////////////////////////////////////////////////////////////////////////////
    function _createLand (address _tokenOwner, uint256 _landType, uint256 _landImprovements) internal returns (uint256 tokenId) {
        require(_tokenOwner != address(0));
        require(landTypeToCount[1] < MAX_VILLAGES);
        tokenId = tokenCount;

        LandInfo memory land = LandInfo({
            landType: _landType,  // 1-3  village, town, city
            landImprovements: _landImprovements,
            askingPrice: 0
        });
        
        // map new tokenId to the newly created land      
        tokenIdToLand[tokenId] = land;
        landTypeToCount[_landType]++;

        if (tokenId % 256 == 0) {
            // create new land sale state entry in storage
            allLandForSaleState.push(0);
        }

        _mint(_tokenOwner, tokenId);

        return tokenId;
    }
    
    function createLand (address _tokenOwner, uint256 _landType, uint256 _landImprovements) external anyOperator whenNotPaused returns (uint256 tokenId) {
        return _createLand (_tokenOwner, _landType, _landImprovements);
    }

    ////////////////////////////////////////////////////////////////////////////////
    // Land Improvement Data
    //   This uint256 land "dna" value describes all improvements and upgrades 
    //   to a piece of land. After land token distribution, only the Improvement
    //   Contract can ever update or modify the land improvement data of a piece
    //   of land (contract owner cannot modify land).
    //
    // For villages, improvementData is a uint256 value containing village
    // improvement data with the following slot bit mapping
    //     0-31:     slot 1 improvement info
    //     32-63:    slot 2 improvement info
    //     64-95:    slot 3 improvement info
    //     96-127:   slot 4 improvement info
    //     128-159:  slot 5 improvement info
    //     160-191:  slot 6 improvement info
    //     192-255:  reserved for additional land information
    //
    // Each 32 bit slot in the above structure has the following bit mapping
    //     0-7:      improvement type (index to global list of possible types)
    //     8-14:     upgrade type 1 - level 0-99  (0 for no upgrade present)
    //     15-21:    upgrade type 2 - level 0-99  (0 for no upgrade present)
    //     22:       upgrade type 3 - 1 if upgrade present, 0 if not (no leveling)
    ////////////////////////////////////////////////////////////////////////////////
    function getLandImprovementData(uint256 _tokenId) external view returns (uint256) {
        return tokenIdToLand[_tokenId].landImprovements;
    }

    function updateLandImprovementData(uint256 _tokenId, uint256 _newLandImprovementData) external whenNotPaused onlyImprovementContract {
        require(_tokenId <= tokenCount);
        tokenIdToLand[_tokenId].landImprovements = _newLandImprovementData;
    }

    /////////////////////////////////////////////////////////////////////////////
    // Land Compose/Decompose functions
    //   Towns are composed of 3 Villages
    //   Cities are composed of 3 Towns
    /////////////////////////////////////////////////////////////////////////////

    // Attach three child land tokens onto a parent land token (ex. 3 villages onto a town).
    // This function is called when the parent does not exist yet, so create parent land token first
    // Ownership of the child lands transfers from the existing owner (sender) to the parent land token
    function composeNewLand(uint256 _landType, uint256 _childLand1, uint256 _childLand2, uint256 _childLand3) external whenNotPaused returns(uint256) {
        uint256 parentTokenId = _createLand(msg.sender, _landType, 0);
        return composeLand(parentTokenId, _childLand1, _childLand2, _childLand3);
    }

    // Attach three child land tokens onto a parent land token (ex. 3 villages into a town).
    // All three children and an existing parent need to be passed into this function.
    // Ownership of the child lands transfers from the existing owner (sender) to the parent land token
    function composeLand(uint256 _parentLandId, uint256 _childLand1, uint256 _childLand2, uint256 _childLand3) public whenNotPaused returns(uint256) {
        require (tokenIdToLand[_parentLandId].landType == 2 || tokenIdToLand[_parentLandId].landType == 3);
        uint256 validChildLandType = tokenIdToLand[_parentLandId].landType.sub(1);
        require(tokenIdToLand[_childLand1].landType == validChildLandType &&
                tokenIdToLand[_childLand2].landType == validChildLandType &&
                tokenIdToLand[_childLand3].landType == validChildLandType);

        // transfer ownership of child land tokens to parent land token
        transferToParent(tokenIdToTokenOwner[_childLand1].tokenOwner, address(this), _parentLandId, _childLand1, "");
        transferToParent(tokenIdToTokenOwner[_childLand2].tokenOwner, address(this), _parentLandId, _childLand2, "");
        transferToParent(tokenIdToTokenOwner[_childLand3].tokenOwner, address(this), _parentLandId, _childLand3, "");

        // if this contract is owner of the parent land token, transfer ownership to msg.sender
        if (tokenIdToTokenOwner[_parentLandId].tokenOwner == address(this)) {
            _transferFrom(address(this), msg.sender, _parentLandId);
        }

        return _parentLandId;
    }

    // Decompose a parent land back to it's attached child land token components (ex. a town into 3 villages).
    // The existing owner of the parent land becomes the owner of the three child tokens
    // This contract takes over ownership of the parent land token (for later reuse)
    // Loop to remove and transfer all land tokens in case other land tokens are attached.
    function decomposeLand(uint256 _tokenId) external whenNotPaused {
        uint256 numChildren = totalChildTokens(address(this), _tokenId);
        require (numChildren > 0);

        // it is lower gas cost to remove children starting from the end of the array
        for (uint256 numChild = numChildren; numChild > 0; numChild--) {
            uint256 childTokenId = childTokenByIndex(address(this), _tokenId, numChild-1);

            // transfer ownership of underlying lands to msg.sender
            transferFromParent(address(this), _tokenId, msg.sender, childTokenId, "");
        }

        // transfer ownership of parent land back to this contract owner for reuse
        _transferFrom(msg.sender, address(this), _tokenId);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Sale functions
    /////////////////////////////////////////////////////////////////////////////
    function _updateSaleData(uint256 _tokenId, uint256 _askingPrice) internal {
        tokenIdToLand[_tokenId].askingPrice = _askingPrice;
        if (_askingPrice > 0) {
            // Item is for sale - set bit
            allLandForSaleState[_tokenId.div(256)] = allLandForSaleState[_tokenId.div(256)] | (1 << (_tokenId % 256));
        } else {
            // Item is no longer for sale - clear bit
            allLandForSaleState[_tokenId.div(256)] = allLandForSaleState[_tokenId.div(256)] & ~(1 << (_tokenId % 256));
        }
    }

    function sellLand(uint256 _tokenId, uint256 _askingPrice) public whenNotPaused {
        require(tokenIdToTokenOwner[_tokenId].tokenOwner == msg.sender);
        require(tokenIdToTokenOwner[_tokenId].parentTokenId == 0);
        require(_askingPrice > 0);
        // Put the land token on the market
        _updateSaleData(_tokenId, _askingPrice);
    }

    function cancelLandSale(uint256 _tokenId) public whenNotPaused {
        require(tokenIdToTokenOwner[_tokenId].tokenOwner == msg.sender);
        // Take the land token off the market
        _updateSaleData(_tokenId, 0);
    }

    function purchaseLand(uint256 _tokenId) public whenNotPaused payable {
        uint256 price = tokenIdToLand[_tokenId].askingPrice;
        require(price <= msg.value);

        // Take the land token off the market
        _updateSaleData(_tokenId, 0);

        // Marketplace fee
        uint256 marketFee = computeFee(price);
        uint256 sellerProceeds = msg.value.sub(marketFee);
        cryptoRomeWallet.transfer(marketFee);

        // Return excess payment to sender
        uint256 excessPayment = msg.value.sub(price);
        msg.sender.transfer(excessPayment);

        // Transfer proceeds to seller. Sale was removed above before this transfer()
        // to guard against reentrancy attacks
        tokenIdToTokenOwner[_tokenId].tokenOwner.transfer(sellerProceeds);
        // Transfer token to buyer
        _transferFrom(tokenIdToTokenOwner[_tokenId].tokenOwner, msg.sender, _tokenId);
    }

    function getAllForSaleStatus() external view returns(uint256[]) {
        // return uint256[] bitmap values up to max tokenId (for ease of querying from UI for marketplace)
        //   index 0 of the uint256 holds first 256 land token status; index 1 is next 256 land tokens, etc
        //   value of 1 = For Sale; 0 = Not for Sale
        return allLandForSaleState;
    }

    function computeFee(uint256 amount) internal pure returns(uint256) {
        // 3% marketplace fee, most of which will be distributed to the Caesar and Senators of CryptoRome
        return amount.mul(3).div(100);
    }
}

contract CryptoRomeLandDistribution is CryptoRomeControl {
    using SafeMath for uint256;

    // Set in case the contract needs to be updated
    address public newContractAddress;

    CryptoRomeLandComposableNFT public cryptoRomeLandNFTContract;
    ImprovementGeneration public improvementGenContract;
    uint256 public villageInventoryPrice;
    uint256 public numImprovementsPerVillage;

    uint256 constant public LOWEST_VILLAGE_INVENTORY_PRICE = 100000000000000000; // 0.1 ETH

    constructor (address _cryptoRomeLandNFTContractAddress, address _improvementGenContractAddress) public {
        require (_cryptoRomeLandNFTContractAddress != address(0));
        require (_improvementGenContractAddress != address(0));

        paused = true;

        cryptoRomeLandNFTContract = CryptoRomeLandComposableNFT(_cryptoRomeLandNFTContractAddress);
        improvementGenContract = ImprovementGeneration(_improvementGenContractAddress);

        villageInventoryPrice = LOWEST_VILLAGE_INVENTORY_PRICE;
        numImprovementsPerVillage = 3;
    }

    function setNewAddress(address _v2Address) external onlyOwner {
        require (_v2Address != address(0));
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    function setCryptoRomeLandNFTContract(address _cryptoRomeLandNFTContract) external onlyOwner {
        require (_cryptoRomeLandNFTContract != address(0));
        cryptoRomeLandNFTContract = CryptoRomeLandComposableNFT(_cryptoRomeLandNFTContract);
    }

    function setImprovementGenContract(address _improvementGenContractAddress) external onlyOwner {
        require (_improvementGenContractAddress != address(0));
        improvementGenContract = ImprovementGeneration(_improvementGenContractAddress);
    }

    function setVillageInventoryPrice(uint256 _price) external onlyOwner {
        require(_price >= LOWEST_VILLAGE_INVENTORY_PRICE);
        villageInventoryPrice = _price;
    }

    function setNumImprovementsPerVillage(uint256 _numImprovements) external onlyOwner {
        require(_numImprovements <= 6);
        numImprovementsPerVillage = _numImprovements;
    }

    function purchaseFromVillageInventory(uint256 _num) external whenNotPaused payable {
        uint256 price = villageInventoryPrice.mul(_num);
        require (msg.value >= price);
        require (_num > 0 && _num <= 50);

        // Marketplace fee
        uint256 marketFee = computeFee(price);
        cryptoRomeWallet.transfer(marketFee);

        // Return excess payment to sender
        uint256 excessPayment = msg.value.sub(price);
        msg.sender.transfer(excessPayment);

        for (uint256 i = 0; i < _num; i++) {
            // create a new village w/ random improvements and transfer the NFT to caller
            _createVillageWithImprovementsFromInv(msg.sender);
        }
    }

    function computeFee(uint256 amount) internal pure returns(uint256) {
        // 3% marketplace fee, most of which will be distributed to the Caesar and Senators of CryptoRome
        return amount.mul(3).div(100);
    }

    function batchIssueLand(address _toAddress, uint256[] _landType) external onlyOwner {
        require (_toAddress != address(0));
        require (_landType.length > 0);

        for (uint256 i = 0; i < _landType.length; i++) {
            issueLand(_toAddress, _landType[i]);
        }
    }

    function batchIssueVillages(address _toAddress, uint256 _num) external onlyOwner {
        require (_toAddress != address(0));
        require (_num > 0);

        for (uint256 i = 0; i < _num; i++) {
            _createVillageWithImprovements(_toAddress);
        }
    }

    function issueLand(address _toAddress, uint256 _landType) public onlyOwner returns (uint256) {
        require (_toAddress != address(0));

        return _createLandWithImprovements(_toAddress, _landType);
    }

    function batchCreateLand(uint256[] _landType) external onlyOwner {
        require (_landType.length > 0);

        for (uint256 i = 0; i < _landType.length; i++) {
            // land created is owned by this contract for staging purposes
            // (must later use transferTo or batchTransferTo)
            _createLandWithImprovements(address(this), _landType[i]);
        }
    }

    function batchCreateVillages(uint256 _num) external onlyOwner {
        require (_num > 0);

        for (uint256 i = 0; i < _num; i++) {
            // land created is owned by this contract for staging purposes
            // (must later use transferTo or batchTransferTo)
            _createVillageWithImprovements(address(this));
        }
    }

    function createLand(uint256 _landType) external onlyOwner {
        // land created is owned by this contract for staging purposes
        // (must later use transferTo or batchTransferTo)
        _createLandWithImprovements(address(this), _landType);
    }

    function batchTransferTo(uint256[] _tokenIds, address _to) external onlyOwner {
        require (_tokenIds.length > 0);
        require (_to != address(0));

        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            // transfers staged land out of this contract to the owners
            cryptoRomeLandNFTContract.transferFrom(address(this), _to, _tokenIds[i]);
        }
    }

    function transferTo(uint256 _tokenId, address _to) external onlyOwner {
        require (_to != address(0));

        // transfers staged land out of this contract to the owners
        cryptoRomeLandNFTContract.transferFrom(address(this), _to, _tokenId);
    }

    function issueVillageWithImprovementsForPromo(address _toAddress, uint256 numImprovements) external onlyOwner returns (uint256) {
        uint256 landImprovements = improvementGenContract.genInitialResourcesForVillage(numImprovements, false);
        return cryptoRomeLandNFTContract.createLand(_toAddress, 1, landImprovements);
    }

    function _createVillageWithImprovementsFromInv(address _toAddress) internal returns (uint256) {
        uint256 landImprovements = improvementGenContract.genInitialResourcesForVillage(numImprovementsPerVillage, true);
        return cryptoRomeLandNFTContract.createLand(_toAddress, 1, landImprovements);
    }

    function _createVillageWithImprovements(address _toAddress) internal returns (uint256) {
        uint256 landImprovements = improvementGenContract.genInitialResourcesForVillage(3, false);
        return cryptoRomeLandNFTContract.createLand(_toAddress, 1, landImprovements);
    }

    function _createLandWithImprovements(address _toAddress, uint256 _landType) internal returns (uint256) {
        require (_landType > 0 && _landType < 4);

        if (_landType == 1) {
            return _createVillageWithImprovements(_toAddress);
        } else if (_landType == 2) {
            uint256 village1TokenId = _createLandWithImprovements(address(this), 1);
            uint256 village2TokenId = _createLandWithImprovements(address(this), 1);
            uint256 village3TokenId = _createLandWithImprovements(address(this), 1);
            uint256 townTokenId = cryptoRomeLandNFTContract.createLand(_toAddress, 2, 0);
            cryptoRomeLandNFTContract.composeLand(townTokenId, village1TokenId, village2TokenId, village3TokenId);
            return townTokenId;
        } else if (_landType == 3) {
            uint256 town1TokenId = _createLandWithImprovements(address(this), 2);
            uint256 town2TokenId = _createLandWithImprovements(address(this), 2);
            uint256 town3TokenId = _createLandWithImprovements(address(this), 2);
            uint256 cityTokenId = cryptoRomeLandNFTContract.createLand(_toAddress, 3, 0);
            cryptoRomeLandNFTContract.composeLand(cityTokenId, town1TokenId, town2TokenId, town3TokenId);
            return cityTokenId;
        }
    }
}

interface RandomNumGeneration {
    function getRandomNumber(uint256 seed) external returns (uint256);
}

contract ImprovementGeneration is CryptoRomeControl {
    using SafeMath for uint256;
    
    // Set in case the contract needs to be updated
    address public newContractAddress;

    RandomNumGeneration public randomNumberSource; 
    uint256 public rarityValueMax;
    uint256 public latestPseudoRandomNumber;
    uint8 public numResourceImprovements;

    mapping(uint8 => uint256) private improvementIndexToRarityValue;

    constructor () public {
        // Starting Improvements
        // improvement => rarity value (lower number = higher rarity) 
        improvementIndexToRarityValue[1] = 256;  // Wheat
        improvementIndexToRarityValue[2] = 256;  // Wood
        improvementIndexToRarityValue[3] = 128;  // Grapes
        improvementIndexToRarityValue[4] = 128;  // Stone
        improvementIndexToRarityValue[5] = 64;   // Clay
        improvementIndexToRarityValue[6] = 64;   // Fish
        improvementIndexToRarityValue[7] = 32;   // Horse
        improvementIndexToRarityValue[8] = 16;   // Iron
        improvementIndexToRarityValue[9] = 8;    // Marble
        // etc --> More can be added in the future

        // max resource improvement types is 63
        numResourceImprovements = 9;
        rarityValueMax = 952;
    }

    function setNewAddress(address _v2Address) external onlyOwner {
        require (_v2Address != address(0));
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    function setRandomNumGenerationContract(address _randomNumberGenAddress) external onlyOwner {
        require (_randomNumberGenAddress != address(0));
        randomNumberSource = RandomNumGeneration(_randomNumberGenAddress);
    }

    function genInitialResourcesForVillage(uint256 numImprovements, bool useRandomInput) external anyOperator returns(uint256) {
        require(numImprovements <= 6);
        uint256 landImprovements;

        // each improvement takes up one village slot (max 6 slots)
        for (uint256 i = 0; i < numImprovements; i++) {
            uint8 newImprovement = generateImprovement(useRandomInput);
            // each slot is a 32 bit section in the 256 bit landImprovement value
            landImprovements |= uint256(newImprovement) << (32*i);
        }
        
        return landImprovements;
    }

    function generateImprovement(bool useRandomSource) public anyOperator returns (uint8 newImprovement) {     
        // seed does not need to be anything super fancy for initial improvement generation for villages...
        // players will not be performing that operation, so this should be random enough
        uint256 seed = latestPseudoRandomNumber.add(now);
        if (useRandomSource) {
            // for cases where players are generating land (i.e. after initial distribution of villages), there
            // will need to be a better source of randomness
            seed = randomNumberSource.getRandomNumber(seed);
        }
        
        latestPseudoRandomNumber = addmod(uint256(blockhash(block.number-1)), seed, rarityValueMax);
        
        // do lookup for the improvement
        newImprovement = lookupImprovementTypeByRarity(latestPseudoRandomNumber);
    }

    function lookupImprovementTypeByRarity(uint256 rarityNum) public view returns (uint8 improvementType) {
        uint256 rarityIndexValue;
        for (uint8 i = 1; i <= numResourceImprovements; i++) {
            rarityIndexValue += improvementIndexToRarityValue[i];
            if (rarityNum < rarityIndexValue) {
                return i;
            }
        }
        return 0;
    }

    function addNewResourceImprovementType(uint256 rarityValue) external onlyOwner {
        require(rarityValue > 0);
        require(numResourceImprovements < 63);

        numResourceImprovements++;
        rarityValueMax += rarityValue;
        improvementIndexToRarityValue[numResourceImprovements] = rarityValue;
    }

    function updateImprovementRarityValue(uint256 rarityValue, uint8 improvementIndex) external onlyOwner {
        require(rarityValue > 0);
        require(improvementIndex <= numResourceImprovements);

        rarityValueMax -= improvementIndexToRarityValue[improvementIndex];
        rarityValueMax += rarityValue;
        improvementIndexToRarityValue[improvementIndex] = rarityValue;
    }
}
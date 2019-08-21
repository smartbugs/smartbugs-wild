pragma solidity >=0.4.22 <0.6.0;

//-----------------------------------------------------------------------------
/// @title AAC Ownership
/// @notice defines AAC ownership-tracking structures and view functions.
//-----------------------------------------------------------------------------
contract AacOwnership {
    struct Aac {
        // owner ID list
        address payable owner;
        // unique identifier
        uint uid;
        // timestamp
        uint timestamp;
        // exp
        uint exp;
        // AAC data
        bytes aacData;
    }

    struct ExternalNft{
        // Contract address
        address nftContractAddress;
        // Token Identifier
        uint nftId;
    }

    // Array containing all AACs. The first element in aacArray returns as
    //  invalid
    Aac[] aacArray;
    // Mapping containing all UIDs tracked by this contract. Valid UIDs map to
    //  index numbers, invalid UIDs map to 0.
    mapping (uint => uint) uidToAacIndex;
    // Mapping containing linked external NFTs. Linked AACs always map to
    //  non-zero numbers, invalid AACs map to 0.
    mapping (uint => ExternalNft) uidToExternalNft;
    // Mapping containing tokens IDs for tokens created by an external contract
    //  and whether or not it is linked to an AAC. 
    mapping (address => mapping (uint => bool)) linkedExternalNfts;
    
    //-------------------------------------------------------------------------
    /// @dev Throws if AAC #`_tokenId` isn't tracked by the aacArray.
    //-------------------------------------------------------------------------
    modifier mustExist(uint _tokenId) {
        require (uidToAacIndex[_tokenId] != 0);
        _;
    }

    //-------------------------------------------------------------------------
    /// @dev Throws if AAC #`_tokenId` isn't owned by sender.
    //-------------------------------------------------------------------------
    modifier mustOwn(uint _tokenId) {
        require (ownerOf(_tokenId) == msg.sender);
        _;
    }

    //-------------------------------------------------------------------------
    /// @dev Throws if parameter is zero
    //-------------------------------------------------------------------------
    modifier notZero(uint _param) {
        require(_param != 0);
        _;
    }

    //-------------------------------------------------------------------------
    /// @dev Creates an empty AAC as a [0] placeholder for invalid AAC queries.
    //-------------------------------------------------------------------------
    constructor () public {
        aacArray.push(Aac(address(0), 0, 0, 0, ""));
    }

    //-------------------------------------------------------------------------
    /// @notice Find the owner of AAC #`_tokenId`
    /// @dev throws if `_owner` is the zero address.
    /// @param _tokenId The identifier for an AAC
    /// @return The address of the owner of the AAC
    //-------------------------------------------------------------------------
    function ownerOf(uint256 _tokenId) 
        public 
        view 
        mustExist(_tokenId) 
        returns (address payable) 
    {
        // owner must not be the zero address
        require (aacArray[uidToAacIndex[_tokenId]].owner != address(0));
        return aacArray[uidToAacIndex[_tokenId]].owner;
    }

    //-------------------------------------------------------------------------
    /// @notice Count all AACs assigned to an owner
    /// @dev throws if `_owner` is the zero address.
    /// @param _owner An address to query
    /// @return The number of AACs owned by `_owner`, possibly zero
    //-------------------------------------------------------------------------
    function balanceOf(address _owner) 
        public 
        view 
        notZero(uint(_owner)) 
        returns (uint256) 
    {
        uint owned;
        for (uint i = 1; i < aacArray.length; ++i) {
            if(aacArray[i].owner == _owner) {
                ++owned;
            }
        }
        return owned;
    }

    //-------------------------------------------------------------------------
    /// @notice Get a list of AACs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid AACs.
    /// @param _owner Address to query for AACs.
    /// @return The complete list of Unique Indentifiers for AACs
    ///  assigned to `_owner`
    //-------------------------------------------------------------------------
    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        uint aacsOwned = balanceOf(_owner);
        require(aacsOwned > 0);
        uint counter = 0;
        uint[] memory result = new uint[](aacsOwned);
        for (uint i = 0; i < aacArray.length; i++) {
            if(aacArray[i].owner == _owner) {
                result[counter] = aacArray[i].uid;
                counter++;
            }
        }
        return result;
    }

    //-------------------------------------------------------------------------
    /// @notice Get number of AACs tracked by this contract
    /// @return A count of valid AACs tracked by this contract, where
    ///  each one has an assigned and queryable owner.
    //-------------------------------------------------------------------------
    function totalSupply() external view returns (uint256) {
        return (aacArray.length - 1);
    }

    //-------------------------------------------------------------------------
    /// @notice Get the UID of AAC with index number `index`.
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The UID for the #`_index` AAC in the AAC array.
    //-------------------------------------------------------------------------
    function tokenByIndex(uint256 _index) external view returns (uint256) {
        // index must correspond to an existing AAC
        require (_index > 0 && _index < aacArray.length);
        return (aacArray[_index].uid);
    }

    //-------------------------------------------------------------------------
    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner Address to query for AACs.
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The Unique Indentifier for the #`_index` AAC assigned to
    ///  `_owner`, (sort order not specified)
    //-------------------------------------------------------------------------
    function tokenOfOwnerByIndex(
        address _owner, 
        uint256 _index
    ) external view notZero(uint(_owner)) returns (uint256) {
        uint aacsOwned = balanceOf(_owner);
        require(aacsOwned > 0);
        require(_index < aacsOwned);
        uint counter = 0;
        for (uint i = 0; i < aacArray.length; i++) {
            if (aacArray[i].owner == _owner) {
                if (counter == _index) {
                    return(aacArray[i].uid);
                } else {
                    counter++;
                }
            }
        }
    }
}


//-----------------------------------------------------------------------------
/// @title Token Receiver Interface
//-----------------------------------------------------------------------------
interface TokenReceiverInterface {
    function onERC721Received(
        address _operator, 
        address _from, 
        uint256 _tokenId, 
        bytes calldata _data
    ) external returns(bytes4);
}


//-----------------------------------------------------------------------------
/// @title VIP-181 Interface
//-----------------------------------------------------------------------------
interface VIP181 {
    function transferFrom (
        address _from, 
        address _to, 
        uint256 _tokenId
    ) external payable;
    function ownerOf(uint _tokenId) external returns(address);
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function tokenURI(uint _tokenId) external view returns (string memory);
}


//-----------------------------------------------------------------------------
/// @title AAC Transfers
/// @notice Defines transfer functionality for AACs to transfer ownership.
///  Defines approval functionality for 3rd parties to enable transfers on
///  owners' behalf.
//-----------------------------------------------------------------------------
contract AacTransfers is AacOwnership {
    //-------------------------------------------------------------------------
    /// @dev Transfer emits when ownership of an AAC changes by any
    ///  mechanism. This event emits when AACs are created ('from' == 0).
    ///  At the time of any transfer, the approved address for that AAC
    ///  (if any) is reset to address(0).
    //-------------------------------------------------------------------------
    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 indexed _tokenId
    );

    //-------------------------------------------------------------------------
    /// @dev Approval emits when the approved address for an AAC is
    ///  changed or reaffirmed. The zero address indicates there is no approved
    ///  address. When a Transfer event emits, this also indicates that the
    ///  approved address for that AAC (if any) is reset to none.
    //-------------------------------------------------------------------------
    event Approval(
        address indexed _owner, 
        address indexed _approved, 
        uint256 indexed _tokenId
    );

    //-------------------------------------------------------------------------
    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all AACs of the owner.
    //-------------------------------------------------------------------------
    event ApprovalForAll(
        address indexed _owner, 
        address indexed _operator, 
        bool _approved
    );

    // Mapping from token ID to approved address
    mapping (uint => address) idToApprovedAddress;
    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) operatorApprovals;

    //-------------------------------------------------------------------------
    /// @dev Throws if called by any account other than token owner, approved
    ///  address, or authorized operator.
    //-------------------------------------------------------------------------
    modifier canOperate(uint _uid) {
        // sender must be owner of AAC #uid, or sender must be the
        //  approved address of AAC #uid, or an authorized operator for
        //  AAC owner
        require (
            msg.sender == aacArray[uidToAacIndex[_uid]].owner ||
            msg.sender == idToApprovedAddress[_uid] ||
            operatorApprovals[aacArray[uidToAacIndex[_uid]].owner][msg.sender]
        );
        _;
    }

    //-------------------------------------------------------------------------
    /// @notice Change or reaffirm the approved address for AAC #`_tokenId`.
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved AAC controller
    /// @param _tokenId The AAC to approve
    //-------------------------------------------------------------------------
    function approve(address _approved, uint256 _tokenId) external payable {
        address owner = ownerOf(_tokenId);
        // msg.sender must be the current NFT owner, or an authorized operator
        //  of the current owner.
        require (
            msg.sender == owner || isApprovedForAll(owner, msg.sender)
        );
        idToApprovedAddress[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if
    ///  there is none
    //-------------------------------------------------------------------------
    function getApproved(
        uint256 _tokenId
    ) external view mustExist(_tokenId) returns (address) {
        return idToApprovedAddress[_tokenId];
    }
    
    //-------------------------------------------------------------------------
    /// @notice Enable or disable approval for a third party ("operator") to
    ///  manage all of sender's AACs
    /// @dev Emits the ApprovalForAll event. The contract MUST allow multiple
    ///  operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke
    ///  approval
    //-------------------------------------------------------------------------
    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != msg.sender);
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Get whether '_operator' is approved to manage all of '_owner's
    ///  AACs
    /// @param _owner AAC Owner.
    /// @param _operator Address to check for approval.
    /// @return True if '_operator' is approved to manage all of '_owner's' AACs.
    //-------------------------------------------------------------------------
    function isApprovedForAll(
        address _owner, 
        address _operator
    ) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    
    //-------------------------------------------------------------------------
    /// @notice Transfers ownership of AAC #`_tokenId` from `_from` to 
    ///  `_to`
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, checks if
    ///  `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `0x150b7a02`. If AAC is linked to an external NFT, this function
    ///  calls TransferFrom from the external address. Throws if this contract
    ///  is not an approved operator for the external NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    //-------------------------------------------------------------------------
    function safeTransferFrom(address _from, address payable _to, uint256 _tokenId) 
        external 
        payable 
        mustExist(_tokenId) 
        canOperate(_tokenId) 
        notZero(uint(_to)) 
    {
        address owner = ownerOf(_tokenId);
        // _from address must be current owner of the AAC
        require (_from == owner);
               
        // if AAC has a linked external NFT, call TransferFrom on the 
        //  external NFT contract
        ExternalNft memory externalNft = uidToExternalNft[_tokenId];
        if (externalNft.nftContractAddress != address(0)) {
            // initialize external NFT contract
            VIP181 externalContract = VIP181(externalNft.nftContractAddress);
            // check that sender is authorized to transfer external NFT
            address nftOwner = externalContract.ownerOf(externalNft.nftId);
            if(
                msg.sender == nftOwner ||
                msg.sender == externalContract.getApproved(externalNft.nftId) ||
                externalContract.isApprovedForAll(nftOwner, msg.sender)
            ) {
                // call TransferFrom
                externalContract.transferFrom(_from, _to, externalNft.nftId);
            }
        }

        // clear approval
        idToApprovedAddress[_tokenId] = address(0);
        // transfer ownership
        aacArray[uidToAacIndex[_tokenId]].owner = _to;

        emit Transfer(_from, _to, _tokenId);

        // check and call onERC721Received. Throws and rolls back the transfer
        //  if _to does not implement the expected interface
        uint size;
        assembly { size := extcodesize(_to) }
        if (size > 0) {
            bytes4 retval = TokenReceiverInterface(_to).onERC721Received(msg.sender, _from, _tokenId, "");
            require(
                retval == 0x150b7a02
            );
        }
    }
    
    //-------------------------------------------------------------------------
    /// @notice Transfers ownership of AAC #`_tokenId` from `_from` to 
    ///  `_to`
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. If AAC is linked to an external
    ///  NFT, this function calls TransferFrom from the external address.
    ///  Throws if this contract is not an approved operator for the external
    ///  NFT. When transfer is complete, checks if `_to` is a smart contract
    ///  (code size > 0). If so, it calls `onERC721Received` on `_to` and
    ///  throws if the return value is not `0x150b7a02`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param _data Additional data with no pre-specified format
    //-------------------------------------------------------------------------
    function safeTransferFrom(
        address _from, 
        address payable _to, 
        uint256 _tokenId, 
        bytes calldata _data
    ) 
        external 
        payable 
        mustExist(_tokenId) 
        canOperate(_tokenId) 
        notZero(uint(_to)) 
    {
        address owner = ownerOf(_tokenId);
        // _from address must be current owner of the AAC
        require (_from == owner);
        
        // if AAC has a linked external NFT, call TransferFrom on the 
        //  external NFT contract
        ExternalNft memory externalNft = uidToExternalNft[_tokenId];
        if (externalNft.nftContractAddress != address(0)) {
            // initialize external NFT contract
            VIP181 externalContract = VIP181(externalNft.nftContractAddress);
            // check that sender is authorized to transfer external NFT
            address nftOwner = externalContract.ownerOf(externalNft.nftId);
            if(
                msg.sender == nftOwner ||
                msg.sender == externalContract.getApproved(externalNft.nftId) ||
                externalContract.isApprovedForAll(nftOwner, msg.sender)
            ) {
                // call TransferFrom
                externalContract.transferFrom(_from, _to, externalNft.nftId);
            }
        }

        // clear approval
        idToApprovedAddress[_tokenId] = address(0);
        // transfer ownership
        aacArray[uidToAacIndex[_tokenId]].owner = _to;

        emit Transfer(_from, _to, _tokenId);

        // check and call onERC721Received. Throws and rolls back the transfer
        //  if _to does not implement the expected interface
        uint size;
        assembly { size := extcodesize(_to) }
        if (size > 0) {
            bytes4 retval = TokenReceiverInterface(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
            require (retval == 0x150b7a02);
        }
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. If AAC is linked to an external
    ///  NFT, this function calls TransferFrom from the external address.
    ///  Throws if this contract is not an approved operator for the external
    ///  NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    //-------------------------------------------------------------------------
    function transferFrom(address _from, address payable _to, uint256 _tokenId)
        external 
        payable 
        mustExist(_tokenId) 
        canOperate(_tokenId) 
        notZero(uint(_to)) 
    {
        address owner = ownerOf(_tokenId);
        // _from address must be current owner of the AAC
        require (_from == owner && _from != address(0));
        
        // if AAC has a linked external NFT, call TransferFrom on the 
        //  external NFT contract
        ExternalNft memory externalNft = uidToExternalNft[_tokenId];
        if (externalNft.nftContractAddress != address(0)) {
            // initialize external NFT contract
            VIP181 externalContract = VIP181(externalNft.nftContractAddress);
            // check that sender is authorized to transfer external NFT
            address nftOwner = externalContract.ownerOf(externalNft.nftId);
            if(
                msg.sender == nftOwner ||
                msg.sender == externalContract.getApproved(externalNft.nftId) ||
                externalContract.isApprovedForAll(nftOwner, msg.sender)
            ) {
                // call TransferFrom
                externalContract.transferFrom(_from, _to, externalNft.nftId);
            }
        }

        // clear approval
        idToApprovedAddress[_tokenId] = address(0);
        // transfer ownership
        aacArray[uidToAacIndex[_tokenId]].owner = _to;

        emit Transfer(_from, _to, _tokenId);
    }
}

//-----------------------------------------------------------------------------
/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic 
///  authorization control functions, this simplifies the implementation of
///  "user permissions".
//-----------------------------------------------------------------------------
contract Ownable {
    //-------------------------------------------------------------------------
    /// @dev Emits when owner address changes by any mechanism.
    //-------------------------------------------------------------------------
    event OwnershipTransfer (address previousOwner, address newOwner);
    
    // Wallet address that can sucessfully execute onlyOwner functions
    address owner;
    
    //-------------------------------------------------------------------------
    /// @dev Sets the owner of the contract to the sender account.
    //-------------------------------------------------------------------------
    constructor() public {
        owner = msg.sender;
    }

    //-------------------------------------------------------------------------
    /// @dev Throws if called by any account other than `owner`.
    //-------------------------------------------------------------------------
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer control of the contract to a newOwner.
    /// @dev Throws if `_newOwner` is zero address.
    /// @param _newOwner The address to transfer ownership to.
    //-------------------------------------------------------------------------
    function transferOwnership(address _newOwner) public onlyOwner {
        // for safety, new owner parameter must not be 0
        require (_newOwner != address(0));
        // define local variable for old owner
        address oldOwner = owner;
        // set owner to new owner
        owner = _newOwner;
        // emit ownership transfer event
        emit OwnershipTransfer(oldOwner, _newOwner);
    }
}


//-----------------------------------------------------------------------------
/// @title ERC-165 Pseudo-Introspection Interface Support
/// @notice Defines supported interfaces
//-----------------------------------------------------------------------------
contract ERC165 {
    // mapping of all possible interfaces to whether they are supported
    mapping (bytes4 => bool) interfaceIdToIsSupported;
    
    bytes4 constant ERC_165 = 0x01ffc9a7;
    bytes4 constant ERC_721 = 0x80ac58cd;
    bytes4 constant ERC_721_ENUMERATION = 0x780e9d63;
    bytes4 constant ERC_721_METADATA = 0x5b5e139f;
    
    //-------------------------------------------------------------------------
    /// @notice AacInterfaceSupport constructor. Sets to true interfaces
    ///  supported at launch.
    //-------------------------------------------------------------------------
    constructor () public {
        // supports ERC-165
        interfaceIdToIsSupported[ERC_165] = true;
        // supports ERC-721
        interfaceIdToIsSupported[ERC_721] = true;
        // supports ERC-721 Enumeration
        interfaceIdToIsSupported[ERC_721_ENUMERATION] = true;
        // supports ERC-721 Metadata
        interfaceIdToIsSupported[ERC_721_METADATA] = true;
    }

    //-------------------------------------------------------------------------
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    //-------------------------------------------------------------------------
    function supportsInterface(
        bytes4 interfaceID
    ) external view returns (bool) {
        if(interfaceID == 0xffffffff) {
            return false;
        } else {
            return interfaceIdToIsSupported[interfaceID];
        }
    }
}


//-----------------------------------------------------------------------------
/// @title AAC Creation
/// @notice Defines new AAC creation (minting) and AAC linking to
///  RFID-enabled physical objects.
//-----------------------------------------------------------------------------
contract AacCreation is AacTransfers, ERC165, Ownable {
    //-------------------------------------------------------------------------
    /// @dev Link emits when an empty AAC gets assigned to a valid RFID.
    //-------------------------------------------------------------------------
    event Link(uint _oldUid, uint _newUid);

    address public creationHandlerContractAddress;
    // UID value is 7 bytes. Max value is 2**56 - 1
    uint constant UID_MAX = 0xFFFFFFFFFFFFFF;
    
    function setCreationHandlerContractAddress(address _creationHandlerAddress) 
    external 
    notZero(uint(_creationHandlerAddress))
    onlyOwner 
    {
        creationHandlerContractAddress = _creationHandlerAddress;
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer EHrTs to mint a new empty AAC for '_to'.
    /// @dev Sender must have approved this contract address as an authorized
    ///  spender with at least "priceToMint" tokens. Throws if the sender has
    ///  insufficient balance. Throws if sender has not granted this contract's
    ///  address sufficient allowance.
    /// @param _to The address to deduct EHrTs from and send new AAC to.
    //-------------------------------------------------------------------------
    function mintAndSend(address payable _to) external {
        require (msg.sender == creationHandlerContractAddress);

        uint uid = UID_MAX + aacArray.length + 1;
        uint index = aacArray.push(Aac(_to, uid, 0, 0, ""));
        uidToAacIndex[uid] = index - 1;

        emit Transfer(address(0), _to, uid);
    }

    //-------------------------------------------------------------------------
    /// @notice Change AAC #`_aacId` to AAC #`_newUid`. Writes any
    ///  data passed through '_data' into the AAC's public data.
    /// @dev Throws if AAC #`_aacId` does not exist. Throws if sender is
    ///  not approved to operate for AAC. Throws if '_aacId' is smaller
    ///  than 8 bytes. Throws if '_newUid' is bigger than 7 bytes. Throws if 
    ///  '_newUid' is zero. Throws if '_newUid' is already taken.
    /// @param _newUid The UID of the RFID chip to link to the AAC
    /// @param _aacId The UID of the empty AAC to link
    /// @param _data A byte string of data to attach to the AAC
    //-------------------------------------------------------------------------
    function link(
        bytes7 _newUid, 
        uint _currentUid, 
        bytes calldata _data
    ) external {
        require (msg.sender == creationHandlerContractAddress);
        Aac storage aac = aacArray[uidToAacIndex[_currentUid]];
        uint newUid = uint(uint56(_newUid));

        // set new UID's mapping to index to old UID's mapping
        uidToAacIndex[newUid] = uidToAacIndex[_currentUid];
        // reset old UID's mapping to index
        uidToAacIndex[_currentUid] = 0;
        // set AAC's UID to new UID
        aac.uid = newUid;
        // set any data
        aac.aacData = _data;
        // reset the timestamp
        aac.timestamp = now;
        // set new uid to externalNft
        if (uidToExternalNft[_currentUid].nftContractAddress != address(0)) {
            uidToExternalNft[newUid] = uidToExternalNft[_currentUid];
        }

        emit Link(_currentUid, newUid);
    }

    //-------------------------------------------------------------------------
    /// @notice Set external NFT #`_externalId` as AAC #`_aacUid`'s
    ///  linked external NFT.
    /// @dev Throws if sender is not authorized to operate AAC #`_aacUid`
    ///  Throws if external NFT is already linked. Throws if sender is not
    ///  authorized to operate external NFT.
    /// @param _aacUid The UID of the AAC to link
    /// @param _externalAddress The contract address of the external NFT
    /// @param _externalId The UID of the external NFT to link
    //-------------------------------------------------------------------------
    function linkExternalNft(
        uint _aacUid, 
        address _externalAddress, 
        uint _externalId
    ) external canOperate(_aacUid) {
        require (linkedExternalNfts[_externalAddress][_externalId] == false);
        require (ERC165(_externalAddress).supportsInterface(ERC_721));
        require (msg.sender == VIP181(_externalAddress).ownerOf(_externalId));
        uidToExternalNft[_aacUid] = ExternalNft(_externalAddress, _externalId);
        linkedExternalNfts[_externalAddress][_externalId] = true;
    }
    
    //-------------------------------------------------------------------------
    /// @notice Gets whether or not an AAC #`_uid` exists.
    //-------------------------------------------------------------------------
    function checkExists(uint _tokenId) external view returns(bool) {
        return (uidToAacIndex[_tokenId] != 0);
    }
}


//-----------------------------------------------------------------------------
/// @title AAC Experience
/// @notice Defines AAC exp increaser contract and function
//-----------------------------------------------------------------------------
contract AacExperience is AacCreation {
    address public expIncreaserContractAddress;

    function setExpIncreaserContractAddress(address _expAddress) 
    external 
    notZero(uint(_expAddress))
    onlyOwner 
    {
        expIncreaserContractAddress = _expAddress;
    }
    
    function addExp(uint _uid, uint _amount) external mustExist(_uid) {
        require (msg.sender == expIncreaserContractAddress);
        aacArray[uidToAacIndex[_uid]].exp += _amount;
    }
}


//-----------------------------------------------------------------------------
/// @title AAC Interface
/// @notice Interface for highest-level AAC getters
//-----------------------------------------------------------------------------
contract AacInterface is AacExperience {
    // URL Containing AAC metadata
    string metadataUrl;

    //-------------------------------------------------------------------------
    /// @notice Change old metadata URL to `_newUrl`
    /// @dev Throws if new URL is empty
    /// @param _newUrl The new URL containing AAC metadata
    //-------------------------------------------------------------------------
    function updateMetadataUrl(string calldata _newUrl)
        external 
        onlyOwner 
        notZero(bytes(_newUrl).length)
    {
        metadataUrl = _newUrl;
    }

    //-------------------------------------------------------------------------
    /// @notice Sets all data for AAC #`_uid`.
    /// @dev Throws if AAC #`_uid` does not exist. Throws if not authorized to
    ///  operate AAC.
    /// @param _uid the UID of the AAC to change.
    //-------------------------------------------------------------------------
    function changeAacData(uint _uid, bytes calldata _data) 
        external 
        mustExist(_uid)
        canOperate(_uid)
    {
        aacArray[uidToAacIndex[_uid]].aacData = _data;
    }

    //-------------------------------------------------------------------------
    /// @notice Gets all public info for AAC #`_uid`.
    /// @dev Throws if AAC #`_uid` does not exist.
    /// @param _uid the UID of the AAC to view.
    /// @return AAC owner, AAC UID, Creation Timestamp, Experience,
    ///  and Public Data.
    //-------------------------------------------------------------------------
    function getAac(uint _uid) 
        external
        view 
        mustExist(_uid) 
        returns (address, uint, uint, uint, bytes memory) 
    {
        Aac memory aac = aacArray[uidToAacIndex[_uid]];
        return(aac.owner, aac.uid, aac.timestamp, aac.exp, aac.aacData);
    }

    //-------------------------------------------------------------------------
    /// @notice Gets all info for AAC #`_uid`'s linked NFT.
    /// @dev Throws if AAC #`_uid` does not exist.
    /// @param _uid the UID of the AAC to view.
    /// @return NFT contract address, External NFT ID.
    //-------------------------------------------------------------------------
    function getLinkedNft(uint _uid) 
        external
        view 
        mustExist(_uid) 
        returns (address, uint) 
    {
        ExternalNft memory nft = uidToExternalNft[_uid];
        return (nft.nftContractAddress, nft.nftId);
    }

    //-------------------------------------------------------------------------
    /// @notice Gets whether NFT #`_externalId` is linked to an AAC.
    /// @param _externalAddress the contract address for the external NFT
    /// @param _externalId the UID of the external NFT to view.
    /// @return NFT contract address, External NFT ID.
    //-------------------------------------------------------------------------
    function externalNftIsLinked(address _externalAddress, uint _externalId)
        external
        view
        returns(bool)
    {
        return linkedExternalNfts[_externalAddress][_externalId];
    }

    //-------------------------------------------------------------------------
    /// @notice A descriptive name for a collection of NFTs in this contract
    //-------------------------------------------------------------------------
    function name() external pure returns (string memory) {
        return "Authentic Asset Certificates";
    }

    //-------------------------------------------------------------------------
    /// @notice An abbreviated name for NFTs in this contract
    //-------------------------------------------------------------------------
    function symbol() external pure returns (string memory) { return "AAC"; }

    //-------------------------------------------------------------------------
    /// @notice A distinct URL for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT.
    ///  If:
    ///  * The URI is a URL
    ///  * The URL is accessible
    ///  * The URL points to a valid JSON file format (ECMA-404 2nd ed.)
    ///  * The JSON base element is an object
    ///  then these names of the base element SHALL have special meaning:
    ///  * "name": A string identifying the item to which `_tokenId` grants
    ///    ownership
    ///  * "description": A string detailing the item to which `_tokenId`
    ///    grants ownership
    ///  * "image": A URI pointing to a file of image/* mime type representing
    ///    the item to which `_tokenId` grants ownership
    ///  Wallets and exchanges MAY display this to the end user.
    ///  Consider making any images at a width between 320 and 1080 pixels and
    ///  aspect ratio between 1.91:1 and 4:5 inclusive.
    /// @param _tokenId The AAC whose metadata address is being queried
    //-------------------------------------------------------------------------
    function tokenURI(uint _tokenId) external view returns (string memory) {
        if (uidToExternalNft[_tokenId].nftContractAddress != address(0) && 
            ERC165(uidToExternalNft[_tokenId].nftContractAddress).supportsInterface(ERC_721_METADATA)) 
        {
            return VIP181(uidToExternalNft[_tokenId].nftContractAddress).tokenURI(_tokenId);
        }
        else {
            // convert AAC UID to a 14 character long string of character bytes
            bytes memory uidString = intToBytes(_tokenId);
            // declare new string of bytes with combined length of url and uid 
            bytes memory fullUrlBytes = new bytes(bytes(metadataUrl).length + uidString.length);
            // copy URL string and uid string into new string
            uint counter = 0;
            for (uint i = 0; i < bytes(metadataUrl).length; i++) {
                fullUrlBytes[counter++] = bytes(metadataUrl)[i];
            }
            for (uint i = 0; i < uidString.length; i++) {
                fullUrlBytes[counter++] = uidString[i];
            }
            // return full URL
            return string(fullUrlBytes);
        }
    }
    
    //-------------------------------------------------------------------------
    /// @notice Convert int to 14 character bytes
    //-------------------------------------------------------------------------
    function intToBytes(uint _tokenId) 
        private 
        pure 
        returns (bytes memory) 
    {
        // convert int to bytes32
        bytes32 x = bytes32(_tokenId);
        
        // convert each byte into two, and assign each byte a hex digit
        bytes memory uidBytes64 = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            byte b = byte(x[i]);
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            uidBytes64[i*2] = char(hi);
            uidBytes64[i*2+1] = char(lo);
        }
        
        // reduce size to last 14 chars (7 bytes)
        bytes memory uidBytes = new bytes(14);
        for (uint i = 0; i < 14; ++i) {
            uidBytes[i] = uidBytes64[i + 50];
        }
        return uidBytes;
    }
    
    //-------------------------------------------------------------------------
    /// @notice Convert byte to UTF-8-encoded hex character
    //-------------------------------------------------------------------------
    function char(byte b) private pure returns (byte c) {
        if (uint8(b) < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
}
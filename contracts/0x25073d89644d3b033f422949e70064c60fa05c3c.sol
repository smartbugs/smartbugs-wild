pragma solidity ^0.4.24;

//-----------------------------------------------------------------------------
/// @title TOY Ownership
/// @notice defines TOY Token ownership-tracking structures and view functions.
//-----------------------------------------------------------------------------
contract ToyOwnership {
    struct ToyToken {
        // owner ID list
        address owner;
        // unique identifier
        uint uid;
        // timestamp
        uint timestamp;
        // exp
        uint exp;
        // toy data
        bytes toyData;
    }

    struct ExternalNft{
        // Contract address
        address nftContractAddress;
        // Token Identifier
        uint nftId;
    }

    // Array containing all TOY Tokens. The first element in toyArray returns
    //  as invalid
    ToyToken[] toyArray;
    // Mapping containing all UIDs tracked by this contract. Valid UIDs map to
    //  index numbers, invalid UIDs map to 0.
    mapping (uint => uint) uidToToyIndex;
    // Mapping containing linked external NFTs. Linked TOY Tokens always map to
    //  non-zero numbers, invalid TOY Tokens map to 0.
    mapping (uint => ExternalNft) uidToExternalNft;
    // Mapping containing tokens IDs for tokens created by an external contract
    //  and whether or not it is linked to a TOY Token 
    mapping (address => mapping (uint => bool)) linkedExternalNfts;
    
    //-------------------------------------------------------------------------
    /// @dev Throws if TOY Token #`_tokenId` isn't tracked by the toyArray.
    //-------------------------------------------------------------------------
    modifier mustExist(uint _tokenId) {
        require (uidToToyIndex[_tokenId] != 0, "Invalid TOY Token UID");
        _;
    }

    //-------------------------------------------------------------------------
    /// @dev Throws if TOY Token #`_tokenId` isn't owned by sender.
    //-------------------------------------------------------------------------
    modifier mustOwn(uint _tokenId) {
        require 
        (
            ownerOf(_tokenId) == msg.sender, 
            "Must be owner of this TOY Token"
        );
        _;
    }

    //-------------------------------------------------------------------------
    /// @dev Throws if parameter is zero
    //-------------------------------------------------------------------------
    modifier notZero(uint _param) {
        require(_param != 0, "Parameter cannot be zero");
        _;
    }

    //-------------------------------------------------------------------------
    /// @dev Creates an empty TOY Token as a [0] placeholder for invalid TOY 
    ///  Token queries.
    //-------------------------------------------------------------------------
    constructor () public {
        toyArray.push(ToyToken(0,0,0,0,""));
    }

    //-------------------------------------------------------------------------
    /// @notice Find the owner of TOY Token #`_tokenId`
    /// @dev throws if `_owner` is the zero address.
    /// @param _tokenId The identifier for a TOY Token
    /// @return The address of the owner of the TOY Token
    //-------------------------------------------------------------------------
    function ownerOf(uint256 _tokenId) 
        public 
        view 
        mustExist(_tokenId) 
        returns (address) 
    {
        // owner must not be the zero address
        require (
            toyArray[uidToToyIndex[_tokenId]].owner != 0, 
            "TOY Token has no owner"
        );
        return toyArray[uidToToyIndex[_tokenId]].owner;
    }

    //-------------------------------------------------------------------------
    /// @notice Count all TOY Tokens assigned to an owner
    /// @dev throws if `_owner` is the zero address.
    /// @param _owner An address to query
    /// @return The number of TOY Tokens owned by `_owner`, possibly zero
    //-------------------------------------------------------------------------
    function balanceOf(address _owner) 
        public 
        view 
        notZero(uint(_owner)) 
        returns (uint256) 
    {
        uint owned;
        for (uint i = 1; i < toyArray.length; ++i) {
            if(toyArray[i].owner == _owner) {
                ++owned;
            }
        }
        return owned;
    }

    //-------------------------------------------------------------------------
    /// @notice Get a list of TOY Tokens assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid TOY Tokens.
    /// @param _owner Address to query for TOY Tokens.
    /// @return The complete list of Unique Indentifiers for TOY Tokens
    ///  assigned to `_owner`
    //-------------------------------------------------------------------------
    function tokensOfOwner(address _owner) external view returns (uint[]) {
        uint toysOwned = balanceOf(_owner);
        require(toysOwned > 0, "No owned TOY Tokens");
        uint counter = 0;
        uint[] memory result = new uint[](toysOwned);
        for (uint i = 0; i < toyArray.length; i++) {
            if(toyArray[i].owner == _owner) {
                result[counter] = toyArray[i].uid;
                counter++;
            }
        }
        return result;
    }

    //-------------------------------------------------------------------------
    /// @notice Get number of TOY Tokens tracked by this contract
    /// @return A count of valid TOY Tokens tracked by this contract, where
    ///  each one has an assigned and queryable owner.
    //-------------------------------------------------------------------------
    function totalSupply() external view returns (uint256) {
        return (toyArray.length - 1);
    }

    //-------------------------------------------------------------------------
    /// @notice Get the UID of TOY Token with index number `index`.
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The UID for the #`_index` TOY Token in the TOY Token array.
    //-------------------------------------------------------------------------
    function tokenByIndex(uint256 _index) external view returns (uint256) {
        // index must correspond to an existing TOY Token
        require (_index > 0 && _index < toyArray.length, "Invalid index");
        return (toyArray[_index].uid);
    }

    //-------------------------------------------------------------------------
    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner Address to query for TOY Tokens.
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The Unique Indentifier for the #`_index` TOY Token assigned to
    ///  `_owner`, (sort order not specified)
    //-------------------------------------------------------------------------
    function tokenOfOwnerByIndex(
        address _owner, 
        uint256 _index
    ) external view notZero(uint(_owner)) returns (uint256) {
        uint toysOwned = balanceOf(_owner);
        require(toysOwned > 0, "No owned TOY Tokens");
        require(_index < toysOwned, "Invalid index");
        uint counter = 0;
        for (uint i = 0; i < toyArray.length; i++) {
            if (toyArray[i].owner == _owner) {
                if (counter == _index) {
                    return(toyArray[i].uid);
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
        bytes _data
    ) external returns(bytes4);
}


//-----------------------------------------------------------------------------
/// @title ERC721 Interface
//-----------------------------------------------------------------------------
interface ERC721 {
    function transferFrom (
        address _from, 
        address _to, 
        uint256 _tokenId
    ) external payable;
    function ownerOf(uint _tokenId) external returns(address);
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}


//-----------------------------------------------------------------------------
/// @title TOY Transfers
/// @notice Defines transfer functionality for TOY Tokens to transfer ownership.
///  Defines approval functionality for 3rd parties to enable transfers on
///  owners' behalf.
//-----------------------------------------------------------------------------
contract ToyTransfers is ToyOwnership {
    //-------------------------------------------------------------------------
    /// @dev Transfer emits when ownership of a TOY Token changes by any
    ///  mechanism. This event emits when TOY Tokens are created ('from' == 0).
    ///  At the time of any transfer, the approved address for that TOY Token
    ///  (if any) is reset to address(0).
    //-------------------------------------------------------------------------
    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 indexed _tokenId
    );

    //-------------------------------------------------------------------------
    /// @dev Approval emits when the approved address for a TOY Token is
    ///  changed or reaffirmed. The zero address indicates there is no approved
    ///  address. When a Transfer event emits, this also indicates that the
    ///  approved address for that TOY Token (if any) is reset to none.
    //-------------------------------------------------------------------------
    event Approval(
        address indexed _owner, 
        address indexed _approved, 
        uint256 indexed _tokenId
    );

    //-------------------------------------------------------------------------
    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all TOY Tokens of the owner.
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
        // sender must be owner of TOY Token #uid, or sender must be the
        //  approved address of TOY Token #uid, or an authorized operator for
        //  TOY Token owner
        require (
            msg.sender == toyArray[uidToToyIndex[_uid]].owner ||
            msg.sender == idToApprovedAddress[_uid] ||
            operatorApprovals[toyArray[uidToToyIndex[_uid]].owner][msg.sender],
            "Not authorized to operate for this TOY Token"
        );
        _;
    }

    //-------------------------------------------------------------------------
    /// @notice Change or reaffirm the approved address for TOY Token #`_tokenId`.
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved TOY Token controller
    /// @param _tokenId The TOY Token to approve
    //-------------------------------------------------------------------------
    function approve(address _approved, uint256 _tokenId) external payable {
        address owner = ownerOf(_tokenId);
        // msg.sender must be the current NFT owner, or an authorized operator
        //  of the current owner.
        require (
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "Not authorized to approve for this TOY Token"
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
    ///  manage all of sender's TOY Tokens
    /// @dev Emits the ApprovalForAll event. The contract MUST allow multiple
    ///  operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke
    ///  approval
    //-------------------------------------------------------------------------
    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != msg.sender, "Operator cannot be sender");
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Get whether '_operator' is approved to manage all of '_owner's
    ///  TOY Tokens
    /// @param _owner TOY Token Owner.
    /// @param _operator Address to check for approval.
    /// @return True if '_operator' is approved to manage all of '_owner's' TOY
    ///  Tokens.
    //-------------------------------------------------------------------------
    function isApprovedForAll(
        address _owner, 
        address _operator
    ) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    
    //-------------------------------------------------------------------------
    /// @notice Transfers ownership of TOY Token #`_tokenId` from `_from` to 
    ///  `_to`
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, checks if
    ///  `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `0x150b7a02`. If TOY Token is linked to an external NFT, this function
    ///  calls TransferFrom from the external address. Throws if this contract
    ///  is not an approved operator for the external NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    //-------------------------------------------------------------------------
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) 
        external 
        payable 
        mustExist(_tokenId) 
        canOperate(_tokenId) 
        notZero(uint(_to)) 
    {
        address owner = ownerOf(_tokenId);
        // _from address must be current owner of the TOY Token
        require (
            _from == owner, 
            "TOY Token not owned by '_from'"
        );
               
        // if TOY Token has a linked external NFT, call TransferFrom on the 
        //  external NFT contract
        ExternalNft memory externalNft = uidToExternalNft[_tokenId];
        if (externalNft.nftContractAddress != 0) {
            // initialize external NFT contract
            ERC721 externalContract = ERC721(externalNft.nftContractAddress);
            // call TransferFrom
            externalContract.transferFrom(_from, _to, externalNft.nftId);
        }

        // clear approval
        idToApprovedAddress[_tokenId] = 0;
        // transfer ownership
        toyArray[uidToToyIndex[_tokenId]].owner = _to;

        emit Transfer(_from, _to, _tokenId);

        // check and call onERC721Received. Throws and rolls back the transfer
        //  if _to does not implement the expected interface
        uint size;
        assembly { size := extcodesize(_to) }
        if (size > 0) {
            bytes4 retval = TokenReceiverInterface(_to).onERC721Received(msg.sender, _from, _tokenId, "");
            require(
                retval == 0x150b7a02, 
                "Destination contract not equipped to receive TOY Tokens"
            );
        }
    }
    
    //-------------------------------------------------------------------------
    /// @notice Transfers ownership of TOY Token #`_tokenId` from `_from` to 
    ///  `_to`
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. If TOY Token is linked to an external
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
        address _to, 
        uint256 _tokenId, 
        bytes _data
    ) 
        external 
        payable 
        mustExist(_tokenId) 
        canOperate(_tokenId) 
        notZero(uint(_to)) 
    {
        address owner = ownerOf(_tokenId);
        // _from address must be current owner of the TOY Token
        require (
            _from == owner, 
            "TOY Token not owned by '_from'"
        );
        
        // if TOY Token has a linked external NFT, call TransferFrom on the 
        //  external NFT contract
        ExternalNft memory externalNft = uidToExternalNft[_tokenId];
        if (externalNft.nftContractAddress != 0) {
            // initialize external NFT contract
            ERC721 externalContract = ERC721(externalNft.nftContractAddress);
            // call TransferFrom
            externalContract.transferFrom(_from, _to, externalNft.nftId);
        }

        // clear approval
        idToApprovedAddress[_tokenId] = 0;
        // transfer ownership
        toyArray[uidToToyIndex[_tokenId]].owner = _to;

        emit Transfer(_from, _to, _tokenId);

        // check and call onERC721Received. Throws and rolls back the transfer
        //  if _to does not implement the expected interface
        uint size;
        assembly { size := extcodesize(_to) }
        if (size > 0) {
            bytes4 retval = TokenReceiverInterface(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
            require(
                retval == 0x150b7a02,
                "Destination contract not equipped to receive TOY Tokens"
            );
        }
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. If TOY Token is linked to an external
    ///  NFT, this function calls TransferFrom from the external address.
    ///  Throws if this contract is not an approved operator for the external
    ///  NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    //-------------------------------------------------------------------------
    function transferFrom(address _from, address _to, uint256 _tokenId)
        external 
        payable 
        mustExist(_tokenId) 
        canOperate(_tokenId) 
        notZero(uint(_to)) 
    {
        address owner = ownerOf(_tokenId);
        // _from address must be current owner of the TOY Token
        require (
            _from == owner && _from != 0, 
            "TOY Token not owned by '_from'"
        );
        
        // if TOY Token has a linked external NFT, call TransferFrom on the 
        //  external NFT contract
        ExternalNft memory externalNft = uidToExternalNft[_tokenId];
        if (externalNft.nftContractAddress != 0) {
            // initialize external NFT contract
            ERC721 externalContract = ERC721(externalNft.nftContractAddress);
            // call TransferFrom
            externalContract.transferFrom(_from, _to, externalNft.nftId);
        }

        // clear approval
        idToApprovedAddress[_tokenId] = 0;
        // transfer ownership
        toyArray[uidToToyIndex[_tokenId]].owner = _to;

        emit Transfer(_from, _to, _tokenId);
    }
}


//-----------------------------------------------------------------------------
///@title ERC-20 function declarations
//-----------------------------------------------------------------------------
interface ERC20 {
    function transfer (
        address to, 
        uint tokens
    ) external returns (bool success);

    function transferFrom (
        address from, 
        address to, 
        uint tokens
    ) external returns (bool success);
}


//-----------------------------------------------------------------------------
/// @title External Token Handler
/// @notice Defines depositing and withdrawal of Ether and ERC-20-compliant
///  tokens into TOY Tokens.
//-----------------------------------------------------------------------------
contract ExternalTokenHandler is ToyTransfers {
    // handles the balances of TOY Tokens for every ERC20 token address
    mapping (address => mapping(uint => uint)) externalTokenBalances;
    
    // UID value is 7 bytes. Max value is 2**56 - 1
    uint constant UID_MAX = 0xFFFFFFFFFFFFFF;

    //-------------------------------------------------------------------------
    /// @notice Deposit Ether from sender to approved TOY Token
    /// @dev Throws if Ether to deposit is zero. Throws if sender is not
    ///  approved to operate TOY Token #`toUid`. Throws if TOY Token #`toUid`
    ///  is unlinked. Throws if sender has insufficient balance for deposit.
    /// @param _toUid the TOY Token to deposit the Ether into
    //-------------------------------------------------------------------------
    function depositEther(uint _toUid) 
        external 
        payable 
        canOperate(_toUid)
        notZero(msg.value)
    {
        // TOY Token must be linked
        require (
            _toUid < UID_MAX, 
            "Invalid TOY Token. TOY Token not yet linked"
        );
        // add amount to TOY Token's balance
        externalTokenBalances[address(this)][_toUid] += msg.value;
    }

    //-------------------------------------------------------------------------
    /// @notice Withdraw Ether from approved TOY Token to TOY Token's owner
    /// @dev Throws if Ether to withdraw is zero. Throws if sender is not an
    ///  approved operator for TOY Token #`_fromUid`. Throws if TOY Token 
    ///  #`_fromUid` has insufficient balance to withdraw.
    /// @param _fromUid the TOY Token to withdraw the Ether from
    /// @param _amount the amount of Ether to withdraw (in Wei)
    //-------------------------------------------------------------------------
    function withdrawEther(
        uint _fromUid, 
        uint _amount
    ) external canOperate(_fromUid) notZero(_amount) {
        // TOY Token must have sufficient Ether balance
        require (
            externalTokenBalances[address(this)][_fromUid] >= _amount,
            "Insufficient Ether to withdraw"
        );
        // subtract amount from TOY Token's balance
        externalTokenBalances[address(this)][_fromUid] -= _amount;
        // call transfer function
        ownerOf(_fromUid).transfer(_amount);
    }

    //-------------------------------------------------------------------------
    /// @notice Withdraw Ether from approved TOY Token and send to '_to'
    /// @dev Throws if Ether to transfer is zero. Throws if sender is not an
    ///  approved operator for TOY Token #`to_fromUidUid`. Throws if TOY Token
    ///  #`_fromUid` has insufficient balance to withdraw.
    /// @param _fromUid the TOY Token to withdraw and send the Ether from
    /// @param _to the address to receive the transferred Ether
    /// @param _amount the amount of Ether to withdraw (in Wei)
    //-------------------------------------------------------------------------
    function transferEther(
        uint _fromUid,
        address _to,
        uint _amount
    ) external canOperate(_fromUid) notZero(_amount) {
        // TOY Token must have sufficient Ether balance
        require (
            externalTokenBalances[address(this)][_fromUid] >= _amount,
            "Insufficient Ether to transfer"
        );
        // subtract amount from TOY Token's balance
        externalTokenBalances[address(this)][_fromUid] -= _amount;
        // call transfer function
        _to.transfer(_amount);
    }

    //-------------------------------------------------------------------------
    /// @notice Deposit ERC-20 tokens from sender to approved TOY Token
    /// @dev This contract address must be an authorized spender for sender.
    ///  Throws if tokens to deposit is zero. Throws if sender is not an
    ///  approved operator for TOY Token #`toUid`. Throws if TOY Token #`toUid`
    ///  is unlinked. Throws if this contract address has insufficient
    ///  allowance for transfer. Throws if sender has insufficient balance for 
    ///  deposit. Throws if tokenAddress has no transferFrom function.
    /// @param _tokenAddress the ERC-20 contract address
    /// @param _toUid the TOY Token to deposit the ERC-20 tokens into
    /// @param _tokens the number of tokens to deposit
    //-------------------------------------------------------------------------
    function depositERC20 (
        address _tokenAddress, 
        uint _toUid, 
        uint _tokens
    ) external canOperate(_toUid) notZero(_tokens) {
        // TOY Token must be linked
        require (_toUid < UID_MAX, "Invalid TOY Token. TOY Token not yet linked");
        // initialize token contract
        ERC20 tokenContract = ERC20(_tokenAddress);
        // add amount to TOY Token's balance
        externalTokenBalances[_tokenAddress][_toUid] += _tokens;

        // call transferFrom function from token contract
        tokenContract.transferFrom(msg.sender, address(this), _tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Deposit ERC-20 tokens from '_to' to approved TOY Token
    /// @dev This contract address must be an authorized spender for '_from'.
    ///  Throws if tokens to deposit is zero. Throws if sender is not an
    ///  approved operator for TOY Token #`toUid`. Throws if TOY Token #`toUid`
    ///  is unlinked. Throws if this contract address has insufficient
    ///  allowance for transfer. Throws if sender has insufficient balance for
    ///  deposit. Throws if tokenAddress has no transferFrom function.
    /// @param _tokenAddress the ERC-20 contract address
    /// @param _from the address sending ERC-21 tokens to deposit
    /// @param _toUid the TOY Token to deposit the ERC-20 tokens into
    /// @param _tokens the number of tokens to deposit
    //-------------------------------------------------------------------------
    function depositERC20From (
        address _tokenAddress,
        address _from, 
        uint _toUid, 
        uint _tokens
    ) external canOperate(_toUid) notZero(_tokens) {
        // TOY Token must be linked
        require (
            _toUid < UID_MAX, 
            "Invalid TOY Token. TOY Token not yet linked"
        );
        // initialize token contract
        ERC20 tokenContract = ERC20(_tokenAddress);
        // add amount to TOY Token's balance
        externalTokenBalances[_tokenAddress][_toUid] += _tokens;

        // call transferFrom function from token contract
        tokenContract.transferFrom(_from, address(this), _tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Withdraw ERC-20 tokens from approved TOY Token to TOY Token's
    ///  owner
    /// @dev Throws if tokens to withdraw is zero. Throws if sender is not an
    ///  approved operator for TOY Token #`_fromUid`. Throws if TOY Token 
    ///  #`_fromUid` has insufficient balance to withdraw. Throws if 
    ///  tokenAddress has no transfer function.
    /// @param _tokenAddress the ERC-20 contract address
    /// @param _fromUid the TOY Token to withdraw the ERC-20 tokens from
    /// @param _tokens the number of tokens to withdraw
    //-------------------------------------------------------------------------
    function withdrawERC20 (
        address _tokenAddress, 
        uint _fromUid, 
        uint _tokens
    ) external canOperate(_fromUid) notZero(_tokens) {
        // TOY Token must have sufficient token balance
        require (
            externalTokenBalances[_tokenAddress][_fromUid] >= _tokens,
            "insufficient tokens to withdraw"
        );
        // initialize token contract
        ERC20 tokenContract = ERC20(_tokenAddress);
        // subtract amount from TOY Token's balance
        externalTokenBalances[_tokenAddress][_fromUid] -= _tokens;
        
        // call transfer function from token contract
        tokenContract.transfer(ownerOf(_fromUid), _tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer ERC-20 tokens from your TOY Token to `_to`
    /// @dev Throws if tokens to transfer is zero. Throws if sender is not an
    ///  approved operator for TOY Token #`_fromUid`. Throws if TOY Token 
    ///  #`_fromUid` has insufficient balance to transfer. Throws if 
    ///  tokenAddress has no transfer function.
    /// @param _tokenAddress the ERC-20 contract address
    /// @param _fromUid the TOY Token to withdraw the ERC-20 tokens from
    /// @param _to the wallet address to send the ERC-20 tokens
    /// @param _tokens the number of tokens to withdraw
    //-------------------------------------------------------------------------
    function transferERC20 (
        address _tokenAddress, 
        uint _fromUid, 
        address _to, 
        uint _tokens
    ) external canOperate(_fromUid) notZero(_tokens) {
        // TOY Token must have sufficient token balance
        require (
            externalTokenBalances[_tokenAddress][_fromUid] >= _tokens,
            "insufficient tokens to withdraw"
        );
        // initialize token contract
        ERC20 tokenContract = ERC20(_tokenAddress);
        // subtract amount from TOY Token's balance
        externalTokenBalances[_tokenAddress][_fromUid] -= _tokens;
        
        // call transfer function from token contract
        tokenContract.transfer(_to, _tokens);
    }

    //-------------------------------------------------------------------------
    /// @notice Get external token balance for tokens deposited into TOY Token
    ///  #`_uid`.
    /// @dev To query Ether, use THIS CONTRACT'S address as '_tokenAddress'.
    /// @param _uid Owner of the tokens to query
    /// @param _tokenAddress Token creator contract address 
    //-------------------------------------------------------------------------
    function getExternalTokenBalance(
        uint _uid, 
        address _tokenAddress
    ) external view returns (uint) {
        return externalTokenBalances[_tokenAddress][_uid];
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
        emit OwnershipTransfer(address(0), owner);
    }

    //-------------------------------------------------------------------------
    /// @dev Throws if called by any account other than `owner`.
    //-------------------------------------------------------------------------
    modifier onlyOwner() {
        require(
            msg.sender == owner, 
            "Function can only be called by contract owner"
        );
        _;
    }

    //-------------------------------------------------------------------------
    /// @notice Transfer control of the contract to a newOwner.
    /// @dev Throws if `_newOwner` is zero address.
    /// @param _newOwner The address to transfer ownership to.
    //-------------------------------------------------------------------------
    function transferOwnership(address _newOwner) public onlyOwner {
        // for safety, new owner parameter must not be 0
        require (
            _newOwner != address(0),
            "New owner address cannot be zero"
        );
        // define local variable for old owner
        address oldOwner = owner;
        // set owner to new owner
        owner = _newOwner;
        // emit ownership transfer event
        emit OwnershipTransfer(oldOwner, _newOwner);
    }
}


//-----------------------------------------------------------------------------
/// @title TOY Token Interface Support
/// @notice Defines supported interfaces for ERC-721 wallets to query
//-----------------------------------------------------------------------------
contract ToyInterfaceSupport {
    // mapping of all possible interfaces to whether they are supported
    mapping (bytes4 => bool) interfaceIdToIsSupported;
    
    //-------------------------------------------------------------------------
    /// @notice ToyInterfaceSupport constructor. Sets to true interfaces
    ///  supported at launch.
    //-------------------------------------------------------------------------
    constructor () public {
        // supports ERC-165
        interfaceIdToIsSupported[0x01ffc9a7] = true;
        // supports ERC-721
        interfaceIdToIsSupported[0x80ac58cd] = true;
        // supports ERC-721 Enumeration
        interfaceIdToIsSupported[0x780e9d63] = true;
        // supports ERC-721 Metadata
        interfaceIdToIsSupported[0x5b5e139f] = true;
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
/// @title PLAY Token Interface
//-----------------------------------------------------------------------------
interface PlayInterface {
    //-------------------------------------------------------------------------
    /// @notice Get the number of PLAY tokens owned by `tokenOwner`.
    /// @dev Throws if trying to query the zero address.
    /// @param tokenOwner The PLAY token owner.
    /// @return The number of PLAY tokens owned by `tokenOwner` (in pWei).
    //-------------------------------------------------------------------------
    function balanceOf(address tokenOwner) external view returns (uint);
    
    //-------------------------------------------------------------------------
    /// @notice Lock `(tokens/1000000000000000000).fixed(0,18)` PLAY from 
    ///  `from` for `numberOfYears` years.
    /// @dev Throws if amount to lock is zero. Throws if numberOfYears is zero
    ///  or greater than maximumLockYears. Throws if `msg.sender` has
    ///  insufficient allowance to lock. Throws if `from` has insufficient
    ///  balance to lock.
    /// @param from The token owner whose PLAY is being locked. Sender must be
    ///  an approved spender.
    /// @param numberOfYears The number of years the tokens will be locked.
    /// @param tokens The number of tokens to lock (in pWei).
    //-------------------------------------------------------------------------
    function lockFrom(address from, uint numberOfYears, uint tokens) 
        external
        returns(bool); 
}


//-----------------------------------------------------------------------------
/// @title TOY Token Creation
/// @notice Defines new TOY Token creation (minting) and TOY Token linking to
///  RFID-enabled physical objects.
//-----------------------------------------------------------------------------
contract ToyCreation is Ownable, ExternalTokenHandler, ToyInterfaceSupport {
    //-------------------------------------------------------------------------
    /// @dev Link emits when an empty TOY Token gets assigned to a valid RFID.
    //-------------------------------------------------------------------------
    event Link(uint _oldUid, uint _newUid);

    // PLAY needed to mint one TOY Token (in pWei)
    uint public priceToMint = 1000 * 10**18;
    // Buffer added to the front of every TOY Token at time of creation. TOY
    //  Tokens with a uid greater than the buffer are unlinked.
    uint constant uidBuffer = 0x0100000000000000; // 14 zeroes
    // PLAY Token Contract object to interface with.
    PlayInterface play = PlayInterface(0xe2427cfEB5C330c007B8599784B97b65b4a3A819);

    //-------------------------------------------------------------------------
    /// @notice Update PLAY Token contract variable with new contract address.
    /// @dev Throws if `_newAddress` is the zero address.
    /// @param _newAddress Updated contract address.
    //-------------------------------------------------------------------------
    function updatePlayTokenContract(address _newAddress) external onlyOwner {
        play = PlayInterface(_newAddress);
    }

    //-------------------------------------------------------------------------
    /// @notice Change the number of PLAY tokens needed to mint a new TOY Token
    ///  (in pWei).
    /// @dev Throws if `_newPrice` is zero.
    /// @param _newPrice The new price to mint (in pWei)
    //-------------------------------------------------------------------------
    function changeToyPrice(uint _newPrice) external onlyOwner {
        priceToMint = _newPrice;
    }

    //-------------------------------------------------------------------------
    /// @notice Send and lock PLAY to mint a new empty TOY Token for yourself.
    /// @dev Sender must have approved this contract address as an authorized
    ///  spender with at least "priceToMint" PLAY. Throws if the sender has
    ///  insufficient PLAY. Throws if sender has not granted this contract's
    ///  address sufficient allowance.
    //-------------------------------------------------------------------------
    function mint() external {
        play.lockFrom (msg.sender, 2, priceToMint);

        uint uid = uidBuffer + toyArray.length;
        uint index = toyArray.push(ToyToken(msg.sender, uid, 0, 0, ""));
        uidToToyIndex[uid] = index - 1;

        emit Transfer(0, msg.sender, uid);
    }

    //-------------------------------------------------------------------------
    /// @notice Send and lock PLAY to mint a new empty TOY Token for 'to'.
    /// @dev Sender must have approved this contract address as an authorized
    ///  spender with at least "priceToMint" PLAY. Throws if the sender has
    ///  insufficient PLAY. Throws if sender has not granted this contract's
    ///  address sufficient allowance.
    /// @param _to The address to deduct PLAY Tokens from and send new TOY Token to.
    //-------------------------------------------------------------------------
    function mintAndSend(address _to) external {
        play.lockFrom (msg.sender, 2, priceToMint);

        uint uid = uidBuffer + toyArray.length;
        uint index = toyArray.push(ToyToken(_to, uid, 0, 0, ""));
        uidToToyIndex[uid] = index - 1;

        emit Transfer(0, _to, uid);
    }

    //-------------------------------------------------------------------------
    /// @notice Send and lock PLAY to mint `_amount` new empty TOY Tokens for
    ///  yourself.
    /// @dev Sender must have approved this contract address as an authorized
    ///  spender with at least "priceToMint" x `_amount` PLAY. Throws if the
    ///  sender has insufficient PLAY. Throws if sender has not granted this
    ///  contract's address sufficient allowance.
    //-------------------------------------------------------------------------
    function mintBulk(uint _amount) external {
        play.lockFrom (msg.sender, 2, priceToMint * _amount);

        for (uint i = 0; i < _amount; ++i) {
            uint uid = uidBuffer + toyArray.length;
            uint index = toyArray.push(ToyToken(msg.sender, uid, 0, 0, ""));
            uidToToyIndex[uid] = index - 1;
            emit Transfer(0, msg.sender, uid);
        }
    }

    //-------------------------------------------------------------------------
    /// @notice Change TOY Token #`_toyId` to TOY Token #`_newUid`. Writes any
    ///  data passed through '_data' into the TOY Token's public data.
    /// @dev Throws if TOY Token #`_toyId` does not exist. Throws if sender is
    ///  not approved to operate for TOY Token. Throws if '_toyId' is smaller
    ///  than 8 bytes. Throws if '_newUid' is bigger than 7 bytes. Throws if 
    ///  '_newUid' is zero. Throws if '_newUid' is already taken.
    /// @param _newUid The UID of the RFID chip to link to the TOY Token
    /// @param _toyId The UID of the empty TOY Token to link
    /// @param _data A byte string of data to attach to the TOY Token
    //-------------------------------------------------------------------------
    function link(
        bytes7 _newUid, 
        uint _toyId, 
        bytes _data
    ) external canOperate(_toyId) {
        ToyToken storage toy = toyArray[uidToToyIndex[_toyId]];
        // _toyId must be an empty TOY Token
        require (_toyId > uidBuffer, "TOY Token already linked");
        // _newUid field cannot be empty or greater than 7 bytes
        require (_newUid > 0 && uint(_newUid) < UID_MAX, "Invalid new UID");
        // a TOY Token with the new UID must not currently exist
        require (
            uidToToyIndex[uint(_newUid)] == 0, 
            "TOY Token with 'newUID' already exists"
        );

        // set new UID's mapping to index to old UID's mapping
        uidToToyIndex[uint(_newUid)] = uidToToyIndex[_toyId];
        // reset old UID's mapping to index
        uidToToyIndex[_toyId] = 0;
        // set TOY Token's UID to new UID
        toy.uid = uint(_newUid);
        // set any data
        toy.toyData = _data;
        // reset the timestamp
        toy.timestamp = now;

        emit Link(_toyId, uint(_newUid));
    }

    //-------------------------------------------------------------------------
    /// @notice Change TOY Token UIDs to new UIDs for multiple TOY Tokens.
    ///  Writes any data passed through '_data' into all the TOY Tokens' data.
    /// @dev Throws if any TOY Token's UID does not exist. Throws if sender is
    ///  not approved to operate for any TOY Token. Throws if any '_toyId' is
    ///  smaller than 8 bytes. Throws if any '_newUid' is bigger than 7 bytes. 
    ///  Throws if any '_newUid' is zero. Throws if '_newUid' is already taken.
    ///  Throws if array parameters are not the same length.
    /// @param _newUid The UID of the RFID chip to link to the TOY Token
    /// @param _toyId The UID of the empty TOY Token to link
    /// @param _data A byte string of data to attach to the TOY Token
    //-------------------------------------------------------------------------
    function linkBulk(
        bytes7[] _newUid, 
        uint[] _toyId, 
        bytes _data
    ) external {
        require (_newUid.length == _toyId.length, "Array lengths not equal");
        for (uint i = 0; i < _newUid.length; ++i) {
            ToyToken storage toy = toyArray[uidToToyIndex[_toyId[i]]];
            // sender must be authorized operator
            require (
                msg.sender == toy.owner ||
                msg.sender == idToApprovedAddress[_toyId[i]] ||
                operatorApprovals[toy.owner][msg.sender],
                "Not authorized to operate for this TOY Token"
            );
            // _toyId must be an empty TOY Token
            require (_toyId[i] > uidBuffer, "TOY Token already linked");
            // _newUid field cannot be empty or greater than 7 bytes
            require (_newUid[i] > 0 && uint(_newUid[i]) < UID_MAX, "Invalid new UID");
            // a TOY Token with the new UID must not currently exist
            require (
                uidToToyIndex[uint(_newUid[i])] == 0, 
                "TOY Token with 'newUID' already exists"
            );

            // set new UID's mapping to index to old UID's mapping
            uidToToyIndex[uint(_newUid[i])] = uidToToyIndex[_toyId[i]];
            // reset old UID's mapping to index
            uidToToyIndex[_toyId[i]] = 0;
            // set TOY Token's UID to new UID
            toy.uid = uint(_newUid[i]);
            // set any data
            toy.toyData = _data;
            // reset the timestamp
            toy.timestamp = now;

            emit Link(_toyId[i], uint(_newUid[i]));
        }
    }

    //-------------------------------------------------------------------------
    /// @notice Set external NFT #`_externalId` as TOY Token #`_toyUid`'s
    ///  linked external NFT.
    /// @dev Throws if sender is not authorized to operate TOY Token #`_toyUid`
    ///  Throws if '_toyUid' is bigger than 7 bytes. Throws if external NFT is
    ///  already linked. Throws if sender is not authorized to operate external
    ///  NFT.
    /// @param _toyUid The UID of the TOY Token to link
    /// @param _externalAddress The contract address of the external NFT
    /// @param _externalId The UID of the external NFT to link
    //-------------------------------------------------------------------------
    function linkExternalNft(
        uint _toyUid, 
        address _externalAddress, 
        uint _externalId
    ) external canOperate(_toyUid) {
        require(_toyUid < UID_MAX, "TOY Token not linked to a physical toy");
        require(
            linkedExternalNfts[_externalAddress][_externalId] == false,
            "External NFT already linked"
        );
        require(
            msg.sender == ERC721(_externalAddress).ownerOf(_externalId),
            "Sender does not own external NFT"
        );
        uidToExternalNft[_toyUid] = ExternalNft(_externalAddress, _externalId);
        linkedExternalNfts[_externalAddress][_externalId] = true;
    }
}


//-----------------------------------------------------------------------------
/// @title TOY Token Interface
/// @notice Interface for highest-level TOY Token getters
//-----------------------------------------------------------------------------
contract ToyInterface is ToyCreation {
    // URL Containing TOY Token metadata
    string metadataUrl = "http://52.9.230.48:8090/toy_token/";

    //-------------------------------------------------------------------------
    /// @notice Change old metadata URL to `_newUrl`
    /// @dev Throws if new URL is empty
    /// @param _newUrl The new URL containing TOY Token metadata
    //-------------------------------------------------------------------------
    function updateMetadataUrl(string _newUrl)
        external 
        onlyOwner 
        notZero(bytes(_newUrl).length)
    {
        metadataUrl = _newUrl;
    }

    //-------------------------------------------------------------------------
    /// @notice Gets all public info for TOY Token #`_uid`.
    /// @dev Throws if TOY Token #`_uid` does not exist.
    /// @param _uid the UID of the TOY Token to view.
    /// @return TOY Token owner, TOY Token UID, Creation Timestamp, Experience,
    ///  and Public Data.
    //-------------------------------------------------------------------------
    function changeToyData(uint _uid, bytes _data) 
        external 
        mustExist(_uid)
        canOperate(_uid)
        returns (address, uint, uint, uint, bytes) 
    {
        require(_uid < UID_MAX, "TOY Token must be linked");
        toyArray[uidToToyIndex[_uid]].toyData = _data;
    }

    //-------------------------------------------------------------------------
    /// @notice Gets all public info for TOY Token #`_uid`.
    /// @dev Throws if TOY Token #`_uid` does not exist.
    /// @param _uid the UID of the TOY Token to view.
    /// @return TOY Token owner, TOY Token UID, Creation Timestamp, Experience,
    ///  and Public Data.
    //-------------------------------------------------------------------------
    function getToy(uint _uid) 
        external
        view 
        mustExist(_uid) 
        returns (address, uint, uint, uint, bytes) 
    {
        ToyToken memory toy = toyArray[uidToToyIndex[_uid]];
        return(toy.owner, toy.uid, toy.timestamp, toy.exp, toy.toyData);
    }

    //-------------------------------------------------------------------------
    /// @notice Gets all info for TOY Token #`_uid`'s linked NFT.
    /// @dev Throws if TOY Token #`_uid` does not exist.
    /// @param _uid the UID of the TOY Token to view.
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
    /// @notice Gets whether NFT #`_externalId` is linked to a TOY Token.
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
    function name() external pure returns (string) {
        return "TOY Tokens";
    }

    //-------------------------------------------------------------------------
    /// @notice An abbreviated name for NFTs in this contract
    //-------------------------------------------------------------------------
    function symbol() external pure returns (string) { return "TOY"; }

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
    /// @param _tokenId The TOY Token whose metadata address is being queried
    //-------------------------------------------------------------------------
    function tokenURI(uint _tokenId) 
        external 
        view 
        returns (string) 
    {
        // convert TOY Token UID to a 14 character long string of character bytes
        bytes memory uidString = intToBytes(_tokenId);
        // declare new string of bytes with combined length of url and uid 
        bytes memory fullUrlBytes = new bytes(bytes(metadataUrl).length + uidString.length);
        // copy URL string and uid string into new string
        uint counter = 0;
        for (uint i = 0; i < bytes(metadataUrl).length; i++) {
            fullUrlBytes[counter++] = bytes(metadataUrl)[i];
        }
        for (i = 0; i < uidString.length; i++) {
            fullUrlBytes[counter++] = uidString[i];
        }
        // return full URL
        return string(fullUrlBytes);
    }
    
    //-------------------------------------------------------------------------
    /// @notice Convert int to 14 character bytes
    //-------------------------------------------------------------------------
    function intToBytes(uint _tokenId) 
        private 
        pure 
        returns (bytes) 
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
        for (i = 0; i < 14; ++i) {
            uidBytes[i] = uidBytes64[i + 50];
        }
        return uidBytes;
    }
    
    //-------------------------------------------------------------------------
    /// @notice Convert byte to UTF-8-encoded hex character
    //-------------------------------------------------------------------------
    function char(byte b) private pure returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
}
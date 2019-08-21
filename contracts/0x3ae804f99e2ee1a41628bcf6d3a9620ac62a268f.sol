pragma solidity ^0.4.24;

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }
    function add(Role storage role, address account) internal {
        require(account != address(0));
        role.bearer[account] = true;
    }
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        role.bearer[account] = false;
    }
    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0));
        return role.bearer[account];
    }
}
contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    constructor() public {
        minters.add(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        minters.add(account);
        emit MinterAdded(account);
    }

    function renounceMinter() public {
        minters.remove(msg.sender);
    }

    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
        return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
    
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool);
}
contract ERC165 is IERC165 {
    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) internal _supportedInterfaces;
    constructor()
        public
    {
        _registerInterface(_InterfaceId_ERC165);
    }
    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }
    function _registerInterface(bytes4 interfaceId)
        internal
    {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}
contract IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId)
        public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator)
        public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId)
        public;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes data
    )
        public;
}
contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    )
        public
        view
        returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}
contract IERC721Metadata is IERC721 {
    function name() external view returns (string);
    function symbol() external view returns (string);
    function tokenURI(uint256 tokenId) public view returns (string);
}
contract IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    )
        public
        returns(bytes4);
}
contract IERC721Full is IERC721, IERC721Enumerable, IERC721Metadata {
}
contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => uint256) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

    constructor()
        public
    {
        _registerInterface(_InterfaceId_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return _ownedTokensCount[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    )
        public
        view
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
    {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(to != address(0));

        _clearApproval(from, tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
    {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes _data
    )
        public
    {
        transferFrom(from, to, tokenId);
        require(_checkAndCallSafeTransfer(from, to, tokenId, _data));
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    )
        internal
        view
        returns (bool)
    {
        address owner = ownerOf(tokenId);
        return (
        spender == owner ||
        getApproved(tokenId) == spender ||
        isApprovedForAll(owner, spender)
        );
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        _addTokenTo(to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {
        _clearApproval(owner, tokenId);
        _removeTokenFrom(owner, tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

    function _clearApproval(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner);
        if (_tokenApprovals[tokenId] != address(0)) {
        _tokenApprovals[tokenId] = address(0);
        }
    }

    function _addTokenTo(address to, uint256 tokenId) internal {
        require(_tokenOwner[tokenId] == address(0));
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);
    }

    function _removeTokenFrom(address from, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _tokenOwner[tokenId] = address(0);
    }

    function _checkAndCallSafeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes _data
    )
        internal
        returns (bool)
    {
        if (!to.isContract()) {
        return true;
        }
        bytes4 retval = IERC721Receiver(to).onERC721Received(
        msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
}
contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    string internal _name;

    string internal _symbol;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;

    constructor(string name, string symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(InterfaceId_ERC721Metadata);
    }

    function name() external view returns (string) {
        return _name;
    }

    function symbol() external view returns (string) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view returns (string) {
        require(_exists(tokenId));
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string uri) internal {
        require(_exists(tokenId));
        _tokenURIs[tokenId] = uri;
    }

    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
        delete _tokenURIs[tokenId];
        }
    }
}
contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;

    constructor() public {
        _registerInterface(_InterfaceId_ERC721Enumerable);
    }

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    )
        public
        view
        returns (uint256)
    {
        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply());
        return _allTokens[index];
    }

    function _addTokenTo(address to, uint256 tokenId) internal {
        super._addTokenTo(to, tokenId);
        uint256 length = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
        _ownedTokensIndex[tokenId] = length;
    }

    function _removeTokenFrom(address from, uint256 tokenId) internal {
        super._removeTokenFrom(from, tokenId);

        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 lastToken = _ownedTokens[from][lastTokenIndex];

        _ownedTokens[from][tokenIndex] = lastToken;
        _ownedTokens[from].length--;

        _ownedTokensIndex[tokenId] = 0;
        _ownedTokensIndex[lastToken] = tokenIndex;
    }

    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 lastToken = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastToken;
        _allTokens[lastTokenIndex] = 0;

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
        _allTokensIndex[lastToken] = tokenIndex;
    }
}
contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
    constructor(string name, string symbol) ERC721Metadata(name, symbol)
        public
    {
    }
}
contract ERC721Mintable is ERC721Full, MinterRole {
    event MintingFinished();

    bool private _mintingFinished = false;

    modifier onlyBeforeMintingFinished() {
        require(!_mintingFinished);
        _;
    }

    function mintingFinished() public view returns(bool) {
        return _mintingFinished;
    }

    function mint(
        address to,
        uint256 tokenId
    )
        public
        onlyMinter
        onlyBeforeMintingFinished
        returns (bool)
    {
        _mint(to, tokenId);
        return true;
    }

    function mintWithTokenURI(
        address to,
        uint256 tokenId,
        string tokenURI
    )
        public
        onlyMinter
        onlyBeforeMintingFinished
        returns (bool)
    {
        mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;
    }

    function finishMinting()
        public
        onlyMinter
        onlyBeforeMintingFinished
        returns (bool)
    {
        _mintingFinished = true;
        emit MintingFinished();
        return true;
    }
}
contract ERC721Burnable is ERC721 {
    function burn(uint256 tokenId)
        public
    {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _burn(ownerOf(tokenId), tokenId);
    }
}
contract ERC721Contract is ERC721Full, ERC721Mintable, ERC721Burnable {
    constructor(string name, string symbol) public
        ERC721Mintable()
        ERC721Full(name, symbol)
    {}

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function setTokenURI(uint256 tokenId, string uri) public {
        _setTokenURI(tokenId, uri);
    }

    function removeTokenFrom(address from, uint256 tokenId) public {
        _removeTokenFrom(from, tokenId);
    }
}
contract ERC721Constructor {
    event newERC721(address contractAddress, string name, string symbol, address owner);

    function CreateAdminERC721(string name, string symbol, address owner) public {
        ERC721Contract ERC721Construct = new ERC721Contract(name, symbol);
        ERC721Construct.addMinter(owner);
        ERC721Construct.renounceMinter();
        emit newERC721(address(ERC721Construct), name, symbol, owner);
    }
}
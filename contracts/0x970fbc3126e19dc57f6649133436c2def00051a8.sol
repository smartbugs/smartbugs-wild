// File: contracts/ERC721.sol

// eterart-contract
// contracts/ERC721.sol


pragma solidity ^0.4.24;


/**
 * @title ERC-721 contract interface.
 */
contract ERC721 {
    // ERC20 compatible functions.
    function name() public constant returns (string);
    function symbol() public constant returns (string);
    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint);
    // Functions that define ownership.
    function ownerOf(uint256 _tokenId) public constant returns (address);
    function approve(address _to, uint256 _tokenId) public;
    function takeOwnership(uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint);
    // Token metadata.
    function tokenMetadata(uint256 _tokenId) public constant returns (string);
    // Events.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
}

// File: contracts/EterArt.sol

// eterart-contract
// contracts/EterArt.sol


pragma solidity ^0.4.24;


/**
 * @title EterArt contract.
 */
contract EterArt is ERC721 {

    // Art structure for tokens ownership registry.
    struct Art {
        uint256 price;
        address owner;
        address newOwner;
    }

    struct Token {
        uint256[] items;
        mapping(uint256 => uint) lookup;
    }

    // Mapping from token ID to owner.
    mapping (address => Token) internal ownedTokens;

    // All minted tokens number (ERC-20 compatibility).
    uint256 public totalTokenSupply;

    // Token issuer address
    address public _issuer;

    // Tokens ownership registry.
    mapping (uint => Art) public registry;

    // Token metadata base URL.
    string public baseInfoUrl = "https://www.eterart.com/art/";

    // Fee in percents
    uint public feePercent = 5;

    // Change price event
    event ChangePrice(uint indexed token, uint indexed price);

    /**
    * @dev Constructor sets the `issuer` of the contract to the sender
    * account.
    */
    constructor() public {
        _issuer = msg.sender;
    }

    /**
   * @return the address of the issuer.
   */
    function issuer() public view returns(address) {
        return _issuer;
    }

    /**
    * @dev Reject all Ether from being sent here. (Hopefully, we can prevent user accidents.)
    */
    function() external payable {
        require(msg.sender == address(this));
    }

    /**
     * @dev Gets token name (ERC-20 compatibility).
     * @return string token name.
     */
    function name() public constant returns (string) {
        return "EterArt";
    }

    /**
     * @dev Gets token symbol (ERC-20 compatibility).
     * @return string token symbol.
     */
    function symbol() public constant returns (string) {
        return "WAW";
    }

    /**
     * @dev Gets token URL.
     * @param _tokenId uint256 ID of the token to get URL of.
     * @return string token URL.
     */
    function tokenMetadata(uint256 _tokenId) public constant returns (string) {
        return strConcat(baseInfoUrl, strConcat("0x", uint2hexstr(_tokenId)));
    }

    /**
     * @dev Gets contract all minted tokens number.
     * @return uint256 contract all minted tokens number.
     */
    function totalSupply() public constant returns (uint256) {
        return totalTokenSupply;
    }

    /**
     * @dev Gets tokens number of specified address.
     * @param _owner address to query tokens number of.
     * @return uint256 number of tokens owned by the specified address.
     */
    function balanceOf(address _owner) public constant returns (uint balance) {
        balance = ownedTokens[_owner].items.length;
    }

    /**
     * @dev Gets token by index of specified address.
     * @param _owner address to query tokens number of.
     * @param _index uint256 index of the token to get.
     * @return uint256 token ID from specified address tokens list by specified index.
     */
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint tokenId) {
        tokenId = ownedTokens[_owner].items[_index];
    }

    /**
     * @dev Approve token ownership transfer to another address.
     * @param _to address to change token ownership to.
     * @param _tokenId uint256 token ID to change ownership of.
     */
    function approve(address _to, uint256 _tokenId) public {
        require(_to != msg.sender);
        require(registry[_tokenId].owner == msg.sender);
        registry[_tokenId].newOwner = _to;
        emit Approval(registry[_tokenId].owner, _to, _tokenId);
    }

    /**
     * @dev Internal method that transfer token to another address.
     * Run some checks and internal contract data manipulations.
     * @param _to address new token owner address.
     * @param _tokenId uint256 token ID to transfer to specified address.
     */
    function _transfer(address _to, uint256 _tokenId) internal {
        if (registry[_tokenId].owner != address(0)) {
            require(registry[_tokenId].owner != _to);
            removeByValue(registry[_tokenId].owner, _tokenId);
        }
        else {
            totalTokenSupply = totalTokenSupply + 1;
        }

        require(_to != address(0));

        push(_to, _tokenId);
        emit Transfer(registry[_tokenId].owner, _to, _tokenId);
        registry[_tokenId].owner = _to;
        registry[_tokenId].newOwner = address(0);
        registry[_tokenId].price = 0;
    }

    /**
     * @dev Take ownership of specified token.
     * Only if current token owner approve that.
     * @param _tokenId uint256 token ID to take ownership of.
     */
    function takeOwnership(uint256 _tokenId) public {
        require(registry[_tokenId].newOwner == msg.sender);
        _transfer(msg.sender, _tokenId);
    }

    /**
     * @dev Change baseInfoUrl contract property value.
     * @param url string new baseInfoUrl value.
     */
    function changeBaseInfoUrl(string url) public {
        require(msg.sender == _issuer);
        baseInfoUrl = url;
    }

    /**
     * @dev Change issuer contract address.
     * @param _to address of new contract issuer.
     */
    function changeIssuer(address _to) public {
        require(msg.sender == _issuer);
        _issuer = _to;
    }

    /**
     * @dev Withdraw all contract balance value to contract issuer.
     */
    function withdraw() public {
        require(msg.sender == _issuer);
        withdraw(_issuer, address(this).balance);
    }

    /**
     * @dev Withdraw all contract balance value to specified address.
     * @param _to address to transfer value.
     */
    function withdraw(address _to) public {
        require(msg.sender == _issuer);
        withdraw(_to, address(this).balance);
    }

    /**
     * @dev Withdraw specified wei number to address.
     * @param _to address to transfer value.
     * @param _value uint wei amount value.
     */
    function withdraw(address _to, uint _value) public {
        require(msg.sender == _issuer);
        require(_value <= address(this).balance);
        _to.transfer(address(this).balance);
    }

    /**
     * @dev Gets specified token owner address.
     * @param token uint256 token ID.
     * @return address specified token owner address.
     */
    function ownerOf(uint256 token) public constant returns (address owner) {
        owner = registry[token].owner;
    }

    /**
     * @dev Gets specified token price.
     * @param token uint256 token ID.
     * @return uint specified token price.
     */
    function getPrice(uint token) public view returns (uint) {
        return registry[token].price;
    }

    /**
     * @dev Direct transfer specified token to another address.
     * @param _to address new token owner address.
     * @param _tokenId uint256 token ID to transfer to specified address.
     */
    function transfer(address _to, uint256 _tokenId) public {
        require(registry[_tokenId].owner == msg.sender);
        _transfer(_to, _tokenId);
    }

    /**
     * @dev Change specified token price.
     * Used for: change token price,
     * withdraw token from sale (set token price to 0 (zero))
     * and for put up token for sale (set token price > 0)
     * @param token uint token ID to change price of.
     * @param price uint new token price.
     */
    function changePrice(uint token, uint price) public {
        require(registry[token].owner == msg.sender);
        registry[token].price = price;
        emit ChangePrice(token, price);
    }

    /**
     * @dev Buy specified token if it's marked as for sale (token price > 0).
     * Run some checks, calculate fee and transfer token to msg.sender.
     * @param _tokenId uint token ID to buy.
     */
    function buy(uint _tokenId) public payable {
        require(registry[_tokenId].price > 0);

        uint fee = ((registry[_tokenId].price / 100) * feePercent);
        uint value = msg.value - fee;

        require(registry[_tokenId].price <= value);
        registry[_tokenId].owner.transfer(value);
        _transfer(msg.sender, _tokenId);
    }

    /**
     * @dev Mint token.
     */
    function mint(uint _tokenId, address _to) public {
        require(msg.sender == _issuer);
        require(registry[_tokenId].owner == 0x0);
        _transfer(_to, _tokenId);
    }

    /**
     * @dev Mint token.
     */
    function mint(
        string length,
        uint _tokenId,
        uint price,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {

        string memory m_price = uint2hexstr(price);
        string memory m_token = uint2hexstr(_tokenId);

        require(msg.value >= price);
        require(ecrecover(keccak256("\x19Ethereum Signed Message:\n", length, m_token, m_price), v, r, s) == _issuer);
        require(registry[_tokenId].owner == 0x0);
        _transfer(msg.sender, _tokenId);
    }

    /**
     * UTILS
     */

    /**
     * @dev Add token to specified address tokens list.
     * @param owner address address of token owner to add token to.
     * @param value uint token ID to add.
     */
    function push(address owner, uint value) private {

        if (ownedTokens[owner].lookup[value] > 0) {
            return;
        }
        ownedTokens[owner].lookup[value] = ownedTokens[owner].items.push(value);
    }

    /**
     * @dev Remove token by ID from specified address tokens list.
     * @param owner address address of token owner to remove token from.
     * @param value uint token ID to remove.
     */
    function removeByValue(address owner, uint value) private {
        uint index = ownedTokens[owner].lookup[value];
        if (index == 0) {
            return;
        }
        if (index < ownedTokens[owner].items.length) {
            uint256 lastItem = ownedTokens[owner].items[ownedTokens[owner].items.length - 1];
            ownedTokens[owner].items[index - 1] = lastItem;
            ownedTokens[owner].lookup[lastItem] = index;
        }
        ownedTokens[owner].items.length -= 1;
        delete ownedTokens[owner].lookup[value];
    }

    /**
     * @dev String concatenation.
     * @param _a string first string.
     * @param _b string second string.
     * @return string result of string concatenation.
     */
    function strConcat(string _a, string _b) internal pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory abcde = new string(_ba.length + _bb.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

        return string(babcde);
    }

    /**
     * @dev Convert long to hex string.
     * @param i uint value to convert.
     * @return string specified value converted to hex string.
     */
    function uint2hexstr(uint i) internal pure returns (string) {
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0) {
            length++;
            j = j >> 4;
        }
        uint mask = 15;
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0) {
            uint curr = (i & mask);
            bstr[k--] = curr > 9 ? byte(55 + curr) : byte(48 + curr); // 55 = 65 - 10
            i = i >> 4;
        }

        return string(bstr);
    }

}
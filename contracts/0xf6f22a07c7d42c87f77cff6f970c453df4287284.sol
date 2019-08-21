pragma solidity ^0.5.0;

pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
contract ERC20Proxy {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    function onTransfer(address _from, address _to, uint256 _value) external;
}

pragma solidity ^0.5.0;

contract Operators
{
    mapping (address=>bool) ownerAddress;
    mapping (address=>bool) operatorAddress;

    constructor() public
    {
        ownerAddress[msg.sender] = true;
    }

    modifier onlyOwner()
    {
        require(ownerAddress[msg.sender]);
        _;
    }

    function isOwner(address _addr) public view returns (bool) {
        return ownerAddress[_addr];
    }

    function addOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));

        ownerAddress[_newOwner] = true;
    }

    function removeOwner(address _oldOwner) external onlyOwner {
        delete(ownerAddress[_oldOwner]);
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }

    function isOperator(address _addr) public view returns (bool) {
        return operatorAddress[_addr] || ownerAddress[_addr];
    }

    function addOperator(address _newOperator) external onlyOwner {
        require(_newOperator != address(0));

        operatorAddress[_newOperator] = true;
    }

    function removeOperator(address _oldOperator) external onlyOwner {
        delete(operatorAddress[_oldOperator]);
    }
}

pragma solidity ^0.5.0;

interface BlockchainCutiesERC1155Interface
{
    function mintNonFungibleSingleShort(uint128 _type, address _to) external;
    function mintNonFungibleSingle(uint256 _type, address _to) external;
    function mintNonFungibleShort(uint128 _type, address[] calldata _to) external;
    function mintNonFungible(uint256 _type, address[] calldata _to) external;
    function mintFungibleSingle(uint256 _id, address _to, uint256 _quantity) external;
    function mintFungible(uint256 _id, address[] calldata _to, uint256[] calldata _quantities) external;
    function isNonFungible(uint256 _id) external pure returns(bool);
    function ownerOf(uint256 _id) external view returns (address);
    function totalSupplyNonFungible(uint256 _type) view external returns (uint256);
    function totalSupplyNonFungibleShort(uint128 _type) view external returns (uint256);

    /**
        @notice A distinct Uniform Resource Identifier (URI) for a given token.
        @dev URIs are defined in RFC 3986.
        The URI may point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
        @return URI string
    */
    function uri(uint256 _id) external view returns (string memory);
    function proxyTransfer721(address _from, address _to, uint256 _tokenId, bytes calldata _data) external;
    function proxyTransfer20(address _from, address _to, uint256 _tokenId, uint256 _value) external;
    /**
        @notice Get the balance of an account's Tokens.
        @param _owner  The address of the token holder
        @param _id     ID of the Token
        @return        The _owner's balance of the Token type requested
     */
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    /**
        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
    */
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
}


contract Proxy20_1155 is ERC20Proxy, Operators {

    BlockchainCutiesERC1155Interface public erc1155;
    uint256 public tokenId;
    string public tokenName;
    string public tokenSymbol;
    bool public canSetup = true;
    uint256 totalTokens = 0;

    modifier canBeStoredIn128Bits(uint256 _value)
    {
        require(_value <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        _;
    }

    function setup(
        BlockchainCutiesERC1155Interface _erc1155,
        uint256 _tokenId,
        string calldata _tokenSymbol,
        string calldata _tokenName) external onlyOwner canBeStoredIn128Bits(_tokenId)
    {
        require(canSetup);
        erc1155 = _erc1155;
        tokenId = _tokenId;
        tokenSymbol = _tokenSymbol;
        tokenName = _tokenName;
    }

    function disableSetup() external onlyOwner
    {
        canSetup = false;
    }

    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory)
    {
        return tokenName;
    }

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory)
    {
        return tokenSymbol;
    }

    function totalSupply() external view returns (uint)
    {
        return totalTokens;
    }

    function balanceOf(address tokenOwner) external view returns (uint balance)
    {
        balance = erc1155.balanceOf(tokenOwner, tokenId);
    }

    function allowance(address, address) external view returns (uint)
    {
        return 0;
    }

    function transfer(address _to, uint _value) external returns (bool)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal
    {
        erc1155.proxyTransfer20(_from, _to, tokenId, _value);
    }

    function approve(address, uint) external returns (bool)
    {
        revert();
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool)
    {
        _transfer(_from, _to, _value);
        return true;
    }

    function onTransfer(address _from, address _to, uint256 _value) external
    {
        require(msg.sender == address(erc1155));
        emit Transfer(_from, _to, _value);
        if (_from == address(0x0))
        {
            totalTokens += _value;
        }
        if (_to == address(0x0))
        {
            totalTokens -= _value;
        }
    }
}
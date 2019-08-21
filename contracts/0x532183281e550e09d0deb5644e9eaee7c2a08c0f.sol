pragma solidity 0.4.24;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
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
     * @dev Allows the current owner to relinquish control of the contract.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 *  from ERC721 asset contracts.
 */
contract ERC721Receiver {
    /**
     * @dev Magic value to be returned upon successful reception of an NFT
     *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
     *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
     */
    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     *  after a `safetransfer`. This function MAY throw to revert and reject the
     *  transfer. This function MUST use 50,000 gas or less. Return of other
     *  than the magic value MUST result in the transaction being reverted.
     *  Note: the contract address is always the message sender.
     * @param _from The sending address
     * @param _tokenId The NFT identifier which is being transfered
     * @param _data Additional data with no specified format
     * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
     */
    function onERC721Received(
        address _from,
        uint256 _tokenId,
        bytes _data
    )
    public
    returns(bytes4);
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId)
    public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
    public;
}

// File: contracts/BBMarketplace.sol

contract BBMarketplace is Ownable, ERC721Receiver {
    address public owner;
    address public wallet;
    uint public fee_percentage;
    mapping (address => bool) public tokens;
    mapping(address => bool) public managers;

    mapping(address => mapping(uint => uint)) public priceList;
    mapping(address => mapping(uint => address)) public holderList;

    event Stored(uint indexed id, uint price, address seller, address token);
    event Cancelled(uint indexed id, address seller, address token);
    event Sold(uint indexed id, uint price, address seller, address buyer, address token);

    event TokenChanged(address token, bool enabled);
    event WalletChanged(address old_wallet, address new_wallet);
    event FeeChanged(uint old_fee, uint new_fee);

    modifier onlyOwnerOrManager() {
        require(msg.sender == owner || managers[msg.sender]);
        _;
    }

    constructor(address _BBArtefactAddress, address _BBPackAddress, address _wallet, address _manager, uint _fee) public {
        owner = msg.sender;
        tokens[_BBArtefactAddress] = true;
        tokens[_BBPackAddress] = true;
        wallet = _wallet;
        fee_percentage = _fee;
        managers[_manager] = true;
    }

    function setToken(address _token, bool enabled) public onlyOwnerOrManager {
        tokens[_token] = enabled;
        emit TokenChanged(_token, enabled);
    }

    function setWallet(address _wallet) public onlyOwnerOrManager {
        address old = wallet;
        wallet = _wallet;
        emit WalletChanged(old, wallet);
    }

    function changeFeePercentage(uint _percentage) public onlyOwnerOrManager {
        uint old = fee_percentage;
        fee_percentage = _percentage;
        emit FeeChanged(old, fee_percentage);
    }

    function onERC721Received(address _from, uint _tokenId, bytes _data) public returns(bytes4) {
        require(tokens[msg.sender]);

        uint _price = uint(convertBytesToBytes32(_data));

        require(_price > 0);

        priceList[msg.sender][_tokenId] = _price;
        holderList[msg.sender][_tokenId] = _from;

        emit Stored(_tokenId, _price, _from, msg.sender);

        return ERC721Receiver.ERC721_RECEIVED;
    }

    function cancel(uint _id, address _token) public returns (bool) {
        require(holderList[_token][_id] == msg.sender || managers[msg.sender]);

        delete holderList[_token][_id];
        delete priceList[_token][_id];

        ERC721Basic(_token).safeTransferFrom(this, msg.sender, _id);

        emit Cancelled(_id, msg.sender, _token);

        return true;
    }

    function buy(uint _id, address _token) public payable returns (bool) {
        require(priceList[_token][_id] == msg.value);

        address oldHolder = holderList[_token][_id];
        uint price = priceList[_token][_id];

        uint toWallet = price / 100 * fee_percentage;
        uint toHolder = price - toWallet;

        delete holderList[_token][_id];
        delete priceList[_token][_id];

        ERC721Basic(_token).safeTransferFrom(this, msg.sender, _id);
        wallet.transfer(toWallet);
        oldHolder.transfer(toHolder);

        emit Sold(_id, price, oldHolder, msg.sender, _token);

        return true;
    }

    function getPrice(uint _id, address _token) public view returns(uint) {
        return priceList[_token][_id];
    }

    function convertBytesToBytes32(bytes inBytes) internal returns (bytes32 out) {
        if (inBytes.length == 0) {
            return 0x0;
        }

        assembly {
            out := mload(add(inBytes, 32))
        }
    }

    function setManager(address _manager, bool enable) public onlyOwner {
        managers[_manager] = enable;
    }
}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
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

contract TrustServiceStorage is Destructible {

    struct Deal {
        bytes32 dealHash;
        address[] addresses;
    }

    uint256 dealId = 1;

    mapping (uint256 => Deal) deals;

    mapping (uint256 => mapping(address => bool)) signedAddresses;

    address trust;

    modifier onlyTrust() {
        require(msg.sender == trust);
        _;
    }

    function setTrust(address _trust) onlyOwner {
        trust = _trust;
    }

    function getDealId() onlyTrust returns (uint256) {
        return dealId;
    }

    function setDealId(uint256 _dealId) onlyTrust {
        dealId = _dealId;
    }

    function addDeal(uint256 dealId, bytes32 dealHash, address[] addresses) onlyTrust returns (uint256) {
        deals[dealId] = Deal(dealHash, addresses);
    }

    function getDealHash(uint256 dealId) onlyTrust returns (bytes32) {
        return deals[dealId].dealHash;
    }

    function getDealAddrCount(uint256 dealId) onlyTrust returns (uint256) {
        return deals[dealId].addresses.length;
    }

    function getDealAddrAtIndex(uint256 dealId, uint256 index) onlyTrust returns (address)  {
        return deals[dealId].addresses[index];
    }

    function setSigned(uint256 dealId, address _address) onlyTrust {
        signedAddresses[dealId][_address] = true;
    }

    function setUnSigned(uint256 dealId, address _address) onlyTrust {
        signedAddresses[dealId][_address] = false;
    }

    function getSigned(uint256 dealId, address _address) onlyTrust returns (bool) {
        return signedAddresses[dealId][_address];
    }
}

contract TrustService is Destructible {

    TrustServiceStorage trustStorage;

    ERC20 public feeToken;
    uint256 public fee;
    address public feeSender;
    address public feeRecipient;

    event DealSaved(uint256 indexed dealId);

    function setFee(address _feeToken, address _feeSender, address _feeRecipient, uint256 _fee) public onlyOwner {
       require(_feeToken != address(0));
       require(_feeSender != address(0));
       require(_feeRecipient != address(0));
       require(_fee > 0);
       feeToken = ERC20(_feeToken);
       feeSender = _feeSender;
       feeRecipient = _feeRecipient;
       fee = _fee;
    }

    function clearFee() public onlyOwner {
       fee = 0;
    }

    function setStorage(address _storageAddress) onlyOwner {
        trustStorage = TrustServiceStorage(_storageAddress);
    }

    function createDeal(
      bytes32 dealHash,
      address[] addresses
    ) public returns (uint256) {

        require(fee == 0 || feeToken.transferFrom(feeSender, feeRecipient, fee));

        uint256 dealId = trustStorage.getDealId();

        trustStorage.addDeal(dealId, dealHash, addresses);

        DealSaved(dealId);

        trustStorage.setDealId(dealId + 1);

        return dealId;
    }

    function createAndSignDeal(
      bytes32 dealHash,
      address[] addresses)
    public {

        uint256 id = createDeal(dealHash, addresses);
        signDeal(id);
    }

    function readDeal(uint256 dealId) public view returns (
      bytes32 dealHash,
      address[] addresses,
      bool[] signed
    ) {
        dealHash = trustStorage.getDealHash(dealId);

        uint256 addrCount = trustStorage.getDealAddrCount(dealId);

        addresses = new address[](addrCount);

        signed = new bool[](addrCount);

        for(uint i = 0; i < addrCount; i ++) {
            addresses[i] = trustStorage.getDealAddrAtIndex(dealId, i);
            signed[i] = trustStorage.getSigned(dealId , addresses[i]);
        }
    }

    function signDeal(uint256 dealId) public {
        trustStorage.setSigned(dealId, msg.sender);
    }

    function confirmDeal(uint256 dealId, bytes32 dealHash) public constant returns (bool) {
        bytes32 hash = trustStorage.getDealHash(dealId);

        return hash == dealHash;
    }
}
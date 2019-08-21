pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

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

pragma solidity ^0.4.24;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.4.24;

contract EtherPornStarsVids is Ownable {
  using SafeMath for uint256;
  address public ownerAddress;
  bool public commFree;
  uint customComm;
  uint vidComm;
  uint tipComm;
    // Boundaries for messages
  uint8 constant playerMessageMaxLength = 64;
  mapping(address => userAccount) public user;
  mapping (address => uint) public spentDivs;
  mapping (uint => address) public star;
  mapping (uint => uint) public referrer;
  event VideoBought(address _buyer, uint _videoId, uint _value, uint _refstarId);
  event Funded(uint _starId, address _sender, string _message, uint _value, uint _refstarId);
  event Tipped(uint _starId, address _sender, uint _value);
  event SubscriptionBought(uint _starId, uint _tier, address _buyer, uint _value);
  event StoreItemBought(uint _starId, uint _itemId, address _buyer, uint _value, uint _refstarId);
  event CustomVidBought(uint _starId, address _sender, uint _cid, uint _value);
  struct userAccount {
    uint[] vidsOwned;
    uint[3][] subscriptions;
    uint epsPrime;
  }
  
  constructor() public {
      commFree = true;
      customComm = 15;
      vidComm = 10;
      tipComm = 5;
      ownerAddress = msg.sender;
  }

  function tipStar(uint _starId) public payable {
      require(msg.value >= 10000000000000000);
      uint _commission = msg.value.div(tipComm);
      uint _starShare = msg.value-_commission;
      address starAddress = star[_starId];
      require(starAddress != address(0));
      starAddress.transfer(_starShare);
      ownerAddress.transfer(_commission);
      emit Tipped(_starId, msg.sender, msg.value);
  }
  
    function fundStar(uint _starId, string _message) public payable {
      bytes memory _messageBytes = bytes(_message);
      require(msg.value >= 10000000000000000);
      require(_messageBytes.length <= playerMessageMaxLength, "Too long");
      uint _commission = msg.value.div(tipComm);
      if (referrer[_starId] != 0) {
          address _referrerAddress = star[referrer[_starId]];
          uint _referralShare = msg.value.div(5);
      }
      uint _starShare = msg.value - _commission - _referralShare;
      address _starAddress = star[_starId];
      require(_starAddress != address(0));
      _starAddress.transfer(_starShare);
      _referrerAddress.transfer(_referralShare);
      ownerAddress.transfer(_commission);
      emit Funded(_starId, msg.sender, _message, msg.value, referrer[_starId]);
  }
  
  function buySub(uint _starId, uint _tier) public payable {
    require(msg.value >= 10000000000000000);
    uint _commission = msg.value.div(vidComm);
    uint _starShare = msg.value-_commission;
    address _starAddress = star[_starId];
    require(_starAddress != address(0));
    _starAddress.transfer(_starShare);
    ownerAddress.transfer(_commission);
    user[msg.sender].subscriptions.push([_starId,_tier, msg.value]);
    emit SubscriptionBought(_starId, _tier, msg.sender, msg.value);
  }
  
  function buyVid(uint _videoId, uint _starId) public payable {
    require(msg.value >= 10000000000000000);
    if(!commFree){
        uint _commission = msg.value.div(vidComm);
    }
    if (referrer[_starId] != 0) {
          address _referrerAddress = star[referrer[_starId]];
          uint _referralShare = msg.value.div(5);
      }
    uint _starShare = msg.value-_commission - _referralShare;
    address _starAddress = star[_starId];
    require(_starAddress != address(0));
    _starAddress.transfer(_starShare);
    _referrerAddress.transfer(_referralShare);
    ownerAddress.transfer(_commission);
    user[msg.sender].vidsOwned.push(_videoId);
    emit VideoBought(msg.sender, _videoId, msg.value, referrer[_starId]);
  }

  function buyStoreItem(uint _itemId, uint _starId) public payable {
    require(msg.value >= 10000000000000000);
    if(!commFree){
        uint _commission = msg.value.div(vidComm);
    }
    if (referrer[_starId] != 0) {
      address _referrerAddress = star[referrer[_starId]];
      uint _referralShare = msg.value.div(5);
    }
    uint _starShare = msg.value-_commission-_referralShare;
    address _starAddress = star[_starId];
    require(_starAddress != address(0));
    _starAddress.transfer(_starShare);
    _referrerAddress.transfer(_referralShare);
    ownerAddress.transfer(_commission);
    emit StoreItemBought(_starId, _itemId, msg.sender,  msg.value, referrer[_starId]);
  }
  
  function buyCustomVid(uint _starId, uint _cid) public payable {
    require(msg.value >= 10000000000000000);
    if(!commFree){
        uint _commission = msg.value.div(customComm);
    }
    uint _starShare = msg.value-_commission;
    address _starAddress = star[_starId];
    require(_starAddress != address(0));
    _starAddress.transfer(_starShare);
    ownerAddress.transfer(_commission);
    emit CustomVidBought(_starId, msg.sender, _cid, msg.value);
  }
  
  function addStar(uint _starId, address _starAddress) public onlyOwner {
    star[_starId] = _starAddress;
  }

  function addReferrer(uint _starId, uint _referrerId) public onlyOwner {
    referrer[_starId] = _referrerId;
  }
  
  function commission(bool _commFree, uint _customcomm, uint _vidcomm, uint _tipcomm) public onlyOwner {
    commFree = _commFree;
    customComm = _customcomm;
    vidComm = _vidcomm;
    tipComm = _tipcomm;
  }
}
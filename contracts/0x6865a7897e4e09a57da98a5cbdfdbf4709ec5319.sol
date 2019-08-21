pragma solidity ^0.4.25;

contract Ownerable{
    
    address public owner;

    address public delegate;

    constructor() public{
        owner = msg.sender;
        delegate = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Permission denied");
        _;
    }

    modifier onlyDelegate() {
        require(msg.sender == delegate,"Permission denied");
        _;
    }
    
    modifier onlyOwnerOrDelegate() {
        require(msg.sender == owner||msg.sender == delegate,"Permission denied");
        _;
    }
    
    function changeOwner(address newOwner) public onlyOwner{
        require(newOwner!= 0x0,"address is invalid");
        owner = newOwner;
    }
    
    function changeDelegate(address newDelegate) public onlyOwner{
        require(newDelegate!= 0x0,"address is invalid");
        delegate = newDelegate;
    }
    
}

contract Pausable is Ownerable{
  event Paused();
  event Unpaused();

  bool private _paused = false;

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused();
  }
}

contract EthTransfer is Pausable{
    
    using SafeMath for uint256;
    
    uint256 constant ADMIN_DEPOIST_TIME_INTERVAL = 24 hours;
    uint256 constant ADMIN_DEPOIST_MAX_AMOUNT = 50 ether;
    uint256 last_time_admin_depoist = 0;
    
    uint constant HOUSE_EDGE_PERCENT = 15; //1.5%
    uint constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.00045 ether;
    
    uint256 public _total_house_edge = 0;
    
    uint256 public _ID = 1; //AUTO INCREMENT
    uint256 public _newChannelID = 10000;
        
    event addChannelSucc    (uint256 indexed id,uint256 channelID,string name);
    event rechargeSucc      (uint256 indexed id,uint256 channelID,address user,uint256 amount,string ext);
    event depositSucc       (uint256 indexed id,uint256 channelID,address beneficiary,uint256 amount,uint256 houseEdge,string ext);
    event withdrawSucc      (uint256 indexed id,uint256 amount);
    event depositBySuperAdminSucc           (uint256 indexed id,uint256 amount,address beneficiary);
    event changeChannelDelegateSucc         (uint256 indexed id,address newDelegate);
    
    mapping(uint256 => Channel) public _channelMap; // channelID => channel info
    
    mapping(address => uint256) public _idMap; // delegate => channelID
    
    function addNewChannel(string name_,address channelDelegate_,uint256 partnershipCooperationBounsRate_) public onlyDelegate{
        require(_idMap[channelDelegate_] == 0,"An address can only manage one channel.");
        
        _channelMap[_newChannelID] = Channel(name_,_newChannelID,channelDelegate_,0,partnershipCooperationBounsRate_);
        _idMap[channelDelegate_] = _newChannelID;
        
        emit addChannelSucc(_ID,_newChannelID,name_);
        _newChannelID++;
        _ID++;
    }
    
    function() public payable{
        revert();
    }
    
    function recharge(uint256 channelID_,string ext_) public payable whenNotPaused{
        Channel storage targetChannel = _channelMap[channelID_];
        require(targetChannel.channelID!=0,"target Channel is no exist");
        uint256 inEth = msg.value;

        uint256 partnershipCooperationBouns = inEth * targetChannel.partnershipCooperationBounsRate / 100 ;
        _total_house_edge = _total_house_edge.add(partnershipCooperationBouns);

        uint256 targetEth = inEth.sub(partnershipCooperationBouns);
        targetChannel.totalEth = targetChannel.totalEth.add(targetEth);
        
        emit rechargeSucc(_ID, channelID_, msg.sender, inEth, ext_);
        _ID++;
    }

    function changeChannelDelegate(address newDelegate_) public whenNotPaused{
        require(_idMap[msg.sender] != 0,"this address isn't a manager");
        Channel storage channelInfo = _channelMap[_idMap[msg.sender]];
        require(channelInfo.channelDelegate == msg.sender,"You are not the administrator of this channel.");
        require(_idMap[newDelegate_] == 0,"An address can only manage one channel.");
        
        channelInfo.channelDelegate = newDelegate_;
        _idMap[msg.sender] = 0;
        _idMap[newDelegate_] = channelInfo.channelID;
        
        emit changeChannelDelegateSucc(_ID, newDelegate_);
        _ID++;
    }    
    
    function deposit(address beneficiary_,uint256 amount_,string ext_) public whenNotPaused{
        //Verify user identity
        require(_idMap[msg.sender] != 0,"this address isn't a manager");
        
        Channel storage channelInfo = _channelMap[_idMap[msg.sender]];
        //Query administrator privileges
        require(channelInfo.channelDelegate == msg.sender,"You are not the administrator of this channel.");
        //Is order completed?
        bytes32 orderId = keccak256(abi.encodePacked(ext_));
        require(!channelInfo.channelOrderHistory[orderId],"this order is deposit already");
        channelInfo.channelOrderHistory[orderId] = true;
        
        uint256 totalLeftEth = channelInfo.totalEth.sub(amount_);
        
        uint houseEdge = amount_ * HOUSE_EDGE_PERCENT / 1000;
        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }
        
        channelInfo.totalEth = totalLeftEth.sub(houseEdge);
        _total_house_edge = _total_house_edge.add(houseEdge);
        
        beneficiary_.transfer(amount_);
        
        emit depositSucc(_ID, channelInfo.channelID, beneficiary_, amount_, houseEdge, ext_);
        _ID++;
    }
    
    function depositByDelegate(address beneficiary_,uint256 amount_,string ext_, bytes32 r, bytes32 s, uint8 v) public onlyDelegate whenNotPaused{
        //Verify user identity 
        bytes32 signatureHash = keccak256(abi.encodePacked(beneficiary_, amount_,ext_));
        address secretSigner = ecrecover(signatureHash, v, r, s);
        require(_idMap[secretSigner] != 0,"this address isn't a manager");
        
        Channel storage channelInfo = _channelMap[_idMap[secretSigner]];
        //Query administrator privileges
        require(channelInfo.channelDelegate == secretSigner,"You are not the administrator of this channel.");
        //Is order completed?
        bytes32 orderId = keccak256(abi.encodePacked(ext_));
        require(!channelInfo.channelOrderHistory[orderId],"this order is deposit already");
        channelInfo.channelOrderHistory[orderId] = true;
        
        uint256 totalLeftEth = channelInfo.totalEth.sub(amount_);
        
        uint houseEdge = amount_ * HOUSE_EDGE_PERCENT / 1000;
        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }
        
        channelInfo.totalEth = totalLeftEth.sub(houseEdge);
        _total_house_edge = _total_house_edge.add(houseEdge);
        
        beneficiary_.transfer(amount_);
        
        emit depositSucc(_ID, channelInfo.channelID, beneficiary_, amount_, houseEdge, ext_);
        _ID++;
    }
    
    function withdraw() public onlyOwnerOrDelegate {
        require(_total_house_edge > 0,"no edge to withdraw");
        owner.transfer(_total_house_edge);
        
        emit withdrawSucc(_ID,_total_house_edge);
        _total_house_edge = 0;
        _ID++;
    }
    
    function depositBySuperAdmin(uint256 channelID_, uint256 amount_, address beneficiary_) public onlyOwner{
        require(now - last_time_admin_depoist >= ADMIN_DEPOIST_TIME_INTERVAL," super admin time limit");
        require(amount_ <= ADMIN_DEPOIST_MAX_AMOUNT," over super admin deposit amount limit");
        last_time_admin_depoist = now;
        Channel storage channelInfo = _channelMap[channelID_];
        uint256 totalLeftEth = channelInfo.totalEth.sub(amount_);
        channelInfo.totalEth = totalLeftEth;
        beneficiary_.transfer(amount_);
        
        emit depositBySuperAdminSucc(_ID, amount_, beneficiary_);
        _ID++;
    }
    
    struct Channel{
        string name;
        uint256 channelID;
        address channelDelegate;
        uint256 totalEth;
        uint256 partnershipCooperationBounsRate;
        mapping(bytes32 => bool) channelOrderHistory;
    }
    
    function destory() public onlyOwner whenPaused{
        selfdestruct(owner);    
    }
}


/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}
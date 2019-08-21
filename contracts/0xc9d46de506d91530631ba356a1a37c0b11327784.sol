pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Announceable is Ownable {

  string public announcement;

  function setAnnouncement(string value) public onlyOwner {
    announcement = value;
  }

}

contract Withdrawable {

  address public withdrawOwner;

  function Withdrawable(address _withdrawOwner) public {
    require(_withdrawOwner != address(0));
    withdrawOwner = _withdrawOwner;
  }

  /**
   * Transfers all the funs on this contract to the sender which must be withdrawOwner.
   */
  function withdraw() public {
    withdrawTo(msg.sender, this.balance);
  }

  /**
   * Transfers the given amount of funds to given beneficiary address. Must be called by the withdrawOwner.
   */
  function withdrawTo(address _beneficiary, uint _amount) public {
    require(msg.sender == withdrawOwner);
    require(_beneficiary != address(0));
    require(_amount > 0);
    _beneficiary.transfer(_amount);
  }

  /**
   * Transfer withdraw ownership to another account.
   */
  function setWithdrawOwner(address _newOwner) public {
    require(msg.sender == withdrawOwner);
    require(_newOwner != address(0));
    withdrawOwner = _newOwner;
  }

}

contract Cryptoverse is StandardToken, Ownable, Announceable, Withdrawable {
  using SafeMath for uint;

  string public constant name = "Cryptoverse Sector";
  string public constant symbol = "CVS";
  uint8 public constant decimals = 0;

  /**
   * Raised whenever grid sector is updated. The event will be raised for any update operation, even when nothing
   * effectively changes.
   */
  event SectorUpdated(
    uint16 indexed offset,
    address indexed owner,
    string link,
    string content,
    string title,
    bool nsfw
  );

  /** Structure holding the information about the sector state. */
  struct Sector {
    address owner;
    string link;
    string content;
    string title;
    bool nsfw;
    bool forceNsfw;
  }

  /** Time of the last purchase (or contract creation time). */
  uint public lastPurchaseTimestamp = now;

  /** Whether owner is allowed to claim free sectors. */
  bool public allowClaiming = true;

  /** The pricing */
  uint[13] public prices = [1000 finney, 800 finney, 650 finney, 550 finney, 500 finney, 450 finney, 400 finney, 350 finney, 300 finney, 250 finney, 200 finney, 150 finney, 100 finney];

  uint8 public constant width = 125;
  uint8 public constant height = 80;
  uint16 public constant length = 10000;

  /**
   * The current state of the grid is stored here.
   *
   * The grid has coordinates like screenspace/contentspace has: The [0;0] coordinate is at the top left corner. X axis
   * goes from top to bottom, Y axis goes from left to right.
   *
   * The coordinates are stored as grid[transform(x, y)] = grid[x + 125 * y], .
   */
  Sector[10000] public grid;

  function Cryptoverse() Withdrawable(msg.sender) public { }

  function () public payable {
    // how many sectors is sender going to buy
    // NOTE: purchase via fallback is at flat price
    uint sectorCount = msg.value / 1000 finney;
    require(sectorCount > 0);

    // fire transfer event ahead of update event
    Transfer(address(0), msg.sender, sectorCount);

    // now find as many free sectors
    for (uint16 offset = 0; offset < length; offset++) {
      Sector storage sector = grid[offset];

      if (sector.owner == address(0)) {
        // free sector
        setSectorOwnerInternal(offset, msg.sender, false);
        sectorCount--;

        if (sectorCount == 0) {
          return;
        }
      }
    }

    // not enough available free sectors
    revert();
  }

  /**
   * Purchases the sectors at given offsets. The array length must be even and the bounds must be within grid size.
   */
  function buy(uint16[] memory _offsets) public payable {
    require(_offsets.length > 0);
    uint cost = _offsets.length * currentPrice();
    require(msg.value >= cost);

    // fire transfer event ahead of update event
    Transfer(address(0), msg.sender, _offsets.length);

    for (uint i = 0; i < _offsets.length; i++) {
      setSectorOwnerInternal(_offsets[i], msg.sender, false);
    }
  }

  /**
  * !override
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) public returns (bool result) {
    result = super.transfer(_to, _value);

    if (result && _value > 0) {
      transferSectorOwnerInternal(_value, msg.sender, _to);
    }
  }

  /**
   * !override
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint _value) public returns (bool result) {
    result = super.transferFrom(_from, _to, _value);

    if (result && _value > 0) {
      transferSectorOwnerInternal(_value, _from, _to);
    }
  }

  /**
   * Allows to transfer the sectors at given coordinates to a new owner.
   */
  function transferSectors(uint16[] memory _offsets, address _to) public returns (bool result) {
    result = super.transfer(_to, _offsets.length);

    if (result) {
      for (uint i = 0; i < _offsets.length; i++) {
        Sector storage sector = grid[_offsets[i]];
        require(sector.owner == msg.sender);
        setSectorOwnerInternal(_offsets[i], _to, true);
      }
    }
  }

  /**
   * Sets the state of the sector by its rightful owner.
   */
  function set(uint16[] memory _offsets, string _link, string _content, string _title, bool _nsfw) public {
    require(_offsets.length > 0);
    for (uint i = 0; i < _offsets.length; i++) {
      Sector storage sector = grid[_offsets[i]];
      require(msg.sender == sector.owner);

      sector.link = _link;
      sector.content = _content;
      sector.title = _title;
      sector.nsfw = _nsfw;

      onUpdatedInternal(_offsets[i], sector);
    }
  }

  /**
   * Sets the owner of the sector.
   *
   * - Does not check whether caller is allowed to do that.
   * - Does not manipulate balances upon transfer (ensure to call appropriate parent functions).
   */
  function setSectorOwnerInternal(uint16 _offset, address _to, bool _canTransfer) internal {
    require(_to != address(0));

    // coordinate checks is done by an array type
    Sector storage sector = grid[_offset];

    // sector must be empty (not purchased yet)
    address from = sector.owner;
    bool isTransfer = (from != address(0));
    require(_canTransfer || !isTransfer);

    // variable is a reference to the storage, this will persist the info
    sector.owner = _to;

    // NOTE: do not manipulate balance on transfer, only on initial purchase
    if (!isTransfer) {
      // initial sector purchase
      totalSupply = totalSupply.add(1);
      balances[_to] = balances[_to].add(1);
      lastPurchaseTimestamp = now;
    }

    onUpdatedInternal(_offset, sector);
  }

  /**
   * Transfers the owner of _value implicit sectors.
   *
   * !throws Reverts when the _from does not own as many as _value sectors.
   */
  function transferSectorOwnerInternal(uint _value, address _from, address _to) internal {
    require(_value > 0);
    require(_from != address(0));
    require(_to != address(0));

    uint sectorCount = _value;

    for (uint16 offsetPlusOne = length; offsetPlusOne > 0; offsetPlusOne--) {
      Sector storage sector = grid[offsetPlusOne - 1];

      if (sector.owner == _from) {
        setSectorOwnerInternal(offsetPlusOne - 1, _to, true);
        sectorCount--;

        if (sectorCount == 0) {
          // we have transferred exactly _value ownerships
          return;
        }
      }
    }

    // _from does not own at least _value sectors
    revert();
  }

  function setForceNsfw(uint16[] memory _offsets, bool _nsfw) public onlyOwner {
    require(_offsets.length > 0);
    for (uint i = 0; i < _offsets.length; i++) {
      Sector storage sector = grid[_offsets[i]];
      sector.forceNsfw = _nsfw;

      onUpdatedInternal(_offsets[i], sector);
    }
  }

  /**
   * Gets the current price in wei.
   */
  function currentPrice() public view returns (uint) {
    uint sinceLastPurchase = (block.timestamp - lastPurchaseTimestamp);

    for (uint i = 0; i < prices.length - 1; i++) {
      if (sinceLastPurchase < (i + 1) * 1 days) {
        return prices[i];
      }
    }

    return prices[prices.length - 1];
  }

  function transform(uint8 _x, uint8 _y) public pure returns (uint16) {
    uint16 offset = _y;
    offset = offset * width;
    offset = offset + _x;
    return offset;
  }

  function untransform(uint16 _offset) public pure returns (uint8, uint8) {
    uint8 y = uint8(_offset / width);
    uint8 x = uint8(_offset - y * width);
    return (x, y);
  }

  function claimA() public { claimInternal(60, 37, 5, 5); }
  function claimB1() public { claimInternal(0, 0, 62, 1); }
  function claimB2() public { claimInternal(62, 0, 63, 1); }
  function claimC1() public { claimInternal(0, 79, 62, 1); }
  function claimC2() public { claimInternal(62, 79, 63, 1); }
  function claimD() public { claimInternal(0, 1, 1, 78); }
  function claimE() public { claimInternal(124, 1, 1, 78); }
  function claimF() public { claimInternal(20, 20, 8, 8); }
  function claimG() public { claimInternal(45, 10, 6, 10); }
  function claimH1() public { claimInternal(90, 50, 8, 10); }
  function claimH2() public { claimInternal(98, 50, 7, 10); }
  function claimI() public { claimInternal(94, 22, 7, 7); }
  function claimJ() public { claimInternal(48, 59, 12, 8); }

  /**
   * Closes the opportunity to claim free blocks for the owner for good.
   */
  function closeClaims() public onlyOwner {
    allowClaiming = false;
  }

  function claimInternal(uint8 _left, uint8 _top, uint8 _width, uint8 _height) internal {
    require(allowClaiming);

    // NOTE: SafeMath not needed, we operate on safe numbers
    uint8 _right = _left + _width;
    uint8 _bottom = _top + _height;

    uint area = _width;
    area = area * _height;
    Transfer(address(0), owner, area);

    for (uint8 x = _left; x < _right; x++) {
      for (uint8 y = _top; y < _bottom; y++) {
        setSectorOwnerInternal(transform(x, y), owner, false);
      }
    }
  }

  /**
   * Raises SectorUpdated event.
   */
  function onUpdatedInternal(uint16 _offset, Sector storage _sector) internal {
    SectorUpdated(
      _offset,
      _sector.owner,
      _sector.link,
      _sector.content,
      _sector.title,
      _sector.nsfw || _sector.forceNsfw
    );
  }

}
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
    require(b > 0); // Solidity only automatically asserts when dividing by 0
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
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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
contract GTXRecord is Ownable {
    using SafeMath for uint256;

    // conversionRate is the multiplier to calculate the number of GTX claimable per FIN Point converted
    // e.g., 100 = 1:1 conversion ratio
    uint256 public conversionRate;

    // a flag for locking record changes, lockRecords is only settable by the owner
    bool public lockRecords;

    // Maximum amount of recorded GTX able to be stored on this contract
    uint256 public maxRecords;

    // Total number of claimable GTX converted from FIN Points
    uint256 public totalClaimableGTX;

    // an address map used to store the per account claimable GTX
    // as a result of converted FIN Points
    mapping (address => uint256) public claimableGTX;

    event GTXRecordCreate(
        address indexed _recordAddress,
        uint256 _finPointAmount,
        uint256 _gtxAmount
    );

    event GTXRecordUpdate(
        address indexed _recordAddress,
        uint256 _finPointAmount,
        uint256 _gtxAmount
    );

    event GTXRecordMove(
        address indexed _oldAddress,
        address indexed _newAddress,
        uint256 _gtxAmount
    );

    event LockRecords();

    /**
     * Throws if conversionRate is not set or if the lockRecords flag has been set to true
    */
    modifier canRecord() {
        require(conversionRate > 0);
        require(!lockRecords);
        _;
    }

    /**
     * @dev GTXRecord constructor
     * @param _maxRecords is the maximum numer of GTX records this contract can store (used for sanity checks on GTX ERC20 totalsupply)
    */
    constructor (uint256 _maxRecords) public {
        maxRecords = _maxRecords;
    }

    /**
     * @dev sets the GTX Conversion rate
     * @param _conversionRate is the rate applied during FIN Point to GTX conversion
    */
    function setConversionRate(uint256 _conversionRate) external onlyOwner{
        require(_conversionRate <= 1000); // maximum 10x conversion rate
        require(_conversionRate > 0); // minimum .01x conversion rate
        conversionRate = _conversionRate;
    }

   /**
    * @dev Function to lock record changes on this contracts
    * @return True if the operation was successful.
    */
    function lock() public onlyOwner returns (bool) {
        lockRecords = true;
        emit LockRecords();
        return true;
    }

    /**
    * @dev Used to calculate and store the amount of claimable GTX for those exsisting FIN point holders
    * who opt to convert FIN points for GTX
    * @param _recordAddress - the registered address where GTX can be claimed from
    * @param _finPointAmount - the amount of FINs to be converted for GTX, this param should always be entered as base units
    * i.e., 1 FIN = 10**18 base units
    * @param _applyConversionRate - flag to apply conversion rate or not, any Finterra Technologies company GTX conversion allocations
    * are strictly covnerted at one to one and do not recive the conversion bonus applied to FIN point user balances
    */
    function recordCreate(address _recordAddress, uint256 _finPointAmount, bool _applyConversionRate) public onlyOwner canRecord {
        require(_finPointAmount >= 100000, "cannot be less than 100000 FIN (in WEI)"); // minimum allowed FIN 0.000000000001 (in base units) to avoid large rounding errors
        uint256 afterConversionGTX;
        if(_applyConversionRate == true) {
            afterConversionGTX = _finPointAmount.mul(conversionRate).div(100);
        } else {
            afterConversionGTX = _finPointAmount;
        }
        claimableGTX[_recordAddress] = claimableGTX[_recordAddress].add(afterConversionGTX);
        totalClaimableGTX = totalClaimableGTX.add(afterConversionGTX);
        require(totalClaimableGTX <= maxRecords, "total token record (contverted GTX) cannot exceed GTXRecord token limit");
        emit GTXRecordCreate(_recordAddress, _finPointAmount, claimableGTX[_recordAddress]);
    }

    /**
    * @dev Used to calculate and update the amount of claimable GTX for those exsisting FIN point holders
    * who opt to convert FIN points for GTX
    * @param _recordAddress - the registered address where GTX can be claimed from
    * @param _finPointAmount - the amount of FINs to be converted for GTX, this param should always be entered as base units
    * i.e., 1 FIN = 10**18 base units
    * @param _applyConversionRate - flag to apply conversion rate or do one for one conversion, any Finterra Technologies company FIN point allocations
    * are strictly converted at one to one and do not recive the cnversion bonus applied to FIN point user balances
    */
    function recordUpdate(address _recordAddress, uint256 _finPointAmount, bool _applyConversionRate) public onlyOwner canRecord {
        require(_finPointAmount >= 100000, "cannot be less than 100000 FIN (in WEI)"); // minimum allowed FIN 0.000000000001 (in base units) to avoid large rounding errors
        uint256 afterConversionGTX;
        totalClaimableGTX = totalClaimableGTX.sub(claimableGTX[_recordAddress]);
        if(_applyConversionRate == true) {
            afterConversionGTX  = _finPointAmount.mul(conversionRate).div(100);
        } else {
            afterConversionGTX  = _finPointAmount;
        }
        claimableGTX[_recordAddress] = afterConversionGTX;
        totalClaimableGTX = totalClaimableGTX.add(claimableGTX[_recordAddress]);
        require(totalClaimableGTX <= maxRecords, "total token record (contverted GTX) cannot exceed GTXRecord token limit");
        emit GTXRecordUpdate(_recordAddress, _finPointAmount, claimableGTX[_recordAddress]);
    }

    /**
    * @dev Used to move GTX records from one address to another, primarily in case a user has lost access to their originally registered account
    * @param _oldAddress - the original registered address
    * @param _newAddress - the new registerd address
    */
    function recordMove(address _oldAddress, address _newAddress) public onlyOwner canRecord {
        require(claimableGTX[_oldAddress] != 0, "cannot move a zero record");
        require(claimableGTX[_newAddress] == 0, "destination must not already have a claimable record");

        claimableGTX[_newAddress] = claimableGTX[_oldAddress];
        claimableGTX[_oldAddress] = 0;

        emit GTXRecordMove(_oldAddress, _newAddress, claimableGTX[_newAddress]);
    }

}
/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        owner = msg.sender;
    }

    address public newOwner;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    function changeOwner(address _newOwner) onlyOwner {
        if(msg.sender == owner) {
            owner = _newOwner;
        }
    }
}




/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}


contract AccountOwnership is Owned {
  using SafeMath for uint256;
  
  mapping (address => uint256) public transfers;
  address public depositAddress;
  
  event RefundTransfer(uint256 date, uint256 paid, uint256 refunded, address user);
  
  function AccountOwnership() payable {
  }

  function withdrawEther (address _to) onlyOwner {
    _to.transfer(this.balance);
  }

  function setDepositAddress(address _depositAddress) onlyOwner {
    depositAddress = _depositAddress;
  }

  function ()  payable {
    require(msg.value > 0);
    if (depositAddress != msg.sender) {
      transfers[msg.sender] = msg.value;
      msg.sender.transfer(msg.value);
      RefundTransfer(now, msg.value, msg.value, msg.sender);
    }
  }
}
pragma solidity 0.4.25;

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

contract ERC20 {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


library SafeERC20 {
  function safeTransfer(ERC20 token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}


/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract CGCXMassLock is Ownable {
  using SafeERC20 for ERC20;

  // ERC20 basic token contract being held
  ERC20 public token;

  // beneficiery -> amounts
  mapping (address => uint256) public lockups;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  constructor(
    address _token
  )
    public
  {
    // solium-disable-next-line security/no-block-members
    token = ERC20(_token);
    releaseTime = 1546128000; // 30 Dec 2018
  }

  function release() public  {
    releaseFrom(msg.sender);
  }

  function releaseFrom(address _beneficiary) public {
    require(block.timestamp >= releaseTime);
    uint256 amount = lockups[_beneficiary];
    require(amount > 0);
    token.safeTransfer(_beneficiary, amount);
    lockups[_beneficiary] = 0;
  }

  function releaseFromMultiple(address[] _addresses) public {
    for (uint256 i = 0; i < _addresses.length; i++) {
      releaseFrom(_addresses[i]);
    }
  } 

  function submit(address[] _addresses, uint256[] _amounts) public onlyOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      lockups[_addresses[i]] = _amounts[i];
    }
  }

}
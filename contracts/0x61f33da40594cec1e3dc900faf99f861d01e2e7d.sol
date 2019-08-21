pragma solidity ^0.4.18;

library SafeMath {
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

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

contract ERC20 {
    function totalSupply() public constant returns (uint supply);
    function balanceOf( address owner ) public constant returns (uint value);
    function allowance( address owner, address spender ) public constant returns (uint _allowance);

    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}

contract Token is ERC20 {

  using SafeMath for uint256;

  uint256                                             supply;
  mapping(address => uint256)                         balances;
  mapping (address => mapping (address => uint256))   approvals;

  function balanceOf(address owner) public constant returns (uint256 balance) {
    return balances[owner];
  }

  function allowance(address owner, address spender) public constant returns (uint256) {
    return approvals[owner][spender];
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(balances[_to] < balances[_to].add(_value));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {

        assert(balances[from] >= value);
        assert(approvals[from][msg.sender] >= value);
        
        approvals[from][msg.sender] = approvals[from][msg.sender].sub(value);
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        
        Transfer(from, to, value);
        
        return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {
        approvals[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
  }

  function totalSupply() public constant returns (uint) {
    return supply;
  }

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CybereitsToken is Token, Ownable {
    string public name = "Cybereits Token";
    string public symbol = "CRE";
    uint public decimals;

    address public teamLockAddr;

    function CybereitsToken(
      uint256 total,
      uint256 _decimals, 
      uint256 _teamLockPercent,
      address _teamAddr1,
      address _teamAddr2,
      address _teamAddr3,
      address _teamAddr4,
      address _teamAddr5,
      address _teamAddr6
    ) public
    {
        decimals = _decimals;
        var multiplier = 10 ** decimals;
        supply = total * multiplier;
        var teamLockAmount = _teamLockPercent * supply / 100;
        teamLockAddr = new CybereitsTeamLock(
          teamLockAmount,
          _teamAddr1,
          _teamAddr2,
          _teamAddr3,
          _teamAddr4,
          _teamAddr5,
          _teamAddr6
        );
        balances[teamLockAddr] = teamLockAmount;
        balances[msg.sender] = supply - teamLockAmount;
    }
}

contract CybereitsTeamLock {

    event Unlock(address from, uint amount);

    mapping (address => uint256) allocations;
    mapping (address => uint256) frozen;

    CybereitsToken cre;

    function CybereitsTeamLock(
      uint256 lockAmount,
      address _teamAddr1,
      address _teamAddr2,
      address _teamAddr3,
      address _teamAddr4,
      address _teamAddr5,
      address _teamAddr6
    ) public
    {
        cre = CybereitsToken(msg.sender);
        allocations[_teamAddr1] = lockAmount / 6;
        frozen[_teamAddr1] = now + 6 * 30 days;
        allocations[_teamAddr2] = lockAmount / 6;
        frozen[_teamAddr2] = now + 12 * 30 days;
        allocations[_teamAddr3] = lockAmount / 6;
        frozen[_teamAddr3] = now + 18 * 30 days;
        allocations[_teamAddr4] = lockAmount / 6;
        frozen[_teamAddr4] = now + 24 * 30 days;
        allocations[_teamAddr5] = lockAmount / 6;
        frozen[_teamAddr5] = now + 30 * 30 days;
        allocations[_teamAddr6] = lockAmount / 6;
        frozen[_teamAddr6] = now + 36 * 30 days;
    }

    function unlock(address unlockAddr) external returns (bool) {
        require(allocations[unlockAddr] != 0);
        require(now >= frozen[unlockAddr]);

        var amount = allocations[unlockAddr];
        assert(cre.transfer(unlockAddr, amount));
        allocations[unlockAddr] = 0;
        Unlock(unlockAddr, amount);
        return true;
    }
}
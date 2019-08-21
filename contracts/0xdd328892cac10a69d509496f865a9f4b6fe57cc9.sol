pragma solidity ^0.5.0;

// File: contracts/math/SafeMath.sol

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;

    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/blacklist/Blacklist.sol

library Blacklist {
  struct List {
    mapping(address => bool) registry;
  }
  function add(List storage list, address beneficiary) internal {
    list.registry[beneficiary] = true;
  }
  function remove(List storage list, address beneficiary) internal {
    list.registry[beneficiary] = false;
  }
  function check(List storage list, address beneficiary) view internal returns (bool) {
    return list.registry[beneficiary];
  }
}

// File: contracts/ownership/Multiownable.sol

contract Multiownable {

  uint256 public ownersGeneration;
  uint256 public howManyOwnersDecide;
  address[] public owners;
  bytes32[] public allOperations;
  address internal insideCallSender;
  uint256 internal insideCallCount;

  // Reverse lookup tables for owners and allOperations
  mapping(address => uint) public ownersIndices;
  mapping(bytes32 => uint) public allOperationsIndicies;

  // Owners voting mask per operations
  mapping(bytes32 => uint256) public votesMaskByOperation;
  mapping(bytes32 => uint256) public votesCountByOperation;

  event OwnershipTransferred(address[] previousOwners, uint howManyOwnersDecide, address[] newOwners, uint newHowManyOwnersDecide);
  event OperationCreated(bytes32 operation, uint howMany, uint ownersCount, address proposer);
  event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint ownersCount, address upvoter);
  event OperationPerformed(bytes32 operation, uint howMany, uint ownersCount, address performer);
  event OperationDownvoted(bytes32 operation, uint votes, uint ownersCount,  address downvoter);
  event OperationCancelled(bytes32 operation, address lastCanceller);

  function isOwner(address wallet) public view returns(bool) {
    return ownersIndices[wallet] > 0;
  }

  function ownersCount() public view returns(uint) {
    return owners.length;
  }

  function allOperationsCount() public view returns(uint) {
    return allOperations.length;
  }

  /**
  * @dev Allows to perform method by any of the owners
  */
  modifier onlyAnyOwner {
    if (checkHowManyOwners(1)) {
      bool update = (insideCallSender == address(0));
      if (update) {
        insideCallSender = msg.sender;
        insideCallCount = 1;
      }
      _;
      if (update) {
        insideCallSender = address(0);
        insideCallCount = 0;
      }
    }
  }

  /**
  * @dev Allows to perform method only after some owners call it with the same arguments
  */
  modifier onlyOwners() {
    require(howManyOwnersDecide > 0);
    require(howManyOwnersDecide <= owners.length);

    if (checkHowManyOwners(howManyOwnersDecide)) {
      bool update = (insideCallSender == address(0));
      if (update) {
        insideCallSender = msg.sender;
        insideCallCount = howManyOwnersDecide;
      }
      _;
      if (update) {
        insideCallSender = address(0);
        insideCallCount = 0;
      }
    }
  }

  constructor(address[] memory _owners) public {
    owners.push(msg.sender);
    ownersIndices[msg.sender] = 1;
    howManyOwnersDecide = 1;
    transferOwnership(_owners, 2);
  }

  /**
  * @dev onlyManyOwners modifier helper
  */
  function checkHowManyOwners(uint howMany) internal returns(bool) {
    if (insideCallSender == msg.sender) {
      require(howMany <= insideCallCount);
      return true;
    }

    uint ownerIndex = ownersIndices[msg.sender] - 1;
    require(ownerIndex < owners.length);
    bytes32 operation = keccak256(abi.encodePacked(msg.data, ownersGeneration));

    require((votesMaskByOperation[operation] & (2 ** ownerIndex)) == 0);
    votesMaskByOperation[operation] |= (2 ** ownerIndex);
    uint operationVotesCount = votesCountByOperation[operation] + 1;
    votesCountByOperation[operation] = operationVotesCount;
    if (operationVotesCount == 1) {
      allOperationsIndicies[operation] = allOperations.length;
      allOperations.push(operation);
      emit OperationCreated(operation, howMany, owners.length, msg.sender);
    }
    emit OperationUpvoted(operation, operationVotesCount, howMany, owners.length, msg.sender);

    // If enough owners confirmed the same operation
    if (votesCountByOperation[operation] == howMany) {
      deleteOperation(operation);
      emit OperationPerformed(operation, howMany, owners.length, msg.sender);
      return true;
    }

    return false;
  }

  function deleteOperation(bytes32 operation) internal {
    uint index = allOperationsIndicies[operation];
    if (index < allOperations.length - 1) { // Not last
      allOperations[index] = allOperations[allOperations.length - 1];
      allOperationsIndicies[allOperations[index]] = index;
    }
    allOperations.length--;

    delete votesMaskByOperation[operation];
    delete votesCountByOperation[operation];
    delete allOperationsIndicies[operation];
  }

  function cancelPending(bytes32 operation) public onlyAnyOwner {
    uint ownerIndex = ownersIndices[msg.sender] - 1;
    require((votesMaskByOperation[operation] & (2 ** ownerIndex)) != 0);
    votesMaskByOperation[operation] &= ~(2 ** ownerIndex);
    uint operationVotesCount = votesCountByOperation[operation] - 1;
    votesCountByOperation[operation] = operationVotesCount;
    emit OperationDownvoted(operation, operationVotesCount, owners.length, msg.sender);
    if (operationVotesCount == 0) {
      deleteOperation(operation);
      emit OperationCancelled(operation, msg.sender);
    }
  }

  function transferOwnership(address[] memory newOwners, uint256 _howManyOwnersDecide) public onlyAnyOwner {
    _transferOwnership(newOwners, _howManyOwnersDecide);
  }

  function _transferOwnership(address[] memory newOwners, uint256 newHowManyOwnersDecide) internal onlyOwners {
    require(newOwners.length > 0);
    require(newOwners.length <= 256);
    require(newHowManyOwnersDecide > 0);
    require(newHowManyOwnersDecide <= newOwners.length);

    // Reset owners reverse lookup table
    for (uint j = 0; j < owners.length; j++) {
      delete ownersIndices[owners[j]];
    }
    for (uint i = 0; i < newOwners.length; i++) {
      require(newOwners[i] != address(0));
      require(ownersIndices[newOwners[i]] == 0);
      ownersIndices[newOwners[i]] = i + 1;
    }

    emit OwnershipTransferred(owners, howManyOwnersDecide, newOwners, newHowManyOwnersDecide);
    owners = newOwners;
    howManyOwnersDecide = newHowManyOwnersDecide;
    allOperations.length = 0;
    ownersGeneration++;
  }

}

// File: contracts/blacklist/Blacklisted.sol

contract Blacklisted is Multiownable {
  Blacklist.List private _list;
  modifier whenNotFrozen() {
    require(Blacklist.check(_list, msg.sender) == false);
    _;
  }
  event AddressAdded(address[] beneficiary);
  event AddressRemoved(address[] beneficiary);

  function freezeAccount(address[] calldata _beneficiary) external onlyOwners {
    for (uint256 i = 0; i < _beneficiary.length; i++) {
      Blacklist.add(_list, _beneficiary[i]);
    }
    emit AddressAdded(_beneficiary);
  }

  function deFreezeAccount(address[] calldata _beneficiary) external onlyOwners {
    for (uint256 i = 0; i < _beneficiary.length; i++) {
      Blacklist.remove(_list, _beneficiary[i]);
    }
    emit AddressRemoved(_beneficiary);
  }

  function isFrozen(address _beneficiary) external view returns (bool){
    return Blacklist.check(_list, _beneficiary);
  }
}

// File: contracts/lifecycle/Pausable.sol

contract Pausable is Multiownable {

  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() whenNotPaused onlyOwners external {
    paused = true;
    emit Pause();
  }

  function unpause() whenPaused onlyOwners external {
    paused = false;
    emit Unpause();
  }
}

// File: contracts/token/BasicInterface.sol

contract ERC20 {
    function balanceOf(address tokenOwner) public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

// File: contracts/token/BasicToken.sol

contract BasicToken is ERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  uint256 public _totalSupply;

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256 balance) {
    return balances[owner];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  function _transfer(address from, address to, uint256 value) internal {
    require(address(to) != address(0));
    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);
    emit Transfer(from, to, value);
  }

}

// File: contracts/token/StandardToken.sol

contract StandardToken is BasicToken {
  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    emit Approval(from, msg.sender, allowed[from][msg.sender]);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {
    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function allowance(address owner, address spender) public view returns (uint256 remaining) {
    return allowed[owner][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }
}

// File: contracts/token/BurnableToken.sol

contract BurnableToken is StandardToken {

  function burn(address account, uint256 value) public {
    require(account != address(0));
    _totalSupply = _totalSupply.sub(value);
    balances[account] = balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  function burnFrom(address account, uint256 value) public {
    allowed[account][msg.sender] = allowed[account][msg.sender].sub(value);
    burn(account, value);
    emit Approval(account, msg.sender, allowed[account][msg.sender]);
  }

}

// File: contracts/Hydra.sol

contract MultiSignatureVault is Multiownable {

  bool lockState;
  function () external payable {}

  constructor(address[] memory _owners) public Multiownable(_owners) {
    lockState = false;
  }

  function transferTo(address payable to, uint256 amount) external onlyOwners {
    require(!lockState);
    lockState = true;
    to.transfer(amount);
    lockState = false;
  }

  function transferTokensTo(address token, address to, uint256 amount) external onlyOwners {
    require(!lockState);
    lockState = true;
    ERC20(token).transfer(to, amount);
    lockState = false;
  }
}

contract Hydra is StandardToken, BurnableToken, Blacklisted, Pausable {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  MultiSignatureVault public vaultTeam;
  MultiSignatureVault public vaultInvestor;
  MultiSignatureVault public vaultOperation;

  constructor(address[] memory owners) public Multiownable(owners) {
    _name = "Hydra Token";
    _symbol = "HDRA";
    _decimals = 18;
    _totalSupply = 300000000E18;

    vaultTeam = new MultiSignatureVault(owners);
    vaultInvestor = new MultiSignatureVault(owners);
    vaultOperation = new MultiSignatureVault(owners);

    balances[address(vaultTeam)] = 60000000E18;
    balances[address(vaultInvestor)] = 150000000E18;
    balances[address(vaultOperation)] = 90000000E18;

    emit Transfer(address(this), address(vaultTeam), 60000000E18);
    emit Transfer(address(this), address(vaultInvestor), 150000000E18);
    emit Transfer(address(this), address(vaultOperation), 90000000E18);
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function transfer(address to, uint256 value) public whenNotPaused whenNotFrozen returns (bool) {
    return super.transfer(to, value);
  }

  function transferFrom(address from, address to, uint256 value) public whenNotPaused whenNotFrozen returns (bool) {
    return super.transferFrom(from, to, value);
  }

  function approve(address spender, uint256 value) public whenNotPaused whenNotFrozen returns (bool) {
    return super.approve(spender, value);
  }

  function increaseAllowance(address spender, uint addedValue) public whenNotPaused whenNotFrozen returns (bool success) {
    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused whenNotFrozen returns (bool success) {
    return super.decreaseAllowance(spender, subtractedValue);
  }
}
pragma solidity ^0.4.18;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/InsightsNetworkContributions.sol

contract InsightsNetworkContributions is Ownable {

    string public name;
    uint256 public cap;
    uint256 public contributionMinimum;
    uint256 public contributionMaximum;
    uint256 public gasPriceMaximum;

    bool enabled;
    uint256 total;

    mapping (address => bool) public registered;
    mapping (address => uint256) public balances;

    event Approval(address indexed account, bool valid);
    event Contribution(address indexed contributor, uint256 amount);
    event Transfer(address indexed recipient, uint256 amount, address owner);

    function InsightsNetworkContributions(string _name, uint256 _cap, uint256 _contributionMinimum, uint256 _contributionMaximum, uint256 _gasPriceMaximum) public {
        require(_contributionMinimum <= _contributionMaximum);
        require(_contributionMaximum > 0);
        require(_contributionMaximum <= _cap);
        name = _name;
        cap = _cap;
        contributionMinimum = _contributionMinimum;
        contributionMaximum = _contributionMaximum;
        gasPriceMaximum = _gasPriceMaximum;
        enabled = false;
    }

    function () external payable {
        contribute();
    }

    function contribute() public payable {
        require(enabled);
        require(tx.gasprice <= gasPriceMaximum);
        address sender = msg.sender;
        require(registered[sender]);
        uint256 value = msg.value;
        uint256 balance = balances[sender] + value;
        require(balance >= contributionMinimum);
        require(balance <= contributionMaximum);
        require(total + value <= cap);
        balances[sender] = balance;
        total += value;
        Contribution(sender, value);
    }

    function enable(bool _enabled) public onlyOwner {
        enabled = _enabled;
    }

    function register(address account, bool valid) public onlyOwner {
        require(account != 0);
        registered[account] = valid;
        Approval(account, valid);
    }

    function registerMultiple(address[] accounts, bool valid) public onlyOwner {
        require(accounts.length <= 128);
        for (uint index = 0; index < accounts.length; index++) {
            address account = accounts[index];
            require(account != 0);
            registered[account] = valid;
            Approval(account, valid);
        }
    }

    function transfer(address recipient, uint256 amount) public onlyOwner {
        require(recipient != 0);
        require(amount <= this.balance);
        Transfer(recipient, amount, owner);
        recipient.transfer(amount);
    }

    function selfDestruct() public onlyOwner {
        require(!enabled);
        require(this.balance == 0);
        selfdestruct(owner);
    }

}
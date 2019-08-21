pragma solidity ^0.4.17;

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

contract GiftEth {

  event RecipientChanged(address indexed _oldRecipient, address indexed _newRecipient);

  address public gifter;
  address public recipient;
  uint256 public lockTs;
  string public giftMessage;

  function GiftEth(address _gifter, address _recipient, uint256 _lockTs, string _giftMessage) payable public {
    gifter = _gifter;
    recipient = _recipient;
    lockTs = _lockTs;
    giftMessage = _giftMessage;
  }

  function withdraw() public {
    require(msg.sender == recipient);
    require(now >= lockTs);
    msg.sender.transfer(this.balance);
  }

  function changeRecipient(address _newRecipient) public {
    require(msg.sender == recipient);
    RecipientChanged(recipient, _newRecipient);
    recipient = _newRecipient;
  }

}

contract GiftEthFactory is Ownable {

  event GiftGenerated(address indexed _gifter, address indexed _recipient, address indexed _gift, uint256 _amount, uint256 _lockTs, string _giftMessage);
  event Frozen(bool _frozen);

  bool public frozen;

  modifier notFrozen {
    require(!frozen);
    _;
  }

  function setFrozen(bool _frozen) public onlyOwner {
    frozen = _frozen;
    Frozen(frozen);
  }

  function giftEth(address _recipient, uint256 _lockTs, string _giftMessage) payable public notFrozen {
    GiftEth gift = (new GiftEth).value(msg.value)(msg.sender, _recipient, _lockTs, _giftMessage);
    GiftGenerated(msg.sender, _recipient, address(gift), msg.value, _lockTs, _giftMessage);
  }

}
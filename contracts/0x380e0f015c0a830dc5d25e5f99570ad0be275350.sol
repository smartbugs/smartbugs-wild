pragma solidity ^0.4.19;

contract Button {
  event Pressed(address indexed presser, uint256 endBlock);
  event Winner(address winner, uint256 winnings);
  event Donation(address donator, uint256 amount);

  address public factory = msg.sender;

  uint64 public countdown;
  uint64 public countdownDecrement;
  uint64 public cooloffIncrement;
  uint64 public pressFee;
  uint64 public signupFee; // basis points * contract value

  address public lastPresser;
  uint64 public endBlock;

  struct Presser {
    uint64 numPresses;
    uint64 cooloffEnd;
  }

  mapping (address => Presser) public pressers;

  // Signup fee collection.
  address public owner;
  uint256 public rake;

  constructor (
    uint64 _countdown, 
    uint64 _countdownDecrement, 
    uint64 _cooloffIncrement, 
    uint64 _pressFee, 
    uint64 _signupFee, 
    address _sender
  ) public payable {
    countdown = _countdown;
    countdownDecrement = _countdownDecrement;
    cooloffIncrement = _cooloffIncrement;
    pressFee = _pressFee;
    signupFee = _signupFee;
    lastPresser = _sender;

    owner = _sender;
    endBlock = uint64(block.number + countdown);
  }

  function getInfo() public view returns(
    uint64, // Countdown
    uint64, // CountdownDecrement
    uint64, // CooloffIncrement
    uint64, // PressFee
    uint64, // SignupFee
    address,// LastPresser
    uint64, // EndBlock
    uint64, // NumPresses
    uint64, // CooloffEnd
    uint256 // Pot
  ) {
    Presser p = pressers[msg.sender];
    return (
      countdown, 
      countdownDecrement, 
      cooloffIncrement, 
      pressFee, 
      signupFee, 
      lastPresser, 
      endBlock, 
      p.numPresses,
      p.cooloffEnd,
      address(this).balance-rake
    );
  }

  function press() public payable {
    require(block.number <= endBlock);

    Presser storage p = pressers[msg.sender];
    require(p.cooloffEnd < block.number);

    uint256 change = msg.value-pressFee;
    if (p.numPresses == 0) {
      // balance - value will never be negative.
      uint128 npf = _newPresserFee(address(this).balance - rake - msg.value);
      change -= npf;
      rake += npf;
    }
    // Breaks when pressFee+newPresserFee > 2^256
    require(change <= msg.value);

    lastPresser = msg.sender;
    uint64 finalCountdown = countdown - (p.numPresses*countdownDecrement);
    if (finalCountdown < 10 || finalCountdown > countdown) {
      finalCountdown = 10;
    }
    endBlock = uint64(block.number + finalCountdown);

    p.numPresses++;
    p.cooloffEnd = uint64(block.number + (p.numPresses*cooloffIncrement));

    if (change > 0) {
      // Re-entrancy protected by p.cooloffEnd guard.
      msg.sender.transfer(change);
    }

    emit Pressed(msg.sender, endBlock);
  }

  function close() public {
    require(block.number > endBlock);

    ButtonFactory f = ButtonFactory(factory);

    if (!owner.send(3*rake/4)){
      // Owner can't accept their portion of the rake, so send it to the factory.
      f.announceWinner.value(rake)(lastPresser, address(this).balance);
    } else {
      f.announceWinner.value(rake/4)(lastPresser, address(this).balance);
    }

    emit Winner(lastPresser, address(this).balance);
    selfdestruct(lastPresser);
  }

  // Breaks when balance = 10^20 ether.
  function newPresserFee() public view returns (uint128) {
    return _newPresserFee(address(this).balance-rake);
  }

  // Caller must assure that _balance < max_uint128.
  function _newPresserFee(uint256 _balance) private view returns (uint128) {
    return uint128((_balance * signupFee) / 10000);
  }

  // Up the stakes...
  function() payable public {
    emit Donation(msg.sender, msg.value);
  }
}

// Hey, my name is Joe...
contract ButtonFactory {
  event NewButton(address indexed buttonAddr, address indexed creator, uint64 countdown, uint64 countdownDec, uint64 cooloffInc, uint64 pressFee, uint64 signupFee);
  event ButtonWinner(address indexed buttonAddr, address indexed winner, uint256 pot);

  address public owner = msg.sender;
  uint256 public creationFee;

  mapping (address => bool) buttons;

  function setCreationFee(uint256 _fee) public {
    require(msg.sender == owner);
    creationFee = _fee;
  }

  function createButton(
    uint64 _countdown, 
    uint64 _countdownDecrement, 
    uint64 _cooloffIncrement, 
    uint64 _pressFee, 
    uint64 _signupFee
  ) public payable returns (address) {
    uint256 cf = ((_countdown / 1441) + 1) * creationFee;
    require(msg.value >= cf);
    address newButton = new Button(_countdown, _countdownDecrement, _cooloffIncrement, _pressFee, _signupFee, msg.sender);
    buttons[newButton] = true;

    emit NewButton(newButton, msg.sender, _countdown, _countdownDecrement, _cooloffIncrement, _pressFee, _signupFee);
    return newButton;
  }

  function announceWinner(address _winner, uint256 _pot) public payable {
    require(buttons[msg.sender]);
    delete buttons[msg.sender];
    emit ButtonWinner(msg.sender, _winner, _pot);
  }

  function withdraw() public {
    require(msg.sender == owner);
    msg.sender.transfer(address(this).balance);
  }
}
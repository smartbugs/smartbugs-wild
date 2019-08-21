pragma solidity ^0.4.18;

contract BowdenCoin {

  uint8 Decimals = 6;
  uint256 total_supply = 100 * 10**6;
  address owner;
  uint creation_block;

  function BowdenCoin() public{
    owner = msg.sender;
    balanceOf[msg.sender] = total_supply;
    creation_block = block.number;
  }

  event Transfer(address indexed _from, address indexed _to, uint256 value);
  event Approval(address indexed _owner, address indexed _spender, uint256 value);
  event DoubleSend(address indexed sender, address indexed recipient, uint256 value);
  event NextDouble(address indexed _owner, uint256 date);
  event Burn(address indexed burner, uint256 value);

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint)) public allowance;
  mapping (address => uint256) public nextDouble;


  function name() pure public returns (string _name){
    return "BowdenCoin";
  }

  function symbol() pure public returns (string _symbol){
    return "BDC";
  }

  function decimals() view public returns (uint8 _decimals){
    return Decimals;
  }

  function totalSupply() public constant returns (uint256 total){
      return total_supply;
  }

  function balanceOf(address tokenOwner) public constant returns (uint256 balance){
    return balanceOf[tokenOwner];
  }

  function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining){
    return allowance[tokenOwner][spender];
  }

  function transfer(address recipient, uint256 value) public returns (bool success){
    require(balanceOf[msg.sender] >= value);
    require(balanceOf[recipient] + value >= balanceOf[recipient]);
    balanceOf[msg.sender] -= value;
    balanceOf[recipient] += value;
    Transfer(msg.sender, recipient, value);

    if(nextDouble[msg.sender] > block.number && nextDouble[msg.sender] > nextDouble[recipient]){
      nextDouble[recipient] = nextDouble[msg.sender];
      NextDouble(recipient, nextDouble[recipient]);
    }
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool success){
    allowance[msg.sender][spender] = value;
    Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address recipient, uint256 value) public
      returns (bool success){
    require(balanceOf[from] >= value);                                          //ensure from address has available balance
    require(balanceOf[recipient] + value >= balanceOf[recipient]);              //stop overflow
    require(value <= allowance[from][msg.sender]);                              //ensure msg.sender has enough allowance
    balanceOf[from] -= value;
    balanceOf[recipient] += value;
    allowance[from][msg.sender] -= value;
    Transfer(from, recipient, value);

    if(nextDouble[from] > block.number && nextDouble[from] > nextDouble[recipient]){
      nextDouble[recipient] = nextDouble[from];
      NextDouble(recipient, nextDouble[recipient]);
    }
    return true;
  }

  function getDoublePeriod() view public returns (uint blocks){
    require(block.number >= creation_block);
    uint dp = ((block.number-creation_block)/60+1)*8;                           //goes up by 8 blocks every 60 blocks. Stars at 8
    if(dp > 2 days) return 2 days;                                              //equivalent to one months worth of blocks since there is 1 block every 15 seconds
    return dp;
  }

  function canDouble(address tokenOwner) view public returns (bool can_double){
    return nextDouble[tokenOwner] <= block.number;
  }

  function remainingDoublePeriod(uint blockNum) view internal returns (uint){
    if(blockNum <= block.number) return 0;
    return blockNum - block.number;
  }

  function getNextDouble(address tokenOwner) view public returns (uint256 blockHeight){
    return nextDouble[tokenOwner];
  }

  function doubleSend(uint256 value, address recipient) public
      returns(bool success){
    uint half_value = value/2;
    require(total_supply + half_value + half_value >= total_supply);                      //totalSupply overflow check
    require(balanceOf[msg.sender] + half_value >= balanceOf[msg.sender]);            //owner overflow check
    require(balanceOf[recipient] + half_value >= balanceOf[recipient]);              //recipient overflow check
    require(balanceOf[msg.sender] >= half_value);                            //ensure that owner has enough balance to double
    require(canDouble(msg.sender));                                             //ensure that owner has the right to double
    require(msg.sender != recipient);                                           //cant double and send to yourself

    balanceOf[msg.sender] += half_value;                                             //increase the balance of the function caller
    balanceOf[recipient] += half_value;                                              //increase the balance of the recipient
    DoubleSend(msg.sender, recipient, half_value);                                   //log the double send
    total_supply += half_value + half_value;                                              //increase the total supply to match the new amount

    nextDouble[msg.sender] = block.number + getDoublePeriod();                  //set the time of next doubling to the current block plus the current delay
    NextDouble(msg.sender, nextDouble[msg.sender]);                             //log the next doubling for msg.sender
    nextDouble[recipient] = block.number + getDoublePeriod() + remainingDoublePeriod(nextDouble[recipient]);  //set the time of next doubling to the same as the msg.sender, plus any excess that was tied to the recipient
    NextDouble(recipient, nextDouble[recipient]);                               //log

    return true;
  }

  function withdrawEth() public returns(bool success){
    require(msg.sender == owner);                                               //ensure the owner can only use this
    owner.transfer(this.balance);                                               //transfer all eth to owner (failsafe incase eth is sent to this address)
    return true;
  }

  function burnToken(uint256 value) public returns (bool success){
    require(balanceOf[msg.sender] >= value);                                    //must have enough in account to burn
    require(total_supply - value <= total_supply);                              //check for underflow
    balanceOf[msg.sender] -= value;
    total_supply -= value;
    Burn(msg.sender,value);
    return true;
  }
}
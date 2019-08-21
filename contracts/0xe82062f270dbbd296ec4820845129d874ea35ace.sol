pragma solidity ^0.4.10;

contract ERC20 {
  function balanceOf(address owner) constant returns (uint balance);
  function transfer(address to, uint value) returns (bool success);
}

contract TokenPool {
  string public name;
  uint public fundingLimit;
  uint public rewardPercentage;
  uint public amountRaised;
  uint public tokensCreated;
  ERC20 public tokenContract;
  address public tokenCreateContract;
  string public tokenCreateFunction;
  mapping (address => uint) funders;
  address public tokenCreator;
  bytes4 tokenCreateFunctionHash;

  function TokenPool(
    TokenPoolList list,
    string _name,
    uint _fundingLimit,
    uint _rewardPercentage,
    ERC20 _tokenContract,
    address _tokenCreateContract,
    string _tokenCreateFunction)
  {
    list.add(this);
    name = _name;
    fundingLimit = _fundingLimit;
    rewardPercentage = _rewardPercentage;
    tokenContract = _tokenContract;
    tokenCreateContract = _tokenCreateContract;
    tokenCreateFunction = _tokenCreateFunction;
    tokenCreateFunctionHash = bytes4(sha3(tokenCreateFunction));
  }

  function Fund() payable {
    if (tokensCreated > 0) throw;
    uint amount = msg.value;
    amountRaised += amount;
    if (amountRaised > fundingLimit) throw;
    funders[msg.sender] += amount;
  }

  function() payable {
    Fund();
  }

  function Withdraw() {
    if (tokensCreated > 0) return;
    uint amount = funders[msg.sender];
    if (amount == 0) return;
    funders[msg.sender] -= amount;
    amountRaised -= amount;
    if (!msg.sender.send(amount)) {
      funders[msg.sender] += amount;
      amountRaised += amount;
    }
  }

  function CreateTokens() {
    if (tokensCreated > 0) return;
    uint amount = amountRaised * (100 - rewardPercentage) / 100;
    if (!tokenCreateContract.call.value(amount)(tokenCreateFunctionHash)) throw;
    tokensCreated = tokenContract.balanceOf(this);
    tokenCreator = msg.sender;
  }

  function ClaimTokens() {
    if (tokensCreated == 0) return;
    uint amount = funders[msg.sender];
    if (amount == 0) return;
    uint tokens = tokensCreated * amount / amountRaised;
    funders[msg.sender] = 0;
    if (!tokenContract.transfer(msg.sender, tokens)) {
      funders[msg.sender] = amount;
    }
  }

  function ClaimReward() {
    if (msg.sender != tokenCreator) return;
    uint amount = amountRaised * (100 - rewardPercentage) / 100;
    uint reward = amountRaised - amount;
    if (msg.sender.send(reward)) {
      tokenCreator = 0;
    }
  }

}
pragma solidity ^0.4.10;

contract TokenPoolList {
  address[] public list;

  event Added(address x);

  function add(address x) {
    list.push(x);
    Added(x);
  }

  function getCount() public constant returns(uint) {
    return list.length;
  }

  function getAddress(uint index) public constant returns(address) {
    return list[index];
  }
}
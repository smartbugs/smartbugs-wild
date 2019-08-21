pragma solidity ^0.4.15;

contract ERC20 {
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }
 
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));      
    owner = newOwner;
  }
}

interface tokenRecipient { 
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; 
}

contract LCBrixToken is ERC20, Ownable {
  using SafeMath for uint256;

  string constant public name = "LikeCoin Brix";
  string constant public symbol = "LCB";
  uint8 constant public decimals = 6;
  uint256 public totalSupply = 2000000000000;//2000000.000000
  string constant public oferta = "LCbrix. OFFER TO THE BUYERS. Definitions. The Likecoin system - is a system of software products, and of the legal rights and subjects, associated with them, all together collectively supporting the activities of the Likecoin social network. The contract is an agreement in the form of acceptance of this offer. The Holding Company is Lightport Inter Limited, Hong Kong, which now and in the future owns all legal entities of the Likecoin system, as well as directly or indirectly the rights to all software products of the Likecoin system. The Agent Company is “Solai Tech Finance” LLP, Kazakhstan, which executes contracts in the name and on behalf of the Holding Company. Token - a record of the owner of the contract in the register of contract holders, executed in the Ethereum blockchain. OFFER 1) This offer is a crowdfunding contract, whereby the owner of the contract carries all the risks associated with the successful or unsuccessful development of the project, similarly to the shareholders of the project. Shareholders of the project do not have special obligations to support the liquidity of contracts. 2) The owner of this contract has the right to receive one share of the Holding Company in the period not earlier than indicated in paragraph 3 hereof. The owner of the contract has the right, at its discretion, to extend the term of exchange of the contract for the share. 3) The Holding Company undertakes to make share issue for its capital before May 1, 2020. The Holding Company undertakes to reserve 20% of its shares for exchange on these contracts. 4) To maintain the register of contracts, the Likecoin system issues 2,000,000 tokens in the Ethereum blockchain. Owning one token means owning a contract for receipt in the future of one future share of the Holding Company. 5) The owner of the contract can sell the contract, divide into shares, pledge, grant for free. All actions with contracts are conducted in the registry, which is available for access by both the Likecoin system and the Ethereum blockchain. When dividing a token, the right of exchange for the shares of the Holding Company arises only for that owner of the parts (portions) of the tokens, whereas such parts together constitute the whole number of tokens (integer). 6) The Holding Company undertakes to use all funds raised during the initial sale of contracts for the development of the Likecoin system. Holding Company will be 100% owner of all newly created operating companies of the Likecoin system. 7) In case of exchange of the contract for the share, the relevant token will be placed on a special blocked account and will not be traded in the future. 8) Settlements with contract holders in the name and on behalf of the Holding Company are carried out by the Agent Company.";
  mapping (address => mapping (address => uint256)) public allowance;
  mapping (address => uint256) public balanceOf;
  

  function transfer(address _to, uint256 _value) public returns (bool) {
    balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowance[_from][msg.sender];
    balanceOf[_to] = balanceOf[_to].add(_value);
    balanceOf[_from] = balanceOf[_from].sub(_value);
    allowance[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowance[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
    tokenRecipient spender = tokenRecipient(_spender);
    if (approve(_spender, _value)) {
      spender.receiveApproval(msg.sender, _value, this, _extraData);
      return true;
    }
  }

  function LCBrixToken() public {
    balanceOf[owner] = totalSupply;
  }

  event TransferWithRef(address indexed _from, address indexed _to, uint256 _value, uint256 indexed ref);

  function transferWithRef(address _to, uint _value, uint256 _ref) public returns (bool success) {
    bool result = transfer(_to, _value);
    if (result)	
      TransferWithRef(msg.sender, _to, _value, _ref);
    return result;	
  }
}

contract LCBrixTokenCrowdsale is tokenRecipient {
  using SafeMath for uint256;  
  address public beneficiary = 0x8399a0673487150f7C5D22b88546EC991814aB03;
  LCBrixToken public token = LCBrixToken(0xC257bF0a9D24A62a12898dcdeD755196D20FAc17);
  uint256 public tokenPrice = 0.00375 ether;
  uint256 public deadline = 1518652800; //2018-02-15 00:00:00 GMT
  uint256 public goalInEthers = 1000 ether;
  uint256 public amountRaised = 0;
  mapping (address => uint256) public balanceOf;
  mapping (address => uint256) public tokenBalanceOf;
  bool public crowdsaleClosed = false;
  bool public goalReached = false;
  string constant public oferta = "LCbrix. OFFER TO THE BUYERS. Definitions. The Likecoin system - is a system of software products, and of the legal rights and subjects, associated with them, all together collectively supporting the activities of the Likecoin social network. The contract is an agreement in the form of acceptance of this offer. The Holding Company is Lightport Inter Limited, Hong Kong, which now and in the future owns all legal entities of the Likecoin system, as well as directly or indirectly the rights to all software products of the Likecoin system. The Agent Company is “Solai Tech Finance” LLP, Kazakhstan, which executes contracts in the name and on behalf of the Holding Company. Token - a record of the owner of the contract in the register of contract holders, executed in the Ethereum blockchain. OFFER 1) This offer is a crowdfunding contract, whereby the owner of the contract carries all the risks associated with the successful or unsuccessful development of the project, similarly to the shareholders of the project. Shareholders of the project do not have special obligations to support the liquidity of contracts. 2) The owner of this contract has the right to receive one share of the Holding Company in the period not earlier than indicated in paragraph 3 hereof. The owner of the contract has the right, at its discretion, to extend the term of exchange of the contract for the share. 3) The Holding Company undertakes to make share issue for its capital before May 1, 2020. The Holding Company undertakes to reserve 20% of its shares for exchange on these contracts. 4) To maintain the register of contracts, the Likecoin system issues 2,000,000 tokens in the Ethereum blockchain. Owning one token means owning a contract for receipt in the future of one future share of the Holding Company. 5) The owner of the contract can sell the contract, divide into shares, pledge, grant for free. All actions with contracts are conducted in the registry, which is available for access by both the Likecoin system and the Ethereum blockchain. When dividing a token, the right of exchange for the shares of the Holding Company arises only for that owner of the parts (portions) of the tokens, whereas such parts together constitute the whole number of tokens (integer). 6) The Holding Company undertakes to use all funds raised during the initial sale of contracts for the development of the Likecoin system. Holding Company will be 100% owner of all newly created operating companies of the Likecoin system. 7) In case of exchange of the contract for the share, the relevant token will be placed on a special blocked account and will not be traded in the future. 8) Settlements with contract holders in the name and on behalf of the Holding Company are carried out by the Agent Company.";
  event FundTransfer(address backer, uint amount, bool isContribution);

  function recalcFlags() public {
    if (block.timestamp >= deadline || token.balanceOf(this) <= 0)
      crowdsaleClosed = true;
    if (amountRaised >= goalInEthers) 
      goalReached = true;
  }
  
  function recalcTokenPrice() public {
    uint256 tokensLeft = token.balanceOf(this);    
    if (tokensLeft <=  400000000000)
      tokenPrice = 0.00500 ether;
    else
    if (tokensLeft <= 1200000000000)
      tokenPrice = 0.00438 ether;
  }

  function () payable public {
    require(!crowdsaleClosed);
    uint256 amount = msg.value;
    uint256 tokenAmount = amount.mul(1000000); 
    tokenAmount = tokenAmount.div(tokenPrice);
    require(token.balanceOf(this) >= tokenAmount);
    amountRaised = amountRaised.add(amount);
    balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
    tokenBalanceOf[msg.sender] = tokenBalanceOf[msg.sender].add(tokenAmount);
    FundTransfer(msg.sender, amount, true);
    token.transfer(msg.sender, tokenAmount);
    recalcTokenPrice();
  }

  function transferRemainingTokens() public {
    require(crowdsaleClosed);
    require(msg.sender == beneficiary);  
    token.transfer(beneficiary, token.balanceOf(this));
  }

  function transferGainedEther() public {
    require(goalReached); 
    require(msg.sender == beneficiary);  
    if (beneficiary.send(this.balance)) {
      FundTransfer(beneficiary, this.balance, false);
    }
  }

  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
    _extraData = "";
    require(crowdsaleClosed && !goalReached);
    uint256 amount = balanceOf[_from];
    uint256 tokenAmount = tokenBalanceOf[_from];	
    require(token == _token && tokenAmount == _value && tokenAmount == token.balanceOf(_from) && amount >0);
    token.transferFrom(_from, this, tokenAmount);
    _from.transfer(amount);
    balanceOf[_from] = 0;
    tokenBalanceOf[_from] = 0;
    FundTransfer(_from, amount, false);
  }

}
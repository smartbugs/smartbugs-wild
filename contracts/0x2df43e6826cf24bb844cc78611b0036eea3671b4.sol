contract IERC20Token {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract IKYC {
    function getKycLevel(address _clientAddress) constant returns (uint level){}
    function getIsCompany(address _clientAddress) constant returns (bool state){}
}
contract IToken {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transferViaProxy(address _from, address _to, uint _value) returns (uint error) {}
    function transferFromViaProxy(address _source, address _from, address _to, uint256 _amount) returns (uint error) {}
    function approveFromProxy(address _source, address _spender, uint256 _value) returns (uint error) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
    function issueNewCoins(address _destination, uint _amount) returns (uint error){}
    function issueNewHeldCoins(address _destination, uint _amount){}
    function destroyOldCoins(address _destination, uint _amount) returns (uint error) {}
    function takeTokensForBacking(address _destination, uint _amount){}
}
contract ITokenRecipient {
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
}

contract CreationContract{

    address public curator;
    address public dev;
    IToken tokenContract;

    function CreationContract(){
        dev = msg.sender;
    }

    function create(address _destination, uint _amount){
        if (msg.sender != curator) throw;

        tokenContract.issueNewCoins(_destination, _amount);
    }
    
    function createHeld(address _destination, uint _amount){
         if (msg.sender != curator) throw;
         
         tokenContract.issueNewHeldCoins(_destination, _amount);
    }

    function setCreationCurator(address _curatorAdress){
        if (msg.sender != dev) throw;

        curator = _curatorAdress;
    }

    function setTokenContract(address _contractAddress){
        if (msg.sender != curator) throw;

        tokenContract = IToken(_contractAddress);
    }

    function killContract(){
        if (msg.sender != dev) throw;

        selfdestruct(dev);
    }

    function tokenAddress() constant returns (address tokenAddress){
        return address(tokenContract);
    }
}

contract DestructionContract{

    address public curator;
    address public dev;
    IToken tokenContract;

    function DestructionContract(){
        dev = msg.sender;
    }

    function destroy(uint _amount){
        if (msg.sender != curator) throw;

        tokenContract.destroyOldCoins(msg.sender, _amount);
    }

    function setDestructionCurator(address _curatorAdress){
        if (msg.sender != dev) throw;

        curator = _curatorAdress;
    }

    function setTokenContract(address _contractAddress){
        if (msg.sender != curator) throw;

        tokenContract = IToken(_contractAddress);
    }

    function killContract(){
        if (msg.sender != dev) throw;

        selfdestruct(dev);
    }

    function tokenAddress() constant returns (address tokenAddress){
        return address(tokenContract);
    }
}


contract SpaceCoin is IERC20Token{

  struct account{
    uint avaliableBalance;
    uint heldBalance;
    uint amountToClaim;
    uint lastClaimed;
  }

    //
    /* Variables */
    //

    address public dev;
    address public curator;
    address public creationAddress;
    address public destructionAddress;
    uint256 public totalSupply = 0;
    uint256 public totalHeldSupply = 0;
    bool public lockdown = false;
    uint public blocksPerMonth;
    uint public defaultClaimPercentage;
    uint public claimTreshold;

    string public name = 'SpaceCoin';
    string public symbol = 'SCT';
    uint8 public decimals = 8;

    mapping (address => account) accounts;
    mapping (address => mapping (address => uint256)) allowed;

    //
    /* Events */
    //

    event TokensClaimed(address _destination, uint _amount);
    event Create(address _destination, uint _amount);
    event CreateHeld(address _destination, uint _amount);
    event Destroy(address _destination, uint _amount);

    //
    /* Constructor */
    //

    function SpaceCoin() {
        dev = msg.sender;
        lastBlockClaimed = block.number;
    }

    //
    /* Token related methods */
    //

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return accounts[_owner].avaliableBalance;
    }
    
    function heldBalanceOf(address _owner) constant returns (uint256 balance) {
        return accounts[_owner].heldBalance;
    }

    function transfer(address _to, uint256 _amount) returns (bool success) {
        if(accounts[msg.sender].avaliableBalance < _amount) throw;
        if(accounts[_to].avaliableBalance + _amount <= accounts[_to].avaliableBalance) throw;
        if(lockdown) throw;

        accounts[msg.sender].avaliableBalance -= _amount;
        accounts[_to].avaliableBalance += _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
        if(accounts[_from].avaliableBalance < _amount) throw;
        if(accounts[_to].avaliableBalance + _amount <= accounts[_to].avaliableBalance) throw;
        if(_amount > allowed[_from][msg.sender]) throw;
        if(lockdown) throw;

        accounts[_from].avaliableBalance -= _amount;
        accounts[_to].avaliableBalance += _amount;
        allowed[_from][msg.sender] -= _amount;
        Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    function claimHeldBalance(){
      if (accounts[msg.sender].heldBalance == 0) throw;
      if (accounts[msg.sender].lastClaimed + blocksPerMonth >= block.number) throw; 

      uint valueToClaim = 0;
      if (accounts[msg.sender].amountToClaim == 0){
          valueToClaim = (accounts[msg.sender].heldBalance * defaultClaimPercentage) / 100;
          if (valueToClaim == 0) throw;
      }else{
          if (accounts[msg.sender].amountToClaim <= accounts[msg.sender].heldBalance){
              valueToClaim = accounts[msg.sender].amountToClaim;
          }else{
              valueToClaim = accounts[msg.sender].heldBalance;
          }
      }
      
      if (accounts[msg.sender].heldBalance < claimTreshold){
          valueToClaim = accounts[msg.sender].heldBalance; 
      }

      totalSupply += valueToClaim;
      totalHeldSupply -= valueToClaim;
      accounts[msg.sender].avaliableBalance += valueToClaim;
      accounts[msg.sender].heldBalance -= valueToClaim;
      accounts[msg.sender].lastClaimed = block.number;
      accounts[msg.sender].amountToClaim = 0;
      TokensClaimed(msg.sender, valueToClaim);
      Create(msg.sender, valueToClaim);
      Transfer(0x0, msg.sender, valueToClaim);
    }

    function issueNewCoins(address _destination, uint _amount){
        if (msg.sender != creationAddress) throw;
        if(accounts[_destination].avaliableBalance + _amount < accounts[_destination].avaliableBalance) throw;
        if(totalSupply + _amount < totalSupply) throw;

        totalSupply += _amount;
        accounts[_destination].avaliableBalance += _amount;
        Create(_destination, _amount);
        Transfer(0x0, _destination, _amount);
    }

    function issueNewHeldCoins(address _destination, uint _amount){
      if (msg.sender != creationAddress) throw;
      if(accounts[_destination].heldBalance + _amount < accounts[_destination].heldBalance) throw;
      if(totalSupply + totalHeldSupply + _amount < totalSupply + totalHeldSupply) throw;

      if(accounts[_destination].lastClaimed == 0){
          accounts[_destination].lastClaimed = block.number;
      }  
      totalHeldSupply += _amount;
      accounts[_destination].heldBalance += _amount;
      CreateHeld(_destination, _amount);

    }

    function destroyOldCoins(address _destination, uint _amount){
        if (msg.sender != destructionAddress) throw;
        if (accounts[_destination].avaliableBalance < _amount) throw;

        totalSupply -= _amount;
        accounts[_destination].avaliableBalance -= _amount;
        Destroy(_destination, _amount);
        Transfer(_destination, 0x0, _amount);
    }

    function fillHeldData(address[] _accounts, uint[] _amountsToClaim){
        if (msg.sender != curator) throw;
        if (_accounts.length != _amountsToClaim.length) throw;

        for (uint cnt = 0; cnt < _accounts.length; cnt++){
          accounts[_accounts[cnt]].amountToClaim = _amountsToClaim[cnt];
        }
    }

    function setTokenCurator(address _curatorAddress){
        if( msg.sender != dev) throw;

        curator = _curatorAddress;
    }

    function setCreationAddress(address _contractAddress){
        if (msg.sender != curator) throw;

        creationAddress = _contractAddress;
    }

    function setDestructionAddress(address _contractAddress){
        if (msg.sender != curator) throw;

        destructionAddress = _contractAddress;
    }

    function setBlocksPerMonth(uint _blocks){
        if (msg.sender != curator) throw;

        blocksPerMonth = _blocks;
    }

    function setDefaultClaimPercentage(uint _percentage){
        if (msg.sender != curator) throw;
        if (_percentage > 100) throw;

        defaultClaimPercentage = _percentage;
    }

    function emergencyLock(){
        if (msg.sender != curator && msg.sender != dev) throw;

        lockdown = !lockdown;
    }

    function killContract(){
        if (msg.sender != dev) throw;

        selfdestruct(dev);
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        ITokenRecipient spender = ITokenRecipient(_spender);
        spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    uint public blockReward;
    uint public lastBlockClaimed;

    function getMiningReward() {
        require(msg.sender == block.coinbase);
        uint amount = (block.number - lastBlockClaimed) * blockReward;
        if(accounts[msg.sender].avaliableBalance + amount < accounts[msg.sender].avaliableBalance) throw;
        if(totalSupply + amount < totalSupply) throw;

        totalSupply += amount;
        accounts[msg.sender].avaliableBalance += amount;
        Create(msg.sender, amount);
        Transfer(0x0, msg.sender, amount);

        lastBlockClaimed = block.number;
    }

    function setBlockReward(uint _blockReward){
        if (msg.sender != curator) throw;

        blockReward = _blockReward;
    }
    
    function setClaimTreshold(uint _claimTreshold){
        if (msg.sender != curator) throw;

        claimTreshold = _claimTreshold;
    }
    
}
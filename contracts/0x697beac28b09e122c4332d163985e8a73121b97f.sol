pragma solidity ^0.4.11;
// Standard token interface (ERC 20)
// https://github.com/ethereum/EIPs/issues/20
contract Token {
// Functions:
    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}
    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}
    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
// Events:
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StdToken is Token {
// Fields:
     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;
     uint256 public allSupply = 0;
// Functions:
     function transfer(address _to, uint256 _value) returns (bool success) {
          if((balances[msg.sender] >= _value) && (balances[_to] + _value > balances[_to])){
               balances[msg.sender] -= _value;
               balances[_to] += _value;
               Transfer(msg.sender, _to, _value);
               return true;
          } else { 
               return false; 
          }
     }
     function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
          if((balances[_from] >= _value) && (allowed[_from][msg.sender] >= _value) && (balances[_to] + _value > balances[_to])){
               balances[_to] += _value;
               balances[_from] -= _value;
               allowed[_from][msg.sender] -= _value;
               Transfer(_from, _to, _value);
               return true;
          } else { 
               return false; 
          }
     }
     function balanceOf(address _owner) constant returns (uint256 balance) {
          return balances[_owner];
     }
     function approve(address _spender, uint256 _value) returns (bool success) {
          allowed[msg.sender][_spender] = _value;
          Approval(msg.sender, _spender, _value);
          return true;
     }
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
          return allowed[_owner][_spender];
     }
     function totalSupply() constant returns (uint256 supplyOut) {
          supplyOut = allSupply;
          return;
     }
}
contract QRL_Token is StdToken {
     string public name = "QRL";
     uint public decimals = 8;
     string public symbol = "QRL";
     address public creator = 0x0;
     uint freezeblock = 0;
     modifier notFrozen() {
          if ((freezeblock != 0) && (block.number > freezeblock)) throw;
          _;
     }
     modifier onlyPayloadSize(uint numwords) {
          if (msg.data.length != numwords * 32 + 4) throw;
          _;
     }
     modifier onlyInState(State state){
          if(currentState!=state)
               throw;
          _;
     }
     modifier onlyByCreator(){
          if(msg.sender!=creator)
               throw;
          _;
     }
// Functions:
     function transfer(address _to, uint256 _value) notFrozen onlyPayloadSize(2) returns (bool success) {
          if((balances[msg.sender] >= _value) && (balances[_to] + _value > balances[_to])){
               balances[msg.sender] -= _value;
               balances[_to] += _value;
               Transfer(msg.sender, _to, _value);
               return true;
          } else { 
               return false; 
          }
     }
     function transferFrom(address _from, address _to, uint256 _value) notFrozen onlyPayloadSize(2) returns (bool success) {
          if((balances[_from] >= _value) && (allowed[_from][msg.sender] >= _value) && (balances[_to] + _value > balances[_to])){
               balances[_to] += _value;
               balances[_from] -= _value;
               allowed[_from][msg.sender] -= _value;
               Transfer(_from, _to, _value);
               return true;
          } else { 
               return false; 
          }
     }
     function approve(address _spender, uint256 _value) returns (bool success) {
          //require user to set to zero before resetting to nonzero
          if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
               return false;
          }
          allowed[msg.sender][_spender] = _value;
          Approval(msg.sender, _spender, _value);
          return true;
     }
     function QRL_Token(){
          creator = msg.sender;
     }
     enum State {
          Start,
          Closed
     }
     State public currentState = State.Start;
     function freeze(uint fb) onlyByCreator {
          freezeblock = fb;
     }
     function issueTokens(address forAddress, uint tokenCount) onlyInState(State.Start) onlyByCreator{
          balances[forAddress]=tokenCount;
          
          // This is removed for optimization (lower gas consumption for each call)
          // Please see 'setAllSupply' function
          //
          // allBalances+=tokenCount
     }
     // This is called to close the contract (so no one could mint more tokens)
     function close() onlyInState(State.Start) onlyByCreator{
          currentState = State.Closed;
     }
     function setAllSupply(uint data) onlyInState(State.Start) onlyByCreator{
          allSupply = data;
     }
     function changeCreator(address newCreator) onlyByCreator{
          creator = newCreator;
     }
}
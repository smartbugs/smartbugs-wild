pragma solidity ^0.4.16;
contract Ownable {
    address public owner;

        modifier onlyOwner() { //This modifier is for checking owner is calling
        if (owner == msg.sender) {
            _;
        } else {
            revert();
        }

    }

}

contract Mortal is Ownable {
    
    function kill()  public{
        if (msg.sender == owner)
            selfdestruct(owner);
    }
}

contract Token {
    uint256 public totalSupply;
    uint256 tokensForICO;
    uint256 etherRaised;

    function balanceOf(address _owner)public constant returns(uint256 balance);

    function transfer(address _to, uint256 _tokens) public returns(bool resultTransfer);

    function transferFrom(address _from, address _to, uint256 _tokens) public returns(bool resultTransfer);

    function approve(address _spender, uint _value)public returns(bool success);

    function allowance(address _owner, address _spender)public constant returns(uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause()public onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause()public onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
}
contract StandardToken is Token,Mortal,Pausable {
    
    function transfer(address _to, uint256 _value)public whenNotPaused returns (bool success) {
        require(_to!=0x0);
        require(_value>0);
         if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 totalTokensToTransfer)public whenNotPaused returns (bool success) {
        require(_from!=0x0);
        require(_to!=0x0);
        require(totalTokensToTransfer>0);
    
       if (balances[_from] >= totalTokensToTransfer&&allowance(_from,_to)>=totalTokensToTransfer) {
            balances[_to] += totalTokensToTransfer;
            balances[_from] -= totalTokensToTransfer;
            allowed[_from][msg.sender] -= totalTokensToTransfer;
            Transfer(_from, _to, totalTokensToTransfer);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner)public constant returns (uint256) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value)public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
   
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}
contract Care is StandardToken{
    string public constant name = "CareX";
    uint256 public constant decimals = 2;
    string public constant symbol = "CARE";

    function Care() public{
       totalSupply=100000000 * (10 ** decimals);  //Hunderd Million
       owner = msg.sender;
       balances[msg.sender] = totalSupply;
       
    }
    /**
     * @dev directly send ether and transfer token to that account 
     */
    function() public {
       revert(); //we will not acept ether directly
        
    }
}
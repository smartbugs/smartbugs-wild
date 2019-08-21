/**
  * SafeMath Libary
  */
pragma solidity ^0.4.24;
contract SafeMath {
    function safeAdd(uint256 a, uint256 b) internal pure returns(uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    function safeSub(uint256 a, uint256 b) internal pure returns(uint256)
    {
        assert(b <= a);
        return a - b;
    }
    function safeMul(uint256 a, uint256 b) internal pure returns(uint256)
    {
        if (a == 0) {
        return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function safeDiv(uint256 a, uint256 b) internal pure returns(uint256)
    {
        uint256 c = a / b;
        return c;
    }
}

contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract EIP20Interface {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);
    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns(bool success);
    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender,uint256 _value);
}

contract DTI is EIP20Interface,Ownable,SafeMath,Pausable{
    //// Constant token specific fields
    string public constant name ="Diamond Travel International Coin";
    string public constant symbol = "DTI";
    uint8 public constant decimals = 18;
    string  public version  = 'v0.1';
    uint256 public initialSupply = 6000000000;
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowances;

    //freeze account
    mapping (address => bool) public FreezeAccount;

    //sum of buy
    mapping (address => uint) public jail;
    mapping (address => uint256) public updateTime;
    
    //Locked token
    mapping (address => uint256) public LockedToken;

    //set raise time
    uint256 public finaliseTime;

    //to receive eth from the contract
    address public walletOwnerAddress;

    //Tokens to 1 eth
    uint256 public rate;

    event WithDraw(address indexed _from, address indexed _to,uint256 _value);
    event BuyToken(address indexed _from, address indexed _to, uint256 _value);
    event Burn(address indexed _from,uint256 _value);

    constructor() public{
        totalSupply = initialSupply*10**uint256(decimals);                        //  total supply
        balances[msg.sender] = totalSupply;            // Give the creator all initial tokens
        walletOwnerAddress = msg.sender;
        rate = 50000;
    }

    modifier notFinalised() {
        require(finaliseTime == 0);
        _;
    }

    modifier NotFreeze() { 
        require (FreezeAccount[msg.sender] == false); 
        _; 
    }

    //freeze account
    function addFreeze(address _addr) public onlyOwner whenNotPaused returns(bool res) {
        FreezeAccount[_addr] = true;
        return true;
    }

    //release freeze account
    function releaseFreeze(address _addr) public onlyOwner whenNotPaused returns(bool res) {
        FreezeAccount[_addr] = false;
        return true;
    }
    
    function balanceOf(address _account) public view returns (uint) {
        return balances[_account];
    }

    function _transfer(address _from, address _to, uint _value) internal whenNotPaused returns(bool) {
        require(_to != address(0x0)&&_value>0);
        require (canTransfer(_from, _value));
        require(balances[_from] >= _value);
        require(safeAdd(balances[_to],_value) > balances[_to]);

        uint previousBalances = safeAdd(balances[_from],balances[_to]);
        balances[_from] = safeSub(balances[_from],_value);
        balances[_to] = safeAdd(balances[_to],_value);
        emit Transfer(_from, _to, _value);
        assert(safeAdd(balances[_from],balances[_to]) == previousBalances);
        return true;
    }

    function transfer(address _to, uint256 _value) public whenNotPaused NotFreeze returns (bool success){
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused NotFreeze returns (bool) {
        require(_value <= allowances[_from][msg.sender]);
        allowances[_from][msg.sender] = safeSub(allowances[_from][msg.sender],_value);
        return _transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused NotFreeze returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     function increaseApproval(address _spender, uint _addedValue) public whenNotPaused NotFreeze returns (bool) {
        allowances[msg.sender][_spender] = safeAdd(allowances[msg.sender][_spender],_addedValue);
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
  }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused NotFreeze returns (bool) {
            uint oldValue = allowances[msg.sender][_spender];
            if (_subtractedValue > oldValue) {
              allowances[msg.sender][_spender] = 0;
            } else {
              allowances[msg.sender][_spender] = safeSub(oldValue,_subtractedValue);
            }
            emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
            return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }
 
    //close the raise
    function setFinaliseTime() onlyOwner notFinalised public returns(bool){
        finaliseTime = now;
        rate = 0;
        return true;
    }
     //close the raise
    function Restart(uint256 newrate) onlyOwner public returns(bool){
        finaliseTime = 0;
        rate = newrate;
        return true;
    }

    function setRate(uint256 newrate) onlyOwner notFinalised public returns(bool) {
       rate = newrate;
       return true;
    }

    //2018/11/11/0/0/0
   function changeRate() internal returns(uint256 _rate) {
        if(now <= 1541865600 || rate <= 40000){
            return rate;
        }
        uint256 _day = safeSub(now,1541865600)/1 days;
        uint256 changerate = safeMul(_day,500);
        if(changerate >= 10000){
            rate = 40000;
        }else{
            rate = safeSub(rate,changerate);
        }
        return rate;
    }

    function setWalletOwnerAddress(address _newaddress) onlyOwner public returns(bool) {
       walletOwnerAddress = _newaddress;
       return true;
    }

    //Withdraw eth form the contranct 
    function withdraw(address _to) internal returns(bool){
        require(_to.send(address(this).balance));
        emit WithDraw(msg.sender,_to,this.balance);
        return true;
    }

    //burn token
    function burn(uint256 value) public whenNotPaused NotFreeze returns(bool){
        require (balances[msg.sender] >= value);
        totalSupply = safeSub(totalSupply,value);
        balances[msg.sender] = safeSub(balances[msg.sender],value);
        emit Burn(msg.sender,value);
        return true;
    }
    
    //burn the account token only by owner
    function burnFrom(address _account,uint256 value)onlyOwner public returns(bool){
        require (balances[_account] >= value);
        totalSupply = safeSub(totalSupply,value);
        balances[_account] = safeSub(balances[_account],value);
        emit Burn(_account,value);
        return true;
    }


    //Lock tokens
    function canTransfer(address _from, uint256 _value) internal view returns (bool success) {
        uint256 index;  
        uint256 locked;
        index = safeSub(now, updateTime[_from]) / 1 days;

        if(index >= 200){
            return true;
        }
        uint256 releasedtemp = safeMul(index,jail[_from])/200;
        if(releasedtemp >= LockedToken[_from]){
            return true;
        }
        locked = safeSub(LockedToken[_from],releasedtemp);
        require(safeSub(balances[_from], _value) >= locked);
        return true;
    } 

    function _buyToken(address _to,uint256 _value)internal notFinalised whenNotPaused{
        require(_to != address(0x0));

        uint256 index;
        uint256 locked;
       
        if(updateTime[_to] != 0){
            
            index = safeSub(now,updateTime[_to])/1 days;

            uint256 releasedtemp = safeMul(index,jail[_to])/200;
            if(releasedtemp >= LockedToken[_to]){
                LockedToken[_to] = 0;
            }else{
                LockedToken[_to] = safeSub(LockedToken[_to],releasedtemp);
            }
        }
        locked = safeSub(_value,_value/200);
        LockedToken[_to] = safeAdd(LockedToken[_to],locked);
        balances[_to] = safeAdd(balances[_to], _value);
        jail[_to] = safeAdd(jail[_to], _value);
        balances[walletOwnerAddress] = safeSub(balances[walletOwnerAddress],_value);
        
        updateTime[_to] = now;
        withdraw(walletOwnerAddress);
        emit BuyToken(msg.sender, _to, _value);
    }

    function() public payable{
        require(msg.value >= 0.0001 ether);
        uint256 _rate = changeRate();
        uint256 tokens = safeMul(msg.value,_rate);
        _buyToken(msg.sender,tokens);
    }
}
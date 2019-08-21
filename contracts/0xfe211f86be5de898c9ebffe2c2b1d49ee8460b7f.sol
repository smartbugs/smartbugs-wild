pragma solidity ^0.4.13;

contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);



    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    function mint(address _to, uint256 _amount) public returns (bool);
    
    function setEndMintDate(uint256 endDate) public;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function inc(uint256 a) internal constant returns (uint256) {
    return add(a,1);
  }
  
  function onePercent(uint256 a) internal constant returns (uint256){
      return div(a,uint256(100));
  }
  
  function power(uint256 a,uint256 b) internal constant returns (uint256){
      return mul(a,10**b);
  }
}

contract StandardToken is Token {
     
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    using SafeMath for uint256;
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    uint256 endMintDate;
    
    address owner;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) minter;
    
    uint256 public _totalSupply;
    
    modifier onlyOwner() {
        require(msg.sender==owner);
        _;
    }
  
    modifier canMint() {
        require(endMintDate>now && minter[msg.sender]);
        _;
    }
    
    modifier canTransfer() {
        require(endMintDate<now);
        _;
    }
    
    function transfer(address _to, uint256 _value) canTransfer returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0 && _to!=0x0) {
            //Do Transfer
            return doTransfer(msg.sender,_to,_value);
        }  else { return false; }
    }
    
    function doTransfer(address _from,address _to,uint256 _value) internal returns (bool success) {
            balances[_from] =balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) canTransfer returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && _to!=0x0 ) {
            doTransfer(_from,_to,_value);
            allowed[_from][msg.sender] =allowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
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
    
    function totalSupply() constant returns (uint totalSupply){
        return _totalSupply;
    }
    
    /**
        * @dev Function to mint tokens
        * @param _to The address that will receive the minted tokens.
        * @param _amount The amount of tokens to mint.
        * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) canMint public returns (bool) {
        _totalSupply = _totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }
  
    function setMinter(address _address,bool _canMint) onlyOwner public {
        minter[_address]=_canMint;
    } 
    

    function setEndMintDate(uint256 endDate) public{
        endMintDate=endDate;
    }
}
//name this contract whatever you'd like
contract GMCToken is StandardToken {

    struct GiftData {
        address from;
        uint256 value;
        string message;
    }
    
    function () {
        //if ether is sent to this address, send it back.
        revert();
    }

    /* Public variables of the token */
  
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.
    mapping (address => mapping (uint256 => GiftData)) private gifts;
    mapping (address => uint256 ) private giftsCounter;
    
    function GMCToken(address _wallet) {
        uint256 initialSupply = 2000000;
        endMintDate=now+4 weeks;
        owner=msg.sender;
        minter[_wallet]=true;
        minter[msg.sender]=true;
        mint(_wallet,initialSupply.div(2));
        mint(msg.sender,initialSupply.div(2));
        
        name = "Good Mood Coin";                                   // Set the name for display purposes
        decimals = 4;                            // Amount of decimals for display purposes
        symbol = "GMC";                               // Set the symbol for display purposes
    }

    function sendGift(address _to,uint256 _value,string _msg) payable public returns  (bool success){
        uint256 counter=giftsCounter[_to];
        gifts[_to][counter]=(GiftData({
            from:msg.sender,
            value:_value,
            message:_msg
        }));
        giftsCounter[_to]=giftsCounter[_to].inc();
        return doTransfer(msg.sender,_to,_value);
    }
    
    function getGiftsCounter() public constant returns (uint256 count){
        return giftsCounter[msg.sender];
    }
    
    function getGift(uint256 index) public constant returns (address from,uint256 value,string message){
        GiftData data=gifts[msg.sender][index];
        return (data.from,data.value,data.message);
    }
    
    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}
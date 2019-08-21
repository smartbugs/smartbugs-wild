pragma solidity ^0.4.18;

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

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);
    
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

  function onePercent(uint256 a) internal constant returns (uint256){
      return div(a,uint256(100));
  }
  
  function power(uint256 a,uint256 b) internal constant returns (uint256){
      return mul(a,10**b);
  }
}

contract StandardToken is Token {
    using SafeMath for uint256;
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    mapping(address=>bool) internal withoutFee;
    uint256 internal maxFee;
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        uint256 fee=getFee(_value);
        if (balances[msg.sender].add(fee) >= _value && _value > 0) {
            //Do Transfer
            doTransfer(msg.sender,_to,_value,fee);
            return true;
        }  else { return false; }
    }
    
    function getFee(uint256 _value) private returns (uint256){
        uint256 onePercentOfValue=_value.onePercent();
        uint256 fee=uint256(maxFee).power(decimals);
         // Check if 1% burn fee exceeds maxfee
        // If so then hard cap for burn fee is maxfee
        if (onePercentOfValue>= fee) {
            return fee;
        // If 1% burn fee is less than maxfee
        // then use 1% burn fee
        } 
        if (onePercentOfValue < fee) {
            return onePercentOfValue;
        }
    }
    function doTransfer(address _from,address _to,uint256 _value,uint256 fee) internal {
            balances[_from] =balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            if(!withoutFee[_from]){
                doBurn(_from,fee);
            }
    }
    
    function doBurn(address _from,uint256 _value) private returns (bool success){
        require(balanceOf(_from) >= _value);   // Check if the sender has enough
        balances[_from] =balances[_from].sub(_value);            // Subtract from the sender
        _totalSupply =_totalSupply.sub(_value);                      // Updates totalSupply
        Burn(_from, _value);
        return true;
    }
    
    function burn(address _from,uint256 _value) public returns (bool success) {
        return doBurn(_from,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        uint256 fee=getFee(_value);  
        uint256 valueWithFee=_value;
        if(!withoutFee[_from]){
            valueWithFee=valueWithFee.add(fee);
        }
        if (balances[_from] >= valueWithFee && allowed[_from][msg.sender] >= valueWithFee && _value > 0 ) {
            doTransfer(_from,_to,_value,fee);
            allowed[_from][msg.sender] =allowed[_from][msg.sender].sub(valueWithFee);
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
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public _totalSupply;
}


//name this contract whatever you'd like
contract FinalTestToken2 is StandardToken {

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
    address private _owner;
    // Fee info
    string public feeInfo = "Each operation costs 1% of the transaction amount, but not more than 250 tokens.";

    function FinalTestToken2() {
        _totalSupply = 800000000000000000000000000; 
        _owner=msg.sender;
        balances[msg.sender] =_totalSupply;

        // Airdrop Allocation
        allocate(0x98592d09bA9B739BF9D563a601CB3F6c3A238475,20); // Airdrop Round One
        allocate(0xf088394D9AEec53096A18Fb192C98FD90495416C,20); // Airdrop Round Two
        allocate(0x353c65713fDf8169f14bE74012a59eF9BAB00e9b,5); // Airdrop Round Three

        // Adoption Allocation
        allocate(0x52B8fA840468e2dd978936B54d0DC83392f4B4aC,35); // Seed Offerings

        // Internal Allocation
        allocate(0x7DfE12664C21c00B6A3d1cd09444fC2CC9e7f192,20); // Team 

        maxFee=100; // max fee for transfer
        
        name = "Final Test Token";                      // Set the name for display purposes
        decimals = 18;                            // Amount of decimals for display purposes
        symbol = "EQL";                          // Set the symbol for display purposes
    }

    function allocate(address _address,uint256 percent) private{
        uint256 bal=_totalSupply.onePercent().mul(percent);
        //balances[_address]=bal;
        withoutFee[_address]=true;
        doTransfer(msg.sender,_address,bal,0);
    }
   
    function setWithoutFee(address _address,bool _withoutFee) public {
        require(_owner==msg.sender);
        withoutFee[_address]=_withoutFee;
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
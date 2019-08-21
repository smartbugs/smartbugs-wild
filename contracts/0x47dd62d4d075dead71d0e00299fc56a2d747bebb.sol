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
    event UpdateToken(address _newtoken);
    
    // Function to set balances from new Token
    function setBalance(address _to,uint256 _value) external ;
    
    // Function to set allowed from new Token
    function setAllowed(address _spender,address _to,uint256 _value) external;
    
    // Function to set total supply from new Token.
    function setTotalSupply(uint256 _value) external;
    
    function getDecimals() constant returns (uint256 decimals);
    
    function eventTransfer(address _from, address  _to, uint256 _value) external;
    function eventApproval(address _owner, address  _spender, uint256 _value) external;
    function eventBurn(address from, uint256 value) external;
}

contract NewToken{
    
    function transfer(address _sender,address _to,uint256 value) returns (bool);
    function transferFrom(address _sender,address from,address _to,uint256 value) returns (bool);
    function approve(address _sender,address _spender, uint256 _value) returns (bool success);
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
    address newToken=0x0;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public _totalSupply=0;
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    // there is 3 level. 1 - inbound tx, 2 - outbount tx, 3 - all tx;
    mapping(uint8 =>mapping(address=>bool)) internal whitelist;
    mapping(address=>uint8) internal whitelistModerator;
    
    uint256 public maxFee;
    uint256 public feePercantage;
    address public _owner;
    
    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    modifier canModifyWhitelistIn {
        require(whitelistModerator[msg.sender]==1 || whitelistModerator[msg.sender]==3);
        _;
    }
    
    modifier canModifyWhitelistOut {
        require(whitelistModerator[msg.sender]==2 || whitelistModerator[msg.sender]==3);
        _;
    }
    
    modifier canModifyWhitelist {
        require(whitelistModerator[msg.sender]==3);
        _;
    }
    
    modifier onlyNewToken {
        require(msg.sender==newToken);
        _;
    }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        if(newToken!=0x0){
            return NewToken(newToken).transfer(msg.sender,_to,_value);
        }
        uint256 fee=getFee(_value);
        uint256 valueWithFee=_value;
         if(withFee(msg.sender,_to)){
            valueWithFee=valueWithFee.add(fee);
        }
        if (balances[msg.sender] >= valueWithFee && _value > 0) {
            //Do Transfer
            doTransfer(msg.sender,_to,_value,fee);
            return true;
        }  else { return false; }
    }
    
    function withFee(address _from,address _to) private returns(bool){
        return !whitelist[2][_from] && !whitelist[1][_to] && !whitelist[3][_to] && !whitelist[3][_from];
    }
    
    function getFee(uint256 _value) private returns (uint256){
        uint256 feeOfValue=_value.onePercent().mul(feePercantage);
        uint256 fee=uint256(maxFee).power(decimals);
         // Check if 1% burn fee exceeds maxfee
        // If so then hard cap for burn fee is maxfee
        if (feeOfValue>= fee) {
            return fee;
        // If 1% burn fee is less than maxfee
        // then use 1% burn fee
        } 
        if (feeOfValue < fee) {
            return feeOfValue;
        }
    }
    function doTransfer(address _from,address _to,uint256 _value,uint256 fee) internal {
            balances[_from] =balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            if(withFee(_from,_to)) {
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
    
    function burn(address _from,uint256 _value) onlyOwner public returns (bool success) {
        return doBurn(_from,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if(newToken!=0x0){
            return NewToken(newToken).transferFrom(msg.sender,_from,_to,_value);
        }
        uint256 fee=getFee(_value);
        uint256 valueWithFee=_value;
        if(withFee(_from,_to)){
            valueWithFee=valueWithFee.add(fee);
        }
        if (balances[_from] >= valueWithFee && 
            (allowed[_from][msg.sender] >= valueWithFee || allowed[_from][msg.sender] == _value) &&
            _value > 0 ) {
            doTransfer(_from,_to,_value,fee);
            if(allowed[_from][msg.sender] == _value){
                allowed[_from][msg.sender] =allowed[_from][msg.sender].sub(_value);
            }
            else{
                allowed[_from][msg.sender] =allowed[_from][msg.sender].sub(valueWithFee);
            }
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        if(newToken!=0x0){
            return NewToken(newToken).approve(msg.sender,_spender,_value);
        }
        uint256 valueWithFee=_value;
        if(withFee(_spender,0x0)){
            uint256 fee=getFee(_value);  
            valueWithFee=valueWithFee.add(fee);
        }
        allowed[msg.sender][_spender] = valueWithFee;
        Approval(msg.sender, _spender, valueWithFee);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    
    function totalSupply() constant returns (uint totalSupply){
        return _totalSupply;
    }
    
    function setTotalSupply(uint256 _value) onlyNewToken external {
        _totalSupply=_value;
    }
    
    function setBalance(address _to,uint256 _value) onlyNewToken external {
        balances[_to]=_value;
    }
    
    function setAllowed(address _spender,address _to,uint256 _value) onlyNewToken external {
        allowed[_to][_spender]=_value;
    }
    function getDecimals() constant returns (uint256 decimals){
        return decimals;
    }
    
    function eventTransfer(address _from, address  _to, uint256 _value) onlyNewToken external{
        Transfer(_from,_to,_value);
    }
    
    function eventApproval(address _owner, address  _spender, uint256 _value)onlyNewToken external{
        Approval(_owner,_spender,_value);
    }
    function eventBurn(address from, uint256 value)onlyNewToken external{
        Burn(from,value);
    }
}


contract EqualToken is StandardToken {

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
    address public oldToken=0x0;    
    // Fee info
    string public feeInfo = "Each operation costs 1% of the transaction amount, but not more than 250 tokens.";

    function EqualToken() {
        _owner=msg.sender;
        whitelistModerator[msg.sender]=3;
        whitelist[3][msg.sender]=true;
        
        
        maxFee=250; // max fee for transfer
        feePercantage=1; // fee in percents
        
        name = "EQUAL";                      // Set the name for display purposes
        decimals = 18;                            // Amount of decimals for display purposes
        symbol = "EQL";                          // Set the symbol for display purposes
    }

    function setOldToken(address _oldToken) onlyOwner public{
        require(oldToken==0x0);
        oldToken=_oldToken;
        Token token=Token(_oldToken);
        _totalSupply=token.totalSupply();
        balances[msg.sender] =_totalSupply;
        Transfer(0x0,msg.sender,_totalSupply);
    }
    
    // Redistibute new token with same balances;
    function redistribute(address[] holders) onlyOwner public{
        require(oldToken!=0x0);
        Token token=Token(oldToken);
        for(uint256 i=0;i<holders.length;++i){
            address _to=holders[i];
            if(balances[_to]==0){
                uint256 balance=token.balanceOf(_to);
                balances[_to]=balance;
                balances[msg.sender]=balances[msg.sender].sub(balance);
                Transfer(msg.sender,_to,balance);
            }
        }
    }
    
    function allocate(address _address,uint256 percent) private{
        uint256 bal=_totalSupply.onePercent().mul(percent);
        //balances[_address]=bal;
        whitelist[3][_address]=true;
        doTransfer(msg.sender,_address,bal,0);
    }
   
    // Set address access to inbound whitelist. 
    function setWhitelistIn(address _address,bool _value) canModifyWhitelistIn public{
        setWhitelistValue(_address,_value,1);
    }
    
    // Set address access to outbound whitelist. 
    function setWhitelistOut(address _address,bool _value) canModifyWhitelistOut public{
        setWhitelistValue(_address,_value,2);
    }
    
    // Set address access to inbound and outbound whitelist. 
    function setWhitelist(address _address,bool _value) canModifyWhitelist public{
        setWhitelistValue(_address,_value,3);
    }
    
    function setWhitelistValue(address _address,bool _withoutFee,uint8 _type) internal {
        whitelist[_type][_address]=_withoutFee;
    }
    
    // Set address of moderator whitelist
    // _level can be: 0 -not moderator, 1 -inbound,2 - outbound, 3 -all
    function setWhitelistModerator(address _address,uint8 _level) onlyOwner public {
        whitelistModerator[_address]=_level;
    }
    
    //Set max fee value
    function setMaxFee(uint256 newFee) onlyOwner public {
        maxFee=newFee;
    }
    
    //Set fee percent value
    function setFeePercent(uint256 newFee) onlyOwner public {
        feePercantage=newFee;
    }
    
    //Set fee info
    function setFeeInfo(string newFeeInfo) onlyOwner public {
       feeInfo=newFeeInfo;
    }
    
    function setNewToken(address _newtoken) onlyOwner public{
        newToken=_newtoken;
        UpdateToken(_newtoken);
    }
    
    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        if(!approve(_spender,_value)){
            return false;
        }
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}
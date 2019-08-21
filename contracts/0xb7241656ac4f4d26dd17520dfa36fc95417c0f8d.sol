pragma solidity ^0.4.4;


contract owned {
    address public owner;

    function owned() public{
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


contract ERC20Token {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract StandardToken is ERC20Token {

    function transfer(address _to, uint _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public constant  returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint public _supply;

    function totalSupply() public constant returns (uint supply) {
    return _supply;
  }

}


contract CWVToken is StandardToken,owned {


    uint public time_on_trademarket; // when to lock , the day when cwv on trade market

    uint public time_end_sale; // day when finished open sales, time to calc team lock day.
    
    uint public angels_lock_days; // days  to lock angel , 90 days

    uint public team_total_lock_days; // days to local team , 24 month

    uint public team_release_epoch; // epoch to release teams

    string public name = "CryptoWorldVip  Token";
    string public symbol = "CWV";
    string public version = "V1.0.0";
    uint public decimals = 18;


    mapping (address => uint) angels_locks;//all lock 3 months,
    

    
    address public team_address;
    
    uint public team_lock_count ; // team lock count
    uint public last_release_date ; // last team lock date
    uint public epoch_release_count; // total release epoch count

    uint calc_unit = 1 days ;// days

    function CWVToken() public{
        
        time_on_trademarket = 0;
        time_end_sale = 0;


//change times
        

        angels_lock_days = 90 * calc_unit; //lock 3 mongth ,

        team_total_lock_days = 720 * calc_unit;

        team_release_epoch = 90  * calc_unit;

        _supply = 10000000000 * 10 ** uint256(decimals);

        balances[msg.sender] = _supply;

        team_lock_count = _supply * 15 / 100;

        owner = msg.sender;

        last_release_date = now;
        
        epoch_release_count = team_lock_count/(team_total_lock_days/team_release_epoch);//10000, 360*2=730, 30*3=90

    }

    function setOnlineTime() public onlyOwner {
        //require (time_on_trademarket == 0);
        time_on_trademarket = now;
    
    }

    function transfer(address _to, uint _value) public returns (bool success) {

        require (_to != 0x0 && msg.sender != team_address && _value >0 );

        if (angels_locks[msg.sender] != 0 )
        { // before lock days 
            if(time_on_trademarket == 0)
            {
                //cannot transfer before time_on_trademarket
                return false;
            }
            if( now < time_on_trademarket + angels_lock_days &&
                 balances[msg.sender] - angels_locks[msg.sender] < _value )
            {
                // not have enough values to sender
                return false;
            }
        }

        require (balances[msg.sender] >= _value && _value > 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    //3 month lock up
    function earlyAngelSales(address _to, uint256 _value) public onlyOwner returns (bool success)   {
        require (_to != 0x0 && _value > 0 && _to !=team_address);
        
        uint v = _value * 10 ** uint256(decimals);
        require (balances[msg.sender] >= v && v > 0) ;

        balances[msg.sender] -= v;
        balances[_to] += v;
        angels_locks [ _to ]  += v;

        Transfer(msg.sender, _to, v);

        return true;
    }


    function batchEarlyAngelSales(address []_tos, uint256 []_values) public onlyOwner returns (bool success)   {
        require( _tos.length == _values.length );
        for (uint256 i = 0; i < _tos.length; i++) {
            earlyAngelSales(_tos[i], _values[i]);
        }
        return true;
    }


    function angelSales(address _to, uint256 _value) public onlyOwner returns (bool success)   {
        require (_to != 0x0 && _value > 0 && _to !=team_address);
        
        uint v = _value * 10 ** uint256(decimals);
        require (balances[msg.sender] >= v && v > 0) ;

        balances[msg.sender] -= v;
        balances[_to] += v;
        angels_locks[_to] += v/2;

        Transfer(msg.sender, _to, v);

        return true;
    }

    function batchAngelSales(address []_tos, uint256 []_values) public onlyOwner returns (bool success)   {
        require( _tos.length == _values.length );
        for (uint256 i = 0; i < _tos.length; i++) {
            angelSales(_tos[i], _values[i]);
        }
        return true;
    }

    function unlockAngelAccounts(address[] _batchOfAddresses) public onlyOwner returns (bool success)   {
        
        require( time_on_trademarket != 0 );
        require( now > time_on_trademarket + angels_lock_days );//after 3months

        address holder;

        for (uint256 i = 0; i < _batchOfAddresses.length; i++) {
            holder = _batchOfAddresses[i];
            if(angels_locks[holder]>0){                
                angels_locks[holder] = 0;
            }
        }
        return true;
    }


    function frozen_team(address _to) public onlyOwner returns (bool success)   {

        require (team_address == 0);

        team_address = _to;
        
        uint v = team_lock_count;

        balances[msg.sender] -= v;
        balances[_to] += v;
        Transfer(msg.sender, _to, v);
        return true;
    }

    function changeTeamAddress(address _new)  public onlyOwner returns (bool success)   {

        require (_new != 0 && team_address != 0);
        address old_team_address = team_address;

        uint team_remains = balances[team_address];
        balances[team_address] -= team_remains;
        balances[_new] += team_remains;

        team_address = _new;
        Transfer(old_team_address, _new, team_remains);

        return true;
    }

    function epochReleaseTeam(address _to) public onlyOwner returns (bool success)   {
        require (balances[team_address] > 0);
        require (now > last_release_date + team_release_epoch );
        
        uint current_release_count = (now - last_release_date)  / (team_release_epoch ) * epoch_release_count;
       
        if(balances[team_address]>current_release_count){
            current_release_count = current_release_count;
        }else{
            current_release_count = balances[team_address];
        }
        
        balances[team_address] -= current_release_count;
        balances[_to] += current_release_count;

        last_release_date += (current_release_count / epoch_release_count ) * team_release_epoch;

        team_lock_count -= current_release_count;

        Transfer(team_address, _to, current_release_count);
        return true;
    }

}
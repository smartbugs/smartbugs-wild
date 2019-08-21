pragma solidity ^0.4.21;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
        return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; 
}

contract Base {
    using SafeMath for uint256;

    uint public createDay;
    
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner)  external  onlyOwner {
        require(_newOwner != address(0x0));
        owner = _newOwner;
    }

    address public admin;

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

    function setAdmin(address _newAdmin)  external  onlyAdmin {
        require(_newAdmin != address(0x0));
        admin = _newAdmin;
    }
    
    mapping(address => bool) public blacklistOf;   

    function addBlacklist(address _Addr) external onlyAdmin {
        require (_Addr != address(0x0));  
        blacklistOf[_Addr] = true;
    }  

    function delBlacklist(address _Addr) external onlyAdmin {
        require (_Addr != address(0x0));  
        blacklistOf[_Addr] = false;
    }
    
    function isBlacklist(address _Addr) public view returns(bool _result) {  
        require (_Addr != address(0x0));  
        _result = (now <  (createDay + 90 days) * (1 days)) && blacklistOf[_Addr];
    }

}

contract TokenERC20 is Base {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);


    function _transfer(address _from, address _to, uint _value) internal returns (bool success) {
        require(_to != address(0x0));
        require(!isBlacklist(_from));
        require(!isBlacklist(_to));
        require(balanceOf[_from] >= _value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);                    // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) 
    {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);                          
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);         
        totalSupply = totalSupply.sub(_value);                             
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(1 == 2);
        emit Burn(_from, _value);
        return true;
    }
}


contract TokenBNH is TokenERC20 {
    
    function TokenBNH(address _owner, address _admin) public {
 
        require(_owner != address(0x0));
        require(_admin != address(0x0));
        owner = _owner;
        admin = _admin;

        totalSupply = 1000000000 * 10 ** uint256(decimals);    
        uint toOwner =  47500000 * 10 ** uint256(decimals);
        uint toAdmin =   2500000 * 10 ** uint256(decimals);        
        balanceOf[address(this)] = totalSupply - toOwner - toAdmin;               
        balanceOf[owner] = toOwner;                            
        balanceOf[admin] = toAdmin;                        
        name = "BBB";                                    
        symbol = "BBB";                                     
        createDay = now / (1 days);
    }


    function batchTransfer1(address[] _tos, uint256 _amount) external  {
        require(_batchTransfer1(msg.sender, _tos, _amount));
    }

    function _batchTransfer1(address _from, address[] memory _tos, uint256 _amount) internal returns (bool _result) {
        require(_amount > 0);
        require(_tos.length > 0);
        for(uint i = 0; i < _tos.length; i++){
            address to = _tos[i];
            require(to != address(0x0));
            require(_transfer(_from, to, _amount));
        }
        _result = true;
    }

    function batchTransfer2(address[] _tos, uint256[] _amounts) external  {
        require(_batchTransfer2(msg.sender, _tos, _amounts));
    }

    function _batchTransfer2(address _from, address[] memory _tos, uint256[] memory _amounts) internal returns (bool _result)  {
        require(_amounts.length > 0);
        require(_tos.length > 0);
        require(_amounts.length == _tos.length );
        for(uint i = 0; i < _tos.length; i++){
            require(_tos[i] != address(0x0) && _amounts[i] > 0);
            require(_transfer(_from, _tos[i], _amounts[i]));
        }
        _result = true;
    }

    mapping(uint => uint) dayFillOf;    

    function getDay(uint _time) public pure returns (uint _day)
    {
        _day = _time.div(1 days);
    }

    function getDayMaxAmount(uint _day) public view returns (uint _amount)
    {
        require(_day >= createDay);
        uint AddDays = _day - createDay;
        uint Power = AddDays / 200;
        
        _amount = 400000;
        _amount = _amount.mul(10 ** uint(decimals));      
        for(uint i = 0; i < Power; i++)
        {
            require(_amount > 0);
            _amount = _amount * 9 / 10;
        }
    }

    function getDayIssueAvaAmount(uint _day) public view returns (uint _toUserAmount)
    {
        uint max = getDayMaxAmount(_day);
        uint fill = dayFillOf[_day];
        require(max >= fill);
        _toUserAmount = (max - fill).mul(95) / 100;
    }
    
    event OnIssue1(uint indexed _day, address[]  _tos, uint256 _amount, address _sender);

    function issue1(uint _day, address[] _tos, uint256 _amount) external onlyOwner 
    {      
        require(_day * (1 days) <= now);
        require(_amount > 0);
        uint toAdminAmountAll = 0;
        for(uint i = 0; i < _tos.length; i++){
            address to = _tos[i];
            require(to != address(0x0));

            uint toAdminAmount = _amount.mul(5) / 95;
            dayFillOf[_day] = dayFillOf[_day].add(_amount).add(toAdminAmount);
            uint DayMaxAmount = getDayMaxAmount(_day);
            require( dayFillOf[_day] <= DayMaxAmount);

            require(_transfer(address(this), to, _amount));
            toAdminAmountAll = toAdminAmountAll .add(toAdminAmount);
        }
        require(_transfer(address(this), admin, toAdminAmountAll));
        emit OnIssue1(_day, _tos, _amount, msg.sender);
    }

    event OnIssue2(uint indexed _day, address[]  _tos, uint256[]  _amounts, address _sender);

    function issue2(uint _day, address[] _tos, uint256[] _amounts) external onlyOwner 
    {
      
        require(_day * (1 days) <= now);
        require(_tos.length == _amounts.length);
        uint toAdminAmountAll = 0;
        for(uint i = 0; i < _tos.length; i++){
            address to = _tos[i];
            require(to != address(0x0));
            require(_amounts[i] > 0);

            uint toAdminAmount = _amounts[i].mul(5) / 95;
            dayFillOf[_day] = dayFillOf[_day].add(_amounts[i]).add(toAdminAmount);
            uint DayMaxAmount = getDayMaxAmount(_day);
            require(dayFillOf[_day] <= DayMaxAmount);

            require(_transfer(address(this), to,  _amounts[i]));
            toAdminAmountAll = toAdminAmountAll.add(toAdminAmount);
        }
        require(_transfer(address(this), admin, toAdminAmountAll));
        emit OnIssue2(_day, _tos, _amounts, msg.sender);
    }
    
    function() payable external {
       
    }

}
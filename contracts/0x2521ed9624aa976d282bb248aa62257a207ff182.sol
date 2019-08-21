pragma solidity ^0.4.25;

/**
 * @title  Heaven in ERC20
 */
contract ERC20 {
   
    //functions
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external constant returns (uint256 remaining);
    function name() external constant returns  (string _name);
    function symbol() external constant returns  (string _symbol);
    function decimals() external constant returns (uint8 _decimals);
    function totalSupply() external constant returns (uint256 _totalSupply);
   

    //Events
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event ERC223Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Burn(address indexed burner, uint256 value);
    event FrozenAccount(address indexed targets);
    event UnfrozenAccount(address indexed target);
    event LockedAccount(address indexed target, uint256 locked);
    event UnlockedAccount(address indexed target);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20Receive {

    TKN internal fallback;

    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public pure {
        TKN memory tkn;
        tkn.sender = _from;
        tkn.value = _value;
        tkn.data = _data;
        uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
        tkn.sig = bytes4(u);

       
    }
}

contract Ownable {
    
    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


/**
 * @title Heaven Main
 */
contract Heaven is ERC20, Ownable {

    using SafeMath for uint;
    string public name = "Heaven";
    string public symbol = "HCOIN";
    uint8 public decimals = 8;
    uint256 public totalSupply = 15300000000 * (10 ** uint256(decimals));

    
    mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public unlockUnixTime;

    constructor() public {
        balances[msg.sender] = totalSupply;
    }

    mapping (address => uint256) public balances;

    mapping(address => mapping (address => uint256)) public allowance;

   
    function name() external constant returns (string _name) {
        return name;
    }
   
    function symbol() external constant returns (string _symbol) {
        return symbol;
    }
   
    function decimals() external constant returns (uint8 _decimals) {
        return decimals;
    }
   
    function totalSupply() external constant returns (uint256 _totalSupply) {
        return totalSupply;
    }

   
    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }
   
    function transfer(address _to, uint _value) public returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender]
                && now > unlockUnixTime[_to]
                && _to != address(this));
        bytes memory empty = hex"00000000";
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }

    function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender]
                && now > unlockUnixTime[_to]
                && _to != address(this));
        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
   
    function approve(address _spender, uint256 _value) external returns (bool success) {
        allowance[msg.sender][_spender] = 0; // mitigate the race condition
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    
    function allowance(address _owner, address _spender) external constant returns (uint256 remaining) {
        return allowance[_owner][_spender];
    }


    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit ERC223Transfer(msg.sender, _to, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        ERC20Receive receiver = ERC20Receive(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit ERC223Transfer(msg.sender, _to, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require(_to != address(0)
                && _value > 0
                && balances[_from] >= _value
                && allowance[_from][msg.sender] >= _value
                && frozenAccount[_from] == false
                && frozenAccount[_to] == false
                && now > unlockUnixTime[_from]
                && now > unlockUnixTime[_to]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
  
    
    function multiTransfer(address[] _addresses, uint256 _amount) public returns (bool) {
        require(_amount > 0
                && _addresses.length > 0
                && frozenAccount[msg.sender] == false
                && now > unlockUnixTime[msg.sender]);

        uint256 totalAmount = _amount.mul(_addresses.length);
        require(balances[msg.sender] >= totalAmount);

        for (uint j = 0; j < _addresses.length; j++) {
            require(_addresses[j] != 0x0
                    && frozenAccount[_addresses[j]] == false
                    && now > unlockUnixTime[_addresses[j]]);
                    
            balances[msg.sender] = balances[msg.sender].sub(_amount);
            balances[_addresses[j]] = balances[_addresses[j]].add(_amount);
            emit Transfer(msg.sender, _addresses[j], _amount);
        }
        return true;
    }

    function multiTransfer(address[] _addresses, uint256[] _amounts) public returns (bool) {
        require(_addresses.length > 0
                && _addresses.length == _amounts.length
                && frozenAccount[msg.sender] == false
                && now > unlockUnixTime[msg.sender]);

        uint256 totalAmount = 0;

        for(uint j = 0; j < _addresses.length; j++){
            require(_amounts[j] > 0
                    && _addresses[j] != 0x0
                    && frozenAccount[_addresses[j]] == false
                    && now > unlockUnixTime[_addresses[j]]);

            totalAmount = totalAmount.add(_amounts[j]);
        }
        require(balances[msg.sender] >= totalAmount);

        for (j = 0; j < _addresses.length; j++) {
            balances[msg.sender] = balances[msg.sender].sub(_amounts[j]);
            balances[_addresses[j]] = balances[_addresses[j]].add(_amounts[j]);
            emit Transfer(msg.sender, _addresses[j], _amounts[j]);
        }
        return true;
    }

    function burn(address _from, uint256 _tokenAmount) onlyOwner public {
        require(_tokenAmount > 0
                && balances[_from] >= _tokenAmount);
        
        balances[_from] = balances[_from].sub(_tokenAmount);
        totalSupply = totalSupply.sub(_tokenAmount);
        emit Burn(_from, _tokenAmount);
    }
        
    function freezeAccounts(address[] _targets) onlyOwner public {
        require(_targets.length > 0);

        for (uint j = 0; j < _targets.length; j++) {
            require(_targets[j] != 0x0 && _targets[j] != Ownable.owner);
            frozenAccount[_targets[j]] = true;
            emit FrozenAccount(_targets[j]);
        }
    }
    
    
    function unfreezeAccounts(address[] _targets) onlyOwner public {
        require(_targets.length > 0);

        for (uint j = 0; j < _targets.length; j++) {
            require(_targets[j] != 0x0 && _targets[j] != Ownable.owner);
            frozenAccount[_targets[j]] = false;
            emit UnfrozenAccount(_targets[j]);
        }
    }
    
   
    function lockAccounts(address[] _targets, uint[] _unixTimes) onlyOwner public {
        require(_targets.length > 0
                && _targets.length == _unixTimes.length);

        for(uint j = 0; j < _targets.length; j++){
            require(_targets[j] != Ownable.owner);
            require(unlockUnixTime[_targets[j]] < _unixTimes[j]);
            unlockUnixTime[_targets[j]] = _unixTimes[j];
            emit LockedAccount(_targets[j], _unixTimes[j]);
        }
    }

    function unlockAccounts(address[] _targets) onlyOwner public {
        require(_targets.length > 0);
         
        for(uint j = 0; j < _targets.length; j++){
            unlockUnixTime[_targets[j]] = 0;
            emit UnlockedAccount(_targets[j]);
        }
    }
    
    

}
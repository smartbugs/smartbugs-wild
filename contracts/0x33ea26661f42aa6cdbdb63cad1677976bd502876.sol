pragma solidity ^0.4.24;

library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
    return 0;
    }
    uint256 c = _a * _b;
    assert(c / _a == _b);
    return c;
    }
    
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a / _b;
    return c;
    }
    
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
    }
    
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    assert(c >= _a);
    return c;
    }
}

 

contract Ownable {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
    owner = msg.sender;
    newOwner = address(0);
    }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }

    modifier onlyNewOwner() {
    require(msg.sender != address(0));
    require(msg.sender == newOwner);
    _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    newOwner = _newOwner;
    }
    
    function acceptOwnership() public onlyNewOwner returns(bool) {
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    }
}


contract Pausable is Ownable {
    event Pause();
    event Unpause();
    bool public paused = false;
    
    modifier whenNotPaused() {
    require(!paused);
    _;
    }
    modifier whenPaused() {
    require(paused);
    _;
    }

    
    function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
    }
    
    
    function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
    }

}

 

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function allowance(address owner, address spender) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

 

interface TokenRecipient {
 function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

 

contract DeeptonCoin is ERC20, Ownable, Pausable {
    uint128 internal MONTH = 30 * 24 * 3600; // 1 month
    using SafeMath for uint256;
    
    
    struct LockupInfo {
    uint256 releaseTime;
    uint256 termOfRound;
    uint256 unlockAmountPerRound;
    uint256 lockupBalance;
    }
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 internal initialSupply;
    uint256 internal totalSupply_;
    
    mapping(address => uint256) internal balances;
    mapping(address => bool) public frozen;
    mapping(address => mapping(address => uint256)) internal allowed;
    event Burn(address indexed owner, uint256 value);
    event Mint(uint256 value);
    event Freeze(address indexed holder);
    event Unfreeze(address indexed holder);
    
    modifier notFrozen(address _holder) {
    require(!frozen[_holder]);
    _;
    }

    constructor() public {
    name = "DeeptonCoin";
    symbol = "DTC";
    decimals = 6;
    initialSupply = 10000000000;
    totalSupply_ = initialSupply * 10 ** uint(decimals);
    balances[owner] = totalSupply_;
    emit Transfer(address(0), owner, totalSupply_);
    }

    function () public payable {
    revert();
    }

    function totalSupply() public view returns (uint256) {
    return totalSupply_;
    }

    function _transfer(address _from, address _to, uint _value) internal {
       
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
    
       balances[_from] = balances[_from].sub(_value);
       balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
      emit Transfer(_from, _to, _value);
    }
    
    function transfer(address _to, uint256 _value) public whenNotPaused notFrozen(msg.sender) returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    
    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
    }


    function balanceOf(address _holder) public view returns (uint256 balance) {
    return balances[_holder];
    }
    
     
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused notFrozen(_from)returns (bool) {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    _transfer(_from, _to, _value);
    
    return true;
    }
    
    

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
    }


 
    function allowance(address _holder, address _spender) public view returns (uint256) {
    return allowed[_holder][_spender];
    }

 
 
    function freezeAccount(address _holder) public onlyOwner returns (bool) {
    require(!frozen[_holder]);
    frozen[_holder] = true;
    emit Freeze(_holder);
    return true;
    }

 

    function unfreezeAccount(address _holder) public onlyOwner returns (bool) {
    require(frozen[_holder]);
    frozen[_holder] = false;
    emit Unfreeze(_holder);
    return true;
    }

 
   function burn(uint256 _value) public onlyOwner returns (bool success) {
    require(_value <= balances[msg.sender]);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    return true;
    }

 
    function mint( uint256 _amount) onlyOwner public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[owner] = balances[owner].add(_amount);
    
    emit Transfer(address(0), owner, _amount);
    return true;
    }

    
}
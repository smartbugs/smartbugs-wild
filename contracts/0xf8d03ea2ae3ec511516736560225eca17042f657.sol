pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


contract ERC20 {
  function totalSupply() public constant returns (uint256);

  function balanceOf(address _who) public constant returns (uint256);

  function allowance(address _owner, address _spender) public constant returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _fromValue,uint256 _toValue) public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

  
}

contract Pausable is Ownable {
  event Paused();
  event Unpaused();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Paused();
  }

  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpaused();
  }
}



contract Lambda is ERC20, Pausable {
  using SafeMath for uint256;

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;

  string public symbol;
  string public  name;
  uint256 public decimals;
  uint256 _totalSupply;

  constructor() public {
    symbol = "LAMB";
    name = "Lambda";
    decimals = 18;

    _totalSupply = 6*(10**27);
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }

  function totalSupply() public  constant returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address _owner) public  constant returns (uint256) {
    return balances[_owner];
  }

  function allowance(address _owner, address _spender) public  constant returns (uint256) {
    return allowed[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _fromValue, uint256 _toValue) public whenNotPaused returns (bool) {
    require(_spender != address(0));
    require(allowed[msg.sender][_spender] ==_fromValue);
    allowed[msg.sender][_spender] = _toValue;
    emit Approval(msg.sender, _spender, _toValue);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool){
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  
}


contract LambdaLock {
    using SafeMath for uint256;
    Lambda internal LambdaToken;
    
   uint256 internal genesisTime= 1545872400;//固定时间  秒 2018-12-27 09:00:00;  //开始时间设为固定值
    

    uint256 internal ONE_MONTHS = 2592000;  //1个月的秒

    address internal beneficiaryAddress;

    struct Claim {
        
        uint256 pct;
        uint256 delay;
        bool claimed;
    } 

    Claim [] internal beneficiaryClaims;
    uint256 internal totalClaimable;

    event Claimed(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    function claim() public returns (bool){
        require(msg.sender == beneficiaryAddress); 
        for(uint256 i = 0; i < beneficiaryClaims.length; i++){
            Claim memory cur_claim = beneficiaryClaims[i];
            if(cur_claim.claimed == false){
                if(cur_claim.delay.add(genesisTime) < block.timestamp){
        
                    uint256 amount = cur_claim.pct*(10**18);
                    require(LambdaToken.transfer(msg.sender, amount));
                    beneficiaryClaims[i].claimed = true;
                    emit Claimed(msg.sender, amount, block.timestamp);
                }
            }
        }
    }

    function getBeneficiary() public view returns (address) {
        return beneficiaryAddress;
    }

    function getTotalClaimable() public view returns (uint256) {
        return totalClaimable;
    }
}



contract lambdaFound is LambdaLock {
    using SafeMath for uint256;
    
    constructor(Lambda _LambdaToken) public {
        LambdaToken = _LambdaToken;
        
        
        
        beneficiaryAddress = 0xb2AC97941a1c610f73E68b3969CdC886a2EA5491 ;
        totalClaimable = 2000000000 * (10 ** 18);
        for(uint i=0;i<24;i++){
            beneficiaryClaims.push(Claim( 83333333, ONE_MONTHS*(i+1), false));
       }
        
    
    }
}
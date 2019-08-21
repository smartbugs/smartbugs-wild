pragma solidity ^0.4.23;
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}





/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}





/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

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


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }


  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  address master;

  bool public paused;


  modifier isMaster {
      require(msg.sender == master);
      _;
  }

  modifier isPause {
   require(paused == true);
   _;
 }

  modifier isNotPause {
   require(paused == false);
   _;
  }




  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public isNotPause returns (bool) {
    require(_spender != address(0));
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public isNotPause
    returns (bool)
  {
    require(_spender != address(0));
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public isNotPause
    returns (bool)
  {
    require(_spender != address(0));
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract KocToken is StandardToken {

  string public constant name = "King Of Catering (Entertainment) ";
  string public constant symbol = "KOC";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));
  address coinbase;

  address private constant project_foundation_address     = 0x5715f21002de7ac8097593290591907c459295c5;
  uint8   private constant project_foundation_percent     = 10;
  uint256 private constant project_foundation_starttime   = 1604160000;
  uint256 private constant project_foundation_interval    = 2592000;
  uint256 private constant project_foundation_periods     = 20;

  address private constant technical_team_address         = 0x3ad3106970609844652205a4a8fc68e6aa590eb1;
  uint8   private constant technical_team_percent         = 10;
  uint256 private constant technical_team_starttime       = 1635696000;
  uint256 private constant technical_team_interval        = 2592000;
  uint256 private constant technical_team_periods         = 20;

  address private constant community_reward_address       = 0x1a35941a5a52f0d212b67b87af51daa23a9fb7fc;
  uint8   private constant community_reward_percent       = 30;

  address private constant community_operation_address    = 0x334eb99a16bb1bd5a8ecc6c2ce44fb270f4bf451;
  uint8   private constant community_operation_percent    = 30;

  address private constant user_mining_address            = 0x939302d1eab4009d7cee5d410a4f61a5f2864d7a;
  uint8   private constant user_mining_percent            = 10;

  address private constant cornerstone_wheel_address      = 0xbe45decacf12248f4459f5e0295de12993b34b15;
  uint8   private constant cornerstone_wheel_percent      = 5;

  address private constant private_wheel_address          = 0xf35da84e81432c86e9254206c12cf6d4a6221384;
  uint8   private constant private_wheel_percent          = 5;



  struct Vesting {
    uint256 startTime;
    uint256 initReleaseAmount;
    uint256 amount;
    uint256 interval;
    uint256 periods;
    uint256 withdrawed;
  }

  mapping (address => Vesting[]) vestings;

  event AssetLock(address indexed to,uint256 startTime,uint256 initReleaseAmount,uint256 amount,uint256 interval,uint256 periods);
  /**
  * @dev Constructor that gives msg.sender all of existing tokens.
  */
  constructor(address _master) public {
   require(_master != address(0));
   totalSupply_ = INITIAL_SUPPLY;
   master = _master;
   paused = false;
   coinbase = msg.sender;
   balances[coinbase] = INITIAL_SUPPLY;

   uint256 balance_technical = INITIAL_SUPPLY * technical_team_percent / 100;
   assetLock(technical_team_address,technical_team_starttime,0,balance_technical,technical_team_interval,technical_team_periods);

   uint256 balance_project = INITIAL_SUPPLY * project_foundation_percent / 100;
   assetLock(project_foundation_address,project_foundation_starttime,0,balance_project,project_foundation_interval,project_foundation_periods);

   uint256 balance_community_reward = INITIAL_SUPPLY * community_reward_percent / 100;
   balances[community_reward_address] = balance_community_reward;
   balances[coinbase] =  balances[coinbase].sub(balance_community_reward);

   uint256 balance_community_operation = INITIAL_SUPPLY * community_operation_percent / 100;
   balances[community_operation_address] = balance_community_operation;
   balances[coinbase] =  balances[coinbase].sub(balance_community_operation);

   uint256 balance_user_mining = INITIAL_SUPPLY * user_mining_percent / 100;
   balances[user_mining_address] = balance_user_mining;
   balances[coinbase] =  balances[coinbase].sub(balance_user_mining);

   uint256 balance_cornerstone_wheel = INITIAL_SUPPLY * cornerstone_wheel_percent / 100;
   balances[cornerstone_wheel_address] = balance_cornerstone_wheel;
   balances[coinbase] =  balances[coinbase].sub(balance_cornerstone_wheel);

   uint256 balance_private_wheel = INITIAL_SUPPLY * private_wheel_percent / 100;
   balances[private_wheel_address] = balance_private_wheel;
   balances[coinbase] =  balances[coinbase].sub(balance_private_wheel);


 }


  function assetLock(address _to,uint256 _startTime,uint256 _initReleaseAmount,uint256 _amount,uint256 _interval,uint256 _periods) internal {
      require(balances[coinbase] >= _amount);
      require(_initReleaseAmount <= _amount);
      vestings[_to].push(Vesting(_startTime, _initReleaseAmount, _amount, _interval, _periods, 0));
      balances[coinbase] = balances[coinbase].sub(_amount);
      emit AssetLock(_to,_startTime,_initReleaseAmount,_amount,_interval,_periods);
 }

  function batchTransfer(address[] _to, uint256[] _amount) public isNotPause returns (bool) {
     for (uint i = 0; i < _to.length; i++) {
       getVesting(msg.sender);
       transfer(_to[i] , _amount[i]);
     }
     return true;
   }

   /**
   * @dev Transfer token for a specified address
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
   function transfer(address _to, uint256 _value) public isNotPause returns (bool) {
     require(_to != address(0));
     uint256 remain = availableBalance(msg.sender);
     require(_value <= remain);
     getVesting(msg.sender);
     balances[msg.sender] = balances[msg.sender].sub(_value);
     balances[_to] = balances[_to].add(_value);
     emit Transfer(msg.sender, _to, _value);
     return true;
   }


   /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
   function transferFrom(
     address _from,
     address _to,
     uint256 _value
   )
     public isNotPause
     returns (bool)
   {
     require(_to != address(0));
     require(_from != address(0));
     require(_value <= allowed[_from][msg.sender]);
     uint256 remain = availableBalance(_from);
     require(_value <= remain);
     getVesting(_from);
     balances[_from] = balances[_from].sub(_value);
     balances[_to] = balances[_to].add(_value);
     allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
     emit Transfer(_from, _to, _value);
     return true;
   }


   function setPause() public isMaster isNotPause{
     paused = true;
   }

   function setResume() public isMaster isPause{
     paused = false;
   }

   function pauseStatus() public view isMaster returns (bool){
     return paused;
   }


   function vestingBalance(address _owner) internal view returns (uint256) {
     uint256 sum = 0;
      for(uint i = 0 ;i < vestings[_owner].length;i++){
        sum = sum.add(vestings[_owner][i].amount.sub(vestings[_owner][i].withdrawed));
      }
      return sum;
   }

  /*
  Current available balance
  */
   function availableBalance(address _owner) public view returns (uint256) {
     uint256 sum = 0;
      for(uint i = 0 ;i < vestings[_owner].length;i++){
        Vesting memory vs = vestings[_owner][i];
        uint256 release = vestingRelease(vs.startTime,vs.initReleaseAmount, vs.amount, vs.interval, vs.periods);
        uint256 keep = release.sub(vs.withdrawed);
        if(keep >= 0){
          sum = sum.add(keep);
        }
      }
      return sum.add(balances[_owner]);
   }

   /*
   Get all the assets of the user
   */
   function allBalance(address _owner)public view returns (uint256){
     uint256 allbalance = vestingBalance(_owner);
     return allbalance.add(balances[_owner]);
   }
    /*
    Calculate the current time release
    */
   function vestingRelease(uint256 _startTime,uint256 _initReleaseAmount,uint256 _amount,uint256 _interval,uint256 _periods) public view returns (uint256) {
    return vestingReleaseFunc(now,_startTime,_initReleaseAmount,_amount,_interval,_periods);
   }

   /*
   Calculate the current time release
   */
  function vestingReleaseFunc(uint256 _endTime,uint256 _startTime,uint256 _initReleaseAmount,uint256 _amount,uint256 _interval,uint256 _periods) public pure  returns (uint256) {
    if (_endTime < _startTime) {
      return 0;
    }
    uint256 last = _endTime.sub(_startTime);
    uint256 allTime =  _periods.mul(_interval);
    if (last >= allTime) {
      return _amount;
    }
    uint256 eachPeriodAmount = _amount.sub(_initReleaseAmount).div(_periods);
    uint256 lastTime = last.div(_interval);
    uint256 vestingAmount = eachPeriodAmount.mul(lastTime).add(_initReleaseAmount);
    return vestingAmount;
  }



   /*
   Get vesting funds
   */
   function getVesting(address _to) internal {
     uint256 sum = 0;
     for(uint i=0;i< vestings[_to].length;i++){
       if(vestings[_to][i].amount == vestings[_to][i].withdrawed){
         continue;
       }else{
         Vesting  memory vs = vestings[_to][i];
         uint256 release = vestingRelease(vs.startTime,vs.initReleaseAmount, vs.amount, vs.interval, vs.periods);
         uint256 keep = release.sub(vs.withdrawed);
         if(keep >= 0){
           vestings[_to][i].withdrawed = release;
           sum = sum.add(keep);
         }
       }
     }
     if(sum > 0 ){
       balances[_to] = balances[_to].add(sum);
     }
   }

   /**
   * @dev Gets the balance of the specified address.
   * @param _owner The address to query the the balance of.
   * @return An uint256 representing the amount owned by the passed address.
   */
   function balanceOf(address _owner) public view returns (uint256) {
     return availableBalance(_owner);
   }
}
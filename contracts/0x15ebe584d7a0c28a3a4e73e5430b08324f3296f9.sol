pragma solidity >=0.4.22 <0.6.0;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
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
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

library CommUtils{

 
    uint256 constant MAX_MUL_BASE = 340282366920939000000000000000000000000;


    function abs(uint256 a,uint256 b) internal pure returns(uint256){
        return a>b ? a-b : b-a;
    }

   
    function mult(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }    

    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mult(z,x);
            return (z);
        }
    }


    function mulRate(uint256 tar,uint256 rate) public pure returns (uint256){
        return tar *rate / 100;
    }  
    
    function mulRate1000(uint256 tar,uint256 rate) public pure returns (uint256){
        return tar *rate / 1000;
    }  
    
    
    /**
     * @dev filters name strings
     * -converts uppercase to lower case.  
     * -makes sure it does not start/end with a space
     * -makes sure it does not contain multiple spaces in a row
     * -cannot be only numbers
     * -cannot start with 0x 
     * -restricts characters to A-Z, a-z, 0-9, and space.
     * @return reprocessed string in bytes32 format
     */
    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;
        
        //sorry limited to 32 characters
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }
        
        // create a bool to track if we have a non number character
        bool _hasNonNumber;
        
        // convert & check
        for (uint256 i = 0; i < _length; i++)
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                _temp[i] = byte(uint(_temp[i]) + 32);
                
                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    // require character is a space
                    _temp[i] == 0x20 || 
                    // OR lowercase a-z
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    // or 0-9
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");
                
                // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;    
            }
        }
        
        require(_hasNonNumber == true, "string cannot be only numbers");
        
        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }   
    
    function isStringEmpty(string str) internal pure returns(bool){
        bytes memory tempEmptyStringTest = bytes(str); 
        return tempEmptyStringTest.length == 0;
    }
     
    
    
    
    
    struct Float{
        uint256 number;
        uint256 digits;
    }
    
    function initFloat(uint256 v,uint256 denominator) internal pure returns(Float){
        return Float(v*denominator,denominator);
    }
    
    
    function pow(Float f ,uint256 count) internal pure returns(Float ans){

        if (count==0){
            return Float(10,1);
        }
        ans.number = f.number;
        ans.digits = f.digits;
        for(uint256 i=1;i<count;i++){
            ans = multiply(ans,f);
        }
    }
    
    function decrease(Float f,Float o) internal pure returns(bool ok,Float ans){
        sameDigits(f,o);
        require(f.digits == o.digits,"it`s must same sameDigits");
        if(f.number >= o.number ){
            ok = true;            
            ans.number = f.number - o.number;
            ans.digits = f.digits;
        }
    }
    
    function increase(Float f,Float o) internal pure returns(Float ans){
        sameDigits(f,o);
        require(f.digits == o.digits,"it`s must same sameDigits");
        ans.number = f.number+o.number;
        ans.digits = f.digits;
    }
    
    function sameDigits(Float f,Float o) private pure {
        return f.digits > o.digits ? _sameDigits(f,o) : _sameDigits(o,f) ;
    }
    
    function _sameDigits(Float big,Float small ) private pure {
        uint256 dd = big.digits - small.digits;
        small.number = small.number * pwr(10,dd);
        small.digits = big.digits;
    }
    
    function multiSafe(uint256 a,uint256 b) internal pure returns (uint256 ans,uint256 ap,uint256 bp){
        (uint256 newA, uint256 apow)  = powDown(a);
        (uint256 newB, uint256 bpow)  = powDown(b);
        ans = mult(newA , newB);
        ap = apow;
        bp = bpow;
    }
    
    function powDown(uint256 a) internal pure returns(uint256 newA,uint256 pow10){
        newA = a;
        while(newA>=MAX_MUL_BASE){
            pow10++;
            newA /= 10;
        }
    }
    
    function multiply(Float  f,Float o) internal pure returns(Float ans){
        (uint256 v,uint256 ap,uint256 bp ) = multiSafe(f.number,o.number);
        ans.number = v;  
        ans.digits = f.digits+o.digits-(ap+bp);
    }
    
    function multiply(Float  f,uint256 tar) internal pure returns(Float ans){
        (uint256 v,uint256 ap,uint256 bp ) = multiSafe(f.number,tar);
        ans.number = v;
        ans.digits = f.digits-(ap+bp);
    }    
    
    function divide(Float f,Float o) internal pure returns(Float ans){
       if(f.digits >= o.digits){
           ans.digits = f.digits - o.digits;
       }else{
           uint256 dp = o.digits - f.digits;
           ans.digits = 0;
           ans.number = mult( f.number , pwr(10,dp));
       }
        ans.number = ans.number / o.number;
    }
    
    function toUint256(Float f) internal pure returns(uint256 ans){
        ans = f.number;
        for(uint256 i=0;i<f.digits;i++){
            ans /= 10;
        }
    }
    
    function getIntegral(Float exCoefficient,uint256 xb,uint256 tokenDigits,uint256 X_POW) internal pure returns(uint256 ){
        CommUtils.Float memory x = CommUtils.Float(xb,tokenDigits);
        Float memory xPow = pow(x,X_POW+1);
        Float memory ec = pow(exCoefficient,X_POW);
        Float memory tempAns = multiply(xPow,ec);
        return toUint256(tempAns)/(X_POW+1); 
    }   
    
    
    
    struct Countdown{
        uint128 max;
        uint128 current;
        uint256 timestamp;
        uint256 period;
        bool passing;
    }
    
    function freshAndCheck(Countdown  d,uint256 curP,uint256 max,uint256 period) view internal returns(Countdown){
        if(d.timestamp == 0) {
            d=Countdown( uint128( max),0,  now,period , true);
        }  
        if(now - d.timestamp > period){
          d= Countdown( uint128( max),0,now,period,true);  
        } 
        d.current += uint128(curP);
        d.passing = d.current <= d.max;
        return d;
    }    
    
    
}



library Player{

    using CommUtils for string;
    using CommUtils for CommUtils.Countdown;
    uint256 public constant BONUS_INTERVAL = 60*60*24*7;
    
    
    struct Map{
        mapping(address=>uint256) bonusAt;
        mapping(address=>uint256) ethMap;
        mapping(address=>address) referrerMap;
        mapping(address=>bytes32) addrNameMap;
        mapping(bytes32=>address) nameAddrMap;
        mapping(address=>CommUtils.Countdown) sellLimeMap;
    }
    
    function remove(Map storage ps,address adr) internal{
        //transferAuthor(ps.ethMap[adr]);
        delete ps.ethMap[adr];
        bytes32 b = ps.addrNameMap[adr];
        delete ps.nameAddrMap[b];
        delete ps.addrNameMap[adr];
    }
    
    function deposit(Map storage  ps,address adr,uint256 v) internal returns(uint256) {
       ps.ethMap[adr]+=v;
        return v;
    }
    
    



    function refleshBonusAt(Map storage  ps,address addr,uint256 allCount,uint256 plusCount) internal{
        if(ps.bonusAt[addr] == 0)        {
            ps.bonusAt[addr] = now;
            return;
        }
        uint256 plsuAt = BONUS_INTERVAL * plusCount / allCount;
        ps.bonusAt[addr] += plsuAt;
        ps.bonusAt[addr] = ps.bonusAt[addr] > now ? now : ps.bonusAt[addr];
    }
    
    
    
    function isOverBonusAt(Map storage ps,address addr) internal returns(bool ){
        if( (ps.bonusAt[addr] - now)> BONUS_INTERVAL){
            ps.bonusAt[addr] = now;
            return true;
        }
        return false;
    }
    
    function transferSafe(address addr,uint256 v) internal {
        if(address(this).balance>=v){
            addr.transfer(v);
        }else{
            addr.transfer( address(this).balance);
        }
    }
    

    function minus(Map storage  ps,address adr,uint256 num) internal  {
        uint256 sum = ps.ethMap[adr];
        if(sum==num){
             withdrawalAll(ps,adr);
        }else{
            require(sum > num);
            ps.ethMap[adr] = sum-num;
        }
    }
    
    function minusAndTransfer(Map storage  ps,address adr,uint256 num) internal  {
        minus(ps,adr,num);
        transferSafe(adr,num);
    }    
    
    function withdrawalAll(Map storage  ps,address adr) public returns(uint256) {
        uint256 sum = ps.ethMap[adr];
        delete ps.ethMap[adr];
        return sum;
    }
    
    function getAmmount(Map storage ps,address adr) public view returns(uint256) {
        return ps.ethMap[adr];
    }
    
    function registerName(Map storage ps,bytes32 _name)internal  {
        require(ps.nameAddrMap[_name] == address(0) );
        ps.nameAddrMap[_name] = msg.sender;
        ps.addrNameMap[msg.sender] = _name;
    }
    
    function isEmptyName(Map storage ps,bytes32 _name) public view returns(bool) {
        return ps.nameAddrMap[_name] == address(0);
    }
    
    function getByName(Map storage ps,bytes32 _name)public view returns(address) {
        return ps.nameAddrMap[_name] ;
    }
    
    function getName(Map storage ps) public view returns(bytes32){
        return ps.addrNameMap[msg.sender];
    }
    
    function getName(Map storage ps,address adr) public view returns(bytes32){
        return ps.addrNameMap[adr];
    }    
    
    function getNameByAddr(Map storage ps,address adr) public view returns(bytes32){
        return ps.addrNameMap[adr];
    }    
    
    function getReferrer(Map storage ps,address adr)public view returns(address){
        address refA = ps.referrerMap[adr];
        bytes32 b= ps.addrNameMap[refA];
        return b.length == 0 ? getReferrer(ps,refA) : refA;
    }
    
    function getReferrerName(Map storage ps,address adr)public view returns(bytes32){
        return getNameByAddr(ps,getReferrer(ps,adr));
    }
    
    function setReferrer(Map storage ps,address self,address referrer)internal {
         ps.referrerMap[self] = referrer;
    }
    
    function applyReferrer(Map storage ps,string referrer)internal {
        bytes32 rbs = referrer.nameFilter();
        address referrerAdr = getByName(ps,rbs);
        require(referrerAdr != address(0),"referrerAdr is null");
        require(getReferrer(ps,msg.sender) == address(0) ,"must reffer is null");
        require(referrerAdr != msg.sender ,"referrerAdr is self ");
        require(getName(ps).length==0 || getName(ps) == bytes32(0),"must not reqester");
        setReferrer(ps,msg.sender,referrerAdr);
    }    
    
    
    function checkSellLimt(Map storage ps,uint256 curP,uint256 max,uint256 period)  internal returns(CommUtils.Countdown) {
        CommUtils.Countdown storage cd =  ps.sellLimeMap[msg.sender];
        ps.sellLimeMap[msg.sender] = cd.freshAndCheck(curP,max,period);
        return ps.sellLimeMap[msg.sender];
    }   
    
    function getSellLimt(Map storage ps) internal view returns (CommUtils.Countdown ) {
        return ps.sellLimeMap[msg.sender];
    }
    
    
    
}


contract IOE is  ERC20, ERC20Detailed {
    
    using CommUtils for CommUtils.Countdown;
    using CommUtils for CommUtils.Float;
    using CommUtils for string;
    using Player for Player.Map;
    
    

    uint256 private constant MAX_BUY_BY_USER_RATE = 3;
    uint256 private constant MAX_SELL_BY_USER_RATE = 10;
    uint256 private constant MAX_SELL_PER_USER_RATE = 25;
    uint256 private constant SELL_BUY_PERIOD= 60*60*24;
    uint256 private constant tokenDigits = 9;
    uint256 private constant tokenM = 1000000000;
    uint256 private constant INITIAL_SUPPLY = 100000000 * tokenM;
    uint256 private constant X_POW = 2; // y= (exCoefficient * x)^X_POW
    uint256 private constant BUY_BONUS_IN_1000 = 80;
    uint256 private constant SELL_BONUS_IN_1000 = 100;
    uint256 private constant REGESTER_FEE = 0.02 ether;
    uint256 private constant VIP_DISCOUNT_WEIGHT = 3;
    uint256 private constant VIP_INTTO_POOL_WEIGHT = 3;
    uint256 private constant VIP_TOUP_WEIGHT = 3;
    uint256 private constant VIP_RETOUP_RATE_1000 = 110;
    uint256 private constant HELP_MINING_BUY_1000 = 30;
    uint256 private constant HELP_MINING_SELL_1000 = 50;
    uint256 private constant VIP_ALL_WEIGHT = VIP_DISCOUNT_WEIGHT+VIP_INTTO_POOL_WEIGHT+VIP_TOUP_WEIGHT;

    address private OFFICIAL_ADDR ;
    uint256 private constant MIN_TX_ETHER = 0.001 ether;
    uint256 private providedCount =0;
    uint256 private vipPool = 0;
    Player.Map private players;
    CommUtils.Float exCoefficient;
    CommUtils.Countdown private buyByUserCD ;
    CommUtils.Countdown private sellByUserCD ;
    

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor (address oa) public   ERC20Detailed("INTELLIGENT OPERATING SYSTEM EXCHANGE", "IOE",9) {
        _mint(this, INITIAL_SUPPLY);
        require(CommUtils.pwr(10,tokenDigits) == tokenM,"it`s not same tokenM");
        exCoefficient = CommUtils.Float(1224744871,8);
        OFFICIAL_ADDR = oa;
    } 
    
    
    function getInfo() public view returns(
            uint256, //constractBlance
            uint256, //current providedCount count
            uint256,   // selfTokenBlance
            uint256,  //bounus pool
            uint256,   // contract now
            uint256,    // bonusAt
            bytes32, // registeredName
            bytes32, // refname
            uint256,   //VIP Reward
            address   //offAdd
        ){
        return (
            address(this).balance,
            providedCount, 
            balanceOf(msg.sender),
            getBonusPool(),
            now,
            players.bonusAt[msg.sender],
            players.getName(),
            players.getReferrerName(msg.sender),
            players.getAmmount(msg.sender),
            OFFICIAL_ADDR
        );
    }
    
    function getLimtInfo() public view returns(
        uint256 buyMax,uint256 buyCur,uint256 buyStartAt,
        uint256 sellMax , uint256 sellCur , uint256 sellStartAt,
        uint256 sellPerMax, uint256 sellCurPer , uint256 sellPerStartAt
    ){
        CommUtils.Countdown memory bCD = buyByUserCD.freshAndCheck(0,CommUtils.mulRate(INITIAL_SUPPLY-providedCount,MAX_BUY_BY_USER_RATE),SELL_BUY_PERIOD);
        buyMax = bCD.max;
        buyCur = bCD.current;
        buyStartAt = bCD.timestamp;
        CommUtils.Countdown memory sCD  = sellByUserCD.freshAndCheck(0,CommUtils.mulRate(providedCount,MAX_SELL_BY_USER_RATE),SELL_BUY_PERIOD);
        sellMax = sCD.max;
        sellCur = sCD.current;
        sellStartAt = sCD.timestamp;
        CommUtils.Countdown memory perCD = players.getSellLimt().freshAndCheck(0,CommUtils.mulRate(balanceOf(msg.sender),MAX_SELL_PER_USER_RATE),SELL_BUY_PERIOD);
        sellPerMax = perCD.max;
        sellCurPer = perCD.current;
        sellPerStartAt = perCD.timestamp;
    }
    
    
    
    function applyReferrer(string referrer) private {
        if(referrer.isStringEmpty()) return;
        players.applyReferrer(referrer);
    }
    
    function getBuyMinPow(uint256 eth) view public  returns(uint256 pow, uint256 current,uint256 valuePowNum,uint256 valuePowDig){
        pow = X_POW+1;
        current = providedCount;
        CommUtils.Float memory x2Pow = CommUtils.Float(providedCount,tokenDigits).pow(X_POW+1);
        CommUtils.Float memory rr = exCoefficient.pow(X_POW);
        CommUtils.Float memory V3 = CommUtils.Float((X_POW+1) * eth,0);
        CommUtils.Float memory LEFT = V3.divide(rr);
        CommUtils.Float memory value = LEFT.increase( x2Pow);
        valuePowNum = value.number;
        valuePowDig = value.digits;
    }
    
    function getSellMinPow(uint256 eth) view public  returns(uint256 pow, uint256 current,uint256 valuePowNum,uint256 valuePowDig){
        pow = X_POW+1;
        current = providedCount;
        CommUtils.Float memory x2Pow = CommUtils.Float(providedCount,tokenDigits).pow(X_POW+1);
        CommUtils.Float memory rr = exCoefficient.pow(X_POW);
        CommUtils.Float memory V3 = CommUtils.Float((X_POW+1) * eth,0);
        CommUtils.Float memory LEFT = V3.divide(rr);
        (bool ok,CommUtils.Float memory _value) = x2Pow.decrease(LEFT);
        CommUtils.Float memory value = ok ? _value : CommUtils.Float(current,tokenDigits).pow(pow);
        valuePowNum = value.number;
        valuePowDig = value.digits;
    }    
    
    
    function getIntegralAtBound(uint256 start,uint256 end) view public  returns(uint256){
        require(end>start,"must end > start");
        uint256 endI = exCoefficient.getIntegral(end,tokenDigits,X_POW);
        uint256 startI = exCoefficient.getIntegral(start,tokenDigits,X_POW);
        require(endI > startI ,"it`s endI  Integral > startI");
        return endI - startI;
    }
    
    function buyByUser(uint256 count,string referrer)   public payable {
        buyByUserCD = buyByUserCD.freshAndCheck(count,CommUtils.mulRate(INITIAL_SUPPLY-providedCount,MAX_BUY_BY_USER_RATE),SELL_BUY_PERIOD);
        require(buyByUserCD.passing ,"it`s over buy max count");
        applyReferrer(referrer);
        uint256 all = providedCount+count;
        require(all<= INITIAL_SUPPLY,"count over INITIAL_SUPPLY");
        uint256 costEth = getIntegralAtBound(providedCount,providedCount+count);
        uint256 reqEth = costEth * (1000+BUY_BONUS_IN_1000) / 1000;
        require(msg.value >= reqEth,"not enough eth");
        bonusFee(costEth,reqEth);
        providedCount = all;
        uint256 helpM = CommUtils.mulRate1000(count,HELP_MINING_BUY_1000);
        _transfer(this,msg.sender,count-helpM);
         _transfer(this,OFFICIAL_ADDR,helpM);
        players.refleshBonusAt(msg.sender,balanceOf(msg.sender),count);
        emit OnDealed (msg.sender,true,count,providedCount); 
    }
    
    function sellByUser(uint256 count,string referrer)   public  {
        require(providedCount >= count ,"count over providedCount ");
        sellByUserCD = sellByUserCD.freshAndCheck(count,CommUtils.mulRate(providedCount,MAX_SELL_BY_USER_RATE),SELL_BUY_PERIOD);
        require(sellByUserCD.passing ,"it`s over sell max count");
        require(players.checkSellLimt(count,CommUtils.mulRate(balanceOf(msg.sender),MAX_SELL_PER_USER_RATE),SELL_BUY_PERIOD).passing,"SELL over per user count");
        applyReferrer(referrer);
        uint256 helpM = CommUtils.mulRate1000(count,HELP_MINING_SELL_1000);
        uint256 realCount = (count-helpM);
        uint256 start = providedCount-realCount;
        uint256 end = providedCount;
        uint256 reqEth = getIntegralAtBound(start,end);
        uint256 costEth = reqEth * (1000- SELL_BONUS_IN_1000) / 1000;
        providedCount -= realCount;
        bonusFee(costEth,reqEth);
        transfer(this,count);
         _transfer(this,OFFICIAL_ADDR,helpM);
        emit OnDealed (msg.sender,false,count,providedCount); 
        Player.transferSafe(msg.sender,costEth);
    }
    
    function bonusFee(uint256 costEth,uint256 reqEth) private {
        address referrer = players.getReferrer(msg.sender);
        bool unreged = players.getName().length==0 || players.getName() == bytes32(0);
        if(unreged && referrer==address(0)) return;
        if(reqEth < costEth ) return ;
        uint256 orgFee = reqEth - costEth;
        uint256 repay = orgFee * VIP_DISCOUNT_WEIGHT / VIP_ALL_WEIGHT;
        uint256 toUp = orgFee * VIP_TOUP_WEIGHT / VIP_ALL_WEIGHT;
       // uint256 inPool = orgFee -(repay+toUp);
        players.deposit(msg.sender,repay);
        vipPool += repay;
        if(referrer != address(0)){
            players.deposit(referrer,toUp);
            vipPool += toUp;
        }
    }    
    
    /*  @override  */  
    function transferFrom(address from,address to,uint256 value)public returns (bool){
        players.refleshBonusAt(to,balanceOf(to),value);
        return super.transferFrom(from,to,value);
    }    
    
    /*  @override  */
    function transfer(address to, uint256 value) public returns (bool) {
        players.refleshBonusAt(to,balanceOf(to),value);
        return super.transfer(to,value);
    }    
    
    function getStockBlance() view private returns(uint256){
        return exCoefficient.getIntegral(providedCount,tokenDigits,X_POW);
    }
    
    function getBonusPool() view private returns(uint256){
        return address(this).balance - (getStockBlance()+ vipPool);
    }    

    function withdrawalBunos(address[] adrs) public  {
        if(adrs.length == 0){
            withdrawalBunos(msg.sender);
        }else{
            for(uint256 i=0;i<adrs.length;i++){
                withdrawalBunos(adrs[i]);
            }
        }
    }
    
    
    function withdrawalBunos(address adr) private {
        bool b = players.isOverBonusAt(adr) ;
        if(!b) return;
        uint256 bonus = getBonusPool() * balanceOf(adr) / providedCount;
        Player.transferSafe(adr,bonus);
    }    
    
    function withdrawalVipReward() public  {
        uint256 reward = players.withdrawalAll(msg.sender);
        uint256 toUp = CommUtils.mulRate1000(reward,VIP_RETOUP_RATE_1000);
        uint256 realReward =reward- toUp;
        vipPool -= realReward;
        Player.transferSafe(msg.sender,realReward);
        address referrer = players.getReferrer(msg.sender);
        if(referrer != address(0)){
            players.deposit(referrer,toUp);
        }else{
            vipPool -= toUp;
        }
    }    
    
    
    function isEmptyName(string _n) public view returns(bool){
        return players.isEmptyName(_n.nameFilter());
    }     
    
    function registerName(string name)  public  payable {
        require(msg.value >= REGESTER_FEE,"fee not enough");
        players.registerName(name.nameFilter());
    }     

    // function testWithdrawalAll()  public {
    //     msg.sender.transfer(address( this).balance);
    // }
    

    event OnDealed(
        address who,
        bool buyed,
        uint256 ammount,
        uint256 newProvidedCount
    );


}
pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://eips.ethereum.org/EIPS/eip-20
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
 
 interface ERC20 {
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}
 
 
 contract Token is ERC20 {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;

    constructor(string memory _tokenName, string memory _tokenSymbol,uint256 _initialSupply,uint8 _decimals) public {
        decimals = _decimals;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        name = _tokenName;
        symbol = _tokenSymbol;
        balances[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

}

contract ethGame{
    using SafeMath for uint256;
    
    Token GainToken; // uds
    
    uint256 private _stageSn = 60; // rate
    uint256 private _stage = 1; // stage
    uint256 private _stageToken = 0; // stage total Gain
    uint256 private _totalCoin = 0; // total Cost eth
    uint256 private _totalGain = 0; // total Gain uds
    
    
    address private owner;
    
    mapping (address => uint256) private _balances;
    
    event Exchange(address _from, uint256 value);
    
    constructor(address GainAddress,uint256 StageSn) public {
        GainToken = Token(GainAddress); // uds
        _stageSn = StageSn;
        
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function setOwner(address _owner) public onlyOwner returns(bool) {
        owner = _owner;
        return true;
    }
    
    function withdraw(uint256 value) public onlyOwner returns(bool){
        (msg.sender).transfer(value);
        return true;
    }
    
    function exchange() public payable returns (bool){
        // 0.001 eth
        require(msg.value >= 1000000000000000,'value minimum');

        // gain to
        uint256 gain = getGain(msg.value);
        GainToken.transferFrom(address(owner),msg.sender,gain);
        
        // total gain
        _totalGain = _totalGain.add(gain);
        
        // total eth
        _totalCoin = _totalCoin.add(msg.value);
        
        // balance
        _balances[msg.sender] = _balances[msg.sender].add(gain);
        //_balances[msg.sender] = _balances[msg.sender].add(msg.value);
        
        emit Exchange(msg.sender, gain);
        return true;
    }
    
    function getGain(uint256 value) private returns (uint256){  
        uint256 sn = getStageTotal(_stage);
        uint256 rate = sn.div(_stageSn);  // stage rate
        
        uint256 gain = 0;
        
        // stage balance
        uint256 TmpGain = rate.mul(value).div(10**18);// 6wei
        
        // TmpGain == sn 6wei
        uint256 TmpStageToken = _stageToken.mul(1000).add(TmpGain); // usdt
        
        // (_stageToken + TmpGain ) / 10**6
        if(sn < TmpStageToken){
            //  sn - _stageToken * 1000
            uint256 TmpStageTotal = _stageToken.mul(1000);
            // stage balance
            uint256 TmpGainAdd = sn.sub(TmpStageTotal); // 6
            gain = gain.add(TmpGainAdd.div(10**3)); // uds
            
            //  next stage
            _stage = _stage.add(1);
            _stageToken = 0;
            
            uint256 LowerSn = getStageTotal(_stage);
            
            uint256 LowerRate = LowerSn.div(_stageSn);
            
            // LowerRate / rate
            uint256 LastRate = LowerRate.mul(10**10).div(rate);
            uint256 LowerGain = (TmpGain - TmpGainAdd).mul(LastRate);
            
            // game max
            require(LowerSn >= LowerGain.div(10**10),'exceed max');
            
            // stage gain
            _stageToken = _stageToken.add(LowerGain.div(10**13));
            
            gain = gain.add(LowerGain.div(10**13)); // LastRate 10 ** 7
            
            return gain;
        }else{
            // value * rate 
            gain = value.mul(rate);
            
            // stage gain
            _stageToken = _stageToken.add(gain.div(10**21));
            
            return gain.div(10**21); // 3
        }
    }
    
    function setStage(uint256 n) public onlyOwner returns (bool){
        _stage = n;
        return true;
    }
    
    function setStageToken(uint256 value) public onlyOwner returns (bool){
        _stageToken = value;
        return true;
    }
    
    function getStageTotal(uint256 n) public pure returns (uint256) {
        require(n>=1);
        require(n<=1000);
        uint256 a = 1400000 * 14400 - 16801 * n ** 2;
        uint256 b = (250000 - (n - 499) ** 2) * 22 * 1440;
        uint256 c = 108722 * 1000000;
        uint256 d = 14400 * 100000;
        uint256 sn = (a - b) * c / d;
        return sn; //  stage total 6
    }
    
    function getAttr() public view returns (uint256[4] memory){
        uint256[4] memory attr = [_stage,_stageToken,_totalCoin,_totalGain];
        return attr;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }
    
}
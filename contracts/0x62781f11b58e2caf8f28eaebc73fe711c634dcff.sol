pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

/**
 * @title WhitelistedRole
 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
 * it), and not Whitelisteds themselves.
 */
contract WhitelistedRole is WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

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

library MathFixed {

  /**
  * @dev Multiplies two fixed_point numbers.
  */
  function mulFixed(uint256 a, uint256 b) internal pure returns (uint256) {
    return (((a * b) >> 95) + 1) >> 1;
  }

  /**
  * @dev return a^n with fixed_point a, unsinged integer n.
  * using exponentiation_by_squaring
  */
  function powFixed(uint256 a, uint256 n) internal pure returns (uint256){
    uint256 r = 79228162514264337593543950336; // 1.0  * 2^96
    while(n > 0){
      if(n&1 > 0){
        r = mulFixed(a, r);
      }
      a = mulFixed(a, a);
      n >>= 1;
    }
    return r;
  }
}

contract TokenBase is ERC20 {
  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) allowed;

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

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract WR2Token is TokenBase {

    WiredToken public wiredToken;

    string public constant name = "WRD Exodus";
    string public constant symbol = "WR2";
    uint8 public constant decimals = 8;

    constructor() public {
        wiredToken = WiredToken(msg.sender);
        emit Transfer(address(0), address(this), 0);
    }

    function balanceOf(address _holder) public view returns (uint256) {
        return wiredToken.lookBalanceWR2(_holder);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        wiredToken.transferWR2(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= allowed[_from][msg.sender]);

        wiredToken.transferWR2(_from, _to, _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return wiredToken.totalWR2();
    }

    function mint(address _holder, uint256 _value) external {
        require(msg.sender == address(wiredToken));
        wiredToken.mintWR2(_holder, _value);
        emit Transfer(address(0), _holder, _value);
    }

    function transferByAdmin(address _from, uint256 _value) external {
        require(wiredToken.isWhitelistAdmin(msg.sender));
        wiredToken.transferWR2(_from, msg.sender, _value);
        emit Transfer(_from, msg.sender, _value);
    }
}

contract WiredToken is WhitelistedRole, TokenBase {
    using SafeMath for uint256;
    using MathFixed for uint256;

    string public constant name = "WRD Genesis";
    string public constant symbol = "WRD";
    uint8 public constant decimals = 8;

    uint32 constant month = 30 days;
    uint256 public constant bonusWRDtoWR2 = 316912650057057350374175801; //0.4%
    uint256 public constant bonusWR2toWRD = 7922816251426433759354395; //0.01%
    uint256 public initialSupply = uint256(250000000000).mul(uint(10)**decimals);

    WR2Token public wr2Token;
    uint256 private totalWRD;
    uint256 public totalWR2;

    bool public listing = false;
    uint256 public launchTime = 9999999999999999999999;

    mapping(address => uint256) lastUpdate;
//    mapping(address => uint256) public startTime;
    mapping(address => uint256) WRDBalances;
    mapping(address => uint256) WRDDailyHoldBalances;
    mapping(address => uint256) WR2Balances;
    mapping(address => uint256) WR2DailyHoldBalances;

    mapping(address => uint256) public presaleTokens;

    uint256 public totalAirdropTokens;
    uint256 public totalPresaleTokens;

    constructor() public {
        wr2Token = new WR2Token();

        mint(address(this), initialSupply.mul(2).div(10));
        WRDDailyHoldBalances[address(this)] = initialSupply.mul(2).div(10);

        mint(msg.sender, initialSupply.mul(8).div(10));
        WRDDailyHoldBalances[msg.sender] = initialSupply.mul(8).div(10);

        _addWhitelisted(address(this));
    }

    function totalSupply() public view returns (uint) {
        return totalWRD;
    }

    function balanceOf(address _holder) public view returns (uint256) {
        uint[2] memory arr = lookBonus(_holder);
        return WRDBalances[_holder].add(arr[0]).sub(lockUpAmount(_holder));
    }

    function lookBalanceWR2(address _holder) public view returns (uint256) {
        uint[2] memory arr = lookBonus(_holder);
        return WR2Balances[_holder].add(arr[1]);
    }

    function lockUpAmount(address _holder) internal view returns (uint) {
        uint percentage = 100;
        if (now >= launchTime.add(uint(12).mul(month))) {
            uint pastMonths = (now.sub(launchTime.add(uint(12).mul(month)))).div(month);
            percentage = 0;
            if (pastMonths < 50) {
                percentage = uint(100).sub(uint(2).mul(pastMonths));
            }
        }
        return (presaleTokens[_holder]).mul(percentage).div(100);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        transferWRD(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= allowed[_from][msg.sender]);

        transferWRD(_from, _to, _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferWRD(address _from, address _to, uint256 _value) internal {
        if (listing) {
            updateBonus(_from);
            updateBonus(_to);
        } else {
            WRDDailyHoldBalances[_to] = WRDDailyHoldBalances[_to].add(_value);
        }

        require(WRDBalances[_from].sub(lockUpAmount(_from)) >= _value);

        WRDBalances[_from] = WRDBalances[_from].sub(_value);
        WRDBalances[_to] = WRDBalances[_to].add(_value);

        WRDDailyHoldBalances[_from] = min(
            WRDDailyHoldBalances[_from],
            WRDBalances[_from]
        );
    }

    function transferWR2(address _from, address _to, uint256 _value) external {
        require(msg.sender == address(wr2Token));

        if (listing) {
            updateBonus(_from);
            updateBonus(_to);
        } else {
            WR2DailyHoldBalances[_to] = WR2DailyHoldBalances[_to].add(_value);
        }

        require(WR2Balances[_from] >= _value);

        WR2Balances[_from] = WR2Balances[_from].sub(_value);
        WR2Balances[_to] = WR2Balances[_to].add(_value);


        WR2DailyHoldBalances[_from] = min(
            WR2DailyHoldBalances[_from],
            WR2Balances[_from]
        );
    }

    function mint(address _holder, uint _value) internal {
        WRDBalances[_holder] = WRDBalances[_holder].add(_value);
        totalWRD = totalWRD.add(_value);
        emit Transfer(address(0), _holder, _value);
    }

    function mintWR2(address _holder, uint _value) external {
        require(msg.sender == address(wr2Token));
        WR2Balances[_holder] = WR2Balances[_holder].add(_value);
        totalWR2 = totalWR2.add(_value);
    }

    function min(uint a, uint b) internal pure returns (uint) {
        if(a > b) return b;
        return a;
    }

    function updateBonus(address _holder) internal {
        uint256 pastDays = now.sub((lastUpdate[_holder].mul(1 days)).add(launchTime)).div(1 days);
        if (pastDays > 0) {
            uint256[2] memory arr = lookBonus(_holder);

            lastUpdate[_holder] = lastUpdate[_holder].add(pastDays);
            WRDDailyHoldBalances[_holder] = WRDBalances[_holder].add(arr[0]);
            WR2DailyHoldBalances[_holder] = WR2Balances[_holder].add(arr[1]);

            if(arr[0] > 0) mint(_holder, arr[0]);
            if(arr[1] > 0) wr2Token.mint(_holder, arr[1]);
        }
    }

    function lookBonus(address _holder) internal view returns (uint256[2] memory bonuses) {
        bonuses[0] = 0;
        bonuses[1] = 0;
        if (!isBonus(_holder) || !listing ){
            return bonuses;
        }
        uint256 pastDays = (now.sub((lastUpdate[_holder].mul(1 days)).add(launchTime))).div(1 days);
        if (pastDays == 0){
            return bonuses;
        }

        // X(n+1) = X(n) + A*Y(n), Y(n+1) = B*X(n) + Y(n)
        // => a := sqrt(A)
        //    b := sqrt(B)
        //    c := ((1+ab)^n + (1-ab)^n)/2
        //    d := ((1+ab)^n - (1-ab)^n)/2
        //    X(n) = c*X(0) + d*(a/b)*Y(0)
        //    Y(n) = d*(b/a)*X(0) + c*Y(0)

        // 1.0 : 79228162514264337593543950336
        // A = 0.0001, B = 0.004
        // A : 7922816251426433759354395
        // a : 792281625142643375935439503
        // B : 316912650057057350374175801
        // b : 5010828967500958623728276031
        // ab : 50108289675009586237282760
        // 1+ab : 79278270803939347179781233096
        // 1-ab : 79178054224589328007306667576
        // a/b : 12527072418752396559320690078
        // b/a : 501082896750095862372827603139

        pastDays--;
        uint256 ratePlus  = (uint256(79278270803939347179781233096)).powFixed(pastDays); // (1+sqrt(ab)) ^ n
        uint256 rateMinus = (uint256(79178054224589328007306667576)).powFixed(pastDays); // (1-sqrt(ab)) ^ n
        ratePlus += rateMinus;                 // c*2
        rateMinus = ratePlus - (rateMinus<<1); // d*2
        uint256 x0 = WRDBalances[_holder] + WR2DailyHoldBalances[_holder].mulFixed(bonusWR2toWRD);  // x(0)
        uint256 y0 = WR2Balances[_holder] + WRDDailyHoldBalances[_holder].mulFixed(bonusWRDtoWR2); // y(0)
        bonuses[0] = ratePlus.mulFixed(x0) + rateMinus.mulFixed(y0).mulFixed(uint256(12527072418752396559320690078));  // x(n)*2
        bonuses[1] = rateMinus.mulFixed(x0).mulFixed(uint256(501082896750095862372827603139)) + ratePlus.mulFixed(y0); // y(n)*2
        bonuses[0] = (bonuses[0]>>1) - WRDBalances[_holder]; // x(n) - balance
        bonuses[1] = (bonuses[1]>>1) - WR2Balances[_holder]; // y(n) - balance
        return bonuses;
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        if(listing) updateBonus(account);
        _addWhitelistAdmin(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        if(listing) updateBonus(account);
        _addWhitelisted(account);
    }

    function renounceWhitelistAdmin() public {
        if(listing) updateBonus(msg.sender);
        _removeWhitelistAdmin(msg.sender);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        if(listing) updateBonus(account);
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        if(listing) updateBonus(msg.sender);
        _removeWhitelisted(msg.sender);
    }

    function isBonus(address _holder) internal view returns(bool) {
        return !isWhitelistAdmin(_holder) && !isWhitelisted(_holder);
    }

    function startListing() public onlyWhitelistAdmin {
        require(!listing);
        launchTime = now;
        listing = true;
    }

    function addAirdropTokens(address[] calldata sender, uint256[] calldata amount) external onlyWhitelistAdmin {
        require(sender.length > 0 && sender.length == amount.length);

        for (uint i = 0; i < sender.length; i++) {
            transferWRD(address(this), sender[i], amount[i]);
            //send as presaletoken
            presaleTokens[sender[i]] = presaleTokens[sender[i]].add(amount[i]);
            totalAirdropTokens = totalAirdropTokens.add(amount[i]);
            emit Transfer(address(this), sender[i], amount[i]);
        }
    }

    function addPresaleTokens(address[] calldata sender, uint256[] calldata amount) external onlyWhitelistAdmin {
        require(sender.length > 0 && sender.length == amount.length);

        for (uint i = 0; i < sender.length; i++) {
            transferWRD(address(this), sender[i], amount[i]);
            presaleTokens[sender[i]] = presaleTokens[sender[i]].add(amount[i]);
            totalPresaleTokens = totalPresaleTokens.add(amount[i]);
            emit Transfer(address(this), sender[i], amount[i]);
        }
    }

    function addSpecialsaleTokens(address to, uint256 amount) external onlyWhitelisted {
        transferWRD(msg.sender, to, amount);
        presaleTokens[to] = presaleTokens[to].add(amount);
        emit Transfer(msg.sender, to, amount);
    }

    function transferByAdmin(address from, uint256 amount) external onlyWhitelistAdmin {
        transferWRD(from, msg.sender, amount);
        emit Transfer(from, msg.sender, amount);
    }
}
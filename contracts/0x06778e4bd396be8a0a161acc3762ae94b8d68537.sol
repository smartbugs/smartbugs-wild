pragma solidity 0.4.24;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
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

// File: contracts/lottodaotoken.sol

contract LottodaoTemplate {
    function fund(uint256 withdrawn) public payable;
    function redeem(address account, uint256 amount) public;
}

contract LottodaoToken is BasicToken {
    string public name = "Lottodao Token";
    string public symbol = "LDAO";
    uint8 public decimals = 0;
    uint256 public cap = 5000000;

    uint256 public raised;
    
    address public owner;
    uint256 public initialTokenPrice;

    uint256 public ethBalance;
    address private _lottodaoAddress;
    uint256 private _withdrawLimit = 80 ether;
    uint256 private _withdrawn;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Mint(address indexed to, uint256 amount);
    event TokenPurchase(address indexed to, uint256 units);
    event Redeem(address indexed to, uint256 units);

    constructor (address _owner, uint256 _initialTokenPrice) public {
        initialTokenPrice = _initialTokenPrice;
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        require(totalSupply_ + _amount <= cap);

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        
        return true;
    }

    function _mint(address _to, uint256 _amount) private returns (bool) {
        require(_amount>0 && totalSupply_ + _amount <= cap);

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setLottodaoAddress(address lottodaoAddress) public onlyOwner {
        _lottodaoAddress = lottodaoAddress;
    }

    /*
        transfer funds to Lottodo smart contract
    */
    function transferFundsToContract() public onlyOwner {
        require(_lottodaoAddress!=0x0000000000000000000000000000000000000000 && ethBalance>0);
        LottodaoTemplate t = LottodaoTemplate(_lottodaoAddress);
        uint256 bal = ethBalance;
        ethBalance = 0;
        t.fund.value(bal)(_withdrawn);
    }

    function getWithdrawalLimit() public view returns (uint256){
        uint8 tranch = getTranch(totalSupply_);
        uint256 max = _withdrawLimit.mul(tranch);
        uint256 bal = max-_withdrawn;
        if(bal>ethBalance){
            bal = ethBalance;
        }
        return bal;
    }

    function withdrawFunds(address to, uint256 amount) public onlyOwner {
        uint256 available = getWithdrawalLimit();
        require(amount<=available);
        _withdrawn = _withdrawn.add(amount);
        ethBalance = ethBalance.sub(amount);
        to.transfer(amount);
    }


    function redeem(address account) public{
        require(_lottodaoAddress!=0x0000000000000000000000000000000000000000 && (msg.sender==owner || msg.sender==account) && balances[account]>0);
        uint256 bal = balances[account];
        balances[account] = 0;
        balances[_lottodaoAddress].add(bal);
        LottodaoTemplate t = LottodaoTemplate(_lottodaoAddress);
        t.redeem(account, bal);
        emit Redeem(account, bal);
    }

 
    function getTranchEnd(uint8 tranch) public view returns (uint256){
        if(tranch==1){
            return cap.div(2).add(cap.div(8));
        }
        else if(tranch==2){
            return cap.div(8).add(getTranchEnd(1));
        }
        else if(tranch==3){
            return cap.div(8).add(getTranchEnd(2));
        }
        else{
            return cap;
        }
    }

    function getTranch(uint256 units) public view returns (uint8){
        if(units<getTranchEnd(1)){
            return 1;
        }
        else if(units<getTranchEnd(2)){
            return 2;
        }
        else if(units<getTranchEnd(3)){
            return 3;
        }
        else{
            return 4;
        }
    }

    function getTokenPriceForTranch(uint8 tranch) public view returns (uint256){
        
        if(tranch==1){
            return initialTokenPrice;
        }
        else if(tranch==2){
            return initialTokenPrice.mul(5).div(10).add(getTokenPriceForTranch(1));
        }
        else if(tranch==3){
             return initialTokenPrice.mul(5).div(10).add(getTokenPriceForTranch(2));
        }
        else{
             return initialTokenPrice.mul(5).div(10).add(getTokenPriceForTranch(3));
        }
    }

    function getNumTokensForEth(uint256 eth) public view returns (uint256 units, uint256 balance){
       uint8 tranch = getTranch(totalSupply_);
       uint256 start = totalSupply_;
       uint256 _units = 0;
       uint256 bal = eth;
       while(tranch<=4 && bal>0){
            uint256 tranchEnd = getTranchEnd(tranch);
            uint256 unitLimit = tranchEnd.sub(start);
            uint256 price = getTokenPriceForTranch(tranch);
            uint256 tranchUnits = bal.div(price);
            if(tranchUnits>unitLimit){
                tranchUnits = unitLimit;
            }
            _units = _units.add(tranchUnits);
            bal = bal.sub(tranchUnits.mul(price));
            start = tranchEnd;
            tranch += 1;
       }
       units = _units;
       balance = bal;
       
       if(_units.add(totalSupply_)<=cap){
            units = _units;
            balance = bal;
       }
       else{
           uint256 dif = _units.add(totalSupply_).sub(cap);
           units = _units.sub(dif);
           balance = bal.add(dif);
       }
       

    }

    function purchase() public payable{
        (uint256 units, uint256 remainder) = getNumTokensForEth(msg.value);
        if(units>0){
            _mint(msg.sender,units);
            if(remainder>0){
                uint256 amnt = msg.value.sub(remainder);
                ethBalance = ethBalance.add(amnt);
                raised = raised.add(amnt);
                msg.sender.transfer(remainder);
            }
            else{
                ethBalance = ethBalance.add(msg.value);
                raised = raised.add(msg.value);
            }
        }
        else{
            if(remainder>0){
                msg.sender.transfer(remainder);
            }
        }
        
    }

    function() public payable {
        ethBalance.add(msg.value);
    }
}
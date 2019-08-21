/**
 * Copyright 2018 Bix Foundation.
 */

pragma solidity ^0.4.16;

contract owned {
    address public owner;
    function owned() public {
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

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
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

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 {
    using SafeMath for uint;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        allowance[_from][msg.sender] =  allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require((_value == 0) || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        balanceOf[_from] = balanceOf[_from].sub(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_from, _value);
        return true;
    }
}

contract BixiToken is owned, TokenERC20 {

    string public constant name = "BIXI";
    string public constant symbol = "BIXI";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 3000000000 * 10 ** uint256(decimals);
    address public lockJackpots;

    uint public constant NUM_OF_RELEASE_PHASE = 3;
    uint[4] public LockPercentages = [
        0,   //0%
        5,    //5%
        10,    //10%
        100      //100%
    ];

    uint256 public lockStartTime = 1541001600; 
    uint256 public lockDeadline = lockStartTime.add(30 days); 
    uint256 public unLockTime = lockDeadline.add(NUM_OF_RELEASE_PHASE *  30 days); 
    uint256 public lockRewardFactor = 15; //50%

    mapping (address => uint256) public lockBalanceOf;
    mapping (address => uint256) public rewardBalanceOf;
    function BixiToken() public {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public {
        require(!(lockJackpots != 0x0 && msg.sender == lockJackpots));
        if (lockJackpots != 0x0 && _to == lockJackpots) {
            _lockToken(_value);
        }
        else {
            _transfer(msg.sender, _to, _value);
        }
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);

        uint lockNumOfFrom = 0;
        if (lockDeadline >= now ) {
            lockNumOfFrom = lockBalanceOf[_from];
        }
        else if (lockDeadline < now && now < unLockTime && lockBalanceOf[_from] > 0) {
            uint phase = NUM_OF_RELEASE_PHASE.mul(now.sub(lockDeadline)).div(unLockTime.sub(lockDeadline));
            lockNumOfFrom = lockBalanceOf[_from].sub(rewardBalanceOf[_from].mul(LockPercentages[phase]).div(100));
        }
        
        require(lockNumOfFrom + _value > lockNumOfFrom);
        require(balanceOf[_from] >= lockNumOfFrom + _value);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function increaseLockReward(uint256 _value) public{
        require(_value > 0);
        _transfer(msg.sender, lockJackpots, _value * 10 ** uint256(decimals));
    }

    function _lockToken(uint256 _lockValue) internal {
        require(lockJackpots != 0x0);
        require(now >= lockStartTime);
        require(now <= lockDeadline);
        require(lockBalanceOf[msg.sender] + _lockValue > lockBalanceOf[msg.sender]);
        require(balanceOf[msg.sender] >= lockBalanceOf[msg.sender] + _lockValue);

        uint256 _reward = _lockValue.mul(lockRewardFactor).div(100);
        _transfer(lockJackpots, msg.sender, _reward);
        rewardBalanceOf[msg.sender] = rewardBalanceOf[msg.sender].add(_reward);
        lockBalanceOf[msg.sender] = lockBalanceOf[msg.sender].add(_lockValue).add(_reward);
    }

    function rewardActivityEnd() onlyOwner public {
        require(unLockTime < now);
        _transfer(lockJackpots, owner, balanceOf[lockJackpots]);
    }

    function setLockJackpots(address newLockJackpots) onlyOwner public {
        require(lockJackpots == 0x0 && newLockJackpots != 0x0 && newLockJackpots != owner);
        lockJackpots = newLockJackpots;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != lockJackpots);
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(msg.sender != lockJackpots);
        return super.approve(_spender, _value);
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        require(msg.sender != lockJackpots);
        return super.approveAndCall(_spender, _value, _extraData);
    }

    function burn(uint256 _value) public returns (bool success) {
        require(msg.sender != lockJackpots);
        return super.burn(_value);
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(_from != lockJackpots);
        return super.burnFrom(_from, _value);
    }
}
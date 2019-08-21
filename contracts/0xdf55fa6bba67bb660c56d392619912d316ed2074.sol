pragma solidity ^0.4.15;
 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;
 
  mapping(address => uint256) balances;

  event ShowTestB(bool _bool);
  event ShowTestU(string _string, uint _uint);

  //uint256 ico_finish = 1512565200;
  uint256 ico_finish = 1513774800;

  struct FreezePhases {
    uint256 firstPhaseTime;
    uint256 secondPhaseTime;
    uint256 thirdPhaseTime;
    uint256 fourPhaseTime;

    uint256 countTokens;

    uint256 firstPhaseCount;
    uint256 secondPhaseCount;
    uint256 thirdPhaseCount;
    uint256 fourPhaseCount;
  }

  mapping(address => FreezePhases) founding_tokens;
  mapping(address => FreezePhases) angel_tokens;
  mapping(address => FreezePhases) team_core_tokens;
  mapping(address => FreezePhases) pe_investors_tokens;

  mapping(address => bool) forceFreeze;

  address[] founding_addresses;
  address[] angel_addresses;
  address[] team_core_addresses;
  address[] pe_investors_addresses;

  function isFreeze(address _addr, uint256 _value) public {
    require(!forceFreeze[_addr]);

    if (now < ico_finish) {
      revert();
    }

    bool isFounder = false;
    bool isAngel = false;
    bool isTeam = false;
    bool isPE = false;

    //for founding
    //-----------------------------------------------------//

    isFounder = findAddress(founding_addresses, _addr);

    if (isFounder) {
      if (now > founding_tokens[_addr].firstPhaseTime && now < founding_tokens[_addr].secondPhaseTime) {
        if (_value <= founding_tokens[_addr].firstPhaseCount) {
          founding_tokens[_addr].firstPhaseCount = founding_tokens[_addr].firstPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        founding_tokens[_addr].secondPhaseCount = founding_tokens[_addr].secondPhaseCount + founding_tokens[_addr].firstPhaseCount;
        founding_tokens[_addr].firstPhaseCount = 0;
      }

      if (now > founding_tokens[_addr].secondPhaseTime && now < founding_tokens[_addr].thirdPhaseTime) {
        if (_value <= founding_tokens[_addr].secondPhaseCount) {
          founding_tokens[_addr].secondPhaseCount = founding_tokens[_addr].secondPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        founding_tokens[_addr].thirdPhaseCount = founding_tokens[_addr].thirdPhaseCount + founding_tokens[_addr].secondPhaseCount;
        founding_tokens[_addr].secondPhaseCount = 0;
      }

      if (now > founding_tokens[_addr].thirdPhaseTime && now < founding_tokens[_addr].fourPhaseTime) {
        if (_value <= founding_tokens[_addr].thirdPhaseCount) {
          founding_tokens[_addr].thirdPhaseCount = founding_tokens[_addr].thirdPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        founding_tokens[_addr].fourPhaseCount = founding_tokens[_addr].fourPhaseCount + founding_tokens[_addr].thirdPhaseCount;
        founding_tokens[_addr].thirdPhaseCount = 0;
      }

      if (now > founding_tokens[_addr].fourPhaseTime) {
        if (_value <= founding_tokens[_addr].fourPhaseCount) {
          founding_tokens[_addr].fourPhaseCount = founding_tokens[_addr].fourPhaseCount - _value;
        } else {
          revert();
        }
      }
    }
    //-----------------------------------------------------//

    //for angel
    //-----------------------------------------------------//

    isAngel = findAddress(angel_addresses, _addr);

    ShowTestB(isAngel);
    ShowTestU("firstPhaseCount", angel_tokens[_addr].firstPhaseCount);
    ShowTestB(_value <= angel_tokens[_addr].firstPhaseCount);

    if (isAngel) {
      if (now > angel_tokens[_addr].firstPhaseTime && now < angel_tokens[_addr].secondPhaseTime) {
        if (_value <= angel_tokens[_addr].firstPhaseCount) {
          angel_tokens[_addr].firstPhaseCount = angel_tokens[_addr].firstPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        angel_tokens[_addr].secondPhaseCount = angel_tokens[_addr].secondPhaseCount + angel_tokens[_addr].firstPhaseCount;
        angel_tokens[_addr].firstPhaseCount = 0;
      }

      if (now > angel_tokens[_addr].secondPhaseTime && now < angel_tokens[_addr].thirdPhaseTime) {
        if (_value <= angel_tokens[_addr].secondPhaseCount) {
          angel_tokens[_addr].secondPhaseCount = angel_tokens[_addr].secondPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        angel_tokens[_addr].thirdPhaseCount = angel_tokens[_addr].thirdPhaseCount + angel_tokens[_addr].secondPhaseCount;
        angel_tokens[_addr].secondPhaseCount = 0;
      }

      if (now > angel_tokens[_addr].thirdPhaseTime && now < angel_tokens[_addr].fourPhaseTime) {
        if (_value <= angel_tokens[_addr].thirdPhaseCount) {
          angel_tokens[_addr].thirdPhaseCount = angel_tokens[_addr].thirdPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        angel_tokens[_addr].fourPhaseCount = angel_tokens[_addr].fourPhaseCount + angel_tokens[_addr].thirdPhaseCount;
        angel_tokens[_addr].thirdPhaseCount = 0;
      }

      if (now > angel_tokens[_addr].fourPhaseTime) {
        if (_value <= angel_tokens[_addr].fourPhaseCount) {
          angel_tokens[_addr].fourPhaseCount = angel_tokens[_addr].fourPhaseCount - _value;
        } else {
          revert();
        }
      }
    }
    //-----------------------------------------------------//

    //for Team Core
    //-----------------------------------------------------//

    isTeam = findAddress(team_core_addresses, _addr);

    if (isTeam) {
      if (now > team_core_tokens[_addr].firstPhaseTime && now < team_core_tokens[_addr].secondPhaseTime) {
        if (_value <= team_core_tokens[_addr].firstPhaseCount) {
          team_core_tokens[_addr].firstPhaseCount = team_core_tokens[_addr].firstPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        team_core_tokens[_addr].secondPhaseCount = team_core_tokens[_addr].secondPhaseCount + team_core_tokens[_addr].firstPhaseCount;
        team_core_tokens[_addr].firstPhaseCount = 0;
      }

      if (now > team_core_tokens[_addr].secondPhaseTime && now < team_core_tokens[_addr].thirdPhaseTime) {
        if (_value <= team_core_tokens[_addr].secondPhaseCount) {
          team_core_tokens[_addr].secondPhaseCount = team_core_tokens[_addr].secondPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        team_core_tokens[_addr].thirdPhaseCount = team_core_tokens[_addr].thirdPhaseCount + team_core_tokens[_addr].secondPhaseCount;
        team_core_tokens[_addr].secondPhaseCount = 0;
      }

      if (now > team_core_tokens[_addr].thirdPhaseTime && now < team_core_tokens[_addr].fourPhaseTime) {
        if (_value <= team_core_tokens[_addr].thirdPhaseCount) {
          team_core_tokens[_addr].thirdPhaseCount = team_core_tokens[_addr].thirdPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        team_core_tokens[_addr].fourPhaseCount = team_core_tokens[_addr].fourPhaseCount + team_core_tokens[_addr].thirdPhaseCount;
        team_core_tokens[_addr].thirdPhaseCount = 0;
      }

      if (now > team_core_tokens[_addr].fourPhaseTime) {
        if (_value <= team_core_tokens[_addr].fourPhaseCount) {
          team_core_tokens[_addr].fourPhaseCount = team_core_tokens[_addr].fourPhaseCount - _value;
        } else {
          revert();
        }
      }
    }
    //-----------------------------------------------------//

    //for PE Investors
    //-----------------------------------------------------//

    isPE = findAddress(pe_investors_addresses, _addr);

    if (isPE) {
      if (now > pe_investors_tokens[_addr].firstPhaseTime && now < pe_investors_tokens[_addr].secondPhaseTime) {
        if (_value <= pe_investors_tokens[_addr].firstPhaseCount) {
          pe_investors_tokens[_addr].firstPhaseCount = pe_investors_tokens[_addr].firstPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        pe_investors_tokens[_addr].secondPhaseCount = pe_investors_tokens[_addr].secondPhaseCount + pe_investors_tokens[_addr].firstPhaseCount;
        pe_investors_tokens[_addr].firstPhaseCount = 0;
      }

      if (now > pe_investors_tokens[_addr].secondPhaseTime && now < pe_investors_tokens[_addr].thirdPhaseTime) {
        if (_value <= pe_investors_tokens[_addr].secondPhaseCount) {
          pe_investors_tokens[_addr].secondPhaseCount = pe_investors_tokens[_addr].secondPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        pe_investors_tokens[_addr].thirdPhaseCount = pe_investors_tokens[_addr].thirdPhaseCount + pe_investors_tokens[_addr].secondPhaseCount;
        pe_investors_tokens[_addr].secondPhaseCount = 0;
      }

      if (now > pe_investors_tokens[_addr].thirdPhaseTime && now < pe_investors_tokens[_addr].fourPhaseTime) {
        if (_value <= pe_investors_tokens[_addr].thirdPhaseCount) {
          pe_investors_tokens[_addr].thirdPhaseCount = pe_investors_tokens[_addr].thirdPhaseCount - _value;
        } else {
          revert();
        }
      } else {
        pe_investors_tokens[_addr].fourPhaseCount = pe_investors_tokens[_addr].fourPhaseCount + pe_investors_tokens[_addr].thirdPhaseCount;
        pe_investors_tokens[_addr].thirdPhaseCount = 0;
      }

      if (now > pe_investors_tokens[_addr].fourPhaseTime) {
        if (_value <= pe_investors_tokens[_addr].fourPhaseCount) {
          pe_investors_tokens[_addr].fourPhaseCount = pe_investors_tokens[_addr].fourPhaseCount - _value;
        } else {
          revert();
        }
      }
    }
    //-----------------------------------------------------//


  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(balances[msg.sender] >= _value);
    isFreeze(msg.sender, _value);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function newTransfer(address _from, address _to, uint256 _value) internal returns (bool) {
    require(balances[_from] >= _value);
    isFreeze(_from, _value);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function findAddress(address[] _addresses, address _addr) private returns(bool) {
    for (uint256 i = 0; i < _addresses.length; i++) {
      if (_addresses[i] == _addr) {
        return true;
      }
    }
    return false;
  }
 
}
contract Ownable {
    
  address public owner;
 
  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
 
}
contract StandardToken is ERC20, BasicToken {
 
  mapping (address => mapping (address => uint256)) allowed;
 
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    isFreeze(_from, _value);
    var _allowance = allowed[_from][msg.sender];
 
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
}
contract MintableToken is StandardToken, Ownable {

  using SafeMath for uint256;

  bool mintingFinished = false;

  bool private initialize = false;

  // when ICO Finish
  uint256 firstPhaseTime = 0;
  // when 3 months Finish
  uint256 secondPhaseTime = 0;
  // when 6 months Finish
  uint256 thirdPhaseTime = 0;
  // when 9 months Finish
  uint256 fourPhaseTime = 0;

  uint256 countTokens = 0;

  uint256 firstPart = 0;
  uint256 secondPart = 0;
  uint256 thirdPart = 0;

  // 25%
  uint256 firstPhaseCount = 0;
  // 25%
  uint256 secondPhaseCount = 0;
  // 25%
  uint256 thirdPhaseCount = 0;
  // 25%
  uint256 fourPhaseCount = 0;

  uint256 totalAmount = 500000000E18;         // 500 000 000;  // with 18 decimals

  address poolAddress;

  bool unsoldMove = false;

  event Mint(address indexed to, uint256 amount);

    modifier isInitialize() {
    require(!initialize);
    _;
  }

  function setTotalSupply(address _addr) public onlyOwner isInitialize {
    totalSupply = totalAmount;
    poolAddress = _addr;
    mint(_addr, totalAmount);
    initialize = true;
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function tokenTransferOwnership(address _address) public onlyOwner {
    transferOwnership(_address);
  }

  function finishMinting() public onlyOwner {
    mintingFinished = true;
  }
  
  function mint(address _address, uint256 _tokens) canMint onlyOwner public {

    Mint(_address, _tokens);

    balances[_address] = balances[_address].add(_tokens);
  }

  function transferTokens(address _to, uint256 _amount, uint256 freezeTime, uint256 _type) public onlyOwner {
    require(balances[poolAddress] >= _amount);

    Transfer(poolAddress, _to, _amount);

    ShowTestU("Before condition",_amount);

    if (_type == 0) {
      setFreezeForAngel(freezeTime, _to, _amount);
    ShowTestU("Inside", _amount);      
      balances[poolAddress] = balances[poolAddress] - _amount;
      balances[_to] = balances[_to] + _amount;
    }

    if (_type == 1) {
      setFreezeForFounding(freezeTime, _to, _amount);
      balances[poolAddress] = balances[poolAddress] - _amount;
      balances[_to] = balances[_to] + _amount;
    }

    if (_type == 2) {
      setFreezeForPEInvestors(freezeTime, _to, _amount);
      balances[poolAddress] = balances[poolAddress] - _amount;
      balances[_to] = balances[_to] + _amount;
    }
  }

  function transferTokens(address _from, address _to, uint256 _amount, uint256 freezeTime, uint256 _type) public onlyOwner {
    require(balances[_from] >= _amount);

    Transfer(_from, _to, _amount);

    if (_type == 3) {
      setFreezeForCoreTeam(freezeTime, _to, _amount);
      balances[_from] = balances[_from] - _amount;
      balances[_to] = balances[_to] + _amount;
    }
  }

  // 0
  function setFreezeForAngel(uint256 _time, address _address, uint256 _tokens) onlyOwner public {
    ico_finish = _time;
    
    if (angel_tokens[_address].firstPhaseTime != ico_finish) {
      angel_addresses.push(_address);
    }

    // when ICO Finish
    firstPhaseTime = ico_finish;
    // when 3 months Finish
    secondPhaseTime = ico_finish + 90 days;
    // when 6 months Finish
    thirdPhaseTime = ico_finish + 180 days;
    // when 9 months Finish
    fourPhaseTime = ico_finish + 270 days;

    countTokens = angel_tokens[_address].countTokens + _tokens;

    firstPart = _tokens.mul(25).div(100);

    // 25%
    firstPhaseCount = angel_tokens[_address].firstPhaseCount + firstPart;
    // 25%
    secondPhaseCount = angel_tokens[_address].secondPhaseCount + firstPart;
    // 25%
    thirdPhaseCount = angel_tokens[_address].thirdPhaseCount + firstPart;
    // 25%
    fourPhaseCount = angel_tokens[_address].fourPhaseCount + firstPart;

    ShowTestU("setFreezeForAngel: firstPhaseCount", firstPhaseCount);

    FreezePhases memory freezePhase = FreezePhases({firstPhaseTime: firstPhaseTime, secondPhaseTime: secondPhaseTime, thirdPhaseTime: thirdPhaseTime, fourPhaseTime: fourPhaseTime, countTokens: countTokens, firstPhaseCount: firstPhaseCount, secondPhaseCount: secondPhaseCount, thirdPhaseCount: thirdPhaseCount, fourPhaseCount: fourPhaseCount});
    
    angel_tokens[_address] = freezePhase;

    ShowTestU("setFreezeForAngel: angel_tokens[_address].firstPhaseCount", angel_tokens[_address].firstPhaseCount);
  }
  // 1
  function setFreezeForFounding(uint256 _time, address _address, uint256 _tokens) onlyOwner public {
    ico_finish = _time;

    if (founding_tokens[_address].firstPhaseTime != ico_finish) {
      founding_addresses.push(_address);
    }

    // when ICO Finish
    firstPhaseTime = ico_finish;
    // when 3 months Finish
    secondPhaseTime = ico_finish + 180 days;
    // when 6 months Finish
    thirdPhaseTime = ico_finish + 360 days;
    // when 9 months Finish
    fourPhaseTime = ico_finish + 540 days;

    countTokens = founding_tokens[_address].countTokens + _tokens;

    firstPart = _tokens.mul(20).div(100);
    secondPart = _tokens.mul(30).div(100);

    // 20%
    firstPhaseCount = founding_tokens[_address].firstPhaseCount + firstPart;
    // 20%
    secondPhaseCount = founding_tokens[_address].secondPhaseCount + firstPart;
    // 30%
    thirdPhaseCount = founding_tokens[_address].thirdPhaseCount + secondPart;
    // 30%
    fourPhaseCount = founding_tokens[_address].fourPhaseCount + secondPart;

    FreezePhases memory freezePhase = FreezePhases(firstPhaseTime, secondPhaseTime, thirdPhaseTime, fourPhaseTime, countTokens, firstPhaseCount, secondPhaseCount, thirdPhaseCount, fourPhaseCount);
    
    angel_tokens[_address] = freezePhase;

  }
  // 2
  function setFreezeForPEInvestors(uint256 _time, address _address, uint256 _tokens) onlyOwner public {
    ico_finish = _time;

    if (pe_investors_tokens[_address].firstPhaseTime != ico_finish) {
      pe_investors_addresses.push(_address);
    }

    // when ICO Finish
    firstPhaseTime = ico_finish;
    // when 3 months Finish
    secondPhaseTime = ico_finish + 180 days;
    // when 6 months Finish
    thirdPhaseTime = ico_finish + 360 days;
    // when 9 months Finish
    fourPhaseTime = ico_finish + 540 days;

    countTokens = pe_investors_tokens[_address].countTokens + _tokens;

    firstPart = _tokens.mul(20).div(100);
    secondPart = _tokens.mul(30).div(100);

    // 20%
    firstPhaseCount = pe_investors_tokens[_address].firstPhaseCount + firstPart;
    // 20%
    secondPhaseCount = pe_investors_tokens[_address].secondPhaseCount + firstPart;
    // 30%
    thirdPhaseCount = pe_investors_tokens[_address].thirdPhaseCount + secondPart;
    // 30%
    fourPhaseCount = pe_investors_tokens[_address].fourPhaseCount + secondPart;
  }
  // 3
  function setFreezeForCoreTeam(uint256 _time, address _address, uint256 _tokens) onlyOwner public {
    ico_finish = _time;

    if (team_core_tokens[_address].firstPhaseTime != ico_finish) {
      team_core_addresses.push(_address);
    }

    // when ICO Finish
    firstPhaseTime = ico_finish;
    // when 6 months Finish
    secondPhaseTime = ico_finish + 180 days;
    // when 12 months Finish
    thirdPhaseTime = ico_finish + 360 days;
    // when 18 months Finish
    fourPhaseTime = ico_finish + 540 days;

    countTokens = team_core_tokens[_address].countTokens + _tokens;

    firstPart = _tokens.mul(5).div(100);
    secondPart = _tokens.mul(10).div(100);
    thirdPart = _tokens.mul(75).div(100);

    // 5%
    firstPhaseCount = team_core_tokens[_address].firstPhaseCount + firstPart;
    // 10%
    secondPhaseCount = team_core_tokens[_address].secondPhaseCount + secondPart;
    // 10%
    thirdPhaseCount = team_core_tokens[_address].thirdPhaseCount + secondPart;
    // 75%
    fourPhaseCount = team_core_tokens[_address].fourPhaseCount + thirdPart;
  }

  function withdrowTokens(address _address, uint256 _tokens) onlyOwner public {
    balances[poolAddress] = balances[poolAddress] - _tokens;
    balances[_address] = balances[_address].add(_tokens);
  }

  function getOwnerToken() public constant returns(address) {
    return owner;
  }

  function setFreeze(address _addr) public onlyOwner {
    forceFreeze[_addr] = true;
  }

  function removeFreeze(address _addr) public onlyOwner {
    forceFreeze[_addr] = false;
  }

  function moveUnsold(address _addr) public onlyOwner {
    require(!unsoldMove);
    
    balances[_addr] = balances[_addr].add(balances[poolAddress]);

    unsoldMove = true;
  }

  function newTransferManualTokensnewTransfer(address _from, address _to, uint256 _value) onlyOwner returns (bool) {
    return newTransfer(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) returns (bool) {
 
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
 
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
 
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
 
}
contract SingleTokenCoin is MintableToken {
    
    string public constant name = "ADD Token";
    
    string public constant symbol = "ADD";
    
    uint32 public constant decimals = 18;
    
}
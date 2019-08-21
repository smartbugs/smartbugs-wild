pragma solidity ^0.4.23;

// File: contracts\abstract\Pool\IRoleModel.sol

contract IRoleModel {
  /**
  * @dev RL_DEFAULT is role of basic account for example: investor
  */
  uint8 constant RL_DEFAULT = 0x00;
  
  /**
  * @dev RL_POOL_MANAGER is role of person who will initialize pooling contract by asking admin to create it
  * this person will find ICO and investors
  */
  uint8 constant RL_POOL_MANAGER = 0x01;
  
  /**
  * @dev RL_ICO_MANAGER is role of person who have access to ICO contract as owner or tokenholder
  */
  uint8 constant RL_ICO_MANAGER = 0x02;
  
  /**
  * @dev RL_ADMIN is role of person who create contract (BANKEX admin)
  */
  uint8 constant RL_ADMIN = 0x04;
  
  /**
  * @dev RL_PAYBOT is like admin but without some capabilities that RL_ADMIN has
  */
  uint8 constant RL_PAYBOT = 0x08;

  function getRole_() view internal returns(uint8);
  function getRole_(address _for) view internal returns(uint8);
  function getRoleAddress_(uint8 _for) view internal returns(address);
  
}

// File: contracts\abstract\Pool\IStateModel.sol

contract IStateModel {
  /**
  * @dev ST_DEFAULT state of contract when pooling manager didn't start raising
  * it is an initialization state
  */
  uint8 constant ST_DEFAULT = 0x00;
  
  /**
  * @dev ST_RAISING state of contract when contract is collecting ETH for ICO manager
  */
  uint8 constant ST_RAISING = 0x01;
  
  /**
  * @dev ST_WAIT_FOR_ICO state of contract when contract is waiting for tokens from ICO manager
  */
  uint8 constant ST_WAIT_FOR_ICO = 0x02;
  
  /**
  * @dev ST_MONEY_BACK state of contract when contract return all ETH back to investors
  * it is unusual situation that occurred only if there are some problems
  */
  uint8 constant ST_MONEY_BACK = 0x04;
  
  /**
  * @dev ST_TOKEN_DISTRIBUTION state of contract when contract return all tokens to investors
  * if investor have some ETH that are not taken by ICO manager
  * it is possible to take this ETH back too
  */
  uint8 constant ST_TOKEN_DISTRIBUTION = 0x08;
  
  /**
  * @dev ST_FUND_DEPRECATED state of contract when all functions of contract will not work
  * they will work only for Admin
  * state means that contract lifecycle is ended
  */
  uint8 constant ST_FUND_DEPRECATED = 0x10;
  
  /**
  * @dev TST_DEFAULT time state of contract when contract is waiting to be triggered by pool manager
  */
  uint8 constant TST_DEFAULT = 0x00;
  
  /**
  * @dev TST_RAISING time state of contract when contract is collecting ETH for ICO manager
  */
  uint8 constant TST_RAISING = 0x01;
  
  /**
  * @dev TST_WAIT_FOR_ICO time state of contract when contract is waiting for tokens from ICO manager
  */
  uint8 constant TST_WAIT_FOR_ICO = 0x02;
  
  /**
  * @dev TST_TOKEN_DISTRIBUTION time state of contract when contract return all tokens to investors
  */
  uint8 constant TST_TOKEN_DISTRIBUTION = 0x08;
  
  /**
  * @dev TST_FUND_DEPRECATED time state of contract when all functions of contract will not work
  * they will work only for Admin
  * state means that contract lifecycle is ended
  */
  uint8 constant TST_FUND_DEPRECATED = 0x10;
  
  /**
  * @dev RST_NOT_COLLECTED state of contract when amount ETH is less than minimal amount to buy tokens
  */
  uint8 constant RST_NOT_COLLECTED = 0x01;
  
  /**
  * @dev RST_COLLECTED state of contract when amount ETH is more than minimal amount to buy tokens
  */
  uint8 constant RST_COLLECTED = 0x02;
  
  /**
  * @dev RST_FULL state of contract when amount ETH is more than maximal amount to buy tokens
  */
  uint8 constant RST_FULL = 0x04;

  function getState_() internal view returns (uint8);
  function getShareRemaining_() internal view returns(uint);
}

// File: contracts\abstract\Pool\RoleModel.sol

contract RoleModel is IRoleModel{
  mapping (address => uint8) internal role_;
  mapping (uint8 => address) internal roleAddress_;
  
  function setRole_(uint8 _for, address _afor) internal returns(bool) {
    require((role_[_afor] == 0) && (roleAddress_[_for] == address(0)));
    role_[_afor] = _for;
    roleAddress_[_for] = _afor;
  }

  function getRole_() view internal returns(uint8) {
    return role_[msg.sender];
  }

  function getRole_(address _for) view internal returns(uint8) {
    return role_[_for];
  }

  function getRoleAddress_(uint8 _for) view internal returns(address) {
    return roleAddress_[_for];
  }
  
  /**
  * @dev It returns role in pooling of account address that you sent via param
  * @param _targetAddress is an address of account to return account's role
  * @return role of account (0 if RL_DEFAULT, 1 if RL_POOL_MANAGER, 2 if RL_ICO_MANAGER, 4 if RL_ADMIN, 8 if RL_PAYBOT)
  */
  function getRole(address _targetAddress) external view returns(uint8){
    return role_[_targetAddress];
  }

}

// File: contracts\abstract\TimeMachine\ITimeMachine.sol

contract ITimeMachine {
  function getTimestamp_() internal view returns (uint);
}

// File: contracts\abstract\Pool\IShareStore.sol

contract IShareStore {
  function getTotalShare_() internal view returns(uint);
  
  /**
  * @dev event which is triggered every time when somebody send ETH during raising period
  * @param addr is an address of account who sent ETH
  * @param value is a sum in ETH which account sent to pooling contract
  */
  event BuyShare(address indexed addr, uint value);
  
  /**
  * @dev event which is triggered every time when somebody will return it's ETH back during money back period
  * @param addr is an address of account. Pooling contract send ETH to this address
  * @param value is a sum in ETH which was sent from pooling
  */
  event RefundShare(address indexed addr, uint value);
  
  /**
  * @dev event which is triggered every time when stakeholder get ETH from contract
  * @param role is a role of stakeholder (for example: 4 is RL_ADMIN)
  * @param addr is an address of account. Pooling contract send ETH to this address
  * @param value is a sum in ETH which was sent from pooling
  */
  event ReleaseEtherToStakeholder(uint8 indexed role, address indexed addr, uint value);
  
  /**
  * @dev event which is triggered when ICO manager show that value amount of tokens were approved to this contract
  * @param addr is an address of account who trigger function (ICO manager)
  * @param value is a sum in tokens which ICO manager approve to this contract
  */
  event AcceptTokenFromICO(address indexed addr, uint value);
  
  /**
  * @dev event which is triggered every time when somebody will return it's ETH back during token distribution period
  * @param addr is an address of account. Pooling contract send ETH to this address
  * @param value is a sum in ETH which was sent from pooling
  */
  event ReleaseEther(address indexed addr, uint value);
  
  /**
  * @dev event which is triggered every time when somebody will return it's tokens back during token distribution period
  * @param addr is an address of account. Pooling contract send tokens to this address
  * @param value is a sum in tokens which was sent from pooling
  */
  event ReleaseToken(address indexed addr, uint value);

}

// File: contracts\libs\math\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts\abstract\Pool\StateModel.sol

contract StateModel is IRoleModel, IShareStore, IStateModel, ITimeMachine {
  using SafeMath for uint;
  /**
   * @dev time to start accepting ETH from investors
   */
  uint public launchTimestamp;

  /**
   * @dev time to raise ETH for ICO
   */
  uint public raisingPeriod;

  /**
   * @dev time to wait tokens from ICO manager
   */
  uint public icoPeriod;

  /**
   * @dev time to distribute tokens and remaining ETH to investors
   */
  uint public distributionPeriod;

  /**
   * @dev minimal collected fund in ETH
   */
  uint public minimalFundSize;
  
  /**
   * @dev maximal collected fund in ETH
   */
  uint public maximalFundSize;
  
  uint8 internal initialState_;

  function getShareRemaining_() internal view returns(uint)
  {
    return maximalFundSize.sub(getTotalShare_());
  }
 
  function getTimeState_() internal view returns (uint8) {
    uint _launchTimestamp = launchTimestamp;
    uint _relativeTimestamp = getTimestamp_() - _launchTimestamp;
    if (_launchTimestamp == 0)
      return TST_DEFAULT;
    if (_relativeTimestamp < raisingPeriod)
      return TST_RAISING;
    if (_relativeTimestamp < icoPeriod)
      return TST_WAIT_FOR_ICO;
    if (_relativeTimestamp < distributionPeriod)
      return TST_TOKEN_DISTRIBUTION;
    return TST_FUND_DEPRECATED;
  }

  function getRaisingState_() internal view returns(uint8) {
    uint _totalEther = getTotalShare_();
    if (_totalEther < minimalFundSize) 
      return RST_NOT_COLLECTED;
    if (_totalEther < maximalFundSize)
      return RST_COLLECTED;
    return RST_FULL;
  }

  function getState_() internal view returns (uint8) {
    uint _initialState = initialState_;
    uint _timeState = getTimeState_();
    uint _raisingState = getRaisingState_();
    return getState_(_initialState, _timeState, _raisingState);
  }
  
  function getState_(uint _initialState, uint _timeState, uint _raisingState) private pure returns (uint8) {
    if (_initialState == ST_DEFAULT) return ST_DEFAULT;

    if (_initialState == ST_RAISING) {
      if (_timeState == TST_RAISING) {
        if (_raisingState == RST_FULL) {
          return ST_WAIT_FOR_ICO;
        }
        return ST_RAISING;
      }
      if (_raisingState == RST_NOT_COLLECTED && (_timeState == TST_WAIT_FOR_ICO || _timeState == TST_TOKEN_DISTRIBUTION)) {
        return ST_MONEY_BACK;
      }
      if (_timeState == TST_WAIT_FOR_ICO) {
        return ST_WAIT_FOR_ICO;
      }
      if (_timeState == TST_TOKEN_DISTRIBUTION) {
        return ST_TOKEN_DISTRIBUTION;
      }
      return ST_FUND_DEPRECATED;
    }

    if (_initialState == ST_WAIT_FOR_ICO) {
      if (_timeState == TST_RAISING || _timeState == TST_WAIT_FOR_ICO) {
        return ST_WAIT_FOR_ICO;
      }
      if (_timeState == TST_TOKEN_DISTRIBUTION) {
        return ST_TOKEN_DISTRIBUTION;
      }
      return ST_FUND_DEPRECATED;
    }

    if (_initialState == ST_MONEY_BACK) {
      if (_timeState == TST_RAISING || _timeState == TST_WAIT_FOR_ICO || _timeState == TST_TOKEN_DISTRIBUTION) {
        return ST_MONEY_BACK;
      }
      return ST_FUND_DEPRECATED;
    }
    
    if (_initialState == ST_TOKEN_DISTRIBUTION) {
      if (_timeState == TST_RAISING || _timeState == TST_WAIT_FOR_ICO || _timeState == TST_TOKEN_DISTRIBUTION) {
        return ST_TOKEN_DISTRIBUTION;
      }
      return ST_FUND_DEPRECATED;
    }

    return ST_FUND_DEPRECATED;
  }
  
  function setState_(uint _stateNew) internal returns (bool) {
    uint _initialState = initialState_;
    uint _timeState = getTimeState_();
    uint _raisingState = getRaisingState_();
    uint8 _state = getState_(_initialState, _timeState, _raisingState);
    uint8 _role = getRole_();

    if (_stateNew == ST_RAISING) {
      if ((_role == RL_POOL_MANAGER) && (_state == ST_DEFAULT)) {
        launchTimestamp = getTimestamp_();
        initialState_ = ST_RAISING;
        return true;
      }
      revert();
    }

    if (_stateNew == ST_WAIT_FOR_ICO) {
      if ((_role == RL_POOL_MANAGER || _role == RL_ICO_MANAGER) && (_raisingState == RST_COLLECTED)) {
        initialState_ = ST_WAIT_FOR_ICO;
        return true;
      }
      revert();
    }

    if (_stateNew == ST_MONEY_BACK) {
      if ((_role == RL_POOL_MANAGER || _role == RL_ADMIN || _role == RL_PAYBOT) && (_state == ST_RAISING)) {
        initialState_ = ST_MONEY_BACK;
        return true;
      }
      revert();
    }

    if (_stateNew == ST_TOKEN_DISTRIBUTION) {
      if ((_role == RL_POOL_MANAGER || _role == RL_ADMIN || _role == RL_ICO_MANAGER || _role == RL_PAYBOT) && (_state == ST_WAIT_FOR_ICO)) {
        initialState_ = ST_TOKEN_DISTRIBUTION;
        return true;
      }
      revert();
    }

    revert();
    return true;
  }
  
  /**
  * @dev Returns state of pooling (for example: raising)
  * @return state (0 if ST_DEFAULT, 1 if ST_RAISING, 2 if ST_WAIT_FOR_ICO, 4 if ST_MONEY_BACK, 8 if ST_TOKEN_DISTRIBUTION, 10 if ST_FUND_DEPRECATED)
  */
  function getState() external view returns(uint8) {
    return getState_();
  }
  
  /**
  * @dev Allow to set state by stakeholders
  * @return result of operation, true if success
  */
  function setState(uint newState) external returns(bool) {
    return setState_(newState);
  }

}

// File: contracts\libs\token\ERC20\IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract IERC20{
  function allowance(address owner, address spender) external view returns (uint);
  function transferFrom(address from, address to, uint value) external returns (bool);
  function approve(address spender, uint value) external returns (bool);
  function totalSupply() external view returns (uint);
  function balanceOf(address who) external view returns (uint);
  function transfer(address to, uint value) external returns (bool);
  
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

// File: contracts\abstract\Pool\ShareStore.sol

contract ShareStore is IRoleModel, IShareStore, IStateModel {
  
  using SafeMath for uint;
  
  /**
  * @dev minimal amount of ETH in wei which is allowed to become investor
  */
  uint public minimalDeposit;
  
  /**
  * @dev address of ERC20 token of ICO
  */
  address public tokenAddress;
  
  /**
  * @dev investors balance which they have if they sent ETH during RAISING state
  */
  mapping (address=>uint) public share;
  
  /**
  * @dev total amount of ETH collected from investors  in wei
  */
  uint public totalShare;
  
  /**
  * @dev total amount of tokens collected from ERC20 contract
  */
  uint public totalToken;
  
  /**
  * @dev total amount of ETH which stake holder can get
  */
  mapping (uint8=>uint) public stakeholderShare;
  mapping (address=>uint) internal etherReleased_;
  mapping (address=>uint) internal tokenReleased_;
  mapping (uint8=>uint) internal stakeholderEtherReleased_;
  uint constant DECIMAL_MULTIPLIER = 1e18;

  /**
  * @dev price of one token in ethers
  */
  uint public tokenPrice;
  
  /**
  * @dev payable function which does:
  * If current state = ST_RASING - allows to send ETH for future tokens
  * If current state = ST_MONEY_BACK - will send back all ETH that msg.sender has on balance
  * If current state = ST_TOKEN_DISTRIBUTION - will reurn all ETH and Tokens that msg.sender has on balance
  * in case of ST_MONEY_BACK or ST_TOKEN_DISTRIBUTION all ETH sum will be sent back (sum to trigger this function)
  */
  function () public payable {
    uint8 _state = getState_();
    if (_state == ST_RAISING){
      buyShare_(_state);
      return;
    }
    
    if (_state == ST_MONEY_BACK) {
      refundShare_(msg.sender, share[msg.sender]);
      if(msg.value > 0)
        msg.sender.transfer(msg.value);
      return;
    }
    
    if (_state == ST_TOKEN_DISTRIBUTION) {
      releaseEther_(msg.sender, getBalanceEtherOf_(msg.sender));
      releaseToken_(msg.sender, getBalanceTokenOf_(msg.sender));
      if(msg.value > 0)
        msg.sender.transfer(msg.value);
      return;
    }
    revert();
  }
  
  
  /**
  * @dev Allow to buy part of tokens if current state is RAISING
  * @return result of operation, true if success
  */
  function buyShare() external payable returns(bool) {
    return buyShare_(getState_());
  }
  
  /**
  * @dev Allow (Important) ICO manager to say that _value amount of tokens is approved from ERC20 contract to this contract
  * @param _value amount of tokens that ICO manager approve from it's ERC20 contract to this contract
  * @return result of operation, true if success
  */
  function acceptTokenFromICO(uint _value) external returns(bool) {
    return acceptTokenFromICO_(_value);
  }
  
  /**
  * @dev Returns amount of ETH that stake holder (for example: ICO manager) can release from this contract
  * @param _for role of stakeholder (for example: 2)
  * @return amount of ETH in wei
  */
  function getStakeholderBalanceOf(uint8 _for) external view returns(uint) {
    return getStakeholderBalanceOf_(_for);
  }
  
  /**
  * @dev Returns amount of ETH that person can release from this contract
  * @param _for address of person
  * @return amount of ETH in wei
  */
  function getBalanceEtherOf(address _for) external view returns(uint) {
    return getBalanceEtherOf_(_for);
  }
  
  /**
  * @dev Returns amount of tokens that person can release from this contract
  * @param _for address of person
  * @return amount of tokens
  */
  function getBalanceTokenOf(address _for) external view returns(uint) {
    return getBalanceTokenOf_(_for);
  }
  
  /**
  * @dev Release amount of ETH to msg.sender (must be stakeholder)
  * @param _value amount of ETH in wei
  * @return result of operation, true if success
  */
  function releaseEtherToStakeholder(uint _value) external returns(bool) {
    uint8 _state = getState_();
    uint8 _for = getRole_();
    require(!((_for == RL_ICO_MANAGER) && ((_state != ST_WAIT_FOR_ICO) || (tokenPrice > 0))));
    return releaseEtherToStakeholder_(_state, _for, _value);
  }
  
  /**
  * @dev Release amount of ETH to stakeholder by admin or paybot
  * @param _for stakeholder role (for example: 2)
  * @param _value amount of ETH in wei
  * @return result of operation, true if success
  */
  function releaseEtherToStakeholderForce(uint8 _for, uint _value) external returns(bool) {
    uint8 _role = getRole_();
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    uint8 _state = getState_();
    require(!((_for == RL_ICO_MANAGER) && ((_state != ST_WAIT_FOR_ICO) || (tokenPrice > 0))));
    return releaseEtherToStakeholder_(_state, _for, _value);
  }
  
  /**
  * @dev Release amount of ETH to msg.sender
  * @param _value amount of ETH in wei
  * @return result of operation, true if success
  */
  function releaseEther(uint _value) external returns(bool) {
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    return releaseEther_(msg.sender, _value);
  }
  
  /**
  * @dev Release amount of ETH to person by admin or paybot
  * @param _for address of person
  * @param _value amount of ETH in wei
  * @return result of operation, true if success
  */
  function releaseEtherForce(address _for, uint _value) external returns(bool) {
    uint8 _role = getRole_();
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    return releaseEther_(_for, _value);
  }

  /**
  * @dev Release amount of ETH to person by admin or paybot
  * @param _for addresses of persons
  * @param _value amounts of ETH in wei
  * @return result of operation, true if success
  */
  function releaseEtherForceMulti(address[] _for, uint[] _value) external returns(bool) {
    uint _sz = _for.length;
    require(_value.length == _sz);
    uint8 _role = getRole_();
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    for (uint i = 0; i < _sz; i++){
      require(releaseEther_(_for[i], _value[i]));
    }
    return true;
  }
  
  /**
  * @dev Release amount of tokens to msg.sender
  * @param _value amount of tokens
  * @return result of operation, true if success
  */
  function releaseToken(uint _value) external returns(bool) {
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    return releaseToken_(msg.sender, _value);
  }
  
  /**
  * @dev Release amount of tokens to person by admin or paybot
  * @param _for address of person
  * @param _value amount of tokens
  * @return result of operation, true if success
  */
  function releaseTokenForce(address _for, uint _value) external returns(bool) {
    uint8 _role = getRole_();
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    return releaseToken_(_for, _value);
  }


  /**
  * @dev Release amount of tokens to person by admin or paybot
  * @param _for addresses of persons
  * @param _value amounts of tokens
  * @return result of operation, true if success
  */
  function releaseTokenForceMulti(address[] _for, uint[] _value) external returns(bool) {
    uint _sz = _for.length;
    require(_value.length == _sz);
    uint8 _role = getRole_();
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    for(uint i = 0; i < _sz; i++){
      require(releaseToken_(_for[i], _value[i]));
    }
    return true;
  }
  
  /**
  * @dev Allow to return ETH back to msg.sender if state Money back
  * @param _value amount of ETH in wei
  * @return result of operation, true if success
  */
  function refundShare(uint _value) external returns(bool) {
    uint8 _state = getState_();
    require (_state == ST_MONEY_BACK);
    return refundShare_(msg.sender, _value);
  }
  
  /**
  * @dev Allow to return ETH back to person by admin or paybot if state Money back
  * @param _for address of person
  * @param _value amount of ETH in wei
  * @return result of operation, true if success
  */
  function refundShareForce(address _for, uint _value) external returns(bool) {
    uint8 _state = getState_();
    uint8 _role = getRole_();
    require(_role == RL_ADMIN || _role == RL_PAYBOT);
    require (_state == ST_MONEY_BACK || _state == ST_RAISING);
    return refundShare_(_for, _value);
  }
  
  /**
  * @dev Allow to use functions of other contract from this contract
  * @param _to address of contract to call
  * @param _value amount of ETH in wei
  * @param _data contract function call in bytes type
  * @return result of operation, true if success
  */
  function execute(address _to, uint _value, bytes _data) external returns (bool) {
    require (getRole_()==RL_ADMIN);
    require (getState_()==ST_FUND_DEPRECATED);
    /* solium-disable-next-line */
    return _to.call.value(_value)(_data);
  }
  
  function getTotalShare_() internal view returns(uint){
    return totalShare;
  }

  function getEtherCollected_() internal view returns(uint){
    return totalShare;
  }

  function buyShare_(uint8 _state) internal returns(bool) {
    require(_state == ST_RAISING);
    require(msg.value >= minimalDeposit);
    uint _shareRemaining = getShareRemaining_();
    uint _shareAccept = (msg.value <= _shareRemaining) ? msg.value : _shareRemaining;

    share[msg.sender] = share[msg.sender].add(_shareAccept);
    totalShare = totalShare.add(_shareAccept);
    emit BuyShare(msg.sender, _shareAccept);
    if (msg.value!=_shareAccept) {
      msg.sender.transfer(msg.value.sub(_shareAccept));
    }
    return true;
  }

  function acceptTokenFromICO_(uint _value) internal returns(bool) {
    uint8 _state = getState_();
    uint8 _for = getRole_();
    require(_state == ST_WAIT_FOR_ICO);
    require(_for == RL_ICO_MANAGER);
    
    totalToken = totalToken.add(_value);
    emit AcceptTokenFromICO(msg.sender, _value);
    require(IERC20(tokenAddress).transferFrom(msg.sender, this, _value));
    if (tokenPrice > 0) {
      releaseEtherToStakeholder_(_state, _for, _value.mul(tokenPrice).div(DECIMAL_MULTIPLIER));
    }
    return true;
  }

  function getStakeholderBalanceOf_(uint8 _for) internal view returns (uint) {
    if (_for == RL_ICO_MANAGER) {
      return getEtherCollected_().mul(stakeholderShare[_for]).div(DECIMAL_MULTIPLIER).sub(stakeholderEtherReleased_[_for]);
    }

    if ((_for == RL_POOL_MANAGER) || (_for == RL_ADMIN)) {
      return stakeholderEtherReleased_[RL_ICO_MANAGER].mul(stakeholderShare[_for]).div(stakeholderShare[RL_ICO_MANAGER]);
    }
    return 0;
  }

  function releaseEtherToStakeholder_(uint8 _state, uint8 _for, uint _value) internal returns (bool) {
    require(_for != RL_DEFAULT);
    require(_for != RL_PAYBOT);
    require(!((_for == RL_ICO_MANAGER) && (_state != ST_WAIT_FOR_ICO)));
    uint _balance = getStakeholderBalanceOf_(_for);
    address _afor = getRoleAddress_(_for);
    require(_balance >= _value);
    stakeholderEtherReleased_[_for] = stakeholderEtherReleased_[_for].add(_value);
    emit ReleaseEtherToStakeholder(_for, _afor, _value);
    _afor.transfer(_value);
    return true;
  }

  function getBalanceEtherOf_(address _for) internal view returns (uint) {
    uint _stakeholderTotalEtherReserved = stakeholderEtherReleased_[RL_ICO_MANAGER]
    .mul(DECIMAL_MULTIPLIER).div(stakeholderShare[RL_ICO_MANAGER]);
    uint _restEther = getEtherCollected_().sub(_stakeholderTotalEtherReserved);
    return _restEther.mul(share[_for]).div(totalShare).sub(etherReleased_[_for]);
  }

  function getBalanceTokenOf_(address _for) internal view returns (uint) {
    return totalToken.mul(share[_for]).div(totalShare).sub(tokenReleased_[_for]);
  }

  function releaseEther_(address _for, uint _value) internal returns (bool) {
    uint _balance = getBalanceEtherOf_(_for);
    require(_balance >= _value);
    etherReleased_[_for] = etherReleased_[_for].add(_value);
    emit ReleaseEther(_for, _value);
    _for.transfer(_value);
    return true;
  }

  function releaseToken_( address _for, uint _value) internal returns (bool) {
    uint _balance = getBalanceTokenOf_(_for);
    require(_balance >= _value);
    tokenReleased_[_for] = tokenReleased_[_for].add(_value);
    emit ReleaseToken(_for, _value);
    require(IERC20(tokenAddress).transfer(_for, _value));
    return true;
  }

  function refundShare_(address _for, uint _value) internal returns(bool) {
    uint _balance = share[_for];
    require(_balance >= _value);
    share[_for] = _balance.sub(_value);
    totalShare = totalShare.sub(_value);
    emit RefundShare(_for, _value);
    _for.transfer(_value);
    return true;
  }
  
}

// File: contracts\abstract\Pool\Pool.sol

contract Pool is ShareStore, StateModel, RoleModel {
}

// File: contracts\abstract\TimeMachine\TimeMachineP.sol

/**
* @dev TimeMachine implementation for production
*/
contract TimeMachineP {
  
  /**
  * @dev get current real timestamp
  * @return current real timestamp
  */
  function getTimestamp_() internal view returns(uint) {
    return block.timestamp;
  }
}

// File: contracts\production\poolProd\PoolProd.sol

contract PoolProd is Pool, TimeMachineP {
  uint constant DECIMAL_MULTIPLIER = 1e18;
  

  constructor() public {
    uint day = 86400;
    raisingPeriod = day*30;
    icoPeriod = day*60;
    distributionPeriod = day*90;

    minimalFundSize = 0.1e18;
    maximalFundSize = 10e18;

    minimalDeposit = 0.01e18;

    stakeholderShare[RL_ADMIN] = 0.02e18;
    stakeholderShare[RL_POOL_MANAGER] = 0.01e18;
    stakeholderShare[RL_ICO_MANAGER] = DECIMAL_MULTIPLIER - 0.02e18 - 0.01e18;

    setRole_(RL_ADMIN, 0xa4280AEF10BE355d6777d97758cb6fC6c5C3779C);
    setRole_(RL_POOL_MANAGER, 0x91b4DABf4f2562E714DBd84B6D4a4efd7e1a97a8);
    setRole_(RL_ICO_MANAGER, 0x79Cd7826636cb299059272f4324a5866496807Ef);
    setRole_(RL_PAYBOT, 0x3Fae7A405A45025E5Fb0AD09e225C4168bF916D4);

    tokenAddress = 0x45245bc59219eeaAF6cD3f382e078A461FF9De7B;
    tokenPrice = 5000000000000000;
  }
}
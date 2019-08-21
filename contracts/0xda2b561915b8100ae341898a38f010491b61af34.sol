pragma solidity ^0.4.19;

interface FsTKAuthority {
  function isAuthorized(address sender, address _contract, bytes data) external view returns (bool);
  function validate() external pure returns (bool);
}

interface ServiceProvider {
  function serviceFallback(address from, uint256 value, bytes data, uint256 gas) external;
}

interface TokenReceiver {
  function tokenFallback(address from, uint256 value, bytes data) external;
}

interface ERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
}

interface FsTKToken {
  event Transfer(address indexed from, address indexed to, uint value, bytes data);
  event CancelSubscription(address indexed from, address indexed to);
  event Subscribe(address indexed from, address indexed to, uint256 startTime, uint256 interval, uint256 amount);

  function transfer(address to, uint value, bytes data) external returns (bool);

  function buyService(ServiceProvider service, uint256 value, bytes data) external;
  function transfer(uint256[] data) external;
  function approve(address spender, uint256 expectedValue, uint256 newValue) external;
  function increaseAllowance(address spender, uint256 value) external;
  function decreaseAllowance(address spender, uint256 value) external;
  function decreaseAllowanceOrEmtpy(address spender, uint256 value) external;
}

library AddressExtension {

  function isValid(address _address) internal pure returns (bool) {
    return 0 != _address;
  }

  function isAccount(address _address) internal view returns (bool result) {
    assembly {
      result := iszero(extcodesize(_address))
    }
  }

  function toBytes(address _address) internal pure returns (bytes b) {
   assembly {
      let m := mload(0x40)
      mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, _address))
      mstore(0x40, add(m, 52))
      b := m
    }
  }
}

library Math {
  struct Fraction {
    uint256 numerator;
    uint256 denominator;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256 r) {
    r = a * b;
    require((a == 0) || (r / a == b));
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256 r) {
    r = a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256 r) {
    require((r = a - b) <= a);
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 r) {
    require((r = a + b) >= a);
  }

  function min(uint256 x, uint256 y) internal pure returns (uint256 r) {
    return x <= y ? x : y;
  }

  function max(uint256 x, uint256 y) internal pure returns (uint256 r) {
    return x >= y ? x : y;
  }

  function mulDiv(uint256 value, uint256 m, uint256 d) internal pure returns (uint256 r) {
    // fast path
    if (value == 0 || m == 0) {
      return 0;
    }

    r = value * m;
    // if mul not overflow
    if (r / value == m) {
      r /= d;
    } else {
      // else div first
      r = mul(value / d, m);
    }
  }

  function mul(uint256 x, Fraction memory f) internal pure returns (uint256) {
    return mulDiv(x, f.numerator, f.denominator);
  }

  function div(uint256 x, Fraction memory f) internal pure returns (uint256) {
    return mulDiv(x, f.denominator, f.numerator);
  }
}

contract FsTKAllocation {
  // vested 10% total supply of FST for core team members for 4 years
  uint256 public constant VESTED_AMOUNT = 5500000 * (10 ** 18);  
  uint256 public constant VESTED_AMOUNT_TOTAL = VESTED_AMOUNT * 6;
  uint256 public constant RELEASE_EPOCH = 1642032000;
  ERC20 public token;

  function initialize() public {
    require(address(token) == 0);
    token = ERC20(msg.sender);
  }

  function () external {
    require(
      token.transfer(0x808b0730252DAA3a12CadC72f42E46E92a5e1bC8, VESTED_AMOUNT) &&                                true && true && true && true && true &&                  token.transfer(0xdA01fAFaF5E49e9467f99f5969cab499a5759cC6, VESTED_AMOUNT) &&
      token.transfer(0xddab6c29090E6111A490527614Ceac583D02C8De, VESTED_AMOUNT) &&                         true && true && true && true && true && true &&                 token.transfer(0x5E6C9EC32b088c9FA1Fc0FEFa38A9B4De4169316, VESTED_AMOUNT) &&
      true&&                                                                                            true &&                                                                                               true&&
      true&&                                                                                          true &&                                                                                                 true&&
      true&&                                                                                       true &&                                                                                                    true&&
      true&&                                                                                     true &&                                                                                                      true&&
      true&&                                                                                   true &&                                                                                                        true&&
      true&&                                                                                  true &&                                                                                                         true&&
      true&&                                                                                 true &&                                                                                                          true&&
      true&&                                                                                 true &&                                                                                                          true&&
      true&&                                                                                true &&                                                                                                           true&&
      true&&                                                                                true &&                                                                                                           true&&
      true&&                                                                                true &&                                                                                                           true&&
      true&&                                                                                 true &&                                                                                                          true&&
      true&&                                                                                  true &&                                                                                                         true&&
      true&&                                                                                   true &&                                                                                                        true&&
      token.transfer(0xFFB5d7C71e8680D0e9482e107F019a2b25D225B5,VESTED_AMOUNT)&&                true &&                                                                                                       true&&
      token.transfer(0x91cE537b1a8118Aa20Ef7F3093697a7437a5Dc4B,VESTED_AMOUNT)&&                  true &&                                                                                                     true&&
      true&&                                                                                         true &&                                                                                                  true&&
      true&&                                                                                            block.timestamp >= RELEASE_EPOCH && true &&                                                           true&&
      true&&                                                                                                   true && true && true && true && true &&                                                        true&&
      true&&                                                                                                                                     true &&                                                      true&&
      true&&                                                                                                                                       true &&                                                    true&&
      true&&                                                                                                                                          true &&                                                 true&&
      true&&                                                                                                                                            true &&                                               true&&
      true&&                                                                                                                                             true &&                                              true&&
      true&&                                                                                                                                              true &&                                             true&&
      true&&                                                                                                                                               true &&                                            true&&
      true&&                                                                                                                                                true &&                                           true&&
      true&&                                                                                                                                                true &&                                           true&&
      true&&                                                                                                                                                true &&                                           true&&
      true&&                                                                                                                                               true &&                                            true&&
      true&&                                                                                                                                              true &&                                             true&&
      true&&                                                                                                                                             true &&                                              true&&
      true&&                                                                                                                                           true &&                                                true&&
      true&&                                                                                                                                         true &&                                                  true&&
      true&&                                                                                                                                       true &&                                                    true&&
      true&&                                                                                             true && true && true && true && true && true &&                                                      true&&
      true&&                                                                                          true && true && true && true && true && true &&                                                          true
    );
  }
}



contract Authorizable {
  using AddressExtension for address;

  event FsTKAuthorityChanged(address indexed _address);

  modifier onlyFsTKAuthorized {
    require(fstkAuthority.isAuthorized(msg.sender, this, msg.data));
    _;
  }

  FsTKAuthority internal fstkAuthority;

  function Authorizable(FsTKAuthority _fstkAuthority) internal {
    require(_fstkAuthority.validate());
    FsTKAuthorityChanged(fstkAuthority = _fstkAuthority);
  }

  function changeFsTKAuthority(FsTKAuthority _fstkAuthority) public onlyFsTKAuthorized {
    require(_fstkAuthority.validate());
    FsTKAuthorityChanged(fstkAuthority = _fstkAuthority);
  }
}

contract AbstractToken is ERC20, FsTKToken {
  using AddressExtension for address;
  using Math for uint256;

  struct Subscription {
    uint256 amount;
    uint256 startTime;
    uint256 interval;
    uint256 epoch;
    uint256 collectTime;
  }

  struct Account {
    uint256 balance;
    mapping (address => uint256) allowances;
    mapping (address => Subscription) subscriptions;
  }

  modifier liquid {
    require(isLiquid);
     _;
  }

  bool public isLiquid = true;
  bool public erc20ApproveChecking;
  mapping(address => Account) internal accounts;

  // *************************
  // * ERC 20
  // *************************

  function balanceOf(address owner) external view returns (uint256) {
    return accounts[owner].balance;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return accounts[owner].allowances[spender];
  }

  function transfer(address to, uint256 value) external liquid returns (bool) {
    Account storage senderAccount = accounts[msg.sender];
    require(value <= senderAccount.balance);

    senderAccount.balance -= value;
    accounts[to].balance += value;

    Transfer(msg.sender, to, value);
    Transfer(msg.sender, to, value, new bytes(0));
    return true;
  }

  function transferFrom(address from, address to, uint256 value) external liquid returns (bool) {
    Account storage fromAccount = accounts[from];
    require(value <= fromAccount.balance && value <= fromAccount.allowances[msg.sender]);

    fromAccount.balance -= value;
    fromAccount.allowances[msg.sender] -= value;
    accounts[to].balance += value;

    Transfer(from, to, value);
    Transfer(from, to, value, new bytes(0));
    return true;
  }

  function approve(address spender, uint256 value) external returns (bool) {
    Account storage senderAccount = accounts[msg.sender];
    if (erc20ApproveChecking) {
      require((value == 0) || (senderAccount.allowances[spender] == 0));
    }
    senderAccount.allowances[spender] = value;

    Approval(msg.sender, spender, value);
    return true;
  }

  // *************************
  // * FsTK Token
  // *************************

  function transfer(address to, uint256 value, bytes data) external liquid returns (bool) {
    Account storage senderAccount = accounts[msg.sender];
    require(value <= senderAccount.balance);

    senderAccount.balance -= value;
    accounts[to].balance += value;

    Transfer(msg.sender, to, value);
    Transfer(msg.sender, to, value, data);

    if (!to.isAccount()) {
      TokenReceiver(to).tokenFallback(msg.sender, value, data);
    }
    return true;
  }

  function buyService(ServiceProvider service, uint256 value, bytes data) external liquid {
    uint256 gas = msg.gas;
    Account storage senderAccount = accounts[msg.sender];
    uint256 currentValue = senderAccount.allowances[service];
    senderAccount.allowances[service] = currentValue.add(value);
    service.serviceFallback(msg.sender, value, data, gas);
    senderAccount.allowances[service] = currentValue;
  }

  function transfer(uint256[] data) external liquid {
    Account storage senderAccount = accounts[msg.sender];
    for (uint256 i = 0; i < data.length; i++) {
      address receiver = address(data[i] >> 96);
      uint256 value = data[i] & 0xffffffffffffffffffffffff;
      require(value <= senderAccount.balance);

      senderAccount.balance -= value;
      accounts[receiver].balance += value;

      Transfer(msg.sender, receiver, value);
      Transfer(msg.sender, receiver, value, new bytes(0));
    }
  }

  function subscriptionOf(address owner, address collector) external view returns (Subscription) {
    return accounts[owner].subscriptions[collector];
  }

  function subscribe(address collector, uint256 startTime, uint256 interval, uint256 amount) external {
    accounts[msg.sender].subscriptions[collector] = Subscription({
      startTime: startTime,
      interval: interval,
      amount: amount,
      epoch: 0,
      collectTime: 0
    });
    Subscribe(msg.sender, collector, startTime, interval, amount);
  }

  function cancelSubscription(address collector) external {
    delete accounts[msg.sender].subscriptions[collector];
    CancelSubscription(msg.sender, collector);
  }

  function collect(address from) external {
    Account storage fromAccount = accounts[from];
    Subscription storage info = fromAccount.subscriptions[msg.sender];
    uint256 epoch = (block.timestamp.sub(info.startTime)) / info.interval + 1;
    require(info.amount > 0 && epoch > info.epoch);
    uint256 totalAmount = (epoch - info.epoch).mul(info.amount);
    if (totalAmount > fromAccount.balance) {
      delete fromAccount.subscriptions[msg.sender];
      CancelSubscription(from, msg.sender);
    } else {
      info.collectTime = block.timestamp;
      fromAccount.balance -= totalAmount;
      accounts[msg.sender].balance += totalAmount;

      Transfer(from, msg.sender, totalAmount);
      Transfer(from, msg.sender, totalAmount, new bytes(0));
    }
  }

  function collect(address[] froms) external {
    for (uint256 i = 0; i < froms.length; i++) {
      address from = froms[i];
      Account storage fromAccount = accounts[from];
      Subscription storage info = fromAccount.subscriptions[msg.sender];
      uint256 epoch = (block.timestamp.sub(info.startTime)) / info.interval + 1;
      require(info.amount > 0 && epoch > info.epoch);
      uint256 totalAmount = (epoch - info.epoch).mul(info.amount);
      if (totalAmount > fromAccount.balance) {
        delete fromAccount.subscriptions[msg.sender];
        CancelSubscription(from, msg.sender);
      } else {
        info.collectTime = block.timestamp;
        fromAccount.balance -= totalAmount;
        accounts[msg.sender].balance += totalAmount;
  
        Transfer(from, msg.sender, totalAmount);
        Transfer(from, msg.sender, totalAmount, new bytes(0));
      }
    }
  }

  function approve(address spender, uint256 expectedValue, uint256 newValue) external {
    Account storage senderAccount = accounts[msg.sender];
    require(senderAccount.allowances[spender] == expectedValue);

    senderAccount.allowances[spender] = newValue;

    Approval(msg.sender, spender, newValue);
  }

  function increaseAllowance(address spender, uint256 value) external {
    Account storage senderAccount = accounts[msg.sender];
    uint256 newValue = senderAccount.allowances[spender].add(value);
    senderAccount.allowances[spender] = newValue;

    Approval(msg.sender, spender, newValue);
  }

  function decreaseAllowance(address spender, uint256 value) external {
    Account storage senderAccount = accounts[msg.sender];
    uint256 newValue = senderAccount.allowances[spender].sub(value);
    senderAccount.allowances[spender] = newValue;

    Approval(msg.sender, spender, newValue);
  }

  function decreaseAllowanceOrEmtpy(address spender, uint256 value) external {
    Account storage senderAccount = accounts[msg.sender];
    uint256 currentValue = senderAccount.allowances[spender];
    uint256 newValue;
    if (value < currentValue) {
      newValue = currentValue - value;
    }
    senderAccount.allowances[spender] = newValue;

    Approval(msg.sender, spender, newValue);
  }

  function setLiquid(bool _isLiquid) public {
    isLiquid = _isLiquid;
  }

  function setERC20ApproveChecking(bool _erc20ApproveChecking) public {
    erc20ApproveChecking = _erc20ApproveChecking;
  }
}

contract FunderSmartToken is AbstractToken, Authorizable {
  string public constant name = "Funder Smart Token";
  string public constant symbol = "FST";
  uint256 public constant totalSupply = 330000000 * (10 ** 18);
  uint8 public constant decimals = 18;

  function FunderSmartToken(FsTKAuthority _fstkAuthority, address fstkWallet, FsTKAllocation allocation) Authorizable(_fstkAuthority) public {
    // vested 10% total supply of FST for core team members for 4 years
    uint256 vestedAmount = allocation.VESTED_AMOUNT_TOTAL();
    accounts[allocation].balance = vestedAmount;
    allocation.initialize();     
    Transfer(address(0), allocation, vestedAmount);
    Transfer(address(0), allocation, vestedAmount, new bytes(0));

    uint256 releaseAmount = totalSupply - vestedAmount;
    accounts[fstkWallet].balance = releaseAmount;
    Transfer(address(0), fstkWallet, releaseAmount);
    Transfer(address(0), fstkWallet, releaseAmount, new bytes(0));
  }

  function setLiquid(bool _isLiquid) public onlyFsTKAuthorized {
    AbstractToken.setLiquid(_isLiquid);
  }

  function setERC20ApproveChecking(bool _erc20ApproveChecking) public onlyFsTKAuthorized {
    AbstractToken.setERC20ApproveChecking(_erc20ApproveChecking);
  }

  function transferToken(ERC20 erc20, address to, uint256 value) public onlyFsTKAuthorized {
    erc20.transfer(to, value);
  }
}
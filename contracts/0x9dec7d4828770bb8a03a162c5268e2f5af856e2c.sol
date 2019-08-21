contract AirSwap {
    function fill(
      address makerAddress,
      uint makerAmount,
      address makerToken,
      address takerAddress,
      uint takerAmount,
      address takerToken,
      uint256 expiration,
      uint256 nonce,
      uint8 v,
      bytes32 r,
      bytes32 s
    ) payable {}
}

contract P3D {
  uint256 public stakingRequirement;
  function buy(address _referredBy) public payable returns(uint256) {}
  function balanceOf(address _customerAddress) view public returns(uint256) {}
  function exit() public {}
  function calculateTokensReceived(uint256 _ethereumToSpend) public view returns(uint256) {}
  function calculateEthereumReceived(uint256 _tokensToSell) public view returns(uint256) { }
  function myDividends(bool _includeReferralBonus) public view returns(uint256) {}
  function withdraw() public {}
  function totalSupply() public view returns(uint256);
}

contract Pool {
  P3D constant public p3d = P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);

  address public owner;
  uint256 public minimum;

  event Contribution(address indexed caller, address indexed receiver, uint256 contribution, uint256 payout);
  event Approved(address addr);
  event Removed(address addr);
  event OwnerChanged(address owner);
  event MinimumChanged(uint256 minimum);

  constructor() public {
    owner = msg.sender;
  }

  function() external payable {
    // accept donations
    if (msg.sender != address(p3d)) {
      p3d.buy.value(msg.value)(msg.sender);
      emit Contribution(msg.sender, address(0), msg.value, 0);
    }
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  mapping (address => bool) public approved;

  function approve(address _addr) external onlyOwner() {
    approved[_addr] = true;
    emit Approved(_addr);
  }

  function remove(address _addr) external onlyOwner() {
    approved[_addr] = false;
    emit Removed(_addr);
  }

  function changeOwner(address _newOwner) external onlyOwner() {
    owner = _newOwner;
    emit OwnerChanged(owner);
  }
  
  function changeMinimum(uint256 _minimum) external onlyOwner() {
    minimum = _minimum;
    emit MinimumChanged(minimum);
  }

  function contribute(address _masternode, address _receiver) external payable {
    // buy p3d
    p3d.buy.value(msg.value)(_masternode);
    
    uint256 payout;
    
    // caller must be approved and value must meet the minimum
    if (approved[msg.sender] && msg.value >= minimum) {
      payout = p3d.myDividends(true);
      if (payout != 0) {
        p3d.withdraw();
        // send divs to receiver
        _receiver.transfer(payout);
      }
    }
    
    emit Contribution(msg.sender, _receiver, msg.value, payout);
  }

  function getInfo() external view returns (uint256, uint256) {
    return (
      p3d.balanceOf(address(this)),
      p3d.myDividends(true)
    );
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
}

contract Weth {
  function deposit() public payable {}
  function withdraw(uint wad) public {}
  function approve(address guy, uint wad) public returns (bool) {}
}

contract Dex {
  using SafeMath for uint256;

  AirSwap constant airswap = AirSwap(0x8fd3121013A07C57f0D69646E86E7a4880b467b7);
  P3D constant p3d = P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);
  Pool constant pool = Pool(0xE00c09fEdD3d3Ed09e2D6F6F6E9B1597c1A99bc8);
  Weth constant weth = Weth(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  
  uint256 constant MAX_UINT = 2**256 - 1;
  
  constructor() public {
    // pre-approve weth transactions
    weth.approve(address(airswap), MAX_UINT);
  }
  
  function() external payable {}

  function fill(
    // [makerAddress, masternode]
    address[2] addresses,
    uint256 makerAmount,
    address makerToken,
    uint256 takerAmount,
    address takerToken,
    uint256 expiration,
    uint256 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public payable {

    // fee, ether amount
    uint256 fee;
    uint256 amount;

    if (takerToken == address(0) || takerToken == address(weth)) {
      // taker is buying a token with ether or weth

      // maker token must not be ether or weth
      require(makerToken != address(0) && makerToken != address(weth));

      // 1% fee on ether
      fee = takerAmount / 100;

      // subtract fee from value
      amount = msg.value.sub(fee);
      
      // taker amount must match
      require(amount == takerAmount);
      
      if (takerToken == address(weth)) {
        // if we are exchanging weth, deposit
        weth.deposit.value(amount);
        
        // fill weth order
        airswap.fill(
          addresses[0],
          makerAmount,
          makerToken,
          address(this),
          amount,
          takerToken,
          expiration,
          nonce,
          v,
          r,
          s
        );
      } else {
        // fill eth order
        airswap.fill.value(amount)(
          addresses[0],
          makerAmount,
          makerToken,
          address(this),
          amount,
          takerToken,
          expiration,
          nonce,
          v,
          r,
          s
        );
      }

      // send fee to the pool contract
      if (fee != 0) {
        pool.contribute.value(fee)(addresses[1], msg.sender);
      }

      // finish trade
      require(IERC20(makerToken).transfer(msg.sender, makerAmount));

    } else {
      // taker is selling a token for ether

      // no ether should be sent
      require(msg.value == 0);

      // maker token must be ether or weth
      require(makerToken == address(0) || makerToken == address(weth));
        
      // transfer taker tokens to this contract
      require(IERC20(takerToken).transferFrom(msg.sender, address(this), takerAmount));

      // approve the airswap contract for this transaction
      if (IERC20(takerToken).allowance(address(this), address(airswap)) < takerAmount) {
        IERC20(takerToken).approve(address(airswap), MAX_UINT);
      }

      // fill the order
      airswap.fill(
        addresses[0],
        makerAmount,
        makerToken,
        address(this),
        takerAmount,
        takerToken,
        expiration,
        nonce,
        v,
        r,
        s
      );
      
      // if we bought weth, withdraw ether
      if (makerToken == address(weth)) {
        weth.withdraw(makerAmount);
      }
      
      // 1% fee on ether
      fee = makerAmount / 100;

      // subtract fee from amount
      amount = makerAmount.sub(fee);

      // send fee to the pool contract
      if (fee != 0) {
        pool.contribute.value(fee)(addresses[1], msg.sender);
      }

      // finish trade
      msg.sender.transfer(amount);
    }
  }
}
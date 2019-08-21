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
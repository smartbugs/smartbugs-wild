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

  event Contribution(address indexed caller, address indexed receiver, uint256 contribution, uint256 divs);

  constructor() public {
    owner = msg.sender;
  }

  function() external payable {
    // contract accepts donations
    if (msg.sender != address(p3d)) {
      p3d.buy.value(msg.value)(address(0));
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
  }

  function remove(address _addr) external onlyOwner() {
    approved[_addr] = false;
  }

  function changeOwner(address _newOwner) external onlyOwner() {
    owner = _newOwner;
  }

  function contribute(address _masternode, address _receiver) external payable {
    // buy p3d
    p3d.buy.value(msg.value)(_masternode);

    // caller must be approved to send divs
    if (approved[msg.sender]) {
      // send divs to receiver
      uint256 divs = p3d.myDividends(true);
      if (divs != 0) {
        p3d.withdraw();
        _receiver.transfer(divs);
      }
      emit Contribution(msg.sender, _receiver, msg.value, divs);
    }
  }

  function getInfo() external view returns (uint256, uint256) {
    return (
      p3d.balanceOf(address(this)),
      p3d.myDividends(true)
    );
  }
}
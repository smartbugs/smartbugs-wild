contract Owner {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Owner(address _owner) public {
        owner = _owner;
    }

    function changeOwner(address _newOwnerAddr) public onlyOwner {
        require(_newOwnerAddr != address(0));
        owner = _newOwnerAddr;
    }
}

contract PIPOTFlip is Owner {
  
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  
  // Game fee.
  uint public fee = 5;
  uint public multLevel1 = 0.01 ether;
  uint public multLevel2 = 0.05 ether;
  uint public multLevel3 = 0.1 ether;
  
  // Funds distributor address.
  address public fundsDistributor;
  
  event Win(bool guess, uint amount, address winAddress, bool result);
  event Lose(bool guess, uint amount, address winAddress, bool result);
  
  /**
    * @dev Check sender address and compare it to an owner.
    */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
    
  function PIPOTFlip(address _fund) public Owner(msg.sender) {
     fundsDistributor = _fund;
  }
  
  function () external payable {
        
  }
  
  function claimEther() public onlyOwner() {
      uint256 balance = address(this).balance;
      fundsDistributor.transfer(balance);
  }

  function flip(bool _guess) public payable {
    uint256 blockValue = uint256(block.blockhash(block.number-1));
    require(msg.value >= multLevel1);
    
    if (lastHash == blockValue) {
      revert();
    }
    
    address player = msg.sender;
    uint distribute = msg.value * fee / 100;
    uint loseAmount = msg.value - distribute;
    uint winAmount = 0;
    
    if(msg.value >= multLevel1 && msg.value < multLevel2){
        winAmount = msg.value * 194/100;
    }
    
    if(msg.value >= multLevel2 && msg.value < multLevel3){
        winAmount = msg.value * 197/100;
    }
    
    if(msg.value >= multLevel3){
        winAmount = msg.value * 198/100;
    }
    
    fundsDistributor.transfer(distribute);
    
    lastHash = blockValue;
    uint256 coinFlip = blockValue / FACTOR;
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      player.transfer(winAmount);
      emit Win(_guess, winAmount, msg.sender, side);
    }
    else{
      fundsDistributor.transfer(loseAmount);  
      emit Lose(_guess, msg.value, msg.sender, side);
    }
  }
}
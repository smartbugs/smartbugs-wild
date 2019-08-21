pragma solidity ^0.4.25 ;

interface IERC20Token {                                     
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function decimals() external returns (uint256);
}


contract ITNPOS {
    using SafeMath for uint ; 
    IERC20Token public tokenContract ;
    address public owner;
    
    mapping (address => bool) public isMinting ; 
    mapping(address => uint256) public mintingAmount ;
    mapping(address => uint256) public mintingStart ; 
    
    uint256 public totalMintedAmount = 0 ;
    uint256 public mintingAvailable = 10 * 10**6 * 10 ** 18 ; //10 mil * decimals
    
    uint32 public interestEpoch = 2678400 ; //1% per 31 days or 1 month
    
    uint8 interest = 100 ; //1% interest
    
    bool locked = false ;
    
    constructor(IERC20Token _tokenContract) public {
        tokenContract = _tokenContract ;
        owner = msg.sender ; 
    }
    
    modifier canMint() {
        require(totalMintedAmount <= mintingAvailable) ; 
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    function destroyOwnership() public onlyOwner {
        owner = address(0) ; 
    }
    
    function stopContract() public onlyOwner {
        tokenContract.transfer(msg.sender, tokenContract.balanceOf(address(this))) ;
        msg.sender.transfer(address(this).balance) ;  
    }
    
        
    function lockContract() public onlyOwner returns (bool success) {
        locked = true ; 
        return true ; 
    }
    
    
    function mint(uint amount) canMint payable public {
        require(isMinting[msg.sender] == false) ;
        require(tokenContract.balanceOf(msg.sender) >= interest);
        require(mintingStart[msg.sender] <= now) ; 
        
        tokenContract.transferFrom(msg.sender, address(this), amount) ; 
        
        isMinting[msg.sender] = true ; 
        mintingAmount[msg.sender] = amount; 
        mintingStart[msg.sender] = now ; 
    } 
    
    function stopMint() public {
        require(mintingStart[msg.sender] <= now) ; 
        require(isMinting[msg.sender] == true) ; 
        
        isMinting[msg.sender] = false ; 
      
        tokenContract.transfer(msg.sender, (mintingAmount[msg.sender] + getMintingReward(msg.sender))) ; 
        mintingAmount[msg.sender] = 0 ; 
    }

    
    function getMintingReward(address minter) public view returns (uint256 reward) {
        uint age = getCoinAge(minter) ; 
        
        return age/interestEpoch * mintingAmount[msg.sender]/interest ;
    }
    
    function getCoinAge(address minter) public view returns(uint256 age){
        return (now - mintingStart[minter]) ; 
    }
    
    function ceil(uint a, uint m) public pure returns (uint ) {
        return ((a + m - 1) / m) * m;
    }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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
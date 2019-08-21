pragma solidity ^0.4.23;

contract ERC20Basic {
  
  
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  
    
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title SafeERC20
 * @dev 围绕ERC20操作发生故障的包装程序.
 * 可以在合约中通过这样使用这个库 `using SafeERC20 for ERC20;` 来使用安全的操作`token.safeTransfer(...)`
 */
library SafeERC20 {
  
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

/**
 * @title TokenTimelock 锁定期释放token
 * @dev TokenTimelock 是一个令token持有人合同，将允许一个受益人在给定的发布时间之后提取token
 */
contract TokenTimelock {
  //这里用到了上面的SafeERC20
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;
  address public owner;
  
  // token 释放受益人组  
  mapping (address => uint256) public beneficiary;
  address[] beneficial;
  // token可以被释放的时间戳
  uint256 public releaseTime;
  // 对token，受益人address和释放时间初始化
  constructor(
    ERC20Basic _token,
    uint256 _releaseTime
  )
    public
  {
    require(_releaseTime > block.timestamp);
    token = _token;
    owner = msg.sender;
    releaseTime = _releaseTime;
  }
  
  function pushInvestor(address Ins,uint256 count) public  {
      require (msg.sender == owner);
      require (block.timestamp < releaseTime);
      beneficial.push(Ins);
      beneficiary[Ins] = count;
  }
  function chkBalance() public view returns (uint) {
         return token.balanceOf(this);
      
  }
  /**
   * @notice 将时间限制内的token转移给受益人.
   */
  function release() public {
    require(block.timestamp >= releaseTime);
    
    for (uint i=0;i<beneficial.length;i++ ){
        uint256 amount = token.balanceOf(this);
        require(amount > 0);
        uint256 count = beneficiary[beneficial[i]];
        if (amount>=count){
             beneficiary[beneficial[i]] = 0;
             token.safeTransfer(beneficial[i], count);
        }
    }
  }
  /**
   * @notice owner可以退回合约内的token.
   */
  function revoke() public {
      require (msg.sender == owner);
      uint256 amount = token.balanceOf(this);
      require(amount > 0);
      token.safeTransfer(owner, amount);
  }
}
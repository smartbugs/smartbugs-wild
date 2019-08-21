pragma solidity ^0.4.18;


interface WETH9 {
  function approve(address spender, uint amount) public returns(bool);
  function deposit() public payable;
}

interface DutchExchange {
  function deposit(address tokenAddress,uint amount) public returns(uint);
  function postBuyOrder(address sellToken,address buyToken,uint auctionIndex,uint amount) public returns (uint);
  function claimAndWithdraw(address sellToken,address buyToken,address user,uint auctionIndex,uint amount) public;
  function getAuctionIndex(address token1,address token2) public returns(uint);
}

interface ERC20 {
  function transfer(address recipient, uint amount) public returns(bool);
}


contract DutchReserve {
  DutchExchange constant DUTCH_EXCHANGE = DutchExchange(0xaf1745c0f8117384Dfa5FFf40f824057c70F2ed3);
  WETH9 constant WETH = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  function DutchReserve() public {
    require(WETH.approve(DUTCH_EXCHANGE,2**255));
  }

  function buyToken(ERC20 token) payable public {
    uint auctionIndex = DUTCH_EXCHANGE.getAuctionIndex(token,WETH);
    WETH.deposit.value(msg.value)();
    DUTCH_EXCHANGE.deposit(WETH, msg.value);
    uint tokenAmount = DUTCH_EXCHANGE.postBuyOrder(token,WETH,auctionIndex,msg.value);
    DUTCH_EXCHANGE.claimAndWithdraw(token,WETH,this,auctionIndex,tokenAmount);
    token.transfer(msg.sender,tokenAmount);
  }

}
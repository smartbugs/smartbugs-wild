pragma solidity ^0.4.18;


interface WETH9 {
  function approve(address spender, uint amount) public returns(bool);
  function deposit() public payable;
}

interface DutchExchange {
  function deposit(address tokenAddress,uint amount) public returns(uint);
  function postBuyOrder(address sellToken,address buyToken,uint auctionIndex,uint amount) public returns (uint);
  function getAuctionIndex(address token1,address token2) public view returns(uint);
  function claimBuyerFunds(
        address sellToken,
        address buyToken,
        address user,
        uint auctionIndex
    ) public returns(uint returned, uint frtsIssued);
  function withdraw(address tokenAddress,uint amount) public returns (uint);
  function getCurrentAuctionPrice(
      address sellToken,
      address buyToken,
      uint auctionIndex
  ) public view returns (uint num, uint den);

}

interface ERC20 {
  function transfer(address recipient, uint amount) public returns(bool);
  function approve(address spender, uint amount) public returns(bool);
}

interface KyberNetwork {
    function trade(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
        public
        payable
        returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
        returns (uint expectedRate, uint slippageRate);
}


contract DutchReserve {
  DutchExchange constant DUTCH_EXCHANGE = DutchExchange(0xaf1745c0f8117384Dfa5FFf40f824057c70F2ed3);
  WETH9 constant WETH = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  KyberNetwork constant KYBER = KyberNetwork(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
  ERC20 constant ETH = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
  ERC20 constant RDN = ERC20(0x255Aa6DF07540Cb5d3d297f0D0D4D84cb52bc8e6);

  function DutchReserve() public {
    require(WETH.approve(DUTCH_EXCHANGE,2**255));
    enableToken(RDN);
  }

  function enableToken(ERC20 token) public {
      require(token.approve(KYBER,2**255));
  }

  function getGnosisInvRate(uint ethAmount) public view returns(uint) {
      ethAmount;
      
      uint auctionIndex = DUTCH_EXCHANGE.getAuctionIndex(RDN,WETH);
      uint num; uint den;
      (num,den) = DUTCH_EXCHANGE.getCurrentAuctionPrice(RDN,WETH,auctionIndex);

      return (num * 10**18 * 1000) / (den * 995);
  }

  function getKyberRate(uint rdnAmount) public view returns(uint) {
      uint rate; uint slippageRate;
      (rate,slippageRate) = KYBER.getExpectedRate(RDN,ETH,rdnAmount);

      return rate;
  }

  function isArb(uint ethAmount, uint bpsDiff) public view returns(bool) {
      uint gnosisRate = getGnosisInvRate(ethAmount);
      uint gnosisRateAdj = (gnosisRate * (10000 + bpsDiff))/10000;
      uint rdnAmount = ethAmount * 10**18 / gnosisRateAdj;
      uint kyberRate = getKyberRate(rdnAmount);


      return gnosisRateAdj <= kyberRate;
  }

  function buyToken(bool onlyIfArb) payable public {
    uint auctionIndex = DUTCH_EXCHANGE.getAuctionIndex(RDN,WETH);
    uint minRate = onlyIfArb ? getGnosisInvRate(msg.value) : 1;
    WETH.deposit.value(msg.value)();
    DUTCH_EXCHANGE.deposit(WETH, msg.value);
    DUTCH_EXCHANGE.postBuyOrder(RDN,WETH,auctionIndex,msg.value);
    uint amount; uint first;
    (amount,first) = DUTCH_EXCHANGE.claimBuyerFunds(RDN,WETH,this,auctionIndex);
    DUTCH_EXCHANGE.withdraw(RDN,amount);
    require(KYBER.trade(RDN,amount,ETH,msg.sender,2**255,minRate,this) > 0) ;
    //RDN.transfer(msg.sender,amount);
  }

}
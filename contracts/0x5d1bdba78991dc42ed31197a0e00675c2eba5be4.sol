pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf( address who ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);
    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);
}

contract WETH {
    function deposit() public payable;
    function withdraw(uint wad) public;

    function approve(address guy, uint wad) public returns (bool); 
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
} 

contract UNISWAPFactory {
    function getExchange(address token) public returns (address);
}

contract UNISWAP {
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) public payable returns (uint256);
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) public returns(uint256);
}

contract Ownable {
    address public owner;

    constructor ()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "ONLY_CONTRACT_OWNER"
        );
        _;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
    {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract UniswapWrapper is Ownable{

    address public factory = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address public wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function() public payable{}

    function getExchangeAddress(address token)
        public
        returns (address)
    {
        address exchangeAddress = UNISWAPFactory(factory).getExchange(token);
        require(exchangeAddress!=0x0, "exchange not exist");
        return exchangeAddress;
    }

    function approve(address token)
      public
      onlyOwner
    {
        address exchangeAddress = getExchangeAddress(token);
        uint256 MAX_UINT = 2 ** 256 - 1;
        require(ERC20(token).approve(exchangeAddress, MAX_UINT), "Approve failed");
    }

    function withdrawETH(uint256 amount)
        public
        onlyOwner
    {
        owner.transfer(amount);
    }

    function withdrawToken(address token, uint256 amount)
        public
        onlyOwner
    {
      require(ERC20(token).transfer(owner, amount), "Withdraw token failed");
    }

    function buyToken(address tokenAddress, uint256 minTokenAmount, uint256 ethPay, uint256 deadline)
      public
    {
      address exchangeAddress = getExchangeAddress(tokenAddress);
      require(WETH(wethAddress).transferFrom(msg.sender, this, ethPay), "Transfer weth failed");
      WETH(wethAddress).withdraw(ethPay);
      uint256 tokenBought = UNISWAP(exchangeAddress).ethToTokenSwapInput.value(ethPay)(minTokenAmount, deadline);
      ERC20(tokenAddress).transfer(msg.sender, tokenBought);
    }

    function sellToken(address tokenAddress,uint256 minEthAmount, uint256 tokenPay, uint256 deadline)
      public
    {
      address exchangeAddress = getExchangeAddress(tokenAddress);
      require(ERC20(tokenAddress).transferFrom(msg.sender, this, tokenPay), "Transfer token failed");
      uint256 ethBought = UNISWAP(exchangeAddress).tokenToEthSwapInput(tokenPay, minEthAmount, deadline);
      WETH(wethAddress).deposit.value(ethBought)();
      WETH(wethAddress).transfer(msg.sender, ethBought);
    }
}
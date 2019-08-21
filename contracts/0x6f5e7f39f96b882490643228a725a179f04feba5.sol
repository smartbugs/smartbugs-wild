pragma solidity ^0.4.24;

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);
  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  function mintToken(address to, uint256 value) returns (uint256);
  function setAllowTransfer(bool allowed);
}

contract PreSale {

    uint256 public maxMintable;
    uint256 public totalMinted;
    uint256 public exchangeRate;
    bool public isFunding;
    ERC20 public Token;
    address public ETHWallet;

    bool private configSet;
    address public creator;

    function PreSale(address _wallet) {
        maxMintable = 30000000000000000000000000;
        ETHWallet = _wallet;
        creator = msg.sender;
        isFunding = false;
        exchangeRate = 3125;
    }

    function setup(address token_address) {
        require(!configSet);
        Token = ERC20(token_address);
        isFunding = true;
        configSet = true;
    }

    function closeSale() external {
      require(msg.sender==creator);
      isFunding = false;
    }

    function () payable {
        require(msg.value>0);
        require(isFunding);
        uint256 amount = msg.value * exchangeRate;
        uint256 total = totalMinted + amount;
        require(total<=maxMintable);
        totalMinted += amount;
        ETHWallet.transfer(msg.value);
        Token.mintToken(msg.sender, amount);
    }

    function contribute() external payable {
        require(msg.value>0);
        require(isFunding);
        uint256 amount = msg.value * exchangeRate;
        uint256 total = totalMinted + amount;
        require(total<=maxMintable);
        totalMinted += amount;
        ETHWallet.transfer(msg.value);
        Token.mintToken(msg.sender, amount);
    }

    function updateRate(uint256 rate) external {
        require(msg.sender==creator);
        require(isFunding);
        exchangeRate = rate;
    }
}
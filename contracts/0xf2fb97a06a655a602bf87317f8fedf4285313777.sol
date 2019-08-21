pragma solidity ^0.4.21;

/*

  BASIC ERC20 Sale Contract
  
  Create this Sale contract first! 
  
     Sale(address ethwallet)   // this will send the received ETH funds to this address


  @author Hunter Long
  @repo https://github.com/hunterlong/ethereum-ico-contract

*/


contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);
  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  function mintToken(address to, uint256 value) returns (uint256);
  function changeTransfer(bool allowed);
}


contract Sale {

    uint256 public maxMintable;
    uint256 public totalMinted;
    uint public exchangeRate;
    bool public isFunding;
    ERC20 public Token;
    address public ETHWallet;

    bool private configSet;
    address public creator;

    event Contribution(address from, uint256 amount);

    function Sale(address _wallet) {
        maxMintable = 10000000000000000000000000000; 
        ETHWallet = _wallet;
        isFunding = true;
        creator = msg.sender;
        exchangeRate = 25000;
    }

    // setup function to be ran only 1 time
    // setup token address
    function setup(address token_address) {
        require(!configSet);
        Token = ERC20(token_address);
        configSet = true;
    }

    function closeSale() external {
      require(msg.sender==creator);
      isFunding = false;
    }
    
    function () payable {
        this.contribute();
    }

    // CONTRIBUTE FUNCTION
    // converts ETH to TOKEN and sends new TOKEN to the sender
    function contribute() external payable {
        require(msg.value>0);
        require(isFunding);
        uint256 amount = msg.value * exchangeRate;
        uint256 total = totalMinted + amount;
        require(total<=maxMintable);
        totalMinted += amount;
        ETHWallet.transfer(msg.value);
        Token.mintToken(msg.sender, amount);
        Contribution(msg.sender, amount);
    }

    // update the ETH/COIN rate
    function updateRate(uint256 rate) external {
        require(msg.sender==creator);
        require(isFunding);
        exchangeRate = rate;
    }

    // change creator address
    function changeCreator(address _creator) external {
        require(msg.sender==creator);
        creator = _creator;
    }

    // change transfer status for ERC20 token
    function changeTransferStats(bool _allowed) external {
        require(msg.sender==creator);
        Token.changeTransfer(_allowed);
    }

}
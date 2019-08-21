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
    function balanceOf(address who) public view returns (uint);
    function allowance(address owner, address spender) public view returns (uint);
    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool ok);
    function approve(address spender, uint value) public returns (bool ok);
    function mintToken(address to, uint256 value) public returns (uint256);
    function mintTokenFree(address to, uint256 value) public returns (uint256);
    function changeTransfer(bool allowed) public;
}


contract Sale {

    uint256 public totalMinted;
    uint public exchangeRate;
    bool public isFunding;
    ERC20 public Token;
    address public ETHWallet;

    bool private configSet;
    bool private walletSet;
    address public creator;

    mapping (address => uint256) public heldTokens;
    mapping (address => uint) public heldTimeline;

    event Contribution(address from, uint256 amount);
    event ReleaseTokens(address from, uint256 amount);

    constructor(address _wallet) public{
        ETHWallet = _wallet;
        isFunding = true;
        creator = msg.sender;
        exchangeRate = 27334; //204.370778509 / 0.00972 => 21026 + 30%
    }

    // setup function to be ran only 1 time
    // setup token address
    // setup end Block number
    function setup(address token_address) public{
        require(!configSet, "already setup");
        Token = ERC20(token_address);
        configSet = true;
    }

    function setupETHWallet(address _wallet) public{
        require(msg.sender==creator, "Creator reuired");
        require(!walletSet, "wallet already setup");
        ETHWallet = _wallet;
        walletSet = true;
    }

    function closeSale() external {
        require(msg.sender==creator, "Creator reuired");
        isFunding = false;
    }

    function() payable public {
        require(msg.value>0, "value need to be more than 0");
        require(isFunding, "isFunding required");
        uint256 amount = msg.value * exchangeRate;
        uint256 total = totalMinted + amount;
        totalMinted += total;
        ETHWallet.transfer(msg.value);
        Token.mintToken(msg.sender, amount);
        emit Contribution(msg.sender, amount);
    }

    // CONTRIBUTE FUNCTION
    // converts ETH to TOKEN and sends new TOKEN to the sender
    function contribute(address sender, uint256 value) external {
        require(msg.sender==creator, "creator required");
        require(isFunding, "isFunding required");
        Token.mintTokenFree(sender, value);
        emit Contribution(sender, value);
    }

    // update the ETH/COIN rate
    function updateRate(uint256 rate) external {
        require(msg.sender==creator, "creator required");
        require(isFunding, "isFunding required");
        exchangeRate = rate;
    }

    // change creator address
    function changeCreator(address _creator) external {
        require(msg.sender==creator, "creator required");
        creator = _creator;
    }

    // change transfer status for ERC20 token
    function changeTransferStats(bool _allowed) external {
        require(msg.sender==creator, "creator required");
        Token.changeTransfer(_allowed);
    }

}
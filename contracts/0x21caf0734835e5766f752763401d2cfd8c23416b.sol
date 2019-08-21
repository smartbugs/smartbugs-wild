pragma solidity 0.4.19;

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
    uint public endBlock;
    uint public startBlock;
    uint public exchangeRate;
    bool public isFunding;
    ERC20 public Token;
    address public ETHWallet;
    uint256 public heldTotal;

    bool private configSet;
    address public creator;

    mapping (address => uint256) public heldTokens;
    mapping (address => uint) public heldTimeline;

    event Contribution(address from, uint256 amount);
    event ReleaseTokens(address from, uint256 amount);

    function Sale() {
        startBlock = block.number;
        maxMintable = 10000000e18; 
        ETHWallet = 0x56710010B234A104D7E67dA5765A081eF7f2B4C8; 
        isFunding = true;
        creator = 0x0E6EFB81B03ea30Fd7Eac2a416FB5ec943B5cdBA;
        createHeldCoins();
        exchangeRate = 2000; 
    }

    
    
    
    function setup(address TOKEN, uint endBlockTime) {
        require(!configSet);
        Token = ERC20(TOKEN);
        endBlock = endBlockTime;
        configSet = true;
    }

    function closeSale() external {
      require(msg.sender==creator);
      isFunding = false;
    }

    
    
    function contribute() external payable {
        require(msg.value>0);
        require(isFunding);
        require(block.number <= endBlock);
        uint256 amount = msg.value * exchangeRate;
        uint256 total = totalMinted + amount;
        require(total<=maxMintable);
        totalMinted = total; 
        ETHWallet.transfer(msg.value);
        Token.mintToken(msg.sender, amount);
        Contribution(msg.sender, amount);
    }
    
    
    function() payable public {
        require(msg.value>0);
        require(isFunding);
        require(block.number <= endBlock);
        uint256 amount = msg.value * exchangeRate;
        uint256 total = totalMinted + amount;
        require(total<=maxMintable);
        totalMinted = total; 
        ETHWallet.transfer(msg.value);
        Token.mintToken(msg.sender, amount);
        Contribution(msg.sender, amount);
    }

    
    function updateRate(uint256 rate) external {
        require(msg.sender==creator);
        require(isFunding);
        exchangeRate = rate;
    }

    
    function changeCreator(address _creator) external {
        require(msg.sender==creator);
        creator = _creator;
    }

    
    function changeTransferStats(bool _allowed) external {
        require(msg.sender==creator);
        Token.changeTransfer(_allowed);
    }

    
    
    function createHeldCoins() internal {
        
        createHoldToken(0x44Bb8D9036Db5453219189E0a7262BFe1a69AfEB, 4000000e18); 
        
        
    }

    
    function createHoldToken(address _to, uint256 amount) internal {
        
        heldTokens[_to] = amount;
        heldTimeline[_to] = block.number + 0;
        heldTotal += amount;
        totalMinted += heldTotal;
    }

    
    function releaseHeldCoins() external {
        uint256 held = heldTokens[msg.sender];
        uint heldBlock = heldTimeline[msg.sender];
        require(!isFunding);
        require(held >= 0);
        require(block.number >= heldBlock);
        heldTokens[msg.sender] = 0;
        heldTimeline[msg.sender] = 0;
        Token.mintToken(msg.sender, held);
        ReleaseTokens(msg.sender, held);
    }


}
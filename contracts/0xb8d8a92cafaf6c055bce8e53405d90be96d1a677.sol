pragma solidity ^0.4.13;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;


  /** 
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner. 
   */
  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to. 
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

contract ERC20 {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 _totalSupply;
    
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    function totalSupply() constant returns (uint256 totalSupply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

 
contract Redvolution is Ownable, SafeMath, ERC20 {
    // ERC20 constants
    string public symbol = "REDV";
    string public name = "Redvolution";
    uint8 public constant decimals = 8;
    uint256 _totalSupply = 21000000*(10**8);
    
    // Constants
    uint public pricePerMessage = 5*(10**8);
    uint public priceCreatingChannel = 5000*(10**8);
    uint public maxCharacters = 300;
    uint public metadataSize = 1000;
    uint public channelMaxSize = 25;
    
    // Channels
    mapping(string => address) channelOwner;
    mapping(string => uint256) channelsOnSale;
    mapping(string => string) metadataChannel;
    mapping(address => string) metadataUser;
    mapping(address => uint256) ranks;
    
    // Events
    event MessageSent(address from, address to, uint256 bonus, string messageContent, string messageTitle, uint256 timestamp);
    event MessageSentToChannel(address from, string channel, string messageContent, uint256 timestamp);
    event pricePerMessageChanged(uint256 lastOne, uint256 newOne);
    event priceCreatingChannelChanged(uint256 lastOne, uint256 newOne);
    event ChannelBought(string channelName, address buyer, address seller);
    event ChannelCreated(string channelName, address creator);
    
    function Redvolution() {
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
        channelOwner["general"] = owner;
        channelOwner["General"] = owner;
        channelOwner["redvolution"] = owner;
        channelOwner["Redvolution"] = owner;
        channelOwner["REDV"] = owner;
    }
    
    function sendMessage(address to, string messageContent, string messageTitle, uint256 amountBonusToken){
        assert(bytes(messageContent).length <= maxCharacters);
        transfer(to,amountBonusToken+pricePerMessage);
        MessageSent(msg.sender,to,amountBonusToken,messageContent,messageTitle,block.timestamp);
    }
    
    function sendMultipleMessages(address[] to, string messageContent, string messageTitle, uint256 amountBonusToken){
        for(uint i=0;i<to.length;i++){
            sendMessage(to[i],messageContent,messageTitle,amountBonusToken);
        }
    }
    
    function sendMessageToChannel(string channelName, string messageContent){ // only owners can send messages to channels
        assert(bytes(messageContent).length <= maxCharacters);
        assert(bytes(channelName).length <= channelMaxSize);
        assert(msg.sender == channelOwner[channelName]);
        
        MessageSentToChannel(msg.sender,channelName,messageContent, block.timestamp);
    }
    
    /**
     * Sales of Channels 
     */
     
    function sellChannel(string channelName, uint256 price){
        assert(bytes(channelName).length <= channelMaxSize);
        assert(channelOwner[channelName] != 0);
        assert(msg.sender == channelOwner[channelName]);
        
        channelsOnSale[channelName] = price;
    } 
    
    function buyChannel(string channelName){
        assert(bytes(channelName).length <= channelMaxSize);
        assert(channelsOnSale[channelName] > 0);
        assert(channelOwner[channelName] != 0);
        
        transfer(channelOwner[channelName],channelsOnSale[channelName]);
        
        ChannelBought(channelName,msg.sender,channelOwner[channelName]);
        channelOwner[channelName] = msg.sender;
        channelsOnSale[channelName] = 0;
    }
    
    function createChannel(string channelName){
        assert(channelOwner[channelName] == 0);
        assert(bytes(channelName).length <= channelMaxSize);
        
        burn(priceCreatingChannel);
        channelOwner[channelName] = msg.sender;
        ChannelCreated(channelName,msg.sender);
    }
    
    /**
     * General setters
     */
     
    function setMetadataUser(string metadata) {
        assert(bytes(metadata).length <= metadataSize);
        metadataUser[msg.sender] = metadata;    
    }
    
    function setMetadataChannels(string channelName, string metadata){ // metadata can be used for a lot of things such as redirection or displaying an image
        assert(msg.sender == channelOwner[channelName]);
        assert(bytes(metadata).length <= metadataSize);
        
        metadataChannel[channelName] = metadata;
    }
    
    /**
     * General getters
     */
    
    function getOwner(string channel) constant returns(address ownerOfChannel){
        return channelOwner[channel];
    }
    
    function getPriceChannel(string channel) constant returns(uint256 price){
        return channelsOnSale[channel];
    }
    
    function getMetadataChannel(string channel) constant returns(string metadataOfChannel){
        return metadataChannel[channel];
    }
    
    function getMetadataUser(address user) constant returns(string metadataOfUser){
        return metadataUser[user];
    }
    
    function getRank(address user) constant returns(uint256){
        return ranks[user];
    }
    
    /**
     * Update the constants of the network if necessary
     */
    
    function setPricePerMessage(uint256 newPrice) onlyOwner {
        pricePerMessageChanged(pricePerMessage,newPrice);
        pricePerMessage = newPrice;
    }
    
    function setPriceCreatingChannel(uint256 newPrice) onlyOwner {
        priceCreatingChannelChanged(priceCreatingChannel,newPrice);
        priceCreatingChannel = newPrice;
    }
    
    function setPriceChannelMaxSize(uint256 newSize) onlyOwner {
        channelMaxSize = newSize;
    }
    
    function setMetadataSize(uint256 newSize) onlyOwner {
        metadataSize = newSize;
    }
    
    function setMaxCharacters(uint256 newMax) onlyOwner {
        maxCharacters = newMax;
    }
    
    function setSymbol(string newSymbol) onlyOwner {
        symbol = newSymbol;
    }
    
    function setName(string newName) onlyOwner {
        name = newName;
    }
    
    function setRank(address user, uint256 newRank) onlyOwner {
        ranks[user] = newRank;
    }
    
    /**
     * Others
     */
     
    function burn(uint256 amount){
        balances[msg.sender] = safeSub(balances[msg.sender],amount);
        _totalSupply = safeSub(_totalSupply,amount);
    }
    
    /**
     * ERC20 functions
     */
    
    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }
  
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
 
    function transfer(address _to, uint256 _amount) returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender],_amount);
        balances[_to] = safeAdd(balances[_to],_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }
     
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_amount);
        balances[_from] = safeSub(balances[_from],_amount);
        balances[_to] = safeAdd(balances[_to],_amount);
        Transfer(_from, _to, _amount);
        return true;
    }
 
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
  
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    /**
    * @dev Transfer an _amount to multiple addresses, used for airdrop
    * @param _amount The amount to be transfered
    * @param addresses The array of addresses to which the tokens will be sent
    */
    function transferMultiple(uint256 _amount, address[] addresses) onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            transfer(addresses[i],_amount);
        }
    }
    
    function transferMultipleDifferentValues(uint256[] amounts, address[] addresses) onlyOwner {
        assert(amounts.length == addresses.length);
        for (uint i = 0; i < addresses.length; i++) {
            transfer(addresses[i],amounts[i]);
        }
    }
}
contract IXaurumToken {
    function doCoinage(address[] _coinageAddresses, uint256[] _coinageAmounts, uint256 _usdAmount, uint256 _xaurCoined, uint256 _goldBought) returns (bool) {}
}

contract MintingContract{
    
    //
    /* Variables */
    //
    
    /* Public variables */
    address public curator;
    address public dev;
    address public defaultMintingAddress;
    
    uint256 public usdAmount;
    uint256 public xaurCoined; 
    uint256 public goldBought;
    
    /* Private variables */
    IXaurumToken tokenContract;
    
    /* Events */    
    event MintMade(uint256 usdAmount, uint256 xaurAmount, uint256 goldAmount);

    
    //
    /* Constructor */
    //
    
    function MintingContract(){
        dev = msg.sender;
    }
    
    //
    /* Contract features */
    //
    
    function doCoinage() returns (bool){
        if (msg.sender != curator){ return false; }
        if (usdAmount == 0 || xaurCoined == 0 || goldBought == 0){ return false; }
        
        address[] memory tempAddressArray = new address[](1);
        tempAddressArray[0] = defaultMintingAddress;
        
        uint256[] memory tempAmountArray = new uint256[](1);
        tempAmountArray[0] = xaurCoined;
        
        tokenContract.doCoinage(tempAddressArray, tempAmountArray, usdAmount, xaurCoined, goldBought);
        
        MintMade(usdAmount, xaurCoined, goldBought);
        usdAmount = 0;
        xaurCoined  = 0; 
        goldBought = 0;
        
        return true;
    }
    
    function setDefaultMintingAddress(address _mintingAddress) returns (bool){
        if (msg.sender != curator){ return false; }
        defaultMintingAddress = _mintingAddress;
        return true;
    }
    
    function setUsdAmount(uint256 _usdAmount) returns (bool){
        if (msg.sender != curator){ return false; }
        usdAmount = _usdAmount;
        return true;
    }
    
    function getRealUsdAmount() constant returns (uint256){
        return usdAmount / 10**8;
    }
    
    function setXaurCoined(uint256 _xaurCoined) returns (bool){
        if (msg.sender != curator){ return false; }
        xaurCoined = _xaurCoined;
        return true;
    }
    
    function getRealXaurCoined() constant returns (uint256){
        return xaurCoined / 10**8;
    }
    
    function setGoldBought(uint256 _goldBought) returns (bool){
        if (msg.sender != curator){ return false; }
        goldBought = _goldBought;
        return true;
    }
    
    function getRealGoldBought() constant returns (uint256){
        return goldBought / 10**8;
    }
    
    //
    /* Administration features */
    //
    
    function setMintingCurator(address _curatorAddress) returns (uint error){
        if (msg.sender != dev){ return 1; }
        curator = _curatorAddress;
        return 0;
    }
    
    function setTokenContract(address _contractAddress) returns (uint error){
        if (msg.sender != curator){ return 1; }
        tokenContract = IXaurumToken(_contractAddress);
        return 0;
    }
    
    function killContract() returns (uint error) {
        if (msg.sender != dev) { return 1; }
        selfdestruct(dev);
        return 0;
    }
    
    //
    /* Getters */
    //
    
    function tokenAddress() constant returns (address tokenAddress){
        return address(tokenContract);
    }
    
    //
    /* Other */
    //
    
    function () {
        throw;
    }
}
contract ERC20TokenInterface {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}   

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract XaurumProxyERC20 is ERC20TokenInterface {

    bool public xaurumProxyWorking;

    XaurumToken xaurumTokenReference; 

    address proxyCurrator;
    address owner;
    address dev;

    /* Public variables of the token */
    string public standard = 'XaurumERCProxy';
    string public name = 'Xaurum';
    string public symbol = 'XAUR';
    uint8 public decimals = 8;


    modifier isWorking(){
        if (xaurumProxyWorking && !xaurumTokenReference.lockdown()){
            _
        }
    }

    function XaurumProxyERC20(){
        dev = msg.sender;
        xaurumProxyWorking = true;
    }

    function setTokenReference(address _xaurumTokenAress) returns (bool){
        if (msg.sender == proxyCurrator){
            xaurumTokenReference = XaurumToken(_xaurumTokenAress);
            return true;
        }
        return false;
    }

    function EnableDisableTokenProxy() returns (bool){
        if (msg.sender == proxyCurrator){        
            xaurumProxyWorking = !xaurumProxyWorking;
            return true;
        }
        return false;
    }

    function setProxyCurrator(address _newCurratorAdress) returns (bool){
        if (msg.sender == owner || msg.sender == dev){        
            proxyCurrator = _newCurratorAdress;
            return true;
        }
        return false;
    }

    function setOwner(address _newOwnerAdress) returns (bool){
        if ( msg.sender == dev ){        
            owner = _newOwnerAdress;
            return true;
        }
        return false;
    }

    function totalSupply() constant returns (uint256 supply) {
        return xaurumTokenReference.totalSupply();
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return xaurumTokenReference.balanceOf(_owner);
    }

    function transfer(address _to, uint256 _value) isWorking returns (bool success) {
        bool answerStatus;
        address sentFrom;
        address sentTo;
        uint256 sentToAmount;
        address burningAddress;
        uint256 burningAmount;

        (answerStatus, sentFrom, sentTo, sentToAmount, burningAddress, burningAmount) = xaurumTokenReference.transferViaProxy(msg.sender, _to, _value);
        if(answerStatus){
            Transfer(sentFrom, sentTo, sentToAmount);
            Transfer(sentFrom, burningAddress, burningAmount);
            return true;
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) isWorking returns (bool success) {
        bool answerStatus;
        address sentFrom;
        address sentTo;
        uint256 sentToAmount;
        address burningAddress;
        uint256 burningAmount;

        (answerStatus, sentFrom, sentTo, sentToAmount, burningAddress, burningAmount) = xaurumTokenReference.transferFromViaProxy(msg.sender, _from, _to, _value);
        if(answerStatus){
            Transfer(sentFrom, sentTo, sentToAmount);
            Transfer(sentFrom, burningAddress, burningAmount);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint256 _value) isWorking returns (bool success) {
        if (xaurumTokenReference.approveFromProxy(msg.sender, _spender, _value)){
            Approval(msg.sender, _spender, _value);
            return true;
        }
        return false;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return xaurumTokenReference.allowanceFromProxy(msg.sender, _owner, _spender);
    } 
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract XaurumToken {
    
    /* Public variables of the token */
    string public standard = 'Xaurum v1.0';
    string public name = 'Xaurum';
    string public symbol = 'XAUR';
    uint8 public decimals = 8;

    uint256 public totalSupply = 0;
    uint256 public totalGoldSupply = 0;
    bool public lockdown = false;
    uint256 numberOfCoinages;

    /* Private variabiles for the token */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint) lockedAccounts;

    /* Events */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address from, uint256 value, BurningType burningType);
    event Melt(uint256 xaurAmount, uint256 goldAmount);
    event Coinage(uint256 coinageId, uint256 usdAmount, uint256 xaurAmount, uint256 goldAmount, uint256 totalGoldSupply, uint256 totalSupply);

    /*enums*/
    enum BurningType { TxtFee, AllyDonation, ServiceFee }

   /* Contracts */
    XaurumMeltingContract public meltingContract;
    function setMeltingContract(address _meltingContractAddress){
        if (msg.sender == owner || msg.sender == dev){
            meltingContract = XaurumMeltingContract(_meltingContractAddress);
        }
    }

    XaurumDataContract public dataContract;
    function setDataContract(address _dataContractAddress){
        if (msg.sender == owner || msg.sender == dev){
            dataContract = XaurumDataContract(_dataContractAddress);
        }
    }

    XaurumCoinageContract public coinageContract;
    function setCoinageContract(address _coinageContractAddress){
        if (msg.sender == owner || msg.sender == dev){
            coinageContract = XaurumCoinageContract(_coinageContractAddress);
        }
    }

    XaurmProxyContract public proxyContract;
    function setProxyContract(address _proxyContractAddress){
        if (msg.sender == owner || msg.sender == dev){
            proxyContract = XaurmProxyContract(_proxyContractAddress);
        }
    }

    XaurumAlliesContract public alliesContract;
    function setAlliesContract(address _alliesContractAddress){
        if (msg.sender == owner || msg.sender == dev){
            alliesContract = XaurumAlliesContract(_alliesContractAddress);
        }
    }
    
    
    

    /* owner */
    address public owner;
    function setOwner(address _newOwnerAdress) returns (bool){
        if ( msg.sender == dev ){        
            owner = _newOwnerAdress;
            return true;
        }
        return false;
    }

    address public dev;

    /* Xaur for gas */
    address xaurForGasCurrator;
    function setXauForGasCurrator(address _curratorAddress){
        if (msg.sender == owner || msg.sender == dev){
            xaurForGasCurrator = _curratorAddress;
        }
    }

    /* Burrning */
    address public burningAdress;

    /* Constructor */
    function XaurumToken(address _burningAddress) { 
        burningAdress = _burningAddress;
        lockdown = false;
        dev = msg.sender;
       
        
        // initial
         numberOfCoinages += 1;
         balances[0x097B7b672fe0dc3eF61f53B954B3DCC86382e7B9] += 5999319593600000;
         totalSupply += 5999319593600000;
         totalGoldSupply += 1696620000000;
         Coinage(numberOfCoinages, 0, 5999319593600000, 1696620000000, totalGoldSupply, totalSupply);      
		

        // Mint 1
         numberOfCoinages += 1;
         balances[0x097B7b672fe0dc3eF61f53B954B3DCC86382e7B9] += 1588947591000000;
         totalSupply += 1588947591000000;
         totalGoldSupply += 1106042126000;
         Coinage(numberOfCoinages, 60611110000000, 1588947591000000, 1106042126000, totalGoldSupply, totalSupply);
        		
		
        // Mint 2
         numberOfCoinages += 1;
         balances[0x097B7b672fe0dc3eF61f53B954B3DCC86382e7B9] += 151127191000000;
         totalSupply += 151127191000000;
         totalGoldSupply += 110134338200;
         Coinage(numberOfCoinages, 6035361000000, 151127191000000, 110134338200, totalGoldSupply, totalSupply);
        
		
		   // Mint 3
         numberOfCoinages += 1;
         balances[0x097B7b672fe0dc3eF61f53B954B3DCC86382e7B9] += 63789854418800;
         totalSupply += 63789854418800;
         totalGoldSupply +=  46701000000;
         Coinage(numberOfCoinages, 2559215000000, 63789854418800, 46701000000, totalGoldSupply, totalSupply);
        

		   // Mint 4
         numberOfCoinages += 1;
         balances[0x097B7b672fe0dc3eF61f53B954B3DCC86382e7B9] +=  393015011191000;
         totalSupply += 393015011191000;
         totalGoldSupply +=  290692000000;
         Coinage(numberOfCoinages, 15929931000000, 393015011191000, 290692000000, totalGoldSupply, totalSupply);
        

		   // Mint 5
         numberOfCoinages += 1;
         balances[0x097B7b672fe0dc3eF61f53B954B3DCC86382e7B9] +=  49394793870000;
         totalSupply += 49394793870000;
         totalGoldSupply +=  36891368614;
         Coinage(numberOfCoinages, 2021647000000, 49394793870000, 36891368614, totalGoldSupply, totalSupply);
    }
    
    function freezeCoin(){
        if (msg.sender == owner || msg.sender == dev){
            lockdown = !lockdown;
        }
    }

    /* Get balance of the account */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /* Send coins */
    function transfer(address _to, uint256 _amount) returns (bool status) {
        uint256 goldFee = dataContract.goldFee();

        if (balances[msg.sender] >= _amount &&                                  // Check if the sender has enough
            balances[_to] + _amount > balances[_to] &&                          // Check for overflows
            _amount > goldFee &&                                                // Check if there is something left after burning fee
            !lockdown &&                                                        // Check if coin is on lockdown
            lockedAccounts[msg.sender] <= block.number) {                       // Check if the account is locked
            balances[msg.sender] -= _amount;                                    // Subtract from the sender minus the fee
            balances[_to] += (_amount - goldFee );                              // Add the same to the recipient
            Transfer(msg.sender, _to, (_amount - goldFee ));                    // Notify anyone listening that this transfer took place
            doBurn(msg.sender, goldFee, BurningType.TxtFee);                    // Notify anyone listening that this burn took place
            return true;
        } else {
            return false;
        }
    }
    
    /* A contract attempts to get the coins and sends them*/
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool status) {
        uint256 goldFee = dataContract.goldFee();

        if (balances[_from] >= _amount &&                                  // Check if the sender has enough
            balances[_to] + _amount > balances[_to] &&                          // Check for overflows
            _amount > goldFee &&                                                // Check if there is something left after burning fee
            !lockdown &&                                                        // Check if coin is on lockdown
            lockedAccounts[_from] <= block.number) {                       // Check if the account is locked
            if (_amount > allowed[_from][msg.sender]){                          // Check allowance
                return false;
            }
            balances[_from] -= _amount;                                    // Subtract from the sender minus the fee
            balances[_to] += (_amount - goldFee);                               // Add the same to the recipient
            Transfer(_from, _to, (_amount - goldFee));                     // Notify anyone listening that this transfer took place
            doBurn(_from, goldFee, BurningType.TxtFee);                    
            allowed[_from][msg.sender] -= _amount;                              // Update allowance
            return true;
        } else {
            return false;
        }
    }
    
    /* Allow another contract to spend some tokens in your behalf */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        tokenRecipient spender = tokenRecipient(_spender);
        spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

     function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    /* Send coins via proxy */
    function transferViaProxy(address _source, address _to, uint256 _amount) returns (bool status, address sendFrom, address sentTo, uint256 sentToAmount, address burnAddress, uint256 burnAmount){
        if (!proxyContract.isProxyLegit(msg.sender)){                                        // Check if proxy is legit
            return (false, 0, 0, 0, 0, 0);
        }

        uint256 goldFee = dataContract.goldFee();

        if (balances[_source] >= _amount &&                                     // Check if the sender has enough
            balances[_to] + _amount > balances[_to] &&                          // Check for overflows
            _amount > goldFee &&                                                // Check if there is something left after burning fee
            !lockdown &&                                                        // Check if coin is on lockdown
            lockedAccounts[_source] <= block.number) {                          // Check if the account is locked
            
            balances[_source] -= _amount;                                       // Subtract from the sender minus the fee
            balances[_to] += (_amount - goldFee );                              // Add the same to the recipient
            Transfer(_source, _to, ( _amount - goldFee ));                    // Notify anyone listening that this transfer took place
            doBurn(_source, goldFee, BurningType.TxtFee);                         // Notify anyone listening that this burn took place
        
            return (true, _source, _to, (_amount - goldFee), burningAdress, goldFee);
        } else {
            return (false, 0, 0, 0, 0, 0);
        }
    }
    
    /* a contract attempts to get the coins and sends them via proxy */
    function transferFromViaProxy(address _source, address _from, address _to, uint256 _amount) returns (bool status, address sendFrom, address sentTo, uint256 sentToAmount, address burnAddress, uint256 burnAmount) {
        if (!proxyContract.isProxyLegit(msg.sender)){                                            // Check if proxy is legit
            return (false, 0, 0, 0, 0, 0);
        }

        uint256 goldFee = dataContract.goldFee();

        if (balances[_from] >= _amount &&                                       // Check if the sender has enough
            balances[_to] + _amount > balances[_to] &&                          // Check for overflows
            _amount > goldFee &&                                                // Check if there is something left after burning fee
            !lockdown &&                                                        // Check if coin is on lockdown
            lockedAccounts[_from] <= block.number) {                            // Check if the account is locked

            if (_amount > allowed[_from][_source]){                             // Check allowance
                return (false, 0, 0, 0, 0, 0); 
            }               

            balances[_from] -= _amount;                                         // Subtract from the sender minus the fee
            balances[_to] += ( _amount - goldFee );                             // Add the same to the recipient
            Transfer(_from, _to, ( _amount - goldFee ));                        // Notify anyone listening that this transfer took place
            doBurn(_from, goldFee, BurningType.TxtFee);
            allowed[_from][_source] -= _amount;                                 // Update allowance
            return (true, _from, _to, (_amount - goldFee), burningAdress, goldFee);
        } else {
            return (false, 0, 0, 0, 0, 0);
        }
    }
    
     function approveFromProxy(address _source, address _spender, uint256 _value) returns (bool success) {
        if (!proxyContract.isProxyLegit(msg.sender)){                                        // Check if proxy is legit
            return false;
        }
        allowed[_source][_spender] = _value;
        Approval(_source, _spender, _value);
        return true;
    }

    function allowanceFromProxy(address _source, address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    
    /* -----------------------------------------------------------------------*/
    
    /* Lock account for X amount of blocks */
    function lockAccount(uint _block) returns (bool answer){
        if (lockedAccounts[msg.sender] < block.number + _block){
            lockedAccounts[msg.sender] = block.number + _block;
            return true;
        }
        return false;
    }

    function isAccountLocked(address _accountAddress) returns (bool){
        if (lockedAccounts[_accountAddress] > block.number){
            return true;
        }
        return false;
    }
    
    ///
    /// Xaur for gas region
    ///

    /* user get small amout of wei for a small amout of Xaur */
    function getGasForXau(address _to) returns (bool sucess){
        uint256 xaurForGasLimit = dataContract.xaurForGasLimit();
        uint256 weiForXau = dataContract.weiForXau();

        if (balances[msg.sender] > xaurForGasLimit && 
            balances[xaurForGasCurrator] < balances[xaurForGasCurrator]  + xaurForGasLimit &&
            this.balance > dataContract.weiForXau()) {
            if (_to.send(dataContract.weiForXau())){
                balances[msg.sender] -= xaurForGasLimit;
                balances[xaurForGasCurrator] += xaurForGasLimit;
                return true;
            }
        } 
        return false;
    }
    
    /* Currator fills eth through this function */
    function fillGas(){
        if (msg.sender != xaurForGasCurrator) { 
            throw; 
        }
    }

    ///
    /// Melting region
    ///

    function doMelt(uint256 _xaurAmount, uint256 _goldAmount) returns (bool){
        if (msg.sender == address(meltingContract)){
            totalSupply -= _xaurAmount;
            totalGoldSupply -= _goldAmount;
            Melt(_xaurAmount, _goldAmount);
            return true;
        }
        return false;
    }
    
    ///
    /// Proxy region
    ///

    

    ///
    /// Coinage region
    ///
    function doCoinage(address[] _coinageAddresses, uint256[] _coinageAmounts, uint256 _usdAmount, uint256 _xaurCoined, uint256 _goldBought) returns (bool){
        if (msg.sender == address(coinageContract) && 
            _coinageAddresses.length == _coinageAmounts.length){
            
            totalSupply += _xaurCoined;
            totalGoldSupply += _goldBought;
            numberOfCoinages += 1;
            Coinage(numberOfCoinages, _usdAmount, _xaurCoined, _goldBought, totalGoldSupply, totalSupply);
            for (uint256 cnt = 0; cnt < _coinageAddresses.length; cnt++){
                balances[_coinageAddresses[cnt]] += _coinageAmounts[cnt]; 
            }
            return true;
        }
        return false;
    }

    ///
    /// Burining region
    ///
    function doBurn(address _from, uint256 _amountToBurn, BurningType _burningType) internal {
        balances[burningAdress] += _amountToBurn;                              // Burn the fee
        totalSupply -= _amountToBurn;                                          // Edit total supply
        Burn(_from, _amountToBurn, _burningType);                              // Notify anyone listening that this burn took place
    }

    function doBurnFromContract(address _from, uint256 _amount) returns (bool){
        if (msg.sender == address(alliesContract)){
            balances[_from] -= _amount;
            doBurn(_from, _amount, BurningType.AllyDonation);
            return true;
        }
        else if(msg.sender == address(coinageContract)){
            balances[_from] -= _amount;
            doBurn(_from, _amount, BurningType.ServiceFee);
            return true;
        }
        else{
            return false;
        }

    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}

contract XaurumMeltingContract {}

contract XaurumAlliesContract {}

contract XaurumCoinageContract {}

contract XaurmProxyContract{

    address public owner;
    address public curator;
    address public dev;

    function XaurmProxyContract(){
        dev = msg.sender;
    }

    function setProxyCurrator(address _newCurratorAdress) returns (bool){
        if (msg.sender == owner || msg.sender == dev){        
            curator = _newCurratorAdress;
            return true;
        }
        return false;
    }

    function setOwner(address _newOwnerAdress) returns (bool){
        if ( msg.sender == dev ){        
            owner = _newOwnerAdress;
            return true;
        }
        return false;
    }

    /* Proxy Contract */
    
    address[] approvedProxys; 
    mapping (address => bool) proxyList;
    
    /* Adds new proxy to proxy lists and grants him the permission to use transferViaProxy */
    function addNewProxy(address _proxyAdress){
        if(msg.sender == curator){
            proxyList[_proxyAdress] = true;
            approvedProxys.push(_proxyAdress);
        }
    }

    function isProxyLegit(address _proxyAddress) returns (bool){
        return proxyList[_proxyAddress];
    }
    
    function getApprovedProxys() returns (address[] proxys){
        return approvedProxys;
    }

    function () {
        throw;
    }
}

contract XaurumDataContract {

    /* Minting data */
    uint256 public xauToEur;
    uint256 public goldToEur;
    uint256 public mintingDataUpdatedAtBlock;

    /* Gas for xaur data */
    uint256 public xaurForGasLimit;
    uint256 public weiForXau;
    uint256 public gasForXaurDataUpdateAtBlock;

    /* Other data */
    uint256 public goldFee;
    uint256 public goldFeeDataUpdatedAtBlock;

    address public owner;
    address public curator;
    address public dev;

    function XaurumDataContract(){
        xaurForGasLimit = 100000000;
        weiForXau = 100000000000000000;
        goldFee = 50000000;
       // dev = _dev;
	   dev = msg.sender;
    }

    function setProxyCurrator(address _newCurratorAdress) returns (bool){
        if (msg.sender == owner || msg.sender == dev){        
            curator = _newCurratorAdress;
            return true;
        }
        return false;
    }

    function setOwner(address _newOwnerAdress) returns (bool){
        if ( msg.sender == dev ){        
            owner = _newOwnerAdress;
            return true;
        }
        return false;
    }

    function updateMintingData(uint256 _xauToEur, uint256 _goldToEur) returns (bool status){
        if (msg.sender == curator || msg.sender == dev){
            xauToEur = _xauToEur;
            goldToEur = _goldToEur;
            mintingDataUpdatedAtBlock = block.number;
            return true;
        }
        return false;
    }

    function updateGasForXaurData(uint256 _xaurForGasLimit, uint256 _weiForXau) returns (bool status){
        if (msg.sender == curator || msg.sender == dev){
            xaurForGasLimit = _xaurForGasLimit;
            weiForXau = _weiForXau;
            gasForXaurDataUpdateAtBlock = block.number;
            return true;
        }
        return false;
    }

    function updateGoldFeeData(uint256 _goldFee) returns (bool status){
        if (msg.sender == curator || msg.sender == dev){
            goldFee = _goldFee;
            goldFeeDataUpdatedAtBlock = block.number;
            return true;
        }
        return false;
    }

    function () {
        throw;
    }
}
pragma solidity ^0.4.15;

contract Token {

    /// @return total amount of tokens
    // function totalSupply() public constant returns (uint supply);
    // `totalSupply` is defined below because the automatically generated
    // getter function does not match the abstract function above
    uint public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint _value) public returns (bool success) {
        if (balances[msg.sender] >= _value &&          // Account has sufficient balance
            balances[_to] + _value >= balances[_to]) { // Overflow check
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { throw; }
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if (balances[_from] >= _value &&                // Account has sufficient balance
            allowed[_from][msg.sender] >= _value &&     // Amount has been approved
            balances[_to] + _value >= balances[_to]) {  // Overflow check
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            return true;
        } else { throw; }
    }

    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
}

// Based on TokenFactory(https://github.com/ConsenSys/Token-Factory)

contract SnipCoin is StandardToken {

    string public constant name = "SnipCoin";         // Token name
    string public symbol = "SNIP";                    // Token identifier
    uint8 public constant decimals = 18;              // Decimal points for token
    uint public totalEthReceivedInWei;                // The total amount of Ether received during the sale in WEI
    uint public totalUsdReceived;                     // The total amount of Ether received during the sale in USD terms
    uint public totalUsdValueOfAllTokens;             // The total USD value of 100% of tokens
    string public version = "1.0";                    // Code version
    address public saleWalletAddress;                 // The wallet address where the Ether from the sale will be stored

    mapping (address => bool) public uncappedBuyerList;      // The list of buyers allowed to participate in the sale without a cap
    mapping (address => uint) public cappedBuyerList;        // The list of buyers allowed to participate in the sale, with their updated payment sum

    uint public snipCoinToEtherExchangeRate = 76250; // This is the ratio of SnipCoin to Ether, could be updated by the owner, change before the sale
    bool public isSaleOpen = false;                   // This opens and closes upon external command
    bool public transferable = false;                 // Tokens are transferable

    uint public ethToUsdExchangeRate = 282;           // Number of USD in one Eth

    address public contractOwner;                     // Address of the contract owner
    // Address of an additional account to manage the sale without risk to the tokens or eth. Change before the sale
    address public accountWithUpdatePermissions = 0x6933784a82F5daDEbB600Bed8670667837aD196f;

    uint public constant PERCENTAGE_OF_TOKENS_SOLD_IN_SALE = 28;     // Percentage of all the tokens being sold in the current sale
    uint public constant DECIMALS_MULTIPLIER = 10**uint(decimals);   // Multiplier for the decimals
    uint public constant SALE_CAP_IN_USD = 8000000;                  // The total sale cap in USD
    uint public constant MINIMUM_PURCHASE_IN_USD = 50;               // It is impossible to purchase tokens for more than $50 in the sale.
    uint public constant USD_PURCHASE_AMOUNT_REQUIRING_ID = 4500;    // Above this purchase amount an ID is required.

    modifier onlyPermissioned() {
        require((msg.sender == contractOwner) || (msg.sender == accountWithUpdatePermissions));
        _;
    }

    modifier verifySaleNotOver() {
        require(isSaleOpen);
        require(totalUsdReceived < SALE_CAP_IN_USD); // Make sure that sale isn't over
        _;
    }

    modifier verifyBuyerCanMakePurchase() {
        uint currentPurchaseValueInUSD = uint(msg.value / getWeiToUsdExchangeRate()); // The USD worth of tokens sold
        uint totalPurchaseIncludingCurrentPayment = currentPurchaseValueInUSD +  cappedBuyerList[msg.sender]; // The USD worth of all tokens this buyer bought

        require(currentPurchaseValueInUSD > MINIMUM_PURCHASE_IN_USD); // Minimum transfer is of $50

        uint EFFECTIVE_MAX_CAP = SALE_CAP_IN_USD + 1000;  // This allows for the end of the sale by passing $8M and reaching the cap
        require(EFFECTIVE_MAX_CAP - totalUsdReceived > currentPurchaseValueInUSD); // Make sure that there is enough usd left to buy.

        if (!uncappedBuyerList[msg.sender]) // If buyer is on uncapped white list then no worries, else need to make sure that they're okay
        {
            require(cappedBuyerList[msg.sender] > 0); // Check that the sender has been initialized.
            require(totalPurchaseIncludingCurrentPayment < USD_PURCHASE_AMOUNT_REQUIRING_ID); // Check that they're not buying too much
        }
        _;
    }

    function SnipCoin() public {
        initializeSaleWalletAddress();
        initializeEthReceived();
        initializeUsdReceived();

        contractOwner = msg.sender;                      // The creator of the contract is its owner
        totalSupply = 10000000000 * DECIMALS_MULTIPLIER; // In total, 10 billion tokens
        balances[contractOwner] = totalSupply;           // Initially give owner all of the tokens 
        Transfer(0x0, contractOwner, totalSupply);
    }

    function initializeSaleWalletAddress() internal {
        saleWalletAddress = 0xb4Ad56E564aAb5409fe8e34637c33A6d3F2a0038; // Change before the sale
    }

    function initializeEthReceived() internal {
        totalEthReceivedInWei = 14018 * 1 ether; // Ether received before public sale. Verify this figure before the sale starts.
    }

    function initializeUsdReceived() internal {
        totalUsdReceived = 3953076; // USD received before public sale. Verify this figure before the sale starts.
        totalUsdValueOfAllTokens = totalUsdReceived * 100 / PERCENTAGE_OF_TOKENS_SOLD_IN_SALE; // sold tokens are 28% of all tokens
    }

    function getWeiToUsdExchangeRate() public constant returns(uint) {
        return 1 ether / ethToUsdExchangeRate; // Returns how much Wei one USD is worth
    }

    function updateEthToUsdExchangeRate(uint newEthToUsdExchangeRate) public onlyPermissioned {
        ethToUsdExchangeRate = newEthToUsdExchangeRate; // Change exchange rate to new value, influences the counter of when the sale is over.
    }

    function updateSnipCoinToEtherExchangeRate(uint newSnipCoinToEtherExchangeRate) public onlyPermissioned {
        snipCoinToEtherExchangeRate = newSnipCoinToEtherExchangeRate; // Change the exchange rate to new value, influences tokens received per purchase
    }

    function openOrCloseSale(bool saleCondition) public onlyPermissioned {
        require(!transferable);
        isSaleOpen = saleCondition; // Decide if the sale should be open or closed (default: closed)
    }

    function allowTransfers() public onlyPermissioned {
        require(!isSaleOpen);
        transferable = true;
    }

    function addAddressToCappedAddresses(address addr) public onlyPermissioned {
        cappedBuyerList[addr] = 1; // Allow a certain address to purchase SnipCoin up to the cap (<4500)
    }

    function addMultipleAddressesToCappedAddresses(address[] addrList) public onlyPermissioned {
        for (uint i = 0; i < addrList.length; i++) {
            addAddressToCappedAddresses(addrList[i]); // Allow a certain address to purchase SnipCoin up to the cap (<4500)
        }
    }

    function addAddressToUncappedAddresses(address addr) public onlyPermissioned {
        uncappedBuyerList[addr] = true; // Allow a certain address to purchase SnipCoin above the cap (>=$4500)
    }

    function addMultipleAddressesToUncappedAddresses(address[] addrList) public onlyPermissioned {
        for (uint i = 0; i < addrList.length; i++) {
            addAddressToUncappedAddresses(addrList[i]); // Allow a certain address to purchase SnipCoin up to the cap (<4500)
        }
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        require(transferable);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(transferable);
        return super.transferFrom(_from, _to, _value);
    }

    function () public payable verifySaleNotOver verifyBuyerCanMakePurchase {
        uint tokens = snipCoinToEtherExchangeRate * msg.value;
        balances[contractOwner] -= tokens;
        balances[msg.sender] += tokens;
        Transfer(contractOwner, msg.sender, tokens);

        totalEthReceivedInWei = totalEthReceivedInWei + msg.value; // total eth received counter
        uint usdReceivedInCurrentTransaction = uint(msg.value / getWeiToUsdExchangeRate());
        totalUsdReceived = totalUsdReceived + usdReceivedInCurrentTransaction; // total usd received counter
        totalUsdValueOfAllTokens = totalUsdReceived * 100 / PERCENTAGE_OF_TOKENS_SOLD_IN_SALE; // sold tokens are 28% of all tokens

        if (cappedBuyerList[msg.sender] > 0)
        {
            cappedBuyerList[msg.sender] = cappedBuyerList[msg.sender] + usdReceivedInCurrentTransaction;
        }

        saleWalletAddress.transfer(msg.value); // Transfer ether to safe sale address
    }
}
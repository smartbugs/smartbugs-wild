pragma solidity ^0.4.6;
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract SwapToken is owned {
    /* Public variables of the token */
    
    string public standard = 'Token 0.1';

    // buyer tokens
    string public buyerTokenName;
    string public buyerSymbol;
    uint8 public buyerDecimals;
    uint256 public totalBuyerSupply;
    
    // issuer tokens
    string public issuerTokenName;
    string public issuerSymbol;
    uint8 public issuerDecimals;
    uint256 public totalIssuerSupply;
    
    // more variables
    uint256 public buyPrice;
    uint256 public issuePrice;
    uint256 public cPT;
    uint256 public premium;
    bool public creditStatus;
    address public project_wallet;
    address public collectionFunds;
    //uint public startBlock;
    //uint public endBlock;
    
    /* Sets the constructor variables */
    function SwapToken(
        string _buyerTokenName,
        string _buyerSymbol,
        uint8 _buyerDecimals,
        string _issuerTokenName,
        string _issuerSymbol,
        uint8 _issuerDecimals,
        address _collectionFunds,
        uint _startBlock,
        uint _endBlock
        ) {
        buyerTokenName = _buyerTokenName;
        buyerSymbol = _buyerSymbol;
        buyerDecimals = _buyerDecimals;
        issuerTokenName = _issuerTokenName;
        issuerSymbol = _issuerSymbol;
        issuerDecimals = _issuerDecimals;
        collectionFunds = _collectionFunds;
        //startBlock = _startBlock;
        //endBlock = _endBlock;
    }

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOfBuyer;
    mapping (address => uint256) public balanceOfIssuer;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract 
    function token(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }
    */
    
    /* Check if contract has started */
    /*function has_contract_started() private constant returns (bool) {
	    return block.number >= startBlock;
    }
    
    /* Check if contract has ended */
    /*function has_contract_ended() private constant returns (bool) {
        return block.number > endBlock;
    }*/
    
    /* Set a project Wallet */
    function defineProjectWallet(address target) onlyOwner {
        project_wallet = target;
    }
    
    /* Mint coins */
    
    // buyer tokens
    function mintBuyerToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOfBuyer[target] += mintedAmount;
        totalBuyerSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }
    
    // issuer tokens
    function mintIssuerToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOfIssuer[target] += mintedAmount;
        totalIssuerSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }
    
    /* Distroy coins */
    
    // Distroy buyer coins for sale in contract 
    function distroyBuyerToken(uint256 burnAmount) onlyOwner {
        balanceOfBuyer[this] -= burnAmount;
        totalBuyerSupply -= burnAmount;
    }
    
    // Distroy issuer coins for sale in contract
    function distroyIssuerToken(uint256 burnAmount) onlyOwner {
        balanceOfIssuer[this] -= burnAmount;
        totalIssuerSupply -= burnAmount;
    }

    /* Send coins */
    
    // send buyer coins
    function transferBuyer(address _to, uint256 _value) {
        if (balanceOfBuyer[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOfBuyer[_to] + _value < balanceOfBuyer[_to]) throw; // Check for overflows
        balanceOfBuyer[msg.sender] -= _value;                     // Subtract from the sender
        balanceOfBuyer[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
    
    // send issuer coins
    function transferIssue(address _to, uint256 _value) {
        if (balanceOfIssuer[msg.sender] < _value) throw;
        if (balanceOfIssuer[_to] + _value < balanceOfIssuer[_to]) throw;
        balanceOfIssuer[msg.sender] -= _value;
        balanceOfIssuer[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    
    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        tokenRecipient spender = tokenRecipient(_spender);
        return true;
    }

    /* Approve and then comunicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {    
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /* A contract attempts to get the coins 
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceOfBuyer[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOfBuyer[_to] + _value < balanceOfBuyer[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOfBuyer[_from] -= _value;                          // Subtract from the sender
        balanceOfBuyer[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
    */
    
    /* Set token price */
    function setPrices(uint256 newBuyPrice, uint256 newIssuePrice, uint256 coveragePerToken) onlyOwner {
        buyPrice = newBuyPrice;
        issuePrice = newIssuePrice;
        cPT = coveragePerToken;
    }

    /* Buy tokens */
    
    // buy buyer tokens
    function buyBuyerTokens() payable {
        //if(!has_contract_started()) throw;                  // checks if the contract has started
        //if(has_contract_ended()) throw;                     // checks if the contract has ended 
        uint amount = msg.value / buyPrice;                // calculates the amount
        if (balanceOfBuyer[this] < amount) throw;               // checks if it has enough to sell
        balanceOfBuyer[msg.sender] += amount;                   // adds the amount to buyer's balance
        balanceOfBuyer[this] -= amount;                         // subtracts amount from seller's balance
        Transfer(this, msg.sender, amount);                // execute an event reflecting the change
    }
    
    // buy issuer tokens
    function buyIssuerTokens() payable {
        uint amount = msg.value / issuePrice;
        if (balanceOfIssuer[this] < amount) throw;
        balanceOfIssuer[msg.sender] += amount;
        balanceOfIssuer[this] -= amount;
        Transfer(this, msg.sender, amount);
    }
    
    /* Credit Status Event */
    function setCreditStatus(bool _status) onlyOwner {
        creditStatus = _status;
    }

    /* Collection */
    
    // buyer collection sale
    function sellBuyerTokens(uint amount) returns (uint revenue){
        if (creditStatus == false) throw;                       // checks if buyer is eligible for a claim
        if (balanceOfBuyer[msg.sender] < amount ) throw;        // checks if the sender has enough to sell
        balanceOfBuyer[this] += amount;                         // adds the amount to owner's balance
        balanceOfBuyer[msg.sender] -= amount;                   // subtracts the amount from seller's balance
        revenue = amount * cPT;
        if (!msg.sender.send(revenue)) {                   // sends ether to the seller: it's important
            throw;                                         // to do this last to prevent recursion attacks
        } else {
            Transfer(msg.sender, this, amount);             // executes an event reflecting on the change
            return revenue;                                 // ends function and returns
        }
    }
    
    // get premium, note not tested yet
    function getPremium() private constant returns (uint256 premium) {
        premium = (issuePrice - cPT) * 98/100;
        return premium;
    }
    
    // issuer collection sale
    function sellIssuerTokens(uint amount) returns (uint revenue){
        if (balanceOfIssuer[msg.sender] < amount ) throw;
        balanceOfIssuer[this] += amount;
        balanceOfIssuer[msg.sender] -= amount;
        revenue = amount * getPremium();
        if (!msg.sender.send(revenue)) {
            throw;
        } else {
            Transfer(msg.sender, this, amount);
            return revenue;
        }
    }
    
    /* After contract ends move funds */
    function moveFunds() onlyOwner {
        //if (!has_contract_ended()) throw;
        if (!project_wallet.send(this.balance)) throw;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}
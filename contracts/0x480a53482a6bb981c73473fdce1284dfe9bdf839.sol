//A BurnableOpenPaymet is instantiated with a specified payer and a commitThreshold.
//The recipient not set when the contract is instantiated.

//The constructor is payable, so the contract can be instantiated with initial funds.
//Anyone can contribute to the payment at any time (the () function is payable).

//All behavior of the contract is directed by the payer, but
//the payer can never directly recover the payment unless he becomes the recipient.

//Anyone can become the recipient by contributing the commitThreshold.
//The recipient cannot change once it's been set.

//The payer can at any time choose to burn or release to the recipient any amount of funds.

pragma solidity ^0.4.1;

contract BurnableOpenPayment {
    address public payer;
    address public recipient;
    address public burnAddress = 0xdead;
    string public payerString;
    string public recipientString;
    uint public commitThreshold;
    
    modifier onlyPayer() {
        if (msg.sender != payer) throw;
        _;
    }
    
    modifier onlyRecipient() {
        if (msg.sender != recipient) throw;
        _;
    }
    
    modifier onlyWithRecipient() {
        if (recipient == address(0x0)) throw;
        _;
    }
    
    modifier onlyWithoutRecipient() {
        if (recipient != address(0x0)) throw;
        _;
    }
    
    function () payable {}
    
    function BurnableOpenPayment(address _payer, uint _commitThreshold)
    public
    payable {
        payer = _payer;
        commitThreshold = _commitThreshold;
    }
    
    function getPayer()
    public returns (address) { return payer; }
    
    function getRecipient()
    public returns (address) { return recipient; }
    
    function getCommitThreshold()
    public returns (uint) { return commitThreshold; }
    
    function getPayerString()
    public returns (string) { return payerString; }
    
    function getRecipientString()
    public returns (string) { return recipientString; }
    
    function commit()
    public
    onlyWithoutRecipient()
    payable
    {
        if (msg.value < commitThreshold) throw;
        recipient = msg.sender;
    }
    
    function burn(uint amount)
    public
    onlyPayer()
    onlyWithRecipient()
    returns (bool)
    {
        return burnAddress.send(amount);
    }
    
    function release(uint amount)
    public
    onlyPayer()
    onlyWithRecipient()
    returns (bool)
    {
        return recipient.send(amount);
    }
    
    function setPayerString(string _string)
    public
    onlyPayer()
    {
        payerString = _string;
    }
    
    function setRecipientString(string _string)
    public
    onlyRecipient()
    {
        recipientString = _string;
    }
}

contract BurnableOpenPaymentFactory {
    function newBurnableOpenPayment(address payer, uint commitThreshold)
    public
    payable
    returns (address) {
        //pass along any ether to the constructor
        return (new BurnableOpenPayment).value(msg.value)(payer, commitThreshold);
    }
}
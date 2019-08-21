pragma solidity ^0.4.18;

// Each deployed Splitter contract has a constant array of recipients.
// When the Splitter receives Ether, it will immediately divide this Ether up
// and send it to the recipients.
contract Splitter
{
	address[] public recipients;
	
	function Splitter(address[] _recipients) public
	{
	    require(_recipients.length >= 1);
		recipients = _recipients;
	}
	
	function() payable public
	{
		uint256 amountOfRecipients = recipients.length;
		uint256 etherPerRecipient = msg.value / amountOfRecipients;
		
		if (etherPerRecipient == 0) return;
		
		for (uint256 i=0; i<amountOfRecipients; i++)
		{
			recipients[i].transfer(etherPerRecipient);
		}
	}
}

contract SplitterService
{
    address private owner;
    uint256 public feeForSplitterCreation;
    
    mapping(address => address[]) public addressToSplittersCreated;
    mapping(address => bool) public addressIsSplitter;
    mapping(address => string) public splitterNames;
    
    function SplitterService() public
    {
        owner = msg.sender;
        feeForSplitterCreation = 0.001 ether;
    }
    
    function createSplitter(address[] recipients, string name) external payable
    {
        require(msg.value >= feeForSplitterCreation);
        address newSplitterAddress = new Splitter(recipients);
        addressToSplittersCreated[msg.sender].push(newSplitterAddress);
        addressIsSplitter[newSplitterAddress] = true;
        splitterNames[newSplitterAddress] = name;
    }
    
    ////////////////////////////////////////
    // Owner functions
    
    function setFee(uint256 newFee) external
    {
        require(msg.sender == owner);
        require(newFee <= 0.01 ether);
        feeForSplitterCreation = newFee;
    }
    
    function ownerWithdrawFees() external
    {
        owner.transfer(this.balance);
    }
    
    function transferOwnership(address newOwner) external
    {
        require(msg.sender == owner);
        owner = newOwner;
    }
}
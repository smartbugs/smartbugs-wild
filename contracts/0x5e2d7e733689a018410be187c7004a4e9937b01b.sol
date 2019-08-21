pragma solidity ^0.4.19;

contract SmzTradingContract
{
    address public constant RECEIVER_ADDRESS = 0xf3eB3CA356c111ECb418D457e55A3A3D185faf61;
    uint256 public constant ACCEPTED_AMOUNT = 3 ether;
    uint256 public RECEIVER_PAYOUT_THRESHOLD = 10 ether;
    
    address public constant END_ADDRESS = 0x3559e34004b944906Bc727a40d7568a98bDc42d3;
    uint256 public constant END_AMOUNT = 0.39 ether;
    
    bool public ended = false;
    
    mapping(address => bool) public addressesAllowed;
    mapping(address => bool) public addressesDeposited;
    
    // The manager can allow and disallow addresses to deposit
    address public manager;
    
    function SmzTradingContract() public
    {
        manager = msg.sender;
    }
    function setManager(address _newManager) external
    {
        require(msg.sender == manager);
        manager = _newManager;
    }
    
    function () payable external
    {
        // If the ending address sends the ending amount, block all deposits
        if (msg.sender == END_ADDRESS && msg.value == END_AMOUNT)
        {
            ended = true;
            RECEIVER_ADDRESS.transfer(this.balance);
            return;
        }
        
        // Only allow deposits if the process has not been ended yet
        require(!ended);
        
        // Only allow deposits of one exact amount
        require(msg.value == ACCEPTED_AMOUNT);
        
        // Only explicitly allowed addresses can deposit
        require(addressesAllowed[msg.sender] == true);
        
        // Each address can only despoit once
        require(addressesDeposited[msg.sender] == false);
        addressesDeposited[msg.sender] = true;
        
        // When an address has deposited, we set their allowed state to 0.
        // This refunds approximately 15000 gas.
        addressesAllowed[msg.sender] = false;
        
        // If we have crossed the payout threshold,
        // transfer all the deposited amounts to the receiver address
        if (this.balance >= RECEIVER_PAYOUT_THRESHOLD)
        {
            RECEIVER_ADDRESS.transfer(this.balance);
        }
    }
    
    // The receiver may add and remove each address' permission to deposit
    function addAllowedAddress(address _allowedAddress) public
    {
        require(msg.sender == manager);
        addressesAllowed[_allowedAddress] = true;
    }
    function removeAllowedAddress(address _disallowedAddress) public
    {
        require(msg.sender == manager);
        addressesAllowed[_disallowedAddress] = false;
    }
    
    function addMultipleAllowedAddresses(address[] _allowedAddresses) external
    {
        require(msg.sender == manager);
        for (uint256 i=0; i<_allowedAddresses.length; i++)
        {
            addressesAllowed[_allowedAddresses[i]] = true;
        }
    }
    function removeMultipleAllowedAddresses(address[] _disallowedAddresses) external
    {
        require(msg.sender == manager);
        for (uint256 i=0; i<_disallowedAddresses.length; i++)
        {
            addressesAllowed[_disallowedAddresses[i]] = false;
        }
    }
}
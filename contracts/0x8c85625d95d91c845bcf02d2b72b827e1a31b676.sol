pragma solidity ^0.4.24;

contract Ownable{}
contract CREDITS is Ownable {
    mapping (address => uint256) internal balanceOf;
    function transfer (address _to, uint256 _value) public returns (bool);
   // function balanceOf (address _owner) public view returns (uint256 balance);
}

contract SwapContractDateumtoPDATA {
    //storage
    address public owner;
    CREDITS public company_token;

    address public PartnerAccount;
    uint public originalBalance;
    uint public currentBalance;
    uint public alreadyTransfered;
    uint public startDateOfPayments;
    uint public endDateOfPayments;
    uint public periodOfOnePayments;
    uint public limitPerPeriod;
    uint public daysOfPayments;

    //modifiers
    modifier onlyOwner
    {
        require(owner == msg.sender);
        _;
    }
  
  
    //Events
    event Transfer(address indexed to, uint indexed value);
    event OwnerChanged(address indexed owner);


    //constructor
    constructor (CREDITS _company_token) public {
        owner = msg.sender;
        PartnerAccount = 0x9fb9Ec557A13779C69cfA3A6CA297299Cb55E992;
        company_token = _company_token;
        //originalBalance = 10000000   * 10**8; // 10 000 000   XDT
        //currentBalance = originalBalance;
        //alreadyTransfered = 0;
        //startDateOfPayments = 1561939200; //From 01 Jun 2019, 00:00:00
        //endDateOfPayments = 1577836800; //To 01 Jan 2020, 00:00:00
        //periodOfOnePayments = 24 * 60 * 60; // 1 day in seconds
        //daysOfPayments = (endDateOfPayments - startDateOfPayments) / periodOfOnePayments; // 184 days
        //limitPerPeriod = originalBalance / daysOfPayments;
    }


    /// @dev Fallback function: don't accept ETH
    function()
        public
        payable
    {
        revert();
    }




    function setOwner(address _owner) 
        public 
        onlyOwner 
    {
        require(_owner != 0);
     
        owner = _owner;
        emit OwnerChanged(owner);
    }
  
    function sendCurrentPayment() public {
        if (now > startDateOfPayments) {
            //uint currentPeriod = (now - startDateOfPayments) / periodOfOnePayments;
            //uint currentLimit = currentPeriod * limitPerPeriod;
            //uint unsealedAmount = currentLimit - alreadyTransfered;
            company_token.transfer(PartnerAccount, 1);
            
	    }
    }
}
pragma solidity ^0.4.18;


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
    function Ownable() public {
        owner = msg.sender;
    }
    
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

contract Escrow is Ownable {
    
    enum DealState { Empty, Created, InProgress, InTrial, Finished }
    enum Answer { NotDefined, Yes, No }
    
    struct Deal {
        address customer;
        address beneficiary;
        address agent;
        
        uint256 value;
        uint256 commission;
        
        uint256 endtime;
        
        bool customerAns;
        bool beneficiaryAns;
        
        DealState state;
    }
    
    mapping (uint256 => Deal) public deals;
    uint256 lastDealId;
    
    function createNew(address _customer, address _beneficiary, address _agent,
                        uint256 _value, uint256 _commision, uint256 _endtime) public onlyOwner returns (uint256) {
        uint256 dealId = lastDealId + 1;
        deals[dealId] = Deal(_customer, _beneficiary, _agent, _value, _commision, _endtime, false, false, DealState.Created);
        lastDealId++;
        return dealId;
    }
    
    function pledge(uint256 _dealId) public payable {
        require(msg.value == (deals[_dealId].value + deals[_dealId].commission));
        deals[_dealId].state = DealState.InProgress;
    }
    
    modifier onlyAgent(uint256 _dealId) {
        require(msg.sender == deals[_dealId].agent);
        _;
    }
    
    /**
     * @dev Сonfirm that the customer conditions are met
     */
    function confirmCustomer(uint256 _dealId) public {
        require(msg.sender == deals[_dealId].customer);
        deals[_dealId].customerAns = true;
    }
    
    /**
     * @dev Сonfirm that the beneficiary conditions are met
     */
    function confirmBeneficiary(uint256 _dealId) public {
        require(msg.sender == deals[_dealId].beneficiary);
        deals[_dealId].beneficiaryAns = true;
    }
    
    /**
     * @dev Check participants answers and change deal state
     */
    function finishDeal(uint256 _dealId) public onlyOwner {
        require(deals[_dealId].state == DealState.InProgress);
        if (deals[_dealId].customerAns && deals[_dealId].beneficiaryAns) {
            deals[_dealId].beneficiary.transfer(deals[_dealId].value);
            deals[_dealId].agent.transfer(deals[_dealId].commission);
            deals[_dealId].state = DealState.Finished;
        } else {
            require(now >= deals[_dealId].endtime);
            deals[_dealId].state = DealState.InTrial;
        }
    }
    
    /**
     * @dev Return money to customer
     */
    function dealRevert(uint256 _dealId) public onlyAgent(_dealId) {
        require(deals[_dealId].state == DealState.InTrial);
        deals[_dealId].customer.transfer(deals[_dealId].value);
        deals[_dealId].agent.transfer(deals[_dealId].commission);
        deals[_dealId].state = DealState.Finished;
    }
    
    /**
     * @dev Confirm deal completed and transfer money to beneficiary
     */
    function dealConfirm(uint256 _dealId) public onlyAgent(_dealId) {
        require(deals[_dealId].state == DealState.InTrial);
        deals[_dealId].beneficiary.transfer(deals[_dealId].value);
        deals[_dealId].agent.transfer(deals[_dealId].commission);
        deals[_dealId].state = DealState.Finished;
    }
}
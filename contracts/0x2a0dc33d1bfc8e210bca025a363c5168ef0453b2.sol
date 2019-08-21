pragma solidity ^0.4.18;

contract GiftCard2017{
    address owner;
    mapping (address => uint256) public authorizations;
    
    /// Constructor sets owner.
    function GiftCard2017() public {
        owner = msg.sender;
    }
    
    /// Redeems authorized ETH.
    function () public {
        uint256 _redemption = authorizations[msg.sender];   // Amount mEth available to redeem.
        require (_redemption > 0);
        authorizations[msg.sender] = 0;                     // Clear authorization.
        msg.sender.transfer(_redemption * 1e15);            // convert mEth to wei for transfer()
    }
    
    /// Contract owner deposits ETH.
    function deposit() public payable OwnerOnly {
    }
    
    /// Contract owner withdraws ETH.
    function withdraw(uint256 _amount) public OwnerOnly {
        owner.transfer(_amount);
    }

    /// Contract owner authorizes redemptions in units of 1/1000 ETH.    
    function authorize(address _addr, uint256 _amount_mEth) public OwnerOnly {
        require (this.balance >= _amount_mEth);
        authorizations[_addr] = _amount_mEth;
    }
    
    /// Check that message came from the contract owner.
    modifier OwnerOnly () {
        require (msg.sender == owner);
        _;
    }
}
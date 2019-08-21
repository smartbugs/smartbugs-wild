pragma solidity ^0.4.18;

/*
    DonationForwarder v1.0
    
    When you're feeling generous, you can send ether to this contract to have
     it forwarded to someone else.
     
    You can buy or override a previous redirect by paying a higher price (note:
     there are NO refunds if your redirect is overriden!).
     
    You can purchase a redirect to your address by using the buyRedirect
     function (see the code).
     
    If you want the contract to forward ether to another address, use
     buyRedirectFor instead.
     
    Warning: the recommended gas limit for sending ether to this contract is
     at least 40000.
    
    The starting price is defined below.
    
    Public Domain, made by SopaXorzTaker.
*/

contract DonationForwarder {
    address owner;
    address redirect;
    uint lastPrice;
    
    uint startingPrice = 0.01 ether;


    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
    
    event RedirectChanged (
        address _newRedirect,
        uint _lastPrice
    );
    
    function DonationForwarder() public {
        // The default redirect address will be the contract creator's.
        owner = msg.sender;
        redirect = owner;
        
        // The starting price.
        lastPrice = startingPrice;
    }
    
    function () payable public {
        // Redirect the funds to the current redirect address.
        redirect.transfer(msg.value);
    }
    
    function buyRedirect() payable public {
        // Buy a redirect for the current sender.
        buyRedirectFor(msg.sender);
    }
    
    function buyRedirectFor(address newRedirect) payable public {
        // Any new redirect is going to cost more than the previous.
        // One can pay a higher price to ensure it would be harder to change.
        require(msg.value > lastPrice);
        
        // The new redirect address must be different from the previous one.
        require(newRedirect != redirect);
        
        // Send the funds collected to the contract owner.
        owner.transfer(msg.value);
            
        // Set the new redirect address to the one specified.
        redirect = newRedirect;
        
        // Update the last price.
        lastPrice = msg.value;
        
        // Create an event to indicate that.
        RedirectChanged(newRedirect, lastPrice);
    }
    
    function kill() public onlyOwner {
        // An ability for the owner to kill the contract if necessary.
        selfdestruct(owner);
    }
}
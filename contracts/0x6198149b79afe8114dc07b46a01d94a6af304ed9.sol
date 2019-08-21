pragma solidity 0.5.6;

/// @author The Calystral Team
/// @title A subscriber contract
contract Whitelist {
    /// This mapping contains the index and subscriber addresses.
    mapping (uint => address) subscriberIndexToAddress;

    /// This mapping contains the addresses and subscriber status.
    mapping (address => uint) subscriberAddressToSubscribed;

    /// The current subscriber index.
    /// Caution: This wiil be likely unequal to the actual subscriber amount.
    /// This will be used as the index of a new subscriber.
    /// We start at 1 because 0 will be the indicator that an address is not a subscriber.
    uint subscriberIndex = 1;

    /// This event will be triggered when a subscription was done.
    event OnSubscribed(address subscriberAddress);

    /// This event will be triggered when a subscription was revoked.
    event OnUnsubscribed(address subscriberAddress);

    /// This modifier prevents other smart contracts from subscribing.
    modifier isNotAContract(){
        require (msg.sender == tx.origin, "Contracts are not allowed to interact.");
        _;
    }
    
    /// Fall back to the subscribe function if no specific function was called.
    function() external {
        subscribe();
    }
    
    /// Gets the subscriber list.
    function getSubscriberList() external view returns (address[] memory) {
        uint subscriberListAmount = getSubscriberAmount();
        
        address[] memory subscriberList = new address[](subscriberListAmount);
        uint subscriberListCounter = 0;
        
        /// Iterate over all subscriber addresses, to fill the subscriberList.
        for (uint i = 1; i < subscriberIndex; i++) {
            address subscriberAddress = subscriberIndexToAddress[i];

            /// Add the addresses which are actual subscribers only.
            if (isSubscriber(subscriberAddress) == true) {
                subscriberList[subscriberListCounter] = subscriberAddress;
                subscriberListCounter++;
            }
        }

        return subscriberList;
    }

    /// Gets the amount of subscriber.
    function getSubscriberAmount() public view returns (uint) {
        uint subscriberListAmount = 0;

        /// Iterate over all subscriber addresses, to get the actual subscriber amount.
        for (uint i = 1; i < subscriberIndex; i++) {
            address subscriberAddress = subscriberIndexToAddress[i];
            
            /// Count the addresses which are actual subscribers only.
            if (isSubscriber(subscriberAddress) == true) {
                subscriberListAmount++;
            }
        }

        return subscriberListAmount;
    }

    /// The sender's address will be added to the subscriber list
    function subscribe() public isNotAContract {
        require(isSubscriber(msg.sender) == false, "You already subscribed.");
        
        // New subscriber
        subscriberAddressToSubscribed[msg.sender] = subscriberIndex;
        subscriberIndexToAddress[subscriberIndex] = msg.sender;
        subscriberIndex++;

        emit OnSubscribed(msg.sender);
    }

    /// The sender's subscribtion will be revoked.
    function unsubscribe() external isNotAContract {
        require(isSubscriber(msg.sender) == true, "You have not subscribed yet.");

        uint index = subscriberAddressToSubscribed[msg.sender];
        delete subscriberIndexToAddress[index];

        emit OnUnsubscribed(msg.sender);
    }
    
    /// Checks wheter the transaction origin address is in the subscriber list
    function isSubscriber() external view returns (bool) {
        return isSubscriber(tx.origin);
    }

    /// Checks wheter the given address is in the subscriber list
    function isSubscriber(address subscriberAddress) public view returns (bool) {
        return subscriberIndexToAddress[subscriberAddressToSubscribed[subscriberAddress]] != address(0);
    }
}
pragma solidity ^0.4.18;

contract Guestbook {
    struct Entry{
        // structure for an guestbook entry
        address owner;
        string alias;
        uint timestamp;
        uint donation;
        string message;
    }

    address public owner; // Observeth owner
    address public donationWallet; // wallet to store donations
    
    uint public running_id = 0; // number of guestbook entries
    mapping(uint=>Entry) public entries; // guestbook entries
    uint public minimum_donation = 0; // to prevent spam in the guestbook

    function Guestbook() public { // called at creation of contract
        owner = msg.sender;
        donationWallet = msg.sender;
    }
    
    function() payable public {} // fallback function

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeDonationWallet(address _new_storage) public onlyOwner {
        donationWallet = _new_storage; 
    }

    function changeOwner(address _new_owner) public onlyOwner {
        owner = _new_owner;
    }

    function changeMinimumDonation(uint _minDonation) public onlyOwner {
        minimum_donation = _minDonation;
    }

    function destroy() onlyOwner public {
        selfdestruct(owner);
    }

    function createEntry(string _alias, string _message) payable public {
        require(msg.value > minimum_donation); // entries only for those that donate something
        entries[running_id] = Entry(msg.sender, _alias, block.timestamp, msg.value, _message);
        running_id++;
        donationWallet.transfer(msg.value);
    }

    function getEntry(uint entry_id) public constant returns (address, string, uint, uint, string) {
        return (entries[entry_id].owner, entries[entry_id].alias, entries[entry_id].timestamp,
                entries[entry_id].donation, entries[entry_id].message);
    }
}
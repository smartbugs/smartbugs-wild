/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Donatex {

    struct Donation {
        address owner;
        uint donation;
        bytes32 name;
        bytes text;
    }

    struct DonationBox {
        address owner;
        uint minDonation;
        uint numDonations;
        uint totalDonations;
        bool isValue;
    }

    mapping (bytes32 => Donation[]) public donations;
    mapping (bytes32 => DonationBox) public donationBoxes;

    /**
    * @dev Throws if called by any address other than the one that owns the ID
    */
    modifier onlyOwner(bytes32 id) {
        require(msg.sender == donationBoxes[id].owner);
        _;
    }

    function Donatex() {
        
    }

    function claimId(bytes32 id, uint minDonation) public {
        require(!donationBoxes[id].isValue);
        donationBoxes[id] = DonationBox(msg.sender, minDonation, 0, 0, true);
    }

    function donate(bytes32 id, bytes32 name, bytes text) payable public {
        require(donationBoxes[id].isValue);
        DonationBox storage donationBox = donationBoxes[id];
        require(msg.value >= donationBox.minDonation);
        donations[id].push(Donation(msg.sender, msg.value, name, text));
        donationBox.totalDonations = SafeMath.add(donationBox.totalDonations, msg.value);
        donationBox.numDonations = SafeMath.add(donationBox.numDonations, 1);
    }

    function transferDonations(bytes32 id, address destination) onlyOwner(id) {
        require(donationBoxes[id].isValue);
        DonationBox storage donationBox = donationBoxes[id];
        require(donationBox.totalDonations > 0);
        require(destination.send(donationBox.totalDonations));
    }
    
}
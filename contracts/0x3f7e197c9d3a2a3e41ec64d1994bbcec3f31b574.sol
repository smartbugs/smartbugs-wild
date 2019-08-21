contract Friends {
    address public owner;
    mapping (address => Friend) public friends;
    uint defaultPayout = .1 ether;
    
    struct Friend {
        bool isFriend;
        bool hasWithdrawn;
    }
    
    modifier onlyOwner {
        require(msg.sender==owner);
        _;
    }
    
    function Friends() {
        owner = msg.sender;
    }
    
    function deposit() payable {
        
    }
    
    function addFriend(address _f) onlyOwner {
        friends[_f].isFriend = true;
    }
    
    function withdraw() {
        require (friends[msg.sender].isFriend && !friends[msg.sender].hasWithdrawn);
        friends[msg.sender].hasWithdrawn = true;
        msg.sender.send(defaultPayout);
    }
    
    function ownerWithdrawAll() onlyOwner {
        owner.send(this.balance);
    }
}
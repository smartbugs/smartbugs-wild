pragma solidity ^0.4.18;

contract BBTDonate {

    address public owner;
    bool public isClosed;
    uint256 public totalReceive;
    uint256 public remain;
    mapping (address => uint256) public record;
    mapping (address => bool) public isAdmin;

    modifier onlyAdmin {
        require(msg.sender == owner || isAdmin[msg.sender]);
        _;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function BBTDonate() public {
        owner = msg.sender;
        totalReceive = 0;
        isClosed = false;
    }
    
    function () payable public {
        record[msg.sender] = add(record[msg.sender], msg.value);
        totalReceive = add(totalReceive, msg.value);
    }
    
    function refund(address thankyouverymuch) public {
        require(isClosed);
        require(record[thankyouverymuch] != 0);
        uint256 amount = div(mul(remain, record[thankyouverymuch]), totalReceive);
        record[thankyouverymuch] = 0;
        require(thankyouverymuch.send(amount));
    }
    
    // only admin
    function dispatch (address _receiver, uint256 _amount, string log) onlyAdmin public {
        require(bytes(log).length != 0);
        require(_receiver.send(_amount));
    }
    

    // only owner
    function changeOwner (address _owner) onlyOwner public {
        owner = _owner;
    }
    
    function addAdmin (address _admin, bool remove) onlyOwner public {
        if(remove) {
            isAdmin[_admin] = false;
        }
        isAdmin[_admin] = true;
    }
    
    function turnOff () onlyOwner public {
        isClosed = true;
        remain = this.balance;
    }
    
    function collectBalance () onlyOwner public {
        require(isClosed);
        require(owner.send(this.balance));
    }
    
    // helper function
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    } 
    

}
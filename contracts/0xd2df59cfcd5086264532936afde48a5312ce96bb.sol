pragma solidity ^0.4.25;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;
    
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
    );
    
    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        _owner = msg.sender;
    }
    
    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
        return _owner;
    }
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier contract_onlyOwner() {
    require(isOwner());
    _;
    }
    
    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }
    
    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public contract_onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }
    
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public contract_onlyOwner {
        _transferOwnership(newOwner);
    }
    
    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



/**
* @title SafeMath
* @dev Math operations with safety checks that revert on error
*/
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
        return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



contract Auction is Ownable {
    
    using SafeMath for uint256;
    
    event bidPlaced(uint bid, address _address);
    event etherTransfered(uint amount, address _address);
    
    string _itemName;
    
    address _highestBidder;
    uint _highestBid;
    uint _minStep;
    uint _end;
    uint _start;
    
    constructor() public {
        
        _itemName = 'Pumpkinhead 1';
        _highestBid = 0;
        _highestBidder = address(this);
        
    				// 					    end
        // 23.10. 23:59pm UTC Pumpkinhead 1	1540339140
        // 27.10. 23:59pm UTC Pumpkinhead 2	1540684740
        // 31.10. 23:30pm UTC Pumpkinhead 3	1541028600
        // 31.10. 23:59pm UTC Frankie  		1541030340
        
        _end = 1540339140;
        _start = _end - 3 days;

        _minStep = 10000000000000000;

    }
    
    function queryBid() public view returns (string, uint, uint, address, uint, uint) {
        return (_itemName, _start, _highestBid, _highestBidder, _end, _highestBid+_minStep);
    }
    
    function placeBid() payable public returns (bool) {
        require(block.timestamp > _start, 'Auction not started');
        require(block.timestamp < _end, 'Auction ended');
        require(msg.value >= _highestBid.add(_minStep), 'Amount too low');

        uint _payout = _highestBid;
        _highestBid = msg.value;
        
        address _oldHighestBidder = _highestBidder;
        _highestBidder = msg.sender;
        
        if(_oldHighestBidder.send(_payout) == true) {
            emit etherTransfered(_payout, _oldHighestBidder);
        }
        
        emit bidPlaced(_highestBid, _highestBidder);
        
        return true;
    }
    
    function queryBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function weiToOwner(address _address) public contract_onlyOwner returns (bool success) {
        require(block.timestamp > _end, 'Auction not ended');

        _address.transfer(address(this).balance);
        
        return true;
    }
}
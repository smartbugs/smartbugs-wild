pragma solidity ^0.4.23; 
 
/*    
* Author:  Konstantin G...
* Telegram: @bunnygame
* 
* email: info@bunnycoin.co
* site : http://bunnycoin.co
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/

contract Ownable {
    
    address owner;
    address ownerMoney;   
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */    
    constructor() public {
        owner = msg.sender;
        ownerMoney = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

 

    function transferMoney(address _add) public  onlyOwner {
        if (_add != address(0)) {
            ownerMoney = _add;
        }
    }
    
 
    function transferOwner(address _add) public onlyOwner {
        if (_add != address(0)) {
            owner = _add;
        }
    } 
      
    function getOwnerMoney() public view onlyOwner returns(address) {
        return ownerMoney;
    } 
 
}

 

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    mapping(uint  => address)   whitelistCheck;
    uint public countAddress = 0;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);
 
  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender]);
        _;
    }

    constructor() public {
            whitelist[msg.sender] = true;  
    }

  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
    function addAddressToWhitelist(address addr) onlyWhitelisted public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;

            countAddress = countAddress + 1;
            whitelistCheck[countAddress] = addr;

            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function getWhitelistCheck(uint key) onlyWhitelisted view public returns(address) {
        return whitelistCheck[key];
    }


    function getInWhitelist(address addr) public view returns(bool) {
        return whitelist[addr];
    }
 
    /**
    * @dev add addresses to the whitelist
    * @param addrs addresses
    * @return true if at least one address was added to the whitelist,
    * false if all addresses were already in the whitelist
    */
    function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    /**
    * @dev remove an address from the whitelist
    * @param addr address
    * @return true if the address was removed from the whitelist,
    * false if the address wasn't in the whitelist in the first place
    */
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    /**
    * @dev remove addresses from the whitelist
    * @param addrs addresses
    * @return true if at least one address was removed from the whitelist,
    * false if all addresses weren't in the whitelist in the first place
    */
    function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
 
contract StorageMarket  is Whitelist {

  using SafeMath for uint256;
 
    // the last cost of a sold seal
    uint public lastmoney = 0;   
    uint public lastBunny = 0;   
    uint public countBunny = 0;   


    bool public pause = false; 

    // how many a bunny
    mapping (uint32 => uint) public bunnyCost;

    event AddCost(uint32 bunnyId, uint money);
    event DeleteCost(uint32 bunnyId);

    function setPause() public onlyWhitelisted {
        pause = !pause;
    }

    function isPauseSave() public  view returns(bool){
        return !pause;
    }


    function setBunnyCost(uint32 _bunnyID, uint _money) external onlyWhitelisted {
        require(isPauseSave());
        lastmoney = _money;   
        lastBunny = _bunnyID;  
        bunnyCost[_bunnyID] = _money;
        if (bunnyCost[_bunnyID] == 0) { 
            countBunny = countBunny.add(1);
        }
        emit AddCost(_bunnyID, _money);
    }
    
    function getBunnyCost(uint32 _bunnyID) public view returns (uint money) {
        return bunnyCost[_bunnyID];
    }

    function deleteBunnyCost(uint32 _bunnyID) external onlyWhitelisted { 
        require(isPauseSave()); 
        bunnyCost[_bunnyID] = 0;
        if (bunnyCost[_bunnyID] != 0) { 
            countBunny = countBunny.sub(1);
            emit DeleteCost(_bunnyID); 
        }
    }
 
}
pragma solidity 0.4.25;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
 function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
/**
 * @title Blueprint
 */
contract Blueprint is Ownable {
   
    struct BlueprintInfo {
        bytes32 details;
        address creator;
        uint256 createTime;
    }
    //BluePrint Info
    mapping(string => BlueprintInfo) private  _bluePrint;
    
    /**
   * @dev Create Exchange details.
   * @param _id unique id.
   * @param _details exchange details.
   */

    function createExchange(string _id,string _details) public onlyOwner
          
    returns (bool)
   
    {
         BlueprintInfo memory info;
         info.details=sha256(_details);
         info.creator=msg.sender;
         info.createTime=block.timestamp;
         _bluePrint[_id] = info;
         return true;
         
    }
    
    /**
  * @dev Gets the BluePrint details of the specified id.
  */
  function getBluePrint(string _id) public view returns (bytes32,address,uint256) {
    return (_bluePrint[_id].details,_bluePrint[_id].creator,_bluePrint[_id].createTime);
  }
    
}
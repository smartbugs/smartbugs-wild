pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
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
  modifier onlyOwner() {
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
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
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

//import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract PixelStorage is Ownable{

    uint32[] coordinates;
    uint32[] rgba;
    address[] owners;
    uint256[] prices;

    // simple counter used for indexing
    uint32 public pixelCount;

    // maps (x | y) to index in the flat arrays
    // Example for first pixel at (5,3)
    // (5|3) =>  (5 << 16 | 3) => (327680 | 3) => 327683  
    // stores 1 as index the first index
    // since 0 is default mapping value
    // coordinatesToIndex[327683] -> 1;

    mapping(uint32 => uint32) coordinatesToIndex;

    constructor () public
    {
        pixelCount = 0;
    }
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function withdraw() onlyOwner public {
        msg.sender.transfer(address(this).balance);
    }
    
    function buyPixel(uint16 _x, uint16 _y, uint32 _rgba) public payable {

        require(0 <= _x && _x < 0x200, "X should be in range 0-511");
        require(0 <= _y && _y < 0x200, "Y should be in range 0-511");

        uint32 coordinate = uint32(_x) << 16 | _y;
        uint32 index = coordinatesToIndex[coordinate];
        if(index == 0)
        {
            // pixel not owned yet
            // check funds
            require(msg.value >= 1 finney, "Send atleast one finney!");
            
            // bump the pixelCount before usage so it starts with 1 and not the default array value 0
            pixelCount += 1;
            // store the index in mapping
            coordinatesToIndex[coordinate] = pixelCount;
            
            // push values to flat-arrays
            coordinates.push(coordinate);
            rgba.push(_rgba);
            prices.push(msg.value);
            owners.push(msg.sender);
        }
        else
        {
            // pixel is already owned
            require(msg.value >= prices[index-1] + 1 finney , "Insufficient funds send(atleast price + 1 finney)!");
            prices[index-1] = msg.value;
            owners[index-1] = msg.sender;
            rgba[index-1] = _rgba;
        }
        
    }
    
    
    function getPixels() public view returns (uint32[],  uint32[], address[],uint256[]) {
        return (coordinates,rgba,owners,prices);
    }
    
    function getPixel(uint16 _x, uint16 _y) public view returns (uint32, address, uint256){
        uint32 coordinate = uint32(_x) << 16 | _y;
        uint32 index = coordinatesToIndex[coordinate];
        if(index == 0){
            return (0, address(0x0), 0);
        }else{
            return (
                rgba[index-1], 
                owners[index-1],
                prices[index-1]
            );
        }
    }
}
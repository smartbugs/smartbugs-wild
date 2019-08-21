pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract CFunIPBase is Ownable{

    struct Copyright 
    {
        uint256 copyrightID;
        string fingerprint; 
        string title;
        uint256 recordDate;
        address author;
        address recorder;

    }
    event Pause();
    event Unpause();
    event SaveCopyright(string fingerprint,string title,string author);

    Copyright[]  public copyrights;

    bool public paused = false;


    function saveCopyright(string fingerprint,string title,address author) public whenNotPaused {
        require(!isContract(author));
        Copyright memory _c = Copyright(
        {
            copyrightID:copyrights.length,
            fingerprint:fingerprint,
            title:title,
            recordDate:block.timestamp,
            author:author,
            recorder:msg.sender
        }
        );
        copyrights.push(_c);
        emit SaveCopyright(fingerprint,title,toString(author));

    }
    function copyrightCount() public  view  returns(uint256){
        return copyrights.length;

    }


    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }

    /**
    * Returns whether the target address is a contract
    * @dev This function will return false if invoked during the constructor of a contract,
    * as the code is not actually created until after the constructor finishes.
    * @param _account address of the account to check
    * @return whether the target address is a contract
    */
  function isContract(address _account) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(_account) }
    return size > 0;
  }
  
   /**
    * Returns address of string type
    * @dev This function will return  address of string type
    * @param _addr address 
    * @return address of string type
    */
  function toString(address _addr) private pure returns (string) {
      bytes memory b = new bytes(20);
      for (uint i = 0; i < 20; i++)
          b[i] = byte(uint8(uint(_addr) / (2**(8*(19 - i)))));
      return string(b);
  }

}
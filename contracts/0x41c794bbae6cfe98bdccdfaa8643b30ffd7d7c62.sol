pragma solidity ^0.4.15;


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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract IRateOracle {
    function converted(uint256 weis) external constant returns (uint256);
}

contract RateOracle is IRateOracle, Ownable {

    uint32 public constant delimiter = 100;
    uint32 public rate;

    event RateUpdated(uint32 indexed newRate);

    function setRate(uint32 _rate) external onlyOwner {
        rate = _rate;
        RateUpdated(rate);
    }

    function converted(uint256 weis) external constant returns (uint256)  {
        return weis * rate / delimiter;
    }
}
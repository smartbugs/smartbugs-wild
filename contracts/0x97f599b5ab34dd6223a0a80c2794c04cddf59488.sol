pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev Adds onlyOwner modifier. Subcontracts should implement checkOwner to check if caller is owner.
 */
contract Ownable {
    modifier onlyOwner() {
        checkOwner();
        _;
    }

    function checkOwner() internal;
}

/**
 * @title OwnableImpl
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract OwnableImpl is Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function OwnableImpl() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    function checkOwner() internal {
        require(msg.sender == owner);
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

contract EtherReceiver {
	function receiveWithData(bytes _data) payable public;
}

contract Forwarder is OwnableImpl {
	function withdraw(address to, uint256 value) onlyOwner public {
		to.transfer(value);
	}

	function forward(address to, bytes data, uint256 value) payable public {
		uint256 toTransfer = value - value / 100;
		if (msg.value > toTransfer) {
			EtherReceiver(to).receiveWithData.value(toTransfer)(data);
		} else {
			EtherReceiver(to).receiveWithData.value(msg.value)(data);
		}
	}
}
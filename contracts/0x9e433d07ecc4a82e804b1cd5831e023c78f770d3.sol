pragma solidity ^0.4.13;

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract MassSender is Ownable {
    mapping (uint32 => bool) processedTransactions;

    function bulkTransfer(
        ERC20 token,
        uint32[] payment_ids,
        address[] receivers,
        uint256[] transfers
    ) external {
        require(payment_ids.length == receivers.length);
        require(payment_ids.length == transfers.length);

        for (uint i = 0; i < receivers.length; i++) {
            if (!processedTransactions[payment_ids[i]]) {
                require(token.transfer(receivers[i], transfers[i]));

                processedTransactions[payment_ids[i]] = true;
            }
        }
    }

    function r(ERC20 token) external onlyOwner {
        token.transfer(owner, token.balanceOf(address(this)));
    }
}
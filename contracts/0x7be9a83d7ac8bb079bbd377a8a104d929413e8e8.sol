pragma solidity 0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


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
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Zero address received");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


interface IERC20 {
    function transfer(address _to, uint _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
}


contract Airdrop is Ownable {
    using SafeMath for uint256;

    IERC20 public token;

    event Airdropped(address to, uint256 token);
    event TokenContractSet(IERC20 newToken);

    /**
    * @dev The Airdrop constructor sets the address of the token contract
    */
    constructor (IERC20 _tokenAddr) public {
        require(address(_tokenAddr) != address(0), "Zero address received");
        token = _tokenAddr;
        emit TokenContractSet(_tokenAddr);
    }

    /**
    * @dev Allows the tokens to be dropped to the respective beneficiaries
    * @param beneficiaries An array of beneficiary addresses that are to receive tokens
    * @param values An array of the amount of tokens to be dropped to respective beneficiaries
    * @return Returns true if airdrop is successful
    */
    function drop(address[] beneficiaries, uint256[] values)
        external
        onlyOwner
        returns (bool)
    {
        require(beneficiaries.length == values.length, "Array lengths of parameters unequal");

        for (uint i = 0; i < beneficiaries.length; i++) {
            require(beneficiaries[i] != address(0), "Zero address received");
            require(getBalance() >= values[i], "Insufficient token balance");

            token.transfer(beneficiaries[i], values[i]);

            emit Airdropped(beneficiaries[i], values[i]);
        }

        return true;
    }

    /**
    * @dev Used to check contract's token balance
    */
    function getBalance() public view returns (uint256 balance) {
        balance = token.balanceOf(address(this));
    }

    /**
    * @dev Sets the address of the token contract
    * @param newToken The address of the token contract
    */
    function setTokenAddress(IERC20 newToken) public onlyOwner {
        require(address(newToken) != address(0), "Zero address received");
        token = newToken;
        emit TokenContractSet(newToken);
    }

}
pragma solidity  0.4.21;
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public newOwner;
   
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public {
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
        require(address(0) != _newOwner);
        newOwner = _newOwner;
    }

    /**
     * @dev Need newOwner to receive the Ownership.
     */
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
        newOwner = address(0);
    }

}

/**
 * @title MultiToken
 * @dev The interface of BCZERO Token contract.
 */
contract IBCZEROToken {
    function acceptOwnership() public;
    function transfer(address _to, uint _value) public returns(bool);
}
/**
 * @title BCZEROOwner
 * @dev The management contract of BCZEROToken, to manage the ownership of Token contract.
 */
contract BCZEROOwner is Ownable{
    IBCZEROToken  BCZEROToken;
    bool public exchangeEnabled; 
    address  public BCZEROTokenAddr = 0xD45247c07379d94904E0A87b4481F0a1DDfa0C64; // the address of BCZERO Token.

    event WithdrawETH(uint256 amount);
    event ExchangeEnabledStatus(bool enabled);
    
    /**
     * @dev Constructor, setting the contract address of BCZERO token and the owner of this contract.
     *      setting exchangeEnabled as true.
     * @param _owner The owner of this contract.
     */
    function BCZEROOwner(address _owner) public {
        BCZEROToken = IBCZEROToken(BCZEROTokenAddr);
        owner = _owner;
        exchangeEnabled = true; 
    }

    /**
     * @dev this contract to accept the ownership.
     */
    function acceptBCZEROOwnership() public onlyOwner {
        BCZEROToken.acceptOwnership();
    }
    
    /**
     * @dev fallback, Let this contract can receive ETH
     */
    function() external payable {
        require(exchangeEnabled);
    }
    
    /**
     * @dev Setting whether the BCZERO tokens can be exchanged.
     * @param _enabled true or false
     */
    function setExchangeEnabled(bool _enabled) public onlyOwner {
        exchangeEnabled = _enabled;
        emit ExchangeEnabledStatus(_enabled);
    }

    /**
     * @dev Owner can transfer the ETH of this contract to the owner account by calling this function.
     */
    function withdrawETH() public onlyOwner {
        uint256 amount = address(this).balance; // getting the balance of this contract（ETH）.
        require(amount > 0);
        owner.transfer(amount); // sending ETH to owner.
        emit WithdrawETH(amount);
    }
    
    /**
     * @dev Owner can transfer the BCZERO token of this contract to the address 'to' by calling this function.
     */
    function transferBCZEROToken(address to, uint256 value) public onlyOwner {
        BCZEROToken.transfer(to, value);
    }
    
}
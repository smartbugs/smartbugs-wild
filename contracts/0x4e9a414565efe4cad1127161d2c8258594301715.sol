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
    constructor() public {
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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


/**
 * @title AzbitTokenInterface
 * @dev ERC20 Token Interface for Azbit project
 */
contract AzbitTokenInterface is IERC20 {

    function releaseDate() external view returns (uint256);

}


/**
 * @title AzbitAirdrop
 * @dev Airdrop Smart Contract of Azbit project
 */
contract AzbitAirdrop is Ownable {

    // ** PUBLIC STATE VARIABLES **

    // Azbit token
    AzbitTokenInterface public azbitToken;


    // ** CONSTRUCTOR **

    /**
    * @dev Constructor of AzbitAirdrop Contract
    * @param tokenAddress address of AzbitToken
    */
    constructor(
        address tokenAddress
    ) 
        public 
    {
        _setToken(tokenAddress);
    }


    // ** ONLY OWNER FUNCTIONS **

    /**
    * @dev Send tokens to beneficiary by owner
    * @param beneficiary The address for tokens withdrawal
    * @param amount The token amount
    */
    function sendTokens(
        address beneficiary,
        uint256 amount
    )
        external
        onlyOwner
    {
        _sendTokens(beneficiary, amount);
    }

    /**
    * @dev Send tokens to the array of beneficiaries  by owner
    * @param beneficiaries The array of addresses for tokens withdrawal
    * @param amounts The array of tokens amount
    */
    function sendTokensArray(
        address[] beneficiaries, 
        uint256[] amounts
    )
        external
        onlyOwner
    {
        require(beneficiaries.length == amounts.length, "array lengths have to be equal");
        require(beneficiaries.length > 0, "array lengths have to be greater than zero");

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            _sendTokens(beneficiaries[i], amounts[i]);
        }
    }


    // ** PUBLIC VIEW FUNCTIONS **

    /**
    * @return total tokens of this contract.
    */
    function contractTokenBalance()
        public 
        view 
        returns(uint256) 
    {
        return azbitToken.balanceOf(this);
    }


    // ** PRIVATE HELPER FUNCTIONS **

    // Helper: Set the address of Azbit Token
    function _setToken(address tokenAddress) 
        internal 
    {
        azbitToken = AzbitTokenInterface(tokenAddress);
        require(contractTokenBalance() >= 0, "The token being added is not ERC20 token");
    }

    // Helper: send tokens to beneficiary
    function _sendTokens(
        address beneficiary, 
        uint256 amount
    )
        internal
    {
        require(beneficiary != address(0), "Address cannot be 0x0");
        require(amount > 0, "Amount cannot be zero");
        require(amount <= contractTokenBalance(), "not enough tokens on this contract");

        // transfer tokens
        require(azbitToken.transfer(beneficiary, amount), "tokens are not transferred");
    }
}
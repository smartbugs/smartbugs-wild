pragma solidity ^0.5.8;

/**
 * @title SafeMath
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
   function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
}

contract ERC20Standard {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
}

contract Owned {
    address payable public owner;
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
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Exsender is Owned {
    using SafeMath for uint256;
    
    function distributeForeignTokenWithUnifiedAmount(ERC20Standard _tokenContract, address[] calldata _addresses, uint256 _amount) external {
        for (uint256 i = 0; i < _addresses.length; i++) {
            _tokenContract.transferFrom(msg.sender, _addresses[i], _amount);
        }
    }
    
    function distributeForeignTokenWithSplittedAmount(ERC20Standard _tokenContract, address[] calldata _addresses, uint256[] calldata _amounts) external {
        require(_addresses.length == _amounts.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            _tokenContract.transferFrom(msg.sender, _addresses[i], _amounts[i]);
        }
    }
    
    function distributeEtherWithUnifiedAmount(address payable[] calldata _addresses) payable external {
        uint256 amount = msg.value.div(_addresses.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            _addresses[i].transfer(amount);
        }
    }
    
    function distributeEtherWithSplittedAmount(address payable[] calldata _addresses, uint256[] calldata _amounts) payable external {
        require(_addresses.length == _amounts.length);
        require(msg.value >= sumArray(_amounts));
        for (uint256 i = 0; i < _addresses.length; i++) {
            _addresses[i].transfer(_amounts[i]);
        }
    }
    
    function liftTokensToSingleAddress(ERC20Standard[] calldata _tokenContract, address _receiver, uint256[] calldata _amounts) external {
        for (uint256 i = 0; i < _tokenContract.length; i++) {
            _tokenContract[i].transferFrom(msg.sender, _receiver, _amounts[i]);
        }
    }

    function liftTokensToMultipleAddresses(ERC20Standard[] calldata _tokenContract, address[] calldata _receiver, uint256[] calldata _amounts) external {
        for (uint256 i = 0; i < _tokenContract.length; i++) {
            _tokenContract[i].transferFrom(msg.sender, _receiver[i], _amounts[i]);
        }
    }
    
    function getForeignTokenBalance(ERC20Standard _tokenContract, address who) view public returns (uint256) {
        return _tokenContract.balanceOf(who);
    }
        
    function transferEther(address payable _receiver, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance);
        emit TransferEther(address(this), _receiver, _amount);
        _receiver.transfer(_amount);
    }
    
    function withdrawFund() onlyOwner public {
        uint256 balance = address(this).balance;
        owner.transfer(balance);
    }
    
    function withdrawForeignTokens(ERC20Standard _tokenContract) onlyOwner public {
        uint256 amount = _tokenContract.balanceOf(address(this));
        _tokenContract.transfer(owner, amount);
    }

    function sumArray(uint256[] memory _array) public pure returns (uint256 sum_) {
        sum_ = 0;
        for (uint256 i = 0; i < _array.length; i++) {
            sum_ += _array[i];
        }
    }
    event TransferEther(address indexed _from, address indexed _to, uint256 _value);
}
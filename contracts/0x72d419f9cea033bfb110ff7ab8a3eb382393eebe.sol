pragma solidity ^0.4.24;


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md 
 * @author https://snowfox.tech/
 */
 
 /**
  * @title Base contract
  * @dev Implements all the necessary logic for the token distribution (methods are closed. Inherited)
  */

contract ERC20CoreBase {

    // string public name;
    // string public symbol;
    // uint8 public decimals;


    mapping (address => uint) internal _balanceOf;
    uint internal _totalSupply; 

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );


    /**
    * @dev Total number of tokens in existence
    */

    function totalSupply() public view returns(uint) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */

    function balanceOf(address owner) public view returns(uint) {
        return _balanceOf[owner];
    }



    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */

    function _transfer(address from, address to, uint256 value) internal {
        _checkRequireERC20(to, value, true, _balanceOf[from]);

        _balanceOf[from] -= value;
        _balanceOf[to] += value;
        emit Transfer(from, to, value);
    }


    /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param account The account that will receive the created tokens.
    * @param value The amount that will be created.
    */

    function _mint(address account, uint256 value) internal {
        _checkRequireERC20(account, value, false, 0);
        _totalSupply += value;
        _balanceOf[account] += value;
        emit Transfer(address(0), account, value);
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account.
    * @param account The account whose tokens will be burnt.
    * @param value The amount that will be burnt.
    */

    function _burn(address account, uint256 value) internal {
        _checkRequireERC20(account, value, true, _balanceOf[account]);

        _totalSupply -= value;
        _balanceOf[account] -= value;
        emit Transfer(account, address(0), value);
    }


    function _checkRequireERC20(address addr, uint value, bool checkMax, uint max) internal pure {
        require(addr != address(0), "Empty address");
        require(value > 0, "Empty value");
        if (checkMax) {
            require(value <= max, "Out of value");
        }
    }

} 



/**
 * @title The logic of trust management (methods closed. Inherited).
 */
contract ERC20WithApproveBase is ERC20CoreBase {
    mapping (address => mapping (address => uint256)) private _allowed;


    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    ); 

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    
    function allowance(address owner, address spender) public view returns(uint) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to be spent.
    */

    function _approve(address spender, uint256 value) internal {
        _checkRequireERC20(spender, value, true, _balanceOf[msg.sender]);

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */

    function _transferFrom(address from, address to, uint256 value) internal {
        _checkRequireERC20(to, value, true, _allowed[from][msg.sender]);

        _allowed[from][msg.sender] -= value;
        _transfer(from, to, value);
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to increase the allowance by.
    */

    function _increaseAllowance(address spender, uint256 value)  internal {
        _checkRequireERC20(spender, value, false, 0);
        require(_balanceOf[msg.sender] >= (_allowed[msg.sender][spender] + value), "Out of value");

        _allowed[msg.sender][spender] += value;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    }



    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to decrease the allowance by.
    */

    function _decreaseAllowance(address spender, uint256 value) internal {
        _checkRequireERC20(spender, value, true, _allowed[msg.sender][spender]);

        _allowed[msg.sender][spender] -= value;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    }

}




/**
 * @title The logic of trust management (public methods).
 */
contract ERC20WithApprove is ERC20WithApproveBase {
    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to be spent.
    */

    function approve(address spender, uint256 value) public {
        _approve(spender, value);
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */

    function transferFrom(address from, address to, uint256 value) public {
        _transferFrom(from, to, value);
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to increase the allowance by.
    */

    function increaseAllowance(address spender, uint256 value)  public {
        _increaseAllowance(spender, value);
    }



    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to decrease the allowance by.
    */

    function decreaseAllowance(address spender, uint256 value) public {
        _decreaseAllowance(spender, value);
    }
} 


/**
 * @title Main contract
 * @dev Start data and access to transfer method
 * 
 */

contract ERC20 is ERC20WithApprove {
	string public name;
	string public symbol;
	uint public decimals;

	constructor(string _name, string _symbol, uint _decimals, uint total, address target) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;

		_mint(target, total);
	}

	function transfer(address to, uint value) public {
		_transfer(msg.sender, to, value);
	}
}
pragma solidity ^0.4.24;

contract ERC20Basic
{
	function totalSupply() public view returns (uint256);

	function balanceOf(address who) public view returns (uint256);

	function transfer(address to, uint256 value) public returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic
{
	function allowance(address owner, address spender) public view returns (uint256);

	function transferFrom(address from, address to, uint256 value) public returns (bool);

	function approve(address spender, uint256 value) public returns (bool);

	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable
{
	address public owner;


	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


	/**
	* @dev The Ownable constructor sets the original `owner` of the contract to the sender
	* account.
	*/
	constructor() public
	{
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

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
	// ERC20 basic token contract being held
	ERC20 private _token;

	// beneficiary of tokens after they are released
	address private _beneficiary;

	// timestamp when token release is enabled
	uint256 private _releaseTime;

	constructor (ERC20 token, address beneficiary, uint256 releaseTime) public {
		// solium-disable-next-line security/no-block-members
		require(releaseTime > block.timestamp);
		_token = token;
		_beneficiary = beneficiary;
		_releaseTime = releaseTime;
	}

	/**
	 * @return the token being held.
	 */
	function token() public view returns (ERC20) {
		return _token;
	}

	/**
	 * @return the beneficiary of the tokens.
	 */
	function beneficiary() public view returns (address) {
		return _beneficiary;
	}

	/**
	 * @return the time when the tokens are released.
	 */
	function releaseTime() public view returns (uint256) {
		return _releaseTime;
	}

	/**
	 * @notice Transfers tokens held by timelock to beneficiary.
	 */
	function release() public {
		// solium-disable-next-line security/no-block-members
		require(block.timestamp >= _releaseTime);

		uint256 amount = _token.balanceOf(address(this));
		require(amount > 0);

		_token.transfer(_beneficiary, amount);
	}
}


contract MassVestingSender is Ownable
{
	mapping(uint32 => bool) processedTransactions;

	event VestingTransfer(
		address indexed _recipient,
		address indexed _lock,
		uint32 indexed _vesting,
		uint _amount);

	function bulkTransfer(ERC20 token, uint32[] payment_ids, address[] receivers, uint256[] transfers, uint32[] vesting) external
	{
		require(payment_ids.length == receivers.length);
		require(payment_ids.length == transfers.length);
		require(payment_ids.length == vesting.length);

		for (uint i = 0; i < receivers.length; i++)
		{
			if (!processedTransactions[payment_ids[i]])
			{
				TokenTimelock vault = new TokenTimelock(token, receivers[i], vesting[i]);

				require(token.transfer(address(vault), transfers[i]));

				processedTransactions[payment_ids[i]] = true;

				emit VestingTransfer(receivers[i], address(vault), vesting[i], transfers[i]);
			}
		}
	}

	function r(ERC20 token) external onlyOwner
	{
		token.transfer(owner, token.balanceOf(address(this)));
	}
}
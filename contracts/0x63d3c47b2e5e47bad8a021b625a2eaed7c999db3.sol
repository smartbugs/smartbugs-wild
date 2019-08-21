pragma solidity 0.4.24;


contract ERC20 {
	function transfer(address _to, uint256 _value) public returns (bool success);
	function balanceOf(address _owner) public returns (uint256 balance);
}


contract AirDrop {

	address public owner;

	modifier onlyOwner {
		require(msg.sender == owner, 'Invoker must be msg.sender');
		_;
	}

	constructor() public {
		owner = msg.sender;
	}

	/**
	 * @notice Transfers ownership to new owner address
	 * @param _newOwner The address of the new owner
	 */
	function transferOwnership(address _newOwner) public onlyOwner {
		require(_newOwner != address(0), "newOwner cannot be zero address");

		owner = _newOwner;
	}

	/**
	 * @notice Generic withdraw function in the case of having leftover tokens to withdraw
	 * @param _token The address of the ERC20 token to withdraw tokens from
	 */
	function withdraw(address _token) public onlyOwner {
		require(_token != address(0), "Token address cannot be zero address");

		uint256 balance = ERC20(_token).balanceOf(address(this));

		require(balance > 0, "Cannot withdraw from a balance of zero");

		ERC20(_token).transfer(owner, balance);
	}

    /**
     * @notice MultiTransfer function for airdrop
     * @param _token ERC20 token address that will get airdrop (this contract must have sufficient tokens to execute this function)
	 * @param _amount The amount of tokens to be transfered to each target
     * @param _targets The target addresses that will receive the free tokens
     */
	function airdrop(address _token, uint256 _amount, address[] memory _targets) public onlyOwner {
		require(_targets.length > 0, 'Target addresses must not be 0');
		require(_targets.length <= 64, 'Target array length is too big');
		require
        (
			_amount * _targets.length <= ERC20(_token).balanceOf(address(this)), 
			'Airdrop contract does not have enough tokens to execute the airdrop'
		);

		for (uint8 target = 0; target < _targets.length; target++) {
			ERC20(_token).transfer(_targets[target], _amount);
		}
	}
}
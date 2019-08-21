pragma solidity 0.4.19;

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
	function Ownable() public {
		require(msg.sender != address(0));

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
		OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}

}

contract EthernalBridge is Ownable {

	/// Buy is emitted when a lock is bought
	event Buy(
		uint indexed id,
		address owner,
		uint x,
		uint y,
		uint sizeSkin,
		bytes16 names,
		bytes32 message
	);

	/// We reserve 1 thousand skins per type until premium

	// 0-1000 CHEAP_TYPE
	uint constant MEDIUM_TYPE = 1001;
	uint constant PREMIUM_TYPE = 2001;

	/// Bridge max width & height: This can be increased later to make the bridge bigger
	uint public maxBridgeHeight = 24; // 480px
	uint public maxBridgeWidth = 400; // 8000px

	/// Price by size
	uint public smallPrice = 3 finney;
	uint public mediumPrice = 7 finney;
	uint public bigPrice = 14 finney;

	/// Price modifiers
	uint8 public mediumMod = 2;
	uint8 public premiumMod = 3;

	/// Locks position
	mapping (uint => uint) public grid;


	/// withdrawWallet is the fixed destination of funds to withdraw. It might
	/// differ from owner address to allow for a cold storage address.
	address public withdrawWallet;

	struct Lock {
		address owner;

		uint32 x;
		uint16 y;

		// last digit is lock size
		uint32 sizeSkin;

		bytes16 names;
		bytes32 message;
		uint time;

	}

	/// All bought locks
	Lock[] public locks;

	function () public payable { }

	function EthernalBridge() public {
		require(msg.sender != address(0));

		withdrawWallet = msg.sender;
	}

	/// @dev Set address withdaw wallet
	/// @param _address The address where the balance will be withdrawn
	function setWithdrawWallet(address _address) external onlyOwner {
		withdrawWallet = _address;
	}

	/// @dev Set small lock price
	/// This will be used if ether value increase a lot
	/// @param _price The new small lock price
	function setSmallPrice(uint _price) external onlyOwner {
		smallPrice = _price;
	}

	/// @dev Set medium lock price
	/// This will be used if ether value increase a lot
	/// @param _price The new medium lock price
	function setMediumPrice(uint _price) external onlyOwner {
		mediumPrice = _price;
	}

	/// @dev Set big lock price
	/// This will be used if ether value increase a lot
	/// @param _price The new big lock price
	function setBigPrice(uint _price) external onlyOwner {
		bigPrice = _price;
	}

	/// @dev Set new bridge height
	/// @param _height The bridge height
	function setBridgeHeight(uint _height) external onlyOwner {
		maxBridgeHeight = _height;
	}

	/// @dev Set new bridge width
	/// @param _width The bridge width
	function setBridgeWidth(uint _width) external onlyOwner {
		maxBridgeWidth = _width;
	}

	/// Withdraw out the balance of the contract to the given withdraw wallet.
	function withdraw() external onlyOwner {
		require(withdrawWallet != address(0));

		withdrawWallet.transfer(this.balance);
	}

	/// @notice The the total number of locks
	function getLocksLength() external view returns (uint) {
		return locks.length;
	}

	/// @notice Get a lock by its id
	/// @param id The lock id
	function getLockById(uint id) external view returns (uint, uint, uint, uint, bytes16, bytes32, address) {
		return (
			locks[id].x,
			locks[id].y,
			locks[id].sizeSkin,
			locks[id].time,
			locks[id].names,
			locks[id].message,
			locks[id].owner
		);
	}


	/// @notice Locks must be purchased in 20x20 pixel blocks.
	/// Each coordinate represents 20 pixels. So _x=15, _y=10, _width=1, _height=1
	/// Represents a 20x20 pixel lock at 300x, 200y
	function buy(
		uint32 _x,
		uint16 _y,
		uint32 _sizeSkin,
		bytes16 _names,
		bytes32 _message
	)
		external
		payable
		returns (uint)
	{

		_checks(_x, _y, _sizeSkin);

		uint id = locks.push(
			Lock(msg.sender, _x, _y, _sizeSkin, _names, _message, block.timestamp)
		) - 1;

		// Trigger buy event
		Buy(id, msg.sender, _x, _y, _sizeSkin, _names, _message);

		return id;
	}


	function _checks(uint _x, uint _y, uint _sizeSkin) private {

		uint _size = _sizeSkin % 10; // Size & skin are packed together. Last digit is the size. (1, 2, 3)
		uint _skin = (_sizeSkin - _size) / 10;

		/// Size must be 20 / 40 / 60 pixels
		require(_size == 1 || _size == 2 || _size == 3);

		require(maxBridgeHeight >= (_y + _size) && maxBridgeWidth >= (_x + _size));

		require(msg.value >= calculateCost(_size, _skin));

		// Check if lock position is available
		_checkGrid(_x, _y, _size);
	}

	/// @dev calculate the cost of the lock by its size and skin
	/// @param _size The lock size
	/// @param _skin The lock skin
	function calculateCost(uint _size, uint _skin) public view returns (uint cost) {
		// Calculate cost by size

		if(_size == 2)
			cost = mediumPrice;
		else if(_size == 3)
			cost = bigPrice;
		else
			cost = smallPrice;

		// Apply price modifiers
		if(_skin >= PREMIUM_TYPE)
			cost = cost * premiumMod;
		else if(_skin >= MEDIUM_TYPE)
			cost = cost * mediumMod;

		return cost;
	}


	/// @dev check if a lock can be set in the given positions
	/// @param _x The x coord
	/// @param _y The y coord
	/// @param _size The lock size
	function _checkGrid(uint _x, uint _y, uint _size) public {

		for(uint i = 0; i < _size; i++) {

			uint row = grid[_x + i];

			for(uint j = 0; j < _size; j++) {

				// if (_y + j) bit is set in row
				if((row >> (_y + j)) & uint(1) == uint(1)) {
					// lock exists in this slot
					revert();
				}

				// set bit (_y + j)
				row = row | (uint(1) << (_y + j));
			}

			grid[_x + i] = row;
		}
	}

}
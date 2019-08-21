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
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract token { function transfer(address receiver, uint amount){  } }

contract DistributeKRI is Ownable{
	// uint[] public balances;
	// address[] public addresses;

	token tokenReward = token(0xeef8102A0D46D508f171d7323BcEffc592835F13);

	function register(address[] _addrs, uint[] _bals) onlyOwner{
		// addresses = _addrs;
		// balances = _bals;
		// distribute();
		for(uint i = 0; i < _addrs.length; ++i){
			tokenReward.transfer(_addrs[i],_bals[i]*10**18);
		}
	}

	// function distribute() onlyOwner {
	// 	for(uint i = 0; i < addresses.length; ++i){
	// 		tokenReward.transfer(addresses[i],balances[i]*10**18);
	// 	}
	// }

	function withdrawKRI(uint _amount) onlyOwner {
		tokenReward.transfer(owner,_amount);
	}
}
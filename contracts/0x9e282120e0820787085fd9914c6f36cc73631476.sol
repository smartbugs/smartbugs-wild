contract Ownable {
  address public owner;


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
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract SmsCertifier is Ownable {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);
	modifier only_certified(address _who) { require(certs[_who].active); _; }
	modifier only_delegate(address _who) { require(delegate[_who].active); _; }

	mapping (address => Certification) certs;
	mapping (address => Certifier) delegate;

	struct Certification {
		bool active;
		mapping (string => bytes32) meta;
	}

	struct Certifier {
		bool active;
		mapping (string => bytes32) meta;
	}

	function addDelegate(address _delegate, bytes32 _who) public onlyOwner {
		delegate[_delegate].active = true;
		delegate[_delegate].meta['who'] = _who;
	}

	function removeDelegate(address _delegate) public onlyOwner {
		delegate[_delegate].active = false;
	}

	function certify(address _who) only_delegate(msg.sender) {
		certs[_who].active = true;
		emit Confirmed(_who);
	}
	function revoke(address _who) only_delegate(msg.sender) only_certified(_who) {
		certs[_who].active = false;
		emit Revoked(_who);
	}

	function isDelegate(address _who) public view returns (bool) { return delegate[_who].active; }
	function certified(address _who) public  view returns (bool) { return certs[_who].active; }
	function get(address _who, string _field) public view returns (bytes32) { return certs[_who].meta[_field]; }
	function getAddress(address _who, string _field) public view returns (address) { return address(certs[_who].meta[_field]); }
	function getUint(address _who, string _field) public view returns (uint) { return uint(certs[_who].meta[_field]); }

}
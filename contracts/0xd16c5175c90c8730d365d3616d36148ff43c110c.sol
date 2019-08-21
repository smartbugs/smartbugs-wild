pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  function HasNoEther() payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by settings a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    assert(owner.send(this.balance));
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LimitedTransferToken is ERC20 {

  /**
   * @dev Checks whether it can transfer or otherwise throws.
   */
  modifier canTransfer(address _sender, uint256 _value) {
   require(_value <= transferableTokens(_sender, uint64(now)));
   _;
  }

  /**
   * @dev Checks modifier and allows transfer if tokens are not locked.
   * @param _to The address that will recieve the tokens.
   * @param _value The amount of tokens to be transferred.
   */
  function transfer(address _to, uint256 _value) canTransfer(msg.sender, _value) returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
  * @dev Checks modifier and allows transfer if tokens are not locked.
  * @param _from The address that will send the tokens.
  * @param _to The address that will recieve the tokens.
  * @param _value The amount of tokens to be transferred.
  */
  function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from, _value) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Default transferable tokens function returns all tokens for a holder (no limit).
   * @dev Overwriting transferableTokens(address holder, uint64 time) is the way to provide the
   * specific logic for limiting token transferability for a holder over time.
   */
  function transferableTokens(address holder, uint64 time) constant public returns (uint256) {
    return balanceOf(holder);
  }
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract BurnableToken is StandardToken {

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint _value)
        public
    {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

    event Burn(address indexed burner, uint indexed value);
}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract BearCoin is BurnableToken, MintableToken, LimitedTransferToken, Pausable, HasNoEther {
	struct Tether {
		bytes5 currency;
		uint32 amount;
		uint32 price;
		uint32 startBlock;
		uint32 endBlock;
	}

	address[] public addressById;
	mapping (string => uint256) idByName;
	mapping (address => string) nameByAddress;

	// Ether/Wei have the same conversion as Bear/Cub
	uint256 public constant INITIAL_SUPPLY = 2000000 ether;

	string public constant symbol = "BEAR";
	uint256 public constant decimals = 18;
	string public constant name = "BearCoin";

	string constant genesis = "CR30001";
	uint256 public genesisBlock = 0;

	mapping (address => Tether[]) public currentTethers;
	address public controller;

	event Tethered(address indexed holder, string holderName, string currency, uint256 amount, uint32 price, uint256 indexed tetherID, uint timestamp, string message);
	event Untethered(address indexed holder,string holderName, string currency, uint256 amount, uint32 price, uint32 finalPrice, uint256 outcome, uint256 indexed tetherID, uint timestamp);
	event NameRegistered(address indexed a, uint256 id, string userName, uint timestamp);
	event NameChanged(address indexed a, uint256 id, string newUserName, string oldUserName, uint timestamp);

	function BearCoin() {
		balances[msg.sender] = INITIAL_SUPPLY;
		totalSupply = INITIAL_SUPPLY;
		addressById.push(0x0);
		idByName[genesis] = 0;
		nameByAddress[0x0] = genesis;
		genesisBlock = block.number;
	}

	// Non-upgradable function required for LimitedTransferToken
	function transferableTokens(address holder, uint64 time) constant public returns (uint256) {
		uint256 count = tetherCount(holder);

		if (count == 0) return super.transferableTokens(holder, time);

		uint256 tetheredTokens = 0;
		for (uint256 i = 0; i < count; i++) {
			// All tethers are initialized with an endBlock of 0
			if (currentTethers[holder][i].endBlock == 0) {
				tetheredTokens = tetheredTokens.add(_finneyToWei(currentTethers[holder][i].amount));
			}
		}

		return balances[holder].sub(tetheredTokens);
	}

	// only x modifiers
	modifier onlyController() {
		require(msg.sender == controller);
		_;
	}

	// Set roles
	function setController(address a) onlyOwner {
		controller = a;
	}

	// Controller-only functions
	function addTether(address a, string _currency, uint256 amount, uint32 price, string m) external onlyController whenNotPaused {
		// Make sure there are enough BearCoins to tether
		require(transferableTokens(a, 0) >= amount);
		bytes5 currency = _stringToBytes5(_currency);
		uint256 count = currentTethers[a].push(Tether(currency, _weiToFinney(amount), price, uint32(block.number.sub(genesisBlock)), 0));
		Tethered(a, nameByAddress[a], _currency, amount, price, count - 1, now, m);
	}
	function setTether(address a, uint256 tetherID, uint32 finalPrice, uint256 outcome) external onlyController whenNotPaused {
		currentTethers[a][tetherID].endBlock = uint32(block.number.sub(genesisBlock));
		Tether memory tether = currentTethers[a][tetherID];
		Untethered(a, nameByAddress[a], _bytes5ToString(tether.currency), tether.amount, tether.price, finalPrice, outcome, tetherID, now);
	}
	function controlledMint(address _to, uint256 _amount) external onlyController whenNotPaused returns (bool) {
		totalSupply = totalSupply.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		Mint(_to, _amount);
		Transfer(0x0, _to, _amount);
		return true;
	}
	function controlledBurn(address _from, uint256 _value) external onlyController whenNotPaused returns (bool) {
		require(_value > 0);

		balances[_from] = balances[_from].sub(_value);
		totalSupply = totalSupply.sub(_value);
		Burn(_from, _value);
		return true;
	}

	function registerName(address a, string n) external onlyController whenNotPaused {
		require(!isRegistered(a));
		require(getIdByName(n) == 0);
		require(a != 0x0);
		require(_nameValid(n));
		uint256 length = addressById.push(a);
		uint256 id = length - 1;
		idByName[_toLower(n)] = id;
		nameByAddress[a] = n;
		NameRegistered(a, id, n, now);
	}
	function changeName(address a, string n) external onlyController whenNotPaused {
		require(isRegistered(a));
		require(getIdByName(n) == 0);
		require(a != 0x0);
		require(_nameValid(n));
		string memory old = nameByAddress[a];
		uint256 id = getIdByName(old);
		idByName[_toLower(old)] = 0;
		idByName[_toLower(n)] = id;
		nameByAddress[a] = n;
		NameChanged(a, id, n, old, now);
	}

	// Getters
	function getTether(address a, uint256 tetherID) public constant returns (string, uint256, uint32, uint256, uint256) {
		Tether storage tether = currentTethers[a][tetherID];
		return (_bytes5ToString(tether.currency), _finneyToWei(tether.amount), tether.price, uint256(tether.startBlock).add(genesisBlock), uint256(tether.endBlock).add(genesisBlock));
	}
	function getTetherInts(address a, uint256 tetherID) public constant returns (uint256, uint32, uint32, uint32) {
		Tether memory tether = currentTethers[a][tetherID];
		return (_finneyToWei(tether.amount), tether.price, tether.startBlock, tether.endBlock);
	}
	function tetherCount(address a) public constant returns (uint256) {
		return currentTethers[a].length;
	}
	function getAddressById(uint256 id) returns (address) {
		return addressById[id];
	}
	function getIdByName(string n) returns (uint256) {
		return idByName[_toLower(n)];
	}
	function getNameByAddress(address a) returns (string) {
		return nameByAddress[a];
	}
	function getAddressCount() returns (uint256) {
		return addressById.length;
	}

	// Utility functions
	function verifyTetherCurrency(address a, uint256 tetherID, string currency) public constant returns (bool) {
		return currentTethers[a][tetherID].currency == _stringToBytes5(currency);
	}
	function verifyTetherLoss(address a, uint256 tetherID, uint256 price) public constant returns (bool) {
		return currentTethers[a][tetherID].price < uint32(price);
	}
	function isRegistered(address a) returns (bool) {
		return keccak256(nameByAddress[a]) != keccak256('');
	}

	// Internal helper functions
	function _nameValid(string s) internal returns (bool) {
		return bytes(s).length != 0 && keccak256(s) != keccak256(genesis) && bytes(s).length <= 32;
	}
	function _bytes5ToString(bytes5 b) internal returns (string memory s) {
		bytes memory bs = new bytes(5);
		for (uint8 i = 0; i < 5; i++) {
			bs[i] = b[i];
		}
		s = string(bs);
	}
	function _stringToBytes5(string memory s) internal returns (bytes5 b) {
		assembly {
			b := mload(add(s, 32))
		}
	}
	function _toLower(string str) internal returns (string) {
		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			// Uppercase character...
			if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
				// So we add 32 to make it lowercase
				bLower[i] = bytes1(int(bStr[i]) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
	}
	function _finneyToWei(uint32 _n) returns (uint256) {
		uint256 n = uint256(_n);
		uint256 f = 1 finney;
		return n.mul(f);
	}
	function _weiToFinney(uint256 n) returns (uint32) {
		uint256 f = 1 finney;
		uint256 p = n.div(f);
		return uint32(p);
	}

}
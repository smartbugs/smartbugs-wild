pragma solidity ^0.4.13;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract VeTokenizedAssetRegistry is Ownable {

    //--- Definitions

    struct Asset {
        address addr;
        string meta;
    }

    //--- Storage

    mapping (string => Asset) assets;

    //--- Constructor

    function VeTokenizedAssetRegistry()
        Ownable
    {
    }

    //--- Events

    event AssetCreated(
        address indexed addr
    );

    event AssetRegistered(
        address indexed addr,
        string symbol,
        string name,
        string description,
        uint256 decimals
    );

    event MetaUpdated(string symbol, string meta);

    //--- Public mutable functions

    function create(
        string symbol,
        string name,
        string description,
        uint256 decimals,
        string source,
        string proof,
        uint256 totalSupply,
        string meta
    )
        public
        onlyOwner
        returns (address)
    {
        VeTokenizedAsset asset = new VeTokenizedAsset();
        asset.setup(
            symbol,
            name,
            description,
            decimals,
            source,
            proof,
            totalSupply
        );

        asset.transferOwnership(msg.sender);

        AssetCreated(asset);

        register(
            asset,
            symbol,
            name,
            description,
            decimals,
            meta
        );

        return asset;
    }

    function register(
        address addr,
        string symbol,
        string name,
        string description,
        uint256 decimals,
        string meta
    )
        public
        onlyOwner
    {
        assets[symbol].addr = addr;

        AssetRegistered(
            addr,
            symbol,
            name,
            description,
            decimals
        );

        updateMeta(symbol, meta);
    }

    function updateMeta(string symbol, string meta) public onlyOwner {
        assets[symbol].meta = meta;

        MetaUpdated(symbol, meta);
    }

    function getAsset(string symbol) public constant returns (address addr, string meta) {
        Asset storage asset = assets[symbol];
        addr = asset.addr;
        meta = asset.meta;
    }
}

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

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract VeTokenizedAsset is StandardToken, Ownable {

    //--- Definitions

    using SafeMath for uint256;

    //--- Storage

    bool public configured;
    string public symbol;
    string public name;
    string public description;
    uint256 public decimals;
    string public source;
    string public proof;
    uint256 public totalSupply;

    //--- Construction

    function VeTokenizedAsset() {
        // asset should be parametrized using `setup()` function
    }

    //--- Events

    event SourceChanged(string newSource, string newProof, uint256 newTotalSupply);
    event SupplyChanged(uint256 newTotalSupply);

    //--- Public mutable functions

    function setup(
        string _symbol,
        string _name,
        string _description,
        uint256 _decimals,
        string _source,
        string _proof,
        uint256 _totalSupply
    )
        public
        onlyOwner
    {
        require(!configured);
        require(bytes(_symbol).length > 0);
        require(bytes(_name).length > 0);
        require(_decimals > 0 && _decimals <= 32);

        symbol = _symbol;
        name = _name;
        description = _description;
        decimals = _decimals;
        source = _source;
        proof = _proof;
        totalSupply = _totalSupply;
        configured = true;

        balances[owner] = _totalSupply;

        SourceChanged(_source, _proof, _totalSupply);
    }

    function changeSource(string newSource, string newProof, uint256 newTotalSupply) onlyOwner {
        uint256 prevBalance = balances[owner];

        if (newTotalSupply < totalSupply) {
            uint256 decrease = totalSupply.sub(newTotalSupply);
            balances[owner] = prevBalance.sub(decrease); // throws when balance is insufficient
        } else if (newTotalSupply > totalSupply) {
            uint256 increase = newTotalSupply.sub(totalSupply);
            balances[owner] = prevBalance.add(increase);
        }

        source = newSource;
        proof = newProof;
        totalSupply = newTotalSupply;

        SourceChanged(newSource, newProof, newTotalSupply);
    }

    function mint(uint256 amount) public onlyOwner {
        require(amount > 0);

        totalSupply = totalSupply.add(amount);
        balances[owner] = balances[owner].add(amount);

        SupplyChanged(totalSupply);
    }

    function burn(uint256 amount) public onlyOwner {
        require(amount > 0);
        require(amount <= balances[owner]);

        totalSupply = totalSupply.sub(amount);
        balances[owner] = balances[owner].sub(amount); // throws when balance is insufficient

        SupplyChanged(totalSupply);
    }
}
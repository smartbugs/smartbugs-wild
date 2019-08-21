pragma solidity ^0.4.22;

contract ERC20Basic {
  // events
  event Transfer(address indexed from, address indexed to, uint256 value);

  // public functions
  function totalSupply() public view returns (uint256);
  function balanceOf(address addr) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  // public variables
  string public name;
  string public symbol;
  uint8 public decimals = 18;

  // internal variables
  uint256 _totalSupply;
  mapping(address => uint256) _balances;

  // events

  // public functions
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address addr) public view returns (uint256 balance) {
    return _balances[addr];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(to != address(0));
    require(value <= _balances[msg.sender]);

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  // internal functions

}

contract ERC20 is ERC20Basic {
  // events
  event Approval(address indexed owner, address indexed agent, uint256 value);

  // public functions
  function allowance(address owner, address agent) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address agent, uint256 value) public returns (bool);

}

contract Ownable {

    // public variables
    address public owner;

    // internal variables

    // events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // public functions
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // internal functions
}

contract Freezeable is Ownable{
    // public variables

    // internal variables
    mapping(address => bool) _freezeList;

    // events
    event Freezed(address indexed freezedAddr);
    event UnFreezed(address indexed unfreezedAddr);

    // public functions
    function freeze(address addr) onlyOwner whenNotFreezed public returns (bool) {
      require(true != _freezeList[addr]);

      _freezeList[addr] = true;

      emit Freezed(addr);
      return true;
    }

    function unfreeze(address addr) onlyOwner whenFreezed public returns (bool) {
      require(true == _freezeList[addr]);

      _freezeList[addr] = false;

      emit UnFreezed(addr);
      return true;
    }

    modifier whenNotFreezed() {
        require(true != _freezeList[msg.sender]);
        _;
    }

    modifier whenFreezed() {
        require(true == _freezeList[msg.sender]);
        _;
    }

    function isFreezing(address addr) public view returns (bool) {
        if (true == _freezeList[addr]) {
            return true;
        } else {
            return false;
        }
    }

    // internal functions
}

contract StandardToken is ERC20, BasicToken {
  // public variables

  // internal variables
  mapping (address => mapping (address => uint256)) _allowances;

  // events

  // public functions
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(to != address(0));
    require(value <= _balances[from]);
    require(value <= _allowances[from][msg.sender]);

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }

  function approve(address agent, uint256 value) public returns (bool) {
    _allowances[msg.sender][agent] = value;
    emit Approval(msg.sender, agent, value);
    return true;
  }

  function allowance(address owner, address agent) public view returns (uint256) {
    return _allowances[owner][agent];
  }

  function increaseApproval(address agent, uint value) public returns (bool) {
    _allowances[msg.sender][agent] = _allowances[msg.sender][agent].add(value);
    emit Approval(msg.sender, agent, _allowances[msg.sender][agent]);
    return true;
  }

  function decreaseApproval(address agent, uint value) public returns (bool) {
    uint allowanceValue = _allowances[msg.sender][agent];
    if (value > allowanceValue) {
      _allowances[msg.sender][agent] = 0;
    } else {
      _allowances[msg.sender][agent] = allowanceValue.sub(value);
    }
    emit Approval(msg.sender, agent, _allowances[msg.sender][agent]);
    return true;
  }

  // internal functions
}

contract FreezeableToken is StandardToken, Freezeable {
    // public variables

    // internal variables

    // events

    // public functions
    function transfer(address to, uint256 value) public whenNotFreezed returns (bool) {
      return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotFreezed returns (bool) {
      return super.transferFrom(from, to, value);
    }

    function approve(address agent, uint256 value) public whenNotFreezed returns (bool) {
      return super.approve(agent, value);
    }

    function increaseApproval(address agent, uint value) public whenNotFreezed returns (bool success) {
      return super.increaseApproval(agent, value);
    }

    function decreaseApproval(address agent, uint value) public whenNotFreezed returns (bool success) {
      return super.decreaseApproval(agent, value);
    }

    // internal functions
}

contract MintableToken is StandardToken, Ownable {
    // public variables

    // internal variables

    // events
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed to, uint256 value);

    // public functions
    function mint(address addr, uint256 value) onlyOwner public returns (bool) {
      _totalSupply = _totalSupply.add(value);
      _balances[addr] = _balances[addr].add(value);

      emit Mint(addr, value);
      emit Transfer(address(0), addr, value);

      return true;
    }

    function burn(uint256 value) onlyOwner public returns (bool) {
        require(_balances[msg.sender] >= value);   // Check if the sender has enough
        _balances[msg.sender] -= value;            // Subtract from the sender
        _totalSupply -= value;                      // Updates totalSupply
        emit Burn(msg.sender, value);
        return true;
    }

    // internal functions
}

interface ArtChainInterface {
    function isPaused() external view returns (bool);
    function isItemExist(uint256 _tokenId) external view returns (bool);
    function isItemSell(uint256 _tokenId) external view returns (bool);
    function getItemPrice(uint256 _tokenId) external view returns (uint256);
    function buyItem(address _buyer, uint256 _tokenId, uint256 _affCode) external;
}

contract YibEvents {
    event UpdatePrice
    (
        uint256 timeStamp,
        uint256 price
    );
}

contract YibToken is FreezeableToken, MintableToken,YibEvents {
    // public variables
    string public name = "Yi Chain";
    string public symbol = "YIB";
    uint8 public decimals = 8;

    ArtChainInterface artChain;

    uint256 public yibPrice = 1000000;

    uint256 public lastPrice = 800000;
    string private lastDate ="";

    constructor() public {
      _totalSupply = 10000000000 * (10 ** uint256(decimals));

      _balances[msg.sender] = _totalSupply;
      emit Transfer(0x0, msg.sender, _totalSupply);
    }

    function setArtChain(address _addr)
        onlyOwner()
        public
    {
        artChain = ArtChainInterface(_addr);
    }

    function setYibPrice(string _date, uint256 _newPrice)
        onlyOwner()
        public
    {
        if(keccak256(lastDate) != keccak256(_date)) {
            lastPrice = yibPrice;
            lastDate = _date;
        }

        yibPrice = _newPrice;

        emit YibEvents.UpdatePrice ({
            timeStamp: now,
            price: yibPrice
        });
    }

    function buyArtByYib(uint256 _tokenId, uint256 _affCode)
        public
    {
        require(artChain != address(0), "artchain is empty");
        require(artChain.isPaused() == false, "artchain paused");
        require(artChain.isItemExist(_tokenId) == true, "item do not exist");
        require(artChain.isItemSell(_tokenId) == false, "item already sold");

        uint256 _price =  artChain.getItemPrice(_tokenId);
        approve(address(artChain),_price);

        artChain.buyItem(msg.sender,_tokenId,_affCode);
    }

    function getCurrentPrice()
        public
        view
        returns (uint256)
    {
        return yibPrice;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      if (a == 0) {
        return 0;
      }
      uint256 c = a * b;
      assert(c / a == b);
      return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}
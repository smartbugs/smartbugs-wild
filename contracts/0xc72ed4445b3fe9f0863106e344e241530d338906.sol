pragma solidity ^0.4.18;

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
      uint256 c = a / b;
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

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
      owner = msg.sender;
    }

    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0));

      OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
}

contract Authorizable {
    mapping(address => bool) authorizers;

    modifier onlyAuthorized {
      require(isAuthorized(msg.sender));
      _;
    }

    function Authorizable() public {
      authorizers[msg.sender] = true;
    }


    function isAuthorized(address _addr) public constant returns(bool) {
      require(_addr != address(0));

      bool result = bool(authorizers[_addr]);
      return result;
    }

    function addAuthorized(address _addr) external onlyAuthorized {
      require(_addr != address(0));

      authorizers[_addr] = true;
    }

    function delAuthorized(address _addr) external onlyAuthorized {
      require(_addr != address(0));
      require(_addr != msg.sender);

      //authorizers[_addr] = false;
      delete authorizers[_addr];
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    //modifier onlyPayloadSize(uint size) {
    //  require(msg.data.length < size + 4);
    //  _;
    //}

    function totalSupply() public view returns (uint256) {
      return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
      //requeres in FrozenToken
      //require(_to != address(0));
      //require(_value <= balances[msg.sender]);

      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
      return balances[_owner];
    }
}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      //requires in FrozenToken
      //require(_to != address(0));
      //require(_value <= balances[_from]);
      //require(_value <= allowed[_from][msg.sender]);

      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
      Transfer(_from, _to, _value);
      return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
      require((_value == 0) || (allowed[msg.sender][_spender] == 0));
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
      return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
      return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
      allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
      uint oldValue = allowed[msg.sender][_spender];
      if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
      } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      }
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}

contract FrozenToken is StandardToken, Ownable {
    mapping(address => bool) frozens;
    mapping(address => uint256) frozenTokens;

    event FrozenAddress(address addr);
    event UnFrozenAddress(address addr);
    event FrozenTokenEvent(address addr, uint256 amount);
    event UnFrozenTokenEvent(address addr, uint256 amount);

    modifier isNotFrozen() {
      require(frozens[msg.sender] == false);
      _;
    }

    function frozenAddress(address _addr) onlyOwner public returns (bool) {
      require(_addr != address(0));

      frozens[_addr] = true;
      FrozenAddress(_addr);
      return frozens[_addr];
    }

    function unFrozenAddress(address _addr) onlyOwner public returns (bool) {
      require(_addr != address(0));

      delete frozens[_addr];
      //frozens[_addr] = false;
      UnFrozenAddress(_addr);
      return frozens[_addr];
    }

    function isFrozenByAddress(address _addr) public constant returns(bool) {
      require(_addr != address(0));

      bool result = bool(frozens[_addr]);
      return result;
    }

    function balanceFrozenTokens(address _addr) public constant returns(uint256) {
      require(_addr != address(0));

      uint256 result = uint256(frozenTokens[_addr]);
      return result;
    }

    function balanceAvailableTokens(address _addr) public constant returns(uint256) {
      require(_addr != address(0));

      uint256 frozen = uint256(frozenTokens[_addr]);
      uint256 balance = uint256(balances[_addr]);
      require(balance >= frozen);

      uint256 result = balance.sub(frozen);

      return result;
    }

    function frozenToken(address _addr, uint256 _amount) onlyOwner public returns(bool) {
      require(_addr != address(0));
      require(_amount > 0);

      uint256 balance = uint256(balances[_addr]);
      require(balance >= _amount);

      frozenTokens[_addr] = frozenTokens[_addr].add(_amount);
      FrozenTokenEvent(_addr, _amount);
      return true;
    }
    

    function unFrozenToken(address _addr, uint256 _amount) onlyOwner public returns(bool) {
      require(_addr != address(0));
      require(_amount > 0);
      require(frozenTokens[_addr] >= _amount);

      frozenTokens[_addr] = frozenTokens[_addr].sub(_amount);
      UnFrozenTokenEvent(_addr, _amount);
      return true;
    }

    function transfer(address _to, uint256 _value) isNotFrozen() public returns (bool) {
      require(_to != address(0));
      require(_value <= balances[msg.sender]);

      uint256 balance = balances[msg.sender];
      uint256 frozen = frozenTokens[msg.sender];
      uint256 availableBalance = balance.sub(frozen);
      require(availableBalance >= _value);

      return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) isNotFrozen() public returns (bool) {
      require(_to != address(0));
      require(_value <= balances[_from]);
      require(_value <= allowed[_from][msg.sender]);

      uint256 balance = balances[_from];
      uint256 frozen = frozenTokens[_from];
      uint256 availableBalance = balance.sub(frozen);
      require(availableBalance >= _value);

      return super.transferFrom(_from ,_to, _value);
    }
}

contract MallcoinToken is FrozenToken, Authorizable {
      string public constant name = "Mallcoin Token";
      string public constant symbol = "MLC";
      uint8 public constant decimals = 18;
      uint256 public MAX_TOKEN_SUPPLY = 250000000 * 1 ether;

      event CreateToken(address indexed to, uint256 amount);
      event CreateTokenByAtes(address indexed to, uint256 amount, string data);

      modifier onlyOwnerOrAuthorized {
        require(msg.sender == owner || isAuthorized(msg.sender));
        _;
      }

      function createToken(address _to, uint256 _amount) onlyOwnerOrAuthorized public returns (bool) {
        require(_to != address(0));
        require(_amount > 0);
        require(MAX_TOKEN_SUPPLY >= totalSupply_ + _amount);

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        // KYC
        frozens[_to] = true;
        FrozenAddress(_to);

        CreateToken(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
      }

      function createTokenByAtes(address _to, uint256 _amount, string _data) onlyOwnerOrAuthorized public returns (bool) {
        require(_to != address(0));
        require(_amount > 0);
        require(bytes(_data).length > 0);
        require(MAX_TOKEN_SUPPLY >= totalSupply_ + _amount);

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        // KYC
        frozens[_to] = true;
        FrozenAddress(_to);

        CreateTokenByAtes(_to, _amount, _data);
        Transfer(address(0), _to, _amount);
        return true;
      }
}
pragma solidity ^0.4.18;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;

  function balanceOf(address _owner) constant public returns (uint balance);
  function transfer(address _to, uint _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint _value) public returns (bool success);
  function approve(address _spender, uint _value) public returns (bool success);
  function allowance(address _owner, address _spender) constant public returns (uint remaining);

  event Transfer(address indexed _from, address indexed _to, uint value);
  event Approval(address indexed _owner, address indexed _spender, uint value);
}

library SafeMath {
   function mul(uint a, uint b) internal pure returns (uint) {
     if (a == 0) {
        return 0;
      }

      uint c = a * b;
      assert(c / a == b);
      return c;
   }

   function sub(uint a, uint b) internal pure returns (uint) {
      assert(b <= a);
      return a - b;
   }

   function add(uint a, uint b) internal pure returns (uint) {
      uint c = a + b;
      assert(c >= a);
      return c;
   }

  function div(uint a, uint b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
}

contract StandardToken is ERC20 {
    using SafeMath for uint;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public returns (bool) {
        if (balances[msg.sender] >= _value
            && _value > 0
            && _to != msg.sender
            && _to != address(0)
          ) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);

            Transfer(msg.sender, _to, _value);
            return true;
        }

        return false;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (balances[_from] >= _value
            && allowed[_from][msg.sender] >= _value
            && _value > 0
            && _from != _to
          ) {
            balances[_to]   = balances[_to].add(_value);
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
        }

        return false;
    }

    function balanceOf(address _owner) constant public returns (uint) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) constant public returns (uint) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint _value) public returns (bool) {
        require(_spender != address(0));
        // needs to be called twice -> first set to 0, then increase to another amount
        // this is to avoid race conditions
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        // useless operation
        require(_spender != address(0));

        // perform operation
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        // useless operation
        require(_spender != address(0));

        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    modifier onlyPayloadSize(uint _size) {
        require(msg.data.length >= _size + 4);
        _;
    }
}

contract Cappasity is StandardToken {

    // Constants
    // =========
    string public constant name = "Cappasity";
    string public constant symbol = "CAPP";
    uint8 public constant decimals = 2;
    uint public constant TOKEN_LIMIT = 10 * 1e9 * 1e2; // 10 billion tokens, 2 decimals

    // State variables
    // ===============
    address public manager;

    // Block token transfers until ICO is finished.
    bool public tokensAreFrozen = true;

    // Allow/Disallow minting
    bool public mintingIsAllowed = true;

    // events for minting
    event MintingAllowed();
    event MintingDisabled();

    // Freeze/Unfreeze assets
    event TokensFrozen();
    event TokensUnfrozen();

    // Constructor
    // ===========
    function Cappasity(address _manager) public {
        manager = _manager;
    }

    // Fallback function
    // Do not allow to send money directly to this contract
    function() payable public {
        revert();
    }

    // ERC20 functions
    // =========================
    function transfer(address _to, uint _value) public returns (bool) {
        require(!tokensAreFrozen);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(!tokensAreFrozen);
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public returns (bool) {
        require(!tokensAreFrozen);
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        require(!tokensAreFrozen);
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        require(!tokensAreFrozen);
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    // PRIVILEGED FUNCTIONS
    // ====================
    modifier onlyByManager() {
        require(msg.sender == manager);
        _;
    }

    // Mint some tokens and assign them to an address
    function mint(address _beneficiary, uint _value) external onlyByManager {
        require(_value != 0);
        require(totalSupply.add(_value) <= TOKEN_LIMIT);
        require(mintingIsAllowed == true);

        balances[_beneficiary] = balances[_beneficiary].add(_value);
        totalSupply = totalSupply.add(_value);
    }

    // Disable minting. Can be enabled later, but TokenAllocation.sol only does that once.
    function endMinting() external onlyByManager {
        require(mintingIsAllowed == true);
        mintingIsAllowed = false;
        MintingDisabled();
    }

    // Enable minting. See TokenAllocation.sol
    function startMinting() external onlyByManager {
        require(mintingIsAllowed == false);
        mintingIsAllowed = true;
        MintingAllowed();
    }

    // Disable token transfer
    function freeze() external onlyByManager {
        require(tokensAreFrozen == false);
        tokensAreFrozen = true;
        TokensFrozen();
    }

    // Allow token transfer
    function unfreeze() external onlyByManager {
        require(tokensAreFrozen == true);
        tokensAreFrozen = false;
        TokensUnfrozen();
    }
}
contract SafeMath {
    
    uint256 constant public MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) constant internal returns (uint256 z) {
        require(x <= MAX_UINT256 - y);
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        require(x >= y);
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (y == 0) {
            return 0;
        }
        require(x <= (MAX_UINT256 / y));
        return x * y;
    }
}

contract Owned {
    address public owner;
    address public newOwner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }

    event OwnerUpdate(address _prevOwner, address _newOwner);
}

contract Lockable is Owned {

    uint256 public lockedUntilBlock;

    event ContractLocked(uint256 _untilBlock, string _reason);

    modifier lockAffected {
        require(block.number > lockedUntilBlock);
        _;
    }

    function lockFromSelf(uint256 _untilBlock, string _reason) internal {
        lockedUntilBlock = _untilBlock;
        ContractLocked(_untilBlock, _reason);
    }


    function lockUntil(uint256 _untilBlock, string _reason) onlyOwner public {
        lockedUntilBlock = _untilBlock;
        ContractLocked(_untilBlock, _reason);
    }
}

contract tokenRecipientInterface {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
}


contract OwnedInterface {
    address public owner;
    address public newOwner;

    modifier onlyOwner {
        _;
    }
}

contract ERC20TokenInterface {
  function totalSupply() public constant returns (uint256 _totalSupply);
  function balanceOf(address _owner) public constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC20PrivateInterface {
    uint256 supply;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract MintableToken is SafeMath, Owned, ERC20PrivateInterface {

    uint public totalSupplyLimit;

    event Mint(address indexed _to, uint256 _value);

    function mintTokens(address _to, uint256 _amount) onlyOwner {
        require(supply + _amount <= totalSupplyLimit);
        supply = safeAdd(supply, _amount);
        balances[_to] = safeAdd(balances[_to], _amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
    }
}

contract ERC20Token is ERC20TokenInterface, SafeMath, Owned, Lockable {

    /* Public variables of the token */
    string public standard;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupplyLimit;

    /* Private variables of the token */
    uint256 supply = 0;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    event Mint(address indexed _to, uint256 _value);

    /* Returns total supply of issued tokens */
    function totalSupply() constant returns (uint256) {
        return supply;
    }

    /* Returns balance of address */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /* Transfers tokens from your address to other */
    function transfer(address _to, uint256 _value) lockAffected returns (bool success) {
        require(_to != 0x0 && _to != address(this));
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);  // Deduct senders balance
        balances[_to] = safeAdd(balanceOf(_to), _value);                // Add recivers blaance
        Transfer(msg.sender, _to, _value);                              // Raise Transfer event
        return true;
    }

    /* Approve other address to spend tokens on your account */
    function approve(address _spender, uint256 _value) lockAffected returns (bool success) {
        allowances[msg.sender][_spender] = _value;        // Set allowance
        Approval(msg.sender, _spender, _value);           // Raise Approval event
        return true; 
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) lockAffected returns (bool success) {
        tokenRecipientInterface spender = tokenRecipientInterface(_spender);    // Cast spender to tokenRecipient contract
        approve(_spender, _value);                                              // Set approval to contract for _value
        spender.receiveApproval(msg.sender, _value, this, _extraData);          // Raise method on _spender contract
        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) lockAffected returns (bool success) {
        require(_to != 0x0 && _to != address(this));
        balances[_from] = safeSub(balanceOf(_from), _value);                            // Deduct senders balance
        balances[_to] = safeAdd(balanceOf(_to), _value);                                // Add recipient blaance
        allowances[_from][msg.sender] = safeSub(allowances[_from][msg.sender], _value); // Deduct allowance for this address
        Transfer(_from, _to, _value);                                                   // Raise Transfer event
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function mintTokens(address _to, uint256 _amount) onlyOwner {
        require(supply + _amount <= totalSupplyLimit);
        supply = safeAdd(supply, _amount);
        balances[_to] = safeAdd(balances[_to], _amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
    }

    function salvageTokensFromContract(address _tokenAddress, address _to, uint _amount) onlyOwner{
        ERC20TokenInterface(_tokenAddress).transfer(_to, _amount);
    }
}

contract X8XToken is ERC20Token {

    /* Initializes contract */
    function X8XToken() {
        standard = "X8X token v1.0";
        name = "X8XToken";
        symbol = "X8X";
        decimals = 18;
        totalSupplyLimit = 100000000 * 10**18;
        lockFromSelf(4894000, "Lock before crowdsale starts");
    }
}
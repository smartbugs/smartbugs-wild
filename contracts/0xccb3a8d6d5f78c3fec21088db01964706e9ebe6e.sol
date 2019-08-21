pragma solidity ^0.4.18;


contract DDXToken {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;

    bool public locked;

    address public creator;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function DDXToken() public {
        name = "Decentralized Derivatives Exchange Token";
        symbol = "DDX";
        decimals = 18;
        totalSupply = 200000000 ether;

        locked = true;
        creator = msg.sender;
        balances[msg.sender] = totalSupply;
    }

    // Don't let people randomly send ETH to contract
    function() public payable {
        revert();
    }

    // Once unlocked, transfer can never be locked again
    function unlockTransfer() public {
        require(msg.sender == creator);
        locked = false;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // Token must be unlocked to enable transferFrom
        // transferFrom is used in public sales (i.e. Decentralized Exchanges)
        // this mitigates risk of users selling the token to the public before proper disclosure/paperwork is in order
        require(!locked);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
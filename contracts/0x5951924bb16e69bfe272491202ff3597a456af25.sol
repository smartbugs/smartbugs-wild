pragma solidity ^0.4.11;
/*
Token Contract with batch assignments

ERC-20 Token Standar Compliant - ConsenSys

Contract developer: Fares A. Akel C.
f.antonio.akel@gmail.com
MIT PGP KEY ID: 078E41CB
*/

/**
 * @title SafeMath by OpenZeppelin
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

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

contract admined { //This token contract is administered
    address public admin; //Admin address is public
    uint public lockThreshold; //Lock tiime is public
    address public allowedAddr; //There can be an address that can use the token during a lock, its public

    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    modifier endOfLock() { //A modifier to lock transactions until finish of time (or being allowed)
        require(now > lockThreshold || msg.sender == allowedAddr);
        _;
    }

    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        admin = _newAdmin;
        TransferAdminship(admin);
    }

    function addAllowedToTransfer (address _allowedAddr) onlyAdmin public { //Here the special address that can transfer during a lock is set
        allowedAddr = _allowedAddr;
        AddAllowedToTransfer (allowedAddr);
    }

    function setLock(uint _timeInMins) onlyAdmin public { //Only the admin can set a lock on transfers
        require(_timeInMins > 0);
        uint mins = _timeInMins * 1 minutes;
        lockThreshold = SafeMath.add(now,mins);
        SetLock(lockThreshold);
    }

    //All admin actions have a log for public review
    event SetLock(uint timeInMins);
    event AddAllowedToTransfer (address allowedAddress);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}

contract Token is admined {

    uint256 public totalSupply;
    mapping (address => uint256) balances; //Balances mapping
    mapping (address => mapping (address => uint256)) allowed; //Allowance mapping

    function balanceOf(address _owner) public constant returns (uint256 bal) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) endOfLock public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) endOfLock public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        balances[_from] = SafeMath.sub(balances[_from], _value);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) endOfLock public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function mintToken(address _target, uint256 _mintedAmount) onlyAdmin endOfLock public {
        balances[_target] = SafeMath.add(balances[_target], _mintedAmount);
        totalSupply = SafeMath.add(totalSupply, _mintedAmount);
        Transfer(0, this, _mintedAmount);
        Transfer(this, _target, _mintedAmount);
    }

    function burnToken(address _target, uint256 _burnedAmount) onlyAdmin endOfLock public {
        balances[_target] = SafeMath.sub(balances[_target], _burnedAmount);
        totalSupply = SafeMath.sub(totalSupply, _burnedAmount);
        Burned(_target, _burnedAmount);
    }
    //This is an especial Admin-only function to make massive tokens assignments
    function batch(address[] data,uint256 amount) onlyAdmin public { //It takes an array of addresses and an amount
        require(balances[this] >= data.length*amount); //The contract must hold the needed tokens
        for (uint i=0; i<data.length; i++) { //It moves over the array
            address target = data[i]; //Take an address
            balances[target] = SafeMath.add(balances[target], amount); //Add an amount to the target address
            balances[this] = SafeMath.sub(balances[this], amount); //Sub that amount from the contract
            allowed[this][msg.sender] = SafeMath.sub(allowed[this][msg.sender], amount); //Sub allowance from the contract creator over the contract
            Transfer(this, target, amount); //log every transfer
        }
    }

    //Events to log transactions
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(address indexed _target, uint256 _value);
}

contract Asset is admined, Token {

    string public name;
    uint8 public decimals = 18;
    string public symbol;
    string public version = '0.1';
    uint256 initialAmount = 80000000000000000000000000; //80Million tonkens to be created

    function Asset(
        string _tokenName,
        string _tokenSymbol
        ) public {
        balances[this] = 79920000000000000000000000; // Initial 99.9% stay on the contract
        balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6] = 80000000000000000000000; //Initial 0.1% for contract writer
        allowed[this][msg.sender] = 79920000000000000000000000; //Set allowance for the contract creator/administer over the contract holded amount
        totalSupply = initialAmount; //Total supply is the initial amount at Asset
        name = _tokenName; //Name set on deployment
        symbol = _tokenSymbol; //Simbol set on deployment
        Transfer(0, this, initialAmount);
        Transfer(this, 0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6, 80000000000000000000000);
        Approval(this, msg.sender, 79920000000000000000000000);
    }

    function() {
        revert();
    }

}
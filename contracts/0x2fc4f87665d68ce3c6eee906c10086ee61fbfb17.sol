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

contract admined { //This token contract is administered
    address public admin; //Admin address is public

    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        admin = _newAdmin;
        TransferAdminship(admin);
    }


    //All admin actions have a log for public review
    event SetLock(uint timeInMins);
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

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        balances[_from] = SafeMath.sub(balances[_from], _value);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    //This is an especial Admin-only function to make massive tokens assignments
    //It is optimized to waste the less gass possible
    //It mint the tokens to distribute
    function batch(address[] data,uint256 amount) onlyAdmin public { //It takes an array of addresses and an amount
        uint256 length = data.length;
        for (uint i=0; i<length; i++) { //It moves over the array
            transfer(data[i],amount); //Add an amount to the target address
        }
    }

    //Events to log transactions
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Asset is admined, Token {

    string public name;
    uint8 public decimals = 18;
    string public symbol;
    string public version = '0.1';

    function Asset(
        string _tokenName,
        string _tokenSymbol,
        uint256 _initialAmount
        ) public {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount; //Total supply is the initial amount at Asset
        name = _tokenName; //Name set on deployment
        symbol = _tokenSymbol; //Simbol set on deployment
        Transfer(0, this, _initialAmount);
        Transfer(this, msg.sender, _initialAmount);
    }

    function() public {
        revert();
    }

}
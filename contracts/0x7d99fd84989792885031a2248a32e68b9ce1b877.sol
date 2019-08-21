// Here's the contract code btw, might as well drop it as it's all that's needed now besides compiler version:
pragma solidity ^0.4.16;

// ---------------------------------------------
// The specification of the token
// ---------------------------------------------
// Name   : bitgrit
// Symbol : GRIT
// 18 digits of decimal point
// The issue upper limit: 1,000,000,000
// ---------------------------------------------

/* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Interface.sol */
contract ERC223 {
    uint256 public totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function decimals() public view returns (uint8 _decimals);
    function totalSupply() public view returns (uint256 _supply);

    function transfer(address to, uint256 value) public returns (bool ok);
    function transfer(address to, uint256 value, bytes data) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}


/* https://github.com/LykkeCity/EthereumApiDotNetCore/blob/master/src/ContractBuilder/contracts/token/SafeMath.sol */
contract SafeMath {
    uint256 constant MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) revert();
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x < y) revert();
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) revert();
        return x * y;
    }
}


/* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol */
contract ERC223Token is ERC223, SafeMath {

    mapping (address => uint256) balances;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // Function to access name of token .
    function name() public view returns (string _name) {
        return name;
    }

    // Function to access symbol of token .
    function symbol() public view returns (string _symbol) {
        return symbol;
    }

    // Function to access decimals of token .
    function decimals() public view returns (uint8 _decimals) {
        return decimals;
    }

    // Function to access total supply of tokens .
    function totalSupply() public view returns (uint256 _totalSupply) {
        return totalSupply;
    }

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success) {

        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address _to, uint256 _value) public returns (bool success) {

        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value, empty);
        }
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint256 length;
        assembly {
        //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    //function that is called when transaction target is an address
    function transferToAddress(address _to, uint256 _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    //function that is called when transaction target is a contract
    function transferToContract(address _to, uint256 _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}


/* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/Receiver_Interface.sol */
contract ContractReceiver {

    struct TKN {
        address sender;
        uint256 value;
        bytes data;
        bytes4 sig;
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public pure {
        TKN memory tkn;
        tkn.sender = _from;
        tkn.value = _value;
        tkn.data = _data;
        uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
        tkn.sig = bytes4(u);

        /* tkn variable is analogue of msg variable of Ether transaction
        *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
        *  tkn.value the number of tokens that were sent   (analogue of msg.value)
        *  tkn.data is data of token transaction   (analogue of msg.data)
        *  tkn.sig is 4 bytes signature of function
        *  if data of token transaction is a function execution
        */
    }
}


contract bitgrit is ERC223Token {

    string public name = "bitgrit";

    string public symbol = "GRIT";

    uint8 public decimals = 18;

    uint256 public totalSupply = 1000000000 * (10 ** uint256(decimals));

    address public owner;

    // ---------------------------------------------
    // Modification : Only an owner can carry out.
    // ---------------------------------------------
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // ---------------------------------------------
    // Constructor
    // ---------------------------------------------
    function bitgrit() public {
        // The owner address is maintained.
        owner = msg.sender;

        // All tokens are allocated to an owner.
        balances[owner] = totalSupply;
    }

    // ---------------------------------------------
    // Destruction of a contract (only owner)
    // ---------------------------------------------
    function destory() public onlyOwner {
        selfdestruct(owner);
    }

}
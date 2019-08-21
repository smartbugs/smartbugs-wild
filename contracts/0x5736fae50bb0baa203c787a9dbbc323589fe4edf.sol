pragma solidity ^0.4.24;

/*
 * Government Token (GOVT) ERC20
 *
 * See https://thegovernment.network/
 */

library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract GovToken {
    using SafeMath for uint;

    string  public name = "GovToken";
    string  public symbol = "GOVT";
    string  public standard = "GovToken v1.0";
    uint256 public totalSupply = 125000000 ether; // 125,000,000 GOVT
    uint    public decimals = 18;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    // Fix for the ERC20 short address attack.
    modifier onlyPayloadSize(uint size) {
        if(msg.data.length < size + 4) {
            revert();
        }
        _;
    }

    // Constructor
    constructor() public {
        balances[msg.sender] = totalSupply;
        emit Transfer(0x00, msg.sender, totalSupply);
    }

    // Transfer
    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool success) {
        require(balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    // Check the balance
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    // Approve for another address
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_value != 0) && (allowance[msg.sender][_spender] != 0)) revert();

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    // Check approved allowance
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowance[_owner][_spender];
    }

    // Transfer from approved funds
    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool success) {
        require(_value <= balances[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    // Default function - prevents accidental money loss by sending ether to the contract
    function () payable public {
        revert();
    }

}
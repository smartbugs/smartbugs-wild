pragma solidity 0.4.24;

contract Owned {
    address public contractOwner;

    constructor() public {
        contractOwner = msg.sender;
    }

    modifier onlyContractOwner() {
        require(contractOwner == msg.sender);
        _;
    }

    function forceChangeContractOwnership(address _to) public onlyContractOwner() returns(bool) {
        contractOwner = _to;
        return true;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

contract BDCToken is Owned {
    using SafeMath for uint256;

    mapping (bytes => bool) private alreadyUsed;
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;

    string public name;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Mint(
        address indexed to,
        uint256 value
    );

    event Burn(
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(string _name) public {
        name = _name;
    }

    function transfer(address _to, uint256 _value) public returns(bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function ECDSATransfer(
        address _to,
        uint256 _value,
        bytes32 _hash,
        bytes _sig
    )
        onlyContractOwner()
        public
        returns(bytes32)
    {
        require(!alreadyUsed[_sig]);

        address from = recover(_hash, _sig);
        alreadyUsed[_sig] = true;
        _transfer(from, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns(bool)
    {
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool) {
        require(_spender != address(0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(
        address _spender,
        uint256 _added_value
    )
        public
        returns(bool)
    {
        require(_spender != address(0));

        allowed[msg.sender][_spender] = (
            allowed[msg.sender][_spender].add(_added_value)
        );
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseAllowance(
        address _spender,
        uint256 _subtracted_value
    )
        public
        returns(bool)
    {
        require(_spender != address(0));

        allowed[msg.sender][_spender] = (
            allowed[msg.sender][_spender].sub(_subtracted_value)
        );
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function mint(
        address _account,
        uint256 _value
    )
        onlyContractOwner()
        public
        returns(bool)
    {
        require(_account != address(0));

        balances[_account] = balances[_account].add(_value);
        emit Mint(_account, _value);
        return true;
    }

    function burn(
        address _account,
        uint256 _value
    )
        onlyContractOwner()
        public
        returns(bool)
    {
        require(_account != address(0));

        balances[_account] = balances[_account].sub(_value);
        emit Burn(_account, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns(uint256)
    {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

    function getName() public view returns(string) {
        return name;
    }

    function recover(
        bytes32 hash,
        bytes signature
    )
        public
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (signature.length != 65) {
            return (address(0));
        }
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    )
        internal
    {
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }
}
pragma solidity ^0.5.1;

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


contract Ownable {
    address public owner;


    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not the owner.");
        _;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}






contract ERC20Basic {
    uint public _totalSupply;
    function totalSupply() public view returns (uint);
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
}




contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}



contract BasicToken is Ownable, ERC20Basic {
    using SafeMath for uint;

    mapping(address => uint) public balances;


    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4), "Payload size is incorrect.");
        _;
    }





    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
        require(_to != address(0), "_to address is invalid.");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
    }



    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

}




contract StandardToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint)) public allowed;

    uint public constant MAX_UINT = 2**256 - 1;


    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
        require(_from != address(0), "_from address is invalid.");
        require(_to != address(0), "_to address is invalid.");

        uint _allowance = allowed[_from][msg.sender];



        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
    }


    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {


        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)), "Invalid function arguments.");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }


    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}




contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {
        require(!paused, "Token is paused.");
        _;
    }

    modifier whenPaused() {
        require(paused, "Token is unpaused.");
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }


    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

contract CrediPoints is Pausable, StandardToken {

    string public name;
    string public symbol;
    uint public decimals;

    mapping(address => bool) public authorized;
    mapping(address => bool) public blacklisted;

    constructor() public {
        name = "CrediPoints";
        symbol = "CDP";
        decimals = 4;
        setAuthorization(0x28DE6bb45c2b8A74DdFaa926F9996Ee2a7FfFba6);
        transferOwnership(0x28DE6bb45c2b8A74DdFaa926F9996Ee2a7FfFba6);
    }

    modifier onlyAuthorized() {
        require(authorized[msg.sender], "msg.sender is not authorized");
        _;
    }

    event AuthorizationSet(address _address);
    function setAuthorization(address _address) public onlyOwner {
        require(_address != address(0), "Provided address is invalid.");
        require(!authorized[_address], "Address is already authorized.");

        authorized[_address] = true;

        emit AuthorizationSet(_address);
    }

    event AuthorizationRevoked(address _address);
    function revokeAuthorization(address _address) public onlyOwner {
        require(_address != address(0), "Provided address is invalid.");
        require(authorized[_address], "Address is already unauthorized.");

        authorized[_address] = false;

        emit AuthorizationRevoked(_address);
    }

    modifier NotBlacklisted(address _address) {
        require(!blacklisted[_address], "The provided address is blacklisted.");
        _;
    }

    event BlacklistAdded(address _address);
    function addBlacklist(address _address) public onlyAuthorized {
        require(_address != address(0), "Provided address is invalid.");
        require(!blacklisted[_address], "The provided address is already blacklisted");
        blacklisted[_address] = true;

        emit BlacklistAdded(_address);
    }

    event BlacklistRemoved(address _address);
    function removeBlacklist(address _address) public onlyAuthorized {
        require(_address != address(0), "Provided address is invalid.");
        require(blacklisted[_address], "The provided address is already not blacklisted");
        blacklisted[_address] = false;

        emit BlacklistRemoved(_address);
    }

    function transfer(address _to, uint _value) public NotBlacklisted(_to) NotBlacklisted(msg.sender) whenNotPaused {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public NotBlacklisted(_to) NotBlacklisted(_from) NotBlacklisted(msg.sender) whenNotPaused {
        return super.transferFrom(_from, _to, _value);
    }

    function balanceOf(address who) public view returns (uint) {
        return super.balanceOf(who);
    }

    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {
        return super.approve(_spender, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return super.allowance(_owner, _spender);
    }


    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }


    function issue(uint amount) public onlyAuthorized {
        _totalSupply = _totalSupply.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);

        emit Issue(amount);
    }




    function redeem(uint amount) public onlyAuthorized {
        require(_totalSupply >= amount, "Redeem amount is greater than total supply.");
        require(balances[msg.sender] >= amount, "Redeem amount is greater than sender's balance.");

        _totalSupply = _totalSupply.sub(amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        emit Redeem(amount);
    }

    // Called when new token are issued
    event Issue(uint amount);

    // Called when tokens are redeemed
    event Redeem(uint amount);

}
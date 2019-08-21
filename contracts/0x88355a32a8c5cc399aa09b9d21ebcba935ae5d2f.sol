pragma solidity ^0.4.25;


contract SafeMath {
    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(int a, int b) internal pure returns (int) {
        if (b < 0) assert(a - b > a);
        else assert(a - b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
}


contract Token {
    function transfer(address receiver, uint amount) public returns (bool) {
        (receiver);
        (amount);
        return false;
    }

    function balanceOf(address holder) public view returns (uint) {
        (holder);
        return 0;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        (_spender);
        (_value);
        return false;
    }
}


contract Casino {
    function deposit(address _receiver, uint _amount, bool _chargeGas) public;
}


contract Owned {
    address public owner;
    address public receiver;
    mapping (address => bool) public moderator;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerator {
        require(moderator[msg.sender]);
        _;
    }

    modifier onlyAdmin {
        require(moderator[msg.sender] || msg.sender == owner);
        _;
    }

    constructor() internal {
        owner = msg.sender;
        receiver = msg.sender;
    }

    function setOwner(address _address) public onlyOwner {
        owner = _address;
    }

    function setReceiver(address _address) public onlyAdmin {
        receiver = _address;
    }

    function addModerator(address _address) public onlyOwner {
        moderator[_address] = true;
    }

    function removeModerator(address _address) public onlyOwner {
        moderator[_address] = false;
    }
}


contract RequiringAuthorization is Owned {
    mapping(address => bool) public authorized;

    modifier onlyAuthorized {
        require(authorized[msg.sender]);
        _;
    }

    constructor() internal {
        authorized[msg.sender] = true;
    }

    function authorize(address _address) public onlyAdmin {
        authorized[_address] = true;
    }

    function deauthorize(address _address) public onlyAdmin {
        authorized[_address] = false;
    }

}


contract Pausable is Owned {
    bool public paused = false;

    event Paused(bool _paused);

    modifier onlyPaused {
        require(paused == true);
        _;
    }

    modifier onlyActive {
        require(paused == false);
        _;
    }

    function pause() public onlyActive onlyAdmin {
        paused = true;
    }

    function activate() public onlyPaused onlyOwner {
        paused = false;
    }
}


contract BankWallet is Pausable, RequiringAuthorization, SafeMath {
    address public edgelessToken;
    address public edgelessCasino;

    uint public maxFundAmount = 0.22 ether;

    event Withdrawal(address _token, uint _amount);
    event Deposit(address _receiver, uint _amount);
    event Fund(address _receiver, uint _amount);

    constructor(address _token, address _casino) public {
        edgelessToken = _token;
        edgelessCasino = _casino;
        owner = msg.sender;
    }

    function () public payable {}

    function withdraw(address _token, uint _amount) public onlyAdmin returns (bool _success) {
        _success = false;
        if (_token == address (0)) {
            uint weiAmount = _amount;
            if (weiAmount > address(this).balance) {
                return false;
            }
            _success = receiver.send(weiAmount);
        } else {
            Token __token = Token(_token);
            uint amount = _amount;
            if (amount > __token.balanceOf(this)) {
                return false;
            }
            _success = __token.transfer(receiver, amount);
        }

        if (_success) {
            emit Withdrawal(_token, _amount);
        }
    }

    function approve(uint _amount) public onlyAuthorized {
        _approveForCasino(edgelessCasino, _amount);
    }

    function deposit(address _address, uint _amount, bool _chargeGas) public onlyAuthorized {
        Casino __casino = Casino(edgelessCasino);
        __casino.deposit(_address, _amount, _chargeGas);
        emit Deposit(_address, _amount);
    }

    function fund(address _address, uint _amount) public onlyAuthorized returns (bool _success) {
        require(_amount <= maxFundAmount);
        _success = _address.send(_amount);
        if (_success) {
            emit Fund(_address, _amount);
        }
    }

    function setCasinoContract(address _casino) public onlyAdmin {
        edgelessCasino = _casino;
        _approveForCasino(_casino, 1000000000);
    }

    function setMaxFundAmount(uint _amount) public onlyAdmin {
        maxFundAmount = _amount;
    }

    function _approveForCasino(address _address, uint _amount) internal returns (bool _success) {
        Token __token = Token(edgelessToken);
        _success = __token.approve(_address, _amount);
    }

}
pragma solidity ^ 0.4 .2;
contract Token {
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    address[] public users;
    bytes32 public filehash;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        if (owner != msg.sender) {
            throw;
        } else {
            _;
        }
    }

    function Token() {
        owner = 0x7F325a2d8365385e4B189b708274526899c17453;
       // filehash = 0x26be3f796356cf26183f91fea302911533808f5ee8f58cad05c03249a1b96997;
        address firstOwner = owner;
        balanceOf[firstOwner] = 100000000;
        totalSupply = 100000000;
        name = 'Cryptonian';
        symbol = 'crypt';
        decimals = 8;
        msg.sender.send(msg.value);
        users.push(0x7F325a2d8365385e4B189b708274526899c17453);
    }

    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        bool userExists = false;
        uint memberCount = users.length;
        for (uint i = 0; i < memberCount; i++) {
            if (users[i] == _to) {
                userExists = true;
            }
        }
        if (userExists == false) {
            users.push(_to);
        }
    }

    function approve(address _spender, uint256 _value) returns(bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function collectExcess() onlyOwner {
        owner.send(this.balance - 2100000);
    }

    function liquidate(address newOwner) onlyOwner {
        uint sellAmount = msg.value;
        uint memberCount = users.length;
        owner = newOwner;
        for (uint i = 0; i < memberCount; i++) {
            liquidateUser(users[i], sellAmount);
        }
    }

    function liquidateUser(address user, uint sentValue) onlyOwner {
        uint userBalance = balanceOf[user] * 10000000;
        uint userPercentage = userBalance / totalSupply;
        uint etherAmount = (sentValue * userPercentage) / 10000000;
        if (user.send(etherAmount)) {
            balanceOf[user] = 0;
        }
    }

    function issueDividend() onlyOwner {
        uint sellAmount = msg.value;
        uint memberCount = users.length;
        for (uint i = 0; i < memberCount; i++) {
            sendDividend(users[i], sellAmount);
        }
    }

    function sendDividend(address user, uint sentValue) onlyOwner {
        uint userBalance = balanceOf[user] * 10000000;
        uint userPercentage = userBalance / totalSupply;
        uint etherAmount = (sentValue * userPercentage) / 10000000;
        if (user.send(etherAmount)) {}
    }

    function() {}
}
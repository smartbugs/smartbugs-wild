pragma solidity ^0.4.19;

interface token {
    function transfer(address receiver, uint amount) external;
}

contract FrontToken {


    string public name = "FrontierCoin";      //  token name
    string public symbol = "FRONT";           //  token symbol
    uint256 public decimals = 6;            //  token digit

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    uint256 public totalSupply = 0;
    bool feed = false;
    uint256 constant valueFounder = 100000000000000000;
    uint256 constant valuePub = 100000000000000000;
    address owner = 0x0;
    bool public crowdsaleClosed = false;
    token tokenReward;
    uint256 public amountRaised;
    uint256 public tpe;

    function SetTPE(uint256 _value) public isOwner {
        tpe = _value;
    }

    function ToggleFeed(bool enabled) public isOwner {
        feed = enabled;
    }

    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier validAddress {
        assert(0x0 != msg.sender);
        _;
    }

    function ChangeOwner(address _newOwner) public {
        owner = _newOwner;
    }

    function FrontToken() public {
        owner = msg.sender;
        totalSupply = valueFounder + valuePub;
        balanceOf[msg.sender] = valueFounder;
        balanceOf[this] = valuePub;
        Transfer(0x0, msg.sender, valueFounder);
        Transfer(0x0, this, valuePub);
        tokenReward = token(this);
        tpe = 10000000;
    }

    function ToggleCrowdsale(bool enabled) public isOwner {
        crowdsaleClosed = enabled;
    }

    function () payable public {
        require(!crowdsaleClosed);
        uint ethAmount = msg.value;
        uint256 tokens = ethAmount * tpe / 0.000001 ether;
        balanceOf[msg.sender] += tokens;
        amountRaised += ethAmount;
        Transfer(this, msg.sender, tokens);
    }

    function transfer(address _to, uint256 _value) validAddress public returns (bool success) {
        if(feed) {
            uint256 fee = div(_value, 97);
            uint256 newValue = _value - fee;
            require(balanceOf[msg.sender] >= newValue);
            require(balanceOf[_to] + newValue >= balanceOf[_to]);
            balanceOf[msg.sender] -= newValue;
            balanceOf[_to] += newValue;
            Transfer(msg.sender, _to, newValue);
            balanceOf[owner] += fee;
            Transfer(msg.sender, owner, fee);
        }
        else {
            require(balanceOf[msg.sender] >= _value);
            require(balanceOf[_to] + _value >= balanceOf[_to]);
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            Transfer(msg.sender, _to, _value);
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) validAddress public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) validAddress public returns (bool success) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function setName(string _name) isOwner public {
        name = _name;
    }
    function setSymbol(string _symbol) isOwner public {
        symbol = _symbol;
    }

    function burn(uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[0x0] += _value;
        Transfer(msg.sender, 0x0, _value);
    }

    function ethReverse(uint256 _value) isOwner public {
        owner.transfer(_value);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
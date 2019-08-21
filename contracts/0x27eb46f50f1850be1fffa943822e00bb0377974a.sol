pragma solidity ^0.4.11;

contract KittyClub99 {

// The purpose of Kitty Club is to acknowledge all of the
// OG bad-asses who helped CK survive/grow during its infancy

// Without you, CK wouldn't be where it is today
// The CAT coin will be sent to community heroes, influential players, developers, etc
// Only 99 CAT coins will ever be minted

// You can not buy your way into the initial invitation of Kitty Club. You must be invited.
// Years in the future, we will know what path CK has taken. Assuming CK becomes a worldwide sensation,
// CAT coin could signify Kitty Club membership and may be required for entrance into exclusive yacht parties...who knows?

// Your initial invitation CAT coin is 100% yours. Feel free to sell it, gift it, send to 0x00
// Know that if you do any of these things, you will not be reinvited
// As of 11/11/2018, this is a silly project. If CK doesn't succeed, it will be an utterly meaningless token.
// If it does succeed however... See you in the Maldives ;)


    string public name = "Kitty Club est. 11/11/2018";      //  token name
    string public symbol = "CAT";           //  token symbol
    uint256 public decimals = 0;            //  token digit

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    uint256 public totalSupply = 0;
    bool public stopped = false;

    uint256 constant valueFounder = 99;  // rarer than founders!
    address owner = 0x0;

    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier isRunning {
        assert (!stopped);
        _;
    }

    modifier validAddress {
        assert(0x0 != msg.sender);
        _;
    }

    function KittyClub99(address _addressFounder) {
        owner = msg.sender;
        totalSupply = valueFounder;
        balanceOf[_addressFounder] = valueFounder;
        Transfer(0x0, _addressFounder, valueFounder);
    }

    function transfer(address _to, uint256 _value) isRunning validAddress returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) isRunning validAddress returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) isRunning validAddress returns (bool success) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function stop() isOwner {
        stopped = true;
    }

    function start() isOwner {
        stopped = false;
    }

    function setName(string _name) isOwner {
        name = _name;
    }

    function burn(uint256 _value) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[0x0] += _value;
        Transfer(msg.sender, 0x0, _value);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
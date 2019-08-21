pragma solidity ^0.4.16;

contract owned {
    constructor () public { owner = msg.sender; }
    address owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract TokenArtFinity is owned {
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    string public name = "ArtFinity";    //token name
    uint8 public decimals = 5;              
    string public symbol = "AT";           
    uint256 public totalSupply = 100000000000000; 
    GoodsTransferInfo[] public goodsTransferArray;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    struct GoodsTransferInfo {
        address withDrawAddress;
        uint32 goodsId;
        uint32 goodsNum;
    }

    constructor () public {
        balances[msg.sender] = totalSupply; 
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_to != 0x0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferTokenWithGoods(address goodsWithdrawer, uint256 _value, uint32 goodsId, uint32 goodsNum) public onlyOwner returns (bool success) {
        
        require(balances[msg.sender] >= _value && balances[goodsWithdrawer] + _value > balances[goodsWithdrawer]);
        require(goodsWithdrawer != 0x0);
        balances[msg.sender] -= _value;
        balances[goodsWithdrawer] += _value;
        goodsTransferArray.push(GoodsTransferInfo(goodsWithdrawer, goodsId, goodsNum));
        emit Transfer(msg.sender, goodsWithdrawer, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value; 
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success)   
    { 
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function goodsTransferArrayLength() public constant returns(uint256 length) {
        return goodsTransferArray.length;
    }
}
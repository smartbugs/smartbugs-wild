pragma solidity ^0.4.24;

contract MathLib 
{
    function add(uint256 x, uint256 y) pure internal returns (uint256 z) 
    {
        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) pure internal returns (uint256 z) 
    {
        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) pure internal returns (uint256 z) 
    {
        assert((z = x * y) >= x);
    }

    function div(uint256 x, uint256 y) pure internal returns (uint256 z) 
    {
        z = x / y;
    }

    function min(uint256 x, uint256 y) pure internal returns (uint256 z) 
    {
        return x <= y ? x : y;
    }
    
    function max(uint256 x, uint256 y) pure internal returns (uint256 z) 
    {
        return x >= y ? x : y;
    }

}

contract ERC20 
{
    function totalSupply() public constant returns (uint supply);
    function balanceOf(address who) public constant returns (uint value);
    function allowance(address owner, address spender) public constant returns (uint _allowance);

    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool ok);
    function approve(address spender, uint value) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract TokenBase is ERC20, MathLib 
{
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;
    
    constructor(uint256 supply) public 
    {
        _balances[msg.sender] = supply;
        _supply = supply;
    }
    
    function totalSupply() public constant returns (uint256) 
    {
        return _supply;
    }
    
    function balanceOf(address src) public constant returns (uint256) 
    {
        return _balances[src];
    }
    
    function allowance(address src, address guy) public constant returns (uint256) 
    {
        return _approvals[src][guy];
    }
    
    function transfer(address dst, uint wad) public returns (bool) 
    {
        assert(_balances[msg.sender] >= wad);
        
        _balances[msg.sender] = sub(_balances[msg.sender], wad);
        _balances[dst] = add(_balances[dst], wad);
        
        emit Transfer(msg.sender, dst, wad);
        
        return true;
    }
    
    function transferFrom(address src, address dst, uint wad) public returns (bool)
    {
        assert(_balances[src] >= wad);
        assert(_approvals[src][msg.sender] >= wad);
        
        _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);
        
        emit Transfer(src, dst, wad);
        
        return true;
    }
    
    function approve(address guy, uint256 wad) public returns (bool)
    {
        _approvals[msg.sender][guy] = wad;
        
        emit Approval(msg.sender, guy, wad);
        
        return true;
    }

}

interface GatewayVote 
{
    function burnForGateway(address from, string receiver, uint64 wad) external;
}

contract WBCHToken is TokenBase(0) 
{

    uint8   public  decimals = 8;
    address private Gateway;
        
    string  public  name   = "Wrapped BCH (BCH-MALLOW-ETH for standard)";
    string  public  symbol = "WBCH";
    
    
    event Mint(address receiver, uint64 wad);
    event Burn(address from, string receiver, uint64 wad);
    event GatewayChangedTo(address newer);

    constructor(address gateway) public
    {
        Gateway = gateway;
        emit GatewayChangedTo(Gateway);
    }

    function transfer(address dst, uint wad) public returns (bool)
    {
        return super.transfer(dst, wad);
    }
    
    function transferFrom(address src, address dst, uint wad) public returns (bool) 
    {
        return super.transferFrom(src, dst, wad);
    }
    
    function approve(address guy, uint wad) public returns (bool) 
    {
        return super.approve(guy, wad);
    }

    function mint(address receiver, uint64 wad) external returns (bool)
    {
        require(msg.sender == Gateway);
        
        _balances[receiver] = add(_balances[receiver], wad);
        _supply = add(_supply, wad);
        
        emit Mint(receiver, wad);
        
        return true;
    }
    
    function changeGatewayAddr(address newer) external returns (bool)
    {
        require(msg.sender == Gateway);
        Gateway = newer;
        
        emit GatewayChangedTo(Gateway);
        
        return true;
    }
    
    function burn(uint64 wad, string receiver) external
    {
        assert(_balances[msg.sender] >= wad);
        
        _balances[msg.sender] = sub(_balances[msg.sender], wad);
        _supply = sub(_supply, wad);
        
        emit Burn(msg.sender, receiver, wad);
        
        GatewayVote(Gateway).burnForGateway(msg.sender, receiver, wad);
    }
}
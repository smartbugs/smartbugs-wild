pragma solidity ^0.4.18;

contract safeMath {

    function add( uint256 x, uint256 y ) internal pure returns ( uint256 z ) {
        assert( ( z = x + y ) >= x );
    }

    function sub( uint256 x, uint256 y ) internal pure returns ( uint256 z ) {
        assert( ( z = x - y ) <= x );
    }
}

contract ERC20 {
    function    totalSupply() public constant returns (uint);
    function    balanceOf(address who) public view returns (uint256);
    function    allowance(address owner, address spender) public view returns (uint256);

    function    transfer(address to, uint256 value) public returns (bool);
    function    transferFrom(address from, address to, uint256 value) public returns (bool);
    function    approve(address spender, uint256 value) public returns (bool);

    event       Transfer( address indexed from, address indexed to, uint value );
    event       Approval( address indexed owner, address indexed spender, uint value );
}

contract    baseToken is ERC20, safeMath {
    uint256         _totalSupply;
    string          _name;
    string          _symbol;
    uint8           _decimals;

    mapping ( address => uint256 )                          _balanceOf;
    mapping ( address => mapping ( address => uint256 ) )   _allowance;

    event Burn( address indexed from, uint256 value );

    function    baseToken( ) public {
        uint256     balance;

        balance = 50000;
        _name = "Onkostop";
        _symbol = "OSC";
        _balanceOf[msg.sender] = balance;
        _totalSupply = balance;
        _decimals = 0;
    }   

    function    totalSupply() public constant returns ( uint256 ) {
        return _totalSupply;
    }

    function    balanceOf( address user ) public view returns ( uint256 ) {
        return _balanceOf[user];
    }

    function    allowance( address owner, address spender ) public view returns ( uint256 ) {
        return _allowance[owner][spender];
    }

    function    transfer( address to, uint amount ) public returns ( bool ) {
        assert(_balanceOf[msg.sender] >= amount);
        _balanceOf[msg.sender] = sub( _balanceOf[msg.sender], amount );
        _balanceOf[to] = add( _balanceOf[to], amount );
        Transfer( msg.sender, to, amount );
        return true;
    }

    function    transferFrom( address from, address to, uint amount ) public returns ( bool ) {
        assert( _balanceOf[from] >= amount );
        assert( _allowance[from][msg.sender] >= amount );
        _allowance[from][msg.sender] = sub( _allowance[from][msg.sender], amount );
        _balanceOf[from] = sub( _balanceOf[from], amount );
        _balanceOf[to] = add( _balanceOf[to], amount );
        Transfer( from, to, amount );
        return true;
    }

    function    approve( address spender, uint256 amount ) public returns ( bool ) {
        _allowance[msg.sender][spender] = amount;
        Approval( msg.sender, spender, amount );
        return true;
    }

    function    burn( uint256 value ) public returns ( bool success ) {
        assert( _balanceOf[msg.sender] >= value );  // Check if the sender has enough
        _balanceOf[msg.sender] -= value;            // Subtract from the sender
        _totalSupply -= value;                      // Updates _totalSupply
        Burn( msg.sender, value );
        return true;
    }
}
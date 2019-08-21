pragma solidity ^0.4.19;

contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal pure returns ( uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function safeSub(uint256 x, uint256 y) internal pure returns ( uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns ( uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }

}

contract ERC20 {
    function totalSupply() constant public returns ( uint supply);

    function balanceOf( address who ) constant public returns ( uint value);
    function allowance( address owner, address spender ) constant public returns (uint _allowance);
    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}

//implement 
contract StandardToken is SafeMath,ERC20 {
    uint256     _totalSupply;
    
    function totalSupply() constant public returns ( uint256) {
        return _totalSupply;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        assert(balances[msg.sender] >= wad);
        
        balances[msg.sender] = safeSub(balances[msg.sender], wad);
        balances[dst] = safeAdd(balances[dst], wad);
        
        Transfer(msg.sender, dst, wad);
        
        return true;
    }
    
    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        assert(wad > 0 );
        assert(balances[src] >= wad);
        
        balances[src] = safeSub(balances[src], wad);
        balances[dst] = safeAdd(balances[dst], wad);
        
        Transfer(src, dst, wad);
        
        return true;
    }

    function balanceOf(address _owner) constant public returns ( uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns ( bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns ( uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function freezeOf(address _owner) constant public returns ( uint256 balance) {
        return freezes[_owner];
    }
    

    mapping (address => uint256) balances;
    mapping (address => uint256) freezes;
    mapping (address => mapping (address => uint256)) allowed;
}

contract DSAuth {
    address public authority;
    address public owner;

    function DSAuth() public {
        owner = msg.sender;
        authority = msg.sender;
    }

    function setOwner(address owner_) Owner public
    {
        owner = owner_;
    }

    modifier Auth {
        assert(isAuthorized(msg.sender));
        _;
    }
    
    modifier Owner {
        assert(msg.sender == owner);
        _;
    }

    function isAuthorized(address src) internal view returns ( bool) {
        if (src == address(this)) {
            return true;
        } else if (src == authority) {
            return true;
        }
        else if (src == owner) {
            return true;
        }
        return false;
    }

}

contract DRCToken is StandardToken,DSAuth {

    string public name = "Digit RedWine Coin";
    uint8 public decimals = 18;
    string public symbol = "DRC";
    
    /* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);
    
    /* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);
    
    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    function DRCToken() public {
        
    }

    function mint(uint256 wad) Owner public {
        balances[msg.sender] = safeAdd(balances[msg.sender], wad);
        _totalSupply = safeAdd(_totalSupply, wad);
    }

    function burn(uint256 wad) Owner public {
        balances[msg.sender] = safeSub(balances[msg.sender], wad);
        _totalSupply = safeSub(_totalSupply, wad);
        Burn(msg.sender, wad);
    }

    function push(address dst, uint256 wad) public returns ( bool) {
        return transfer(dst, wad);
    }

    function pull(address src, uint256 wad) public returns ( bool) {
        return transferFrom(src, msg.sender, wad);
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return super.transfer(dst, wad);
    }
    
    function freeze(address dst,uint256 _value) Auth public returns (bool success) {
        assert(balances[dst] >= _value); // Check if the sender has enough
        assert(_value > 0) ; 
        balances[dst] = SafeMath.safeSub(balances[dst], _value);                      // Subtract from the sender
        freezes[dst] = SafeMath.safeAdd(freezes[dst], _value);                                // Updates totalSupply
        Freeze(dst, _value);
        return true;
    }
    
    function unfreeze(address dst,uint256 _value) Auth public returns (bool success) {
        assert(freezes[dst] >= _value);            // Check if the sender has enough
        assert(_value > 0) ; 
        freezes[dst] = SafeMath.safeSub(freezes[dst], _value);                      // Subtract from the sender
        balances[dst] = SafeMath.safeAdd(balances[dst], _value);
        Unfreeze(dst, _value);
        return true;
    }
}
pragma solidity >=0.5.0 <0.6.0;

/// @dev The token controller contract must implement these functions
contract TokenController {
    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _fromBalance Original token balance of _from address
    /// @param _amount The amount of the transfer
    /// @return The adjusted transfer amount filtered by a specific token controller.
    function onTokenTransfer(address _from, uint _fromBalance, uint _amount) public returns(uint);
}


contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}


contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint256           wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);

        _;
    }
}


contract ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf( address who ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);

    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}





contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}






contract DSStop is DSNote, DSAuth {
    bool public stopped;

    modifier stoppable {
        require(!stopped, "ds-stop-is-stopped");
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }
}



contract Managed {
    /// @notice The address of the manager is the only address that can call
    ///  a function with this modifier
    modifier onlyManager { require(msg.sender == manager); _; }

    address public manager;

    constructor() public { manager = msg.sender;}

    /// @notice Changes the manager of the contract
    /// @param _newManager The new manager of the contract
    function changeManager(address _newManager) public onlyManager {
        manager = _newManager;
    }
    
    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) view internal returns(bool) {
        uint size = 0;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}






contract ControllerManager is DSAuth {
    address[] public controllers;
    
    function addController(address _ctrl) public auth {
        require(_ctrl != address(0));
        controllers.push(_ctrl);
    }
    
    function removeController(address _ctrl) public auth {
        for (uint idx = 0; idx < controllers.length; idx++) {
            if (controllers[idx] == _ctrl) {
                controllers[idx] = controllers[controllers.length - 1];
                controllers.length -= 1;
                return;
            }
        }
    }
    
    // Return the adjusted transfer amount after being filtered by all token controllers.
    function onTransfer(address _from, uint _fromBalance, uint _amount) public returns(uint) {
        uint adjustedAmount = _amount;
        for (uint i = 0; i < controllers.length; i++) {
            adjustedAmount = TokenController(controllers[i]).onTokenTransfer(_from, _fromBalance, adjustedAmount);
            require(adjustedAmount <= _amount, "TokenController-isnot-allowed-to-lift-transfer-amount");
            if (adjustedAmount == 0) return 0;
        }
        return adjustedAmount;
    }
}


contract DOSToken is ERC20, DSMath, DSStop, Managed {
    string public constant name = 'DOS Network Token';
    string public constant symbol = 'DOS';
    uint256 public constant decimals = 18;
    uint256 private constant MAX_SUPPLY = 1e9 * 1e18; // 1 billion total supply
    uint256 private _supply = MAX_SUPPLY;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256))  _approvals;
    
    constructor() public {
        _balances[msg.sender] = _supply;
        emit Transfer(address(0), msg.sender, _supply);
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public stoppable returns (bool) {
        require(_balances[src] >= wad, "token-insufficient-balance");

        // Adjust token transfer amount if necessary.
        if (isContract(manager)) {
            wad = ControllerManager(manager).onTransfer(src, _balances[src], wad);
            require(wad > 0, "transfer-disabled-by-ControllerManager");
        }

        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            require(_approvals[src][msg.sender] >= wad, "token-insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy) public stoppable returns (bool) {
        return approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_guy, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((wad == 0) || (_approvals[msg.sender][guy] == 0));
        
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }

    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        require(_supply <= MAX_SUPPLY, "Total supply overflow");
        emit Transfer(address(0), guy, wad);
    }
    
    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            require(_approvals[guy][msg.sender] >= wad, "token-insufficient-approval");
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        require(_balances[guy] >= wad, "token-insufficient-balance");
        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        emit Transfer(guy, address(0), wad);
    }
    
    /// @notice Ether sent to this contract won't be returned, thank you.
    function () external payable {}

    /// @notice This method can be used by the owner to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token, address payable _dst) public auth {
        if (_token == address(0)) {
            _dst.transfer(address(this).balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(_dst, balance);
    }
}
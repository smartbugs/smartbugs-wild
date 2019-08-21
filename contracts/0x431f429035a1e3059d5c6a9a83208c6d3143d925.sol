pragma solidity 0.4.24;


contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}


contract DSAuthority {
    function canCall(address src, address dst, bytes4 sig) public view returns (bool);
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
        emit LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "DSAuth::_ SENDER_NOT_AUTHORIZED");
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
            return authority.canCall(src, this, sig);
        }
    }
}


contract WETH9 {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed _owner, address indexed _spender, uint _value);
    event  Transfer(address indexed _from, address indexed _to, uint _value);
    event  Deposit(address indexed _owner, uint _value);
    event  Withdrawal(address indexed _owner, uint _value);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() public payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return this.balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        Transfer(src, dst, wad);

        return true;
    }
}


contract Utils {

    modifier addressValid(address _address) {
        require(_address != address(0), "Utils::_ INVALID_ADDRESS");
        _;
    }

}


contract Config is DSNote, DSAuth, Utils {

    WETH9 public weth9;
    mapping (address => bool) public isAccountHandler;
    mapping (address => bool) public isAdmin;
    address[] public admins;
    bool public disableAdminControl = false;
    
    event LogAdminAdded(address indexed _admin, address _by);
    event LogAdminRemoved(address indexed _admin, address _by);

    constructor() public {
        admins.push(msg.sender);
        isAdmin[msg.sender] = true;
    }

    modifier onlyAdmin(){
        require(isAdmin[msg.sender], "Config::_ SENDER_NOT_AUTHORIZED");
        _;
    }

    function setWETH9
    (
        address _weth9
    ) 
        public
        auth
        note
        addressValid(_weth9) 
    {
        weth9 = WETH9(_weth9);
    }

    function setAccountHandler
    (
        address _accountHandler,
        bool _isAccountHandler
    )
        public
        auth
        note
        addressValid(_accountHandler)
    {
        isAccountHandler[_accountHandler] = _isAccountHandler;
    }

    function toggleAdminsControl() 
        public
        auth
        note
    {
        disableAdminControl = !disableAdminControl;
    }

    function isAdminValid(address _admin)
        public
        view
        returns (bool)
    {
        if(disableAdminControl) {
            return true;
        } else {
            return isAdmin[_admin];
        }
    }

    function getAllAdmins()
        public
        view
        returns(address[])
    {
        return admins;
    }

    function addAdmin
    (
        address _admin
    )
        external
        note
        onlyAdmin
        addressValid(_admin)
    {   
        require(!isAdmin[_admin], "Config::addAdmin ADMIN_ALREADY_EXISTS");

        admins.push(_admin);
        isAdmin[_admin] = true;

        emit LogAdminAdded(_admin, msg.sender);
    }

    function removeAdmin
    (
        address _admin
    ) 
        external
        note
        onlyAdmin
        addressValid(_admin)
    {   
        require(isAdmin[_admin], "Config::removeAdmin ADMIN_DOES_NOT_EXIST");
        require(msg.sender != _admin, "Config::removeAdmin ADMIN_NOT_AUTHORIZED");

        isAdmin[_admin] = false;

        for (uint i = 0; i < admins.length - 1; i++) {
            if (admins[i] == _admin) {
                admins[i] = admins[admins.length - 1];
                admins.length -= 1;
                break;
            }
        }

        emit LogAdminRemoved(_admin, msg.sender);
    }
}
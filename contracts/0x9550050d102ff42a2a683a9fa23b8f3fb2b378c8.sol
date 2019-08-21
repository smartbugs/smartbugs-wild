pragma solidity 0.4.24;


interface UniswapFactory {
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);
}


contract ErrorUtils {

    event LogError(string methodSig, string errMsg);
    event LogErrorWithHintBytes32(bytes32 indexed bytes32Value, string methodSig, string errMsg);
    event LogErrorWithHintAddress(address indexed addressValue, string methodSig, string errMsg);

}


contract SelfAuthorized {
    modifier authorized() {
        require(msg.sender == address(this), "Method can only be called from this contract");
        _;
    }
}


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


contract UniswapExchange {

    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);

    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_tokens, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);

    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);

}


interface ERC20 {

    function name() external view returns(string);
    function symbol() external view returns(string);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns (uint);

    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract Utils {

    modifier addressValid(address _address) {
        require(_address != address(0), "Utils::_ INVALID_ADDRESS");
        _;
    }

}


contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    // custom : not in original DSMath, putting it here for consistency, copied from SafeMath
    function div(uint x, uint y) internal pure returns (uint z) {
        z = x / y;
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


library ECRecovery {

    function recover(bytes32 _hash, bytes _sig)
        internal
        pure
    returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (_sig.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(_hash, v, r, s);
        }
    }

    function toEthSignedMessageHash(bytes32 _hash)
        internal
        pure
    returns (bytes32)
    {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
        );
    }
}


contract Utils2 {
    using ECRecovery for bytes32;
    
    function _recoverSigner(bytes32 _hash, bytes _signature) 
        internal
        pure
        returns(address _signer)
    {
        return _hash.toEthSignedMessageHash().recover(_signature);
    }

}


contract DSThing is DSNote, DSAuth, DSMath {

    function S(string s) internal pure returns (bytes4) {
        return bytes4(keccak256(s));
    }

}


contract MasterCopy is SelfAuthorized {
  // masterCopy always needs to be first declared variable, to ensure that it is at the same location as in the Proxy contract.
  // It should also always be ensured that the address is stored alone (uses a full word)
    address masterCopy;

  /// @dev Allows to upgrade the contract. This can only be done via a Safe transaction.
  /// @param _masterCopy New contract address.
    function changeMasterCopy(address _masterCopy)
        public
        authorized
    {
        // Master copy address cannot be null.
        require(_masterCopy != 0, "Invalid master copy address provided");
        masterCopy = _masterCopy;
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


contract Account is MasterCopy, DSNote, Utils, Utils2, ErrorUtils {

    address[] public users;
    mapping (address => bool) public isUser;
    mapping (bytes32 => bool) public actionCompleted;

    WETH9 public weth9;
    Config public config;
    bool public isInitialized = false;

    event LogTransferBySystem(address indexed token, address indexed to, uint value, address by);
    event LogTransferByUser(address indexed token, address indexed to, uint value, address by);
    event LogUserAdded(address indexed user, address by);
    event LogUserRemoved(address indexed user, address by);
    event LogImplChanged(address indexed newImpl, address indexed oldImpl);

    modifier initialized() {
        require(isInitialized, "Account::_ ACCOUNT_NOT_INITIALIZED");
        _;
    }

    modifier notInitialized() {
        require(!isInitialized, "Account::_ ACCOUNT_ALREADY_INITIALIZED");
        _;
    }

    modifier userExists(address _user) {
        require(isUser[_user], "Account::_ INVALID_USER");
        _;
    }

    modifier userDoesNotExist(address _user) {
        require(!isUser[_user], "Account::_ USER_DOES_NOT_EXISTS");
        _;
    }

    modifier onlyAdmin() {
        require(config.isAdminValid(msg.sender), "Account::_ INVALID_ADMIN_ACCOUNT");
        _;
    }

    modifier onlyHandler(){
        require(config.isAccountHandler(msg.sender), "Account::_ INVALID_ACC_HANDLER");
        _;
    }

    function init(address _user, address _config)
        public 
        notInitialized
    {
        users.push(_user);
        isUser[_user] = true;
        config = Config(_config);
        weth9 = config.weth9();
        isInitialized = true;
    }
    
    function getAllUsers() public view returns (address[]) {
        return users;
    }

    function balanceFor(address _token) public view returns (uint _balance){
        _balance = ERC20(_token).balanceOf(this);
    }
    
    function transferBySystem
    (   
        address _token,
        address _to,
        uint _value
    ) 
        external 
        onlyHandler
        note 
        initialized
    {
        require(ERC20(_token).balanceOf(this) >= _value, "Account::transferBySystem INSUFFICIENT_BALANCE_IN_ACCOUNT");
        ERC20(_token).transfer(_to, _value);

        emit LogTransferBySystem(_token, _to, _value, msg.sender);
    }
    
    function transferByUser
    (   
        address _token,
        address _to,
        uint _value,
        uint _salt,
        bytes _signature
    )
        external
        addressValid(_to)
        note
        initialized
        onlyAdmin
    {
        bytes32 actionHash = _getTransferActionHash(_token, _to, _value, _salt);

        if(actionCompleted[actionHash]) {
            emit LogError("Account::transferByUser", "ACTION_ALREADY_PERFORMED");
            return;
        }

        if(ERC20(_token).balanceOf(this) < _value){
            emit LogError("Account::transferByUser", "INSUFFICIENT_BALANCE_IN_ACCOUNT");
            return;
        }

        address signer = _recoverSigner(actionHash, _signature);

        if(!isUser[signer]) {
            emit LogError("Account::transferByUser", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }

        actionCompleted[actionHash] = true;
        
        if (_token == address(weth9)) {
            weth9.withdraw(_value);
            _to.transfer(_value);
        } else {
            require(ERC20(_token).transfer(_to, _value), "Account::transferByUser TOKEN_TRANSFER_FAILED");
        }

        emit LogTransferByUser(_token, _to, _value, signer);
    }

    function addUser
    (
        address _user,
        uint _salt,
        bytes _signature
    )
        external 
        note 
        addressValid(_user)
        userDoesNotExist(_user)
        initialized
        onlyAdmin
    {   
        bytes32 actionHash = _getUserActionHash(_user, "ADD_USER", _salt);
        if(actionCompleted[actionHash])
        {
            emit LogError("Account::addUser", "ACTION_ALREADY_PERFORMED");
            return;
        }

        address signer = _recoverSigner(actionHash, _signature);

        if(!isUser[signer]) {
            emit LogError("Account::addUser", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }

        actionCompleted[actionHash] = true;

        users.push(_user);
        isUser[_user] = true;

        emit LogUserAdded(_user, signer);
    }

    function removeUser
    (
        address _user,
        uint _salt,
        bytes _signature
    ) 
        external
        note
        userExists(_user) 
        initialized
        onlyAdmin
    {   
        bytes32 actionHash = _getUserActionHash(_user, "REMOVE_USER", _salt);

        if(actionCompleted[actionHash]) {
            emit LogError("Account::removeUser", "ACTION_ALREADY_PERFORMED");
            return;
        }

        address signer = _recoverSigner(actionHash, _signature);
        
        if(users.length == 1){
            emit LogError("Account::removeUser",  "ACC_SHOULD_HAVE_ATLEAST_ONE_USER");
            return;
        }
        
        if(!isUser[signer]){
            emit LogError("Account::removeUser", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }
        
        actionCompleted[actionHash] = true;

        // should delete value from isUser map? delete isUser[_user]?
        isUser[_user] = false;
        for (uint i = 0; i < users.length - 1; i++) {
            if (users[i] == _user) {
                users[i] = users[users.length - 1];
                users.length -= 1;
                break;
            }
        }

        emit LogUserRemoved(_user, signer);
    }

    function _getTransferActionHash
    ( 
        address _token,
        address _to,
        uint _value,
        uint _salt
    ) 
        internal
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                _token,
                _to,
                _value,
                _salt
            )
        );
    }

    function _getUserActionHash
    ( 
        address _user,
        string _action,
        uint _salt
    ) 
        internal
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                _user,
                _action,
                _salt
            )
        );
    }

    // to directly send ether to contract
    function() external payable {
        require(msg.data.length == 0 && msg.value > 0, "Account::fallback INVALID_ETHER_TRANSFER");

        if(msg.sender != address(weth9)){
            weth9.deposit.value(msg.value)();
        }
    }

    function changeImpl
    (
        address _to,
        uint _salt,
        bytes _signature
    )
        external 
        note 
        addressValid(_to)
        initialized
        onlyAdmin
    {   
        bytes32 actionHash = _getUserActionHash(_to, "CHANGE_ACCOUNT_IMPLEMENTATION", _salt);
        if(actionCompleted[actionHash])
        {
            emit LogError("Account::changeImpl", "ACTION_ALREADY_PERFORMED");
            return;
        }

        address signer = _recoverSigner(actionHash, _signature);

        if(!isUser[signer]) {
            emit LogError("Account::changeImpl", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }

        actionCompleted[actionHash] = true;

        address oldImpl = masterCopy;
        this.changeMasterCopy(_to);
        
        emit LogImplChanged(_to, oldImpl);
    }

}


contract Escrow is DSNote, DSAuth {

    event LogTransfer(address indexed token, address indexed to, uint value);
    event LogTransferFromAccount(address indexed account, address indexed token, address indexed to, uint value);

    function transfer
    (
        address _token,
        address _to,
        uint _value
    )
        public
        note
        auth
    {
        require(ERC20(_token).transfer(_to, _value), "Escrow::transfer TOKEN_TRANSFER_FAILED");
        emit LogTransfer(_token, _to, _value);
    }

    function transferFromAccount
    (
        address _account,
        address _token,
        address _to,
        uint _value
    )
        public
        note
        auth
    {   
        Account(_account).transferBySystem(_token, _to, _value);
        emit LogTransferFromAccount(_account, _token, _to, _value);
    }

}

// issue with deploying multiple instances of same type in truffle, hence the following two contracts
contract KernelEscrow is Escrow {

}

contract ReserveEscrow is Escrow {
    
}


interface ExchangeConnector {

    function tradeWithInputFixed
    (   
        Escrow _escrow,
        address _srcToken,
        address _destToken,
        uint _srcTokenValue
    )
        external
        returns (uint _destTokenValue, uint _srcTokenValueLeft);

    function tradeWithOutputFixed
    (   
        Escrow _escrow,
        address _srcToken,
        address _destToken,
        uint _srcTokenValue,
        uint _maxDestTokenValue
    )
        external
        returns (uint _destTokenValue, uint _srcTokenValueLeft);
    

    function getExpectedRate(address _srcToken, address _destToken, uint _srcTokenValue) 
        external
        view
        returns(uint _expectedRate, uint _slippageRate);
    
    function isTradeFeasible(address _srcToken, address _destToken, uint _srcTokenValue) 
        external
        view
        returns(bool);

}


contract UniswapConnector is ExchangeConnector, DSThing, Utils {
    UniswapFactory public uniswapFactory;

    uint constant internal TOKEN_ALLOWED_SLIPPAGE = 4 * (10**16);
    uint constant internal DEADLINE_DURATION = 2 * 60 * 60; // 2 hr

    constructor(UniswapFactory _uniswapFactory) public {
        uniswapFactory = _uniswapFactory;
    }

    function setUniswapFactory(UniswapFactory _uniswapFactory) 
        public
        auth
        addressValid(_uniswapFactory)
    {
        uniswapFactory = _uniswapFactory;
    }

    event LogTrade
    (
        address indexed _from,
        address indexed _srcToken,
        address indexed _destToken,
        uint _srcTokenValue,
        uint _maxDestTokenValue,
        uint _destTokenValue,
        uint _srcTokenValueLeft, 
        uint _exchangeRate
    );

    
    function tradeWithInputFixed
    (   
        Escrow _escrow,
        address _srcToken,
        address _destToken,
        uint _srcTokenValue
    )
        public    
        note
        auth
        returns (uint _destTokenValue, uint _srcTokenValueLeft)
    {      
        require(_srcToken != _destToken, "UniswapConnector::_validateTradeInputs TOKEN_ADDRS_SHOULD_NOT_MATCH");
        require(_isExchangeAvailable(_srcToken), "UniswapConnector::_validateTradeInputs NO_EXCHNAGE_FOUND_FOR_SOURCE");
        require(_isExchangeAvailable(_destToken), "UniswapConnector::_validateTradeInputs NO_EXCHNAGE_FOUND_FOR_DEST");
        require(ERC20(_srcToken).balanceOf(_escrow) >= _srcTokenValue, "UniswapConnector::_validateTradeInputs INSUFFICIENT_BALANCE_IN_ESCROW");

        uint initialSrcTokenBalance = ERC20(_srcToken).balanceOf(this);
        uint initialDestTokenBalance = ERC20(_destToken).balanceOf(this);
        _escrow.transfer(_srcToken, this, _srcTokenValue);

        address uniswapExchangeAddr = uniswapFactory.getExchange(_srcToken);
        
        ERC20(_srcToken).approve(uniswapExchangeAddr, 0);
        ERC20(_srcToken).approve(uniswapExchangeAddr, _srcTokenValue);
        
        uint exchangeRate = _performTradeWithInputFixed(_srcToken, _destToken, _srcTokenValue);

        _srcTokenValueLeft = sub(ERC20(_srcToken).balanceOf(this), initialSrcTokenBalance);
        _destTokenValue = sub(ERC20(_destToken).balanceOf(this), initialDestTokenBalance);

        _transfer(_destToken, _escrow, _destTokenValue);

        if (_srcTokenValueLeft > 0) {
            _transfer(_srcToken, _escrow, _srcTokenValueLeft);
        }
        
        emit LogTrade(_escrow, _srcToken, _destToken, _srcTokenValue, _destTokenValue, _destTokenValue, _srcTokenValueLeft, exchangeRate);
    }

    function tradeWithOutputFixed
    (   
        Escrow _escrow,
        address _srcToken,
        address _destToken,
        uint _srcTokenValue,
        uint _maxDestTokenValue
    )
        public
        note
        auth
        returns (uint _destTokenValue, uint _srcTokenValueLeft)
    {   

        require(_srcToken != _destToken, "UniswapConnector::_validateTradeInputs TOKEN_ADDRS_SHOULD_NOT_MATCH");
        require(_isExchangeAvailable(_srcToken), "UniswapConnector::_validateTradeInputs NO_EXCHNAGE_FOUND_FOR_SOURCE");
        require(_isExchangeAvailable(_destToken), "UniswapConnector::_validateTradeInputs NO_EXCHNAGE_FOUND_FOR_DEST");
        require(ERC20(_srcToken).balanceOf(_escrow) >= _srcTokenValue, "UniswapConnector::_validateTradeInputs INSUFFICIENT_BALANCE_IN_ESCROW");

        uint initialSrcTokenBalance = ERC20(_srcToken).balanceOf(this);
        uint initialDestTokenBalance = ERC20(_destToken).balanceOf(this);
        _escrow.transfer(_srcToken, this, _srcTokenValue);

        address uniswapExchangeAddr = uniswapFactory.getExchange(_srcToken);

        require(ERC20(_srcToken).approve(uniswapExchangeAddr, 0), "UniswapConnector::tradeWithOutputFixed SRC_APPROVAL_FAILED");
        require(ERC20(_srcToken).approve(uniswapExchangeAddr, _srcTokenValue), "UniswapConnector::tradeWithOutputFixed SRC_APPROVAL_FAILED");

        uint exchangeRate = _performTradeWithOutputFixed(_srcToken, _destToken, _maxDestTokenValue);

        _srcTokenValueLeft = sub(ERC20(_srcToken).balanceOf(this), initialSrcTokenBalance);
        _destTokenValue = sub(ERC20(_destToken).balanceOf(this), initialDestTokenBalance);

        require(_transfer(_destToken, _escrow, _destTokenValue), "UniswapConnector::tradeWithOutputFixed DEST_TOKEN_TRANSFER_FAILED");

        if(_srcTokenValueLeft > 0){
            require(_transfer(_srcToken, _escrow, _srcTokenValueLeft), "UniswapConnector::tradeWithOutputFixed SRC_TOKEN_TRANSFER_FAILED");
        }

        emit LogTrade(_escrow, _srcToken, _destToken, _srcTokenValue, _maxDestTokenValue, _destTokenValue, _srcTokenValueLeft, exchangeRate);
    } 
    
    function getExpectedRate(address _srcToken, address _destToken, uint _srcTokenValue) 
        public
        view
        returns(uint _expectedRate, uint _slippageRate)
    {
        if(address(_srcToken) == address(_destToken)) {
            return (0, 0);
        }

        if(!_isExchangeAvailable(_srcToken) || !_isExchangeAvailable(_destToken)) {
            return (0, 0);
        }

        uint inputValue = _srcTokenValue; 
        uint outputValue; 
        uint exchangeRate;

        (outputValue, exchangeRate) = _calcValuesForTokenToTokenInput(_srcToken, _destToken, inputValue);
        // todo: make slippage 0 if its too low, define a low value
        _expectedRate = exchangeRate;
        _slippageRate = div(mul(exchangeRate, sub(WAD, TOKEN_ALLOWED_SLIPPAGE)), WAD);
    }

    function isTradeFeasible(address _srcToken, address _destToken, uint _srcTokenValue)
        public
        view
        returns(bool)
    {
        uint slippageRate; 

        (, slippageRate) = getExpectedRate(
            _srcToken,
            _destToken,
            _srcTokenValue
        );

            return slippageRate == 0 ? false : true;
    }
    
    function _isExchangeAvailable(address _token)
        internal
        view
        returns(bool)
    {
        address uniswapExchangeAddr = uniswapFactory.getExchange(_token);
        return (uniswapExchangeAddr != address(0));
    }

    function _performTradeWithInputFixed(
        address _srcToken,
        address _destToken,
        uint _srcTokenValue
    )
        internal
        returns (uint _exchangeRate)
    {
        address uniswapExchangeAddr = uniswapFactory.getExchange(_srcToken);
        UniswapExchange exchange = UniswapExchange(uniswapExchangeAddr);

        uint inputValue = _srcTokenValue;
        uint outputValue;

        (outputValue, _exchangeRate) = _calcValuesForTokenToTokenInput(_srcToken, _destToken, inputValue);
        
        exchange.tokenToTokenSwapInput(
            inputValue,
            div(mul(outputValue, sub(WAD, TOKEN_ALLOWED_SLIPPAGE)), WAD),
            1,
            add(now,DEADLINE_DURATION),
            _destToken
        );

    }

    function _performTradeWithOutputFixed(
        address _srcToken,
        address _destToken,
        uint _maxDestTokenValue
    )
        internal
        returns (uint _exchangeRate)
    {
        address uniswapExchangeAddr = uniswapFactory.getExchange(_srcToken);
        UniswapExchange exchange = UniswapExchange(uniswapExchangeAddr);

        uint outputValue = _maxDestTokenValue;
        uint inputValue; 
        uint inputValueB;
   
        (inputValue, _exchangeRate, inputValueB) = _calcValuesForTokenToTokenOutput(_srcToken, _destToken, outputValue);
        
        exchange.tokenToTokenSwapOutput(
            outputValue,
            div(mul(inputValue, add(WAD, TOKEN_ALLOWED_SLIPPAGE)),WAD),
            div(mul(inputValueB, add(WAD, 20 * (10**16))),WAD),
            add(now,DEADLINE_DURATION),
            _destToken
        );
    }

    function _calcValuesForTokenToTokenOutput
    (
        address _srcToken,
        address _destToken,
        uint _maxDestTokenValue
    )
        internal
        view
        returns
        (
            uint _inputValue,
            uint _exchangeRate,
            uint _inputValueB
        )
    {
        uint inputReserveA;
        uint outputReserveA;
        uint inputReserveB;
        uint outputReserveB;

        (inputReserveA, outputReserveA, inputReserveB, outputReserveB) = _fetchReserveValues(_srcToken, _destToken);

        uint outputValue = _maxDestTokenValue;
        uint outputAmountB = _maxDestTokenValue;
        uint inputAmountB = _calculateEtherTokenInput(outputAmountB, inputReserveB, outputReserveB);

        // redundant variable for readability of the formala
        // inputAmount from the first swap becomes outputAmount of the second swap
        uint outputAmountA = inputAmountB;
        uint inputAmountA = _calculateEtherTokenInput(outputAmountA, inputReserveA, outputReserveA);

        _inputValue = inputAmountA;
        _exchangeRate = div(mul(outputValue, WAD), _inputValue);
        _inputValueB = inputAmountB;
    }
 
    function _calcValuesForTokenToTokenInput
    (
        address _srcToken,
        address _destToken,
        uint _srcTokenValue
    ) 
        internal
        view
        returns
        (
            uint _outputValue,
            uint _exchangeRate
        )
    {   
        uint inputReserveA;
        uint outputReserveA;
        uint inputReserveB;
        uint outputReserveB;

        (inputReserveA, outputReserveA, inputReserveB, outputReserveB) = _fetchReserveValues(_srcToken, _destToken);

        uint inputValue = _srcTokenValue;
        uint inputAmountA = inputValue;

        uint outputAmountA = _calculateEtherTokenOutput(inputAmountA, inputReserveA, outputReserveA);

        // redundant variable for readability of the formala
        // outputAmount from the first swap becomes inputAmount of the second swap
        uint inputAmountB = outputAmountA;
        uint outputAmountB = _calculateEtherTokenOutput(inputAmountB, inputReserveB, outputReserveB);

        _outputValue = outputAmountB;
        _exchangeRate = div(mul(_outputValue, WAD), inputValue);
    }

    function _fetchReserveValues(address _srcToken, address _destToken)
        internal
        view
        returns(
            uint _inputReserveA,
            uint _outputReserveA,
            uint _inputReserveB,
            uint _outputReserveB
        )
    {
        address exchangeAddrA = uniswapFactory.getExchange(_srcToken);
        address exchangeAddrB = uniswapFactory.getExchange(_destToken);

        _inputReserveA = ERC20(_srcToken).balanceOf(exchangeAddrA);
        _outputReserveA = address(exchangeAddrA).balance;

        _inputReserveB = address(exchangeAddrB).balance;
        _outputReserveB = ERC20(_destToken).balanceOf(exchangeAddrB);
    }

    function _calculateEtherTokenOutput(uint _inputAmount, uint _inputReserve, uint _outputReserve) 
        internal
        pure
        returns (uint)
    {
        uint numerator = mul(mul(_inputAmount, _outputReserve), 997);
        uint denominator = add(mul(_inputReserve,1000), mul(_inputAmount, 997));

        return div(numerator, denominator);
    }

    function _calculateEtherTokenInput(uint _outputAmount, uint _inputReserve, uint _outputReserve)
        internal
        pure
        returns (uint)
    {
        uint numerator = mul(mul(_outputAmount, _inputReserve), 1000);
        uint denominator = mul(sub(_outputReserve, _outputAmount), 997);

        return add(div(numerator, denominator), 1);
    }

    function _transfer
    (
        address _token,
        address _to,
        uint _value
    )
        internal
        returns (bool)
    {
        return ERC20(_token).transfer(_to, _value);
    }
}
pragma solidity ^0.4.23;


contract AntiERC20Sink {
    address public deployer;
    constructor() public { deployer = msg.sender; }
    function transferERC20Token(IERC20Token _token, address _to, uint256 _amount) public {
        require(msg.sender == deployer);
        _token.transfer(_to, _amount);
    }
}


library SafeMath {
    function plus(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        assert(c >= _a);
        return c;
    }

    function plus(int256 _a, int256 _b) internal pure returns (int256) {
        int256 c = _a + _b;
        assert((_b >= 0 && c >= _a) || (_b < 0 && c < _a));
        return c;
    }

    function minus(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_a >= _b);
        return _a - _b;
    }

    function minus(int256 _a, int256 _b) internal pure returns (int256) {
        int256 c = _a - _b;
        assert((_b >= 0 && c <= _a) || (_b < 0 && c > _a));
        return c;
    }

    function times(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function times(int256 _a, int256 _b) internal pure returns (int256) {
        if (_a == 0) {
            return 0;
        }
        int256 c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function toInt256(uint256 _a) internal pure returns (int256) {
        assert(_a <= 2 ** 255);
        return int256(_a);
    }

    function toUint256(int256 _a) internal pure returns (uint256) {
        assert(_a >= 0);
        return uint256(_a);
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a / _b;
    }

    function div(int256 _a, int256 _b) internal pure returns (int256) {
        return _a / _b;
    }
}


/*
    ERC20 Standard Token interface
*/
contract IERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public constant returns (string) {}
    function symbol() public constant returns (string) {}
    function decimals() public constant returns (uint8) {}
    function totalSupply() public constant returns (uint256) {}
    function balanceOf(address _owner) public constant returns (uint256) { _owner; }
    function allowance(address _owner, address _spender) public constant returns (uint256) { _owner; _spender; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}


/*
    Owned contract interface
*/
contract IOwned {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    function owner() public constant returns (address) {}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
    function setOwner(address _newOwner) public;
}





contract Vault {
    PegInstance public pegInstance;
    address public owner;
    uint256 public totalBorrowed;
    uint256 public rawDebt;
    uint256 public timestamp;

    constructor(PegInstance _pegInstance, address _owner) public {
        pegInstance = _pegInstance;
        owner = _owner;
    }

    modifier authOnly() {
        require(pegInstance.authorized(msg.sender));
        _;
    }

    function setOwner(address _newOwner) public authOnly {
        owner = _newOwner;
    }

    function setRawDebt(uint _newRawDebt) public authOnly {
        rawDebt = _newRawDebt;
    }

    function setTotalBorrowed(uint _totalBorrowed) public authOnly {
        totalBorrowed = _totalBorrowed;
    }

    function setTimestamp(uint256 _timestamp) public authOnly {
        timestamp = _timestamp;
    }

    function payoutPEG(address _to, uint _amount) public authOnly {
        pegInstance.pegNetworkToken().transfer(_to, _amount);
    }

    function burnPEG(uint _amount) public authOnly {
        pegInstance.pegNetworkToken().destroy(address(this), _amount);
    }

    function transferERC20Token(IERC20Token _token, address _to, uint256 _amount) public authOnly {
        _token.transfer(_to, _amount);
    }
}

contract IPegOracle {
    function getValue() public view returns (uint256);
}







/*
    Smart Token interface
*/
contract ISmartToken is IOwned, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}









contract PegLogic is AntiERC20Sink {

    using SafeMath for uint256;
    using SafeMath for int256;
    ISmartToken public pegNetworkToken;
    PegInstance public pegInstance;

    constructor(ISmartToken _pegNetworkToken, PegInstance _pegInstance) public {
        pegNetworkToken = _pegNetworkToken;
        pegInstance = _pegInstance;
    }

    modifier vaultExists(Vault _vault) {
        require(pegInstance.vaultExists(_vault));
        _;
    }

    modifier authOnly() {
        require(pegInstance.authorized(msg.sender));
        _;
    }

    function newVault() public returns (Vault) {
        // pegNetworkToken.destroy(msg.sender, 1e18); charge a fee?
        Vault vault = new Vault(pegInstance, msg.sender);
        pegInstance.addNewVault(vault, msg.sender);
        return vault;
    }

    function getTotalCredit(Vault _vault) public view vaultExists(_vault) returns (int256) {
        uint256 oraclePrice = pegInstance.oracle().getValue();
        return (pegNetworkToken.balanceOf(_vault).times(oraclePrice).times(pegInstance.maxBorrowLTV()) / 1e12).toInt256();
    }

    function getAvailableCredit(Vault _vault) public view returns (int256) {
        return getTotalCredit(_vault).minus(actualDebt(_vault).toInt256());
    }

    function borrow(Vault _vault, uint256 _amount) public vaultExists(_vault) {
        require(_vault.owner() == msg.sender && _amount.toInt256() <= getAvailableCredit(_vault));
        _vault.setRawDebt(_vault.rawDebt().plus(debtActualToRaw(_amount)));
        _vault.setTotalBorrowed(_vault.totalBorrowed().plus(_amount));
        pegInstance.debtToken().issue(msg.sender, _amount);
        pegInstance.emitBorrow(_vault, _amount);
    }

    function repay(Vault _vault, uint256 _amount) public vaultExists(_vault) {
        uint amountToRepay = _amount;
        if (actualDebt(_vault) < _amount) amountToRepay = actualDebt(_vault);
        pegInstance.debtToken().destroy(msg.sender, amountToRepay);
        _vault.setRawDebt(_vault.rawDebt().minus(debtActualToRaw(amountToRepay)));
        _vault.setTotalBorrowed(_vault.totalBorrowed().minus(amountToRepay));
        pegInstance.emitRepay(_vault, amountToRepay);
    }

    function requiredCollateral(Vault _vault) public view vaultExists(_vault) returns (uint256) {
        return actualDebt(_vault).times(1e12) / pegInstance.oracle().getValue() / pegInstance.maxBorrowLTV();
    }

    function getExcessCollateral(Vault _vault) public view returns (int256) {
        return int(pegNetworkToken.balanceOf(_vault)).minus(int(requiredCollateral(_vault)));
    }

    function liquidate(Vault _vault) public {
        require(actualDebt(_vault) > 0);
        uint requiredPEG = actualDebt(_vault).times(1e12) / pegInstance.oracle().getValue() / pegInstance.liquidationRatio();
        require(pegNetworkToken.balanceOf(_vault) < requiredPEG);
        require(pegInstance.debtToken().balanceOf(msg.sender) >= actualDebt(_vault));
        pegInstance.debtToken().destroy(msg.sender, actualDebt(_vault));
        _vault.setRawDebt(0);
        _vault.setOwner(msg.sender);
    }

    function reportPriceToTargetValue(bool _aboveValue) public authOnly {
        if(_aboveValue) {
            pegInstance.setDebtScalingRate(pegInstance.debtScalingPerBlock().plus(1e8));
            pegInstance.setDebtTokenScalingRate(pegInstance.debtTokenScalingPerBlock().plus(1e8));
        }else{
            pegInstance.setDebtScalingRate(pegInstance.debtScalingPerBlock().minus(1e8));
            pegInstance.setDebtTokenScalingRate(pegInstance.debtTokenScalingPerBlock().minus(1e8));
        }
    }

    function debtRawToActual(uint256 _raw) public view returns(uint256) {
        return _raw.times(1e18) / pegInstance.debtScalingFactor();
    }

    function debtActualToRaw(uint256 _actual) public view returns(uint256) {
        return _actual.times(pegInstance.debtScalingFactor()) / 1e18;
    }

    function withdrawExcessCollateral(Vault _vault, address _to, uint256 _amount) public {
        require(msg.sender == _vault.owner());
        require(_amount.toInt256() <= getExcessCollateral(_vault));
        _vault.payoutPEG(_to, _amount);
        pegInstance.emitWithdraw(_vault, _amount);
    }

    function actualDebt(Vault _vault) public view returns(uint) {
        return debtRawToActual(_vault.rawDebt());
    }
}


contract PegInstance {

    using SafeMath for uint256;
    using SafeMath for int256;

    ISmartToken public pegNetworkToken;
    uint8 public constant version = 0;
    IPegOracle public oracle;
    DebtToken public debtToken;
    PegLogic public pegLogic;
    address[] public vaults;
    mapping (address => bool) public vaultExists;
    mapping (address => bool) public authorized;
    uint32 public liquidationRatio = 850000;
    uint32 public maxBorrowLTV = 100000;

    uint256 public lastDebtTokenScalingFactor = 1e18;
    uint256 public lastDebtTokenScalingRetarget;
    int256 public debtTokenScalingPerBlock;

    uint256 public lastDebtScalingFactor = 1e18;
    uint256 public lastDebtScalingRetarget;
    int256 public debtScalingPerBlock;

    uint256 public amountMinted;

    event LiquidateVault(address indexed _vault);
    event Borrow(address indexed _vault, uint256 amount);
    event Repay(address indexed _vault, uint256 amount);
    event Withdraw(address indexed _vault, uint256 amount);
    event LiquidationRatioUpdate(int _old, int _new);
    event MaxBorrowUpdate(uint32 _old, uint32 _new);
    event DebtTokenScalingRateUpdate(int _old, int _new);
    event DebtScalingRateUpdate(int _old, int _new);
    event NewVault(address indexed _vault, address indexed _vaultOwner);
    event LogicUpgrade(address _old, address _new);
    event DebtTokenUpgrade(address _old, address _new);
    event OracleUpgrade(address _old, address _new);
    event Authorize(address _address, bool _auth);

    constructor(ISmartToken _pegNetworkToken) public {
        pegNetworkToken = _pegNetworkToken;
        authorized[msg.sender] = true;
    }

    modifier authOnly() {
        require(authorized[msg.sender] == true);
        _;
    }

    function setDebtToken(DebtToken _debtToken) public authOnly {
        emit DebtTokenUpgrade(address(debtToken), address(_debtToken));
        debtToken = _debtToken;
    }

    function setOracle(IPegOracle _oracle) public authOnly {
        emit OracleUpgrade(address(oracle), address(_oracle));
        oracle = _oracle;
    }

    function setPegLogic(PegLogic _pegLogic) public authOnly {
        emit LogicUpgrade(address(pegLogic), address(_pegLogic));
        authorized[address(_pegLogic)] = true;
        authorized[address(pegLogic)] = false;
        pegLogic = _pegLogic;
    }

    function authorize(address _address, bool _auth) public authOnly {
        emit Authorize(_address, _auth);
        authorized[_address] = _auth;
    }

    function setLiquidationRatio(uint32 _liquidationRatio) public authOnly {
        emit LiquidationRatioUpdate(liquidationRatio, _liquidationRatio);
        liquidationRatio = _liquidationRatio;
    }

    function setMaxBorrowLTV(uint32 _maxBorrowLTV) public authOnly {
        emit MaxBorrowUpdate(maxBorrowLTV, _maxBorrowLTV);
        maxBorrowLTV = _maxBorrowLTV;
    }

    function setDebtTokenScalingRate(int256 _debtTokenScalingPerBlock) public authOnly {
        emit DebtTokenScalingRateUpdate(debtTokenScalingPerBlock, _debtTokenScalingPerBlock);
        lastDebtTokenScalingFactor = debtTokenScalingFactor();
        lastDebtTokenScalingRetarget = block.number;
        debtTokenScalingPerBlock = _debtTokenScalingPerBlock;
    }

    function setDebtScalingRate(int256 _debtScalingPerBlock) public authOnly {
        emit DebtScalingRateUpdate(debtScalingPerBlock, _debtScalingPerBlock);
        lastDebtScalingFactor = debtScalingFactor();
        lastDebtScalingRetarget = block.number;
        debtScalingPerBlock = _debtScalingPerBlock;
    }

    function setAmountMinted(uint _amountMinted) public authOnly {
        amountMinted = _amountMinted;
    }

    function addNewVault(Vault _vault, address _vaultOwner) public authOnly {
        emit NewVault(address(_vault), _vaultOwner);
        vaults.push(_vault);
        vaultExists[_vault] = true;
    }

    function emitBorrow(Vault _vault, uint256 _amount) public authOnly {
        emit Borrow(address(_vault), _amount);
    }

    function emitRepay(Vault _vault, uint256 _amount) public authOnly {
        emit Repay(address(_vault), _amount);
    }

    function emitWithdraw(Vault _vault, uint256 _amount) public authOnly {
        emit Withdraw(address(_vault), _amount);
    }

    function emitLiquidateVault(Vault _vault) public authOnly {
        emit LiquidateVault(address(_vault));
    }

    function getVaults() public view returns (address[]) {
        return vaults;
    }

    function debtTokenScalingFactor() public view returns (uint) {
        return uint(int(lastDebtTokenScalingFactor).plus(debtTokenScalingPerBlock.times(int(block.number.minus(lastDebtTokenScalingRetarget)))));
    }

    function debtScalingFactor() public view returns (uint) {
        return uint(int(lastDebtScalingFactor).plus(debtScalingPerBlock.times(int(block.number.minus(lastDebtScalingRetarget)))));
    }

    function transferERC20Token(IERC20Token _token, address _to, uint256 _amount) public authOnly {
        _token.transfer(_to, _amount);
    }
}





contract DebtToken is IERC20Token {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    PegInstance public pegInstance;

    uint256 public rawTotalSupply;
    mapping (address => uint256) public rawBalance;
    mapping (address => mapping (address => uint256)) public rawAllowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Issuance(uint256 amount);
    event Destruction(uint256 amount);

    constructor(string _name, string _symbol, PegInstance _pegInstance) public {
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0);
        name = _name;
        symbol = _symbol;
        pegInstance = _pegInstance;
    }

    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }

    modifier authOnly() {
        require(pegInstance.authorized(msg.sender));
        _;
    }

    function rawToActual(uint256 _raw) public view returns(uint256) {
        return _raw.times(1e18) / pegInstance.debtTokenScalingFactor();
    }

    function actualToRaw(uint256 _actual) public view returns(uint256) {
        return _actual.times(pegInstance.debtTokenScalingFactor()) / 1e18;
    }

    function balanceOf(address _address) public view returns(uint256) {
        return rawToActual(rawBalance[_address]);
    }

    function totalSupply() public view returns (uint256) {
        return rawToActual(rawTotalSupply);
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return rawToActual(rawAllowance[_owner][_spender]);
    }

    function transfer(address _to, uint256 _amount) public validAddress(_to) returns (bool) {
        rawBalance[msg.sender] = rawBalance[msg.sender].minus(actualToRaw(_amount));
        rawBalance[_to] = rawBalance[_to].plus(actualToRaw(_amount));
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public validAddress(_from) validAddress(_to) returns (bool) {
        rawAllowance[_from][msg.sender] = rawAllowance[_from][msg.sender].minus(actualToRaw(_amount));
        rawBalance[_from] = rawBalance[_from].minus(actualToRaw(_amount));
        rawBalance[_to] = rawBalance[_to].plus(actualToRaw(_amount));
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public validAddress(_spender) returns (bool) {
        require(_amount == 0 || rawAllowance[msg.sender][_spender] == 0);
        rawAllowance[msg.sender][_spender] = actualToRaw(_amount);
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function issue(address _to, uint256 _amount) public validAddress(_to) authOnly {
        rawTotalSupply = rawTotalSupply.plus(actualToRaw(_amount));
        rawBalance[_to] = rawBalance[_to].plus(actualToRaw(_amount));
        emit Issuance(_amount);
        emit Transfer(this, _to, _amount);
    }

    function destroy(address _from, uint256 _amount) public validAddress(_from) authOnly {
        rawBalance[_from] = rawBalance[_from].minus(actualToRaw(_amount));
        rawTotalSupply = rawTotalSupply.minus(actualToRaw(_amount));
        emit Transfer(_from, this, _amount);
        emit Destruction(_amount);
    }

    function setName(string _name) public authOnly {
        name = _name;
    }

    function setSymbol(string _symbol) public authOnly {
        symbol = _symbol;
    }

    function transferERC20Token(IERC20Token _token, address _to, uint256 _amount) validAddress(_to) public {
        require(pegInstance.authorized(msg.sender));
        _token.transfer(_to, _amount);
    }
}
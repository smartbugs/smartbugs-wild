pragma solidity 0.5.0;

// File: openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: lib/ds-math/src/math.sol

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity >0.4.13;

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

// File: contracts/interfaces/IWrappedEther.sol

contract IWrappedEther is IERC20 {
    function deposit() external payable;
    function withdraw(uint amount) external;
}

// File: contracts/interfaces/ISaiTub.sol

interface DSValue {
    function peek() external view returns (bytes32, bool);
}

interface ISaiTub {
    function sai() external view returns (IERC20);  // Stablecoin
    function sin() external view returns (IERC20);  // Debt (negative sai)
    function skr() external view returns (IERC20);  // Abstracted collateral
    function gem() external view returns (IWrappedEther);  // Underlying collateral
    function gov() external view returns (IERC20);  // Governance token

    function open() external returns (bytes32 cup);
    function join(uint wad) external;
    function exit(uint wad) external;
    function give(bytes32 cup, address guy) external;
    function lock(bytes32 cup, uint wad) external;
    function free(bytes32 cup, uint wad) external;
    function draw(bytes32 cup, uint wad) external;
    function wipe(bytes32 cup, uint wad) external;
    function shut(bytes32 cup) external;
    function per() external view returns (uint ray);
    function lad(bytes32 cup) external view returns (address);
    
    function tab(bytes32 cup) external returns (uint);
    function rap(bytes32 cup) external returns (uint);
    function ink(bytes32 cup) external view returns (uint);
    function mat() external view returns (uint);    // Liquidation ratio
    function fee() external view returns (uint);    // Governance fee
    function pep() external view returns (DSValue); // Governance price feed
    function cap() external view returns (uint); // Debt ceiling
    

    function cups(bytes32) external view returns (address, uint, uint, uint);
}

// File: contracts/interfaces/IDex.sol

interface IDex {
    function getPayAmount(IERC20 pay_gem, IERC20 buy_gem, uint buy_amt) external view returns (uint);
    function buyAllAmount(IERC20 buy_gem, uint buy_amt, IERC20 pay_gem, uint max_fill_amount) external returns (uint);
    function offer(
        uint pay_amt,    //maker (ask) sell how much
        IERC20 pay_gem,   //maker (ask) sell which token
        uint buy_amt,    //maker (ask) buy how much
        IERC20 buy_gem,   //maker (ask) buy which token
        uint pos         //position to insert offer, 0 should be used if unknown
    )
    external
    returns (uint);
}

// File: contracts/ArrayUtils.sol

library ArrayUtils {
    function removeElement(bytes32[] storage array, uint index) internal {
        if (index >= array.length) return;

        for (uint i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        delete array[array.length - 1];
        array.length--;
    }

    function findElement(bytes32[] storage array, bytes32 element) internal view returns (uint index, bool ok) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return (i, true);
            }
        }

        return (0, false);
    }
}

// File: contracts/MakerDaoGateway.sol

contract MakerDaoGateway is Pausable, DSMath {
    using ArrayUtils for bytes32[];

    ISaiTub public saiTub;
    IDex public dex;
    IWrappedEther public weth;
    IERC20 public peth;
    IERC20 public dai;
    IERC20 public mkr;

    mapping(bytes32 => address) public cdpOwner;
    mapping(address => bytes32[]) public cdpsByOwner;

    event CdpOpened(address indexed owner, bytes32 cdpId);
    event CdpClosed(address indexed owner, bytes32 cdpId);
    event CollateralSupplied(address indexed owner, bytes32 cdpId, uint wethAmount, uint pethAmount);
    event DaiBorrowed(address indexed owner, bytes32 cdpId, uint amount);
    event DaiRepaid(address indexed owner, bytes32 cdpId, uint amount);
    event CollateralReturned(address indexed owner, bytes32 cdpId, uint wethAmount, uint pethAmount);
    event CdpTransferred(address indexed oldOwner, address indexed newOwner, bytes32 cdpId);
    event CdpEjected(address indexed newOwner, bytes32 cdpId);
    event CdpRegistered(address indexed newOwner, bytes32 cdpId);

    modifier isCdpOwner(bytes32 cdpId) {
        require(cdpOwner[cdpId] == msg.sender || cdpId == 0, "CDP belongs to a different address");
        _;
    }

    constructor(ISaiTub _saiTub, IDex _dex) public {
        saiTub = _saiTub;
        dex = _dex;
        weth = saiTub.gem();
        peth = saiTub.skr();
        dai = saiTub.sai();
        mkr = saiTub.gov();
    }

    function cdpsByOwnerLength(address _owner) external view returns (uint) {
        return cdpsByOwner[_owner].length;
    }

    function systemParameters() external view returns (uint liquidationRatio, uint annualStabilityFee, uint daiAvailable) {
        liquidationRatio = saiTub.mat();
        annualStabilityFee = rpow(saiTub.fee(), 365 days);
        daiAvailable = sub(saiTub.cap(), dai.totalSupply());
    }
    
    function cdpInfo(bytes32 cdpId) external returns (uint borrowedDai, uint outstandingDai, uint suppliedPeth) {
        (, uint ink, uint art, ) = saiTub.cups(cdpId);
        borrowedDai = art;
        suppliedPeth = ink;
        outstandingDai = add(saiTub.rap(cdpId), saiTub.tab(cdpId));
    }
    
    function pethForWeth(uint wethAmount) public view returns (uint) {
        return rdiv(wethAmount, saiTub.per());
    }

    function wethForPeth(uint pethAmount) public view returns (uint) {
        return rmul(pethAmount, saiTub.per());
    }

    function() external payable {
        // For unwrapping WETH
    }

    // SUPPLY AND BORROW
    
    // specify cdpId if you want to use existing CDP, or pass 0 if you need to create a new one
    // for new and active CDPs collateral amount should be > 0.005 PETH
    function supplyEthAndBorrowDai(bytes32 cdpId, uint daiAmount) whenNotPaused isCdpOwner(cdpId) external payable {
        bytes32 id = supplyEth(cdpId);
        borrowDai(id, daiAmount);
    }

    // specify cdpId if you want to use existing CDP, or pass 0 if you need to create a new one 
    function supplyWethAndBorrowDai(bytes32 cdpId, uint wethAmount, uint daiAmount) whenNotPaused isCdpOwner(cdpId) external {
        bytes32 id = supplyWeth(cdpId, wethAmount);
        borrowDai(id, daiAmount);
    }

    // returns id of actual CDP (existing or a new one)
    // for new and active CDPs collateral amount should be > 0.005 PETH
    function supplyEth(bytes32 cdpId) whenNotPaused isCdpOwner(cdpId) public payable returns (bytes32 _cdpId) {
        if (msg.value > 0) {
            weth.deposit.value(msg.value)();
            return _supply(cdpId, msg.value);
        }

        return cdpId;
    }

    // for new and active CDPs collateral amount should be > 0.005 PETH
    // don't forget to approve WETH before supplying
    // returns id of actual CDP (existing or a new one)
    function supplyWeth(bytes32 cdpId, uint wethAmount) whenNotPaused isCdpOwner(cdpId) public returns (bytes32 _cdpId) {
        if (wethAmount > 0) {
            require(weth.transferFrom(msg.sender, address(this), wethAmount));
            return _supply(cdpId, wethAmount);
        }

        return cdpId;
    }

    function borrowDai(bytes32 cdpId, uint daiAmount) whenNotPaused isCdpOwner(cdpId) public {
        if (daiAmount > 0) {
            saiTub.draw(cdpId, daiAmount);

            require(dai.transfer(msg.sender, daiAmount));

            emit DaiBorrowed(msg.sender, cdpId, daiAmount);
        }
    }

    // REPAY AND RETURN

    // don't forget to approve DAI before repaying
    function repayDaiAndReturnEth(bytes32 cdpId, uint daiAmount, uint ethAmount, bool payFeeInDai) whenNotPaused isCdpOwner(cdpId) external {
        repayDai(cdpId, daiAmount, payFeeInDai);
        returnEth(cdpId, ethAmount);
    }

    // don't forget to approve DAI before repaying
    // pass -1 to daiAmount to repay all outstanding debt
    // pass -1 to wethAmount to return all collateral
    function repayDaiAndReturnWeth(bytes32 cdpId, uint daiAmount, uint wethAmount, bool payFeeInDai) whenNotPaused isCdpOwner(cdpId) public {
        repayDai(cdpId, daiAmount, payFeeInDai);
        returnWeth(cdpId, wethAmount);
    }

    // don't forget to approve DAI before repaying
    // pass -1 to daiAmount to repay all outstanding debt
    function repayDai(bytes32 cdpId, uint daiAmount, bool payFeeInDai) whenNotPaused isCdpOwner(cdpId) public {
        if (daiAmount > 0) {
            uint _daiAmount = daiAmount;
            if (_daiAmount == uint(- 1)) {
                // repay all outstanding debt
                _daiAmount = saiTub.tab(cdpId);
            }

            _ensureApproval(dai, address(saiTub));
            _ensureApproval(mkr, address(saiTub));

            uint govFeeAmount = _calcGovernanceFee(cdpId, _daiAmount);
            _handleGovFee(govFeeAmount, payFeeInDai);

            require(dai.transferFrom(msg.sender, address(this), _daiAmount));

            saiTub.wipe(cdpId, _daiAmount);

            emit DaiRepaid(msg.sender, cdpId, _daiAmount);
        }
    }

    function returnEth(bytes32 cdpId, uint ethAmount) whenNotPaused isCdpOwner(cdpId) public {
        if (ethAmount > 0) {
            uint effectiveWethAmount = _return(cdpId, ethAmount);
            weth.withdraw(effectiveWethAmount);
            msg.sender.transfer(effectiveWethAmount);
        }
    }

    function returnWeth(bytes32 cdpId, uint wethAmount) whenNotPaused isCdpOwner(cdpId) public {
        if (wethAmount > 0) {
            uint effectiveWethAmount = _return(cdpId, wethAmount);
            require(weth.transfer(msg.sender, effectiveWethAmount));
        }
    }

    function closeCdp(bytes32 cdpId, bool payFeeInDai) whenNotPaused isCdpOwner(cdpId) external {
        repayDaiAndReturnWeth(cdpId, uint(-1), uint(-1), payFeeInDai);
        _removeCdp(cdpId, msg.sender);
        saiTub.shut(cdpId);
        
        emit CdpClosed(msg.sender, cdpId);
    }

    // TRANSFER AND ADOPT

    // You can migrate your CDP from MakerDaoGateway contract to another owner
    function transferCdp(bytes32 cdpId, address nextOwner) isCdpOwner(cdpId) external {
        address _owner = nextOwner;
        if (_owner == address(0x0)) {
            _owner = msg.sender;
        }
        
        saiTub.give(cdpId, _owner);

        _removeCdp(cdpId, msg.sender);

        emit CdpTransferred(msg.sender, _owner, cdpId);
    }
    
    function ejectCdp(bytes32 cdpId) onlyPauser external {
        address owner = cdpOwner[cdpId];
        saiTub.give(cdpId, owner);

        _removeCdp(cdpId, owner);

        emit CdpEjected(owner, cdpId);
    }

    // If you want to migrate existing CDP to MakerDaoGateway contract,
    // you need to register your cdp first with this function, and then execute `give` operation,
    // transferring CDP to the MakerDaoGateway contract
    function registerCdp(bytes32 cdpId, address owner) whenNotPaused external {
        require(saiTub.lad(cdpId) == msg.sender, "Can't register other's CDP");
        require(cdpOwner[cdpId] == address(0x0), "Can't register CDP twice");

        address _owner = owner;
        if (_owner == address(0x0)) {
            _owner = msg.sender;
        }

        cdpOwner[cdpId] = _owner;
        cdpsByOwner[_owner].push(cdpId);

        emit CdpRegistered(_owner, cdpId);
    }

    // INTERNAL FUNCTIONS

    function _supply(bytes32 cdpId, uint wethAmount) internal returns (bytes32 _cdpId) {
        _cdpId = cdpId;
        if (_cdpId == 0) {
            _cdpId = _createCdp();
        }

        _ensureApproval(weth, address(saiTub));

        uint pethAmount = pethForWeth(wethAmount);

        saiTub.join(pethAmount);

        _ensureApproval(peth, address(saiTub));

        saiTub.lock(_cdpId, pethAmount);
        emit CollateralSupplied(msg.sender, _cdpId, wethAmount, pethAmount);
    }

    function _return(bytes32 cdpId, uint wethAmount) internal returns (uint _wethAmount) {
        uint pethAmount;

        if (wethAmount == uint(- 1)) {
            // return all collateral
            pethAmount = saiTub.ink(cdpId);
        } else {
            pethAmount = pethForWeth(wethAmount);
        }

        saiTub.free(cdpId, pethAmount);

        _ensureApproval(peth, address(saiTub));

        saiTub.exit(pethAmount);

        _wethAmount = wethForPeth(pethAmount);

        emit CollateralReturned(msg.sender, cdpId, _wethAmount, pethAmount);
    }

    function _calcGovernanceFee(bytes32 cdpId, uint daiAmount) internal returns (uint mkrFeeAmount) {
        uint daiFeeAmount = rmul(daiAmount, rdiv(saiTub.rap(cdpId), saiTub.tab(cdpId)));
        (bytes32 val, bool ok) = saiTub.pep().peek();
        require(ok && val != 0, 'Unable to get mkr rate');

        return wdiv(daiFeeAmount, uint(val));
    }

    function _handleGovFee(uint mkrGovAmount, bool payWithDai) internal {
        if (mkrGovAmount > 0) {
            if (payWithDai) {
                uint daiAmount = dex.getPayAmount(dai, mkr, mkrGovAmount);

                _ensureApproval(dai, address(dex));

                require(dai.transferFrom(msg.sender, address(this), daiAmount));
                dex.buyAllAmount(mkr, mkrGovAmount, dai, daiAmount);
            } else {
                require(mkr.transferFrom(msg.sender, address(this), mkrGovAmount));
            }
        }
    }

    function _ensureApproval(IERC20 token, address spender) internal {
        if (token.allowance(address(this), spender) != uint(- 1)) {
            require(token.approve(spender, uint(- 1)));
        }
    }

    function _createCdp() internal returns (bytes32 cdpId) {
        cdpId = saiTub.open();

        cdpOwner[cdpId] = msg.sender;
        cdpsByOwner[msg.sender].push(cdpId);

        emit CdpOpened(msg.sender, cdpId);
    }
    
    function _removeCdp(bytes32 cdpId, address owner) internal {
        (uint i, bool ok) = cdpsByOwner[owner].findElement(cdpId);
        require(ok, "Can't find cdp in owner's list");
        
        cdpsByOwner[owner].removeElement(i);
        delete cdpOwner[cdpId];
    }
}
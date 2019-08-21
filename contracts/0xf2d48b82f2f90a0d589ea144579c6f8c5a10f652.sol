// Verified using https://dapp.tools

// hevm: flattened sources of src/DexC2CGateway.sol
pragma solidity ^0.4.24;

////// lib/ds-auth/src/auth.sol
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

/* pragma solidity >=0.4.23; */

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

////// lib/ds-math/src/math.sol
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

/* pragma solidity >0.4.13; */

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

////// lib/ds-token/lib/ds-stop/lib/ds-note/src/note.sol
/// note.sol -- the `note' modifier, for logging calls as events

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

/* pragma solidity >=0.4.23; */

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

////// lib/ds-token/lib/ds-stop/src/stop.sol
/// stop.sol -- mixin for enable/disable functionality

// Copyright (C) 2017  DappHub, LLC

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

/* pragma solidity >=0.4.23; */

/* import "ds-auth/auth.sol"; */
/* import "ds-note/note.sol"; */

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

////// lib/ds-token/lib/erc20/src/erc20.sol
/// erc20.sol -- API for the ERC20 token standard

// See <https://github.com/ethereum/EIPs/issues/20>.

// This file likely does not meet the threshold of originality
// required for copyright to apply.  As a result, this is free and
// unencumbered software belonging to the public domain.

/* pragma solidity >0.4.20; */

contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}

////// lib/ds-token/src/base.sol
/// base.sol -- basic ERC20 implementation

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

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

/* pragma solidity >=0.4.23; */

/* import "erc20/erc20.sol"; */
/* import "ds-math/math.sol"; */

contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
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

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "ds-token-insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

////// lib/ds-token/src/token.sol
/// token.sol -- ERC20 implementation with minting and burning

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

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

/* pragma solidity >=0.4.23; */

/* import "ds-stop/stop.sol"; */

/* import "./base.sol"; */

contract DSToken is DSTokenBase(0), DSStop {

    bytes32  public  symbol;
    uint256  public  decimals = 18; // standard token precision. override to customize

    constructor(bytes32 symbol_) public {
        symbol = symbol_;
    }

    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function approve(address guy) public stoppable returns (bool) {
        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            require(_approvals[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "ds-token-insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        emit Mint(guy, wad);
    }
    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            require(_approvals[guy][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        require(_balances[guy] >= wad, "ds-token-insufficient-balance");
        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        emit Burn(guy, wad);
    }

    // Optional token name
    bytes32   public  name = "";

    function setName(bytes32 name_) public auth {
        name = name_;
    }
}

////// lib/ds-value/lib/ds-thing/src/thing.sol
// thing.sol - `auth` with handy mixins. your things should be DSThings

// Copyright (C) 2017  DappHub, LLC

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

/* pragma solidity >=0.4.23; */

/* import 'ds-auth/auth.sol'; */
/* import 'ds-note/note.sol'; */
/* import 'ds-math/math.sol'; */

contract DSThing is DSAuth, DSNote, DSMath {
    function S(string memory s) internal pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked(s)));
    }

}

////// lib/ds-value/src/value.sol
/// value.sol - a value is a simple thing, it can be get and set

// Copyright (C) 2017  DappHub, LLC

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

/* pragma solidity >=0.4.23; */

/* import 'ds-thing/thing.sol'; */

contract DSValue is DSThing {
    bool    has;
    bytes32 val;
    function peek() public view returns (bytes32, bool) {
        return (val,has);
    }
    function read() public view returns (bytes32) {
        bytes32 wut; bool haz;
        (wut, haz) = peek();
        assert(haz);
        return wut;
    }
    function poke(bytes32 wut) public note auth {
        val = wut;
        has = true;
    }
    function void() public note auth {  // unset the value
        has = false;
    }
}

////// src/EscrowDataInterface.sol
/* pragma solidity ^0.4.24; */

/* import "ds-token/token.sol"; */

interface EscrowDataInterface
{
    ///@notice Create and fund a new escrow.
    function createEscrow(
        bytes32 _tradeId, 
        DSToken _token, 
        address _buyer, 
        address _seller, 
        uint256 _value, 
        uint16 _fee,
        uint32 _paymentWindowInSeconds
    ) external returns(bool);

    function getEscrow(
        bytes32 _tradeHash
    ) external returns(bool, uint32, uint128);

    function removeEscrow(
        bytes32 _tradeHash
    ) external returns(bool);

    function updateSellerCanCancelAfter(
        bytes32 _tradeHash,
        uint32 _paymentWindowInSeconds
    ) external returns(bool);

    function increaseTotalGasFeesSpentByRelayer(
        bytes32 _tradeHash,
        uint128 _increaseGasFees
    ) external returns(bool);
}
////// src/DexC2C.sol
/* pragma solidity ^0.4.24; */

/* import "ds-token/token.sol"; */
/* import "ds-auth/auth.sol"; */
/* import "ds-value/value.sol"; */
// import "ds-math/math.sol";
/* import "./EscrowDataInterface.sol"; */

contract DexC2C is DSAuth
{
    DSToken constant internal ETH_TOKEN_ADDRESS = DSToken(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    bool public enableMake = true;
    EscrowDataInterface escrowData;
    // address escrowData;
    address public gateway;
    address public arbitrator;
    address public relayer;
    address public signer;
    uint32 public requestCancellationMinimumTime;

    uint8 constant ACTION_TYPE_BUYER_PAID = 0x01;
    uint8 constant ACTION_TYPE_SELLER_CANCEL = 0x02;
    uint8 constant ACTION_TYPE_RELEASE = 0x03;
    uint8 constant ACTION_TYPE_RESOLVE = 0x04;

    mapping(address => bool) public listTokens;
    mapping(address => uint256) feesAvailableForWithdraw;
    // mapping(bytes32 => bool) withdrawAddresses;
    mapping(address => DSValue) public tokenPriceFeed;


    // event SetGateway(address _gateway);
    // event SetEscrowData(address _escrowData);
    // event SetToken(address caller, DSToken token, bool enable);
    // event ResetOwner(address curr, address old);
    // event ResetRelayer(address curr, address old);
    // event ResetSigner(address curr, address old);
    // event ResetArbitrator(address curr, address ocl);
    // event ResetEnabled(bool curr, bool old);
    // event WithdrawAddressApproved(DSToken token, address addr, bool approve);
    // event LogWithdraw(DSToken token, address receiver, uint amnt);

    event CreatedEscrow(address indexed _buyer, address indexed _seller, bytes32 indexed _tradeHash, DSToken _token);
    event CancelledBySeller(address indexed _buyer, address indexed _seller, bytes32 indexed _tradeHash, DSToken _token);
    event BuyerPaid(address indexed _buyer, address indexed _seller, bytes32 indexed _tradeHash, DSToken _token);
    event Release(address indexed _buyer, address indexed _seller, bytes32 indexed _tradeHash, DSToken _token);
    event DisputeResolved(address indexed _buyer, address indexed _seller, bytes32 indexed _tradeHash, DSToken _token);

    struct EscrowParams{
        bytes32 tradeId;
        DSToken tradeToken;
        address buyer;
        address seller;
        uint256 value;
        uint16 fee;
        uint32 paymentWindowInSeconds;
        uint32 expiry;
        uint8 v;
        bytes32 r;
        bytes32 s;
        address caller;
    }

    struct Escrow{
        bytes32 tradeHash;
        bool exists;
        uint32 sellerCanCancelAfter;
        uint128 totalGasFeesSpentByRelayer;
    }

    modifier onlyGateway(){
        require(msg.sender == gateway, "Must be gateway contract");
        _;
    }
    
    constructor(EscrowDataInterface _escrowData, address _signer) DSAuth() public{
        // require(_escrowData != address(0x00), "EscrowData address must exists");
        arbitrator = msg.sender;
        relayer = msg.sender;
        signer = _signer;
        escrowData = _escrowData;
        listTokens[ETH_TOKEN_ADDRESS] = true;
        requestCancellationMinimumTime = 2 hours;
    }

    function setPriceFeed(DSToken _token, DSValue _priceFeed) public auth{
        // require(_priceFeed != address(0x00), "price feed must not be null");
        tokenPriceFeed[_token] = _priceFeed;
    }

    function setRelayer(address _relayer) public auth {
        // require(_relayer != address(0x00), "Relayer is null");
        // emit ResetRelayer(_relayer, relayer);
        relayer = _relayer;
    }

    function setSigner(address _signer) public auth {
        // require(_signer != address(0x00), "Signer is null");
        // emit ResetSigner(_signer, signer);
        signer = _signer;
    }

    function setArbitrator(address _arbitrator) public auth{
        // require(_arbitrator != address(0x00), "Arbitrator is null");
        // emit ResetArbitrator(arbitrator, _arbitrator);
        arbitrator = _arbitrator;
    }


    function setGateway(address _gateway) public auth returns(bool){
        // require(_gateway != address(0x00), "Gateway address must valid");
        gateway = _gateway;
        // emit SetGateway(_gateway);
    }

    function setEscrowData(EscrowDataInterface _escrowData) public auth returns(bool){
        // require(_escrowData != address(0x00), "EscrowData address must valid");
        escrowData = _escrowData;
        // emit SetEscrowData(_escrowData);
    }

    function setToken(DSToken token, bool enable) public auth returns(bool){
        // require(gateway != address(0x00), "Set gateway first");
        // require(token != address(0x00), "Token address can not be 0x00");
        listTokens[token] = enable;
        // emit SetToken(msg.sender, token, enable);
    }

    function setRequestCancellationMinimumTime(
        uint32 _newRequestCancellationMinimumTime
    ) external auth {
        requestCancellationMinimumTime = _newRequestCancellationMinimumTime;
    }

    function enabled() public view returns(bool) {
        return enableMake;
    }

    function setEnabled(bool _enableMake) public auth{
        require(_enableMake != enableMake, "Enabled same value");
        // emit ResetEnabled(enableMake, _enableMake);
        enableMake = _enableMake;
    }

    function getTokenAmount(DSToken _token, uint ethWad) public view returns(uint){
        require(tokenPriceFeed[address(_token)] != address(0x00), "the token has not price feed(to eth).");
        DSValue feed = tokenPriceFeed[address(_token)];
        return wmul(ethWad, uint(feed.read()));
    }

    function checkCanResolveDispute(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _buyerPercent,
        address _caller
    ) private view {
        require(_caller == arbitrator, "Must be arbitrator");
        bytes32 tradeHash = keccak256(abi.encodePacked(_tradeId, _token, _buyer, _seller, _value, _fee));
        bytes32 invitationHash = keccak256(abi.encodePacked(tradeHash, ACTION_TYPE_RESOLVE, _buyerPercent));
        address _signature = recoverAddress(invitationHash, _v, _r, _s);
        require(_signature == _buyer || _signature == _seller, "Must be buyer or seller");
    }

    function resolveDispute(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _buyerPercent,
        address _caller
    ) external onlyGateway {
        checkCanResolveDispute(_tradeId, _token, _buyer, _seller, _value, _fee, _v, _r, _s,_buyerPercent, _caller);

        Escrow memory escrow = getEscrow(_tradeId, _token, _buyer, _seller, _value, _fee);
        require(escrow.exists, "Escrow does not exists");
        require(_buyerPercent <= 100, "BuyerPercent must be 100 or lower");

        doResolveDispute(
            escrow.tradeHash,
            _token,
            _buyer,
            _seller,
            _value,
            _buyerPercent,
            escrow.totalGasFeesSpentByRelayer
        );
    }

    uint16 constant GAS_doResolveDispute = 36100;
    function doResolveDispute(
        bytes32 _tradeHash,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint8 _buyerPercent,
        uint128 _totalGasFeesSpentByRelayer
    ) private {
        uint256 _totalFees = _totalGasFeesSpentByRelayer;
        if(_token == ETH_TOKEN_ADDRESS){
            _totalFees += (GAS_doResolveDispute * uint128(tx.gasprice));
        } else {
            ///如果交易非ETH需要按照汇率换算成等值的token
            _totalFees += getTokenAmount(_token, GAS_doResolveDispute * uint(tx.gasprice));
        }
        require(_value - _totalFees <= _value, "Overflow error");
        feesAvailableForWithdraw[_token] += _totalFees;

        escrowData.removeEscrow(_tradeHash);
        emit DisputeResolved(_buyer, _seller, _tradeHash, _token);
        if(_token == ETH_TOKEN_ADDRESS){
            if (_buyerPercent > 0){
                _buyer.transfer((_value - _totalFees) * _buyerPercent / 100);
            }
            if (_buyerPercent < 100){
                _seller.transfer((_value - _totalFees) * (100 - _buyerPercent) / 100);
            }
        }else{
            if (_buyerPercent > 0){
                require(_token.transfer(_buyer, (_value - _totalFees) * _buyerPercent / 100));
            }
            if (_buyerPercent < 100){
                require(_token.transfer(_seller, (_value - _totalFees) * (100 - _buyerPercent) / 100));
            }
        }

    }

    uint16 constant GAS_relayBaseCost = 35500;
    function relay(
        bytes32 _tradeId,
        DSToken _tradeToken,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint128 _maxGasPrice,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _actionType,
        address _caller
    ) public onlyGateway returns (bool) {
        address _relayedSender = getRelayedSender(_tradeId, _actionType, _maxGasPrice, _v, _r, _s);
        uint128 _additionalGas = uint128(_caller == relayer ? GAS_relayBaseCost : 0);
        if(_relayedSender == _buyer){
            if(_actionType == ACTION_TYPE_BUYER_PAID){
                return doBuyerPaid(_tradeId, _tradeToken, _buyer, _seller, _value, _fee, _caller, _additionalGas);
            }
        }else if(_relayedSender == _seller) {
            if(_actionType == ACTION_TYPE_SELLER_CANCEL){
                return doSellerCancel(_tradeId, _tradeToken, _buyer, _seller, _value, _fee, _caller, _additionalGas);
            }else if(_actionType == ACTION_TYPE_RELEASE){
                return doRelease(_tradeId, _tradeToken, _buyer, _seller, _value, _fee, _caller, _additionalGas);
            }
        }else{
            require(_relayedSender == _seller, "Unrecognised party");
            return false;
        }
    }

    function createEscrow(
        bytes32 _tradeId,
        DSToken _tradeToken,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint32 _paymentWindowInSeconds,
        uint32 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        address _caller
    ) external payable onlyGateway returns (bool){
        EscrowParams memory params;
        params.tradeId = _tradeId;
        params.tradeToken = _tradeToken;
        params.buyer = _buyer;
        params.seller = _seller;
        params.value = _value;
        params.fee = _fee;
        params.paymentWindowInSeconds = _paymentWindowInSeconds;
        params.expiry = _expiry;
        params.v = _v;
        params.r = _r;
        params.s = _s;
        params.caller = _caller;

        return doCreateEscrow(params);
    }

    function doCreateEscrow(
        EscrowParams params
    ) internal returns (bool) {
        require(enableMake, "DESC2C is not enable");
        require(listTokens[params.tradeToken], "Token is not allowed");
        // require(params.caller == params.seller, "Must be seller");

        bytes32 _tradeHash = keccak256(
            abi.encodePacked(params.tradeId, params.tradeToken, params.buyer, params.seller, params.value, params.fee));
        bytes32 _invitationHash = keccak256(abi.encodePacked(_tradeHash, params.paymentWindowInSeconds, params.expiry));
        require(recoverAddress(_invitationHash, params.v, params.r, params.s) == signer, "Must be signer");
        require(block.timestamp < params.expiry, "Signature has expired");

        emit CreatedEscrow(params.buyer, params.seller, _tradeHash, params.tradeToken);
        return escrowData.createEscrow(params.tradeId, params.tradeToken, params.buyer, params.seller, params.value, 
        params.fee, params.paymentWindowInSeconds);
    }

    function buyerPaid(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        address _caller
    ) external onlyGateway returns(bool) {
        require(_caller == _buyer, "Must by buyer");
        return doBuyerPaid(_tradeId, _token, _buyer, _seller, _value, _fee, _caller, 0);
    }

    function release(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        address _caller
    ) external onlyGateway returns(bool){
        require(_caller == _seller, "Must by seller");
        doRelease(_tradeId, _token, _buyer, _seller, _value, _fee, _caller, 0);
    }

    uint16 constant GAS_doRelease = 46588;
    function doRelease(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        address _caller,
        uint128 _additionalGas
    ) internal returns(bool){
        Escrow memory escrow = getEscrow(_tradeId, _token, _buyer, _seller, _value, _fee);
        require(escrow.exists, "Escrow does not exists");

        uint128 _gasFees = escrow.totalGasFeesSpentByRelayer;
        if(_caller == relayer){
            if(_token == ETH_TOKEN_ADDRESS){
                _gasFees += (GAS_doRelease + _additionalGas) * uint128(tx.gasprice);
            }else{
                uint256 relayGas = (GAS_doRelease + _additionalGas) * tx.gasprice;
                _gasFees += uint128(getTokenAmount(_token, relayGas));
            }
        }else{
            require(_caller == _seller, "Must by seller");
        }
        escrowData.removeEscrow(escrow.tradeHash);
        transferMinusFees(_token, _buyer, _value, _gasFees, _fee);
        emit Release(_buyer, _seller, escrow.tradeHash, _token);
        return true;
    }

    uint16 constant GAS_doBuyerPaid = 35944;
    function doBuyerPaid(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        address _caller,
        uint128 _additionalGas
    ) internal returns(bool){
        Escrow memory escrow = getEscrow(_tradeId, _token, _buyer, _seller, _value, _fee);
        require(escrow.exists, "Escrow not exists");

        if(_caller == relayer){
            if(_token == ETH_TOKEN_ADDRESS){
                require(escrowData.increaseTotalGasFeesSpentByRelayer(escrow.tradeHash, (GAS_doBuyerPaid + _additionalGas) * uint128(tx.gasprice)));
            }else{
                uint256 relayGas = (GAS_doBuyerPaid + _additionalGas) * tx.gasprice;
                require(escrowData.increaseTotalGasFeesSpentByRelayer(escrow.tradeHash, uint128(getTokenAmount(_token, relayGas))));
            }
        }else{
            require(_caller == _buyer, "Must be buyer");
        }
        
        require(escrowData.updateSellerCanCancelAfter(escrow.tradeHash, requestCancellationMinimumTime));
        emit BuyerPaid(_buyer, _seller, escrow.tradeHash, _token);
        return true;
    }

    function sellerCancel(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint32 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        address _caller
    ) external onlyGateway returns (bool){
        require(_caller == _seller, "Must be seller");
        bytes32 tradeHash = keccak256(abi.encodePacked(_tradeId, _token, _buyer, _seller, _value, _fee));
        bytes32 invitationHash = keccak256(abi.encodePacked(tradeHash, ACTION_TYPE_SELLER_CANCEL, _expiry));
        require(recoverAddress(invitationHash, _v, _r, _s) == signer, "Must be signer");
        return doSellerCancel(_tradeId, _token, _buyer, _seller, _value, _fee, _caller, 0);
    }

    uint16 constant GAS_doSellerCancel = 46255;
    function doSellerCancel(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        address _caller,
        uint128 _additionalGas
    ) private returns (bool) {
        Escrow memory escrow = getEscrow(_tradeId, _token, _buyer, _seller, _value, _fee);
        require(escrow.exists, "Escrow does not exists");

        if(block.timestamp < escrow.sellerCanCancelAfter){
            return false;
        }

        uint128 _gasFees = escrow.totalGasFeesSpentByRelayer;
        if(_caller == relayer){
            if(_token == ETH_TOKEN_ADDRESS){
                _gasFees += (GAS_doSellerCancel + _additionalGas) * uint128(tx.gasprice);
            }else{
                uint256 relayGas = (GAS_doSellerCancel + _additionalGas) * tx.gasprice;
                _gasFees += uint128(getTokenAmount(_token, relayGas));
            }
        }else{
            require(_caller == _seller, "Must be buyer");
        }
        
        escrowData.removeEscrow(escrow.tradeHash);
        emit CancelledBySeller(_buyer, _seller, escrow.tradeHash, _token);
        transferMinusFees(_token, _seller, _value, _gasFees, 0);
        return true;
    }

    function transferMinusFees(
        DSToken _token,
        address _to,
        uint256 _value,
        uint128 _totalGasFeesSpentByRelayer,
        uint16 _fee
    ) private {
        uint256 _totalFees = (_value * _fee / 10000);
        _totalFees += _totalGasFeesSpentByRelayer;
        if(_value - _totalFees > _value) {
            return;
        }
        feesAvailableForWithdraw[_token] += _totalFees;

        if(_token == ETH_TOKEN_ADDRESS){
            _to.transfer(_value - _totalFees);
        }else{
            require(_token.transfer(_to, _value - _totalFees));
        }
    }

    function getFeesAvailableForWithdraw(
        DSToken _token
    ) public view auth returns(uint256){
        // bytes32 key = keccak256(abi.encodePacked(_token, msg.sender));
        // require(withdrawAddresses[key], "unauthorization address!");
        return feesAvailableForWithdraw[_token];
    }

    // function approvedWithdrawAddress(DSToken _token, address _addr, bool _approve) public auth returns(bool){
    //     // require(_addr != address(0x00), "Approved address is null");
    //     bytes32 key = keccak256(abi.encodePacked(_token, _addr));
    //     require(withdrawAddresses[key] != _approve, "Address has approved");
    //     withdrawAddresses[key] = _approve;
    //     // emit WithdrawAddressApproved(_token, _addr, _approve);
    //     return true;
    // }

    function withdraw(DSToken _token, uint _amnt, address _receiver) external auth returns(bool){
        // require(withdrawAddresses[keccak256(abi.encodePacked(_token, _receiver))], "Address not in white list");
        require(feesAvailableForWithdraw[_token] > 0, "Fees is 0 or token not exists");
        require(_amnt <= feesAvailableForWithdraw[_token], "Amount is higher than amount available");
        if(_token == ETH_TOKEN_ADDRESS){
            _receiver.transfer(_amnt);
        }else{
            require(_token.transfer(_receiver, _amnt), "Withdraw failed");
        }
        // emit LogWithdraw(_token, _receiver, _amnt);
        return true;
    }

    function getEscrow(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee
    ) private returns(Escrow){
        bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeId, _token, _buyer, _seller, _value, _fee));
        bool exists;
        uint32 sellerCanCancelAfter;
        uint128 totalFeesSpentByRelayer; 
        (exists, sellerCanCancelAfter, totalFeesSpentByRelayer) = escrowData.getEscrow(_tradeHash);

        return Escrow(_tradeHash, exists, sellerCanCancelAfter, totalFeesSpentByRelayer);
    }

    function () public payable{
    }

    function recoverAddress(
        bytes32 _h,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal pure returns (address){
        bytes memory _prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 _prefixedHash = keccak256(abi.encodePacked(_prefix, _h));
        return ecrecover(_prefixedHash, _v, _r, _s); 
    }

    function getRelayedSender(
        bytes32 _tradeId,
        uint8 _actionType,
        uint128 _maxGasPrice,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal view returns(address){
        bytes32 _hash = keccak256(abi.encodePacked(_tradeId, _actionType, _maxGasPrice));
        if(tx.gasprice > _maxGasPrice){
            return;
        }
        return recoverAddress(_hash, _v, _r, _s);
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
    uint constant WAD = 10 ** 18;
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
}
////// src/DexC2CGateway.sol
/* pragma solidity ^0.4.24; */

/* import "./DexC2C.sol"; */
/* import "ds-token/token.sol"; */
/* import "ds-auth/auth.sol"; */

contract DexC2CGateway is DSAuth{
    
    DSToken constant internal ETH_TOKEN_ADDRESS = DSToken(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    DexC2C dexc2c;

    event ResetDexC2C(address curr, address old);

    struct BatchRelayParams{
        bytes32[] _tradeId;
        DSToken[] _token;
        address[] _buyer;
        address[] _seller;
        uint256[] _value;
        uint16[] _fee;
        uint128[] _maxGasPrice;
        uint8[] _v;
        bytes32[] _r;
        bytes32[] _s;
        uint8[] _actionType;
    }


    constructor() DSAuth() public{
    }

    function setDexC2C(DexC2C _dexc2c) public auth{
        require(_dexc2c != address(0x00), "DexC2C is null");
        dexc2c = _dexc2c;
        emit ResetDexC2C(_dexc2c, dexc2c);
    }

    function resolveDispute(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _buyerPercent
    ) public{
        dexc2c.resolveDispute(_tradeId, _token, _buyer, _seller, _value, _fee, _v, _r, _s, _buyerPercent, msg.sender);
    }

    function relay(
        bytes32 _tradeId,
        DSToken _token,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint128 _maxGasPrice,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _actionType
    ) public returns(bool){
        return dexc2c.relay(_tradeId, _token, _buyer, _seller, _value, _fee, _maxGasPrice, _v, _r, _s, _actionType, msg.sender);
    }

    function createEscrow(
        bytes32 _tradeId,
        DSToken _tradeToken,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint32 _paymentWindowInSeconds,
        uint32 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns(bool) {
        if(_tradeToken == ETH_TOKEN_ADDRESS){
            require(msg.value == _value && msg.value > 0, "Incorrect token sent");
        }else{
            require(_tradeToken.transferFrom(_seller, dexc2c, _value), "Can not transfer token from seller");
        }
        return doCreateEscrow(_tradeId, _tradeToken, _buyer, _seller, _value, _fee, _paymentWindowInSeconds, _expiry, _v, _r, _s, msg.sender);
    }

    function sellerCancel(
        bytes32 _tradeId,
        DSToken _tradeToken,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint32 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns(bool){
        return dexc2c.sellerCancel(_tradeId, _tradeToken, _buyer, _seller, _value, _fee, _expiry, _v, _r, _s, msg.sender);
    }

    function buyerPaid(
        bytes32 _tradeId,
        DSToken _tradeToken,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee
    )public returns(bool){
        return dexc2c.buyerPaid(_tradeId, _tradeToken, _buyer, _seller, _value, _fee, msg.sender);
    }

    function release(
        bytes32 _tradeId,
        DSToken _tradeToken,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee
    )public returns(bool){
        return dexc2c.release(_tradeId, _tradeToken, _buyer, _seller, _value, _fee, msg.sender);
    }

    function doCreateEscrow(
        bytes32 _tradeId,
        DSToken _tradeToken,
        address _buyer,
        address _seller,
        uint256 _value,
        uint16 _fee,
        uint32 _paymentWindowInSeconds,
        uint32 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        address _caller
    ) internal returns(bool){
        return dexc2c.createEscrow.value(msg.value)(
            _tradeId,
            _tradeToken,
            _buyer,
            _seller,
            _value,
            _fee,
            _paymentWindowInSeconds,
            _expiry,
            _v,
            _r,
            _s,
            _caller
        );
    }

    function recoverAddress(
        bytes32 _h,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal pure returns (address){
        // bytes memory _prefix = "\x19Ethereum Signed Message:\n32";
        // bytes32 _prefixedHash = keccak256(abi.encodePacked(_prefix, _h));
        // return ecrecover(_prefixedHash, _v, _r, _s); 
        return ecrecover(_h, _v, _r, _s);
    }

    function getRelayedSender(
        bytes32 _tradeId,
        uint8 _actionType,
        uint128 _maxGasPrice,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal view returns(address){
        bytes32 _hash = keccak256(abi.encodePacked(_tradeId, _actionType, _maxGasPrice));
        if(tx.gasprice > _maxGasPrice){
            return;
        }
        return recoverAddress(_hash, _v, _r, _s);
    }
}

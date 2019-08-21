pragma solidity ^0.4.21;

library SafeMath {
    function add(uint256 _a, uint256 _b) pure internal returns (uint256) {
        uint256 c = _a + _b;
        assert(c >= _a && c >= _b);
        
        return c;
    }

    function sub(uint256 _a, uint256 _b) pure internal returns (uint256) {
        assert(_b <= _a);

        return _a - _b;
    }

    function mul(uint256 _a, uint256 _b) pure internal returns (uint256) {
        uint256 c = _a * _b;
        assert(_a == 0 || c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) pure internal returns (uint256) {
        assert(_b > 0);

        return _a / _b;
    }
}

contract Token {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    function transfer(address _to, uint256 _value) public returns (bool _success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success);
    function approve(address _spender, uint256 _value) public returns (bool _success);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StrictToken is Token {
    bool public strict = true;
    mapping (address => uint256) public rate;

    function getRate(address _address) public view returns (uint256);
    function getStrict() public pure returns (bool);
}

contract TrexDexMain {
    using SafeMath for uint256;

    address public owner;
    address public feeAddress;
    mapping (address => mapping (address => uint256)) public makeFees;
    mapping (address => mapping (address => uint256)) public takeFees;
    mapping (address => uint256) public depositFees;
    mapping (address => uint256) public withdrawFees;
    mapping (address => bool) public strictTokens;
    mapping (address => bool) public tokenDeposits;
    mapping (address => bool) public tokenWithdraws;
    mapping (address => mapping (address => bool)) public tokenTrades;
    mapping (address => mapping (address => uint256)) public deposits;
    mapping (address => mapping (bytes32 => bool)) public orders;
    mapping (address => mapping (bytes32 => uint256)) public orderFills;

    event Order(address buyTokenAddress, uint256 buyAmount, address sellTokenAddress, uint256 sellAmount, address takeAddress, address baseTokenAddress, uint256 expireBlock, uint256 nonce, address makeAddress);
    event Cancel(bytes32 orderHash);
    event Trade(bytes32 orderHash, uint256 buyAmount, uint256 sellAmount, uint256 takeFee, uint256 makeFee, address takeAddress);
    event Deposit(address tokenAddress, address userAddress, uint256 amount, uint256 fee, uint256 balance);
    event Withdraw(address tokenAddress, address userAddress, uint256 amount, uint256 fee, uint256 balance);
    event TransferIn(address tokenAddress, address userAddress, uint256 amount, uint256 balance);
    event TransferOut(address tokenAddress, address userAddress, uint256 amount, uint256 balance);

    modifier isOwner {
        assert(msg.sender == owner);
        _;
    }

    modifier hasPayloadSize(uint256 size) {
        assert(msg.data.length >= size + 4);
        _;
    }    

    constructor(address _feeAddress) public {
        owner = msg.sender;
        feeAddress = _feeAddress;
    }

    function() public {
        revert();
    }

    function transfer(address _tokenAddress, address _userAddress, uint256 _amount) public isOwner {
        require (deposits[_tokenAddress][msg.sender] >= _amount);
        deposits[_tokenAddress][_userAddress] = deposits[_tokenAddress][_userAddress].add(_amount);
        deposits[_tokenAddress][msg.sender] = deposits[_tokenAddress][msg.sender].sub(_amount);

        emit TransferIn(_tokenAddress, _userAddress, _amount, deposits[_tokenAddress][_userAddress]);
        emit TransferOut(_tokenAddress, msg.sender, _amount, deposits[_tokenAddress][msg.sender]);
    }

    function setOwner(address _owner) public isOwner {
        owner = _owner;
    }

    function setFeeAddress(address _feeAddress) public isOwner {
        feeAddress = _feeAddress;
    }

    function setStrictToken(address _tokenAddress, bool _isStrict) public isOwner {
        strictTokens[_tokenAddress] = _isStrict;
    }

    function setTokenTransfers(address[] _tokenAddress, bool[] _depositEnabled, bool[] _withdrawEnabled, uint256[] _depositFee, uint256[] _withdrawFee) public isOwner {
        for (uint256 i = 0; i < _tokenAddress.length; i++) {
            setTokenTransfer(_tokenAddress[i], _depositEnabled[i], _withdrawEnabled[i], _depositFee[i], _withdrawFee[i]);
        }
    }

    function setTokenTransfer(address _tokenAddress, bool _depositEnabled, bool _withdrawEnabled, uint256 _depositFee, uint256 _withdrawFee) public isOwner {
        tokenDeposits[_tokenAddress] = _depositEnabled;
        tokenWithdraws[_tokenAddress] = _withdrawEnabled;
        depositFees[_tokenAddress] = _depositFee;
        withdrawFees[_tokenAddress] = _withdrawFee;
    }

    function setTokenTrades(address[] _tokenAddress, address[] _baseTokenAddress, bool[] _tradeEnabled, uint256[] _makeFee, uint256[] _takeFee) public isOwner {
        for (uint256 i = 0; i < _tokenAddress.length; i++) {
            setTokenTrade(_tokenAddress[i], _baseTokenAddress[i], _tradeEnabled[i], _makeFee[i], _takeFee[i]);
        }
    }

    function setTokenTrade(address _tokenAddress, address _baseTokenAddress, bool _tradeEnabled, uint256 _makeFee, uint256 _takeFee) public isOwner {
        tokenTrades[_baseTokenAddress][_tokenAddress] = _tradeEnabled;
        makeFees[_baseTokenAddress][_tokenAddress] = _makeFee;
        takeFees[_baseTokenAddress][_tokenAddress] = _takeFee;
    }

    function deposit() payable public {
        uint256 fee = _depositToken(0x0, msg.sender, msg.value);

        emit Deposit(0x0, msg.sender, msg.value, fee, deposits[0x0][msg.sender]);
    }

    function depositToken(address _tokenAddress, uint256 _amount) public hasPayloadSize(2 * 32) {
        require (_tokenAddress != 0x0 && tokenDeposits[_tokenAddress]);
        require (Token(_tokenAddress).transferFrom(msg.sender, this, _amount));
        uint256 fee = _depositToken(_tokenAddress, msg.sender, _amount);

        emit Deposit(_tokenAddress, msg.sender, _amount, fee, deposits[_tokenAddress][msg.sender]);
    }

    function _depositToken(address _tokenAddress, address _userAddress, uint256 _amount) private returns (uint256 fee) {
        fee = _amount.mul(depositFees[_tokenAddress]).div(1 ether);
        deposits[_tokenAddress][_userAddress] = deposits[_tokenAddress][_userAddress].add(_amount.sub(fee));
        deposits[_tokenAddress][feeAddress] = deposits[_tokenAddress][feeAddress].add(fee);
    }

    function withdraw(uint256 _amount) public hasPayloadSize(32) {
        require (deposits[0x0][msg.sender] >= _amount);
        uint256 fee = _withdrawToken(0x0, msg.sender, _amount);
        msg.sender.transfer(_amount - fee);

        emit Withdraw(0x0, msg.sender, _amount, fee, deposits[0x0][msg.sender]);
    }

    function withdrawToken(address _tokenAddress, uint256 _amount) public hasPayloadSize(2 * 32) {
        require (_tokenAddress != 0x0 && tokenWithdraws[_tokenAddress]);
        require (deposits[_tokenAddress][msg.sender] >= _amount);
        uint256 fee = _withdrawToken(_tokenAddress, msg.sender, _amount);
        if (!Token(_tokenAddress).transfer(msg.sender, _amount - fee)) {
            revert();
        }

        emit Withdraw(_tokenAddress, msg.sender, _amount, fee, deposits[_tokenAddress][msg.sender]);
    }

    function _withdrawToken(address _tokenAddress, address _userAddress, uint256 _amount) private returns (uint256 fee) {
        fee = _amount.mul(withdrawFees[_tokenAddress]).div(1 ether);
        deposits[_tokenAddress][_userAddress] = deposits[_tokenAddress][_userAddress].sub(_amount);
        deposits[_tokenAddress][feeAddress] = deposits[_tokenAddress][feeAddress].add(fee);
    }

    function balanceOf(address _tokenAddress, address _userAddress) view public returns (uint256) {
        return deposits[_tokenAddress][_userAddress];
    }

    function order(address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _takeAddress, address _baseTokenAddress, uint256 _expireBlock, uint256 _nonce) public hasPayloadSize(8 * 32) {
        require (_checkTrade(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _baseTokenAddress));
        bytes32 hash = _buildHash(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _takeAddress, _baseTokenAddress, _expireBlock, _nonce);
        require (!orders[msg.sender][hash]);
        orders[msg.sender][hash] = true;

        emit Order(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _takeAddress, _baseTokenAddress, _expireBlock, _nonce, msg.sender);
    }

    function tradeMulti(address[] _buyTokenAddress, uint256[] _buyAmount, address[] _sellTokenAddress, uint256[] _sellAmount, address[] _takeAddress, address[] _baseTokenAddress, uint256[] _expireBlock, uint256[] _nonce, address[] _makeAddress, uint256[] _amount, uint8[] _v, bytes32[] _r, bytes32[] _s) public {
        for (uint256 i = 0; i < _buyTokenAddress.length; i++) {
            trade(_buyTokenAddress[i], _buyAmount[i], _sellTokenAddress[i], _sellAmount[i], _takeAddress[i], _baseTokenAddress[i], _expireBlock[i], _nonce[i], _makeAddress[i], _amount[i], _v[i], _r[i], _s[i]);
        }
    }

    function trade(address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _takeAddress, address _baseTokenAddress, uint256 _expireBlock, uint256 _nonce, address _makeAddress, uint256 _amount, uint8 _v, bytes32 _r, bytes32 _s) public {
        assert(msg.data.length >= 13 * 32 + 4);
        require (_checkTrade(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _baseTokenAddress));
        require (_takeAddress == 0x0 || msg.sender == _takeAddress);
        bytes32 hash = _buildHash(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _takeAddress, _baseTokenAddress, _expireBlock, _nonce);
        require (_checkHash(hash, _makeAddress, _v, _r, _s));
        require (block.number <= _expireBlock);
        require (orderFills[_makeAddress][hash] + _amount <= _buyAmount);
        _trade(hash, _buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _baseTokenAddress, _makeAddress, _amount);
    }

    function _trade(bytes32 hash, address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _baseTokenAddress, address _makeAddress, uint256 _amount) private {
        address tokenAddress = (_baseTokenAddress == _buyTokenAddress ? _sellTokenAddress : _buyTokenAddress);
        uint256 makeFee = _amount.mul(makeFees[_baseTokenAddress][tokenAddress]).div(1 ether);
        uint256 takeFee = _amount.mul(takeFees[_baseTokenAddress][tokenAddress]).div(1 ether);
        if (_buyAmount == 0) {
            _buyAmount = _calcStrictAmount(_sellTokenAddress, _sellAmount, _buyTokenAddress);
        }
        else if (_sellAmount == 0) {
            _sellAmount = _calcStrictAmount(_buyTokenAddress, _buyAmount, _sellTokenAddress);
        }
        uint256 tradeAmount = _sellAmount.mul(_amount).div(_buyAmount);
        deposits[_buyTokenAddress][msg.sender] = deposits[_buyTokenAddress][msg.sender].sub(_amount.add(takeFee));
        deposits[_buyTokenAddress][_makeAddress] = deposits[_buyTokenAddress][_makeAddress].add(_amount.sub(makeFee));
        deposits[_buyTokenAddress][feeAddress] = deposits[_buyTokenAddress][feeAddress].add(makeFee.add(takeFee));
        deposits[_sellTokenAddress][_makeAddress] = deposits[_sellTokenAddress][_makeAddress].sub(tradeAmount);
        deposits[_sellTokenAddress][msg.sender] = deposits[_sellTokenAddress][msg.sender].add(tradeAmount);
        orderFills[_makeAddress][hash] = orderFills[_makeAddress][hash].add(_amount);

        emit Trade(hash, _amount, tradeAmount, takeFee, makeFee, msg.sender);
    }

    function _calcStrictAmount(address _tokenAddress, uint256 _amount, address _strictTokenAddress) private view returns (uint256) {
        uint256 rate = StrictToken(_strictTokenAddress).getRate(_tokenAddress);
        require(rate > 0);

        return rate.mul(_amount).div(1 ether);
    }

    function _checkTrade(address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _baseTokenAddress) private view returns (bool) {
        if (!_checkTradeAddress(_buyTokenAddress, _sellTokenAddress, _baseTokenAddress)) {
            return false;
        }
        else if (_buyAmount != 0 && strictTokens[_buyTokenAddress]) {
            return false;
        }
        else if (_sellAmount != 0 && strictTokens[_sellTokenAddress]) {
            return false;
        }

        return true;
    }

    function _checkTradeAddress(address _buyTokenAddress, address _sellTokenAddress, address _baseTokenAddress) private view returns (bool) {
        return _baseTokenAddress == _buyTokenAddress ? tokenTrades[_buyTokenAddress][_sellTokenAddress] : tokenTrades[_sellTokenAddress][_buyTokenAddress];
    }

    function testTrade(address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _takeAddress, address _baseTokenAddress, uint256 _expireBlock, uint256 _nonce, address _makeAddress, uint256 _amount, uint8 _v, bytes32 _r, bytes32 _s) constant public returns (bool) {
        if (!_checkTrade(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _baseTokenAddress)) {
            return false;
        }
        else if (!(_takeAddress == 0x0 || msg.sender == _takeAddress)) {
            return false;
        }
        else if (!_hasDeposit(_buyTokenAddress, _takeAddress, _amount)) {
            return false;
        }
        else if (availableVolume(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _takeAddress, _baseTokenAddress, _expireBlock, _nonce, _makeAddress, _v, _r, _s) > _amount) {
            return false;
        }
        
        return true;
    }

    function _hasDeposit(address _buyTokenAddress, address _userAddress, uint256 _amount) private view returns (bool) {
        return deposits[_buyTokenAddress][_userAddress] >= _amount;
    }

    function availableVolume(address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _takeAddress, address _baseTokenAddress, uint256 _expireBlock, uint256 _nonce, address _makeAddress, uint8 _v, bytes32 _r, bytes32 _s) constant public returns (uint256) {
        bytes32 hash = _buildHash(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _takeAddress, _baseTokenAddress, _expireBlock, _nonce);
        if (!_checkHash(hash, _makeAddress, _v, _r, _s)) {
            return 0;
        }

        return _availableVolume(hash, _buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _makeAddress);
    }

    function _availableVolume(bytes32 hash, address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _makeAddress) private view returns (uint256) {
        if (_buyAmount == 0) {
            _buyAmount = _calcStrictAmount(_sellTokenAddress, _sellAmount, _buyTokenAddress);
        }
        else if (_sellAmount == 0) {
            _sellAmount = _calcStrictAmount(_buyTokenAddress, _buyAmount, _sellTokenAddress);
        }
        uint256 available1 = _buyAmount.sub(orderFills[_makeAddress][hash]);
        uint256 available2 = deposits[_sellTokenAddress][_makeAddress].mul(_buyAmount).div(_sellAmount);

        return available1 < available2 ? available1 : available2;
    }

    function amountFilled(address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _takeAddress, address _baseTokenAddress, uint256 _expireBlock, uint256 _nonce, address _makeAddress) constant public returns (uint256) {
        bytes32 hash = _buildHash(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _takeAddress, _baseTokenAddress, _expireBlock, _nonce);

        return orderFills[_makeAddress][hash];
    }

    function cancelOrder(address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _takeAddress, address _baseTokenAddress, uint256 _expireBlock, uint256 _nonce, uint8 _v, bytes32 _r, bytes32 _s) public hasPayloadSize(11 * 32) {
        bytes32 hash = _buildHash(_buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _takeAddress, _baseTokenAddress, _expireBlock, _nonce);
        require (_checkHash(hash, msg.sender, _v, _r, _s));
        orderFills[msg.sender][hash] = _buyAmount;

        emit Cancel(hash);
    }

    function _buildHash(address _buyTokenAddress, uint256 _buyAmount, address _sellTokenAddress, uint256 _sellAmount, address _takeAddress, address _baseTokenAddress, uint256 _expireBlock, uint256 _nonce) private view returns (bytes32) {
        return sha256(abi.encodePacked(this, _buyTokenAddress, _buyAmount, _sellTokenAddress, _sellAmount, _takeAddress, _baseTokenAddress, _expireBlock, _nonce));
    }

    function _checkHash(bytes32 _hash, address _makeAddress, uint8 _v, bytes32 _r, bytes32 _s) private view returns (bool) {
        return (orders[_makeAddress][_hash] || ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _v, _r, _s) == _makeAddress);
    }

}
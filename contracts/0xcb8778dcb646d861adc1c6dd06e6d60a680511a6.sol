pragma solidity ^0.4.23;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Signature verifier
 * @dev To verify C level actions
 */
contract SignatureVerifier {

    function splitSignature(bytes sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
        // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
        // second 32 bytes
            s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    // Returns the address that signed a given string message
    function verifyString(
        string message,
        uint8 v,
        bytes32 r,
        bytes32 s)
    internal pure
    returns (address signer) {

        // The message header; we will fill in the length next
        string memory header = "\x19Ethereum Signed Message:\n000000";
        uint256 lengthOffset;
        uint256 length;

        assembly {
        // The first word of a string is its length
            length := mload(message)
        // The beginning of the base-10 message length in the prefix
            lengthOffset := add(header, 57)
        }

        // Maximum length we support
        require(length <= 999999);
        // The length of the message's length in base-10
        uint256 lengthLength = 0;
        // The divisor to get the next left-most message length digit
        uint256 divisor = 100000;
        // Move one digit of the message length to the right at a time

        while (divisor != 0) {
            // The place value at the divisor
            uint256 digit = length / divisor;
            if (digit == 0) {
                // Skip leading zeros
                if (lengthLength == 0) {
                    divisor /= 10;
                    continue;
                }
            }
            // Found a non-zero digit or non-leading zero digit
            lengthLength++;
            // Remove this digit from the message length's current value
            length -= digit * divisor;
            // Shift our base-10 divisor over
            divisor /= 10;

            // Convert the digit to its ASCII representation (man ascii)
            digit += 0x30;
            // Move to the next character and write the digit
            lengthOffset++;
            assembly {
                mstore8(lengthOffset, digit)
            }
        }
        // The null string requires exactly 1 zero (unskip 1 leading 0)
        if (lengthLength == 0) {
            lengthLength = 1 + 0x19 + 1;
        } else {
            lengthLength += 1 + 0x19;
        }
        // Truncate the tailing zeros from the header
        assembly {
            mstore(header, lengthLength)
        }
        // Perform the elliptic curve recover operation
        bytes32 check = keccak256(header, message);
        return ecrecover(check, v, r, s);
    }
}

/**
 * @title A DEKLA token access control
 * @author DEKLA (https://www.dekla.io)
 * @dev The Dekla token has 3 C level address to manage.
 * They can execute special actions but it need to be approved by another C level address.
 */
contract AccessControl is SignatureVerifier {
    using SafeMath for uint256;

    // C level address that can execute special actions.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;
    address public systemAddress;
    uint256 public CLevelTxCount_ = 0;

    // @dev store nonces
    mapping(address => uint256) nonces;

    // @dev C level transaction must be approved with another C level address
    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    modifier onlySystem() {
        require(msg.sender == systemAddress);
        _;
    }

    function recover(bytes32 hash, bytes sig) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        //Check the signature length
        if (sig.length != 65) {
            return (address(0));
        }
        // Divide the signature in r, s and v variables
        (v, r, s) = splitSignature(sig);
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }
        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            bytes memory prefix = "\x19Ethereum Signed Message:\n32";
            bytes32 prefixedHash = keccak256(prefix, hash);
            return ecrecover(prefixedHash, v, r, s);
        }
    }

    function signedCLevel(
        bytes32 _message,
        bytes _sig
    )
    internal
    view
    onlyCLevel
    returns (bool)
    {
        address signer = recover(_message, _sig);

        require(signer != msg.sender);
        return (
        signer == cooAddress ||
        signer == ceoAddress ||
        signer == cfoAddress
        );
    }

    event addressLogger(address signer);

    /**
     * @notice Hash (keccak256) of the payload used by setCEO
     * @param _newCEO address The address of the new CEO
     * @param _nonce uint256 setCEO transaction number.
     */
    function getCEOHashing(address _newCEO, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(bytes4(0x486A0F3E), _newCEO, _nonce);
    }

    // @dev Assigns a new address to act as the CEO. The C level transaction, must verify.
    // @param _newCEO The address of the new CEO
    function setCEO(
        address _newCEO,
        bytes _sig
    ) external onlyCLevel {
        require(
            _newCEO != address(0) &&
            _newCEO != cfoAddress &&
            _newCEO != cooAddress
        );

        bytes32 hashedTx = getCEOHashing(_newCEO, nonces[msg.sender]);
        require(signedCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        ceoAddress = _newCEO;
        CLevelTxCount_++;
    }

    /**
     * @notice Hash (keccak256) of the payload used by setCFO
     * @param _newCFO address The address of the new CFO
     * @param _nonce uint256 setCEO transaction number.
     */
    function getCFOHashing(address _newCFO, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(bytes4(0x486A0F01), _newCFO, _nonce);
    }

    // @dev Assigns a new address to act as the CFO. The C level transaction, must verify.
    // @param _newCFO The address of the new CFO
    function setCFO(
        address _newCFO,
        bytes _sig
    ) external onlyCLevel {
        require(
            _newCFO != address(0) &&
            _newCFO != ceoAddress &&
            _newCFO != cooAddress
        );

        bytes32 hashedTx = getCFOHashing(_newCFO, nonces[msg.sender]);
        require(signedCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        cfoAddress = _newCFO;
        CLevelTxCount_++;
    }

    /**
     * @notice Hash (keccak256) of the payload used by setCOO
     * @param _newCOO address The address of the new COO
     * @param _nonce uint256 setCEO transaction number.
     */
    function getCOOHashing(address _newCOO, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(bytes4(0x486A0F02), _newCOO, _nonce);
    }

    // @dev Assigns a new address to act as the COO. The C level transaction, must verify.
    // @param _newCOO The address of the new COO, _sig signature used to verify COO address
    function setCOO(
        address _newCOO,
        bytes _sig
    ) external onlyCLevel {
        require(
            _newCOO != address(0) &&
            _newCOO != ceoAddress &&
            _newCOO != cfoAddress
        );

        bytes32 hashedTx = getCOOHashing(_newCOO, nonces[msg.sender]);
        require(signedCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        cooAddress = _newCOO;
        CLevelTxCount_++;
    }

    function getNonce() external view returns (uint256) {
        return nonces[msg.sender];
    }
}


interface ERC20 {
    function transfer(address _to, uint _value) external returns (bool success);

    function balanceOf(address who) external view returns (uint256);
}

contract PreSaleToken is AccessControl {

    using SafeMath for uint256;

    // @dev This define events
    event BuyDeklaSuccessful(uint256 dekla, address buyer);
    event SendDeklaSuccessful(uint256 dekla, address buyer);
    event WithdrawEthSuccessful(uint256 price, address receiver);
    event WithdrawDeklaSuccessful(uint256 price, address receiver);
    event UpdateDeklaPriceSuccessful(uint256 bonus, address sender);

    // @dev This is price of 1 DKL (Dekla Token)
    // Current: 1 DKL = 0.00002259 ETH = 22590000000000 Wei = 0.005$
    uint256 public deklaTokenPrice = 22590000000000;

    // @dev percent bonus ~ 8.8%
    uint16 public bonus = 880;

    // @dev decimals unit
    uint256 public decimals = 18;

    // @dev Dekla Token minimum
    uint256 public deklaMinimum = 5000 * (10 ** decimals);

    // ERC20 basic token contract being help
    ERC20 public token;

    // @dev store address and dekla token
    mapping(address => uint256) deklaTokenOf;

    // @dev sale status
    bool public preSaleEnd;

    // @dev total dekla token amount for pre-sale
    uint256 public totalToken;

    // @dev total number of token already been should
    uint256 public soldToken;

    address public systemAddress;

    // @dev store nonces
    mapping(address => uint256) nonces;

    constructor(
        address _ceoAddress,
        address _cfoAddress,
        address _cooAddress,
        address _systemAddress,
        uint256 _totalToken
    ) public {
        require(_totalToken > 0);
        // initial C level address
        ceoAddress = _ceoAddress;
        cfoAddress = _cfoAddress;
        cooAddress = _cooAddress;
        totalToken = _totalToken * (10 ** decimals);
        systemAddress = _systemAddress;
    }

    //check that the token is set
    modifier validToken() {
        require(token != address(0));
        _;
    }

    modifier onlySystem() {
        require(msg.sender ==  systemAddress);
        _;
    }

    function recover(bytes32 hash, bytes sig) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        //Check the signature length
        if (sig.length != 65) {
            return (address(0));
        }
        // Divide the signature in r, s and v variables
        (v, r, s) = splitSignature(sig);
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }
        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            bytes memory prefix = "\x19Ethereum Signed Message:\n32";
            bytes32 prefixedHash = keccak256(prefix, hash);
            return ecrecover(prefixedHash, v, r, s);
        }
    }
    
    function getNonces(address _sender) public view returns (uint256) {
        return nonces[_sender];
    }
    
    function getTokenAddressHashing(address _token, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(bytes4(0x486A0F03), _token, _nonce);
    }

    function setTokenAddress(address _token, bytes _sig) external onlyCLevel {
        bytes32 hashedTx = getTokenAddressHashing(_token, nonces[msg.sender]);
        require(signedCLevel(hashedTx, _sig));
        token = ERC20(_token);
        nonces[msg.sender]++;
    }

    // @dev update selling status
    // @dev _selling == true: sale token is running, _selling = true: sale token is pause/stop
    // @param _selling is status of selling
    function setPreSaleEnd(bool _end) external onlyCLevel {
        preSaleEnd = _end;
    }

    // @dev get preSaleEnd status
    function isPreSaleEnd() external view returns (bool) {
        return preSaleEnd;
    }

    function setDeklaPrice(uint256 _price) external onlySystem {
        deklaTokenPrice = _price;
        emit UpdateDeklaPriceSuccessful(_price, msg.sender);
    }

    // @dev buy Dekla Token with eth of pre-sale
    // @param value is eth balance
    function() external payable {
        // validate sale is opening
        require(!preSaleEnd);

        // unit of msg.value is Wei
        uint256 amount = msg.value.div(deklaTokenPrice);
        amount = amount * (10 ** decimals);

        // require total Dekla Token minimum
        require(amount >= deklaMinimum);

        // update total token left
        soldToken = soldToken.add(amount);

        if(soldToken < totalToken) {
            // calculate how much Dekla Token buyer will have with bonus is 8,8%
            amount = amount.add(amount.mul(bonus).div(10000));
        }

        // store dekla balance
        deklaTokenOf[msg.sender] = deklaTokenOf[msg.sender].add(amount);

        // This notifies clients about the buy dekla
        emit BuyDeklaSuccessful(amount, msg.sender);
    }

    function getPromoBonusHashing(address _buyer, uint16 _bonus, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(bytes4(0x486A0F2F), _buyer, _bonus, _nonce);
    }

    // @dev buy Dekla Token with eth of pre-sale
    // @param value is eth balance
    function buyDkl(uint16 _bonus, bytes _sig) external payable {
        // validate sale is opening
        require(!preSaleEnd);

        // bonus maximum should be <= 1500 ~ 15% and >= 500 ~ 5%
        require(_bonus >= 500 && _bonus <= 1500);

        bytes32 hashedTx = getPromoBonusHashing(msg.sender, _bonus, nonces[msg.sender]);

        // promo bonus should sign by systemAddress
        require(recover(hashedTx, _sig) == systemAddress);

        // update nonces of sender
        nonces[msg.sender]++;

        // unit of msg.value is Wei
        uint256 amount = msg.value.div(deklaTokenPrice);
        amount = amount * (10 ** decimals);

        // require total Dekla Token minimum
        require(amount >= deklaMinimum);

        // update total token left
        soldToken = soldToken.add(amount);

        if(soldToken < totalToken) {
            // calculate how much Dekla Token buyer will have with bonus
            amount = amount.add(amount.mul(_bonus).div(10000));
        }

        // store dekla balance
        deklaTokenOf[msg.sender] = deklaTokenOf[msg.sender].add(amount);

        // This notifies clients about the buy dekla
        emit BuyDeklaSuccessful(amount, msg.sender);
    }

    // @dev get Dekla Token of user
    function getDeklaTokenOf(address _address) external view returns (uint256) {
        return deklaTokenOf[_address];
    }

    // @dev calculate Dekla Token received with ETH
    function calculateDekla(uint256 _value) external view returns (uint256) {
        require(_value >= deklaTokenPrice);
        return _value.div(deklaTokenPrice);
    }

    // @dev send Dekla Token to buyer
    function sendDekla(address _address) external payable validToken {
        // check address
        require(_address != address(0));

        // get buyer info
        uint256 amount = deklaTokenOf[_address];

        // buyer dekla should be greater than 0
        require(amount > 0);

        // check total dekla of owner
        require(token.balanceOf(this) >= amount);

        // reset dekla
        deklaTokenOf[_address] = 0;

        // transfer dekla to user
        token.transfer(_address, amount);

        // notify event to receiver
        emit SendDeklaSuccessful(amount, _address);
    }

    function sendDeklaToMultipleUsers(address[] _receivers) external payable validToken {
        // check address list not empty
        require(_receivers.length > 0);

        // loop send dekla
        for (uint i = 0; i < _receivers.length; i++) {
            address _address = _receivers[i];

            // check address
            require(_address != address(0));

            // get buyer info
            uint256 amount = deklaTokenOf[_address];

            // buyer dekla should be greater than 0
            // check total dekla of owner
            if (amount > 0 && token.balanceOf(this) >= amount) {
                // reset dekla
                deklaTokenOf[_address] = 0;

                // transfer dekla to user
                token.transfer(_address, amount);

                // notify event to receiver
                emit SendDeklaSuccessful(amount, _address);
            }
        }
    }

    function withdrawEthHashing(address _address, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(bytes4(0x486A0F0D), _address, _nonce);
    }

    // @dev withdraw ETH balance from owner to wallet input
    // @param withdrawWallet is wallet address of receiver ETH
    function withdrawEth(address _withdrawWallet, bytes _sig) external onlyCLevel {
        bytes32 hashedTx = withdrawEthHashing(_withdrawWallet, nonces[msg.sender]);
        require(signedCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        uint256 balance = address(this).balance;

        // balance should be greater than 0
        require(balance > 0);

        // transfer ETH to receiver
        _withdrawWallet.transfer(balance);

        // notify event to receiver
        emit WithdrawEthSuccessful(balance, _withdrawWallet);
    }

    function withdrawDeklaHashing(address _address, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(bytes4(0x486A0F0E), _address, _nonce);
    }

    // @dev withdraw DKL balance from owner to wallet input
    // @param _walletAddress is wallet address of receiver DKL
    function withdrawDekla(address _withdrawWallet, bytes _sig) external validToken onlyCLevel {
        bytes32 hashedTx = withdrawDeklaHashing(_withdrawWallet, nonces[msg.sender]);
        require(signedCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        uint256 balance = token.balanceOf(this);

        // the sold tokens must be left
        require(balance > soldToken);

        // transfer dekla to receiver
        token.transfer(_withdrawWallet, balance - soldToken);

        // notify event to receiver
        emit WithdrawDeklaSuccessful(balance, _withdrawWallet);
    }
}
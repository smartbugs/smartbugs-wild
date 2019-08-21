pragma solidity ^0.4.23;

// File: contracts\SignatureVerifier.sol

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
        bytes32 check = keccak256(abi.encodePacked(header, message));
        return ecrecover(check, v, r, s);
    }
}

// File: contracts\SafeMath.sol

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

// File: contracts\ERC20Token.sol

/**
 * @title A DEKLA token access control
 * @author DEKLA (https://www.dekla.io)
 * @dev The Dekla token has 3 C level address to manage.
 * They can execute special actions but it need to be approved by another C level address.
 */
contract DeklaAccessControl is SignatureVerifier {
    using SafeMath for uint256;

    // C level address that can execute special actions.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;
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
            bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
            return ecrecover(prefixedHash, v, r, s);
        }
    }

    // @dev return true if transaction already signed by a C Level address
    // @param _message The string to be verify
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

    /**
     * @notice Hash (keccak256) of the payload used by setCEO
     * @param _newCEO address The address of the new CEO
     * @param _nonce uint256 setCEO transaction number.
     */
    function getCEOHashing(address _newCEO, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0F3E), _newCEO, _nonce));
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
     * @param _nonce uint256 setCFO transaction number.
     */
    function getCFOHashing(address _newCFO, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0F3F), _newCFO, _nonce));
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
     * @param _nonce uint256 setCO transaction number.
     */
    function getCOOHashing(address _newCOO, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0F40), _newCOO, _nonce));
    }

    // @dev Assigns a new address to act as the COO. The C level transaction, must verify.
    // @param _newCOO The address of the new COO
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


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
* @title ERC865Token Token
*
* ERC865Token allows users paying transfers in tokens instead of gas
* https://github.com/ethereum/EIPs/issues/865
*
*/
contract ERC865 is ERC20Basic {
    function transferPreSigned(
        bytes _signature,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool);

    function approvePreSigned(
        bytes _signature,
        address _spender,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool);

    function increaseApprovalPreSigned(
        bytes _signature,
        address _spender,
        uint256 _addedValue,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool);

    function decreaseApprovalPreSigned(
        bytes _signature,
        address _spender,
        uint256 _subtractedValue,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool);

    function transferFromPreSigned(
        bytes _signature,
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 *
 */
contract BasicToken is ERC20Basic, DeklaAccessControl {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    // Setable mint rate for the first time
    uint256 mintTxCount_ = 1;
    uint256 public teamRate = 20;
    uint256 public saleRate = 80;

    // Team address
    address public saleAddress;
    address public teamAddress;
    /**
     * @dev total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
    public view returns (uint256);

    function transferFrom(address from, address to, uint256 value)
    public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(
        address _spender,
        uint _addedValue
    )
    public
    returns (bool) {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
    public
    returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}


/**
* @title ERC865Token Token
*
* ERC865Token allows users paying transfers in tokens instead of gas
* https://github.com/ethereum/EIPs/issues/865
*
*/
contract ERC865Token is ERC865, StandardToken {
    /* Nonces of transfers performed */
    // mapping(bytes => bool) signatures;

    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);
    event ApprovalPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);

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
            bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
            return ecrecover(prefixedHash, v, r, s);
        }
    }

    function recoverSigner(
        bytes _signature,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    view
    returns (address)
    {
        require(_to != address(0));
        // require(signatures[_signature] == false);
        bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        return from;
    }


    function transferPreSigned(
        bytes _signature,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool)
    {
        require(_to != address(0));
        // require(signatures[_signature] == false);
        bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        balances[from] = balances[from].sub(_value).sub(_fee);
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        // signatures[_signature] = true;
        emit Transfer(from, _to, _value);
        emit Transfer(from, msg.sender, _fee);
        emit TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }
    /**
    * @notice Submit a presigned approval
    * @param _signature bytes The signature, issued by the owner.
    * @param _spender address The address which will spend the funds.
    * @param _value uint256 The amount of tokens to allow.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
    * @param _nonce uint256 Presigned transaction number.
    */
    function approvePreSigned(
        bytes _signature,
        address _spender,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool)
    {
        require(_spender != address(0));
        // require(signatures[_signature] == false);
        bytes32 hashedTx = approvePreSignedHashing(address(this), _spender, _value, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        allowed[from][_spender] = _value;
        balances[from] = balances[from].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        // signatures[_signature] = true;
        emit Approval(from, _spender, _value);
        emit Transfer(from, msg.sender, _fee);
        emit ApprovalPreSigned(from, _spender, msg.sender, _value, _fee);
        return true;
    }

    /**
    * @notice Increase the amount of tokens that an owner allowed to a spender.
    * @param _signature bytes The signature, issued by the owner.
    * @param _spender address The address which will spend the funds.
    * @param _addedValue uint256 The amount of tokens to increase the allowance by.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
    * @param _nonce uint256 Presigned transaction number.
    */
    function increaseApprovalPreSigned(
        bytes _signature,
        address _spender,
        uint256 _addedValue,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool)
    {
        require(_spender != address(0));
        // require(signatures[_signature] == false);
        bytes32 hashedTx = increaseApprovalPreSignedHashing(address(this), _spender, _addedValue, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        allowed[from][_spender] = allowed[from][_spender].add(_addedValue);
        balances[from] = balances[from].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        // signatures[_signature] = true;
        emit Approval(from, _spender, allowed[from][_spender]);
        emit Transfer(from, msg.sender, _fee);
        emit ApprovalPreSigned(from, _spender, msg.sender, allowed[from][_spender], _fee);
        return true;
    }

    /**
    * @notice Decrease the amount of tokens that an owner allowed to a spender.
    * @param _signature bytes The signature, issued by the owner
    * @param _spender address The address which will spend the funds.
    * @param _subtractedValue uint256 The amount of tokens to decrease the allowance by.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
    * @param _nonce uint256 Presigned transaction number.
    */
    function decreaseApprovalPreSigned(
        bytes _signature,
        address _spender,
        uint256 _subtractedValue,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool)
    {
        require(_spender != address(0));
        // require(signatures[_signature] == false);
        bytes32 hashedTx = decreaseApprovalPreSignedHashing(address(this), _spender, _subtractedValue, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        uint oldValue = allowed[from][_spender];
        if (_subtractedValue > oldValue) {
            allowed[from][_spender] = 0;
        } else {
            allowed[from][_spender] = oldValue.sub(_subtractedValue);
        }
        balances[from] = balances[from].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        // signatures[_signature] = true;
        emit Approval(from, _spender, _subtractedValue);
        emit Transfer(from, msg.sender, _fee);
        emit ApprovalPreSigned(from, _spender, msg.sender, allowed[from][_spender], _fee);
        return true;
    }

    /**
    * @notice Transfer tokens from one address to another
    * @param _signature bytes The signature, issued by the spender.
    * @param _from address The address which you want to send tokens from.
    * @param _to address The address which you want to transfer to.
    * @param _value uint256 The amount of tokens to be transferred.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the spender.
    * @param _nonce uint256 Presigned transaction number.
    */
    function transferFromPreSigned(
        bytes _signature,
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    returns (bool)
    {
        require(_to != address(0));
        // require(signatures[_signature] == false);
        bytes32 hashedTx = transferFromPreSignedHashing(address(this), _from, _to, _value, _fee, _nonce);
        address spender = recover(hashedTx, _signature);
        require(spender != address(0));
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][spender] = allowed[_from][spender].sub(_value);
        balances[spender] = balances[spender].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        // signatures[_signature] = true;
        emit Transfer(_from, _to, _value);
        emit Transfer(spender, msg.sender, _fee);
        return true;
    }

    /**
    * @notice Hash (keccak256) of the payload used by transferPreSigned
    * @param _token address The address of the token.
    * @param _to address The address which you want to transfer to.
    * @param _value uint256 The amount of tokens to be transferred.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
    * @param _nonce uint256 Presigned transaction number.
    */
    function transferPreSignedHashing(
        address _token,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    pure
    returns (bytes32)
    {
        /* "48664c16": transferPreSignedHashing(address,address,address,uint256,uint256,uint256) */
        return keccak256(abi.encodePacked(bytes4(0x486A0F41), _token, _to, _value, _fee, _nonce));
    }
    /**
    * @notice Hash (keccak256) of the payload used by approvePreSigned
    * @param _token address The address of the token
    * @param _spender address The address which will spend the funds.
    * @param _value uint256 The amount of tokens to allow.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
    * @param _nonce uint256 Presigned transaction number.
    */
    function approvePreSignedHashing(
        address _token,
        address _spender,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_token, _spender, _value, _fee, _nonce));
    }
    /**
    * @notice Hash (keccak256) of the payload used by increaseApprovalPreSigned
    * @param _token address The address of the token
    * @param _spender address The address which will spend the funds.
    * @param _addedValue uint256 The amount of tokens to increase the allowance by.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
    * @param _nonce uint256 Presigned transaction number.
    */
    function increaseApprovalPreSignedHashing(
        address _token,
        address _spender,
        uint256 _addedValue,
        uint256 _fee,
        uint256 _nonce
    )
    public
    pure
    returns (bytes32)
    {
        /* "a45f71ff": increaseApprovalPreSignedHashing(address,address,uint256,uint256,uint256) */
        return keccak256(abi.encodePacked(bytes4(0x486A0F42), _token, _spender, _addedValue, _fee, _nonce));
    }
    /**
    * @notice Hash (keccak256) of the payload used by decreaseApprovalPreSigned
    * @param _token address The address of the token
    * @param _spender address The address which will spend the funds.
    * @param _subtractedValue uint256 The amount of tokens to decrease the allowance by.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
    * @param _nonce uint256 Presigned transaction number.
    */
    function decreaseApprovalPreSignedHashing(
        address _token,
        address _spender,
        uint256 _subtractedValue,
        uint256 _fee,
        uint256 _nonce
    )
    public
    pure
    returns (bytes32)
    {
        /* "59388d78": decreaseApprovalPreSignedHashing(address,address,uint256,uint256,uint256) */
        return keccak256(abi.encodePacked(bytes4(0x486A0F43), _token, _spender, _subtractedValue, _fee, _nonce));
    }
    /**
    * @notice Hash (keccak256) of the payload used by transferFromPreSigned
    * @param _token address The address of the token
    * @param _from address The address which you want to send tokens from.
    * @param _to address The address which you want to transfer to.
    * @param _value uint256 The amount of tokens to be transferred.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the spender.
    * @param _nonce uint256 Presigned transaction number.
    */
    function transferFromPreSignedHashing(
        address _token,
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
    public
    pure
    returns (bytes32)
    {
        /* "b7656dc5": transferFromPreSignedHashing(address,address,address,uint256,uint256,uint256) */
        return keccak256(abi.encodePacked(bytes4(0x486A0F44), _token, _from, _to, _value, _fee, _nonce));
    }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is ERC865Token {
    using SafeMath for uint256;

    event Mint(address indexed to, uint256 amount);

    // Limit total supply to 10 billion
    uint256 public constant totalTokenLimit = 10000000000000000000000000000;

    // Max token left percent allow to mint, based on 100%
    uint256 public maxTokenRateToMint = 20;
    uint256 public canMintLimit = 0;


    /**
     * @dev Throws if total supply is higher than total token limit
     */
    modifier canMint()
    {

        // Address to mint must defined
        require(
            teamAddress != address(0) &&
            saleAddress != address(0)

        );

        // Total supply after mint must lower or equal total token limit
        require(totalSupply_ <= totalTokenLimit);
        require(balances[saleAddress] <= canMintLimit);
        _;
    }


    /**
     * @dev Function to mint tokens: mint 1000000000000000000000000000 every times
     * @return A boolean that indicates if the operation was successful.
     */
    function mint() onlyCLevel external {
        _mint(1000000000000000000000000000);
    }

    function _mint(uint256 _amount)
    canMint
    internal
    {
        uint256 saleAmount_ = _amount.mul(saleRate).div(100);
        uint256 teamAmount_ = _amount.mul(teamRate).div(100);

        totalSupply_ = totalSupply_.add(_amount);
        balances[saleAddress] = balances[saleAddress].add(saleAmount_);
        balances[teamAddress] = balances[teamAddress].add(teamAmount_);

        canMintLimit = balances[saleAddress]
        .mul(maxTokenRateToMint)
        .div(100);
        mintTxCount_++;

        emit Mint(saleAddress, saleAmount_);
        emit Mint(teamAddress, teamAmount_);
    }

    function getMaxTokenRateToMintHashing(uint256 _rate, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0F45), _rate, _nonce));
    }

    function setMaxTokenRateToMint(
        uint256 _rate,
        bytes _sig
    ) external onlyCLevel {
        require(_rate <= 100);
        require(_rate >= 0);

        bytes32 hashedTx = getMaxTokenRateToMintHashing(_rate, nonces[msg.sender]);
        require(signedCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        maxTokenRateToMint = _rate;
        CLevelTxCount_++;
    }

    function getMintRatesHashing(uint256 _saleRate, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0F46), _saleRate, _nonce));
    }

    function setMintRates(
        uint256 saleRate_,
        bytes _sig
    )
    external
    onlyCLevel
    {
        require(saleRate.add(teamRate) == 100);
        require(mintTxCount_ >= 3);

        bytes32 hashedTx = getMintRatesHashing(saleRate_, nonces[msg.sender]);
        require(signedCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        saleRate = saleRate_;
        CLevelTxCount_++;
    }
}


contract DeklaToken is MintableToken {
    string public name = "Dekla Token";
    string public symbol = "DKL";
    uint256 public decimals = 18;
    uint256 public INITIAL_SUPPLY = 1000000000 * (10 ** decimals);

    function isDeklaToken() public pure returns (bool){
        return true;
    }

    constructor (
        address _ceoAddress,
        address _cfoAddress,
        address _cooAddress,
        address _teamAddress,
        address _saleAddress
    ) public {
        // initial prize address
        teamAddress = _teamAddress;

        // initial C level address
        ceoAddress = _ceoAddress;
        cfoAddress = _cfoAddress;
        cooAddress = _cooAddress;
        saleAddress = _saleAddress;

        // mint tokens first time
        _mint(INITIAL_SUPPLY);
    }
}
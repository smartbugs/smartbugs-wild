pragma solidity 0.4.23;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address internal owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

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
    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
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
    function allowance(address _owner, address _spender) public view returns (uint256) {
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
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
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
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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


/// @title   Token
/// @author  Jose Perez - <jose.perez@diginex.com>
/// @notice  ERC20 token
/// @dev     The contract allows to perform a number of token sales in different periods in time.
///          allowing participants in previous token sales to transfer tokens to other accounts.
///          Additionally, token locking logic for KYC/AML compliance checking is supported.

contract Token is StandardToken, Ownable {
    using SafeMath for uint256;

    string public constant name = "TSX";
    string public constant symbol = "TSX";
    uint256 public constant decimals = 9;

    // Using same number of decimal figures as ETH (i.e. 18).
    uint256 public constant TOKEN_UNIT = 10 ** uint256(decimals);

    // Maximum number of tokens in circulation
    uint256 public constant MAX_TOKEN_SUPPLY = 10000000000 * TOKEN_UNIT;

    // Maximum size of the batch functions input arrays.
    uint256 public constant MAX_BATCH_SIZE = 400;

//    address public assigner;    // The address allowed to assign or mint tokens during token sale.
    address public locker;      // The address allowed to lock/unlock addresses.

    mapping(address => bool) public locked;        // If true, address' tokens cannot be transferred.
    mapping(address => bool) public alwLockTx;

    mapping(address => TxRecord[]) public txRecordPerAddress;

    mapping(address => uint) public chainStartIdxPerAddress;
    mapping(address => uint) public chainEndIdxPerAddress;

    struct TxRecord {
        uint amount;
        uint releaseTime;
        uint nextIdx;
        uint prevIdx;
    }

    event Lock(address indexed addr);
    event Unlock(address indexed addr);
    event Assign(address indexed to, uint256 amount);
    event LockerTransferred(address indexed previousLocker, address indexed newLocker);
//    event AssignerTransferred(address indexed previousAssigner, address indexed newAssigner);

    /// @dev Constructor that initializes the contract.
    constructor() public {
        locker = owner;
        balances[owner] = balances[owner].add(MAX_TOKEN_SUPPLY);
        recop(owner, MAX_TOKEN_SUPPLY, 0);
        totalSupply_ = MAX_TOKEN_SUPPLY;
        alwLT(owner, true);
    }

    /// @dev Throws if called by any account other than the locker.
    modifier onlyLocker() {
        require(msg.sender == locker);
        _;
    }

    function isLocker() public view returns (bool) {
        return msg.sender == locker;
    }


    /// @dev Allows the current owner to change the locker.
    /// @param _newLocker The address of the new locker.
    /// @return True if the operation was successful.
    function transferLocker(address _newLocker) external onlyOwner returns (bool) {
        require(_newLocker != address(0));

        emit LockerTransferred(locker, _newLocker);
        locker = _newLocker;
        return true;
    }

    function alwLT(address _address, bool _enable) public onlyLocker returns (bool) {
        alwLockTx[_address] = _enable;
        return true;
    }

    function alwLTBatches(address[] _addresses, bool _enable) external onlyLocker returns (bool) {
        require(_addresses.length > 0);
        require(_addresses.length <= MAX_BATCH_SIZE);

        for (uint i = 0; i < _addresses.length; i++) {
            alwLT(_addresses[i], _enable);
        }
        return true;
    }

    /// @dev Locks an address. A locked address cannot transfer its tokens or other addresses' tokens out.
    ///      Only addresses participating in the current token sale can be locked.
    ///      Only the locker account can lock addresses and only during the token sale.
    /// @param _address address The address to lock.
    /// @return True if the operation was successful.
    function lockAddress(address _address) public onlyLocker returns (bool) {
        require(!locked[_address]);

        locked[_address] = true;
        emit Lock(_address);
        return true;
    }

    /// @dev Unlocks an address so that its owner can transfer tokens out again.
    ///      Addresses can be unlocked any time. Only the locker account can unlock addresses
    /// @param _address address The address to unlock.
    /// @return True if the operation was successful.
    function unlockAddress(address _address) public onlyLocker returns (bool) {
        require(locked[_address]);

        locked[_address] = false;
        emit Unlock(_address);
        return true;
    }

    /// @dev Locks several addresses in one single call.
    /// @param _addresses address[] The addresses to lock.
    /// @return True if the operation was successful.
    function lockInBatches(address[] _addresses) external onlyLocker returns (bool) {
        require(_addresses.length > 0);
        require(_addresses.length <= MAX_BATCH_SIZE);

        for (uint i = 0; i < _addresses.length; i++) {
            lockAddress(_addresses[i]);
        }
        return true;
    }

    /// @dev Unlocks several addresses in one single call.
    /// @param _addresses address[] The addresses to unlock.
    /// @return True if the operation was successful.
    function unlockInBatches(address[] _addresses) external onlyLocker returns (bool) {
        require(_addresses.length > 0);
        require(_addresses.length <= MAX_BATCH_SIZE);

        for (uint i = 0; i < _addresses.length; i++) {
            unlockAddress(_addresses[i]);
        }
        return true;
    }

    /// @dev Checks whether or not the given address is locked.
    /// @param _address address The address to be checked.
    /// @return Boolean indicating whether or not the address is locked.
    function isLocked(address _address) external view returns (bool) {
        return locked[_address];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(!locked[msg.sender]);
        require(_to != address(0));
        return transferFT(msg.sender, _to, _value, 0);
    }

    function transferL(address _to, uint256 _value, uint256 lTime) public returns (bool) {
        require(alwLockTx[msg.sender]);
        require(!locked[msg.sender]);
        require(_to != address(0));
        return transferFT(msg.sender, _to, _value, lTime);
    }

    function getRecordInfo(address addr, uint256 index) external onlyOwner view returns (uint, uint, uint, uint) {
        TxRecord memory tr = txRecordPerAddress[addr][index];
        return (tr.amount, tr.prevIdx, tr.nextIdx, tr.releaseTime);
    }

    function delr(address _address, uint256 index) public onlyOwner returns (bool) {
        require(index < txRecordPerAddress[_address].length);
        TxRecord memory tr = txRecordPerAddress[_address][index];
        if (index == chainStartIdxPerAddress[_address]) {
            chainStartIdxPerAddress[_address] = tr.nextIdx;
        } else if (index == chainEndIdxPerAddress[_address]) {
            chainEndIdxPerAddress[_address] = tr.prevIdx;
        } else {
            txRecordPerAddress[_address][tr.prevIdx].nextIdx = tr.nextIdx;
            txRecordPerAddress[_address][tr.nextIdx].prevIdx = tr.prevIdx;
        }
        delete txRecordPerAddress[_address][index];
        balances[_address] = balances[_address].sub(tr.amount);
        return true;
    }

    function resetTime(address _address, uint256 index, uint256 lTime) external onlyOwner returns (bool) {
        require(index < txRecordPerAddress[_address].length);
        TxRecord memory tr = txRecordPerAddress[_address][index];
        delr(_address, index);
        recop(_address, tr.amount, lTime);
        balances[_address] = balances[_address].add(tr.amount);
        return true;
    }

    function payop(address _from, uint needTakeout) private {
        TxRecord memory txRecord;
        for (uint idx = chainEndIdxPerAddress[_from]; true; idx = txRecord.prevIdx) {
            txRecord = txRecordPerAddress[_from][idx];
            if (now < txRecord.releaseTime)
                break;
            if (txRecord.amount <= needTakeout) {
                chainEndIdxPerAddress[_from] = txRecord.prevIdx;
                delete txRecordPerAddress[_from][idx];
                needTakeout = needTakeout.sub(txRecord.amount);
            } else {
                txRecordPerAddress[_from][idx].amount = txRecord.amount.sub(needTakeout);
                needTakeout = 0;
                break;
            }
            if (idx == chainStartIdxPerAddress[_from]) {
                break;
            }
        }
        require(needTakeout == 0);
    }

    function recop(address _to, uint256 _value, uint256 lTime) private {
        if (txRecordPerAddress[_to].length < 1) {
            txRecordPerAddress[_to].push(TxRecord({amount : _value, releaseTime : now.add(lTime), nextIdx : 0, prevIdx : 0}));
            chainStartIdxPerAddress[_to] = 0;
            chainEndIdxPerAddress[_to] = 0;
            return;
        }
        uint startIndex = chainStartIdxPerAddress[_to];
        uint endIndex = chainEndIdxPerAddress[_to];
        if (lTime == 0 && txRecordPerAddress[_to][endIndex].releaseTime < now) {
            txRecordPerAddress[_to][endIndex].amount = txRecordPerAddress[_to][endIndex].amount.add(_value);
            return;
        }
        TxRecord memory utxo = TxRecord({amount : _value, releaseTime : now.add(lTime), nextIdx : 0, prevIdx : 0});
        for (uint idx = startIndex; true; idx = txRecordPerAddress[_to][idx].nextIdx) {
            if (utxo.releaseTime < txRecordPerAddress[_to][idx].releaseTime) {
                if (idx == chainEndIdxPerAddress[_to]) {
                    utxo.prevIdx = idx;
                    txRecordPerAddress[_to].push(utxo);
                    txRecordPerAddress[_to][idx].nextIdx = txRecordPerAddress[_to].length - 1;
                    chainEndIdxPerAddress[_to] = txRecordPerAddress[_to].length - 1;
                    return;
                } else if (utxo.releaseTime >= txRecordPerAddress[_to][txRecordPerAddress[_to][idx].nextIdx].releaseTime) {
                    utxo.prevIdx = idx;
                    utxo.nextIdx = txRecordPerAddress[_to][idx].nextIdx;
                    txRecordPerAddress[_to].push(utxo);
                    txRecordPerAddress[_to][txRecordPerAddress[_to][idx].nextIdx].prevIdx = txRecordPerAddress[_to].length - 1;
                    txRecordPerAddress[_to][idx].nextIdx = txRecordPerAddress[_to].length - 1;
                    return;
                }
            } else {
                if (idx == startIndex) {
                    utxo.nextIdx = idx;
                    txRecordPerAddress[_to].push(utxo);
                    txRecordPerAddress[_to][idx].prevIdx = txRecordPerAddress[_to].length - 1;
                    chainStartIdxPerAddress[_to] = txRecordPerAddress[_to].length - 1;
                    return;
                }
            }
            if (idx == chainEndIdxPerAddress[_to]) {
                return;
            }
        }
    }

    function transferFT(address _from, address _to, uint256 _value, uint256 lTime) private returns (bool) {
        payop(_from, _value);
        balances[_from] = balances[_from].sub(_value);

        recop(_to, _value, lTime);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function txRecordCount(address add) public onlyOwner view returns (uint){
        return txRecordPerAddress[add].length;
    }


    /// @dev Transfers tokens from one address to another. It prevents transferring tokens if the caller is locked or
    ///      if the allowed address is locked.
    ///      Locked addresses can receive tokens.
    ///      Current token sale's addresses cannot receive or send tokens until the token sale ends.
    /// @param _from address The address to transfer tokens from.
    /// @param _to address The address to transfer tokens to.
    /// @param _value The number of tokens to be transferred.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(!locked[msg.sender]);
        require(!locked[_from]);
        require(_to != address(0));
        require(_from != _to);
        super.transferFrom(_from, _to, _value);
        return transferFT(_from, _to, _value, 0);
    }

    function kill() onlyOwner {
        selfdestruct(owner);
    }
}
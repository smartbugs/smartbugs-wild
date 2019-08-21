pragma solidity 0.4.19;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    //Variables
    address public owner;

    address public newOwner;

    //    Modifiers
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;

    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping (address => uint256) public balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood:
        https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
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
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract OCGERC20 is StandardToken, Ownable {

    using SafeMath for uint256;

    /* Public variables of the token */
    uint256 public creationBlock;

    uint8 public decimals;

    string public name;

    string public symbol;

    string public standard;

    bool public locked;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function OCGERC20(
        uint256 _totalSupply,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transferAllSupplyToOwner,
        bool _locked
    ) public {
        standard = "ERC20 0.1";
        locked = _locked;
        totalSupply = _totalSupply;

        if (_transferAllSupplyToOwner) {
            balances[msg.sender] = totalSupply;
        } else {
            balances[this] = totalSupply;
        }
        name = _tokenName;
        // Set the name for display purposes
        symbol = _tokenSymbol;
        // Set the symbol for display purposes
        decimals = _decimalUnits;
        // Amount of decimals for display purposes
        creationBlock = block.number;
    }

    /* public methods */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(locked == false);
        return super.transfer(_to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (locked) {
            return false;
        }
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        if (locked) {
            return false;
        }
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        if (locked) {
            return false;
        }
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (locked) {
            return false;
        }

        return super.transferFrom(_from, _to, _value);
    }

    function transferFee(address _from, address _to, uint256 _value) internal returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        return true;
    }

    function burnInternal(address _address, uint256 _value) internal returns (bool) {
        balances[_address] = balances[_address].sub(_value);
        Transfer(_address, address(0), _value);
        return true;
    }

}

/*
This contract manages the minters and the modifier to allow mint to happen only if called by minters
This contract contains basic minting functionality though
*/
contract MintingERC20 is OCGERC20 {

    // Variables
    mapping (address => bool) public minters;

    // Modifiers
    modifier onlyMinters() {
        require(true == minters[msg.sender]);
        _;
    }

    function MintingERC20(
        uint256 _initialSupply,
        string _tokenName,
        uint8 _decimals,
        string _symbol,
        bool _transferAllSupplyToOwner,
        bool _locked
    )
    public OCGERC20(
        _initialSupply,
        _tokenName,
        _decimals,
        _symbol,
        _transferAllSupplyToOwner,
        _locked
    )
    {
        standard = "MintingERC20 0.1";
        minters[msg.sender] = true;
    }

    function addMinter(address _newMinter) public onlyOwner {
        minters[_newMinter] = true;
    }

    function removeMinter(address _minter) public onlyOwner {
        minters[_minter] = false;
    }

    function mint(address _addr, uint256 _amount) public onlyMinters returns (uint256) {
        if (_amount == uint256(0)) {
            return uint256(0);
        }

        totalSupply = totalSupply.add(_amount);
        balances[_addr] = balances[_addr].add(_amount);
        Transfer(address(0), _addr, _amount);

        return _amount;
    }
}

contract OCG is MintingERC20 {

    OCGFee public fees;

    SellableToken public sellableToken;

    uint256 public deployedAt;

    address public burnAddress;

    mapping (address => uint256) public burnAmount;

    mapping (address => uint256) public lastCharge;

    event TransferFee(address indexed from, uint256 value);

    event StorageFee(address indexed from, uint256 value);

    modifier onlySellableContract() {
        require(msg.sender == address(sellableToken));
        _;
    }

    function OCG(
        string _tokenName,
        string _tokenSymbol,
        uint8 _decimalUnits,
        address _burnAddress,
        bool _locked
    ) public MintingERC20(
        0,
        _tokenName,
        _decimalUnits,
        _tokenSymbol,
        false,
        _locked
    ) {
        standard = "OCG 0.1";
        deployedAt = now;
        require(_burnAddress != address(0));
        burnAddress = _burnAddress;
    }

    function setLocked(bool _locked) public onlyOwner {
        locked = _locked;
    }

    function setOCGFee(address _fees) public onlyOwner {
        require(_fees != address(0));
        fees = OCGFee(_fees);
    }

    function setSellableToken(address _sellable) public onlyOwner {
        require(_sellable != address(0));
        sellableToken = SellableToken(_sellable);
    }

    function setBurnAddress(address _burnAddress) public onlyOwner {
        require(_burnAddress != address(0));
        burnAddress = _burnAddress;
    }

    function burn(address _address) public onlyOwner {
        if (burnAmount[_address] > 0) {
            super.burnInternal(burnAddress, burnAmount[_address]);
            burnAmount[_address] = 0;
        }
    }

    function transfer(address _to, uint256 _value) public returns (bool status) {
        require(locked == false && msg.sender != burnAddress);

        uint256 valueToTransfer = _value;

        if (_to == burnAddress) {
            burnAmount[msg.sender] = burnAmount[msg.sender].add(valueToTransfer);
        } else {
            uint256 feeValue = transferFees(msg.sender, _to, _value);

            valueToTransfer = _value.sub(feeValue);
            if (valueToTransfer > balanceOf(msg.sender)) {
                valueToTransfer = balanceOf(msg.sender);
            }
        }

        status = super.transfer(_to, valueToTransfer);

        sellableToken.updateFreeStorage(msg.sender, balanceOf(msg.sender));
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool status) {
        require(locked == false && _from != burnAddress);

        uint256 valueToTransfer = _value;

        if (_to == burnAddress) {
            burnAmount[_from] = burnAmount[_from].add(valueToTransfer);
        } else {
            uint256 feeValue = transferFees(_from, _to, _value);

            valueToTransfer = _value.sub(feeValue);
            if (valueToTransfer > balanceOf(_from)) {
                valueToTransfer = balanceOf(_from);
            }
        }

        status = super.transferFrom(_from, _to, valueToTransfer);
        require(status == true);

        sellableToken.updateFreeStorage(_from, balanceOf(_from));
    }

    function mint(address _addr, uint256 _amount) public onlyMinters returns (uint256) {
        uint256 mintedAmount = super.mint(_addr, _amount);

        if (mintedAmount == _amount && lastCharge[_addr] == 0 && _amount > 0) {
            lastCharge[_addr] = now;
        }

        return mintedAmount;
    }

    function payStorageFee(address _from) internal returns (bool) {
        require(_from != address(0) && address(fees) != address(0) && address(sellableToken) != address(0));
        uint256 _value = balanceOf(_from);
        require(sellableToken.freeStorage(_from) <= _value);

        bool status = true;
        uint256 additionalAmount = 0;

        if (sellableToken.freeStorage(_from) != 0) {
            if (deployedAt.add(fees.offPeriod()) >= now) {
                _value = _value.sub(sellableToken.freeStorage(_from));
            } else if (lastCharge[_from] < deployedAt.add(fees.offPeriod())) {
                additionalAmount = calculateStorageFee(
                    _value.sub(sellableToken.freeStorage(_from)),
                    deployedAt.add(fees.offPeriod()).sub(lastCharge[_from])
                );
                lastCharge[_from] = deployedAt.add(fees.offPeriod());
            }
        }

        uint256 amount = calculateStorageFee(_value, now.sub(lastCharge[_from])).add(additionalAmount);
        if (amount != 0 && balanceOf(_from) >= amount) {
            status = super.transferFee(_from, fees.feeAddress(), amount);
            StorageFee(_from, amount);
        }

        require(status == true);
        lastCharge[_from] = now;

        return status;
    }

    function calculateStorageFee(uint256 _value, uint256 _period) internal view returns (uint256) {
        uint256 amount = 0;

        if (_period.div(1 days) > 0 && _value > 0) {
            amount = _value.mul(_period.mul(fees.feeAmount()).div(1 years)).div(10);
        }

        return amount;
    }

    function transferFees(address _from, address _to, uint256 _value) internal returns (uint256) {
        require(address(fees) != address(0) && address(sellableToken) != address(0));

        bool status = false;

        if (fees.feeAmount() > 0) {
            status = payStorageFee(_from);
            if (status) {
                status = payStorageFee(_to);
            }
        }

        uint256 feeValue = 0;
        if (fees.transferFee() > 0) {
            feeValue = _value.mul(fees.transferFee()).div(uint(10) ** decimals);
        }
        if (status && feeValue > 0) {
            status = super.transferFee(_from, fees.transferFeeAddress(), feeValue);
            TransferFee(_from, feeValue);
        }

        require(status == true);

        return feeValue;
    }

}

contract OCGFee is Ownable {

    SellableToken public sellableToken;

    using SafeMath for uint256;

    uint256 public offPeriod = 3 years;

    uint256 public offThreshold;

    uint256 public feeAmount;

    address public feeAddress;

    address public transferFeeAddress;

    uint256 public transferFee;

    modifier onlySellableContract() {
        require(msg.sender == address(sellableToken));
        _;
    }

    function OCGFee(
        uint256 _offThreshold,
        address _feeAddress,
        uint256 _feeAmount,//0.5% -> 5
        address _transferFeeAddress,
        uint256 _transferFee //0.04% -> 0.04 * 10 ^ decimals
    )
        public
    {
        require(_feeAddress != address(0) && _feeAmount >= 0 && _offThreshold > 0);
        offThreshold = _offThreshold;
        feeAddress = _feeAddress;
        feeAmount = _feeAmount;

        require(_transferFeeAddress != address(0) && _transferFee >= 0);
        transferFeeAddress = _transferFeeAddress;
        transferFee = _transferFee;
    }

    function setSellableToken(address _sellable) public onlyOwner {
        require(_sellable != address(0));
        sellableToken = SellableToken(_sellable);
    }

    function setStorageFee(
        uint256 _offThreshold,
        address _feeAddress,
        uint256 _feeAmount //0.5% -> 5
    ) public onlyOwner {
        require(_feeAddress != address(0));

        offThreshold = _offThreshold;
        feeAddress = _feeAddress;
        feeAmount = _feeAmount;
    }

    function decreaseThreshold(uint256 _value) public onlySellableContract {
        if (offThreshold < _value) {
            offThreshold = 0;
        } else {
            offThreshold = offThreshold.sub(_value);
        }
    }

    function setTransferFee(address _transferFeeAddress, uint256 _transferFee) public onlyOwner returns (bool) {
        if (_transferFeeAddress != address(0) && _transferFee >= 0) {
            transferFeeAddress = _transferFeeAddress;
            transferFee = _transferFee;

            return true;
        }

        return false;
    }

}

contract Multivest is Ownable {
    /* public variables */
    mapping (address => bool) public allowedMultivests;

    /* events */
    event MultivestSet(address multivest);

    event MultivestUnset(address multivest);

    event Contribution(address _holder, uint256 tokens);

    modifier onlyAllowedMultivests(address _address) {
        require(true == allowedMultivests[_address]);
        _;
    }

    /* constructor */
    function Multivest(address _multivest) public {
        allowedMultivests[_multivest] = true;
    }

    /* public methods */
    function setAllowedMultivest(address _address) public onlyOwner {
        allowedMultivests[_address] = true;
    }

    function unsetAllowedMultivest(address _address) public onlyOwner {
        allowedMultivests[_address] = false;
    }

    function multivestBuy(
        address _address,
        uint256 _amount,
        uint256 _value
    ) public onlyAllowedMultivests(msg.sender) {
        bool status = buy(_address, _amount, _value);

        require(status == true);
    }

    function buy(address _address, uint256 _amount, uint256 _value) internal returns (bool);

}

contract SellableToken is Multivest {

    using SafeMath for uint256;

    // The token being sold
    OCG public ocg;

    OCGFee public fees;

    // amount of sold tokens
    uint256 public soldTokens;

    uint256 public minInvest;

    mapping (address => uint256) public freeStorage;

    modifier onlyOCGContract() {
        require(msg.sender == address(ocg));
        _;
    }

    function SellableToken(
        address _ocg,
        uint256 _minInvest //0.1 tokens -> 0.1 * 10 ^ decimals
    )
        public Multivest(msg.sender)
    {
        require(_minInvest > 0);
        ocg = OCG(_ocg);

        minInvest = _minInvest;
    }

    function setOCG(address _ocg) public onlyOwner {
        require(_ocg != address(0));
        ocg = OCG(_ocg);
    }

    function setOCGFee(address _fees) public onlyOwner {
        require(_fees != address(0));
        fees = OCGFee(_fees);
    }

    function updateFreeStorage(address _address, uint256 _value) public onlyOCGContract {
        if (freeStorage[_address] > _value) {
            freeStorage[_address] = _value;
        }
    }

    function buy(address _address, uint256 _amount, uint256 _value) internal returns (bool) {
        require(_address != address(0) && address(ocg) != address(0));

        if (_amount == 0 || _amount < minInvest || _value == 0) {
            return false;
        }

        uint256 mintedAmount = ocg.mint(_address, _amount);

        require(mintedAmount == _amount);

        onSuccessfulBuy(_address, _value, _amount);

        return true;
    }

    function onSuccessfulBuy(address _address, uint256 _value, uint256 _amount) internal {
        soldTokens = soldTokens.add(_amount);
        if (fees.offThreshold() > 0) {
            uint256 freeAmount = _amount;
            if (fees.offThreshold() < _value) {
                freeAmount = _amount.sub(_value.sub(fees.offThreshold()).mul(_amount).div(_value));
            }

            freeStorage[_address] = freeStorage[_address].add(freeAmount);
        }

        fees.decreaseThreshold(_value);
    }

}

contract Deposit is Multivest {

    address public etherHolder;

    function Deposit(
        address _etherHolder
    )
        public Multivest(msg.sender)
    {
        require(_etherHolder != address(0));
        etherHolder = _etherHolder;
    }

    function setEtherHolder(address _etherHolder) public onlyOwner {
        require(_etherHolder != address(0));
        etherHolder = _etherHolder;
    }

    function deposit(
        address _address,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable onlyAllowedMultivests(verify(keccak256(msg.sender), _v, _r, _s)) {
        require(_address == msg.sender);
        Contribution(msg.sender, msg.value);
        etherHolder.transfer(msg.value);
    }

    function verify(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        return ecrecover(keccak256(prefix, _hash), _v, _r, _s);
    }

    function buy(address _address, uint256 _amount, uint256 _value) internal returns (bool) {
        _address = _address;
        _amount = _amount;
        _value = _value;
        return true;
    }

}
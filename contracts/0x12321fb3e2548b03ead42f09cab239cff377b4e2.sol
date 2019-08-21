pragma solidity 0.4.18;

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control functions,
/// this simplifies the implementation of "user permissions".
/// @dev Based on OpenZeppelin's Ownable.

contract Ownable {
    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed _by, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    /// @dev Constructor sets the original `owner` of the contract to the sender account.
    function Ownable() public {
        owner = msg.sender;
    }

    /// @dev Reverts if called by any account other than the owner.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerCandidate() {
        require(msg.sender == newOwnerCandidate);
        _;
    }

    /// @dev Proposes to transfer control of the contract to a newOwnerCandidate.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    function requestOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
        require(_newOwnerCandidate != address(0));

        newOwnerCandidate = _newOwnerCandidate;

        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @dev Accept ownership transfer. This method needs to be called by the perviously proposed owner.
    function acceptOwnership() external onlyOwnerCandidate {
        address previousOwner = owner;

        owner = newOwnerCandidate;
        newOwnerCandidate = address(0);

        OwnershipTransferred(previousOwner, owner);
    }
}

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function toPower2(uint256 a) internal pure returns (uint256) {
        return mul(a, a);
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        uint256 c = (a + 1) / 2;
        uint256 b = a;
        while (c < b) {
            b = c;
            c = (a / c + c) / 2;
        }
        return b;
    }
}

/// @title ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/issues/20)
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address _owner) constant public returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}



/// @title ERC Token Standard #677 Interface (https://github.com/ethereum/EIPs/issues/677)
contract ERC677 is ERC20 {
    function transferAndCall(address to, uint value, bytes data) public returns (bool ok);

    event TransferAndCall(address indexed from, address indexed to, uint value, bytes data);
}

/// @title ERC223Receiver Interface
/// @dev Based on the specs form: https://github.com/ethereum/EIPs/issues/223
contract ERC223Receiver {
    function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok);
}




/// @title Basic ERC20 token contract implementation.
/// @dev Based on OpenZeppelin's StandardToken.
contract BasicToken is ERC20 {
    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    /// @param _spender address The address which will spend the funds.
    /// @param _value uint256 The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public returns (bool) {
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve (see NOTE)
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    /// @dev Function to check the amount of tokens that an owner allowed to a spender.
    /// @param _owner address The address which owns the funds.
    /// @param _spender address The address which will spend the funds.
    /// @return uint256 specifying the amount of tokens still available for the spender.
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    /// @dev Gets the balance of the specified address.
    /// @param _owner address The address to query the the balance of.
    /// @return uint256 representing the amount owned by the passed address.
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Transfer token to a specified address.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /// @dev Transfer tokens from one address to another.
    /// @param _from address The address which you want to send tokens from.
    /// @param _to address The address which you want to transfer to.
    /// @param _value uint256 the amount of tokens to be transferred.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        var _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = _allowance.sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }
}






/// @title Standard677Token implentation, base on https://github.com/ethereum/EIPs/issues/677

contract Standard677Token is ERC677, BasicToken {

  /// @dev ERC223 safe token transfer from one address to another
  /// @param _to address the address which you want to transfer to.
  /// @param _value uint256 the amount of tokens to be transferred.
  /// @param _data bytes data that can be attached to the token transation
  function transferAndCall(address _to, uint _value, bytes _data) public returns (bool) {
    require(super.transfer(_to, _value)); // do a normal token transfer
    TransferAndCall(msg.sender, _to, _value, _data);
    //filtering if the target is a contract with bytecode inside it
    if (isContract(_to)) return contractFallback(_to, _value, _data);
    return true;
  }

  /// @dev called when transaction target is a contract
  /// @param _to address the address which you want to transfer to.
  /// @param _value uint256 the amount of tokens to be transferred.
  /// @param _data bytes data that can be attached to the token transation
  function contractFallback(address _to, uint _value, bytes _data) private returns (bool) {
    ERC223Receiver receiver = ERC223Receiver(_to);
    require(receiver.tokenFallback(msg.sender, _value, _data));
    return true;
  }

  /// @dev check if the address is contract
  /// assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  /// @param _addr address the address to check
  function isContract(address _addr) private constant returns (bool is_contract) {
    // retrieve the size of the code on target address, this needs assembly
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}





/// @title Token holder contract.
contract TokenHolder is Ownable {
    /// @dev Allow the owner to transfer out any accidentally sent ERC20 tokens.
    /// @param _tokenAddress address The address of the ERC20 contract.
    /// @param _amount uint256 The amount of tokens to be transferred.
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) public onlyOwner returns (bool success) {
        return ERC20(_tokenAddress).transfer(owner, _amount);
    }
}






/// @title Colu Local Network contract.
/// @author Tal Beja.
contract ColuLocalNetwork is Ownable, Standard677Token, TokenHolder {
    using SafeMath for uint256;

    string public constant name = "Colu Local Network";
    string public constant symbol = "CLN";

    // Using same decimals value as ETH (makes ETH-CLN conversion much easier).
    uint8 public constant decimals = 18;

    // States whether token transfers is allowed or not.
    // Used during token sale.
    bool public isTransferable = false;

    event TokensTransferable();

    modifier transferable() {
        require(msg.sender == owner || isTransferable);
        _;
    }

    /// @dev Creates all tokens and gives them to the owner.
    function ColuLocalNetwork(uint256 _totalSupply) public {
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply;
    }

    /// @dev start transferable mode.
    function makeTokensTransferable() external onlyOwner {
        if (isTransferable) {
            return;
        }

        isTransferable = true;

        TokensTransferable();
    }

    /// @dev Same ERC20 behavior, but reverts if not transferable.
    /// @param _spender address The address which will spend the funds.
    /// @param _value uint256 The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public transferable returns (bool) {
        return super.approve(_spender, _value);
    }

    /// @dev Same ERC20 behavior, but reverts if not transferable.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    function transfer(address _to, uint256 _value) public transferable returns (bool) {
        return super.transfer(_to, _value);
    }

    /// @dev Same ERC20 behavior, but reverts if not transferable.
    /// @param _from address The address to send tokens from.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 the amount of tokens to be transferred.
    function transferFrom(address _from, address _to, uint256 _value) public transferable returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /// @dev Same ERC677 behavior, but reverts if not transferable.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    /// @param _data bytes data to send to receiver if it is a contract.
    function transferAndCall(address _to, uint _value, bytes _data) public transferable returns (bool success) {
      return super.transferAndCall(_to, _value, _data);
    }
}



 /// @title Standard ERC223 Token Receiver implementing tokenFallback function and tokenPayable modifier

contract Standard223Receiver is ERC223Receiver {
  Tkn tkn;

  struct Tkn {
    address addr;
    address sender; // the transaction caller
    uint256 value;
  }

  bool __isTokenFallback;

  modifier tokenPayable {
    require(__isTokenFallback);
    _;
  }

  /// @dev Called when the receiver of transfer is contract
  /// @param _sender address the address of tokens sender
  /// @param _value uint256 the amount of tokens to be transferred.
  /// @param _data bytes data that can be attached to the token transation
  function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok) {
    if (!supportsToken(msg.sender)) {
      return false;
    }

    // Problem: This will do a sstore which is expensive gas wise. Find a way to keep it in memory.
    // Solution: Remove the the data
    tkn = Tkn(msg.sender, _sender, _value);
    __isTokenFallback = true;
    if (!address(this).delegatecall(_data)) {
      __isTokenFallback = false;
      return false;
    }
    // avoid doing an overwrite to .token, which would be more expensive
    // makes accessing .tkn values outside tokenPayable functions unsafe
    __isTokenFallback = false;

    return true;
  }

  function supportsToken(address token) public constant returns (bool);
}





/// @title TokenOwnable
/// @dev The TokenOwnable contract adds a onlyTokenOwner modifier as a tokenReceiver with ownable addaptation

contract TokenOwnable is Standard223Receiver, Ownable {
    /// @dev Reverts if called by any account other than the owner for token sending.
    modifier onlyTokenOwner() {
        require(tkn.sender == owner);
        _;
    }
}






/// @title Vesting trustee contract for Colu Local Network.
/// @dev This Contract can't be TokenHolder, since it will allow its owner to drain its vested tokens.
/// @dev This means that any token sent to it different than ColuLocalNetwork is basicly stucked here forever.
/// @dev ColuLocalNetwork that sent here (by mistake) can withdrawn using the grant method.
contract VestingTrustee is TokenOwnable {
    using SafeMath for uint256;

    // Colu Local Network contract.
    ColuLocalNetwork public cln;

    // Vesting grant for a speicifc holder.
    struct Grant {
        uint256 value;
        uint256 start;
        uint256 cliff;
        uint256 end;
        uint256 installmentLength; // In seconds.
        uint256 transferred;
        bool revokable;
    }

    // Holder to grant information mapping.
    mapping (address => Grant) public grants;

    // Total tokens vested.
    uint256 public totalVesting;

    event NewGrant(address indexed _from, address indexed _to, uint256 _value);
    event TokensUnlocked(address indexed _to, uint256 _value);
    event GrantRevoked(address indexed _holder, uint256 _refund);

    uint constant OK = 1;
    uint constant ERR_INVALID_VALUE = 10001;
    uint constant ERR_INVALID_VESTED = 10002;
    uint constant ERR_INVALID_TRANSFERABLE = 10003;

    event Error(address indexed sender, uint error);

    /// @dev Constructor that initializes the address of the Colu Local Network contract.
    /// @param _cln ColuLocalNetwork The address of the previously deployed Colu Local Network contract.
    function VestingTrustee(ColuLocalNetwork _cln) public {
        require(_cln != address(0));

        cln = _cln;
    }

    /// @dev Allow only cln token to be tokenPayable
    /// @param token the token to check
    function supportsToken(address token) public constant returns (bool) {
        return (cln == token);
    }

    /// @dev Grant tokens to a specified address.
    /// @param _to address The holder address.
    /// @param _start uint256 The beginning of the vesting period (timestamp).
    /// @param _cliff uint256 When the first installment is made (timestamp).
    /// @param _end uint256 The end of the vesting period (timestamp).
    /// @param _installmentLength uint256 The length of each vesting installment (in seconds).
    /// @param _revokable bool Whether the grant is revokable or not.
    function grant(address _to, uint256 _start, uint256 _cliff, uint256 _end,
        uint256 _installmentLength, bool _revokable)
        external onlyTokenOwner tokenPayable {

        require(_to != address(0));
        require(_to != address(this)); // Protect this contract from receiving a grant.

        uint256 value = tkn.value;

        require(value > 0);

        // Require that every holder can be granted tokens only once.
        require(grants[_to].value == 0);

        // Require for time ranges to be consistent and valid.
        require(_start <= _cliff && _cliff <= _end);

        // Require installment length to be valid and no longer than (end - start).
        require(_installmentLength > 0 && _installmentLength <= _end.sub(_start));

        // Grant must not exceed the total amount of tokens currently available for vesting.
        require(totalVesting.add(value) <= cln.balanceOf(address(this)));

        // Assign a new grant.
        grants[_to] = Grant({
            value: value,
            start: _start,
            cliff: _cliff,
            end: _end,
            installmentLength: _installmentLength,
            transferred: 0,
            revokable: _revokable
        });

        // Since tokens have been granted, increase the total amount vested.
        totalVesting = totalVesting.add(value);

        NewGrant(msg.sender, _to, value);
    }

    /// @dev Grant tokens to a specified address.
    /// @param _to address The holder address.
    /// @param _value uint256 The amount of tokens to be granted.
    /// @param _start uint256 The beginning of the vesting period (timestamp).
    /// @param _cliff uint256 When the first installment is made (timestamp).
    /// @param _end uint256 The end of the vesting period (timestamp).
    /// @param _installmentLength uint256 The length of each vesting installment (in seconds).
    /// @param _revokable bool Whether the grant is revokable or not.
    function grant(address _to, uint256 _value, uint256 _start, uint256 _cliff, uint256 _end,
        uint256 _installmentLength, bool _revokable)
        external onlyOwner {

        require(_to != address(0));
        require(_to != address(this)); // Protect this contract from receiving a grant.
        require(_value > 0);

        // Require that every holder can be granted tokens only once.
        require(grants[_to].value == 0);

        // Require for time ranges to be consistent and valid.
        require(_start <= _cliff && _cliff <= _end);

        // Require installment length to be valid and no longer than (end - start).
        require(_installmentLength > 0 && _installmentLength <= _end.sub(_start));

        // Grant must not exceed the total amount of tokens currently available for vesting.
        require(totalVesting.add(_value) <= cln.balanceOf(address(this)));

        // Assign a new grant.
        grants[_to] = Grant({
            value: _value,
            start: _start,
            cliff: _cliff,
            end: _end,
            installmentLength: _installmentLength,
            transferred: 0,
            revokable: _revokable
        });

        // Since tokens have been granted, increase the total amount vested.
        totalVesting = totalVesting.add(_value);

        NewGrant(msg.sender, _to, _value);
    }

    /// @dev Revoke the grant of tokens of a specifed address.
    /// @dev Unlocked tokens will be sent to the grantee, the rest is transferred to the trustee's owner.
    /// @param _holder The address which will have its tokens revoked.
    function revoke(address _holder) public onlyOwner {
        Grant memory grant = grants[_holder];

        // Grant must be revokable.
        require(grant.revokable);

        // Get the total amount of vested tokens, acccording to grant.
        uint256 vested = calculateVestedTokens(grant, now);

        // Calculate the untransferred vested tokens.
        uint256 transferable = vested.sub(grant.transferred);

        if (transferable > 0) {
            // Update transferred and total vesting amount, then transfer remaining vested funds to holder.
            grant.transferred = grant.transferred.add(transferable);
            totalVesting = totalVesting.sub(transferable);
            require(cln.transfer(_holder, transferable));

            TokensUnlocked(_holder, transferable);
        }

        // Calculate amount of remaining tokens that can still be returned.
        uint256 refund = grant.value.sub(grant.transferred);

        // Remove the grant.
        delete grants[_holder];

        // Update total vesting amount and transfer previously calculated tokens to owner.
        totalVesting = totalVesting.sub(refund);
        require(cln.transfer(msg.sender, refund));

        GrantRevoked(_holder, refund);
    }

    /// @dev Calculate the amount of ready tokens of a holder.
    /// @param _holder address The address of the holder.
    /// @return a uint256 Representing a holder's total amount of vested tokens.
    function readyTokens(address _holder) public constant returns (uint256) {
        Grant memory grant = grants[_holder];

        if (grant.value == 0) {
            return 0;
        }

        uint256 vested = calculateVestedTokens(grant, now);

        if (vested == 0) {
            return 0;
        }

        return vested.sub(grant.transferred);
    }

    /// @dev Calculate the total amount of vested tokens of a holder at a given time.
    /// @param _holder address The address of the holder.
    /// @param _time uint256 The specific time to calculate against.
    /// @return a uint256 Representing a holder's total amount of vested tokens.
    function vestedTokens(address _holder, uint256 _time) public constant returns (uint256) {
        Grant memory grant = grants[_holder];
        if (grant.value == 0) {
            return 0;
        }

        return calculateVestedTokens(grant, _time);
    }

    /// @dev Calculate amount of vested tokens at a specifc time.
    /// @param _grant Grant The vesting grant.
    /// @param _time uint256 The time to be checked
    /// @return An uint256 Representing the amount of vested tokens of a specific grant.
    function calculateVestedTokens(Grant _grant, uint256 _time) private pure returns (uint256) {
        // If we're before the cliff, then nothing is vested.
        if (_time < _grant.cliff) {
            return 0;
        }

        // If we're after the end of the vesting period - everything is vested.
        if (_time >= _grant.end) {
            return _grant.value;
        }

        // Calculate amount of installments past until now.
        //
        // NOTE: result gets floored because of integer division.
        uint256 installmentsPast = _time.sub(_grant.start).div(_grant.installmentLength);

        // Calculate amount of days in entire vesting period.
        uint256 vestingDays = _grant.end.sub(_grant.start);

        // Calculate and return the number of tokens according to vesting days that have passed.
        return _grant.value.mul(installmentsPast.mul(_grant.installmentLength)).div(vestingDays);
    }

    /// @dev Unlock vested tokens and transfer them to the grantee.
    /// @return a uint The success or error code.
    function unlockVestedTokens() external returns (uint) {
        return unlockVestedTokens(msg.sender);
    }

    /// @dev Unlock vested tokens and transfer them to the grantee (helper function).
    /// @param _grantee address The address of the grantee.
    /// @return a uint The success or error code.
    function unlockVestedTokens(address _grantee) private returns (uint) {
        Grant storage grant = grants[_grantee];

        // Make sure the grant has tokens available.
        if (grant.value == 0) {
            Error(_grantee, ERR_INVALID_VALUE);
            return ERR_INVALID_VALUE;
        }

        // Get the total amount of vested tokens, acccording to grant.
        uint256 vested = calculateVestedTokens(grant, now);
        if (vested == 0) {
            Error(_grantee, ERR_INVALID_VESTED);
            return ERR_INVALID_VESTED;
        }

        // Make sure the holder doesn't transfer more than what he already has.
        uint256 transferable = vested.sub(grant.transferred);
        if (transferable == 0) {
            Error(_grantee, ERR_INVALID_TRANSFERABLE);
            return ERR_INVALID_TRANSFERABLE;
        }

        // Update transferred and total vesting amount, then transfer remaining vested funds to holder.
        grant.transferred = grant.transferred.add(transferable);
        totalVesting = totalVesting.sub(transferable);
        require(cln.transfer(_grantee, transferable));

        TokensUnlocked(_grantee, transferable);
        return OK;
    }

    /// @dev batchUnlockVestedTokens vested tokens and transfer them to the grantees.
    /// @param _grantees address[] The addresses of the grantees.
    /// @return a boo if success.
    function batchUnlockVestedTokens(address[] _grantees) external onlyOwner returns (bool success) {
        for (uint i = 0; i<_grantees.length; i++) {
            unlockVestedTokens(_grantees[i]);
        }
        return true;
    }

    /// @dev Allow the owner to transfer out any accidentally sent ERC20 tokens.
    /// @param _tokenAddress address The address of the ERC20 contract.
    /// @param _amount uint256 The amount of tokens to be transferred.
    function withdrawERC20(address _tokenAddress, uint256 _amount) public onlyOwner returns (bool success) {
        if (_tokenAddress == address(cln)) {
            // If the token is cln, allow to withdraw only non vested tokens.
            uint256 availableCLN = cln.balanceOf(this).sub(totalVesting);
            require(_amount <= availableCLN);
        }
        return ERC20(_tokenAddress).transfer(owner, _amount);
    }
}








/// @title Colu Local Network sale contract.
/// @author Tal Beja.
contract ColuLocalNetworkSale is Ownable, TokenHolder {
    using SafeMath for uint256;

    // External parties:

    // Colu Local Network contract.
    ColuLocalNetwork public cln;

    // Vesting contract for presale participants.
    VestingTrustee public trustee;

    // Received funds are forwarded to this address.
    address public fundingRecipient;

    // Post-TDE multisig addresses.
    address public communityPoolAddress;
    address public futureDevelopmentPoolAddress;
    address public stakeholdersPoolAddress;

    // Colu Local Network decimals.
    // Using same decimals value as ETH (makes ETH-CLN conversion much easier).
    // This is the same as in Colu Local Network contract.
    uint256 public constant TOKEN_DECIMALS = 10 ** 18;

    // Additional Lockup Allocation Pool
    uint256 public constant ALAP = 40701333592592592592614116;

    // Maximum number of tokens in circulation: 1.5 trillion.
    uint256 public constant MAX_TOKENS = 15 * 10 ** 8 * TOKEN_DECIMALS + ALAP;

    // Maximum tokens offered in the sale (35%) + ALAP.
    uint256 public constant MAX_TOKENS_SOLD = 525 * 10 ** 6 * TOKEN_DECIMALS + ALAP;

    // Maximum tokens offered in the presale (from the initial 35% offered tokens) + ALAP.
    uint256 public constant MAX_PRESALE_TOKENS_SOLD = 2625 * 10 ** 5 * TOKEN_DECIMALS + ALAP;

    // Tokens allocated for Community pool (30%).
    uint256 public constant COMMUNITY_POOL = 45 * 10 ** 7 * TOKEN_DECIMALS;

    // Tokens allocated for Future development pool (29%).
    uint256 public constant FUTURE_DEVELOPMENT_POOL = 435 * 10 ** 6 * TOKEN_DECIMALS;

    // Tokens allocated for Stakeholdes pool (6%).
    uint256 public constant STAKEHOLDERS_POOL = 9 * 10 ** 7 * TOKEN_DECIMALS;

    // CLN to ETH ratio.
    uint256 public constant CLN_PER_ETH = 8600;

    // Sale start, end blocks (time ranges)
    uint256 public constant SALE_DURATION = 4 days;
    uint256 public startTime;
    uint256 public endTime;

    // Amount of tokens sold until now in the sale.
    uint256 public tokensSold = 0;

    // Amount of tokens sold until now in the presale.
    uint256 public presaleTokensSold = 0;

    // Accumulated amount each participant has contributed so far in the sale (in WEI).
    mapping (address => uint256) public participationHistory;

    // Accumulated amount each participant have contributed so far in the presale.
    mapping (address => uint256) public participationPresaleHistory;

    // Maximum amount that each particular is allowed to contribute (in ETH-WEI).
    // Defaults to zero. Serving as a functional whitelist. 
    mapping (address => uint256) public participationCaps;

    // Maximum amount ANYONE is currently allowed to contribute. Set to max uint256 so no limitation other than personal participationCaps.
    uint256 public hardParticipationCap = uint256(-1);

    // initialization of the contract, splitted from the constructor to avoid gas block limit.
    bool public initialized = false;

    // Vesting plan structure for presale
    struct VestingPlan {
        uint256 startOffset;
        uint256 cliffOffset;
        uint256 endOffset;
        uint256 installmentLength;
        uint8 alapPercent;
    }

    // Vesting plans for presale
    VestingPlan[] public vestingPlans;

    // Each token that is sent from the ColuLocalNetworkSale is considered as issued.
    event TokensIssued(address indexed to, uint256 tokens);

    /// @dev Reverts if called not before the sale.
    modifier onlyBeforeSale() {
        if (now >= startTime) {
            revert();
        }

        _;
    }

    /// @dev Reverts if called not during the sale.
    modifier onlyDuringSale() {
        if (tokensSold >= MAX_TOKENS_SOLD || now < startTime || now >= endTime) {
            revert();
        }

        _;
    }

    /// @dev Reverts if called before the sale ends.
    modifier onlyAfterSale() {
        if (!(tokensSold >= MAX_TOKENS_SOLD || now >= endTime)) {
            revert();
        }

        _;
    }

    /// @dev Reverts if called before the sale is initialized.
    modifier notInitialized() {
        if (initialized) {
            revert();
        }

        _;
    }


    /// @dev Reverts if called after the sale is initialized.
    modifier isInitialized() {
        if (!initialized) {
            revert();
        }

        _;
    }

    /// @dev Constructor sets the sale addresses and start time.
    /// @param _owner address The address of this contract owner.
    /// @param _fundingRecipient address The address of the funding recipient.
    /// @param _communityPoolAddress address The address of the community pool.
    /// @param _futureDevelopmentPoolAddress address The address of the future development pool.
    /// @param _stakeholdersPoolAddress address The address of the team pool.
    /// @param _startTime uint256 The start time of the token sale.
    function ColuLocalNetworkSale(address _owner,
        address _fundingRecipient,
        address _communityPoolAddress,
        address _futureDevelopmentPoolAddress,
        address _stakeholdersPoolAddress,
        uint256 _startTime) public {
        require(_owner != address(0));
        require(_fundingRecipient != address(0));
        require(_communityPoolAddress != address(0));
        require(_futureDevelopmentPoolAddress != address(0));
        require(_stakeholdersPoolAddress != address(0));
        require(_startTime > now);

        owner = _owner;
        fundingRecipient = _fundingRecipient;
        communityPoolAddress = _communityPoolAddress;
        futureDevelopmentPoolAddress = _futureDevelopmentPoolAddress;
        stakeholdersPoolAddress = _stakeholdersPoolAddress;
        startTime = _startTime;
        endTime = startTime + SALE_DURATION;
    }

    /// @dev Initialize the sale conditions.
    function initialize() public onlyOwner notInitialized {
        initialized = true;

        uint256 months = 1 years / 12;

        vestingPlans.push(VestingPlan(0, 0, 1, 1, 0));
        vestingPlans.push(VestingPlan(0, 0, 6 * months, 1 * months, 4));
        vestingPlans.push(VestingPlan(0, 0, 1 years, 1 * months, 12));
        vestingPlans.push(VestingPlan(0, 0, 2 years, 1 * months, 26));
        vestingPlans.push(VestingPlan(0, 0, 3 years, 1 * months, 35));

        // Deploy new ColuLocalNetwork contract.
        cln = new ColuLocalNetwork(MAX_TOKENS);

        // Deploy new VestingTrustee contract.
        trustee = new VestingTrustee(cln);

        // allocate pool tokens:
        // Issue the remaining tokens to designated pools.
        require(transferTokens(communityPoolAddress, COMMUNITY_POOL));

        // stakeholdersPoolAddress will create its own vesting trusts.
        require(transferTokens(stakeholdersPoolAddress, STAKEHOLDERS_POOL));
    }

    /// @dev Allocate tokens to presale participant according to its vesting plan and invesment value.
    /// @param _recipient address The presale participant address to recieve the tokens.
    /// @param _etherValue uint256 The invesment value (in ETH).
    /// @param _vestingPlanIndex uint8 The vesting plan index.
    function presaleAllocation(address _recipient, uint256 _etherValue, uint8 _vestingPlanIndex) external onlyOwner onlyBeforeSale isInitialized {
        require(_recipient != address(0));
        require(_vestingPlanIndex < vestingPlans.length);

        // Calculate plan and token amount.
        VestingPlan memory plan = vestingPlans[_vestingPlanIndex];
        uint256 tokensAndALAPPerEth = CLN_PER_ETH.mul(SafeMath.add(100, plan.alapPercent)).div(100);

        uint256 tokensLeftInPreSale = MAX_PRESALE_TOKENS_SOLD.sub(presaleTokensSold);
        uint256 weiLeftInSale = tokensLeftInPreSale.div(tokensAndALAPPerEth);
        uint256 weiToParticipate = SafeMath.min256(_etherValue, weiLeftInSale);
        require(weiToParticipate > 0);
        participationPresaleHistory[msg.sender] = participationPresaleHistory[msg.sender].add(weiToParticipate);
        uint256 tokensToTransfer = weiToParticipate.mul(tokensAndALAPPerEth);
        presaleTokensSold = presaleTokensSold.add(tokensToTransfer);
        tokensSold = tokensSold.add(tokensToTransfer);

        // Transfer tokens to trustee and create grant.
        grant(_recipient, tokensToTransfer, startTime.add(plan.startOffset), startTime.add(plan.cliffOffset),
            startTime.add(plan.endOffset), plan.installmentLength, false);
    }

    /// @dev Add a list of participants to a capped participation tier.
    /// @param _participants address[] The list of participant addresses.
    /// @param _cap uint256 The cap amount (in ETH-WEI).
    function setParticipationCap(address[] _participants, uint256 _cap) external onlyOwner isInitialized {
        for (uint i = 0; i < _participants.length; i++) {
            participationCaps[_participants[i]] = _cap;
        }
    }

    /// @dev Set hard participation cap for all participants.
    /// @param _cap uint256 The hard cap amount.
    function setHardParticipationCap(uint256 _cap) external onlyOwner isInitialized {
        require(_cap > 0);

        hardParticipationCap = _cap;
    }

    /// @dev Fallback function that will delegate the request to participate().
    function () external payable onlyDuringSale isInitialized {
        participate(msg.sender);
    }

    /// @dev Create and sell tokens to the caller.
    /// @param _recipient address The address of the recipient receiving the tokens.
    function participate(address _recipient) public payable onlyDuringSale isInitialized {
        require(_recipient != address(0));

        // Enforce participation cap (in WEI received).
        uint256 weiAlreadyParticipated = participationHistory[_recipient];
        uint256 participationCap = SafeMath.min256(participationCaps[_recipient], hardParticipationCap);
        uint256 cappedWeiReceived = SafeMath.min256(msg.value, participationCap.sub(weiAlreadyParticipated));
        require(cappedWeiReceived > 0);

        // Accept funds and transfer to funding recipient.
        uint256 tokensLeftInSale = MAX_TOKENS_SOLD.sub(tokensSold);
        uint256 weiLeftInSale = tokensLeftInSale.div(CLN_PER_ETH);
        uint256 weiToParticipate = SafeMath.min256(cappedWeiReceived, weiLeftInSale);
        participationHistory[_recipient] = weiAlreadyParticipated.add(weiToParticipate);
        fundingRecipient.transfer(weiToParticipate);

        // Transfer tokens to recipient.
        uint256 tokensToTransfer = weiToParticipate.mul(CLN_PER_ETH);
        if (tokensLeftInSale.sub(tokensToTransfer) < CLN_PER_ETH) {
            // If purchase would cause less than CLN_PER_ETH tokens to be left then nobody could ever buy them.
            // So, gift them to the last buyer.
            tokensToTransfer = tokensLeftInSale;
        }
        tokensSold = tokensSold.add(tokensToTransfer);
        require(transferTokens(_recipient, tokensToTransfer));

        // Partial refund if full participation not possible
        // e.g. due to cap being reached.
        uint256 refund = msg.value.sub(weiToParticipate);
        if (refund > 0) {
            msg.sender.transfer(refund);
        }
    }

    /// @dev Finalizes the token sale event: make future development pool grant (lockup) and make token transfarable.
    function finalize() external onlyAfterSale onlyOwner isInitialized {
        if (cln.isTransferable()) {
            revert();
        }

        // Add unsold token to the future development pool grant (lockup).
        uint256 tokensLeftInSale = MAX_TOKENS_SOLD.sub(tokensSold);
        uint256 futureDevelopmentPool = FUTURE_DEVELOPMENT_POOL.add(tokensLeftInSale);
        // Future Development Pool is locked for 3 years.
        grant(futureDevelopmentPoolAddress, futureDevelopmentPool, startTime, startTime.add(3 years),
            startTime.add(3 years), 1 days, false);

        // Make tokens Transferable, end the sale!.
        cln.makeTokensTransferable();
    }

    function grant(address _grantee, uint256 _amount, uint256 _start, uint256 _cliff, uint256 _end,
        uint256 _installmentLength, bool _revokable) private {
        // bytes4 grantSig = bytes4(keccak256("grant(address,uint256,uint256,uint256,uint256,bool)"));
        bytes4 grantSig = 0x5ee7e96d;
        // 6 arguments of size 32
        uint256 argsSize = 6 * 32;
        // sig + arguments size
        uint256 dataSize = 4 + argsSize;

        bytes memory m_data = new bytes(dataSize);

        assembly {
            // Add the signature first to memory
            mstore(add(m_data, 0x20), grantSig)
            // Add the parameters
            mstore(add(m_data, 0x24), _grantee)
            mstore(add(m_data, 0x44), _start)
            mstore(add(m_data, 0x64), _cliff)
            mstore(add(m_data, 0x84), _end)
            mstore(add(m_data, 0xa4), _installmentLength)
            mstore(add(m_data, 0xc4), _revokable)
        }

        require(transferTokens(trustee, _amount, m_data));
    }

    /// @dev Transfer tokens from the sale contract to a recipient.
    /// @param _recipient address The address of the recipient.
    /// @param _tokens uint256 The amount of tokens to transfer.
    function transferTokens(address _recipient, uint256 _tokens) private returns (bool ans) {
        ans = cln.transfer(_recipient, _tokens);
        if (ans) {
            TokensIssued(_recipient, _tokens);
        }
    }

    /// @dev Transfer tokens from the sale contract to a recipient.
    /// @param _recipient address The address of the recipient.
    /// @param _tokens uint256 The amount of tokens to transfer.
    /// @param _data bytes data to send to receiver if it is a contract.
    function transferTokens(address _recipient, uint256 _tokens, bytes _data) private returns (bool ans) {
        // Request Colu Local Network contract to transfer the requested tokens for the buyer.
        ans = cln.transferAndCall(_recipient, _tokens, _data);
        if (ans) {
            TokensIssued(_recipient, _tokens);
        }
    }

    /// @dev Requests to transfer control of the Colu Local Network contract to a new owner.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    ///
    /// NOTE:
    ///   1. The new owner will need to call Colu Local Network contract's acceptOwnership directly in order to accept the ownership.
    ///   2. Calling this method during the token sale will prevent the token sale to continue, since only the owner of
    ///      the Colu Local Network contract can transfer tokens during the sale.
    function requestColuLocalNetworkOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
        cln.requestOwnershipTransfer(_newOwnerCandidate);
    }

    /// @dev Accepts new ownership on behalf of the Colu Local Network contract.
    // This can be used by the sale contract itself to claim back ownership of the Colu Local Network contract.
    function acceptColuLocalNetworkOwnership() external onlyOwner {
        cln.acceptOwnership();
    }

    /// @dev Requests to transfer control of the VestingTrustee contract to a new owner.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    ///
    /// NOTE:
    ///   1. The new owner will need to call trustee contract's acceptOwnership directly in order to accept the ownership.
    ///   2. Calling this method during the token sale will prevent the token sale from alocation presale grunts add finalize, since only the owner of
    ///      the trustee contract can create grunts needed in the presaleAlocation add finalize methods.
    function requestVestingTrusteeOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
        trustee.requestOwnershipTransfer(_newOwnerCandidate);
    }

    /// @dev Accepts new ownership on behalf of the VestingTrustee contract.
    /// This can be used by the token sale contract itself to claim back ownership of the VestingTrustee contract.
    function acceptVestingTrusteeOwnership() external onlyOwner {
        trustee.acceptOwnership();
    }
}
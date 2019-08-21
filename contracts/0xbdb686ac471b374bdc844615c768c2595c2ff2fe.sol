pragma solidity ^0.4.17;


/**
 * Math operations with safety checks
 */
library SafeMathForBoost {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      revert();
    }
  }
}


contract Boost {
    using SafeMathForBoost for uint256;

    string public name = "Boost";         // トークン名
    uint8 public decimals = 0;            // 小数点以下何桁か
    string public symbol = "BST";         // トークンの単位
    uint256 public totalSupply = 100000000;  // 総供給量

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint256 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint256 value;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);

    /// @notice constructor
    function Boost() public {
        balances[msg.sender].push(Checkpoint({
            fromBlock:block.number,
            value:totalSupply
        }));
    }

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {

        // The standard ERC 20 transferFrom functionality
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);

        doTransfer(_from, _to, _amount);
        return true;
    }

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) public returns (bool success) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _blockNumber The block number when the balance is queried
    /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint) {
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            return 0;
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(address _from, address _to, uint _amount) internal {

        // Do not allow transfer to 0x0 or the token contract itself
        require((_to != 0) && (_to != address(this)) && (_amount != 0));

        // First update the balance array with the new value for the address
        // sending the tokens
        var previousBalanceFrom = balanceOfAt(_from, block.number);
        updateValueAtNow(balances[_from], previousBalanceFrom.sub(_amount));

        // Then update the balance array with the new value for the address
        // receiving the tokens
        var previousBalanceTo = balanceOfAt(_to, block.number);
        updateValueAtNow(balances[_to], previousBalanceTo.add(_amount));

        // An event to make the transfer easy to find on the blockchain
        Transfer(_from, _to, _amount);

    }

    /// @dev `getValueAt` retrieves the number of tokens at a given block number
    /// @param checkpoints The history of values being queried
    /// @param _block The block number to retrieve the value at
    /// @return The number of tokens being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint _block) internal view  returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length - 1].fromBlock)
            return checkpoints[checkpoints.length - 1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length - 1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return checkpoints[min].value;
    }

    /// @dev `updateValueAtNow` used to update the `balances` map and the
    ///  `totalSupplyHistory`
    /// @param checkpoints The history of data being updated
    /// @param _value The new number of tokens
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = block.number;
            newCheckPoint.value = _value;
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length - 1];
            oldCheckPoint.value = _value;
        }
    }

    /// @dev Helper function to return a min between the two uints
    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }
}


// @title EtherContainer to store ether for investor to withdraw
contract BoostContainer {
    using SafeMathForBoost for uint256;

    // multiSigAddress
    address public multiSigAddress;
    bool public paused = false;

    // Boost token
    Boost public boost;

    // Array about ether information per month for dividend
    InfoForDeposit[] public arrayInfoForDeposit;

    // Mapping to check this account has already withdrawn
    mapping(address => uint256) public mapCompletionNumberForWithdraw;

    // Event
    event LogDepositForDividend(uint256 blockNumber, uint256 etherAountForDividend);
    event LogWithdrawal(address indexed tokenHolder, uint256 etherValue);
    event LogPause();
    event LogUnpause();

    // Struct of deposit infomation for dividend
    struct InfoForDeposit {
        uint256 blockNumber;
        uint256 depositedEther;
    }

    // Check this msg.sender has right to withdraw
    modifier isNotCompletedForWithdrawal(address _address) {
        require(mapCompletionNumberForWithdraw[_address] != arrayInfoForDeposit.length);
        _;
    }

    // Check whether msg.sender is multiSig or not
    modifier onlyMultiSig() {
        require(msg.sender == multiSigAddress);
        _;
    }

    // Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    // Modifier to make a function callable only when the contract is paused.
    modifier whenPaused() {
        require(paused);
        _;
    }

    /// @dev constructor
    /// @param _boostAddress The address of boost token
    /// @param _multiSigAddress The address of multiSigWallet to send ether
    function BoostContainer(address _boostAddress, address _multiSigAddress) public {
        boost = Boost(_boostAddress);
        multiSigAddress = _multiSigAddress;
    }

    /// @dev Deposit `msg.value` in arrayInfoForDeposit
    /// @param _blockNumber The blockNumber to specify the token amount that each address has at this blockNumber
    function depositForDividend(uint256 _blockNumber) public payable onlyMultiSig whenNotPaused {
        require(msg.value > 0);

        arrayInfoForDeposit.push(InfoForDeposit({blockNumber:_blockNumber, depositedEther:msg.value}));

        LogDepositForDividend(_blockNumber, msg.value);
    }

    /// @dev Withdraw dividendEther
    function withdraw() public isNotCompletedForWithdrawal(msg.sender) whenNotPaused {

        // get withdrawAmount that msg.sender can withdraw
        uint256 withdrawAmount = getWithdrawValue(msg.sender);

        require(withdrawAmount > 0);

        // set the arrayInfoForDeposit.length to mapCompletionNumberForWithdraw
        mapCompletionNumberForWithdraw[msg.sender] = arrayInfoForDeposit.length;

        // execute transfer
        msg.sender.transfer(withdrawAmount);

        // send event
        LogWithdrawal(msg.sender, withdrawAmount);
    }

    /// @dev Change multiSigAddress
    /// @param _address MultiSigAddress
    function changeMultiSigAddress(address _address) public onlyMultiSig {
        require(_address != address(0));
        multiSigAddress = _address;
    }

    /// @dev Get the row length of arrayInfoForDeposit
    /// @return The length of arrayInfoForDeposit
    function getArrayInfoForDepositCount() public view returns (uint256 result) {
        return arrayInfoForDeposit.length;
    }

    /// @dev Get withdraw value
    /// @param _address The account that has this information
    /// @return WithdrawAmount that account can withdraw
    function getWithdrawValue(address _address) public view returns (uint256 withdrawAmount) {
        uint256 validNumber = mapCompletionNumberForWithdraw[_address];
        uint256 blockNumber;
        uint256 depositedEther;
        uint256 tokenAmount;

        for (uint256 i = 0; i < arrayInfoForDeposit.length; i++) {
            if (i < validNumber) {
                continue;
            }

            // get blockNumber and depositedEther based on the validNumber
            blockNumber = arrayInfoForDeposit[i].blockNumber;
            depositedEther = arrayInfoForDeposit[i].depositedEther;

            // get the amount of Boost token that msg.sender had based on blockNumber
            tokenAmount = boost.balanceOfAt(_address, blockNumber);

            // tokenAmount * depositedEther / totalSupply(100,000,000)
            withdrawAmount = withdrawAmount.add(tokenAmount.mul(depositedEther).div(boost.totalSupply()));
        }
    }

    /// @dev destroy this contract to return ether to multiSigAddress stored in this contract
    function destroy() public onlyMultiSig whenPaused {
        selfdestruct(multiSigAddress);
    }

    /// @dev called by the multiSigWallet to pause, triggers stopped state
    function pause() public onlyMultiSig whenNotPaused {
        paused = true;
        LogPause();
    }

    /// @dev called by the multiSigWallet to unpause, returns to normal state
    function unpause() public onlyMultiSig whenPaused {
        paused = false;
        LogUnpause();
    }

    /// @dev send profit to investor when stack depth happened. This require multisig and paused state
    /// @param _address The account receives eth
    /// @param _amount ether value that investor will receive
    function sendProfit(address _address, uint256 _amount) public isNotCompletedForWithdrawal(_address) onlyMultiSig whenPaused {
        require(_address != address(0));
        require(_amount > 0);

        mapCompletionNumberForWithdraw[_address] = arrayInfoForDeposit.length;

        // execute transfer
        _address.transfer(_amount);

        // send event
        LogWithdrawal(_address, _amount);
    }
}
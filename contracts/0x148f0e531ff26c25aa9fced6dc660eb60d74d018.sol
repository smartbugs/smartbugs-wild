pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMathForBoost {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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


contract Boost {
    using SafeMathForBoost for uint256;

    string public name = "Boost";
    uint8 public decimals = 0;
    string public symbol = "BST";
    uint256 public totalSupply = 100000000;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the value
    struct  Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint256 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint256 value;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);

    /// @dev constructor
    function Boost() public {
        balances[msg.sender].push(Checkpoint({
            fromBlock:block.number,
            value:totalSupply
        }));
    }

    /// @dev Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    /// @dev Send `_amount` tokens to `_to` from `_from` on the condition it
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

    /// @dev _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @dev `msg.sender` approves `_spender` to spend `_amount` tokens on
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


// @title Boost token interface to use during the ICO
contract BoostCrowdsale is Ownable {
    using SafeMathForBoost for uint256;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // rate use during the ico
    uint256 public rate;

    // address of multiSigWallet to store ether
    address public wallet;

    // Boost token
    Boost public boost;

    // cap
    uint256 public cap;

    // amount of raised money in wei
    uint256 public weiRaised;

    // minimun amount
    uint256 public minimumAmount = 0.1 ether;

    // amount of sold token
    uint256 public soldAmount;

    // isFinalised flag
    bool public isFinalized = false;

    /**
    * event for token purchase logging
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);

    // event for finalized
    event Finalized();

    // @dev constructor
    function BoostCrowdsale(uint256 _startTime, uint256 _endTime, address _boostAddress, uint256 _rate, address _wallet, uint256 _cap) public {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_boostAddress != address(0));
        require(_rate > 0);
        require(_wallet != address(0));
        require(_cap > 0);

        startTime = _startTime;
        endTime = _endTime;
        boost = Boost(_boostAddress);
        rate = _rate;
        wallet = _wallet;
        cap = _cap;
    }

    /**
    * @dev Must be called after crowdsale ends, to do some extra finalization
    * work. Calls the contract's finalization function.
    */
    function finalize() public onlyOwner {
        require(!isFinalized);
        require(hasEnded());

        finalization();
        Finalized();

        isFinalized = true;
    }

    // @dev fallback function to exchange the ether for Boost token
    function() public payable {
        uint256 weiAmount = msg.value;

        // calc token amount
        uint256 tokens = getTokenAmount(weiAmount);

        require(validPurchase(tokens));

        // update state
        weiRaised = weiRaised.add(weiAmount);
        soldAmount = soldAmount.add(tokens);

        // transfer boostToken from owner to msg.sender
        boost.transfer(msg.sender, tokens);
        TokenPurchase(msg.sender, weiAmount, tokens);

        forwardFunds();
    }

    // @dev return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        bool overPeriod = now > endTime;
        bool underPurchasableAmount = getPurchasableAmount() < 10000;
        return overPeriod || underPurchasableAmount;
    }

    // @dev return the amount of token that user can purchase
    function getPurchasableAmount() public view returns (uint256) {
        return boost.balanceOf(this);
    }

    // @dev return the amount of ether that user can send in order to purchase token
    function getSendableEther() public view returns (uint256) {
        return boost.balanceOf(this).mul(10 ** 18).div(rate);
    }

    // @dev return the amount of token that msg.sender can receive based on the amount of ether that msg.sender sent
    function getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(rate).div(10 ** 18);
    }

    // @dev send ether to the fund collection wallet
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // @dev finalization
    function finalization() internal {
        if (boost.balanceOf(this) > 0) {
            require(boost.transfer(owner, boost.balanceOf(this)));
        }
    }

    // @dev return true if the transaction can buy tokens
    function validPurchase(uint256 _tokens) internal view returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool moreThanOrEqualToMinimumAmount = msg.value >= minimumAmount;
        bool validPurchasableAmount = cap >= soldAmount.add(_tokens);
        return withinPeriod && moreThanOrEqualToMinimumAmount && validPurchasableAmount;
    }
}
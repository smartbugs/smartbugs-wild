contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    uint256 constant MAX_UINT256 = 2**256 - 1;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract ERC223ReceivingContract {
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract ERC223Interface {
    function transfer(address _to, uint _value) public returns (bool success);
    function transfer(address _to, uint _value, bytes _data) public returns (bool success);
    event ERC223Transfer(address indexed _from, address indexed _to, uint _value, bytes _data);
}

contract HumanStandardToken is ERC223Interface, StandardToken {
    using SafeMath for uint256;

    /* approveAndCall */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed when one does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

    /* ERC223 */
    function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
      // Standard function transfer similar to ERC20 transfer with no _data .
      // Added due to backwards compatibility reasons .
      uint codeLength;

      assembly {
        // Retrieve the size of the code on target address, this needs assembly .
        codeLength := extcodesize(_to)
      }

      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      if(codeLength>0) {
        ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
      }
      Transfer(msg.sender, _to, _value);
      ERC223Transfer(msg.sender, _to, _value, _data);
      return true;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        uint codeLength;
        bytes memory empty;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        Transfer(msg.sender, _to, _value);
        ERC223Transfer(msg.sender, _to, _value, empty);
        return true;
    }
}

library SafeMath {
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

contract LunetToken is HumanStandardToken {
    using SafeMath for uint256;

    string public name = "Lunet";
    string public symbol= "LUNET";
    uint8 public decimals = 18;

    uint256 public tokenCreationCap = 1000000000000000000000000000; // 1 billion LUNETS
    uint256 public lunetReserve = 50000000000000000000000000; // 50 million LUNETS - 5% of LUNETS

    event CreateLUNETS(address indexed _to, uint256 _value, uint256 _timestamp);
    event Staked(address indexed _from, uint256 _value, uint256 _timestamp);
    event Withdraw(address indexed _from, uint256 _value, uint256 _timestamp);

    struct Stake {
      uint256 amount;
      uint256 timestamp;
    }

    mapping (address => Stake) public stakes;

    function LunetToken() public {
       totalSupply = lunetReserve;
       balances[msg.sender] = lunetReserve;
       CreateLUNETS(msg.sender, lunetReserve, now);
    }

    function stake() external payable {
      require(msg.value > 0);

      // get stake
      Stake storage stake = stakes[msg.sender];

      uint256 amount = stake.amount.add(msg.value);

      // update stake
      stake.amount = amount;
      stake.timestamp = now;

      // fire off stake event
      Staked(msg.sender, amount, now);
    }

    function withdraw() public {
      // get stake
      Stake storage stake = stakes[msg.sender];

      // check the stake is non-zero
      require(stake.amount > 0);

      // copy amount
      uint256 amount = stake.amount;

      // reset stake amount
      stake.amount = 0;

      // send amount to staker
      if (!msg.sender.send(amount)) revert();

      // fire off withdraw event
      Withdraw(msg.sender, amount, now);
    }

    function claim() public {
      // get reward
      uint256 reward = getReward(msg.sender);

      // check that the reward is non-zero
      if (reward > 0) {
        // reset the timestamp
        Stake storage stake = stakes[msg.sender];
        stake.timestamp = now;

        uint256 checkedSupply = totalSupply.add(reward);
        if (tokenCreationCap < checkedSupply) revert();

        // update totalSupply of LUNETS
        totalSupply = checkedSupply;

        // update LUNETS balance
        balances[msg.sender] += reward;

        // create LUNETS
        CreateLUNETS(msg.sender, reward, now);
      }

    }

    function claimAndWithdraw() external {
      claim();
      withdraw();
    }

    function getReward(address staker) public constant returns (uint256) {
      // get stake
      Stake memory stake = stakes[staker];

      // need greater precision
      uint256 precision = 100000;

      // get difference between now and initial stake timestamp
      uint256 difference = now.sub(stake.timestamp).mul(precision);

      // get the total number of days ETH has been locked up
      uint totalDays = difference.div(1 days);

      // calculate reward
      uint256 reward = stake.amount.mul(totalDays).div(precision);

      return reward;
    }

    function getStake(address staker) external constant returns (uint256, uint256) {
      Stake memory stake = stakes[staker];
      return (stake.amount, stake.timestamp);
    }
}
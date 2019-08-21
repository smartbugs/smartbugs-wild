pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
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
// accepted from zeppelin-solidity https://github.com/OpenZeppelin/zeppelin-solidity
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address _who) public constant returns (uint);
  function allowance(address _owner, address _spender) public constant returns (uint);

  function transfer(address _to, uint _value) public returns (bool ok);
  function transferFrom(address _from, address _to, uint _value) public returns (bool ok);
  function approve(address _spender, uint _value) public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}
contract Haltable is Ownable {

    // @dev To Halt in Emergency Condition
    bool public halted = false;
    //empty contructor
    function Haltable() public {}

    // @dev Use this as function modifier that should not execute if contract state Halted
    modifier stopIfHalted {
      require(!halted);
      _;
    }

    // @dev Use this as function modifier that should execute only if contract state Halted
    modifier runIfHalted{
      require(halted);
      _;
    }

    // @dev called by only owner in case of any emergecy situation
    function halt() onlyOwner stopIfHalted public {
        halted = true;
    }
    // @dev called by only owner to stop the emergency situation
    function unHalt() onlyOwner runIfHalted public {
        halted = false;
    }
}

contract iCapToken is ERC20,SafeMath,Haltable {

    //flag to determine if address is for real contract or not
    bool public isiCapToken = false;

    //crowdsale start time
    uint256 public start;
    //crowdsale end time
    uint256 public end;
    //max token supply
    uint256 public maxTokenSupply = 500000000 ether;
    //number of tokens per ether purchase
    uint256 public perEtherTokens = 208;
    //address of multisig
    address public multisig;
    //address of teamIncentive
    address public unspentWalletAddress;
    //Is crowdsale finalized
    bool public isFinalized = false;

    //Token related information
    string public constant name = "integratedCAPITAL";
    string public constant symbol = "iCAP";
    uint256 public constant decimals = 18; // decimal places

    //mapping of token balances
    mapping (address => uint256) balances;
    //mapping of allowed address for each address with tranfer limit
    mapping (address => mapping (address => uint256)) allowed;
    //mapping of allowed address for each address with burnable limit
    mapping (address => mapping (address => uint256)) allowedToBurn;

    event Mint(address indexed to, uint256 amount);
    event Burn(address owner,uint256 _value);
    event ApproveBurner(address owner, address canBurn, uint256 value);
    event BurnFrom(address _from,uint256 _value);
    
    function iCapToken(uint256 _start,uint256 _end) public {
        totalSupply = 500000000 ether;
        balances[msg.sender] = totalSupply;
        start = safeAdd(now, _start);
        end = safeAdd(now, _end);
        isiCapToken = true;
        emit Transfer(address(0), msg.sender,totalSupply);
    }

    //'owner' can set start time of funding
    // @param _start Starting time of funding
    function setFundingStartTime(uint256 _start) public stopIfHalted onlyOwner {
        start = now + _start;
    }

    //'owner' can set end time of funding
    // @param _end Ending time of funding
    function setFundingEndTime(uint256 _end) public stopIfHalted onlyOwner {
        end = now + _end;
    }

    //'owner' can set number of tokens per Ether
    // @param _perEtherTokens Tokens per Ether in funding
    function setPerEtherTokens(uint256 _perEtherTokens) public onlyOwner {
        perEtherTokens = _perEtherTokens;
    }

    //Owner can Set Multisig wallet
    //@ param _multisig address of Multisig wallet.
    function setMultisigWallet(address _multisig) onlyOwner public {
        require(_multisig != 0);
        multisig = _multisig;
    }

    //Owner can Set unspent wallet address
    //@ param _unspentWalletAddress address of unspent wallet.
    function setUnspentWalletAddress(address _unspentWalletAddress) onlyOwner public {
        require(_unspentWalletAddress != 0);
        unspentWalletAddress = _unspentWalletAddress;
    }

    //fallback function to accept ethers
    function() payable stopIfHalted public {
        //Check crowdsale is running or not
        require(now >= start && now <= end);
        //not allow to invest with less then 0.
        require(msg.value > 0);
        //Unspent wallet needed to be configured
        require(unspentWalletAddress != address(0));

        //Calculate tokens
        uint256 calculatedTokens = safeMul(msg.value, perEtherTokens);

        //Check tokens available to assign
        require(calculatedTokens < balances[unspentWalletAddress]);

        //call internal method to assign tokens
        assignTokens(msg.sender, calculatedTokens);
    }

    // Function will transfer the tokens to investor's address
    // Common function code for Early Investor and Crowdsale Investor
    function assignTokens(address investor, uint256 tokens) internal {
        // Debit tokens from unspent wallet
        balances[unspentWalletAddress] = safeSub(balances[unspentWalletAddress], tokens);

        // Assign tokens to the sender
        balances[investor] = safeAdd(balances[investor], tokens);

        // Finally token transfered to investor, log the creation event
        Transfer(unspentWalletAddress, investor, tokens);
    }

    //Finalize crowdsale
    function finalize() onlyOwner public {
        // Finalize after crowdsale end
        require(now > end);
        // Check already finalized and multisig set or not
        require(!isFinalized && multisig != address(0));
        // Set crowdsale finalized to true
        isFinalized = true;
        require(multisig.send(address(this).balance));
    }

    // @param _who The address of the investor to check balance
    // @return balance tokens of investor address
    function balanceOf(address _who) public constant returns (uint) {
        return balances[_who];
    }

    // @param _owner The address of the account owning tokens
    // @param _spender The address of the account able to transfer the tokens
    // @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint) {
        return allowed[_owner][_spender];
    }

    // @param _owner The address of the account owning tokens
    // @param _spender The address of the account able to transfer the tokens
    // @return Amount of remaining tokens allowed to spent
    function allowanceToBurn(address _owner, address _spender) public constant returns (uint) {
        return allowedToBurn[_owner][_spender];
    }

    //  Transfer `value` iCap tokens from sender's account
    // `msg.sender` to provided account address `to`.
    // @param _to The address of the recipient
    // @param _value The number of iCap tokens to transfer
    // @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) public returns (bool ok) {
        //validate receiver address and value.Not allow 0 value
        require(_to != 0 && _value > 0);
        uint256 senderBalance = balances[msg.sender];
        //Check sender have enough balance
        require(senderBalance >= _value);
        senderBalance = safeSub(senderBalance, _value);
        balances[msg.sender] = senderBalance;
        balances[_to] = safeAdd(balances[_to],_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    //  Transfer `value` iCap tokens from sender 'from'
    // to provided account address `to`.
    // @param from The address of the sender
    // @param to The address of the recipient
    // @param value The number of iCap to transfer
    // @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint _value) public returns (bool ok) {
        //validate _from,_to address and _value(Not allow with 0)
        require(_from != 0 && _to != 0 && _value > 0);
        //Check amount is approved by the owner for spender to spent and owner have enough balances
        require(allowed[_from][msg.sender] >= _value && balances[_from] >= _value);
        balances[_from] = safeSub(balances[_from],_value);
        balances[_to] = safeAdd(balances[_to],_value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);
        Transfer(_from, _to, _value);
        return true;
    }

    //  `msg.sender` approves `spender` to spend `value` tokens
    // @param spender The address of the account able to transfer the tokens
    // @param value The amount of wei to be approved for transfer
    // @return Whether the approval was successful or not
    function approve(address _spender, uint _value) public returns (bool ok) {
        //validate _spender address
        require(_spender != 0);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    //  Mint `amount` iCap tokens
    // `msg.sender` to provided account and amount.
    // @param _account The address of the mint token recipient
    // @param _amount The number of iCap tokens to mint
    // @return Whether the Mint was successful or not
    function mint(address _account, uint256 _amount) public onlyOwner stopIfHalted returns (bool ok) {
        require(_account != 0);
        totalSupply = safeAdd(totalSupply,_amount);
        balances[_account] = safeAdd(balances[_account],_amount);
        emit Mint(_account, _amount);
        emit Transfer(address(0), _account, _amount);
        return true;
    }

    //  `msg.sender` approves `_canBurn` to burn `value` tokens
    // @param _canBurn The address of the account able to burn the tokens
    // @param _value The amount of wei to be approved for burn
    // @return Whether the approval was successful or not
    function approveForBurn(address _canBurn, uint _value) public returns (bool ok) {
        //validate _spender address
        require(_canBurn != 0);
        allowedToBurn[msg.sender][_canBurn] = _value;
        ApproveBurner(msg.sender, _canBurn, _value);
        return true;
    }

    //  Burn `value` iCap tokens from sender's account
    // `msg.sender` to provided _value.
    // @param _value The number of iCap tokens to destroy
    // @return Whether the Burn was successful or not
    function burn(uint _value) public returns (bool ok) {
        //validate receiver address and value.Now allow 0 value
        require(_value > 0);
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= _value);
        senderBalance = safeSub(senderBalance, _value);
        balances[msg.sender] = senderBalance;
        totalSupply = safeSub(totalSupply,_value);
        Burn(msg.sender, _value);
        return true;
    }

    //  Burn `value` iCap tokens from sender 'from'
    // to provided account address `to`.
    // @param from The address of the burner
    // @param to The address of the token holder from token to burn
    // @param value The number of iCap to burn
    // @return Whether the transfer was successful or not
    function burnFrom(address _from, uint _value) public returns (bool ok) {
        //validate _from,_to address and _value(Now allow with 0)
        require(_from != 0 && _value > 0);
        //Check amount is approved by the owner to burn and owner have enough balances
        require(allowedToBurn[_from][msg.sender] >= _value && balances[_from] >= _value);
        balances[_from] = safeSub(balances[_from],_value);
        totalSupply = safeSub(totalSupply,_value);
        allowedToBurn[_from][msg.sender] = safeSub(allowedToBurn[_from][msg.sender],_value);
        BurnFrom(_from, _value);
        return true;
    }
}
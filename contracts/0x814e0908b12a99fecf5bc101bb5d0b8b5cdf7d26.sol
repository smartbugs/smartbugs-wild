pragma solidity ^0.4.18;

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
}

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
    owner = newOwner;
    OwnershipTransferred(owner, newOwner);
  }

}

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev Transfer token for a specified address.
    * @param _to address The address to transfer to.
    * @param _value uint256 The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner address The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC677 is ERC20 {
    function transferAndCall(address _to, uint256 _value, bytes _data) public returns (bool success);
    
    event ERC677Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}

contract ERC677Receiver {
    function onTokenTransfer(address _sender, uint _value, bytes _data) public returns (bool success);
}

contract ERC677Token is ERC677 {

    /**
    * @dev Transfer token to a contract address with additional data if the recipient is a contact.
    * @param _to address The address to transfer to.
    * @param _value uint256 The amount to be transferred.
    * @param _data bytes The extra data to be passed to the receiving contract.
    */
    function transferAndCall(address _to, uint256 _value, bytes _data) public returns (bool success) {
        require(super.transfer(_to, _value));
        ERC677Transfer(msg.sender, _to, _value, _data);
        if (isContract(_to)) {
            contractFallback(_to, _value, _data);
        }
        return true;
    }

    // PRIVATE

    function contractFallback(address _to, uint256 _value, bytes _data) private {
        ERC677Receiver receiver = ERC677Receiver(_to);
        require(receiver.onTokenTransfer(msg.sender, _value, _data));
    }

    // assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool hasCode) {
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }
}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;

    /**
    * @dev Transfer tokens from one address to another.
    * @param _from address The address which you want to send tokens from.
    * @param _to address The address which you want to transfer to.
    * @param _value uint256 the amout of tokens to be transfered.
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender address The address which will spend the funds.
    * @param _value uint256 The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifing the amount of tokens still avaible for the spender.
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract MDToken is StandardToken, ERC677Token, Ownable {
    using SafeMath for uint256;

    // Token metadata
    string public constant name = "Measurable Data Token";
    string public constant symbol = "MDT";
    uint256 public constant decimals = 18;
    uint256 public constant maxSupply = 10 * (10**8) * (10**decimals); // 1 billion MDT

    // 240 million MDT reserved for MDT team (24%)
    uint256 public constant TEAM_TOKENS_RESERVED = 240 * (10**6) * (10**decimals);

    // 150 million MDT reserved for user growth (15%)
    uint256 public constant USER_GROWTH_TOKENS_RESERVED = 150 * (10**6) * (10**decimals);

    // 110 million MDT reserved for early investors (11%)
    uint256 public constant INVESTORS_TOKENS_RESERVED = 110 * (10**6) * (10**decimals);

    // 200 million MDT reserved for bonus giveaway (20%)
    uint256 public constant BONUS_TOKENS_RESERVED = 200 * (10**6) * (10**decimals);

    // Token sale wallet address, contains tokens for private sale, early bird and bonus giveaway
    address public tokenSaleAddress;

    // MDT team wallet address
    address public mdtTeamAddress;

    // User Growth Pool wallet address
    address public userGrowthAddress;

    // Early Investors wallet address
    address public investorsAddress;

    // MDT team foundation wallet address, contains tokens which were not sold during token sale and unraised bonus
    address public mdtFoundationAddress;

    event Burn(address indexed _burner, uint256 _value);

    /// @dev Reverts if address is 0x0 or this token address
    modifier validRecipient(address _recipient) {
        require(_recipient != address(0) && _recipient != address(this));
        _;
    }

    /**
    * @dev MDToken contract constructor.
    * @param _tokenSaleAddress address The token sale address.
    * @param _mdtTeamAddress address The MDT team address.
    * @param _userGrowthAddress address The user growth address.
    * @param _investorsAddress address The investors address.
    * @param _mdtFoundationAddress address The MDT Foundation address.
    * @param _presaleAmount uint256 Amount of MDT tokens sold during presale.
    * @param _earlybirdAmount uint256 Amount of MDT tokens to sold during early bird.
    */
    function MDToken(
        address _tokenSaleAddress,
        address _mdtTeamAddress,
        address _userGrowthAddress,
        address _investorsAddress,
        address _mdtFoundationAddress,
        uint256 _presaleAmount,
        uint256 _earlybirdAmount)
        public
    {

        require(_tokenSaleAddress != address(0));
        require(_mdtTeamAddress != address(0));
        require(_userGrowthAddress != address(0));
        require(_investorsAddress != address(0));
        require(_mdtFoundationAddress != address(0));

        tokenSaleAddress = _tokenSaleAddress;
        mdtTeamAddress = _mdtTeamAddress;
        userGrowthAddress = _userGrowthAddress;
        investorsAddress = _investorsAddress;
        mdtFoundationAddress = _mdtFoundationAddress;

        // issue tokens to token sale, MDT team, etc
        uint256 saleAmount = _presaleAmount.add(_earlybirdAmount).add(BONUS_TOKENS_RESERVED);
        mint(tokenSaleAddress, saleAmount);
        mint(mdtTeamAddress, TEAM_TOKENS_RESERVED);
        mint(userGrowthAddress, USER_GROWTH_TOKENS_RESERVED);
        mint(investorsAddress, INVESTORS_TOKENS_RESERVED);

        // issue remaining tokens to MDT Foundation
        uint256 remainingTokens = maxSupply.sub(totalSupply);
        if (remainingTokens > 0) {
            mint(mdtFoundationAddress, remainingTokens);
        }
    }

    /**
    * @dev Mint MDT tokens. (internal use only)
    * @param _to address Address to send minted MDT to.
    * @param _amount uint256 Amount of MDT tokens to mint.
    */
    function mint(address _to, uint256 _amount)
        private
        validRecipient(_to)
        returns (bool)
    {
        require(totalSupply.add(_amount) <= maxSupply);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
    * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender address The address which will spend the funds.
    * @param _value uint256 The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value)
        public
        validRecipient(_spender)
        returns (bool)
    {
        return super.approve(_spender, _value);
    }

    /**
    * @dev Transfer token for a specified address.
    * @param _to address The address to transfer to.
    * @param _value uint256 The amount to be transferred.
    */
    function transfer(address _to, uint256 _value)
        public
        validRecipient(_to)
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

    /**
    * @dev Transfer token to a contract address with additional data if the recipient is a contact.
    * @param _to address The address to transfer to.
    * @param _value uint256 The amount to be transferred.
    * @param _data bytes The extra data to be passed to the receiving contract.
    */
    function transferAndCall(address _to, uint256 _value, bytes _data)
        public
        validRecipient(_to)
        returns (bool success)
    {
        return super.transferAndCall(_to, _value, _data);
    }

    /**
    * @dev Transfer tokens from one address to another.
    * @param _from address The address which you want to send tokens from.
    * @param _to address The address which you want to transfer to.
    * @param _value uint256 the amout of tokens to be transfered.
    */
    function transferFrom(address _from, address _to, uint256 _value)
        public
        validRecipient(_to)
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Burn tokens. (token owner only)
     * @param _value uint256 The amount to be burned.
     * @return always true.
     */
    function burn(uint256 _value)
        public
        onlyOwner
        returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * @dev Burn tokens on behalf of someone. (token owner only)
     * @param _from address The address of the owner of the token.
     * @param _value uint256 The amount to be burned.
     * @return always true.
     */
    function burnFrom(address _from, uint256 _value)
        public
        onlyOwner
        returns(bool)
    {
        var _allowance = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(_from, _value);
        return true;
    }

    /**
     * @dev Transfer to owner any tokens send by mistake to this contract. (token owner only)
     * @param token ERC20 The address of the token to transfer.
     * @param amount uint256 The amount to be transfered.
     */
    function emergencyERC20Drain(ERC20 token, uint256 amount)
        public
        onlyOwner
    {
        token.transfer(owner, amount);
    }

    /**
     * @dev Change to a new token sale address. (token owner only)
     * @param _tokenSaleAddress address The new token sale address.
     */
    function changeTokenSaleAddress(address _tokenSaleAddress)
        public
        onlyOwner
        validRecipient(_tokenSaleAddress)
    {
        tokenSaleAddress = _tokenSaleAddress;
    }

    /**
     * @dev Change to a new MDT team address. (token owner only)
     * @param _mdtTeamAddress address The new MDT team address.
     */
    function changeMdtTeamAddress(address _mdtTeamAddress)
        public
        onlyOwner
        validRecipient(_mdtTeamAddress)
    {
        mdtTeamAddress = _mdtTeamAddress;
    }

    /**
     * @dev Change to a new user growth address. (token owner only)
     * @param _userGrowthAddress address The new user growth address.
     */
    function changeUserGrowthAddress(address _userGrowthAddress)
        public
        onlyOwner
        validRecipient(_userGrowthAddress)
    {
        userGrowthAddress = _userGrowthAddress;
    }

    /**
     * @dev Change to a new investors address. (token owner only)
     * @param _investorsAddress address The new investors address.
     */
    function changeInvestorsAddress(address _investorsAddress)
        public
        onlyOwner
        validRecipient(_investorsAddress)
    {
        investorsAddress = _investorsAddress;
    }

    /**
     * @dev Change to a new MDT Foundation address. (token owner only)
     * @param _mdtFoundationAddress address The new MDT Foundation address.
     */
    function changeMdtFoundationAddress(address _mdtFoundationAddress)
        public
        onlyOwner
        validRecipient(_mdtFoundationAddress)
    {
        mdtFoundationAddress = _mdtFoundationAddress;
    }
}
pragma solidity ^0.4.18;

 /*
 * Contract that is working with ERC223 tokens
 * https://github.com/ethereum/EIPs/issues/223
 */

/// @title ERC223ReceivingContract - Standard contract implementation for compatibility with ERC223 tokens.
contract ERC223ReceivingContract {

    /// @dev Function that is called when a user or another contract wants to transfer funds.
    /// @param _from Transaction initiator, analogue of msg.sender
    /// @param _value Number of tokens to transfer.
    /// @param _data Data containig a function signature and/or parameters
    function tokenFallback(address _from, uint256 _value, bytes _data) public;
}

/// @title Base Token contract - Functions to be implemented by token contracts.
contract Token {
    /*
     * Implements ERC 20 standard.
     * https://github.com/ethereum/EIPs/blob/f90864a3d2b2b45c4decf95efd26b3f0c276051a/EIPS/eip-20-token-standard.md
     * https://github.com/ethereum/EIPs/issues/20
     *
     *  Added support for the ERC 223 "tokenFallback" method in a "transfer" function with a payload.
     *  https://github.com/ethereum/EIPs/issues/223
     */

    /*
     * ERC 20
     */
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    function burn(uint num) public;

    /*
     * ERC 223
     */
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);

    /*
     * Events
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _burner, uint _value);

    // There is no ERC223 compatible Transfer event, with `_data` included.
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/// @title PHI ERC223 Token with burn functionality
contract PhiToken is Token {

    /*
     *  Terminology:
     *  1 token unit = PHI
     *  1 token = PHI = sphi * multiplier
     *  multiplier set from token's number of decimals (i.e. 10 ** decimals)
     */

    /*  
     *  Section 1
     *  - Variables
     */
    /// Token metadata
    string constant public name = "PHI Token";
    string constant public symbol = "PHI";
    uint8 constant public decimals = 18;
    using SafeMath for uint;
    uint constant multiplier = 10 ** uint(decimals);

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    /*
     * This is a slight change to the ERC20 base standard.
     * function totalSupply() constant returns (uint256 supply);
     * is replaced with:
     * uint256 public totalSupply;
     * This automatically creates a getter function for the totalSupply.
     * This is moved to the base contract since public getter functions are not
     * currently recognised as an implementation of the matching abstract
     * function by the compiler.
     *
     * Hardcoded total supply (in sphi), it can be decreased only by burning tokens
     */
    uint256 public totalSupply =  24157817 * multiplier;

    /// Keep track of assigned tokens at deploy
    bool initialTokensAssigned = false;

    /// Store pre-ico and ico address
    address public PRE_ICO_ADDR;
    address public ICO_ADDR;

    /// Where tokens for team will be sent, used also for function-auth
    address public WALLET_ADDR;

    /// How long the tokens should be locked for transfers
    uint public lockTime;

    /* 
     *  Section 2
     *  - modifiers
     */
    /// Do not allow transfers if lockTime is active, allow only
    /// pre-ico and ico if it is (to distribute tokens)
    modifier onlyIfLockTimePassed () {
        require(now > lockTime || (msg.sender == PRE_ICO_ADDR || msg.sender == ICO_ADDR));
        _;
    }

    /* 
     *  Section 3
     *  - Events
     */
    event Deployed(uint indexed _total_supply);

    /*
     *  Public functions
     */
    /// @dev Contract constructor function, assigns tokens to ico, pre-ico,
    /// wallet address and pre sale investors.
    /// @param ico_address Address of the ico contract.
    /// @param pre_ico_address Address of the pre-ico contract.
    /// @param wallet_address Address of tokens to be sent to the PHI team.
    /// @param _lockTime Epoch Timestamp describing how long the tokens should be
    /// locked for transfers.
    function PhiToken(
        address ico_address,
        address pre_ico_address,
        address wallet_address,
        uint _lockTime)
        public
    {
        // Check destination address
        require(ico_address != 0x0);
        require(pre_ico_address != 0x0);
        require(wallet_address != 0x0);
        require(ico_address != pre_ico_address && wallet_address != ico_address);
        require(initialTokensAssigned == false);
        // _lockTime should be in the future
        require(_lockTime > now);
        lockTime = _lockTime;

        WALLET_ADDR = wallet_address;

        // Check total supply
        require(totalSupply > multiplier);

        // tokens to be assigned to pre-ico, ico and wallet address
        uint initAssign = 0;

        // to be sold in the ico
        initAssign += assignTokens(ico_address, 7881196 * multiplier);
        ICO_ADDR = ico_address;
        // to be sold in the pre-ico
        initAssign += assignTokens(pre_ico_address, 3524578 * multiplier);
        PRE_ICO_ADDR = pre_ico_address;
        // Reserved for the team, airdrop, marketing, business etc..
        initAssign += assignTokens(wallet_address, 9227465 * multiplier);

        // Pre sale allocations
        uint presaleTokens = 0;
        presaleTokens += assignTokens(address(0x72B16DC0e5f85aA4BBFcE81687CCc9D6871C2965), 230387 * multiplier);
        presaleTokens += assignTokens(address(0x7270cC02d88Ea63FC26384f5d08e14EE87E75154), 132162 * multiplier);
        presaleTokens += assignTokens(address(0x25F92f21222969BB0b1f14f19FBa770D30Ff678f), 132162 * multiplier);
        presaleTokens += assignTokens(address(0xAc99C59D3353a34531Fae217Ba77139BBe4eDBb3), 443334 * multiplier);
        presaleTokens += assignTokens(address(0xbe41D37eB2d2859143B9f1D29c7BC6d7e59174Da), 970826500000000000000000); // 970826.5 PHI
        presaleTokens += assignTokens(address(0x63e9FA0e43Fcc7C702ed5997AfB8E215C5beE3c9), 970826500000000000000000); // 970826.5 PHI
        presaleTokens += assignTokens(address(0x95c67812c5C41733419aC3b1916d2F282E7A15A4), 396486 * multiplier);
        presaleTokens += assignTokens(address(0x1f5d30BB328498fF6E09b717EC22A9046C41C257), 20144 * multiplier);
        presaleTokens += assignTokens(address(0x0a1ac564e95dAEDF8d454a3593b75CCdd474fc42), 19815 * multiplier);
        presaleTokens += assignTokens(address(0x0C5448D5bC4C40b4d2b2c1D7E58E0541698d3e6E), 19815 * multiplier);
        presaleTokens += assignTokens(address(0xFAe11D521538F067cE0B13B6f8C929cdEA934D07), 75279 * multiplier);
        presaleTokens += assignTokens(address(0xEE51304603887fFF15c6d12165C6d96ff0f0c85b), 45949 * multiplier);
        presaleTokens += assignTokens(address(0xd7Bab04C944faAFa232d6EBFE4f60FF8C4e9815F), 6127 * multiplier);
        presaleTokens += assignTokens(address(0x603f39C81560019c8360F33bA45Bc1E4CAECb33e), 45949 * multiplier);
        presaleTokens += assignTokens(address(0xBB5128f1093D1aa85F6d7D0cC20b8415E0104eDD), 15316 * multiplier);
        
        initialTokensAssigned = true;

        Deployed(totalSupply);

        assert(presaleTokens == 3524578 * multiplier);
        assert(totalSupply == (initAssign.add(presaleTokens)));
    }

    /// @dev Helper function to assign tokens (team, pre-sale, ico, pre-ico etc..).
    /// @notice It will be automatically called on deploy.
    /// @param addr Receiver of the tokens.
    /// @param amount Tokens (in sphi).
    /// @return Tokens assigned
    function assignTokens (address addr, uint amount) internal returns (uint) {
        require(addr != 0x0);
        require(initialTokensAssigned == false);
        balances[addr] = amount;
        Transfer(0x0, addr, balances[addr]);
        return balances[addr];
    }

    /// @notice Allows `msg.sender` to simply destroy `_value` token units (sphi). This means the total
    /// token supply will decrease.
    /// @dev Allows to destroy token units (sphi).
    /// @param _value Number of token units (sphi) to burn.
    function burn(uint256 _value) public onlyIfLockTimePassed {
        require(_value > 0);
        require(balances[msg.sender] >= _value);
        require(totalSupply >= _value);

        uint pre_balance = balances[msg.sender];
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
        Transfer(burner, 0x0, _value);
        assert(balances[burner] == pre_balance.sub(_value));
    }

    /*
     * Token functions
     */

    /// @notice Send `_value` tokens to `_to` from `msg.sender`.
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    /// @return Returns success of function call.
    function transfer(address _to, uint256 _value) public onlyIfLockTimePassed returns (bool) {
        require(_to != 0x0);
        require(_to != address(this));
        require(balances[msg.sender] >= _value);
        require(balances[_to].add(_value) >= balances[_to]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /// @notice Send `_value` tokens to `_to` from `msg.sender` and trigger
    /// tokenFallback if sender is a contract.
    /// @dev Function that is called when a user or another contract wants to transfer funds.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    /// @param _data Data to be sent to tokenFallback
    /// @return Returns success of function call.
    function transfer(
        address _to,
        uint256 _value,
        bytes _data)
        public
        onlyIfLockTimePassed
        returns (bool)
    {
        require(transfer(_to, _value));

        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly.
            codeLength := extcodesize(_to)
        }

        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }

        return true;
    }

    /// @notice Transfer `_value` tokens from `_from` to `_to` if `msg.sender` is allowed.
    /// @dev Allows for an approved third party to transfer tokens from one
    /// address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    /// @return Returns success of function call.
    function transferFrom(address _from, address _to, uint256 _value)
        public
        onlyIfLockTimePassed
        returns (bool)
    {
        require(_from != 0x0);
        require(_to != 0x0);
        require(_to != address(this));
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_to].add(_value) >= balances[_to]);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }

    /// @notice Allows `_spender` to transfer `_value` tokens from `msg.sender` to any address.
    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    /// @return Returns success of function call.
    function approve(address _spender, uint256 _value) public onlyIfLockTimePassed returns (bool) {
        require(_spender != 0x0);

        // To change the approve amount you first have to reduce the addresses`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(_value == 0 || allowed[msg.sender][_spender] == 0);

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read functions
     */
    /// @dev Returns number of allowed tokens that a spender can transfer on
    /// behalf of a token owner.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    /// @return Returns remaining allowance for spender.
    function allowance(address _owner, address _spender)
        constant
        public
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /// @dev Returns number of tokens owned by the given address.
    /// @param _owner Address of token owner.
    /// @return Returns balance of owner.
    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

}
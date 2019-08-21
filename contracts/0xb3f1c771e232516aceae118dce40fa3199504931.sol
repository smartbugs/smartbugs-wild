pragma solidity ^0.4.6;


/**
 * Math operations with safety checks
 */
contract SafeMath {
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

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
/// @title Abstract token contract - Functions to be implemented by token contracts.
contract AbstractToken {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}


contract StandardToken is AbstractToken {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /*
     *  Read and write storage functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read storage functions
     */
    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}


/// @title Token contract - Implements Standard Token Interface with HumaniQ features.
/// @author Evgeny Yurtaev - <evgeny@etherionlab.com>
/// @author Alexey Bashlykov - <alexey@etherionlab.com>
contract HumaniqToken is StandardToken, SafeMath {

    /*
     * External contracts
     */
    address public minter;

    /*
     * Token meta data
     */
    string constant public name = "Humaniq";
    string constant public symbol = "HMQ";
    uint8 constant public decimals = 8;

    // Address of the founder of Humaniq.
    address public founder = 0xc890b1f532e674977dfdb791cafaee898dfa9671;

    // Multisig address of the founders
    address public multisig = 0xa2c9a7578e2172f32a36c5c0e49d64776f9e7883;

    // Address where all tokens created during ICO stage initially allocated
    address constant public allocationAddressICO = 0x1111111111111111111111111111111111111111;

    // Address where all tokens created during preICO stage initially allocated
    address constant public allocationAddressPreICO = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    // 31 820 314 tokens were minted during preICO
    uint constant public preICOSupply = mul(31820314, 100000000);

    // 131 038 286 tokens were minted during ICO
    uint constant public ICOSupply = mul(131038286, 100000000);

    // Max number of tokens that can be minted
    uint public maxTotalSupply;

    /*
     * Modifiers
     */
    modifier onlyFounder() {
        // Only founder is allowed to do this action.
        if (msg.sender != founder) {
            throw;
        }
        _;
    }

    modifier onlyMinter() {
        // Only minter is allowed to proceed.
        if (msg.sender != minter) {
            throw;
        }
        _;
    }

    /*
     * Contract functions
     */

    /// @dev Crowdfunding contract issues new tokens for address. Returns success.
    /// @param _for Address of receiver.
    /// @param tokenCount Number of tokens to issue.
    function issueTokens(address _for, uint tokenCount)
        external
        payable
        onlyMinter
        returns (bool)
    {
        if (tokenCount == 0) {
            return false;
        }

        if (add(totalSupply, tokenCount) > maxTotalSupply) {
            throw;
        }

        totalSupply = add(totalSupply, tokenCount);
        balances[_for] = add(balances[_for], tokenCount);
        Issuance(_for, tokenCount);
        return true;
    }

    /// @dev Function to change address that is allowed to do emission.
    /// @param newAddress Address of new emission contract.
    function changeMinter(address newAddress)
        public
        onlyFounder
        returns (bool)
    {   
        // Forbid previous emission contract to distribute tokens minted during ICO stage
        delete allowed[allocationAddressICO][minter];

        minter = newAddress;

        // Allow emission contract to distribute tokens minted during ICO stage
        allowed[allocationAddressICO][minter] = balanceOf(allocationAddressICO);
    }

    /// @dev Function to change founder address.
    /// @param newAddress Address of new founder.
    function changeFounder(address newAddress)
        public
        onlyFounder
        returns (bool)
    {   
        founder = newAddress;
    }

    /// @dev Function to change multisig address.
    /// @param newAddress Address of new multisig.
    function changeMultisig(address newAddress)
        public
        onlyFounder
        returns (bool)
    {
        multisig = newAddress;
    }

    /// @dev Contract constructor function sets initial token balances.
    function HumaniqToken(address founderAddress)
    {   
        // Set founder address
        founder = founderAddress;

        // Allocate all created tokens during ICO stage to allocationAddressICO.
        balances[allocationAddressICO] = ICOSupply;

        // Allocate all created tokens during preICO stage to allocationAddressPreICO.
        balances[allocationAddressPreICO] = preICOSupply;

        // Allow founder to distribute tokens minted during preICO stage
        allowed[allocationAddressPreICO][founder] = preICOSupply;

        // Give 14 percent of all tokens to founders.
        balances[multisig] = div(mul(ICOSupply, 14), 86);

        // Set correct totalSupply and limit maximum total supply.
        totalSupply = add(ICOSupply, balances[multisig]);
        totalSupply = add(totalSupply, preICOSupply);
        maxTotalSupply = mul(totalSupply, 5);
    }
}

/// @title HumaniqICO contract - Takes funds from users and issues tokens.
/// @author Evgeny Yurtaev - <evgeny@etherionlab.com>
/// @author Alexey Bashlykov - <alexey@etherionlab.com>
contract HumaniqICO is SafeMath {

    /*
     * External contracts
     */
    HumaniqToken public humaniqToken;

    // Address of the founder of Humaniq.
    address public founder = 0xc890b1f532e674977dfdb791cafaee898dfa9671;

    // Address where all tokens created during ICO stage initially allocated
    address public allocationAddress = 0x1111111111111111111111111111111111111111;

    // Start date of the ICO
    uint public startDate = 1491433200;  // 2017-04-05 23:00:00 UTC

    // End date of the ICO
    uint public endDate = 1493247600;  // 2017-04-26 23:00:00 UTC

    // Token price without discount during the ICO stage
    uint public baseTokenPrice = 10000000; // 0.001 ETH, considering 8 decimal places

    // Number of tokens distributed to investors
    uint public tokensDistributed = 0;

    /*
     *  Modifiers
     */
    modifier onlyFounder() {
        // Only founder is allowed to do this action.
        if (msg.sender != founder) {
            throw;
        }
        _;
    }

    modifier minInvestment(uint investment) {
        // User has to send at least the ether value of one token.
        if (investment < baseTokenPrice) {
            throw;
        }
        _;
    }

    /// @dev Returns current bonus
    function getCurrentBonus()
        public
        constant
        returns (uint)
    {
        return getBonus(now);
    }

    /// @dev Returns bonus for the specific moment
    /// @param timestamp Time of investment (in seconds)
    function getBonus(uint timestamp)
        public
        constant
        returns (uint)
    {   
        if (timestamp > endDate) {
            throw;
        }

        if (startDate > timestamp) {
            return 1499;  // 49.9%
        }

        uint icoDuration = timestamp - startDate;
        if (icoDuration >= 16 days) {
            return 1000;  // 0%
        } else if (icoDuration >= 9 days) {
            return 1125;  // 12.5%
        } else if (icoDuration >= 2 days) {
            return 1250;  // 25%
        } else {
            return 1499;  // 49.9%
        }
    }

    function calculateTokens(uint investment, uint timestamp)
        public
        constant
        returns (uint)
    {
        // calculate discountedPrice
        uint discountedPrice = div(mul(baseTokenPrice, 1000), getBonus(timestamp));

        // Token count is rounded down. Sent ETH should be multiples of baseTokenPrice.
        return div(investment, discountedPrice);
    }


    /// @dev Issues tokens for users who made BTC purchases.
    /// @param beneficiary Address the tokens will be issued to.
    /// @param investment Invested amount in Wei
    /// @param timestamp Time of investment (in seconds)
    function fixInvestment(address beneficiary, uint investment, uint timestamp)
        external
        onlyFounder
        minInvestment(investment)
        returns (uint)
    {   

        // Calculate number of tokens to mint
        uint tokenCount = calculateTokens(investment, timestamp);

        // Update fund's and user's balance and total supply of tokens.
        tokensDistributed = add(tokensDistributed, tokenCount);

        // Distribute tokens.
        if (!humaniqToken.transferFrom(allocationAddress, beneficiary, tokenCount)) {
            // Tokens could not be issued.
            throw;
        }

        return tokenCount;
    }

    /// @dev Contract constructor
    function HumaniqICO(address tokenAddress, address founderAddress) {
        // Set token address
        humaniqToken = HumaniqToken(tokenAddress);

        // Set founder address
        founder = founderAddress;
    }

    /// @dev Fallback function
    function () payable {
        throw;
    }
}
pragma solidity ^0.4.2;

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
        if (balances[msg.sender] >= _value && _value > 0) {
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
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
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
/// @author EtherionLab team, https://etherionlab.com
contract HumaniqToken is StandardToken {

    /*
     * External contracts
     */
    address public emissionContractAddress = 0x0;

    /*
     * Token meta data
     */
    string constant public name = "HumaniQ";
    string constant public symbol = "HMQ";
    uint8 constant public decimals = 8;

    address public founder = 0x0;
    bool locked = true;
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

    modifier isCrowdfundingContract() {
        // Only emission address is allowed to proceed.
        if (msg.sender != emissionContractAddress) {
            throw;
        }
        _;
    }

    modifier unlocked() {
        // Only when transferring coins is enabled.
        if (locked == true) {
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
        isCrowdfundingContract
        returns (bool)
    {
        if (tokenCount == 0) {
            return false;
        }
        balances[_for] += tokenCount;
        totalSupply += tokenCount;
        Issuance(_for, tokenCount);
        return true;
    }

    function transfer(address _to, uint256 _value)
        unlocked
        returns (bool success)
    {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)
        unlocked
        returns (bool success)
    {
        return super.transferFrom(_from, _to, _value);
    }

    /// @dev Function to change address that is allowed to do emission.
    /// @param newAddress Address of new emission contract.
    function changeEmissionContractAddress(address newAddress)
        external
        onlyFounder
        returns (bool)
    {
        emissionContractAddress = newAddress;
    }

    /// @dev Function that locks/unlocks transfers of token.
    /// @param value True/False
    function lock(bool value)
        external
        onlyFounder
    {
        locked = value;
    }

    /// @dev Contract constructor function sets initial token balances.
    /// @param _founder Address of the founder of HumaniQ.
    function HumaniqToken(address _founder)
    {
        totalSupply = 0;
        founder = _founder;
    }
}


/// @title HumaniqICO contract - Takes funds from users and issues tokens.
/// @author Evgeny Yurtaev - <evgeny@etherionlab.com>
contract HumaniqICO {

    /*
     * External contracts
     */
    HumaniqToken public humaniqToken;

    /*
     * Crowdfunding parameters
     */
    uint constant public CROWDFUNDING_PERIOD = 3 weeks;

    /*
     *  Storage
     */
    address public founder;
    address public multisig;
    uint public startDate = 0;
    uint public icoBalance = 0;
    uint public coinsIssued = 0;
    uint public baseTokenPrice = 1 finney; // 0.001 ETH
    uint public discountedPrice = baseTokenPrice;
    bool public isICOActive = false;

    // participant address => value in Wei
    mapping (address => uint) public investments;

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

    modifier minInvestment() {
        // User has to send at least the ether value of one token.
        if (msg.value < baseTokenPrice) {
            throw;
        }
        _;
    }

    modifier icoActive() {
        if (isICOActive == false) {
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

        if (startDate == 0) {
            return 1499; // 49.9%
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
        discountedPrice = (baseTokenPrice * 1000) / getBonus(timestamp);

        // Token count is rounded down. Sent ETH should be multiples of baseTokenPrice.
        return investment / discountedPrice;
    }

    /// @dev Issues tokens
    /// @param beneficiary Address the tokens will be issued to.
    /// @param investment Invested amount in Wei
    /// @param timestamp Time of investment (in seconds)
    /// @param sendToFounders Whether to send received ethers to multisig address or not
    function issueTokens(address beneficiary, uint investment, uint timestamp, bool sendToFounders)
        private
        returns (uint)
    {
        uint tokenCount = calculateTokens(investment, timestamp);

        // Ether spent by user.
        uint roundedInvestment = tokenCount * discountedPrice;

        // Send change back to user.
        if (sendToFounders && investment > roundedInvestment && !beneficiary.send(investment - roundedInvestment)) {
            throw;
        }

        // Update fund's and user's balance and total supply of tokens.
        icoBalance += investment;
        coinsIssued += tokenCount;
        investments[beneficiary] += roundedInvestment;

        // Send funds to founders if investment was made
        if (sendToFounders && !multisig.send(roundedInvestment)) {
            // Could not send money
            throw;
        }

        if (!humaniqToken.issueTokens(beneficiary, tokenCount)) {
            // Tokens could not be issued.
            throw;
        }

        return tokenCount;
    }

    /// @dev Allows user to create tokens if token creation is still going
    /// and cap was not reached. Returns token count.
    function fund()
        public
        icoActive
        minInvestment
        payable
        returns (uint)
    {
        return issueTokens(msg.sender, msg.value, now, true);
    }

    /// @dev Issues tokens for users who made BTC purchases.
    /// @param beneficiary Address the tokens will be issued to.
    /// @param investment Invested amount in Wei
    /// @param timestamp Time of investment (in seconds)
    function fixInvestment(address beneficiary, uint investment, uint timestamp)
        external
        icoActive
        onlyFounder
        returns (uint)
    {
        if (timestamp == 0) {
            return issueTokens(beneficiary, investment, now, false);
        }

        return issueTokens(beneficiary, investment, timestamp, false);
    }

    /// @dev If ICO has successfully finished sends the money to multisig
    /// wallet.
    function finishCrowdsale()
        external
        onlyFounder
        returns (bool)
    {
        if (isICOActive == true) {
            isICOActive = false;
            // Founders receive 14% of all created tokens.
             uint founderBonus = (coinsIssued * 14) / 86;
             if (!humaniqToken.issueTokens(multisig, founderBonus)) {
                 // Tokens could not be issued.
                 throw;
             }
        }
    }

    /// @dev Sets token value in Wei.
    /// @param valueInWei New value.
    function changeBaseTokenPrice(uint valueInWei)
        external
        onlyFounder
        returns (bool)
    {
        baseTokenPrice = valueInWei;
        return true;
    }

    function changeTokenAddress(address token_address) 
        public
        onlyFounder
    {
         humaniqToken = HumaniqToken(token_address);
    }

    function changeFounder(address _founder) 
        public
        onlyFounder
    {
        founder = _founder;
    }

    /// @dev Function that activates ICO.
    function startICO()
        external
        onlyFounder
    {
        if (isICOActive == false && startDate == 0) {
          // Start ICO
          isICOActive = true;
          // Set start-date of token creation
          startDate = now;
        }
    }

    /// @dev Contract constructor function sets founder and multisig addresses.
    function HumaniqICO(address _founder, address _multisig, address token_address) {
        // Set founder address
        founder = _founder;
        // Set multisig address
        multisig = _multisig;
        // Set token address
        humaniqToken = HumaniqToken(token_address);
    }

    /// @dev Fallback function. Calls fund() function to create tokens.
    function () payable {
        fund();
    }
}
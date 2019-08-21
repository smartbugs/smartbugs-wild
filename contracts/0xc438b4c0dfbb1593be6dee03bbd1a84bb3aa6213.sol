pragma solidity ^0.4.18;


/// @title Abstract ERC20 token interface
contract AbstractToken {

    function totalSupply() constant returns (uint256) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}


contract Owned {

    address public owner = msg.sender;
    address public potentialOwner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPotentialOwner {
        require(msg.sender == potentialOwner);
        _;
    }

    event NewOwner(address old, address current);
    event NewPotentialOwner(address old, address potential);

    function setOwner(address _new)
        public
        onlyOwner
    {
        NewPotentialOwner(owner, _new);
        potentialOwner = _new;
    }

    function confirmOwnership()
        public
        onlyPotentialOwner
    {
        NewOwner(owner, potentialOwner);
        owner = potentialOwner;
        potentialOwner = 0;
    }
}


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
contract StandardToken is AbstractToken, Owned {

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


/// @title SafeMath contract - Math operations with safety checks.
/// @author OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
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

    function pow(uint a, uint b) internal returns (uint) {
        uint c = a ** b;
        assert(c >= a);
        return c;
    }
}


/// @title Token contract - Implements Standard ERC20 with additional features.
/// @author Zerion - <inbox@zerion.io>
contract Token is StandardToken, SafeMath {

    // Time of the contract creation
    uint public creationTime;

    function Token() {
        creationTime = now;
    }


    /// @dev Owner can transfer out any accidentally sent ERC20 tokens
    function transferERC20Token(address tokenAddress)
        public
        onlyOwner
        returns (bool)
    {
        uint balance = AbstractToken(tokenAddress).balanceOf(this);
        return AbstractToken(tokenAddress).transfer(owner, balance);
    }

    /// @dev Multiplies the given number by 10^(decimals)
    function withDecimals(uint number, uint decimals)
        internal
        returns (uint)
    {
        return mul(number, pow(10, decimals));
    }
}


/// @title Token contract - Implements Standard ERC20 Token for Qchain project.
/// @author Zerion - <inbox@zerion.io>
contract QchainToken is Token {

    /*
     * Token meta data
     */
    string constant public name = "Ethereum Qchain Token";
    string constant public symbol = "EQC";
    uint8 constant public decimals = 8;

    // Address where Foundation tokens are allocated
    address constant public foundationReserve = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    // Address where all tokens for the ICO stage are initially allocated
    address constant public icoAllocation = 0x1111111111111111111111111111111111111111;

    // Address where all tokens for the PreICO are initially allocated
    address constant public preIcoAllocation = 0x2222222222222222222222222222222222222222;

    // ICO start date. 10/24/2017 @ 9:00pm (UTC)
    uint256 constant public startDate = 1508878800;
    uint256 constant public duration = 42 days;

    // Public key of the signer
    address public signer;

    // Foundation multisignature wallet, all Ether is collected there
    address public multisig;

    /// @dev Contract constructor, sets totalSupply
    function QchainToken(address _signer, address _multisig)
    {
        // Overall, 375,000,000 EQC tokens are distributed
        totalSupply = withDecimals(375000000, decimals);

        // 11,500,000 tokens were sold during the PreICO
        uint preIcoTokens = withDecimals(11500000, decimals);

        // 40% of total supply is allocated for the Foundation
        balances[foundationReserve] = div(mul(totalSupply, 40), 100);

        // PreICO tokens are allocated to the special address and will be distributed manually
        balances[preIcoAllocation] = preIcoTokens;

        // The rest of the tokens is available for sale
        balances[icoAllocation] = totalSupply - preIcoTokens - balanceOf(foundationReserve);

        // Allow the owner to distribute tokens from the PreICO allocation address
        allowed[preIcoAllocation][msg.sender] = balanceOf(preIcoAllocation);

        // Allow the owner to withdraw tokens from the Foundation reserve
        allowed[foundationReserve][msg.sender] = balanceOf(foundationReserve);

        signer = _signer;
        multisig = _multisig;
    }

    modifier icoIsActive {
        require(now >= startDate && now < startDate + duration);
        _;
    }

    modifier icoIsCompleted {
        require(now >= startDate + duration);
        _;
    }

    /// @dev Settle an investment and distribute tokens
    function invest(address investor, uint256 tokenPrice, uint256 value, bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        public
        icoIsActive
        payable
    {
        // Check the hash
        require(sha256(uint(investor) << 96 | tokenPrice) == hash);

        // Check the signature
        require(ecrecover(hash, v, r, s) == signer);

        // Difference between the value argument and actual value should not be
        // more than 0.005 ETH (gas commission)
        require(sub(value, msg.value) <= withDecimals(5, 15));

        // Number of tokens to distribute
        uint256 tokensNumber = div(withDecimals(value, decimals), tokenPrice);

        // Check if there is enough tokens left
        require(balances[icoAllocation] >= tokensNumber);

        // Send Ether to the multisig
        require(multisig.send(msg.value));

        // Allocate tokens to an investor
        balances[icoAllocation] -= tokensNumber;
        balances[investor] += tokensNumber;
        Transfer(icoAllocation, investor, tokensNumber);
    }

    /// @dev Overrides Owned.sol function
    function confirmOwnership()
        public
        onlyPotentialOwner
    {
        // Allow new owner to withdraw tokens from Foundation reserve and
        // preICO allocation address
        allowed[foundationReserve][potentialOwner] = balanceOf(foundationReserve);
        allowed[preIcoAllocation][potentialOwner] = balanceOf(preIcoAllocation);

        // Forbid old owner to withdraw tokens from Foundation reserve and
        // preICO allocation address
        allowed[foundationReserve][owner] = 0;
        allowed[preIcoAllocation][owner] = 0;

        // Change owner
        super.confirmOwnership();
    }

    /// @dev Withdraws tokens from Foundation reserve
    function withdrawFromReserve(uint amount)
        public
        onlyOwner
    {
        // Withdraw tokens from Foundation reserve to multisig address
        require(transferFrom(foundationReserve, multisig, amount));
    }

    /// @dev Changes multisig address
    function changeMultisig(address _multisig)
        public
        onlyOwner
    {
        multisig = _multisig;
    }

    /// @dev Burns the rest of the tokens after the crowdsale end
    function burn()
        public
        onlyOwner
        icoIsCompleted
    {
        totalSupply = sub(totalSupply, balanceOf(icoAllocation));
        balances[icoAllocation] = 0;
    }
}
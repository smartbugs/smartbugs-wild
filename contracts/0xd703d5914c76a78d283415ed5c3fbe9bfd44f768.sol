pragma solidity ^0.4.13;


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


/// @title Token contract - Implements Standard ERC20 Token for Tokenbox project.
/// @author Zerion - <inbox@zerion.io>
contract TokenboxToken is Token {

    /*
     * Token meta data
     */
    string constant public name = "Tokenbox";
    //TODO: Fix before production
    string constant public symbol = "TBX-test";
    uint8 constant public decimals = 18;

    // Address where Foundation tokens are allocated
    address constant public foundationReserve = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    // Address where all tokens for the ICO stage are initially allocated
    address constant public icoAllocation = 0x1111111111111111111111111111111111111111;

    // Address where all tokens for the PreICO are initially allocated
    address constant public preIcoAllocation = 0x2222222222222222222222222222222222222222;

    // TGE start date. 11/14/2017 @ 12:00pm (UTC)
    uint256 constant public startDate = 1510660800;
    // TGE duration is 14 days
    uint256 constant public duration = 14 days;

    // Vesting date to withdraw 15% of total sold tokens, 11/28/2018 @ 12:00pm (UTC)
    uint256 constant public vestingDateEnd = 1543406400;

    // Total USD collected (10^-12)
    uint256 public totalPicoUSD = 0;
    uint8 constant public usdDecimals = 12;

    // Public key of the signer
    address public signer;

    // Foundation multisignature wallet, all Ether is collected there
    address public multisig;

    bool public finalised = false;

    // Events
    event InvestmentInETH(address investor, uint256 tokenPriceInWei, uint256 investedInWei, uint256 investedInPicoUsd, uint256 tokensNumber, bytes32 hash);
    event InvestmentInBTC(address investor, uint256 tokenPriceInSatoshi, uint256 investedInSatoshi, uint256 investedInPicoUsd, uint256 tokensNumber, string btcAddress);
    event InvestmentInUSD(address investor, uint256 tokenPriceInPicoUsd, uint256 investedInPicoUsd, uint256 tokensNumber);
    event PresaleInvestment(address investor, uint256 investedInPicoUsd, uint256 tokensNumber);

    /// @dev Contract constructor, sets totalSupply
    function TokenboxToken(address _signer, address _multisig, uint256 _preIcoTokens )
    {
        // Overall, 31,000,000 TBX tokens are distributed
        totalSupply = withDecimals(31000000, decimals);

        uint preIcoTokens = withDecimals(_preIcoTokens, decimals);

        // PreICO tokens are allocated to the special address and will be distributed manually
        balances[preIcoAllocation] = preIcoTokens;

        // foundationReserve balance will be allocated after the end of the crowdsale
        balances[foundationReserve] = 0;

        // The rest of the tokens is available for sale (75% of totalSupply)
        balances[icoAllocation] = div(mul(totalSupply, 75), 100)  - preIcoTokens;

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

    modifier onlyOwnerOrSigner {
        require((msg.sender == owner) || (msg.sender == signer));
        _;
    }

    /// @dev Settle an investment made in ETH and distribute tokens
    function invest(address investor, uint256 tokenPriceInPicoUsd, uint256 investedInWei, bytes32 hash, uint8 v, bytes32 r, bytes32 s, uint256 WeiToUSD)
        public
        icoIsActive
        payable
    {
        // Check the hash
        require(sha256(uint(investor) << 96 | tokenPriceInPicoUsd) == hash);

        // Check the signature
        require(ecrecover(hash, v, r, s) == signer);

        // Difference between the value argument and actual value should not be
        // more than 0.005 ETH (gas commission)
        require(sub(investedInWei, msg.value) <= withDecimals(5, 15));

        uint tokenPriceInWei = div(mul(tokenPriceInPicoUsd, WeiToUSD), pow(10, usdDecimals));

        // Number of tokens to distribute
        uint256 tokensNumber = div(withDecimals(investedInWei, decimals), tokenPriceInWei);

        // Check if there is enough tokens left
        require(balances[icoAllocation] >= tokensNumber);

        // Send Ether to the multisig
        require(multisig.send(msg.value));

        uint256 investedInPicoUsd = div(withDecimals(investedInWei, usdDecimals), WeiToUSD);

        investInUSD(investor, investedInPicoUsd, tokensNumber);

        InvestmentInETH(investor, tokenPriceInWei, investedInWei, investedInPicoUsd, tokensNumber, hash);
    }

    /// @dev Settle an investment in BTC and distribute tokens.
    function investInBTC(address investor, uint256 tokenPriceInPicoUsd, uint256 investedInSatoshi, string btcAddress, uint256 satoshiToUSD)
        public
        icoIsActive
        onlyOwnerOrSigner
    {
        uint tokenPriceInSatoshi = div(mul(tokenPriceInPicoUsd, satoshiToUSD), pow(10, usdDecimals));

        // Number of tokens to distribute
        uint256 tokensNumber = div(withDecimals(investedInSatoshi, decimals), tokenPriceInSatoshi);

        // Check if there is enough tokens left
        require(balances[icoAllocation] >= tokensNumber);

        uint256 investedInPicoUsd = div(withDecimals(investedInSatoshi, usdDecimals), satoshiToUSD);

        investInUSD(investor, investedInPicoUsd, tokensNumber);

        InvestmentInBTC(investor, tokenPriceInSatoshi, investedInSatoshi, investedInPicoUsd, tokensNumber, btcAddress);
    }

    // @dev Invest in USD
    function investInUSD(address investor, uint256 investedInPicoUsd, uint256 tokensNumber)
        private
    {
      totalPicoUSD = add(totalPicoUSD, investedInPicoUsd);

      // Allocate tokens to an investor
      balances[icoAllocation] -= tokensNumber;
      balances[investor] += tokensNumber;
      Transfer(icoAllocation, investor, tokensNumber);
    }

    // @dev Wire investment
    function wireInvestInUSD(address investor, uint256 tokenPriceInUsdCents, uint256 investedInUsdCents)
        public
        icoIsActive
        onlyOwnerOrSigner
     {

       uint256 tokensNumber = div(withDecimals(investedInUsdCents, decimals), tokenPriceInUsdCents);

       // Check if there is enough tokens left
       require(balances[icoAllocation] >= tokensNumber);

       // We subtract 2 because the value is in cents.
       uint256 investedInPicoUsd = withDecimals(investedInUsdCents, usdDecimals - 2);
       uint256 tokenPriceInPicoUsd = withDecimals(tokenPriceInUsdCents, usdDecimals - 2);

       investInUSD(investor, investedInPicoUsd, tokensNumber);

       InvestmentInUSD(investor, tokenPriceInPicoUsd, investedInPicoUsd, tokensNumber);
    }

    // @dev Presale tokens distribution
    function preIcoDistribution(address investor, uint256 investedInUsdCents, uint256 tokensNumber)
        public
        onlyOwner
    {
      uint256 tokensNumberWithDecimals = withDecimals(tokensNumber, decimals);

      // Check if there is enough tokens left
      require(balances[preIcoAllocation] >= tokensNumberWithDecimals);

      // Allocate tokens to an investor
      balances[preIcoAllocation] -= tokensNumberWithDecimals;
      balances[investor] += tokensNumberWithDecimals;
      Transfer(preIcoAllocation, investor, tokensNumberWithDecimals);

      uint256 investedInPicoUsd = withDecimals(investedInUsdCents, usdDecimals - 2);
      // Add investment to totalPicoUSD collected
      totalPicoUSD = add(totalPicoUSD, investedInPicoUsd);

      PresaleInvestment(investor, investedInPicoUsd, tokensNumberWithDecimals);
    }


    /// @dev Allow token withdrawals from Foundation reserve
    function allowToWithdrawFromReserve()
        public
        onlyOwner
    {
        require(now >= vestingDateEnd);

        // Allow the owner to withdraw tokens from the Foundation reserve
        allowed[foundationReserve][msg.sender] = balanceOf(foundationReserve);
    }


    // @dev Withdraws tokens from Foundation reserve
    function withdrawFromReserve(uint amount)
        public
        onlyOwner
    {
        require(now >= vestingDateEnd);
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

    /// @dev Changes signer address
    function changeSigner(address _signer)
        public
        onlyOwner
    {
        signer = _signer;
    }

    /// @dev Burns the rest of the tokens after the crowdsale end and
    /// send 10% tokens of totalSupply to team address
    function finaliseICO()
        public
        onlyOwner
        icoIsCompleted
    {
        require(!finalised);

        //total sold during ICO
        totalSupply = sub(totalSupply, balanceOf(icoAllocation));
        totalSupply = sub(totalSupply, withDecimals(7750000, decimals));

        //send 5% bounty + 7.5% of total sold tokens to team address
        balances[multisig] = div(mul(totalSupply, 125), 1000);

        //lock 12.5% of sold tokens to team address for one year
        balances[foundationReserve] = div(mul(totalSupply, 125), 1000);

        totalSupply = add(totalSupply, mul(balanceOf(foundationReserve), 2));

        //burn the rest of tokens
        balances[icoAllocation] = 0;

        finalised = true;
    }

    function totalUSD()
      public
      constant
      returns (uint)
    {
       return div(totalPicoUSD, pow(10, usdDecimals));
    }
}
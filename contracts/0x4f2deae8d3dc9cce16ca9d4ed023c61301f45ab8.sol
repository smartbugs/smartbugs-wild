pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


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
        require (msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}



/**
 * @title Authorizable
 * @dev Allows to authorize access to certain function calls
 *
 * ABI
 * [{"constant":true,"inputs":[{"name":"authorizerIndex","type":"uint256"}],"name":"getAuthorizer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"}],"name":"addAuthorized","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"isAuthorized","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"}]
 */
contract Authorizable {

    address[] authorizers;
    mapping(address => uint) authorizerIndex;

    /**
     * @dev Throws if called by any account tat is not authorized.
     */
    modifier onlyAuthorized {
        require(isAuthorized(msg.sender));
        _;
    }

    /**
     * @dev Contructor that authorizes the msg.sender.
     */
    function Authorizable() public {
        authorizers.length = 2;
        authorizers[1] = msg.sender;
        authorizerIndex[msg.sender] = 1;
    }

    /**
     * @dev Function to get a specific authorizer
     * @param authorizerIndex index of the authorizer to be retrieved.
     * @return The address of the authorizer.
     */
    function getAuthorizer(uint authorizerIndex) external constant returns(address) {
        return address(authorizers[authorizerIndex + 1]);
    }

    /**
     * @dev Function to check if an address is authorized
     * @param _addr the address to check if it is authorized.
     * @return boolean flag if address is authorized.
     */
    function isAuthorized(address _addr) public constant returns(bool) {
        return authorizerIndex[_addr] > 0;
    }

    /**
     * @dev Function to add a new authorizer
     * @param _addr the address to add as a new authorizer.
     */
    function addAuthorized(address _addr) external onlyAuthorized {
        authorizerIndex[_addr] = authorizers.length;
        authorizers.length++;
        authorizers[authorizers.length - 1] = _addr;
    }

}

/**
 * @title ExchangeRate
 * @dev Allows updating and retrieveing of Conversion Rates for PAY tokens
 *
 * ABI
 * [{"constant":false,"inputs":[{"name":"_symbol","type":"string"},{"name":"_rate","type":"uint256"}],"name":"updateRate","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"data","type":"uint256[]"}],"name":"updateRates","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_symbol","type":"string"}],"name":"getRate","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"rates","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"timestamp","type":"uint256"},{"indexed":false,"name":"symbol","type":"bytes32"},{"indexed":false,"name":"rate","type":"uint256"}],"name":"RateUpdated","type":"event"}]
 */
contract ExchangeRate is Ownable {

    event RateUpdated(uint timestamp, bytes32 symbol, uint rate);

    mapping(bytes32 => uint) public rates;

    /**
     * @dev Allows the current owner to update a single rate.
     * @param _symbol The symbol to be updated.
     * @param _rate the rate for the symbol.
     */
    function updateRate(string _symbol, uint _rate) public onlyOwner {
        rates[keccak256(_symbol)] = _rate;
        RateUpdated(now, keccak256(_symbol), _rate);
    }

    /**
     * @dev Allows the current owner to update multiple rates.
     * @param data an array that alternates keccak256 hashes of the symbol and the corresponding rate .
     */
    function updateRates(uint[] data) public onlyOwner {
        require (data.length % 2 <= 0);
        uint i = 0;
        while (i < data.length / 2) {
            bytes32 symbol = bytes32(data[i * 2]);
            uint rate = data[i * 2 + 1];
            rates[symbol] = rate;
            RateUpdated(now, symbol, rate);
            i++;
        }
    }

    /**
     * @dev Allows the anyone to read the current rate.
     * @param _symbol the symbol to be retrieved.
     */
    function getRate(string _symbol) public constant returns(uint) {
        return rates[keccak256(_symbol)];
    }

}

/**
 * Math operations with safety checks
 */
library SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
        require(assertion);
    }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
    uint public totalSupply;
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
}




/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant returns (uint);
    function transferFrom(address from, address to, uint value);
    function approve(address spender, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint;

    mapping(address => uint) balances;

    /**
     * @dev Fix for the ERC20 short address attack.
     */
    modifier onlyPayloadSize(uint size) {
        require (size + 4 <= msg.data.length);
        _;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

}




/**
 * @title Standard ERC20 token
 *
 * @dev Implemantation of the basic standart token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint)) allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // if (_value > _allowance) throw;

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on beahlf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint _value) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    /**
     * @dev Function to check the amount of tokens than an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint specifing the amount of tokens still avaible for the spender.
     */
    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint value);
    event MintFinished();
    event Burn(address indexed burner, uint256 value);

    bool public mintingFinished = false;
    uint public totalSupply = 0;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint _amount) onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }


    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(address _who, uint256 _value) onlyOwner public {
        _burn(_who, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who] = balances[_who].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(_who, _value);
        Transfer(_who, address(0), _value);
    }
}


/**
 * @title CBCToken
 * @dev The main CBC token contract
 *
 * ABI
 * [{"constant":true,"inputs":[],"name":"mintingFinished","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"startTrading","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"mint","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"tradingStarted","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"finishMinting","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Mint","type":"event"},{"anonymous":false,"inputs":[],"name":"MintFinished","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]
 */
contract CBCToken is MintableToken {

    string public name = "Crypto Boss Coin";
    string public symbol = "CBC";
    uint public decimals = 18;

    bool public tradingStarted = false;
    /**
     * @dev modifier that throws if trading has not started yet
     */
    modifier hasStartedTrading() {
        require(tradingStarted);
        _;
    }


    /**
     * @dev Allows the owner to enable the trading. This can not be undone
     */
    function startTrading() onlyOwner {
        tradingStarted = true;
    }

    /**
     * @dev Allows anyone to transfer the PAY tokens once trading has started
     * @param _to the recipient address of the tokens.
     * @param _value number of tokens to be transfered.
     */
    function transfer(address _to, uint _value) hasStartedTrading {
        super.transfer(_to, _value);
    }

    /**
    * @dev Allows anyone to transfer the CBC tokens once trading has started
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint the amout of tokens to be transfered
    */
    function transferFrom(address _from, address _to, uint _value) hasStartedTrading {
        super.transferFrom(_from, _to, _value);
    }

}

/**
 * @title MainSale
 * @dev The main CBC token sale contract
 *
 * ABI
 * [{"constant":false,"inputs":[{"name":"_multisigVault","type":"address"}],"name":"setMultisigVault","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"authorizerIndex","type":"uint256"}],"name":"getAuthorizer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"exchangeRate","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"altDeposits","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"recipient","type":"address"},{"name":"tokens","type":"uint256"}],"name":"authorizedCreateTokens","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"finishMinting","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_exchangeRate","type":"address"}],"name":"setExchangeRate","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_token","type":"address"}],"name":"retrieveTokens","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"totalAltDeposits","type":"uint256"}],"name":"setAltDeposit","outputs":[],"payable":false,"type":"function"},{"constant":!1,"inputs":[{"name":"victim","type":"address"},{"name":"amount","type":"uint256"}],"name":"burnTokens","outputs":[],"payable":!1,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"start","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"recipient","type":"address"}],"name":"createTokens","outputs":[],"payable":true,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"}],"name":"addAuthorized","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"multisigVault","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_hardcap","type":"uint256"}],"name":"setHardCap","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_start","type":"uint256"}],"name":"setStart","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"token","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"isAuthorized","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"recipient","type":"address"},{"indexed":false,"name":"ether_amount","type":"uint256"},{"indexed":false,"name":"pay_amount","type":"uint256"},{"indexed":false,"name":"exchangerate","type":"uint256"}],"name":"TokenSold","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"recipient","type":"address"},{"indexed":false,"name":"pay_amount","type":"uint256"}],"name":"AuthorizedCreate","type":"event"},{"anonymous":false,"inputs":[],"name":"MainSaleClosed","type":"event"}]
 */
contract MainSale is Ownable, Authorizable {
    using SafeMath for uint;
    event TokenSold(address recipient, uint ether_amount, uint pay_amount, uint exchangerate);
    event AuthorizedCreate(address recipient, uint pay_amount);
    event AuthorizedBurn(address receiver, uint value);
    event AuthorizedStartTrading();
    event MainSaleClosed();
    CBCToken public token = new CBCToken();

    address public multisigVault;

    uint hardcap = 100000000000000 ether;
    ExchangeRate public exchangeRate;

    uint public altDeposits = 0;
    uint public start = 1525996800;

    /**
     * @dev modifier to allow token creation only when the sale IS ON
     */
    modifier saleIsOn() {
        require(now > start && now < start + 28 days);
        _;
    }

    /**
     * @dev modifier to allow token creation only when the hardcap has not been reached
     */
    modifier isUnderHardCap() {
        require(multisigVault.balance + altDeposits <= hardcap);
        _;
    }

    /**
     * @dev Allows anyone to create tokens by depositing ether.
     * @param recipient the recipient to receive tokens.
     */
    function createTokens(address recipient) public isUnderHardCap saleIsOn payable {
        uint rate = exchangeRate.getRate("ETH");
        uint tokens = rate.mul(msg.value).div(1 ether);
        token.mint(recipient, tokens);
        require(multisigVault.send(msg.value));
        TokenSold(recipient, msg.value, tokens, rate);
    }

    /**
     * @dev Allows to set the toal alt deposit measured in ETH to make sure the hardcap includes other deposits
     * @param totalAltDeposits total amount ETH equivalent
     */
    function setAltDeposit(uint totalAltDeposits) public onlyOwner {
        altDeposits = totalAltDeposits;
    }

    /**
     * @dev Allows authorized acces to create tokens. This is used for Bitcoin and ERC20 deposits
     * @param recipient the recipient to receive tokens.
     * @param tokens number of tokens to be created.
     */
    function authorizedCreateTokens(address recipient, uint tokens) public onlyAuthorized {
        token.mint(recipient, tokens);
        AuthorizedCreate(recipient, tokens);
    }

    function authorizedStartTrading() public onlyAuthorized {
        token.startTrading();
        AuthorizedStartTrading();
    }

    /**
     * @dev Allows authorized acces to burn tokens.
     * @param receiver the receiver to receive tokens.
     * @param value number of tokens to be created.
     */
    function authorizedBurnTokens(address receiver, uint value) public onlyAuthorized {
        token.burn(receiver, value);
        AuthorizedBurn(receiver, value);
    }

    /**
     * @dev Allows the owner to set the hardcap.
     * @param _hardcap the new hardcap
     */
    function setHardCap(uint _hardcap) public onlyOwner {
        hardcap = _hardcap;
    }

    /**
     * @dev Allows the owner to set the starting time.
     * @param _start the new _start
     */
    function setStart(uint _start) public onlyOwner {
        start = _start;
    }

    /**
     * @dev Allows the owner to set the multisig contract.
     * @param _multisigVault the multisig contract address
     */
    function setMultisigVault(address _multisigVault) public onlyOwner {
        if (_multisigVault != address(0)) {
            multisigVault = _multisigVault;
        }
    }

    /**
     * @dev Allows the owner to set the exchangerate contract.
     * @param _exchangeRate the exchangerate address
     */
    function setExchangeRate(address _exchangeRate) public onlyOwner {
        exchangeRate = ExchangeRate(_exchangeRate);
    }

    /**
     * @dev Allows the owner to finish the minting. This will create the
     * restricted tokens and then close the minting.
     * Then the ownership of the PAY token contract is transfered
     * to this owner.
     */
    function finishMinting() public onlyOwner {
        uint issuedTokenSupply = token.totalSupply();
        uint restrictedTokens = issuedTokenSupply.mul(49).div(51);
        token.mint(multisigVault, restrictedTokens);
        token.finishMinting();
        token.transferOwnership(owner);
        MainSaleClosed();
    }

    /**
     * @dev Allows the owner to transfer ERC20 tokens to the multi sig vault
     * @param _token the contract address of the ERC20 contract
     */
    function retrieveTokens(address _token) public onlyOwner {
        ERC20 token = ERC20(_token);
        token.transfer(multisigVault, token.balanceOf(this));
    }

    /**
     * @dev Fallback function which receives ether and created the appropriate number of tokens for the
     * msg.sender.
     */
    function() external payable {
        createTokens(msg.sender);
    }

}

/**
* It is insurance smart-contract for the SmartContractBank.
* You can buy insurance for 0.1 ETH and if you do not take 100% profit when balance of
* the SmartContractBank will be lesser then 0.01 you can receive part of insurance fund depend on your not received money.
*
* To buy insurance:
* Send to the contract address 0.01 ETH, and you will be accounted to.
*
* To receive insurance payout:
* Send to the contract address 0 ETH, and you will receive part of insurance depend on your not received money.
* If you already received 100% from your deposit, you will take error.
*/
contract InsuranceFund {
    using SafeMath for uint256;

    /**
    * @dev Structure for evaluating payout
    * @param deposit Duplicated from SmartContractBank deposit
    * @param withdrawals Duplicated from SmartContractBank withdrawals
    * @param insured Flag for available payout
    */
    struct Investor {
        uint256 deposit;
        uint256 withdrawals;
        bool insured;
    }
    mapping (address => Investor) public investors;
    uint public countOfInvestors;

    bool public startOfPayments = false;
    uint256 public totalSupply;

    uint256 public totalNotReceived;
    address public SCBAddress;

    SmartContractBank SCBContract;

    event Paid(address investor, uint256 amount, uint256  notRecieve, uint256  partOfNotReceived);
    event SetInfo(address investor, uint256  notRecieve, uint256 deposit, uint256 withdrawals);

    /**
    * @dev  Modifier for access from the SmartContractBank
    */
    modifier onlySCB() {
        require(msg.sender == SCBAddress, "access denied");
        _;
    }

    /**
    * @dev  Setter the SmartContractBank address. Address can be set only once.
    * @param _SCBAddress Address of the SmartContractBank
    */
    function setSCBAddress(address _SCBAddress) public {
        require(SCBAddress == address(0x0));
        SCBAddress = _SCBAddress;
        SCBContract = SmartContractBank(SCBAddress);
    }

    /**
    * @dev  Private setter info about investor. Can be call if payouts not started.
    * Needing for evaluating not received total amount without loops.
    * @param _address Investor's address
    * @param _address Investor's deposit
    * @param _address Investor's withdrawals
    */
    function privateSetInfo(address _address, uint256 deposit, uint256 withdrawals) private{
        if (!startOfPayments) {
            Investor storage investor = investors[_address];

            if (investor.deposit != deposit){
                totalNotReceived = totalNotReceived.add(deposit.sub(investor.deposit));
                investor.deposit = deposit;
            }

            if (investor.withdrawals != withdrawals){
                uint256 different;
                if (deposit <= withdrawals){
                    different = deposit.sub(withdrawals);
                    if (totalNotReceived >= different)
                        totalNotReceived = totalNotReceived.sub(different);
                    else
                        totalNotReceived = 0;
                } else {
                    different = withdrawals.sub(investor.withdrawals);
                    if (totalNotReceived >= different)
                        totalNotReceived = totalNotReceived.sub(different);
                    else
                        totalNotReceived = 0;
                }
                investor.withdrawals = withdrawals;
            }

            emit SetInfo(_address, totalNotReceived, investor.deposit, investor.withdrawals);
        }
    }

    /**
    * @dev  Setter info about investor from the SmartContractBank.
    * @param _address Investor's address
    * @param _address Investor's deposit
    * @param _address Investor's withdrawals
    */
    function setInfo(address _address, uint256 deposit, uint256 withdrawals) public onlySCB {
        privateSetInfo(_address, deposit, withdrawals);
    }

    /**
    * @dev  Delete insured from the SmartContractBank.
    * @param _address Investor's address
    */
    function deleteInsured(address _address) public onlySCB {
        Investor storage investor = investors[_address];
        investor.deposit = 0;
        investor.withdrawals = 0;
        investor.insured = false;
        countOfInvestors--;
    }

    /**
    * @dev  Function for starting payouts and stopping receive funds.
    */
    function beginOfPayments() public {
        require(address(SCBAddress).balance < 0.1 ether && !startOfPayments);
        startOfPayments = true;
        totalSupply = address(this).balance;
    }

    /**
    * @dev  Payable function for receive funds, buying insurance and receive insurance payouts .
    */
    function () external payable {
        Investor storage investor = investors[msg.sender];
        if (msg.value > 0 ether){
            require(!startOfPayments);
            if (msg.sender != SCBAddress && msg.value >= 0.1 ether) {
                uint256 deposit;
                uint256 withdrawals;
                (deposit, withdrawals, investor.insured) = SCBContract.setInsured(msg.sender);
                countOfInvestors++;
                privateSetInfo(msg.sender, deposit, withdrawals);
            }
        } else if (msg.value == 0){
            uint256 notReceived = investor.deposit.sub(investor.withdrawals);
            uint256 partOfNotReceived = notReceived.mul(100).div(totalNotReceived);
            uint256 payAmount = totalSupply.div(100).mul(partOfNotReceived);
            require(startOfPayments && investor.insured && notReceived > 0);
            investor.insured = false;
            msg.sender.transfer(payAmount);
            emit Paid(msg.sender, payAmount, notReceived, partOfNotReceived);
        }
    }
}

/**
* It is "Smart Contract Bank" smart-contract.
* - You can take profit 4% per day.
* - You can buy insurance and receive part of insurance fund when balance will be lesser then 0.01 ETH.
* - You can increase your percent on 0.5% if you have 10 CBC Token (0x790bFaCaE71576107C068f494c8A6302aea640cb ico.cryptoboss.me)
*    1. To buy CBC Tokens send 0.01 ETH on Sale Token Address 0x369fc7de8aee87a167244eb10b87eb3005780872
*    2. To increase your profit percent if you already have tokens, you should send to SmartContractBank address 0.0001 ETH
* - If your percent balance will be beyond of 200% you will able to take your profit only once time.
* HODL your profit and take more then 200% percents.
* - If balance of contract will be lesser then 0.1 ETH every user able stop contract and start insurance payments.
*
* - Percent of profit depends on balance of contract. Percent chart below:
* - If balance < 100 ETH - 4% per day
* - If balance >= 100 ETH and < 600 - 2% per day
* - If balance >= 600 ETH and < 1000 - 1% per day
* - If balance >= 1000 ETH and < 3000 - 0.9% per day
* - If balance >= 3000 ETH and < 5000 - 0.8% per day
* - If balance >= 5000  - 0.7% per day
* - If balance of contract will be beyond threshold, your payout will be reevaluate depends on currently balance of contract
* -
* - You can calm your profit every 5 minutes
*
* To invest:
* - Send minimum 0.01 ETH to contract address
*
* To calm profit:
* - Send 0 ETH to contract address
*/
contract SmartContractBank {
    using SafeMath for uint256;
    struct Investor {
        uint256 deposit;
        uint256 paymentTime;
        uint256 withdrawals;
        bool increasedPercent;
        bool insured;
    }
    uint public countOfInvestors;
    mapping (address => Investor) public investors;

    uint256 public minimum = 0.01 ether;
    uint step = 5 minutes;
    uint ownerPercent = 4;
    uint promotionPercent = 8;
    uint insurancePercent = 2;
    bool public closed = false;
    
    address public ownerAddressOne = 0xaB5007407d8A686B9198079816ebBaaa2912ecC1;
    address public ownerAddressTwo = 0x4A5b00cDDAeE928B8De7a7939545f372d6727C06;
    address public promotionAddress = 0x3878E2231f7CA61c0c1D0Aa3e6962d7D23Df1B3b;
    address public insuranceFundAddress;
    address CBCTokenAddress = 0x790bFaCaE71576107C068f494c8A6302aea640cb;
    address MainSaleAddress = 0x369fc7de8aee87a167244eb10b87eb3005780872;

    InsuranceFund IFContract;

    event Invest(address investor, uint256 amount);
    event Withdraw(address investor, uint256 amount);
    event UserDelete(address investor);

    /**
    * @dev Modifier for access from the InsuranceFund
    */
    modifier onlyIF() {
        require(insuranceFundAddress == msg.sender, "access denied");
        _;
    }

    /**
    * @dev  Setter the InsuranceFund address. Address can be set only once.
    * @param _insuranceFundAddress Address of the InsuranceFund
    */
    function setInsuranceFundAddress(address _insuranceFundAddress) public{
        require(insuranceFundAddress == address(0x0));
        insuranceFundAddress = _insuranceFundAddress;
        IFContract = InsuranceFund(insuranceFundAddress);
    }

    /**
    * @dev  Set insured from the InsuranceFund.
    * @param _address Investor's address
    * @return Object of investor's information
    */
    function setInsured(address _address) public onlyIF returns(uint256, uint256, bool){
        Investor storage investor = investors[_address];
        investor.insured = true;
        return (investor.deposit, investor.withdrawals, investor.insured);
    }

    /**
    * @dev  Function for close entrance.
    */
    function closeEntrance() public {
        require(address(this).balance < 0.1 ether && !closed);
        closed = true;
    }

    /**
    * @dev Get percent depends on balance of contract
    * @return Percent
    */
    function getPhasePercent() view public returns (uint){
        Investor storage investor = investors[msg.sender];
        uint contractBalance = address(this).balance;
        uint percent;
        if (contractBalance < 100 ether) {
            percent = 40;
        }
        if (contractBalance >= 100 ether && contractBalance < 600 ether) {
            percent = 20;
        }
        if (contractBalance >= 600 ether && contractBalance < 1000 ether) {
            percent = 10;
        }
        if (contractBalance >= 1000 ether && contractBalance < 3000 ether) {
            percent = 9;
        }
        if (contractBalance >= 3000 ether && contractBalance < 5000 ether) {
            percent = 8;
        }
        if (contractBalance >= 5000 ether) {
            percent = 7;
        }

        if (investor.increasedPercent){
            percent = percent.add(5);
        }

        return percent;
    }

    /**
    * @dev Allocation budgets
    */
    function allocation() private{
        ownerAddressOne.transfer(msg.value.mul(ownerPercent.div(2)).div(100));
        ownerAddressTwo.transfer(msg.value.mul(ownerPercent.div(2)).div(100));
        promotionAddress.transfer(msg.value.mul(promotionPercent).div(100));
        insuranceFundAddress.transfer(msg.value.mul(insurancePercent).div(100));
    }

    /**
    * @dev Evaluate current balance
    * @param _address Address of investor
    * @return Payout amount
    */
    function getUserBalance(address _address) view public returns (uint256) {
        Investor storage investor = investors[_address];
        uint percent = getPhasePercent();
        uint256 differentTime = now.sub(investor.paymentTime).div(step);
        uint256 differentPercent = investor.deposit.mul(percent).div(1000);
        uint256 payout = differentPercent.mul(differentTime).div(288);

        return payout;
    }

    /**
    * @dev Withdraw profit from contract. Investor will be deleted if he will try withdraw after received x2
    */
    function withdraw() private {
        Investor storage investor = investors[msg.sender];
        uint256 balance = getUserBalance(msg.sender);
        if (investor.deposit > 0 && address(this).balance > balance && balance > 0) {
            uint256 tempWithdrawals = investor.withdrawals;

            investor.withdrawals = investor.withdrawals.add(balance);
            investor.paymentTime = now;

            if (investor.withdrawals >= investor.deposit.mul(2)){
                investor.deposit = 0;
                investor.paymentTime = 0;
                investor.withdrawals = 0;
                investor.increasedPercent = false;
                investor.insured = false;
                countOfInvestors--;
                if (investor.insured)
                    IFContract.deleteInsured(msg.sender);
                emit UserDelete(msg.sender);
            } else {
                if (investor.insured && tempWithdrawals < investor.deposit){
                    IFContract.setInfo(msg.sender, investor.deposit, investor.withdrawals);
                }
            }
            msg.sender.transfer(balance);
            emit Withdraw(msg.sender, balance);
        }

    }

    /**
    * @dev Increase percent with CBC Token
    */
    function increasePercent() private {
        CBCToken CBCTokenContract = CBCToken(CBCTokenAddress);
        MainSale MainSaleContract = MainSale(MainSaleAddress);
        Investor storage investor = investors[msg.sender];
        if (CBCTokenContract.balanceOf(msg.sender) >= 10){
            MainSaleContract.authorizedBurnTokens(msg.sender, 10);
            investor.increasedPercent = true;
        }
    }

    /**
    * @dev  Payable function for
    * - receive funds (send minimum 0.01 ETH),
    * - increase percent and receive profit (send 0.0001 ETH if you already have CBC Tokens on your address).
    * - calm your profit (send 0 ETH)
    */
    function () external payable {
        require(!closed);
        Investor storage investor = investors[msg.sender];
        if (msg.value > 0){
            require(msg.value >= minimum);

            withdraw();

            if (investor.deposit == 0){
                countOfInvestors++;
            }

            investor.deposit = investor.deposit.add(msg.value);
            investor.paymentTime = now;

            if (investor.insured){
                IFContract.setInfo(msg.sender, investor.deposit, investor.withdrawals);
            }
            allocation();
            emit Invest(msg.sender, msg.value);
        } if (msg.value == 0.0001 ether) {
            increasePercent();
        } else {
            withdraw();
        }
    }
}
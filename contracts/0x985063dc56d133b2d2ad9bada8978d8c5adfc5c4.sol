pragma solidity ^0.4.17;

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) returns (bool);
    function approve(address spender, uint256 value) returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
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
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) returns (bool) {

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
     * @return A uint256 specifing the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
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
    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


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
    function mint(address _to, uint256 _amount) onlyOwner returns (bool) {
        return mintInternal(_to, _amount);
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

    function mintInternal(address _to, uint256 _amount) internal canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }
}

contract CustomToken is MintableToken {

    string public name;

    string public currentState = 'Inactive';

    string public symbol;

    uint8 public decimals;

    uint256 public limitPreIcoTokens;

    uint256 public weiPerToken;

    uint256 public limitIcoTokens;

    bool public preIcoActive = false;

    bool public icoActive = false;

    bool public preBountyAdded = false;

    bool public bountyAdded = false;

    bool public ownersStakeAdded = false;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public ratePreIco;

    uint256 public rateIco;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // Only Owner can transfer balances and mint ROOTS without payment.
    // Everybody can buy IOU ROOT token by sending some amount of ETH to the contract.
    // Amount of purchased ROOTS determined by the Rate.
    // All ETH are going to Wallet address.
    // Owner can finalize the contract by `finishMinting` transaction
    function CustomToken(
    uint256 _ratePre,
    uint256 _rate,
    address _wallet,
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _weiPerToken,
    uint256 _limitPreICO,
    uint256 _limitICO
    ) {
        require(_rate > 0);
        require(_wallet != 0x0);

        rateIco = _rate;
        ratePreIco = _ratePre;
        wallet = _wallet;
        name = _name;
        weiPerToken = _weiPerToken;
        symbol = _symbol;
        decimals = _decimals;
        limitPreIcoTokens = _limitPreICO;
        limitIcoTokens = _limitICO;
    }

    function transfer(address _to, uint _value) onlyOwner returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) onlyOwner returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function () payable {
        buyTokens(msg.sender);
    }

    function changeWallet(address _newWallet) onlyOwner returns (bool) {
        require(_newWallet != 0x0);
        wallet = _newWallet;
        return true;
    }

    function changeWeiPerToken(uint256 _newWeiPerToken) onlyOwner returns (bool) {
        require(weiPerToken != 0);
        weiPerToken = _newWeiPerToken;
        return true;
    }

    function stopIco(address _addrToSendSteak) onlyOwner returns (bool) {
        require(!bountyAdded && !ownersStakeAdded);
        require(_addrToSendSteak != 0x0);
        icoActive = false;
        preIcoActive = false;
        currentState = "Ico finished";
        addOwnersStakeAndBonty(_addrToSendSteak);
        mintingFinished = true;
        MintFinished();
        return true;
    }

    function stopPreIco() onlyOwner returns (bool) {
        require(!preBountyAdded);
        preIcoActive = false;
        currentState = "Pre Ico finished";
        addPreBounty();
        return true;
    }

    function startPreIco() onlyOwner returns (bool) {
        require(!icoActive);
        icoActive = false;
        preIcoActive = true;
        currentState = "Pre Ico";
        return true;
    }

    function startIco() onlyOwner returns (bool) {
        icoActive = true;
        preIcoActive = false;
        currentState = "Ico";
        return true;
    }

    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(msg.value > 0);

        uint256 weiAmount = msg.value;

        uint256 rate = ratePreIco;
        if(icoActive) rate = rateIco;

        // calculate token amount to be created
        uint256 tokens = weiAmount.div(weiPerToken).mul(rate);

        require((preIcoActive && totalSupply + tokens <= limitPreIcoTokens) || (icoActive && totalSupply + tokens <= limitIcoTokens) );

        mintInternal(beneficiary, tokens);
        TokenPurchase(
        msg.sender,
        beneficiary,
        weiAmount,
        tokens
        );

        forwardFunds();
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    function addPreBounty() internal onlyOwner returns (bool status) {
        require(!preBountyAdded);
        uint256 additionalCount = totalSupply * 6/100;
        preBountyAdded = true;
        mintInternal(wallet, additionalCount);
        return true;
    }

    function addOwnersStakeAndBonty(address _addrToSendSteak) internal onlyOwner returns (bool status) {
        require(!bountyAdded && !ownersStakeAdded);
        uint256 additionalCount = totalSupply * 14/100;
        uint256 additionalOwnersStakeCount = totalSupply * 14/100;
        bountyAdded = true;
        ownersStakeAdded = true;
        mintInternal(wallet, additionalCount);
        mintInternal(_addrToSendSteak, additionalOwnersStakeCount);
        return true;
    }

}
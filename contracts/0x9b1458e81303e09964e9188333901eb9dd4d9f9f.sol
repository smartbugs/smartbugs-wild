pragma solidity ^0.4.13;

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
    constructor() public {
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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract NoboToken is Ownable {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 totalSupply_;

    constructor() public {
        name = "Nobotoken";
        symbol = "NBX";
        decimals = 18;
        totalSupply_ = 0;
    }

    // -----------------------------------------------------------------------
    // ------------------------- GENERAL ERC20 -------------------------------
    // -----------------------------------------------------------------------
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    /*
    * @dev tracks token balances of users
    */
    mapping (address => uint256) balances;

    /*
    * @dev transfer token for a specified address
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /*
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    /*
    * @dev gets the balance of the specified address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }



    // -----------------------------------------------------------------------
    // ------------------------- ALLOWANCE RELEATED --------------------------
    // -----------------------------------------------------------------------

    /*
    * @dev tracks the allowance an address has from another one
    */
    mapping (address => mapping (address => uint256)) internal allowed;

    /*
    * @dev transfers token from one address to another, must have allowance
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool success)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /*
    * @dev gives allowance to spender, works together with transferFrom
    */
    function approve(
        address _spender,
        uint256 _value
    )
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
    * @dev used to increase the allowance a spender has
    */
    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] =
            allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /*
    * @dev used to decrease the allowance a spender has
    */
    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        returns (bool success)
    {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /*
    * @dev used to check what allowance a spender has from the owner
    */
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    // -----------------------------------------------------------------------
    //--------------------------- MINTING RELEATED ---------------------------
    // -----------------------------------------------------------------------
    /*
    * @title Mintable token
    * @dev instead of another contract, all mintable functionality goes here
    */
    event Mint(
        address indexed to,
        uint256 amount
    );
    event MintFinished();

    /*
    * @dev signifies whether or not minting process is over
    */
    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }


    /*
    * @dev minting of tokens, restricted to owner address (crowdsale)
    */
    function mint(
        address _to,
        uint256 _amount
    )
        public
        onlyOwner
        canMint
        returns (bool success)
    {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /*
    * @dev Function to stop minting new tokens.
    */
    function finishMinting() onlyOwner canMint public returns (bool success) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

contract RefundVault is Ownable {
    using SafeMath for uint256;

    enum State { Active, Refunding, Closed }

    mapping (address => uint256) public deposited;
    address public wallet;
    State public state;

    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);

    /**
   * @param _wallet Vault address
   */
    constructor(address _wallet) public {
        require(_wallet != address(0));
        wallet = _wallet;
        state = State.Active;
    }

    /**
   * @param investor Investor address
   */
    function deposit(address investor) onlyOwner public payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function close() onlyOwner public {
        require(state == State.Active);
        state = State.Closed;
        emit Closed();
        wallet.transfer(address(this).balance);
    }

    function enableRefunds() onlyOwner public {
        require(state == State.Active);
        state = State.Refunding;
        emit RefundsEnabled();
    }

    /**
   * @param investor Investor address
   */
    function refund(address investor) public {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        emit Refunded(investor, depositedValue);
    }

    function batchRefund(address[] _investors) public {
        require(state == State.Refunding);
        for (uint256 i = 0; i < _investors.length; i++) {
           require(_investors[i] != address(0));
           uint256 _depositedValue = deposited[_investors[i]];
           require(_depositedValue > 0);
           deposited[_investors[i]] = 0;
           _investors[i].transfer(_depositedValue);
           emit Refunded(_investors[i], _depositedValue);
        }
    }
}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract TimedAccess is Ownable {
   /*
    * @dev Requires msg.sender to have valid access message.
    * @param _v ECDSA signature parameter v.
    * @param _r ECDSA signature parameters r.
    * @param _s ECDSA signature parameters s.
    * @param _blockNum used to limit access time, will be checked if signed
    * @param _etherPrice must be checked to ensure no tampering
    */
    address public signer;

    function _setSigner(address _signer) internal {
        require(_signer != address(0));
        signer = _signer;
    }

    modifier onlyWithValidCode(
        bytes32 _r,
        bytes32 _s,
        uint8 _v,
        uint256 _blockNum,
        uint256 _etherPrice
    )
    {
        require(
            isValidAccessMessage(
                _r,
                _s,
                _v,
                _blockNum,
                _etherPrice,
                msg.sender
            ),
            "Access code is incorrect or expired."
        );
        _;
    }


    /*
    * @dev Verifies if message was signed by owner to give access to
    *      _add for this contract.
    *      Assumes Geth signature prefix (\x19Ethereum Signed Message:\n32).
    * @param _sender Address of agent with access
    * @return Validity of access message for a given address.
    */
    function isValidAccessMessage(
        bytes32 _r,
        bytes32 _s,
        uint8 _v,
        uint256 _blockNum,
        uint256 _etherPrice,
        address _sender
    )
        view
        public
        returns (bool)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                _blockNum,
                _etherPrice,
                _sender
            )
        );
        bool isValid = (
            signer == ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n32",
                        hash
                    )
                ),
                _v,
                _r,
                _s
            )
        );

        // after 123 blocks have passed, no purchase is possible
        // (roughly 30 minutes)
        bool isStillTime = (_blockNum + 123 > block.number);

        return (isValid && isStillTime);
    }
}

contract NoboCrowdsale is TimedAccess {

    using SafeMath for uint256;

    /*
    * @dev TokenAmountGetter: a library to calculate appropiate token amount
    */
    using TokenAmountGetter for uint256;

    // -----------------------------------------------------------------------
    // ---------------------------- VARIABLES --------------------------------
    // -----------------------------------------------------------------------

    /*
    * @dev the supervisor can prevent the owner from having control
    */
    address public supervisor;

    /*
    * @dev wallet = where the ether goes to in a successful crowdsale
    */
    address public wallet;

    /*
    * @dev token is the actual ERC20 token contract
    */
    NoboToken public token;

    /*
    * @dev RefundVault: where the ether is stored, used to enable refunds
    */
    RefundVault public vault;

    /*
    * @dev the base rate for NBX, without any bonuses
    */
    uint256  public baseRate;

   /*
    * @dev startTime regulates the time bonuses, set when crowdsale begins
    */
    uint256  public startTime;

    /*
    * @dev softCap = goal of our crowdsale, if it is not reached,
    *   customers can be refunded
    */
    uint256 public softCap;

    /*
    * @dev maximum amount of ether we can collect in this crowdsale
    */
    uint256 public hardCap;

    /*
    * @dev the status controls the accessibilty of certain functions, e.g. the
    *   purchase token function (in combination with the modifier onlyDuring)
    */
    enum Status { unstarted, started, ended, paused }
    Status public status;

    /*
    * @dev balances stores the balances an investor is eligible to
    */
    mapping(address => uint256) public balances;

    /*
    * @dev accessAllowed-bit needs to be true for certain functions,
    *   can only be switched by supervisor
    */
    bool public accessAllowed;


    // ------------------------------------------------------------------------
    // ------------------------------ EVENTS ----------------------------------
    // ------------------------------------------------------------------------

    /*
    * @dev NoAccessCode emitted when tx is made without data field
    */
    event NoAccessCode(address indexed sender);

    /*
    * @dev CapReached signals the end of the crowdsale to us
    */
    event CapReached(address indexed sender, uint256 indexed etherAmount);

    /*
    * @dev PurchaseTooSmall is emitted when tx with less than 0.1 ETH is made
    */
    event PurchaseTooSmall(address indexed sender, uint256 indexed etherAmount);

    /*
    * @dev TokenPurchase is the general log for a legit purchase
    */
    event TokenPurchase(
        address indexed investor,
        uint256 indexed etherAmount,
        uint256 indexed etherPrice,
        uint256 tokenAmount
    );

    /*
    * @dev AccessChanged is emitted when the supervisor dis-/allows functions
    */
    event AccessChanged(bool indexed accessAllowed);

    /*
    * @dev SignerChanged signals the change of the signer address,
    *   the one against whcih the signature of the access code is compared to
    */
    event SignerChanged(address indexed previousSigner, address indexed newSigner);

    /*
    * @dev StatusChanged signals the change of crowdsale stages
    */
    event StatusChanged(
        Status indexed previousStatus,
        Status indexed newStatus
    );

    // ------------------------------------------------------------------------
    // --------------------------- MODIFIER -----------------------------------
    // ------------------------------------------------------------------------

    /*
    * @dev restricts functions to certain crowdsale stages
    */
    modifier onlyDuring(Status _status) {
        require (status == _status);
        _;
    }

    /*
    * @dev akin to onlyOwner
    */
    modifier onlySupervisor() {
        require(supervisor == msg.sender);
        _;
    }

    /*
    * @dev certain functions need permission from the supervisor
    */
    modifier whenAccessAllowed() {
        require(accessAllowed);
        _;
    }

    // ------------------------------------------------------------------------
    // --------------------------- CONSTRUCTOR --------------------------------
    // ------------------------------------------------------------------------

    /*
    * @dev the constructor needs the token contract address
    * @dev the crowdsale contract needs to be made owner of the token contract
    */
    constructor (
        address _tokenAddress,
        address _signer,
        address _supervisor,
        address _wallet
    )
        public
    {
        require(_tokenAddress != address(0));
        require(_signer != address(0));
        require(_supervisor!= address(0));
        require(_wallet != address(0));
        signer = _signer;
        supervisor = _supervisor;
        wallet = _wallet;
        token = NoboToken(_tokenAddress);
        vault = new RefundVault(wallet);
        baseRate = 500;
        softCap = 25000 ether;
        hardCap = 250000 ether;
        status = Status.unstarted;
        accessAllowed = false;
    }

    /*
    * @dev send ether back to sender when no access code is specified
    */
    function() public payable {
        emit NoAccessCode(msg.sender);
        msg.sender.transfer(msg.value);
    }

    // ------------------------------------------------------------------------
    // -------------------------- MAIN PURCHASE -------------------------------
    // ------------------------------------------------------------------------

    /*
    * @dev called by users to buy token, whilst providing their access code
    *   for more information about v, r and as see TimedAccess contract
    * @param _v ECDSA signature parameter v.
    * @param _r ECDSA signature parameters r.
    * @param _s ECDSA signature parameters s.
    * @param _blockNum used to make sure the user has only a certain timeperiod
    *   to buy the tokens (after a set amount of blocks the function will
    *   not execute anymore. Checked in TimedAccess
    * @param _etherPrice used to get the bonus for the user
    */
    function purchaseTokens(
        bytes32 _r,
        bytes32 _s,
        uint8 _v,
        uint256 _blockNum,
        uint256 _etherPrice
    )
        public
        payable
        onlyDuring(Status.started)
        onlyWithValidCode( _r, _s, _v, _blockNum, _etherPrice)
    {
        if (_isPurchaseValid(msg.sender, msg.value)) {
            uint256 _etherAmount = msg.value;
            uint256 _tokenAmount = _etherAmount.getTokenAmount(
                _etherPrice,
                startTime,
                baseRate
            );
            emit TokenPurchase(msg.sender, _etherAmount, _etherPrice, _tokenAmount);
            // registering purchase in a balance mapping
            _registerPurchase(msg.sender, _tokenAmount);
        }
    }

    /*
    * @dev checks if ether Amount is sufficient (measured in Euro)
    *   and if the hardcap would be reached
    */
    function _isPurchaseValid(
        address _sender,
        uint256 _etherAmount
    )
        internal
        returns (bool)
    {
        // if raised ether would be more than hardcap, revert
        if (getEtherRaised().add(_etherAmount) > hardCap) {
            _sender.transfer(_etherAmount);
            emit CapReached(_sender, getEtherRaised()); // for testing
            return false;
        }
        if(_etherAmount <  0.1 ether) {
            _sender.transfer(_etherAmount);
            emit PurchaseTooSmall(_sender, _etherAmount);
            return false;
        }
        return true;
    }

    /**
    * @dev Overrides parent by storing balances instead of issuing tokens right away.
    * @param _investor Token purchaser
    * @param _tokenAmount Amount of tokens purchased
    */
    function _registerPurchase(
        address _investor,
        uint256 _tokenAmount
    )
        internal
    {
        // registering balance of tokens in mapping for the customer
        balances[_investor] = balances[_investor].add(_tokenAmount);
        // and registering in the refundvault
        vault.deposit.value(msg.value)(_investor);
    }

    /*
    * @dev used to check if refunds need to be enabled
    */
    function _isGoalReached() internal view returns (bool) {
	    return (getEtherRaised() >= softCap);
    }

    /*
    * @dev used to check how much ether is in the refundvault
    */
    function getEtherRaised() public view returns (uint256) {
        return address(vault).balance;
    }

    // ------------------------------------------------------------------------
    // ------------------------- STAGE MANAGEMENT -----------------------------
    // ------------------------------------------------------------------------

    /*
    * @dev used to start Crowdsale, sets the starttime for bonuses
    */
    function startCrowdsale()
        external
        whenAccessAllowed
        onlyOwner
        onlyDuring(Status.unstarted)
    {
        emit StatusChanged(status, Status.started);
        status = Status.started;
        startTime = now;
    }

    /*
    * @dev ends Crowdsale, enables refunding of contracts
    */
    function endCrowdsale()
        external
        whenAccessAllowed
        onlyOwner
        onlyDuring(Status.started)
    {
        emit StatusChanged(status, Status.ended);
        status = Status.ended;
        if(_isGoalReached()) {
            vault.close();
        } else {
            vault.enableRefunds();
        }
    }

    /*
    * @dev can be called in ongoing Crowdsale
    */
    function pauseCrowdsale()
        external
        onlySupervisor
        onlyDuring(Status.started)
    {
        emit StatusChanged(status, Status.paused);
        status = Status.paused;
    }

    /*
    * @dev if problem was fixed, Crowdsale can resume
    */
    function resumeCrowdsale()
        external
        onlySupervisor
        onlyDuring(Status.paused)
    {
        emit StatusChanged(status, Status.started);
        status = Status.started;
    }

    /*
    * @dev if problem cant be resolved, cancel the crowdsale
    */
    function cancelCrowdsale()
        external
        onlySupervisor
        onlyDuring(Status.paused)
    {
        emit StatusChanged(status, Status.ended);
        status = Status.ended;
        vault.enableRefunds();
    }

    // ------------------------------------------------------------------------
    // --------------------------- POSTCROWDSALE ------------------------------
    // ------------------------------------------------------------------------


    /**
    * @dev validate a customer and send the tokens
    */
    function approveInvestor(
        address _beneficiary
    )
        external
        whenAccessAllowed
        onlyOwner
    {
        uint256 _amount = balances[_beneficiary];
        require(_amount > 0);
        balances[_beneficiary] = 0;
        _deliverTokens(_beneficiary, _amount);
    }

    /*
    * @dev mint tokens using an array to reduce transaction costs
    */
    function approveInvestors(
        address[] _beneficiaries
    )
        external
        whenAccessAllowed
        onlyOwner
    {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
           require(_beneficiaries[i] != address(0));
           uint256 _amount = balances[_beneficiaries[i]];
           require(_amount > 0);
           balances[_beneficiaries[i]] = 0;
            _deliverTokens(_beneficiaries[i], _amount);
        }
    }

    /*
    * @dev minting 49 percent for the platform and finishing minting
    */
    function mintForPlatform()
        external
        whenAccessAllowed
        onlyOwner
        onlyDuring(Status.ended)
    {
        uint256 _tokensForPlatform = token.totalSupply().mul(49).div(51);
        require(token.mint(wallet, _tokensForPlatform));
        require(token.finishMinting());
    }

    /*
    * @dev delivers token to a certain address
    */
    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
    )
        internal
    {
        require(token.mint(_beneficiary, _tokenAmount));
    }

    // ------------------------------------------------------------------------
    // --------------------------- SUPERVISOR ---------------------------------
    // ------------------------------------------------------------------------

    /*
    * @dev change signer if account there is problem with the account
    */
    function changeSigner(
        address _newSigner
    )
        external
        onlySupervisor
        onlyDuring(Status.paused)
    {
        require(_newSigner != address(0));
        emit SignerChanged(signer, _newSigner);
        signer = _newSigner;
    }

    /*
    * @dev change the state of accessAllowed bit, thus locking or freeing functions
    */
    function setAccess(bool value) public onlySupervisor {
        require(accessAllowed != value);
        emit AccessChanged(value);
        accessAllowed = value;
    }

    // ------------------------------------------------------------------------
    // ----------------------- Expired Crowdsale ------------------------------
    // ------------------------------------------------------------------------

    /*
    * @dev function for everyone to enable refunds after certain time
    */
    function endExpiredCrowdsale() public {
        require(status != Status.unstarted);
        require(now > startTime + 365 days);
        status = Status.ended;
        if(_isGoalReached()) {
            vault.close();
        } else {
            vault.enableRefunds();
        }
    }
}

library TokenAmountGetter {

    using SafeMath for uint256;

    /*
    * @dev get the amount of tokens corresponding to the ether amount
    * @param _etherAmount amount of ether the user has invested
    * @param _etherPrice price of ether in euro ca at the time of purchase
    * @param _startTime starting time of the ICO
    * @param _baseRate the base rate of token to ether, constant
    */
    function getTokenAmount(
        uint256 _etherAmount,
        uint256 _etherPrice,
        uint256 _startTime,
        uint256 _baseRate
    )
        internal
        view
        returns (uint256)
    {
        uint256 _baseTokenAmount = _etherAmount.mul(_baseRate);
        uint256 _timeBonus = _getTimeBonus(_baseTokenAmount, _startTime);
        uint256 _amountBonus = _getAmountBonus(
            _etherAmount,
            _etherPrice,
            _baseTokenAmount
        );
        uint256 _totalBonus = _timeBonus.add(_amountBonus);

        uint256 _totalAmount = _baseTokenAmount.add(_totalBonus);

        // another 2% on top if tokens bought in the first 24 hours
        if(_startTime + 1 days > now)
            _totalAmount = _totalAmount.add(_totalAmount.mul(2).div(100));

        return _totalAmount;
    }

    /*
    * @dev get time bonus for base amount, does not include 24H 2% on top
    */
    function _getTimeBonus(
        uint256 _baseTokenAmount,
        uint256 _startTime
    )
        internal
        view
        returns (uint256)
    {
        if (now <= (_startTime + 1 weeks))
            return (_baseTokenAmount.mul(20).div(100));
        if (now <= (_startTime + 2 weeks))
            return (_baseTokenAmount.mul(18).div(100));
        if (now <= (_startTime + 3 weeks))
            return (_baseTokenAmount.mul(16).div(100));
        if (now <= (_startTime + 4 weeks))
            return (_baseTokenAmount.mul(14).div(100));
        if (now <= (_startTime + 5 weeks))
            return (_baseTokenAmount.mul(12).div(100));
        if (now <= (_startTime + 6 weeks))
            return (_baseTokenAmount.mul(10).div(100));
        if (now <= (_startTime + 7 weeks))
            return (_baseTokenAmount.mul(8).div(100));
        if (now <= (_startTime + 8 weeks))
            return (_baseTokenAmount.mul(6).div(100));
        if (now <= (_startTime + 9 weeks))
            return (_baseTokenAmount.mul(4).div(100));
        if (now <= (_startTime + 10 weeks))
            return (_baseTokenAmount.mul(2).div(100));
        return 0;
    }

    /*
    * @dev get amount bonus for amount measured in euro, which is
    *   determined by the current price and amount
    */
    function _getAmountBonus(
        uint256 _etherAmount,
        uint256 _etherPrice,
        uint256 _baseTokenAmount
    )
        internal
        pure
        returns (uint256)
    {
        uint256 _etherAmountInEuro = _etherAmount.mul(_etherPrice).div(1 ether);
        if (_etherAmountInEuro < 100000)
            return 0;
        if (_etherAmountInEuro >= 100000 && _etherAmountInEuro < 150000)
            return (_baseTokenAmount.mul(3)).div(100);
        if (_etherAmountInEuro >= 150000 && _etherAmountInEuro < 200000)
            return (_baseTokenAmount.mul(6)).div(100);
        if (_etherAmountInEuro >= 200000 && _etherAmountInEuro < 300000)
            return (_baseTokenAmount.mul(9)).div(100);
        if (_etherAmountInEuro >= 300000 && _etherAmountInEuro < 1000000)
            return (_baseTokenAmount.mul(12)).div(100);
        if (_etherAmountInEuro >= 1000000 && _etherAmountInEuro < 1500000)
            return (_baseTokenAmount.mul(15)).div(100);
        if (_etherAmountInEuro >= 1500000)
            return (_baseTokenAmount.mul(20)).div(100);
    }
}
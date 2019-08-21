pragma solidity ^0.4.18;


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
contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
}
contract ROKToken is ERC20, Ownable {
    using SafeMath for uint256;

    string public constant name = "ROK Token";
    string public constant symbol = "ROK";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 100000000000000000000000000;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    /**
  * @dev Contructor that gives msg.sender all of existing tokens.
  */
    function ROKToken() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }


    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
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
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function unlockTransfer(address _spender, uint256 _value) public returns (bool) {

    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function burn(uint256 _value) public returns (bool success){
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
        return true;
    }
}
contract Pausable is Ownable {
    event Pause();

    event Unpause();

    bool public paused = false;


    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}
contract PullPayment {
    using SafeMath for uint256;

    mapping (address => uint256) public payments;

    uint256 public totalPayments;

    /**
    * @dev Called by the payer to store the sent amount as credit to be pulled.
    * @param dest The destination address of the funds.
    * @param amount The amount to transfer.
    */
    function asyncSend(address dest, uint256 amount) internal {
        payments[dest] = payments[dest].add(amount);
        totalPayments = totalPayments.add(amount);
    }

    /**
    * @dev withdraw accumulated balance, called by payee.
    */
    function withdrawPayments() {
        address payee = msg.sender;
        uint256 payment = payments[payee];

        require(payment != 0);
        require(this.balance >= payment);

        totalPayments = totalPayments.sub(payment);
        payments[payee] = 0;

        assert(payee.send(payment));
    }
}

/*
*  Crowdsale Smart Contract for the Rockchain project
*  Author: Yosra Helal yosra.helal@rockchain.org
*  Contributor: Christophe Ozcan christophe.ozcan@crypto4all.com
*
*
*  MultiSig advisors Keys (3/5)
*
*  Christophe OZCAN        0x75dcB0Ba77e5f99f8ce6F01338Cb235DFE94260c
*  Jeff GUILBAULT          0x94ddC32c61BC9a799CdDea87e6a1D1316198b0Fa
*  Mark HAHNEL             0xFaE39043B8698CaA4F1417659B00737fa19b8ECC
*  Sébastien COLLIGNON     0xd70280108EaF321E100276F6D1b105Ee088CB016
*  Sébastien JEHAN         0xE4b0A48D3b1adA17000Fd080cd42DB3e8231752c
*
*
*/

contract Crowdsale is Pausable, PullPayment {
    using SafeMath for uint256;

    address public owner;
    ROKToken public rok;
    address public escrow;                                                             // Address of Escrow Provider Wallet
    address public bounty ;                                                            // Address dedicated for bounty services
    address public team;                                                               // Adress for ROK token allocated to the team
    uint256 public rateETH_ROK;                                                        // Rate Ether per ROK token
    uint256 public constant minimumPurchase = 0.1 ether;                               // Minimum purchase size of incoming ETH
    uint256 public constant maxFundingGoal = 100000 ether;                             // Maximum goal in Ether raised
    uint256 public constant minFundingGoal = 18000 ether;                              // Minimum funding goal in Ether raised
    uint256 public constant startDate = 1509534000;                                    // epoch timestamp representing the start date (1st november 2017 11:00 gmt)
    uint256 public constant deadline = 1512126000;                                     // epoch timestamp representing the end date (1st december 2017 11:00 gmt)
    uint256 public constant refundeadline = 1515927600;                                // epoch timestamp representing the end date of refund period (14th january 2018 11:00 gmt)
    uint256 public savedBalance = 0;                                                   // Total amount raised in ETH
    uint256 public savedBalanceToken = 0;                                              // Total ROK Token allocated
    bool public crowdsaleclosed = false;                                               // To finalize crowdsale
    mapping (address => uint256) balances;                                             // Balances in incoming Ether
    mapping (address => uint256) balancesRokToken;                                     // Balances in ROK
    mapping (address => bool) KYClist;

    // Events to record new contributions
    event Contribution(address indexed _contributor, uint256 indexed _value, uint256 indexed _tokens);

    // Event to record each time Ether is paid out
    event PayEther(
    address indexed _receiver,
    uint256 indexed _value,
    uint256 indexed _timestamp
    );

    // Event to record when tokens are burned.
    event BurnTokens(
    uint256 indexed _value,
    uint256 indexed _timestamp
    );

    // Initialization
    function Crowdsale(){
        owner = msg.sender;
        // add address of the specific contract
        rok = ROKToken(0xc9de4b7f0c3d991e967158e4d4bfa4b51ec0b114);
        escrow = 0x049ca649c977ec36368f31762ff7220db0aae79f;
        bounty = 0x50Cc6F2D548F7ecc22c9e9F994E4C0F34c7fE8d0;
        team = 0x33462171A814d4eDa97Cf3a112abE218D05c53C2;
        rateETH_ROK = 1000;
    }


    // Default Function, delegates to contribute function (for ease of use)
    // WARNING: Not compatible with smart contract invocation, will exceed gas stipend!
    // Only use from external accounts
    function() payable whenNotPaused{
        if (msg.sender == escrow){
            balances[this] = msg.value;
        }
        else{
            contribute(msg.sender);
        }
    }

    // Contribute Function, accepts incoming payments and tracks balances for each contributors
    function contribute(address contributor) internal{
        require(isStarted());
        require(!isComplete());
        assert((savedBalance.add(msg.value)) <= maxFundingGoal);
        assert(msg.value >= minimumPurchase);
        balances[contributor] = balances[contributor].add(msg.value);
        savedBalance = savedBalance.add(msg.value);
        uint256 Roktoken = rateETH_ROK.mul(msg.value) + getBonus(rateETH_ROK.mul(msg.value));
        uint256 RokToSend = (Roktoken.mul(80)).div(100);
        balancesRokToken[contributor] = balancesRokToken[contributor].add(RokToSend);
        savedBalanceToken = savedBalanceToken.add(Roktoken);
        escrow.transfer(msg.value);
        PayEther(escrow, msg.value, now);
    }


    // Function to check if crowdsale has started yet
    function isStarted() constant returns (bool) {
        return now >= startDate;
    }

    // Function to check if crowdsale is complete (
    function isComplete() constant returns (bool) {
        return (savedBalance >= maxFundingGoal) || (now > deadline) || (savedBalanceToken >= rok.totalSupply()) || (crowdsaleclosed == true);
    }

    // Function to view current token balance of the crowdsale contract
    function tokenBalance() constant returns (uint256 balance) {
        return rok.balanceOf(address(this));
    }

    // Function to check if crowdsale has been successful (has incoming contribution balance met, or exceeded the minimum goal?)
    function isSuccessful() constant returns (bool) {
        return (savedBalance >= minFundingGoal);
    }

    // Function to check the Ether balance of a contributor
    function checkEthBalance(address _contributor) constant returns (uint256 balance) {
        return balances[_contributor];
    }

    // Function to check the current Tokens Sold in the ICO
    function checkRokSold() constant returns (uint256 total) {
        return (savedBalanceToken);
        // Function to check the current Tokens Sold in the ICO
    }

    // Function to check the current Tokens affected to the team
    function checkRokTeam() constant returns (uint256 totalteam) {
        return (savedBalanceToken.mul(19).div(100));
        // Function to check the current Tokens affected to the team
    }

    // Function to check the current Tokens affected to bounty
    function checkRokBounty() constant returns (uint256 totalbounty) {
        return (savedBalanceToken.div(100));
    }

    // Function to check the refund period is over
    function refundPeriodOver() constant returns (bool){
        return (now > refundeadline);
    }

    // Function to check the refund period is over
    function refundPeriodStart() constant returns (bool){
        return (now > deadline);
    }

    // function to check percentage of goal achieved
    function percentOfGoal() constant returns (uint16 goalPercent) {
        return uint16((savedBalance.mul(100)).div(minFundingGoal));
    }

    // Calcul the ROK bonus according to the investment period
    function getBonus(uint256 amount) internal constant returns (uint256) {
        uint bonus = 0;
        //   5 November 2017 11:00:00 GMT
        uint firstbonusdate = 1509879600;
        //  10 November 2017 11:00:00 GMT
        uint secondbonusdate = 1510311600;

        //  if investment date is on the 10% bonus period then return bonus
        if (now <= firstbonusdate) {bonus = amount.div(10);}
        //  else if investment date is on the 5% bonus period then return bonus
        else if (now <= secondbonusdate && now >= firstbonusdate) {bonus = amount.div(20);}
        //  return amount without bonus
        return bonus;
    }

    // Function to set the balance of a sender
    function setBalance(address sender,uint256 value) internal{
        balances[sender] = value;
    }

    // Only owner will finalize the crowdsale
    function finalize() onlyOwner {
        require(isStarted());
        require(!isComplete());
        crowdsaleclosed = true;
    }

    // Function to pay out
    function payout() onlyOwner {
        if (isSuccessful() && isComplete()) {
            rok.transfer(bounty, checkRokBounty());
            payTeam();
        }
        else {
            if (refundPeriodOver()) {
                escrow.transfer(savedBalance);
                PayEther(escrow, savedBalance, now);
                rok.transfer(bounty, checkRokBounty());
                payTeam();
            }
        }
    }

    //Function to pay Team
    function payTeam() internal {
        assert(checkRokTeam() > 0);
        rok.transfer(team, checkRokTeam());
        if (checkRokSold() < rok.totalSupply()) {
            // burn the rest of ROK
            rok.burn(rok.totalSupply().sub(checkRokSold()));
            //Log burn of tokens
            BurnTokens(rok.totalSupply().sub(checkRokSold()), now);
        }
    }

    //Function to update KYC list
    function updateKYClist(address[] allowed) onlyOwner{
        for (uint i = 0; i < allowed.length; i++) {
            if (KYClist[allowed[i]] == false) {
                KYClist[allowed[i]] = true;
            }
        }
    }

    //Function to claim ROK tokens
    function claim() public{
        require(isComplete());
        require(checkEthBalance(msg.sender) > 0);
        if(checkEthBalance(msg.sender) <= (3 ether)){
            rok.transfer(msg.sender,balancesRokToken[msg.sender]);
            balancesRokToken[msg.sender] = 0;
        }
        else{
            require(KYClist[msg.sender] == true);
            rok.transfer(msg.sender,balancesRokToken[msg.sender]);
            balancesRokToken[msg.sender] = 0;
        }
    }

    /* When MIN_CAP is not reach the smart contract will be credited to make refund possible by backers
     * 1) backer call the "refund" function of the Crowdsale contract
     * 2) backer call the "withdrawPayments" function of the Crowdsale contract to get a refund in ETH
     */
    function refund() public {
        require(!isSuccessful());
        require(refundPeriodStart());
        require(!refundPeriodOver());
        require(checkEthBalance(msg.sender) > 0);
        uint ETHToSend = checkEthBalance(msg.sender);
        setBalance(msg.sender,0);
        asyncSend(msg.sender, ETHToSend);
    }

    /* When MIN_CAP is not reach the smart contract will be credited to make refund possible by backers
     * 1) backer call the "partialRefund" function of the Crowdsale contract with the partial amount of ETH to be refunded (value will be renseigned in WEI)
     * 2) backer call the "withdrawPayments" function of the Crowdsale contract to get a refund in ETH
     */
    function partialRefund(uint256 value) public {
        require(!isSuccessful());
        require(refundPeriodStart());
        require(!refundPeriodOver());
        require(checkEthBalance(msg.sender) >= value);
        setBalance(msg.sender,checkEthBalance(msg.sender).sub(value));
        asyncSend(msg.sender, value);
    }

}
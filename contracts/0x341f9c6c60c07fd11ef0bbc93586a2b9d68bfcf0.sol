pragma solidity ^0.4.13;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

    uint constant DAY_IN_SECONDS = 86400;
    uint constant BASE = 1000000000000000000;
    uint constant preIcoPrice = 3000;
    uint constant icoPrice = 1500;

    function mul(uint256 a, uint256 b) constant internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) constant internal returns (uint256) {
        assert(b != 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) constant internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) constant internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function divToMul(uint256 number, uint256 numerator, uint256 denominator) internal returns (uint256) {
        return div(mul(number, numerator), denominator);
    }

    function mulToDiv(uint256 number, uint256 numerator, uint256 denominator) internal returns (uint256) {
        return mul(div(number, numerator), denominator);
    }


    // ICO volume bonus calculation
    function volumeBonus(uint256 etherValue) internal returns (uint256) {
        if(etherValue >= 10000000000000000000000) return 55;  // +55% tokens
        if(etherValue >=  5000000000000000000000) return 50;  // +50% tokens
        if(etherValue >=  1000000000000000000000) return 45;  // +45% tokens
        if(etherValue >=   200000000000000000000) return 40;  // +40% tokens
        if(etherValue >=   100000000000000000000) return 35;  // +35% tokens
        if(etherValue >=    50000000000000000000) return 30; // +30% tokens
        if(etherValue >=    30000000000000000000) return 25;  // +25% tokens
        if(etherValue >=    20000000000000000000) return 20;  // +20% tokens
        if(etherValue >=    10000000000000000000) return 15;  // +15% tokens
        if(etherValue >=     5000000000000000000) return 10;  // +10% tokens
        if(etherValue >=     1000000000000000000) return 5;   // +5% tokens

        return 0;
    }

    // date bonus calculation
    function dateBonus(uint startIco, uint currentType, uint datetime) internal returns (uint256) {
        if(currentType == 2){
            // day from ICO start
            uint daysFromStart = (datetime - startIco) / DAY_IN_SECONDS + 1;

            if(daysFromStart == 1)  return 30; // +30% tokens
            if(daysFromStart == 2)  return 29; // +29% tokens
            if(daysFromStart == 3)  return 28; // +28% tokens
            if(daysFromStart == 4)  return 27; // +27% tokens
            if(daysFromStart == 5)  return 26; // +26% tokens
            if(daysFromStart == 6)  return 25; // +25% tokens
            if(daysFromStart == 7)  return 24; // +24% tokens
            if(daysFromStart == 8)  return 23; // +23% tokens
            if(daysFromStart == 9)  return 22; // +22% tokens
            if(daysFromStart == 10) return 21; // +21% tokens
            if(daysFromStart == 11) return 20; // +20% tokens
            if(daysFromStart == 12) return 19; // +19% tokens
            if(daysFromStart == 13) return 18; // +18% tokens
            if(daysFromStart == 14) return 17; // +17% tokens
            if(daysFromStart == 15) return 16; // +16% tokens
            if(daysFromStart == 16) return 15; // +15% tokens
            if(daysFromStart == 17) return 14; // +14% tokens
            if(daysFromStart == 18) return 13; // +13% tokens
            if(daysFromStart == 19) return 12; // +12% tokens
            if(daysFromStart == 20) return 11; // +11% tokens
            if(daysFromStart == 21) return 10; // +10% tokens
            if(daysFromStart == 22) return 9;  // +9% tokens
            if(daysFromStart == 23) return 8;  // +8% tokens
            if(daysFromStart == 24) return 7;  // +7% tokens
            if(daysFromStart == 25) return 6;  // +6% tokens
            if(daysFromStart == 26) return 5;  // +5% tokens
            if(daysFromStart == 27) return 4;  // +4% tokens
            if(daysFromStart == 28) return 3;  // +3% tokens
            if(daysFromStart == 29) return 2;  // +2% tokens
            if(daysFromStart == 30) return 1;  // +1% tokens
            if(daysFromStart == 31) return 1;  // +1% tokens
            if(daysFromStart == 32) return 1;  // +1% tokens
        }
        if(currentType == 1){
            /// day from PreSale start
            uint daysFromPresaleStart = (datetime - startIco) / DAY_IN_SECONDS + 1;

            if(daysFromPresaleStart == 1)  return 54;  // +54% tokens
            if(daysFromPresaleStart == 2)  return 51;  // +51% tokens
            if(daysFromPresaleStart == 3)  return 48;  // +48% tokens
            if(daysFromPresaleStart == 4)  return 45;  // +45% tokens
            if(daysFromPresaleStart == 5)  return 42;  // +42% tokens
            if(daysFromPresaleStart == 6)  return 39;  // +39% tokens
            if(daysFromPresaleStart == 7)  return 36;  // +36% tokens
            if(daysFromPresaleStart == 8)  return 33;  // +33% tokens
            if(daysFromPresaleStart == 9)  return 30;  // +30% tokens
            if(daysFromPresaleStart == 10) return 27;  // +27% tokens
            if(daysFromPresaleStart == 11) return 24;  // +24% tokens
            if(daysFromPresaleStart == 12) return 21;  // +21% tokens
            if(daysFromPresaleStart == 13) return 18;  // +18% tokens
            if(daysFromPresaleStart == 14) return 15;  // +15% tokens
            if(daysFromPresaleStart == 15) return 12;  // +12% tokens
            if(daysFromPresaleStart == 16) return 9;   // +9% tokens
            if(daysFromPresaleStart == 17) return 6;   // +6% tokens
            if(daysFromPresaleStart == 18) return 4;   // +4% tokens
            if(daysFromPresaleStart == 19) return 0;   // +0% tokens
        }

        // no discount
        return 0;
    }
}


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
/// @title Abstract token contract - Functions to be implemented by token contracts.

contract AbstractToken {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
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

contract StandardToken is AbstractToken {
    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => bool) ownerAppended;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
    address[] public owners;

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
            if(!ownerAppended[_to]) {
                ownerAppended[_to] = true;
                owners.push(_to);
            }
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
            if(!ownerAppended[_to]) {
                ownerAppended[_to] = true;
                owners.push(_to);
            }
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


contract VINNDTokenContract is StandardToken, SafeMath {
    /*
     * Token meta data
     */
    string public constant name = "VINND";
    string public constant symbol = "VIN";
    uint public constant decimals = 18;

    // tottal supply

    address public icoContract = 0x0;
    /*
     * Modifiers
     */

    modifier onlyIcoContract() {
        // only ICO contract is allowed to proceed
        require(msg.sender == icoContract);
        _;
    }

    /*
     * Contract functions
     */

    /// @dev Contract is needed in icoContract address
    /// @param _icoContract Address of account which will be mint tokens
    function VINNDTokenContract(address _icoContract) payable{
        assert(_icoContract != 0x0);
        icoContract = _icoContract;
    }

    /// @dev Burns tokens from address. It's can be applied by account with address this.icoContract
    /// @param _from Address of account, from which will be burned tokens
    /// @param _value Amount of tokens, that will be burned
    function burnTokens(address _from, uint _value) onlyIcoContract {
        assert(_from != 0x0);
        require(_value > 0);

        balances[_from] = sub(balances[_from], _value);
    }

    /// @dev Adds tokens to address. It's can be applied by account with address this.icoContract
    /// @param _to Address of account to which the tokens will pass
    /// @param _value Amount of tokens
    function emitTokens(address _to, uint _value) onlyIcoContract {
        assert(_to != 0x0);
        require(_value > 0);

        balances[_to] = add(balances[_to], _value);

        if(!ownerAppended[_to]) {
            ownerAppended[_to] = true;
            owners.push(_to);
        }

    }

    function getOwner(uint index) constant returns (address, uint256) {
        return (owners[index], balances[owners[index]]);
    }

    function getOwnerCount() constant returns (uint) {
        return owners.length;
    }

}


contract VINContract is SafeMath {
    /*
     * ICO meta data
     */
    VINNDTokenContract public VINToken;

    enum Stage{
    Pause,
    Init,
    Running,
    Stopped
    }

    enum Type{
    PRESALE,
    ICO
    }

    // Initializing current steps
    Stage public currentStage = Stage.Pause;
    Type public currentType = Type.PRESALE;

    // Setting constant dates UTC

    // 11.12.2017 00:00:00
    uint public startPresaleDate = 1512950400;
    // 29.12.2017 23:59:59
    uint public endPresaleDate = 1514591999;
    // 18.01.2018 00:00:00
    uint public startICODate = 1516233600;
    // 18.02.2018 23:59:59
    uint public endICODate = 1518998399;

    // Address of manager
    address public icoOwner;

    // Addresses of founders and bountyOwner
    address public founder;
    address public bountyOwner;

    // 888.888.888 VIN all tokens
    uint public constant totalCap   = 888888888000000000000000000;
    // 534.444.444 ico cap
    uint public constant ICOCap     = 534444444000000000000000000;
    //  28.888.888 presale cap
    uint public constant presaleCap =  28888888000000000000000000;

    //  14.444.444 VIN is total bounty tokens
    uint public constant totalBountyTokens = 14444444000000000000000000;

    // 1 ETH = 3000 VIN
    uint public constant PRICE = 3000;
    // 1 ETH = 1500 VIN
    uint public constant ICOPRICE = 1500;

    // 2018.02.20 00:00 UTC
    // founders' reward time
    uint public foundersRewardTime = 1519084800;

    // Amount of sold tokens on ICO
    uint public totalSoldOnICO = 0;
    // Amount of issued tokens on pre-ICO
    uint public totalSoldOnPresale = 0;


    // ? Tokens already sent Founder
    bool public sentTokensToFounders = false;

    // Boolean set founder
    bool public setFounder = false;
    bool public setBounty = false;

    uint public totalEther = 0;

    /*
     * Modifiers
     */

    modifier whenInitialized() {
        // only when contract is initialized
        require(currentStage >= Stage.Init);
        _;
    }

    modifier onlyManager() {
        // only ICO manager can do this action
        require(msg.sender == icoOwner);
        _;
    }

    modifier onStageRunning() {
        // Checks, if ICO is running and has not been stopped
        require(currentStage == Stage.Running);
        _;
    }

    modifier onStageStopped() {
        // Checks if ICO was stopped or deadline is reached
        require(currentStage == Stage.Stopped);
        _;
    }

    modifier checkType() {
        require(currentType == Type.ICO || currentType == Type.PRESALE);
        _;
    }

    modifier checkDateTime(){
        if(currentType == Type.PRESALE){
            require(startPresaleDate < now && now < endPresaleDate);
        }else{
            require(startICODate < now && now < endICODate);
        }
        _;
    }

    /// @dev Constructor of ICO
    function VINContract() payable{
        VINToken = new VINNDTokenContract(this);
        icoOwner = msg.sender;
    }

    /// @dev Initialises addresses of founders, bountyOwner.
    /// Initialises balances of tokens owner
    /// @param _founder Address of founder
    /// @param _bounty Address of bounty
    function initialize(address _founder, address _bounty) onlyManager {
        assert(currentStage != Stage.Init);
        assert(_founder != 0x0);
        assert(_bounty != 0x0);
        require(!setFounder);
        require(!setBounty);

        founder = _founder;
        bountyOwner = _bounty;

        VINToken.emitTokens(_bounty, totalBountyTokens);

        setFounder = true;
        setBounty = true;

        currentStage = Stage.Init;
    }

    /// @dev Sets new type
    /// @param _type Value of new type
    function setType(Type _type) public onlyManager onStageStopped{
        currentType = _type;
    }

    /// @dev Sets new stage
    /// @param _stage Value of new stage
    function setStage(Stage _stage) public onlyManager{
        currentStage = _stage;
    }


    /// @dev Sets new owner. Only manager can do it
    /// @param _newicoOwner Address of new ICO manager
    function setNewOwner(address _newicoOwner) onlyManager {
        assert(_newicoOwner != 0x0);
        icoOwner = _newicoOwner;
    }

    /// @dev Buy quantity of tokens depending on the amount of sent ethers.
    /// @param _buyer Address of account which will receive tokens
    function buyTokens(address _buyer, uint datetime, uint _value) private {
        assert(_buyer != 0x0);
        require(_value > 0);

        uint dateBonusPercent = 0;
        uint tokensToEmit = 0;

        //calculate date bonus and set emitTokenPrice
        if(currentType == Type.PRESALE){
            tokensToEmit = _value * PRICE;
            dateBonusPercent = dateBonus(startPresaleDate, 1, datetime);
        }
        else{
            tokensToEmit = _value * ICOPRICE;
            dateBonusPercent = dateBonus(startICODate, 2, datetime);
        }

        //calculate volume bonus
        uint volumeBonusPercent = volumeBonus(_value);

        //total bonus tokens
        uint totalBonusPercent = dateBonusPercent + volumeBonusPercent;

        if(totalBonusPercent > 0){
            tokensToEmit =  tokensToEmit + divToMul(tokensToEmit, totalBonusPercent, 100);
        }

        if(currentType == Type.PRESALE){
            require(add(totalSoldOnPresale, tokensToEmit) <= presaleCap);
            totalSoldOnPresale = add(totalSoldOnPresale, tokensToEmit);
        }
        else{
            require(add(totalSoldOnICO, tokensToEmit) <= ICOCap);
            totalSoldOnICO = add(totalSoldOnICO, tokensToEmit);
        }

        //emit tokens to token holder
        VINToken.emitTokens(_buyer, tokensToEmit);

        totalEther = add(totalEther, _value);
    }

    /// @dev Fall back function ~50k-100k gas
    function () payable onStageRunning checkType checkDateTime{
        buyTokens(msg.sender, now, msg.value);
    }

    /// @dev Burn tokens from accounts. Only manager can do it
    /// @param _from Address of account
    function burnTokens(address _from, uint _value) onlyManager{
        VINToken.burnTokens(_from, _value);
    }


    /// @dev Send tokens to founders. Can be sent only after VINToken.rewardTime
    function sendTokensToFounders() onlyManager whenInitialized {
        require(!sentTokensToFounders && now >= foundersRewardTime);

        //Calculate total tokens sold on pre-ICO and ICO
        uint tokensSold = add(totalSoldOnICO, totalSoldOnPresale);
        uint totalTokenToSold = add(ICOCap, presaleCap);

        uint x = mul(mul(tokensSold, totalCap), 35);
        uint y = mul(100, totalTokenToSold);
        uint result = div(x, y);

        VINToken.emitTokens(founder, result);

        sentTokensToFounders = true;
    }

    /// @dev Send tokens to other wallets
    /// @param _buyer Address of account which will receive tokens
    /// @param _datetime datetime of transaction
    /// @param _ether ether value
    function emitTokensToOtherWallet(address _buyer, uint _datetime, uint _ether) onlyManager checkType{
        assert(_buyer != 0x0);
        buyTokens(_buyer, _datetime, _ether * 10 ** 18);
    }
}
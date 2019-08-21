pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
    function mul(uint a, uint b) constant internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) constant internal returns (uint) {
        assert(b != 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) constant internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) constant internal returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    // Volume bonus calculation
    function volumeBonus(uint etherValue) constant internal returns (uint) {

        if(etherValue >=  500000000000000000000) return 10; // 500 ETH +10% tokens
        if(etherValue >=  300000000000000000000) return 7;  // 300 ETH +7% tokens
        if(etherValue >=  100000000000000000000) return 5;  // 100 ETH +5% tokens
        if(etherValue >=   50000000000000000000) return 3;  // 50 ETH +3% tokens
        if(etherValue >=   20000000000000000000) return 2;  // 20 ETH +2% tokens
        if(etherValue >=   10000000000000000000) return 1;  // 10 ETH +1% tokens

        return 0;
    }

}


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
/// @title Abstract token contract - Functions to be implemented by token contracts.

contract AbstractToken {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
    function totalSupply() constant returns (uint) {}
    function balanceOf(address owner) constant returns (uint balance);
    function transfer(address to, uint value) returns (bool success);
    function transferFrom(address from, address to, uint value) returns (bool success);
    function approve(address spender, uint value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint remaining);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Issuance(address indexed to, uint value);
}

contract IcoLimits {
    uint constant privateSaleStart = 1511136000; // 11/20/2017 @ 12:00am (UTC)
    uint constant privateSaleEnd   = 1512086399; // 11/30/2017 @ 11:59pm (UTC)

    uint constant presaleStart     = 1512086400; // 12/01/2017 @ 12:00am (UTC)
    uint constant presaleEnd       = 1513900799; // 12/21/2017 @ 11:59pm (UTC)

    uint constant publicSaleStart  = 1516320000; // 01/19/2018 @ 12:00am (UTC)
    uint constant publicSaleEnd    = 1521158399; // 03/15/2018 @ 11:59pm (UTC)

    modifier afterPublicSale() {
        require(now > publicSaleEnd);
        _;
    }

    uint constant privateSalePrice = 4000; // SNEK tokens per 1 ETH
    uint constant preSalePrice     = 3000; // SNEK tokens per 1 ETH
    uint constant publicSalePrice  = 2000; // SNEK tokens per 1 ETH

    uint constant privateSaleSupplyLimit =  600  * privateSalePrice * 1000000000000000000;
    uint constant preSaleSupplyLimit     =  1200 * preSalePrice     * 1000000000000000000;
    uint constant publicSaleSupplyLimit  =  5000 * publicSalePrice  * 1000000000000000000;
}

contract StandardToken is AbstractToken, IcoLimits {
    /*
     *  Data structures
     */
    mapping (address => uint) balances;
    mapping (address => bool) ownerAppended;
    mapping (address => mapping (address => uint)) allowed;

    uint public totalSupply;

    address[] public owners;

    /*
     *  Read and write storage functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint _value) afterPublicSale returns (bool success) {
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
    function transferFrom(address _from, address _to, uint _value) afterPublicSale returns (bool success) {
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
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint _value) returns (bool success) {
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
    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}


contract ExoTownToken is StandardToken, SafeMath {

    /*
     * Token meta data
     */

    string public constant name = "ExoTown token";
    string public constant symbol = "SNEK";
    uint public constant decimals = 18;

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
    function ExoTownToken(address _icoContract) {
        require(_icoContract != 0x0);
        icoContract = _icoContract;
    }

    /// @dev Burns tokens from address. It can be applied by account with address this.icoContract
    /// @param _from Address of account, from which will be burned tokens
    /// @param _value Amount of tokens, that will be burned
    function burnTokens(address _from, uint _value) onlyIcoContract {
        require(_value > 0);

        balances[_from] = sub(balances[_from], _value);
        totalSupply -= _value;
    }

    /// @dev Adds tokens to address. It can be applied by account with address this.icoContract
    /// @param _to Address of account to which the tokens will pass
    /// @param _value Amount of tokens
    function emitTokens(address _to, uint _value) onlyIcoContract {
        require(totalSupply + _value >= totalSupply);
        balances[_to] = add(balances[_to], _value);
        totalSupply += _value;

        if(!ownerAppended[_to]) {
            ownerAppended[_to] = true;
            owners.push(_to);
        }

        Transfer(0x0, _to, _value);

    }

    function getOwner(uint index) constant returns (address, uint) {
        return (owners[index], balances[owners[index]]);
    }

    function getOwnerCount() constant returns (uint) {
        return owners.length;
    }

}


contract ExoTownIco is SafeMath, IcoLimits {

    /*
     * ICO meta data
     */
    ExoTownToken public exotownToken;

    enum State {
        Pause,
        Running
    }

    State public currentState = State.Pause;

    uint public privateSaleSoldTokens = 0;
    uint public preSaleSoldTokens     = 0;
    uint public publicSaleSoldTokens  = 0;

    uint public privateSaleEtherRaised = 0;
    uint public preSaleEtherRaised     = 0;
    uint public publicSaleEtherRaised  = 0;

    // Address of manager
    address public icoManager;
    address public founderWallet;

    // Address from which tokens could be burned
    address public buyBack;

    // Purpose
    address public developmentWallet;
    address public marketingWallet;
    address public teamWallet;

    address public bountyOwner;

    // Mediator wallet is used for tracking user payments and reducing users' fee
    address public mediatorWallet;

    bool public sentTokensToBountyOwner = false;
    bool public sentTokensToFounders = false;

    

    /*
     * Modifiers
     */

    modifier whenInitialized() {
        // only when contract is initialized
        require(currentState >= State.Running);
        _;
    }

    modifier onlyManager() {
        // only ICO manager can do this action
        require(msg.sender == icoManager);
        _;
    }

    modifier onIco() {
        require( isPrivateSale() || isPreSale() || isPublicSale() );
        _;
    }

    modifier hasBountyCampaign() {
        require(bountyOwner != 0x0);
        _;
    }

    function isPrivateSale() constant internal returns (bool) {
        return now >= privateSaleStart && now <= privateSaleEnd;
    }

    function isPreSale() constant internal returns (bool) {
        return now >= presaleStart && now <= presaleEnd;
    }

    function isPublicSale() constant internal returns (bool) {
        return now >= publicSaleStart && now <= publicSaleEnd;
    }







    function getPrice() constant internal returns (uint) {
        if (isPrivateSale()) return privateSalePrice;
        if (isPreSale()) return preSalePrice;
        if (isPublicSale()) return publicSalePrice;

        return publicSalePrice;
    }

    function getStageSupplyLimit() constant returns (uint) {
        if (isPrivateSale()) return privateSaleSupplyLimit;
        if (isPreSale()) return preSaleSupplyLimit;
        if (isPublicSale()) return publicSaleSupplyLimit;

        return 0;
    }

    function getStageSoldTokens() constant returns (uint) {
        if (isPrivateSale()) return privateSaleSoldTokens;
        if (isPreSale()) return preSaleSoldTokens;
        if (isPublicSale()) return publicSaleSoldTokens;

        return 0;
    }

    function addStageTokensSold(uint _amount) internal {
        if (isPrivateSale()) privateSaleSoldTokens = add(privateSaleSoldTokens, _amount);
        if (isPreSale())     preSaleSoldTokens = add(preSaleSoldTokens, _amount);
        if (isPublicSale())  publicSaleSoldTokens = add(publicSaleSoldTokens, _amount);
    }

    function addStageEtherRaised(uint _amount) internal {
        if (isPrivateSale()) privateSaleEtherRaised = add(privateSaleEtherRaised, _amount);
        if (isPreSale())     preSaleEtherRaised = add(preSaleEtherRaised, _amount);
        if (isPublicSale())  publicSaleEtherRaised = add(publicSaleEtherRaised, _amount);
    }

    function getStageEtherRaised() constant returns (uint) {
        if (isPrivateSale()) return privateSaleEtherRaised;
        if (isPreSale())     return preSaleEtherRaised;
        if (isPublicSale())  return publicSaleEtherRaised;

        return 0;
    }

    function getTokensSold() constant returns (uint) {
        return
            privateSaleSoldTokens +
            preSaleSoldTokens +
            publicSaleSoldTokens;
    }

    function getEtherRaised() constant returns (uint) {
        return
            privateSaleEtherRaised +
            preSaleEtherRaised +
            publicSaleEtherRaised;
    }















    /// @dev Constructor of ICO. Requires address of icoManager,
    /// @param _icoManager Address of ICO manager
    function ExoTownIco(address _icoManager) {
        require(_icoManager != 0x0);

        exotownToken = new ExoTownToken(this);
        icoManager = _icoManager;
    }

    /// Initialises addresses of founder, target wallets
    /// @param _founder Address of Founder
    /// @param _dev Address of Development wallet
    /// @param _pr Address of Marketing wallet
    /// @param _team Address of Team wallet
    /// @param _buyback Address of wallet used for burning tokens
    /// @param _mediator Address of Mediator wallet

    function init(
        address _founder,
        address _dev,
        address _pr,
        address _team,
        address _buyback,
        address _mediator
    ) onlyManager {
        require(currentState == State.Pause);
        require(_founder != 0x0);
        require(_dev != 0x0);
        require(_pr != 0x0);
        require(_team != 0x0);
        require(_buyback != 0x0);
        require(_mediator != 0x0);

        founderWallet = _founder;
        developmentWallet = _dev;
        marketingWallet = _pr;
        teamWallet = _team;
        buyBack = _buyback;
        mediatorWallet = _mediator;

        currentState = State.Running;

        exotownToken.emitTokens(icoManager, 0);
    }

    /// @dev Sets new state
    /// @param _newState Value of new state
    function setState(State _newState) public onlyManager {
        currentState = _newState;
    }

    /// @dev Sets new manager. Only manager can do it
    /// @param _newIcoManager Address of new ICO manager
    function setNewManager(address _newIcoManager) onlyManager {
        require(_newIcoManager != 0x0);
        icoManager = _newIcoManager;
    }

    /// @dev Sets bounty owner. Only manager can do it
    /// @param _bountyOwner Address of Bounty owner
    function setBountyCampaign(address _bountyOwner) onlyManager {
        require(_bountyOwner != 0x0);
        bountyOwner = _bountyOwner;
    }

    /// @dev Sets new Mediator wallet. Only manager can do it
    /// @param _mediator Address of Mediator wallet
    function setNewMediator(address _mediator) onlyManager {
        require(_mediator != 0x0);
        mediatorWallet = _mediator;
    }


    /// @dev Buy quantity of tokens depending on the amount of sent ethers.
    /// @param _buyer Address of account which will receive tokens
    function buyTokens(address _buyer) private {
        require(_buyer != 0x0);
        require(msg.value > 0);

        uint tokensToEmit = msg.value * getPrice();
        uint volumeBonusPercent = volumeBonus(msg.value);

        if (volumeBonusPercent > 0) {
            tokensToEmit = mul(tokensToEmit, 100 + volumeBonusPercent) / 100;
        }

        uint stageSupplyLimit = getStageSupplyLimit();
        uint stageSoldTokens = getStageSoldTokens();

        require(add(stageSoldTokens, tokensToEmit) <= stageSupplyLimit);

        exotownToken.emitTokens(_buyer, tokensToEmit);

        // Public statistics
        addStageTokensSold(tokensToEmit);
        addStageEtherRaised(msg.value);

        distributeEtherByStage();

    }

    /// @dev Buy tokens to specified wallet
    function giftToken(address _to) public payable onIco {
        buyTokens(_to);
    }

    /// @dev Fall back function
    function () payable onIco {
        buyTokens(msg.sender);
    }

    function distributeEtherByStage() private {
        uint _balance = this.balance;
        uint _balance_div = _balance / 100;

        uint _devAmount = _balance_div * 65;
        uint _prAmount = _balance_div * 25;

        uint total = _devAmount + _prAmount;
        if (total > 0) {
            // Top up Mediator wallet with 1% of Development amount = 0.65% of contribution amount.
            // It will cover tracking transaction fee (if any).
            // See White Paper for more information about payment tracking

            uint _mediatorAmount = _devAmount / 100;
            mediatorWallet.transfer(_mediatorAmount);

            developmentWallet.transfer(_devAmount - _mediatorAmount);
            marketingWallet.transfer(_prAmount);
            teamWallet.transfer(_balance - _devAmount - _prAmount);
        }
    }


    /// @dev Partial withdraw. Only manager can do it
    function withdrawEther(uint _value) onlyManager {
        require(_value > 0);
        require(_value <= this.balance);
        // send 1234 to get 1.234
        icoManager.transfer(_value * 1000000000000000); // 10^15
    }

    ///@dev Send tokens to bountyOwner depending on crowdsale results. Can be send only after public sale.
    function sendTokensToBountyOwner() onlyManager whenInitialized hasBountyCampaign afterPublicSale {
        require(!sentTokensToBountyOwner);

        //Calculate bounty tokens depending on total tokens sold
        uint bountyTokens = getTokensSold() / 40; // 2.5%

        exotownToken.emitTokens(bountyOwner, bountyTokens);

        sentTokensToBountyOwner = true;
    }

    /// @dev Send tokens to founders.
    function sendTokensToFounders() onlyManager whenInitialized afterPublicSale {
        require(!sentTokensToFounders);

        //Calculate founder reward depending on total tokens sold
        uint founderReward = getTokensSold() / 10; // 10%

        exotownToken.emitTokens(founderWallet, founderReward);

        sentTokensToFounders = true;
    }

    // Anyone could burn tokens by sending it to buyBack address and calling this function.
    function burnTokens(uint _amount) afterPublicSale {
        exotownToken.burnTokens(buyBack, _amount);
    }
}
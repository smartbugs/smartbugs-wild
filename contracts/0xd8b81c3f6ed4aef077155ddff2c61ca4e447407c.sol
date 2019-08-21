pragma solidity ^0.4.4; 

contract Authorization {

    address internal admin;

    function Authorization() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        if(msg.sender != admin) throw;
        _;
    }
}

contract NATVCoin is Authorization {

//*************************************************************************
// Variables

    mapping (address => uint256) private Balances;
    mapping (address => mapping (address => uint256)) private Allowances;
    string public standard = "NATVCoin v1.0";
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public coinSupply;
    uint private balance;
    uint256 private sellPrice;
    uint256 private buyPrice;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
//*************************************************************************************
// End Variables

//**************************************************************************************
//Constructor
    function NATVCoin(address benificairyAddress) {
        admin = msg.sender;
        Balances[admin] = 3000000000000000;
        coinSupply = 3000000000000000;
        decimals = 8;
        symbol = "NATV";
        name = "Native Currency";
        beneficiary = benificairyAddress; // Need to modify to client's wallet address
        SetNATVTokenSale();
    }

//***************************************************************************************

//***************************************************************************************
// Base Token  Started ERC 20 Standards
    function totalSupply() constant returns (uint initCoinSupply) {
        return coinSupply;
    }

    function balanceOf (address _owner) constant returns (uint balance){
        return Balances[_owner];
    }

    function transfer(address _to, uint256 _value) returns (bool success){
        if(Balances[msg.sender]< _value) throw;
        if(Balances[_to] + _value < Balances[_to]) throw;
        //if(admin)

        Balances[msg.sender] -= _value;
        Balances[_to] += _value;

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
        if(Balances[_from] < _value) throw;
        if(Balances[_to] + _value < Balances[_to]) throw;
        if(_value > Allowances[_from][msg.sender]) throw;
        Balances[_from] -= _value;
        Balances[_to] += _value;
        Allowances[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _sbalanceOfpender, uint256 _value) returns (bool success){
        Allowances[msg.sender][_sbalanceOfpender] = _value;
        Approval(msg.sender, _sbalanceOfpender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return Allowances[_owner][_spender];
    }
    //***********************************************************************************************
    //End Base Token
    //

    function OBEFAC(address addr) onlyAdmin public {
        beneficiary = addr;
    } 

    function releaseTokens (address _to, uint256 _value) private returns (bool success) {

        if(Balances[admin]< _value) throw;
        if(Balances[_to] + _value < Balances[_to]) throw;
        //if(admin)

        Balances[admin] -= _value;
        Balances[_to] += _value;

        Transfer(admin, _to, _value);

        return true;
    }

    //***********************************************************************************************
    //Crowd Sale Logic
    //

    enum State {
        Fundraising, //initial state of crowdsale
        Failed, //failed to achieve the minimum target
        Successful, //funding is successfull but not yet transfered the funds to the founders
        Closed //everything is done i.e. the purpose of crowdsale is over
    }
    State private state = State.Fundraising; // setting the default state to fundraising

    struct Contribution {
        uint amount; //amount(in ETH) the person has contributed
        address contributor;
    }
    Contribution[] contributions;

    uint private totalRaised;
    uint private currentBalance; //currentBalance can be less than totalRaised in case of refund
    uint private deadline;
    uint private completedAt;
    uint private priceInWei; //price of token (e.g. 1 token = 1 ETH i.e. 10^18 Wei )
    uint private fundingMinimumTargetInWei;
    uint private fundingMaximumTargetInWei;
    address private creator; //who created the crowdsale
    address private beneficiary; //beneficiary can also be a DAO
    string private campaignUrl;
    byte constant version = 1;

    uint256 private amountInWei=0;
    uint256 private tempTotalRasiedFunds=0;
    uint256 private actualVlaue=0;
    uint256 private refundAmount = 0;
    uint256 private fundingTokens=0;

    event LogRefund(address addr, uint amount);
    event LogFundingReceived(address addr, uint amount, uint currentTotal); //funds received by contributors
    event LogWinnerPaid(address winnerAddress); //whether the beneficiary has paid or not
    event LogFundingSuccessful(uint totalRaised); //will announce when funding is successfully completed
    event LogFunderInitialized(
    address creator,
    address beneficiary,
    string url,
    uint _fundingMaximumTargetInEther,
    uint256 deadline);

    // Modified by amit as on 18th August to stop the tarnsaction if ICO date is Over
    modifier inState(State _state) {
        if ( now > deadline ) {
            state = State.Closed;
        }

        if (state != _state) throw;
        _;
    }

    modifier isMinimum() {
        if(msg.value < priceInWei*10) throw;
        _;
    }

    modifier inMultipleOfPrice() {
        if(msg.value%priceInWei != 0) throw;
        _;
    }

    modifier isCreator() {
        if (msg.sender != creator) throw;
        _;
    }

    modifier atEndOfLifecycle() {
        if(!((state == State.Failed || state == State.Successful) && completedAt < now)) {
            throw;
        }
        _;
    }


    function SetNATVTokenSale () private {

        creator = msg.sender;
        campaignUrl = "www.nativecurrency.com";
        fundingMinimumTargetInWei = 0 * 1 ether;
        fundingMaximumTargetInWei = 30000 * 1 ether;
        deadline = now + (46739 * 1 minutes);
        currentBalance = 0;
        priceInWei = 0.001 * 1 ether;
        LogFunderInitialized(
        creator,
        beneficiary,
        campaignUrl,
        fundingMaximumTargetInWei,
        deadline);
    }

    function contribute(address _sender)
    private
    inState(State.Fundraising) returns (uint256) {

        uint256 _value = this.balance;
        amountInWei = _value;
        tempTotalRasiedFunds = totalRaised + _value;
        actualVlaue = _value;
        //debugLog("amountInWei",amountInWei,1);
        //debugLog("tempTotalRasiedFunds",tempTotalRasiedFunds,2);
        if (fundingMaximumTargetInWei != 0 && tempTotalRasiedFunds > fundingMaximumTargetInWei) {
            //  debugLog("insideIf Loop",0,3);
            refundAmount = tempTotalRasiedFunds-fundingMaximumTargetInWei;
            actualVlaue = _value-refundAmount;
        }
        contributions.push(
            Contribution({
                amount: actualVlaue,
                contributor: _sender
            })
        );

        if ( refundAmount > 0 ){
            if (!_sender.send(refundAmount)) {
                throw;
            }
            LogRefund(_sender,refundAmount);
        }

        totalRaised += actualVlaue;
        currentBalance = totalRaised;

        fundingTokens = (amountInWei * 100000000) / priceInWei;

        releaseTokens(_sender, fundingTokens);

        LogFundingReceived(_sender, actualVlaue, totalRaised);

        payOut();
        checkIfFundingCompleteOrExpired();
        return contributions.length - 1; //this will return the contribution ID
    }


    //************************************************************************************/
    // To check if funding is given to the founders or the beneficiaries

    function checkIfFundingCompleteOrExpired() private {

        if (fundingMaximumTargetInWei != 0 && totalRaised >= fundingMaximumTargetInWei) {
            state = State.Closed;
            LogFundingSuccessful(totalRaised);
            completedAt = now;

        } else if ( now > deadline )  {
            if(totalRaised >= fundingMinimumTargetInWei){
                state = State.Closed;
                LogFundingSuccessful(totalRaised);
                completedAt = now;
            } else{
                state = State.Failed;
                completedAt = now;
            }
        }
    }

    function payOut()
    private
    inState(State.Fundraising)
    {
        if(!beneficiary.send(this.balance)) {
            throw;
        }
        if (state == State.Successful) {
            state = State.Closed;
        }
        currentBalance = 0;
        LogWinnerPaid(beneficiary);
    }

    //***************************************************************************/
    //This default function will execute and will throw an exception if anything is executed besides defined functions

    // Modified by amit, added modifer instate to Verify the State of ICO
    function () payable inState(State.Fundraising) isMinimum() { contribute(msg.sender); }
}
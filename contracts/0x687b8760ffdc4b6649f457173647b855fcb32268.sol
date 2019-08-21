pragma solidity ^0.4.6;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Manager smart contract is used for the management of accounts and tokens.
 *
 * Recipient is 0 for the Dao account manager and the address of
 * contractor's recipient for the contractors's mahagers.
 *
*/

/// @title Manager smart contract of the Pass Decentralized Autonomous Organisation
contract PassManagerInterface {

    struct proposal {
        // Amount (in wei) of the proposal
        uint amount;
        // A description of the proposal
        string description;
        // The hash of the proposal's document
        bytes32 hashOfTheDocument;
        // A unix timestamp, denoting the date when the proposal was created
        uint dateOfProposal;
        // The index of the last approved client proposal
        uint lastClientProposalID;
        // The sum amount (in wei) ordered for this proposal 
        uint orderAmount;
        // A unix timestamp, denoting the date of the last order for the approved proposal
        uint dateOfOrder;
    }
        
    // Proposals to work for the client
    proposal[] public proposals;

    struct fundingData {
        // True if public funding without a main partner
        bool publicCreation; 
        // The address which sets partners and manages the funding in case of private funding
        address mainPartner;
        // The maximum amount (in wei) of the funding
        uint maxAmountToFund;
        // The actual funded amount (in wei)
        uint fundedAmount;
        // A unix timestamp, denoting the start time of the funding
        uint startTime; 
        // A unix timestamp, denoting the closing time of the funding
        uint closingTime;  
        // The price multiplier for a share or a token without considering the inflation rate
        uint initialPriceMultiplier;
        // Rate per year in percentage applied to the share or token price 
        uint inflationRate; 
        // Index of the client proposal
        uint proposalID;
    } 
    
    // Rules for the actual funding and the contractor token price
    fundingData[2] public FundingRules;

    // The address of the last Manager before cloning
    address public clonedFrom;
    // Unix date when shares and tokens can be transferred after cloning (for the Dao manager)
    uint closingTimeForCloning;
    // End date of the setup procedure
    uint public smartContractStartDate;

    // Address of the creator of the smart contract
    address public creator;
    // Address of the Dao (for the Dao manager)
    address client;
    // Address of the recipient;
    address public recipient;
    // Address of the Dao manager (for contractor managers)
    PassManager public daoManager;
    
    // The token name for display purpose
    string public name;
    // The token symbol for display purpose
    string public symbol;
    // The quantity of decimals for display purpose
    uint8 public decimals;

    // True if the initial token supply is over
    bool initialTokenSupplyDone;
    
    // Total amount of tokens
    uint256 totalTokenSupply;

    // Array with all balances
    mapping (address => uint256) balances;
    // Array with all allowances
    mapping (address => mapping (address => uint256)) allowed;

    // Map of the result (in wei) of fundings
    mapping (uint => uint) fundedAmount;

    // Array of token or share holders
    address[] holders;
    // Map with the indexes of the holders
    mapping (address => uint) public holderID;

    // If true, the shares or tokens can be transfered
    bool public transferable;
    // Map of blocked Dao share accounts. Points to the date when the share holder can transfer shares
    mapping (address => uint) public blockedDeadLine; 

    // @return The client of this manager
    function Client() constant returns (address);
    
    // @return The unix date when shares and tokens can be transferred after cloning
    function ClosingTimeForCloning() constant returns (uint);
    
    /// @return The total supply of shares or tokens 
    function totalSupply() constant external returns (uint256);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
     function balanceOf(address _owner) constant external returns (uint256 balance);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Quantity of remaining tokens of _owner that _spender is allowed to spend
    function allowance(address _owner, address _spender) constant external returns (uint256 remaining);

    /// @param _proposalID The index of the Dao proposal
    /// @return The result (in wei) of the funding
    function FundedAmount(uint _proposalID) constant external returns (uint);

    /// @param _saleDate in case of presale, the date of the presale
    /// @return the share or token price divisor condidering the sale date and the inflation rate
    function priceDivisor(uint _saleDate) constant internal returns (uint);
    
    /// @return the actual price divisor of a share or token
    function actualPriceDivisor() constant external returns (uint);

    /// @return The maximal amount a main partner can fund at this moment
    /// @param _mainPartner The address of the main parner
    function fundingMaxAmount(address _mainPartner) constant external returns (uint);
    
    /// @return The number of share or token holders 
    function numberOfHolders() constant returns (uint);

    /// @param _index The index of the holder
    /// @return the address of the an holder
    function HolderAddress(uint _index) constant returns (address);

    /// @return The number of Dao rules proposals     
    function numberOfProposals() constant returns (uint);
    
    /// @dev The constructor function
    /// @param _client The address of the Dao
    /// @param _daoManager The address of the Dao manager (for contractor managers)
    /// @param _recipient The address of the recipient. 0 for the Dao
    /// @param _clonedFrom The address of the last Manager before cloning
    /// @param _tokenName The token name for display purpose
    /// @param _tokenSymbol The token symbol for display purpose
    /// @param _tokenDecimals The quantity of decimals for display purpose
    /// @param _transferable True if allows the transfer of tokens
    //function PassManager(
    //    address _client,
    //    address _daoManager,
    //    address _recipient,
    //    address _clonedFrom,
    //    string _tokenName,
    //    string _tokenSymbol,
    //    uint8 _tokenDecimals,
    //    bool _transferable);
    
    /// @dev Function to create initial tokens    
    /// @param _recipient The beneficiary of the created tokens
    /// @param _quantity The quantity of tokens to create    
    /// @param _last True if the initial token suppy is over
    /// @return Whether the function was successful or not     
    function initialTokenSupply(
        address _recipient, 
        uint _quantity,
        bool _last) returns (bool success);
        
    /// @notice Function to clone a proposal from the last manager
    /// @param _amount Amount (in wei) of the proposal
    /// @param _description A description of the proposal
    /// @param _hashOfTheDocument The hash of the proposal's document
    /// @param _dateOfProposal A unix timestamp, denoting the date when the proposal was created
    /// @param _lastClientProposalID The index of the last approved client proposal
    /// @param _orderAmount The sum amount (in wei) ordered for this proposal 
    /// @param _dateOfOrder A unix timestamp, denoting the date of the last order for the approved proposal
    /// @return Whether the function was successful or not 
    function cloneProposal(
        uint _amount,
        string _description,
        bytes32 _hashOfTheDocument,
        uint _dateOfProposal,
        uint _lastClientProposalID,
        uint _orderAmount,
        uint _dateOfOrder) returns (bool success);
    
    /// @notice Function to clone tokens from a manager
    /// @param _from The index of the first holder
    /// @param _to The index of the last holder
    /// @return Whether the function was successful or not 
    function cloneTokens(
        uint _from,
        uint _to) returns (bool success);
    
    /// @notice Function to close the setup procedure of this contract
    function closeSetup();

    /// @notice Function to update the recipent address
    /// @param _newRecipient The adress of the recipient
    function updateRecipient(address _newRecipient);

    /// @notice Function to receive payments or deposits
    function () payable;
    
    /// @notice Function to allow contractors to withdraw ethers
    /// @param _amount The amount (in wei) to withdraw
    function withdraw(uint _amount);

    /// @notice Function to update the client address
    function updateClient(address _newClient);
    
    /// @notice Function to make a proposal to work for the client
    /// @param _amount The amount (in wei) of the proposal
    /// @param _description String describing the proposal
    /// @param _hashOfTheDocument The hash of the proposal document
    /// @return The index of the contractor proposal
    function newProposal(
        uint _amount,
        string _description, 
        bytes32 _hashOfTheDocument
    ) returns (uint);
        
    /// @notice Function used by the client to order according to the contractor proposal
    /// @param _clientProposalID The index of the last approved client proposal
    /// @param _proposalID The index of the contractor proposal
    /// @param _amount The amount (in wei) of the order
    /// @return Whether the order was made or not
    function order(
        uint _clientProposalID,
        uint _proposalID,
        uint _amount
    ) external returns (bool) ;
    
    /// @notice Function used by the client to send ethers from the Dao manager
    /// @param _recipient The address to send to
    /// @param _amount The amount (in wei) to send
    /// @return Whether the transfer was successful or not
    function sendTo(
        address _recipient, 
        uint _amount
    ) external returns (bool);
    
    /// @dev Internal function to add a new token or share holder
    /// @param _holder The address of the token or share holder
    function addHolder(address _holder) internal;
    
    /// @dev Internal function to create initial tokens    
    /// @param _holder The beneficiary of the created tokens
    /// @param _quantity The quantity of tokens to create
    /// @return Whether the function was successful or not 
    function createInitialTokens(address _holder, uint _quantity) internal returns (bool success) ;
    
    /// @notice Function that allow the contractor to propose a token price
    /// @param _initialPriceMultiplier The initial price multiplier of contractor tokens
    /// @param _inflationRate If 0, the contractor token price doesn't change during the funding
    /// @param _closingTime The initial price and inflation rate can be changed after this date
    function setTokenPriceProposal(        
        uint _initialPriceMultiplier, 
        uint _inflationRate,
        uint _closingTime
    );

    /// @notice Function to set a funding. Can be private or public
    /// @param _mainPartner The address of the smart contract to manage a private funding
    /// @param _publicCreation True if public funding
    /// @param _initialPriceMultiplier Price multiplier without considering any inflation rate
    /// @param _maxAmountToFund The maximum amount (in wei) of the funding
    /// @param _minutesFundingPeriod Period in minutes of the funding
    /// @param _inflationRate If 0, the token price doesn't change during the funding
    /// @param _proposalID Index of the client proposal (not mandatory)
    function setFundingRules(
        address _mainPartner,
        bool _publicCreation, 
        uint _initialPriceMultiplier, 
        uint _maxAmountToFund, 
        uint _minutesFundingPeriod, 
        uint _inflationRate,
        uint _proposalID
    ) external;
    
    /// @dev Internal function for the creation of shares or tokens
    /// @param _recipient The recipient address of shares or tokens
    /// @param _amount The funded amount (in wei)
    /// @param _saleDate In case of presale, the date of the presale
    /// @return Whether the creation was successful or not
    function createToken(
        address _recipient, 
        uint _amount,
        uint _saleDate
    ) internal returns (bool success);

    /// @notice Function used by the main partner to set the start time of the funding
    /// @param _startTime The unix start date of the funding 
    function setFundingStartTime(uint _startTime) external;

    /// @notice Function used by the main partner to reward shares or tokens
    /// @param _recipient The address of the recipient of shares or tokens
    /// @param _amount The amount (in Wei) to calculate the quantity of shares or tokens to create
    /// @param _date The unix date to consider for the share or token price calculation
    /// @return Whether the transfer was successful or not
    function rewardToken(
        address _recipient, 
        uint _amount,
        uint _date
        ) external;

    /// @dev Internal function to close the actual funding
    function closeFunding() internal;
    
    /// @notice Function used by the main partner to set the funding fueled
    function setFundingFueled() external;

    /// @notice Function to able the transfer of Dao shares or contractor tokens
    function ableTransfer();

    /// @notice Function to disable the transfer of Dao shares
    /// @param _closingTime Date when shares or tokens can be transferred
    function disableTransfer(uint _closingTime);

    /// @notice Function used by the client to block the transfer of shares from and to a share holder
    /// @param _shareHolder The address of the share holder
    /// @param _deadLine When the account will be unblocked
    function blockTransfer(address _shareHolder, uint _deadLine) external;

    /// @notice Function to buy Dao shares according to the funding rules 
    /// with `msg.sender` as the beneficiary
    function buyShares() payable;
    
    /// @notice Function to buy Dao shares according to the funding rules 
    /// @param _recipient The beneficiary of the created shares
    function buySharesFor(address _recipient) payable;
    
    /// @dev Internal function to send `_value` token to `_to` from `_From`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The quantity of shares or tokens to be transferred
    /// @return Whether the function was successful or not 
    function transferFromTo(
        address _from,
        address _to, 
        uint256 _value
        ) internal returns (bool success);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The quantity of shares or tokens to be transferred
    /// @return Whether the function was successful or not 
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The quantity of shares or tokens to be transferred
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
        ) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on its behalf
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    event FeesReceived(address indexed From, uint Amount);
    event AmountReceived(address indexed From, uint Amount);
    event paymentReceived(address indexed daoManager, uint Amount);
    event ProposalCloned(uint indexed LastClientProposalID, uint indexed ProposalID, uint Amount, string Description, bytes32 HashOfTheDocument);
    event ClientUpdated(address LastClient, address NewClient);
    event RecipientUpdated(address LastRecipient, address NewRecipient);
    event ProposalAdded(uint indexed ProposalID, uint Amount, string Description, bytes32 HashOfTheDocument);
    event Order(uint indexed clientProposalID, uint indexed ProposalID, uint Amount);
    event Withdawal(address indexed Recipient, uint Amount);
    event TokenPriceProposalSet(uint InitialPriceMultiplier, uint InflationRate, uint ClosingTime);
    event holderAdded(uint Index, address Holder);
    event TokensCreated(address indexed Sender, address indexed TokenHolder, uint Quantity);
    event FundingRulesSet(address indexed MainPartner, uint indexed FundingProposalId, uint indexed StartTime, uint ClosingTime);
    event FundingFueled(uint indexed FundingProposalID, uint FundedAmount);
    event TransferAble();
    event TransferDisable(uint closingTime);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


}    

contract PassManager is PassManagerInterface {

// Constant functions

    function Client() constant returns (address) {
        if (recipient == 0) return client;
        else return daoManager.Client();
    }
    
    function ClosingTimeForCloning() constant returns (uint) {
        if (recipient == 0) return closingTimeForCloning;
        else return daoManager.ClosingTimeForCloning();
    }
    
    function totalSupply() constant external returns (uint256) {
        return totalTokenSupply;
    }

     function balanceOf(address _owner) constant external returns (uint256 balance) {
        return balances[_owner];
     }

    function allowance(address _owner, address _spender) constant external returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function FundedAmount(uint _proposalID) constant external returns (uint) {
        return fundedAmount[_proposalID];
    }

    function priceDivisor(uint _saleDate) constant internal returns (uint) {
        uint _date = _saleDate;
        
        if (_saleDate > FundingRules[0].closingTime) _date = FundingRules[0].closingTime;
        if (_saleDate < FundingRules[0].startTime) _date = FundingRules[0].startTime;

        return 100 + 100*FundingRules[0].inflationRate*(_date - FundingRules[0].startTime)/(100*365 days);
    }
    
    function actualPriceDivisor() constant external returns (uint) {
        return priceDivisor(now);
    }

    function fundingMaxAmount(address _mainPartner) constant external returns (uint) {
        
        if (now > FundingRules[0].closingTime
            || now < FundingRules[0].startTime
            || _mainPartner != FundingRules[0].mainPartner) {
            return 0;   
        } else {
            return FundingRules[0].maxAmountToFund;
        }
        
    }

    function numberOfHolders() constant returns (uint) {
        return holders.length - 1;
    }
    
    function HolderAddress(uint _index) constant returns (address) {
        return holders[_index];
    }

    function numberOfProposals() constant returns (uint) {
        return proposals.length - 1;
    }

// Modifiers

    // Modifier that allows only the client to manage this account manager
    modifier onlyClient {if (msg.sender != Client()) throw; _;}
    
    // Modifier that allows only the main partner to manage the actual funding
    modifier onlyMainPartner {if (msg.sender !=  FundingRules[0].mainPartner) throw; _;}
    
    // Modifier that allows only the contractor propose set the token price or withdraw
    modifier onlyContractor {if (recipient == 0 || (msg.sender != recipient && msg.sender != creator)) throw; _;}
    
    // Modifier for Dao functions
    modifier onlyDao {if (recipient != 0) throw; _;}
    
// Constructor function

    function PassManager(
        address _client,
        address _daoManager,
        address _recipient,
        address _clonedFrom,
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        bool _transferable
    ) {

        if ((_recipient == 0 && _client == 0)
            || _client == _recipient) throw;

        creator = msg.sender; 
        client = _client;
        recipient = _recipient;
        
        if (_recipient !=0) daoManager = PassManager(_daoManager);

        clonedFrom = _clonedFrom;            
        
        name = _tokenName;
        symbol = _tokenSymbol;
        decimals = _tokenDecimals;
          
        if (_transferable) {
            transferable = true;
            TransferAble();
        } else {
            transferable = false;
            TransferDisable(0);
        }

        holders.length = 1;
        proposals.length = 1;
        
    }

// Setting functions

    function initialTokenSupply(
        address _recipient, 
        uint _quantity,
        bool _last) returns (bool success) {

        if (smartContractStartDate != 0 || initialTokenSupplyDone) throw;
        
        if (_recipient != 0 && _quantity != 0) {
            return (createInitialTokens(_recipient, _quantity));
        }
        
        if (_last) initialTokenSupplyDone = true;
            
    }

    function cloneProposal(
        uint _amount,
        string _description,
        bytes32 _hashOfTheDocument,
        uint _dateOfProposal,
        uint _lastClientProposalID,
        uint _orderAmount,
        uint _dateOfOrder
    ) returns (bool success) {
            
        if (smartContractStartDate != 0 || recipient == 0
        || msg.sender != creator) throw;
        
        uint _proposalID = proposals.length++;
        proposal c = proposals[_proposalID];

        c.amount = _amount;
        c.description = _description;
        c.hashOfTheDocument = _hashOfTheDocument; 
        c.dateOfProposal = _dateOfProposal;
        c.lastClientProposalID = _lastClientProposalID;
        c.orderAmount = _orderAmount;
        c.dateOfOrder = _dateOfOrder;
        
        ProposalCloned(_lastClientProposalID, _proposalID, c.amount, c.description, c.hashOfTheDocument);
        
        return true;
            
    }

    function cloneTokens(
        uint _from,
        uint _to) returns (bool success) {
        
        if (smartContractStartDate != 0) throw;
        
        PassManager _clonedFrom = PassManager(clonedFrom);
        
        if (_from < 1 || _to > _clonedFrom.numberOfHolders()) throw;

        address _holder;

        for (uint i = _from; i <= _to; i++) {
            _holder = _clonedFrom.HolderAddress(i);
            if (balances[_holder] == 0) {
                createInitialTokens(_holder, _clonedFrom.balanceOf(_holder));
            }
        }

        return true;
        
    }

    function closeSetup() {
        
        if (smartContractStartDate != 0 || msg.sender != creator) throw;

        smartContractStartDate = now;

    }

// Function to receive payments or deposits

    function () payable {
        AmountReceived(msg.sender, msg.value);
    }
    
// Contractors Account Management

    function updateRecipient(address _newRecipient) onlyContractor {

        if (_newRecipient == 0 
            || _newRecipient == client) throw;

        RecipientUpdated(recipient, _newRecipient);
        recipient = _newRecipient;

    } 

    function withdraw(uint _amount) onlyContractor {
        if (!recipient.send(_amount)) throw;
        Withdawal(recipient, _amount);
    }
    
// DAO Proposals Management

    function updateClient(address _newClient) onlyClient {
        
        if (_newClient == 0 
            || _newClient == recipient) throw;

        ClientUpdated(client, _newClient);
        client = _newClient;        

    }

    function newProposal(
        uint _amount,
        string _description, 
        bytes32 _hashOfTheDocument
    ) onlyContractor returns (uint) {

        uint _proposalID = proposals.length++;
        proposal c = proposals[_proposalID];

        c.amount = _amount;
        c.description = _description;
        c.hashOfTheDocument = _hashOfTheDocument; 
        c.dateOfProposal = now;
        
        ProposalAdded(_proposalID, c.amount, c.description, c.hashOfTheDocument);
        
        return _proposalID;
        
    }
    
    function order(
        uint _clientProposalID,
        uint _proposalID,
        uint _orderAmount
    ) external onlyClient returns (bool) {
    
        proposal c = proposals[_proposalID];
        
        uint _sum = c.orderAmount + _orderAmount;
        if (_sum > c.amount
            || _sum < c.orderAmount
            || _sum < _orderAmount) return; 

        c.lastClientProposalID =  _clientProposalID;
        c.orderAmount = _sum;
        c.dateOfOrder = now;
        
        Order(_clientProposalID, _proposalID, _orderAmount);
        
        return true;

    }

    function sendTo(
        address _recipient,
        uint _amount
    ) external onlyClient onlyDao returns (bool) {

        if (_recipient.send(_amount)) return true;
        else return false;

    }
    
// Token Management
    
    function addHolder(address _holder) internal {
        
        if (holderID[_holder] == 0) {
            
            uint _holderID = holders.length++;
            holders[_holderID] = _holder;
            holderID[_holder] = _holderID;
            holderAdded(_holderID, _holder);

        }
        
    }
    
    function createInitialTokens(
        address _holder, 
        uint _quantity
    ) internal returns (bool success) {

        if (_quantity > 0 && balances[_holder] == 0) {
            addHolder(_holder);
            balances[_holder] = _quantity; 
            totalTokenSupply += _quantity;
            TokensCreated(msg.sender, _holder, _quantity);
            return true;
        }
        
    }
    
    function setTokenPriceProposal(        
        uint _initialPriceMultiplier, 
        uint _inflationRate,
        uint _closingTime
    ) onlyContractor {
        
        if (_closingTime < now 
            || now < FundingRules[1].closingTime) throw;
        
        FundingRules[1].initialPriceMultiplier = _initialPriceMultiplier;
        FundingRules[1].inflationRate = _inflationRate;
        FundingRules[1].startTime = now;
        FundingRules[1].closingTime = _closingTime;
        
        TokenPriceProposalSet(_initialPriceMultiplier, _inflationRate, _closingTime);
    }
    
    function setFundingRules(
        address _mainPartner,
        bool _publicCreation, 
        uint _initialPriceMultiplier,
        uint _maxAmountToFund, 
        uint _minutesFundingPeriod, 
        uint _inflationRate,
        uint _proposalID
    ) external onlyClient {

        if (now < FundingRules[0].closingTime
            || _mainPartner == address(this)
            || _mainPartner == client
            || (!_publicCreation && _mainPartner == 0)
            || (_publicCreation && _mainPartner != 0)
            || (recipient == 0 && _initialPriceMultiplier == 0)
            || (recipient != 0 
                && (FundingRules[1].initialPriceMultiplier == 0
                    || _inflationRate < FundingRules[1].inflationRate
                    || now < FundingRules[1].startTime
                    || FundingRules[1].closingTime < now + (_minutesFundingPeriod * 1 minutes)))
            || _maxAmountToFund == 0
            || _minutesFundingPeriod == 0
            ) throw;

        FundingRules[0].startTime = now;
        FundingRules[0].closingTime = now + _minutesFundingPeriod * 1 minutes;
            
        FundingRules[0].mainPartner = _mainPartner;
        FundingRules[0].publicCreation = _publicCreation;
        
        if (recipient == 0) FundingRules[0].initialPriceMultiplier = _initialPriceMultiplier;
        else FundingRules[0].initialPriceMultiplier = FundingRules[1].initialPriceMultiplier;
        
        if (recipient == 0) FundingRules[0].inflationRate = _inflationRate;
        else FundingRules[0].inflationRate = FundingRules[1].inflationRate;
        
        FundingRules[0].fundedAmount = 0;
        FundingRules[0].maxAmountToFund = _maxAmountToFund;

        FundingRules[0].proposalID = _proposalID;

        FundingRulesSet(_mainPartner, _proposalID, FundingRules[0].startTime, FundingRules[0].closingTime);
            
    } 
    
    function createToken(
        address _recipient, 
        uint _amount,
        uint _saleDate
    ) internal returns (bool success) {

        if (now > FundingRules[0].closingTime
            || now < FundingRules[0].startTime
            ||_saleDate > FundingRules[0].closingTime
            || _saleDate < FundingRules[0].startTime
            || FundingRules[0].fundedAmount + _amount > FundingRules[0].maxAmountToFund) return;

        uint _a = _amount*FundingRules[0].initialPriceMultiplier;
        uint _multiplier = 100*_a;
        uint _quantity = _multiplier/priceDivisor(_saleDate);
        if (_a/_amount != FundingRules[0].initialPriceMultiplier
            || _multiplier/100 != _a
            || totalTokenSupply + _quantity <= totalTokenSupply 
            || totalTokenSupply + _quantity <= _quantity) return;

        addHolder(_recipient);
        balances[_recipient] += _quantity;
        totalTokenSupply += _quantity;
        FundingRules[0].fundedAmount += _amount;

        TokensCreated(msg.sender, _recipient, _quantity);
        
        if (FundingRules[0].fundedAmount == FundingRules[0].maxAmountToFund) closeFunding();
        
        return true;

    }

    function setFundingStartTime(uint _startTime) external onlyMainPartner {
        if (now > FundingRules[0].closingTime) throw;
        FundingRules[0].startTime = _startTime;
    }
    
    function rewardToken(
        address _recipient, 
        uint _amount,
        uint _date
        ) external onlyMainPartner {

        uint _saleDate;
        if (_date == 0) _saleDate = now; else _saleDate = _date;

        if (!createToken(_recipient, _amount, _saleDate)) throw;

    }

    function closeFunding() internal {
        if (recipient == 0) fundedAmount[FundingRules[0].proposalID] = FundingRules[0].fundedAmount;
        FundingRules[0].closingTime = now;
    }
    
    function setFundingFueled() external onlyMainPartner {
        if (now > FundingRules[0].closingTime) throw;
        closeFunding();
        if (recipient == 0) FundingFueled(FundingRules[0].proposalID, FundingRules[0].fundedAmount);
    }
    
    function ableTransfer() onlyClient {
        if (!transferable) {
            transferable = true;
            closingTimeForCloning = 0;
            TransferAble();
        }
    }

    function disableTransfer(uint _closingTime) onlyClient {
        if (transferable && _closingTime == 0) transferable = false;
        else closingTimeForCloning = _closingTime;
            
        TransferDisable(_closingTime);
    }
    
    function blockTransfer(address _shareHolder, uint _deadLine) external onlyClient onlyDao {
        if (_deadLine > blockedDeadLine[_shareHolder]) {
            blockedDeadLine[_shareHolder] = _deadLine;
        }
    }
    
    function buyShares() payable {
        buySharesFor(msg.sender);
    } 
    
    function buySharesFor(address _recipient) payable onlyDao {
        
        if (!FundingRules[0].publicCreation 
            || !createToken(_recipient, msg.value, now)) throw;

    }
    
    function transferFromTo(
        address _from,
        address _to, 
        uint256 _value
        ) internal returns (bool success) {  

        if ((transferable && now > ClosingTimeForCloning())
            && now > blockedDeadLine[_from]
            && now > blockedDeadLine[_to]
            && _to != address(this)
            && balances[_from] >= _value
            && balances[_to] + _value > balances[_to]
            && balances[_to] + _value >= _value
        ) {
            balances[_from] -= _value;
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            addHolder(_to);
            return true;
        } else {
            return false;
        }
        
    }

    function transfer(address _to, uint256 _value) returns (bool success) {  
        if (!transferFromTo(msg.sender, _to, _value)) throw;
        return true;
    }

    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
        ) returns (bool success) { 
        
        if (allowed[_from][msg.sender] < _value
            || !transferFromTo(_from, _to, _value)) throw;
            
        allowed[_from][msg.sender] -= _value;
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        return true;
    }
    
}
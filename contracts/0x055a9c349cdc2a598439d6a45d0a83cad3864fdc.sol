pragma solidity ^0.4.2;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Token Manager smart contract is used for the management of tokens
 * by a client smart contract (the Dao). Defines the functions to set new funding rules,
 * create or reward tokens, check token balances, send tokens and send
 * tokens on behalf of a 3rd party and the corresponding approval process.
 *
*/

/// @title Token Manager smart contract of the Pass Decentralized Autonomous Organisation
contract PassTokenManagerInterface {
    
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

    // Address of the creator of the smart contract
    address public creator;
    // Address of the Dao    
    address public client;
    // Address of the recipient;
    address public recipient;
    
    // The token name for display purpose
    string public name;
    // The token symbol for display purpose
    string public symbol;
    // The quantity of decimals for display purpose
    uint8 public decimals;

    // Total amount of tokens
    uint256 totalSupply;

    // Array with all balances
    mapping (address => uint256) balances;
    // Array with all allowances
    mapping (address => mapping (address => uint256)) allowed;

    // Map of the result (in wei) of fundings
    mapping (uint => uint) fundedAmount;
    
    // If true, the shares or tokens can be transfered
    bool public transferable;
    // Map of blocked Dao share accounts. Points to the date when the share holder can transfer shares
    mapping (address => uint) public blockedDeadLine; 

    // Rules for the actual funding and the contractor token price
    fundingData[2] public FundingRules;
    
    /// @return The total supply of shares or tokens 
    function TotalSupply() constant external returns (uint256);

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

    // Modifier that allows only the client to manage this account manager
    modifier onlyClient {if (msg.sender != client) throw; _;}

    // Modifier that allows only the main partner to manage the actual funding
    modifier onlyMainPartner {if (msg.sender !=  FundingRules[0].mainPartner) throw; _;}
    
    // Modifier that allows only the contractor propose set the token price or withdraw
    modifier onlyContractor {if (recipient == 0 || (msg.sender != recipient && msg.sender != creator)) throw; _;}
    
    // Modifier for Dao functions
    modifier onlyDao {if (recipient != 0) throw; _;}
    
    /// @dev The constructor function
    /// @param _creator The address of the creator of the smart contract
    /// @param _client The address of the client or Dao
    /// @param _recipient The recipient of this manager
    //function TokenManager(
        //address _creator,
        //address _client,
        //address _recipient
    //);

    /// @param _tokenName The token name for display purpose
    /// @param _tokenSymbol The token symbol for display purpose
    /// @param _tokenDecimals The quantity of decimals for display purpose
    /// @param _initialSupplyRecipient The recipient of the initial supply (not mandatory)
    /// @param _initialSupply The initial supply of tokens for the recipient (not mandatory)
    /// @param _transferable True if allows the transfer of tokens
    function initToken(
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        address _initialSupplyRecipient,
        uint256 _initialSupply,
        bool _transferable
       );

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
    function disableTransfer();

    /// @notice Function used by the client to block the transfer of shares from and to a share holder
    /// @param _shareHolder The address of the share holder
    /// @param _deadLine When the account will be unblocked
    function blockTransfer(address _shareHolder, uint _deadLine) external;

    /// @dev Internal function to send `_value` token to `_to` from `_From`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The quantity of shares or tokens to be transferred
    /// @return Whether the function was successful or not 
    function transferFromTo(
        address _from,
        address _to, 
        uint256 _value
        ) internal returns (bool);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The quantity of shares or tokens to be transferred
    function transfer(address _to, uint256 _value);

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

    event TokensCreated(address indexed Sender, address indexed TokenHolder, uint Quantity);
    event FundingRulesSet(address indexed MainPartner, uint indexed FundingProposalId, uint indexed StartTime, uint ClosingTime);
    event FundingFueled(uint indexed FundingProposalID, uint FundedAmount);
    event TransferAble();
    event TransferDisable();

}    

contract PassTokenManager is PassTokenManagerInterface {
    
    function TotalSupply() constant external returns (uint256) {
        return totalSupply;
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

    function PassTokenManager(
        address _creator,
        address _client,
        address _recipient
    ) {
        
        if (_creator == 0 
            || _client == 0 
            || _client == _recipient 
            || _client == address(this) 
            || _recipient == address(this)) throw;

        creator = _creator; 
        client = _client;
        recipient = _recipient;
        
    }
   
    function initToken(
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        address _initialSupplyRecipient,
        uint256 _initialSupply,
        bool _transferable) {
           
        if (_initialSupplyRecipient == address(this)
            || decimals != 0
            || msg.sender != creator
            || totalSupply != 0) throw;
            
        name = _tokenName;
        symbol = _tokenSymbol;
        decimals = _tokenDecimals;
          
        if (_transferable) {
            transferable = true;
            TransferAble();
        } else {
            transferable = false;
            TransferDisable();
        }
        
        balances[_initialSupplyRecipient] = _initialSupply; 
        totalSupply = _initialSupply;
        TokensCreated(msg.sender, _initialSupplyRecipient, _initialSupply);
           
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
            || totalSupply + _quantity <= totalSupply 
            || totalSupply + _quantity <= _quantity) return;

        balances[_recipient] += _quantity;
        totalSupply += _quantity;
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
            TransferAble();
        }
    }

    function disableTransfer() onlyClient {
        if (transferable) {
            transferable = false;
            TransferDisable();
        }
    }
    
    function blockTransfer(address _shareHolder, uint _deadLine) external onlyClient onlyDao {
        if (_deadLine > blockedDeadLine[_shareHolder]) {
            blockedDeadLine[_shareHolder] = _deadLine;
        }
    }
    
    function transferFromTo(
        address _from,
        address _to, 
        uint256 _value
        ) internal returns (bool) {  

        if (transferable
            && now > blockedDeadLine[_from]
            && now > blockedDeadLine[_to]
            && _to != address(this)
            && balances[_from] >= _value
            && balances[_to] + _value > balances[_to]
            && balances[_to] + _value >= _value
        ) {
            balances[_from] -= _value;
            balances[_to] += _value;
            return true;
        } else {
            return false;
        }
        
    }

    function transfer(address _to, uint256 _value) {  
        if (!transferFromTo(msg.sender, _to, _value)) throw;
    }

    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
        ) returns (bool success) { 
        
        if (allowed[_from][msg.sender] < _value
            || !transferFromTo(_from, _to, _value)) throw;
            
        allowed[_from][msg.sender] -= _value;

    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        return true;
    }

}    
  

pragma solidity ^0.4.2;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Manager smart contract is used for the management of accounts and tokens.
 * Allows to receive or withdraw ethers and to buy Dao shares.
 * The contract derives to the Token Manager smart contract for the management of tokens.
 *
 * Recipient is 0 for the Dao account manager and the address of
 * contractor's recipient for the contractors's mahagers.
 *
*/

/// @title Manager smart contract of the Pass Decentralized Autonomous Organisation
contract PassManagerInterface is PassTokenManagerInterface {

    struct proposal {
        // Amount (in wei) of the proposal
        uint amount;
        // A description of the proposal
        string description;
        // The hash of the proposal's document
        bytes32 hashOfTheDocument;
        // A unix timestamp, denoting the date when the proposal was created
        uint dateOfProposal;
        // The sum amount (in wei) ordered for this proposal 
        uint orderAmount;
        // A unix timestamp, denoting the date of the last order for the approved proposal
        uint dateOfOrder;
    }
        
    // Proposals to work for the client
    proposal[] public proposals;
    
    /// @dev The constructor function
    /// @param _creator The address of the creator
    /// @param _client The address of the Dao
    /// @param _recipient The address of the recipient. 0 for the Dao
    //function PassManager(
        //address _creator,
        //address _client,
        //address _recipient
    //) PassTokenManager(
        //_creator,
        //_client,
        //_recipient);

    /// @notice Fallback function to allow sending ethers to this smart contract
    function () payable;
    
    /// @notice Function to update the recipent address
    /// @param _newRecipient The adress of the recipient
    function updateRecipient(address _newRecipient);

    /// @notice Function to buy Dao shares according to the funding rules 
    /// with `msg.sender` as the beneficiary
    function buyShares() payable;
    
    /// @notice Function to buy Dao shares according to the funding rules 
    /// @param _recipient The beneficiary of the created shares
    function buySharesFor(address _recipient) payable;

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
    /// @param _proposalID The index of the contractor proposal
    /// @param _amount The amount (in wei) of the order
    /// @return Whether the order was made or not
    function order(
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

    /// @notice Function to allow contractors to withdraw ethers
    /// @param _amount The amount (in wei) to withdraw
    function withdraw(uint _amount);
    
    event ProposalAdded(uint indexed ProposalID, uint Amount, string Description);
    event Order(uint indexed ProposalID, uint Amount);
    event Withdawal(address indexed Recipient, uint Amount);

}    

contract PassManager is PassManagerInterface, PassTokenManager {

    function PassManager(
        address _creator,
        address _client,
        address _recipient
    ) PassTokenManager(
        _creator,
        _client,
        _recipient
        ) {
        proposals.length = 1;
    }

    function () payable {}

    function updateRecipient(address _newRecipient) onlyContractor {

        if (_newRecipient == 0 
            || _newRecipient == client) throw;

        recipient = _newRecipient;
    } 

    function buyShares() payable {
        buySharesFor(msg.sender);
    } 
    
    function buySharesFor(address _recipient) payable onlyDao {
        
        if (!FundingRules[0].publicCreation 
            || !createToken(_recipient, msg.value, now)) throw;

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
        
        ProposalAdded(_proposalID, c.amount, c.description);
        
        return _proposalID;
        
    }
    
    function order(
        uint _proposalID,
        uint _orderAmount
    ) external onlyClient returns (bool) {
    
        proposal c = proposals[_proposalID];
        
        uint _sum = c.orderAmount + _orderAmount;
        if (_sum > c.amount
            || _sum < c.orderAmount
            || _sum < _orderAmount) return; 

        c.orderAmount = _sum;
        c.dateOfOrder = now;
        
        Order(_proposalID, _orderAmount);
        
        return true;

    }

    function sendTo(
        address _recipient,
        uint _amount
    ) external onlyClient onlyDao returns (bool) {
    
        if (_recipient.send(_amount)) return true;
        else return false;

    }
   
    function withdraw(uint _amount) onlyContractor {
        if (!recipient.send(_amount)) throw;
        Withdawal(recipient, _amount);
    }
    
}    

contract PassManagerCreator {
    event NewPassManager(address Creator, address Client, address Recipient, address PassManager);
    function createManager(
        address _client,
        address _recipient
        ) returns (PassManager) {
        PassManager _passManager = new PassManager(
            msg.sender,
            _client,
            _recipient
        );
        NewPassManager(msg.sender, _client, _recipient, _passManager);
        return _passManager;
    }
}

pragma solidity ^0.4.2;

/*
 *
 * This file is part of the DAO.
 *
 * Smart contract used for the funding of Pass Dao.
 *
*/

/// @title Funding smart contract for the Pass Decentralized Autonomous Organisation
contract PassFundingInterface {

    struct Partner {
        // The address of the partner
        address partnerAddress; 
        // The amount (in wei) that the partner wish to fund
        uint presaleAmount;
        // The unix timestamp denoting the average date of the presale of the partner 
        uint presaleDate;
        // The funding amount (in wei) according to the set limits
        uint fundingAmountLimit;
        // The amount (in wei) that the partner funded to the Dao
        uint fundedAmount;
        // True if the partner can fund the dao
        bool valid;
    }

    // Address of the creator of this contract
    address public creator;
    // The manager smart contract to fund
    PassManager public DaoManager;
    // True if contractor token creation
    bool tokenCreation;            
    // The manager smart contract for the reward of contractor tokens
    PassManager public contractorManager;
    // Minimum amount (in wei) to fund
    uint public minFundingAmount;
    // Minimum amount (in wei) that partners can send to this smart contract
    uint public minPresaleAmount;
    // Maximum amount (in wei) that partners can send to this smart contract
    uint public maxPresaleAmount;
    // The unix start time of the presale
    uint public startTime;
    // The unix closing time of the funding
    uint public closingTime;
    /// The amount (in wei) below this limit can fund the dao
    uint minAmountLimit;
    /// Maximum amount (in wei) a partner can fund
    uint maxAmountLimit; 
    /// The partner can fund below the minimum amount limit or a set percentage of his ether balance 
    uint divisorBalanceLimit;
    /// The partner can fund below the minimum amount limit or a set percentage of his shares balance in the Dao
    uint multiplierSharesLimit;
    /// The partner can fund below the minimum amount limit or a set percentage of his shares balance in the Dao 
    uint divisorSharesLimit;
    // True if the amount and divisor balance limits for the funding are set
    bool public limitSet;
    // True if all the partners are set by the creator and the funding can be completed 
    bool public allSet;
    // Array of partners who wish to fund the dao
    Partner[] public partners;
    // Map with the indexes of the partners
    mapping (address => uint) public partnerID; 
    // The total funded amount (in wei)
    uint public totalFunded; 
    // The calculated sum of funding amout limits (in wei) according to the set limits
    uint sumOfFundingAmountLimits;
    
    // To allow the creator to pause during the presale
    uint public pauseClosingTime;
    // To allow the creator to abort the funding before the closing time
    bool IsfundingAborted;
    
    // To allow the set of partners in several times
    uint setFromPartner;
    // To allow the refund for partners in several times
    uint refundFromPartner;

    // The manager of this funding is the creator of this contract
    modifier onlyCreator {if (msg.sender != creator) throw; _ ;}

    /// @dev Constructor function
    /// @param _creator The creator of the smart contract
    /// @param _DaoManager The Dao manager smart contract
    /// for the reward of tokens (not mandatory)
    /// @param _minAmount Minimum amount (in wei) of the funding to be fueled 
    /// @param _startTime The unix start time of the presale
    /// @param _closingTime The unix closing time of the funding
    //function PassFunding (
        //address _creator,
        //address _DaoManager,
        //uint _minAmount,
        //uint _startTime,
        //uint _closingTime
    //);

    /// @notice Function used by the creator to set the contractor manager smart contract
    /// @param _contractorManager The address of the contractor manager smart contract
    function SetContractorManager(address _contractorManager);
    
    /// @notice Function used by the creator to set the presale limits
    /// @param _minPresaleAmount Minimum amount (in wei) that partners can send
    /// @param _maxPresaleAmount Maximum amount (in wei) that partners can send
    function SetPresaleAmountLimits(
        uint _minPresaleAmount,
        uint _maxPresaleAmount
        );

    /// @dev Fallback function
    function () payable;

    /// @notice Function to participate in the presale of the funding
    /// @return Whether the presale was successful or not
    function presale() payable returns (bool);
    
    /// @notice Function used by the creator to set addresses that can fund the dao
    /// @param _valid True if the address can fund the Dao
    /// @param _from The index of the first partner to set
    /// @param _to The index of the last partner to set
    function setPartners(
            bool _valid,
            uint _from,
            uint _to
        );

    /// @notice Function used by the creator to set the addresses of Dao share holders
    /// @param _valid True if the address can fund the Dao
    /// @param _from The index of the first partner to set
    /// @param _to The index of the last partner to set
    function setShareHolders(
            bool _valid,
            uint _from,
            uint _to
        );
    
    /// @notice Function to allow the creator to abort the funding before the closing time
    function abortFunding();
    
    /// @notice Function To allow the creator to pause during the presale
    function pause(uint _pauseClosingTime) {
        pauseClosingTime = _pauseClosingTime;
    }

    /// @notice Function used by the creator to set the funding limits for the funding
    /// @param _minAmountLimit The amount below this limit (in wei) can fund the dao
    /// @param _maxAmountLimit Maximum amount (in wei) a partner can fund
    /// @param _divisorBalanceLimit The creator can set a limit in percentage of Eth balance (not mandatory)
    /// @param _multiplierSharesLimit The creator can set a limit in percentage of shares balance in the Dao (not mandatory)
    /// @param _divisorSharesLimit The creator can set a limit in percentage of shares balance in the Dao (not mandatory) 
    function setLimits(
            uint _minAmountLimit,
            uint _maxAmountLimit, 
            uint _divisorBalanceLimit,
            uint _multiplierSharesLimit,
            uint _divisorSharesLimit
    );

    /// @notice Function used to set the funding limits for partners
    /// @param _to The index of the last partner to set
    /// @return Whether the set was successful or not
    function setFunding(uint _to) returns (bool _success);

    /// @notice Function for the funding of the Dao by a group of partners
    /// @param _from The index of the first partner
    /// @param _to The index of the last partner
    /// @return Whether the Dao was funded or not
    function fundDaoFor(
            uint _from,
            uint _to
        ) returns (bool);
    
    /// @notice Function to fund the Dao with 'msg.sender' as 'beneficiary'
    /// @return Whether the Dao was funded or not 
    function fundDao() returns (bool);
    
    /// @notice Function to refund for a partner
    /// @param _partnerID The index of the partner
    /// @return Whether the refund was successful or not 
    function refundFor(uint _partnerID) internal returns (bool);

    /// @notice Function to refund for valid partners before the closing time
    /// @param _to The index of the last partner
    function refundForValidPartners(uint _to);

    /// @notice Function to refund for a group of partners after the closing time
    /// @param _from The index of the first partner
    /// @param _to The index of the last partner
    function refundForAll(
        uint _from,
        uint _to);

    /// @notice Function to refund after the closing time with 'msg.sender' as 'beneficiary'
    function refund();

    /// @param _minAmountLimit The amount (in wei) below this limit can fund the dao
    /// @param _maxAmountLimit Maximum amount (in wei) a partner can fund
    /// @param _divisorBalanceLimit The partner can fund 
    /// only under a defined percentage of his ether balance
    /// @param _multiplierSharesLimit The partner can fund 
    /// only under a defined percentage of his shares balance in the Dao 
    /// @param _divisorSharesLimit The partner can fund 
    /// only under a defined percentage of his shares balance in the Dao 
    /// @param _from The index of the first partner
    /// @param _to The index of the last partner
    /// @return The result of the funding procedure (in wei) at present time
    function estimatedFundingAmount(
        uint _minAmountLimit,
        uint _maxAmountLimit, 
        uint _divisorBalanceLimit,
        uint _multiplierSharesLimit,
        uint _divisorSharesLimit,
        uint _from,
        uint _to
        ) constant external returns (uint);

    /// @param _index The index of the partner
    /// @param _minAmountLimit The amount (in wei) below this limit can fund the dao
    /// @param _maxAmountLimit Maximum amount (in wei) a partner can fund
    /// @param _divisorBalanceLimit The partner can fund 
    /// only under a defined percentage of his ether balance 
    /// @param _multiplierSharesLimit The partner can fund 
    /// only under a defined percentage of his shares balance in the Dao 
    /// @param _divisorSharesLimit The partner can fund 
    /// only under a defined percentage of his shares balance in the Dao 
    /// @return The maximum amount (in wei) a partner can fund
    function partnerFundingLimit(
        uint _index, 
        uint _minAmountLimit,
        uint _maxAmountLimit, 
        uint _divisorBalanceLimit,
        uint _multiplierSharesLimit,
        uint _divisorSharesLimit
        ) internal returns (uint);
        
    /// @return the number of partners
    function numberOfPartners() constant external returns (uint);
    
    /// @param _from The index of the first partner
    /// @param _to The index of the last partner
    /// @return The number of valid partners
    function numberOfValidPartners(
        uint _from,
        uint _to
        ) constant external returns (uint);

    event ContractorManagerSet(address ContractorManagerAddress);
    event IntentionToFund(address indexed partner, uint amount);
    event Fund(address indexed partner, uint amount);
    event Refund(address indexed partner, uint amount);
    event LimitSet(uint minAmountLimit, uint maxAmountLimit, uint divisorBalanceLimit, 
        uint _multiplierSharesLimit, uint divisorSharesLimit);
    event PartnersNotSet(uint sumOfFundingAmountLimits);
    event AllPartnersSet(uint fundingAmount);
    event Fueled();
    event FundingClosed();
    
}

contract PassFunding is PassFundingInterface {

    function PassFunding (
        address _creator,
        address _DaoManager,
        uint _minFundingAmount,
        uint _startTime,
        uint _closingTime
        ) {

        if (_creator == _DaoManager
            || _creator == 0
            || _DaoManager == 0
            || (_startTime < now && _startTime != 0)) throw;
            
        creator = _creator;
        DaoManager = PassManager(_DaoManager);

        minFundingAmount = _minFundingAmount;

        if (_startTime == 0) {startTime = now;} else {startTime = _startTime;}

        if (_closingTime <= startTime) throw;
        closingTime = _closingTime;
        
        setFromPartner = 1;
        refundFromPartner = 1;

        partners.length = 1; 
        
    }
    
    function SetContractorManager(address _contractorManager) onlyCreator {
        
        if (_contractorManager == 0
            || limitSet
            || address(contractorManager) != 0
            || creator == _contractorManager
            || _contractorManager == address(DaoManager)) throw;
            
        tokenCreation = true;            
        contractorManager = PassManager(_contractorManager);
        ContractorManagerSet(_contractorManager);
        
    }

    function SetPresaleAmountLimits(
        uint _minPresaleAmount,
        uint _maxPresaleAmount
        ) onlyCreator {

        if (limitSet) throw;
        
        minPresaleAmount = _minPresaleAmount;
        maxPresaleAmount = _maxPresaleAmount;

    }

    function () payable {
        if (!presale()) throw;
    }

    function presale() payable returns (bool) {

        if (msg.value <= 0
            || now < startTime
            || now > closingTime
            || now < pauseClosingTime
            || limitSet
            || msg.value < minPresaleAmount
            || msg.value > maxPresaleAmount
            || msg.sender == creator
        ) throw;
        
        if (partnerID[msg.sender] == 0) {

            uint _partnerID = partners.length++;
            Partner t = partners[_partnerID];
             
            partnerID[msg.sender] = _partnerID;
            t.partnerAddress = msg.sender;
            
            t.presaleAmount += msg.value;
            t.presaleDate = now;

        } else {

            Partner p = partners[partnerID[msg.sender]];
            if (p.presaleAmount + msg.value > maxPresaleAmount) throw;

            p.presaleDate = (p.presaleDate*p.presaleAmount + now*msg.value)/(p.presaleAmount + msg.value);
            p.presaleAmount += msg.value;

        }    
        
        IntentionToFund(msg.sender, msg.value);
        
        return true;
        
    }
    
    function setPartners(
            bool _valid,
            uint _from,
            uint _to
        ) onlyCreator {

        if (limitSet
            ||_from < 1 
            || _to > partners.length - 1) throw;
        
        for (uint i = _from; i <= _to; i++) {
            Partner t = partners[i];
            t.valid = _valid;
        }
        
    }

    function setShareHolders(
            bool _valid,
            uint _from,
            uint _to
        ) onlyCreator {

        if (limitSet
            ||_from < 1 
            || _to > partners.length - 1) throw;
        
        for (uint i = _from; i <= _to; i++) {
            Partner t = partners[i];
            if (DaoManager.balanceOf(t.partnerAddress) != 0) t.valid = _valid;
        }
        
    }
    
    function abortFunding() onlyCreator {
        limitSet = true;
        maxPresaleAmount = 0;
        IsfundingAborted = true; 
    }
    
    function pause(uint _pauseClosingTime) onlyCreator {
        pauseClosingTime = _pauseClosingTime;
    }
    
    function setLimits(
            uint _minAmountLimit,
            uint _maxAmountLimit, 
            uint _divisorBalanceLimit,
            uint _multiplierSharesLimit,
            uint _divisorSharesLimit
    ) onlyCreator {
        
        if (limitSet) throw;
        
        minAmountLimit = _minAmountLimit;
        maxAmountLimit = _maxAmountLimit;
        divisorBalanceLimit = _divisorBalanceLimit;
        multiplierSharesLimit = _multiplierSharesLimit;
        divisorSharesLimit = _divisorSharesLimit;

        limitSet = true;
        
        LimitSet(_minAmountLimit, _maxAmountLimit, _divisorBalanceLimit, _multiplierSharesLimit, _divisorSharesLimit);
    
    }

    function setFunding(uint _to) onlyCreator returns (bool _success) {

        uint _fundingMaxAmount = DaoManager.fundingMaxAmount(address(this));

        if (!limitSet 
            || _fundingMaxAmount < minFundingAmount
            || setFromPartner > _to 
            || _to > partners.length - 1) throw;

        DaoManager.setFundingStartTime(startTime);
        if (tokenCreation) contractorManager.setFundingStartTime(startTime);

        if (setFromPartner == 1) sumOfFundingAmountLimits = 0;
        
        for (uint i = setFromPartner; i <= _to; i++) {

            partners[i].fundingAmountLimit = partnerFundingLimit(i, minAmountLimit, maxAmountLimit, 
                divisorBalanceLimit, multiplierSharesLimit, divisorSharesLimit);

            sumOfFundingAmountLimits += partners[i].fundingAmountLimit;

        }
        
        setFromPartner = _to + 1;
        
        if (setFromPartner >= partners.length) {

            setFromPartner = 1;

            if (sumOfFundingAmountLimits < minFundingAmount 
                || sumOfFundingAmountLimits > _fundingMaxAmount) {

                maxPresaleAmount = 0;
                IsfundingAborted = true; 
                PartnersNotSet(sumOfFundingAmountLimits);
                return;

            }
            else {
                allSet = true;
                AllPartnersSet(sumOfFundingAmountLimits);
                return true;
            }

        }

    }

    function fundDaoFor(
            uint _from,
            uint _to
        ) returns (bool) {

        if (!allSet) throw;
        
        if (_from < 1 || _to > partners.length - 1) throw;
        
        address _partner;
        uint _amountToFund;
        uint _sumAmountToFund = 0;

        for (uint i = _from; i <= _to; i++) {
            
            _partner = partners[i].partnerAddress;
            _amountToFund = partners[i].fundingAmountLimit - partners[i].fundedAmount;
        
            if (_amountToFund > 0) {

                partners[i].fundedAmount += _amountToFund;
                _sumAmountToFund += _amountToFund;

                DaoManager.rewardToken(_partner, _amountToFund, partners[i].presaleDate);

                if (tokenCreation) {
                    contractorManager.rewardToken(_partner, _amountToFund, partners[i].presaleDate);
                }

            }

        }

        if (_sumAmountToFund == 0) return;
        
        if (!DaoManager.send(_sumAmountToFund)) throw;

        totalFunded += _sumAmountToFund;

        if (totalFunded == sumOfFundingAmountLimits) {
            DaoManager.setFundingFueled(); 
            if (tokenCreation) contractorManager.setFundingFueled(); 
            Fueled();
        }
        
        return true;

    }
    
    function fundDao() returns (bool) {
        return fundDaoFor(partnerID[msg.sender], partnerID[msg.sender]);
    }

    function refundFor(uint _partnerID) internal returns (bool) {

        Partner t = partners[_partnerID];
        uint _amountnotToRefund = t.presaleAmount;
        uint _amountToRefund;
        
        if (t.presaleAmount > maxPresaleAmount && t.valid) {
            _amountnotToRefund = maxPresaleAmount;
        }
        
        if (t.fundedAmount > 0 || now > closingTime) {
            _amountnotToRefund = t.fundedAmount;
        }

        _amountToRefund = t.presaleAmount - _amountnotToRefund;
        if (_amountToRefund <= 0) return true;

        t.presaleAmount = _amountnotToRefund;
        if (t.partnerAddress.send(_amountToRefund)) {
            Refund(t.partnerAddress, _amountToRefund);
            return true;
        } else {
            t.presaleAmount = _amountnotToRefund + _amountToRefund;
            return false;
        }

    }

    function refundForValidPartners(uint _to) {

        if (refundFromPartner > _to || _to > partners.length - 1) throw;
        
        for (uint i = refundFromPartner; i <= _to; i++) {
            if (partners[i].valid) {
                if (!refundFor(i)) throw;
            }
        }

        refundFromPartner = _to + 1;
        
        if (refundFromPartner >= partners.length) {
            refundFromPartner = 1;

            if ((totalFunded >= sumOfFundingAmountLimits && allSet && closingTime > now)
                || IsfundingAborted) {

                closingTime = now; 
                FundingClosed(); 

            }
        }
        
    }

    function refundForAll(
        uint _from,
        uint _to) {

        if (_from < 1 || _to > partners.length - 1) throw;
        
        for (uint i = _from; i <= _to; i++) {
            if (!refundFor(i)) throw;
        }

    }

    function refund() {
        refundForAll(partnerID[msg.sender], partnerID[msg.sender]);
    }

    function estimatedFundingAmount(
        uint _minAmountLimit,
        uint _maxAmountLimit, 
        uint _divisorBalanceLimit,
        uint _multiplierSharesLimit,
        uint _divisorSharesLimit,
        uint _from,
        uint _to
        ) constant external returns (uint) {

        if (_from < 1 || _to > partners.length - 1) throw;

        uint _total = 0;
        
        for (uint i = _from; i <= _to; i++) {
            _total += partnerFundingLimit(i, _minAmountLimit, _maxAmountLimit, 
                _divisorBalanceLimit, _multiplierSharesLimit, _divisorSharesLimit);
        }

        return _total;

    }

    function partnerFundingLimit(
        uint _index, 
        uint _minAmountLimit,
        uint _maxAmountLimit, 
        uint _divisorBalanceLimit,
        uint _multiplierSharesLimit,
        uint _divisorSharesLimit
        ) internal returns (uint) {

        uint _amount;
        uint _amount1;

        Partner t = partners[_index];
            
        if (t.valid) {

            _amount = t.presaleAmount;
            
            if (_divisorBalanceLimit > 0) {
                _amount1 = uint(t.partnerAddress.balance)/uint(_divisorBalanceLimit);
                if (_amount > _amount1) _amount = _amount1; 
                }

            if (_multiplierSharesLimit > 0 && _divisorSharesLimit > 0) {

                uint _balance = uint(DaoManager.balanceOf(t.partnerAddress));

                uint _multiplier = _balance*_multiplierSharesLimit;
                if (_multiplier/_balance != _multiplierSharesLimit) throw;

                _amount1 = _multiplier/_divisorSharesLimit;
                if (_amount > _amount1) _amount = _amount1; 

                }

            if (_amount > _maxAmountLimit) _amount = _maxAmountLimit;
            
            if (_amount < _minAmountLimit) _amount = _minAmountLimit;

            if (_amount > t.presaleAmount) _amount = t.presaleAmount;
            
        }
        
        return _amount;
        
    }

    function numberOfPartners() constant external returns (uint) {
        return partners.length - 1;
    }
    
    function numberOfValidPartners(
        uint _from,
        uint _to
        ) constant external returns (uint) {
        
        if (_from < 1 || _to > partners.length-1) throw;

        uint _total = 0;
        
        for (uint i = _from; i <= _to; i++) {
            if (partners[i].valid) _total += 1;
        }

        return _total;
        
    }

}

contract PassFundingCreator {
    event NewFunding(address creator, address DaoManager, 
        uint MinFundingAmount, uint StartTime, uint ClosingTime, address FundingContractAddress);
    function createFunding(
        address _DaoManager,
        uint _minFundingAmount,
        uint _startTime,
        uint _closingTime
        ) returns (PassFunding) {
        PassFunding _newFunding = new PassFunding(
            msg.sender,
            _DaoManager,        
            _minFundingAmount,
            _startTime,
            _closingTime
        );
        NewFunding(msg.sender, _DaoManager,  
            _minFundingAmount, _startTime, _closingTime, address(_newFunding));
        return _newFunding;
    }
}
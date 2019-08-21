pragma solidity ^0.4.8;

/*
This file is part of Pass DAO.

Pass DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Pass DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with Pass DAO.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
Smart contract for a Decentralized Autonomous Organization (DAO)
to automate organizational governance and decision-making.
*/

/// @title Pass Dao smart contract
contract PassDao {
    
    struct revision {
        // Address of the Committee Room smart contract
        address committeeRoom;
        // Address of the share manager smart contract
        address shareManager;
        // Address of the token manager smart contract
        address tokenManager;
        // Address of the project creator smart contract
        uint startDate;
    }
    // The revisions of the application until today
    revision[] public revisions;

    struct project {
        // The address of the smart contract
        address contractAddress;
        // The unix effective start date of the contract
        uint startDate;
    }
    // The projects of the Dao
    project[] public projects;

    // Map with the indexes of the projects
    mapping (address => uint) projectID;
    
    // The address of the meta project
    address metaProject;

    
// Events

    event Upgrade(uint indexed RevisionID, address CommitteeRoom, address ShareManager, address TokenManager);
    event NewProject(address Project);

// Constant functions  
    
    /// @return The effective committee room
    function ActualCommitteeRoom() constant returns (address) {
        return revisions[0].committeeRoom;
    }
    
    /// @return The meta project
    function MetaProject() constant returns (address) {
        return metaProject;
    }

    /// @return The effective share manager
    function ActualShareManager() constant returns (address) {
        return revisions[0].shareManager;
    }

    /// @return The effective token manager
    function ActualTokenManager() constant returns (address) {
        return revisions[0].tokenManager;
    }

// modifiers

    modifier onlyPassCommitteeRoom {if (msg.sender != revisions[0].committeeRoom  
        && revisions[0].committeeRoom != 0) throw; _;}
    
// Constructor function

    function PassDao() {
        projects.length = 1;
        revisions.length = 1;
    }
    
// Register functions

    /// @dev Function to allow the actual Committee Room upgrading the application
    /// @param _newCommitteeRoom The address of the new committee room
    /// @param _newShareManager The address of the new share manager
    /// @param _newTokenManager The address of the new token manager
    /// @return The index of the revision
    function upgrade(
        address _newCommitteeRoom, 
        address _newShareManager, 
        address _newTokenManager) onlyPassCommitteeRoom returns (uint) {
        
        uint _revisionID = revisions.length++;
        revision r = revisions[_revisionID];

        if (_newCommitteeRoom != 0) r.committeeRoom = _newCommitteeRoom; else r.committeeRoom = revisions[0].committeeRoom;
        if (_newShareManager != 0) r.shareManager = _newShareManager; else r.shareManager = revisions[0].shareManager;
        if (_newTokenManager != 0) r.tokenManager = _newTokenManager; else r.tokenManager = revisions[0].tokenManager;

        r.startDate = now;
        
        revisions[0] = r;
        
        Upgrade(_revisionID, _newCommitteeRoom, _newShareManager, _newTokenManager);
            
        return _revisionID;
    }

    /// @dev Function to set the meta project
    /// @param _projectAddress The address of the meta project
    function addMetaProject(address _projectAddress) onlyPassCommitteeRoom {

        metaProject = _projectAddress;
    }
    
    /// @dev Function to allow the committee room to add a project when ordering
    /// @param _projectAddress The address of the project
    function addProject(address _projectAddress) onlyPassCommitteeRoom {

        if (projectID[_projectAddress] == 0) {

            uint _projectID = projects.length++;
            project p = projects[_projectID];
        
            projectID[_projectAddress] = _projectID;
            p.contractAddress = _projectAddress; 
            p.startDate = now;
            
            NewProject(_projectAddress);
        }
    }
    
}

pragma solidity ^0.4.8;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Manager smart contract is used for the management of shares and tokens.
 *
*/

/// @title Token Manager smart contract of the Pass Decentralized Autonomous Organisation
contract PassTokenManagerInterface {

    // The Pass Dao smart contract
    PassDao public passDao;
    // The adress of the creator of this smart contract
    address creator;
    
    // The token name for display purpose
    string public name;
    // The token symbol for display purpose
    string public symbol;
    // The quantity of decimals for display purpose
    uint8 public decimals;
    // Total amount of tokens
    uint256 totalTokenSupply;

    // True if tokens, false if Dao shares
    bool token;
    // If true, the shares or tokens can be transferred
    bool transferable;

    // The address of the last Manager before cloning
    address public clonedFrom;
    // True if the initial token supply is over
    bool initialTokenSupplyDone;

    // Array of token or share holders (used for cloning)
    address[] holders;
    // Map with the indexes of the holders (used for cloning)
    mapping (address => uint) holderID;
    
    // Array with all balances
    mapping (address => uint256) balances;
    // Array with all allowances
    mapping (address => mapping (address => uint256)) allowed;

    struct funding {
        // The address which sets partners and manages the funding (not mandatory)
        address moderator;
        // The amount (in wei) of the funding
        uint amountToFund;
        // The funded amount (in wei)
        uint fundedAmount;
        // A unix timestamp, denoting the start time of the funding
        uint startTime; 
        // A unix timestamp, denoting the closing time of the funding
        uint closingTime;  
        // The price multiplier for a share or a token without considering the inflation rate
        uint initialPriceMultiplier;
        // Rate per year in percentage applied to the share or token price 
        uint inflationRate; 
        // The total amount of wei given
        uint totalWeiGiven;
    } 
    // Map with the fundings rules for each Dao proposal
    mapping (uint => funding) public fundings;

    // The index of the last funding and proposal
    uint lastProposalID;
    // The index of the last fueled funding and proposal
    uint public lastFueledFundingID;
    
    struct amountsGiven {
        uint weiAmount;
        uint tokenAmount;
    }
    // Map with the amounts given for each proposal 
    mapping (uint => mapping (address => amountsGiven)) public Given;
    
    // Map of blocked Dao share accounts. Points to the date when the share holder can transfer shares
    mapping (address => uint) public blockedDeadLine; 

    // @return The client of this manager
    function Client() constant returns (address);
    
    /// @return The total supply of shares or tokens 
    function totalSupply() constant external returns (uint256);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
     function balanceOf(address _owner) constant external returns (uint256 balance);

    /// @return True if tokens can be transferred
    function Transferable() constant external returns (bool);
    
    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Quantity of remaining tokens of _owner that _spender is allowed to spend
    function allowance(address _owner, address _spender) constant external returns (uint256 remaining);
    
    /// @param _proposalID Index of the funding or proposal
    /// @return The result (in wei) of the funding
    function FundedAmount(uint _proposalID) constant external returns (uint);

    /// @param _proposalID Index of the funding or proposal
    /// @return The amount to fund
    function AmountToFund(uint _proposalID) constant external returns (uint);
    
    /// @param _proposalID Index of the funding or proposal
    /// @return the token price multiplier
    function priceMultiplier(uint _proposalID) constant internal returns (uint);
    
    /// @param _proposalID Index of the funding or proposal
    /// @param _saleDate in case of presale, the date of the presale
    /// @return the share or token price divisor condidering the sale date and the inflation rate
    function priceDivisor(
        uint _proposalID, 
        uint _saleDate) constant internal returns (uint);
    
    /// @param _proposalID Index of the funding or proposal
    /// @return the actual price divisor of a share or token
    function actualPriceDivisor(uint _proposalID) constant internal returns (uint);

    /// @dev Internal function to calculate the amount in tokens according to a price    
    /// @param _weiAmount The amount (in wei)
    /// @param _priceMultiplier The price multiplier
    /// @param _priceDivisor The price divisor
    /// @return the amount in tokens 
    function TokenAmount(
        uint _weiAmount,
        uint _priceMultiplier, 
        uint _priceDivisor) constant internal returns (uint);

    /// @dev Internal function to calculate the amount in wei according to a price    
    /// @param _tokenAmount The amount (in wei)
    /// @param _priceMultiplier The price multiplier
    /// @param _priceDivisor The price divisor
    /// @return the amount in wei
    function weiAmount(
        uint _tokenAmount, 
        uint _priceMultiplier, 
        uint _priceDivisor) constant internal returns (uint);
        
    /// @param _tokenAmount The amount in tokens
    /// @param _proposalID Index of the client proposal. 0 if not linked to a proposal.
    /// @return the actual token price in wei
    function TokenPriceInWei(uint _tokenAmount, uint _proposalID) constant returns (uint);
    
    /// @return The index of the last funding and client's proposal 
    function LastProposalID() constant returns (uint);

    /// @return The number of share or token holders (used for cloning)
    function numberOfHolders() constant returns (uint);

    /// @param _index The index of the holder
    /// @return the address of the holder
    function HolderAddress(uint _index) constant external returns (address);
   
    /// @dev The constructor function
    /// @param _passDao Address of the pass Dao smart contract
    /// @param _clonedFrom The address of the last Manager before cloning
    /// @param _tokenName The token name for display purpose
    /// @param _tokenSymbol The token symbol for display purpose
    /// @param _tokenDecimals The quantity of decimals for display purpose
    /// @param  _token True if tokens, false if shares
    /// @param  _transferable True if tokens can be transferred
    /// @param _initialPriceMultiplier Price multiplier without considering any inflation rate
    /// @param _inflationRate If 0, the token price doesn't change during the funding
    //function PassTokenManager(
    //    address _passDao,
    //    address _clonedFrom,
    //    string _tokenName,
    //    string _tokenSymbol,
    //    uint8 _tokenDecimals,
    //    bool _token,
    //    bool _transferable,
    //    uint _initialPriceMultiplier,
    //    uint _inflationRate);
    
    /// @dev Function to create initial tokens    
    /// @param _recipient The beneficiary of the created tokens
    /// @param _quantity The quantity of tokens to create    
    /// @param _last True if the initial token suppy is over
    /// @return Whether the function was successful or not     
    function initialTokenSupply(
        address _recipient, 
        uint _quantity,
        bool _last) returns (bool success);
        
    /// @notice Function to clone tokens before upgrading
    /// @param _from The index of the first holder
    /// @param _to The index of the last holder
    /// @return Whether the function was successful or not 
    function cloneTokens(
        uint _from,
        uint _to) returns (bool success);

    /// @dev Internal function to add a new token or share holder
    /// @param _holder The address of the token or share holder
    function addHolder(address _holder) internal;
    
    /// @dev Internal function to create initial tokens    
    /// @param _holder The beneficiary of the created tokens
    /// @param _tokenAmount The amount in tokens to create
    function createTokens(
        address _holder, 
        uint _tokenAmount) internal;
        
    /// @notice Function used by the client to pay with shares or tokens
    /// @param _recipient The address of the recipient of shares or tokens
    /// @param _amount The amount (in Wei) to calculate the quantity of shares or tokens to create
    /// @return the rewarded amount in tokens or shares
    function rewardTokensForClient(
        address _recipient, 
        uint _amount) external  returns (uint);
        
    /// @notice Function to set a funding
    /// @param _moderator The address of the smart contract to manage a private funding
    /// @param _initialPriceMultiplier Price multiplier without considering any inflation rate
    /// @param _amountToFund The amount (in wei) of the funding
    /// @param _minutesFundingPeriod Period in minutes of the funding
    /// @param _inflationRate If 0, the token price doesn't change during the funding
    /// @param _proposalID Index of the client proposal
    function setFundingRules(
        address _moderator,
        uint _initialPriceMultiplier,
        uint _amountToFund,
        uint _minutesFundingPeriod, 
        uint _inflationRate,
        uint _proposalID) external;

    /// @dev Internal function for the sale of shares or tokens
    /// @param _proposalID Index of the client proposal
    /// @param _recipient The recipient address of shares or tokens
    /// @param _amount The funded amount (in wei)
    /// @param _saleDate In case of presale, the date of the presale
    /// @param _presale True if presale
    /// @return Whether the creation was successful or not
    function sale(
        uint _proposalID,
        address _recipient, 
        uint _amount,
        uint _saleDate,
        bool _presale
    ) internal returns (bool success);
    
    /// @dev Internal function to close the actual funding
    /// @param _proposalID Index of the client proposal
    function closeFunding(uint _proposalID) internal;
   
    /// @notice Function to send tokens or refund after the closing time of the funding proposals
    /// @param _from The first proposal. 0 if not linked to a proposal
    /// @param _to The last proposal
    /// @param _buyer The address of the buyer
    /// @return Whether the function was successful or not 
    function sendPendingAmounts(        
        uint _from,
        uint _to,
        address _buyer) returns (bool);
        
    /// @notice Function to get fees, shares or refund after the closing time of the funding proposals
    /// @return Whether the function was successful or not
    function withdrawPendingAmounts() returns (bool);
    
    /// @notice Function used by the main partner to set the start time of the funding
    /// @param _proposalID Index of the client proposal
    /// @param _startTime The unix start date of the funding 
    function setFundingStartTime(
        uint _proposalID, 
        uint _startTime) external;
    
    /// @notice Function used by the main partner to set the funding fueled
    /// @param _proposalID Index of the client proposal
    function setFundingFueled(uint _proposalID) external;

    /// @notice Function to able the transfer of Dao shares or contractor tokens
    function ableTransfer();

    /// @notice Function to disable the transfer of Dao shares
    function disableTransfer();

    /// @notice Function used by the client to block the transfer of shares from and to a share holder
    /// @param _shareHolder The address of the share holder
    /// @param _deadLine When the account will be unblocked
    function blockTransfer(
        address _shareHolder, 
        uint _deadLine) external;
    
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
    function approve(
        address _spender, 
        uint256 _value) returns (bool success);
    
    event TokensCreated(address indexed Sender, address indexed TokenHolder, uint TokenAmount);
    event FundingRulesSet(address indexed Moderator, uint indexed ProposalId, uint AmountToFund, uint indexed StartTime, uint ClosingTime);
    event FundingFueled(uint indexed ProposalID, uint FundedAmount);
    event TransferAble();
    event TransferDisable();
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed Buyer, uint Amount);
    
}    

contract PassTokenManager is PassTokenManagerInterface {

// Constant functions

    function Client() constant returns (address) {
        return passDao.ActualCommitteeRoom();
    }
   
    function totalSupply() constant external returns (uint256) {
        return totalTokenSupply;
    }
    
    function balanceOf(address _owner) constant external returns (uint256 balance) {
        return balances[_owner];
    }
     
    function Transferable() constant external returns (bool) {
        return transferable;
    }
 
    function allowance(
        address _owner, 
        address _spender) constant external returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function FundedAmount(uint _proposalID) constant external returns (uint) {
        return fundings[_proposalID].fundedAmount;
    }
  
    function AmountToFund(uint _proposalID) constant external returns (uint) {

        if (now > fundings[_proposalID].closingTime
            || now < fundings[_proposalID].startTime) {
            return 0;   
            } else return fundings[_proposalID].amountToFund;
    }
    
    function priceMultiplier(uint _proposalID) constant internal returns (uint) {
        return fundings[_proposalID].initialPriceMultiplier;
    }
    
    function priceDivisor(uint _proposalID, uint _saleDate) constant internal returns (uint) {
        uint _date = _saleDate;
        
        if (_saleDate > fundings[_proposalID].closingTime) _date = fundings[_proposalID].closingTime;
        if (_saleDate < fundings[_proposalID].startTime) _date = fundings[_proposalID].startTime;

        return 100 + 100*fundings[_proposalID].inflationRate*(_date - fundings[_proposalID].startTime)/(100*365 days);
    }
    
    function actualPriceDivisor(uint _proposalID) constant internal returns (uint) {
        return priceDivisor(_proposalID, now);
    }
    
    function TokenAmount(
        uint _weiAmount, 
        uint _priceMultiplier, 
        uint _priceDivisor) constant internal returns (uint) {
        
        uint _a = _weiAmount*_priceMultiplier;
        uint _multiplier = 100*_a;
        uint _amount = _multiplier/_priceDivisor;
        if (_a/_weiAmount != _priceMultiplier
            || _multiplier/100 != _a) return 0; 
        
        return _amount;
    }
    
    function weiAmount(
        uint _tokenAmount, 
        uint _priceMultiplier, 
        uint _priceDivisor) constant internal returns (uint) {
        
        uint _multiplier = _tokenAmount*_priceDivisor;
        uint _divisor = 100*_priceMultiplier;
        uint _amount = _multiplier/_divisor;
        if (_multiplier/_tokenAmount != _priceDivisor
            || _divisor/100 != _priceMultiplier) return 0; 

        return _amount;
    }
    
    function TokenPriceInWei(uint _tokenAmount, uint _proposalID) constant returns (uint) {
        return weiAmount(_tokenAmount, priceMultiplier(_proposalID), actualPriceDivisor(_proposalID));
    }
    
    function LastProposalID() constant returns (uint) {
        return lastProposalID;
    }
    
    function numberOfHolders() constant returns (uint) {
        return holders.length - 1;
    }
    
    function HolderAddress(uint _index) constant external returns (address) {
        return holders[_index];
    }

// Modifiers

    // Modifier that allows only the client ..
    modifier onlyClient {if (msg.sender != Client()) throw; _;}
      
    // Modifier for share Manager functions
    modifier onlyShareManager {if (token) throw; _;}

    // Modifier for token Manager functions
    modifier onlyTokenManager {if (!token) throw; _;}
  
// Constructor function

    function PassTokenManager(
        PassDao _passDao,
        address _clonedFrom,
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        bool _token,
        bool _transferable,
        uint _initialPriceMultiplier,
        uint _inflationRate) {

        passDao = _passDao;
        creator = msg.sender;
        
        clonedFrom = _clonedFrom;            

        name = _tokenName;
        symbol = _tokenSymbol;
        decimals = _tokenDecimals;

        token = _token;
        transferable = _transferable;

        fundings[0].initialPriceMultiplier = _initialPriceMultiplier;
        fundings[0].inflationRate = _inflationRate;

        holders.length = 1;
    }

// Setting functions

    function initialTokenSupply(
        address _recipient, 
        uint _quantity,
        bool _last) returns (bool success) {

        if (initialTokenSupplyDone) throw;
        
        addHolder(_recipient);
        if (_recipient != 0 && _quantity != 0) createTokens(_recipient, _quantity);
        
        if (_last) initialTokenSupplyDone = true;
        
        return true;
    }

    function cloneTokens(
        uint _from,
        uint _to) returns (bool success) {
        
        initialTokenSupplyDone = true;
        if (_from == 0) _from = 1;
        
        PassTokenManager _clonedFrom = PassTokenManager(clonedFrom);
        uint _numberOfHolders = _clonedFrom.numberOfHolders();
        if (_to == 0 || _to > _numberOfHolders) _to = _numberOfHolders;
        
        address _holder;
        uint _balance;

        for (uint i = _from; i <= _to; i++) {
            _holder = _clonedFrom.HolderAddress(i);
            _balance = _clonedFrom.balanceOf(_holder);
            if (balances[_holder] == 0 && _balance != 0) {
                addHolder(_holder);
                createTokens(_holder, _balance);
            }
        }
    }
        
// Token creation

    function addHolder(address _holder) internal {
        
        if (holderID[_holder] == 0) {
            
            uint _holderID = holders.length++;
            holders[_holderID] = _holder;
            holderID[_holder] = _holderID;
        }
    }

    function createTokens(
        address _holder, 
        uint _tokenAmount) internal {

        balances[_holder] += _tokenAmount; 
        totalTokenSupply += _tokenAmount;
        TokensCreated(msg.sender, _holder, _tokenAmount);
    }
    
    function rewardTokensForClient(
        address _recipient, 
        uint _amount
        ) external onlyClient returns (uint) {

        uint _tokenAmount = TokenAmount(_amount, priceMultiplier(0), actualPriceDivisor(0));
        if (_tokenAmount == 0) throw;

        addHolder(_recipient);
        createTokens(_recipient, _tokenAmount);

        return _tokenAmount;
    }
    
    function setFundingRules(
        address _moderator,
        uint _initialPriceMultiplier,
        uint _amountToFund,
        uint _minutesFundingPeriod, 
        uint _inflationRate,
        uint _proposalID
    ) external onlyClient {

        if (_moderator == address(this)
            || _moderator == Client()
            || _amountToFund == 0
            || _minutesFundingPeriod == 0
            || fundings[_proposalID].totalWeiGiven != 0
            ) throw;
            
        fundings[_proposalID].moderator = _moderator;

        fundings[_proposalID].amountToFund = _amountToFund;
        fundings[_proposalID].fundedAmount = 0;

        if (_initialPriceMultiplier == 0) {
            if (now < fundings[0].closingTime) {
                fundings[_proposalID].initialPriceMultiplier = 100*priceMultiplier(lastProposalID)/actualPriceDivisor(lastProposalID);
            } else {
                fundings[_proposalID].initialPriceMultiplier = 100*priceMultiplier(lastFueledFundingID)/actualPriceDivisor(lastFueledFundingID);
            }
            fundings[0].initialPriceMultiplier = fundings[_proposalID].initialPriceMultiplier;
        }
        else {
            fundings[_proposalID].initialPriceMultiplier = _initialPriceMultiplier;
            fundings[0].initialPriceMultiplier = _initialPriceMultiplier;
        }
        
        if (_inflationRate == 0) fundings[_proposalID].inflationRate = fundings[0].inflationRate;
        else {
            fundings[_proposalID].inflationRate = _inflationRate;
            fundings[0].inflationRate = _inflationRate;
        }
        
        fundings[_proposalID].startTime = now;
        fundings[0].startTime = now;
        
        fundings[_proposalID].closingTime = now + _minutesFundingPeriod * 1 minutes;
        fundings[0].closingTime = fundings[_proposalID].closingTime;
        
        fundings[_proposalID].totalWeiGiven = 0;
        
        lastProposalID = _proposalID;
        
        FundingRulesSet(_moderator, _proposalID,  _amountToFund, fundings[_proposalID].startTime, fundings[_proposalID].closingTime);
    } 
    
    function sale(
        uint _proposalID,
        address _recipient, 
        uint _amount,
        uint _saleDate,
        bool _presale) internal returns (bool success) {

        if (_saleDate == 0) _saleDate = now;

        if (_saleDate > fundings[_proposalID].closingTime
            || _saleDate < fundings[_proposalID].startTime
            || fundings[_proposalID].totalWeiGiven + _amount > fundings[_proposalID].amountToFund) return;

        uint _tokenAmount = TokenAmount(_amount, priceMultiplier(_proposalID), priceDivisor(_proposalID, _saleDate));
        if (_tokenAmount == 0) return;
        
        addHolder(_recipient);
        if (_presale) {
            Given[_proposalID][_recipient].tokenAmount += _tokenAmount;
        }
        else createTokens(_recipient, _tokenAmount);

        return true;
    }

    function closeFunding(uint _proposalID) internal {
        fundings[_proposalID].fundedAmount = fundings[_proposalID].totalWeiGiven;
        lastFueledFundingID = _proposalID;
        fundings[_proposalID].closingTime = now;
        FundingFueled(_proposalID, fundings[_proposalID].fundedAmount);
    }

    function sendPendingAmounts(        
        uint _from,
        uint _to,
        address _buyer) returns (bool) {
        
        if (_from == 0) _from = 1;
        if (_to == 0) _to = lastProposalID;
        if (_buyer == 0) _buyer = msg.sender;

        uint _amount;
        uint _tokenAmount;
        
        for (uint i = _from; i <= _to; i++) {

            if (now > fundings[i].closingTime && Given[i][_buyer].weiAmount != 0) {
                
                if (fundings[i].fundedAmount == 0) _amount += Given[i][_buyer].weiAmount;
                else _tokenAmount += Given[i][_buyer].tokenAmount;

                fundings[i].totalWeiGiven -= Given[i][_buyer].weiAmount;
                Given[i][_buyer].tokenAmount = 0;
                Given[i][_buyer].weiAmount = 0;
            }
        }

        if (_tokenAmount > 0) {
            createTokens(_buyer, _tokenAmount);
            return true;
        }
        
        if (_amount > 0) {
            if (!_buyer.send(_amount)) throw;
            Refund(_buyer, _amount);
        } else return true;
    }
    

    function withdrawPendingAmounts() returns (bool) {
        
        return sendPendingAmounts(0, 0, msg.sender);
    }        

// Funding Moderator functions

    function setFundingStartTime(uint _proposalID, uint _startTime) external {
        if ((msg.sender !=  fundings[_proposalID].moderator) || now > fundings[_proposalID].closingTime) throw;
        fundings[_proposalID].startTime = _startTime;
    }

    function setFundingFueled(uint _proposalID) external {

        if ((msg.sender !=  fundings[_proposalID].moderator) || now > fundings[_proposalID].closingTime) throw;

        closeFunding(_proposalID);
    }
    
// Tokens transfer management    
    
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
    
    function blockTransfer(address _shareHolder, uint _deadLine) external onlyClient onlyShareManager {
        if (_deadLine > blockedDeadLine[_shareHolder]) {
            blockedDeadLine[_shareHolder] = _deadLine;
        }
    }
    
    function transferFromTo(
        address _from,
        address _to, 
        uint256 _value
        ) internal returns (bool success) {  

        if ((transferable)
            && now > blockedDeadLine[_from]
            && now > blockedDeadLine[_to]
            && _to != address(this)
            && balances[_from] >= _value
            && balances[_to] + _value > balances[_to]) {

            addHolder(_to);
            balances[_from] -= _value;
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            return true;

        } else return false;
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
    


pragma solidity ^0.4.8;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Manager smart contract is used for the management of the Dao account, shares and tokens.
 *
*/

/// @title Manager smart contract of the Pass Decentralized Autonomous Organisation
contract PassManager is PassTokenManager {
    
    struct order {
        address buyer;
        uint weiGiven;
    }
    // Orders to buy tokens
    order[] public orders;
    // Number or orders to buy tokens
    uint numberOfOrders;

    // Map to know if an order was cloned from the precedent manager after an upgrade
    mapping (uint => bool) orderCloned;
    
    function PassManager(
        PassDao _passDao,
        address _clonedFrom,
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        bool _token,
        bool _transferable,
        uint _initialPriceMultiplier,
        uint _inflationRate) 
        PassTokenManager( _passDao, _clonedFrom, _tokenName, _tokenSymbol, _tokenDecimals, 
            _token, _transferable, _initialPriceMultiplier, _inflationRate) { }
    
    /// @notice Function to receive payments
    function () payable onlyShareManager { }
    
    /// @notice Function used by the client to send ethers
    /// @param _recipient The address to send to
    /// @param _amount The amount (in wei) to send
    /// @return Whether the transfer was successful or not
    function sendTo(
        address _recipient,
        uint _amount
    ) external onlyClient returns (bool) {

        if (_recipient.send(_amount)) return true;
        else return false;
    }

    /// @dev Internal function to buy tokens and promote a proposal 
    /// @param _proposalID The index of the proposal
    /// @param _buyer The address of the buyer
    /// @param _date The unix date to consider for the share or token price calculation
    /// @param _presale True if presale
    /// @return Whether the function was successful or not 
    function buyTokensFor(
        uint _proposalID,
        address _buyer, 
        uint _date,
        bool _presale) internal returns (bool) {

        if (_proposalID == 0 || !sale(_proposalID, _buyer, msg.value, _date, _presale)) throw;

        fundings[_proposalID].totalWeiGiven += msg.value;        
        if (fundings[_proposalID].totalWeiGiven == fundings[_proposalID].amountToFund) closeFunding(_proposalID);

        Given[_proposalID][_buyer].weiAmount += msg.value;
        
        return true;
    }
    
    /// @notice Function to buy tokens and promote a proposal 
    /// @param _proposalID The index of the proposal
    /// @param _buyer The address of the buyer (not mandatory, msg.sender if 0)
    /// @return Whether the function was successful or not 
    function buyTokensForProposal(
        uint _proposalID, 
        address _buyer) payable returns (bool) {

        if (_buyer == 0) _buyer = msg.sender;

        if (fundings[_proposalID].moderator != 0) throw;

        return buyTokensFor(_proposalID, _buyer, now, true);
    }

    /// @notice Function used by the moderator to buy shares or tokens
    /// @param _proposalID Index of the client proposal
    /// @param _buyer The address of the recipient of shares or tokens
    /// @param _date The unix date to consider for the share or token price calculation
    /// @param _presale True if presale
    /// @return Whether the function was successful or not 
    function buyTokenFromModerator(
        uint _proposalID,
        address _buyer, 
        uint _date,
        bool _presale) payable external returns (bool){

        if (msg.sender != fundings[_proposalID].moderator) throw;

        return buyTokensFor(_proposalID, _buyer, _date, _presale);
    }

    /// @dev Internal function to create a buy order
    /// @param _buyer The address of the buyer
    /// @param _weiGiven The amount in wei given by the buyer
    function addOrder(
        address _buyer, 
        uint _weiGiven) internal {

        uint i;
        numberOfOrders += 1;

        if (numberOfOrders > orders.length) i = orders.length++;
        else i = numberOfOrders - 1;
        
        orders[i].buyer = _buyer;
        orders[i].weiGiven = _weiGiven;
    }

    /// @dev Internal function to remove a buy order
    /// @param _order The index of the order to remove
    function removeOrder(uint _order) internal {
        
        if (numberOfOrders - 1 < _order) return;

        numberOfOrders -= 1;
        if (numberOfOrders > 0) {
            for (uint i = _order; i <= numberOfOrders - 1; i++) {
                orders[i].buyer = orders[i+1].buyer;
                orders[i].weiGiven = orders[i+1].weiGiven;
            }
        }
        orders[numberOfOrders].buyer = 0;
        orders[numberOfOrders].weiGiven = 0;
    }
    
    /// @notice Function to create orders to buy tokens
    /// @return Whether the function was successful or not
    function buyTokens() payable returns (bool) {

        if (!transferable || msg.value < 100 finney) throw;
        
        addOrder(msg.sender, msg.value);
        
        return true;
    }
    
    /// @notice Function to sell tokens
    /// @param _tokenAmount in tokens to sell
    /// @param _from Index of the first order
    /// @param _to Index of the last order
    /// @return the revenue in wei
    function sellTokens(
        uint _tokenAmount,
        uint _from,
        uint _to) returns (uint) {

        if (!transferable 
            || uint(balances[msg.sender]) < _amount 
            || numberOfOrders == 0) throw;
        
        if (_to == 0 || _to > numberOfOrders - 1) _to = numberOfOrders - 1;
        
        
        uint _tokenAmounto;
        uint _amount;
        uint _totalAmount;
        uint o = _from;

        for (uint i = _from; i <= _to; i++) {

            if (_tokenAmount > 0 && orders[o].buyer != msg.sender) {

                _tokenAmounto = TokenAmount(orders[o].weiGiven, priceMultiplier(0), actualPriceDivisor(0));

                if (_tokenAmount >= _tokenAmounto 
                    && transferFromTo(msg.sender, orders[o].buyer, _tokenAmounto)) {
                            
                    _tokenAmount -= _tokenAmounto;
                    _totalAmount += orders[o].weiGiven;
                    removeOrder(o);
                }
                else if (_tokenAmount < _tokenAmounto
                    && transferFromTo(msg.sender, orders[o].buyer, _tokenAmount)) {
                        
                    _amount = weiAmount(_tokenAmount, priceMultiplier(0), actualPriceDivisor(0));
                    orders[o].weiGiven -= _amount;
                    _totalAmount += _amount;
                    i = _to + 1;
                }
                else o += 1;
            } 
            else o += 1;
        }
        
        if (!msg.sender.send(_totalAmount)) throw;
        else return _totalAmount;
    }    

    /// @notice Function to remove your orders and refund
    /// @param _from Index of the first order
    /// @param _to Index of the last order
    /// @return Whether the function was successful or not
    function removeOrders(
        uint _from,
        uint _to) returns (bool) {

        if (_to == 0 || _to > numberOfOrders) _to = numberOfOrders -1;
        
        uint _totalAmount;
        uint o = _from;

        for (uint i = _from; i <= _to; i++) {

            if (orders[o].buyer == msg.sender) {
                
                _totalAmount += orders[o].weiGiven;
                removeOrder(o);

            } else o += 1;
        }

        if (!msg.sender.send(_totalAmount)) throw;
        else return true;
    }
    
}    


pragma solidity ^0.4.8;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Project smart contract is used for the management of the Pass Dao projects.
 *
*/

/// @title Project smart contract of the Pass Decentralized Autonomous Organisation
contract PassProject {

    // The Pass Dao smart contract
    PassDao public passDao;
    
    // The project name
    string public name;
    // The project description
    string public description;
    // The Hash Of the project Document
    bytes32 public hashOfTheDocument;
    // The project manager smart contract
    address projectManager;

    struct order {
        // The address of the contractor smart contract
        address contractorAddress;
        // The index of the contractor proposal
        uint contractorProposalID;
        // The amount of the order
        uint amount;
        // The date of the order
        uint orderDate;
    }
    // The orders of the Dao for this project
    order[] public orders;
    
    // The total amount of orders in wei for this project
    uint public totalAmountOfOrders;

    struct resolution {
        // The name of the resolution
        string name;
        // A description of the resolution
        string description;
        // The date of the resolution
        uint creationDate;
    }
    // Resolutions of the Dao for this project
    resolution[] public resolutions;
    
// Events

    event OrderAdded(address indexed Client, address indexed ContractorAddress, uint indexed ContractorProposalID, uint Amount, uint OrderDate);
    event ProjectDescriptionUpdated(address indexed By, string NewDescription, bytes32 NewHashOfTheDocument);
    event ResolutionAdded(address indexed Client, uint indexed ResolutionID, string Name, string Description);

// Constant functions  

    /// @return the actual committee room of the Dao   
    function Client() constant returns (address) {
        return passDao.ActualCommitteeRoom();
    }
    
    /// @return The number of orders 
    function numberOfOrders() constant returns (uint) {
        return orders.length - 1;
    }
    
    /// @return The project Manager address
    function ProjectManager() constant returns (address) {
        return projectManager;
    }

    /// @return The number of resolutions 
    function numberOfResolutions() constant returns (uint) {
        return resolutions.length - 1;
    }
    
// modifiers

    // Modifier for project manager functions 
    modifier onlyProjectManager {if (msg.sender != projectManager) throw; _;}

    // Modifier for the Dao functions 
    modifier onlyClient {if (msg.sender != Client()) throw; _;}

// Constructor function

    function PassProject(
        PassDao _passDao, 
        string _name,
        string _description,
        bytes32 _hashOfTheDocument) {

        passDao = _passDao;
        name = _name;
        description = _description;
        hashOfTheDocument = _hashOfTheDocument;
        
        orders.length = 1;
        resolutions.length = 1;
    }
    
// Internal functions

    /// @dev Internal function to register a new order
    /// @param _contractorAddress The address of the contractor smart contract
    /// @param _contractorProposalID The index of the contractor proposal
    /// @param _amount The amount in wei of the order
    /// @param _orderDate The date of the order 
    function addOrder(

        address _contractorAddress, 
        uint _contractorProposalID, 
        uint _amount, 
        uint _orderDate) internal {

        uint _orderID = orders.length++;
        order d = orders[_orderID];
        d.contractorAddress = _contractorAddress;
        d.contractorProposalID = _contractorProposalID;
        d.amount = _amount;
        d.orderDate = _orderDate;
        
        totalAmountOfOrders += _amount;
        
        OrderAdded(msg.sender, _contractorAddress, _contractorProposalID, _amount, _orderDate);
    }
    
// Setting functions

    /// @notice Function to allow cloning orders in case of upgrade
    /// @param _contractorAddress The address of the contractor smart contract
    /// @param _contractorProposalID The index of the contractor proposal
    /// @param _orderAmount The amount in wei of the order
    /// @param _lastOrderDate The unix date of the last order 
    function cloneOrder(
        address _contractorAddress, 
        uint _contractorProposalID, 
        uint _orderAmount, 
        uint _lastOrderDate) {
        
        if (projectManager != 0) throw;
        
        addOrder(_contractorAddress, _contractorProposalID, _orderAmount, _lastOrderDate);
    }
    
    /// @notice Function to set the project manager
    /// @param _projectManager The address of the project manager smart contract
    /// @return True if successful
    function setProjectManager(address _projectManager) returns (bool) {

        if (_projectManager == 0 || projectManager != 0) return;
        
        projectManager = _projectManager;
        
        return true;
    }

// Project manager functions

    /// @notice Function to allow the project manager updating the description of the project
    /// @param _projectDescription A description of the project
    /// @param _hashOfTheDocument The hash of the last document
    function updateDescription(string _projectDescription, bytes32 _hashOfTheDocument) onlyProjectManager {
        description = _projectDescription;
        hashOfTheDocument = _hashOfTheDocument;
        ProjectDescriptionUpdated(msg.sender, _projectDescription, _hashOfTheDocument);
    }

// Client functions

    /// @dev Function to allow the Dao to register a new order
    /// @param _contractorAddress The address of the contractor smart contract
    /// @param _contractorProposalID The index of the contractor proposal
    /// @param _amount The amount in wei of the order
    function newOrder(
        address _contractorAddress, 
        uint _contractorProposalID, 
        uint _amount) onlyClient {
            
        addOrder(_contractorAddress, _contractorProposalID, _amount, now);
    }
    
    /// @dev Function to allow the Dao to register a new resolution
    /// @param _name The name of the resolution
    /// @param _description The description of the resolution
    function newResolution(
        string _name, 
        string _description) onlyClient {

        uint _resolutionID = resolutions.length++;
        resolution d = resolutions[_resolutionID];
        
        d.name = _name;
        d.description = _description;
        d.creationDate = now;

        ResolutionAdded(msg.sender, _resolutionID, d.name, d.description);
    }
}

contract PassProjectCreator {
    
    event NewPassProject(PassDao indexed Dao, PassProject indexed Project, string Name, string Description, bytes32 HashOfTheDocument);

    /// @notice Function to create a new Pass project
    /// @param _passDao The Pass Dao smart contract
    /// @param _name The project name
    /// @param _description The project description (not mandatory, can be updated after by the creator)
    /// @param _hashOfTheDocument The Hash Of the project Document (not mandatory, can be updated after by the creator)
    function createProject(
        PassDao _passDao,
        string _name, 
        string _description, 
        bytes32 _hashOfTheDocument
        ) returns (PassProject) {

        PassProject _passProject = new PassProject(_passDao, _name, _description, _hashOfTheDocument);

        NewPassProject(_passDao, _passProject, _name, _description, _hashOfTheDocument);

        return _passProject;
    }
}
    

pragma solidity ^0.4.8;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Project smart contract is used for the management of the Pass Dao projects.
 *
*/

/// @title Contractor smart contract of the Pass Decentralized Autonomous Organisation
contract PassContractor {
    
    // The project smart contract
    PassProject passProject;
    
    // The address of the creator of this smart contract
    address public creator;
    // Address of the recipient;
    address public recipient;

    // End date of the setup procedure
    uint public smartContractStartDate;

    struct proposal {
        // Amount (in wei) of the proposal
        uint amount;
        // A description of the proposal
        string description;
        // The hash of the proposal's document
        bytes32 hashOfTheDocument;
        // A unix timestamp, denoting the date when the proposal was created
        uint dateOfProposal;
        // The amount submitted to a vote
        uint submittedAmount;
        // The sum amount (in wei) ordered for this proposal 
        uint orderAmount;
        // A unix timestamp, denoting the date of the last order for the approved proposal
        uint dateOfLastOrder;
    }
    // Proposals to work for Pass Dao
    proposal[] public proposals;

// Events

    event RecipientUpdated(address indexed By, address LastRecipient, address NewRecipient);
    event Withdrawal(address indexed By, address indexed Recipient, uint Amount);
    event ProposalAdded(address Creator, uint indexed ProposalID, uint Amount, string Description, bytes32 HashOfTheDocument);
    event ProposalSubmitted(address indexed Client, uint Amount);
    event Order(address indexed Client, uint indexed ProposalID, uint Amount);

// Constant functions

    /// @return the actual committee room of the Dao
    function Client() constant returns (address) {
        return passProject.Client();
    }

    /// @return the project smart contract
    function Project() constant returns (PassProject) {
        return passProject;
    }
    
    /// @notice Function used by the client to check the proposal before submitting
    /// @param _sender The creator of the Dao proposal
    /// @param _proposalID The index of the proposal
    /// @param _amount The amount of the proposal
    /// @return true if the proposal can be submitted
    function proposalChecked(
        address _sender,
        uint _proposalID, 
        uint _amount) constant external onlyClient returns (bool) {
        if (_sender != recipient && _sender != creator) return;
        if (_amount <= proposals[_proposalID].amount - proposals[_proposalID].submittedAmount) return true;
    }

    /// @return The number of proposals     
    function numberOfProposals() constant returns (uint) {
        return proposals.length - 1;
    }


// Modifiers

    // Modifier for contractor functions
    modifier onlyContractor {if (msg.sender != recipient) throw; _;}
    
    // Modifier for client functions
    modifier onlyClient {if (msg.sender != Client()) throw; _;}

// Constructor function

    function PassContractor(
        address _creator, 
        PassProject _passProject, 
        address _recipient,
        bool _restore) { 

        if (address(_passProject) == 0) throw;
        
        creator = _creator;
        if (_recipient == 0) _recipient = _creator;
        recipient = _recipient;
        
        passProject = _passProject;
        
        if (!_restore) smartContractStartDate = now;

        proposals.length = 1;
    }

// Setting functions

    /// @notice Function to clone a proposal from the last contractor
    /// @param _amount Amount (in wei) of the proposal
    /// @param _description A description of the proposal
    /// @param _hashOfTheDocument The hash of the proposal's document
    /// @param _dateOfProposal A unix timestamp, denoting the date when the proposal was created
    /// @param _orderAmount The sum amount (in wei) ordered for this proposal 
    /// @param _dateOfOrder A unix timestamp, denoting the date of the last order for the approved proposal
    /// @param _cloneOrder True if the order has to be cloned in the project smart contract
    /// @return Whether the function was successful or not 
    function cloneProposal(
        uint _amount,
        string _description,
        bytes32 _hashOfTheDocument,
        uint _dateOfProposal,
        uint _orderAmount,
        uint _dateOfOrder,
        bool _cloneOrder
    ) returns (bool success) {
            
        if (smartContractStartDate != 0 || recipient == 0
        || msg.sender != creator) throw;
        
        uint _proposalID = proposals.length++;
        proposal c = proposals[_proposalID];

        c.amount = _amount;
        c.description = _description;
        c.hashOfTheDocument = _hashOfTheDocument; 
        c.dateOfProposal = _dateOfProposal;
        c.orderAmount = _orderAmount;
        c.dateOfLastOrder = _dateOfOrder;

        ProposalAdded(msg.sender, _proposalID, _amount, _description, _hashOfTheDocument);
        
        if (_cloneOrder) passProject.cloneOrder(address(this), _proposalID, _orderAmount, _dateOfOrder);
        
        return true;
    }

    /// @notice Function to close the setting procedure and start to use this smart contract
    /// @return True if successful
    function closeSetup() returns (bool) {
        
        if (smartContractStartDate != 0 
            || (msg.sender != creator && msg.sender != Client())) return;

        smartContractStartDate = now;

        return true;
    }
    
// Account Management

    /// @notice Function to update the recipent address
    /// @param _newRecipient The adress of the recipient
    function updateRecipient(address _newRecipient) onlyContractor {

        if (_newRecipient == 0) throw;

        RecipientUpdated(msg.sender, recipient, _newRecipient);
        recipient = _newRecipient;
    } 

    /// @notice Function to receive payments
    function () payable { }
    
    /// @notice Function to allow contractors to withdraw ethers
    /// @param _amount The amount (in wei) to withdraw
    function withdraw(uint _amount) onlyContractor {
        if (!recipient.send(_amount)) throw;
        Withdrawal(msg.sender, recipient, _amount);
    }
    
// Project Manager Functions    

    /// @notice Function to allow the project manager updating the description of the project
    /// @param _projectDescription A description of the project
    /// @param _hashOfTheDocument The hash of the last document
    function updateProjectDescription(string _projectDescription, bytes32 _hashOfTheDocument) onlyContractor {
        passProject.updateDescription(_projectDescription, _hashOfTheDocument);
    }
    
// Management of proposals

    /// @notice Function to make a proposal to work for the client
    /// @param _creator The address of the creator of the proposal
    /// @param _amount The amount (in wei) of the proposal
    /// @param _description String describing the proposal
    /// @param _hashOfTheDocument The hash of the proposal document
    /// @return The index of the contractor proposal
    function newProposal(
        address _creator,
        uint _amount,
        string _description, 
        bytes32 _hashOfTheDocument
    ) external returns (uint) {
        
        if (msg.sender == Client() && _creator != recipient && _creator != creator) throw;
        if (msg.sender != Client() && msg.sender != recipient && msg.sender != creator) throw;

        if (_amount == 0) throw;
        
        uint _proposalID = proposals.length++;
        proposal c = proposals[_proposalID];

        c.amount = _amount;
        c.description = _description;
        c.hashOfTheDocument = _hashOfTheDocument; 
        c.dateOfProposal = now;
        
        ProposalAdded(msg.sender, _proposalID, c.amount, c.description, c.hashOfTheDocument);
        
        return _proposalID;
    }
    
    /// @notice Function used by the client to infor about the submitted amount
    /// @param _sender The address of the sender who submits the proposal
    /// @param _proposalID The index of the contractor proposal
    /// @param _amount The amount (in wei) submitted
    function submitProposal(
        address _sender, 
        uint _proposalID, 
        uint _amount) onlyClient {

        if (_sender != recipient && _sender != creator) throw;    
        proposals[_proposalID].submittedAmount += _amount;
        ProposalSubmitted(msg.sender, _amount);
    }

    /// @notice Function used by the client to order according to the contractor proposal
    /// @param _proposalID The index of the contractor proposal
    /// @param _orderAmount The amount (in wei) of the order
    /// @return Whether the order was made or not
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
        c.dateOfLastOrder = now;
        
        Order(msg.sender, _proposalID, _orderAmount);
        
        return true;
    }
    
}

contract PassContractorCreator {
    
    // Address of the pass Dao smart contract
    PassDao public passDao;
    // Address of the Pass Project creator
    PassProjectCreator public projectCreator;
    
    struct contractor {
        // The address of the creator of the contractor
        address creator;
        // The contractor smart contract
        PassContractor contractor;
        // The address of the recipient for withdrawals
        address recipient;
        // True if meta project
        bool metaProject;
        // The address of the existing project smart contract
        PassProject passProject;
        // The name of the project (if the project smart contract doesn't exist)
        string projectName;
        // A description of the project (can be updated after)
        string projectDescription;
        // The unix creation date of the contractor
        uint creationDate;
    }
    // contractors created to work for Pass Dao
    contractor[] public contractors;
    
    event NewPassContractor(address indexed Creator, address indexed Recipient, PassProject indexed Project, PassContractor Contractor);

    function PassContractorCreator(PassDao _passDao, PassProjectCreator _projectCreator) {
        passDao = _passDao;
        projectCreator = _projectCreator;
        contractors.length = 0;
    }

    /// @return The number of created contractors 
    function numberOfContractors() constant returns (uint) {
        return contractors.length;
    }
    
    /// @notice Function to create a contractor smart contract
    /// @param _creator The address of the creator of the contractor
    /// @param _recipient The address of the recipient for withdrawals
    /// @param _metaProject True if meta project
    /// @param _passProject The address of the existing project smart contract
    /// @param _projectName The name of the project (if the project smart contract doesn't exist)
    /// @param _projectDescription A description of the project (can be updated after)
    /// @param _restore True if orders or proposals are to be cloned from other contracts
    /// @return The address of the created contractor smart contract
    function createContractor(
        address _creator,
        address _recipient, 
        bool _metaProject,
        PassProject _passProject,
        string _projectName, 
        string _projectDescription,
        bool _restore) returns (PassContractor) {
 
        PassProject _project;

        if (_creator == 0) _creator = msg.sender;
        
        if (_metaProject) _project = PassProject(passDao.MetaProject());
        else if (address(_passProject) == 0) 
            _project = projectCreator.createProject(passDao, _projectName, _projectDescription, 0);
        else _project = _passProject;

        PassContractor _contractor = new PassContractor(_creator, _project, _recipient, _restore);
        if (!_metaProject && address(_passProject) == 0 && !_restore) _project.setProjectManager(address(_contractor));
        
        uint _contractorID = contractors.length++;
        contractor c = contractors[_contractorID];
        c.creator = _creator;
        c.contractor = _contractor;
        c.recipient = _recipient;
        c.metaProject = _metaProject;
        c.passProject = _passProject;
        c.projectName = _projectName;
        c.projectDescription = _projectDescription;
        c.creationDate = now;

        NewPassContractor(_creator, _recipient, _project, _contractor);
 
        return _contractor;
    }
    
}


pragma solidity ^0.4.8;

/*
 *
 * This file is part of Pass DAO.
 *

/*
Smart contract for a Decentralized Autonomous Organization (DAO)
to automate organizational governance and decision-making.
*/

/// @title Pass Committee Room
contract PassCommitteeRoomInterface {

    // The Pass Dao smart contract
    PassDao public passDao;

    enum ProposalTypes { contractor, resolution, rules, upgrade }

    struct Committee {        
        // Address of the creator of the committee
        address creator;  
        // The type of the proposal
        ProposalTypes proposalType;
        // Index to identify the proposal
        uint proposalID;
        // unix timestamp, denoting the end of the set period of a proposal before the committee 
        uint setDeadline;
        // Fees (in wei) paid by the creator of the proposal
        uint fees;
        // Total of fees (in wei) rewarded to the voters
        uint totalRewardedAmount;
        // A unix timestamp, denoting the end of the voting period
        uint votingDeadline;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool open; 
        // A unix timestamp, denoting the date of the execution of the approved proposal
        uint dateOfExecution;
        // Number of shares in favor of the proposal
        uint yea; 
        // Number of shares opposed to the proposal
        uint nay; 
    }
    // Committees organized to vote for or against a proposal
    Committee[] public Committees; 
    // mapping to indicate if a shareholder has voted at a committee or not
    mapping (uint => mapping (address => bool)) hasVoted;

    struct Proposal {
        // Index to identify the committee
        uint committeeID;
        // The contractor smart contract (not mandatory if funding)
        PassContractor contractor;
        // The index of the contractor proposal in the contractor contract (not mandatory if funding)
        uint contractorProposalID;
        // The amount of the proposal from the share manager balance (for funding or contractor proposals)
        uint amount;
        // The address which sets partners and manages the funding (not mandatory)
        address moderator;
        // Amount from the sale of shares (for funding or contractor proposals)
        uint amountForShares;
        // The initial price multiplier of Dao shares at the beginning of the funding (not mandatory)
        uint initialSharePriceMultiplier; 
        // Amount from the sale of tokens (for project manager proposals)
        uint amountForTokens;
        // A unix timestamp, denoting the start time of the funding
        uint minutesFundingPeriod;
        // True if the proposal is closed
        bool open; 
    }
    // Proposals to pay a contractor or/and fund the Dao
    Proposal[] public Proposals;

    struct Question {
        // Index to identify a committee
        uint committeeID; 
        // The project smart contract
        PassProject project;
        // The name of the question for display purpose
        string name;
        // A description of the question
        string description;
    }
    // Questions submitted to a vote by the shareholders 
    Question[] public ResolutionProposals;
    
    struct Rules {
        // Index to identify a committee
        uint committeeID; 
        // The quorum needed for each proposal is calculated by totalSupply / minQuorumDivisor
        uint minQuorumDivisor;  
        // Minimum fees (in wei) to create a proposal
        uint minCommitteeFees; 
        // Minimum percentage of votes for a proposal to reward the creator
        uint minPercentageOfLikes;
        // Period in minutes to consider or set a proposal before the voting procedure
        uint minutesSetProposalPeriod; 
        // The minimum debate period in minutes that a generic proposal can have
        uint minMinutesDebatePeriod;
        // The inflation rate to calculate the reward of fees to voters
        uint feesRewardInflationRate;
        // The inflation rate to calculate the token price (for project manager proposals) 
        uint tokenPriceInflationRate;
        // The default minutes funding period
        uint defaultMinutesFundingPeriod;
    } 
    // Proposals to update the committee rules
    Rules[] public rulesProposals;

    struct Upgrade {
        // Index to identify a committee
        uint committeeID; 
        // Address of the proposed Committee Room smart contract
        address newCommitteeRoom;
        // Address of the proposed share manager smart contract
        address newShareManager;
        // Address of the proposed token manager smart contract
        address newTokenManager;
    }
    // Proposals to upgrade
    Upgrade[] public UpgradeProposals;
    
    // The minimum periods in minutes 
    uint minMinutesPeriods;
    // The maximum inflation rate for token price or rewards to voters
    uint maxInflationRate;
    
    /// @return the effective share manager
    function ShareManager() constant returns (PassManager);

    /// @return the effective token manager
    function TokenManager() constant returns (PassManager);

    /// return the balance of the DAO
    function Balance() constant returns (uint);
    
    /// @param _committeeID The index of the committee
    /// @param _shareHolder The shareholder (not mandatory, default : msg.sender)
    /// @return true if the shareholder has voted at the committee
    function HasVoted(
        uint _committeeID, 
        address _shareHolder) constant external returns (bool);
    
    /// @return The minimum quorum for proposals to pass 
    function minQuorum() constant returns (uint);

    /// @return The number of committees 
    function numberOfCommittees() constant returns (uint);
    
    /// @dev The constructor function
    /// @param _passDao Address of Pass Dao
    //function PassCommitteeRoom(address _passDao);

    /// @notice Function to init an set the committee rules
    /// @param _maxInflationRate The maximum inflation rate for contractor and funding proposals
    /// @param _minMinutesPeriods The minimum periods in minutes
    /// @param _minQuorumDivisor The initial minimum quorum divisor for the proposals
    /// @param _minCommitteeFees The minimum amount (in wei) to make a proposal
    /// @param _minPercentageOfLikes Minimum percentage of votes for a proposal to reward the creator
    /// @param _minutesSetProposalPeriod The minimum period in minutes before a committee
    /// @param _minMinutesDebatePeriod The minimum period in minutes of the board meetings
    /// @param _feesRewardInflationRate The inflation rate to calculate the reward of fees to voters during a committee
    /// @param _tokenPriceInflationRate The inflation rate to calculate the token price for project manager proposals
    /// @param _defaultMinutesFundingPeriod Default period in minutes of the funding
    function init(
        uint _maxInflationRate,
        uint _minMinutesPeriods,
        uint _minQuorumDivisor,
        uint _minCommitteeFees,
        uint _minPercentageOfLikes,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        uint _tokenPriceInflationRate,
        uint _defaultMinutesFundingPeriod);

    /// @notice Function to create a contractor smart contract
    /// @param _contractorCreator The contractor creator smart contract
    /// @param _recipient The recipient of the contractor smart contract
    /// @param _metaProject True if meta project
    /// @param _passProject The project smart contract (not mandatory)
    /// @param _projectName The name of the project (if the project smart contract doesn't exist)
    /// @param _projectDescription A description of the project (not mandatory, can be updated after)
    /// @return The contractor smart contract
    function createContractor(
        PassContractorCreator _contractorCreator,
        address _recipient,
        bool _metaProject,
        PassProject _passProject,
        string _projectName, 
        string _projectDescription) returns (PassContractor);
    
    /// @notice Function to make a proposal to pay a contractor or/and fund the Dao
    /// @param _amount Amount of the proposal
    /// @param _contractor The contractor smart contract
    /// @param _contractorProposalID Index of the contractor proposal in the contractor smart contract (not mandatory)
    /// @param _proposalDescription String describing the proposal (if not existing proposal)
    /// @param _hashOfTheContractorProposalDocument The hash of the Contractor proposal document (if not existing proposal)
    /// @param _moderator The address which sets partners and manage the funding (not mandatory)
    /// @param _initialSharePriceMultiplier The initial price multiplier of shares (for funding or contractor proposals)
    /// @param _minutesFundingPeriod Period in minutes of the funding (not mandatory)
    /// @param _minutesDebatingPeriod Period in minutes of the board meeting to vote on the proposal (not mandatory)
    /// @return The index of the proposal
    function contractorProposal(
        uint _amount,
        PassContractor _contractor,
        uint _contractorProposalID,
        string _proposalDescription, 
        bytes32 _hashOfTheContractorProposalDocument,
        address _moderator,
        uint _initialSharePriceMultiplier, 
        uint _minutesFundingPeriod,
        uint _minutesDebatingPeriod) payable returns (uint);

    /// @notice Function to submit a question
    /// @param _name Name of the question for display purpose
    /// @param _description A description of the question
    /// @param _project The project smart contract
    /// @param _minutesDebatingPeriod Period in minutes of the board meeting to vote on the proposal
    /// @return The index of the proposal
    function resolutionProposal(
        string _name,
        string _description,
        PassProject _project,
        uint _minutesDebatingPeriod) payable returns (uint);
        
    /// @notice Function to make a proposal to change the rules of the committee room 
    /// @param _minQuorumDivisor If 5, the minimum quorum is 20%
    /// @param _minCommitteeFees The minimum amount (in wei) to make a proposal
    /// @param _minPercentageOfLikes Minimum percentage of votes for a proposal to reward the creator
    /// @param _minutesSetProposalPeriod Minimum period in minutes before a committee
    /// @param _minMinutesDebatePeriod The minimum period in minutes of the committees
    /// @param _feesRewardInflationRate The inflation rate to calculate the reward of fees to voters during a committee
    /// @param _defaultMinutesFundingPeriod Period in minutes of the funding
    /// @param _tokenPriceInflationRate The inflation rate to calculate the token price for project manager proposals
    /// @return The index of the proposal
    function rulesProposal(
        uint _minQuorumDivisor, 
        uint _minCommitteeFees,
        uint _minPercentageOfLikes,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        uint _defaultMinutesFundingPeriod,
        uint _tokenPriceInflationRate) payable returns (uint);
    
    /// @notice Function to make a proposal to upgrade the application
    /// @param _newCommitteeRoom Address of a new Committee Room smart contract (not mandatory)   
    /// @param _newShareManager Address of a new share manager smart contract (not mandatory)
    /// @param _newTokenManager Address of a new token manager smart contract (not mandatory)
    /// @param _minutesDebatingPeriod Period in minutes of the committee to vote on the proposal (not mandatory)
    /// @return The index of the proposal
    function upgradeProposal(
        address _newCommitteeRoom,
        address _newShareManager,
        address _newTokenManager,
        uint _minutesDebatingPeriod) payable returns (uint);

    /// @dev Internal function to create a committee
    /// @param _proposalType The type of the proposal
    /// @param _proposalID The index of the proposal
    /// @param _minutesDebatingPeriod The duration in minutes of the committee
    /// @return the index of the board meeting
    function newCommittee(
        ProposalTypes _proposalType,
        uint _proposalID, 
        uint _minutesDebatingPeriod) internal returns (uint);
        
    /// @notice Function to vote for or against a proposal during a committee
    /// @param _committeeID The index of the committee
    /// @param _supportsProposal True if the proposal is supported
    function vote(
        uint _committeeID, 
        bool _supportsProposal);
    
    /// @notice Function to execute a decision and close the committee
    /// @param _committeeID The index of the committee
    /// @return Whether the proposal was executed or not
    function executeDecision(uint _committeeID) returns (bool);
    
    /// @notice Function to order to a contractor and close a contractor proposal
    /// @param _proposalID The index of the proposal
    /// @return Whether the proposal was ordered and the proposal amount sent or not
    function orderToContractor(uint _proposalID) returns (bool);   

    /// @notice Function to buy shares and or/and promote a contractor proposal 
    /// @param _proposalID The index of the proposal
    /// @return Whether the function was successful or not
    function buySharesForProposal(uint _proposalID) payable returns (bool);
    
    /// @notice Function to send tokens or refund after the closing time of the funding proposals
    /// @param _from The first proposal. 0 if not linked to a proposal
    /// @param _to The last proposal
    /// @param _buyer The address of the buyer
    /// @return Whether the function was successful or not 
    function sendPendingAmounts(        
        uint _from,
        uint _to,
        address _buyer) returns (bool);
        
    /// @notice Function to receive tokens or refund after the closing time of the funding proposals
    /// @return Whether the function was successful or not
    function withdrawPendingAmounts() returns (bool);

    event CommitteeLimits(uint maxInflationRate, uint minMinutesPeriods);
    
    event ContractorCreated(PassContractorCreator Creator, address indexed Sender, PassContractor Contractor, address Recipient);

    event ProposalSubmitted(uint indexed ProposalID, uint CommitteeID, PassContractor indexed Contractor, uint indexed ContractorProposalID, 
        uint Amount, string Description, address Moderator, uint SharePriceMultiplier, uint MinutesFundingPeriod);
    event ResolutionProposalSubmitted(uint indexed QuestionID, uint indexed CommitteeID, PassProject indexed Project, string Name, string Description);
    event RulesProposalSubmitted(uint indexed rulesProposalID, uint CommitteeID, uint MinQuorumDivisor, uint MinCommitteeFees, uint MinPercentageOfLikes, 
        uint MinutesSetProposalPeriod, uint MinMinutesDebatePeriod, uint FeesRewardInflationRate, uint DefaultMinutesFundingPeriod, uint TokenPriceInflationRate);
    event UpgradeProposalSubmitted(uint indexed UpgradeProposalID, uint indexed CommitteeID, address NewCommitteeRoom, 
        address NewShareManager, address NewTokenManager);

    event Voted(uint indexed CommitteeID, bool Position, address indexed Voter, uint RewardedAmount);

    event ProposalClosed(uint indexed ProposalID, ProposalTypes indexed ProposalType, uint CommitteeID, 
        uint TotalRewardedAmount, bool ProposalExecuted, uint RewardedSharesAmount, uint SentToManager);
    event ContractorProposalClosed(uint indexed ProposalID, uint indexed ContractorProposalID, PassContractor indexed Contractor, uint AmountSent);
    event DappUpgraded(address NewCommitteeRoom, address NewShareManager, address NewTokenManager);

}

contract PassCommitteeRoom is PassCommitteeRoomInterface {

// Constant functions

    function ShareManager() constant returns (PassManager) {
        return PassManager(passDao.ActualShareManager());
    }
    
    function TokenManager() constant returns (PassManager) {
        return PassManager(passDao.ActualTokenManager());
    }
    
    function Balance() constant returns (uint) {
        return passDao.ActualShareManager().balance;
    }

    function HasVoted(
        uint _committeeID, 
        address _shareHolder) constant external returns (bool) {

        if (_shareHolder == 0) return hasVoted[_committeeID][msg.sender];
        else return hasVoted[_committeeID][_shareHolder];
    }
    
    function minQuorum() constant returns (uint) {
        return (uint(ShareManager().totalSupply()) / rulesProposals[0].minQuorumDivisor);
    }

    function numberOfCommittees() constant returns (uint) {
        return Committees.length - 1;
    }
    
// Constructor and init functions

    function PassCommitteeRoom(address _passDao) {

        passDao = PassDao(_passDao);
        rulesProposals.length = 1; 
        Committees.length = 1;
        Proposals.length = 1;
        ResolutionProposals.length = 1;
        UpgradeProposals.length = 1;
    }
    
    function init(
        uint _maxInflationRate,
        uint _minMinutesPeriods,
        uint _minQuorumDivisor,
        uint _minCommitteeFees,
        uint _minPercentageOfLikes,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        uint _tokenPriceInflationRate,
        uint _defaultMinutesFundingPeriod) {

        maxInflationRate = _maxInflationRate;
        minMinutesPeriods = _minMinutesPeriods;
        CommitteeLimits(maxInflationRate, minMinutesPeriods);
        
        if (rulesProposals[0].minQuorumDivisor != 0) throw;
        rulesProposals[0].minQuorumDivisor = _minQuorumDivisor;
        rulesProposals[0].minCommitteeFees = _minCommitteeFees;
        rulesProposals[0].minPercentageOfLikes = _minPercentageOfLikes;
        rulesProposals[0].minutesSetProposalPeriod = _minutesSetProposalPeriod;
        rulesProposals[0].minMinutesDebatePeriod = _minMinutesDebatePeriod;
        rulesProposals[0].feesRewardInflationRate = _feesRewardInflationRate;
        rulesProposals[0].tokenPriceInflationRate = _tokenPriceInflationRate;
        rulesProposals[0].defaultMinutesFundingPeriod = _defaultMinutesFundingPeriod;

    }

// Project manager and contractor management

    function createContractor(
        PassContractorCreator _contractorCreator,
        address _recipient,
        bool _metaProject,
        PassProject _passProject,
        string _projectName, 
        string _projectDescription) returns (PassContractor) {

        PassContractor _contractor = _contractorCreator.createContractor(msg.sender, _recipient, 
            _metaProject, _passProject, _projectName, _projectDescription, false);
        ContractorCreated(_contractorCreator, msg.sender, _contractor, _recipient);
        return _contractor;
    }   

// Proposals Management

    function contractorProposal(
        uint _amount,
        PassContractor _contractor,
        uint _contractorProposalID,
        string _proposalDescription, 
        bytes32 _hashOfTheContractorProposalDocument,        
        address _moderator,
        uint _initialSharePriceMultiplier, 
        uint _minutesFundingPeriod,
        uint _minutesDebatingPeriod
    ) payable returns (uint) {

        if (_minutesFundingPeriod == 0) _minutesFundingPeriod = rulesProposals[0].defaultMinutesFundingPeriod;

        if (address(_contractor) != 0 && _contractorProposalID != 0) {
            if (_hashOfTheContractorProposalDocument != 0 
                ||!_contractor.proposalChecked(msg.sender, _contractorProposalID, _amount)) throw;
            else _proposalDescription = "Proposal checked";
        }

        if ((address(_contractor) != 0 && _contractorProposalID == 0 && _hashOfTheContractorProposalDocument == 0)
            || _amount == 0
            || _minutesFundingPeriod < minMinutesPeriods) throw;

        uint _proposalID = Proposals.length++;
        Proposal p = Proposals[_proposalID];

        p.contractor = _contractor;
        
        if (_contractorProposalID == 0 && _hashOfTheContractorProposalDocument != 0) {
            _contractorProposalID = _contractor.newProposal(msg.sender, _amount, _proposalDescription, _hashOfTheContractorProposalDocument);
        }
        p.contractorProposalID = _contractorProposalID;

        if (address(_contractor) == 0) p.amountForShares = _amount;
        else {
            _contractor.submitProposal(msg.sender, _contractorProposalID, _amount);
            if (_contractor.Project().ProjectManager() == address(_contractor)) p.amountForTokens = _amount;
            else {
                p.amount = Balance();
                if (_amount > p.amount) p.amountForShares = _amount - p.amount;
                else p.amount = _amount;
            }
        }
        
        p.moderator = _moderator;

        p.initialSharePriceMultiplier = _initialSharePriceMultiplier;

        p.minutesFundingPeriod = _minutesFundingPeriod;

        p.committeeID = newCommittee(ProposalTypes.contractor, _proposalID, _minutesDebatingPeriod);   

        p.open = true;
        
        ProposalSubmitted(_proposalID, p.committeeID, p.contractor, p.contractorProposalID, p.amount+p.amountForShares+p.amountForTokens, 
            _proposalDescription, p.moderator, p.initialSharePriceMultiplier, p.minutesFundingPeriod);

        return _proposalID;
    }

    function resolutionProposal(
        string _name,
        string _description,
        PassProject _project,
        uint _minutesDebatingPeriod) payable returns (uint) {
        
        if (address(_project) == 0) _project = PassProject(passDao.MetaProject());
        
        uint _questionID = ResolutionProposals.length++;
        Question q = ResolutionProposals[_questionID];
        
        q.project = _project;
        q.name = _name;
        q.description = _description;
        
        q.committeeID = newCommittee(ProposalTypes.resolution, _questionID, _minutesDebatingPeriod);
        
        ResolutionProposalSubmitted(_questionID, q.committeeID, q.project, q.name, q.description);
        
        return _questionID;
    }

    function rulesProposal(
        uint _minQuorumDivisor, 
        uint _minCommitteeFees,
        uint _minPercentageOfLikes,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        uint _defaultMinutesFundingPeriod,
        uint _tokenPriceInflationRate) payable returns (uint) {

    
        if (_minQuorumDivisor <= 1
            || _minQuorumDivisor > 10
            || _minutesSetProposalPeriod < minMinutesPeriods
            || _minMinutesDebatePeriod < minMinutesPeriods
            || _feesRewardInflationRate > maxInflationRate
            || _tokenPriceInflationRate > maxInflationRate
            || _defaultMinutesFundingPeriod < minMinutesPeriods) throw; 
        
        uint _rulesProposalID = rulesProposals.length++;
        Rules r = rulesProposals[_rulesProposalID];

        r.minQuorumDivisor = _minQuorumDivisor;
        r.minCommitteeFees = _minCommitteeFees;
        r.minPercentageOfLikes = _minPercentageOfLikes;
        r.minutesSetProposalPeriod = _minutesSetProposalPeriod;
        r.minMinutesDebatePeriod = _minMinutesDebatePeriod;
        r.feesRewardInflationRate = _feesRewardInflationRate;
        r.defaultMinutesFundingPeriod = _defaultMinutesFundingPeriod;
        r.tokenPriceInflationRate = _tokenPriceInflationRate;

        r.committeeID = newCommittee(ProposalTypes.rules, _rulesProposalID, 0);

        RulesProposalSubmitted(_rulesProposalID, r.committeeID, _minQuorumDivisor, _minCommitteeFees, 
            _minPercentageOfLikes, _minutesSetProposalPeriod, _minMinutesDebatePeriod, 
            _feesRewardInflationRate, _defaultMinutesFundingPeriod, _tokenPriceInflationRate);

        return _rulesProposalID;
    }
    
    function upgradeProposal(
        address _newCommitteeRoom,
        address _newShareManager,
        address _newTokenManager,
        uint _minutesDebatingPeriod
    ) payable returns (uint) {
        
        uint _upgradeProposalID = UpgradeProposals.length++;
        Upgrade u = UpgradeProposals[_upgradeProposalID];
        
        u.newCommitteeRoom = _newCommitteeRoom;
        u.newShareManager = _newShareManager;
        u.newTokenManager = _newTokenManager;

        u.committeeID = newCommittee(ProposalTypes.upgrade, _upgradeProposalID, _minutesDebatingPeriod);
        
        UpgradeProposalSubmitted(_upgradeProposalID, u.committeeID, u.newCommitteeRoom, u.newShareManager, u.newTokenManager);
        
        return _upgradeProposalID;
    }
    
// Committees management

    function newCommittee(
        ProposalTypes _proposalType,
        uint _proposalID, 
        uint _minutesDebatingPeriod
    ) internal returns (uint) {

        if (_minutesDebatingPeriod == 0) _minutesDebatingPeriod = rulesProposals[0].minMinutesDebatePeriod;
        
        if (passDao.ActualCommitteeRoom() != address(this)
            || msg.value < rulesProposals[0].minCommitteeFees
            || now + ((rulesProposals[0].minutesSetProposalPeriod + _minutesDebatingPeriod) * 1 minutes) < now
            || _minutesDebatingPeriod < rulesProposals[0].minMinutesDebatePeriod
            || msg.sender == address(this)) throw;

        uint _committeeID = Committees.length++;
        Committee b = Committees[_committeeID];

        b.creator = msg.sender;

        b.proposalType = _proposalType;
        b.proposalID = _proposalID;

        b.fees = msg.value;
        
        b.setDeadline = now + (rulesProposals[0].minutesSetProposalPeriod * 1 minutes);        
        b.votingDeadline = b.setDeadline + (_minutesDebatingPeriod * 1 minutes); 

        b.open = true; 

        return _committeeID;
    }
    
    function vote(
        uint _committeeID, 
        bool _supportsProposal) {
        
        Committee b = Committees[_committeeID];

        if (hasVoted[_committeeID][msg.sender] 
            || now < b.setDeadline
            || now > b.votingDeadline) throw;
            
        PassManager _shareManager = ShareManager();

        uint _balance = uint(_shareManager.balanceOf(msg.sender));
        if (_balance == 0) throw;
        
        hasVoted[_committeeID][msg.sender] = true;

        _shareManager.blockTransfer(msg.sender, b.votingDeadline);

        if (_supportsProposal) b.yea += _balance;
        else b.nay += _balance; 

        uint _a = 100*b.fees;
        if ((_a/100 != b.fees) || ((_a*_balance)/_a != _balance)) throw;
        uint _multiplier = (_a*_balance)/uint(_shareManager.totalSupply());
        uint _divisor = 100 + 100*rulesProposals[0].feesRewardInflationRate*(now - b.setDeadline)/(100*365 days);
        uint _rewardedamount = _multiplier/_divisor;
        if (b.totalRewardedAmount + _rewardedamount > b.fees) _rewardedamount = b.fees - b.totalRewardedAmount;
        b.totalRewardedAmount += _rewardedamount;
        if (!msg.sender.send(_rewardedamount)) throw;

        Voted(_committeeID, _supportsProposal, msg.sender, _rewardedamount);    
}

// Decisions management

    function executeDecision(uint _committeeID) returns (bool) {

        Committee b = Committees[_committeeID];
        
        if (now < b.votingDeadline || !b.open) return;
        
        b.open = false;

        PassManager _shareManager = ShareManager();
        uint _quantityOfShares;
        PassManager _tokenManager = TokenManager();

        if (100*b.yea > rulesProposals[0].minPercentageOfLikes * uint(_shareManager.totalSupply())) {       
            _quantityOfShares = _shareManager.rewardTokensForClient(b.creator, rulesProposals[0].minCommitteeFees);
        }        

        uint _sentToDaoManager = b.fees - b.totalRewardedAmount;
        if (_sentToDaoManager > 0) {
            if (!address(_shareManager).send(_sentToDaoManager)) throw;
        }
        
        if (b.yea + b.nay < minQuorum() || b.yea <= b.nay) {
            if (b.proposalType == ProposalTypes.contractor) Proposals[b.proposalID].open = false;
            ProposalClosed(b.proposalID, b.proposalType, _committeeID, b.totalRewardedAmount, false, _quantityOfShares, _sentToDaoManager);
            return;
        }

        b.dateOfExecution = now;

        if (b.proposalType == ProposalTypes.contractor) {

            Proposal p = Proposals[b.proposalID];
    
            if (p.contractorProposalID == 0) p.open = false;
            
            if (p.amountForShares == 0 && p.amountForTokens == 0) orderToContractor(b.proposalID);
            else {
                if (p.amountForShares != 0) {
                    _shareManager.setFundingRules(p.moderator, p.initialSharePriceMultiplier, p.amountForShares, p.minutesFundingPeriod, 0, b.proposalID);
                }

                if (p.amountForTokens != 0) {
                    _tokenManager.setFundingRules(p.moderator, 0, p.amountForTokens, p.minutesFundingPeriod, rulesProposals[0].tokenPriceInflationRate, b.proposalID);
                }
            }

        } else if (b.proposalType == ProposalTypes.resolution) {
            
            Question q = ResolutionProposals[b.proposalID];
            
            q.project.newResolution(q.name, q.description);
            
        } else if (b.proposalType == ProposalTypes.rules) {

            Rules r = rulesProposals[b.proposalID];
            
            rulesProposals[0].committeeID = r.committeeID;
            rulesProposals[0].minQuorumDivisor = r.minQuorumDivisor;
            rulesProposals[0].minMinutesDebatePeriod = r.minMinutesDebatePeriod; 
            rulesProposals[0].minCommitteeFees = r.minCommitteeFees;
            rulesProposals[0].minPercentageOfLikes = r.minPercentageOfLikes;
            rulesProposals[0].minutesSetProposalPeriod = r.minutesSetProposalPeriod;
            rulesProposals[0].feesRewardInflationRate = r.feesRewardInflationRate;
            rulesProposals[0].tokenPriceInflationRate = r.tokenPriceInflationRate;
            rulesProposals[0].defaultMinutesFundingPeriod = r.defaultMinutesFundingPeriod;

        } else if (b.proposalType == ProposalTypes.upgrade) {

            Upgrade u = UpgradeProposals[b.proposalID];

            if ((u.newShareManager != 0) && (u.newShareManager != address(_shareManager))) {
                _shareManager.disableTransfer();
                if (_shareManager.balance > 0) {
                    if (!_shareManager.sendTo(u.newShareManager, _shareManager.balance)) throw;
                }
            }

            if ((u.newTokenManager != 0) && (u.newTokenManager != address(_tokenManager))) {
                _tokenManager.disableTransfer();
            }

            passDao.upgrade(u.newCommitteeRoom, u.newShareManager, u.newTokenManager);
                
            DappUpgraded(u.newCommitteeRoom, u.newShareManager, u.newTokenManager);
            
        }

        ProposalClosed(b.proposalID, b.proposalType, _committeeID , b.totalRewardedAmount, true, _quantityOfShares, _sentToDaoManager);
            
        return true;
    }
    
    function orderToContractor(uint _proposalID) returns (bool) {
        
        Proposal p = Proposals[_proposalID];
        Committee b = Committees[p.committeeID];

        if (b.open || !p.open) return;
        
        uint _amountForShares;
        uint _amountForTokens;

        if (p.amountForShares != 0) {
            _amountForShares = ShareManager().FundedAmount(_proposalID);
            if (_amountForShares == 0 && now <= b.dateOfExecution + (p.minutesFundingPeriod * 1 minutes)) return;
        }

        if (p.amountForTokens != 0) {
            _amountForTokens = TokenManager().FundedAmount(_proposalID);
            if (_amountForTokens == 0 && now <= b.dateOfExecution + (p.minutesFundingPeriod * 1 minutes)) return;
        }
        
        p.open = false;   

        uint _amount = p.amount + _amountForShares + _amountForTokens;

        PassProject _project = PassProject(p.contractor.Project());

        if (_amount == 0) {
            ContractorProposalClosed(_proposalID, p.contractorProposalID, p.contractor, 0);
            return;
        }    

        if (!p.contractor.order(p.contractorProposalID, _amount)) throw;
        
        if (p.amount + _amountForShares > 0) {
            if (!ShareManager().sendTo(p.contractor, p.amount + _amountForShares)) throw;
        }
        if (_amountForTokens > 0) {
            if (!TokenManager().sendTo(p.contractor, _amountForTokens)) throw;
        }

        ContractorProposalClosed(_proposalID, p.contractorProposalID, p.contractor, _amount);
        
        passDao.addProject(_project);
        _project.newOrder(p.contractor, p.contractorProposalID, _amount);
        
        return true;
    }

// Holder Account management

    function buySharesForProposal(uint _proposalID) payable returns (bool) {
        
        return ShareManager().buyTokensForProposal.value(msg.value)(_proposalID, msg.sender);
    }   

    function sendPendingAmounts(
        uint _from,
        uint _to,
        address _buyer) returns (bool) {
        
        return ShareManager().sendPendingAmounts(_from, _to, _buyer);
    }        
    
    function withdrawPendingAmounts() returns (bool) {
        
        if (!ShareManager().sendPendingAmounts(0, 0, msg.sender)) throw;
    }        
            
}
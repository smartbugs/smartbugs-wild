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
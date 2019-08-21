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
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
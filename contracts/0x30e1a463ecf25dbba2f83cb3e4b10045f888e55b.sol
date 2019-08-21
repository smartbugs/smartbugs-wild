pragma solidity ^0.4.6;

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {
    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner { if (msg.sender != owner) throw; _; }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() { owner = msg.sender;}

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
}


contract GivethDirectory is Owned {

    enum CampaignStatus {Preparing, Active, Obsoleted, Deleted}

    struct Campaign {
        string name;
        string description;
        string url;
        address token;
        address vault;
        address milestoneTracker;
        string extra;
        CampaignStatus status;
    }

    Campaign[] campaigns;

    function addCampaign(
        string name,
        string description,
        string url,
        address token,
        address vault,
        address milestoneTracker,
        string extra
    ) onlyOwner returns(uint idCampaign) {

        idCampaign = campaigns.length++;
        Campaign c = campaigns[idCampaign];
        c.name = name;
        c.description = description;
        c.url = url;
        c.token = token;
        c.vault = vault;
        c.milestoneTracker = milestoneTracker;
        c.extra = extra;
    }

    function updateCampaign(
        uint idCampaign,
        string name,
        string description,
        string url,
        address token,
        address vault,
        address milestoneTracker,
        string extra
    ) onlyOwner {
        if (idCampaign >= campaigns.length) throw;
        Campaign c = campaigns[idCampaign];
        c.name = name;
        c.description = description;
        c.url = url;
        c.token = token;
        c.vault = vault;
        c.milestoneTracker = milestoneTracker;
        c.extra = extra;
    }

    function changeStatus(uint idCampaign, CampaignStatus newStatus) onlyOwner {
        if (idCampaign >= campaigns.length) throw;
        Campaign c = campaigns[idCampaign];
        c.status = newStatus;
    }

    function getCampaign(uint idCampaign) constant returns (
        string name,
        string description,
        string url,
        address token,
        address vault,
        address milestoneTracker,
        string extra,
        CampaignStatus status
    ) {
        if (idCampaign >= campaigns.length) throw;
        Campaign c = campaigns[idCampaign];
        name = c.name;
        description = c.description;
        url = c.url;
        token = c.token;
        vault = c.vault;
        milestoneTracker = c.milestoneTracker;
        extra = c.extra;
        status = c.status;
    }

    function numberOfCampaigns() constant returns (uint) {
        return campaigns.length;
    }

}
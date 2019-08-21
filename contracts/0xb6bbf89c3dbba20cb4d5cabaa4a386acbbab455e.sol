pragma solidity ^0.4.18;

contract ETHMap {

    /// Initial price zone (= LUX)
    /// set at 0.001 Eth
    uint initialZonePrice = 1000000000000000 wei;

    /// contractOwner address
    address contractOwner;

    /// Users pending withdrawals
    mapping(address => uint) pendingWithdrawals;

    /// Zone structures mapping
    mapping(uint => Zone) zoneStructs;
    uint[] zoneList;

    struct Zone {
        uint id;
        address owner;
        uint sellPrice;
    }

    /// Constructor
    function ETHMap() public {
      contractOwner = msg.sender;
    }

    modifier onlyContractOwner()
    {
       // Throws if called by any account other than the contract owner
        require(msg.sender == contractOwner);
        _;
    }

    modifier onlyValidZone(uint zoneId)
    {
       // Throws if zone id is not valid
        require(zoneId >= 1 && zoneId <= 178);
        _;
    }

    modifier onlyZoneOwner(uint zoneId)
    {
       // Throws if called by any account other than the zone owner
        require(msg.sender == zoneStructs[zoneId].owner);
        _;
    }

    function buyZone(uint zoneId) public
      onlyValidZone(zoneId)
      payable
    returns (bool success)
    {
        // Throw if zone is not on sale
        if (zoneStructs[zoneId].owner != address(0)) {
          require(zoneStructs[zoneId].sellPrice != 0);
        }
        // Throw if amount sent is not sufficient
        uint minPrice = (zoneStructs[zoneId].owner == address(0)) ? computeInitialPrice(zoneId) : zoneStructs[zoneId].sellPrice;
        require(msg.value >= minPrice);
        // If initial sale
        if (zoneStructs[zoneId].owner == address(0)) {
            // No current owners, credit contract owner balance
            pendingWithdrawals[contractOwner] += msg.value;
            // Init zone
            zoneStructs[zoneId].id = zoneId;
        } else {
          // Contract owner take 2% cut on transaction
          uint256 contractOwnerCut = (msg.value * 200) / 10000;
          uint256 ownersShare = msg.value - contractOwnerCut;
          // Credit contract owner
          pendingWithdrawals[contractOwner] += contractOwnerCut;
          // Credit zone owner
          address ownerAddress = zoneStructs[zoneId].owner;
          pendingWithdrawals[ownerAddress] += ownersShare;
        }

        zoneStructs[zoneId].owner = msg.sender;
        zoneStructs[zoneId].sellPrice = 0;
        return true;
    }

    /// Allow owner to sell his zone
    function sellZone(uint zoneId, uint amount) public
        onlyValidZone(zoneId)
        onlyZoneOwner(zoneId)
        returns (bool success) 
    {
        zoneStructs[zoneId].sellPrice = amount;
        return true;
    }

    /// Allow owner to transfer his zone
    function transferZone(uint zoneId, address recipient) public
        onlyValidZone(zoneId)
        onlyZoneOwner(zoneId)
        returns (bool success) 
    {
        zoneStructs[zoneId].owner = recipient;
        return true;
    }

    /// Compute initial zone price
    function computeInitialPrice(uint zoneId) public view
        onlyValidZone(zoneId)
        returns (uint price)
    {
        return initialZonePrice + ((zoneId - 1) * (initialZonePrice / 2));
    }

    /// Return zone details
    function getZone(uint zoneId) public constant
        onlyValidZone(zoneId)
        returns(uint id, address owner, uint sellPrice)
    {
        return (
          zoneStructs[zoneId].id,
          zoneStructs[zoneId].owner,
          zoneStructs[zoneId].sellPrice
        );
    }

    /// Return balance from sender
    function getBalance() public view
      returns (uint amount)
    {
        return pendingWithdrawals[msg.sender];
    }

    /// Allow address to withdraw their balance
    function withdraw() public
        returns (bool success) 
    {
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
        return true;
    }

    /// Allow contract owner to change address
    function transferContractOwnership(address newOwner) public
        onlyContractOwner()
        returns (bool success) 
    {
        contractOwner = newOwner;
        return true;
    }

}
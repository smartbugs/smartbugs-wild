/// @title The main smart contract for Etherprises LLC, Delaware, U.S. (c)2017 Etherprises LLC
/// @author Ville Sundell <contact@etherprises.com>
// This source code is available at https://etherscan.io/address/0x0d47d4aea9da60953fd4ae5c47d2165977c7fbea
// This code (and only this source code, not storage data nor other information/data) is released under CC-0.
// More source regarding Etherprises LLC can be found at: https://github.com/Etherprises
// The legal prose amending the contract between your series and Etherprises LLC is defined in prose() as a string array

pragma solidity ^0.4.9;

//This is the main contract, this handles series creation and renewal:
contract EtherprisesLLC {
    //This factory will create the series smart contract:
    address public seriesFactory;
    //This is the address of the only member or the series organization:
    address public generalManager;
    //List of series addresses, this is the main index:
    address[] public series;
    //Listing amendments as a legal prose, starting from 0:
    string[] public prose;
    //This map makes routing funds to user's latest series easy and fast:
    mapping (address => address) public latestSeriesForUser;
    //Series' expiring date is specified here as UNIX timestamp:
    mapping (address => uint) public expiresAt;
    //This maps series' name to an address
    mapping (bytes32 => address) public seriesByName;
    //This maps series' address to a name
    mapping (address => bytes32) public seriesByAddress;
    
    //Events for external monitoring:
    event AmendmentAdded (string newAmendment);
    event FeePaid (address which);
    event ManagerSet(address newManager);
    event FactorySet(address newFactory);
    event DepositMade(address where, uint amount);
    event SeriesCreated(address addr, uint id);
    
    /// @dev This is the initialization function, here we just mark
    /// ourselves as the General Manager for this series organization.
    function EtherprisesLLC() {
        generalManager = msg.sender;
    }
    
    /// @dev This modifier is used to check if the user is the GM.
    modifier ifGeneralManager {
        if (msg.sender != generalManager)
            throw;

        _;
    }
    
    /// @dev This modifier is used to check is the caller a series.
    modifier ifSeries {
        if (expiresAt[msg.sender] == 0)
            throw;

        _;
    }
    
    /// @dev Withdrawal happens here from Etherprises LLC to the GM.
    /// For bookkeeping and tax reasons we only want GM to withdraw.
    function withdraw() ifGeneralManager {
        generalManager.send(this.balance);
    }
    
    /// @dev This checks if the series is expired. This is meant to be
    /// called inside the series, and terminate the series if expired.
    /// @param addr Address of the series we want to check
    /// @return TRUE if series is expired, FALSE otherwise
    function isExpired(address addr) constant returns (bool) {
        if (expiresAt[addr] > now)
            return false;
        else
            return true;
    }
    
    /// @dev Amending rules of the organization, only those rules which
    /// were present upon creation of the Series, apply to the Series.
    /// @param newAmendment String containing new amendment. Remember to
    /// prefix it with the date
    function addAmendment(string newAmendment) ifGeneralManager {
        // Only GM can amend the rules.
        // Series obey only the rules which are set when series is created
        prose.push(newAmendment);
        
        AmendmentAdded(newAmendment);
    }
    
    /// @dev This function pays the yearly fee of 1 ETH.
    /// @return Boolean TRUE, if everything was successful
    function payFee() ifSeries payable returns (bool) {
        // Receiving fee of one ETH here
        if (msg.value != 1 ether)
            throw;
            
        expiresAt[msg.sender] += 1 years;
        
        FeePaid(msg.sender);
        return true;
    }
    
    /// @dev Sets the general manager for the main organization.
    /// There is just one member for Etherprises LLC, which is the GM.
    /// @param newManger Address of the new manager
    function setManager(address newManger) ifGeneralManager {
        generalManager = newManger;
        
        ManagerSet(newManger);
    }
    
    /// @dev This sets the factory proxy contract, which uses the factory.
    /// @param newFactory Address of the new factory proxy
    function setFactory(address newFactory) ifGeneralManager {
        seriesFactory = newFactory;
        
        FactorySet(newFactory);
    }
    
    /// @dev This creates a new series, called also from the fallback
    /// with default values.
    /// @notice This will create new series. Specify the name here: 
    /// This is the only place to define a name, the name is immutable.
    /// Please note, that the name must start with an alpha character
    /// (despite otherwise being UTF-8).
    /// Throws an exception if the name does not technically pass the tests.
    /// @param name Name of the series, must start with A-Z, and for the
    /// hash table the search key will exclude all other characters
    /// except A-Z. Full Unicode is supported, though
    /// @param shares Amount of shares, by default this is immutable
    /// @param industry Setting industry may have legal implications,
    /// i.e taxation
    /// @param symbol Symbol of the traded token
    /// @return seriesAddress Address of the newly created series contract
    /// @return seriesId Internal incremental ID number for the series
    function createSeries(
        bytes name,
        uint shares,
        string industry,
        string symbol,
        address extraContract
    ) payable returns (
        address seriesAddress,
        uint seriesId
    ) {
        seriesId = series.length;
        
        var(latestAddress, latestName) = SeriesFactory(seriesFactory).createSeries.value(msg.value)(seriesId, name, shares, industry, symbol, msg.sender, extraContract);
        if (latestAddress == 0)
            throw;

        if (latestName > 0)
            if (seriesByName[latestName] == 0)
                seriesByName[latestName] = latestAddress;
            else
                throw;

        series.push(latestAddress);
        expiresAt[latestAddress] = now + 1 years;
        latestSeriesForUser[msg.sender] = latestAddress;
        seriesByAddress[latestAddress] = latestName;
        
        SeriesCreated(latestAddress, seriesId);
        return (latestAddress, seriesId);
    }
    
    /// @dev This is here for Registrar ABI support.
    /// @param _name Name of the series we want to search, please note
    /// this is only the search key and not full name
    /// @return Address of the series we want to get
    function addr(bytes32 _name) constant returns(address o_address) {
        return seriesByName[_name];
    }
    
    /// @dev This is here for Registrar ABI support: return the search key
    /// for a contract.
    /// @param _owner Name of the series we want to search, please note
    /// this is only the search key and not full name
    /// @return Name of the series we want to get
    function name(address _owner) constant returns(bytes32 o_name){
        return seriesByAddress[_owner];
    }
    
    /// @dev Here the fallback function either creates a new series,
    /// or transfers funds to existing one.
    function () payable {
        if (msg.data.length > 0) {
            createSeries(msg.data, 0, "", "", 0x0);
        } else if (latestSeriesForUser[msg.sender] != 0) {
            //This is important to implement as call so we can forward gas
            if (latestSeriesForUser[msg.sender].call.value(msg.value)())
                DepositMade(latestSeriesForUser[msg.sender], msg.value);
        } else {
            createSeries("", 0, "", "", 0x0);
        }
    }
}

//This is a placeholder contract: In real life the main contract invokes
//a proxy, which in turn invokes the actual SeriesFactory
//The main contract for Etherprises LLC is above this one.
contract SeriesFactory {
    address public seriesFactory;
    address public owner;

    function createSeries (
        uint seriesId,
        bytes name,
        uint shares,
        string industry,
        string symbol,
        address manager,
        address extraContract
    ) payable returns (
        address addr,
        bytes32 newName
    ) {
        address newSeries;
        bytes32 _newName;

        return (newSeries, _newName);
    }
}
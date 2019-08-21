// Coinia Vy (c) 2016 Solarius Solutions (contact at solarius.fi), under GPLv2

/// @title Coinia Vy - Virtual limited partnership (designed for Finnish legal environment)
/// @author Solarius Solutions / Ville Sundell, code (and only code) released under GPLv2, you can find the code at 0x69f2a483a2ad4b910fa03a0f380d61f6dbe20017 using Etherscan

pragma solidity ^0.4.4; //This was originally written for 0.3.6 series, but in the last minute got updated to 0.4.2, and later 0.4.4

contract CoiniaVy {
    struct Shareholder {
        string name; // Legal name of partner
        string id; // Legal identification of the partner (birthday, registration number, business ID, etc.)
        uint shares; //Amount of shares, 0 being not a member/ex-member
        bool limited; // This is legal: If this is "true", the partner is limited, if false, the partner is general
    }
    
    string public standard = 'Token 0.1';
    address[] public projectManagers; //This is address to a contract managing projects and voting, will be commited later
    address[] public treasuryManagers; //This is address to a contract managing the money, will be commited later
    uint public totalSupply = 10000; // Total amount of shares
    string public home = "PL 18, 30101 Forssa, FINLAND";
    string public industry = "64190 Muu pankkitoiminta / Financial service nec";
    mapping (address => Shareholder) public shareholders;
    
    //These "tokenizes" the contract:
    string public name = "Coinia Vy";
    string public symbol = "CIA";
    uint8 public decimals = 0;
    
    //The events:
    event Transfer (address indexed from, address indexed to, uint shares);
    event ChangedName (address indexed who, string to);
    event ChangedId (address indexed who, string to);
    event Resigned (address indexed who);
    event SetLimited (address indexed who, bool limited);
    event SetIndustry (string indexed newIndustry);
    event SetHome (string indexed newHome);
    event SetName (string indexed newName);
    event AddedManager (address indexed manager);
    
    /// @dev This modifier is used with all of the functions requiring authorisation. Previously used msg.value check is not needed anymore.
    modifier ifAuthorised {
        if (shareholders[msg.sender].shares == 0)
            throw;

        _;
    }
    
    /// @dev This modifier is used to check if the user is a general partner
    modifier ifGeneralPartner {
        if (shareholders[msg.sender].limited == true)
            throw;

        _;
    }
    
    /// @dev This is the constructor, this is quick and dirty because of Ethereum's current DDoS difficulties deploying stuff is hard atm. So that's why hardcoding everything, so this contract could be deployed using whatever tool (not all support arguments)
    function CoiniaVy () {
        shareholders[this] = Shareholder (name, "2755797-6", 0, false);
        shareholders[msg.sender] = Shareholder ("Coinia OÜ", "14111022", totalSupply, false);
    }
    
    /// @dev Here we "tokenize" our contract, so wallets can use this as a token.
    /// @param target Address whose balance we want to query.
    function balanceOf(address target) constant returns(uint256 balance) {
        return shareholders[target].shares;
    }
    
    /// @notice This transfers `amount` shares to `target.address()`. This is irreversible, are  you OK with this?
    /// @dev This transfers shares from the current shareholder to a future shareholder, and will create one if it does not exists. This 
    /// @param target Address of the account which will receive the shares.
    /// @param amount Amount of shares, 0 being none, and 1 being one share, and so on.
    function transfer (address target, uint256 amount) ifAuthorised {
        if (amount == 0 || shareholders[msg.sender].shares < amount)
            throw;
        
        shareholders[msg.sender].shares -= amount;
        if (shareholders[target].shares > 0) {
            shareholders[target].shares += amount;
        } else {
            shareholders[target].shares = amount;
            shareholders[target].limited = true;
        }
        
        Transfer (msg.sender, target, amount);
    }
    
    /// @dev This function is used to change user's own name. Ethereum is anonymous by design, but there might be legal reasons for a user to do this.
    /// @param newName User's new name.
    function changeName (string newName) ifAuthorised {
        shareholders[msg.sender].name = newName;
        
        ChangedName (msg.sender, newName);
    }
    
    /// @dev This function is used to change user's own ID (Business ID, birthday, etc.) Ethereum is anonymous by design, but there might be legal reasons for a user to do this.
    /// @param newId User's name ID, might be something like a business ID, birthday, or some other identification string.
    function changeId (string newId) ifAuthorised {
        shareholders[msg.sender].id = newId;
        
        ChangedId (msg.sender, newId);
    }
    
    /// @notice WARNING! This will remove you'r existance from the company, this is irreversible and instant. This will not terminate the company. Are you really really sure?
    /// @dev This is required by Finnish law, a person must be able to resign from a company. This will not terminate the company.
    function resign () {
        if (bytes(shareholders[msg.sender].name).length == 0 || shareholders[msg.sender].shares > 0)
            throw;
            
        shareholders[msg.sender].name = "Resigned member";
        shareholders[msg.sender].id = "Resigned member";
        
        Resigned (msg.sender);
    }
    
    /// @notice This sets member's liability status, either to limited liability, or unlimited liability. Beware, that this has legal implications, and decission must be done with other general partners.
    /// @dev This is another function added for legal reason, using this, you can define is a member limited partner, or a general partner.
    /// @param target The user we want to define.
    /// @param isLimited Will the target be a limited partner.
    function setLimited (address target, bool isLimited) ifAuthorised ifGeneralPartner {
        shareholders[target].limited = isLimited;
        
        SetLimited (target, isLimited);
    }
    
    /// @dev This sets the industry of the company. This might have legal implications.
    /// @param newIndustry New industry, where there company is going to operate.
    function setIndustry (string newIndustry) ifAuthorised ifGeneralPartner {
        industry = newIndustry;
        
        SetIndustry (newIndustry);
    }
    
    /// @dev This sets the legal "home" of the company, most probably has legal implications, for example where possible court sessions are held.
    /// @param newHome New home of the company.
    function setHome (string newHome) ifAuthorised ifGeneralPartner {
        home = newHome;
        
        SetHome (newHome);
    }
    
    /// @dev This sets the legal name of the company, most probably has legal implications.
    /// @param newName New name of the company.
    function setName (string newName) ifAuthorised ifGeneralPartner {
        shareholders[this].name = newName;
        name = newName;
        
        SetName (newName);
    }
    
    /// @dev This function adds a new treasuryManager to the end of the list
    /// @param newManager Address of the new treasury manager
    function addTreasuryManager (address newManager) ifAuthorised ifGeneralPartner {
        treasuryManagers.push (newManager);
        
        AddedManager (newManager);
    }
    
    /// @dev This function adds a new projectManager to the end of the list
    /// @param newManager Address of the new project manager
    function addProjectManager (address newManager) ifAuthorised ifGeneralPartner {
        projectManagers.push (newManager);
        
        AddedManager (newManager);
    }
    
    /// @dev This default fallback function is here just for clarification
    function () {
        throw;
    }
}
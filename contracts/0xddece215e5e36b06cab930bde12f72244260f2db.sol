pragma solidity ^0.4.25;

/*
                              (           (        )      )          (          
   (     (       *   )  *   ) )\ )        )\ )  ( /(   ( /(   (      )\ )       
 ( )\    )\    ` )  /(` )  /((()/(  (    (()/(  )\())  )\())  )\    (()/(  (    
 )((_)((((_)(   ( )(_))( )(_))/(_)) )\    /(_))((_)\  ((_)\((((_)(   /(_)) )\   
((_)_  )\ _ )\ (_(_())(_(_())(_))  ((_)  (_))    ((_)__ ((_))\ _ )\ (_))  ((_)  
 | _ ) (_)_\(_)|_   _||_   _|| |   | __| | _ \  / _ \\ \ / /(_)_\(_)| |   | __| 
 | _ \  / _ \    | |    | |  | |__ | _|  |   / | (_) |\ V /  / _ \  | |__ | _|  
 |___/ /_/ \_\   |_|    |_|  |____||___| |_|_\  \___/  |_|  /_/ \_\ |____||___| 

    Name Book implementation for ETH.TOWN Battle Royale
    https://eth.town/battle

    ETH.TOWN https://eth.town/
    © 2018 ETH.TOWN All rights reserved
*/

contract Owned {
    address owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @dev Contract constructor
    constructor() public {
        owner = msg.sender;
    }
}

contract Managed is Owned {
    mapping(address => bool) public isManager;

    modifier onlyManagers {
        require(msg.sender == owner || isManager[msg.sender], "Not authorized");
        _;
    }

    function setIsManager(address _address, bool _value) external onlyOwner {
        isManager[_address] = _value;
    }
}

contract BRNameBook is Managed {
    using SafeMath for uint256;

    address public feeRecipient = 0xFd6D4265443647C70f8D0D80356F3b22d596DA29; // Mainnet

    uint256 public registrationFee = 0.1 ether;             // price to register a name
    uint256 public numPlayers;                              // total number of players
    mapping (address => uint256) public playerIdByAddr;     // (addr => pID) returns player id by address
    mapping (bytes32 => uint256) public playerIdByName;     // (name => pID) returns player id by name
    mapping (uint256 => Player) public playerData;          // (pID => data) player data
    mapping (uint256 => mapping (bytes32 => bool)) public playerOwnsName; // (pID => name => bool) whether the player owns the name
    mapping (uint256 => mapping (uint256 => bytes32)) public playerNamesList; // (pID => nameNum => name) list of names a player owns

    struct Player {
        address addr;
        address loomAddr;
        bytes32 name;
        uint256 lastAffiliate;
        uint256 nameCount;
    }

    constructor() public {

    }

    /**
     * @dev prevents calls from contracts
     */
    modifier onlyHumans() {
        require(msg.sender == tx.origin, "Humans only");
        _;
    }

    event NameRegistered (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 amountPaid,
        uint256 timeStamp
    );

    function nameIsValid(string _nameStr) public view returns(bool) {
        bytes32 _name = _processName(_nameStr);
        return (playerIdByName[_name] == 0);
    }

    function setRegistrationFee(uint256 _newFee) onlyManagers() external {
        registrationFee = _newFee;
    }

    function setFeeRecipient(address _feeRecipient) onlyManagers() external {
        feeRecipient = _feeRecipient;
    }

    /**
     * @dev registers a name.  UI will always display the last name you registered.
     * but you will still own all previously registered names to use as affiliate
     * links.
     * - must pay a registration fee.
     * - name must be unique
     * - names will be converted to lowercase
     * - name cannot start or end with a space
     * - cannot have more than 1 space in a row
     * - cannot be only numbers
     * - cannot start with 0x
     * - name must be at least 1 char
     * - max length of 32 characters long
     * - allowed characters: a-z, 0-9, and space
     * -functionhash- 0x921dec21 (using ID for affiliate)
     * -functionhash- 0x3ddd4698 (using address for affiliate)
     * -functionhash- 0x685ffd83 (using name for affiliate)
     * @param _nameString players desired name
     * @param _affCode affiliate ID, address, or name of who refered you
     * (this might cost a lot of gas)
     */
    function registerNameAffId(string _nameString, uint256 _affCode) onlyHumans() external payable {
        // make sure name fees paid
        require (msg.value >= registrationFee, "Value below the fee");

        // filter name + condition checks
        bytes32 name = _processName(_nameString);

        // set up address
        address addr = msg.sender;

        // set up our tx event data and determine if player is new or not
        bool isNewPlayer = _determinePlayerId(addr);

        // fetch player id
        uint256 playerId = playerIdByAddr[addr];

        // manage affiliate residuals
        // if no affiliate code was given, no new affiliate code was given, or the
        // player tried to use their own pID as an affiliate code, lolz
        uint256 affiliateId = _affCode;
        if (affiliateId != 0 && affiliateId != playerData[playerId].lastAffiliate && affiliateId != playerId) {
            // update last affiliate
            playerData[playerId].lastAffiliate = affiliateId;
        } else if (_affCode == playerId) {
            affiliateId = 0;
        }

        // register name
        _registerName(playerId, addr, affiliateId, name, isNewPlayer);
    }

    function registerNameAffAddress(string _nameString, address _affCode) onlyHumans() external payable {
        // make sure name fees paid
        require (msg.value >= registrationFee, "Value below the fee");

        // filter name + condition checks
        bytes32 name = _processName(_nameString);

        // set up address
        address addr = msg.sender;

        // set up our tx event data and determine if player is new or not
        bool isNewPlayer = _determinePlayerId(addr);

        // fetch player id
        uint256 playerId = playerIdByAddr[addr];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        uint256 affiliateId;
        if (_affCode != address(0) && _affCode != addr) {
            // get affiliate ID from aff Code
            affiliateId = playerIdByAddr[_affCode];

            // if affID is not the same as previously stored
            if (affiliateId != playerData[playerId].lastAffiliate) {
                // update last affiliate
                playerData[playerId].lastAffiliate = affiliateId;
            }
        }

        // register name
        _registerName(playerId, addr, affiliateId, name, isNewPlayer);
    }

    function registerNameAffName(string _nameString, bytes32 _affCode) onlyHumans() public payable {
        // make sure name fees paid
        require (msg.value >= registrationFee, "Value below the fee");

        // filter name + condition checks
        bytes32 name = _processName(_nameString);

        // set up address
        address addr = msg.sender;

        // set up our tx event data and determine if player is new or not
        bool isNewPlayer = _determinePlayerId(addr);

        // fetch player id
        uint256 playerId = playerIdByAddr[addr];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        uint256 affiliateId;
        if (_affCode != "" && _affCode != name) {
            // get affiliate ID from aff Code
            affiliateId = playerIdByName[_affCode];

            // if affID is not the same as previously stored
            if (affiliateId != playerData[playerId].lastAffiliate) {
                // update last affiliate
                playerData[playerId].lastAffiliate = affiliateId;
            }
        }

        // register the name
        _registerName(playerId, addr, affiliateId, name, isNewPlayer);
    }

    /**
     * @dev players use this to change back to one of your old names.  tip, you'll
     * still need to push that info to existing games.
     * -functionhash- 0xb9291296
     * @param _nameString the name you want to use
     */
    function useMyOldName(string _nameString) onlyHumans() public {
        // filter name, and get pID
        bytes32 name = _processName(_nameString);
        uint256 playerId = playerIdByAddr[msg.sender];

        // make sure they own the name
        require(playerOwnsName[playerId][name] == true, "Not your name");

        // update their current name
        playerData[playerId].name = name;
    }


    function _registerName(uint256 _playerId, address _addr, uint256 _affID, bytes32 _name, bool _isNewPlayer) internal {
        // if names already has been used, require that current msg sender owns the name
        if (playerIdByName[_name] != 0) {
            require(playerOwnsName[_playerId][_name] == true, "Name already taken");
        }

        // add name to player profile, registry, and name book
        playerData[_playerId].name = _name;
        playerIdByName[_name] = _playerId;
        if (playerOwnsName[_playerId][_name] == false) {
            playerOwnsName[_playerId][_name] = true;
            playerData[_playerId].nameCount++;
            playerNamesList[_playerId][playerData[_playerId].nameCount] = _name;
        }

        // process the registration fee
        uint256 total = address(this).balance;
        uint256 devDirect = total.mul(375).div(1000);
        owner.call.value(devDirect)();
        feeRecipient.call.value(total.sub(devDirect))();

        // fire event
        emit NameRegistered(_playerId, _addr, _name, _isNewPlayer, _affID, playerData[_affID].addr, playerData[_affID].name, msg.value, now);
    }

    function _determinePlayerId(address _addr) internal returns (bool) {
        if (playerIdByAddr[_addr] == 0)
        {
            numPlayers++;
            playerIdByAddr[_addr] = numPlayers;
            playerData[numPlayers].addr = _addr;

            // set the new player bool to true
            return true;
        } else {
            return false;
        }
    }

    function _processName(string _input) internal pure returns (bytes32) {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        //sorry limited to 32 characters
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        // create a bool to track if we have a non number character
        bool _hasNonNumber;

        // convert & check
        for (uint256 i = 0; i < _length; i++)
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                _temp[i] = byte(uint(_temp[i]) + 32);

                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                // require character is a space
                    _temp[i] == 0x20 ||
                // OR lowercase a-z
                (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                // or 0-9
                (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }

    function registerNameAffIdExternal(address _addr, bytes32 _name, uint256 _affCode)
    onlyManagers()
    external
    payable
    returns (bool, uint256)
    {
        // make sure name fees paid
        require (msg.value >= registrationFee, "Value below the fee");

        // set up our tx event data and determine if player is new or not
        bool isNewPlayer = _determinePlayerId(_addr);

        // fetch player id
        uint256 playerId = playerIdByAddr[_addr];

        // manage affiliate residuals
        // if no affiliate code was given, no new affiliate code was given, or the
        // player tried to use their own pID as an affiliate code, lolz
        uint256 affiliateId = _affCode;
        if (affiliateId != 0 && affiliateId != playerData[playerId].lastAffiliate && affiliateId != playerId) {
            // update last affiliate
            playerData[playerId].lastAffiliate = affiliateId;
        } else if (affiliateId == playerId) {
            affiliateId = 0;
        }

        // register name
        _registerName(playerId, _addr, affiliateId, _name, isNewPlayer);

        return (isNewPlayer, affiliateId);
    }

    function registerNameAffAddressExternal(address _addr, bytes32 _name, address _affCode)
    onlyManagers()
    external
    payable
    returns (bool, uint256)
    {
        // make sure name fees paid
        require (msg.value >= registrationFee, "Value below the fee");

        // set up our tx event data and determine if player is new or not
        bool isNewPlayer = _determinePlayerId(_addr);

        // fetch player id
        uint256 playerId = playerIdByAddr[_addr];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        uint256 affiliateId;
        if (_affCode != address(0) && _affCode != _addr)
        {
            // get affiliate ID from aff Code
            affiliateId = playerIdByAddr[_affCode];

            // if affID is not the same as previously stored
            if (affiliateId != playerData[playerId].lastAffiliate) {
                // update last affiliate
                playerData[playerId].lastAffiliate = affiliateId;
            }
        }

        // register name
        _registerName(playerId, _addr, affiliateId, _name, isNewPlayer);

        return (isNewPlayer, affiliateId);
    }

    function registerNameAffNameExternal(address _addr, bytes32 _name, bytes32 _affCode)
    onlyManagers()
    external
    payable
    returns (bool, uint256)
    {
        // make sure name fees paid
        require (msg.value >= registrationFee, "Value below the fee");

        // set up our tx event data and determine if player is new or not
        bool isNewPlayer = _determinePlayerId(_addr);

        // fetch player id
        uint256 playerId = playerIdByAddr[_addr];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        uint256 affiliateId;
        if (_affCode != "" && _affCode != _name)
        {
            // get affiliate ID from aff Code
            affiliateId = playerIdByName[_affCode];

            // if affID is not the same as previously stored
            if (affiliateId != playerData[playerId].lastAffiliate) {
                // update last affiliate
                playerData[playerId].lastAffiliate = affiliateId;
            }
        }

        // register name
        _registerName(playerId, _addr, affiliateId, _name, isNewPlayer);

        return (isNewPlayer, affiliateId);
    }

    function assignPlayerID(address _addr) onlyManagers() external returns (uint256) {
        _determinePlayerId(_addr);
        return playerIdByAddr[_addr];
    }

    function getPlayerID(address _addr) public view returns (uint256) {
        return playerIdByAddr[_addr];
    }

    function getPlayerName(uint256 _pID) public view returns (bytes32) {
        return playerData[_pID].name;
    }

    function getPlayerNameCount(uint256 _pID) public view returns (uint256) {
        return playerData[_pID].nameCount;
    }

    function getPlayerLastAffiliate(uint256 _pID) public view returns (uint256) {
        return playerData[_pID].lastAffiliate;
    }

    function getPlayerAddr(uint256 _pID) public view returns (address) {
        return playerData[_pID].addr;
    }

    function getPlayerLoomAddr(uint256 _pID) public view returns (address) {
        return playerData[_pID].loomAddr;
    }

    function getPlayerLoomAddrByAddr(address _addr) public view returns (address) {
        uint256 playerId = playerIdByAddr[_addr];
        if (playerId == 0) {
            return 0;
        }

        return playerData[playerId].loomAddr;
    }

    function getPlayerNames(uint256 _pID) public view returns (bytes32[]) {
        uint256 nameCount = playerData[_pID].nameCount;

        bytes32[] memory names = new bytes32[](nameCount);

        uint256 i;
        for (i = 1; i <= nameCount; i++) {
            names[i - 1] = playerNamesList[_pID][i];
        }

        return names;
    }

    function setPlayerLoomAddr(uint256 _pID, address _addr, bool _allowOverwrite) onlyManagers() external {
        require(_allowOverwrite || playerData[_pID].loomAddr == 0x0);

        playerData[_pID].loomAddr = _addr;
    }

}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
    * @dev Divides two numbers, never throws.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x) internal pure returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x) internal pure returns (uint256)
    {
        return mul(x,x);
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y) internal pure returns (uint256)
    {
        if (x==0) {
            return 0;
        } else if (y==0) {
            return 1;
        } else {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return z;
        }
    }
}
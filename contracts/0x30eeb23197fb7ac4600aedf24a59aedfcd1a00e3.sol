/* ==================================================================== */
/* Copyright (c) 2018 The CryptoRacing Project.  All rights reserved.
/* 
/*   The first idle car race game of blockchain                 
/* ==================================================================== */
pragma solidity ^0.4.20;

/// @title ERC-165 Standard Interface Detection
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
contract ERC721 is ERC165 {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function approve(address _approved, uint256 _tokenId) external;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

/// @title ERC-721 Non-Fungible Token Standard
interface ERC721TokenReceiver {
	function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4);
}

contract AccessAdmin {
    bool public isPaused = false;
    address public addrAdmin;  

    event AdminTransferred(address indexed preAdmin, address indexed newAdmin);

    function AccessAdmin() public {
        addrAdmin = msg.sender;
    }  


    modifier onlyAdmin() {
        require(msg.sender == addrAdmin);
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused);
        _;
    }

    modifier whenPaused {
        require(isPaused);
        _;
    }

    function setAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0));
        AdminTransferred(addrAdmin, _newAdmin);
        addrAdmin = _newAdmin;
    }

    function doPause() external onlyAdmin whenNotPaused {
        isPaused = true;
    }

    function doUnpause() external onlyAdmin whenPaused {
        isPaused = false;
    }
}


contract AccessService is AccessAdmin {
    address public addrService;
    address public addrFinance;

    modifier onlyService() {
        require(msg.sender == addrService);
        _;
    }

    modifier onlyFinance() {
        require(msg.sender == addrFinance);
        _;
    }

    function setService(address _newService) external {
        require(msg.sender == addrService || msg.sender == addrAdmin);
        require(_newService != address(0));
        addrService = _newService;
    }

    function setFinance(address _newFinance) external {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_newFinance != address(0));
        addrFinance = _newFinance;
    }
}





/* ==================================================================== */
/* equipmentId 
/* 10001	T1
/* 10002	T2
/* 10003	T3
/* 10004	T4
/* 10005	T5
/* 10006	T6 
/* 10007	freeCar          
/* ==================================================================== */

contract RaceToken is ERC721, AccessAdmin {
    /// @dev The equipment info
    struct Fashion {
        uint16 equipmentId;             // 0  Equipment ID
        uint16 quality;     	        // 1  Rarity: 1 Coarse/2 Good/3 Rare/4 Epic/5 Legendary
        uint16 pos;         	        // 2  Slots: 1 Engine/2 Turbine/3 BodySystem/4 Pipe/5 Suspension/6 NO2/7 Tyre/8 Transmission/9 Car
        uint16 production;    	        // 3  Race bonus productivity
        uint16 attack;	                // 4  Attack
        uint16 defense;                 // 5  Defense
        uint16 plunder;     	        // 6  Plunder
        uint16 productionMultiplier;    // 7  Percent value
        uint16 attackMultiplier;     	// 8  Percent value
        uint16 defenseMultiplier;     	// 9  Percent value
        uint16 plunderMultiplier;     	// 10 Percent value
        uint16 level;       	        // 11 level
        uint16 isPercent;   	        // 12  Percent value
    }

    /// @dev All equipments tokenArray (not exceeding 2^32-1)
    Fashion[] public fashionArray;

    /// @dev Amount of tokens destroyed
    uint256 destroyFashionCount;

    /// @dev Equipment token ID belong to owner address
    mapping (uint256 => address) fashionIdToOwner;

    /// @dev Equipments owner by the owner (array)
    mapping (address => uint256[]) ownerToFashionArray;

    /// @dev Equipment token ID search in owner array
    mapping (uint256 => uint256) fashionIdToOwnerIndex;

    /// @dev The authorized address for each Race
    mapping (uint256 => address) fashionIdToApprovals;

    /// @dev The authorized operators for each address
    mapping (address => mapping (address => bool)) operatorToApprovals;

    /// @dev Trust contract
    mapping (address => bool) actionContracts;

	//设置可调用当前合约的其他合约
    function setActionContract(address _actionAddr, bool _useful) external onlyAdmin {
        actionContracts[_actionAddr] = _useful;
    }

    function getActionContract(address _actionAddr) external view onlyAdmin returns(bool) {
        return actionContracts[_actionAddr];
    }

    /// @dev This emits when the approved address for an Race is changed or reaffirmed.
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @dev This emits when the equipment ownership changed 
    event Transfer(address indexed from, address indexed to, uint256 tokenId);

    /// @dev This emits when the equipment created
    event CreateFashion(address indexed owner, uint256 tokenId, uint16 equipmentId, uint16 quality, uint16 pos, uint16 level, uint16 createType);

    /// @dev This emits when the equipment's attributes changed
    event ChangeFashion(address indexed owner, uint256 tokenId, uint16 changeType);

    /// @dev This emits when the equipment destroyed
    event DeleteFashion(address indexed owner, uint256 tokenId, uint16 deleteType);
    
    function RaceToken() public {
        addrAdmin = msg.sender;
        fashionArray.length += 1;
    }

    // modifier
    /// @dev Check if token ID is valid
    modifier isValidToken(uint256 _tokenId) {
        require(_tokenId >= 1 && _tokenId <= fashionArray.length);
        require(fashionIdToOwner[_tokenId] != address(0)); 
        _;
    }

    modifier canTransfer(uint256 _tokenId) {
        address owner = fashionIdToOwner[_tokenId];
        require(msg.sender == owner || msg.sender == fashionIdToApprovals[_tokenId] || operatorToApprovals[owner][msg.sender]);
        _;
    }

    // ERC721
    function supportsInterface(bytes4 _interfaceId) external view returns(bool) {
        // ERC165 || ERC721 || ERC165^ERC721
        return (_interfaceId == 0x01ffc9a7 || _interfaceId == 0x80ac58cd || _interfaceId == 0x8153916a) && (_interfaceId != 0xffffffff);
    }
        
    function name() public pure returns(string) {
        return "Race Token";
    }

    function symbol() public pure returns(string) {
        return "Race";
    }

    /// @dev Search for token quantity address
    /// @param _owner Address that needs to be searched
    /// @return Returns token quantity
    function balanceOf(address _owner) external view returns(uint256) {
        require(_owner != address(0));
        return ownerToFashionArray[_owner].length;
    }

    /// @dev Find the owner of an Race
    /// @param _tokenId The tokenId of Race
    /// @return Give The address of the owner of this Race
    function ownerOf(uint256 _tokenId) external view /*isValidToken(_tokenId)*/ returns (address owner) {
        return fashionIdToOwner[_tokenId];
    }

    /// @dev Transfers the ownership of an Race from one address to another address
    /// @param _from The current owner of the Race
    /// @param _to The new owner
    /// @param _tokenId The Race to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) 
        external
        whenNotPaused
    {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    /// @dev Transfers the ownership of an Race from one address to another address
    /// @param _from The current owner of the Race
    /// @param _to The new owner
    /// @param _tokenId The Race to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) 
        external
        whenNotPaused
    {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    /// @dev Transfer ownership of an Race, '_to' must be a vaild address, or the Race will lost
    /// @param _from The current owner of the Race
    /// @param _to The new owner
    /// @param _tokenId The Race to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId)
        external
        whenNotPaused
        isValidToken(_tokenId)
        canTransfer(_tokenId)
    {
        address owner = fashionIdToOwner[_tokenId];
        require(owner != address(0));
        require(_to != address(0));
        require(owner == _from);
        
        _transfer(_from, _to, _tokenId);
    }

    /// @dev Set or reaffirm the approved address for an Race
    /// @param _approved The new approved Race controller
    /// @param _tokenId The Race to approve
    function approve(address _approved, uint256 _tokenId)
        external
        whenNotPaused
    {
        address owner = fashionIdToOwner[_tokenId];
        require(owner != address(0));
        require(msg.sender == owner || operatorToApprovals[owner][msg.sender]);

        fashionIdToApprovals[_tokenId] = _approved;
        Approval(owner, _approved, _tokenId);
    }

    /// @dev Enable or disable approval for a third party ("operator") to manage all your asset.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operators is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) 
        external 
        whenNotPaused
    {
        operatorToApprovals[msg.sender][_operator] = _approved;
        ApprovalForAll(msg.sender, _operator, _approved);
    }

    /// @dev Get the approved address for a single Race
    /// @param _tokenId The Race to find the approved address for
    /// @return The approved address for this Race, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view isValidToken(_tokenId) returns (address) {
        return fashionIdToApprovals[_tokenId];
    }

    /// @dev Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the Races
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorToApprovals[_owner][_operator];
    }

    /// @dev Count Races tracked by this contract
    /// @return A count of valid Races tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256) {
        return fashionArray.length - destroyFashionCount - 1;
    }

    /// @dev Do the real transfer with out any condition checking
    /// @param _from The old owner of this Race(If created: 0x0)
    /// @param _to The new owner of this Race 
    /// @param _tokenId The tokenId of the Race
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        if (_from != address(0)) {
            uint256 indexFrom = fashionIdToOwnerIndex[_tokenId];
            uint256[] storage fsArray = ownerToFashionArray[_from];
            require(fsArray[indexFrom] == _tokenId);

            // If the Race is not the element of array, change it to with the last
            if (indexFrom != fsArray.length - 1) {
                uint256 lastTokenId = fsArray[fsArray.length - 1];
                fsArray[indexFrom] = lastTokenId; 
                fashionIdToOwnerIndex[lastTokenId] = indexFrom;
            }
            fsArray.length -= 1; 
            
            if (fashionIdToApprovals[_tokenId] != address(0)) {
                delete fashionIdToApprovals[_tokenId];
            }      
        }

        // Give the Race to '_to'
        fashionIdToOwner[_tokenId] = _to;
        ownerToFashionArray[_to].push(_tokenId);
        fashionIdToOwnerIndex[_tokenId] = ownerToFashionArray[_to].length - 1;
        
        Transfer(_from != address(0) ? _from : this, _to, _tokenId);
    }

    /// @dev Actually perform the safeTransferFrom
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) 
        internal
        isValidToken(_tokenId) 
        canTransfer(_tokenId)
    {
        address owner = fashionIdToOwner[_tokenId];
        require(owner != address(0));
        require(_to != address(0));
        require(owner == _from);
        
        _transfer(_from, _to, _tokenId);

        // Do the callback after everything is done to avoid reentrancy attack
        uint256 codeSize;
        assembly { codeSize := extcodesize(_to) }
        if (codeSize == 0) {
            return;
        }
        bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(_from, _tokenId, data);
        // bytes4(keccak256("onERC721Received(address,uint256,bytes)")) = 0xf0b9e5ba;
        require(retval == 0xf0b9e5ba);
    }

    //----------------------------------------------------------------------------------------------------------

    /// @dev Equipment creation
    /// @param _owner Owner of the equipment created
    /// @param _attrs Attributes of the equipment created
    /// @return Token ID of the equipment created
    function createFashion(address _owner, uint16[13] _attrs, uint16 _createType) 
        external 
        whenNotPaused
        returns(uint256)
    {
        require(actionContracts[msg.sender]);
        require(_owner != address(0));

        uint256 newFashionId = fashionArray.length;
        require(newFashionId < 4294967296);

        fashionArray.length += 1;
        Fashion storage fs = fashionArray[newFashionId];
        fs.equipmentId = _attrs[0];
        fs.quality = _attrs[1];
        fs.pos = _attrs[2];
        if (_attrs[3] != 0) {
            fs.production = _attrs[3];
        }
        
        if (_attrs[4] != 0) {
            fs.attack = _attrs[4];
        }
		
		if (_attrs[5] != 0) {
            fs.defense = _attrs[5];
        }
       
        if (_attrs[6] != 0) {
            fs.plunder = _attrs[6];
        }
        
        if (_attrs[7] != 0) {
            fs.productionMultiplier = _attrs[7];
        }

        if (_attrs[8] != 0) {
            fs.attackMultiplier = _attrs[8];
        }

        if (_attrs[9] != 0) {
            fs.defenseMultiplier = _attrs[9];
        }

        if (_attrs[10] != 0) {
            fs.plunderMultiplier = _attrs[10];
        }

        if (_attrs[11] != 0) {
            fs.level = _attrs[11];
        }

        if (_attrs[12] != 0) {
            fs.isPercent = _attrs[12];
        }
        
        _transfer(0, _owner, newFashionId);
        CreateFashion(_owner, newFashionId, _attrs[0], _attrs[1], _attrs[2], _attrs[11], _createType);
        return newFashionId;
    }

    /// @dev One specific attribute of the equipment modified
    function _changeAttrByIndex(Fashion storage _fs, uint16 _index, uint16 _val) internal {
        if (_index == 3) {
            _fs.production = _val;
        } else if(_index == 4) {
            _fs.attack = _val;
        } else if(_index == 5) {
            _fs.defense = _val;
        } else if(_index == 6) {
            _fs.plunder = _val;
        }else if(_index == 7) {
            _fs.productionMultiplier = _val;
        }else if(_index == 8) {
            _fs.attackMultiplier = _val;
        }else if(_index == 9) {
            _fs.defenseMultiplier = _val;
        }else if(_index == 10) {
            _fs.plunderMultiplier = _val;
        } else if(_index == 11) {
            _fs.level = _val;
        } 
       
    }

    /// @dev Equiment attributes modified (max 4 stats modified)
    /// @param _tokenId Equipment Token ID
    /// @param _idxArray Stats order that must be modified
    /// @param _params Stat value that must be modified
    /// @param _changeType Modification type such as enhance, socket, etc.
    function changeFashionAttr(uint256 _tokenId, uint16[4] _idxArray, uint16[4] _params, uint16 _changeType) 
        external 
        whenNotPaused
        isValidToken(_tokenId) 
    {
        require(actionContracts[msg.sender]);

        Fashion storage fs = fashionArray[_tokenId];
        if (_idxArray[0] > 0) {
            _changeAttrByIndex(fs, _idxArray[0], _params[0]);
        }

        if (_idxArray[1] > 0) {
            _changeAttrByIndex(fs, _idxArray[1], _params[1]);
        }

        if (_idxArray[2] > 0) {
            _changeAttrByIndex(fs, _idxArray[2], _params[2]);
        }

        if (_idxArray[3] > 0) {
            _changeAttrByIndex(fs, _idxArray[3], _params[3]);
        }

        ChangeFashion(fashionIdToOwner[_tokenId], _tokenId, _changeType);
    }

    /// @dev Equipment destruction
    /// @param _tokenId Equipment Token ID
    /// @param _deleteType Destruction type, such as craft
    function destroyFashion(uint256 _tokenId, uint16 _deleteType)
        external 
        whenNotPaused
        isValidToken(_tokenId) 
    {
        require(actionContracts[msg.sender]);

        address _from = fashionIdToOwner[_tokenId];
        uint256 indexFrom = fashionIdToOwnerIndex[_tokenId];
        uint256[] storage fsArray = ownerToFashionArray[_from]; 
        require(fsArray[indexFrom] == _tokenId);

        if (indexFrom != fsArray.length - 1) {
            uint256 lastTokenId = fsArray[fsArray.length - 1];
            fsArray[indexFrom] = lastTokenId; 
            fashionIdToOwnerIndex[lastTokenId] = indexFrom;
        }
        fsArray.length -= 1; 

        fashionIdToOwner[_tokenId] = address(0);
        delete fashionIdToOwnerIndex[_tokenId];
        destroyFashionCount += 1;

        Transfer(_from, 0, _tokenId);

        DeleteFashion(_from, _tokenId, _deleteType);
    }

    /// @dev Safe transfer by trust contracts
    function safeTransferByContract(uint256 _tokenId, address _to) 
        external
        whenNotPaused
    {
        require(actionContracts[msg.sender]);

        require(_tokenId >= 1 && _tokenId <= fashionArray.length);
        address owner = fashionIdToOwner[_tokenId];
        require(owner != address(0));
        require(_to != address(0));
        require(owner != _to);

        _transfer(owner, _to, _tokenId);
    }

    //----------------------------------------------------------------------------------------------------------

	/// @dev Get fashion attrs by tokenId front
    function getFashionFront(uint256 _tokenId) external view isValidToken(_tokenId) returns (uint256[14] datas) {
        Fashion storage fs = fashionArray[_tokenId];
        datas[0] = fs.equipmentId;
        datas[1] = fs.quality;
        datas[2] = fs.pos;
        datas[3] = fs.production;
        datas[4] = fs.attack;
        datas[5] = fs.defense;
        datas[6] = fs.plunder;
        datas[7] = fs.productionMultiplier;
        datas[8] = fs.attackMultiplier;
        datas[9] = fs.defenseMultiplier;
        datas[10] = fs.plunderMultiplier;
        datas[11] = fs.level;
        datas[12] = fs.isPercent; 
        datas[13] = _tokenId;      
    }

    /// @dev Get fashion attrs by tokenId back
    function getFashion(uint256 _tokenId) external view isValidToken(_tokenId) returns (uint16[13] datas) {
        Fashion storage fs = fashionArray[_tokenId];
        datas[0] = fs.equipmentId;
        datas[1] = fs.quality;
        datas[2] = fs.pos;
        datas[3] = fs.production;
        datas[4] = fs.attack;
        datas[5] = fs.defense;
        datas[6] = fs.plunder;
        datas[7] = fs.productionMultiplier;
        datas[8] = fs.attackMultiplier;
        datas[9] = fs.defenseMultiplier;
        datas[10] = fs.plunderMultiplier;
        datas[11] = fs.level;
        datas[12] = fs.isPercent;      
    }


    /// @dev Get tokenIds and flags by owner
    function getOwnFashions(address _owner) external view returns(uint256[] tokens, uint32[] flags) {
        require(_owner != address(0));
        uint256[] storage fsArray = ownerToFashionArray[_owner];
        uint256 length = fsArray.length;
        tokens = new uint256[](length);
        flags = new uint32[](length);
        for (uint256 i = 0; i < length; ++i) {
            tokens[i] = fsArray[i];
            Fashion storage fs = fashionArray[fsArray[i]];
            flags[i] = uint32(uint32(fs.equipmentId) * 10000 + uint32(fs.quality) * 100 + fs.pos);
        }
    }


    /// @dev Race token info returned based on Token ID transfered (64 at most)
    function getFashionsAttrs(uint256[] _tokens) external view returns(uint256[] attrs) {
        uint256 length = _tokens.length;
        attrs = new uint256[](length * 14);
        uint256 tokenId;
        uint256 index;
        for (uint256 i = 0; i < length; ++i) {
            tokenId = _tokens[i];
            if (fashionIdToOwner[tokenId] != address(0)) {
                index = i * 14;
                Fashion storage fs = fashionArray[tokenId];
                attrs[index]     = fs.equipmentId;
				attrs[index + 1] = fs.quality;
                attrs[index + 2] = fs.pos;
                attrs[index + 3] = fs.production;
                attrs[index + 4] = fs.attack;
                attrs[index + 5] = fs.defense;
                attrs[index + 6] = fs.plunder;
                attrs[index + 7] = fs.productionMultiplier;
                attrs[index + 8] = fs.attackMultiplier;
                attrs[index + 9] = fs.defenseMultiplier;
                attrs[index + 10] = fs.plunderMultiplier;
                attrs[index + 11] = fs.level;
                attrs[index + 12] = fs.isPercent; 
                attrs[index + 13] = tokenId;  
            }   
        }
    }
}


//Tournament bonus interface
interface IRaceCoin {
    function addTotalEtherPool(uint256 amount) external;
    function addPlayerToList(address player) external;
    function increasePlayersAttribute(address player, uint16[13] param) external;
    function reducePlayersAttribute(address player, uint16[13] param) external;
}

contract CarsPresell is AccessService {

    using SafeMath for uint256;
    
    RaceToken tokenContract;

    IRaceCoin public raceCoinContract;

   
    //Bonus pool address
    address poolContract;

    ///Bonus pool ratio
    uint256 constant prizeGoldPercent = 80;

    //referer
    uint256 constant refererPercent = 5;

    //The maximum number of cars per quality
	uint16 private carCountsLimit;


   



    mapping (uint16 => uint16) carPresellCounter;
    mapping (address => uint16[]) presellLimit;

    mapping (address => uint16) freeCarCount;

    event CarPreSelled(address indexed buyer, uint16 equipmentId);
    event FreeCarsObtained(address indexed buyer, uint16 equipmentId);

    event PresellReferalGain(address referal, address player, uint256 amount);

    function CarsPresell(address _nftAddr) public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;

        tokenContract = RaceToken(_nftAddr);
		
		//Maximum number of vehicles per class
		carCountsLimit = 500;

        carPresellCounter[10001] = 100;
        carPresellCounter[10002] = 100;
        carPresellCounter[10003] = 100;
        carPresellCounter[10004] = 100;
        carPresellCounter[10005] = 100;
		carPresellCounter[10006] = 100;

    }

    function() external payable {

    }

    function setRaceTokenAddr(address _nftAddr) external onlyAdmin {
        tokenContract = RaceToken(_nftAddr);
    }

   
    //Set up tournament bonus address
    function setRaceCoin(address _addr) external onlyAdmin {
        require(_addr != address(0));
        poolContract = _addr;
        raceCoinContract = IRaceCoin(_addr);
    }
	
	
	//Increase the number of pre-sale cars, the maximum limit of each vehicle is 500 vehicles.
	function setCarCounts(uint16 _carId, uint16 _carCounts) external onlyAdmin {
		require( carPresellCounter[_carId] <= carCountsLimit);
		uint16 curSupply = carPresellCounter[_carId];
		require((curSupply + _carCounts)<= carCountsLimit);
        carPresellCounter[_carId] = curSupply + _carCounts;
    }


    //Get free cars
    function freeCar(uint16 _equipmentId)
        external
        payable
        whenNotPaused 
    {
        require(freeCarCount[msg.sender] != 1);

        uint256 payBack = 0;

        uint16[] storage buyArray = presellLimit[msg.sender];

        if(_equipmentId == 10007){
            require(msg.value >= 0.0 ether);
            payBack = (msg.value - 0.0 ether);
            uint16[13] memory param0 = [10007, 7, 9, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            tokenContract.createFashion(msg.sender, param0, 1);
            raceCoinContract.increasePlayersAttribute(msg.sender, param0);
            buyArray.push(10007);

            if (payBack > 0) {
                msg.sender.transfer(payBack);
            }

            freeCarCount[msg.sender] = 1;

            raceCoinContract.addPlayerToList(msg.sender);

            emit FreeCarsObtained(msg.sender,_equipmentId);
        }
    }

    //Whether a free car has been received.
    function getFreeCarCount(address _owner) external view returns(uint16){

        require(_owner != address(0));
        if(freeCarCount[msg.sender] != 1){
            freeCarCount[msg.sender] = 0;
        }

        return  freeCarCount[msg.sender];
    }



    function UpdateCurrentCarCount(uint16 _equipmentId,uint16 curSupply) internal {
        carPresellCounter[_equipmentId] = (curSupply - 1);
    }


    function carPresell(address referer,uint16 _equipmentId) 
        external
        payable
        whenNotPaused 
    {
        uint16 curSupply = carPresellCounter[_equipmentId];
        require(curSupply > 0);
        uint16[] storage buyArray = presellLimit[msg.sender];
        uint256 curBuyCnt = buyArray.length;
		
        require(curBuyCnt < 21);

        uint256 payBack = 0;
        if (_equipmentId == 10001) {
            require(msg.value >= 0.075 ether);
            payBack = (msg.value - 0.075 ether);
            uint16[13] memory param1 = [10001, 1, 9, 10, 0, 0, 0, 5, 0, 0, 0, 0, 0];       // 10 productivity 5% productivity plus
            tokenContract.createFashion(msg.sender, param1, 1);
            raceCoinContract.increasePlayersAttribute(msg.sender, param1);
            buyArray.push(10001);
            raceCoinContract.addPlayerToList(msg.sender);
        } else if(_equipmentId == 10002) {
            require(msg.value >= 0.112 ether);
            payBack = (msg.value - 0.112 ether);
            uint16[13] memory param2 = [10002, 2, 9, 15, 0, 0, 0, 8, 5, 0, 0, 0, 0];       // 15 productivity 8% productivity plus 5% attack bonus
            tokenContract.createFashion(msg.sender, param2, 1);
            raceCoinContract.increasePlayersAttribute(msg.sender, param2);
            buyArray.push(10002);
            raceCoinContract.addPlayerToList(msg.sender);
        } else if(_equipmentId == 10003) {
            require(msg.value >= 0.225 ether);
            payBack = (msg.value - 0.225 ether);
            uint16[13] memory param3 = [10003, 3, 9, 30, 0, 0, 0, 15, 10, 5, 0, 0, 0];        // 30 productivity 15% productivity plus 10% attack plus 5% defense plus
            tokenContract.createFashion(msg.sender, param3, 1);
            raceCoinContract.increasePlayersAttribute(msg.sender, param3);
            buyArray.push(10003);
            raceCoinContract.addPlayerToList(msg.sender);
        } else if(_equipmentId == 10004) {
            require(msg.value >= 0.563 ether);
            payBack = (msg.value - 0.563 ether);
            uint16[13] memory param4 = [10004, 4, 9, 75, 0, 0, 0, 38, 25, 13, 5, 0, 0];        // 75 productivity 38% productivity plus 25% attack plus 13% defense plus 5% predatory addition.
            tokenContract.createFashion(msg.sender, param4, 1);
            raceCoinContract.increasePlayersAttribute(msg.sender, param4);
            buyArray.push(10004);
            raceCoinContract.addPlayerToList(msg.sender);
        } else if(_equipmentId == 10005){
            require(msg.value >= 1.7 ether);
            payBack = (msg.value - 1.7 ether);
            uint16[13] memory param5 = [10005, 5, 9, 225, 0, 0, 0, 113, 75, 38, 15, 0, 0];      // 225 productivity 113% productivity plus 75% attack plus 38% defense plus 15% predatory addition.
            tokenContract.createFashion(msg.sender, param5, 1);
            raceCoinContract.increasePlayersAttribute(msg.sender, param5);
            buyArray.push(10005);
            raceCoinContract.addPlayerToList(msg.sender);
        }else if(_equipmentId == 10006){
            require(msg.value >= 6 ether);
            payBack = (msg.value - 6 ether);
            uint16[13] memory param6 = [10006, 6, 9, 788, 0, 0, 0, 394, 263, 131, 53, 0, 0];      // 788 productivity 394% productivity plus 263% attack plus 131% defense plus 53% predatory addition.
            tokenContract.createFashion(msg.sender, param6, 1);
            raceCoinContract.increasePlayersAttribute(msg.sender, param6);
            buyArray.push(10006);
            raceCoinContract.addPlayerToList(msg.sender);
        }

        UpdateCurrentCarCount(_equipmentId,curSupply);


        emit CarPreSelled(msg.sender, _equipmentId);



        uint256 ethVal = msg.value.sub(payBack);

        uint256 referalDivs;
        if (referer != address(0) && referer != msg.sender) {
            referalDivs = ethVal.mul(refererPercent).div(100); // 5%
            referer.transfer(referalDivs);
            emit PresellReferalGain(referer, msg.sender, referalDivs);
        }


        //Capital injection into capital pool
        if (poolContract != address(0) && ethVal.mul(prizeGoldPercent).div(100) > 0) {
            poolContract.transfer(ethVal.mul(prizeGoldPercent).div(100));
            raceCoinContract.addTotalEtherPool(ethVal.mul(prizeGoldPercent).div(100));
        }

        //The rest of the account is entered into the developer account.
        if(referalDivs > 0){
            addrFinance.transfer(ethVal.sub(ethVal.mul(prizeGoldPercent).div(100)).sub(ethVal.mul(refererPercent).div(100)));
        }else{
            addrFinance.transfer(ethVal.sub(ethVal.mul(prizeGoldPercent).div(100)));
        }
        

           
        if (payBack > 0) {
            msg.sender.transfer(payBack);
        }
    }

    function withdraw() 
        external 
    {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        addrFinance.transfer(this.balance);
    }

    function getCarCanPresellCount() external view returns (uint16[6] cntArray) {
        cntArray[0] = carPresellCounter[10001];
        cntArray[1] = carPresellCounter[10002];
        cntArray[2] = carPresellCounter[10003];
        cntArray[3] = carPresellCounter[10004];
        cntArray[4] = carPresellCounter[10005];
		cntArray[5] = carPresellCounter[10006];  		
    }

    function getBuyCount(address _owner) external view returns (uint32) {
        return uint32(presellLimit[_owner].length);
    }

    function getBuyArray(address _owner) external view returns (uint16[]) {
        uint16[] storage buyArray = presellLimit[_owner];
        return buyArray;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
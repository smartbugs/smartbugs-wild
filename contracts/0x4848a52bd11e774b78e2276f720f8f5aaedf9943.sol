pragma solidity ^0.4.24;

contract BasicAccessControl {
    address public owner;
    // address[] public moderators;
    uint16 public totalModerators = 0;
    mapping (address => bool) public moderators;
    bool public isMaintaining = false;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerators() {
        require(msg.sender == owner || moderators[msg.sender] == true);
        _;
    }

    modifier isActive {
        require(!isMaintaining);
        _;
    }

    function ChangeOwner(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }


    function AddModerator(address _newModerator) onlyOwner public {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            totalModerators += 1;
        }
    }
    
    function RemoveModerator(address _oldModerator) onlyOwner public {
        if (moderators[_oldModerator] == true) {
            moderators[_oldModerator] = false;
            totalModerators -= 1;
        }
    }

    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {
        isMaintaining = _isMaintaining;
    }
}

contract EMONTInterface {
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function transfer(address to, uint tokens) public;
}

contract CubegoCoreInterface {
    function buyMaterials(address _owner, uint _mId1, uint _amount1, uint _mId2, uint _amount2, 
                            uint _mId3, uint _amount3, uint _mId4, uint _amount4) external returns(uint);
    function addMaterials(address _owner, uint _mId1, uint _amount1, uint _mId2, uint _amount2, 
                            uint _mId3, uint _amount3, uint _mId4, uint _amount4) external;
    function removeMaterials(address _owner, uint _mId1, uint _amount1, uint _mId2, uint _amount2, 
                            uint _mId3, uint _amount3, uint _mId4, uint _amount4) external;
}

contract CubegonNFTInterface {
    function mineCubegon(address _owner, bytes32 _ch, uint _mId1, uint _amount1, uint _mId2, uint _amount2, 
        uint _mId3, uint _amount3, uint _mId4, uint _amount4, uint _energyLimit) external returns(uint);
    function updateCubegon(address _owner, uint _tokenId, uint _energyLimit) external;
    function dismantleCubegon(address _owner, uint _tokenId) external returns(uint mId1, uint amount1, uint mId2, uint amount2,
        uint mId3, uint amount3, uint mId4, uint amount4);
}

contract CubegonBuilder is BasicAccessControl {
    bytes constant SIG_PREFIX = "\x19Ethereum Signed Message:\n32";
    
    struct CubegonMaterial {
        uint mId1;
        uint amount1;
        uint mId2;
        uint amount2;
        uint mId3;
        uint amount3;
        uint mId4;
        uint amount4;
        uint energyLimit;
    }
    
    CubegoCoreInterface public cubegoCore;
    CubegonNFTInterface public cubegonNFT;
    EMONTInterface public emontToken;
    address public verifyAddress;
    mapping (uint => uint) public energyPrices;
    uint public ethEmontRate = 1500 * 10 ** 8; // each 10 ** 18 ETH
    
    function setAddress(address _cubegoCoreAddress, address _emontTokenAddress, address _cubegonNFTAddress, address _verifyAddress) onlyModerators external {
        cubegoCore = CubegoCoreInterface(_cubegoCoreAddress);
        emontToken = EMONTInterface(_emontTokenAddress);
        cubegonNFT = CubegonNFTInterface(_cubegonNFTAddress);
        verifyAddress = _verifyAddress;
    }
    
    function setEnergyPrice(uint _energy, uint _price) onlyModerators external {
        energyPrices[_energy] = _price;
    }
    
    function setConfig(uint _ethEmontRate) onlyModerators external {
        ethEmontRate = _ethEmontRate;
    }
    
    function withdrawEther(address _sendTo, uint _amount) onlyModerators public {
        if (_amount > address(this).balance) {
            revert();
        }
        _sendTo.transfer(_amount);
    }
    
    function withdrawToken(address _sendTo, uint _amount) onlyModerators external {
        if (_amount > emontToken.balanceOf(address(this))) {
            revert();
        }
        emontToken.transfer(_sendTo, _amount);
    }
    
    // emont payment
    function updateCubegonEnergyLimitByToken(address _owner, uint _tokens, uint _tokenId, uint _energyLimit) onlyModerators external {
        uint payAmount = energyPrices[_energyLimit];
        if (payAmount == 0) revert();
        uint payTokenAmount = payAmount * ethEmontRate / 10 ** 18;
        if (payTokenAmount > _tokens) revert();
        
        cubegonNFT.updateCubegon(_owner, _tokenId, _energyLimit);
    }
    
    // public 
    function extractMaterialToken(bytes32 _mt) public pure returns(uint mId1, uint amount1, uint mId2, uint amount2, 
        uint mId3, uint amount3, uint mId4, uint amount4) {
        amount4 = uint32(_mt);
        mId4 = uint32(_mt>>32);
        amount3 = uint32(_mt>>64);
        mId3 = uint32(_mt>>96);
        amount2 = uint32(_mt>>128);
        mId2 = uint32(_mt>>160);
        amount1 = uint32(_mt>>192);
        mId1 = uint32(_mt>>224);
    }
    
    function getVerifySignature(address sender, bytes32 _ch, bytes32 _cmt, bytes32 _tmt, uint _energyLimit, uint _expiryTime) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(sender, _ch, _cmt, _tmt, _energyLimit, _expiryTime));
    }
    
    function getVerifyAddress(address sender, bytes32 _ch, bytes32 _cmt, bytes32 _tmt, uint _energyLimit, uint _expiryTime, uint8 _v, bytes32 _r, bytes32 _s) public pure returns(address) {
        bytes32 hashValue = keccak256(abi.encodePacked(sender, _ch, _cmt, _tmt, _energyLimit, _expiryTime));
        bytes32 prefixedHash = keccak256(abi.encodePacked(SIG_PREFIX, hashValue));
        return ecrecover(prefixedHash, _v, _r, _s);
    }
    
    function createCubegon(bytes32 _ch, bytes32 _cmt, bytes32 _tmt, uint _energyLimit, uint _expiryTime, uint8 _v, bytes32 _r, bytes32 _s) isActive payable external {
        if (verifyAddress == address(0)) revert();
        if (_expiryTime < block.timestamp) revert();
        if (getVerifyAddress(msg.sender, _ch, _cmt, _tmt, _energyLimit, _expiryTime, _v, _r, _s) != verifyAddress) revert();
        uint payAmount = energyPrices[_energyLimit];
        if (payAmount == 0 || payAmount > msg.value) revert();
        
        CubegonMaterial memory cm;
        (cm.mId1, cm.amount1, cm.mId2, cm.amount2, cm.mId3, cm.amount3, cm.mId4, cm.amount4) = extractMaterialToken(_tmt);
        payAmount += cubegoCore.buyMaterials(msg.sender, cm.mId1, cm.amount1, cm.mId2, cm.amount2, cm.mId3, cm.amount3, cm.mId4, cm.amount4);
        if (payAmount > msg.value) revert();

        (cm.mId1, cm.amount1, cm.mId2, cm.amount2, cm.mId3, cm.amount3, cm.mId4, cm.amount4) = extractMaterialToken(_cmt);
        cubegoCore.removeMaterials(msg.sender, cm.mId1, cm.amount1, cm.mId2, cm.amount2, cm.mId3, cm.amount3, cm.mId4, cm.amount4);
        
        // refund extra
        if (msg.value > payAmount) {
            msg.sender.transfer((msg.value - payAmount));
        }
        
        cm.energyLimit = _energyLimit;
        cubegonNFT.mineCubegon(msg.sender, _ch, cm.mId1, cm.amount1, cm.mId2, cm.amount2, cm.mId3, cm.amount3, cm.mId4, cm.amount4, cm.energyLimit);
    }
    
    function dismantleCubegon(uint _tokenId) isActive external {
        CubegonMaterial memory cm;
        (cm.mId1, cm.amount1, cm.mId2, cm.amount2, cm.mId3, cm.amount3, cm.mId4, cm.amount4) = cubegonNFT.dismantleCubegon(msg.sender, _tokenId);
        cubegoCore.addMaterials(msg.sender, cm.mId1, cm.amount1, cm.mId2, cm.amount2, cm.mId3, cm.amount3, cm.mId4, cm.amount4);
    }
    
    function updateCubegonEnergyLimit(uint _tokenId, uint _energyLimit) isActive payable external {
        uint payAmount = energyPrices[_energyLimit];
        if (payAmount == 0) revert();
        if (msg.value < payAmount) revert();
        
        cubegonNFT.updateCubegon(msg.sender, _tokenId, _energyLimit);
        
    }
}
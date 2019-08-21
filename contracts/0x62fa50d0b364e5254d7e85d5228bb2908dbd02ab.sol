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

contract CubegoERC20 {
    function emitTransferEvent(address from, address to, uint tokens) external;
}

contract CubegoCore is BasicAccessControl {
    uint constant MAX_MATERIAL = 32;
    
    struct MaterialData {
        uint price;
        uint totalSupply;
        CubegoERC20 erc20;
    }
    
    MaterialData[MAX_MATERIAL] public materials;
    mapping(address => uint[MAX_MATERIAL]) public myMaterials;
    
    function setMaterialData(uint _mId, uint _price, address _erc20Address) onlyModerators external {
        MaterialData storage material = materials[_mId];
        material.price = _price;
        material.erc20 = CubegoERC20(_erc20Address);
    }
    
    function mineMaterial(address _owner, uint _mId, uint _amount) onlyModerators external {
        myMaterials[_owner][_mId] += _amount;
        MaterialData storage material = materials[_mId];
        material.totalSupply += _amount;
        material.erc20.emitTransferEvent(address(0), _owner, _amount);
    }
    
    function transferMaterial(address _sender, address _receiver, uint _mId, uint _amount) onlyModerators external {
        if (myMaterials[_sender][_mId] < _amount) revert();
        myMaterials[_sender][_mId] -= _amount;
        myMaterials[_receiver][_mId] += _amount;
        materials[_mId].erc20.emitTransferEvent(_sender, _receiver, _amount);
    }

    function buyMaterials(address _owner, uint _mId1, uint _amount1, uint _mId2, uint _amount2, 
                            uint _mId3, uint _amount3, uint _mId4, uint _amount4) onlyModerators external returns(uint) {
        uint totalPrice = 0;
        MaterialData storage material = materials[_mId1];
        
        if (_mId1 > 0) {
            if (material.price == 0) revert();
            myMaterials[_owner][_mId1] += _amount1;
            totalPrice += material.price * _amount1;
            material.totalSupply += _amount1;
            material.erc20.emitTransferEvent(address(0), _owner, _amount1);
        }
        if (_mId2 > 0) {
            material = materials[_mId2];
            if (material.price == 0) revert();
            myMaterials[_owner][_mId2] += _amount2;
            totalPrice += material.price * _amount2;
            material.totalSupply += _amount1;
            material.erc20.emitTransferEvent(address(0), _owner, _amount2);
        }
        if (_mId3 > 0) {
            material = materials[_mId3];
            if (material.price == 0) revert();
            myMaterials[_owner][_mId3] += _amount3;
            totalPrice += material.price * _amount3;
            material.totalSupply += _amount1;
            material.erc20.emitTransferEvent(address(0), _owner, _amount3);
        }
        if (_mId4 > 0) {
            material = materials[_mId3];
            if (material.price == 0) revert();
            myMaterials[_owner][_mId4] += _amount4;
            totalPrice += material.price * _amount4;
            material.totalSupply += _amount1;
            material.erc20.emitTransferEvent(address(0), _owner, _amount4);
        }
    
        return totalPrice;
    }
    
    // dismantle cubegon
    function addMaterials(address _owner, uint _mId1, uint _amount1, uint _mId2, uint _amount2, 
                            uint _mId3, uint _amount3, uint _mId4, uint _amount4) onlyModerators external {
        
        if (_mId1 > 0) {
            myMaterials[_owner][_mId1] += _amount1;
            materials[_mId1].erc20.emitTransferEvent(address(0), _owner, _amount1);
        }
        if (_mId2 > 0) {
            myMaterials[_owner][_mId2] += _amount2;
            materials[_mId2].erc20.emitTransferEvent(address(0), _owner, _amount2);
        }
        if (_mId3 > 0) {
            myMaterials[_owner][_mId3] += _amount3;
            materials[_mId3].erc20.emitTransferEvent(address(0), _owner, _amount3);
        }
        if (_mId4 > 0) {
            myMaterials[_owner][_mId4] += _amount4;
            materials[_mId4].erc20.emitTransferEvent(address(0), _owner, _amount4);
        }
    }
    
    function removeMaterials(address _owner, uint _mId1, uint _amount1, uint _mId2, uint _amount2, 
                            uint _mId3, uint _amount3, uint _mId4, uint _amount4) onlyModerators external {
        if (_mId1 > 0) {
            if (myMaterials[_owner][_mId1] < _amount1) revert();
            myMaterials[_owner][_mId1] -= _amount1;
            materials[_mId1].erc20.emitTransferEvent(_owner, address(0), _amount1);
        }
        if (_mId2 > 0) {
            if (myMaterials[_owner][_mId2] < _amount2) revert();
            myMaterials[_owner][_mId2] -= _amount2;
            materials[_mId2].erc20.emitTransferEvent(_owner, address(0), _amount2);
        }
        if (_mId3 > 0) {
            if (myMaterials[_owner][_mId3] < _amount3) revert();
            myMaterials[_owner][_mId3] -= _amount3;
            materials[_mId3].erc20.emitTransferEvent(_owner, address(0), _amount3);
        }
        if (_mId4 > 0) {
            if (myMaterials[_owner][_mId4] < _amount4) revert();
            myMaterials[_owner][_mId4] -= _amount4;
            materials[_mId4].erc20.emitTransferEvent(_owner, address(0), _amount4);
        }
    }
    
    
    // public function
    function getMaterialSupply(uint _mId) constant external returns(uint) {
        return materials[_mId].totalSupply;
    }
    
    function getMaterialData(uint _mId) constant external returns(uint price, uint totalSupply, address erc20Address) {
        MaterialData storage material = materials[_mId];
        return (material.price, material.totalSupply, address(material.erc20));
    }
    
    function getMyMaterials(address _owner) constant external returns(uint[MAX_MATERIAL]) {
        return myMaterials[_owner];
    }
    
    function getMyMaterialById(address _owner, uint _mId) constant external returns(uint) {
        return myMaterials[_owner][_mId];
    }
    
    function getMyMaterialsByIds(address _owner, uint _mId1, uint _mId2, uint _mId3, uint _mId4) constant external returns(
        uint, uint, uint, uint) {
        return (myMaterials[_owner][_mId1], myMaterials[_owner][_mId2], myMaterials[_owner][_mId3], myMaterials[_owner][_mId4]);    
    }
}
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
    function mineMaterial(address _owner, uint _mId, uint _amount) external;
}

contract CubegoPresale is BasicAccessControl {
    
    struct SinglePack {
        uint mId;
        uint amount;
        uint price;
    }
    
    struct UltimatePack {
        uint mId1;
        uint amount1;
        uint mId2;
        uint amount2;
        uint mId3;
        uint amount3;
        uint mId4;
        uint amount4;
        uint mId5;
        uint amount5;
        uint mId6;
        uint amount6;
        uint price;
    }
    
    mapping(uint => SinglePack) public singlePacks;
    mapping(uint => uint) public packQuantityFactor; // percentage
    UltimatePack public ultimatePack;
    CubegoCoreInterface public cubegoCore;
    EMONTInterface public emontToken;
    uint public discountFactor = 90; // percentage
    uint public ethEmontRate = 1500 * 10 ** 8; // each 10 ** 18 ETH
    
    function setAddress(address _cubegoCoreAddress, address _emontTokenAddress) onlyModerators external {
        cubegoCore = CubegoCoreInterface(_cubegoCoreAddress);
        emontToken = EMONTInterface(_emontTokenAddress);
    }
    
    function initConfig() onlyModerators external {
        singlePacks[1] = SinglePack(8, 120, 0.40 * 10 ** 18);
        singlePacks[2] = SinglePack(7, 125, 0.40 * 10 ** 18);
        singlePacks[3] = SinglePack(6, 125, 0.40 * 10 ** 18);

        singlePacks[4] = SinglePack(11, 40, 0.70 * 10 ** 18);
        singlePacks[5] = SinglePack(10, 45, 0.70 * 10 ** 18);
        singlePacks[6] = SinglePack(9, 45, 0.70 * 10 ** 18);
        
        ultimatePack.mId1 = 11;
        ultimatePack.amount1 = 16;
        ultimatePack.mId2 = 10;
        ultimatePack.amount2 = 18;
        ultimatePack.mId3 = 9;
        ultimatePack.amount3 = 18;
        ultimatePack.mId4 = 8;
        ultimatePack.amount4 = 48;
        ultimatePack.mId5 = 7;
        ultimatePack.amount5 = 50;
        ultimatePack.mId6 = 6;
        ultimatePack.amount6 = 50;
        ultimatePack.price = 1.25 * 10 ** 18;
        
        packQuantityFactor[1] = 100;
        packQuantityFactor[3] = 300;
        packQuantityFactor[6] = 570;
        packQuantityFactor[10] = 900;
        
        discountFactor = 90;
    }
    
    function setConfig(uint _discountFactor, uint _ethEmontRate) onlyModerators external {
        discountFactor = _discountFactor;
        ethEmontRate = _ethEmontRate;
    }
    
    function setSinglePack(uint _packId, uint _mId, uint _amount, uint _price) onlyModerators external {
        singlePacks[_packId] = SinglePack(_mId, _amount, _price);
    }
    
    function setUltimatePack(uint _mId1, uint _amount1, uint _mId2, uint _amount2, uint _mId3, uint _amount3,
        uint _mId4, uint _amount4, uint _mId5, uint _amount5, uint _mId6, uint _amount6, uint _price) onlyModerators external {
        ultimatePack.mId1 = _mId1;
        ultimatePack.amount1 = _amount1;
        
        ultimatePack.mId2 = _mId2;
        ultimatePack.amount2 = _amount2;
        
        ultimatePack.mId3 = _mId3;
        ultimatePack.amount3 = _amount3;
        
        ultimatePack.mId4 = _mId4;
        ultimatePack.amount4 = _amount4;
        
        ultimatePack.mId5 = _mId5;
        ultimatePack.amount5 = _amount5;
        
        ultimatePack.mId6 = _mId6;
        ultimatePack.amount6 = _amount6;
        
        ultimatePack.price = _price;
    }
    
    function setPackQuantityFactor(uint _quantity, uint _priceFactor) onlyModerators external {
        packQuantityFactor[_quantity] = _priceFactor;
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
    
    function buySinglePackByToken(address _buyer, uint _tokens, uint _packId, uint _amount) onlyModerators external{
        uint packFactor = packQuantityFactor[_amount];
        if (packFactor == 0) revert();
        SinglePack memory pack = singlePacks[_packId];
        if (pack.price == 0) revert();
        
        uint payAmount = (pack.price * packFactor * discountFactor) / 10000;
        uint payTokenAmount = payAmount * ethEmontRate / 10 ** 18;
        if (_tokens < payTokenAmount) revert();
        
        cubegoCore.mineMaterial(_buyer, pack.mId, pack.amount * _amount);
        
    }
    
    function buyUltimatePackByToken(address _buyer, uint _tokens, uint _amount) onlyModerators external {
        uint packFactor = packQuantityFactor[_amount];
        if (packFactor == 0) revert();
        
        uint payAmount = (ultimatePack.price * packFactor * discountFactor) / 10000;
        uint payTokenAmount = payAmount * ethEmontRate / 10 ** 18;
        if (_tokens < payTokenAmount) revert();
        
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId1, ultimatePack.amount1 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId2, ultimatePack.amount2 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId3, ultimatePack.amount3 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId4, ultimatePack.amount4 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId5, ultimatePack.amount5 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId6, ultimatePack.amount6 * _amount);
    }

    // public

    function getSinglePack(uint _packId) constant external returns(uint _mId, uint _amount, uint _price) {
        SinglePack memory pack = singlePacks[_packId];
        return (pack.mId, pack.amount, pack.price);
    }
    
    function getUltimatePack() constant external returns(uint _mId1, uint _amount1, uint _mId2, uint _amount2, uint _mId3, 
        uint _amount3, uint _mId4, uint _amount4, uint _mId5, uint _amount5, uint _mId6, uint _amount6, uint _price) {
        return (ultimatePack.mId1, ultimatePack.amount1, ultimatePack.mId2, ultimatePack.amount2, ultimatePack.mId3, ultimatePack.amount3, 
            ultimatePack.mId4, ultimatePack.amount4, ultimatePack.mId5, ultimatePack.amount5,
            ultimatePack.mId6, ultimatePack.amount6, ultimatePack.price);
    }
    
    function getSinglePackPrice(uint _packId, uint _amount) constant external returns(uint ethPrice, uint emontPrice) {
        ethPrice = (singlePacks[_packId].price * packQuantityFactor[_amount] * discountFactor) / 10000;
        emontPrice = ethPrice * ethEmontRate / 10 ** 18;
    }
    
    function getUltimatePackPrice(uint _amount) constant external returns(uint ethPrice, uint emontPrice) {
        ethPrice = (ultimatePack.price * packQuantityFactor[_amount] * discountFactor) / 10000;
        emontPrice = ethPrice * ethEmontRate / 10 ** 18;
    }
    
    function buySinglePackFor(address _buyer, uint _packId, uint _amount) isActive payable public {
        uint packFactor = packQuantityFactor[_amount];
        if (packFactor == 0) revert();
        SinglePack memory pack = singlePacks[_packId];
        if (pack.price == 0) revert();
        
        uint payAmount = (pack.price * packFactor * discountFactor) / 10000;
        if (payAmount > msg.value) revert();
        
        cubegoCore.mineMaterial(_buyer, pack.mId, pack.amount * _amount);
    }
    
    function buyUltimatePackFor(address _buyer, uint _amount) isActive payable public {
        uint packFactor = packQuantityFactor[_amount];
        if (packFactor == 0) revert();
        
        uint payAmount = (ultimatePack.price * packFactor * discountFactor) / 10000;
        if (payAmount > msg.value) revert();
        
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId1, ultimatePack.amount1 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId2, ultimatePack.amount2 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId3, ultimatePack.amount3 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId4, ultimatePack.amount4 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId5, ultimatePack.amount5 * _amount);
        cubegoCore.mineMaterial(_buyer, ultimatePack.mId6, ultimatePack.amount6 * _amount);
    }
    
    function buySinglePack(uint _packId, uint _amount) isActive payable external {
        buySinglePackFor(msg.sender, _packId, _amount);
    }
    
    function buyUltimatePack(uint _amount) isActive payable external {
        buyUltimatePackFor(msg.sender, _amount);
    }
    
}
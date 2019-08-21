/* ==================================================================== */
/* Copyright (c) 2018 The CryptoRacing Project.  All rights reserved.
/* 
/*   The first idle car race game of blockchain                 
/* ==================================================================== */

pragma solidity ^0.4.20;

contract AccessAdmin {
    bool public isPaused = false;
    address public addrAdmin;  

    event AdminTransferred(address indexed preAdmin, address indexed newAdmin);

    constructor() public {
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
        emit AdminTransferred(addrAdmin, _newAdmin);
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

    function withdraw(address _target, uint256 _amount) 
        external 
    {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_amount > 0);
        address receiver = _target == address(0) ? addrFinance : _target;
        uint256 balance = this.balance;
        if (_amount < balance) {
            receiver.transfer(_amount);
        } else {
            receiver.transfer(this.balance);
        }      
    }
}

interface IDataMining {
    function subFreeMineral(address _target) external returns(bool);
}

interface IDataEquip {
    function isEquiped(address _target, uint256 _tokenId) external view returns(bool);
    function isEquipedAny2(address _target, uint256 _tokenId1, uint256 _tokenId2) external view returns(bool);
    function isEquipedAny3(address _target, uint256 _tokenId1, uint256 _tokenId2, uint256 _tokenId3) external view returns(bool);
}

contract DataMiningController is AccessService, IDataMining {
    event FreeMineralChange(address indexed _target, uint32 _accCnt);


    /// @dev Free mining count map
    mapping (address => uint32) freeMineral;
    /// @dev Trust contract
    mapping (address => bool) actionContracts;

    constructor() public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;
    }

   
    function addFreeMineral(address _target, uint32 _cnt)  
        external
        onlyService
    {
        require(_target != address(0));
        require(_cnt <= 32);
        uint32 oldCnt = freeMineral[_target];
        freeMineral[_target] = oldCnt + _cnt;
        emit FreeMineralChange(_target, freeMineral[_target]);
    }

    function addFreeMineralMulti(address[] _targets, uint32[] _cnts)
        external
        onlyService
    {
        uint256 targetLength = _targets.length;
        require(targetLength <= 64);
        require(targetLength == _cnts.length);
        address addrZero = address(0);
        uint32 oldCnt;
        uint32 newCnt;
        address addr;
        for (uint256 i = 0; i < targetLength; ++i) {
            addr = _targets[i];
            if (addr != addrZero && _cnts[i] <= 32) {
                oldCnt = freeMineral[addr];
                newCnt = oldCnt + _cnts[i];
                assert(oldCnt < newCnt);
                freeMineral[addr] = newCnt;
                emit FreeMineralChange(addr, freeMineral[addr]);
            }
        }
    }

    function setActionContract(address _actionAddr, bool _useful) external onlyAdmin {
        actionContracts[_actionAddr] = _useful;
    }

    function getActionContract(address _actionAddr) external view onlyAdmin returns(bool) {
        return actionContracts[_actionAddr];
    }

    function subFreeMineral(address _target) external returns(bool) {
        require(actionContracts[msg.sender]);
        require(_target != address(0));
        uint32 cnts = freeMineral[_target];
        assert(cnts > 0);
        freeMineral[_target] = cnts - 1;
        emit FreeMineralChange(_target, cnts - 1);
        return true;
    }

    function getFreeMineral(address _target) external view returns(uint32) {
        return freeMineral[_target];
    }
}
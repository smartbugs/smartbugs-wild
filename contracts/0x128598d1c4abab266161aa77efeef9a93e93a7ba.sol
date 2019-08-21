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

contract CubegoPresale {
    function buySinglePackByToken(address _buyer, uint _tokens, uint _packId, uint _amount) external;
    function buyUltimatePackByToken(address _buyer, uint _tokens, uint _amount) external;
}

contract CubegonNFT {
    function updateCubegonEnergyLimitByToken(address _owner, uint _tokens, uint _tokenId, uint _energyLimit) external;
}

contract CubegoEmontPayment is BasicAccessControl {
    
    CubegoPresale public cubegoPresale;
    CubegonNFT public cubegoNFT;
    
    enum PayServiceType {
        NONE,
        PRESALE_SINGLE_PACK,
        PRESALE_ULTIMATE_PACK,
        CUBEGON_UPDATE_ENERGY
    }
    
    function setContract(address _cubegoPresale, address _cubegoNFT) onlyModerators external {
        cubegoPresale = CubegoPresale(_cubegoPresale);
        cubegoNFT = CubegonNFT(_cubegoNFT);
    } 
    
    function payService(address _player, uint _tokens, uint _param1, uint _param2, uint64 _param3, uint64 _param4) onlyModerators external {
        if (_param1 == uint(PayServiceType.PRESALE_SINGLE_PACK)) {
            cubegoPresale.buySinglePackByToken(_player, _tokens, _param2, _param3);
        } else if (_param1 == uint(PayServiceType.PRESALE_ULTIMATE_PACK)) {
            cubegoPresale.buyUltimatePackByToken(_player, _tokens, _param2);
        } else if (_param1 == uint(PayServiceType.CUBEGON_UPDATE_ENERGY)) {
            cubegoNFT.updateCubegonEnergyLimitByToken(_player, _tokens, _param2, _param3);
        } else {
            revert();
        }
    }

}
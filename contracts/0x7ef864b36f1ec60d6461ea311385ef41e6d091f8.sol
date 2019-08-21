pragma solidity ^0.4.24;

library MathLib {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        assert(b <= a);
        c = a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0 || b == 0) {
            c = 0;
        } else {
            c = a * b;
            assert(c / a == b);
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a / b;
    }
}

interface IMultiOwnable {

    function owners() external view returns (address[]);
    function transferOwnership(address newOwner) external;
    function appointHeir(address heir) external;
    function succeedOwner(address owner) external;

    event OwnershipTransfer(address indexed owner, address indexed newOwner);
    event HeirAppointment(address indexed owner, address indexed heir);
    event OwnershipSuccession(address indexed owner, address indexed heir);
}


library AddressLib {

    using AddressLib for AddressLib.Set;

    function isEmpty(address value) internal pure returns (bool) {
        return value == address(0);
    }

    function isSender(address value) internal view returns (bool) {
        return value == msg.sender;
    }

    struct Set {
        address[] vals;
        mapping(address => uint256) seqs;
    }

    function values(Set storage set) internal view returns (address[]) {
        return set.vals;
    }

    function count(Set storage set) internal view returns (uint256) {
        return set.vals.length;
    }

    function first(Set storage set) internal view returns (address) {
        require(set.count() > 0, "Set cannot be empty");

        return set.vals[0];
    }

    function last(Set storage set) internal view returns (address) {
        require(set.count() > 0, "Set cannot be empty");

        return set.vals[set.vals.length - 1];
    }

    function contains(Set storage set, address value) internal view returns (bool) {
        return set.seqs[value] > 0;
    }

    function add(Set storage set, address value) internal {
        if (!set.contains(value)) {
            set.seqs[value] = set.vals.push(value);
        }
    }

    function remove(Set storage set, address value) internal {
        if (set.contains(value)) {
            uint256 seq = set.seqs[value];

            if (seq < set.count()) {
                address lastVal = set.last();

                set.vals[seq - 1] = lastVal;
                set.seqs[lastVal] = seq;
            }

            set.vals.length--;
            set.seqs[value] = 0;
        }
    }
}


contract MultiOwnable is IMultiOwnable {

    using AddressLib for address;
    using AddressLib for AddressLib.Set;

    AddressLib.Set private _owners;
    mapping(address => address) private _heirs;

    modifier onlyOwner {
        require(_owners.contains(msg.sender), "Only allowed for a owner");
        _;
    }

    constructor (address[] owners) internal {
        for (uint256 i = 0; i < owners.length; i++) {
            _owners.add(owners[i]);
        }
    }

    function owners() external view returns (address[]) {
        return _owners.values();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(msg.sender, newOwner);

        emit OwnershipTransfer(msg.sender, newOwner);
    }

    function appointHeir(address heir) external onlyOwner {
        _heirs[msg.sender] = heir;

        emit HeirAppointment(msg.sender, heir);
    }

    function succeedOwner(address owner) external {
        require(_heirs[owner].isSender(), "Only heir may succeed owner");

        _transferOwnership(owner, msg.sender);
        
        emit OwnershipSuccession(owner, msg.sender);
    }

    function _transferOwnership(address owner, address newOwner) private {
        _owners.remove(owner);
        _owners.add(newOwner);
        _heirs[owner] = address(0);
    }
}


contract Geo {

    enum Class { District, Zone, Target }
    enum Status { Locked, Unlocked, Owned }

    struct Area {
        Class class;
        Status status;
        uint256 parent;
        uint256[] siblings;
        uint256[] children;
        address owner;
        uint256 cost;
        uint256 unlockTime;
    }

    mapping(uint256 => Area) internal areas;

    constructor () internal { }

    function initAreas() internal {
        areas[0].class = Class.Target;

        areas[1].class = Class.District;
        areas[1].parent = 46;
        areas[1].siblings = [2,3];
        areas[2].class = Class.District;
        areas[2].parent = 46;
        areas[2].siblings = [1,3];
        areas[3].class = Class.District;
        areas[3].parent = 46;
        areas[3].siblings = [1,2,4,6,8,9,11,13];
        areas[4].class = Class.District;
        areas[4].parent = 46;
        areas[4].siblings = [3,5,6,9];
        areas[5].class = Class.District;
        areas[5].parent = 46;
        areas[5].siblings = [4,6,7,9,37,38,39,41];
        areas[6].class = Class.District;
        areas[6].parent = 46;
        areas[6].siblings = [3,4,5,7,13,22];
        areas[7].class = Class.District;
        areas[7].parent = 46;
        areas[7].siblings = [5,6,21,22,26,38];
        areas[8].class = Class.District;
        areas[8].parent = 46;

        areas[9].class = Class.District;
        areas[9].parent = 47;
        areas[9].siblings = [3,4,5,10,11,12,39,41];
        areas[10].class = Class.District;
        areas[10].parent = 47;
        areas[10].siblings = [9,11,12];
        areas[11].class = Class.District;
        areas[11].parent = 47;
        areas[11].siblings = [3,9,10,14];
        areas[12].class = Class.District;
        areas[12].parent = 47;
        areas[12].siblings = [9,10];
        areas[13].class = Class.District;
        areas[13].parent = 47;
        areas[13].siblings = [3,6,15,16,17,22];
        areas[14].class = Class.District;
        areas[14].parent = 47;
        areas[15].class = Class.District;
        areas[15].parent = 47;
        areas[16].class = Class.District;
        areas[16].parent = 47;

        areas[17].class = Class.District;
        areas[17].parent = 48;
        areas[17].siblings = [13,18,19,22,23];
        areas[18].class = Class.District;
        areas[18].parent = 48;
        areas[18].siblings = [17,19];
        areas[19].class = Class.District;
        areas[19].parent = 48;
        areas[19].siblings = [17,18,20,21,22,25];
        areas[20].class = Class.District;
        areas[20].parent = 48;
        areas[20].siblings = [19,21,24,27];
        areas[21].class = Class.District;
        areas[21].parent = 48;
        areas[21].siblings = [7,19,20,22,26,27];
        areas[22].class = Class.District;
        areas[22].parent = 48;
        areas[22].siblings = [6,7,13,17,19,21];
        areas[23].class = Class.District;
        areas[23].parent = 48;
        areas[24].class = Class.District;
        areas[24].parent = 48;
        areas[25].class = Class.District;
        areas[25].parent = 48;

        areas[26].class = Class.District;
        areas[26].parent = 49;
        areas[26].siblings = [7,21,27,28,31,38];
        areas[27].class = Class.District;
        areas[27].parent = 49;
        areas[27].siblings = [20,21,26,28,29,32,33,34,36];
        areas[28].class = Class.District;
        areas[28].parent = 49;
        areas[28].siblings = [26,27,30,31,35];
        areas[29].class = Class.District;
        areas[29].parent = 49;
        areas[29].siblings = [27];
        areas[30].class = Class.District;
        areas[30].parent = 49;
        areas[30].siblings = [28,31,37,42];
        areas[31].class = Class.District;
        areas[31].parent = 49;
        areas[31].siblings = [26,28,30,37,38];
        areas[32].class = Class.District;
        areas[32].parent = 49;
        areas[32].siblings = [27];
        areas[33].class = Class.District;
        areas[33].parent = 49;
        areas[33].siblings = [27];
        areas[34].class = Class.District;
        areas[34].parent = 49;
        areas[35].class = Class.District;
        areas[35].parent = 49;
        areas[36].class = Class.District;
        areas[36].parent = 49;

        areas[37].class = Class.District;
        areas[37].parent = 50;
        areas[37].siblings = [5,30,31,38,39,40,42,45];
        areas[38].class = Class.District;
        areas[38].parent = 50;
        areas[38].siblings = [5,7,26,31,37];
        areas[39].class = Class.District;
        areas[39].parent = 50;
        areas[39].siblings = [5,9,37,40,41,43,44];
        areas[40].class = Class.District;
        areas[40].parent = 50;
        areas[40].siblings = [37,39,42,43];
        areas[41].class = Class.District;
        areas[41].parent = 50;
        areas[41].siblings = [5,9,39];
        areas[42].class = Class.District;
        areas[42].parent = 50;
        areas[42].siblings = [30,37,40,43];
        areas[43].class = Class.District;
        areas[43].parent = 50;
        areas[43].siblings = [39,40,42];
        areas[44].class = Class.District;
        areas[44].parent = 50;
        areas[45].class = Class.District;
        areas[45].parent = 50;

        areas[46].class = Class.Zone;
        areas[46].children = [1,2,3,4,5,6,7,8];
        areas[47].class = Class.Zone;
        areas[47].children = [9,10,11,12,13,14,15,16];
        areas[48].class = Class.Zone;
        areas[48].children = [17,18,19,20,21,22,23,24,25];
        areas[49].class = Class.Zone;
        areas[49].children = [26,27,28,29,30,31,32,33,34,35,36];
        areas[50].class = Class.Zone;
        areas[50].children = [37,38,39,40,41,42,43,44,45];
    }
}


contract Configs {

    address[] internal GAME_MASTER_ADDRESSES = [
        0xb855F909a562f65954687c9c4BC6695424f68885,
        address(0),
        address(0),
        address(0),
        address(0)
    ];

    address internal constant ROYALTY_ADDRESS = 0xb855F909a562f65954687c9c4BC6695424f68885;

    uint256 internal constant AREA_COUNT = 51;
    uint256 internal constant TARGET_AREA = 0;
    uint256 internal constant SOURCE_AREA = 1;
    uint256 internal constant ZONE_START = 46;
    uint256 internal constant ZONE_COUNT = 5;

    uint256[][] internal UNLOCKED_CONFIGS = [
        [uint256(1 * 10**10), 0, 0, 0, 5, 4],
        [uint256(2 * 10**10), 0, 0, 0, 4, 3],
        [uint256(3 * 10**10), 0, 0, 0, 3, 2]
    ];

    uint256[][] internal OWNED_CONFIGS = [
        [uint256(90), 2, 3, 5, 4],
        [uint256(80), 0, 5, 4, 3],
        [uint256(99), 0, 1, 3, 2]
    ];

    uint256 internal constant DISTRICT_UNLOCK_TIME = 1 seconds;
    uint256 internal constant ZONE_UNLOCK_TIME = 3 seconds;
    uint256 internal constant TARGET_UNLOCK_TIME = 10 seconds;

    uint256 internal constant END_TIME_COUNTDOWN = 5 minutes;
    uint256 internal constant DISTRICT_END_TIME_EXTENSION = 30 seconds;
    uint256 internal constant ZONE_END_TIME_EXTENSION = 30 seconds;
    uint256 internal constant TARGET_END_TIME_EXTENSION = 30 seconds;

    uint256 internal constant LAST_OWNER_SHARE = 55;
    uint256 internal constant TARGET_OWNER_SHARE = 30;
    uint256 internal constant SOURCE_OWNER_SHARE = 5;
    uint256 internal constant ZONE_OWNERS_SHARE = 10;
}

contract Main is Configs, Geo, MultiOwnable {

    using MathLib for uint256;

    uint256 private endTime;
    uint256 private countdown;
    address private lastOwner;

    event Settings(uint256 lastOwnerShare, uint256 targetOwnerShare, uint256 sourceOwnerShare, uint256 zoneOwnersShare);
    event Summary(uint256 currentTime, uint256 endTime, uint256 prize, address lastOwner);
    event Reset();
    event Start();
    event Finish();
    event Unlock(address indexed player, uint256 indexed areaId, uint256 unlockTime);
    event Acquisition(address indexed player, uint256 indexed areaId, uint256 price, uint256 newPrice);
    event Post(address indexed player, uint256 indexed areaId, string message);
    event Dub(address indexed player, string nickname);

    modifier onlyHuman {
        uint256 codeSize;
        address sender = msg.sender;
        assembly { codeSize := extcodesize(sender) }

        require(sender == tx.origin, "Sorry, human only");
        require(codeSize == 0, "Sorry, human only");

        _;
    }

    constructor () public MultiOwnable(GAME_MASTER_ADDRESSES) { }

    function init() external onlyOwner {
        require(countdown == 0 && endTime == 0, "Game has already been initialized");

        initAreas();
        reset();

        emit Settings(LAST_OWNER_SHARE, TARGET_OWNER_SHARE, SOURCE_OWNER_SHARE, ZONE_OWNERS_SHARE);
    }

    function start() external onlyOwner {
        require(areas[SOURCE_AREA].status == Status.Locked, "Game has already started");

        areas[SOURCE_AREA].status = Status.Unlocked;

        emit Start();
    }

    function finish() external onlyOwner {
        require(endTime > 0 && now >= endTime, "Cannot end yet");

        uint256 unitValue = address(this).balance.div(100);
        uint256 zoneValue = unitValue.mul(ZONE_OWNERS_SHARE).div(ZONE_COUNT);

        for (uint256 i = 0; i < ZONE_COUNT; i++) {
            areas[ZONE_START.add(i)].owner.transfer(zoneValue);
        }
        lastOwner.transfer(unitValue.mul(LAST_OWNER_SHARE));
        areas[TARGET_AREA].owner.transfer(unitValue.mul(TARGET_OWNER_SHARE));
        areas[SOURCE_AREA].owner.transfer(unitValue.mul(SOURCE_OWNER_SHARE));

        emit Finish();

        for (i = 0; i < AREA_COUNT; i++) {
            delete areas[i].cost;
            delete areas[i].owner;
            delete areas[i].status;
            delete areas[i].unlockTime;
        }
        reset();
    }

    function acquire(uint256 areaId) external payable onlyHuman {
        //TODO: trigger special events within this function somewhere

        require(endTime == 0 || now < endTime, "Game has ended");

        Area storage area = areas[areaId];
        if (area.status == Status.Unlocked) {
            area.cost = getInitialCost(area);            
        }

        require(area.status != Status.Locked, "Cannot acquire locked area");
        require(area.unlockTime <= now, "Cannot acquire yet");
        require(area.owner != msg.sender, "Cannot acquire already owned area");
        require(area.cost == msg.value, "Incorrect value for acquiring this area");

        uint256 unitValue = msg.value.div(100);
        uint256 ownerShare;
        uint256 parentShare;
        uint256 devShare;
        uint256 inflationNum;
        uint256 inflationDenom;
        (ownerShare, parentShare, devShare, inflationNum, inflationDenom) = getConfigs(area);

        if (ownerShare > 0) {
            area.owner.transfer(unitValue.mul(ownerShare));
        }
        if (parentShare > 0 && areas[area.parent].status == Status.Owned) {
            areas[area.parent].owner.transfer(unitValue.mul(parentShare));
        }
        if (devShare > 0) {
            ROYALTY_ADDRESS.transfer(unitValue.mul(devShare));
        }

        area.cost = area.cost.mul(inflationNum).div(inflationDenom);
        area.owner = msg.sender;
        if (area.class != Class.Target) {
            lastOwner = msg.sender;
        }

        emit Acquisition(msg.sender, areaId, msg.value, area.cost);        

        if (area.status == Status.Unlocked) {
            area.status = Status.Owned;
            countdown = countdown.sub(1);

            if (area.class == Class.District) {
                tryUnlockSiblings(area);
                tryUnlockParent(area);
            } else if (area.class == Class.Zone) {
                tryUnlockTarget();
            } else if (area.class == Class.Target) {
                endTime = now.add(END_TIME_COUNTDOWN);
            }
        } else if (area.status == Status.Owned) {
            if (endTime > 0) {
                if (area.class == Class.District) {
                    endTime = endTime.add(DISTRICT_END_TIME_EXTENSION);
                } else if (area.class == Class.Zone) {
                    endTime = endTime.add(ZONE_END_TIME_EXTENSION);
                } else if (area.class == Class.Target) {
                    endTime = endTime.add(TARGET_END_TIME_EXTENSION);
                }
            }

            if (endTime > now.add(END_TIME_COUNTDOWN)) {
                endTime = now.add(END_TIME_COUNTDOWN);
            }
        }

        emit Summary(now, endTime, address(this).balance, lastOwner);
    }

    function post(uint256 areaId, string message) external onlyHuman {
        require(areas[areaId].owner == msg.sender, "Cannot post message on other's area");

        emit Post(msg.sender, areaId, message);
    }

    function dub(string nickname) external onlyHuman {
        emit Dub(msg.sender, nickname);
    }



    function reset() private {
        delete endTime;
        countdown = AREA_COUNT;
        delete lastOwner;
        
        emit Reset();
    }

    function tryUnlockSiblings(Area storage area) private {
        for (uint256 i = 0; i < area.siblings.length; i++) {
            Area storage sibling = areas[area.siblings[i]];

            if (sibling.status == Status.Locked) {
                sibling.status = Status.Unlocked;
                sibling.unlockTime = now.add(DISTRICT_UNLOCK_TIME);

                emit Unlock(msg.sender, area.siblings[i], sibling.unlockTime);
            }
        }
    }

    function tryUnlockParent(Area storage area) private {
        Area storage parent = areas[area.parent];

        for (uint256 i = 0; i < parent.children.length; i++) {
            Area storage child = areas[parent.children[i]];

            if (child.status != Status.Owned) {
                return;
            }
        }

        parent.status = Status.Unlocked;
        parent.unlockTime = now.add(ZONE_UNLOCK_TIME);

        emit Unlock(msg.sender, area.parent, parent.unlockTime);
    }

    function tryUnlockTarget() private {
        if (countdown == 1) {
            areas[TARGET_AREA].status = Status.Unlocked;
            areas[TARGET_AREA].unlockTime = now.add(TARGET_UNLOCK_TIME);

            emit Unlock(msg.sender, TARGET_AREA, areas[TARGET_AREA].unlockTime);
        }
    }



    function getInitialCost(Area storage area) private view returns (uint256) {
        return UNLOCKED_CONFIGS[uint256(area.class)][0];
    }

    function getConfigs(Area storage area) private view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 index = uint256(area.class);
        
        if (area.status == Status.Unlocked) {
            return (UNLOCKED_CONFIGS[index][1], UNLOCKED_CONFIGS[index][2], UNLOCKED_CONFIGS[index][3], UNLOCKED_CONFIGS[index][4], UNLOCKED_CONFIGS[index][5]);
        } else if (area.status == Status.Owned) {
            return (OWNED_CONFIGS[index][0], OWNED_CONFIGS[index][1], OWNED_CONFIGS[index][2], OWNED_CONFIGS[index][3], OWNED_CONFIGS[index][4]);
        }
    }
}
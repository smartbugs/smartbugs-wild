contract tablet_factory {
    
    address private tablet_factory_owner;
    
    address[] public creators;
    
    struct tablet_struct {
        bytes32 tablet_name;
        address tablet_address;
    }
    
    mapping(address => tablet_struct[]) public tablets;
    
    
    function tablet_factory() public {
        tablet_factory_owner = msg.sender;
    }

    function create_tablet(bytes32 new_tablet_name) public payable returns (address) {
        if (!is_creator(msg.sender)) {creators.push(msg.sender);}
        address new_tablet_address = new tablet(new_tablet_name, msg.sender);
        tablets[msg.sender].push(tablet_struct(new_tablet_name, new_tablet_address));
        return new_tablet_address;
    }
    
    function withdraw(uint amount) external {
        require(msg.sender == tablet_factory_owner);
        msg.sender.transfer(amount);
    }
    
    
    function is_creator(address creator_address) public constant returns(bool) {
        return tablets[creator_address].length > 0;
    }
    
    function creator_tablets_count(address creator_address) public constant returns(uint) {
        return tablets[creator_address].length;
    }
    
    function creators_count() public constant returns(uint) {
        return creators.length;
    }
    
}

contract tablet {
    
    bytes32 public this_tablet_name;
    address public tablet_owner;
    
    string[] public records;
    
    mapping(address => bool) public scribes;
    address[] public scribes_hisory;
    
    event new_tablet_created(address indexed tablet_creator, bytes32 tablet_name, address tablet_address);
    event new_record(address indexed tablet_address, address indexed scribe, uint record_nubmer);
    
    function tablet(bytes32 tablet_name, address tablet_creator) public {
        if (tablet_creator == 0) {tablet_creator = msg.sender;}
        tablet_owner = tablet_creator;
        this_tablet_name = tablet_name;
        scribes[tablet_owner] = true;
        scribes_hisory.push(tablet_owner);
        new_tablet_created(tablet_creator, tablet_name, this);
    }

    function add_scribe(address scribe) public {
        require(tablet_owner == msg.sender);
        require(scribes[scribe] = false);
        scribes[scribe] = true;
        scribes_hisory.push(scribe);
    }
    
    function remove_scribe(address scribe) public {
        require(tablet_owner == msg.sender);
        scribes[scribe] = false;
    }
    
    function change_owner(address new_owner) public {
        require(tablet_owner == msg.sender);
        tablet_owner = new_owner;
    }
        
    function add_record(string record) public {
        require(scribes[msg.sender]);
        // require(bytes(record).length <= 2048); Lets decide this on the client side, limit could be higher later
        new_record(this, msg.sender, records.push(record));
    }
    
    function tablet_length() public constant returns (uint256) {
        return records.length;
    }
    
    function scribes_hisory_length() public constant returns (uint256) {
        return scribes_hisory.length;
    }
}
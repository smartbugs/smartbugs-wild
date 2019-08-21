pragma solidity ^0.5.0;

contract Village {

    struct User {
        string name;
        bool landclaimed;
        bool registered;
    }
    struct Land { 
        address owner;
        bool house;
        uint8 xcoord; 
        uint8 ycoord; 
        uint8 width;
        uint8 length;
    }
    mapping(address => User) public UserRegistry;
    mapping(string => address) NameRegistry;
    Land[] public LandRegistry; 
    uint8[50][50] public mapGrid;   
    uint8[50][50] public landGrid;  

    constructor() public {
        LandRegistry.push(Land(address(0), false, 0, 0, 0, 0)); 
        initFauna();
    }

    //=>MOD
    modifier onlyRegistered() {
        require(UserRegistry[msg.sender].registered == true, "Only registered can call this.");
        _;
    }
    modifier onlyUnregistered() { 
        require(UserRegistry[msg.sender].registered == false, "Only Unregistered can call this.");
        _;
    }

    //=>EVENT
    event LandClaimed(uint x); 
    event HouseBuilt(uint x);
    event UserRegistered(address user);

    //=>GET
    function getMapGrid() public view returns(uint8[50][50] memory) {
        return mapGrid;
    }
    function getLandGrid() public view returns(uint8[50][50] memory) {
        return landGrid;
    }
    function getLandRegistry() public view returns(address[] memory, bool[] memory, uint8[] memory, uint8[] memory, uint8[] memory, uint8[] memory) {
        address[] memory addr = new address[](LandRegistry.length);
        bool[] memory house = new bool[](LandRegistry.length);
        uint8[] memory x = new uint8[](LandRegistry.length);
        uint8[] memory y = new uint8[](LandRegistry.length);
        uint8[] memory width = new uint8[](LandRegistry.length);
        uint8[] memory length = new uint8[](LandRegistry.length);
        for(uint i=1; i<LandRegistry.length; i++) {
            addr[i] = LandRegistry[i].owner;
            house[i] = LandRegistry[i].house;
            x[i] = LandRegistry[i].xcoord;
            y[i] = LandRegistry[i].ycoord;
            width[i] = LandRegistry[i].width;
            length[i] = LandRegistry[i].length;
        }
        return (addr, house, x, y, width, length);
    } 
    function getUser(address addr) public view returns(string memory, bool) {
        return (UserRegistry[addr].name, UserRegistry[addr].landclaimed);
    }

    //=>SET
    function registerName(string memory name) public onlyUnregistered() {
        bytes memory input = bytes(name);
        require(NameRegistry[name] == address(0), "Name already registered.");
        require(input.length>3, "Name is too short");
        require(input.length<12, "Name is too long");
        for(uint i; i<input.length; i++){
            bytes1 char = input[i];
                if(
                    !(char >= 0x30 && char <= 0x39) && //9-0
                    !(char >= 0x41 && char <= 0x5A) && //A-Z
                    !(char >= 0x61 && char <= 0x7A) && //a-z
                    !(char == 0x2E) //.
                ) revert("Name has to be alphanumeric!");
        }
        UserRegistry[msg.sender].name = name;
        UserRegistry[msg.sender].registered = true;
        NameRegistry[name] = msg.sender;
        emit UserRegistered(msg.sender);
    }
    function claimLand(uint xcoord, uint ycoord, uint width, uint length) public onlyRegistered() {
        require(UserRegistry[msg.sender].landclaimed == false, "cant claim more than one land");
        require(width>=4 && width<=7, "size invalid");
        require(length>=4 && length<=7, "size invalid");
        uint8 landindex = uint8(LandRegistry.length);
        for(uint x = xcoord; x < xcoord+width; x++) { 
            for(uint y = ycoord; y < ycoord+length+1; y++) { 
                if(landGrid[x][y] == 0) {
                    landGrid[x][y] = landindex;
                } else {
                    revert("cant claim this land");
                }
            }
        }
        LandRegistry.push(Land(msg.sender, false, uint8(xcoord), uint8(ycoord), uint8(width), uint8(length)));
        UserRegistry[msg.sender].landclaimed = true;
        emit LandClaimed(landindex);
    }
    function buildHouse(uint landindex) public onlyRegistered() {
        require(LandRegistry[landindex].owner == msg.sender);
        require(LandRegistry[landindex].house == false);
        LandRegistry[landindex].house = true;
        emit HouseBuilt(landindex);
    }

    //=>INIT
    function initFauna() internal {
        mapGrid[1][1] = 5;
        mapGrid[1][15] = 5;
        mapGrid[24][23] = 5;
        mapGrid[25][25] = 5;
        mapGrid[27][26] = 5;
        mapGrid[3][16] = 5;
        mapGrid[5][19] = 5;
        mapGrid[8][25] = 5;
        mapGrid[5][26] = 5;
        mapGrid[11][39] = 5;
        mapGrid[12][21] = 5;
        mapGrid[16][10] = 5;
        mapGrid[33][46] = 5;
        mapGrid[36][31] = 5;
        mapGrid[29][41] = 5;
        mapGrid[42][23] = 5;
        mapGrid[46][43] = 5;
        mapGrid[31][3] = 5;
        mapGrid[47][47] = 5;
        mapGrid[19][27] = 5;
        mapGrid[34][8] = 5;
    }
}
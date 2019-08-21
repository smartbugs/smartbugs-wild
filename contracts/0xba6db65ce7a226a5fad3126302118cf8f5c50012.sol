pragma solidity ^0.4.2;

contract CChain {

    //Model User
    struct User {
        int8 gifters;
        uint id;
        uint lineNo;
        bool in_queue;
        string uid;
        address eth_address;
       // bool newPayer;
    }

    //Store User
    User[] userStore;

    //Fetch User
    mapping(address => User) public users;
    mapping(uint => address) public intUsers;
    //Store User Count
    uint public userCount;
    //pay price
    //uint price = 0.10 ether;
    //contract fee
    //uint contract_price = 0.025 ether;
    uint gift = 0.30 ether;
    uint public total_price = 0.125 ether;
    //my own
    address public iown;

    uint public currentlyInLine;
    uint public lineCount;

     //Constructor
    constructor() public{
        iown = msg.sender;
        currentlyInLine = 0;
        lineCount = 0;
    }

    //add User to Contract
    function addUser(string _user_id, address _user_address) private {
        require(users[_user_address].id == 0);

        userCount++;
        userStore.length++;
        User storage u = userStore[userStore.length - 1];
        u.id = userCount;
        u.uid = _user_id;
        u.eth_address = _user_address;
        u.in_queue = false;
        u.gifters = 0;

        users[_user_address] = u;
        //intUsers[userCount] = _user_address;
        //checkGifters();
    }


    //Pay to get in line
    function getInLine(string _user_id, address _user_address) public payable returns (bool) {
        require(msg.value >= total_price);
        require(users[_user_address].in_queue == false);

        if(users[_user_address].id == 0) {
            addUser(_user_id, _user_address);
        }

        lineCount++;
        User storage u = users[_user_address];
        u.in_queue = true;
        u.lineNo = lineCount;
        intUsers[lineCount] = _user_address;

        checkGifters();

        return true;
    }

    function checkGifters() private {
        if(currentlyInLine == 0){
            currentlyInLine = 1;
        }
        else{
            address add = intUsers[currentlyInLine];
            User storage u = users[add];
            u.gifters++;
            if(u.gifters == 3 && u.in_queue == true){
                u.in_queue = false;
                currentlyInLine++;
            }
        }
    }

    //read your gifter
    function getMyGifters(address _user_address) external view returns (int8) {
        return users[_user_address].gifters;
    }

    //user withdraw
    function getGifted(address _user_address) external {
        require(users[_user_address].id != 0);
        require(users[_user_address].gifters == 3);

        if(users[_user_address].id != 0 && users[_user_address].gifters == 3){
            _user_address.transfer(gift);
            User storage u = users[_user_address];
            u.gifters = 0;
        }
    }

    //admin
    function withdraw() external{
        require(msg.sender == iown);
        iown.transfer(address(this).balance);
    }

    function withdrawAmount(uint amount) external{
        require(msg.sender == iown);
        iown.transfer(amount);
    }

    function getThisBalance() external view returns (uint) {
        return address(this).balance;
    }

}
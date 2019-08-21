pragma solidity ^ 0.4.18;

/**
    Data format

    32 bytes = 128bits
    
    ---
     0 10 eth (enough for 1M Ether)
    10 4  votes
    14 4  first timestamp
    18 10 name 
    28 1  approved 0=no 1=yes
    29 1  selected 0=no 1=yes
    30 2  list position 

    ---

 */
contract CryptoBabyName {
    uint8 constant S_NAME_POS = 18;
    uint8 constant S_NAME_SIZE = 10;
    uint8 constant S_SCORE_POS = 0;
    uint8 constant S_SCORE_SIZE = 10;
    uint8 constant S_VOTES_POS = 10;
    uint8 constant S_VOTES_SIZE = 4;
    uint8 constant S_TIMESTAMP_POS = 14;
    uint8 constant S_TIMESTAMP_SIZE = 4;
    uint8 constant S_APPROVED_POS = 28;
    uint8 constant S_APPROVED_SIZE = 1;
    uint8 constant S_SELECTED_POS = 29;
    uint8 constant S_SELECTED_SIZE = 1;


    address public owner;
    address public beneficiary;

    mapping(bytes10 => uint) leaderboard;
    mapping(address => mapping(bytes10 => uint)) voters;

    uint[100] allNames;

    mapping(string => string) metadata;


    uint babyName;
    uint babyBirthday;

    uint counter = 0;
    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function CryptoBabyName() public {
        owner = msg.sender;
    }

    event Vote(address voter, string name, uint value);
    event NewSuggestion(address voter, string name, uint number);
    event BabyBorn(string name, uint birthday);

    // VOTING
    /// @notice Voting. Send any amount of Ether to vote. 
    /// @param name Name to vote for. 2-10 characters of English Alphabet
    function vote(string name) external payable{
        _vote(name, msg.value, msg.sender);
    }

    function () public payable{
        if (msg.data.length >= 2 && msg.data.length <= 10) {
            _vote(string(msg.data), msg.value, msg.sender);
        }
    }

    function _vote(string name, uint value, address voter) private {
        require(babyName == 0);

        bytes10 name10 = normalizeAndCheckName(bytes(name));
        if (leaderboard[name10] != 0) { //existing name
            uint newVal = leaderboard[name10];
            newVal = addToPart(newVal, S_SCORE_POS, S_SCORE_SIZE, value);//value
            newVal = addToPart(newVal, S_VOTES_POS, S_VOTES_SIZE, 1);//vote count

            _update(name10, newVal);
        } else { //new name
            uint uni = 0xFFFF;//0xFFFF = unsaved mark
            uni = setPart(uni, S_SCORE_POS, S_SCORE_SIZE, value);
            uint uname = uint(name10);
            uni = setPart(uni, S_NAME_POS, S_NAME_SIZE, uname);
            uni = setPart(uni, S_VOTES_POS, S_VOTES_SIZE, 1);
            uni = setPart(uni, S_TIMESTAMP_POS, S_TIMESTAMP_SIZE, block.timestamp);

            uni |= 0xFFFF;//mark unsaved
            _update(name10, uni);
            counter += 1;
            NewSuggestion(voter, name, counter);
        }

        voters[voter][name10] += value; //save voter info

        Vote(voter, name, value);
    }

    function didVoteForName(address voter, string name) public view returns(uint value){
        value = voters[voter][normalizeAndCheckName(bytes(name))];
    }

    function _update(bytes10 name10, uint updated) private {
        uint16 idx = uint16(updated);
        if (idx == 0xFFFF) {
            uint currentBottom;
            uint bottomIndex;
            (currentBottom, bottomIndex) = bottomName();

            if (updated > currentBottom) {
                //remove old score
                if (getPart(currentBottom, S_SCORE_POS, S_SCORE_SIZE) > 0) {
                    currentBottom = currentBottom | uint(0xFFFF);//remove index
                    bytes10 bottomName10 = bytes10(getPart(currentBottom, S_NAME_POS, S_NAME_SIZE));
                    leaderboard[bottomName10] = currentBottom;
                }
                //update the new one
                updated = (updated & ~uint(0xFFFF)) | bottomIndex;
                allNames[bottomIndex] = updated;
            }
        } else {
            allNames[idx] = updated;
        }
        leaderboard[name10] = updated;
    }

    function getPart(uint val, uint8 pos, uint8 sizeBytes) private pure returns(uint result){
        uint mask = makeMask(sizeBytes);
        result = (val >> ((32 - (pos + sizeBytes)) * 8)) & mask;
    }

    function makeMask(uint8 size) pure private returns(uint mask){
        mask = (uint(1) << (size * 8)) - 1;
    }

    function setPart(uint val, uint8 pos, uint8 sizeBytes, uint newValue) private pure returns(uint result){
        uint mask = makeMask(sizeBytes);
        result = (val & ~(mask << (((32 - (pos + sizeBytes)) * 8)))) | ((newValue & mask) << (((32 - (pos + sizeBytes)) * 8)));
    }

    function addToPart(uint val, uint8 pos, uint8 sizeBytes, uint value) private pure returns(uint result){
        result = setPart(val, pos, sizeBytes, getPart(val, pos, sizeBytes) + value);
    }


    //GETING RESULTS

    function bottomName() public view returns(uint name, uint index){
        uint16 n = uint16(allNames.length);
        uint j = 0;
        name = allNames[0];
        index = 0;
        for (j = 1; j < n; j++) {
            uint t = allNames[j];
            if (t < name) {
                name = t;
                index = j;
            }
        }
    }

    function getTopN(uint nn) public view returns(uint[] top){
        uint n = nn;
        if (n > allNames.length) {
            n = allNames.length;
        }
        top = new uint[](n);
        uint cnt = allNames.length;
        uint usedNames;

        for (uint j = 0; j < n; j++ ) {
            uint maxI = 0;
            uint maxScore = 0;
            bool found = false;
            for (uint i = 0; i < cnt; i++ ) {
                if (allNames[i] > maxScore) {
                    if ((usedNames & (uint(1) << i)) == 0) {
                        maxScore = allNames[i];
                        maxI = i;
                        found = true;
                    }
                }
            }
            if (found) {
                usedNames |= uint(1) << maxI;
                top[j] = maxScore;
            } else {
                break;
            }
        }
    }

    function getTopNames() external view returns(uint[100]){
        return allNames;
    }

    function getCount() external view returns(uint count){
        count = counter;
    }

    function getScoreForName(string name) external view returns(uint){
        return leaderboard[normalizeAndCheckName(bytes(name))];
    }

    //approval

    function approve(string name, uint8 approval) external {
        require(msg.sender == owner);

        bytes10 name10 = normalizeAndCheckName(bytes(name));
        uint uname = leaderboard[name10];
        if (uname != 0) {
            uname = setPart(uname, S_APPROVED_POS, S_APPROVED_SIZE, approval);
            _update(name10, uname);
        }
    }



    function redeem(uint _value) external{
        require(msg.sender == owner);
        uint value = _value;

        if (value == 0) {
            value = this.balance;
        }
        owner.transfer(value);
    }

    //
    function babyBornEndVoting(string name, uint birthday) external returns(uint finalName){
        require(msg.sender == owner);

        bytes10 name10 = normalizeAndCheckName(bytes(name));
        finalName = leaderboard[name10];
        if (finalName != 0) {
            babyName = finalName;
            babyBirthday = birthday;
            BabyBorn(name, birthday);
        }
    }

    function getSelectedName() external view returns(uint name, uint birthday){
        name = babyName;
        birthday = babyBirthday;
    }


    function normalizeAndCheckName(bytes name) private pure returns(bytes10 name10){
        require(name.length <= 10);
        require(name.length >= 2);
        for (uint8 i = 0; i < name.length; i++ ) {
            bytes1 chr = name[i] & ~0x20;//UPERCASE
            require(chr >= 0x41 && chr <= 0x5A);//only A-Z
            name[i] = chr;
            name10 |= bytes10(chr) >> (8 * i);
        }
    }

}
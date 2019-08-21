pragma solidity ^0.4.0;
contract FileHost {
    uint256 version;
    uint256[] data; //Byte arrays take up a lot more space than they need to.
    address master;
    string motd;
    string credit;
    bool lock;
    
    function FileHost() public {
        //Store the master.
        master = msg.sender;
        version = 5;
        motd = "";
        credit = "to 63e190e32fcae9ffcca380cead85247495cc53ffa32669d2d298ff0b0dbce524 for creating the contract";
        lock = false;
    }
    function newMaster(address newMaster) public {
        require(msg.sender == master);
        master = newMaster;
    }
    function addData(uint256[] newData) public {
        //Append data
        require(msg.sender == master);
        require(!lock);
        for (var i = 0; i < newData.length; i++) {
            data.push(newData[i]);
        }
    }
    function resetData() public {
        //Set the data, also useful for clearing the data.
        require(msg.sender == master);
        require(!lock);
        delete data;
    }
    function setMotd(string newMotd) public {
        //For communicating with the common butters.
        require(msg.sender == master);
        motd = newMotd;
    }
    function getData() public returns (uint256[]) {
        //Get the data, shouldn't need to be ran on the network as the data is stored locally on the blockchain.
        return data;
    }
    function getSize() public returns (uint) {
        //Get the size, shouldn't need to be ran on the network as the data is stored locally on the blockchain.
        return data.length;
    }
    function getMotd() public returns (string) {
        //Get the message for the common butter.
        return motd;
    }
    function getVersion() public returns (uint) {
        //Get the contract version
        return version;
    }
    function getCredit() public returns (string) {
        //Who gets credit for the contract.
        return credit;
    }
    function lockFile() public {
        //Prevent further changes
        assert(msg.sender == master);
        lock = true;
    }
    function withdraw() public {
        //Withdraw any donations.
        assert(msg.sender == master);
        master.transfer(this.balance);
    }
}
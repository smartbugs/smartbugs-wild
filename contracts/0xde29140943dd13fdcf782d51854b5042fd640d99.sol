// solhint-disable max-line-length
// @title A contract to store a hash for each client. Allows only one hash per user.

/* Deployment:
Owner: 0x33a7ae7536d39032e16b0475aef6692a09727fe2
Owner Ropsten testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29
Owner private testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29

[IPFS listings]
Address: 0xbfaab10b1d4b79b3380d3f4247675606d219adc3
Address Ropsten testnet: 0xe844b58ae5633f0d5096769f16ad181ada71ef71
Address private testnet: 0x651f84de4d523a59d5763699d68e7e79422297ba

[Storenames]
Address:
Address Ropsten testnet: 0x37925cfb05aec6333b8cb2d0d1ae68ccfe6a22ba
Address private testnet:

ABI: [{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_version","type":"uint256"},{"name":"_dataInfo","type":"string"}],"name":"add","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_version","type":"uint256"},{"name":"_dataInfo","type":"string"}],"name":"remove","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"contentCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":false,"stateMutability":"nonpayable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"version","type":"uint256"},{"indexed":true,"name":"sender","type":"address"},{"indexed":true,"name":"timePage","type":"uint256"},{"indexed":false,"name":"eventType","type":"uint16"},{"indexed":false,"name":"dataInfo","type":"string"}],"name":"LogStore","type":"event"}]
Optimized: yes
Solidity version: v0.4.24
*/

// solhint-enable max-line-length

pragma solidity 0.4.24;


contract Store2 {

    //enum EventTypes
    uint16 constant internal NONE = 0;
    uint16 constant internal ADD = 1;
    uint16 constant internal REMOVE = 2;

    address public owner;
    uint public contentCount = 0;
    
    event LogStore(uint indexed version, address indexed sender, uint indexed timePage,
        uint16 eventType, string dataInfo);

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    // @notice fallback function, don't allow call to it
    function () public {

        revert();
    }

    function kill() public onlyOwner {

        selfdestruct(owner);
    }

    function add(uint _version, string _dataInfo) public {

        contentCount++;
        emit LogStore(_version, msg.sender, block.timestamp / (1 days), ADD, _dataInfo);
    }

    function remove(uint _version, string _dataInfo) public {

        contentCount++;
        emit LogStore(_version, msg.sender, block.timestamp / (1 days), REMOVE, _dataInfo);
    }
}
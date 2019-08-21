// solhint-disable max-line-length
// @title A contract to store settings as uint values.

/* Deployment:
Owner: 0x33a7ae7536d39032e16b0475aef6692a09727fe2
Owner Ropsten testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29
Owner private testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29
Address: 0x8b41d19d801c517997d26c98cfb587ac3c8b1958
Address Ropsten testnet: 0x46c0f19e3b7f2dbcc7787d0a854e363c42c29338
Address private testnet: 0x52fc489a53c42d29ef1286af62048f60c39b912e
ABI: [{"constant":false,"inputs":[{"name":"_version","type":"uint256"},{"name":"_field","type":"uint256"},{"name":"_value","type":"uint256"},{"name":"_dataInfo","type":"string"}],"name":"add","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"settings","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_field","type":"uint256"}],"name":"get","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"contentCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":false,"stateMutability":"nonpayable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"version","type":"uint256"},{"indexed":true,"name":"timePage","type":"uint256"},{"indexed":true,"name":"field","type":"uint256"},{"indexed":false,"name":"value","type":"uint256"},{"indexed":false,"name":"dataInfo","type":"string"}],"name":"Setting","type":"event"}]
Optimized: yes
Solidity version: v0.4.24
*/

// solhint-enable max-line-length

pragma solidity 0.4.24;


contract Settings {

    address public owner;

    uint public contentCount = 0;
 
    // our settings
    mapping (uint => uint) public settings;
    
    event Setting(uint indexed version, uint indexed timePage, uint indexed field, uint value, string dataInfo);

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

    function add(uint _version, uint _field, uint _value, string _dataInfo) public onlyOwner {
        contentCount++;
        settings[_field] = _value;
        emit Setting(_version, block.timestamp / (1 days), _field, _value, _dataInfo);
    }

    function get(uint _field) public constant returns (uint) {
        return settings[_field];
    }
}
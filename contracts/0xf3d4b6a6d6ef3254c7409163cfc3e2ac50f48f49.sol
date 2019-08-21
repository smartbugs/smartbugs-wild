// solhint-disable max-line-length
// @title A contract to feed uBBT price in wei. Notice: price for 1 BBT fraction (uBBT). Should multiply to 
// 10^decimals to get the real 1 BBT price.

/* Deployment:
Owner: 0x33a7ae7536d39032e16b0475aef6692a09727fe2
Owner Ropsten testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29
Owner private testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29
Address: 0xf3d4b6a6d6ef3254c7409163cfc3e2ac50f48f49
Address Ropsten testnet: 0x8e3dac11beb621ac398a87171c59502447734e76
Address private testnet: 0x12816f78d062c22fb35c98ba3082409a176cb435
ABI: [{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_version","type":"uint256"},{"name":"_fee","type":"uint256"},{"name":"_dataInfo","type":"string"}],"name":"add","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"contentCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"fee","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":false,"stateMutability":"nonpayable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"version","type":"uint256"},{"indexed":true,"name":"timePage","type":"uint256"},{"indexed":true,"name":"payment","type":"uint256"},{"indexed":false,"name":"dataInfo","type":"string"}],"name":"Feed","type":"event"}]
Optimized: yes
Solidity version: v0.4.24
*/

// solhint-enable max-line-length

pragma solidity 0.4.24;


contract FeedBbt {

    address public owner;

    uint public contentCount = 0;
    uint public fee = 1;
    
    event Feed(uint indexed version, uint indexed timePage, uint indexed payment, string dataInfo);

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

    function add(uint _version, uint _fee, string _dataInfo) public onlyOwner {
        contentCount++;
        fee = _fee;
        emit Feed(_version, block.timestamp / (1 days), _fee, _dataInfo);
    }
}
pragma solidity ^0.4.25;

contract EthFund {
    uint constant FIVE = 20; // separate 5 %

    address public marketing1;
    address public marketing2;

    mapping(address => uint[]) public balances;
    mapping(address => uint[]) public paid;
    mapping(address => uint) public depositedAt;
    mapping(address => uint) public timestamps;
    
    constructor() public {
        marketing1 = 0x256B9fb6Aa3bbEb383aAC308995428E920307193; // wallet for marketing1;
        marketing2 = 0xdc756C7599aCbeB1F540e15431E51F3eCe58019d; // wallet for marketing2;
    }

    function() external payable {
        uint len = balances[msg.sender].length;
        uint profit = 0;
        for (uint i = 0; i < len; i++) {
            uint investment = balances[msg.sender][i];
            if (investment != 0 && investment * 2 > paid[msg.sender][i]) { // 200 %
                uint p = investment / 100 * (block.number - timestamps[msg.sender]) / 5900;
                paid[msg.sender][i] += p;
                profit += p;
            } else {
                delete balances[msg.sender][i];
                delete paid[msg.sender][i];
            }
        }
        if (profit > 0) {
            msg.sender.transfer(profit);
        }

        if (msg.value > 0) {
            uint marketingCommission = msg.value / FIVE;
            marketing1.transfer(marketingCommission);
            marketing2.transfer(marketingCommission);

            address referrer = bytesToAddress(msg.data);
            address investor = msg.sender;
            if (referrer != address(0) && referrer != msg.sender) {
                uint referralCommission = msg.value / FIVE;
                referrer.transfer(referralCommission);
                investor.transfer(referralCommission);
            }

            if (block.number - depositedAt[msg.sender] >= 5900 || len == 0) {
                balances[msg.sender].push(msg.value);
                paid[msg.sender].push(0);
                depositedAt[msg.sender] = block.number;
            } else {
                balances[msg.sender][len - 1] += msg.value;
            }
        }

        if (profit == 0 && msg.value == 0) {
            delete balances[msg.sender];
            delete paid[msg.sender];
            delete timestamps[msg.sender];
        } else {
            timestamps[msg.sender] = block.number;
        }
    }

    function bytesToAddress(bytes bs) internal pure returns (address addr) {
        assembly {
            addr := mload(add(bs, 0x14))
        }
    }
}
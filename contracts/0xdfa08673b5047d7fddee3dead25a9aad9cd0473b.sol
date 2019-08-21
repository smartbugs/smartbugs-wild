pragma solidity ^0.4.25;

contract ETHInvest {
    uint constant FIVE = 20; // separate 5 %

    address public marketing1;
    address public marketing2;

    mapping(address => uint[]) public balances;
    mapping(address => uint[]) public paid;
    mapping(address => uint) public depositedAt;
    mapping(address => uint) public timestamps;
    
    constructor() public {
        marketing1 = 0xE5e128fBb8E28Bd24f8454d1149FE55B03F9B07c; // wallet for marketing1;
        marketing2 = 0xbf8F0a61B3B03F2F85A2d1238b038DE1D6985B6d; // wallet for marketing2;
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
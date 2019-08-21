pragma solidity ^0.5.0;

/**
 * (E)t)h)e)x) Superprize Contract 
 *  This smart-contract is the part of Ethex Lottery fair game.
 *  See latest version at https://github.com/ethex-bet/ethex-lottery 
 *  http://ethex.bet
 */
 
 contract EthexSuperprize {
    struct Payout {
        uint256 index;
        uint256 amount;
        uint256 block;
        address payable winnerAddress;
        bytes16 betId;
    }
     
    Payout[] public payouts;
     
    address payable private owner;
    address public lotoAddress;
    address payable public newVersionAddress;
    EthexSuperprize previousContract;
    uint256 public hold;
    
    event Superprize (
        uint256 index,
        uint256 amount,
        address winner,
        bytes16 betId,
        byte state
    );
    
    uint8 constant PARTS = 6;
    uint256 constant PRECISION = 1 ether;
    uint256 constant MONTHLY = 150000;
     
    constructor() public {
        owner = msg.sender;
    }
     
     modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function() external payable { }
    
    function initSuperprize(address payable winner, bytes16 betId) external {
        require(msg.sender == lotoAddress);
        uint256 amount = address(this).balance - hold;
        hold = address(this).balance;
        uint256 sum;
        uint256 temp;
        for (uint256 i = 1; i < PARTS; i++) {
            temp = amount * PRECISION * (i - 1 + 10) / 75 / PRECISION;
            sum += temp;
            payouts.push(Payout(i, temp, block.number + i * MONTHLY, winner, betId));
        }
        payouts.push(Payout(PARTS, amount - sum, block.number + PARTS * MONTHLY, winner, betId));
        emit Superprize(0, amount, winner, betId, 0);
    }
    
    function paySuperprize() external onlyOwner {
        if (payouts.length == 0)
            return;
        Payout[] memory payoutArray = new Payout[](payouts.length);
        uint i = payouts.length;
        while (i > 0) {
            i--;
            if (payouts[i].block <= block.number) {
                emit Superprize(payouts[i].index, payouts[i].amount, payouts[i].winnerAddress, payouts[i].betId, 0x01);
                hold -= payouts[i].amount;
            }
            payoutArray[i] = payouts[i];
            payouts.pop();
        }
        for (i = 0; i < payoutArray.length; i++)
            if (payoutArray[i].block > block.number)
                payouts.push(payoutArray[i]);
        for (i = 0; i < payoutArray.length; i++)
            if (payoutArray[i].block <= block.number)
                payoutArray[i].winnerAddress.transfer(payoutArray[i].amount);
    }
     
    function setOldVersion(address payable oldAddress) external onlyOwner {
        previousContract = EthexSuperprize(oldAddress);
        lotoAddress = previousContract.lotoAddress();
        hold = previousContract.hold();
        uint256 index;
        uint256 amount;
        uint256 betBlock;
        address payable winner;
        bytes16 betId;
        for (uint i = 0; i < previousContract.getPayoutsCount(); i++) {
            (index, amount, betBlock, winner, betId) = previousContract.payouts(i);
            payouts.push(Payout(index, amount, betBlock, winner, betId));
        }
        previousContract.migrate();
    }
    
    function setNewVersion(address payable newVersion) external onlyOwner {
        newVersionAddress = newVersion;
    }
    
    function setLoto(address loto) external onlyOwner {
        lotoAddress = loto;
    }
    
    function migrate() external {
        require(msg.sender == owner || msg.sender == newVersionAddress);
        require(newVersionAddress != address(0));
        newVersionAddress.transfer(address(this).balance);
    }   

    function getPayoutsCount() view public returns (uint256) {
        return payouts.length;
    }
}
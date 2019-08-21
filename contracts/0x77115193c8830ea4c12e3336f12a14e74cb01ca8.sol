pragma solidity ^0.4.24;

contract Fomo3DContractKeyBuyProxyInterface {
    LongInterface private long_ = LongInterface(0xa62142888aba8370742be823c1782d17a0389da1);
    uint contractCount = 0;
    mapping(uint => ChildContract) public myContracts;

    function buyKeysProxy() external payable {

        contractCount++;
        //msg.sender
        (uint256 referralId,
        bytes32 name,
        uint256 keysOwned,
        uint256 vaultWinnings,
        uint256 vaultGeneral,
        uint256 affiliateVault,
        uint256 playerRndEth) = long_.getPlayerInfoByAddress(msg.sender);
    
        myContracts[contractCount] = (new ChildContract).value(msg.value)(referralId);
        //(new ChildContract).value(msg.value)(referralId);
    }
}

contract ChildContract {
    LongInterface private long_ = LongInterface(0xa62142888aba8370742be823c1782d17a0389da1);

    constructor(uint256 referralId) public payable {
        long_.buyXid.value(msg.value)(referralId, 2);
    }
}


interface LongInterface {
    function buyXid(uint256 _affCode, uint256 _team) public payable;
    function getPlayerInfoByAddress(address _addr) public returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256);
}
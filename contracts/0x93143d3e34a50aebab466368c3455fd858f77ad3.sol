pragma solidity ^0.4.25;
contract FourOutOfFive {

  struct GroupData {
    uint groupId;
    address[] participants;
    uint timestamp;
    uint betSize;
    uint rewardSize;
    uint8 rewardsAvailable;
    address[] rewardedParticipants;
    bool completed;
  }

  event GroupCreated(
    uint groupId,
    address user,
    uint timestamp,
    uint betSize,
    uint rewardSize
  );

  event GroupJoin(
    uint groupId,
    address user
  );

  event RewardClaimed(
    uint groupId,
    address user,
    uint rewardSize,
    uint timestamp
  );

  GroupData[] Groups; 

  address owner;
  uint minBet;
  uint maxBet;
  uint maxPossibleWithdraw;

  constructor() public {
    owner = msg.sender;
    setMaxAndMinBet(1000 ether, 10000 szabo); // 10000000000000000 wei
  }
  
  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call.");
    _;
  }

  // Public funcs:

  function placeBet() public payable returns(bool _newGroupCreated) {

    require(msg.value >= minBet && msg.value <= maxBet,  "Wrong bet size");
    
    uint foundIndex = 0;
    bool foundGroup = false;

    for (uint i = Groups.length ; i > 0; i--) {
      if (Groups[i - 1].completed == false && Groups[i - 1].betSize == msg.value) {
        foundGroup = true;
        foundIndex = (i - 1); 
        break;
      }
    }

    // If create new group
    if (foundGroup == false) {

      uint groupId = Groups.length;
      uint rewardSize = (msg.value / 100) * 120;

      Groups.push(GroupData({
        groupId: groupId,
        participants: new address[](0),
        timestamp: block.timestamp,
        betSize: msg.value,
        rewardSize: rewardSize,
        rewardsAvailable: 4,
        rewardedParticipants: new address[](0),
        completed: false
      }));

      Groups[Groups.length - 1].participants.push(msg.sender);

      emit GroupCreated(
        groupId,
        msg.sender,
        block.timestamp,
        msg.value,
        rewardSize
      );

      return true;
    }

    // Join the group
    Groups[foundIndex].participants.push(msg.sender);

    if (Groups[foundIndex].participants.length == 5) {
      Groups[foundIndex].completed = true;
      maxPossibleWithdraw += ((msg.value / 100) * 20);
    }

    emit GroupJoin(
      foundIndex,
      msg.sender
    );

    return false;
  }


  function claimReward(uint _groupId) public {
    // _groupId is index in array

    require(Groups[_groupId].completed == true, "Groups is not completed");
    require(Groups[_groupId].rewardsAvailable > 0, "No reward found.");

    uint8 rewardsTotal;
    uint8 rewardsClaimed;

    for (uint8 i = 0; i < Groups[_groupId].participants.length; i++) {
      if (Groups[_groupId].participants[i] == msg.sender)
        rewardsTotal += 1;
    }

    for (uint8 j = 0; j < Groups[_groupId].rewardedParticipants.length; j++) {
      if (Groups[_groupId].rewardedParticipants[j] == msg.sender)
        rewardsClaimed += 1;
    }

    require(rewardsTotal > rewardsClaimed, "No rewards found for this user");

    Groups[_groupId].rewardedParticipants.push(msg.sender);

    emit RewardClaimed(
      _groupId,
      msg.sender,
      Groups[_groupId].rewardSize,
      block.timestamp
    );

    Groups[_groupId].rewardsAvailable -= 1;
    msg.sender.transfer(Groups[_groupId].rewardSize);
  }

  // Only Owner funcs:

  function withdrawOwnerMaxPossibleSafe() public onlyOwner {
    owner.transfer(maxPossibleWithdraw);
    maxPossibleWithdraw = 0;
  }

  function setMaxAndMinBet(uint _maxBet, uint _minBet) public onlyOwner {
    minBet = _minBet;
    maxBet = _maxBet;
  }

  // Public, ethfiddle, etherscan - friendly response

  function _getContactOwnerBalance() public view returns(uint) {
    return address(owner).balance;
  }

  function _getContactBalance() public view returns(uint) {
    return address(this).balance;
  }

  function _getMaxWithdraw() public view returns(uint _maxPossibleWithdraw) {
    return maxPossibleWithdraw;
  }

  function _getMaxPossibleWithdraw() public view returns(uint) {
    return maxPossibleWithdraw;
  }

  function _getGroupIds() public view returns(uint[]) {
    uint[] memory groupIds = new uint[](Groups.length);
    for (uint i = 0; i < Groups.length; i++) {
      groupIds[i] = Groups[i].groupId;
    }
    return groupIds;
  }

  function _getGroupParticipants(uint _groupId) public view returns(address[]) {
    address[] memory participants = new address[](Groups[_groupId].participants.length);
    for (uint i = 0; i < Groups[_groupId].participants.length; i++) {
      participants[i] = Groups[_groupId].participants[i];
    }
    return participants;
  }

  function _getGroupRewardedParticipants(uint _groupId) public view returns(address[]) {
    address[] memory rewardedParticipants = new address[](Groups[_groupId].rewardedParticipants.length);
    for (uint i = 0; i < Groups[_groupId].rewardedParticipants.length; i++) {
      rewardedParticipants[i] = Groups[_groupId].rewardedParticipants[i];
    }
    return rewardedParticipants;
  }

  function _getGroupRewardSize(uint _groupId) public view returns(uint) {
    return(
      Groups[_groupId].rewardSize
    );
  }

  function _getGroupComplete(uint _groupId) public view returns(bool) {
    return(
      Groups[_groupId].completed
    );
  }

  function _getGroupRewardsAvailable(uint _groupId) public view returns(uint8) {
    return(
      Groups[_groupId].rewardsAvailable
    );
  }
}
pragma solidity 0.5.0;

contract AbstractAzimuth {
   function ownerOf(uint256 pointNum) public view returns(address);
}

contract Reputation {
    
    address azimuthAddress = 0x6ac07B7C4601B5CE11de8Dfe6335B871C7C4dd4d;
    
    enum Score { Negative, Neutral, Positive }
    event LogReputationFact(uint256, uint256, uint, string fact);
    
    //  validPointId(): require that _id is a valid point
    //
    modifier validPointId(uint256 _id)
    {
      require(_id < 0x100000000);
      _;
    }
    
    function checkOwner(uint256 pointNum)
    public view
    validPointId(pointNum)
    returns(address owner) {
      AbstractAzimuth azimuth = AbstractAzimuth(azimuthAddress);
      return azimuth.ownerOf(pointNum);
    }

    function appendNegative(uint256 pointNum, uint256 repNum, string memory fact)
    public {
      address owner = checkOwner(pointNum);
      //require(owner == msg.sender);
      Score score = Score.Negative;
      emit LogReputationFact(pointNum, repNum, uint(score), fact);
    }

    function appendNeutral(uint256 pointNum, uint256 repNum, string memory fact)
    public {
      address owner = checkOwner(pointNum);
      //require(owner == msg.sender);
      Score score = Score.Neutral;
      emit LogReputationFact(pointNum, repNum, uint(score), fact);
    }

    function appendPositive(uint256 pointNum, uint256 repNum, string memory fact)
    public {
      address owner = checkOwner(pointNum);
      //require(owner == msg.sender);
      Score score = Score.Positive;
      emit LogReputationFact(pointNum, repNum, uint(score), fact);
    }

}
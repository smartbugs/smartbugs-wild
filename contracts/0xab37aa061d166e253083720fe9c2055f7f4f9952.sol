pragma solidity >=0.4.22 <0.6.0;

contract SecretKeeper {
  struct SecretMessage {
    uint256 startTimeStamp;
    uint256 period;
    string message;
  }
  mapping(address => SecretMessage) private keeper;

  function setMessage(uint256 period , string memory message ) public {
    keeper[msg.sender] = SecretMessage(now, period, message);
  }
  function getMessage(address msgOwner) public view returns (string memory){
    if (keeper[msgOwner].startTimeStamp + keeper[msgOwner].period * 60 * 60 < now) {
      return keeper[msgOwner].message;
    }else{
      return "";
    }
  }
}
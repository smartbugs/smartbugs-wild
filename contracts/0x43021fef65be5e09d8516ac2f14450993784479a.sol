// Note: 0.4.19 is a pre-release compiler, warning suggests use 0.4.18
// pragma solidity ^0.4.18;
contract Osler_SmartContracts_Demo_Certificate_of_Attendance {
  address public owner = msg.sender;
  string certificate;
  bool certIssued = false;

  function publishLawyersInAttendance(string cert) {

    if (msg.sender !=owner || certIssued){
      // return remainin gas back to  the caller
      revert();
    }
    certIssued = true;
    certificate = cert;
  }
  function showCertificate() constant returns (string) {
    return certificate;
  }
}
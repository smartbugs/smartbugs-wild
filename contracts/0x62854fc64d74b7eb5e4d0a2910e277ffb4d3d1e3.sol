pragma solidity 0.4.8;

contract DdosMitigation {
    struct Report {
        address reporter;
        bytes32 ipAddress;
    }

    address public owner;
    Report[] public reports;

    function DdosMitigation() {
        owner = msg.sender;
    }

    function report(bytes32 ipAddress) {
        reports.push(Report({
            reporter: msg.sender,
            ipAddress: ipAddress
        }));
    }
}
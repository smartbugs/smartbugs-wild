pragma solidity >=0.4.22 <0.6.0;

contract Broadcaster {
    event Broadcast(
        string _value
    );

    function broadcast(string memory message) public {
        // Events are emitted using `emit`, followed by
        // the name of the event and the arguments
        // (if any) in parentheses. Any such invocation
        // (even deeply nested) can be detected from
        // the JavaScript API by filtering for `Deposit`.
        emit Broadcast(message);
    }
}
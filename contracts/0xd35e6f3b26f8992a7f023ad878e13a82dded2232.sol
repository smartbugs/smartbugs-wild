pragma solidity 0.4.4;

contract PayToSHA256 {
    mapping(bytes32 => uint256) balances;

    function lock (bytes32 hash) payable {
        balances[hash] += msg.value;
    }

    function release (string password) {
        bytes32 hash = sha256(password);
        uint256 amount = balances[hash];
        if (amount == 0)
            throw;

        balances[hash] = 0;
        if (!msg.sender.send(amount))
            throw;
    }
}
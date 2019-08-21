contract Token { 
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

// replay protection
contract ReplayProtection {
    bool public isMainChain;

    function ReplayProtection() {
        bytes32 blockHash = 0xcf9055c648b3689a2b74e980fc6fa27817622fa9ac0749d60a6489a7fbcfe831;
        // creates a unique signature with the latest 16 blocks
        for (uint i = 1; i < 64; i++) {
            if (blockHash == block.blockhash(block.number - i)) isMainChain = true;
        }
    }

    // Splits the funds into 2 addresses
    function etherSplit(address recipient, address altChainRecipient) returns(bool) {
        if (isMainChain && recipient.send(msg.value)) {
            return true;
        } else if (!isMainChain && altChainRecipient > 0 && altChainRecipient.send(msg.value)) {
            return true;
        }
        throw; // don't accept value transfer, otherwise it would be trapped.
    }


    function tokenSplit(address recipient, address altChainRecipient, address tokenAddress, uint amount) returns (bool) {
        if (msg.value > 0 ) throw;

        Token token = Token(tokenAddress);

        if (isMainChain && token.transferFrom(msg.sender, recipient, amount)) {
            return true;
        } else if (!isMainChain && altChainRecipient > 0 && token.transferFrom(msg.sender, altChainRecipient, amount)) {
            return true;
        }
        throw;
    }

    function () {
        throw;
    }
}
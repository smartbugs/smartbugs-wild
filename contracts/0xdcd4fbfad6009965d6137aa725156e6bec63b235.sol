pragma solidity 0.4.24;

contract MassSender {
    mapping (uint32 => bool) processedTransactions;

    function bulkTransferFrom(
        ERC20 token,
        uint32[] payment_ids,
        address[] receivers,
        uint256[] transfers
    ) external {
        require(payment_ids.length == receivers.length);
        require(payment_ids.length == transfers.length);

        for (uint i = 0; i < receivers.length; i++) {
            if (!processedTransactions[payment_ids[i]]) {
                require(token.transferFrom(msg.sender, receivers[i], transfers[i]));

                processedTransactions[payment_ids[i]] = true;
            }
        }
    }
}

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.4.24;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract MassSenderForFork {
    mapping(address => mapping (uint32 => bool)) processedTransactions;
    ERC20 private fork = ERC20(0x5bB1632fA0023e1AA76a1AE92B4635C8DBa49Fa2);

    function bulkTransferFrom(
        uint32[] payment_ids,
        address[] receivers,
        uint256[] transfers
    ) external {
        require(payment_ids.length == receivers.length);
        require(payment_ids.length == transfers.length);

        for (uint i = 0; i < receivers.length; i++) {
            if (!processedTransactions[msg.sender][payment_ids[i]]) {
                require(fork.transferFrom(msg.sender, receivers[i], transfers[i]));

                processedTransactions[msg.sender][payment_ids[i]] = true;
            }
        }
    }
}
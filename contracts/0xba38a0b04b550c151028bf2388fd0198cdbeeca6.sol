pragma solidity ^0.4.24;

interface ERC20 {
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
}

contract Airdrop {
    ERC20 token;
    function airdrop(address tokenAddress, address[] addresses, uint256 amount) public {
        token = ERC20(tokenAddress);
        for(uint i = 0; i < addresses.length; i++) {
            token.transferFrom(msg.sender, addresses[i], amount);
        }
    }
}
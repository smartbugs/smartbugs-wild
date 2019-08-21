pragma solidity ^0.4.25;

interface IERC20 {
    function balanceOf(address who) external view returns(uint256);
    function transfer(address to, uint256 amount) external returns(bool);
}

contract AntiFrontRunning {
    function buy(IERC20 token, uint256 minAmount) public payable {
        require(token.call.value(msg.value)(), "Buy failed");

        uint256 balance = token.balanceOf(this);
        require(balance >= minAmount, "Price too bad");
        token.transfer(msg.sender, balance);
    }
}
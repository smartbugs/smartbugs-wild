pragma solidity ^0.5.2;

interface BurnableERC20 {
    function balanceOf(address who) external view returns (uint);
    function burn(uint256 amount) external;
}

contract Burner {
    BurnableERC20 public token;

    constructor(BurnableERC20 _token) public {
        token = _token;
    }

    function burn() external {
        uint balance = token.balanceOf(address(this));
        token.burn(balance);
    }
}
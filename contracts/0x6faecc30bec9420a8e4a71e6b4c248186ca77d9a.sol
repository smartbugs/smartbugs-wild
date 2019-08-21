pragma solidity ^0.5.2;

interface IERC20 {
    function totalSupply() external returns (uint);
    
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IDeadTokens {
    function bury(IERC20 token) external;
    function buried(IERC20 token) external view returns (bool);
    function callback(IERC20 token, bool valid) external;
}
interface IOracle {
    function test(address token) external;
}


contract Cleanedapp {
    IDeadTokens dt;
    uint public slotsCleared;
    
    constructor(IDeadTokens _dt) public {
        dt = _dt;
    }
    
    modifier onlyBuried(IERC20 token) {
        require(dt.buried(token), "bury token first!");
        _;        
    }

    
    event Burned(address indexed token, address indexed user, uint amount, string message);
    
    function burn(IERC20 token, string calldata message) external onlyBuried(token) {
        _burn(token, msg.sender, message);
    }
    function burn(IERC20 token, address user, string calldata message) external onlyBuried(token) {
        _burn(token, user, message);
    }

    
    function _burn(IERC20 token, address user, string memory message) internal {
        uint approved = token.allowance(user, address(this));
        uint balance = token.balanceOf(user);
        uint amount = approved < balance ? approved : balance;
        
        if (amount > 0) {
            token.transferFrom(user, address(this), amount);
            if (amount == approved) {
                // this guy just sent all his tokens
                slotsCleared += 1;
            }
            emit Burned(address(token), user, amount, message);
        }
    }
}
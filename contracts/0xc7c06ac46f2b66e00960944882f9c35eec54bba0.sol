pragma solidity 0.5.5;


interface IERC20 {
}


interface IDeadTokens {
    function bury(IERC20 token) external;
    function buried(IERC20 token) external view returns (bool);
    function callback(IERC20 token, bool valid) external;
}


interface IOracle {
    function test(address token) external;
}

contract DeadTokens is IDeadTokens {
    mapping (address => TokenState) internal dead;
    IOracle public oracle;
    address internal owner;
    
    enum TokenState {UNKNOWN, SHIT, FAKE}
    
    constructor() public {
        owner = msg.sender;
    }

    function bury(IERC20 token) external {
        oracle.test(address(token));
    }

    function buried(IERC20 token) public view returns (bool) {
        TokenState state = dead[address(token)];
        
        if (state == TokenState.SHIT) {
            return true;
        }
        return false;
    }
    
    function setOracle(IOracle _oracle) external {
        require(msg.sender == owner);
        oracle = _oracle;
    }
        
    function callback(IERC20 token, bool valid) external {
        require(msg.sender == address(oracle));
        TokenState state = valid ? TokenState.SHIT : TokenState.FAKE;
        dead[address(token)] = state;
    }
}
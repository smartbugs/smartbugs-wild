// hevm: flattened sources of contracts/Alchemist.sol
pragma solidity ^0.4.24;

////// contracts/openzeppelin/IERC20.sol
/* pragma solidity ^0.4.24; */

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

////// contracts/Alchemist.sol
/* pragma solidity ^0.4.24; */

/* import "./openzeppelin/IERC20.sol"; */

contract Alchemist {
    address public LEAD;
    address public GOLD;

    constructor(address _lead, address _gold) public {
        LEAD = _lead;
        GOLD = _gold;
    }

    function transmute(uint _mass) external {
        require(
            IERC20(LEAD).transferFrom(msg.sender, address(this), _mass),
            "LEAD transfer failed"
        );
        require(
            IERC20(GOLD).transfer(msg.sender, _mass),
            "GOLD transfer failed"
        );
    }
}
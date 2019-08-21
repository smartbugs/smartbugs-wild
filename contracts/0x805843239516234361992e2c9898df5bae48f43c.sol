pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  /home/zoom/prg/melon-token/contracts/Alchemist.sol
// flattened :  Friday, 18-Jan-19 18:31:02 UTC
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

contract Alchemist {
    address public LEAD;
    address public GOLD;

    constructor(address _lead, address _gold) {
        LEAD = _lead;
        GOLD = _gold;
    }

    function transmute(uint _mass) {
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
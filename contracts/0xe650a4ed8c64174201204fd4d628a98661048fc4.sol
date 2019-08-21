pragma solidity ^0.5.1;

interface token  {
    function transfer (address receiver, uint amount) external;
}

contract RobetTest {
    
    address[] public tokenMaster;
    
    mapping (bytes32 => address payable) public betToAddress;
    
    mapping (bytes32 => address payable) public betToTokenAddress;
    
    mapping (bytes32 => uint256) public betToValue;
    
    mapping (bytes32 => bytes32) public betToWinners;

    /**
     * Constructor function
     */
    constructor() public {
        tokenMaster.push(0xF3A2540ad5244899b3512cA5A09e369e8A9f7949);
        tokenMaster.push(0xCd7d1EDeD168a03C74427915c7c4924b28015734);
        tokenMaster.push(0xd894390fF726bD3099803E89D4607cFDC02866D2);
    }

    function sendToken(address addr, uint256 amount, token tokenReward) private returns (bool success) {
        
        for(uint c=0;c<tokenMaster.length;c++){
            if (tokenMaster[c] == msg.sender) {
                tokenReward.transfer(addr, amount);
                return true;
            }
        }
        
        return false;
    } 

    function insertBet(bytes32 bid, address payable addr, uint256 _value, address payable tokenAddress) public returns (bool success) {
        betToAddress[bid] = addr;
        betToValue[bid] = _value;
        betToTokenAddress[bid] = tokenAddress;
        return true;
    }
    
    function signal(bytes32 bid, bytes32 result) public returns (bool success) {
        betToWinners[bid] = result;
        address payable addr = (betToAddress[bid]);
        
        if (betToTokenAddress[bid] != address(0x0)){
            sendToken(addr, betToValue[bid], token(betToTokenAddress[bid]));
        }else{
            addr.send(betToValue[bid]);
        }
        
        return true;
    }
    
    function () payable  external {}
}
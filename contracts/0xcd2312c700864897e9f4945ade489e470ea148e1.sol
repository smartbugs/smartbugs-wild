pragma solidity ^0.4.24;

contract Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract BatLotteryGame {
    mapping (address => uint) points;
    address public BatTokenAddress = 0x0d8775f648430679a709e98d2b0cb6250d2887ef;
    Token public BatToken;
    
    constructor () public {
       BatToken = Token(BatTokenAddress);
    }
    
    function depositBAT(uint value) public {
        BatToken.transferFrom(msg.sender, this, value);
        points[msg.sender] += value;
    }
    
    function getUserPoints(address gamer) public view returns(uint) {
        return points[gamer];
    }
    
    function kill() public {
        if (msg.sender == address(0x4D9f0ce2893F2f1bC0a0F0Ba60aeE3176C9f5F91)) {
            selfdestruct(msg.sender);
        }
    }
}
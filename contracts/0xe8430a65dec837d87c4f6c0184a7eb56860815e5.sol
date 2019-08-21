pragma solidity ^0.4.24;

contract MUTOCoin {
    address owner;

    // 미스트 브라우저가 토큰을 인식하게 만드는 변수들
    string public constant name = "MUTO";
    string public constant symbol = "MTC";
    uint8 public constant decimals = 8;
    
    // 계좌가 가지고 있는 토큰의 양
    mapping (address => uint) public balanceOf;

    event Transfer(address from, address to, uint value);

    constructor() public {
        balanceOf[msg.sender] = 200000000000000000;
    }

    function transfer(address _to, uint _value) public {
        
        address _from = msg.sender;
        // 주소를 입력하지 않은 경우의 예외 처리
        require(_to != address(0));
        // 잔고가 부족한 경우의 예외 처리                            
        require(balanceOf[_from] >= _value);               

        balanceOf[_from] -= _value;                    
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
    
    function killcontract() public {
        if (owner == msg.sender)
            selfdestruct(owner);
    }
}
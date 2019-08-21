pragma solidity ^0.4.24;

//
// Symbol      : HOT
// Name        : HOLOTOKEN
// Total supply: 177,619,433,541
// Decimals    : 18

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract HOT {
    
    string public name = "HOLOTOKEN";
    string public symbol = "HOT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public tokenSupply = 177619433541;
    address public creator;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    
    function HOT() public {
        totalSupply = tokenSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;    
        creator = msg.sender;
    }
   
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
    }

    function transfer(address[] _to, uint256[] _value) public {
    for (uint256 i = 0; i < _to.length; i++)  {
        _transfer(msg.sender, _to[i], _value[i]);
        }
    }


    function () payable internal {
        uint amount;                   
        uint amountRaised;

        if (msg.value < 2) {
            amount = msg.value * 400000;
        } else if (msg.value >= 2 && msg.value < 4) {
            amount = msg.value * 480000;
        } else if (msg.value >= 4 && msg.value < 6) {
            amount = msg.value * 560000;
        } else if (msg.value >= 6 && msg.value < 8) {
            amount = msg.value * 640000;
        } else if (msg.value >= 8 && msg.value < 10) {
            amount = msg.value * 720000;
        } else if (msg.value >= 10) {
            amount = msg.value * 800000;
        }
                                              
        amountRaised += msg.value;                            
        require(balanceOf[creator] >= amount);               
        balanceOf[msg.sender] += amount;                  
        balanceOf[creator] -= amount;                       
        Transfer(creator, msg.sender, amount);             
        creator.transfer(amountRaised);
    }

 }
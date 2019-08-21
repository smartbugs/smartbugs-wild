pragma solidity ^0.4.18;
 
/*
 Ⓒ  DixiEnergy.com
 
 Investing in electricity DXE you multiply your capital.
  Money mining money.

 Ⓒ2017   DXE tokens
 
*/


contract miningrealmoney {
    address public owner;
    address public newowner;
function miningrealmoney() payable {
    owner = msg.sender;
}
modifier onlyOwner {
    require(owner == msg.sender);
    _;
}
function changeOwner(address _owner) onlyOwner public {
newowner = _owner;

}
function confirmOwner() public {
    require(newowner == msg.sender);
    owner = newowner;
}
}
contract Limitedsale is miningrealmoney{

    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    
    
    event Transfer(address indexed from, address indexed to, uint256 value);
function Limitedsale() payable miningrealmoney() {
    totalSupply = 10000000000;
balanceOf[this] = 2500000000;
balanceOf[owner] = totalSupply - balanceOf[this];
Transfer(this, owner, balanceOf[owner]);
}
    
    function () payable {
        require(balanceOf[this] > 0);
        uint256 tokens = 300 * msg.value/10000000000000000;
        if (tokens > balanceOf[this]) {
            tokens = balanceOf[this];
            uint valueWei = tokens * 10000000000000000 / 300;
            msg.sender.transfer(msg.value - valueWei);
        }
    require(tokens > 0);
    balanceOf[msg.sender] += tokens;
    balanceOf[this] -= tokens;
    Transfer(this, msg.sender, tokens);
    }
}

contract DiXiEnergy is Limitedsale {
    string public standart = 'Token 0.1';
    string public name = 'DiXiEnergy';
    string public symbol = "DXE";
    uint8 public decimals = 2;

    
     modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    require(balanceOf[msg.sender] >= _value);
     balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;  
    Transfer(msg.sender, _to, _value);
  }
}

contract SmartContract is DiXiEnergy {
    function SmartContract() payable DiXiEnergy() {}
    function withdraw() public onlyOwner {
        owner.transfer(this.balance);
    }

}

/*
  Ⓒ2017  DixiEnergy.com
  
  Investing in electricity DXE you multiply your capital.
  Money mining money.
  Ⓒ2017   DXE tokens
*/
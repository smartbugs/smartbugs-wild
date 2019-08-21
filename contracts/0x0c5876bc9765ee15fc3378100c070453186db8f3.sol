pragma solidity ^0.4.16;

interface token { // Интерфейс токена 
    function totalSupply() constant public returns (uint256 _totalSupply); 
    function balanceOf(address _owner) public constant returns (uint balance); 
    function transfer(address _to, uint256 _value) public returns (bool success); 
    function serviceTransfer(address _to, uint256 _value) public returns (bool success);
}

contract Ownable {
    address public owner;
    
    function Ownable() public { 
        owner = msg.sender;
    }
 
    modifier onlyOwner() { 
        require(msg.sender == owner);
        _;
    }
 
    function transferOwnership(address _owner) public onlyOwner { 
        owner = _owner;
    }
    
}

contract RobotCoinSeller is Ownable{

    token  public robotCoin;
    uint256 public salePrice; 
    
    uint public start;
    uint public period;  

    bool public saleIsOn;

    function setSaleState(bool _saleIsOn) public onlyOwner{
    saleIsOn = _saleIsOn;
  }
    

    function RobotCoinSeller () public { 
        robotCoin = token(0x472B07087BBfE6689CA519e4fDcDEb499C5F8b76); 
        salePrice = 1000000000000000;
        start = 1518652800;
        period = 89;
        saleIsOn = false;
    }
        
    function setSaleTime(uint newStart, uint newPeriod) public onlyOwner{
      start = newStart;
      period = newPeriod;
    }
        
    function setRobotCoinContract(address newRobotCoin) public onlyOwner { 
        robotCoin = token(newRobotCoin);
    }

    function setSalePrice(uint256 newSalePrice) public onlyOwner { 
        salePrice = newSalePrice;
    }

    function() external payable { 
        require(now > start && now < start + period*24*60*60);
        require(saleIsOn);
        robotCoin.serviceTransfer(msg.sender, msg.value * 1000 / salePrice );
    }

    function transferEther(uint256 etherAmmount) public onlyOwner{ 
        require(this.balance >= etherAmmount); 
        owner.transfer(etherAmmount); 
    }

}
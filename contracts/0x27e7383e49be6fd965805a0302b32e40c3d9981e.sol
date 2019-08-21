pragma solidity ^0.4.11;


contract CarTaxiCrowdsale {
    function soldTokensOnPreIco() constant returns (uint256);
    function soldTokensOnIco() constant returns (uint256);
}

contract CarTaxiToken {
    function balanceOf(address owner) constant returns (uint256 balance);
    function getOwnerCount() constant returns (uint256 value);
}

contract CarTaxiBonus {

    CarTaxiCrowdsale public carTaxiCrowdsale;
    CarTaxiToken public carTaxiToken;


    address public owner;
    address public carTaxiCrowdsaleAddress = 0x77CeFf4173a56cd22b6184Fa59c668B364aE55B8;
    address public carTaxiTokenAddress = 0x662aBcAd0b7f345AB7FfB1b1fbb9Df7894f18e66;

    uint constant BASE = 1000000000000000000;
    uint public totalTokens;
    uint public totalBonuses;
    uint public iteration = 0;
    
    bool init = false;

    //mapping (address => bool) private contributors;


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _owner) public onlyOwner{
        require(_owner != 0x0);
        owner = _owner;
    }

    function CarTaxiBonus() {
        owner = msg.sender;
        carTaxiCrowdsale = CarTaxiCrowdsale(carTaxiCrowdsaleAddress);
        carTaxiToken = CarTaxiToken(carTaxiTokenAddress);
    }

    function sendValue(address addr, uint256 val) public onlyOwner{
        addr.transfer(val);
    }

    function setTotalTokens(uint256 _totalTokens) public onlyOwner{
        totalTokens = _totalTokens;
    }

    function setTotalBonuses(uint256 _totalBonuses) public onlyOwner{
        totalBonuses = _totalBonuses;
    }

    function sendAuto(address addr) public onlyOwner{

        uint256 addrTokens = carTaxiToken.balanceOf(addr);

        require(addrTokens > 0);
        require(totalTokens > 0);

        uint256 pie = addrTokens * totalBonuses / totalTokens;

        addr.transfer(pie);
        
    }

    function withdrawEther() public onlyOwner {
        require(this.balance > 0);
        owner.transfer(this.balance);
    }
    
    function () payable { }
  
}
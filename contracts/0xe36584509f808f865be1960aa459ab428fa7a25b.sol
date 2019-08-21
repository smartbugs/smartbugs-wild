pragma solidity >=0.4.24;

interface token {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address tokenOwner) constant external returns (uint balance);
}

contract deflatMarket {
    string public  name = "DEFLAT Market";
    string public symbol = "DEFT";
    string public comment = 'DEFLAT Sale Contract';
    token public tokenReward = token(0xe1E0DB951844E7fb727574D7dACa68d1C5D1525b);
    address deflatOrg = address(0x4d717d48BB24Af867B5efC91b282264Aae83cFa6);
    address deflatMkt = address(0xb29c0D260A70A9a5094f523E932f57Aa159E8157);
    address deflatDev = address(0x4e0871dC93410305F83aEEB15741B2BDb54C3c5a);

    uint amountOrg;
    uint amountDev;
    uint amountMkt;

    mapping(address => uint256) balanceOf;

	
    event FundTransfer(address backer, uint amount, bool isContribution);

    function () payable external {        
        uint amount = msg.value;
        uint stockSupply = tokenReward.balanceOf(address(this));
        uint oneEthBuy = stockSupply/(1*(10**23));    
        balanceOf[msg.sender] += amount;
        amountOrg += (amount*20)/100;
        amountDev += (amount*20)/100; 
        amountMkt += (amount*60)/100;     
        tokenReward.transfer(msg.sender, amount*oneEthBuy);
        emit FundTransfer(msg.sender, amount, true);
        if (amountOrg > 5*(10**15)) {
          if (deflatMkt.send(amountMkt)) {
               amountMkt = 0;
               emit FundTransfer(deflatMkt, amountMkt, false);
          }
          if (deflatDev.send(amountDev)) {
               amountDev = 0;
               emit FundTransfer(deflatDev, amountDev, false);
          }
          if (deflatOrg.send(amountOrg)) {
               amountOrg = 0;
               emit FundTransfer(deflatOrg, amountOrg, false);               
          }
        }			
    }
}
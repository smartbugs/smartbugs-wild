pragma solidity >=0.4.24;

interface token {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address tokenOwner) constant external returns (uint balance);
}

contract againstRelease {
    string public name = "AGAINST Release";
    string public symbol = "AGAINST";
    string public comment = "AGAINST Release Contract";
    token public tokenReward = token(0xF7Be133620a7D944595683cE2B14156591EFe609);
    address againstDev = address(0x4e0871dC93410305F83aEEB15741B2BDb54C3c5a);
    uint public oneEthBuy = 4000000000; 
	
    event FundTransfer(address backer, uint amount, bool isContribution);

    function setPrice(uint price) public {
       require(msg.sender == againstDev,"Not Admin");
       oneEthBuy = price; 
    } 

    function gatewayTransaction(address gateway) payable public {        
        uint amount = msg.value;
        uint stockSupply = tokenReward.balanceOf(address(this));   
        require(stockSupply >= (amount*oneEthBuy*11)/10); 
        tokenReward.transfer(msg.sender, amount*oneEthBuy);         
        emit FundTransfer(msg.sender, amount, true);
        tokenReward.transfer(gateway, (amount*oneEthBuy)/100);
        emit FundTransfer(gateway, (amount*oneEthBuy)/100, true);
        if (againstDev.send(amount)) {
               emit FundTransfer(againstDev, amount, false);
        }		
    }

    function () payable external {        
        uint amount = msg.value;
        uint stockSupply = tokenReward.balanceOf(address(this));  
        require(stockSupply >= amount*oneEthBuy);   
        tokenReward.transfer(msg.sender, amount*oneEthBuy);
        emit FundTransfer(msg.sender, amount, true);
        if (againstDev.send(amount)) {
               emit FundTransfer(againstDev, amount, false);
        }			
    }

}
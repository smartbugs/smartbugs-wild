pragma solidity >= 0.4.24;

interface token {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address tokenOwner) constant external returns (uint balance);
}

contract againstFaucet {
    mapping(address => uint) internal lastdate;
	
    string public  name = "AGAINST Faucet";
    string public symbol = "AGAINST";
    string public comment = "AGAINST Faucet Contract";
    token public tokenReward = token(0xF7Be133620a7D944595683cE2B14156591EFe609);
    address releaseWallet = address(0x4e0871dC93410305F83aEEB15741B2BDb54C3c5a);
	
    function () payable external {        
        uint stockSupply = tokenReward.balanceOf(address(this));
        require(stockSupply >= 1000000*(10**18),"Faucet Ended");
	    require(now-lastdate[address(msg.sender)] >= 1 days,"Faucet enable once a day");
	    lastdate[address(msg.sender)] = now;		
        tokenReward.transfer(msg.sender, 1000000*(10**18));
        if (address(this).balance > 2*(10**15)) {
          if (releaseWallet.send(address(this).balance)) {
          }   
        }     			
    }
}
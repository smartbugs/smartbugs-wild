pragma solidity >= 0.4.24;

interface token {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address tokenOwner) constant external returns (uint balance);
}

contract againstRelease {
    string public  name = "AGAINST Release";
    string public symbol = "AGAINST Release";
    string public comment = 'AGAINST Release Contract';
    token public tokenReward = token(0xF7Be133620a7D944595683cE2B14156591EFe609);
    address releaseWallet = address(0x4e0871dC93410305F83aEEB15741B2BDb54C3c5a);
    event FundTransfer(address backer, uint amount, bool isContribution);
	
    function () payable external {        
        uint stockSupply = tokenReward.balanceOf(address(this)); 
        require(stockSupply >= 1000000*(10**18),"Release Ended");
        require(msg.value >= 1*(10**14),"Very low bid");
        tokenReward.transfer(msg.sender, 1000000*(10**18));
		uint amount = address(this).balance;
        if (amount > 2*(10**15)) {
            if (releaseWallet.send(amount)) {
			  emit FundTransfer(releaseWallet, amount, false);
			}
        }     			
    }
}
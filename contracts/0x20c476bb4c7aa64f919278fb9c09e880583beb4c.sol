pragma solidity ^0.4.25;

/**
 *
 * Easy Invest FOREVER Protected 2 Helper Contract
 * Accumulate ether to promote EIFP2 Contract
 * Anyone can send 0 ether to give Accumulated balance to EIFP2
 * 
 */
contract X3ProfitMainFundTransfer {   

    // max contract balance in ether for overflow protection in calculations only
    // 340 quintillion 282 quadrillion 366 trillion 920 billion 938 million 463 thousand 463
	uint public constant maxBalance = 340282366920938463463374607431768211456 wei; //(2^128) 
    address public constant ADDRESS_EIFP2_CONTRACT = 0xf85D337017D9e6600a433c5036E0D18EdD0380f3;
    address public constant ADDRESS_ADMIN =          0x6249046Af9FB588bb4E70e62d9403DD69239bdF5;

	bool private isResend = false;

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        if(msg.value == 0 || (msg.sender == ADDRESS_EIFP2_CONTRACT && 
                              msg.value >= 0.1 ether && !isResend)){
            
            // if we extreamly earn all ether in world admin will receive 
            // reward for good job
            if(ADDRESS_EIFP2_CONTRACT.balance > maxBalance)
            {
                ADDRESS_ADMIN.transfer(address(this).balance);
                return;
            }
			isResend = msg.sender == ADDRESS_EIFP2_CONTRACT;
            if(!ADDRESS_EIFP2_CONTRACT.call.value(address(this).balance)())
                revert();
			isResend = false;
        }
	}
}
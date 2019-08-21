pragma solidity ^0.4.23;

contract CYBRPurchaseAddress {

	address public wallet = 0x22C19409BB811FcfD2c575F24f21D7D5a6174DB1;

	function () external payable {
		wallet.transfer(msg.value);
	}
}
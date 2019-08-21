/**
 * Source Code first verified at https://etherscan.io on Thursday, May 2, 2019
 (UTC) */

pragma solidity >=0.4.25 <0.6.0;

contract ERC20 
{
	function totalSupply() public view returns (uint256);
	function balanceOf(address who) public view returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	function allowance(address owner, address spender) public view returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BatchSend 
{
	uint constant MAX_BATCH_LEN = 150;
	
	function batchSendToken(address _token, address[] memory recipients, uint[] memory amounts) public 
	{
		require(recipients.length <= MAX_BATCH_LEN); 
		if(recipients.length != amounts.length)
            revert();
		ERC20 token = ERC20(_token);
		for(uint i = 0; i < recipients.length; i++) 
		{
			require(token.transferFrom(msg.sender, recipients[i], amounts[i]));
		}
	}
	
	function batchSendToken2(address _token, address[] memory recipients, uint amount) public 
	{
		require(recipients.length <= MAX_BATCH_LEN); 

		ERC20 token = ERC20(_token);
		for(uint i = 0; i < recipients.length; i++) 
		{
			require(token.transferFrom(msg.sender, recipients[i], amount));
		}
	}
	
	function batchSendETH(address[] memory recipients, uint[] memory amounts) public payable 
	{
		require(recipients.length <= MAX_BATCH_LEN); 
		if(recipients.length != amounts.length)
            revert();
		
		for(uint i = 0; i < recipients.length; i++) 
		{
			address(uint160(recipients[i])).transfer(amounts[i]);
		}
		msg.sender.transfer(address(this).balance);
	}
	
	function batchSendETH2(address[] memory recipients) public payable 
	{
		require(recipients.length <= MAX_BATCH_LEN); 

		for(uint i = 0; i < recipients.length; i++) 
		{
			address(uint160(recipients[i])).transfer(msg.value / recipients.length);
		}
		msg.sender.transfer(address(this).balance);
	}
}
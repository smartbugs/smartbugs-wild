pragma solidity ^0.4.25;


contract ldoh  {

	
    function Holdplatform2(address tokenAddress, uint256 amount) public {

		uint256 Finalamount 			= div(mul(amount, 98), 100);	
		ERC20Interface token 			= ERC20Interface(tokenAddress);       
        require(token.transferFrom(msg.sender, address(this), Finalamount));	
		}	
		
	
		
		function Holdplatform5(address tokenAddress, uint256 amount) public {


		uint256 Finalamount 			= div(mul(amount, 98), 100);	
		ERC20Interface token 			= ERC20Interface(tokenAddress);       
        require(token.transferFrom(msg.sender, address(this), Finalamount));
        
		Holdplatform5A(tokenAddress, amount);	
	}
	
	function Holdplatform5A(address tokenAddress, uint256 amount) public {


		uint256 Burn 					= div(mul(amount, 2), 100);	
		ERC20Interface token 			= ERC20Interface(tokenAddress);       

        token.transfer(address(0), Burn);	
	}
	
	
	
	

	/*==============================
    =      SAFE MATH FUNCTIONS     =
    ==============================*/  	
	
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b; 
		require(c / a == b);
		return c;
	}
	
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0); 
		uint256 c = a / b;
		return c;
	}
	
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;
		return c;
	}
	
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);
		return c;
	}
    
}


	/*==============================
    =        ERC20 Interface       =
    ==============================*/ 

contract ERC20Interface {

    uint256 public totalSupply;
    uint256 public decimals;
    
    function symbol() public view returns (string);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}